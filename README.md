# VocalPoint QField Plugin

The VocalPoint QField Plugin enables quick and efficient digitization of information at a point based on your current location using speech-to-text technology. The plugin automatically parses spoken input and populates the relevant fields in your QField forms, separating each field and its value with a semicolon (`;`).

## How It Works

When you use speech-to-text, the plugin will convert your spoken words into text and populate the fields (first word) with their values (any text following the first word until the next semicolon) as follows:

```text
Name this is a note being taken by speech to text; Note this text will be filled on note field
```

In QField, this input will automatically populate a new form at the specified point, filling the fields with the corresponding data, as shown below:

| Field | Value                                        |
| ----- | -------------------------------------------- |
| Name  | this is a note being taken by speech to text |
| Note  | this text will be filled on note field       |

Fields with default values evaluated by expressions will function as expected.

## Requirements

- **Location Services**: Ensure that location services are enabled on your device.
- **Point Layers**: The plugin currently supports digitization only on Point layers.
- **Field Naming**: It is recommended that fields and layers intended for use with this plugin be single-word and start with an uppercase letter (e.g., `Note`).
- **Multi-Field Input**: To populate multiple fields, separate each field name and value with a semicolon.
