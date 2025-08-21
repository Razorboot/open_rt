--!strict

--# SERVICES
local AssetService = game:GetService("AssetService")


--# INCLUDE
local CompileHelper = require(script.Parent:FindFirstChild("CompileHelper"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))


--# IMPORT TYPES
type array<T> = CompiledTypes.array<T>

type MaterialT = ObjectTypes.MaterialT


--# IMPORTED CONSTANTS
local DEFAULT_TEXTURE_SIZE: Vector2 = ObjectTypes.DEFAULT_TEXTURE_SIZE


--# POINT

--[=[
	The Texture class acts as a wrapper around an EditableImage with added metadata used by OpenRT for appearance modification, such as transprency, gamma, tint, and more.
	Textures are typically used to provide surface information for materials, though they are also used for other purposes, like frame captures.
	The below properties are used to modify the appearance of the Texture, but they are read only and can be accessed with Setters and Getters (see below).

	Each Material Instance contains...

	The name of the Texture
	- Name: String

	The resolution of the Texture, This property is read only when the Texture is parented to a Material.
	- Size: Vector2 *- default: (64, 64)*

	The scale of the Texture. This gets used for Materials with UV mapping, but is disabled for frame captures.
	- Scale: number *- default: (1.0)*

	The Material the Texture belongs to:
	- ParentMaterial: Material

	The EditableImage used by the Texture:
	- Image: EditableImage

	The Content used to create the EditableImage.
	- ImageContent: Content

	The PixelBuffer compiled from the Texture's Image data whenever the Image is changed.
	- PixelBuffer: buffer

	@class Texture
	@tag Class
]=]
local Texture = {}
Texture.__index = Texture


--# CONSTRUCTOR/DESTRUCTOR

--- Creates a new Texture instance.
--- @within Texture
--- @tag Constructor
--- @param name -- The name of the Texture
--- @return Texture
function Texture.new(name: string): any
	local newTexture = {
		_Name = name,
		_Size = DEFAULT_TEXTURE_SIZE :: Vector2,
		_Image = nil :: EditableImage?,
		_Content = nil :: Content?,
		_PixelBuffer = nil :: buffer?,
		_Parent = nil :: MaterialT?,
		_Scale = 1.0 :: number
	}
	
	local mt = {
		__index = function(self, key)
			if key == "Name" then
				return rawget(self, "_Name")
			end
			return Texture[key]
		end,
		__newindex = function(self, key, value)
			if key == "Name" then
				error("ERROR: Material.Name is readonly and cannot be changed after initialization.")
			end
			rawset(self, key, value)
		end
	}
	return setmetatable(newTexture, ObjectTypes.getPrivateTable("RenderContext", name))
end

--- Destroys the current Image and all associated metadata for the Texture
--- @within Texture
--- @tag Destructor
--- @return nil
function Texture:destroy(): nil
	if self._Image then
		self._Image:Destroy()
	end
	setmetatable(self, nil)
	return nil
end

--- Clones a Texture instance
--- @within Texture
--- @tag Cloner
--- @param name string -- The name to give the cloned Texture
--- @return Texture
function Texture:clone(name: string): Texture
	local TextureClone = Texture.new(name)
	TextureClone:setSize(self._Size)
	TextureClone:setScale(self._Scale)
	TextureClone:setImageId(self._ImageId)

	return TextureClone
end


--# SETTERS

--- Sets the MaterialsContext that the Texture is stored in.
--- @within Texture
--- @tag Setter
--- @method setParentContext
--- @param Context: MaterialsContext -- The context the Texture is stored in
--- @return nil
function Texture:setParentContext(Context: any): nil
	assert(Context, string.format("ERROR [Texture:setParentContext] <Context> is of type <%s> must be a <MaterialsContext>", typeof(Context)))
	self._ParentContext = Context
	self:_updateTextureRegistry()
	return nil
end

--- Sets the dimensions of the EditableImage attached to the Texture
--- @within Texture
--- @tag Setter
--- @method setSize
--- @param size: Vector2 -- The new size of the Texture
--- @return nil
function Texture:setSize(size: Vector2): nil
	self._Size = size
	if self._Image then
		self._Image:Destroy()
	end
	self._Image = AssetService:CreateEditableImageAsync(self._Content, size)
	self:compile()
	return nil
end

--- Sets the scale of the Image attached to the Texture for UV mapping during rendering
--- @within Texture
--- @tag Setter
--- @method setScale
--- @param scale: number -- The new scale of the Texture
--- @return nil
function Texture:setScale(scale: number): nil
	self._Scale = scale
	self:setSize(self._Size)
	self:compile()
	return nil
end

--- Creates an EditableImage from an asset ID and assigns it to the Texture
--- @within Texture
--- @tag Setter
--- @param imageId -- The image id used to create the Image
--- @return nil
function Texture:setImageId(imageId: string): nil
	self:setContent(Content.fromUri(imageId))
	return nil
end

--- Creates a new EditableImage and assigns it to the Texture
--- @within Texture
--- @tag Setter
--- @param imageContent -- The Image Content used to create the EditableImage used by the Texture
--- @return nil
function Texture:setContent(imageContent: Content): nil
	assert(imageContent.SourceType == Enum.ContentSourceType.Uri, "ERROR [Texture:setContent] <imageContent> must be of <ContentSourceType.Uri>")
	self._Content = imageContent
	self._Image = AssetService:CreateEditableImageAsync(imageContent, self._Size)
	self:compile()
	return nil
end

--- Compiles the Texture's Image pixel data into a buffer.u8 and assigns it to the Texture's PixelBuffer
--- @within Texture
--- @tag Setter
--- @return buffer? -- Returns nil if Image is nil
function Texture:compile(): buffer?
	if not self._Image then
		warn(string.format("WARNING [Texture:compile] Cannot compile because Image under Texture.Name = %q is not yet initialized", self.Name))
		return nil
	end
	self._PixelBuffer = self._Image:ReadPixelsBuffer(Vector2.zero, self._Size)
	return self._PixelBuffer
end


--# GETTERS

--- Returns the Name of the Texture
--- @within Texture
--- @tag Getter
--- @return string
function Texture:getName(): string
	return self._Name
end

--- Returns the Size of the Texture
--- @within Texture
--- @tag Getter
--- @return Vector2 -- Returns nil if Size is nil
function Texture:getSize(): Vector2
	return self._Size
end

--- Returns the Scale of the Texture
--- @within Texture
--- @tag Getter
--- @return number
function Texture:getScale(): number
	return self._Scale
end

--- Returns the URI of Content attached to the Texture
--- @within Texture
--- @tag Getter
--- @return string? -- Returns nil if Content is nil
function Texture:getImageId(): string?
	if not self._Content then
		return nil
	end
	return self._Content.Uri
end