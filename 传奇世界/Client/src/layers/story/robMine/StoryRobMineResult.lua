local StoryRobMineResult = class("StoryRobMineResult" , function() return cc.Layer:create() end)
local comPath = "res/fb/tower/"
local commConst = require("src/config/CommDef");

function StoryRobMineResult:ctor(endData)
	
	self.netData = copyTable(endData)
	if not self.netData.awardData then
		self.netData.awardData = {}
	end
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
	local funcTab = {self.addTitle, self.addAward, self.addWinFlg,self.addFlop, self.addFailTipsBtn, self.winOutBtn, self.failOutBtn}

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
	
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    									return true 
    								end,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.overView)
end

function StoryRobMineResult:addTitle()
	-- if self.isWin then return 0 end
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

function StoryRobMineResult:addWinFlg()
	if not self.isWin then
		return 0
	end

    local posX_text_success, posY_text_success = 480, 640 * 4 / 6
    local sprite_text_success = cc.Sprite:create("res/fb/winFlg.png")
    sprite_text_success:setVisible(false)
    sprite_text_success:setAnchorPoint(.5, .5)
    sprite_text_success:setPosition(cc.p(posX_text_success, posY_text_success))
    sprite_text_success:runAction(cc.Sequence:create(
    	 cc.DelayTime:create(0.25)
        , cc.Show:create()
        , cc.DelayTime:create(1)
        , cc.FadeOut:create(1)
        , cc.RemoveSelf:create()
    ))
    self.overView:addChild(sprite_text_success, 3)

    local animateSpr = Effects:create(false)
    animateSpr:setAnchorPoint(.5, .5)
    animateSpr:setPosition(cc.p(posX_text_success, posY_text_success))
    animateSpr:runAction(cc.Sequence:create(
         cc.CallFunc:create(function()
            animateSpr:playActionData("operationsuccess", 11, 1.9, 1)
        end)
        , cc.DelayTime:create(1.9)
        , cc.RemoveSelf:create()
    ))
    addEffectWithMode(animateSpr, 1)
    self.overView:addChild(animateSpr, 3)

	return 2.5
end

function StoryRobMineResult:addAward()
	if not self.isWin or #self.netData.awardData <= 0 then return 0 end
	
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
	-- local AwardNode = cc.Node:create()
	-- self.overView:addChild(AwardNode)

	-- local pos = cc.p( 260, 270 + 140)
	-- local award = createSprite(self.overView, "res/fb/passAward.png", pos, nil)
	-- local rewordIcons = {}

	-- for m,n in pairs(self.netData.awardData) do
	-- 	local Mprop = require "src/layers/bag/prop"
	-- 	local icon = Mprop.new(
	-- 	{
	-- 		protoId = tonumber(n[1]),
	-- 		num = tonumber(n[2]),
	-- 		swallow = true,
	-- 		--cb = "tips",
	-- 		-- showBind = true,
 --   --      	isBind = tonumber(n.bdlx or 0),
	-- 	})
	-- 	table.insert( rewordIcons, icon) 
	-- end
	
	-- local countNum = 1
	-- local Num = #rewordIcons
	-- if Num > 4 then Num = 4 end
	-- for k,v in pairs(rewordIcons) do
	-- 	if countNum > 4 then break end
	-- 	local x = 400 - Num / 2 * 80 + countNum * 80 --340 + 22 + (countNum - 1) * 80
	-- 	v:setPosition(cc.p(x, pos.y - 75))
	-- 	v:setAnchorPoint(cc.p(0, 0.5))
	-- 	AwardNode:addChild(v)
	-- 	--v:setScale(0.9)
	-- 	countNum = countNum + 1
	-- end
	-- AwardNode:setPosition(cc.p(0, 0))

	return 0
end

function StoryRobMineResult:addStar()
	if not self.isWin then return 0 end
	local StrNode = cc.Node:create()
	self.overView:addChild(StrNode)
	local starSpr = {}
	if self.netData.thisStar > 3 then
        self.netData.thisStar = 3
	end
	for i=1, self.netData.thisStar do
		starSpr[i] = createSprite(StrNode, "res/group/star/s5.png", cc.p(-100, -100))
	end

	posX = 480 + 4
	startPosY = 480
	offSetY = 10
	offSetX = 70
	local starPos = {cc.p(posX, startPosY),cc.p(posX, startPosY),cc.p(posX, startPosY)}
	if #starSpr == 2 then
		starPos[1] = cc.p(posX - offSetX/2, startPosY)
		starPos[2] = cc.p(posX + offSetX/2, startPosY)
	elseif #starSpr == 3 then
		starPos[1] = cc.p(posX - offSetX, startPosY + offSetY)
		starPos[2] = cc.p(posX , startPosY)		
		starPos[3] = cc.p(posX + offSetX, startPosY + offSetY)
	end

	for i=1,#starSpr do
		starSpr[i]:setPosition(starPos[i])
		starSpr[i]:setOpacity(0)
		starSpr[i]:setScale(2)
		starSpr[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.05 + (i-1) *0.3),
												cc.FadeIn:create(0.05),
												cc.ScaleTo:create(0.2, 1)
											 	--cc.MoveTo:create(0.12, cc.p(0, 0))
											 ))
	end

	return 0.3 * #starSpr
end

function StoryRobMineResult:addFlop()
	if false and self.isWin then
		local ret = require("src/base/FBFlopLayer").new({awardData = self.netData.cardPrize, callBack = function () self:flopCallBack() end})
		self.overView:addChild(ret)
	end
	return 0	
end

function StoryRobMineResult:addFailTipsBtn()
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
				g_EventHandler["FbRobMineFailCallBack"] = function() func(i) end 
				self:closeResultLayer()
				 end)
			spr:setScale(0.5)

			local item = createMenuItem(self.overView, "res/component/button/39.png", cc.p(480 - (2-i)* 170, 220), function()
				g_EventHandler["FbRobMineFailCallBack"] = function() func(i) end 
				self:closeResultLayer()	
				 end)
			createLabel(item, menuText[i], getCenterPos(item), nil,22, true)
		end
	end
	return 0
end

function StoryRobMineResult:winOutBtn()
	if not self.isWin then return 0 end

	local autoGetTimeLeft = 10
	local fbid = userInfo.lastFb
	local newFbID = 0
	local ILevel = MRoleStruct:getAttr(ROLE_LEVEL)
	local fbData = require("src/config/FBTower")
	local needLev = 0
	local timer = nil
	if fbData then
		for k,v in pairs(fbData) do
			if v.q_id == fbid then
				newFbID = v.q_nextCopy
				needLev = v.q_limit_level
				break
			end
		end
	end
	local isGotoNext = (newFbID ~= 0)
	local nextCopyLab = nil

	local posCfg = {cc.p(g_scrSize.width-70, g_scrSize.height - 110), cc.p(g_scrSize.width-70, g_scrSize.height - 170)}
	local item = createMenuItem(self.overView, "res/component/button/50.png", cc.p(480, 80), function() self:closeResultLayer()  end)
	createLabel(item, game.getStrByKey("fb_getOutFb"), getCenterPos(item), nil, 22, true):setColor(MColor.lable_yellow)
	
	local timeLabUpdate = function(delTime)
		autoGetTimeLeft = autoGetTimeLeft - delTime
		if autoGetTimeLeft >= 0 and nextCopyLab then
			local str = game.getStrByKey("carry_tip_next_floor1") .. "[" .. autoGetTimeLeft.. "]"
			nextCopyLab:setString(str)
		end

		if autoGetTimeLeft <= 0 then
			if timer then
				timer:stopAllActions()
				timer = nil
			end
			self:closeResultLayer()
		end
	end

	return 0
end

function StoryRobMineResult:failOutBtn()
	if self.isWin then return 0 end

	local autoGetTimeLeft = 10	
	local strOut = game.getStrByKey("fb_secsToGetOut3")

	local autoOutLab = createLabel(self.overView, "" .. autoGetTimeLeft .. strOut, cc.p(480, 40), cc.p(0.5, 0.5), 20, true, 10)
	self.autoOutLab = autoOutLab

	local item = createMenuItem(self.overView, "res/component/button/50.png", cc.p(480, 80), function() self:closeResultLayer()  end)
	createLabel(item, game.getStrByKey("fb_getOutFb"), getCenterPos(item), nil, 22, true):setColor(MColor.lable_yellow)
	self.autoBtn = item
	-- item:setVisible(not self.isWin or self.isOpenFlop)
	-- self.autoOutLab:setVisible(not self.isWin or self.isOpenFlop)

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

function StoryRobMineResult:flopCallBack()
	self.isOpenFlop = true
	if self.autoBtn then
		self.autoBtn:setVisible(true)
	end
	if self.autoOutLab then
		self.autoOutLab:setVisible(true)
	end
end

function StoryRobMineResult:closeResultLayer()
	-- G_MAINSCENE.map_layer:fbExit()
	--完成退出夺矿
	-- G_MAINSCENE:exitStoryMode()
    -- if G_MAINSCENE and G_MAINSCENE.storyNode then
		-- G_MAINSCENE.storyNode:endStory()
    -- end
	G_MAINSCENE.map_layer:fbExit()
	removeFromParent(self)
    -- g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_SIMULATION_QUIT, "DigMineSimulationQuit", {})
	-- G_MAINSCENE.map_layer.towerResult = nil
    
	removeFromParent(self)

end

return StoryRobMineResult