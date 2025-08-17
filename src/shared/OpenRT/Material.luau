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
type TextureT = ObjectTypes.Texture

type TEXTURE_CHANNEL_NAME = "Albedo" | "Normal" | "Specular"


--# IMPORTED CONSTANTS
local DEFAULT_MATERIAL_SIZE: Vector2 = ObjectTypes.DEFAULT_TEXTURE_SIZE


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

	The texture channels that contain an array of Textures. These get used to index EditableImages from the ParentContext.TextureRegistry.
	- AlbedoTextures: {Texture}
	- NormalTextures: {Texture}
	- SpecularTextures: {Texture}

	@class Material
	@tag Class
]=]
--- 
local Material = {}
Material.__index = Material


--# CONSTRUCTOR/DESTRUCTOR

--- Creates a new Material instance under a given name. This name acts as an identifier that cannot be changed after creation.
--- @within Material
--- @tag Constructor
--- @param name string -- The name of the material
--- @return Material
function Material.new(name: string): any
	local newMaterial = {
		_Name = name :: string,
		Size = DEFAULT_MATERIAL_SIZE :: Vector2,
		AlbedoTextures = {} :: {[number]: TextureT},
		NormalTextures = {} :: {[number]: TextureT},
		SpecularTextures = {} :: {[number]: TextureT},
		ParentContext = nil :: MaterialsContextT?
	}

	-- enforces readonly behavior for Material.Name
	local mt = {
		__index = function(self, key)
			if key == "Name" then
				return rawget(self, "_Name")
			end
			return Material[key]
		end,
		__newindex = function(self, key, value)
			if key == "Name" then
				error("ERROR Material.Name is readonly and cannot be changed after initialization.")
			end
			rawset(self, key, value)
		end
	}

	-- finalize
	return setmetatable(newMaterial, mt)
end

--- Destroys a Material instance and detaches it from the parent context.
--- @within Material
--- @tag Destructor
--- @return nil
function Material:destroy(): nil
	if self.ParentContext then
		self.ParentContext:removeMaterial(self.Name)
	end

	self.Name = nil
	self.AlbedoTextures = nil
	self.NormalTextures = nil
	self.SpecularTextures = nil
	setmetatable(self, nil)

	return nil
end


--# SETTERS

--- Sets the shared dimensions between all texture channels.
--- @within Material
--- @param size Vector2 -- The new size to set
--- @tag Setter
--- @return nil
function Material:setSize(size: Vector2): nil
	assert(size.X > 0 and size.Y > 0 and size.X < 513 and size.Y < 513, "ERROR [Material:setSize] <size> must be a Vector2 between (0, 0) and (512, 512)")
	self.Size = size
	return nil
end

--- Adds a Texture to an existing texture channel. If the Texture already exists, a copy will still be added to the texture channel.
--- @within Material
--- @param textureChannelName -- The texture channel ("AlbedoTextures", "NormalTextures", "SpecularTextures")
--- @param Tex -- The Texture to add to the texture channel
--- @tag Setter
--- @return nil
function Material:addTexture(Tex: TextureT, textureChannelName: TEXTURE_CHANNEL_NAME): nil
	assert(Tex, "ERROR [Material:addTexture] <Tex> must be of type <Texture> and != nil") -- TODO: Is this necessary with strict typechecking?

	for _, TexRef: TextureT in self[textureChannelName] do
		if TexRef == Tex then
			warn(TexRef ~= Tex, "ERROR [Material:addTexture] <Tex> of name <" .. Tex.Name .. "> is already in the texture channel")
			break
		end
	end

	table.insert(self[textureChannelName], Tex)

	return nil
end

--- Removes a Texture from an existing texture channel. If the Texture already exists, a copy will still be added to the texture channel.
--- @within Material
--- @param textureChannelName -- The texture channel ("AlbedoTextures", "NormalTextures", "SpecularTextures")
--- @param Tex -- The Texture to remove from the texture channel
--- @tag Setter
--- @return nil
function Material:removeTexture(Tex: TextureT, textureChannelName: TEXTURE_CHANNEL_NAME): nil
	assert(Tex, "ERROR [Material:removeTexture] <Tex> must be of type <Texture> and != nil") -- TODO: Is this necessary with strict typechecking?

	for i: number = #self[textureChannelName], 1, -1 do
		local TexRef: TextureT = self[textureChannelName][i]
		if TexRef == Tex then
			table.remove(self[textureChannelName], i)
			return nil
		end
	end

	return nil
end


--# GETTERS

--- Returns the Name of the Material
--- @within Material
--- @tag Getter
--- @return string
function Material:getName(): string
	return self.Name
end

--- Returns the shared dimensions between all texture channels.
--- @within Material
--- @tag Getter
--- @return Vector2
function Material:getSize(): Vector2
	return self.Size
end

--- Returns a Texture from an existing texture channel.
--- @within Material
--- @tag Getter
--- @param textureIdentifier string | TextureT -- The texture identifier (name of the Texture or the Texture instance itself)
--- @param textureChannelName string -- The name of the texture channel ("AlbedoTextures", 	"NormalTextures", "SpecularTextures")
--- @return Texture? -- Returns nil if the Texture cannot be found
function Material:getTexture(textureIdentifier: string | TextureT, textureChannelName: string): TextureT?
	local texIdentifierType: string = type(textureIdentifier)

	if texIdentifierType == "string" then
		return self[textureChannelName][textureIdentifier]
	else
		for _, Tex: any in self[textureChannelName] do
			if Tex == textureIdentifier then
				return Tex
			end
		end
	end

	return nil
end

--# FINALIZE
return Material
