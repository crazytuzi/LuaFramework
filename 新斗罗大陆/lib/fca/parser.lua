-- fca parser

local parser = {}

local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local find = string.find
local sub = string.sub
local insert = table.insert
local atan2 = math.atan2
local atan = math.atan
local deg = math.deg
local max = math.max
local floor = math.floor
local tonumber = tonumber

local iter
local char
local action
local frame
local animdura = {}
local animatkfram = {}
local effect_dura = {}
local effect_atkfram = {}
local out

local atFrameBegin
local instances
local function parseElement(elem, line)
	local file, a, b, c, d, tx, ty, alpha = match(line, 
	"^Element%(([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^%)]*)%)")
	a = tonumber(a)
	b = tonumber(b)
	c = tonumber(c)
	d = tonumber(d)
	tx = tonumber(tx)
	ty = tonumber(ty)
	alpha = tonumber(alpha)
	local name = instances[file] and (file .. "-" .. (instances[file] + 1)) or file
	instances[file] = (instances[file] or 0) + 1
	local id
	for i, v in ipairs(char.elements) do
		if v.name == name then 
			id = i
			break
		end
	end
	if not id then
		local element = {} -- anim.element()
		element.name = name;
		element.file = file;
		element.index = #char.elements + 1
		insert(char.elements, element)
		id = element.index
	end
	elem.element_idx = id
	elem.alpha = floor(alpha * 255 + 0.5)
	elem.matrix = {a, b, c, d, tx, ty}
end

local function parseEvent(event, line)
	local name = match(line, "^Event%(([^,%)]*)")
	if name == "Attack" then
		event.type = "ATTACK" -- 0	-- ATTACK
		local x, y = match(line, "Attack,([^,]*),([^%)]*)")
		if x and y then event.position = {tonumber(x), tonumber(y)} end
		if not animatkfram[char.name][action.name] then
			animatkfram[char.name][action.name] = {}
		end
		insert(animatkfram[char.name][action.name], {
			Time = #action.frames / action.fps,
			X = x or 0,
			Y = -(y or 0),
		})
	elseif name == "PlaySound" then
		event.type = "PLAYSOUND" -- 1  -- PLAYSOUND
		local filename = match(line, "PlaySound,([^%)]*)")
		event.filename = filename
	elseif name == "PlayEffect" then
		local name, a, b, c, d, tx, ty = match(line, 
		"PlayEffect,([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^%)]*)")
		a = tonumber(a)
		b = tonumber(b)
		c = tonumber(c)
		d = tonumber(d)
		tx = tonumber(tx)
		ty = tonumber(ty)
		event.type = "PLAYEFFECT" -- 2  -- PLAYEFFECT
		event.filename = name
		event.matrix = {a, b, c, d, tx, ty}
		event.zOrder = atFrameBegin and -1 or 1

	end


	print(event.type,event.filename)
end

local function parseFrame()
	atFrameBegin = true
	instances = {}
	for line in iter do
		if match(line, "^Element") then
			atFrameBegin = false
			local elem = {} -- anim.frameElement()
			parseElement(elem, line)
			insert(frame.elements, elem)
		elseif match(line, "^Event") then
			local event = {} -- anim.event()
			parseEvent(event, line)
			insert(frame.events, event)
		elseif line == "FrameEnd" then
			break
		end
	end
end

local function parseAction()
	for line in iter do
		if match(line, "^Anchor") then
			local x, y = match(line, "^Anchor%(([^,]*),([^,]*)%)")
			action.anchor = {tonumber(x), tonumber(y)}
		elseif match(line, "^Frame") then
			frame = {} -- anim.frame()
			local idx = tonumber(match(line, "^Frame:(%d+)"))
			assert(idx == #action.frames + 1)
			frame.elements = {}
			frame.events = {}
			insert(action.frames, frame)
			parseFrame()
		elseif match(line, "^FPS") then
			local fps = match(line, "^FPS%((%d+)%)")
			action.fps = fps
		elseif line == "ActionEnd" then
			break
		end
	end
	if not match(char.name, "^eff") then
		animdura[char.name][action.name] = {Duration = #action.frames / action.fps}
	else
		effect_dura[char.name][action.name] = {Duration = #action.frames / action.fps}
	end
end

local function parseChar()
	if not match(char.name, "^eff") then
		animdura[char.name] = {}
		animatkfram[char.name] = {}
	else
		effect_dura[char.name] = {}
		effect_atkfram[char.name] = {}
	end
	for line in iter do
		if match(line, "^Scale%(") then
			local scale = match(line,"Scale%(([^%)]*)")
			char.scale = tonumber(scale)
		elseif match(line, "^Action:") then
			action = {} -- anim.action()
			insert(char.actions, action)
			action.name = match(line, "^Action:(.*)")
			action.frames = {}
			parseAction()
			action = nil
		elseif line == "ActionEnd" then
			break
		end
	end
end

local function line_iter(data)
	local cur = 1
	return function()
		local idx = find(data, "\n", cur, true)
		if idx then
			local line = sub(data, cur, idx - 1)
			cur = idx + 1
			return line
		end 
	end
end

local function anim_txt_parse(name, data)
	iter = line_iter(data)
	char = {}
	char.name = name
	char.actions = {}
	char.elements = {}
	parseChar()

	local _char = char
	char = nil
	action = nil
	frame = nil
	animdura = {}
	animatkfram = {}
	effect_dura = {}
	effect_atkfram = {}
	out = nil

	return _char
end

parser.anim_txt_parse = anim_txt_parse

return parser