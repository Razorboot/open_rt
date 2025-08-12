--[[
	Contains custom types used during the per-pixel graphics pipeline in parallel.
    This is useful for optimizing data layouts and improving cache coherence.
]]

-- Underlying types
export type array<T> = {[number]: T}

export type packedBuffer = {data: buffer, size: number}
export type packedBufferArray = array<packedBuffer>
export type doublePackedBufferArray = array<packedBufferArray>
export type bufferArray = array<buffer>

export type LightType = "PointLight" | "SurfaceLight" | "SpotLight"

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
		albedoMapAlphaAttributes: array<number>?,
		normalMapIntensityAttributes: array<number>?,
		specularMapIntensityAttributes: array<number>?,

		-- The material stores multiple textures per each texture channel, allowing the end-user full access to any number of textures they want per channel.
		albedoMapIndexAttributes: array<number>?,
		normalMapIndexAttributes: array<number>?,
		specularMapIndexAttributes: array<number>?,

		-- In contract, the material stores a single scale per texture channel that is uniformly applied to all subtextures.
		albedoMapScaleAttributes: array<number>?,
		normalMapScaleAttributes: array<number>?,
		specularMapScaleAttributes: array<number>?,

		-- When a ray hits a part, we compare its material with the material stored here. If we find it, we render that material as a replacement on top of the base roblox material.
		-- This is because it's difficult to find the original textures for the Roblox material. Though this can be solved with MaterialVariants.
		-- For the sake of a unified architecture, we'll keep this base functionality and add an optional layer on top that extracts Roblox's Material textures with a lookup table from our local Roblox directory.
		underlyingMaterialAttributes: array<Enum.Material>?
	},

	-- We continue to use the AoS layouts for light data:
	lightRegistry: {
		countAttribute: number,
		posAttributes: array<Vector3>?,
		colorAttributes: array<Vector3>?,
		rangeAttributes: array<number>?,
		brightnessAttributes: array<number>?,
		baseLightTypeIndices: array<number>?,

		lightTypeAttributes: array<LightType>?
	},

	shaderPipeline: {
		-- pre-resolved call thunks per pass (fast positional args)
		[number] : {
			stage: string,
			fragment: (FrameState, ...any) -> any
		}
	}?,

	-- A second degree flat array consisting of texture data and sizes in buffers.
	-- Prevents the use of EditableImage Read and Write operations per pixel per frame in the per-pixel shader pipeline.
	textureRegistry: array<packedBufferArray>?
}


--# Finalize
return true