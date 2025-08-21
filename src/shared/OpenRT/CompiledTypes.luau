--[[
	Contains custom types used during the per-pixel graphics pipeline in parallel.
    This is useful for optimizing data layouts and improving cache coherence.
]]

--# POINT
local CompiledTypes = {}


--# UNDERLYING TYPES
export type struct<T> = {[string]: T}
export type array<T> = {[number]: T}

export type packedBuffer = {data: buffer, sizeX: number, sizeY: number, length: number}
export type packedBufferArray = array<packedBuffer>
export type doublePackedBufferArray = array<packedBufferArray>
export type bufferArray = array<buffer>

export type LightType = "PointLight" | "SurfaceLight" | "SpotLight"
export type SurfaceType = "Top" | "Bottom" | "Left" | "Right" | "Front" | "Back"
export type TextureChannelType = "Albedo" | "Normal" | "Specular"

export type CoreMode = "Idle" | "Preparing" | "Rendering" | "Finalizing"

export type materialState = {
	-- The material stores a single alpha or intensity per texture channel that is uniformly applied to all subtextures.
	albedoTextureAlphaAttributes: array<number>,
	normalTextureAlphaAttributes: array<number>,
	specularTextureAlphaAttributes: array<number>,

	-- The material stores a unique set of sample scale attributes per subtexture in each texture channel
	albedoSampleScaleAttributes: array<number>,
	normalSampleScaleAttributes: array<number>,
	specularSampleScaleAttributes: array<number>,

	-- The material stores a single reflectivity value per texture channel that is uniformly applied to all subtextures.
	reflectionScaleAttributes: array<number>,

	-- The material stores multiple textures per each texture channel, allowing the end-user full access to any number of textures they want per channel.
	albedoTextureIndexAttributes: array<number>,
	normalTextureIndexAttributes: array<number>,
	specularTextureIndexAttributes: array<number>,

	-- When a ray hits a part, we compare its material with the material stored here. If we find it, we render that material as a replacement on top of the base roblox material.
	-- This is because it's difficult to find the original textures for the Roblox material. Though this can be solved with MaterialVariants.
	-- For the sake of a unified architecture, we'll keep this base functionality and add an optional layer on top that extracts Roblox's Material textures with a lookup table from our local Roblox directory.
	baseMaterialAttributes: array<Enum.Material>,
	
	-- Each material can render on top of a specific surface of a BasePart.
	surfaceAttributes: array<array<SurfaceType>>
}

export type renderState =  {
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
	interlaceGroup: number
}

-- The above types are aligned into a "FrameState".
export type FrameState = {
	frameIndex: number,

	renderState: renderState,

	-- Array-of-Structs (AoS) layouts for hot data:
	materialState: materialState,

	-- We continue to use the AoS layouts for light data:
	lightRegistry: {
		countAttribute: number,
		posAttributes: array<Vector3>?,
		colorAttributes: array<Vector3>?,
		rangeAttributes: array<number>?,
		brightnessAttributes: array<number>?,
		baseLightTypeIndexAttributes: array<number>?,

		lightTypeAttributes: array<LightType>?
	},

	shaderPipeline: {
		-- pre-resolved call thunks per pass (fast positional args)
		[number] : {
			stage: string,
			fragment: (FrameState, ...any) -> any
		}
	},

	-- A second degree flat array consisting of texture data and sizes in buffers.
	-- Prevents the use of EditableImage Read and Write operations per pixel per frame in the per-pixel shader pipeline.
	textureRegistry: array<packedBufferArray>?
}

--# CONSTANTS
CompiledTypes.TEXTURE_CHANNEL_TYPES = {"Albedo", "Normal", "Specular"} :: array<TextureChannelType>
CompiledTypes.LIGHT_TYPES = {"PointLight", "SurfaceLight", "SpotLight"} :: array<LightType>

--# STATE CONSTRUCTORS
function CompiledTypes.newMaterialState(): materialState
	return {
		albedoTextureAlphaAttributes = {} :: array<number>,
		normalTextureAlphaAttributes = {} :: array<number>,
		specularTextureAlphaAttributes = {} :: array<number>,

		reflectionScaleAttributes = {} :: array<number>,
		
		albedoSampleScaleAttributes = {} :: array<number>,
		normalSampleScaleAttributes = {} :: array<number>,
		specularSampleScaleAttributes = {} :: array<number>,

		albedoTextureIndexAttributes = {} :: array<number>,
		normalTextureIndexAttributes = {} :: array<number>,
		specularTextureIndexAttributes = {} :: array<number>,

		baseMaterialAttributes = {} :: array<Enum.Material>,

		surfaceAttributes = {} :: array<array<SurfaceType>>
	}
end

function CompiledTypes.newRenderState(): renderState
	return {
		screenW = 80 :: number,
		screenH = 80 :: number,
		rayDistance = 1000 :: number,
		fogStart = 0 :: number,
		gamma = 2.2 :: number,

		viewportW = 80 :: number,
		viewportH = 80 :: number,
		worldScreenDistance = 1000 :: number,

		worldScreenCoord = CFrame.identity,
		worldScreenCornerCoord = CFrame.identity,

		sunDirection = -Vector3.one,
		skyColor = Vector3.one,

		interlaceGroupCount = 1,
		interlaceGroup = 1
	}
end


--# Finalize
return CompiledTypes