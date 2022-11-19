import { emptyDirSync } from "https://deno.land/std@0.165.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.165.0/path/mod.ts";
import * as yaml from "https://deno.land/std@0.165.0/encoding/yaml.ts";
import {
  camelCase,
  snakeCase,
  upperFirstCase,
} from "https://deno.land/x/case@2.1.1/mod.ts";

// * Replace - with _
// * Language reserved words: new -> new_icon
// * Key starts with number: 500px -> icon_500px
function normalizeKey(key: string) {
  const reservedWords = ["new", "sync", "switch", "try", "null", "class"];

  key = key.replace(/-/g, "_");
  const originalKey = key;
  if (reservedWords.includes(key)) {
    key = key + "_icon";
  }
  if (/^\d/.test(key)) {
    key = "icon_" + key;
  }
  if (key != originalKey) {
    console.log(`[name conversion]: ${originalKey} -> ${key}`);
  }
  return key;
}

function resolve(...ps: string[]) {
  return path.resolve(path.fromFileUrl(import.meta.url), "..", ...ps);
}

console.log("clean");
emptyDirSync(resolve("lib/src"));
emptyDirSync(resolve("fonts"));

console.log("fetch meta");
const base =
  "https://data.jsdelivr.com/v1/package/npm/react-native-vector-icons";
const {
  tags: { latest },
} = await fetch(base).then((res) => res.json());
console.log("latest", latest);

const metaApi = `${base}@${latest}`;
const blobApi = `https://cdn.jsdelivr.net/npm/react-native-vector-icons@${latest}`;

const fonts = await fetch(`${metaApi}/flat`).then(async (res) => {
  const json: { files: { name: string }[] } = await res.json();
  return json.files
    .filter((file) => file.name.startsWith("/Fonts/"))
    .map((file) => {
      const fileName = file.name.slice("/Fonts/".length);
      const name = path.basename(fileName, path.extname(fileName));

      return {
        fileName,
        name,
        fontUrl: blobApi + file.name,
        glyphmapsUrl: `${blobApi}/glyphmaps/${name}.json`,
      };
    });
});
const fontsNoFa5 = fonts.filter((v) => !v.name.includes("FontAwesome5"));
const fontsFa5 = fonts.filter((v) => v.name.includes("FontAwesome5"));

for (const { name, fileName, fontUrl } of fonts) {
  console.log("download font:", name);

  const res = await fetch(fontUrl);
  const buf = await res.arrayBuffer();
  Deno.writeFileSync(resolve("fonts", fileName), new Uint8Array(buf));
}

console.log("write pubspec.yaml");
const pubspec = yaml.parse(
  Deno.readTextFileSync(resolve("pubspec.yaml"))
) as any;
pubspec.flutter.fonts = fonts.map(({ name, fileName }) => ({
  family: name,
  fonts: [{ asset: `fonts/${fileName}` }],
}));
Deno.writeTextFileSync(
  resolve("pubspec.yaml"),
  yaml.stringify(pubspec, {
    // TODO: quote
  })
);

console.log("write lib/flutter_vector_icons.dart");
let entryCode = "library flutter_vector_icons;";
fonts.forEach(({ name }) => {
  entryCode += `export 'src/${snakeCase(name)}.dart';`;
});
Deno.writeTextFileSync(resolve("lib/flutter_vector_icons.dart"), entryCode);

const webData: Record<string, Record<string, number>> = {};
for (const { name, glyphmapsUrl } of fontsNoFa5) {
  console.log(`write ${name}.dart`);

  const iconMap: Record<string, number> = await fetch(glyphmapsUrl).then(
    (res) => res.json()
  );
  webData[name] = {};

  let code = `import 'package:flutter/widgets.dart'; class ${name} {
static const _family = '${name}';
static const _package = 'flutter_vector_icons';`;

  for (const [key, value] of Object.entries(iconMap)) {
    webData[name][normalizeKey(key)] = value;

    code += `static const ${normalizeKey(
      key
    )} = IconData(${value}, fontFamily: _family, fontPackage: _package);`;
  }
  code += "}";

  Deno.writeTextFileSync(resolve(`lib/src/${snakeCase(name)}.dart`), code);
  console.log(`${name} done`);
}

console.log("fetch fa5 meta");
const fa5Meta = await fetch(
  `${blobApi}/glyphmaps/FontAwesome5Free_meta.json`
).then((res) => res.json());

const fa5GlyphMap = await fetch(
  `${blobApi}/glyphmaps/FontAwesome5Free.json`
).then((res) => res.json());

fontsFa5.forEach(({ name }) => {
  console.log("write dart file", name);

  let code = `import 'package:flutter/widgets.dart'; class ${upperFirstCase(
    camelCase(name)
  )} {
static const _family = '${name}';
static const _package = 'flutter_vector_icons';`;

  // FontAwesome5_Brands -> brands
  const groupKey = name.split("_")[1].toLowerCase();
  webData[name] = {};
  for (const key of fa5Meta[groupKey]) {
    webData[name][normalizeKey(key)] = fa5GlyphMap[key];

    const codePoint = fa5GlyphMap[key];
    if (codePoint == null) {
      throw new Error(`codePoint null: ${name}, ${key}`);
    }
    code += `static const ${normalizeKey(
      key
    )} = IconData(${codePoint}, fontFamily: _family, fontPackage: _package);`;
  }
  code += "}";

  Deno.writeTextFileSync(resolve(`lib/src/${snakeCase(name)}.dart`), code);
});

console.log(`write web data`);
Deno.writeTextFileSync(
  resolve("example/lib/data.dart"),
  `const data = ${JSON.stringify(webData)};`
);

await Deno.run({
  cmd: ["dart", "format", "lib", "example"],
  cwd: resolve("."),
}).status();
