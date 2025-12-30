module uibuilder

import json

fn test_generate_v_code_all_components() {
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 1024
            height: 768
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {
                'width': '1024'
                'height': '768'
            }
            layout: LayoutConfig{
                type: 'BoxLayout'
                params: {
                    'ori': '1'
                    'vgap': '10'
                }
            }
            children: [
                // Input Controls
                ProjectNode{
                    type: 'TextField'
                    properties: {
                        'text': 'Enter name'
                        'x': '10'
                        'y': '10'
                        'width': '200'
                        'height': '25'
                    }
                }
                ProjectNode{
                    type: 'Textbox'
                    properties: {
                        'text': 'Description'
                        'x': '10'
                        'y': '45'
                        'width': '300'
                        'height': '100'
                    }
                }
                ProjectNode{
                    type: 'Checkbox'
                    properties: {
                        'text': 'Remember me'
                        'x': '10'
                        'y': '155'
                        'width': '120'
                        'height': '20'
                        'selected': 'true'
                    }
                }
                ProjectNode{
                    type: 'Switch'
                    properties: {
                        'text': 'Enable notifications'
                        'x': '10'
                        'y': '185'
                        'width': '200'
                        'height': '20'
                        'selected': 'false'
                    }
                }
                ProjectNode{
                    type: 'Slider'
                    properties: {
                        'x': '10'
                        'y': '215'
                        'min': '0'
                        'max': '100'
                        'value': '50'
                        'direction': 'hor'
                    }
                }
                ProjectNode{
                    type: 'Progressbar'
                    properties: {
                        'x': '10'
                        'y': '245'
                        'width': '200'
                        'height': '20'
                        'value': '75'
                    }
                }
                // Display Controls
                ProjectNode{
                    type: 'Image'
                    properties: {
                        'file': 'logo.png'
                        'x': '10'
                        'y': '275'
                        'width': '100'
                        'height': '100'
                    }
                }
                ProjectNode{
                    type: 'Hyperlink'
                    properties: {
                        'text': 'Visit us'
                        'url': 'https://example.com'
                        'x': '10'
                        'y': '385'
                    }
                }
                // Layout Controls
                ProjectNode{
                    type: 'ScrollView'
                    properties: {
                        'x': '220'
                        'y': '10'
                        'width': '300'
                        'height': '200'
                    }
                }
                ProjectNode{
                    type: 'Tabbox'
                    properties: {
                        'x': '530'
                        'y': '10'
                        'width': '400'
                        'height': '300'
                    }
                }
                ProjectNode{
                    type: 'SplitView'
                    properties: {
                        'x': '220'
                        'y': '220'
                        'width': '400'
                        'height': '300'
                        'h1': '50'
                        'h2': '50'
                        'min_percent': '30'
                    }
                }
                ProjectNode{
                    type: 'NavPane'
                    properties: {
                        'x': '10'
                        'y': '410'
                        'width': '200'
                        'height': '300'
                        'collapsed': 'false'
                    }
                }
                // Layout Managers (as nested children)
                ProjectNode{
                    type: 'Panel'
                    properties: {
                        'x': '640'
                        'y': '320'
                        'width': '300'
                        'height': '200'
                    }
                    layout: LayoutConfig{
                        type: 'FlowLayout'
                        params: {
                            'hgap': '10'
                            'vgap': '10'
                        }
                    }
                    children: [
                        ProjectNode{
                            type: 'Button'
                            properties: {
                                'text': 'Nested Button 1'
                                'width': '100'
                                'height': '30'
                            }
                        }
                        ProjectNode{
                            type: 'Button'
                            properties: {
                                'text': 'Nested Button 2'
                                'width': '100'
                                'height': '30'
                            }
                        }
                    ]
                }
            ]
        }
    }

    code := generate_v_code(project)

    // Verify Panel and layout
    assert code.contains('mut panel := iui.Panel.new(iui.PanelConfig{')
    assert code.contains('width: 1024')
    assert code.contains('height: 768')
    assert code.contains('layout: iui.BoxLayout.new(ori: 1, vgap: 10)')

    // Verify Input Controls
    assert code.contains('mut tf1 := iui.TextField.new(iui.TextFieldConfig{')
    assert code.contains("text: 'Enter name'")
    
    assert code.contains('mut tb2 := iui.Textbox.new(iui.TextboxConfig{')
    assert code.contains('lines: [')
    
    assert code.contains('mut cb3 := iui.Checkbox.new(iui.CheckboxConfig{')
    assert code.contains("text: 'Remember me'")
    assert code.contains('selected: true')
    
    assert code.contains('mut sw4 := iui.Switch.new(iui.SwitchConfig{')
    assert code.contains("text: 'Enable notifications'")
    
    assert code.contains('mut slider5 := iui.Slider.new(iui.SliderConfig{')
    assert code.contains('min: 0')
    assert code.contains('max: 100')
    
    assert code.contains('mut pb6 := iui.Progressbar.new(iui.ProgressbarConfig{')
    assert code.contains('val: 75')

    // Verify Display Controls
    assert code.contains('mut img7 := iui.Image.new(iui.ImgConfig{')
    assert code.contains("file: 'logo.png'")
    
    // Verify Layout Controls
    assert code.contains('mut sv9 := iui.ScrollView.new(iui.ScrollViewConfig{')
    
    assert code.contains('mut tabs10 := iui.Tabbox.new(iui.TabboxConfig{')
    
    assert code.contains('mut split11 := iui.SplitView.new(iui.SplitViewConfig{')
    assert code.contains('h1: 50')
    assert code.contains('h2: 50')
    
    assert code.contains('mut nav12 := iui.NavPane.new(iui.NavPaneConfig{')
    assert code.contains('collapsed: false')

    // Verify nested components
    assert code.contains('mut panel13 := iui.Panel.new(iui.PanelConfig{')
    assert code.contains('layout: iui.FlowLayout.new(hgap: 10, vgap: 10)')
    assert code.contains('panel13.add_child(btn14)')
    assert code.contains('panel.add_child(panel13)')
}

fn test_component_registry_complete() {
    // Verify that all components are registered and generate correct code
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {}
            children: [
                ProjectNode{type: 'Button', properties: {}},
                ProjectNode{type: 'Label', properties: {}},
                ProjectNode{type: 'TextField', properties: {}},
                ProjectNode{type: 'Textbox', properties: {}},
                ProjectNode{type: 'Checkbox', properties: {}},
                ProjectNode{type: 'Switch', properties: {}},
                ProjectNode{type: 'Slider', properties: {}},
                ProjectNode{type: 'Progressbar', properties: {}},
                ProjectNode{type: 'Image', properties: {}},
                ProjectNode{type: 'Hyperlink', properties: {}},
                ProjectNode{type: 'ScrollView', properties: {}},
                ProjectNode{type: 'Tabbox', properties: {}},
                ProjectNode{type: 'SplitView', properties: {}},
                ProjectNode{type: 'NavPane', properties: {}},
                ProjectNode{type: 'BoxLayout', properties: {}},
                ProjectNode{type: 'FlowLayout', properties: {}},
                ProjectNode{type: 'BorderLayout', properties: {}},
                ProjectNode{type: 'GridLayout', properties: {}},
                ProjectNode{type: 'CardLayout', properties: {}},
            ]
        }
    }

    code := generate_v_code(project)
    
    // Verify all component types generate correctly
    assert code.contains('mut btn1 := iui.Button.new')
    assert code.contains('mut lbl2 := iui.Label.new')
    assert code.contains('mut tf3 := iui.TextField.new')
    assert code.contains('mut tb4 := iui.Textbox.new')
    assert code.contains('mut cb5 := iui.Checkbox.new')
    assert code.contains('mut sw6 := iui.Switch.new')
    assert code.contains('mut slider7 := iui.Slider.new')
    assert code.contains('mut pb8 := iui.Progressbar.new')
    assert code.contains('mut img9 := iui.Image.new')
    assert code.contains('mut link10 := iui.Hyperlink.new')
    assert code.contains('mut sv11 := iui.ScrollView.new')
    assert code.contains('mut tabs12 := iui.Tabbox.new')
    assert code.contains('mut split13 := iui.SplitView.new')
    assert code.contains('mut nav14 := iui.NavPane.new')
    assert code.contains('mut layout15 := iui.BoxLayout.new')
    assert code.contains('mut layout16 := iui.FlowLayout.new')
    assert code.contains('mut layout17 := iui.BorderLayout.new')
    assert code.contains('mut layout18 := iui.GridLayout.new')
    assert code.contains('mut layout19 := iui.CardLayout.new')
}