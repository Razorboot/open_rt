--!strict

--# INCLUDE
local ObjectTypes = require(script.Parent.ObjectTypes)
type MaterialT = ObjectTypes.Material
type MaterialsContextT = ObjectTypes.MaterialsContext
type TextureRegistryT = ObjectTypes.TextureRegistry


--# DEFINITION
--- The MaterialsContext class manages the creation of materials with albedo, normal, and specular properties.
--- @class MaterialsContext
--- @tag Class
local MaterialsContext = {}
MaterialsContext.__index = MaterialsContext

local Material = {}
Material.__index = Material


--# CONSTRUCTOR/DESTRUCTOR
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

--- Destroys an existing MaterialsContext instance.
--- @tag Destructor
function MaterialsContext:destroy(): nil
	self.Materials = nil
	self.TextureRegistry = nil
	return nil
end


--# SETTERS
--- Sets or adds a new material to an existing MaterialsContext instance.
function MaterialsContext:newMaterial(name: string, albedo: Color3, normal: Vector3, specular: number)
	local newMaterial: MaterialT = {
		Name = name,
		Albedo = albedo,
		Normal = normal,
		Specular = specular
	}
	setmetatable(newMaterial, Material)
	self.Materials[name] = newMaterial
	return newMaterial
end

function MaterialsContext:setMaterial(name: string, material: MaterialT): nil
	self.Materials[name] = material
	return nil
end


--# FINALIZE
return MaterialsContext