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
