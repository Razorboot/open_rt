--!strict

--# INCLUDE
local ObjectTypes = require(script.Parent.ObjectTypes)
type MaterialT = ObjectTypes.MaterialT
type TextureT = ObjectTypes.TextureT
type MaterialsContextT = ObjectTypes.MaterialsContextT


--# DEFINITION
--- The MaterialsContext singleton manages the creation of materials with albedo, normal, and specular properties.
--- @class MaterialsContext
--- @tag Singleton
local MaterialsContext = {}
MaterialsContext.__index = MaterialsContext


--- Creates a new MaterialsContext instance.
--- @within MaterialsContext
--- @tag Constructor
--- @return MaterialsContext
function MaterialsContext.new(): any
	local newMaterialsContext = {
		-- Objects
		_Materials = {} :: {[string]: MaterialT},
		_TextureRegistry = {} :: {[string]: TextureT},

		-- Metadata
		_Properties = {
			diffuseEnabled = true :: boolean,
			specularEnabled = true :: boolean,
			normalEnabled = true :: boolean
		} :: {[string]: (string | number | boolean | Vector3 | Vector2)}
	}
	return setmetatable(newMaterialsContext, ObjectTypes.getPrivateTable("MaterialsContext", "MaterialsContext"))
end

--- Destroys an existing MaterialsContext instance and all associated metadata.
--- @within MaterialsContext
--- @tag Destructor
--- @return nil
function MaterialsContext:destroy(): nil
	self._Materials = nil

	-- clear the texture registry
	for _, editableImage: EditableImage in pairs(self._TextureRegistry) do
		editableImage:Destroy()
	end
	self._TextureRegistry = {}

	setmetatable(self, nil)
	return nil
end


--# SETTERS

--- Creates a new Material instance and adds it to the MaterialsContext.
--- @within MaterialsContext
--- @method addMaterial
--- @param MaterialInstance Material -- The material instance to add
--- @tag Setter
--- @return nil
function MaterialsContext:addMaterial(MaterialInstance: MaterialT): nil
	MaterialInstance:setParentContext(self)
	self._Materials[MaterialInstance.Name] = MaterialInstance
	return nil
end

--- Removes an existing Material instance from the MaterialsContext instance.
--- @within MaterialsContext
--- @method removeMaterial
--- @param identifier: (string | Material) -- The name of the material to remove. This will not delete the material instance.
--- @tag Setter
--- @return nil
function MaterialsContext:removeMaterial(identifier: (string | MaterialT)): nil
	if typeof(identifier) == "string" then
		self._Materials[identifier]._ParentContext = nil
		self._Materials[identifier] = nil
	else
		self._Materials[identifier.Name]._ParentContext = nil
		self._Materials[identifier.Name] = nil
	end
	return nil
end


--# GETTERS

--- Returns an existing Material instance from the MaterialsContext instance.
--- @within MaterialsContext
--- @method getMaterial
--- @param identifier: (string | Material) -- The Name of the Material or the Material instance itself
--- @tag Getter
--- @return MaterialT? -- Returns nil if the Material is not found
function MaterialsContext:getMaterial(identifier: (string | MaterialT)): MaterialT?
	local identifierType: string = typeof(identifier)

	for _, MaterialRef: MaterialT in pairs(self._Materials) do
		if identifierType == "string" then
			if MaterialRef:getName() == identifier then
				return MaterialRef
			end
		else
			if MaterialRef == identifier then
				return MaterialRef
			end
		end
	end
	return nil
end


--# FINALIZE
return MaterialsContext