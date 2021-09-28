--[[
 --
 -- add by vicky
 -- 2014.11.26 
 --
 --]]


 local YueqianItem = class("YueqianItem", function()
		return CCTableViewCell:new()
 end) 


 function YueqianItem:getContentSize()
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("nbhuodong/yueqian_item.ccbi", proxy, rootNode)
    local size = rootNode["itemBg"]:getContentSize() 

    self:addChild(node)
    node:removeSelf()

    return size
 end 


 function YueqianItem:getIcon(index) 
 	return self._rootnode["bg_icon_" .. tostring(index)] 
 end


 function YueqianItem:create(param)
 	-- dump(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	self._hasGetAry = param.hasGetAry 
 	self._curDay = param.curDay 

 	local proxy = CCBProxy:create() 
	self._rootnode = {}

	local node = CCBuilderReaderLoad("nbhuodong/yueqian_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node) 

	self:refreshItem(itemData) 

	return self 
 end 


 function YueqianItem:refresh(itemData)
 	self:refreshItem(itemData) 
 end 


 function YueqianItem:refreshItem(itemData) 
 	for i = 1, 4 do 
 		self._rootnode["boss_node_" .. i]:setVisible(false) 
 	end 

 	for i, v in ipairs(itemData) do 
 		self._rootnode["boss_node_" .. i]:setVisible(true) 

 		-- VIP双倍 
 		local vipIcon = self._rootnode["vip_icon_" .. i] 
 		if v.vip ~= nil and v.vip > 0 then 
 			vipIcon:setVisible(true) 
 			vipIcon:setDisplayFrame(display.newSprite("#yueqian_vip_" .. tostring(v.vip) .. ".png"):getDisplayFrame()) 
 		else 
 			vipIcon:setVisible(false) 
 		end 

 		-- 是否已领取 
 		local hasGet = false 
 		for j, d in ipairs(self._hasGetAry) do 
 			if d == v.day then 
 				hasGet = true 
 				break 
 			end 
 		end 

 		local effectNode = self._rootnode["effect_node_" .. i] 
 		if hasGet == true then 
 			self._rootnode["hasGet_node_" .. i]:setVisible(true) 
 			effectNode:removeAllChildrenWithCleanup(true)  
 		else 
 			self._rootnode["hasGet_node_" .. i]:setVisible(false) 
 			effectNode:removeAllChildrenWithCleanup(true)  
 			if v.day <= self._curDay then 
 				local effTextWin = ResMgr.createArma({
			        resType = ResMgr.UI_EFFECT, 
			        armaName = "yueqiandaobiankuang", 
			        isRetain = true 
			    }) 
			    effectNode:addChild(effTextWin) 
 			end 
 		end 

	 	-- 图标  
		local rewardIcon = self._rootnode["reward_icon_" .. i]
		rewardIcon:removeAllChildrenWithCleanup(true) 
		ResMgr.refreshIcon({
	        id = v.id, 
	        resType = v.iconType, 
	        itemBg = rewardIcon, 
	        iconNum = v.num, 
	        isShowIconNum = false, 
	        numLblSize = 22, 
	        numLblColor = ccc3(0, 255, 0), 
	        numLblOutColor = ccc3(0, 0, 0) 
	    })

		-- 属性图标 
		local canhunIcon = self._rootnode["reward_canhun_" .. i]
		local suipianIcon = self._rootnode["reward_suipian_" .. i]
		canhunIcon:setVisible(false)
		suipianIcon:setVisible(false)
		if v.type == 3 then
			-- 装备碎片
			suipianIcon:setVisible(true) 
		elseif v.type == 5 then
			-- 残魂(武将碎片)
			canhunIcon:setVisible(true) 
		end 

		-- 名称
		local nameKey = "reward_name_" .. tostring(i) 
		local nameColor = ccc3(255, 255, 255)
		if v.iconType == ResMgr.ITEM or v.iconType == ResMgr.EQUIP then 
			nameColor = ResMgr.getItemNameColor(v.id)
		elseif v.iconType == ResMgr.HERO then 
			nameColor = ResMgr.getHeroNameColor(v.id)
		end

		local nameLbl = ui.newTTFLabelWithShadow({
	        text = v.name,
	        size = 20,
	        color = nameColor,
	        shadowColor = ccc3(0,0,0),
	        font = FONTS_NAME.font_fzcy,
	        align = ui.TEXT_ALIGN_LEFT
	        })
			
		nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2)
		self._rootnode[nameKey]:removeAllChildren()
	    self._rootnode[nameKey]:addChild(nameLbl) 
	end 
 end 


 function YueqianItem:getReward(param)
 	self._hasGetAry = param.hasGetAry 
 	local itemData = param.itemData 
 	self:refreshItem(itemData) 
 end 
 
 return YueqianItem 
