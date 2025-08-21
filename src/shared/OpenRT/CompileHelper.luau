--[[
    An internally used module containing functions for...
    - Compiling material texture channels and their subtextures into AoS-style buffer structs.
    - Compiling lights into AoS-style structs.
    - Generating the FrameState.
    - Saving frame captures for screenshots or custom shader effects.
]]


--# INCLUDE
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))
type packedBuffer = CompiledTypes.packedBuffer
type array<T> = CompiledTypes.array<T>

type materialState = CompiledTypes.materialState
type MaterialsContextT = ObjectTypes.MaterialsContextT
type MaterialT = ObjectTypes.MaterialT
type TextureT = ObjectTypes.TextureT


--# POINT
local CompileHelper = {}


--# CONSTANTS
local TEXTURE_CHANNEL_TYPES = CompiledTypes.TEXTURE_CHANNEL_TYPES


--# QUICK MATH
local Vec2Zero: Vector2 = Vector2.zero


--# MATERIAL COMPILATION
function CompileHelper.compileMaterialsContext(Context: MaterialsContextT): (materialState, array<packedBuffer>)
    local materialState: materialState = CompiledTypes.newMaterialState()
    local textureRegistry: array<packedBuffer> = {}
    local texCount: number = 0
    
    -- We need to compile all texture data and material data into a table-layout
    for _, Tex: any in Context.TextureRegistry do
        -- Compile each Texture individually into the textureRegistry array that stores the texture buffer itself and important metadata into an SoA layout
        texCount += 1
        table.insert(textureRegistry, {data = Tex.PixelBuffer, sizeX = Tex.Size.X, sizeY = Tex.Size.Y, scale = Tex.Scale, length = Tex.Size.X * Tex.Size.Y * 4})

        -- For each texture, we need to find all materials that reference it and add their properties to the materialRegistry
        -- So we represent all material properties globally with an AoS layout
        for _, MaterialRef: MaterialT in Context.Materials do

            for _, channelType: string in TEXTURE_CHANNEL_TYPES do
                local lowerChannelName = string.lower(channelType)

                for _, TexRef: TextureT in MaterialRef[channelType.."Textures"] do
                    if TexRef == Tex then
                        table.insert(materialState[lowerChannelName.."TextureIndexAttributes"], texCount)
                        table.insert(materialState[lowerChannelName.."SampleScaleAttributes"], MaterialRef:getTextureSampleScale(Tex.Name, channelType))
                        table.insert(materialState[lowerChannelName.."ReflectionScaleAttributes"], MaterialRef:getReflectionScale())
                        table.insert(materialState["baseMaterialAttributes"], MaterialRef:getBaseMaterial())
                        table.insert(materialState["surfaceAttributes"], MaterialRef:getSurfaces())
                    end
                end
            end

        end
    end

    -- Finalize
    return materialState, textureRegistry
end


--# TEXTURE COMPILATION
function CompileHelper.compileTexture(Tex: EditableImage): packedBuffer
    local pixelMap: buffer = Tex:ReadPixelsBuffer(Vec2Zero, Tex.Size)
    local pixelMapSize: number = Tex.Size.X * Tex.Size.Y * 4
    return {data = pixelMap, sizeX = Tex.Size.X, sizeY = Tex.Size.Y, length = pixelMapSize}
end

function CompileHelper.compileTextureArray(TexArray: {EditableImage} ): array<packedBuffer>
    local result: array<packedBuffer> = {}
    for _, Tex in ipairs(TexArray) do
        table.insert(result, CompileHelper.compileTexture(Tex))
    end
    return result
end


--# FINALIZE
return CompileHelper