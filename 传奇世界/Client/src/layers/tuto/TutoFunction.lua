require("src/layers/tuto/TutoDefine")

local resPath = "res/tuto/images/"

function tutoAddTip(layer, touchNodeList, tutoInfo, noTouchNode)
	--log("add Tip nodeTag = "..tutoInfo.q_controls[tutoInfo.q_step].touchNode)
	local tutoStepInfo = tutoInfo.q_controls[tutoInfo.q_step]
	local node = tutoGetNode(touchNodeList, tutoInfo)
	
	-- if checkNode(node) == nil then
	-- 	return
	-- end

	if node or noTouchNode then
		local nodePos
		if node then
			nodePos = node:convertToWorldSpace(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
		else
			nodePos = cc.p(display.cx, display.cy - 150)
		end
		
		if tutoStepInfo.effect == "button" then
			local additionalScaleX = 1
		    local additionalScaleY = 1
		    if tutoStepInfo.effectScale then
		    	additionalScaleX = tutoStepInfo.effectScale.x
		    	additionalScaleY = tutoStepInfo.effectScale.y
		    end
		    --dump(tutoStepInfo.effectScale)
			local animate = tutoAddAnimation(layer, nodePos, TUTO_ANIMATE_TYPE_BUTTON)
			animate:setContentSize(cc.size(220, 65))
			--dump(animate:getContentSize())
			scaleToTarget(animate, node, additionalScaleX, additionalScaleY)
		end
		if tutoStepInfo.touchNode then
			if tutoStepInfo.touchNode < 2006 and tutoStepInfo.touchNode > 2000 then
				local animate = Effects:create(false)
				animate:playActionData("newFunctionExSmall", 19, 1.3, -1)
				layer:addChild(animate)
				animate:setAnchorPoint(cc.p(0.5, 0.5))
				animate:setPosition(nodePos)
				-- dump(animate:getContentSize())
				animate:setScale(1.4)
					-- dump(animate:getContentSize())
			end
		end

		
		local dir
		if nodePos.x > display.width/2 then
			dir = 1
		else
			dir = 2
		end

		if tutoStepInfo.tip then
			local richTextBgHeight = 77
			local fadeInTime = 0.5

			local richText = require("src/RichText").new(nil, cc.p(0, 0), cc.size(220, 30), cc.p(0.5, 0.5), 30, 18, MColor.white)
		    richText:addText(tutoStepInfo.tip)
		    richText:format()
		    dump(richText:getContentSize())

			local richTextBg
			local posx = display.width/2
			local posy = display.height/2 - 70
		    --根据文本大小自动扩展背景框
		    if richText:getContentSize().height < (richTextBgHeight-16) then
		    	richTextBg = createSprite(layer, "res/tuto/images/smallBg.png", cc.p(posx, posy), cc.p(0.5, 0.5))
		    else
		    	richTextBg = createSprite(layer, "res/tuto/images/bigBg.png", cc.p(posx, posy), cc.p(0.5, 0.5))
		    end
		    if dir == 1 then
		    	richTextBg:setScaleX(-1)
		    	richText:setPosition(cc.p(posx+ 10,posy))
		    else
		    	richText:setPosition(cc.p(posx - 10,posy))
		    end   
		    layer:addChild(richText)

		    

			-- if tutoStepInfo.posOffset then
			-- 	richTextBg:setPosition(cc.p(richTextBg:getPositionX() + tutoStepInfo.posOffset.x, richTextBg:getPositionY() + tutoStepInfo.posOffset.y))
			-- end
			local showGirl = addBeautyTuto(richTextBg,dir)
			--showGirl:setFlippedX(true)
			showGirl:setOpacity(0)
			-- tutoSetAdaptionPosition(richTextBg)	

		    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
		    	cc.Spawn:create(cc.MoveBy:create(fadeInTime, cc.p(0, -50)), cc.FadeIn:create(fadeInTime)))
		    richTextBg:runAction(action)

		    local action = cc.Sequence:create(cc.CallFunc:create(function() richText:setOpacity(0) richText:setPositionY(richText:getPositionY()+50) end), --
		    	cc.Spawn:create(cc.MoveBy:create(fadeInTime, cc.p(0, -50)), cc.FadeIn:create(fadeInTime)))
		    richText:runAction(action)

		    showGirl:runAction(cc.FadeIn:create(fadeInTime))

		    if noTouchNode then
		    	local touchTip = createLabel(richTextBg, game.getStrByKey("tuto_next"), cc.p(0, -36), cc.p(0, 0), 24, true, nil, nil, MColor.white)
				tutoAddAnimation(richTextBg, cc.p(richTextBg:getContentSize().width - 15, -20), TUTO_ANIMATE_TYPE_FINGER)
			end
		end
		

		if tutoStepInfo.touchOffset then
			nodePos = cc.p(nodePos.x + tutoStepInfo.touchOffset.x, nodePos.y + tutoStepInfo.touchOffset.y)
		end

		tutoAddHalfCompulsiveAnimation(layer, nodePos, touchNodeList, tutoInfo)
	end
end

function addBeautyTuto(bg,dir)
	local showGirl = createSprite(bg, resPath.."14.png", cc.p(bg:getContentSize().width-70, -155), cc.p(0, 0), nil, 1)
	-- showGirl:setScaleX()
	return showGirl
end

-- function tutoAddTipEx(node, text, posOffset, tag, zOrder, delayDestroy)
-- 	local layer = cc.Layer:create()
-- 	if zOrder then
-- 		G_MAINSCENE:addChild(layer, zOrder)
-- 	else
-- 		G_MAINSCENE:addChild(layer, 99)
-- 	end
-- 	layer:setPosition(cc.p(0, 0))

-- 	local nodePos = cc.p(display.cx, display.cy-150)
-- 	if node then
-- 		nodePos = node:convertToWorldSpace(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
-- 		dump(nodePos)
-- 	end
-- 	if nodePos.y > display.height/2 then
-- 		if text then
-- 			local richTextBg = createScale9Sprite(layer, "res/common/scalable/bg3.png", cc.p(nodePos.x, nodePos.y - 150), cc.size(260, 100), cc.p(0.5, 0.5))
-- 			createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
-- 			if posOffset then
-- 				richTextBg:setPosition(cc.p(richTextBg:getPositionX() + posOffset.x, richTextBg:getPositionY() + posOffset.y))
-- 			end
-- 			addBeautyTuto(richTextBg)
-- 			tutoSetAdaptionPosition(richTextBg)	
-- 			local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height/2), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 24, MColor.white)
-- 		    richText:addText(text)
-- 		    richText:format()
-- 		    richTextBg:setOpacity(0)
-- 		    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
-- 		    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, -50)), cc.FadeIn:create(0.5)))
-- 		    richTextBg:runAction(action)
-- 		end
-- 	else
-- 		if text then
-- 			local richTextBg = createScale9Sprite(layer, "res/common/scalable/bg3.png", cc.p(nodePos.x, nodePos.y + 150), cc.size(260, 100), cc.p(0.5, 0.5))
-- 			if posOffset then
-- 				richTextBg:setPosition(cc.p(richTextBg:getPositionX() + posOffset.x, richTextBg:getPositionY() + posOffset.y))
-- 			end
-- 			addBeautyTuto(richTextBg)
-- 			tutoSetAdaptionPosition(richTextBg)	
-- 			local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height/2), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 24, MColor.white)
-- 		    richText:addText(text)
-- 		    richText:format()
-- 		    richTextBg:setOpacity(0) 
-- 		    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setPositionY(richTextBg:getPositionY()-50) end), --
-- 		    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 50)), cc.FadeIn:create(0.5)))
-- 		    richTextBg:runAction(action)
-- 		end
-- 	end

-- 	local listenner = cc.EventListenerTouchOneByOne:create()
-- 	listenner:registerScriptHandler(function(touch, event) 
-- 		return true 
-- 	end, cc.Handler.EVENT_TOUCH_BEGAN)
--     listenner:registerScriptHandler(function(touch, event)
--     		if tag then
--     			node = G_TUTO_NODE.touchNodeList[tag]
--     		end
    		
--     		node = tolua.cast(node, "cc.Node")
--     		if node then
--     			--log("touch node")
--     			--dump(node)
--     			--dump(G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE])
-- 	            local location = node:getParent():convertTouchToNodeSpace(touch)
-- 	            --log("location.x =".. location.x)
-- 				--log("location.y =".. location.y)
-- 	            if cc.rectContainsPoint(node:getBoundingBox(), cc.p(location.x, location.y))then
-- 	            	if G_TUTO_NODE.touchNodeList and G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] and node == G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] then
-- 	            		if G_MAINSCENE then
-- 	            			G_MAINSCENE:initHangUpCheck()
-- 	            		end
-- 	            	end

-- 	            	if layer then 
-- 	            		removeFromParent(layer)
-- 		            	layer = nil
-- 		            end
-- 	            end
-- 	        end
--         end,cc.Handler.EVENT_TOUCH_ENDED)
--     local eventDispatcher = layer:getEventDispatcher()
--     eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)

--     if delayDestroy then
--     	startTimerAction(layer, delayDestroy, false, function() removeFromParent(layer) layer=nil end)
--     end

--     tutoAddAnimation(layer, nodePos, TUTO_ANIMATE_TYPE_FINGER)
-- end

function tutoAddTipOnNode(node, text, posOffset, tag, zOrder, delayDestroy, checkFunc)
	if not node then
		return
	end
	if node:getChildByTag(150) then
		return
	end

	local layer = cc.Layer:create()
	if zOrder then
		node:addChild(layer, zOrder)
	else
		node:addChild(layer, 99)
	end
	layer:setPosition(cc.p(node:getContentSize().width/2, node:getContentSize().height/2))
	layer:setTag(150)

	local nodePos = cc.p(0, 0)

	local function removeLayerFunc()
		if G_TUTO_NODE.touchNodeList and G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] and node == G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] then
    	if G_MAINSCENE then
    			G_MAINSCENE:initHangUpCheck()
    		end
    	end

    	if layer then 
    		removeFromParent(layer)
        	layer = nil
        end
	end

	local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:registerScriptHandler(function(touch, event) 
		return true 
	end, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
    		if not G_TUTO_NODE then return end
    		if tag then
    			node = G_TUTO_NODE.touchNodeList[tag]
    		end
    		
    		node = tolua.cast(node, "cc.Node")
    		if node then
    			--log("touch node")
    			--dump(node)
    			--dump(G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE])
	            location = node:getParent():convertTouchToNodeSpace(touch)
	            --print("location.x =".. location.x)
				--print("location.y =".. location.y)
	            --if cc.rectContainsPoint(node:getBoundingBox(), cc.p(location.x, location.y))then
	            	removeLayerFunc()
	            --end
	        end
        end,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)

    if delayDestroy then
    	startTimerAction(layer, delayDestroy, false, function() removeFromParent(layer) layer = nil end)
    end

    if checkFunc then
    	startTimerAction(layer, 0.5, true, function()
    		--dump(checkFunc())
    		if checkFunc and checkFunc() then
    			removeLayerFunc()
    		end
    	 end)
    end

    tutoAddAnimation(layer, nodePos, TUTO_ANIMATE_TYPE_FINGER)
end

function tutoAddHalfCompulsiveAnimation(layer, pos, touchNodeList, tutoInfo)
	local node = touchNodeList[tutoInfo.q_controls[tutoInfo.q_step].touchNode]
	if node then
		--tutoAddAnimation(layer, pos, TUTO_ANIMATE_TYPE_HALO)
		tutoAddAnimation(layer, pos, TUTO_ANIMATE_TYPE_FINGER)
	end
end

function tutoAddAnimation(parent, pos, type, scale)
	local animate = Effects:create(false)

	local swith = {
		[TUTO_ANIMATE_TYPE_FINGER] = function()
			animate:playActionData("tutoFinger", 14, 1.2, -1)
		end,

		[TUTO_ANIMATE_TYPE_HALO] = function()
			animate:playActionData("tutoHalo", 6, 1.5, -1)
		end,

		[TUTO_ANIMATE_TYPE_BUTTON] = function()
			animate:playActionData("tutoButton", 12, 1.8, -1)
		end,

		[TUTO_ANIMATE_TYPE_MISSION] = function()
			--animate:playActionData("tutoMission", 12, 3, -1)
		end,
	}

	if swith[type] then
		swith[type]()
	end

	if parent then
		parent:addChild(animate)
	end

	animate:setPosition(pos)

	-- if scale then
	-- 	animate:setScale(scale.x, scale.u)
	-- end

	return animate
end

function tutoIsSpecialNode(touchNodeTag)
	for k,v in pairs(TOUCH_SPECIAL) do
		if touchNodeTag == v then
			return true
		end
	end

	return false
end

function tutoGetNode(touchNodeList, tutoInfo)
	--dump(tutoInfo)
	-- print("touchNodeTag=============",tutoInfo.q_controls[tutoInfo.q_step].touchNode)
	if tutoInfo.q_controls[tutoInfo.q_step] and tutoInfo.q_controls[tutoInfo.q_step].touchNode then
		local touchNodeTag = tutoInfo.q_controls[tutoInfo.q_step].touchNode
		if tutoIsSpecialNode(touchNodeTag) then
			if touchNodeTag == TOUCH_ROLE_EQUIPMENT then
				local MPackManager = require "src/layers/bag/PackManager"
				local MPackStruct = require "src/layers/bag/PackStruct"
				local dress = MPackManager:getPack(MPackStruct.eDress)
				local list = dress:categoryList(MPackStruct.eAll)
				local gird = list[1]
				local girdId = MPackStruct.girdIdFromGird(gird)
				if touchNodeList[touchNodeTag] and touchNodeList[touchNodeTag].mDressSlot then
					return touchNodeList[touchNodeTag].mDressSlot[girdId]
				else
					return nil
				end
			elseif touchNodeTag == TOUCH_ROLE_WEAPON then
				local MPackManager = require "src/layers/bag/PackManager"
				local MPackStruct = require "src/layers/bag/PackStruct"
				local dressPack = MPackManager:getPack(MPackStruct.eDress)
				local gird = dressPack:getGirdByGirdId(MPackStruct.eWeapon)
				local girdId = MPackStruct.girdIdFromGird(gird)
				if touchNodeList[touchNodeTag] and touchNodeList[touchNodeTag].mDressSlot then
					return touchNodeList[touchNodeTag].mDressSlot[girdId]
				else
					return nil
				end
			elseif touchNodeTag == TOUCH_ROLE_SHOES then
				local MPackManager = require "src/layers/bag/PackManager"
				local MPackStruct = require "src/layers/bag/PackStruct"
				local dressPack = MPackManager:getPack(MPackStruct.eDress)
				local gird = dressPack:getGirdByGirdId(MPackStruct.eShoe)
				local girdId = MPackStruct.girdIdFromGird(gird)
				if touchNodeList[touchNodeTag] and touchNodeList[touchNodeTag].mDressSlot then
					return touchNodeList[touchNodeTag].mDressSlot[girdId]
				else
					return nil
				end
			elseif touchNodeTag == TOUCH_ROLE_MEDAL then
				local MPackManager = require "src/layers/bag/PackManager"
				local MPackStruct = require "src/layers/bag/PackStruct"
				local dressPack = MPackManager:getPack(MPackStruct.eDress)
				local gird = dressPack:getGirdByGirdId(MPackStruct.eMedal)
				local girdId = MPackStruct.girdIdFromGird(gird)
				if touchNodeList[touchNodeTag] and touchNodeList[touchNodeTag].mDressSlot then
					return touchNodeList[touchNodeTag].mDressSlot[girdId]
				else
					return nil
				end
			elseif touchNodeTag == TOUCH_BAG_HPMP_STONE 
				or touchNodeTag == TOUCH_BAG_AGAINST_REEL 
				or touchNodeTag == TOUCH_FURNACE_ITEM_1 
				or touchNodeTag == TOUCH_FURNACE_ITEM_2 
				or touchNodeTag == TOUCH_FURNACE_ITEM_3 
				or touchNodeTag == TOUCH_FURNACE_ITEM_4 
				or touchNodeTag == TOUCH_FURNACE_ITEM_5 
				or touchNodeTag == TOUCH_FURNACE_ITEM_6 
				or touchNodeTag == TOUCH_BAG_HOE 
				or touchNodeTag == TOUCH_EQUIPMENT_TRANSMIT_USE1 
				or touchNodeTag == TOUCH_EQUIPMENT_TRANSMIT_USE2 
				or touchNodeTag == TOUCH_EQUIPMENT_TRANSMIT_USE3 
				or touchNodeTag == TOUCH_BAG_USE1 
				or touchNodeTag == TOUCH_BAG_USE2 
				or touchNodeTag == TOUCH_BAG_USE3
				or touchNodeTag == TOUCH_BAG_WASH_1
				or touchNodeTag == TOUCH_BAG_WASH_2
				or touchNodeTag == TOUCH_BAG_WASH_3
				or touchNodeTag == TOUCH_BAG_LOCK 
				or touchNodeTag == TOUCH_BAG_CLOTHES
				or touchNodeTag == TOUCH_EPUIP_SELECT_1
				or touchNodeTag == TOUCH_BAG_BOOK
				or touchNodeTag == TOUCH_BAG_GIFT then
				return touchNodeList[touchNodeTag]()
			end
		else
			return touchNodeList[touchNodeTag]
		end
	else
		return nil
	end
end

function tutoGetShowNode(showNodeList, tutoInfo)
	if tutoInfo.q_controls[tutoInfo.q_step] and tutoInfo.q_controls[tutoInfo.q_step].showNode then
		local showNodeTag = tutoInfo.q_controls[tutoInfo.q_step].showNode
		return showNodeList[showNodeTag]
	end
end

--自适应显示区域算法
function tutoSetAdaptionPosition(node)
	local paddingHorizontal = 10
	local verticalMove = 5
	local parentNode = node:getParent()
  	local worldPos = parentNode:convertToWorldSpace(cc.p(node:getPosition()))
  	local retPos = worldPos
  	local size = node:getContentSize()
  	--local containerSize = cc.size(display.width, display.height)

	log("test x="..worldPos.x)
	log("test y="..worldPos.y)

	if worldPos.y + size.height/2 > display.height then
		log("test1")
		retPos.y = display.height - size.height/2
	elseif worldPos.y - size.height/2 < 0 then
		log("test2")
		retPos.y = size.height/2
	end

	if worldPos.x - size.width/2 < 0 then
		log("test3")
		retPos.x = size.width/2
	elseif worldPos.x + (size.width/2 + 130) > display.width then
		log("test4")
		retPos.x = display.width - (size.width/2 + 130)
	end
	worldPos =  parentNode:convertToNodeSpace(retPos)
	node:setPosition(worldPos)
	log("worldPos x="..worldPos.x)
	log("worldPos y="..worldPos.y)
	return worldPos
end

--自适应显示区域算法
-- function tutoGetTipPosition(parentNode, pos, tipSize)
-- 	local paddingHorizontal = 10
-- 	local verticalMove = 5
--   	local worldPos = parentNode:convertToWorldSpace(pos)
-- 	local retPos = pos
-- 	log("test x="..worldPos.x)
-- 	log("test y="..worldPos.y)
-- 	if worldPos.y > display.height/2 then
-- 		log("test1")
-- 		retPos.y = retPos.y - verticalMove
-- 	else 
-- 		log("test2")
-- 		retPos.y = retPos.y + verticalMove
-- 	end

-- 	if worldPos.x - tipSize.width/2 < paddingHorizontal then
-- 		log("test3")
-- 		retPos.x = paddingHorizontal + tipSize.width/2
-- 	elseif worldPos.x + tipSize.width/2 > display.width - paddingHorizontal then
-- 		log("test4")
-- 		retPos.x = display.width - paddingHorizontal - tipSize.width/2
-- 	end
-- 	retPos.x =  parentNode:convertToNodeSpace(retPos).x
-- 	log("retPos x="..retPos.x)
-- 	log("retPos y="..retPos.y)
-- 	return retPos
-- end

function tutoSetState(tutoInfo, state,finshType)
	log("tutoSetState")
	log("q_id = "..tutoInfo.q_id)
	log("state = "..state)
	dump(TUTO_STATE_FINISH)
	tutoInfo.q_state = state
	if tutoInfo.q_step then
		tutoInfo.q_step = 1
	end

	if state == TUTO_STATE_FINISH then
		-- if tutoInfo.q_conditions.noRecord == true then
		-- 	setLocalRecord("tuto"..tutoInfo.q_id, true)
		-- end
		log("send finish q_id = "..tutoInfo.q_id)
		--g_msgHandlerInst:sendNetDataByFmtExEx(GAMECONFIG_CS_CHANGE_GUARD, "ii", G_ROLE_MAIN.obj_id, tutoInfo.q_id)
		local t = {}
		t.gameGuardID = tutoInfo.q_id
		t.state = finshType or 0
		dump(t)
		g_msgHandlerInst:sendNetDataByTableExEx(GAMECONFIG_CS_CHANGE_GUARD, "GameConfigChangGuardProtocol", t)

		if G_MAINSCENE and G_MAINSCENE.addHangUpCheck then
			--log("wangning 11111111111111111111111111111111111111111111111")
			G_MAINSCENE:addHangUpCheck(true)
		end
	end
end

function tutoSetRecord(tutoInfo)
	--g_msgHandlerInst:sendNetDataByFmtExEx(GAMECONFIG_CS_CHANGE_GUARD, "ii", G_ROLE_MAIN.obj_id, tutoInfo.q_id)
	local t = {}
	t.gameGuardID = tutoInfo.q_id
	g_msgHandlerInst:sendNetDataByTableExEx(GAMECONFIG_CS_CHANGE_GUARD, "GameConfigChangGuardProtocol", t)
end

function tutoaddRidingTutoAction()
	log("addRidingTutoAction")

	if G_MAINSCENE then
		local leftArrow = createSprite(G_MAINSCENE, "res/tuto/images/2.png",  cc.p(display.cx + display.width/4, display.cy+70 - 50), cc.p(0.5, 0.5))
		-- leftArrow:setRotation(-90)

		--手指动作
		local finger = createSprite(G_MAINSCENE, "res/tuto/images/1.png", cc.p(display.cx + display.width/4, display.cy - 100 -50), cc.p(0, 0), 400)
		finger:setOpacity(0)
		--local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.25), cc.MoveBy:create(1.5, cc.p(0, 200)), cc.FadeOut:create(0.25), cc.CallFunc:create(function() finger:setPosition(cc.p(display.cx, display.cy - 100)) end)))
		finger:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function() finger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.25), cc.MoveBy:create(1, cc.p(0, 200)), cc.FadeOut:create(0.25), cc.CallFunc:create(function() 
			finger:setPosition(cc.p(display.cx + display.width/4, display.cy - 100 -50)) 
			end)))) end)))
		finger:runAction(cc.Sequence:create(cc.DelayTime:create(6), cc.CallFunc:create(function() finger:stopAllActions() removeFromParent(finger) end)))

		--旁白图
		local richTextBg = createSprite(G_MAINSCENE, "res/tuto/images/smallBg.png", cc.p(display.cx-200 , display.cy), cc.p(0, 0.5))--createScale9Sprite(G_MAINSCENE, "res/common/scalable/bg3.png", cc.p(display.cx + 150, display.cy), cc.size(260, 100), cc.p(0, 0.5))
		--createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
		richTextBg:setLocalZOrder(400)
		local girl = addBeautyTuto(richTextBg)
		local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2-8, richTextBg:getContentSize().height/2+3), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 18, MColor.white)
	    richText:addText(game.getStrByKey("tuto_tip_riding_up_down"))
	    richText:format()
	    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
	    	cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, -50)), cc.FadeIn:create(1)),cc.DelayTime:create(6), cc.CallFunc:create(
	    		function() 
	    			tutoRemoveRidingTutoAction()
	    		end))
	    richTextBg:runAction(action)
	    G_TUTO_NODE.menuAnimate = {leftArrow,finger,richTextBg}
	    -- richTextBg:runAction(cc.Sequence:create())
	end
end

function tutoRemoveRidingTutoAction( ... )
	-- body

	local saveState = function (  )
		for k,v in pairs(G_TUTO_DATA) do
	        if v.q_id == 12 then        	
	        	if v.q_state == TUTO_STATE_ON then
	            	tutoSetState(v, TUTO_STATE_FINISH)
	            end	             
	            break
	        end
    	end
	end

	if G_TUTO_NODE then
		if G_TUTO_DATA then
			for i,v in ipairs(G_TUTO_DATA) do
				if v.q_id == 12 then
					if G_TUTO_NODE.menuAnimate then
						for k,v in pairs(G_TUTO_NODE.menuAnimate) do
							removeFromParent(v)
						end
						G_TUTO_NODE.menuAnimate = nil

					end
					if G_TUTO_NODE.tutoLayer then
	    				removeFromParent(G_TUTO_NODE.tutoLayer) 
	    				G_TUTO_NODE.tutoLayer = nil
	    			end
	    			saveState()
					break
				end
			end
		end
	end
end

function tutoLayerFunc( params1,tutoStepInfo )
	-- body
	print("1")
	local node = G_TUTO_NODE.showNodeList[tutoStepInfo.showNode]
	if node.tutoFunction then
		print("2")
		node:tutoFunction()
	end
	print("3")

end

function tutoAddMenuTutoAction()
	log("tutoaddMenuTutoAction")
	if G_MAINSCENE then
		--手指动作
		-- local animateLeft = Effects:create(false)
		-- animateLeft:playActionData("tutoArrow", 8, 1.7, -1)
		-- G_MAINSCENE:addChild(animateLeft)
		-- animateLeft:setPosition(cc.p(display.cx, display.cy+80))
		-- animateLeft:setFlippedX(true)
		-- animateLeft:setLocalZOrder(199)

		local leftArrow = createSprite(G_MAINSCENE, "res/tuto/images/2.png",  cc.p(display.cx-230, display.cy+80), cc.p(0.5, 0.5))
		leftArrow:setRotation(-90)
		leftArrow:setZOrder(400)
		local rightArrow = createSprite(G_MAINSCENE, "res/tuto/images/2.png",  cc.p(display.cx+230, display.cy+80), cc.p(0.5, 0.5))
		rightArrow:setRotation(90)
		rightArrow:setZOrder(400)

		-- local animateRight = Effects:create(false)
		-- animateRight:playActionData("tutoArrow", 8, 1.7, -1)
		-- G_MAINSCENE:addChild(animateRight)
		-- animateRight:setPosition(cc.p(display.cx, display.cy+80))
		-- animateRight:setLocalZOrder(199)

		-- G_TUTO_NODE.menuAnimate = {animateLeft, animateRight}

		local leftPos = cc.p(display.cx - 50, display.cy+20)
		local rightPos = cc.p(display.cx + 50, display.cy+20)
		local leftFinger = createSprite(G_MAINSCENE, "res/tuto/images/1-1.png", leftPos, cc.p(0.5, 0.5))
		leftFinger:setLocalZOrder(400)
		leftFinger:setFlippedX(true)
		leftFinger:runAction(
			cc.RepeatForever:create(
			cc.Sequence:create(
				cc.FadeIn:create(0.25),
				cc.MoveBy:create(1.2, cc.p(-150, 0)), 
				cc.FadeOut:create(0.25),
				cc.CallFunc:create(function() leftFinger:setPosition(leftPos) end)))
			)
		local rightFinger = createSprite(G_MAINSCENE, "res/tuto/images/1-1.png", rightPos, cc.p(0.5, 0.5))
		rightFinger:setLocalZOrder(400)
		rightFinger:runAction(
			cc.RepeatForever:create(
			cc.Sequence:create(
				cc.FadeIn:create(0.25),
				cc.MoveBy:create(1.2, cc.p(150, 0)), 
				cc.FadeOut:create(0.25),
				cc.CallFunc:create(function() rightFinger:setPosition(rightPos) end)))
			)
		G_TUTO_NODE.menuAnimateNode = {leftFinger, rightFinger,leftArrow,rightArrow}

		--旁白图
		local richTextBg = createSprite(G_MAINSCENE, "res/tuto/images/smallBg.png", cc.p(display.cx + 100, display.cy - 100), cc.p(0, 0.5))--createScale9Sprite(G_MAINSCENE, "res/common/scalable/bg3.png", cc.p(display.cx + 100, display.cy), cc.size(260, 100), cc.p(0, 0.5))
		G_TUTO_NODE.richTextBg = richTextBg
		--createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
		richTextBg:setLocalZOrder(400)
		addBeautyTuto(richTextBg)
		local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2-8, richTextBg:getContentSize().height/2+3), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 18, MColor.white)
	    richText:addText(game.getStrByKey("tuto_tip_open_menu"))
	    richText:format()
	    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
	    	cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, -50)), cc.FadeIn:create(1)),
	    	cc.DelayTime:create(6), cc.CallFunc:create(function()
	    		tutoRemoveMenuTutoAction()
		    	-- if G_TUTO_NODE.richTextBg then 
		    	-- 	removeFromParent(G_TUTO_NODE.richTextBg) 
		    	-- 	G_TUTO_NODE.richTextBg = nil 
		    	-- end

		    	-- if G_TUTO_NODE.menuAnimate then 
		    	-- 	removeFromParent(G_TUTO_NODE.menuAnimate) 
		    	-- 	G_TUTO_NODE.menuAnimate = nil 
		    	-- end 
	    	end))
	    richTextBg:runAction(action)
	    -- richTextBg:runAction(cc.Sequence:create())
	    -- startTimerAction(self, 10, false, function()
	    -- 	tutoRemoveMenuTutoAction()
	    -- 	end)
	end
end

function tutoRemoveMenuTutoAction()
	if G_TUTO_NODE then
		if G_TUTO_DATA then
			for i,v in ipairs(G_TUTO_DATA) do
				if v.q_id == 6 then
					dump(v)
					if v.q_state == TUTO_STATE_ON then
						--log("test")
						-- if G_TUTO_NODE.menuAnimate then
						-- 	for k,v in pairs(G_TUTO_NODE.menuAnimate) do
						-- 		removeFromParent(v)
						-- 	end
						-- 	G_TUTO_NODE.menuAnimate = nil
						-- end

						if G_TUTO_NODE.menuAnimateNode then
							for k,v in pairs(G_TUTO_NODE.menuAnimateNode) do
								removeFromParent(v)
							end
							G_TUTO_NODE.menuAnimateNode = nil
						end

						if G_TUTO_NODE.richTextBg then
							removeFromParent(G_TUTO_NODE.richTextBg)
							G_TUTO_NODE.richTextBg = nil
						end
						if G_TUTO_NODE.tutoLayer then
		    				removeFromParent(G_TUTO_NODE.tutoLayer) 
		    				G_TUTO_NODE.tutoLayer = nil
	    				end
						tutoSetState({q_id = 6}, TUTO_STATE_FINISH)
						break
					end
				end
			end
		end
	end
end

function tutoShow(id,once)
	-- body
	for k,v in pairs(G_TUTO_DATA) do
        if v.q_id == id then
        	if once then
        		if v.q_state == TUTO_STATE_HIDE then
            	    v.q_state = TUTO_STATE_OFF
            	    G_TUTO_NODE:checkTuto(v)
            	end
            else
            	G_TUTO_NODE:checkTuto(v)
        	end       
            break
        end
    end
end

function tutoAddMoveTutoAction()
	log("tutoaddMoveTutoAction")
	if G_MAINSCENE then
		local operator = G_TUTO_NODE:getTouchNode(TOUCH_MAIN_ROCKING)
		local pos = operator:convertToWorldSpace(getCenterPos(operator))

		--手指动作
		local finger = createSprite(G_MAINSCENE, "res/tuto/images/1.png", pos, cc.p(0.5, 0.5), 100)
		finger:setOpacity(0)
		--local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.25), cc.MoveBy:create(1.5, cc.p(0, 200)), cc.FadeOut:create(0.25), cc.CallFunc:create(function() finger:setPosition(cc.p(display.cx, display.cy - 100)) end)))
		finger:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(function() finger:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.1), cc.MoveBy:create(1.5, cc.p(200, 0)), cc.FadeOut:create(0.1), cc.CallFunc:create(function() finger:setPosition(pos) end)))) end)))
		finger:runAction(cc.Sequence:create(cc.DelayTime:create(8), cc.CallFunc:create(function() finger:stopAllActions() removeFromParent(finger) end)))

		--旁白图
		local richTextBg = createSprite(layer, "res/tuto/images/smallBg.png", cc.p(display.cx - 200, display.cy), cc.p(0, 0.5))--createScale9Sprite(G_MAINSCENE, "res/common/scalable/bg3.png", cc.p(display.cx-200, display.cy), cc.size(260, 100), cc.p(0, 0.5))
		--createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
		richTextBg:setLocalZOrder(100)
		addBeautyTuto(richTextBg)
		--createSprite(richTextBg, "res/tuto/images/14.png", cc.p(richTextBg:getContentSize().width, richTextBg:getContentSize().height/2), cc.p(0, 0.3), nil, 1)
		local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height/2), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 18, MColor.white)
	    richText:addText(game.getStrByKey("tuto_tip_operator"))
	    richText:format()
	    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
	    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, -50)), cc.FadeIn:create(0.5)))
	    richTextBg:runAction(action)
	    richTextBg:runAction(cc.Sequence:create(cc.DelayTime:create(8), cc.CallFunc:create(function() if richTextBg then removeFromParent(richTextBg) richTextBg = nil end end)))
	end
end

function tutoAddSkillTutoAction()
	log("tutoaddMoveTutoAction")
	if G_MAINSCENE then
		local skill = G_TUTO_NODE:getTouchNode(TOUCH_MAIN_MAINSKILL)
		local pos = skill:convertToWorldSpace(getCenterPos(skill))

		--手指动作
		local finger = createSprite(G_MAINSCENE, "res/tuto/images/1.png", pos, cc.p(0.5, 0.5), 100)

		--旁白图
		local richTextBg = createScale9Sprite(G_MAINSCENE, "res/common/scalable/bg3.png", cc.p(display.cx, display.cy), cc.size(260, 100), cc.p(0, 0.5))
		createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
		richTextBg:setLocalZOrder(100)
		addBeautyTuto(richTextBg)
		--createSprite(richTextBg, "res/tuto/images/14.png", cc.p(richTextBg:getContentSize().width, richTextBg:getContentSize().height/2), cc.p(0, 0.3), nil, 1)
		local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height/2), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 18, MColor.white)
	    richText:addText(game.getStrByKey("tuto_tip_operator"))
	    richText:format()
	    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
	    	cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, -50)), cc.FadeIn:create(0.5)))
	    richTextBg:runAction(action)
	    richTextBg:runAction(cc.Sequence:create(cc.DelayTime:create(8), cc.CallFunc:create(function() if richTextBg then removeFromParent(richTextBg) richTextBg = nil end end)))
	end
end

function tutoAddMineAction()
	log("tutoAddMineAction")
	dump(G_MAINSCENE.map_layer.mineTab)
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mineTab then
		local count = 0
		for k,v in pairs(G_MAINSCENE.map_layer.mineTab) do
			if G_MAINSCENE.map_layer.item_Node then
				local mineSpr = G_MAINSCENE.map_layer.item_Node:getChildByTag(v)
				mineSpr = tolua.cast(mineSpr, "SpriteMonster")
				if mineSpr then
					local topNode = mineSpr:getTopNode()
					if topNode then
						local animate
						-- if v == 1 then
						-- 	animate = tutoAddAnimation(mineSpr, cc.p(0, 0), TUTO_ANIMATE_TYPE_FINGER, 1)
						-- else
						-- 	animate = tutoAddAnimation(mineSpr, cc.p(0, 0), TUTO_ANIMATE_TYPE_BUTTON, 1)
						-- 	animate:setScale(0.3, 1.1)
						-- end
						animateButton = tutoAddAnimation(topNode, cc.p(0, 0), TUTO_ANIMATE_TYPE_BUTTON, 1)
						animateButton:setScale(0.5, 1.1)
						animateButton:setTag(501)
						animateButton:setLocalZOrder(10000)
						animateFinger = tutoAddAnimation(topNode, cc.p(0, 0), TUTO_ANIMATE_TYPE_FINGER, 1)
						animateFinger:setTag(401)
						animateFinger:setLocalZOrder(10000)
						count = count + 1
						if count >= 3 then
							--break
						end
					end
				end
			end
		end
	end
end

function tutoRemoveMineAction()
	log("tutoRemoveMineAction")
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mineTab then
		for k,v in pairs(G_MAINSCENE.map_layer.mineTab) do
			if G_MAINSCENE.map_layer.item_Node then
				local mineSpr = G_MAINSCENE.map_layer.item_Node:getChildByTag(v)
				mineSpr = tolua.cast(mineSpr, "SpriteMonster")
				if mineSpr then
					local topNode = mineSpr:getTopNode()
					if topNode then
						if topNode:getChildByTag(401) then
							topNode:removeChildByTag(401)
						end
						if topNode:getChildByTag(501) then
							topNode:removeChildByTag(501)
						end
					end
				end
			end
		end
	end
end

function tutoRemoveHungUpCheck()
	if G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE] then
		G_TUTO_NODE.touchNodeList[TOUCH_MAIN_TASK_GUIDE]:removeChildByTag(150)
	end
end

function tutoInitTutoData()
	G_TUTO_DATA = getConfigItemByKey("TutoCfg")

	if G_TUTO_ON == false then
		G_TUTO_DATA = {}
	end
end

function tutoAddSetHpAction()
	if G_TUTO_NODE then
		local aabb = {width=734}
		local sprite = G_TUTO_NODE:getTouchNode(TOUCH_SET_HP)
		local progress = G_TUTO_NODE:getTouchNode(TOUCH_SET_HP_PROGRESS)
		local label = G_TUTO_NODE:getTouchNode(TOUCH_SET_HP_PROGRESS_LABEL)
		local progressTo = 80
		if sprite and progress then
			local finger = createSprite(sprite, "res/tuto/images/1.png", getCenterPos(sprite), cc.p(0.5, 0.5), 0.8)
			finger:setTag(123)
			sprite:runAction(cc.MoveTo:create(0.5, cc.p((aabb.width-40)*progressTo/100 +20, sprite:getPositionY())))
			progress:runAction(cc.ProgressTo:create(0.5, progressTo))
			if label then
				startTimerAction(label, 0.1, true, function() 
					percent = math.floor(progress:getPercentage())
					label:setString(percent.."%") 
					end)
			end
			setGameSetById(GAME_SET_ID_USE_RED_HP, 80)
		end
	end
end

function removeSetHpAction()
	if G_TUTO_NODE then
		local sprite = G_TUTO_NODE:getTouchNode(TOUCH_SET_HP)
		local label = G_TUTO_NODE:getTouchNode(TOUCH_SET_HP_PROGRESS_LABEL)
		if sprite then
			if sprite:getChildByTag(123) then
				sprite:removeChildByTag(123)
			end
		end

		if label then
			label:stopAllActions()
		end
	end
end

function addTeamShow(params)
	log("addTeamShow 1111111111111111111111111111")
	if G_TUTO_NODE.tutoLayer and checkNode(G_TUTO_NODE.tutoLayer) then
		--log("111111111111111111111111")
		local animate = Effects:create(false)
		animate:playActionData("tutoButton", 12, 1.8, -1)
		G_TUTO_NODE.tutoLayer:addChild(animate)
		animate:setAnchorPoint(cc.p(0, 0))
		animate:setPosition(params.pos)
		dump(animate:getContentSize())
		animate:setScale(params.scaleX, params.scaleY)
		dump(animate:getContentSize())
	end
end

--显示精英怪物
function addBossShow( params )
	-- body
	if G_TUTO_NODE.tutoLayer and checkNode(G_TUTO_NODE.tutoLayer) then

		--旁白图
		local richTextBg = createSprite(G_TUTO_NODE.tutoLayer, "res/tuto/images/smallBg.png", cc.p(display.cx , display.cy), cc.p(0, 0.5))--createScale9Sprite(G_MAINSCENE, "res/common/scalable/bg3.png", cc.p(display.cx + 150, display.cy), cc.size(260, 100), cc.p(0, 0.5))
		--createSprite(richTextBg, "res/common/scalable/bg3-1.png", cc.p(richTextBg:getContentSize().width-3, 20), cc.p(0, 0))
		richTextBg:setLocalZOrder(400)
		local girl = addBeautyTuto(richTextBg)
		local richText = require("src/RichText").new(richTextBg, cc.p(richTextBg:getContentSize().width/2-8, richTextBg:getContentSize().height/2+3), cc.size(richTextBg:getContentSize().width-30, richTextBg:getContentSize().height-30), cc.p(0.5, 0.5), 30, 18, MColor.white)
	    richText:addText(game.getStrByKey("tuto_tip_showboss"))
	    richText:format()
		local finger
		finger = createTouchItem(G_TUTO_NODE.tutoLayer,"res/tuto/images/img" .. params[1].. ".png",cc.p(display.cx - 80, display.cy + 50),function ( ... )
				if richTextBg then 
					removeFromParent(richTextBg) 
					richTextBg = nil 
				end
				if finger then
					removeFromParent(finger) 
					finger = nil 
				end
				if G_TUTO_NODE.tutoLayer then
					removeFromParent(G_TUTO_NODE.tutoLayer) 
					G_TUTO_NODE.tutoLayer = nil
				end
				tutoSetState({q_id = params[2]}, TUTO_STATE_FINISH)
		end,nil,nil)
		finger:setZOrder(399)
	    local action = cc.Sequence:create(cc.CallFunc:create(function() richTextBg:setOpacity(0) richTextBg:setPositionY(richTextBg:getPositionY()+50) end), --
	    	cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, -50)), cc.FadeIn:create(1)),cc.DelayTime:create(5), cc.CallFunc:create( function ( ... )
		    	if richTextBg then 
					removeFromParent(richTextBg) 
					richTextBg = nil 
				end
				if finger then
					removeFromParent(finger) 
					finger = nil 
				end
				if G_TUTO_NODE.tutoLayer then
					removeFromParent(G_TUTO_NODE.tutoLayer) 
					G_TUTO_NODE.tutoLayer = nil
				end
				tutoSetState({q_id = params[2]}, TUTO_STATE_FINISH) 		
	    	end
	    		))
	    richTextBg:runAction(action)
	end
end

function openTaskMenu()
	log("openTaskMenu 1111111111111111111111111111")
	
	dump(require("src/base/BaseMapScene").hide_task)
	if G_MAINSCENE.hideFunc and require("src/base/BaseMapScene").hide_task == true then
		G_MAINSCENE.hideFunc()
	end
end
