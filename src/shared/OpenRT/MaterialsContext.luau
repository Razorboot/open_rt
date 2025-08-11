--!strict

--# INCLUDE
local ObjectTypes = require(script.Parent.ObjectTypes)
local Material = require(script.Parent.Material)
type MaterialT = ObjectTypes.Material
type MaterialsContextT = ObjectTypes.MaterialsContext
type TextureRegistryT = ObjectTypes.TextureRegistry


--# DEFINITION
--- The MaterialsContext singleton manages the creation of materials with albedo, normal, and specular properties.
--- @class MaterialsContext
--- @tag Singleton
local MaterialsContext = {}
MaterialsContext.__index = MaterialsContext


--- Creates a new MaterialsContext instance.
--- @tag Constructor
function MaterialsContext:new(): any
	local newMaterialsContext = {
		Materials = {} :: {[string]: MaterialT},
		TextureRegistry = {} :: TextureRegistryT
	}
	setmetatable(newMaterialsContext, MaterialsContext)
	return newMaterialsContext
end

--- Destroys an existing MaterialsContext instance and all associated metadata.
--- @within MaterialsContext
--- @method MaterialsContext:destroy()
--- @return nil
function MaterialsContext:destroy(): nil
	self.Materials = nil
	self.TextureRegistry = nil
	return nil
end


--# MATERIAL CONSTRUCTOR/DESTRUCTOR

--- Creates a new Material instance and adds it to the MaterialsContext.
--- @within MaterialsContext
--- @method MaterialsContext:addMaterial
--- @param MaterialInstance MaterialT -- The material instance to add
--- @return nil
function MaterialsContext:addMaterial(MaterialInstance: MaterialT): nil
	self.Materials[MaterialInstance.Name] = MaterialInstance
	return nil
end

--- Destroys an existing Material instance in an existing MaterialsContext instance.
--- @tag Destructor
function MaterialsContext:removeMaterial(name: string): nil
	self.Materials[name] = nil
	return nil
end


--# FINALIZE
return MaterialsContext