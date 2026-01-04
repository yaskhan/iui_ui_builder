module main

import isaiahpatton.iui
import gg
import os
import json
import uibuilder

// Main application structure
pub struct UIBuilder {
mut:
    window       &iui.Window
    palette      &iui.NavPane
    canvas       &iui.ScrollView
    properties   &iui.Panel
    structure    &iui.Tree2
    console      &iui.Textbox
    current_file string
    project      uibuilder.Project
    selected     ?uibuilder.ProjectNode
    drag_source  ?string
    drag_target  ?string
}

// Component registry
pub struct ComponentRegistry {
    components map[string]ComponentInfo
}

pub struct ComponentInfo {
    display_name string
    icon         string
    properties   []PropertyInfo
}

pub struct PropertyInfo {
    name         string
    display_name string
    type         string
    default_value string
}

// Initialize the UI Builder
pub fn (mut app UIBuilder) init() {
    // Create main window
    app.window = iui.Window.new(iui.WindowConfig{
        title: 'UI Builder'
        width: 1200
        height: 800
        theme: iui.theme_default()
    })
    
    // Set up the main layout
    app.setup_layout()
    
    // Initialize component registry
    app.setup_component_registry()
    
    // Set up menu
    app.setup_menu()
    
    // Set up toolbar
    app.setup_toolbar()
    
    // Initialize project
    app.project = uibuilder.Project{
        version: '1.0'
        window_settings: uibuilder.WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: uibuilder.ProjectNode{
            type: 'Panel'
            properties: {
                'x': '0'
                'y': '0'
                'width': '800'
                'height': '600'
            }
            layout: uibuilder.LayoutConfig{
                type: 'BoxLayout'
                params: {
                    'ori': '1'  // vertical
                    'vgap': '5'
                }
            }
            children: []
        }
    }
    
    // Update UI
    app.update_canvas()
}

// Set up the main layout structure
fn (mut app UIBuilder) setup_layout() {
    // Create main split view
    mut main_split := iui.SplitView.new(iui.SplitViewConfig{
        bounds: iui.Bounds{0, 0, 0, 0}
        first: iui.Panel.new()
        second: iui.Panel.new()
        h1: 25
        h2: 75
    })
    
    // Left panel - Palette
    mut left_panel := iui.Panel.new(layout: iui.FlowLayout.new(hgap: 5, vgap: 5))
    left_panel.width = 200
    
    // Create component palette
    app.palette = iui.NavPane.new(iui.NavPaneConfig{
        pack: true
        collapsed: false
    })
    left_panel.add_child(app.palette)
    
    // Right panel - Main content area
    mut right_panel := iui.Panel.new(layout: iui.BorderLayout.new())
    
    // Canvas area (center)
    mut canvas_panel := iui.Panel.new()
    canvas_panel.set_background(gg.rgba(240, 240, 240, 255))
    
    app.canvas = iui.ScrollView.new(iui.ScrollViewConfig{
        bounds: iui.Bounds{0, 0, 0, 0}
        view: canvas_panel
        always_show: true
    })
    
    // Properties panel (east)
    app.properties = iui.Panel.new(layout: iui.BoxLayout.new(ori: 1, vgap: 10))
    app.properties.width = 250
    
    // Structure tree (west)
    app.structure = iui.Tree2.new()
    app.structure.width = 200
    
    // Console (south)
    app.console = iui.Textbox.new(iui.TextboxConfig{
        lines: ['Console output...']
        pack: true
    })
    app.console.height = 100
    
    // Add components to right panel
    right_panel.add_child(app.structure, 1)  // west
    right_panel.add_child(app.canvas, 4)     // center
    right_panel.add_child(app.properties, 2) // east
    right_panel.add_child(app.console, 3)    // south
    
    // Add panels to main split
    main_split.children[0].add_child(left_panel)
    main_split.children[1].add_child(right_panel)
    
    // Add to window
    app.window.add_child(main_split)
}

// Set up component registry
fn (mut app UIBuilder) setup_component_registry() {
    // Basic components
    mut registry := ComponentRegistry{
        components: {}
    }
    
    // Button
    registry.components['Button'] = ComponentInfo{
        display_name: 'Button'
        icon: '\uE704'
        properties: [
            PropertyInfo{name: 'text', display_name: 'Text', type: 'string', default_value: 'Button'}
            PropertyInfo{name: 'x', display_name: 'X', type: 'int', default_value: '0'}
            PropertyInfo{name: 'y', display_name: 'Y', type: 'int', default_value: '0'}
            PropertyInfo{name: 'width', display_name: 'Width', type: 'int', default_value: '100'}
            PropertyInfo{name: 'height', display_name: 'Height', type: 'int', default_value: '30'}
        ]
    }
    
    // Label
    registry.components['Label'] = ComponentInfo{
        display_name: 'Label'
        icon: '\uE70F'
        properties: [
            PropertyInfo{name: 'text', display_name: 'Text', type: 'string', default_value: 'Label'}
            PropertyInfo{name: 'x', display_name: 'X', type: 'int', default_value: '0'}
            PropertyInfo{name: 'y', display_name: 'Y', type: 'int', default_value: '0'}
        ]
    }
    
    // Add more components...
    
    // Containers
    registry.components['Panel'] = ComponentInfo{
        display_name: 'Panel'
        icon: '\uE706'
        properties: [
            PropertyInfo{name: 'x', display_name: 'X', type: 'int', default_value: '0'}
            PropertyInfo{name: 'y', display_name: 'Y', type: 'int', default_value: '0'}
            PropertyInfo{name: 'width', display_name: 'Width', type: 'int', default_value: '200'}
            PropertyInfo{name: 'height', display_name: 'Height', type: 'int', default_value: '200'}
        ]
    }
    
    // Add components to palette
    for name, info in registry.components {
        mut item := iui.NavPaneItem.new(iui.NavPaneItemConfig{
            text: name
            icon: info.icon
        })
        
        // Set up drag and drop
        item.subscribe_event('mouse_down', fn (mut e iui.MouseEvent) {
            app.drag_source = name
            app.log('Drag started: ' + name)
        })
        
        app.palette.add_child(item)
    }
}

// Set up menu bar
fn (mut app UIBuilder) setup_menu() {
    mut menubar := iui.Menubar.new(iui.MenubarConfig{
        children: []
    })
    
    // File menu
    mut file_menu := iui.MenuItem.new(iui.MenuItemConfig{
        text: 'File'
        children: [
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'New'
                click_fn: fn (mut e iui.MouseEvent) {
                    app.new_project()
                }
            })
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'Open'
                click_fn: fn (mut e iui.MouseEvent) {
                    app.open_project()
                }
            })
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'Save'
                click_fn: fn (mut e iui.MouseEvent) {
                    app.save_project()
                }
            })
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'Exit'
                click_fn: fn (mut e iui.MouseEvent) {
                    app.window.gg.quit()
                }
            })
        ]
    })
    
    // View menu
    mut view_menu := iui.MenuItem.new(iui.MenuItemConfig{
        text: 'View'
        children: [
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'Themes'
                children: [
                    iui.MenuItem.new(iui.MenuItemConfig{
                        text: 'Default'
                        click_fn: fn (mut e iui.MouseEvent) {
                            app.window.set_theme(iui.theme_default())
                        }
                    })
                    iui.MenuItem.new(iui.MenuItemConfig{
                        text: 'Dark'
                        click_fn: fn (mut e iui.MouseEvent) {
                            app.window.set_theme(iui.theme_dark())
                        }
                    })
                ]
            })
        ]
    })
    
    // Export menu
    mut export_menu := iui.MenuItem.new(iui.MenuItemConfig{
        text: 'Export'
        children: [
            iui.MenuItem.new(iui.MenuItemConfig{
                text: 'Generate V Code'
                click_fn: fn (mut e iui.MouseEvent) {
                    app.generate_v_code()
                }
            })
        ]
    })
    
    menubar.add_child(file_menu)
    menubar.add_child(view_menu)
    menubar.add_child(export_menu)
    
    app.window.set_menubar(menubar)
}

// Set up toolbar
fn (mut app UIBuilder) setup_toolbar() {
    mut toolbar := iui.Panel.new(layout: iui.FlowLayout.new(hgap: 5, vgap: 5))
    toolbar.height = 30
    
    // New button
    mut new_btn := iui.Button.new(iui.ButtonConfig{
        text: 'New'
        width: 80
        height: 25
    })
    new_btn.subscribe_event('mouse_up', fn (mut e iui.MouseEvent) {
        app.new_project()
    })
    toolbar.add_child(new_btn)
    
    // Open button
    mut open_btn := iui.Button.new(iui.ButtonConfig{
        text: 'Open'
        width: 80
        height: 25
    })
    open_btn.subscribe_event('mouse_up', fn (mut e iui.MouseEvent) {
        app.open_project()
    })
    toolbar.add_child(open_btn)
    
    // Save button
    mut save_btn := iui.Button.new(iui.ButtonConfig{
        text: 'Save'
        width: 80
        height: 25
    })
    save_btn.subscribe_event('mouse_up', fn (mut e iui.MouseEvent) {
        app.save_project()
    })
    toolbar.add_child(save_btn)
    
    // Add toolbar to window
    app.window.add_child(toolbar)
}

// Update the canvas with current project
fn (mut app UIBuilder) update_canvas() {
    // Clear canvas
    if app.canvas.children.len > 0 {
        app.canvas.children.clear()
    }
    
    // Create UI from project structure
    mut panel := app.create_component_from_node(app.project.root_component)
    
    // Add to canvas
    app.canvas.set_view(panel)
    
    // Update structure tree
    app.update_structure_tree()
    
    // Update properties if something is selected
    if app.selected != none {
        app.update_properties()
    }
}

// Create UI component from project node
fn (mut app UIBuilder) create_component_from_node(node uibuilder.ProjectNode) &iui.Component_A {
    mut component := unsafe { nil }
    
    // Create component based on type
    if node.type == 'Button' {
        mut btn := iui.Button.new(iui.ButtonConfig{
            text: node.properties['text']
            bounds: iui.Bounds{
                x: node.properties['x'].int()
                y: node.properties['y'].int()
                width: node.properties['width'].int()
                height: node.properties['height'].int()
            }
        })
        
        // Set up selection
        btn.subscribe_event('mouse_up', fn [mut app] (mut e iui.MouseEvent) {
            app.select_component(btn)
        })
        
        component = btn
    } else if node.type == 'Label' {
        mut lbl := iui.Label.new(iui.LabelConfig{
            text: node.properties['text']
            x: node.properties['x'].int()
            y: node.properties['y'].int()
        })
        
        // Set up selection
        lbl.subscribe_event('mouse_up', fn [mut app] (mut e iui.MouseEvent) {
            app.select_component(lbl)
        })
        
        component = lbl
    } else if node.type == 'Panel' {
        // Create layout if specified
        mut layout := unsafe { nil }
        if node.layout != none {
            if node.layout.type == 'BoxLayout' {
                layout = iui.BoxLayout.new(iui.BoxLayoutConfig{
                    ori: node.layout.params['ori'].int()
                    vgap: node.layout.params['vgap'].int()
                })
            }
        }
        
        mut panel := iui.Panel.new(iui.PanelConfig{
            layout: layout
            width: node.properties['width'].int()
            height: node.properties['height'].int()
        })
        
        // Set position
        panel.x = node.properties['x'].int()
        panel.y = node.properties['y'].int()
        
        // Set up selection
        panel.subscribe_event('mouse_up', fn [mut app] (mut e iui.MouseEvent) {
            app.select_component(panel)
        })
        
        // Add children
        for child_node in node.children {
            mut child := app.create_component_from_node(child_node)
            panel.add_child(child)
        }
        
        component = panel
    }
    
    return component
}

// Update structure tree
fn (mut app UIBuilder) update_structure_tree() {
    // Clear tree
    app.structure.children.clear()
    
    // Add root node
    mut root_node := iui.TreeNode{
        text: app.project.root_component.type
        nodes: []
    }
    
    // Add children recursively
    app.add_tree_nodes(root_node, app.project.root_component.children)
    
    app.structure.add_child(root_node)
}

// Add tree nodes recursively
fn (mut app UIBuilder) add_tree_nodes(parent iui.TreeNode, children []uibuilder.ProjectNode) {
    for child in children {
        mut node := iui.TreeNode{
            text: child.type
            nodes: []
        }
        
        // Add to parent
        parent.nodes << node
        
        // Add children recursively
        app.add_tree_nodes(node, child.children)
    }
}

// Select a component
fn (mut app UIBuilder) select_component(component &iui.Component_A) {
    app.selected = none
    
    // Find the corresponding project node
    mut node := app.find_node_for_component(app.project.root_component, component)
    
    if node != none {
        app.selected = node
        app.update_properties()
        app.log('Selected: ' + node.type)
    }
}

// Find project node for a component (simplified)
fn (mut app UIBuilder) find_node_for_component(parent uibuilder.ProjectNode, component &iui.Component_A) ?uibuilder.ProjectNode {
    // This is a simplified version - in a real implementation, you'd need
    // to track component IDs or use other means to identify components
    
    // For now, just return the parent if it matches the component type
    if parent.type == component.type_name().replace('iui.', '') {
        return parent
    }
    
    // Search in children
    for child in parent.children {
        mut result := app.find_node_for_component(child, component)
        if result != none {
            return result
        }
    }
    
    return none
}

// Update properties panel
fn (mut app UIBuilder) update_properties() {
    if app.selected == none {
        return
    }
    
    // Clear properties panel
    app.properties.children.clear()
    
    // Add title
    mut title := iui.Label.new(iui.LabelConfig{
        text: 'Properties: ' + app.selected.type
        pack: true
    })
    app.properties.add_child(title)
    
    // Add properties
    for name, value in app.selected.properties {
        mut panel := iui.Panel.new(layout: iui.FlowLayout.new())
        
        mut label := iui.Label.new(iui.LabelConfig{
            text: name + ':'
            width: 100
        })
        
        mut field := iui.TextField.new(iui.TextFieldConfig{
            text: value
            bounds: iui.Bounds{0, 0, 150, 25}
        })
        
        // Set up property change handler
        field.subscribe_event('text_change', fn [mut app, name] (mut e iui.TextChangeEvent) {
            if app.selected != none {
                app.selected.properties[name] = field.text
                app.update_canvas()
                app.log('Property changed: ' + name + ' = ' + field.text)
            }
        })
        
        panel.add_child(label)
        panel.add_child(field)
        app.properties.add_child(panel)
    }
    
    // Add layout properties if applicable
    if app.selected.layout != none {
        mut layout_title := iui.Label.new(iui.LabelConfig{
            text: 'Layout: ' + app.selected.layout.type
            pack: true
        })
        app.properties.add_child(layout_title)
        
        for name, value in app.selected.layout.params {
            mut panel := iui.Panel.new(layout: iui.FlowLayout.new())
            
            mut label := iui.Label.new(iui.LabelConfig{
                text: name + ':'
                width: 100
            })
            
            mut field := iui.TextField.new(iui.TextFieldConfig{
                text: value
                bounds: iui.Bounds{0, 0, 150, 25}
            })
            
            // Set up layout property change handler
            field.subscribe_event('text_change', fn [mut app, name] (mut e iui.TextChangeEvent) {
                if app.selected != none && app.selected.layout != none {
                    app.selected.layout.params[name] = field.text
                    app.update_canvas()
                    app.log('Layout property changed: ' + name + ' = ' + field.text)
                }
            })
            
            panel.add_child(label)
            panel.add_child(field)
            app.properties.add_child(panel)
        }
    }
}

// New project
fn (mut app UIBuilder) new_project() {
    app.project = uibuilder.Project{
        version: '1.0'
        window_settings: uibuilder.WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: uibuilder.ProjectNode{
            type: 'Panel'
            properties: {
                'x': '0'
                'y': '0'
                'width': '800'
                'height': '600'
            }
            layout: uibuilder.LayoutConfig{
                type: 'BoxLayout'
                params: {
                    'ori': '1'  // vertical
                    'vgap': '5'
                }
            }
            children: []
        }
    }
    
    app.current_file = ''
    app.selected = none
    app.update_canvas()
    app.log('New project created')
}

// Open project
fn (mut app UIBuilder) open_project() {
    // In a real implementation, this would show a file dialog
    // For now, we'll use a simple approach
    
    mut path := 'project.json'
    
    if os.exists(path) {
        content := os.read_file(path) or { 
            app.log('Error reading file')
            return
        }
        
        app.project = json.decode(uibuilder.Project, content) or { 
            app.log('Error parsing JSON')
            return
        }
        
        app.current_file = path
        app.selected = none
        app.update_canvas()
        app.log('Project loaded: ' + path)
    } else {
        app.log('File not found: ' + path)
    }
}

// Save project
fn (mut app UIBuilder) save_project() {
    if app.current_file == '' {
        app.current_file = 'project.json'
    }
    
    json_content := json.encode(app.project)
    os.write_file(app.current_file, json_content) or { 
        app.log('Error saving file')
        return
    }
    
    app.log('Project saved: ' + app.current_file)
}

// Generate V code
fn (mut app UIBuilder) generate_v_code() {
    code := uibuilder.generate_v_code(app.project)

    // Show code in console
    app.console.lines = code.split('\n')
    app.log('V code generated')
}

// Log message to console
fn (mut app UIBuilder) log(message string) {
    app.console.lines << message
    // Scroll to bottom
    app.console.scroll_i = app.console.lines.len
}

// Main function
fn main() {
    mut app := UIBuilder{}
    app.init()
    app.window.run()
}
