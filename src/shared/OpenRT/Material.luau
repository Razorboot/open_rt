--!strict


--# SERVICES
local AssetService = game:GetService("AssetService")


--# INCLUDE
local CompileHelper = require(script.Parent:FindFirstChild("CompileHelper"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))


--# IMPORT TYPES
type struct<T> = CompiledTypes.struct<T>
type array<T> = CompiledTypes.array<T>
type packedBuffer = CompiledTypes.packedBuffer
type MaterialsContextT = ObjectTypes.MaterialsContextT
type MaterialT = ObjectTypes.MaterialT
type TextureT = ObjectTypes.TextureT

type TextureChannelType = CompiledTypes.TextureChannelType
type SurfaceType = CompiledTypes.SurfaceType


--# IMPORTED CONSTANTS
local DEFAULT_MATERIAL_SIZE: Vector2 = ObjectTypes.DEFAULT_TEXTURE_SIZE
local TEXTURE_CHANNEL_TYPES: array<TextureChannelType> = CompiledTypes.TEXTURE_CHANNEL_TYPES


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
		_Size = DEFAULT_MATERIAL_SIZE :: Vector2,

		_AlbedoTextures = {} :: struct<TextureT>,
		_NormalTextures = {} :: struct<TextureT>,
		_SpecularTextures = {} :: struct<TextureT>,

		_AlbedoSampleScales = {} :: struct<number>,
		_NormalSampleScales = {} :: struct<number>,
		_SpecularSampleScales = {} :: struct<number>,

		_BaseMaterial = Enum.Material.Plastic :: Enum.Material,
		_ReflectionScale = 0.0 :: number,
		_Surfaces = {} :: array<SurfaceType>,
		_ParentContext = nil :: MaterialsContextT?
	}

	-- Enforces readonly behavior for Material.Name
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

	-- Finalize
	return setmetatable(newMaterial, ObjectTypes.getPrivateTable("RenderContext", name))
end

--- Destroys a Material instance and detaches it from the parent context.
--- @within Material
--- @tag Destructor
--- @return nil
function Material:destroy(): nil
	if self._ParentContext then
		self._ParentContext:removeMaterial(self._Name)
	end
	setmetatable(self, nil)
	return nil
end

--- Clones a Material instance
--- @within Material
--- @tag Cloner
--- @param name string -- The name to give the cloned Material
--- @return Material
function Material:clone(name: string): MaterialT
	local MaterialClone = Material.new(name)
	MaterialClone:setSize(self._Size)
	MaterialClone:setBaseMaterial(self._BaseMaterial)
	MaterialClone:setReflectionScale(self._ReflectionScale)

	for _, texChannelName: TextureChannelType in TEXTURE_CHANNEL_TYPES do
		for _, TexRef: TextureT in self["_"..texChannelName.."Textures"] do
			MaterialClone:addTexture(TexRef, texChannelName)
		end
	end

	return MaterialClone
end


--# SETTERS

--- Attaches the Material to an existing MaterialsContext.
--- @within Material
--- @param Context MaterialsContext -- The MaterialsContext to attach the Material to. If Context == nil, the Material will be detached from its parent context.
--- @tag Setter
--- @return nil
function Material:setParentContext(Context: MaterialsContextT?): nil
	local lastContext: MaterialsContextT? = self._ParentContext
	if lastContext then
		lastContext:removeMaterial(self._Name)
	end
	self._ParentContext = Context
	return nil
end

--- Sets the shared dimensions between all texture channels.
--- @within Material
--- @param size Vector2 -- The new size to set
--- @tag Setter
--- @return nil
function Material:setSize(size: Vector2): nil
	assert(size.X > 0 and size.Y > 0 and size.X < 513 and size.Y < 513, "ERROR [Material:setSize] <size> must be a Vector2 between (1, 1) and (512, 512)")
	self._Size = size
	-- subtexture sizes will automatically update during compilation
	return nil
end

--- Sets the UV sample scale of a Texture under a given texture channel.
--- @within Material
--- @param scale number -- The new scale to set
--- @param textureName string -- The name of the Texture under the texture channel
--- @param textureChannelType ("Albedo" | "Normal" | "Specular") -- The texture channel type
--- @tag Setter
--- @return nil
function Material:setTextureSampleScale(scale: number, textureName: string, textureChannelType: TextureChannelType): nil
	assert(scale > 0.0 and scale <= 1024.0, "ERROR [Material:setTextureSampleScale] <scale> must be a number > 0.0 and <= 1024.0")
	self["_"..textureChannelType.."SampleScales"][textureName] = scale
	return nil
end

--- Sets the shared dimensions between all texture channels.
--- @within Material
--- @param scale number -- The new scale to set
--- @tag Setter
--- @return nil
function Material:setReflectionScale(scale: number): nil
	assert(scale >= 0.0 and scale <= 1.0, "ERROR [Material:setReflectionScale] <scale> must be a number between (0.0, 1.0)")
	self._ReflectionScale = scale
	return nil
end

--- Sets the underlying Material that the current Material renders on top of.
--- @within Material
--- @tag Setter
--- @param material Enum.Material
--- @return nil
function Material:setBaseMaterial(material: Enum.Material): nil
	self._BaseMaterial = material
	return nil
end

--- Sets whether the Material renders on top of a specific surface type
--- @within Material
--- @tag Setter
--- @param surface ("Top" | "Bottom" | "Left" | "Right" | "Front" | "Back")
--- @param enabled boolean
--- @return nil
function Material:setSurfaceEnabled(surface: SurfaceType, enabled: boolean): nil
	self._Surface[surface] = enabled
	return nil
end

--- Adds a Texture to an existing texture channel. If the Texture already exists, a copy will still be added to the texture channel.
--- @within Material
--- @param textureChannelType -- The texture channel type ("Albedo", "Normal", "Specular")
--- @param Tex -- The Texture to add to the texture channel
--- @tag Setter
--- @return nil
function Material:addTexture(Tex: TextureT, textureChannelType: TextureChannelType): nil
	for _, TexRef: TextureT in self["_"..textureChannelType.."Textures"] do
		if TexRef == Tex then
			warn(TexRef ~= Tex, "ERROR [Material:addTexture] <Tex> of name <" .. Tex.Name .. "> is already in the texture channel")
			break
		end
	end

	table.insert(self["_"..textureChannelType.."Textures"], Tex)

	return nil
end

--- Removes a Texture from an existing texture channel. If the Texture already exists, a copy will still be added to the texture channel.
--- @within Material
--- @param textureChannelType -- The texture channel type ("Albedo", "Normal", "Specular")
--- @param Tex -- The Texture to remove from the texture channel
--- @tag Setter
--- @return nil
function Material:removeTexture(Tex: TextureT, textureChannelType: TextureChannelType): nil
	for i: number = #self["_"..textureChannelType.."Textures"], 1, -1 do
		local TexRef: TextureT = self["_"..textureChannelType.."Textures"][i]
		if TexRef == Tex then
			table.remove(self["_"..textureChannelType.."Textures"], i)
			return nil
		end
	end

	return nil
end

--- Removes all Textures from an existing texture channel.
--- @within Material
--- @param textureChannelType -- The texture channel type ("Albedo", "Normal", "Specular")
--- @tag Setter
--- @return nil
function Material:clearTextureChannel(textureChannelType: TextureChannelType): nil
	self["_"..textureChannelType.."Textures"] = {}
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

--- Returns the UV sample scale of a Texture under a given texture channel.
--- @within Material
--- @param textureName string -- The name of the Texture under the texture channel
--- @param textureChannelType ("Albedo" | "Normal" | "Specular") -- The texture channel type
--- @tag Getter
--- @return nil
function Material:getTextureSampleScale(textureName: string, textureChannelType: TextureChannelType): number | nil
	return self["_"..textureChannelType.."SampleScales"][textureName]
end

--- Returns the reflection scale of the Material.
--- @within Material
--- @tag Getter
--- @return number
function Material:getReflectionScale(): number
	return self._ReflectionScale
end

--- Returns the ParentContext of the Material.
--- @within Material
--- @tag Getter
--- @return MaterialsContextT? -- Returns nil if the ParentContext is nil
function Material:getParentContext(): MaterialsContextT?
	return self.ParentContext
end

--- Returns the underlying material the Material Instance renders on top of.
--- @within Material
--- @tag Getter
--- @return Enum.Material
function Material:getBaseMaterial(): Enum.Material
	return self._BaseMaterial
end

--- Returns whether the Material renders on top of a specific surface type.
--- @within Material
--- @tag Getter
--- @param surface ("Top" | "Bottom" | "Left" | "Right" | "Front" | "Back")
--- @return boolean
function Material:getSurfaceEnabled(surface: SurfaceType): boolean
	return self._Surface[surface]
end

--- Returns a Texture from an existing texture channel.
--- @within Material
--- @tag Getter
--- @param textureIdentifier string | TextureT -- The texture identifier (name of the Texture or the Texture instance itself)
--- @param textureChannelName string -- The name of the texture channel ("Albedo", "Normal", "Specular")
--- @return Texture? -- Returns nil if the Texture cannot be found
function Material:getTexture(textureIdentifier: string | TextureT, textureChannelName: string): TextureT?
	local texIdentifierType: string = type(textureIdentifier)

	if texIdentifierType == "string" then
		return self["_"..textureChannelName.."Textures"][textureIdentifier]
	else
		for _, Tex: any in self["_"..textureChannelName.."Textures"] do
			if Tex == textureIdentifier then
				return Tex
			end
		end
	end

	return nil
end

--- Returns the Textures inside of a texture channel
--- @within Material
--- @tag Getter
--- @param textureChannelType string -- The type of the texture channel ("Albedo", "Normal", "Specular")
--- @return {Texture} -- Returns an array of Texture objects
function Material:getTextureChannel(textureChannelType: TextureChannelType): array<TextureT>
	return self[textureChannelType.."Textures"] or {}
end

--- Returns all the Textures in use by the Material
--- @within Material
--- @tag Getter
--- @return {Texture} -- Returns an array of Texture objects
function Material:getAllTextures(): array<TextureT>
	local allTextures = {}

	for _, textureChannelType in TEXTURE_CHANNEL_TYPES do
		for _, Tex: TextureT in self[textureChannelType.."Textures"] do
			if not table.find(allTextures, Tex) then
				table.insert(allTextures, Tex)
			end
		end
	end

	return allTextures or {}
end

--# FINALIZE
return Material
