--! strict


--# INCLUDE
local CompiledTypes = require(script.Parent:FindFirstChild("CompiledTypes"))
local ObjectTypes = require(script.Parent:FindFirstChild("ObjectTypes"))


--# IMPORT TYPES
type CoreT = ObjectTypes.CoreT
type RenderContextT = ObjectTypes.RenderContextT

type array<T> = CompiledTypes.array<T>
type struct<T> = CompiledTypes.struct<T>

--# IMPORT CONSTANTS


--# INIT RENDERCONTEXT

--[=[
    The RenderContext singleton defines important information about the per-pixel rendering pipeline. 
    This not only includes properties that allow you to change the rendering state of your OpenRT instance, 
    but also the ability to add to or modify the rendering pipeline with ShaderPasses.

    Properties:
    - Name: String - The name of the RenderContext
    - Parent: CoreT? - The parent Core object (optional)
    
    Screen and viewport properties:
    - ScreenSize: Vector2 - The size of the screen (default: 80x80)
    - ViewportSize: Vector2 - The size of the viewport (default: 80x80)
    - WorldScreenDistance: number - Distance from world to screen (default: 20.0)
    
    Rendering properties:
    - RayDistance: number - Maximum ray tracing distance (default: 1000.0)
    - FogStart: number - Distance where fog begins (default: 0.0)
    - Gamma: number - Gamma correction value (default: 2.2)
    
    Camera/World coordinate properties:
    - WorldScreenCoord: CFrame - World screen coordinate frame
    - WorldScreenCornerCoord: CFrame - World screen corner coordinate frame
    
    Lighting properties:
    - SunDirection: Vector3 - Direction of the sun light (default: -Vector3.one)
    - SkyColor: Vector3 - Color of the sky (default: Vector3.one)
    
    Interlacing properties:
    - InterlaceGroupCount: number - Number of interlace groups (default: 1)
    - InterlaceGroup: number - Current interlace group (default: 1)
    
    Shader system:
    - ShaderRegistry: array<any> - Registry of shader passes

    @class RenderContext
    @tag Class
]=]
local RenderContext = {}
RenderContext.__index = RenderContext


--# CONSTRUCTOR/DESTRUCTOR

function RenderContext.new(name: string): any
    local newRenderContext = {
        properties = {
            _Name = name :: string,
            _Parent = nil :: CoreT?,

            _ScreenSize = Vector2.new(80, 80) :: Vector2,
            _RayDistance = 1000.0 :: number,
            _FogStart = 0.0 :: number,
            _Gamma = 2.2 :: number,

            _ViewportSize = Vector2.new(80, 80) :: Vector2,
            _WorldScreenDistance = 20.0 :: number,

            _WorldScreenCoord = CFrame.identity,
            _WorldScreenCornerCoord = CFrame.identity,

            _SunDirection = -Vector3.one,
            _SkyColor = Vector3.one,

            _InterlaceGroupCount = 1,
            _InterlaceGroup = 1,

            _ShaderRegistry = {} :: array<any>,
        } :: struct<any>
    }
	return setmetatable(newRenderContext, ObjectTypes.getPrivateTable("RenderContext", name))
end

--- Destroys a RenderContext instance.
--- @within RenderContext
--- @tag Destructor
--- @return nil
function RenderContext:destroy(): nil
	self.properties = nil
	setmetatable(self, nil)
	return nil
end


--# SETTERS

--- Sets the parent Core object.
--- @within RenderContext
--- @param parent CoreT? -- The parent Core object (can be nil)
--- @tag Setter
--- @return nil
function RenderContext:setParent(parent: CoreT?): nil
	self.properties._Parent = parent
	return nil
end

--- Sets the screen size.
--- @within RenderContext
--- @param screenSize Vector2 -- The new screen size, capped at (512, 512)
--- @tag Setter
--- @return nil
function RenderContext:setScreenSize(screenSize: Vector2int16): nil
    assert(math.floor(screenSize.X) == screenSize.X and math.floor(screenSize.Y) == screenSize.Y, "ERROR [RenderContext:setScreenSize] Screen size must use integer values")
	assert(screenSize.X > 0 and screenSize.Y > 0 and screenSize.X <= 512 and screenSize.Y <= 512, "ERROR [RenderContext:setScreenSize] Screen size must use positive integers no greater than (512, 512)")
	self.properties._ScreenSize = screenSize
	return nil
end

--- Sets the viewport size.
--- @within RenderContext
--- @param viewportSize Vector2 -- The new viewport size
--- @tag Setter
--- @return nil
function RenderContext:setViewportSize(viewportSize: Vector2): nil
	assert(viewportSize.X > 0 and viewportSize.Y > 0, "ERROR [RenderContext:setViewportSize] Viewport size must be positive")
	self.properties._ViewportSize = viewportSize
	return nil
end

--- Sets the world screen distance.
--- @within RenderContext
--- @param distance number -- The new world screen distance
--- @tag Setter
--- @return nil
function RenderContext:setWorldScreenDistance(distance: number): nil
	assert(distance > 0, "ERROR [RenderContext:setWorldScreenDistance] Distance must be positive")
	self.properties._WorldScreenDistance = distance
	return nil
end

--- Sets the maximum ray tracing distance.
--- @within RenderContext
--- @param distance number -- The new ray distance
--- @tag Setter
--- @return nil
function RenderContext:setRayDistance(distance: number): nil
	assert(distance > 0, "ERROR [RenderContext:setRayDistance] Ray distance must be positive")
	self.properties._RayDistance = distance
	return nil
end

--- Sets the fog start distance.
--- @within RenderContext
--- @param fogStart number -- The new fog start distance
--- @tag Setter
--- @return nil
function RenderContext:setFogStart(fogStart: number): nil
	assert(fogStart >= 0, "ERROR [RenderContext:setFogStart] Fog start must be non-negative")
	self.properties._FogStart = fogStart
	return nil
end

--- Sets the gamma correction value.
--- @within RenderContext
--- @param gamma number -- The new gamma value
--- @tag Setter
--- @return nil
function RenderContext:setGamma(gamma: number): nil
	assert(gamma > 0, "ERROR [RenderContext:setGamma] Gamma must be positive")
	self.properties._Gamma = gamma
	return nil
end

--- Sets the world screen coordinate frame.
--- @within RenderContext
--- @param coord CFrame -- The new world screen coordinate frame
--- @tag Setter
--- @return nil
function RenderContext:setWorldScreenCoord(coord: CFrame): nil
	self.properties._WorldScreenCoord = coord
	return nil
end

--- Sets the sun direction.
--- @within RenderContext
--- @param direction Vector3 -- The new sun direction
--- @tag Setter
--- @return nil
function RenderContext:setSunDirection(direction: Vector3): nil
	self.properties._SunDirection = direction.Unit
	return nil
end

--- Sets the sky color.
--- @within RenderContext
--- @param color Vector3 -- The new sky color
--- @tag Setter
--- @return nil
function RenderContext:setSkyColor(color: Vector3): nil
	self.properties._SkyColor = color
	return nil
end

--- Sets the interlace group count.
--- @within RenderContext
--- @param count number -- The new interlace group count
--- @tag Setter
--- @return nil
function RenderContext:setInterlaceGroupCount(count: number): nil
	assert(count >= 1 and count == math.floor(count), "ERROR [RenderContext:setInterlaceGroupCount] Count must be a positive integer")
	self.properties._InterlaceGroupCount = count
	return nil
end

-- TODO: FIX BELOW
--- Sets the current interlace group.
--- @within RenderContext
--- @param group number -- The new interlace group
--- @tag Setter
--- @return nil
function RenderContext:setInterlaceGroup(group: number): nil
	assert(group >= 1 and group == math.floor(group), "ERROR [RenderContext:setInterlaceGroup] Group must be a positive integer")
	assert(group <= self.properties._InterlaceGroupCount, "ERROR [RenderContext:setInterlaceGroup] Group cannot exceed InterlaceGroupCount")
	self.properties._InterlaceGroup = group
	return nil
end

--- Adds a shader pass to the shader registry.
--- @within RenderContext
--- @param shader any -- The shader pass to add
--- @tag Setter
--- @return nil
function RenderContext:addShaderPass(shader: any): nil
	table.insert(self.properties._ShaderRegistry, shader)
	return nil
end

--- Removes a shader pass from the shader registry.
--- @within RenderContext
--- @param shader any -- The shader pass to remove
--- @tag Setter
--- @return nil
function RenderContext:removeShaderPass(shader: any): nil
	for i = #self.properties._ShaderRegistry, 1, -1 do
		if self.properties._ShaderRegistry[i] == shader then
			table.remove(self.properties._ShaderRegistry, i)
			return nil
		end
	end
	return nil
end

--- Clears all shader passes from the shader registry.
--- @within RenderContext
--- @tag Setter
--- @return nil
function RenderContext:clearShaderRegistry(): nil
	self.properties._ShaderRegistry = {}
	return nil
end


--# GETTERS

--- Returns the name of the RenderContext.
--- @within RenderContext
--- @tag Getter
--- @return string
function RenderContext:getName(): string
	return self.properties._Name
end

--- Returns the parent Core object.
--- @within RenderContext
--- @tag Getter
--- @return CoreT?
function RenderContext:getParent(): CoreT?
	return self.properties._Parent
end

--- Returns the screen size.
--- @within RenderContext
--- @tag Getter
--- @return Vector2
function RenderContext:getScreenSize(): Vector2
	return self.properties._ScreenSize
end

--- Returns the viewport size.
--- @within RenderContext
--- @tag Getter
--- @return Vector2
function RenderContext:getViewportSize(): Vector2
	return self.properties._ViewportSize
end

--- Returns the world screen distance.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getWorldScreenDistance(): number
	return self.properties._WorldScreenDistance
end

--- Returns the maximum ray tracing distance.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getRayDistance(): number
	return self.properties._RayDistance
end

--- Returns the fog start distance.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getFogStart(): number
	return self.properties._FogStart
end

--- Returns the gamma correction value.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getGamma(): number
	return self.properties._Gamma
end

--- Returns the world screen coordinate frame.
--- @within RenderContext
--- @tag Getter
--- @return CFrame
function RenderContext:getWorldScreenCoord(): CFrame
	return self.properties._WorldScreenCoord
end

--- Returns the world screen corner coordinate frame.
--- @within RenderContext
--- @tag Getter
--- @return CFrame
function RenderContext:getWorldScreenCornerCoord(): CFrame
	return self.properties._WorldScreenCornerCoord
end

--- Returns the sun direction.
--- @within RenderContext
--- @tag Getter
--- @return Vector3
function RenderContext:getSunDirection(): Vector3
	return self.properties._SunDirection
end

--- Returns the sky color.
--- @within RenderContext
--- @tag Getter
--- @return Vector3
function RenderContext:getSkyColor(): Vector3
	return self.properties._SkyColor
end

--- Returns the interlace group count.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getInterlaceGroupCount(): number
	return self.properties._InterlaceGroupCount
end

--- Returns the current interlace group.
--- @within RenderContext
--- @tag Getter
--- @return number
function RenderContext:getInterlaceGroup(): number
	return self.properties._InterlaceGroup
end

--- Returns the shader registry.
--- @within RenderContext
--- @tag Getter
--- @return array<any>
function RenderContext:getShaderRegistry(): array<any>
	return self.properties._ShaderRegistry
end


--# FINALIZE
return RenderContext 
