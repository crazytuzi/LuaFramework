local spoolerLayer = class("spoolerLayer", function() return cc.Layer:create() end)

function spoolerLayer:ctor(spoolerId,bindThing,propNum,pos)
	self:tutoForPlayer(spoolerId,bindThing,propNum,pos)
end

function spoolerLayer:tutoForPlayer(spoolerId,bindThing,propNum,pos)
		local taskIds = nil 
		if DATA_Mission then
			taskIds = DATA_Mission:getBranchPropID()
		end
		if spoolerId or 
		( taskIds and taskIds[ spoolerId .. "" ] ) then
		local MPackStruct = require "src/layers/bag/PackStruct"
		local canUse = propNum

		local MPackManager = require "src/layers/bag/PackManager"
		local pack = MPackManager:getPack(MPackStruct.eBag)
		local bg = createSprite(self, "res/tuto/images/autobg.png", cc.p(display.width-200, display.height/2), cc.p(0.5, 0.5))
		local bg_size = bg:getContentSize()
		local Mprop = require( "src/layers/bag/prop")
		local MpropOp = require("src/config/propOp")
	  	--local iconSpr = Mprop.new({protoId = spoolerId})
	  	local iconSpr = Mprop.new(
		{
			protoId = spoolerId,
			swallow = true,
			num = canUse,
			cb = "tips",
		})
	  	bg:addChild(iconSpr)
	  	local specialPos = pos
	  	-----------------------------------------------------------------------------------
	  	--if not (spoolerId >= 9007 and spoolerId <= 9009) then
	  	if MpropOp.canUsedInBatch(spoolerId) then
			local tmp_node = cc.Node:create()
			local tmp_func = function(observable, event, pos, pos1, new_grid)
				if event == "-" or event == "+" or event == "=" or event == "reset" then
					local girdPropNum = pack:numOfOverlay(specialPos)
					local girdPropId = pack:protoId(specialPos)
					if not girdPropNum or girdPropId ~= spoolerId then
						removeFromParent(self)
					end
				end
			end

			tmp_node:registerScriptHandler(function(event)
				if event == "enter" then
					pack:register(tmp_func)
				elseif event == "exit" then
					pack:unregister(tmp_func)
				end
			end)
			self:addChild(tmp_node)
		end
		--------------------------------------------------				


	  	iconSpr:setPosition(cc.p(bg_size.width/2,bg_size.height-90))
	  	local nameStr = MpropOp.name(spoolerId)
	  	createLabel(bg, nameStr, cc.p(bg_size.width/2,145), cc.p(0.5, 0.5), 20, nil, nil, nil, MpropOp.nameColor(spoolerId))
		local buttonFun = function()
			local temp = 10
			local thingNum = pack:numOfOverlay(pos) --相应格子位的物品数量
			if not thingNum or (thingNum and thingNum == 0 ) then
				TIPS( { type = 1 , str = "^c(yellow)"..game.getStrByKey("notInBag").."^" }  )
			end
			local protoIdTemp = pack:protoId(pos)
			if protoIdTemp then
				local function UseItemByProtoId(pos)
					return MPackManager:useByGirdId(pos,canUse)
				end
				UseItemByProtoId(pos)
			end
			removeFromParent(self)
			if not bindThing then
				temp = 20
			end
			-- if spoolerId >= 9007 and spoolerId <= 9009 then
			-- 	for i=(9007+temp),(9008+temp) do
			-- 		if G_MAINSCENE.tipLayer:getChildByTag(i) ~= nil then
			-- 			local theLayer1 = G_MAINSCENE.tipLayer:getChildByTag(i)
			-- 			removeFromParent(theLayer1)
			-- 			theLayer1 = nil
			-- 		end
			-- 	end
			-- 	-- if (G_SPOOL_TIME - canUse) ~= 0 then
			-- 	-- 	G_MAINSCENE:spoolerButton(1,pos,G_SPOOL_TIME - canUse)
			-- 	-- end
			-- end
		end
		local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(bg_size.width/2, 70), buttonFun)
		menuItem:setScale(0.95)
		addLableToMenuItem(menuItem,game.getStrByKey("useNow"),22,MColor.lable_yellow)
		createTouchItem(bg,"res/component/button/x3.png",cc.p(bg_size.width-25,bg_size.height-25),function() removeFromParent(self) end)
		menuItem:blink()
		print("显示快捷使用技能书")
		G_TUTO_NODE:setTouchNode(menuItem,TOUCH_AUTOCONFIG_USE)		
		G_TUTO_NODE:setShowNode(self,SHOW_AUTOCONFIG)	
	end
end

return spoolerLayer
