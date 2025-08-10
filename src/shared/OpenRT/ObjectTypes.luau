--!strict
-- Types-only module (returns nil at runtime). Safe to `require` in type expressions.

export type MaterialT = {
	-- Flesh out as needed
	albedoId: string?,
	normalId: string?,
	specular: number?,
}

export type MaterialsContextT = {
	-- state
	Materials: {[string]: MaterialT},

	-- methods
	setMaterial: (self: MaterialsContextT, name: string, material: MaterialT) -> nil,
	destroy: (self: MaterialsContextT) -> nil,
}

return nil