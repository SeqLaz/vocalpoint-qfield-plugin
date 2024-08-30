# VocalPoint QField Plugin

The VocalPoint QField Plugin facilitates quick and efficient digitization of information at a point based on your current location using speech-to-text technology. The plugin automatically parses spoken input and populates the relevant fields in your QField forms, separating each field and its corresponding value with a semicolon (`;`).

## How It Works

When you use speech-to-text, the plugin converts your spoken words into text and populates the fields (the first word) with their values (any text following the first word until the next semicolon) as shown below:

```text
Name this is a note being taken by speech to text; Note this text will be filled on note field
```

In QField, this input automatically populates a new form at the specified point, filling the fields with the corresponding data, as demonstrated here:

| Field | Value                                        |
|-------|----------------------------------------------|
| name  | This is a note being taken by speech to text |
| note  | This text will be filled on note field       |

Fields with default values evaluated by expressions will function as expected.

## Requirements

### General Requirements

- **Location Services**: Ensure that location services are enabled on your device.
- **Point Layers**: The plugin currently supports digitization only on Point layers.
- Due to the behavior of the speech-to-text functionality, the following naming conventions are recommended:
  - **Layer Naming**: Layers intended for use with this plugin should be a single word and start with an uppercase letter (e.g., `Point`).
  - **Field Naming**: Fields intended for use with this plugin should be a single word, in all lowercase letters (e.g., `note`). You can enhance the appearance of your form by using "Alias names" for these fields.
  - **Multi-Field Input**: To populate multiple fields, separate each field name and its value with a semicolon.

https://github.com/user-attachments/assets/c605a100-4044-4cae-a521-33e09c6fd2c0
