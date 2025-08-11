--!strict
-- Types-only module (returns nil at runtime). Safe to `require` in type expressions.

export type Material = {
	-- Flesh out as needed
	albedoId: string?,
	normalId: string?,
	specular: number?,
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