--[[
	Contains custom types used during the per-pixel graphics pipeline in parallel.
    This is useful for optimizing data layouts and improving cache coherence.
]]

-- Underlying types
export type doubleBufferStruct = {[number]: {[number]: buffer}}
export type numberStruct = {[number]: number}
export type vec3Struct = {[number]: Vector3}

export type baseMaterialStruct = {[number]: Enum.Material}

export type baseLightTypeStruct = {[number]: string}

-- The above types are aligned into a "FrameState".
export type FrameState = {
	frameIndex: number,

	renderContext: {
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

	-- Array-of-Structs (AoS) layouts for hot data:
	materialRegistry: {
		-- The material stores a single alpha or intensity per texture channel that is uniformly applied to all subtextures.
		albedoMapAlphaAttributes: numberStruct?,
		normalMapIntensityAttributes: numberStruct?,
		specularMapIntensityAttributes: numberStruct?,

		-- The material stores multiple textures per each texture channel, allowing the end-user full access to any number of textures they want per channel.
		albedoMapAttributes: doubleBufferStruct?,
		normalMapAttributes: doubleBufferStruct?,
		specularMapAttributes: doubleBufferStruct?,

		-- In contract, the material stores a single scale per texture channel that is uniformly applied to all subtextures.
		albedoMapScaleAttributes: numberStruct?,
		normalMapScaleAttributes: numberStruct?,
		specularMapScaleAttributes: numberStruct?,

		-- When a ray hits a part, we compare its material with the material stored here. If we find it, we render that material as a replacement on top of the base roblox material.
		-- This is because it's difficult to find the original textures for the Roblox material. Though this can be solved with MaterialVariants.
		-- For the sake of a unified architecture, we'll keep this base functionality and add an optional layer on top that extracts Roblox's Material textures with a lookup table from our local Roblox directory.
		underlyingMaterialAttributes: baseMaterialStruct?
	},

	-- We continue to use the AoS layouts for light data:
	lightRegistry: {
		count: numberStruct,
		pos: vec3Struct?,
		color: vec3Struct?,
		range: numberStruct?,
		type: baseLightTypeStruct?
	},

	shaderPipeline: {
		-- pre-resolved call thunks per pass (fast positional args)
		[number] : {
			stage: string,
			fragment: (FrameState, any) -> any
		}
	}
}


--# Finalize
return true