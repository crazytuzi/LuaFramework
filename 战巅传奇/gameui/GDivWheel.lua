GDivWheel = {}

local var = {}

function GDivWheel.init()
	var = {
		layerRocker,
		rockerWidget,
		-- rockerTouch,
		rockerBlock,
		rockerBg,
		rocker,
		freeRocker=true,
		rockerCenter = cc.p(110,185),
		defaultPos = cc.p(110,185),
	}

	var.layerRocker = cc.Layer:create()

	-- ccui.Widget:setWidgetRect(true)
	var.rockerWidget = GUIAnalysis.load("ui/layout/GDivWheel.uif")

	var.rockerWidget:setPosition(GameConst.leftBottom(0,-50))

	var.layerRocker:addChild(var.rockerWidget)

	if var.rockerWidget then
		-- var.rockerTouch = var.rockerWidget:getChildByName("rocker_touch") -- 技能区域，屏蔽摇杆触摸
		var.rockerBlock = var.rockerWidget:getChildByName("block_area")
		var.rockerBg = var.rockerWidget:getChildByName("main_rocker_bg"):setOpacity(255 * 0.14) -- 摇杆背景圈

		var.rocker = var.rockerWidget:getChildByName("main_rocker") -- 摇杆本身
		var.rocker:setTouchEnabled(false)
		-- var.rocker:setScale(0.8)
		var.rocker:setOpacity(255 * 0.14)

 		GDivWheel.changeRockerMode()

 		cc.EventProxy.new(GameSocket,var.rockerWidget)
			:addEventListener(GameMessageCode.EVENT_CHANGE_ROCKER,GDivWheel.changeRockerMode)
			:addEventListener(GameMessageCode.EVENT_HAND_MODEL,GDivWheel.changeRockerSide)
 	end

	GDivWheel.registerGDivControl()

	return var.layerRocker
end

function GDivWheel.registerGDivControl()
	local touchID, TBPos, active, showRocker

	local function onTouchBegan(touch,event)
 		-- print("GDivWheel onTouchBegan")
 		local touchPos = touch:getLocation()

		if GUILeftBottom.hitTestCall(touchPos) then return false end
 		if touchPos.x < 300 and touchPos.y < GameConst.VISIBLE_Y + 50 then return true end

		-- if touchPos.y < GameConst.VISIBLE_Y + 50 then return false end --屏蔽聊天栏

		if not GDivWheel.hitTest(touchPos) then
			if GUIMain.handleGhostsTouched(touchPos) or GameUtilSenior.hitTest(var.rockerBlock, touchPos) then
				if (not GameSocket.mSelectGridSkill) and (not GameSocket.mCastGridSkill) then
					return false
				end 
			end
		end

		if active and GameSocket.mCastGridSkill then  --有待释放的指定位置的格子技能
			GUIMain.handleGridSkillTouched(touchPos)
			return false
		end

		if GameSocket.mSelectGridSkill then
			GUIMain.handleGridSkillTouched(touchPos)
			GameSocket.mSelectGridSkill = nil
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GRID_SKILL_STATE})
			return false
		end
		
		if not touchID then			
			if var.freeRocker then
				showRocker = false
				TBPos = var.rockerWidget:convertToNodeSpace(touchPos)
			else
				if GDivWheel.hitTest(touchPos) then
					var.rocker:setHighlighted(true)
					var.rocker:setOpacity(255 * 0.74)
					var.rocker:setScale(0.88)
					var.rockerBg:setOpacity(255 * 0.64)
					active = true
					local lbPos = var.rockerWidget:convertToNodeSpace(touchPos)
					GDivWheel.setRockerPosition(lbPos)
					-- GDivWheel.onRockerMoved(lbPos)
				else
					if GameSocket.mCastGridSkill then
						GUIMain.handleGridSkillTouched(touchPos)
						return false
					end
					if not GameSocket.mSelectGridSkill then
						GUIMain.findingTouchMove(touchPos)
					end
				end
			end
			touchID = touch:getId()
			GameBaseLogic.setTouchingRocker(true)
			return true
		end
	end
	local function onTouchMoved(touch,event)
		if touch:getId() ~= touchID then return end
		if var.freeRocker then
			local lbPos = var.rockerWidget:convertToNodeSpace(touch:getLocation())
			if showRocker then
				GDivWheel.onRockerMoved(lbPos,true)
			elseif cc.pDistanceSQ(TBPos,lbPos) > 10*10 then
				showRocker = true
				GDivWheel.setRockerPosition(lbPos)
				var.rocker:setVisible(true)
				-- GDivWheel.setRockerVisible(true)
				var.rocker:setHighlighted(true)
				var.rocker:setOpacity(255 * 0.74)
				var.rockerBg:setOpacity(255 * 0.64)
			end
		else
			local touchPos = touch:getLocation()
			if active then
				local lbPos = var.rockerWidget:convertToNodeSpace(touchPos)
				GDivWheel.onRockerMoved(lbPos,true)
				-- if not GameBaseLogic.isJumpShow then
				-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING,btn="main_jump",visible = true})
				-- end
			else
				if not GameSocket.mSelectGridSkill then
					GUIMain.findingTouchMove(touchPos)
				end
			end
		end
	end
	local function onTouchEnded(touch,event)
		if touch:getId() ~= touchID then return end
		touchID = nil
		showRocker = false
		local touchPos = touch:getLocation()
		if var.freeRocker then
			
			if cc.pDistanceSQ(TBPos,var.rockerWidget:convertToNodeSpace(touchPos)) < 3*3 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_MAP_TOUCHED , pos = touchPos})
			else
				GDivWheel.onRockerReleased()
			end
			TBPos = nil
		else
			if active then
				GDivWheel.onRockerReleased(true)
				active = false
				GameCharacter.needCheckPickItem = true
			else
				GUIMain.findingTouchEnd(GameConst.center())
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_MAP_TOUCHED , pos = touchPos})
			end
		end
		GameBaseLogic.setTouchingRocker(false)
	end

	local function onTouchCancelled(touch,event)
		-- if touch:getId() ~= touchID then return end
		touchID = nil
		showRocker = false
		if var.freeRocker then
			GDivWheel.onRockerReleased()
			TBPos = nil
		elseif active then
			GDivWheel.onRockerReleased(true)
			active = false
		end
		GameBaseLogic.setTouchingRocker(false)
	end

	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)

	_touchListener:setSwallowTouches(false)
	local eventDispatcher = var.layerRocker:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.layerRocker)
end


function GDivWheel.changeRockerMode(event)
	var.freeRocker = not var.freeRocker
	GDivWheel.setRockerfreeRocker(var.freeRocker)
end

function GDivWheel.setRockerfreeRocker(full)
	var.rocker:setVisible(not full)
	-- GDivWheel.setRockerVisible(not full)
	if not full then
		GDivWheel.setRockerPosition(var.defaultPos)
	else

	end
end

-- function GDivWheel.setRockerVisible(visible)
-- 	-- var.rockerBg:setVisible(visible)
-- 	-- var.rockerBg:setVisible(false)
-- 	var.rocker:setVisible(visible)
-- end

function GDivWheel.onRockerMoved(pos,moved)
	if cc.pDistanceSQ(var.rockerCenter,pos) > 60*60 then
		pos=cc.pAdd(var.rockerCenter,cc.pMul(cc.pNormalize(cc.pSub(pos,var.rockerCenter)),60))
	end
	var.rocker:setPosition(pos)
	-- print("GDivWheel.onRockerMoved",moved,GDivWheel.getScreenPosition(var.rockerCenter,pos).x,GDivWheel.getScreenPosition(var.rockerCenter,pos).y)
	if moved then
		GUIMain.findingTouchMove(GDivWheel.getScreenPosition(var.rockerCenter,pos))
	end
end

function GDivWheel.getScreenPosition(cpoint,npoint)
	local rcpoint = GUIMain.get_mainrole_pixespos()
	if not rcpoint then rcpoint=GameConst.center() end
	local scalex=math.min(GameConst.VISIBLE_WIDTH/60,GameConst.VISIBLE_HEIGHT/60)
	local resultpoint=cc.pSub(npoint,cpoint)
	local mappos=cc.pAdd(rcpoint,cc.p(resultpoint.x*scalex,resultpoint.y*scalex))
	return cc.p(mappos.x,mappos.y)
end

function GDivWheel.onRockerReleased(visible) --visible 摇杆是否可见
	if not visible then visible = false end
	
	var.rocker:setHighlighted(false)
	var.rocker:setOpacity(255 * 0.14)
	var.rockerBg:setOpacity(255 * 0.14)
	if visible then GDivWheel.setRockerPosition(var.defaultPos) end
	var.rocker:setVisible(visible)
	if visible then
		-- var.rocker:runAction(cca.seq({cca.scaleTo(0.1,1.1),cca.scaleTo(0.1,1)}))
	end
	var.rocker:setScale(1)
	-- GDivWheel.setRockerVisible(visible)
	GUIMain.findingTouchEnd(GameConst.center())
	-- if GameBaseLogic.isJumpShow then
	-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HANDLE_FLOATING,btn="main_jump",visible = false})
	-- end
end

function GDivWheel.setRockerPosition(pos)
	if not pos then 
		pos = var.rockerCenter 
	else
		var.rockerCenter = pos
	end
	var.rocker:setPosition(pos)
	var.rockerBg:setPosition(pos)
	var.rockerBlock:setPosition(pos)
end

function GDivWheel.changeRockerSide(event)
	local rockerParam = {
		["normal"] = {defaultPos = cc.p(150,220), anchor = cc.p(0,0), pos = GameConst.leftBottom()},
		["reverse"]= {defaultPos = cc.p(-150,220), anchor = cc.p(1,0), pos = GameConst.rightBottom()}
	}
	
	local param = rockerParam[event.hand]
	if param then
		var.defaultPos = param.defaultPos
		var.rockerWidget:setAnchorPoint(param.anchor)
		-- var.rockerTouch:setAnchorPoint(param.anchor)
		var.rockerBlock:setAnchorPoint(param.anchor)
		var.rockerWidget:setPosition(param.pos)
	end
	GDivWheel.setRockerPosition(var.defaultPos)
end

function GDivWheel.hitTest(pos)
	local center = var.rockerWidget:convertToWorldSpace(var.defaultPos)
	return cc.pDistanceSQ(pos,center) < 126 * 120
end