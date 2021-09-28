local operate = {
	init = function ()
		operate.pressed = {}

		def.operate.init()

		local listener = cc.EventListenerKeyboard:create()

		listener.registerScriptHandler(listener, function (keyCode, evt)
			table.insert(operate.pressed, keyCode)

			return 
		end, cc.Handler.EVENT_KEYBOARD_PRESSED)
		listener.registerScriptHandler(operate, function (keyCode, evt)
			local trigger = def.operate.isTrigger(keyCode, operate.pressed)

			if trigger and trigger.event then
				operate.handlerKeybord(trigger)
			end

			for idx, _keycode in ipairs(operate.pressed) do
				if keyCode == _keycode then
					table.remove(operate.pressed, idx)

					break
				end
			end

			return 
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		cc.Director.getInstance(slot1):getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

		local _mouseListener = cc.EventListenerMouse:create()

		_mouseListener.registerScriptHandler(_mouseListener, function (evt)
			local keyCode = evt.getMouseButton(evt)
			local trigger = def.operate.isTrigger(keyCode, operate.pressed)

			if trigger and trigger.event and operate[trigger.event .. "_begin"] then
				operate[trigger.event .. "_begin"](trigger, evt)
			end

			return 
		end, cc.Handler.EVENT_MOUSE_DOWN)
		_mouseListener.registerScriptHandler(slot1, function (evt)
			operate.mouseMoveControl(evt)

			local keyCode = evt.getMouseButton(evt)
			local trigger = def.operate.isTrigger(keyCode, operate.pressed)

			if trigger and trigger.event and operate[trigger.event .. "_moved"] then
				operate[trigger.event .. "_moved"](trigger, evt)
			end

			return 
		end, cc.Handler.EVENT_MOUSE_MOVE)
		_mouseListener.registerScriptHandler(slot1, function (evt)
			local keyCode = evt.getMouseButton(evt)
			local trigger = def.operate.isTrigger(keyCode, operate.pressed)

			if trigger and trigger.event and operate[trigger.event .. "_end"] then
				operate[trigger.event .. "_end"](trigger, evt)
			end

			return 
		end, cc.Handler.EVENT_MOUSE_UP)
		cc.Director.getInstance(slot2):getEventDispatcher():addEventListenerWithFixedPriority(_mouseListener, 1)
		operate.hideUI()

		return 
	end,
	hideUI = function ()
		if main_scene then
			local rocker = main_scene.ui.console:get("rocker")

			if rocker then
				rocker.setVisible(rocker, false)
			end

			local lock = main_scene.ui.console:get("lock")

			if lock then
				lock.setVisible(lock, false)
			end
		end

		return 
	end,
	handlerKeybord = function (info)
		if info.keyType then
			if info.keyType == "panel" then
				if main_scene then
					sound.playSound("103")
					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
				end
			elseif info.keyType == "skill" then
				if info.params and info.params.magicId then
					operate.useMagic(info.params.magicId)
				end
			elseif info.keyType == "normal" then
				if main_scene then
					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
				end
			elseif info.keyType == "base" then
				if main_scene then
					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
				end
			elseif info.keyType == "setting" then
				if main_scene then
					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
				end
			elseif info.keyType == "hero" then
				if main_scene then
					main_scene.ui.console.btnCallbacks:handle(info.keyType, info.name)
				end
			elseif operate[info.event] then
				operate[info.event](info)
			end
		elseif operate[info.event] then
			operate[info.event](info)
		end

		return 
	end,
	mouseMoveControl = function (evt)
		operate.mouseX = evt.getCursorX(evt)
		operate.mouseY = evt.getCursorY(evt)

		if main_scene then
			local lock = main_scene.ui.console.controller.lock
			local target = operate.getTouchMonTarget(operate.mouseX, operate.mouseY)

			if target then
				local role = main_scene.ground.map:findRole(target)

				if role and not role.isPlayer and lock.target.select ~= role.roleid then
					lock.setSelectTarget(lock, role)
				end
			elseif not lock.target.attack then
				lock.stop(lock)
			end
		end

		return 
	end,
	getTouchMonTarget = function (eventX, eventY)
		local map = main_scene.ground.map

		if map and map.player then
			local x, y = map.getMapPosWithScreenPos(map, eventX, eventY)
			local roles = {}

			table.merge(roles, map.mons)

			local roles = main_scene.ui.console.controller:sortRoles(table.values(roles))

			for i, v in ipairs(roles) do
				if cc.rectContainsPoint(v.getBoundingBox(v), cc.p(x, y)) and not v.die then
					return v.roleid
				end
			end
		end

		return 
	end,
	useMagic = function (magicId)
		if main_scene then
			local lock = main_scene.ui.console.controller.lock
			local map = main_scene.ground.map
			local magic_data = g_data.player:getMagic(magicId)

			main_scene.ui.console.btnCallbacks:handle("skill", magicId, magic_data)

			if lock.skill.enable then
				if lock.target.select then
					local role = map.findRole(map, lock.target.select)

					if checkExist("lock", lock.skill.config.type, lock.skill.config.first) then
						lock.setSkillTarget(lock, role)
					end

					main_scene.ui.console.controller:useMagic(role.x, role.y)
				elseif map then
					local x, y = map.getMapPosWithScreenPos(map, operate.mouseX, operate.mouseY)

					main_scene.ui.console.controller:useMagic(map.getGamePos(map, x, y))
				end
			end
		end

		return 
	end,
	onMouseLeft_begin = function (info, evt)
		if main_scene then
			if not operate.isCanTouch() then
				return 
			end

			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)
			main_scene.ui.console.controller.move.step = 1

			main_scene.ui.console.controller:handleTouch({
				name = "began",
				x = x,
				y = y
			})
		end

		return 
	end,
	onMouseLeft_moved = function (info, evt)
		if main_scene then
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)
			local controller = main_scene.ui.console.controller

			if not controller.move.step then
				return 
			end

			if not operate.isCanTouch() then
				return 
			end

			controller.move.step = 1

			controller.handleTouch(controller, {
				name = "moved",
				x = x,
				y = y
			})
		end

		return 
	end,
	onMouseLeft_end = function (info, evt)
		if main_scene then
			if not main_scene.ui.console.controller.touchGround then
				return 
			end

			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)

			main_scene.ui.console.controller:handleTouch({
				name = "ended",
				x = x,
				y = y
			})

			main_scene.ui.console.controller.move.step = nil
			main_scene.ui.console.controller.touchGround = nil
		end

		return 
	end,
	onMouseRight_begin = function (info, evt)
		if main_scene then
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)
			main_scene.ui.console.controller.move.step = 2

			main_scene.ui.console.controller:handleTouch({
				name = "began",
				x = x,
				y = y
			})
		end

		return 
	end,
	onMouseRight_moved = function (info, evt)
		if main_scene then
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)
			local controller = main_scene.ui.console.controller

			if not controller.move.step then
				return 
			end

			controller.move.step = 2

			controller.handleTouch(controller, {
				name = "moved",
				x = x,
				y = y
			})
		end

		return 
	end,
	onMouseRight_end = function (info, evt)
		if main_scene then
			local x = evt.getCursorX(evt)
			local y = evt.getCursorY(evt)

			main_scene.ui.console.controller:handleTouch({
				name = "ended",
				x = x,
				y = y
			})

			main_scene.ui.console.controller.move.step = nil
			main_scene.ui.console.controller.touchGround = nil
		end

		return 
	end,
	onMouseLeft_SF_begin = function (info, evt)
		if main_scene then
			if not operate.isCanTouch() then
				return 
			end

			main_scene.ui.console.controller.openShift = true
			local map = main_scene.ground.map
			local player = main_scene.ground.player
			local x, y = map.getMapPosWithScreenPos(map, evt.getCursorX(evt), evt.getCursorY(evt))
			local gameX, gameY = map.getGamePos(map, x, y)
			local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

			main_scene.ui.console.controller:forceAttackTest(dir)

			main_scene.ui.console.controller.openShift = false
		end

		return 
	end,
	onMouseLeft_Alt_begin = function (info, evt)
		if main_scene then
			if not operate.isCanTouch() then
				return 
			end

			main_scene.ui.console.controller.autoWa = true
			local map = main_scene.ground.map
			local player = main_scene.ground.player
			local x, y = map.getMapPosWithScreenPos(map, evt.getCursorX(evt), evt.getCursorY(evt))
			local gameX, gameY = map.getGamePos(map, x, y)
			local dir = def.role.getMoveDir(player.x, player.y, gameX, gameY)

			if dir ~= player.dir then
				local rsb = DefaultClientMessage(CM_TURN)
				rsb.FDir = dir

				MirTcpClient:getInstance():postRsb(rsb)
				player.addAct(player, {
					type = "stand",
					dir = dir,
					x = player.x,
					y = player.y
				})
			end
		end

		return 
	end,
	onMouseLeft_Alt_end = function (info, evt)
		if main_scene then
			if not operate.isCanTouch() then
				return 
			end

			main_scene.ui.console.controller.autoWa = false
		end

		return 
	end,
	isCanTouch = function ()
		if main_scene and main_scene.ui.console.controller.touchGround then
			return true
		end

		return false
	end,
	onMouseRight_ctrl_begin = function (info)
		return 
	end,
	onKeybord_A = function (info)
		print("-------------onKeybord_A------------")

		return 
	end,
	onKeybord_B = function (info)
		if main_scene then
			sound.playSound("103")
			main_scene.ui.console.btnCallbacks:handle("panel", "bag")
		end

		return 
	end,
	onKeybord_C = function (info)
		print("-------------onKeybord_C------------")

		return 
	end,
	onKeybord_SF_A = function (info)
		print("-------------onKeybord_SF_A------------")

		return 
	end
}

return operate
