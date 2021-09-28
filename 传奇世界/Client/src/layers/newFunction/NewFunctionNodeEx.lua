local NewFunctionNodeEx = class("NewFunctionNodeEx", function() return cc.Node:create() end)

require("src/layers/newFunction/NewFunctionDefine")

function NewFunctionNodeEx:ctor(record)
	local resPath = "res/newFunctionEx/"
	local key = "newFunctionEx"

	self.showRecord = record

	local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)

	local showFunc = function()
		if self.isNowShowAction == true then
			return
		end

		local lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
		if lv < self.showRecord.lvMax then
			if self.icon:isVisible() == true then
				if self.effect then
					--self.effect:setVisible(false)
					--self.effect:setOpacity(0)
					setLocalRecord(key..self.showRecord.id, true)
				end
				self:createShow(self.showRecord)
			end
		else
			local function getFunc()
				local t = {}
				t.targetRewardID = self.showRecord.id
				dump(t)
				g_msgHandlerInst:sendNetDataByTableExEx(TARGETREWARD_CS_GET, "GetTargetRewardProtocol", t)
			end
			getFunc()
		end
	end
	
    --图标
	local iconBg = createSprite(self, resPath.."4.png", cc.p(0, -30), cc.p(0.5, 0.5))
	self.iconBg = iconBg
	-- if self.showRecord.id == 1 then
	-- 	self.iconBg:setVisible(false)
	-- end

	self.isNowShowAction = false
	self.isNowGetAction = false

	local effect = Effects:create(false)
	effect:setCleanCache()
    effect:playActionData("newFunctionExSmall", 19, 2, -1)
    iconBg:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(cc.p(iconBg:getContentSize().width/2+3, iconBg:getContentSize().height/2-2))
    effect:setScale(1)
    self.effect = effect
    --dump(getLocalRecord(key..self.showRecord.id))
	if getLocalRecord(key..self.showRecord.id) == true then
		--print("setVisible false")
		--self.effect:setVisible(false)
		--self.effect:setOpacity(0)
	end

	local icon
	if record.itemId then
		local MpropOp = require "src/config/propOp"
		local resPath = MpropOp.icon(record.itemId)
		if record.id == 9 then
			resPath = "res/group/currency/4.png"
		end
		icon = createMenuItem(iconBg, resPath, cc.p(iconBg:getContentSize().width/2, iconBg:getContentSize().height/2), showFunc)
		-- if record.id == 2 and (itemId and itemId == 3010301) then
		-- 	icon:setPosition(cc.p(icon:getPositionX(), icon:getPositionY()+8))
		-- end
		if record.itemId == 888888 then
			createSprite(icon, "res/group/lock/1.png", cc.p(0, 0), cc.p(0, 0))
		end
	else
		icon = createMenuItem(iconBg, resPath.."show/"..record.id..".png", cc.p(iconBg:getContentSize().width/2, iconBg:getContentSize().height/2), showFunc)
	end
	if icon then
		icon:setScale(0.75)
	end
	self.icon = icon
	if self.showRecord.num then
		createLabel(icon, "x"..numToFatString(self.showRecord.num), getCenterPos(icon, 5, -5), cc.p(0, 1), 16, true, nil, nil, MColor.white)
	end 
	createLabel(iconBg, string.format(game.getStrByKey("new_function_ex_lv_get"), record.lvMax), cc.p(iconBg:getContentSize().width/2, 0), cc.p(0.5, 0), 16, true, nil, nil, MColor.white)
	-- if require("src/layers/role/RoleStruct") and require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) then
	-- 	removeFromParent(self.levelLabel)
	-- 	self.levelLabel = nil

	-- 	local lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
	-- 	if lv < record.lvMax then
	-- 		self.levelLabel = createLabel(iconBg, string.format(game.getStrByKey("new_function_ex_lv_need"), record.lvMax-lv), cc.p(iconBg:getContentSize().width/2, -20), cc.p(0.5, 0), 16, true, nil, nil, MColor.yellow)
	-- 	else
	-- 		self.isNowGetAction = true
	-- 		self.levelLabel = createLabel(iconBg, game.getStrByKey("new_function_ex_finish_get"), cc.p(iconBg:getContentSize().width/2, -20), cc.p(0.5, 0), 16, true, nil, nil, MColor.green)
	-- 		startTimerAction(self, 0.0, false, function() AudioEnginer.playEffect("sounds/uiMusic/ui_item.mp3",false) self:createShow(self.showRecord, nil, true) end)
	-- 		self.effect:setOpacity(255)
	-- 	end
	-- end
	self:updateUI()

	if getLocalRecord("showTarget"..self.showRecord.id) ~= true and self.isNowGetAction == false then
		-- startTimerAction(self, 0.0, false, function()
		-- 	G_MAINSCENE:hideTopIcon(false) 
		-- 	self.isNowShowAction = true 
		-- 	G_SHOW_ORDER_DATA.showFuncEx = true 
		-- 	self.icon:setOpacity(0) 
		-- 	self.effect:setVisible(false) 
		-- 	self:setShow(false)
		-- 	end)

		startTimerAction(self, self.showRecord.delay or 10.0, false, function() self:createShowAction() end)
	end
end

function NewFunctionNodeEx:updateUI()
	local function closeFunc()
		removeFromParent(self.bg)
		self.detailNode = nil
		self.bg = nil
	end

	local record = self.showRecord
	if require("src/layers/role/RoleStruct") and require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL) then
		removeFromParent(self.levelLabel)
		self.levelLabel = nil

		local lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
		if lv < record.lvMax then
			self.levelLabel = createLabel(self.iconBg, string.format(game.getStrByKey("new_function_ex_lv_need"), record.lvMax-lv), cc.p(self.iconBg:getContentSize().width/2, -20), cc.p(0.5, 0), 16, true, nil, nil, MColor.yellow)
			self.effect:setOpacity(0)
		else
			self.isNowGetAction = true
			self.levelLabel = createLabel(self.iconBg, game.getStrByKey("new_function_ex_finish_get"), cc.p(self.iconBg:getContentSize().width/2, -20), cc.p(0.5, 0), 16, true, nil, nil, MColor.green)
			if record.id == 1 then
				startTimerAction(self, 0.0, false, function() AudioEnginer.playEffect("sounds/uiMusic/ui_item.mp3",false) self:createShow(self.showRecord, nil, true) end)
			end
			self.effect:setOpacity(255)
		end
	end

	-- if getLocalRecord("showTarget"..self.showRecord.id) ~= true and self.isNowGetAction == false then
	-- 	startTimerAction(self, 0.0, false, function()
	-- 		G_MAINSCENE:hideTopIcon(false) 
	-- 		self.isNowShowAction = true 
	-- 		G_SHOW_ORDER_DATA.showFuncEx = true 
	-- 		self.icon:setOpacity(0) 
	-- 		self.effect:setVisible(false) 
	-- 		self:setShow(false)
	-- 		end)

	-- 	startTimerAction(self, self.showRecord.delay or 10.0, false, function() self:createShowAction() end)
	-- end
end

function NewFunctionNodeEx:setShow(isShow)
	if isShow then
		self.iconBg:setPosition(cc.p(0, -30))
	else
		self.iconBg:setPosition(cc.p(display.width*2, display.height*2))
	end
end

function NewFunctionNodeEx:createShowAction()
	AudioEnginer.playEffect("sounds/uiMusic/ui_fx.mp3",false)
	self:setShow(true)
	--如果已经打开了领取界面 则不执行动画
	if self.bg ~= nil then
		return
	end

	-- self:createShow(self.showRecord, true)

	-- self.particleNode = cc.Node:create()
	-- G_MAINSCENE:addChild(self.particleNode, 100)
	-- self.particleNode:setPosition(cc.p(display.cx, display.cy))

	self:runAction(cc.Sequence:create(
		-- cc.DelayTime:create(3),
		-- cc.CallFunc:create(function() 
		-- 	self.shrinkParticle = cc.ParticleSystemQuad:create("res/particle/newFunctionShrink.plist") 
		-- 	self.particleNode:addChild(self.shrinkParticle)
		-- 	end),
		-- cc.CallFunc:create(function() 
		-- 	self.onParticle = cc.ParticleSystemQuad:create("res/particle/newFunctionOn.plist") 
		-- 	self.particleNode:addChild(self.onParticle)
		-- 	end),
		-- cc.CallFunc:create(function() 
		-- 		if checkNode(self.bg) then
		-- 			self.bg:runAction(cc.ScaleTo:create(0.3, 0))
		-- 		end
		-- 	end),
		-- cc.CallFunc:create(function() 
		-- 		if self.shrinkParticle then
		-- 			self.shrinkParticle:stopSystem()
		-- 		end
		-- 	end),
		-- cc.DelayTime:create(0.5),
		-- cc.CallFunc:create(function() 
		-- 	self.particleNode:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p(self:getPosition())), cc.CallFunc:create(function() self.iconBg:setVisible(true) self.effect:setVisible(true) end)))
		-- 	end),
		-- cc.DelayTime:create(1),
		-- cc.CallFunc:create(function() 
		-- 		if self.onParticle then
		-- 			self.onParticle:stopSystem()
		-- 		end
		-- 	end),
		-- cc.DelayTime:create(0.5),
		cc.CallFunc:create(function() self.icon:runAction(cc.FadeIn:create(0.5)) end),--self.icon:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(1), cc.ScaleTo(1, 1))))
		cc.CallFunc:create(function() 
			if checkNode(self.bg) then
				removeFromParent(self.bg) self.detailNode = nil self.bg = nil 
			end
			setLocalRecord("showTarget"..self.showRecord.id, true) self.isNowShowAction = false G_SHOW_ORDER_DATA.showFuncEx = false end)
		)
	)
end

function NewFunctionNodeEx:isCanRemove()
	return (self.isNowShowAction == false)
end

function NewFunctionNodeEx:createShow(record, noCheck, isGet)
	if self.bg then
		return
	end
	--log("NewFunctionNodeEx:createShow")
	local resPath = "res/newFunctionEx/"
	local MTipsBase = require "src/layers/bag/TipsBase"
	local bg = createSprite(nil, resPath.."bgLeft.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))--MTipsBase:background(1200)
	self.bg = bg
	self.bgToPos = cc.p(self.bg:getPositionX()-self.bg:getContentSize().width/2, self.bg:getPositionY())
	self.getBtn = nil
	self.touchProtect = true
	self.touchProtectTime = 2

	if noCheck ~= true then
		-- Manimation:transit(
		-- {
		-- 	ref = getRunScene(),
		-- 	node = bg,
		-- 	curve = "-",
		-- 	sp = cc.p(self:getPosition()),
		-- 	zOrder = 100,
		-- 	swallow = false,
		-- })
		getRunScene():addChild(bg, 100)
	end

	local newBg = createSprite(bg, resPath.."5.png", cc.p(bg:getContentSize().width/2, 485), cc.p(0.5, 0.5))
	--createSprite(newBg, resPath.."10.png", cc.p(newBg:getContentSize().width/2, newBg:getContentSize().height/2), cc.p(0.5, 0.5))

	--背景特效
	if record.id ~= 1 then
		local effect = Effects:create(false)
	    effect:playActionData("newFunctionExBig", 21, 2.1, -1)
	  	addEffectWithMode(effect,3)
	    bg:addChild(effect)
	    effect:setAnchorPoint(cc.p(0.5, 0.5))
	    effect:setPosition(cc.p(bg:getContentSize().width/2, 350))
	    effect:setScale(1)
	end

	--createSprite(bg, resPath.."1.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height), cc.p(0.5, 0.5))
	local tipBg = createSprite(bg, resPath.."2.png", cc.p(bg:getContentSize().width/2, 50), cc.p(0.5, 0))
	-- createSprite(bg, resPath.."6.png", cc.p(35, -5), cc.p(0.5, 0))
	-- createSprite(bg, resPath.."5.png", cc.p(bg:getContentSize().width-35, -5), cc.p(0.5, 0))
	-- createSprite(bg, resPath.."7.png", cc.p(bg:getContentSize().width+2, bg:getContentSize().height/2), cc.p(1, 0.5))
	-- createSprite(bg, resPath.."8.png", cc.p(-2, bg:getContentSize().height/2), cc.p(0, 0.5))
	local function closeFunc()
		removeFromParent(self.bg)
		self.detailNode = nil
		self.bg = nil
	end

	local function getFunc()
		-- bg:removeFromParent()
		-- self.detailNode = nil
		-- self.bg = nil

		-- G_NFTRIGGER_NODE.nowTagetId = G_NFTRIGGER_NODE.nowTagetId + 1
		-- log("###########################G_NFTRIGGER_NODE.nowTagetId = "..G_NFTRIGGER_NODE.nowTagetId)
		-- G_NFTRIGGER_NODE:checkNewFunctionEx()
		dump(self.showRecord.id)
		--g_msgHandlerInst:sendNetDataByFmtExEx(TARGETREWARD_CS_GET, "ii", G_ROLE_MAIN.obj_id, self.showRecord.id)
		local t = {}
		t.targetRewardID = self.showRecord.id
		g_msgHandlerInst:sendNetDataByTableExEx(TARGETREWARD_CS_GET, "GetTargetRewardProtocol", t)
		closeFunc()
	end

	local closeBtn = createMenuItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-45, bg:getContentSize().height-50), closeFunc)
	--closeBtn:setScale(0.7)
	--closeBtn:setLocalZOrder(100)

	--名字
	local showName 
	if record.itemId then
		local MpropOp = require "src/config/propOp"
		showName = createLabel(tipBg, MpropOp.name(record.itemId), cc.p(tipBg:getContentSize().width/2, 105), cc.p(0.5, 0), 24, true)
	else
		showName = createLabel(tipBg, record.name, cc.p(tipBg:getContentSize().width/2, 105), cc.p(0.5, 0), 24, true)
	end
	
	local lv = require("src/layers/role/RoleStruct"):getAttr(ROLE_LEVEL)
	if lv < record.lvMax then
		createLabel(tipBg, game.getStrByKey("new_function_ex_lv_tip"), cc.p(30, 80), cc.p(0, 0), 22, true, nil, nil, MColor.lable_black)
		createLabel(tipBg, string.format(game.getStrByKey("new_function_ex_lv"), record.lvMax), cc.p(30, 40), cc.p(0, 0), 22, true, nil, nil, MColor.lable_yellow)
		createLabel(tipBg, string.format(game.getStrByKey("new_function_ex_lv_need"), record.lvMax-lv), cc.p(tipBg:getContentSize().width/2, 40), cc.p(0.5, 0), 22, true, nil, nil, MColor.red)
		local function goLevelUpBtnFunc()
			removeFromParent(self.bg)
			self.detailNode = nil
			self.bg = nil
		end
		local goLevelUpBtn = createMenuItem(tipBg, "res/component/button/50.png", cc.p(290, 55), goLevelUpBtnFunc)
		goLevelUpBtn:setScale(0.8)
		createLabel(goLevelUpBtn, game.getStrByKey("new_function_ex_go_levelup"), cc.p(goLevelUpBtn:getContentSize().width/2, goLevelUpBtn:getContentSize().height/2), cc.p(0.5, 0.5), 26, true)
	else
		createLabel(tipBg, game.getStrByKey("new_function_ex_lv_tip"), cc.p(30, 80), cc.p(0, 0), 22, true, nil, nil, MColor.lable_black)
		createLabel(tipBg, string.format(game.getStrByKey("new_function_ex_lv"), record.lvMax), cc.p(30, 40), cc.p(0, 0), 22, true, nil, nil, MColor.lable_yellow)
		createLabel(tipBg, game.getStrByKey("new_function_ex_finish"), cc.p(tipBg:getContentSize().width/2, 40), cc.p(0.5, 0), 22, true, nil, nil, MColor.green)
		local getBtn = createMenuItem(tipBg, "res/component/button/50.png", cc.p(290, 55), getFunc)
		getBtn:setScale(0.8)
		self.getBtn = getBtn
		createLabel(getBtn, game.getStrByKey("new_function_ex_lv_get_label"), cc.p(getBtn:getContentSize().width/2, getBtn:getContentSize().height/2), cc.p(0.5, 0.5), 26, true, nil, nil, MColor.lable_yellow)
		getBtn:blink()
		-- --特效
		-- local animate = tutoAddAnimation(getBtn, cc.p(getBtn:getContentSize().width/2, getBtn:getContentSize().height/2), TUTO_ANIMATE_TYPE_BUTTON)
		-- animate:setContentSize(cc.size(200, 65))
		-- scaleToTarget(animate, getBtn)
	end

	--展示动画部分
	if record.res then
		local showSpr = createSprite(bg, record.res, cc.p(bg:getContentSize().width/2, 340), cc.p(0.5, 0.5), nil, record.scale)
		self.showItem = showSpr
	end

	if record.itemId then
		-- local Mprop = require("src/layers/bag/prop")
		-- local iconNode = Mprop.new({cb = "tips", protoId = record.itemId})
		-- bg:addChild(iconNode)
		-- iconNode:setAnchorPoint(cc.p(0.5, 0.5))
  --       iconNode:setPosition(cc.p(bg:getContentSize().width/2, 380))
  --      	iconNode:setScale(1.5)
  		local MpropOp = require "src/config/propOp"
		local resPath = MpropOp.icon(record.itemId)
		if record.id == 10 then
			resPath = "res/group/currency/4.png"
		end
		local icon = createSprite(bg, resPath, cc.p(bg:getContentSize().width/2, 360), cc.p(0.5, 0.5))
		icon:setScale(1.5)

		if record.itemId == 888888 then
			createSprite(icon, "res/group/lock/1.png", cc.p(0, 0), cc.p(0, 0))
		end

       	self.showItem = icon
	else
		if record.effect then
			if record.id == 7 then
				-- local animateSpr = SpriteBase:create("show/1016")
				-- animateSpr:setAnchorPoint(0.5, 0.5)
				-- animateSpr:setType(31)
				-- animateSpr:initStandStatus(4,6,1.5,7)
				-- animateSpr:standed()
				-- bg:addChild(animateSpr)
				-- animateSpr:setPosition(cc.p(bg:getContentSize().width/2, 280)) 
				-- self.showItem = animateSpr
			elseif record.id == 10 then
				local sprite = createSprite(bg, "res/showplist/wing/1.png", cc.p(bg:getContentSize().width/2, 400), cc.p(0.5, 0.5))
				self.showItem = sprite
			else
				local effect = Effects:create(false)
				effect:setCleanCache()
			    effect:playActionData(record.effect, record.effectNum, record.effectTime, -1)
			    bg:addChild(effect)
			    effect:setAnchorPoint(cc.p(0.5, 0.5))
			    effect:setPosition(cc.p(bg:getContentSize().width/2, 340))
			    effect:setScale(record.scale)
			    if record.effectOff then
			    	effect:setPosition(cc.p(effect:getPositionX()+record.effectOff.x, effect:getPositionY()+record.effectOff.y))
			    end

			    if record.id == 1 and record.school == 2 then
			    	local skill_effect = Effects:create(false)
					local actions = {}

					actions[#actions+1] = cc.CallFunc:create(function() skill_effect:setPosition(cc.p(bg:getContentSize().width/2-70, 340)) end)
					actions[#actions+1] = cc.DelayTime:create(0.2)

					local c_ani_begin = skill_effect:createEffect2("2002/shifa", 100)
					c_ani_begin:setLoops(1)	
					actions[#actions+1] = cc.Animate:create(c_ani_begin)

					actions[#actions+1] = cc.DelayTime:create(0.5)

					actions[#actions+1] = cc.CallFunc:create(function() skill_effect:setPosition(cc.p(bg:getContentSize().width/2+100, 340-70)) end)
					
					local c_ani_loop = skill_effect:createEffect2("2002/hit", 100)
					c_ani_loop:setLoops(1)
					actions[#actions+1] = cc.Animate:create(c_ani_loop)

					local action = cc.RepeatForever:create(cc.Sequence:create(actions))
					skill_effect:runAction(action)
					skill_effect:setRenderMode(1)
					bg:addChild(skill_effect)
					skill_effect:setAnchorPoint(cc.p(0.5, 0.5))
			    	skill_effect:setPosition(cc.p(bg:getContentSize().width/2, 340))
			    end

			    if record.id ~= 10 then 
			    	self.showItem = effect
			    end
		   	end
		end
	end
	-- if self.showRecord.num then
	-- 	createLabel(self.showItem, "x"..self.showRecord.num, getCenterPos(self.showItem, 5, -5), cc.p(0, 1), 22, true, nil, nil, MColor.white)
	-- end 

    local function checkFunc()
    	self:createDetail(record)
	end
    local checkBtn = createMenuItem(bg, resPath.."3.png", cc.p(300, 230), checkFunc)
    if noCheck == true then
    	if goLevelUpBtn then
    		removeFromParent(goLevelUpBtn)
    		goLevelUpBtn = nil
    	end
    	if checkBtn then
    		removeFromParent(checkBtn)
    		checkBtn = nil
    	end
    	if closeBtn then removeFromParent(closeBtn) closeBtn = nil end

    	getRunScene():addChild(bg, 100)
    	bg:setPosition(cc.p(display.cx, -display.height))
    	local targetPos = cc.p(self.showItem:getPosition())
    	self.showItem:setPosition(cc.p(targetPos.x, display.height*3))
    	bg:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(0.8, cc.p(display.cx, display.cy)))))
    	self.showItem:runAction(cc.EaseSineOut:create(cc.MoveTo:create(0.8, targetPos)))
    end

    if noCheck ~= true and isGet ~= true then
    	--checkFunc()
    end

    if isGet then
    	if closeBtn then removeFromParent(closeBtn) closeBtn = nil end
    	if goLevelUpBtn then
    		removeFromParent(goLevelUpBtn)
    		goLevelUpBtn = nil
    	end
    	if newBg then removeFromParent(newBg) newBg = nil end
    end

    startTimerAction(self, self.touchProtectTime, false, function() self.touchProtect = false end)

    if noCheck ~= true then
	    local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(true)
	    listenner:registerScriptHandler(function(touch, event)
	    		--log("EVENT_TOUCH_BEGAN")
	       		return true
	        end,cc.Handler.EVENT_TOUCH_BEGAN )

	     listenner:registerScriptHandler(function(touch, event)
	     		--log("EVENT_TOUCH_MOVED")
	        end,cc.Handler.EVENT_TOUCH_MOVED )

	      listenner:registerScriptHandler(function(touch, event)
	      		--log("EVENT_TOUCH_ENDED")
	      		if self.touchProtect then
	      			return
	      		end

	    		local location = touch:getLocation()
	    		if cc.rectContainsPoint(self.bg:getBoundingBox(), cc.p(location.x, location.y)) then

	       		else
	       			if self.detailNode ~= nil then
	       				local locationNode = self.bg:convertToNodeSpace(location)
	       				if cc.rectContainsPoint(self.detailNode:getBoundingBox(), cc.p(locationNode.x, locationNode.y)) then
	       					
	       				else
	       					if self.getBtn then
					      		getFunc()
					      	end
	       					AudioEnginer.playTouchPointEffect()
	       					closeFunc()
	       				end
	       			else
	       				if self.getBtn then
				      		getFunc()
				      	end
	       				AudioEnginer.playTouchPointEffect()
	       				closeFunc()
	       			end
	       		end
	        end,cc.Handler.EVENT_TOUCH_ENDED  )
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, bg)
	end
	--log("NewFunctionNodeEx:createShow end")
end

function NewFunctionNodeEx:createDetail(record)
	if self.detailNode ~= nil then
		return
	end

	local resPath = "res/newFunctionEx/"
	local MTipsBase = require "src/layers/bag/TipsBase"

	local bg = createSprite(nil, resPath.."bgRight.png", cc.p(30, 435), cc.p(0.5, 0.5))--MTipsBase:background(1200)
	-- createSprite(bg, "res/fb/multiple/17.png", cc.p(bg:getContentSize().width/2, 420), cc.p(0.5, 0.5)) 	
	-- createSprite(bg, "res/fb/multiple/17.png", cc.p(bg:getContentSize().width/2, 360), cc.p(0.5, 0.5)) 	

	local function closeFunc()
		self:removeDetail()
	end
	local closeBtn = createMenuItem(bg, "res/common/13.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-25), closeFunc)
	closeBtn:setScale(0.7)

	local iconBg
	if record.itemId then
		log("test 1")
		local Mprop = require("src/layers/bag/prop")
		local iconBg = Mprop.new({cb = "tips", protoId = record.itemId, showBind = true, isBind = true})
		--createSprite(bg, "res/common/bg/itemBg.png", cc.p(35, 430), cc.p(0, 0), 1)
		bg:addChild(iconBg)
		iconBg:setAnchorPoint(cc.p(0, 0))
        iconBg:setPosition(cc.p(35, 430))
       	--iconBg:setScale(1.5)
	else
		log("test 2")
		iconBg = createSprite(bg, "res/group/itemBorder/4.png", cc.p(35, 430), cc.p(0, 0))
		local icon = createSprite(iconBg, resPath.."show/"..record.id..".png", cc.p(iconBg:getContentSize().width/2, iconBg:getContentSize().height/2), cc.p(0.5, 0.5)) 
		createSprite(icon, "res/common/bg/itemBg.png", getCenterPos(icon), cc.p(0.5, 0.5), -1)
		-- local effect = Effects:create(false)
	 --    effect:playActionData("propColor4", 11, 1.2, -1)
	 --    iconBg:addChild(effect)
	 --    effect:setAnchorPoint(cc.p(0.5, 0.5))
	 --    effect:setPosition(cc.p(iconBg:getContentSize().width/2, iconBg:getContentSize().height/2))
	end

	--name
	if record.itemId then
		local MpropOp = require "src/config/propOp"
		createLabel(bg, MpropOp.name(record.itemId), cc.p(120, 470), cc.p(0, 0), 24, true)
	else
		createLabel(bg, record.name, cc.p(120, 470), cc.p(0, 0), 24, true)
	end
	
	--描述
	-- if record.itemId then
	-- 	local MpropOp = require "src/config/propOp"
	-- 	createLabel(bg, MpropOp.description1(record.itemId), cc.p(25, 390), cc.p(0, 0.5), 22, true, nil, nil, MColor.yellow, nil, 350)
	-- else
		createLabel(bg, record.content, cc.p(25, 390), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow, nil, 350)
	-- end
	
	--战斗力
	if record.battle then
		local battleBg = createSprite(bg, "res/common/misc/powerbg_s.png", cc.p(110, 430), cc.p(0, 0))
		battleBg:setScale(0.7)
		createSprite(battleBg, "res/common/misc/power_b.png", cc.p(20, battleBg:getContentSize().height/2), cc.p(0, 0.5), nil, 0.8)
		createSprite(battleBg, "res/component/number/9_inc.png", cc.p(140, battleBg:getContentSize().height/2), cc.p(0, 0.5))
		local  labelAtlas = cc.LabelAtlas:_create(record.battle, "res/component/number/9.png", 29, 40, string.byte('0'))
		battleBg:addChild(labelAtlas)
		labelAtlas:setAnchorPoint(cc.p(0, 0.5))
		labelAtlas:setPosition(170, battleBg:getContentSize().height/2)
	end

	local richText = require("src/RichText").new(bg, cc.p(40, 340), cc.size(300, 355), cc.p(0, 1), 30, 20, MColor.lable_yellow)
	-- if record.itemId then
	-- 	local MpropOp = require "src/config/propOp"
	-- 	richText:addText(MpropOp.description2(record.itemId))
	-- else
		richText:addText(record.detail)
	-- end
    richText:format()

	self.detailNode = bg
	self.bg:addChild(self.detailNode, 10)
	self.detailNode:setPosition(cc.p(self.bg:getContentSize().width/2, self.bg:getContentSize().height/2))
	dump(self.bgToPos)
	--self.bg:stopAllActions()
	self.bg:runAction(cc.MoveTo:create(0.3, self.bgToPos))
	self.detailNode:runAction(cc.MoveBy:create(0.3, cc.p(self.bg:getContentSize().width, 0)))
end

function NewFunctionNodeEx:removeShow()
	if self.bg ~= nil then
		removeFromParent(self.bg)
		self.detailNode = nil
		self.bg = nil
	end
end

function NewFunctionNodeEx:removeDetail()
	if self.detailNode ~= nil then
		removeFromParent(self.detailNode)
		self.detailNode = nil
		self.bg:runAction(cc.MoveTo:create(0.3, cc.p(display.cx, display.cy)))
	end
end

return NewFunctionNodeEx