--!strict

--# SERVICES
local AssetService = game:GetService("AssetService")


--# INCLUDE
local CompileHelper = require(script.Parent:FindFirstChild("CompileHelper"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))


--# IMPORT TYPES
type array<T> = CompiledTypes.array<T>


--# IMPORTED CONSTANTS
local DEFAULT_TEXTURE_SIZE: Vector2 = ObjectTypes.DEFAULT_TEXTURE_SIZE


--# POINT

--[=[
	The Texture class acts as a wrapper around an EditableImage with added metadata used by OpenRT for appearance modification, such as transprency, gamma, tint, and more.
	Textures are typically used to provide surface information for materials, though they are also used for other purposes, like frame captures.
	
	Each Material Instance contains...

	The name of the Texture
	- Name: String

	The size of the Texture, (64, 64) by default. This property is read only when the Texture is parented to a Material.
	- Size: Vector2

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
		Name = name,
		Size = DEFAULT_TEXTURE_SIZE :: Vector2,
		Image = nil :: EditableImage?,
		Content = nil :: Content?,
		PixelBuffer = nil :: buffer?
	}
	return setmetatable(newTexture, Texture)
end

--- Destroys the current Image and all associated metadata for the Texture
--- @within Texture
--- @tag Destructor
--- @return nil
function Texture:destroy(): nil
	if self.Image then 
		self.Image:Destroy() 
	end
	return nil
end


--# SETTERS

--- Sets the MaterialsContext that the Texture is stored in.
--- @within Texture
--- @tag Setter
--- @method setParentContext
--- @param Context: MaterialsContext -- The context the Texture is stored in
--- @return nil
function Texture:setParentContext(Context: any): nil
	self.ParentContext = Context
	return nil
end

--- Sets the dimensions of the EditableImage attached to the Texture
--- @within Texture
--- @tag Setter
--- @method setSize
--- @param size: Vector2 -- The new size of the texture
--- @return nil
function Texture:setSize(size: Vector2): nil
	self.Size = size
	if self.Image then  
		self.Image = AssetService:CreateEditableImageAsync(self.Content, size)
		self.Image:Destroy()
	end
	return nil
end

--- Creates and assigns a new Image to the Texture
--- @within Texture
--- @tag Setter
--- @param imageId -- The image id used to create the Image
--- @return nil
function Texture:setImageId(imageId: string): nil
	self.Content = Content.fromUri(imageId)
	self.Image = AssetService:CreateEditableImageAsync(self.Content, self.Size)
	return nil
end

--- Creates a new EditableImage and assigns it to the Texture
--- @within Texture
--- @tag Setter
--- @param imageContent -- The Image Content used to create the EditableImage used by the Texture
--- @return nil
function Texture:setContent(imageContent: Content): nil
	assert(imageContent.SourceType == Enum.ContentSourceType.Uri, "ERROR [Texture:setContent] <imageContent> must be of <ContentSourceType.Uri>")
	self.Content = imageContent
	self.Image = AssetService:CreateEditableImageAsync(imageContent, self.Size)
	return nil
end


--- Compiles the Texture's Image pixel data into a buffer.u8 and assigns it to the Texture's PixelBuffer
--- @within Texture
--- @tag Setter
--- @return buffer
function Texture:compile(): buffer?
	if not self.Image then 
		warn("WARNING [Texture:compile] Cannot compile because Image is not yet initialized") 
		return nil 
	end
	self.PixelBuffer = self.Image:ReadPixelsBuffer(Vector2.zero, self.Size)
	return self.PixelBuffer
end