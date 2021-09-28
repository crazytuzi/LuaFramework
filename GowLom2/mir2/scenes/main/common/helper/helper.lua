local current = ...
local common = import("..common", current)
local runner = import(".scriptRunner")
local util = import(".util")
local guide = import(".guide", ...)
local helper = {
	runner = runner,
	init = function (self)
		helper.setting = cache.getHelper("setting") or {
			isHiding = false
		}
		self.checkedFirstLogin = false

		return 
	end,
	clickedHelper = function ()
		net.send({
			CM_CLICK_HELPER
		})

		return 
	end,
	show = function (self)
		return 
	end,
	setData = function (self, key, data)
		local playerName = common.getPlayerName()
		helper.setting[playerName] = helper.setting[playerName] or {}
		helper.setting[playerName][key] = data

		cache.saveHelper("setting", helper.setting)

		return 
	end,
	getData = function (self, key)
		local playerName = common.getPlayerName()
		helper.setting[playerName] = helper.setting[playerName] or {}

		return helper.setting[playerName][key]
	end,
	clickHide = function (self)
		self.obj:say("以后可以通过助手按钮找我，随叫随到哦")
		self.obj.role:performWithDelay(function ()
			self:hide()

			return 
		end, 4)
		self.setData(slot0, "isHiding", true)

		return 
	end,
	hide = function (self)
		if not tolua.isnull(helper.obj.role.node) then
			helper.obj:removeSelf()

			helper.obj = nil
		end

		return 
	end,
	getHelper = function (self)
		if self.isHiding(self) then
			self.show(self)
		end

		return self.obj
	end,
	isHiding = function (self)
		local ret = not helper.obj or tolua.isnull(helper.obj.role.node)

		return ret
	end,
	enterMap = function (self, mapid)
		runner.onEnterMap(mapid)

		return 
	end,
	checkFirstLogin = function (self)
		if helper.checkedFirstLogin then
			return 
		else
			helper.checkedFirstLogin = true
		end

		if g_data.player.ability.FLevel == 1 and not self.getData(self, "firstLoginGuided") then
			runner.finishCallback = function ()
				self:setData("firstLoginGuided", true)

				return 
			end

			runner.onGlobalEvent("firstLogin")
		end

		return 
	end,
	onTaskDelete = function (self, taskID)
		if taskID == 1001 then
			runner.onGlobalEvent("learnSkill")
		end

		return 
	end,
	call = function (mod, ...)
		def.magic.getConfig("skillMagic")
		def.magic.getConfig("mapMagic")
		runner.call(mod, ...)

		return 
	end,
	openPanel = function (self, name)
		runner.onOpenPanel(name)

		return 
	end,
	bloodChg = function (self, per)
		if main_scene.ground.player.level <= 20 and per <= 20 and not helper:getData("guided_low_hp") then
			helper:setData("guided_low_hp", true)
			print(helper:getData("guided_low_hp"))
			runner.call("newbee", "low_hp")
		end

		return 
	end
}

scheduler.performWithDelayGlobal(function ()
	if 0 < DEBUG and helper.setting then
		_G.helper = helper

		setmetatable(helper, {
			__newindex = function (_, k, v)
				if k == "mod1" then
					helper:setData("testMod1", v)
				elseif k == "mod2" then
					helper:setData("testMod2", v)
				elseif k == "mod3" then
					helper:setData("testMod3", v)
				elseif k == "mod4" then
					helper:setData("testMod4", v)
				elseif k == "mod5" then
					helper:setData("testMod5", v)
				elseif k == "mod7" then
					helper:setData("testMod7", v)
				elseif k == "mod8" then
					helper:setData("testMod8", v)
				elseif string.sub(k, 3) == "mod" then
					print("只能指定 mod1,mod2,mod3,mod4,mod5,mod7,mod8,当前F6有特殊用途因而不能指定")
				elseif k == "panel" then
					helper:setData("quickKey", v)
				else
					rawset(helper, k, v)
				end

				return 
			end
		})

		local listener = cc.EventListenerKeyboard.create(helper)

		listener.registerScriptHandler(listener, function (keyCode, evt)
			if WIN32_OPERATE then
				return 
			end

			local mod1 = helper.setting.testMod1 or "skill"
			local mod2 = helper.setting.testMod2 or "skill"
			local mod3 = helper.setting.testMod3 or "skill"
			local mod4 = helper.setting.testMod4 or "skill"
			local mod5 = helper.setting.testMod5 or "skill"
			local mod7 = helper.setting.testMod7 or "skill"
			local mod8 = helper.setting.testMod8 or "skill"

			if keyCode == 47 then
				if g_data.player:getIsCrossServer() then
					main_scene.ui:tip("该功能不能使用")

					return 
				end

				main_scene.ui:togglePanel("tradeshop", {
					default = 1,
					type = 1
				})
			elseif keyCode == 48 then
				if g_data.player:getIsCrossServer() then
					main_scene.ui:tip("该功能不能使用")

					return 
				end

				main_scene.ui:togglePanel("tradeshop", {
					default = 1,
					type = 0
				})
				helper.call("newbee", "low_hp")
			elseif keyCode == 49 then
				main_scene:onLoseConnect()
			elseif keyCode == 50 then
				helper.call("newbee", "level_9")
			elseif keyCode == 51 then
				helper.call("newbee", "level_10")
			elseif keyCode == 52 then
				helper.call("test", "level_10")
			elseif keyCode == 56 then
				if IS_PLAYER_DEBUG then
					package.loaded[guide.current] = nil
					guide = import(".guide", current)

					gd:disDebug()
					gd:stop()

					runner.baseEnv.GUIDE = guide.new()
					_G.gd = runner.baseEnv.GUIDE

					gd:debug()
				elseif _G.GUIDE_DEBUG_OPENED == nil or _G.GUIDE_DEBUG_OPENED then
					_G.GUIDE_DEBUG_OPENED = false

					gd:debug()
				else
					_G.GUIDE_DEBUG_OPENED = true

					gd:disDebug()
				end
			elseif keyCode == 58 then
				if g_data.player:getIsCrossServer() then
					main_scene.ui:tip("该功能不能使用")

					return 
				end

				main_scene.ui:togglePanel("tradeshop", 1)
			elseif not IS_PLAYER_DEBUG then
				if keyCode == 53 then
					helper.call(mod7)
				elseif keyCode == 54 then
					helper.call(mod7)
				elseif keyCode == 55 then
					local magic = import("..magic", current)
					local keys = def.magic.getMagicIds(g_data.player.job, false)

					for k, v in pairs(keys) do
						common.sendGMCmd("@doresou " .. def.magic.getMagicConfigByUid(v).name)
					end
				end
			elseif keyCode == 53 then
				package.loaded[current] = nil
				package.loaded[runner.current] = nil

				cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)

				helper = require(current)

				helper.init()

				main_scene.ground.helper = helper

				print("helper 已重置")
			elseif keyCode == 54 then
				if not _G.resetAutoRat then
					package.loaded[main_scene.ui.console.autoRat.current] = nil

					main_scene.ui.console:resetAutoRat()
					main_scene.ui.console.autoRat:enable()
				else
					main_scene.ui.console.autoRat:stop()
				end

				_G.resetAutoRat = not _G.resetAutoRat

				print("helper 已重置1")
			elseif keyCode == 55 then
				local magic = import("..magic", current)
				local keys = def.magic.getMagicIds(g_data.player.job, false)

				for k, v in pairs(keys) do
					local mg = def.magic.getMagicConfigByUid(v)

					dump(mg)

					if mg.name then
						common.sendGMCmd("@doresou " .. mg.name)
					else
						common.sendGMCmd("@doresou " .. mg.heroName)
					end
				end

				print("helper 已重置2")
			elseif keyCode == 57 then
				gd:testTwinkle()
			elseif keyCode == 58 and helper.setting.quickKey then
				main_scene.ui:showPanel(helper.setting.quickKey)
			end

			return 
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		cc.Director.getInstance(guide):getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		local _mouseListener = cc.EventListenerMouse:create()
		local touched = false

		_mouseListener.registerScriptHandler(_mouseListener, function (evt)
			if not main_scene then
				return 
			end

			local controller = main_scene.ui.console.controller
			local btn_mouse = evt.getMouseButton(evt)
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)

			if (btn_mouse ~= 0 or false) and btn_mouse == 1 then
				controller.move.step = 2

				controller.handleTouch(controller, {
					name = "began",
					x = x,
					y = y
				})
			end

			return 
		end, cc.Handler.EVENT_MOUSE_DOWN)
		_mouseListener.registerScriptHandler(guide, function (evt)
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)

			if not main_scene then
				return 
			end

			local controller = main_scene.ui.console.controller

			if not controller.move.step then
				return 
			end

			local btn_mouse = evt.getMouseButton(evt)

			if btn_mouse == 1 then
				controller.move.step = 2

				main_scene.ui.console.controller:handleTouch({
					name = "moved",
					x = x,
					y = y
				})
			end

			return 
		end, cc.Handler.EVENT_MOUSE_MOVE)
		_mouseListener.registerScriptHandler(guide, function (evt)
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)

			if not main_scene then
				return 
			end

			local controller = main_scene.ui.console.controller
			local btn_mouse = evt.getMouseButton(evt)

			if btn_mouse == 1 then
				main_scene.ui.console.controller:handleTouch({
					name = "ended",
					x = x,
					y = y
				})

				controller.move.step = nil
			end

			return 
		end, cc.Handler.EVENT_MOUSE_UP)
	end

	return 
end, 1)

helper.onUpdateAct = function (self, x, y)
	local player = main_scene.ground.player

	if x ~= self.prePlayerX or y ~= self.prePlayerY then
		runner.onUpdatePosition(x, y)

		if not self.isHiding(self) and 15 < player.getDis(player, self.obj) then
			self.obj:jumpToPlayer()
		end
	end

	self.prePlayerX = x
	self.prePlayerY = y

	return 
end

return helper
