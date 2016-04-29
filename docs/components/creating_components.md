# Creating components
Components are written in standard Lua. They are located in lua/quantumchip/components/ and loaded automatically by the addon.

## How to create a component
Make a new .lua file in components folder. When a file is loaded, a global table 'COMPONENT' is created. It stores basic informations like name, author, description etc..

Example:
```
COMPONENT.Name = "Core"
COMPONENT.Description = "Core component of QC. Adds basic types."
COMPONENT.Author = "Szymekk"
```

## Component values

| Name | Description |
|---|---|
| Name | Name of the component |
| Description | Description of the component |
| Author | Author(s) of the component |
| EnabledByDefault | Specifies if the component is enabled by default. |
