--# INCLUDE
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local MaterialsContext = require(script.Parent:FindFirstChild("MaterialsContext"))


--[=[
	This is where the core functionality of OpenRT is implemented.
	This instance acts as a "super state" for contexts used for rendering, materials, lighting, and more.

	@class Core
	@tag Singleton
]=]
local Core = {}
Core.__index = Core


--# CONSTRUCTOR/DESTRUCTOR
--- Creates a new OpenRT Core instance.
--- @tag Constructor
function Core:new(): any
	local newCore = setmetatable({
		RenderingContext = nil,
		LightingContext = nil,
		MaterialsContext = nil
	}, Core)
	return newCore
end

--- Destroys an existing OpenRT Core instance and all attached metadata and instances.
--- @tag Destructor
function Core:destroy(): nil
	self.RenderingContext = nil -- The RenderingContext instance
	self.LightingContext = nil -- The LightingContext instance
	self.MaterialsContext = nil -- The MaterialsContext instance
	setmetatable(self, nil)
	return nil
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
