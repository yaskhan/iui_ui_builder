module uibuilder

pub struct Project {
    pub mut:
        version         string
        window_settings WindowSettings
        root_component  ProjectNode
}

pub struct WindowSettings {
    pub mut:
        width  int
        height int
        theme  string
}

// Project node represents a UI component in the hierarchy.
pub struct ProjectNode {
    pub mut:
        type       string
        properties map[string]string
        layout     ?LayoutConfig
        children   []ProjectNode
}

pub struct LayoutConfig {
    pub mut:
        type   string
        params map[string]string
}
