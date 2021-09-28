--[[
 --
 -- add by vicky
 -- 2014.08.14
 --
 --]]

 local DuobaoItem = class("DuobaoItem", function()
 		return display.newNode()
 	end)
 

 function DuobaoItem:getCanTouchSize()
 	return CCSizeMake(250, 250)
 end


 function DuobaoItem:getContentSize()
 	if self._CntSize == nil then 
 		local proxy = CCBProxy:create()
		local rootnode = {}

		local node = CCBuilderReaderLoad("duobao/duobao_item.ccbi", proxy, rootnode)
		self._CntSize = node:getContentSize()

		self:addChild(node)
		node:removeSelf()
 	end

 	return self._CntSize
 end


 function DuobaoItem:updateItem()
	local itemData = self._itemData
 	local debris = self._itemData.debris 

 	local resType = ResMgr.getResType(itemData.type)

 	self._iconImg:setDisplayFrame(ResMgr.getLargeFrame(resType, itemData.id))

 	local posX = self._rootnode["tag_dipan"]:getContentSize().width/2 + itemData.posX 
 	local posY = self._rootnode["tag_dipan"]:getContentSize().height/2 + itemData.posY 
 	self._iconImg:setPosition(posX, posY) 

 	-- self._iconName:setString(itemData.name)
 	-- ResMgr.refreshItemName({label = self._iconName, resId = itemData.id})

	local nameColor = ResMgr.getItemNameColor(itemData.id)  
	local nameLbl = ui.newTTFLabelWithShadow({
        text = itemData.name,
        size = 24,
        color = nameColor,
        shadowColor = ccc3(0, 0, 0), 
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT
        })
		
	nameLbl:setPosition(-nameLbl:getContentSize().width/2, 0)
	self._iconName:removeAllChildren()
    self._iconName:addChild(nameLbl)


 	for _, v in ipairs(self._debrisType) do 
 		local typeItem = self._rootnode["debrisType_" .. tostring(v)]
 		if (#debris == v) then 
 			typeItem:setVisible(true)
 		else 
 			typeItem:setVisible(false)
 		end
 	end

 	if #debris < 3 or #debris > 7 then
 		CCMessageBox("服务器端返回数据错误！", "Tip")
 		return
 	end

 	local iconKey = "debrisType_" .. #debris .. "_icon_"
 	local numKey = "debrisType_" .. #debris .. "_num_"

 	local canShowMixAll = true 

 	for i, v in ipairs(debris) do 
 		local resType = ResMgr.getResType(v.type)
 		local itemIcon = self._rootnode[iconKey .. i]
 		ResMgr.refreshIcon({itemBg = itemIcon, id = v.id, resType = resType})
 		itemIcon:setScale(0.75)

 		local IMAGE_TAG = 1
 		if(v.num <= 0) then 
 			itemIcon:setColor(ccc3(60, 60, 60)) 
	 		itemIcon:getChildByTag(IMAGE_TAG):setColor(ccc3(60, 60, 60))
	 	else 
	 		itemIcon:setColor(ccc3(255, 255, 255)) 
	 		itemIcon:getChildByTag(IMAGE_TAG):setColor(ccc3(255, 255, 255))
 		end
 		
 		-- self._rootnode[numKey .. i]:setString(tostring(v.num))
 		local numLbl = ui.newTTFLabelWithOutline({
            text = tostring(v.num),
            size = 22,
            color = ccc3(255,255,255),
            outlineColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
 		
 		numLbl:setPosition(-numLbl:getContentSize().width, numLbl:getContentSize().height/2)
 		self._rootnode[numKey .. i]:removeAllChildren()
	    self._rootnode[numKey .. i]:addChild(numLbl)

 		if v.num < 2 then
 			canShowMixAll = false
 		end
 	end

 	self._updateMixAllBtn(canShowMixAll)
 end


 function DuobaoItem:onClickIcon(tag, v, itemIcon)
 	local debris = self._itemData.debris
 	local function getIndex(idx)
 		if idx == 1 then 
 			return "一"
 		elseif idx == 2 then 
 			return "二"
 		elseif idx == 3 then 
 			return "三"
 		elseif idx == 4 then 
 			return "四"
 		elseif idx == 5 then 
 			return "五"
 		elseif idx == 6 then 
 			return "六"
 		end
 	end

	local item = debris[tag] 
	local itemInfo = require("game.Duobao.DuobaoDebrisInfo").new({
        id = item.id, 
        type = item.type, 
        name = item.name, 
        title = self._itemData.name .. "碎片" .. getIndex(tag), 
        describe = item.describe, 
        num = item.num, 
        getMianzhanTime = self._getMianzhanTime,
        closeListener = function ( ... )
    		itemIcon:setTouchEnabled(true)  
        end
    })

    game.runningScene:addChild(itemInfo, 10)
    local itemIcon = self._rootnode["debrisType_" .. v .. "_icon_" .. tag] 
    
 end


 function DuobaoItem:initIconListen()
 	for _, v in ipairs(self._debrisType) do 
 		local iconKey = "debrisType_" .. v .. "_icon_"
 		for i = 1, v do 
 			local itemIcon = self._rootnode[iconKey .. i] 

 			itemIcon:setTouchEnabled(true)
			itemIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)  
	            if (event.name == "began") then 
	            	if self._bItemCanTouch ~= nil and self._bItemCanTouch == true then 
		            	itemIcon:setTouchEnabled(false) 
		            	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		            	self:onClickIcon(i, v, itemIcon)
		            end 

	            	return true
	            end
	        end)
 		end
 	end

 	-- local tutoBtn = 
 	-- TutoMgr.addBtn("duobao_item",tutoBtn)
 	-- TutoMgr.active()
 end

 function DuobaoItem:getTutoBtn() 
 	
 	return self._rootnode["debrisType_3_icon_2"] 

 end

 function DuobaoItem:getWaiGongTutoBtn()
 	return self._rootnode["debrisType_3_1"]
 end

 function DuobaoItem:onExit()
 	-- TutoMgr.removeBtn("duobao_item")
 end


 function DuobaoItem:getAnimEffectNode( ... )
 	return self._rootnode["tag_anim_node"]
 end

 function DuobaoItem:ctor(param)
 	self._index = param.index
 	self._viewSize = param.viewSize
 	self._itemData = param.itemData 
 	self._updateMixAllBtn = param.updateMixAllBtn
 	self._getMianzhanTime = param.getMianzhanTime 
 	self._debrisType = {3, 4, 5, 6}

 	self._bItemCanTouch = true 

 	self:setNodeEventEnabled(true)
 	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("duobao/duobao_item.ccbi", proxy, self._rootnode)
	node:setPosition(self._viewSize.width * 0.5, self._viewSize.height * 0.5)
	self:addChild(node)

	self._iconImg = self._rootnode["icon"]
	self._iconName = self._rootnode["name"]

 	self:initIconListen()

	self:updateItem() 

 end 
 

 function DuobaoItem:refreshItem(param)
 	self._index = param.index
 	self._itemData = param.itemData

 	self:updateItem()
 end
 

 function DuobaoItem:setItemTouchEnabled(bEnabled)
 	self._bItemCanTouch = bEnabled 
 end


 return DuobaoItem
 