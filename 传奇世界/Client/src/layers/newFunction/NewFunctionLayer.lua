local NewFunctionLayer = class("NewFunctionLayer", function() return cc.Layer:create() end)

require("src/layers/newFunction/NewFunctionDefine")

function NewFunctionLayer:ctor(param)
	local node = param.dataRecord.node
	local pos = param.dataRecord.pos
	local record = param.triggerDataRecord
	self.triggerNode = param.triggerNode
	self.record = record

	self.delayTriggerTime = 8

	local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.7))
	self:addChild(masking)
	self.masking = masking

	-- local bg = createSprite(self, "res/newFunction/4.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	-- self.bg = bg
	-- --特效
	-- local animate = Effects:create(false)
	-- animate:playActionData("newFunctionLight", 7, 1.5, 1)
	-- bg:addChild(animate)
	-- performWithDelay(animate,function() removeFromParent(animate) animate = nil end,1.5)
	-- animate:setPosition(cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2))

	local bg = createSprite(self, "res/achievement/get/bg.png", cc.p(display.cx, 125), cc.p(0.5, 0))
	self.bg = bg
	
	createSprite(bg, "res/achievement/get/1.png", cc.p(bg:getContentSize().width/2, 146), cc.p(0.5, 0.5))
	createSprite(bg, "res/achievement/get/2.png", cc.p(bg:getContentSize().width/2, 20), cc.p(0.5, 0.5))

	createSprite(bg, "res/achievement/get/6.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))
	createSprite(bg, "res/achievement/get/5.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-15), cc.p(0.5, 0))

	createSprite(bg, "res/newFunction/6.png", getCenterPos(bg), cc.p(0.5, 0.5))

	local effect = Effects:create(false)
	effect:setCleanCache()
    effect:playActionData("newfunction", 11, 1.3, 1)
    addEffectWithMode(effect, 1)
    bg:addChild(effect, 200)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(cc.p(bg:getContentSize().width/2, 125))

	--local topBg = createSprite(bg, "res/achievement/get/9.png", cc.p(bg:getContentSize().width/2, 120), cc.p(0.5, 0))
	--createSprite(topBg, "res/achievement/get/8.png", getCenterPos(topBg), cc.p(0.5, 0.5))
	local titleBg = createSprite(self, "res/achievement/get/7.png", cc.p(display.cx, 240), cc.p(0.5, 0), 100)
	self.titleBg = titleBg

	createLabel(bg, game.getStrByKey("achievement_touch_close"), cc.p(bg:getContentSize().width/2, 25), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_black)

	local createFlyParticle = function(startPos, endPos)
		-- dump(startPos)
  		-- dump(endPos)
		if startPos == nil or endPos == nil then
			return
		end

		local scale = math.random(2, 5)
		local particleSpr = createSprite(self, "res/particle/star.png", startPos, cc.p(0.5, 0.5), 10, scale/10)
		particleSpr:setColor(cc.c3b(255, 255, 0))
		local bezierContorl1
		local bezierContorl2

		local centerPos = cc.p((startPos.x + endPos.x)/2, (startPos.y + endPos.y)/2)
		-- dump(centerPos)
		--math.randomseed(os.time())
		local function getRandomPoint(a, b)
			if a < b then
				return math.random(a, b)
			else
				return math.random(b, a)
			end
		end

		bezierContorl1 = cc.p(getRandomPoint(startPos.x, centerPos.x), getRandomPoint(startPos.y, centerPos.y))
		bezierContorl2 = cc.p(getRandomPoint(centerPos.x, endPos.x), getRandomPoint(centerPos.y, endPos.y))

		local bezier = {
	        bezierContorl1,
	        bezierContorl2,
	        endPos,
    	}

    	local time = math.random(1, 6)
	    local bezierGo = cc.BezierTo:create(time/10, bezier)
	    local action = cc.Sequence:create(bezierGo, cc.CallFunc:create(function() if particleSpr then removeFromParent(particleSpr) particleSpr = nil end end))
	    particleSpr:runAction(action)
	end

	local createTriggerParticle = function(pos)
		local particle = cc.ParticleSystemQuad:create("res/particle/newFunctionOn.plist")--cc.ParticleRain:create()
		self.newFunctionTirggerParticle = particle
	    --tail:setPosVar(cc.p(display.width/2,0))
	    --tail:setEmissionRate(100)
	    self:addChild(particle)
	    particle:setPosition(pos)
	end

	--图标
	local iconFun = function(pos)
		if self.isIconTouched then
			return
		end
		AudioEnginer.playEffect("sounds/uiMusic/ui_fx.mp3",false)
		self.isIconTouched = true
		self.icon:stopAllActions()
		self.icon:setScale(1)
		
		removeFromParent(self.masking)
		removeFromParent(self.bg)
		removeFromParent(self.titleBg)
		--self.bg:runAction(cc.Sequence:create(cc.FadeOut:create(0.5)))
		--self.tip:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
		-- if self.tip then 
		-- 	removeFromParent(self.tip)
		-- 	self.tip = nil
		-- end

		-- if self.name then
		-- 	removeFromParent(self.name)
		-- 	self.name = nil
		-- end

		self.triggerNode:setAvailable(param.dataRecord, 25, false) 

		local endPos = pos
		if endPos.y < 50 then
			endPos.y = endPos.y + 163
		end
		--dump(endPos)
		createTriggerParticle(endPos)
		
		local startPos = cc.p(self.icon:getPosition())--self.icon:convertToWorldSpace(getCenterPos(self.icon))
		local repeatCreateParticle = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.02), 
		cc.CallFunc:create(function() createFlyParticle(startPos, endPos) end)))--function() log("123") end cc.CallFunc:create(createFlyParticle(startPos, pos) cc.MoveBy:create(1, cc.p(10, 10)))
		self.icon:runAction(repeatCreateParticle)	 

		self.icon:runAction(
			cc.Sequence:create(
				cc.FadeOut:create(1), 
			cc.CallFunc:create(function() 
				if repeatCreateParticle then
					self.icon:stopAction(repeatCreateParticle) 
					repeatCreateParticle = nil
				end
				self.icon:setPosition(endPos) 
				self.icon:setOpacity(255)
				self.newFunctionTirggerParticle:stopSystem() end),
			cc.ScaleTo:create(0.3, 2),
			cc.ScaleTo:create(0.2, 1),
			cc.DelayTime:create(0.75),
			cc.FadeOut:create(0.75),
			cc.CallFunc:create(function() self.icon:setPosition(pos) end),
			cc.CallFunc:create(function() self.triggerNode.triggerLayer = nil 
				self.triggerNode:setAvailable(param.dataRecord, 255) 
				if self.record.q_ID == NF_LOTTERY then
					--寻宝是登陆时设置的红点，这里做一个假的设置
					if TOPBTNMG then TOPBTNMG:showRedMG( "Lotter" , true ) end					
				-- elseif self.record.q_ID == NF_SIGN_IN then
					--签到打开会自己处理红点(已经换位置2106.6.10)
				elseif self.record.q_ID == NF_FB_SINGLE then
					_checkDragonSliayerRed()
				elseif self.record.q_ID == NF_FB_PROTECT then
					DATA_Battle:setRedData( "SHGZ" , true)
					DATA_Battle:setRedData( "DRFB" , true)
				elseif self.record.q_ID == NF_FB_TOWER then
					DATA_Battle:setRedData( "TTT" , true)
				end
				removeFromParent(self) end)))
	end

	local richText = require("src/RichText").new(titleBg, cc.p(titleBg:getContentSize().width/2, 6), cc.size(200, 20), cc.p(0.5, 0), 20, 20, MColor.black)
    --richText:addText(game.getStrByKey("new_function_active"))
    richText:addText(record.F2)
    richText:setAutoWidth()
    richText:format()
    self.name = richText
 	-- self.name = createLabel(bg, "["..record.F2.."]", cc.p(bg:getContentSize().width/2, 35), cc.p(0.5, 0), 20, true, nil, nil, MColor.yellow)
 	-- self.name:setOpacity(0)

	-- self.tip = createLabel(bg, record.q_desc, cc.p(bg:getContentSize().width/2, 10), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
	-- self.tip:setOpacity(0)

	self.icon = createTouchItem(self, iconOnPath..iconTab[record.q_ID], cc.p(display.cx, 318), function() iconFun(pos) end)--iconOnPath..iconTab[record.q_ID]
	--self.icon:setScale(0.1)
	--名称
	--local title = createSprite(self.icon, titleOnPath..iconTab[record.q_ID], cc.p(self.icon:getContentSize().width/2, 10), cc.p(0.5, 1), nil)

	-- local action = cc.Sequence:create(cc.ScaleTo:create(0.5, 2), cc.ScaleTo:create(0.2, 1.1), 
	-- 	cc.CallFunc:create(function() 
	-- 			--self.tip:runAction(cc.FadeIn:create(1)) 
	-- 			self.name:runAction(cc.FadeIn:create(1)) 
	-- 		end))
	-- self.icon:runAction(action)

	performWithDelay(self, function() iconFun(pos) end , self.delayTriggerTime)

	-- SwallowTouches(self)
	local  listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
	self.listenner = listenner
	listenner:registerScriptHandler(function(touch, event)
       			return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
	listenner:registerScriptHandler(function(touch, event)
       			iconFun(pos)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

    self:registerScriptHandler(function(event)
		if event == "enter" then
			G_SHOW_ORDER_DATA.showFunc = true
		elseif event == "exit" then
			G_SHOW_ORDER_DATA.showFunc = false
		end
	end)
end

function NewFunctionLayer:setAvailable(node)
end

return NewFunctionLayer