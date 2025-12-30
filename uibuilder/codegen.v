module uibuilder

import strings

pub fn generate_v_code(project Project) string {
    mut ctx := CodegenContext{}
    mut out := strings.new_builder(1024)

    out.writeln('import iui')
    out.writeln('')
    out.writeln('fn build_ui() &iui.Panel {')

    if project.root_component.type == 'Panel' {
        out.write_string(ctx.gen_node(project.root_component, 1, 'panel'))
        out.writeln('    return panel')
    } else {
        out.writeln('    mut panel := iui.Panel.new(iui.PanelConfig{})')
        child_code, child_var := ctx.gen_child_node(project.root_component, 1)
        out.write_string(child_code)
        out.writeln('    panel.add_child(${child_var})')
        out.writeln('    return panel')
    }

    out.writeln('}')
    return out.str()
}

struct CodegenContext {
    mut:
        next_id int
}

fn (mut ctx CodegenContext) gen_child_node(node ProjectNode, indent int) (string, string) {
    var_name := ctx.next_var_name(node.type)
    code := ctx.gen_node(node, indent, var_name)
    return code, var_name
}

fn (mut ctx CodegenContext) gen_node(node ProjectNode, indent int, var_name string) string {
    spaces := ' '.repeat(indent * 4)
    mut out := strings.new_builder(256)

    match node.type {
        'Panel' {
            out.writeln('${spaces}mut ${var_name} := iui.Panel.new(iui.PanelConfig{')

            width := node.properties['width']
            if width != '' {
                out.writeln('${spaces}    width: ${width}')
            }

            height := node.properties['height']
            if height != '' {
                out.writeln('${spaces}    height: ${height}')
            }

            if node.layout != none {
                layout := node.layout or { panic('unreachable') }
                out.writeln('${spaces}    layout: ${layout_expr(layout)}')
            }

            out.writeln('${spaces}})')

            x := node.properties['x']
            if x != '' {
                out.writeln('${spaces}${var_name}.x = ${x}')
            }

            y := node.properties['y']
            if y != '' {
                out.writeln('${spaces}${var_name}.y = ${y}')
            }

            for child in node.children {
                child_code, child_var := ctx.gen_child_node(child, indent + 1)
                out.write_string(child_code)
                out.writeln('${spaces}${var_name}.add_child(${child_var})')
            }
        }
        'Button' {
            btn_text := node.properties['text']
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '100')
            height := prop_or(node.properties, 'height', '30')

            out.writeln('${spaces}mut ${var_name} := iui.Button.new(iui.ButtonConfig{')
            out.writeln('${spaces}    text: ${v_string(btn_text)}')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}})')
        }
        'Label' {
            lbl_text := node.properties['text']
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')

            out.writeln('${spaces}mut ${var_name} := iui.Label.new(iui.LabelConfig{')
            out.writeln('${spaces}    text: ${v_string(lbl_text)}')
            out.writeln('${spaces}    x: ${x}')
            out.writeln('${spaces}    y: ${y}')
            out.writeln('${spaces}})')
        }
        'TextField' {
            tf_text := prop_or(node.properties, 'text', '')
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '150')
            height := prop_or(node.properties, 'height', '25')

            out.writeln('${spaces}mut ${var_name} := iui.TextField.new(iui.TextFieldConfig{')
            out.writeln('${spaces}    text: ${v_string(tf_text)}')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}})')
        }
        'Textbox' {
            lines := prop_or(node.properties, 'lines', '')
            
            out.writeln('${spaces}mut ${var_name} := iui.Textbox.new(iui.TextboxConfig{')
            if lines != '' {
                out.writeln('${spaces}    lines: [${v_string(lines)}]')
            } else {
                out.writeln('${spaces}    lines: [\'\']')
            }
            out.writeln('${spaces}    pack: true')
            out.writeln('${spaces}})')
            
            x := node.properties['x']
            if x != '' {
                out.writeln('${spaces}${var_name}.x = ${x}')
            }
            y := node.properties['y']
            if y != '' {
                out.writeln('${spaces}${var_name}.y = ${y}')
            }
        }
        'Checkbox' {
            cb_text := prop_or(node.properties, 'text', '')
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '100')
            height := prop_or(node.properties, 'height', '20')
            selected := prop_or(node.properties, 'selected', 'false')

            out.writeln('${spaces}mut ${var_name} := iui.Checkbox.new(iui.CheckboxConfig{')
            out.writeln('${spaces}    text: ${v_string(cb_text)}')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}    selected: ${selected}')
            out.writeln('${spaces}})')
        }
        'Switch' {
            sw_text := prop_or(node.properties, 'text', '')
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '0')
            height := prop_or(node.properties, 'height', '20')
            selected := prop_or(node.properties, 'selected', 'false')

            out.writeln('${spaces}mut ${var_name} := iui.Switch.new(iui.SwitchConfig{')
            out.writeln('${spaces}    text: ${v_string(sw_text)}')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}    selected: ${selected}')
            out.writeln('${spaces}})')
        }
        'Slider' {
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            min := prop_or(node.properties, 'min', '0')
            max := prop_or(node.properties, 'max', '100')
            val := prop_or(node.properties, 'value', '0')
            dir := prop_or(node.properties, 'direction', 'hor')

            out.writeln('${spaces}mut ${var_name} := iui.Slider.new(iui.SliderConfig{')
            out.writeln('${spaces}    min: ${min}')
            out.writeln('${spaces}    max: ${max}')
            out.writeln('${spaces}    dir: .${dir}')
            out.writeln('${spaces}})')
            out.writeln('${spaces}${var_name}.x = ${x}')
            out.writeln('${spaces}${var_name}.y = ${y}')
            out.writeln('${spaces}${var_name}.cur = ${val}')
        }
        'Progressbar' {
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '150')
            height := prop_or(node.properties, 'height', '20')
            val := prop_or(node.properties, 'value', '0')

            out.writeln('${spaces}mut ${var_name} := iui.Progressbar.new(iui.ProgressbarConfig{')
            out.writeln('${spaces}    val: ${val}')
            out.writeln('${spaces}})')
            out.writeln('${spaces}${var_name}.x = ${x}')
            out.writeln('${spaces}${var_name}.y = ${y}')
            out.writeln('${spaces}${var_name}.width = ${width}')
            out.writeln('${spaces}${var_name}.height = ${height}')
        }
        'Image' {
            file := prop_or(node.properties, 'file', '')
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '0')
            height := prop_or(node.properties, 'height', '0')

            out.writeln('${spaces}mut ${var_name} := iui.Image.new(iui.ImgConfig{')
            if file != '' {
                out.writeln('${spaces}    file: ${v_string(file)}')
            }
            if width != '' && width != '0' {
                out.writeln('${spaces}    width: ${width}')
            }
            if height != '' && height != '0' {
                out.writeln('${spaces}    height: ${height}')
            }
            out.writeln('${spaces}})')
            out.writeln('${spaces}${var_name}.x = ${x}')
            out.writeln('${spaces}${var_name}.y = ${y}')
        }
        'Hyperlink' {
            text := prop_or(node.properties, 'text', '')
            url := prop_or(node.properties, 'url', '')
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')

            out.writeln('${spaces}mut ${var_name} := iui.Hyperlink.new(iui.HyperlinkConfig{')
            out.writeln('${spaces}    text: ${v_string(text)}')
            out.writeln('${spaces}    url: ${v_string(url)}')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}})')
        }
        'ScrollView' {
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '200')
            height := prop_or(node.properties, 'height', '150')

            out.writeln('${spaces}mut ${var_name} := iui.ScrollView.new(iui.ScrollViewConfig{')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}})')
        }
        'Tabbox' {
            out.writeln('${spaces}mut ${var_name} := iui.Tabbox.new(iui.TabboxConfig{')
            out.writeln('${spaces}    closable: true')
            out.writeln('${spaces}    compact: false')
            out.writeln('${spaces}    stretch: false')
            out.writeln('${spaces}})')
            
            x := node.properties['x']
            if x != '' {
                out.writeln('${spaces}${var_name}.x = ${x}')
            }
            y := node.properties['y']
            if y != '' {
                out.writeln('${spaces}${var_name}.y = ${y}')
            }
            width := node.properties['width']
            if width != '' {
                out.writeln('${spaces}${var_name}.width = ${width}')
            }
            height := node.properties['height']
            if height != '' {
                out.writeln('${spaces}${var_name}.height = ${height}')
            }
        }
        'SplitView' {
            x := prop_or(node.properties, 'x', '0')
            y := prop_or(node.properties, 'y', '0')
            width := prop_or(node.properties, 'width', '300')
            height := prop_or(node.properties, 'height', '200')
            h1 := prop_or(node.properties, 'h1', '50')
            h2 := prop_or(node.properties, 'h2', '50')
            min_percent := prop_or(node.properties, 'min_percent', '30')

            out.writeln('${spaces}mut ${var_name} := iui.SplitView.new(iui.SplitViewConfig{')
            out.writeln('${spaces}    bounds: iui.Bounds{')
            out.writeln('${spaces}        x: ${x}')
            out.writeln('${spaces}        y: ${y}')
            out.writeln('${spaces}        width: ${width}')
            out.writeln('${spaces}        height: ${height}')
            out.writeln('${spaces}    }')
            out.writeln('${spaces}    h1: ${h1}')
            out.writeln('${spaces}    h2: ${h2}')
            out.writeln('${spaces}    min_percent: ${min_percent}')
            out.writeln('${spaces}})')
        }
        'NavPane' {
            collapsed := prop_or(node.properties, 'collapsed', 'false')
            
            out.writeln('${spaces}mut ${var_name} := iui.NavPane.new(iui.NavPaneConfig{')
            out.writeln('${spaces}    collapsed: ${collapsed}')
            out.writeln('${spaces}    pack: true')
            out.writeln('${spaces}})')
            
            x := node.properties['x']
            if x != '' {
                out.writeln('${spaces}${var_name}.x = ${x}')
            }
            y := node.properties['y']
            if y != '' {
                out.writeln('${spaces}${var_name}.y = ${y}')
            }
            width := node.properties['width']
            if width != '' {
                out.writeln('${spaces}${var_name}.width = ${width}')
            }
            height := node.properties['height']
            if height != '' {
                out.writeln('${spaces}${var_name}.height = ${height}')
            }
        }
        'BoxLayout' {
            ori := prop_or(node.properties, 'ori', '1')
            hgap := prop_or(node.properties, 'hgap', '5')
            vgap := prop_or(node.properties, 'vgap', '5')

            out.writeln('${spaces}mut ${var_name} := iui.BoxLayout.new(iui.BoxLayoutConfig{')
            out.writeln('${spaces}    ori: ${ori}')
            out.writeln('${spaces}    hgap: ${hgap}')
            out.writeln('${spaces}    vgap: ${vgap}')
            out.writeln('${spaces}})')
        }
        'FlowLayout' {
            hgap := prop_or(node.properties, 'hgap', '5')
            vgap := prop_or(node.properties, 'vgap', '5')

            out.writeln('${spaces}mut ${var_name} := iui.FlowLayout.new(iui.FlowLayoutConfig{')
            out.writeln('${spaces}    hgap: ${hgap}')
            out.writeln('${spaces}    vgap: ${vgap}')
            out.writeln('${spaces}})')
        }
        'BorderLayout' {
            hgap := prop_or(node.properties, 'hgap', '5')
            vgap := prop_or(node.properties, 'vgap', '5')
            style := prop_or(node.properties, 'style', '0')

            out.writeln('${spaces}mut ${var_name} := iui.BorderLayout.new(iui.BorderLayoutConfig{')
            out.writeln('${spaces}    hgap: ${hgap}')
            out.writeln('${spaces}    vgap: ${vgap}')
            out.writeln('${spaces}    style: ${style}')
            out.writeln('${spaces}})')
        }
        'GridLayout' {
            rows := prop_or(node.properties, 'rows', '1')
            cols := prop_or(node.properties, 'cols', '1')
            hgap := prop_or(node.properties, 'hgap', '5')
            vgap := prop_or(node.properties, 'vgap', '5')

            out.writeln('${spaces}mut ${var_name} := iui.GridLayout.new(iui.GridLayoutConfig{')
            out.writeln('${spaces}    rows: ${rows}')
            out.writeln('${spaces}    cols: ${cols}')
            out.writeln('${spaces}    hgap: ${hgap}')
            out.writeln('${spaces}    vgap: ${vgap}')
            out.writeln('${spaces}})')
        }
        'CardLayout' {
            hgap := prop_or(node.properties, 'hgap', '5')
            vgap := prop_or(node.properties, 'vgap', '5')
            selected := prop_or(node.properties, 'selected', '')

            out.writeln('${spaces}mut ${var_name} := iui.CardLayout.new(iui.CardLayoutConfig{')
            out.writeln('${spaces}    hgap: ${hgap}')
            out.writeln('${spaces}    vgap: ${vgap}')
            out.writeln('${spaces}})')
            
            if selected != '' {
                out.writeln('${spaces}${var_name}.selected = ${v_string(selected)}')
            }
        }
        else {
            unsupported_text := 'Unsupported: ${node.type}'

            out.writeln('${spaces}mut ${var_name} := iui.Label.new(iui.LabelConfig{')
            out.writeln('${spaces}    text: ${v_string(unsupported_text)}')
            out.writeln('${spaces}})')
        }
    }

    return out.str()
}

fn (mut ctx CodegenContext) next_var_name(component_type string) string {
    ctx.next_id++

    prefix := match component_type {
        'Panel' { 'panel' }
        'Button' { 'btn' }
        'Label' { 'lbl' }
        'TextField' { 'tf' }
        'Textbox' { 'tb' }
        'Checkbox' { 'cb' }
        'Switch' { 'sw' }
        'Slider' { 'slider' }
        'Progressbar' { 'pb' }
        'Image' { 'img' }
        'Hyperlink' { 'link' }
        'ScrollView' { 'sv' }
        'Tabbox' { 'tabs' }
        'SplitView' { 'split' }
        'NavPane' { 'nav' }
        else { component_type.to_lower() }
    }

    return '${prefix}${ctx.next_id}'
}

fn layout_expr(layout LayoutConfig) string {
    mut keys := layout.params.keys()
    keys.sort()

    mut parts := []string{cap: keys.len}
    for key in keys {
        parts << '${key}: ${layout.params[key]}'
    }

    params_str := parts.join(', ')
    if params_str == '' {
        return 'iui.${layout.type}.new()'
    }

    return 'iui.${layout.type}.new(${params_str})'
}

fn prop_or(props map[string]string, key string, default_value string) string {
    if key in props {
        v := props[key]
        if v != '' {
            return v
        }
    }

    return default_value
}

fn v_string(s string) string {
    quote := '\''
    return quote + escape_v_string(s) + quote
}

fn escape_v_string(s string) string {
    quote := '\''
    escaped_quote := '\\\''
    return s.replace('\\', '\\\\').replace(quote, escaped_quote)
}
