-- !strict
-- TraceLib/SharedState.luau
-- Holds shared, immutable per-frame state for all render Actors.

--# Include
require(script.Parent:FindFirstChild("CompiledTypes"))

--# Point
local SharedState = SharedTable.new()

--# Init
SharedState:Set("frameState", {
	frameIndex = 0,

	render = {
		screenW = 0,
		screenH = 0,
		rayDistance = 0,
		fogStart = 0,
		gamma = 0,

		viewportW = 0,
		viewportH = 0,
		worldScreenDistance = 0,

		worldScreenCoord = CFrame.new(),
		worldScreenCornerCoord = CFrame.new(),

		sunDirection = Vector3.new(),
		skyColor = Vector3.new(),

		interlaceGroupCount = 0,
		interlaceGroup = 0,
	},

	materials = {
		count = 0,
		albedoTexId = nil,
		specular = nil,
		normalStrength = nil,
		flags = nil,
	},

	lights = {
		count = 0,
		pos = nil,
		color = nil,
		range = nil,
		type = nil,
		flags = nil,
	},

	textures = nil,

	shaders = nil,
})

--# Finalize
return SharedState