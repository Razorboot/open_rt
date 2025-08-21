--# INCLUDE
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))
local MaterialsContext = require(script.Parent:FindFirstChild("MaterialsContext"))


--# IMPORTED TYPES
type RenderContextT = ObjectTypes.RenderContextT
type LightingContextT = ObjectTypes.LightingContextT
type MaterialsContextT = ObjectTypes.MaterialsContextT
type CoreT = ObjectTypes.CoreT

type array<T> = CompiledTypes.array<T>

type CoreMode = CompiledTypes.CoreMode

--[=[
	This is where the core functionality of OpenRT is implemented.
	This instance acts as a "super state" for contexts used for rendering, materials, lighting, and more.
	The Core Singleton contains these properties:

	RenderingContext Instance defining the state of the rendering pipeline and graphics API.
	- RenderingContext :: RenderContext?

	LightingContext Instance defining the state of global and local lighting, sky, and fog.
	- LightingContext :: LightingContext?

	MaterialsContext Instance defining the state of the materials in the scene.
	- MaterialsContext :: MaterialsContext?

	@class Core
	@tag Singleton
]=]
local Core = {}
Core.__index = Core


--# CONSTRUCTOR/DESTRUCTOR
--- Creates a new OpenRT Core instance.
--- @tag Constructor
function Core:new(): CoreT
	local newCore = setmetatable({
		-- Context
		_RenderingContext = nil :: RenderContextT?,
		_LightingContext = nil :: LightingContextT?,
		_MaterialsContext = nil :: MaterialsContextT?,

		-- Management
		_Workers = {} :: array<Actor>,
		_Mode = "Idle" :: CoreMode
	}, Core)
	return newCore
end

--- Destroys an existing OpenRT Core instance and all attached metadata and instances.
--- @tag Destructor
function Core:destroy(): nil
	self:setRenderingContext(nil)
	self:setLightingContext(nil)
	self:setMaterialsContext(nil)
	setmetatable(self, nil)
	return nil
end


--# SETTERS

--- Assigns a RenderContext Instance to Core
--- @within Core
--- @param context -- The RenderContext Instance (can be nil)
--- @tag Setter
--- @return nil
function Core:setRenderingContext(context: RenderContextT): nil
	self._RenderingContext = context
	return nil
end

--- Assigns a LightingContext Instance to Core
--- @within Core
--- @param context -- The LightingContext Instance (can be nil)
--- @tag Setter
--- @return nil
function Core:setLightingContext(context: LightingContextT?): nil
	self._LightingContext = context
	return nil
end

--- Assigns a MaterialsContext Instance to Core
--- @within Core
--- @param context -- The MaterialsContext Instance (can be nil)
--- @tag Setter
--- @return nil
function Core:setMaterialsContext(context: MaterialsContextT): nil
	self._MaterialsContext = context
	return nil
end


--# PREPARE



--# GETTERS

--- Returns the current RenderContext Instance
--- @within Core
--- @return RenderContextT? -- The RenderContext or nil
function Core:getRenderingContext(): RenderContextT?
	return self._RenderingContext
end

--- Returns the current LightingContext Instance
--- @within Core
--- @return LightingContextT? -- The LightingContext or nil
function Core:getLightingContext(): LightingContextT?
	return self._LightingContext
end

--- Returns the current MaterialsContext Instance
--- @within Core
--- @return MaterialsContextT? -- The MaterialsContext or nil
function Core:getMaterialsContext(): MaterialsContextT?
	return self._MaterialsContext
end

--# FINALIZE
return Core
