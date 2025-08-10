--!strict

--# INCLUDE
require(script.Parent.ObjectTypes)


--# DEFINITION
--- The MaterialsContext class manages the creation of materials with albedo, normal, and specular properties.
--- @class MaterialsContext
--- @tag Class
local MaterialsContext = {}
MaterialsContext.__index = MaterialsContext


--# CONSTRUCTOR/DESTRUCTOR
--- Creates a new MaterialsContext instance.
--- @tag Constructor
function MaterialsContext:new()
    local newMaterialsContext: MaterialsContextT = {
        Materials = {} :: {[string]: MaterialT},    -- A new material
        TextureRegistry = {} :: {[string]: Texture} -- Assuming Texture is defined elsewhere
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
function MaterialsContext:setMaterial(name: string, material: MaterialT): nil
	self.Materials[name] = material
	return nil
end


--# FINALIZE
return MaterialsContext