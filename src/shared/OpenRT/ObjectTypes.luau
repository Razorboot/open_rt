--!strict

--# INCLUDE
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))

--# POINT
local ObjectTypes = {}

--# IMPORTED TYPES
type array<T> = CompiledTypes.array<T>
type packedBuffer = CompiledTypes.packedBuffer
type packedBufferArray = CompiledTypes.packedBufferArray

type LightType = CompiledTypes.LightType
type SurfaceType = CompiledTypes.SurfaceType
type TextureChannelType = CompiledTypes.TextureChannelType

--# CONSTANTS
ObjectTypes.DEFAULT_TEXTURE_SIZE = Vector2.new(64, 64) :: Vector2
ObjectTypes.TEXTURE_CHANNEL_NAMES = {"Albedo", "Normal", "Specular"} :: array<TextureChannelType>

--# TYPES
export type TextureRegistryT = packedBufferArray
export type TextureChannelT = array<TextureChannelType>

--# OBJECT TYPES
export type ObjectT = typeof(
    setmetatable({} :: {[string]: any}, {
        __index = function(table, key)
            return rawget(table, key) or nil
        end
    })
)

-- Refer to OpenRT/Texture
export type TextureT = ObjectT
-- Refer to OpenRT/Material
export type MaterialT = ObjectT
-- Refer to OpenRT/MaterialsContext
export type MaterialsContextT = ObjectT
-- Refer to OpenRT/LightingContext
export type LightingContextT = ObjectT
-- Refer to OpenRT/RenderContext
export type RenderContextT = ObjectT
-- Refer to OpenRT/Core
export type CoreT = ObjectT


--# FUNCTIONS
function ObjectTypes.getPrivateTable(objType: string, objName: string): {any}
    return {
		__newindex = function(self, key, value)
			if string.sub(key, 1, 1) ~= "_" then
				error(string.format("ERROR: %s.%s is either readonly or is not a member of '%s'", objType, key, objName))
			end
			rawset(self, key, value)
		end
	}
end

--# FINALIZE
return ObjectTypes
