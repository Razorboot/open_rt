--!strict
-- Types-only module (returns nil at runtime). Safe to `require` in type expressions.
export type textureChannel = "Albedo" | "Normal" | "Specular"

export type Material = {
	-- Flesh out as needed
	Name: string,
	AlbedoMapIndices: {number}?,
	NormalMapIndices: {number}?,
	SpecularMapIndices: {number}?
}

export type TextureRegistry = {
    [number]: buffer
}

export type MaterialsContext = {
	-- state
	Materials: {[string]: Material},
    TextureRegistry: TextureRegistry
}

return nil