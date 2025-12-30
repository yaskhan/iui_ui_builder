module uibuilder

import json

fn test_generate_v_code_includes_label_and_button_children() {
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {
                'x': '0'
                'y': '0'
                'width': '800'
                'height': '600'
            }
            layout: LayoutConfig{
                type: 'BoxLayout'
                params: {
                    'ori': '1'
                    'vgap': '5'
                }
            }
            children: [
                ProjectNode{
                    type: 'Button'
                    properties: {
                        'text': 'Click'
                        'x': '10'
                        'y': '10'
                        'width': '100'
                        'height': '30'
                    }
                }
                ProjectNode{
                    type: 'Label'
                    properties: {
                        'text': 'Hello'
                        'x': '10'
                        'y': '50'
                    }
                }
            ]
        }
    }

    code := generate_v_code(project)

    assert code.contains('mut panel := iui.Panel.new(iui.PanelConfig{')
    assert code.contains('width: 800')
    assert code.contains('height: 600')
    assert code.contains('panel.x = 0')
    assert code.contains('panel.y = 0')

    assert code.contains('layout: iui.BoxLayout.new(ori: 1, vgap: 5)')

    assert code.contains('mut btn1 := iui.Button.new(iui.ButtonConfig{')
    assert code.contains('text: \'Click\'')
    assert code.contains('panel.add_child(btn1)')

    assert code.contains('mut lbl2 := iui.Label.new(iui.LabelConfig{')
    assert code.contains('text: \'Hello\'')
    assert code.contains('panel.add_child(lbl2)')
}

fn test_generate_v_code_nested_panels() {
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {
                'width': '300'
                'height': '200'
            }
            children: [
                ProjectNode{
                    type: 'Panel'
                    properties: {
                        'x': '5'
                        'y': '10'
                        'width': '200'
                        'height': '100'
                    }
                    layout: LayoutConfig{
                        type: 'FlowLayout'
                        params: {
                            'hgap': '5'
                            'vgap': '5'
                        }
                    }
                    children: [
                        ProjectNode{
                            type: 'Button'
                            properties: {
                                'text': 'OK'
                                'width': '80'
                                'height': '30'
                            }
                        }
                    ]
                }
            ]
        }
    }

    code := generate_v_code(project)

    assert code.contains('mut panel1 := iui.Panel.new(iui.PanelConfig{')
    assert code.contains('layout: iui.FlowLayout.new(hgap: 5, vgap: 5)')
    assert code.contains('panel1.x = 5')
    assert code.contains('panel1.y = 10')

    assert code.contains('mut btn2 := iui.Button.new(iui.ButtonConfig{')
    assert code.contains('text: \'OK\'')
    assert code.contains('panel1.add_child(btn2)')
    assert code.contains('panel.add_child(panel1)')
}

fn test_generate_v_code_escapes_single_quotes() {
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {
                'width': '300'
                'height': '200'
            }
            children: [
                ProjectNode{
                    type: 'Button'
                    properties: {
                        'text': 'Bob\'s'
                        'width': '80'
                        'height': '30'
                    }
                }
            ]
        }
    }

    code := generate_v_code(project)
    expected := 'text: ' + v_string('Bob\'s')
    assert code.contains(expected)
}

fn test_project_json_roundtrip() {
    project := Project{
        version: '1.0'
        window_settings: WindowSettings{
            width: 800
            height: 600
            theme: 'Default'
        }
        root_component: ProjectNode{
            type: 'Panel'
            properties: {
                'width': '800'
                'height': '600'
            }
            children: [
                ProjectNode{
                    type: 'Label'
                    properties: {
                        'text': 'Hello'
                        'x': '1'
                        'y': '2'
                    }
                }
            ]
        }
    }

    s := json.encode(project)
    decoded := json.decode(Project, s) or { panic(err) }

    assert decoded.version == '1.0'
    assert decoded.window_settings.width == 800
    assert decoded.root_component.type == 'Panel'
    assert decoded.root_component.children.len == 1
    assert decoded.root_component.children[0].type == 'Label'
    assert decoded.root_component.children[0].properties['text'] == 'Hello'
}
