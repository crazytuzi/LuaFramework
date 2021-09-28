local FBResult = class("FBResult", function() return cc.Layer:create() end)
local comPath = "res/fb/tower/"
local commConst = require("src/config/CommDef");

function FBResult:ctor(endData)
	self.netData = copyTable(endData)
	self.isWin = self.netData.isWin
	self.isOpenFlop = true
	if self.isWin then
		AudioEnginer.playEffect("sounds/fbWin.mp3", false)
	end

	if not self.isWin then
		local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
		self:addChild(colorbg)
		colorbg:setLocalZOrder(200)
		self.fbSettlementcolorbg = colorbg
	end

	self.overView = cc.Layer:create()
	self.overView:setContentSize(cc.size(960, 640))
	self.overView:setPosition(cc.p(g_scrSize.width/2, g_scrSize.height/2))
	self.overView:ignoreAnchorPointForPosition(false)
	self.overView:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(self.overView, 201)	

	local index = 1
	local actions = {}
	local funcTab = {self.addTitle, self.addAward, self.addWinFlg, self.addFailTipsBtn, self.failOutBtn,self.winOutBtn}

	local loopFunc = nil
	loopFunc = function()
		if funcTab[index] ~= nil then
			local time = funcTab[index](self)
			index = index + 1
			actions = {}
			if time ~= 0 then
				actions[#actions + 1] = cc.DelayTime:create(time)
			end
			actions[#actions + 1] = cc.CallFunc:create(loopFunc)
			self.overView:runAction(cc.Sequence:create(actions))
		end
	end
	self.overView:runAction(cc.CallFunc:create(loopFunc))
	
	if not self.isWin then
		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(true)
	    listenner:registerScriptHandler(function(touch, event)
	    									return true 
	    								end,cc.Handler.EVENT_TOUCH_BEGAN)
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.overView)
	end
end

function FBResult:addTitle()
	if self.isWin then return 0 end
	local str,str2 = nil,nil
	if self.isWin then
		str = "win"
	else
		str = "fail"
	end	
	local TitleNode = cc.Node:create()
	self.overView:addChild(TitleNode)
	local addLight = function()
		if not self.isWin then return end
		local node = cc.Node:create()
		local light = createSprite(node, "res/fb/light.png", cc.p(400, -12), cc.p(0.5, 0.5), 200)
		node:setContentSize(light:getContentSize())
		local rotate = cc.RotateBy:create(0.1, 6)
		local forever = cc.RepeatForever:create(rotate)		
		light:runAction(forever)

	    local scrollView1 = cc.ScrollView:create()
	    local width , height = 800 , 200
	    scrollView1:setViewSize(cc.size( width , height ))
	    scrollView1:setPosition(cc.p(480, 510))
	    scrollView1:setAnchorPoint(cc.p(0.5, 0))
	    scrollView1:ignoreAnchorPointForPosition(false)
	    scrollView1:setContainer( node )
	    scrollView1:updateInset()

	    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
	    scrollView1:setClippingToBounds(true)
	    scrollView1:setBounceable(true)
	    scrollView1:setDelegate()
		scrollView1:setTouchEnabled(false)
		TitleNode:addChild(scrollView1)
	end
	local posX = 480
	if not self.isWin then
		posX = 460
	end
	createSprite(TitleNode, "res/fb/"..str.."_1.png", cc.p(posX, 550), cc.p(0.5, 0.5), 200)
	local bgLine = createSprite(TitleNode, "res/fb/"..str.."Bg.png", cc.p(480, 490), cc.p(0.5, 1), 10)
	TitleNode:setOpacity(0)
	bgLine:setVisible(false)
	TitleNode:setPosition(cc.p(0, display.cy - 550))
	TitleNode:runAction(cc.FadeIn:create(0.3))
	TitleNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),
										   cc.MoveTo:create(0.4, cc.p(0, 0)),
										   cc.DelayTime:create(0.1),
										   cc.CallFunc:create(function() bgLine:setVisible(true) end) 
										   ,cc.CallFunc:create(addLight) 
										  )
						)
	return 1.8
end

function FBResult:addWinFlg()
	if not self.isWin then
		return 0
	end

    -- local posX_text_success, posY_text_success = 480, 640 * 4 / 6
    -- local sprite_text_success = cc.Sprite:create("res/fb/winFlg.png")
    -- sprite_text_success:setVisible(false)
    -- sprite_text_success:setAnchorPoint(.5, .5)
    -- sprite_text_success:setPosition(cc.p(posX_text_success, posY_text_success))
    -- sprite_text_success:runAction(cc.Sequence:create(
    -- 	 cc.DelayTime:create(0.25)
    --     , cc.Show:create()
    --     , cc.DelayTime:create(1)
    --     , cc.FadeOut:create(1)
    --     , cc.RemoveSelf:create()
    -- ))
    -- self.overView:addChild(sprite_text_success, 3)

    -- local animateSpr = Effects:create(false)
    -- animateSpr:setAnchorPoint(.5, .5)
    -- animateSpr:setPosition(cc.p(posX_text_success, posY_text_success))
    -- animateSpr:runAction(cc.Sequence:create(
    --      cc.CallFunc:create(function()
    --         animateSpr:playActionData("operationsuccess", 11, 1.9, 1)
    --     end)
    --     , cc.DelayTime:create(1.9)
    --     , cc.RemoveSelf:create()
    -- ))
    -- addEffectWithMode(animateSpr, 1)
    -- self.overView:addChild(animateSpr, 3)
    addFBTipsEffect(self.overView, cc.p(480, 320), "res/fb/win_2.png")

	return 2
end

function FBResult:addAward()
	if not self.isWin or not self.netData.awardData or #self.netData.awardData <= 0 then return 0 end
	
	local MPropOp = require "src/config/propOp"
	local str = "获得:"
	local flg = false
	for m,n in pairs(self.netData.awardData) do
		if flg then
			str = str .. "+"
		end
		str = str .. MPropOp.name(tonumber(n[1])) .. "x" .. n[2]
		flg = true
	end
	TIPS({str = str})
	
	return 0
end

function FBResult:addFailTipsBtn()
	if not self.isWin then
		createLabel(self.overView, game.getStrByKey("jjc_tip"), cc.p(480, 425), nil, 22):setColor(MColor.lable_yellow)
		createLabel(self.overView, game.getStrByKey("fail_text"), cc.p(480, 150), nil, 22):setColor(MColor.lable_yellow)
		local func = function (num)
			if num == 1 then
				__GotoTarget({ru = "a137", index = 2})
			elseif num == 2 then
				__GotoTarget({ru = "a136", index = 1})
			else
				__GotoTarget({ru = "a136", index = 1})
			end
		end
		local menuText = {game.getStrByKey("tiSheng") .. game.getStrByKey("faction_top_level")
						 ,game.getStrByKey("wr_advance_start") .. game.getStrByKey("equipment") 
						 ,game.getStrByKey("wing") .. game.getStrByKey("wr_advance_start")
						 }
		for i=1,3 do
			local spr = createMenuItem(self.overView, "res/fb/tower/btn"..i..".png", cc.p(480 - (2-i)* 170, 330), function()
				g_EventHandler["normalFbFailCallBack"] = function() func(i) end 
				self:closeResultLayer()
				 end)
			spr:setScale(0.5)

			local item = createMenuItem(self.overView, "res/component/button/39.png", cc.p(480 - (2-i)* 170, 220), function()
				g_EventHandler["normalFbFailCallBack"] = function() func(i) end 
				self:closeResultLayer()	
				 end)
			createLabel(item, menuText[i], getCenterPos(item), nil, 22, true)
		end
	end
	return 0
end

function FBResult:winOutBtn()
	if not self.isWin then return 0 end
	performWithDelay(self, function() self:closeResultLayer() end, 0)
	return 0
end

function FBResult:failOutBtn()
	if self.isWin then return 0 end

	local autoGetTimeLeft = 10	
	local strOut = game.getStrByKey("fb_secsToGetOut3")

	local autoOutLab = createLabel(self.overView, "" .. autoGetTimeLeft .. strOut, cc.p(480, 40), cc.p(0.5, 0.5), 20, true, 10)
	self.autoOutLab = autoOutLab

	local item = createMenuItem(self.overView, "res/component/button/50.png", cc.p(480, 80), function() self:closeResultLayer()  end)
	createLabel(item, game.getStrByKey("fb_getOutFb"), getCenterPos(item), nil, 22, true):setColor(MColor.lable_yellow)
	self.autoBtn = item
	
	local timeLabUpdate = function(delTime)
		autoGetTimeLeft = autoGetTimeLeft - delTime
		if autoGetTimeLeft >= 0 then
			autoOutLab:setString("" .. autoGetTimeLeft .. strOut)
		end

		if autoGetTimeLeft <= 0 then
			self:closeResultLayer()
		end
	end
	startTimerActionEx(self.overView, 1, true, timeLabUpdate)
	
	return 0
end

function FBResult:closeResultLayer()
	self.overView:stopAllActions()
	if self.netData.endCallFun then
		self.netData.endCallFun()
	end
	removeFromParent(self)
end

return FBResult