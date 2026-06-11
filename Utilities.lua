local utilities = {}

function utilities.destroy(object: any): ()
	assert(object ~= nil, "argument missing or nil")

	local methods = {"Destroy", "Disconnect"}

	for _, method in methods do
		if type(method) == "function" then
			local success = pcall(object[method], object)

			if success then
				return
			end
		end
	end

	warn(`failed to destroy {object}`)
end

function utilities.reserve(self: {[any]: any}, index: any, value: any, discard: boolean?): any
	assert(type(self) == "table", `invalid argument #1 (table expected, got {type(self)})`)
	assert(index ~= nil, "argument #2 missing or nil")
	assert(value ~= nil, "argument #3 missing or nil")
	assert((discard ~= nil and type(discard) == "boolean") or discard == nil, `invalid argument #4 (boolean expected, got {type(discard)})`)

	if self[index] == nil then
		self[index] = value
	elseif discard then
		utilities.destroy(value)
	end

	return self[index]
end

function utilities.claim(self: {[any]: any}, index: any, value: any): any
	assert(type(self) == "table", `invalid argument #1 (table expected, got {type(self)})`)
	assert(index ~= nil, "argument #2 missing or nil")
	assert(value ~= nil, "argument #3 missing or nil")

	if self[index] ~= nil then
		utilities.destroy(self[index])
	end

	self[index] = value

	return self[index]
end

type Loop = {
	Enabled: boolean,
	Callback: (deltaTime: number?) -> (),
	Toggle: (self: Loop, boolean: boolean?) -> (),
	Destroy: () -> (),
}

utilities.loop = {} utilities.reserve(utilities.loop, "Cache", {})

function utilities.loop.new(callback: (deltaTime: number?) -> (), disable: boolean?): (Loop)
	assert(type(callback) == "function", `invalid argument #1 (function expected, got {type(callback)})`)
	assert((disable ~= nil and type(disable) == "boolean") or disable == nil, `invalid argument #2 (boolean expected, got {type(disable)})`)

	utilities.loop.Cache[callback] = {
		["Enabled"] = not disable,
		["Callback"] = callback,

		["Toggle"] = function(self: Loop, boolean: boolean?): ()
			assert(self == utilities.loop.Cache[callback], `invalid argument #1 (Loop: {callback} expected, got {type(self)})`)
			assert((boolean ~= nil and type(boolean) == "boolean") or boolean == nil, `invalid argument #2 (boolean expected, got {type(boolean)})`)

			if boolean == nil then
				self.Enabled = not self.Enabled
			else
				self.Enabled = boolean
			end
		end,

		["Destroy"] = function(): ()
			utilities.loop.Cache[callback] = nil
		end,
	}

	return utilities.loop.Cache[callback]
end

utilities.reserve(utilities.loop, "Connection", game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	for _, loop in utilities.loop.Cache:: {Loop} do
		if loop.Enabled then
			local success, result = pcall(loop.Callback, deltaTime)

			if not success then warn(result) end
		end
	end
end), true)

return utilities