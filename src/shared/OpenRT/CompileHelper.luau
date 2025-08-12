--[[
    An internally used module containing functions for...
    - Compiling material texture channels and their subtextures into AoS-style buffer structs.
    - Compiling lights into AoS-style structs.
    - Generating the FrameState.
    - Saving frame captures for screenshots or custom shader effects.
]]


--# INCLUDE
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))
type packedBuffer = CompiledTypes.packedBuffer
type array<T> = CompiledTypes.array<T>


--# POINT
local CompileHelper = {}


--# QUICK MATH
local Vec2Zero: Vector2 = Vector2.zero


--# MATERIAL COMPILATION
function CompileHelper.compileTexture(Tex: EditableImage): packedBuffer
    local pixelMap: buffer = Tex:ReadPixelsBuffer(Vec2Zero, Tex.Size)
    local pixelMapSize: number = Tex.Size.X * Tex.Size.Y * 4
    return {data = pixelMap, size = pixelMapSize}
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