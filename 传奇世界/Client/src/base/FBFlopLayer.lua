local FBFlopLayer = class("FBFlopLayer", function() return cc.Node:create() end)
local PokerSprite = class("PokerSprite", function()	return cc.Node:create() end)

local resPath = "res/fb/flop/"

function FBFlopLayer:ctor(parmas)
	log("FBFlopLayer:ctor..........")
	local parmas = parmas or {}
	parmas.time = parmas.time or 5
	parmas.layer = parmas.layer or 1
	parmas.awardData = parmas.awardData or {}
	self.callBack = parmas.callBack or nil
	--dump(parmas)
	self.parmas = parmas
	self.ChooseIndex = 0
	self.size = cc.size(960, 640)

	self.MidLayer = cc.Node:create()
	self:addChild(self.MidLayer, 1)

	self:addPoker()

	local str = string.format(game.getStrByKey("rescue_princess_autoselect"), parmas.time)
	local lab = createLabel(self.MidLayer, str, cc.p(self.size.width/2, 60), nil, 20, true, 10)
	self.timeLab = lab

	self.time = startTimerActionEx(self, 1, true, function(delTime) 
			parmas.time = parmas.time - delTime
			if parmas.time <= 0 then
				self:autoOpenPoker()
			end

			if parmas.time >= 0 then
				local str = string.format(game.getStrByKey("rescue_princess_autoselect"), parmas.time)
				lab:setString(str)
			else
				lab:setString("")
			end
		end)

 	local msgids = {COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET}
	require("src/MsgHandler").new(self,msgids)
end

function FBFlopLayer:autoOpenPoker()
	if self.ChooseIndex == 0 then
		local itemIndex = math.floor(math.random(1, 3 or #parmas.awardData))
		self:sendOpenPokerMsg(itemIndex)
	end
end

function FBFlopLayer:addPoker()
	local num = #self.parmas.awardData
	local wid = 170
	self.Pokers = {}

	createLabel(self, game.getStrByKey("fb_plsFlop"), cc.p(self.size.width/2, 440), nil, 20, true):setColor(MColor.lable_yellow)
	for i=1, num do
		local pokerTemp = PokerSprite.new("res/fb/defense/card_back.png", "res/fb/defense/card_front.png", i)
		self.MidLayer:addChild(pokerTemp)
		pokerTemp:setPosition(cc.p(self.size.width/2 - num/2 * wid + (i-1) * wid, 175))
		self.Pokers[i] = pokerTemp
		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(false)
	    listenner:registerScriptHandler(function(touch, event)
	     		return true
	        end,cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
				local touchPointInNode = pokerTemp:convertTouchToNodeSpace(touch)
				if(cc.rectContainsPoint(pokerTemp.backSpr:getBoundingBox(), touchPointInNode)) then
					self:sendOpenPokerMsg(pokerTemp.index)
		    	end
	        end,cc.Handler.EVENT_TOUCH_ENDED)          
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, pokerTemp)	
	end
end

function FBFlopLayer:sendOpenPokerMsg(index)
	if index and self.ChooseIndex == 0 then
		self.ChooseIndex = index
		if index < 1 then index = 1 end
		--g_msgHandlerInst:sendNetDataByFmtExEx(COPY_RESCUEPRINCESS_CS_STEPPRIZE_SELECT, "iis", userInfo.currRoleId, index, 1)
		log("[FBFlopLayer:sendOpenPokerMsg] called. index = %d.", index)		
	end
end

function FBFlopLayer:openPokerMsgRet(itemData,index)
	local data = unserialize(itemData)
	--dump(data)
	local tempPoker = self.Pokers[index]

	if tempPoker and tempPoker.frontSpr then
		if data ~= nil then
			local MPropOp = require "src/config/propOp"
			local Mprop = require "src/layers/bag/prop"
			for k, v in pairs(data) do
				local icon = Mprop.new(
				{
					protoId = tonumber(v.itemID),
					num = tonumber(v.count),
					swallow = true,
					--cb = "tips",
				})
				tempPoker.frontSpr:addChild(icon)
				icon:setPosition(tempPoker.frontSpr:getContentSize().width/2, 180)
				icon:setAnchorPoint(0.5, 0.5)
				icon:setScale(1.2)

				local strName = MPropOp.name(tonumber(v.itemID))
				local color = MPropOp.nameColor(tonumber(v.itemID))
				if strName and strName ~= "" then
					createLabel(tempPoker.frontSpr, strName, cc.p(tempPoker.frontSpr:getContentSize().width/2, 80), nil, 26):setColor(color)
				end
				break
			end
		end

		local cardEff = Effects:create(false)
		cardEff:playActionData("card", 20, 1.5, 1)
		addEffectWithMode(cardEff,3)
		local pos = cc.p(tempPoker.frontSpr:getPosition())
		cardEff:setPosition(cc.p(pos.x,pos.y+14))
		tempPoker:addChild(cardEff)
		cardEff:setScale(144/178)
		tempPoker:open(0.3)
	end
end

function FBFlopLayer:closeFunc()
	removeFromParent(self)
end

function FBFlopLayer:networkHander(luabuffer,msgid)
	cclog("[FBFlopLayer:networkHander] called." .. msgid)
    local switch = {
		[COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET] = function()
 			local itemAwardData = luabuffer:popString()
 			local itemIndex = luabuffer:popInt()
			cclog("[COPY_RESCUEPRINCESS_SC_STEPPRIZE_SELECT_RET] %s %d", itemAwardData, itemIndex)
			self:openPokerMsgRet(itemAwardData, itemIndex)
			if self.callBack then
				if self.timeLab then
					self.timeLab:setString("")
				end
				if self.time then
					self.time:stopAllActions()
				end			
				self.callBack()
			end
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

--////////////////////////////////////////////////////////////
function PokerSprite:ctor(backPath, frontPath, index)
	self.changeFunc = changeFunc
	self.touchCall = touchCall
	self.index = index

	local backSpr  = createSprite(self, backPath, cc.p(0, 0), nil)
	local frontSpr = createSprite(self, frontPath, cc.p(0, 0), nil)
	local backSize = frontSpr:getContentSize()
	setNodeAttr(backSpr, cc.p(backSize.width / 2 - 7, backSize.height /2))
	setNodeAttr(frontSpr, cc.p(backSize.width / 2 - 7, backSize.height /2))
	frontSpr:setVisible(false)
	frontSpr:setScale(144/178)
	backSpr:setScale(144/178)
	self.backSpr = backSpr
	self.frontSpr = frontSpr
end

function PokerSprite:open(time )
	time = time or 0.5
	print("PokerSprite:open .........." .. time)
	self.frontSpr:stopAllActions()
	self.backSpr:stopAllActions()         
	local orbitFront = cc.OrbitCamera:create(time * 0.5,1,0,90,-90,0,0)
	local orbitBack = cc.OrbitCamera:create(time * 0.5,1,0,0,-90,0,0)
	local action = cc.TargetedAction:create(self.frontSpr, cc.Sequence:create(cc.Show:create(), orbitFront))
	self.frontSpr:setVisible(false)
	self.backSpr:runAction(cc.Sequence:create(cc.Show:create(),
									   orbitBack,
									   cc.Hide:create(),
									   action
									   )
				  )
end

return FBFlopLayer