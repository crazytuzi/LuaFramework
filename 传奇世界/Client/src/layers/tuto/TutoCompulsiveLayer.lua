local TutoCompulsiveLayer = class("TutoCompulsiveLayer", function() return cc.Layer:create() end )

require("src/layers/tuto/TutoFunction")

function TutoCompulsiveLayer:ctor(showNodeList, touchNodeList, tutoInfo, isHalfCompulsive)
	log("TutoCompulsiveLayer:ctor")
	local tutoStepInfo = tutoInfo.q_controls[tutoInfo.q_step]
	self.tutoStepInfo = tutoStepInfo
	self.tutoInfo = tutoInfo

	local function addOutBtn(pos)	
		if self.tutoInfo.noPass == true then
			return
		end	

		startTimerAction(self, 3, false, function()
		local outBtn = createMenuItem(self, "res/component/button/4.png", pos, function() 
			self.tutoInfo.q_step = #self.tutoInfo.q_controls
			if not self.tutoInfo.notsave then
	            tutoSetState(self.tutoInfo, TUTO_STATE_FINISH,1)
	        else
	        	self.tutoInfo.q_step = 1
	        	self.tutoInfo.q_state = TUTO_STATE_HIDE
	        end  
			G_TUTO_NODE.tutoLayer = nil 
			removeFromParent(self) 
			end)
		createLabel(outBtn, game.getStrByKey("tuto_pass"), cc.p(outBtn:getContentSize().width/2, outBtn:getContentSize().height/2), cc.p(0.5, 0.5), 22, true)
		outBtn:setOpacity(0)
		outBtn:runAction(cc.FadeIn:create(0.3))
		end)
	end


	local isNoTouchNode = false
	if tutoInfo.q_controls[tutoInfo.q_step].touchNode ~= nil then
		isNoTouchNode = false
		local touchPos
		--触摸node的信息处理
		log("tutoInfo.q_id = "..tutoInfo.q_id)
		log("tutoInfo.q_controls[tutoInfo.q_step].touchNode = "..tutoInfo.q_controls[tutoInfo.q_step].touchNode)
		
		local node = tutoGetNode(touchNodeList, tutoInfo)
		node = tolua.cast(node,"cc.Node")
		if node then
			local pos = cc.p(node:getPosition())
			log("pos.x =".. pos.x)
			log("pos.y =".. pos.y)
			log("display.cy =".. display.cy)
			dump(node:getContentSize())
			dump(node:getPosition())
			touchPos = node:convertToWorldSpace(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))

			local pos22 = node:getParent():convertToWorldSpace(cc.p(node:getPosition()))
			-- dump(pos22)
			-- dump(touchPos)

			-- dump(self.tutoStepInfo)
			-- if self.tutoStepInfo.touchOffset then
			-- 	touchPos = cc.p(touchPos.x + self.tutoStepInfo.touchOffset.x, touchPos.y + self.tutoStepInfo.touchOffset.y)
			-- end

			if tutoStepInfo.outBtnPos then
				addOutBtn(tutoStepInfo.outBtnPos)
			else
				if touchPos.y < display.cy then
					addOutBtn(cc.p(display.cx, display.height - 70))
				else
					addOutBtn(cc.p(display.cx, 70))
				end
			end
			

		else
			print("not found node!!!")
			if G_TUTO_NODE then
				G_TUTO_NODE.tutoLayer = nil
			end
			-- if tutoInfo.q_step == 1 then
			-- 	tutoInfo.q_state = TUTO_STATE_OFF
			-- end
			-- log(tutoInfo.q_id .." set TUTO_STATE_FINISH")
	  --       tutoSetState(tutoInfo, TUTO_STATE_FINISH)
	        
			removeFromParent(self)
			return
		end
		log("touchPos.x =".. touchPos.x)
		log("touchPos.y =".. touchPos.y)

		if touchPos.y < 0 then
			touchPos.y = touchPos.y + 170 
		end
		
		local  listenner = cc.EventListenerTouchOneByOne:create()
		if isHalfCompulsive ~= true then
			listenner:setSwallowTouches(true)
		end
	    listenner:registerScriptHandler(function(touch, event)
	    		local tutoLocation = touch:getLocation()
	    		--dump(tutoLocation)
	    		local node = tutoGetNode(touchNodeList, tutoInfo)
	    		node = tolua.cast(node,"cc.Node")
	    		if node == nil then
	    			log("error!!!tuto node is nil!!!")
	    			return true
	    		end
	            location = node:getParent():convertTouchToNodeSpace(touch)
	            log("location.x =".. location.x)
				log("location.y =".. location.y)

	            if cc.rectContainsPoint(node:getBoundingBox(), cc.p(location.x, location.y)) 
	            	-- and self.stencil:getNumberOfRunningActions() == 0 
	            	-- and cc.rectContainsPoint(self.stencil:getBoundingBox(), cc.p(tutoLocation.x, tutoLocation.y)) 
	            	then
	            	if tutoStepInfo.callFunc then
	            		tutoStepInfo.callFunc()
	            	end

	            	if tutoStepInfo.touchNode == TOUCH_MAIN_HEAD then
	            		G_TUTO_NODE:openMenuDelay(0.2)
	            	end

	            	if tutoStepInfo.recordFinish and tutoStepInfo.recordFinish == true then
	            		tutoSetRecord(tutoInfo)
	            	end

	            	tutoInfo.q_step = tutoInfo.q_step + 1
	            	log("tutoInfo.q_step =".. tutoInfo.q_step)
	            	if tutoInfo.q_step > #tutoInfo.q_controls then
	            		log(tutoInfo.q_id .." set TUTO_STATE_FINISH")
	            		if not tutoInfo.notsave then
	            			tutoSetState(tutoInfo, TUTO_STATE_FINISH)
	            		else 
	            			tutoInfo.q_step = 1
	        				self.tutoInfo.q_state = TUTO_STATE_HIDE
	            		end    		
	            	end
	            	if self.updateAction then
	            		self:stopAction(self.updateAction)
	            		self.updateAction = nil
	            	end
	            	removeFromParent(self)

	            	if G_TUTO_NODE then 
		            	G_TUTO_NODE.tutoLayer = nil
		            	log("remove tuto layer")
		            	if tutoStepInfo.setShowNode then
		            		G_TUTO_NODE:setShowNodeEx(tutoStepInfo.setShowNode)
		            	else
		            		if tutoInfo.q_controls[tutoInfo.q_step] and tutoInfo.q_controls[tutoInfo.q_step].delayCheck then
		            			G_TUTO_NODE:checkDelay(tutoInfo.q_controls[tutoInfo.q_step].delayCheck)
		            		else
			            		--有可能同一界面有多步引导
			            		G_TUTO_NODE:check()
			            	end
			            	print("tutoInfo.q_step==============",tutoInfo.q_step)
		            	end
		            end
	           
	            	log("touch false")
	       			return false
	       		else
	       			print("touch true")
	       			self:addEffect(tutoInfo,touchPos,touchNodeList)	
	       			return true
	       		end
	        end,cc.Handler.EVENT_TOUCH_BEGAN )
	    local eventDispatcher = self:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)

	    -- 裁剪固定区域
	    --添加聚焦特效
	    -- self:addEffect(tutoInfo,touchPos,touchNodeList)
	else
		isNoTouchNode = true

		addOutBtn(cc.p(display.cx, display.height - 70))

		-- local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
		-- self:addChild(masking)

		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(true)	
	    listenner:registerScriptHandler(function(touch, event)
	    		return true
	        end,cc.Handler.EVENT_TOUCH_BEGAN )
	    listenner:registerScriptHandler(function(touch, event)
	    		if tutoStepInfo.callFunc then
            		tutoStepInfo.callFunc()
            	end

            	tutoInfo.q_step = tutoInfo.q_step + 1
            	log("tutoInfo.q_step =".. tutoInfo.q_step)
            	if tutoInfo.q_step > #tutoInfo.q_controls then
            		log(tutoInfo.q_id .." set TUTO_STATE_FINISH")
            		if not tutoInfo.notsave then
	            		tutoSetState(tutoInfo, TUTO_STATE_FINISH)
	            	else
	            		tutoInfo.q_step = 1
	        			self.tutoInfo.q_state = TUTO_STATE_HIDE
	            	end  
            	end
            	
            	removeFromParent(self)

            	if G_TUTO_NODE then 
	            	G_TUTO_NODE.tutoLayer = nil
	            	log("remove tuto layer")
	            	if tutoStepInfo.setShowNode then
	            		G_TUTO_NODE:setShowNodeEx(tutoStepInfo.setShowNode)
	            	else
	            		if tutoInfo.q_controls[tutoInfo.q_step] and tutoInfo.q_controls[tutoInfo.q_step].delayCheck then
	            			G_TUTO_NODE:checkDelay(tutoInfo.q_controls[tutoInfo.q_step].delayCheck)
	            		else
		            		--有可能同一界面有多步引导
		            		G_TUTO_NODE:check()
		            	end
	            	end
	            end
	        end,cc.Handler.EVENT_TOUCH_ENDED )
		if not tutoInfo.q_controls[tutoInfo.q_step].noTouch then
            local eventDispatcher = self:getEventDispatcher()
	    	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
        end

	end

    --延迟添加tip
    local delayAddTip = function()
    	--添加提示信息
    	tutoAddTip(self, touchNodeList, tutoInfo, isNoTouchNode)
	end
	local delay = tutoInfo.q_controls[tutoInfo.q_step].delay
	log("delay = "..tostring(delay))
    if delay then
    	log("delay scheduler")
    	performWithDelay(self, delayAddTip, delay)
    else
    	--添加提示信息
    	tutoAddTip(self, touchNodeList, tutoInfo, isNoTouchNode)
    end

    --超时保护
 --    if tutoInfo.delayRemove ~= false then
	--     performWithDelay(self, function() 
	--     	tutoSetState(tutoInfo, TUTO_STATE_FINISH) 
	--     	if G_TUTO_NODE then
	--     		G_TUTO_NODE.tutoLayer = self 
	--     	end
	--     	removeFromParent(self)
	--     	end, 20)
	-- end

    if G_TUTO_NODE then
    	G_TUTO_NODE.tutoLayer = self
    end

    if tutoStepInfo.layerFunc then
		tutoStepInfo.layerFunc(tutoStepInfo.funcConditions,tutoStepInfo)
	end

    if self.tutoStepInfo.sound then
    	AudioEnginer.playLiuEffect("sounds/liuVoice/"..self.tutoStepInfo.sound..".mp3", false)
    end

    self:registerScriptHandler(function(event)
		if event == "enter" then
			G_SHOW_ORDER_DATA.showTuto = true
		elseif event == "exit" then
			G_SHOW_ORDER_DATA.showTuto = false
		end
	end)

	if not tutoInfo.closeChat then
		if getRunScene():getChildByName("npcChat") then
			getRunScene():removeChildByName("npcChat")
		end
	end
	if tutoInfo.time then
		startTimerAction(self, tutoInfo.time, false, function()
			removeFromParent(self)
	        if G_TUTO_NODE then 
		     	G_TUTO_NODE.tutoLayer = nil
		    end
		end)
	end
end
function TutoCompulsiveLayer:addEffect(tutoInfo,touchPos,touchNodeList)
	if self.clipNode then return end
	local node = tutoGetNode(touchNodeList, tutoInfo)
	node = tolua.cast(node,"cc.Node")	
	if not node then return end
	local pos = node:convertToWorldSpace(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
	--添加遮罩
	local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 130))
	-- clipNode:addChild(masking)
	--添加镂空
	local stencil = cc.Sprite:create("res/tuto/images/3.png")--"res/tuto/images/8.png"
	stencil:setAnchorPoint(cc.p(0.5, 0.5))
	stencil:setScale(2)
    stencil:setPosition(pos)

    
    local clipNode = cc.ClippingNode:create(stencil)
    self.clipNode = clipNode
	self:addChild(self.clipNode)
	clipNode:addChild(masking)
	clipNode:setPosition(cc.p(0, 0))

    -- clipNode:setStencil(stencil)
   	clipNode:setInverted(true)
    clipNode:setAlphaThreshold(0)


	local action =cc.Sequence:create( cc.Spawn:create(cc.ScaleTo:create(0.4, 0.1),cc.MoveTo:create(0.4, pos)),cc.CallFunc:create( function ( ... )
    	self.clipNode:removeFromParent()
    	self.clipNode = nil
    	print("进回调")
    end ))
    stencil:runAction(action)
    print("222222")

end
-- function TutoCompulsiveLayer:getNode(touchNodeList, tutoInfo)
-- 	if tutoInfo.q_controls[tutoInfo.q_step] and tutoInfo.q_controls[tutoInfo.q_step].touchNode then
-- 		local touchNodeTag = tutoInfo.q_controls[tutoInfo.q_step].touchNode
-- 		if tutoIsSpecialNode(touchNodeTag) then
-- 			if touchNodeTag == TOUCH_ROLE_EQUIPMENT then
-- 				local MPackManager = require "src/layers/bag/PackManager"
-- 				local MPackStruct = require "src/layers/bag/PackStruct"
-- 				local dress = MPackManager:getPack(MPackStruct.eDress)
-- 				local list = dress:categoryList(MPackStruct.eAll)
-- 				local gird = list[1]
-- 				local girdId = MPackStruct.girdIdFromGird(gird)
-- 				return touchNodeList[touchNodeTag].mDressSlot[girdId]
-- 			elseif touchNodeTag == TOUCH_ROLE_WEAPON then
-- 				local MPackManager = require "src/layers/bag/PackManager"
-- 				local MPackStruct = require "src/layers/bag/PackStruct"
-- 				local dress = MPackManager:getPack(MPackStruct.eDress)
-- 				local list = dress:categoryList(MPackStruct.eAll)
-- 				local gird = list[1]
-- 				local girdId = MPackStruct.girdIdFromGird(gird)
-- 				return touchNodeList[touchNodeTag].mDressSlot[girdId]
-- 			end
-- 		else
-- 			return touchNodeList[touchNodeTag]
-- 		end
-- 	end

-- 	return nil
-- end

return TutoCompulsiveLayer