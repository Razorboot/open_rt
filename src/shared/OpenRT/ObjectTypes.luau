--!strict

--# POINT
local ObjectTypes = {}


--# TYPES
-- Types-only module (returns nil at runtime). Safe to `require` in type expressions.
export type textureChannel = "Albedo" | "Normal" | "Specular"
export type TextureRegistry = {
    [number]: buffer
}

export type Material = any
export type MaterialsContext = any


--# CONSTANTS
ObjectTypes.DEFAULT_MATERIAL_SIZE = Vector2.new(64, 64)


--# FINALIZE
return ObjectTypes