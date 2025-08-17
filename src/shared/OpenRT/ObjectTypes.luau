--!strict

--# POINT
local ObjectTypes = {}


--# CONSTANTS
ObjectTypes.DEFAULT_TEXTURE_SIZE = Vector2.new(64, 64)
ObjectTypes.TEXTURE_CHANNEL_NAMES = {"Albedo", "Normal", "Specular"}


--# TYPE
export type TEXTURE_CHANNEL_NAME = "Albedo" | "Normal" | "Specular"
export type TextureRegistry = {
    [number]: buffer
}

export type TextureChannel = {[number]: TEXTURE_CHANNEL_NAME}

export type Texture = typeof(
    setmetatable({
        Name = "" :: string,
        Size = 0 :: number,
        Image = nil :: EditableImage?,
        Content = nil :: Content?,
        PixelBuffer = nil :: buffer?
    },
    {
        __index = function(table, key)
            return rawget(table, key) or nil
        end
    })
)
export type Material = typeof(setmetatable(
    {
        Name = "" :: string,
        Size = 0 :: number,
        AlbedoMapIds = {} :: {[string]: Texture},
        NormalMapIds = {} :: {[string]: Texture},
        SpecularMapIds = {} :: {[string]: Texture},
        ParentContext = nil :: MaterialsContext?
    }, 
    {
        __index = function(table, key)
            return rawget(table, key) or nil
        end
    })
)
export type MaterialsContext = typeof(setmetatable(
    {
        Materials = {} :: {[string]: Material},
        TextureRegistry = {} :: {[string]: EditableImage},
        Properties = {
            diffuseEnabled = true :: boolean,
            specularEnabled = true :: boolean,
            normalEnabled = true :: boolean
        } :: {[string]: (string | number | boolean | Vector3 | Vector2)}
    }, {
        __index = function(table, key)
            return rawget(table, key) or nil
        end
    })
)


--# FINALIZE
return ObjectTypes