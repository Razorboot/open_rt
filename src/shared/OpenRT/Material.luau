
--!strict

--# SERVICES
local AssetService = game:GetService("AssetService")


--# INCLUDE
local CompileHelper = require(script.Parent:FindFirstChild("CompileHelper"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))


--# IMPORT TYPES
type array<T> = CompiledTypes.array<T>
type MaterialsContextT = ObjectTypes.MaterialsContext
type MaterialT = ObjectTypes.Material
type TextureChannel = ObjectTypes.textureChannel


--# IMPORTED CONSTANTS
local DEFAULT_MATERIAL_SIZE: Vector2 = ObjectTypes.DEFAULT_MATERIAL_SIZE


--# INIT MATERIAL

--[=[
	The Material class represents a material with albedo, normal, and specular maps and properties.
	Materials are a great way to add more detail and realism to surfaces with the realtime simulation of diffuse, normal, and specular lighting.
	
	Each Material Instance contains...

	The name of the Material:
	- Name: String

	The uniform size applied to all texture channels:
	- Size: Vector2

	The MaterialsContext the Material belongs to:
	- ParentContext: MaterialsContext

	The texture channels that contain an array of TextureRegistryIds. These get used to index EditableImages from the ParentContext.TextureRegistry.
	- AlbedoMapIds: {TextureRegistryId}
	- NormalMapIds: {TextureRegistryId}
	- SpecularMapIds: {TextureRegistryId}

	@class Material
	@tag Class
]=]
--- 
local Material = {}
Material.__index = Material


--# CONSTRUCTOR/DESTRUCTOR

--- Creates a new Material instance.
--- @within Material
--- @tag Constructor
--- @method Material.new
--- @param name string -- The name of the material
--- @return Material
function Material.new(name: string): MaterialT
	local newMaterial = {
		Name = name,
		Size = DEFAULT_MATERIAL_SIZE :: Vector2,
		AlbedoMapIds = nil :: array<number>?,
		NormalMapIds = nil :: array<number>?,
		SpecularMapIds = nil :: array<number>?,
		ParentContext = nil :: MaterialsContextT?
	}
	return setmetatable(newMaterial, Material)
end

--- Destroys a Material instance and detaches it from the parent context.
--- @within Material
--- @tag Destructor
--- @method Material:destroy
--- @return nil
function Material:destroy(): nil
	if self.ParentContext then
		self.ParentContext:removeMaterial(self.Name)
	end

	self.Name = nil
	self.AlbedoMapIds = nil
	self.NormalMapIds = nil
	self.SpecularMapIds = nil
	setmetatable(self, nil)

	return nil
end


--# SETTERS

--- Sets the shared dimensions between all texture channels.
--- @within Material
--- @method Material:setSize
--- @param size Vector2 -- The new size to set
--- @tag Setter
--- @return nil
function Material:setSize(size: Vector2): nil
	assert(size.X > 0 and size.Y > 0 and size.X < 513 and size.Y < 513, "ERROR [Material:setSize] <size> must be a Vector2 between (0, 0) and (512, 512)")
	self.Size = size
	return nil
end

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
	
	local AlbedoMap: EditableImage = AssetService:CreateEditableImage({Size = self.Size})
	
	if channel == "Albedo" then
		self.AlbedoMapIds[subtextureIndex] = textureId
	elseif channel == "Normal" then
		self.NormalMapIds[subtextureIndex] = textureId
	elseif channel == "Specular" then
		self.SpecularMapIds[subtextureIndex] = textureId
	end
	return nil
end


--# GETTERS

--- Sets the shared dimensions between all texture channels.
--- @within Material
--- @method Material:getSize
--- @param size Vector2 -- The new size to set
--- @tag Getter
--- @return Vector2
function Material:getSize(): Vector2
	return self.Size
end

--# FINALIZE
return Material
