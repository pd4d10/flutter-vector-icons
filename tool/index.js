// @ts-check
const fs = require("fs-extra");
const path = require("path");
const { execSync } = require("child_process");
const _ = require("lodash");
const yaml = require("js-yaml");

const reservedWords = ["new", "sync", "switch", "try", "null", "class"];

// * Replace - with _
// * Language reserved words: new -> new_icon
// * Key starts with number: 500px -> icon_500px
function normalizeKey(
  /** @type {string} */
  key
) {
  key = key.replace(/-/g, "_");
  var _key = key;
  if (reservedWords.includes(key)) {
    key = key + "_icon";
  }
  if (/^\d/.test(key)) {
    key = "icon_" + key;
  }
  if (key != _key) {
    console.log(`[name conversion]: ${_key} -> ${key}`);
  }
  return key;
}

const resolve = (p) => path.resolve(__dirname, p);

const allFonts = fs
  .readdirSync(resolve("node_modules/react-native-vector-icons/Fonts"))
  .map((v) => v.slice(0, -4));
const fonts = allFonts.filter((v) => !v.includes("FontAwesome5"));
const fa5Fonts = allFonts.filter((v) => v.includes("FontAwesome5"));

fs.emptyDirSync(resolve("../lib/src"));
fs.emptyDirSync(resolve("../fonts"));

// copy fonts
fs.copySync(
  resolve(`node_modules/react-native-vector-icons/Fonts`),
  resolve(`../fonts`)
);

// pubspec
const pubspec = yaml.load(fs.readFileSync(resolve("../pubspec.yaml"), "utf-8"));
pubspec["flutter"].fonts = allFonts.map((name) => ({
  family: name,
  fonts: [{ asset: `fonts/${name}.ttf` }],
}));
fs.writeFileSync(
  resolve("../pubspec.yaml"),
  yaml.dump(pubspec, { quotingType: '"' })
);

// lib/flutter_vector_icons.dart
let entryCode = "library flutter_vector_icons;";
allFonts.forEach((name) => {
  entryCode += `export 'src/${_.snakeCase(name)}.dart';`;
});
fs.writeFileSync(resolve("../lib/flutter_vector_icons.dart"), entryCode);

// lib/src/*.dart
// example/lib/data.dart
const webData = {};
fonts.forEach((name) => {
  const iconMap = fs.readJsonSync(
    resolve(`node_modules/react-native-vector-icons/glyphmaps/${name}.json`)
  );
  webData[name] = {};

  let code = `import 'package:flutter/widgets.dart'; class ${name} {`;
  for (var [key, value] of Object.entries(iconMap)) {
    webData[name][normalizeKey(key)] = value;

    code += `static const IconData ${normalizeKey(
      key
    )} = IconData(${value}, fontFamily: "${name}", fontPackage: "flutter_vector_icons");`;
  }
  code += "}";

  fs.writeFileSync(resolve(`../lib/src/${_.snakeCase(name)}.dart`), code);
  console.log(`${name} done`);
});

// font awesome 5
const fa5Meta = fs.readJsonSync(
  resolve(
    `node_modules/react-native-vector-icons/glyphmaps/FontAwesome5Free_meta.json`
  )
);
const fa5GlyphMap = fs.readJsonSync(
  resolve(
    "node_modules/react-native-vector-icons/glyphmaps/FontAwesome5Free.json"
  )
);

fa5Fonts.forEach((name) => {
  let code = `import 'package:flutter/widgets.dart'; class ${_.upperFirst(
    _.camelCase(name)
  )} {`;

  // FontAwesome5_Brands -> brands
  const groupKey = name.split("_")[1].toLowerCase();
  webData[name] = {};
  for (let key of fa5Meta[groupKey]) {
    webData[name][normalizeKey(key)] = fa5GlyphMap[key];

    var codePoint = fa5GlyphMap[key];
    if (codePoint == null) {
      throw new Error(`codePoint null: ${name}, ${key}`);
    }
    code += `static const IconData ${normalizeKey(
      key
    )} = IconData(${codePoint}, fontFamily: "${name}", fontPackage: "flutter_vector_icons");`;
  }
  code += "}";

  fs.writeFileSync(resolve(`../lib/src/${_.snakeCase(name)}.dart`), code);
  console.log(`${name} done`);
});

fs.writeFileSync(
  resolve("../example/lib/data.dart"),
  `const data = ${JSON.stringify(webData)};`
);
console.log(`data done`);

execSync("flutter dartfmt lib/*.dart lib/*/*.dart example/lib/*.dart", {
  cwd: resolve(".."),
});
