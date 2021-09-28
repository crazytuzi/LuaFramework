local LotteryShowLayer = class("LotteryShowLayer", function() return cc.Layer:create() end)

local path = "res/lotteryEx/"

local function getCenterPos(node)
	return cc.p(node:getContentSize().width/2, node:getContentSize().height/2)
end

function LotteryShowLayer:ctor(parent, isNormal, tab)
	AudioEnginer.playEffect("sounds/uiMusic/ui_treasure.mp3", false)
	self.parent = parent
	self.isNormal = isNormal
	self.data = tab
	self.number = #self.data
	--dump(self.data)

	for k,v in pairs(self.data) do
		if v.id then
			local bagPack = MPackManager:getPack(MPackStruct.eBag)
			v.grid = bagPack:getGirdByGirdId(v.id)
			v.quality = getConfigItemByKey("propCfg", "q_id", MPackStruct.protoIdFromGird(v.grid), "q_default") or 1
		end
	end
	--dump(self.data)
	local sortFunc = function(a, b) 
		return b.quality < a.quality 
	end
	table.sort(self.data, sortFunc)
	--dump(self.data)

	local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.8))
	self:addChild(masking)

	local bg = createSprite(self, path.."21.png", getCenterPos(self), cc.p(0.5, 0.5))

	-- if isNormal then
	-- 	self.boxSpr = createSprite(self, path.."16.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	-- else
	-- 	self.boxSpr = createSprite(self, path.."17.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	-- end

	local function summonOneFun()
		local summonSubType
		if self.isNormal == true then
			summonSubType = 1
		else
			summonSubType = 2
		end

		if summonSubType then
			--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_SUMMON, "ii", G_ROLE_MAIN.obj_id, summonSubType)
			--addNetLoading(LOTTERY_CS_SUMMON, LOTTERY_SC_SUMMON)
		end

		removeFromParent(self)
	end
	local summonOneBtn = createMenuItem(self, "res/component/button/1.png", cc.p(display.cx, 70), summonOneFun)
	self.summonOneBtn = summonOneBtn
	createLabel(summonOneBtn, game.getStrByKey("lotteryEx_btn_one"), getCenterPos(summonOneBtn), cc.p(0.5, 0.5), 20, true)
	self.summonOneBtn:setVisible(false)

	local function summonTenFun()
		local function yesFunc()
			local summonSubType
			if self.isNormal == true then
				summonSubType = 4
			else
				summonSubType = 3
			end

			if summonSubType then
				--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_SUMMON, "ii", G_ROLE_MAIN.obj_id, summonSubType)
				--addNetLoading(LOTTERY_CS_SUMMON, LOTTERY_SC_SUMMON)
			end
			
			removeFromParent(self)
		end
		
		if self.parent.luck and self.parent.luck >= 4 then
			MessageBoxYesNo(nil, game.getStrByKey("lotteryEx_tip_reward"), function() 
					yesFunc()
				end, nil)
		else
			yesFunc()
		end
	end
	local summonTenBtn = createMenuItem(self, "res/component/button/1.png", cc.p(display.cx-270, 70), summonTenFun)
	createLabel(summonTenBtn, game.getStrByKey("lotteryEx_btn_ten"), getCenterPos(summonTenBtn), cc.p(0.5, 0.5), 20, true)
	self.summonTenBtn = summonTenBtn
	self.summonTenBtn:setVisible(false)

	if self.isNormal then
		-- self.oneIcon = createLabel(self, require("src/config/propOp").name(5019), cc.p(summonOneBtn:getPositionX()-20, 105), cc.p(0, 0), 20, true, nil, nil)
		-- self.oneLabel = createLabel(self, "2", cc.p(summonOneBtn:getPositionX()-20, 105), cc.p(1, 0), 20, true, nil, nil, MColor.white)

		-- self.tenIcon = createLabel(self, require("src/config/propOp").name(5019), cc.p(summonTenBtn:getPositionX()-20, 105), cc.p(0, 0), 20, true, nil, nil)
		-- self.tenLabel = createLabel(self, "18", cc.p(summonTenBtn:getPositionX()-20, 105), cc.p(1, 0), 20, true, nil, nil, MColor.white)
		self.oneIcon = createSprite(self, require("src/config/propOp").icon(5019), cc.p(summonOneBtn:getPositionX(), 100), cc.p(1, 0), nil, 0.7)
		self.oneLabel = createLabel(self, "2", cc.p(summonOneBtn:getPositionX(), 105), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)

		self.tenIcon = createSprite(self, require("src/config/propOp").icon(5019), cc.p(summonTenBtn:getPositionX(), 100), cc.p(1, 0), nil, 0.7)
		self.tenLabel = createLabel(self, "18", cc.p(summonTenBtn:getPositionX(), 105), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
	else
		self.oneIcon = createSprite(self, "res/group/currency/3.png", cc.p(summonOneBtn:getPositionX(), 100), cc.p(1, 0), nil, 0.7)
		self.oneLabel = createLabel(self, "40", cc.p(summonOneBtn:getPositionX(), 105), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)

		self.tenIcon = createSprite(self, "res/group/currency/3.png", cc.p(summonTenBtn:getPositionX(), 100), cc.p(1, 0), nil, 0.7)
		self.tenLabel = createLabel(self, "360", cc.p(summonTenBtn:getPositionX(), 105), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
	end
	self.oneIcon:setVisible(false)
	self.oneLabel:setVisible(false)
	self.tenIcon:setVisible(false)
	self.tenLabel:setVisible(false)
	

	local function closeFunc()
		removeFromParent(self)
	end
	local closeBtn = createMenuItem(self, "res/component/button/2.png", cc.p(display.cx+270, 70), closeFunc)
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_LOTTERY_CONFIRM)
	self.closeBtn = closeBtn
	self.closeBtn:setVisible(false)
	createLabel(closeBtn, game.getStrByKey("lotteryEx_sure"), cc.p(closeBtn:getContentSize().width/2, closeBtn:getContentSize().height/2), cc.p(0.5, 0.5), 22, true)

	self:createBoxAction()

	--SwallowTouches(self)

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
	    		--log("EVENT_TOUCH_BEGAN ")
	       		return true
	        end,cc.Handler.EVENT_TOUCH_BEGAN )

	     listenner:registerScriptHandler(function(touch, event)
	     		--log("EVENT_TOUCH_MOVED")
	        end,cc.Handler.EVENT_TOUCH_MOVED )

	      listenner:registerScriptHandler(function(touch, event)
	      		--log("EVENT_TOUCH_ENDED")
	      		if G_TUTO_DATA then
					for k,v in pairs(G_TUTO_DATA) do
						if v.q_id == 11 and v.q_state == TUTO_STATE_ON then
							return
						end
					end
				end
	    		--removeFromParent(self)
	        end,cc.Handler.EVENT_TOUCH_ENDED  )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

function LotteryShowLayer:createBoxAction()
	--dump(self.boxSpr)
	self.boxEffect = Effects:create(false)
	--self.boxEffect:setCleanCache()
	if self.isNormal then
		--self.boxEffect:playActionData("lotteryNormalBoxOpen", 3, 0.5, 1)
		local actions = {}
		actions[#actions+1] = cc.Animate:create(self.boxEffect:createEffect("lotteryNormalBoxOpen", 3, 0.5))
		actions[#actions+1] = cc.CallFunc:create(function() 
			self.boxEffect:setSpriteFrame("lotteryNormalBoxOpen/00003.png")
		end)
		self.boxEffect:runAction(cc.Sequence:create(actions))
	else
		--self.boxEffect:playActionData("lotterySpecialBoxOpen", 3, 0.5, 1)
		local actions = {}
		actions[#actions+1] = cc.Animate:create(self.boxEffect:createEffect("lotterySpecialBoxOpen", 3, 0.5))
		actions[#actions+1] = cc.CallFunc:create(function() 
			self.boxEffect:setSpriteFrame("lotterySpecialBoxOpen/00003.png")
		end)
		self.boxEffect:runAction(cc.Sequence:create(actions))
		--self.boxEffect:runAction(cc.Animate:create(self.boxEffect:createEffect("lotterySpecialBoxOpen", 3, 0.5)))
	end
    self:addChild(self.boxEffect)
    self.boxEffect:setAnchorPoint(cc.p(0.5, 0.5))
    self.boxEffect:setPosition(cc.p(display.cx, display.cy))

	self.boxEffect:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.4),
		cc.CallFunc:create(function() 
			local effect = Effects:create(false)
			--effect:setCleanCache()
		    if self.isNormal then
				effect:playActionData("lotteryNormalOutside", 7, 0.9, 1)
				effect:setPosition(cc.p(223, 210))
			else
				effect:playActionData("lotterySpecialOutside", 7, 0.9, 1)
				effect:setPosition(cc.p(223, 210))
			end
		    self.boxEffect:addChild(effect)
		    effect:setAnchorPoint(cc.p(0.5, 0.5))
		    addEffectWithMode(effect,1)
		    end),
		cc.DelayTime:create(0.3),
		cc.CallFunc:create(function() 
			local effect = Effects:create(false)
			--effect:setCleanCache()
		    if self.isNormal then
				effect:playActionData("lotteryNormalLight", 9, 1.2, -1)
			else
				effect:playActionData("lotterySpecialLight", 9, 1.2, -1)
			end
		    self.boxEffect:addChild(effect)
		    effect:setAnchorPoint(cc.p(0.5, 0.5))
		    effect:setPosition(cc.p(200, 230))
		    effect:setScale(1)
		    addEffectWithMode(effect,2)
		    end),
		cc.DelayTime:create(1.2),
		--cc.ScaleTo:create(0.3, 1.3),
		cc.Spawn:create(cc.ScaleTo:create(0.3, 0.9), cc.MoveBy:create(0.3, cc.p(0, 160))),
		cc.CallFunc:create(function() 
				self:createItemAction()
		    end)
		))
end

function LotteryShowLayer:createItemAction()
	log("LotteryShowLayer:createItemAction ----------------------")
	local function createAction(grid, num, pos, isLast)
		--local sprite = createSprite(self, path.."18.png", cc.p(self.boxSpr:getPositionX(), self.boxSpr:getPositionY()), cc.p(0.5, 0.5))
		--sprite:setOpacity(0.1)

		local Mprop = require("src/layers/bag/prop")
		local iconNode = Mprop.new({cb = "tips", grid = grid, num = num})
		self:addChild(iconNode)
		iconNode:setAnchorPoint(cc.p(0.5, 0.5))
        iconNode:setPosition(cc.p(self.boxEffect:getPositionX(), self.boxEffect:getPositionY()))

		iconNode:runAction(cc.Sequence:create(
				cc.Spawn:create(cc.MoveTo:create(0.3, pos)), --cc.FadeIn:create(0.3)),
				cc.CallFunc:create(function() 

				    local effect = Effects:create(false)
				    effect:playActionData("lotteryItem", 11, 1.5, 1)
				    self:addChild(effect)
				    effect:setAnchorPoint(cc.p(0.5, 0.5))
				    effect:setPosition(pos)
				    addEffectWithMode(effect,1)
				    effect:setScale(1.4)
				    performWithDelay(effect,function() removeFromParent(effect) effect = nil end,1.5)
				    if isLast then
				    	self.summonOneBtn:setVisible(true)
				    	self.summonTenBtn:setVisible(true)
				    	self.closeBtn:setVisible(true)
				    	self.oneIcon:setVisible(true)
				    	self.oneLabel:setVisible(true)
				    	self.tenIcon:setVisible(true)
				    	self.tenLabel:setVisible(true)
				    end
			    end)
		    ))
	end

	local basePos = cc.p(display.cx, display.cy-50)
	local addX = 100
	local addY = 60

	if self.number == 1 and #self.data == 1 then
		createAction(self.data[1].grid, self.data[1].num, basePos, true)
	elseif self.number == 10 and #self.data == 10 then
		local startX = basePos.x - addX * 2
		local startY = basePos.y + addY
		for i=1,10 do
			local x = startX + ((i - 1) % 5) * addX
			local y = startY - math.floor((i - 1) / 5) * (addY * 2)
			startTimerAction(self, i * 0.15, false, function() createAction(self.data[i].grid, self.data[i].num, cc.p(x, y), i==#self.data) end)
		end
	end
end

return LotteryShowLayer