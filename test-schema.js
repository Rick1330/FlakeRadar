const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const fs = require("fs");
const path = require("path");

// Create AJV instance with draft 2020 support
const ajv = new Ajv({ strict: true, allErrors: true });
addFormats(ajv); // Add support for formats like uri-reference

// Load schema
const schemaPath = path.join(__dirname, "schemas", "issues.seed.schema.json");
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf-8"));

// Load seed data
const seedPath = path.join(__dirname, "issues", "seed.json");
const seed = JSON.parse(fs.readFileSync(seedPath, "utf-8"));

// Compile schema
const validate = ajv.compile(schema);

// Validate seed data
const valid = validate(seed);

if (valid) {
  console.log("✓ Seed file is valid according to the schema");
  process.exit(0);
} else {
  console.error("✗ Seed file validation failed:");
  console.error(validate.errors);
  process.exit(1);
}