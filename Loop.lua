local reserve = loadstring(game:HttpGet("https://raw.githubusercontent.com/odioism/Utilities/refs/heads/main/Reserve%2BClaim.lua"))()

export type Loop = {
	Enabled: boolean,
	Callback: (deltaTime: number?) -> (),
	Toggle: (self: Loop, boolean: boolean?) -> (),
	Destroy: () -> (),
}

local Loop = {} reserve(Loop, "Cache", {})

function Loop.new(callback: (deltaTime: number?) -> (), disable: boolean?): (Loop)
	assert(type(callback) == "function", `invalid argument #1 (function expected, got {type(callback)})`)
	assert((disable ~= nil and type(disable) == "boolean") or disable == nil, `invalid argument #2 (boolean expected, got {type(disable)})`)

	Loop.Cache[callback] = {
		["Enabled"] = not disable,
		["Callback"] = callback,

		["Toggle"] = function(self: Loop, boolean: boolean?): ()
			assert(self == Loop.Cache[callback], `invalid argument #1 (Loop: {callback} expected, got {type(self)})`)
			assert((boolean ~= nil and type(boolean) == "boolean") or boolean == nil, `invalid argument #2 (boolean expected, got {type(boolean)})`)

			if boolean == nil then
				self.Enabled = not self.Enabled
			else
				self.Enabled = boolean
			end
		end,

		["Destroy"] = function(): ()
			Loop.Cache[callback] = nil
		end,
	}

	return Loop.Cache[callback]
end

reserve(Loop, "Connection", game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	for _, loop in Loop.Cache:: {Loop} do
		if loop.Enabled then
			local success, result = pcall(loop.Callback, deltaTime)

			if not success then warn(result) end
		end
	end
end), true)

return Loop