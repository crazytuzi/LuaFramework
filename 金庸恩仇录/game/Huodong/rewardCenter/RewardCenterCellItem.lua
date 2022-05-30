--[[
 --
 -- add by vicky
 -- 2014.09.18 
 --
 --]]

local RewardCenterCellItem = class("RewardCenterCellItem", function()
		return CCTableViewCell:new()
end) 

function RewardCenterCellItem:getContentSize()
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("reward/reward_center_item_reward.ccbi", proxy, rootNode) 
    local size = rootNode["item_node"]:getContentSize()
    self:addChild(node)
    node:removeSelf()

    return size
end 


function RewardCenterCellItem:create(param)
	-- dump(param)
	local viewSize = param.viewSize 
	local itemData = param.itemData 

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("reward/reward_center_item_reward.ccbi", proxy, self._rootnode)
    node:setPosition(node:getContentSize().width * 0.5, viewSize.height * 0.5)
	self:addChild(node)
  	
  	self:refreshItem(itemData)

	return self  
end 


function RewardCenterCellItem:refreshItem(itemData)
	-- dump(itemData)
	 -- 图标
	local rewardIcon = self._rootnode["reward_icon"] 
	rewardIcon:removeAllChildrenWithCleanup(true) 
	ResMgr.refreshIcon({
		id = itemData.id, 
		resType = itemData.iconType, 
		itemBg = rewardIcon, 
		iconNum = itemData.num, 
		isShowIconNum = false, 
		numLblSize = 22, 
		numLblColor = display.COLOR_GREEN, 
		numLblOutColor = display.COLOR_BLACK
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

	-- 名称
	local nameColor = display.COLOR_WHITE 
	if itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(itemData.id)
	elseif itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(itemData.id) 
	end 

	local nameLbl = ui.newTTFLabelWithShadow({
        text = itemData.name,
        size = 20,
        color = nameColor,
        shadowColor = display.COLOR_BLACK,
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })
	
	ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, "reward_name", 0, 0)
	nameLbl:align(display.BOTTOM_CENTER)
end 


function RewardCenterCellItem:refresh(param)
	self:refreshItem(param.itemData)
end


return RewardCenterCellItem
