--[[
 --
 -- add by vicky
 -- 2014.12.04 
 --
 --]]

 local VipLibaoRewardItem = class("VipLibaoRewardItem", function()
 		return CCTableViewCell:new() 
 	end)


 function VipLibaoRewardItem:getContentSize()
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("shop/shop_vipLibao_reward_item.ccbi", proxy, rootNode)
    local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()

    return size
 end 


 function VipLibaoRewardItem:create(param)
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 

 	local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("shop/shop_vipLibao_reward_item.ccbi", proxy, self._rootnode) 
    node:setPosition(viewSize.width/2, self._rootnode["itemBg"]:getContentSize().height/2) 
    self:addChild(node) 

 	self._rootnode["itemDesLbl"]:setColor(ccc3(59, 4, 4))  

 	self:refreshItem(itemData) 

 	return self 
 end 


 function VipLibaoRewardItem:refresh(itemData)
 	self:refreshItem(itemData) 
 end 


 function VipLibaoRewardItem:refreshItem(itemData) 
 	-- 描述 
	self._rootnode["itemDesLbl"]:setString(tostring(itemData.describe)) 

	-- 图标
	local rewardIcon = self._rootnode["itemIcon"] 
	rewardIcon:removeAllChildrenWithCleanup(true)
	ResMgr.refreshIcon({
		id = itemData.id, 
		resType = itemData.iconType, 
		itemBg = rewardIcon, 
		-- iconNum = itemData.num, 
		-- isShowIconNum = false, 
		-- numLblSize = 22, 
		-- numLblColor = ccc3(0, 255, 0), 
		-- numLblOutColor = ccc3(0, 0, 0) 
	}) 

	-- 属性图标
	local canhunIcon = self._rootnode["reward_canhun"]
	local suipianIcon = self._rootnode["reward_suipian"] 
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)

	if itemData.type == 3 then
		-- 装备碎片
		suipianIcon:setVisible(true) 
	elseif itemData.type == 5 then
		-- 残魂(武将碎片)
		canhunIcon:setVisible(true) 
	end 

	local nameColor = ccc3(255, 255, 255)
	if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(itemData.id)
	elseif itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(itemData.id)
	end

	self._rootnode["name_lbl"]:setString(tostring(itemData.name)) 
	self._rootnode["name_lbl"]:setColor(nameColor) 
	self._rootnode["top_num_lbl"]:setString("数量: " .. tostring(itemData.num))

 end 


 return VipLibaoRewardItem 
