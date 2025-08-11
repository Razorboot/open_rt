
--!strict

--# INCLUDE
local ObjectTypes = require(script.Parent.ObjectTypes)
type MaterialT = ObjectTypes.Material

--# IMPORT TYPES
type TextureChannel = ObjectTypes.textureChannel


--# INIT MATERIAL

--- The Material class represents a material with albedo, normal, and specular properties.
--- @class Material
--- @tag Class
local Material = {}
Material.__index = Material


--# CONSTRUCTOR/DESTRUCTOR

--- Creates a new Material instance.
--- @within Material
--- @tag Constructor
--- @method Material.new
--- @param name string -- The name of the material
--- @return Material -- The created Material instance
function Material.new(name: string): any
	local newMaterial: MaterialT = {
		Name = name,
		AlbedoMapIds = nil,
		NormalMapIds = nil,
		SpecularMapIds = nil
	}
	setmetatable(newMaterial, Material)
	return newMaterial
end

--- Destroys a Material instance.
--- @tag Destructor
function Material:destroy(): nil
	self.Name = nil
	self.AlbedoMapIds = nil
	self.NormalMapIds = nil
	self.SpecularMapIds = nil
	return nil
end


--# SETTERS
--- Sets the texture map id of a subtexture in a texture channel.
--- @within Material
--- @method Material:setTextureId
--- @param textureId string -- The texture ID to set
--- @param channel TextureChannel -- The texture channel ("Albedo", "Normal", "Specular")
--- @param subtextureIndex number -- The index of the subtexture
--- @tag Setter
--- @return nil
function Material:setTextureId(textureId: string, channel: TextureChannel, subtextureIndex: number): nil
    assert(type(channel) == "string", "ERROR [Material:setTextureId] <channel> must be a string")
	if channel == "Albedo" then
		self.AlbedoMapIds[subtextureIndex] = textureId
	elseif channel == "Normal" then
		self.NormalMapIds[subtextureIndex] = textureId
	elseif channel == "Specular" then
		self.SpecularMapIds[subtextureIndex] = textureId
	end
	return nil
end

--# FINALIZE
return Material
