--!strict

--# INCLUDE
local ObjectTypes = require(script.Parent.ObjectTypes)
type MaterialT = ObjectTypes.Material
type MaterialsContextT = ObjectTypes.MaterialsContext


--# DEFINITION
--- The MaterialsContext singleton manages the creation of materials with albedo, normal, and specular properties.
--- @class MaterialsContext
--- @tag Singleton
local MaterialsContext = {}
MaterialsContext.__index = MaterialsContext


--- Creates a new MaterialsContext instance.
--- @within MaterialsContext
--- @tag Constructor
--- @method MaterialsContext.new
--- @return MaterialsContext
function MaterialsContext.new(): MaterialsContextT
	local newMaterialsContext = {
		Materials = {} :: {[string]: MaterialT},
		TextureRegistry = {} :: {[string]: EditableImage}
	}
	return setmetatable(newMaterialsContext, MaterialsContext)
end

--- Destroys an existing MaterialsContext instance and all associated metadata.
--- @within MaterialsContext
--- @method MaterialsContext:destroy
--- @tag Destructor
--- @return nil
function MaterialsContext:destroy(): nil
	self.Materials = nil

	-- clear the texture registry
	for _, editableImage: EditableImage in pairs(self.TextureRegistry) do
		editableImage:Destroy()
	end
	self.TextureRegistry = nil

	setmetatable(self, nil)
	return nil
end


--# MATERIAL MANAGEMENT

--- Creates a new Material instance and adds it to the MaterialsContext.
--- @within MaterialsContext
--- @method MaterialsContext:addMaterial
--- @param MaterialInstance MaterialT -- The material instance to add
--- @tag Mutator
--- @return nil
function MaterialsContext:addMaterial(MaterialInstance: MaterialT): nil
	MaterialInstance.ParentContext = self
	self.Materials[MaterialInstance.Name] = MaterialInstance
	return nil
end

--- 

--- Removes an existing Material instance from the MaterialsContext instance.
--- @within MaterialsContext
--- @method MaterialsContext:removeMaterial
--- @param identifier: (string | MaterialT) -- The name of the material to remove. This will not delete the material instance.
--- @tag Mutator
--- @return nil
function MaterialsContext:removeMaterial(identifier: (string | MaterialT)): nil
	if typeof(identifier) == "string" then
		self.Materials[identifier].ParentContext = nil
		self.Materials[identifier] = nil
	else
		self.Materials[identifier.Name].ParentContext = nil
		self.Materials[identifier.Name] = nil
	end
	return nil
end


--# FINALIZE
return MaterialsContext