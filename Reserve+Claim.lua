local function destroy(object: any): ()
	assert(object ~= nil, "argument missing or nil")

	local methods = {"Destroy", "Disconnect"}

	for _, method in methods do
		local success = pcall(function()
			object[method](object)
		end)

		if success then
			return
		end
	end

	warn(`failed to destroy {object}`)
end

local function reserve(self: {[any]: any}, index: any, value: any, discard: boolean?): any
	assert(type(self) == "table", `invalid argument #1 (table expected, got {type(self)})`)
	assert(index ~= nil, "argument #2 missing or nil")
	assert(value ~= nil, "argument #3 missing or nil")
	assert((discard ~= nil and type(discard) == "boolean") or discard == nil, `invalid argument #4 (boolean expected, got {type(discard)})`)

	if self[index] == nil then
		self[index] = value
	elseif discard then
		destroy(value)
	end

	return self[index]
end

local function claim(self: {[any]: any}, index: any, value: any): any
	assert(type(self) == "table", `invalid argument #1 (table expected, got {type(self)})`)
	assert(index ~= nil, "argument #2 missing or nil")
	assert(value ~= nil, "argument #3 missing or nil")

	if self[index] ~= nil then
		destroy(self[index])
	end

	self[index] = value

	return self[index]
end

return reserve, claim