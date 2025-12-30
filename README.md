# UI Builder for iui

A visual UI builder application for the iui library, written in V language.

## Features

- **Visual Design**: Drag and drop components to build your UI
- **Property Inspector**: Edit component properties in real-time
- **Structure View**: Hierarchical view of your UI components
- **Code Generation**: Generate V code from your designs
- **Project Management**: Save and load projects
- **Themes**: Support for different visual themes

## Components Supported

### Basic Components
- Button
- Label
- TextField
- Textbox
- Checkbox
- Switch
- Slider
- Progressbar
- Image
- Hyperlink

### Containers
- Panel
- ScrollView
- Tabbox
- SplitView
- NavPane

### Layouts
- BoxLayout
- FlowLayout
- BorderLayout
- GridLayout
- CardLayout

## Usage

1. **Create New Project**: Start with a blank canvas or load an existing project
2. **Add Components**: Drag components from the palette to the canvas
3. **Edit Properties**: Select components and edit their properties
4. **Save Project**: Save your work as a JSON file
5. **Generate Code**: Export your design as V code

## Building

```bash
v main.v
```

## Project Structure

- `main.v`: Main application code
- `project.json`: Example project file (generated when saving)
- `README.md`: This file

## Dependencies

- V language compiler
- iui library (included as a module)

## License

MIT License - See LICENSE file for details
