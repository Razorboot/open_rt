--[[
	Contains custom types used during the per-pixel graphics pipeline in parallel.
    This is useful for optimizing data layouts and improving cache coherence.
]]
export type FrameState = {
	frameIndex: number,

	render: {
		screenW: number,
		screenH: number,
		rayDistance: number,
		fogStart: number,
		gamma: number,

		viewportW: number,
		viewportH: number,
		worldScreenDistance: number,

		worldScreenCoord: CFrame,
		worldScreenCornerCoord: CFrame,

		sunDirection: Vector3,
		skyColor: Vector3,

		interlaceGroupCount: number,
		interlaceGroup: number,
	},

	-- Struct-of-Arrays (SoA) layouts for hot data:
	materials: {
		count: number,
		albedo: buffer?,        -- u16 per material
		specular: buffer?,           -- f32 per material
		normalStrength: buffer?,     -- f32 per material
		flags: buffer?,              -- u8  per material
		-- add more arrays as needed (scales, mipBias, etc.)
	},

	lights: {
		count: number,
		pos: buffer?,     -- f32 xyzxyz...
		color: buffer?,   -- f32 xyzxyz...
		range: buffer?,   -- f32
		type: buffer?,    -- u8
		flags: buffer?,   -- u8
	},

	textures: any, -- catalog: width/height/mipOffsets/data buffers, indexed by small IDs

	shaders: any,  -- pre-resolved call thunks per pass (fast positional args)
}


--# Finalize
return true