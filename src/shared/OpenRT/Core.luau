--# INCLUDE
local Object = require(script.Parent:FindFirstChild("Object"))
local MaterialsContext = require(script.Parent:FindFirstChild("MaterialsContext"))


--[=[
	This is where the core functionality of OpenRT is implemented.
	This instance acts as a "super state" for contexts used for rendering, materials, lighting, and more.

	@class Core
	@tag Singleton
]=]
local Core = Object:extend()


--# CONSTRUCTOR/DESTRUCTOR
--- Creates a new OpenRT Core instance.
--- @tag Constructor
function Core:new()
	self.RenderingContext = nil -- The RenderingContext instance
	self.LightingContext = nil -- The LightingContext instance
	self.MaterialsContext = nil -- The MaterialsContext instance
end

--- Destroys an existing OpenRT Core instance and all attached metadata and instances.
--- @tag Destructor
function Core:destroy()
	self.RenderingContext = nil -- The RenderingContext instance
	self.LightingContext = nil -- The LightingContext instance
	self.MaterialsContext = nil -- The MaterialsContext instance
end


--# SETTERS
function Core:setRenderingContext(context): nil
	self.RenderingContext = context
	return nil
end

function Core:setLightingContext(context): nil
	self.LightingContext = context
	return nil
end

function Core:setMaterialsContext(context): nil
	self.MaterialsContext = context
	return nil
end


--# FINALIZE
return Core
