local current = ...
local common = import("..scenes.main.common.common")
local tags = {
	assert = "断言",
	autoRat = "挂机",
	other = "其他",
	error = "lua错误",
	bag = "背包",
	equip = "装备",
	net = "通讯",
	res = "资源",
	login = "登录",
	normal = "普通"
}
local shows = {
	fps = function (b)
		cc.Director:getInstance():setDisplayStats(b)

		return 
	end,
	同屏人数 = function (b)
		cc.Director:getInstance():getNotificationNode().screenNode:setVisible(b)

		return 
	end,
	ping值 = function (b)
		cc.Director:getInstance():getNotificationNode().pingNode:setVisible(b)

		return 
	end
}

function p2(tag, ...)
	print("_debug_", tag or "normal", ...)

	return 
end

function d2(tag, value, desciption, nestin)
	dump("_debug_", tag or "normal", value, desciption, nestin)

	return 
end

if 0 < DEBUG then
	local STP = import("...StackTracePlus")

	function __G__TRACKBACK__(errorMessage)
		local msg = tostring(errorMessage)

		if not ErrorLogs[msg] then
			ErrorLogs[msg] = true
			local traceMsg = debug.traceback("", 2)
			local STPMsg = STP.stacktrace("", 2)

			if buglyReportLuaException then
				print("____buglyReportLuaException")
				buglyLog(2, "error_log", msg)
				buglyReportLuaException(msg .. " : LuaVer=[" .. (MIR2_VERSION or "1.0.0") .. "]" .. " : BaseVer=[" .. (MIR2_VERSION_BASE or "1.0.0") .. "]", STPMsg)
			end

			p2("error", "----------------------------------------")
			p2("error", "LUA ERROR: " .. msg .. "\n" .. STPMsg)
			p2("error", "----------------------------------------")

			if device.platform == "windows" then
				showLuaErrorMsg(msg .. "\n" .. traceMsg)
			end
		end

		return 
	end

	local _dumpTag = nil
	local _dump = dump

	function dump(mark, tag, value, desciption, nesting)
		if mark == "_debug_" then
			_dumpTag = tag or "normal"

			_dump(value, desciption, nesting)

			_dumpTag = nil
		else
			_dump(mark, tag, value, 1)
		end

		return 
	end

	if not _print then
		_print = print

		local function tprint(mark, tag, ...)
			local str = nil

			if mark == "_debug_" then
				local params = {
					...
				}

				for i = 1, select("#", ...), 1 do
					local v = select(i, ...)
					local valueType = type(v)

					if valueType == "boolean" then
						params[i] = (v and "true") or "false"
					elseif valueType == "userdata" then
						params[i] = "userdata(" .. (v.__cname or tolua.type(v)) .. ")"
					elseif valueType ~= "string" and valueType ~= "number" then
						params[i] = valueType
					end
				end

				str = table.concat(params, "   ")
			else
				local params = {
					mark,
					tag,
					...
				}
				local arglen = select("#", ...) + 2

				if arglen == 2 and tag == nil then
					if mark == nil then
						arglen = 0
					else
						arglen = 1
					end
				end

				for i = 1, arglen, 1 do
					local v = params[i]
					local valueType = type(v)

					if valueType == "boolean" then
						params[i] = (v and "true") or "false"
					elseif valueType == "userdata" then
						params[i] = "userdata(" .. (v.__cname or tolua.type(v)) .. ")"
					elseif valueType ~= "string" and valueType ~= "number" then
						params[i] = valueType
					end
				end

				str = table.concat(params, "   ")
				tag = _dumpTag or "other"
			end

			if m2debug.enables[tag] then
				_print(string.format("[ %s ] %s", tag, str))
			end

			m2debug.add(tag, str)

			return 
		end

		if false then
			scheduler.performWithDelayGlobal(function ()
				tprint("---------- test print ----------")
				tprint(true, false)
				tprint(true)
				tprint(false)
				tprint(false, false, false)
				tprint(nil, false)
				tprint(nil, nil, nil)
				tprint(nil, nil, "arg")
				tprint(nil, "arg", "arg")
				tprint("string1", "string2", "string3", "string4", "string5")
				tprint("number", 1, 2, 3, 4, 5)
				tprint("node")
				tprint(display.newNode())
				tprint("_debug_", "other", "---------- test print2 ----------")
				tprint("_debug_", "other", true, false)
				tprint("_debug_", "other", true)
				tprint("_debug_", "other", false)
				tprint("_debug_", "other", false, false, false)
				tprint("_debug_", "other", nil, false)
				tprint("_debug_", "other", nil, nil, "arg")
				tprint("_debug_", "other", nil, "arg", "arg")
				tprint("_debug_", "other", "string1", "string2", "string3", "string4", "string5")
				tprint("_debug_", "other", "number", 1, 2, 3, 4, 5)
				tprint("_debug_", "other", "node")
				tprint("_debug_", "other", display.newNode())

				return 
			end, 1)
		end

		print = tprint
	end

	local _replaceScene = display.replaceScene
	local afterDrawListener = nil
	display.replaceScene = function (newScene, ...)
		m2debug.show(newScene)

		if afterDrawListener then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(afterDrawListener)

			afterDrawListener = nil
		end

		_replaceScene(newScene, ...)

		return 
	end
	local _pushScene = cc.Director.pushScene
	cc.Director.pushScene = function (d, newScene, ...)
		if m2debug.node then
			m2debug.node:removeSelf()

			m2debug.node = nil
		end

		m2debug.show(newScene)

		if afterDrawListener then
			cc.Director:getInstance():getEventDispatcher():removeEventListener(afterDrawListener)

			afterDrawListener = nil
		end

		_pushScene(d, newScene, ...)

		return 
	end
	local _popScene = cc.Director.popScene
	cc.Director.popScene = function (d, ...)
		if m2debug.node then
			m2debug.node:removeSelf()

			m2debug.node = nil
		end

		afterDrawListener = cc.EventListenerCustom:create("director_after_draw", function ()
			local dir = cc.Director:getInstance()
			local running = dir.getRunningScene(dir)

			m2debug.show(running)
			dir.getEventDispatcher(dir):removeEventListener(afterDrawListener)

			afterDrawListener = nil

			return 
		end)

		d.getEventDispatcher(afterDrawListener):addEventListenerWithFixedPriority(afterDrawListener, 1)
		_popScene(d, ...)

		return 
	end
	local node = display.newNode()
	local screenNode = display.newNode().addTo(slot12, node)
	node.screenNode = screenNode
	local roleCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 185):add2(screenNode)
	local mapCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 165):add2(screenNode)
	local msgCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 145):add2(screenNode)
	local labelTexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 125):add2(screenNode)
	local rsTexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 105):add2(screenNode)
	local mir2TexCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 85):add2(screenNode)
	local m2sprCnt = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):pos(0, 65):add2(screenNode)

	cc.Director:getInstance():setNotificationNode(node)

	debugInfoScheduler = scheduler.scheduleUpdateGlobal(function ()
		if main_scene and main_scene.ground and main_scene.ground.map then
			local roles = {}

			table.merge(roles, main_scene.ground.map.heros)
			table.merge(roles, main_scene.ground.map.mons)
			table.merge(roles, main_scene.ground.map.npcs)

			local allRoleCnt = table.nums(roles)
			local ignoreCnt = 0

			for k, v in pairs(roles) do
				if v.isIgnore then
					ignoreCnt = ignoreCnt + 1
				end
			end

			roleCnt:setString("同屏人数: " .. allRoleCnt - ignoreCnt .. " / " .. allRoleCnt .. " / " .. (main_scene.ground.map.current_frame_updatedRoles or 0))
		end

		if MirAtlasMgr and MirAtlasMgr.getInstance then
			local textureSize = 0
			textureSize = MirAtlasMgr:getInstance():getTotalTextureSize()/1024

			m2sprCnt:setString(string.format("MirAtlas内存:%.1fMb", textureSize))
		end

		local TextureCache = cc.Director:getInstance():getTextureCache()

		if TextureCache.getCachedTextureSize then
			local textureCachedSize = TextureCache.getCachedTextureSize(TextureCache)/1024

			mir2TexCnt:setString(string.format("引擎纹理内存:%.1fMb", textureCachedSize))
		end

		return 
	end)
	node.pingNode = display.newNode().addTo(slot20, node)
	node.pingNode.label = an.newLabel("", 18, 0.8, {
		sd = true,
		color = display.COLOR_GREEN
	}):addTo(node.pingNode):pos(0, 210)

	scheduler.scheduleGlobal(function ()
		if main_scene then
			g_data.client:setLastTime("ping", true)
		end

		return 
	end, 5)
else
	function print()
		return 
	end

	function dump()
		return 
	end

	return 
end

local debugNode = nil
local m2debug = {
	catch = false,
	allowTouch = true,
	enables = {},
	showEnables = {},
	texts = {},
	cmNames = {},
	smNames = {},
	setting = {}
}

for k, v in pairs(slot2) do
	m2debug.enables[k] = true
end

local filter = cache.getDebug("filter")

if filter then
	for k, v in pairs(filter) do
		m2debug.enables[k] = v
	end
end

for k, v in pairs(shows) do
	m2debug.showEnables[k] = true
end

local showEnables = cache.getDebug("shows")

if showEnables then
	for k, v in pairs(showEnables) do
		m2debug.showEnables[k] = v
	end
end

for k, v in pairs(shows) do
	shows[k](m2debug.showEnables[k])
end

local setting = cache.getDebug("setting")

if setting then
	m2debug.setting = setting
end

local roleSpeed = cache.getDebug("roleSpeed")

if roleSpeed then
	m2debug.roleSpeed = roleSpeed
end

for k, v in pairs(_G) do
	if type(v) == "number" then
		if string.find(k, "CM_") == 1 then
			m2debug.cmNames[v] = k
		elseif string.find(k, "SM_") == 1 then
			m2debug.smNames[v] = k
		end
	end
end

m2debug.add = function (tag, str)
	m2debug.texts[#m2debug.texts + 1] = {
		tag,
		str
	}

	if m2debug.enables[tag] and m2debug.node then
		m2debug.node:addLog(tag, str)
	end

	return 
end
m2debug.show = function (scene)
	if not m2debug.hideNode then
		m2debug.node = debugNode.new():add2(scene, an.z.debug)
	end

	return 
end
slot10 = class("debugNode", function ()
	return display.newNode()
end)
debugNode = slot10

table.merge(debugNode, {
	btn,
	btns,
	beganPos,
	beganTouchPos,
	hasMove,
	lock,
	content,
	catchNode
})

debugNode.ctor = function (self)
	self.btn = res.get2("pic/console/iconbg8.png")

	self.btn:pos(self.btn:centerPos()):add2(self, 1):setCascadeOpacityEnabled(true)
	res.get2("pic/debug/icon.png"):pos(self.btn:centerPos()):add2(self.btn)
	self.setCascadeOpacityEnabled(self, true)
	self.size(self, self.btn:getw(), self.btn:geth()):anchor(0.5, 0.5):pos(self.getw(self)/2, display.height - self.geth(self)/2):opacity(0):runs({
		cc.FadeIn:create(1),
		cc.DelayTime:create(3),
		cc.CallFunc:create(function ()
			self:opacity(128)

			return 
		end)
	})
	self.btn.setTouchEnabled(slot1, true)
	self.btn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if self.lock then
			return 
		end

		if event.name == "began" then
			self.beganPos = cc.p(self:getPosition())
			self.beganTouchPos = cc.p(event.x, event.y)
			self.hasMove = false

			self:opacity(255)
			self:scale(1)
			self:stopAllActions()
		elseif event.name == "moved" then
			if self.hasMove or 10 < math.abs(self.beganTouchPos.x - event.x) or 10 < math.abs(self.beganTouchPos.y - event.y) then
				self.hasMove = true
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if x < 0 then
					x = 0
				end

				if display.width < x then
					x = display.width or x
				end

				if y < 0 then
					y = 0
				end

				if display.height < y then
					y = display.height or y
				end

				self:pos(x, y)
			end
		elseif event.name == "ended" then
			local function newx(x)
				if x < self:getw()/2 then
					x = self:getw()/2 or x
				end

				if display.width - self:getw()/2 < x then
					x = display.width - self:getw()/2 or x
				end

				return x
			end

			local function newy(y)
				if y < self:geth()/2 then
					y = self:geth()/2 or y
				end

				if display.height - self:geth()/2 < y then
					y = display.height - self:geth()/2 or y
				end

				return y
			end

			local function bothXY(x, y)
				if y < self:geth() then
					x = newx(x)
					y = self:geth()/2
				elseif display.height - self:geth() < y then
					x = newx(x)
					y = display.height - self:geth()/2
				elseif display.cx < x then
					x = display.width - self:getw()/2
					y = newy(y)
				else
					x = self:getw()/2
					y = newy(y)
				end

				return x, y
			end

			local function goto(x, y)
				if self.content then
					self:moveTo(0.25, x, y)
				else
					self:runs({
						cc.MoveTo:create(0.25, cc.p(x, y)),
						cc.DelayTime:create(3),
						cc.CallFunc:create(function ()
							self:opacity(128)

							return 
						end)
					})
				end

				return 
			end

			if not self.hasMove then
				self.lock = true

				self.btn.runs(slot5, {
					cc.ScaleTo:create(0.1, 0.01),
					cc.ScaleTo:create(0.1, 1),
					cc.CallFunc:create(function ()
						self.lock = nil

						if self.content then
							self.content:removeSelf()

							self.content = nil

							goto(bothXY(self:getPosition()))
						else
							self:createContent()
						end

						return 
					end)
				})
			else
				local x = event.x - self.beganTouchPos.x + self.beganPos.x
				local y = event.y - self.beganTouchPos.y + self.beganPos.y

				if self.content then
					y = newy(y)
					x = slot1(x)
				else
					x, y = bothXY(x, y)
				end

				goto(x, y)
			end
		end

		return true
	end)

	return 
end
debugNode.createContentBase = function (self, type)
	if self.content then
		self.content:removeSelf()
	end

	self.content = display.newNode():anchor(0, 1):pos(self.btn:getw()/2 + 5, self.btn:geth()/2 - 5):size(480, 320):add2(self)
	self.content.type = type

	display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(self.content:getContentSize()):add2(self.content)
	display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")):anchor(0, 0):size(self.content:getContentSize()):add2(self.content)

	return 
end
debugNode.createContent = function (self, hasInput)
	self.createContentBase(self, "main")

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	self.content.beginpos = 1
	self.content.scroll = scroll
	local loadFront = nil

	scroll.enableTouch(scroll, m2debug.allowTouch)
	scroll.setListenner(scroll, function (event)
		local x, y = scroll:getScrollOffset()

		if event.name == "moved" then
			if scroll:getScrollSize().height - scroll:geth() < y + scroll.labelM.wordSize.height then
				self:hideNewMark()
			end

			if y < 0 and not loadFront and 1 < self.content.beginpos then
				loadFront = true
			end
		elseif event.name == "ended" and loadFront then
			local source = {}

			for i = self.content.beginpos - 1, 1, -1 do
				local v = m2debug.texts[i]

				if m2debug.enables[v[1]] then
					self.content.beginpos = i

					table.insert(source, 1, v)

					if 20 <= #source then
						break
					end
				end
			end

			if 0 < #source then
				local labelM = an.newLabelM(scroll:getw(), scroll.labelM.fontSize, 0)

				for i, v in ipairs(source) do
					labelM.nextLine(labelM):addLabel("[ " .. v[1] .. " ] ", self:getColor(v[1])):addLabel(v[2])
				end

				display.newColorLayer(cc.c4b(255, 255, 0, 255)):size(labelM.getw(labelM), 1):add2(labelM)
				scroll.labelM:insertNodeToFront(labelM, #labelM.lines)
				scroll:setScrollOffset(0, (y + labelM.geth(labelM)) - labelM.wordSize.height/2)
			end

			loadFront = nil
		end

		return 
	end)

	local source = {}

	for i = #m2debug.texts, 1, -1 do
		local v = m2debug.texts[i]

		if m2debug.enables[v[1]] then
			self.content.beginpos = i

			table.insert(slot4, 1, v)

			if 20 <= #source then
				break
			end
		end
	end

	for i, v in ipairs(source) do
		self.addLog(self, v[1], v[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local folder = os.date("%Y-%m-%d")
		local key = os.date("%H-%M-%S") .. ".txt"
		local value = {}

		for i, v in ipairs(m2debug.texts) do
			value[#value + 1] = string.format("[%s]  %s", v[1], v[2])
		end

		cache.saveDebugLog(folder, key, value)
		self:createContentForTips("已保存到[" .. folder .. "/" .. key .. "]")

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"保存",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot5, self.content):pos(self.content:getw() - 50, self.content:geth() - 50)

	if hasInput then
		local function executeLua(text)
			local f = loadstring(text)

			if f then
				f()
			else
				print("lua格式有误.")
			end

			return 
		end

		local input = nil
		local mac_use_source_keyboard = true

		if (device.platform == "mac" or device.platform == "windows") and mac_use_source_keyboard then
			input = cc.ui.UIInput.new({
				UIInputType = 1,
				size = cc.size(self.content.getw(slot11), 40),
				image = display.newScale9Sprite(res.getframe2("pic/scale/scale2.png")),
				listener = function (type)
					if type == "changed" then
						local text = input:getText()

						if string.byte(string.reverse(text)) == string.byte("\\") then
							executeLua(string.sub(text, 1, #text - 1))
							input:setText("")
						end
					else
						executeLua(input:getText())
						input:setText("")
					end

					return 
				end
			}).anchor(slot8, 0, 1):opacity(0):fadeIn(0.1):pos(0, 24):moveTo(0.1, 0, 4):add2(self.content)
		else
			input = an.newInput(0, 0, self.content:getw(), 40, 255, {
				label = {
					"",
					22,
					0
				},
				bg = {
					h = 40,
					tex = res.gettex2("pic/scale/scale2.png"),
					offset = {
						-10,
						0
					}
				},
				return_call = function ()
					executeLua(input:getText())
					input:setText("")

					return 
				end
			}).anchor(slot8, 0, 1):opacity(0):fadeIn(0.1):pos(10, 24):moveTo(0.1, 10, 4):add2(self.content)
		end

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(input.getContentSize(input)):add2(input, -1)
	end

	local posx = 0

	local function add(text, func)
		local w = 30
		local btn = nil
		btn = an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
			func(btn)

			return 
		end, {
			pressBig = true,
			scale9 = cc.size(string.utf8len(self)*w, 40),
			label = {
				text,
				18,
				1,
				{
					color = cc.c3b(255, 255, 0)
				}
			}
		}):add2(self.content, -1):anchor(0, 0):pos(posx + 28, self.content:geth() - 4)

		display.newColorLayer(cc.c4b(0, 0, 0, 128)):size(btn.getContentSize(btn)):add2(btn, -1)

		posx = posx + btn.getw(btn) + 2

		return 
	end

	slot6((m2debug.allowTouch and "可触摸") or "不可触摸", function (btn)
		m2debug.allowTouch = not m2debug.allowTouch

		if m2debug.allowTouch then
			btn.label:setText("可触摸")
		else
			btn.label:setText("不可触摸")
		end

		scroll:enableTouch(m2debug.allowTouch)

		return 
	end)
	slot6("清空", function ()
		scroll.labelM:clear()

		return 
	end)
	slot6("过滤", function ()
		self:createContentForFilter()

		return 
	end)
	slot6("lua", function ()
		self:createContentForLua()

		return 
	end)
	slot6("设置", function ()
		self:createContentForSetting()

		return 
	end)
	slot6("GM", function ()
		self:createContentForGMCmd()

		return 
	end)

	return 
end
debugNode.createContentForFilter = function (self)
	self.createContentBase(self)
	self.content:setNodeEventEnabled(true)

	self.content.onCleanup = function ()
		cache.saveDebug("filter", m2debug.enables)

		return 
	end
	local cnt = 0

	local function add(key, text)
		local col = cnt%3
		local line = math.modf(cnt/3)
		local pos = cc.p(col*160 + 20, self.content:geth() - 40 - line*60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.enables[key] = b

			return 
		end, {
			easy = true,
			default = m2debug.enables[key],
			label = {
				self .. "[" .. key .. "]",
				20,
				1,
				{
					color = self:getColor(key)
				}
			}
		}):anchor(0, 0.5):pos(pos.x, pos.y):add2(self.content)
		cnt = cnt + 1

		return 
	end

	for k, v in pairs(tags) do
		slot2(k, v)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForLua = function (self)
	self.createContentBase(self)

	local config = {
		{
			"执行lua语句..",
			function ()
				self:createContent(true)

				return 
			end
		},
		{
			"查询全局变量值..",
			function ()
				self:createContentForLuaQueryVar()

				return 
			end
		},
		{
			"查看常量值..",
			function ()
				self:createContentForLuaQueryConst()

				return 
			end
		},
		{
			"当前版本:" .. (MIR2_VERSION or ""),
			function ()
				return 
			end
		}
	}

	for i, v in ipairs(slot1) do
		an.newLabel(v[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(20, self.content:geth() - 80 - (i - 1)*40):add2(self.content):addUnderline(cc.c3b(255, 255, 0)):enableClick(v[2], {
			ani = true
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot2, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForLuaQueryVar = function (self)
	self.createContentBase(self)
	an.newLabel("变量名: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local input = an.newInput(130, self.content:geth() - 52, 200, 32, 15, {
		label = {
			"g_data",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		}
	}):anchor(0, 0.5):add2(self.content)
	local config = {
		"def",
		"g_data",
		"game",
		"res",
		"display",
		"device"
	}

	for i, v in ipairs(config) do
		local col = math.modf((i - 1)/3)
		local line = (i - 1)%3

		an.newLabel(v, 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):anchor(0.5, 0.5):pos(line*170 + 60, self.content:geth() - 120 - col*50):add2(self.content):addUnderline(cc.c3b(255, 255, 0)):enableClick(function ()
			input:setString(v)

			return 
		end, {
			ani = true,
			size = cc.size(120, 40)
		})
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLuaQueryVarDetail(input:getText())

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLua()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForLuaQueryVarDetail = function (self, varText, parent)
	self.createContentBase(self)

	parent = parent or {}
	parent[#parent + 1] = varText

	local function goback()
		if #parent == 1 then
			self:createContentForLuaQueryVar()
		else
			parent[#parent] = nil
			local lastVar = parent[#parent]
			parent[#parent] = nil

			self:createContentForLuaQueryVarDetail(lastVar, clone(parent))
		end

		return 
	end

	local fullVarText = ""

	for i, v in ipairs(slot2) do
		if i == 1 then
			fullVarText = v
		elseif type(v) == "string" then
			fullVarText = fullVarText .. "[\"" .. v .. "\"]"
		elseif type(v) == "number" then
			fullVarText = fullVarText .. "[" .. v .. "]"
		else
			fullVarText = fullVarText .. ":get(\"" .. v[1] .. "\")"
		end
	end

	local str = "local var = " .. fullVarText .. " return var"
	local f = loadstring(str)

	if not f then
		self.createContentForTips(self, "查询失败. [" .. str .. "]", goback)

		return 
	end

	print(fullVarText)

	local var = f()

	if type(var) ~= "table" then
		self.createContentForTips(self, "变量[" .. varText .. "]并不是table类型", goback)

		return 
	end

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			22,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	scroll.labelM:nextLine():addLabel("变量名: " .. fullVarText, cc.c3b(255, 0, 255)):nextLine()

	local showVar = var
	local keys = table.keys(showVar)

	table.sort(keys, function (a, b)
		return tostring(a) < tostring(b)
	end)

	for i, k in pairs(slot10) do
		local v = showVar[k]

		if type(v) == "table" then
			scroll.labelM:nextLine():addLabel(type(v) .. "  ", display.COLOR_GREEN):addLabel(k .. "  ", cc.c3b(0, 255, 255)):addLabel("查看详情[" .. table.nums(v) .. "]", cc.c3b(255, 255, 0), nil, nil, {
				ani = true,
				callback = function ()
					self:createContentForLuaQueryVarDetail(k, clone(parent))

					return 
				end
			})
		elseif type(slot16) == "number" or type(v) == "string" then
			scroll.labelM:nextLine():addLabel(type(v) .. "  ", display.COLOR_GREEN):addLabel(k .. "  ", cc.c3b(0, 255, 255)):addLabel(v)
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), goback, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForLuaQueryConst = function (self)
	self.createContentBase(self)

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	local config = {
		{
			"原始版本",
			MIR2_VERSION_BASE
		},
		{
			"现在版本",
			MIR2_VERSION
		},
		{
			"登录服务器ip",
			def.ip
		},
		{
			"登录服务器端口",
			def.port
		},
		{
			"区服id",
			def.areaID
		},
		{
			"更新服务器ip",
			import("...upt.def", current).httpRoot
		},
		{
			"httpRoot",
			def.httpRoot
		},
		{
			"chatHttpRoot",
			def.chatHttpRoot
		},
		{
			"屏幕宽高",
			display.width .. " * " .. display.height
		},
		{
			"版本类型",
			def.gameVersionType
		},
		{
			"客户端版本号",
			def.MIR_VERSION_NUMBER
		}
	}

	for i, v in ipairs(config) do
		scroll.labelM:nextLine():addLabel(v[1] .. ": ", display.COLOR_GREEN):addLabel(v[2])
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForLua()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForAdaptSpeed = function (self)
	self.createContentBase(self)

	if not m2debug.roleSpeed then
		m2debug.roleSpeed = def.role.speed
	else
		def.role.speed = m2debug.roleSpeed
	end

	config = {
		{
			"一般动作",
			"normal"
		},
		{
			"加速",
			"fast"
		},
		{
			"冲撞失败",
			"rushKung"
		},
		{
			"野蛮冲撞",
			"rush"
		},
		{
			"基础释法间隔",
			"spell"
		},
		{
			"基础攻击间隔",
			"attack"
		}
	}
	local preInput = nil
	local adapt2input = {}
	local h = 0

	for k, v in pairs(config) do
		h = h + 45
		local input = nil

		local function stopCb()
			print(v[1], num)

			if not tolua.isnull(input) then
				local num = tonumber(input:getString())
				def.role.speed[v[2]] = num

				cache.saveDebug("roleSpeed", def.role.speed)
				print(v[1], num)
			end

			return 
		end

		input = an.newInput(200, self.content.geth(slot13) - h, 170, 32, 15, {
			label = {
				"" .. def.role.speed[v[2]],
				22,
				1
			},
			bg = {
				h = 40,
				tex = res.gettex2("pic/scale/scale2.png"),
				offset = {
					-10,
					0
				}
			},
			start_call = function ()
				if preInput and preInput ~= input then
					preInput:stopInput()
				end

				preInput = input

				return 
			end,
			stop_call = stopCb
		}).anchor(slot11, 0, 0.5):add2(self.content)
		input.onCleanup = function ()
			stopCb()
			input:stopInput()

			return 
		end
		slot11 = an.newLabel(v[1] .. ":", 22, 0, {
			color = cc.c3b(255, 255, 255)
		}).pos(slot11, 10, self.content:geth() - h - 10):add2(self.content)
	end

	return 
end
debugNode.createContentForTest = function (self)
	local function setAssetServerUrl(url)
		local uptScene = require("upt.scene")
		SKIP_UPT = false
		s = uptScene.new(function ()
			s:setTitle("请重启游戏")

			return 
		end)

		s.rmdir(slot2, device.writablePath .. "cache/")
		s:rmdir(s.storagePath .. "res/")
		s:rmdir(s.storagePath .. "rs/")
		s:rmdir(s.storagePath .. "upt/")
		os.remove(s.storagePath .. "project.manifest")
		os.remove(s.storagePath .. "version.manifest")
		display.replaceScene(s)
		s:saveRemoteAddress(url)

		return 
	end

	local function connectServer(ip, port)
		local loginTcp = g_data.login:getLoginTCP()

		loginTcp.clearRemoteHosts(loginTcp)
		loginTcp.clearAllSunscribeScriptOnProtocol(loginTcp)
		loginTcp.clearAllSubscribeOnState(loginTcp)

		if loginTcp.isConnected(loginTcp) then
			print("m2debug:connectServer -- loginTcp:disconnect(true)")
			loginTcp.disconnect(loginTcp, true)
		end

		loginTcp.addRemoteHost(loginTcp, def.ip, def.port)
		print("m2debug:connectServer -- loginTcp:connect start")
		loginTcp.connect(loginTcp)

		return 
	end

	local function disconnectServer()
		local loginTcp = g_data.login:getLoginTCP()

		loginTcp.clearRemoteHosts(loginTcp)
		loginTcp.clearAllSunscribeScriptOnProtocol(loginTcp)
		loginTcp.clearAllSubscribeOnState(loginTcp)

		if loginTcp.isConnected(loginTcp) then
			print("m2debug:connectServer -- loginTcp:disconnect(false)")
			loginTcp.disconnect(loginTcp, false)
		end

		return 
	end

	local config = {
		{
			"执行hotfix",
			function ()
				if hotfix_app_phone_call_crash then
					hotfix_app_phone_call_crash()
				else
					print("hotfix_app_phone_call_crash is nil")
				end

				return 
			end
		},
		{
			"模拟来电",
			function (edit)
				local str = [[
{
 "state":1,
 "number": 18262284791
}]]

				if _G.app_phone_call then
					app_phone_call(str)
				else
					print("app_phone_call is nil")
				end

				return 
			end
		},
		{
			"模拟接听电话",
			function (edit)
				local str = [[
{
 "state":2,
 "number": 18262284791
}]]

				if _G.app_phone_call then
					app_phone_call(str)
				else
					print("app_phone_call is nil")
				end

				return 
			end
		},
		{
			"模拟呼出电话",
			function (edit)
				local str = [[
{
 "state":3,
 "number": 18262284791
}]]

				if _G.app_phone_call then
					app_phone_call(str)
				else
					print("app_phone_call is nil")
				end

				return 
			end
		},
		{
			"模拟挂断电话",
			function (edit)
				local str = [[
{
 "state":0,
 "number": 18262284791
}]]

				if _G.app_phone_call then
					app_phone_call(str)
				else
					print("app_phone_call is nil")
				end

				return 
			end
		},
		{
			"重启lua时不重启虚拟机",
			function ()
				g_data.testOldRestart = not g_data.testOldRestart

				tip("重启lua时将" .. ((g_data.testOldRestart and "----不----重启虚拟机") or "重启虚拟机"))

				return 
			end
		},
		{
			"重启lua",
			function ()
				reStart()

				return 
			end
		},
		{
			"是否越狱或Root",
			function ()
				if device.isJailBrokenOrRoot() then
					tip("(越狱/Root)设备")
				else
					tip("非(越狱/Root)设备")
				end

				return 
			end
		},
		{
			"微端下载",
			function ()
				if main_scene and main_scene.ui then
					main_scene.ui:togglePanel("miniResDownload")
				end

				return 
			end
		},
		{
			"截图",
			function ()
				if main_scene and main_scene.ui then
					self:hide()
					main_scene.ui:togglePanel("screenshot")
				end

				return 
			end
		},
		{
			"TCP连接测试",
			function ()
				if def.ip and def.port then
					print("TCP连接测试")

					local times = 0
					tcphandle = scheduler.scheduleGlobal(function ()
						times = times + 1

						if math.mod(times, 2) == 0 then
							disconnectServer()
						else
							connectServer(def.ip, def.port)
						end

						if 30 <= times and tcphandle then
							scheduler.unscheduleGlobal(tcphandle)

							tcphandle = nil
						end

						return 
					end, 0.5)
				end

				return 
			end
		},
		{
			"图库资源测试",
			function ()
				if MirMiniResDownMgr and MirMiniResDownMgr:getInstance().testAtlasRes then
					print("=======MirMiniResDownMgr:getInstance():testAtlasRes=========")
					print(MirMiniResDownMgr:getInstance():testAtlasRes())
					print("============================================================")
				end

				return 
			end
		}
	}

	self.createContentForSetting(slot0, config)

	return 
end
debugNode.createContentForProfile = function (self)
	local config = {}

	if PlatformUtils:getInstance().luaProfileStart then
		slot2 = {
			{
				"开关lua函数调用频率统计",
				function ()
					g_data.luaSampling = not g_data.luaSampling

					tip("lua函数调用频率统计已" .. ((g_data.luaSampling and "开启，采样完毕后需再次点击此开关关闭统计生成采样文件") or "关闭，正在生成采样文件，请勿关闭游戏"))

					if g_data.luaSampling then
						PlatformUtils:getInstance():luaProfileStart(0)
					else
						PlatformUtils:getInstance():luaProfileStop()
					end

					return 
				end
			},
			{
				"开关lua函数内存申请统计",
				function ()
					g_data.luaAllocProfile = not g_data.luaAllocProfile

					tip("lua函数内存申请统计已" .. ((g_data.luaAllocProfile and "开启，采样完毕后需再次点击此开关关闭统计生成采样文件") or "关闭，正在生成采样文件，请勿关闭游戏"))

					if g_data.luaAllocProfile then
						PlatformUtils:getInstance():luaProfileStart(1)
					else
						PlatformUtils:getInstance():luaProfileStop()
					end

					return 
				end
			},
			{
				"开关lua函数CPU时间占用统计",
				function ()
					g_data.luaAllocProfile = not g_data.luaAllocProfile

					tip("lua函数CPU时间占用统计已" .. ((g_data.luaAllocProfile and "开启，采样完毕后需再次点击此开关关闭统计生成采样文件") or "关闭，正在生成采样文件，请勿关闭游戏"))

					if g_data.luaAllocProfile then
						PlatformUtils:getInstance():luaProfileStart(2)
					else
						PlatformUtils:getInstance():luaProfileStop()
					end

					return 
				end
			}
		}
		config = slot2
	end

	self.createContentForSetting(self, config)

	return 
end
debugNode.createContentForPlayerLog = function (self)
	local config = {
		{
			"开关玩家本人走跑砍间隔日志",
			function ()
				g_data.openMoveLog = not g_data.openMoveLog

				tip("开关玩家本人走跑间隔日志：" .. ((g_data.openMoveLog and "开启") or "关闭"))

				return 
			end
		},
		{
			"开关他人走跑砍协议日志",
			function ()
				g_data.openOtherMoveLog = not g_data.openOtherMoveLog

				tip("开关他人走跑砍协议日志：" .. ((g_data.openOtherMoveLog and "开启") or "关闭"))

				return 
			end
		},
		{
			"开关玩家全部动作日志",
			function ()
				g_data.playerActLog = not g_data.playerActLog

				tip("开关玩家全部动作日志：" .. ((g_data.playerActLog and "开启") or "关闭"))

				return 
			end
		},
		{
			"开关玩家攻击动作日志",
			function ()
				g_data.playerActLog = not g_data.playerActLog

				tip("开关玩家攻击动作日志：" .. ((g_data.playerActLog and "开启") or "关闭"))

				return 
			end
		},
		{
			"调整动作速度",
			function ()
				self:createContentForAdaptSpeed()

				return 
			end
		},
		{
			"加速他人动作",
			function ()
				g_data.speedUpOther = not g_data.speedUpOther

				tip("加速他人动作：" .. ((g_data.speedUpOther and "开启") or "关闭"))

				return 
			end
		},
		{
			"开关动作实时播放",
			function ()
				g_data.openRealTimeAction = not g_data.openRealTimeAction

				tip("动作播放修正已" .. ((g_data.openRealTimeAction and "开启") or "关闭"))

				if g_data.openRealTimeAction then
					gLastPostTime = nil
				end

				return 
			end
		}
	}

	self.createContentForSetting(slot0, config)

	return 
end
debugNode.createContentForException = function (self)
	local config = {
		{
			"触发内存警告",
			function ()
				app:memoryWarning()

				return 
			end
		},
		{
			"测试lua error",
			function ()
				local testLuaError = nil

				testLuaError.func(testLuaError)

				return 
			end
		},
		{
			"测试崩溃",
			function ()
				ycFunction:testCrash()

				return 
			end
		},
		{
			"操作被释放的cocos对象",
			function ()
				local node = display.newNode()

				scheduler.performWithDelayGlobal(function ()
					node:pos(display.cx, display.cy)

					return 
				end, 0)
				node.pos(slot0, display.cx, display.cy)

				return 
			end
		},
		{
			"测试创建角色超时",
			function ()
				g_data.roleCreateTest = not g_data.roleCreateTest

				tip("创建角色超时开关已" .. ((g_data.roleCreateTest and "开启，创建角色时将超时无法创建成功") or "关闭，可正常创建角色"))

				return 
			end
		}
	}

	self.createContentForSetting(slot0, config)

	return 
end
debugNode.createContentForSetting = function (self, cfg)
	self.createContentBase(self)

	if not cfg then
		local config = {
			{
				"隐藏工具图标",
				function ()
					if m2debug.node then
						m2debug.node:removeSelf()

						m2debug.node = nil
					end

					m2debug.hideNode = true

					return 
				end
			},
			{
				"调试信息开关",
				function ()
					self:createContentForSettingShows()

					return 
				end
			},
			{
				"辅助模拟测试",
				function ()
					self:createContentForTest()

					return 
				end
			},
			{
				"玩家动作测试",
				function ()
					self:createContentForPlayerLog()

					return 
				end
			},
			{
				"客户端性能测试",
				function ()
					self:createContentForProfile()

					return 
				end
			},
			{
				"客户端异常测试",
				function ()
					self:createContentForException()

					return 
				end
			},
			{
				"开关省电模式",
				function ()
					if main_scene and g_data.setting and g_data.setting.base then
						g_data.setting.base.operateCheck = not g_data.setting.base.operateCheck

						if not g_data.setting.base.operateCheck then
							main_scene:setNormalFPS()
						else
							main_scene.touchStamp = socket.gettime()
						end

						tip("省电模式已" .. ((g_data.setting.base.operateCheck and "开启，一段时间内无操作帧率将自动降低") or "关闭"))
					else
						tip("省电模式需进入主场景后可用")
					end

					return 
				end
			},
			{
				"GM面板",
				function ()
					if main_scene and main_scene.ui then
						main_scene.ui:togglePanel("quickTest")
					else
						tip("GM面板需进入主场景后可用")
					end

					return 
				end
			}
		}
	end

	local pos = self.content.geth(slot3) - 40
	local left = 20
	local maxWidth = 0

	for i, v in ipairs(config) do
		local edit = nil
		local lb = an.newLabel(v[1], 22, 0, {
			color = cc.c3b(255, 255, 0)
		}):pos(left, pos):add2(self.content):addUnderline(cc.c3b(255, 255, 0)):enableClick(function ()
			if not v or not v[2] then
				return 
			end

			v[2](edit)

			return 
		end, {
			ani = true
		})
		slot13 = v[3] and slot13
		maxWidth = math.max(lb.getw(slot12), maxWidth)
		pos = pos - 45

		if pos < 0 then
			left = left + maxWidth + 20
			maxWidth = 0
			pos = self.content:geth() - 40
		end
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot6, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForSettingShows = function (self)
	self.createContentBase(self)
	self.content:setNodeEventEnabled(true)

	self.content.onCleanup = function ()
		cache.saveDebug("shows", m2debug.showEnables)

		return 
	end
	local cnt = 0

	local function add(key, func)
		local col = cnt%3
		local line = math.modf(cnt/3)
		local pos = cc.p(col*160 + 20, self.content:geth() - 40 - line*60)
		local toggle = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.showEnables[key] = b

			shows[key](b)

			return 
		end, {
			easy = true,
			default = m2debug.showEnables[key],
			label = {
				key,
				20,
				1,
				{
					color = self.getColor(slot12, key)
				}
			}
		}):anchor(0, 0.5):pos(pos.x, pos.y):add2(self.content)
		cnt = cnt + 1

		return 
	end

	for k, v in pairs(shows) do
		slot2(k)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForSettingServer = function (self)
	self.createContentBase(self)
	an.newLabel("服务器IP: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(20, self.content:geth() - 50):add2(self.content)

	local input, areaInput = nil
	input = an.newInput(130, self.content:geth() - 52, 170, 32, 15, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function ()
			areaInput:stopInput()

			return 
		end
	}).anchor(slot3, 0, 0.5):add2(self.content)

	an.newLabel("区服ID: ", 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0, 0.5):pos(300, self.content:geth() - 50):add2(self.content)

	areaInput = an.newInput(390, self.content:geth() - 52, 90, 32, 6, {
		label = {
			"",
			22,
			1
		},
		bg = {
			h = 40,
			tex = res.gettex2("pic/scale/scale2.png"),
			offset = {
				-10,
				0
			}
		},
		start_call = function ()
			input:stopInput()

			return 
		end
	}).anchor(slot3, 0, 0.5):add2(self.content)

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local function tip(text)
			self:createContentForTips(text, function ()
				self:createContentForSetting()

				return 
			end)

			return 
		end

		input.stopInput(input)
		areaInput:stopInput()

		local ip = input:getText()
		local nums = string.split(ip, ".")

		if #nums ~= 4 then
			return tip("不是有效的ip地址")
		end

		for i, v in ipairs(nums) do
			local num = tonumber(v)

			if not num or 255 < num or num < 0 then
				return tip("不是有效的ip地址")
			end
		end

		local areaid = areaInput:getText()

		if areaid == "" then
			return tip("不是有效的区服id")
		end

		local function checkHistory(key, value)
			if not m2debug.setting[key] then
				m2debug.setting[key] = {}
			end

			local has = nil

			for i, v in ipairs(m2debug.setting[key]) do
				if v == value then
					table.remove(m2debug.setting[key], i)

					break
				end
			end

			table.insert(m2debug.setting[key], 1, value)

			return 
		end

		slot4("ip_history", ip .. "-" .. areaid)
		cache.saveDebug("setting", m2debug.setting)
		MirLaunch:restartLaunch()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 150, 30)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContentForSetting()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForTips = function (self, text, func)
	self.createContentBase(self)
	an.newLabel(text, 22, 1, {
		color = cc.c3b(0, 255, 0)
	}):anchor(0.5, 0.5):pos(self.content:centerPos()):add2(self.content)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), func or function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot3, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createContentForGMCmd = function (self)
	self.createContentBase(self)

	local scroll = self.createCmdList(self, "common")

	an.newLabel("命令类别", 18, 1, {
		color = display.COLOR_RED
	}):addTo(scroll):pos(10, scroll.h):anchor(0, 1)

	local h = scroll.h - scroll.space
	local cnt = 1

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		self:createContent()

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot4, self.content):pos(self.content:getw() - 50, 30)

	return 
end
debugNode.createCmdList = function (self, key)
	self.createContentBase(self)

	local scroll = an.newScroll(6, 6, self.content:getw() - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)
	scroll.h = scroll.geth(scroll) - 5
	scroll.space = 30

	return scroll
end
debugNode.createCmd = function (self, data, func)
	self.createContentBase(self)
	self.content:setNodeEventEnabled(true)

	self.content.onCleanup = function ()
		m2debug.catchNode = nil

		return 
	end
	local scroll = an.newScroll(6, 6, self.content.getw(slot6) - 16, self.content:geth() - 12, {
		labelM = {
			18,
			0
		}
	}):anchor(0, 0):addTo(self.content)

	dump(data)

	local w = 10
	local h = scroll.geth(scroll) - 10
	local sw = 150
	local sh = 40

	an.newLabelM(self.content:getw() - 20, 20, 1):addTo(scroll):pos(w, h):anchor(0, 1):nextLine():addLabel("命令描述: " .. data[2])

	h = h - sh
	local edits = {}
	local needCatch = false
	local mapEdit = nil

	if data[4] ~= "" then
		local t = loadstring("return " .. data[4])

		for i, v in ipairs(t()) do
			local opt, edit = nil
			opt = an.newLabel(v, 20, 1):addTo(scroll):pos(10, h):anchor(0, 1)
			edit = an.newInput(0, 0, 120, 35, 255, {
				donotClip = true,
				bg = {
					h = 35,
					tex = res.gettex2("pic/scale/edit.png"),
					offset = {
						-10,
						0
					}
				}
			}):addTo(scroll):pos(opt.getw(opt) + 30, h):anchor(0, 1)
			edits[#edits + 1] = edit

			if string.find(v, "角色名") or string.find(v, "怪物名") then
				needCatch = true

				an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
					print("catch name ", m2debug.catchName)
					edit:setText((m2debug.catchName and m2debug.catchName) or "")

					return 
				end, {
					pressBig = true,
					scale9 = cc.size(80, 40),
					label = {
						"获取名字",
						18,
						1,
						{
							color = cc.c3b(255, 255, 0)
						}
					}
				}).add2(slot19, scroll):pos(edit.getPositionX(edit) + edit.getw(edit) + 30, h):anchor(0, 1)
			end

			if string.find(v, "地图ID") then
				mapEdit = edit
			end

			h = h - sh
		end
	end

	local options = {}
	local selected = nil

	if data[5] ~= "" then
		local t = loadstring("return " .. data[5])

		for i, v in ipairs(t()) do
			local opt = nil
			opt = an.newBtn(res.gettex2("pic/common/toggle10.png"), function (btn)
				for _, tog in ipairs(options) do
					if tog == btn then
						tog.select(tog)

						selected = v
					else
						tog.unselect(tog)
					end
				end

				return 
			end, {
				manual = true,
				label = {
					v,
					20,
					1,
					{
						color = def.colors.btn20,
						sc = def.colors.btn20s
					}
				},
				labelOffset = {
					x = 50,
					y = 0
				},
				select = {
					res.gettex2("pic/common/toggle11.png")
				}
			}).addTo(slot20, scroll):anchor(0, 1)
			options[#options + 1] = opt

			opt.pos(opt, (#options + 2)%3*sw + w, h)

			if i == 1 then
				opt.select(opt)

				selected = v
			end
		end
	end

	if mapEdit then
		local mapCfg = {
			["0"] = "比奇省",
			sldg = "边界城",
			["2"] = "毒蛇山谷",
			["3"] = "盟重省",
			["11"] = "白日门",
			["6"] = "魔龙城",
			["5"] = "苍月岛",
			["1"] = "沃玛森林",
			["4"] = "封魔谷"
		}
		local cnt = 1

		for i, v in pairs(mapCfg) do
			an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
				mapEdit:setText(i)

				return 
			end, {
				pressBig = true,
				scale9 = cc.size(80, 40),
				label = {
					v,
					20,
					1,
					{
						color = cc.c3b(255, 255, 0)
					}
				}
			}).add2(slot20, scroll):pos((cnt - ((5 < cnt and 6) or 1))*90, h):anchor(0, 1)

			cnt = cnt + 1

			if cnt == 6 then
				h = h - sh or h
			end
		end
	end

	if needCatch then
		self.catchNode = an.newToggle(res.gettex2("pic/common/toggle10.png"), res.gettex2("pic/common/toggle11.png"), function (b)
			m2debug.catch = b

			return 
		end, {
			easy = true,
			default = m2debug.catch,
			label = {
				"允许获取",
				20,
				1
			}
		}).addTo(slot13, scroll):pos(10, 24):anchor(0, 0.5)
	end

	an.newBtn(res.gettex2("pic/scale/scale2.png"), function ()
		local str = "@" .. data[3]

		for i, v in ipairs(edits) do
			if v.getText(v) ~= "" then
				str = str .. " " .. v.getText(v)
			end
		end

		if selected then
			str = str .. " " .. selected
		end

		local function encodeMsg(str)
			local ret = {}

			if str then
				str = utf8strs(str)

				for i, v in ipairs(str) do
					if 4 <= string.len(v) then
						local t = crypto.encodeBase64(v)
						t = string.sub(t, 1, string.len(t) - 1)
						t = string.gsub(t, "/", "!")
						ret[i] = "{#ej" .. t .. "}"
					else
						ret[i] = v
					end
				end
			end

			return table.concat(ret)
		end

		common.sendGMCmd(edits(str))

		return 
	end, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"确定",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}).add2(slot13, scroll):pos(scroll.getw(scroll) - 150, 24)
	an.newBtn(res.gettex2("pic/scale/scale2.png"), func, {
		pressBig = true,
		scale9 = cc.size(80, 40),
		label = {
			"返回",
			18,
			1,
			{
				color = cc.c3b(255, 255, 0)
			}
		}
	}):add2(scroll):pos(scroll.getw(scroll) - 40, 24)

	return 
end
debugNode.getColor = function (self, tag)
	if tag == "error" or tag == "assert" then
		return display.COLOR_RED
	end

	return display.COLOR_GREEN
end
debugNode.addLog = function (self, tag, str)
	if not self.content or self.content.type ~= "main" then
		return 
	end

	local scroll = self.content.scroll
	local x, y = scroll.getScrollOffset(scroll)
	local isInEnd = scroll.getScrollSize(scroll).height < y + scroll.geth(scroll) + scroll.labelM.wordSize.height

	scroll.labelM:nextLine():addLabel("[ " .. tag .. " ] ", self.getColor(self, tag)):addLabel(str)

	if isInEnd then
		scroll.setScrollOffset(scroll, 0, scroll.getScrollSize(scroll).height - scroll.geth(scroll))
	else
		self.showNewMark(self)
	end

	return true
end
debugNode.showNewMark = function (self)
	if not self.content.newMark then
		self.content.newMark = res.get2("pic/common/msgNew.png"):add2(self.content, 1):run(cc.RepeatForever:create(transition.sequence({
			cc.ScaleTo:create(0.5, 0.7),
			cc.ScaleTo:create(0.5, 1)
		}))):enableClick(function ()
			self.content.newMark:hide()
			self.content.scroll:setScrollOffset(0, self.content.scroll:getScrollSize().height - self.content.scroll:geth())

			return 
		end)
	end

	self.content.newMark.show(slot1):pos(self.content:getw() - 20, 24)

	return 
end
debugNode.hideNewMark = function (self)
	if self.content.newMark then
		self.content.newMark:hide()
	end

	return 
end
M2DEBUG_INIT = true

return m2debug
