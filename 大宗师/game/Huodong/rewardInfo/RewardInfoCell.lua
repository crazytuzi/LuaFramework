--[[
 --
 -- add by vicky
 -- 2014.08.04
 --
 --]]

local RewardInfoCell = class("RewardInfoCell", function()
	return CCTableViewCell:new()
end)


function RewardInfoCell:getContentSize()
	local proxy = CCBProxy:create()
	local rootnode = {}

	CCBuilderReaderLoad("huodong/reward_information_item.ccbi", proxy, rootnode)
	local contentSize = rootnode["itemBg"]:getContentSize()

	return CCSizeMake(contentSize.width, contentSize.height)
end


function RewardInfoCell:refreshItem(itemData)
	-- dump(itemData)

	-- 图标
	local rewardIcon = self._rootnode["itemIcon"]
	rewardIcon:removeAllChildrenWithCleanup(true) 
	ResMgr.refreshIcon({
		id = itemData.id, 
		resType = itemData.iconType, 
		itemBg = rewardIcon, 
		iconNum = itemData.num, 
		isShowIconNum = false, 
		numLblSize = 22, 
		numLblColor = ccc3(0, 255, 0), 
		numLblOutColor = ccc3(0, 0, 0) 
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
	local nameColor = ccc3(110, 0, 0)
	if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(itemData.id)
	elseif itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(itemData.id)
	end

	self._rootnode["name_lbl"]:setString(itemData.name)
	self._rootnode["name_lbl"]:setColor(nameColor) 

	-- 数量
	self._rootnode["num_lbl"]:setString("数量：" .. tostring(self._num))

	-- local numLbl = ui.newTTFLabelWithOutline({
 --        text = tostring(itemData.num),
 --        size = 22,
 --        color = ccc3(0,255,0),
 --        outlineColor = ccc3(0,0,0),
 --        font = FONTS_NAME.font_fzcy,
 --        align = ui.TEXT_ALIGN_LEFT
 --        })
		
	-- numLbl:setPosition(-numLbl:getContentSize().width, numLbl:getContentSize().height/2)
	-- local numKey = "reward_num"
	-- self._rootnode[numKey]:removeAllChildren()
 --    self._rootnode[numKey]:addChild(numLbl)

    -- 描述
    self._rootnode["itemDesLbl"]:setString(itemData.describe)
end


function RewardInfoCell:create(param) 
	local viewSize = param.viewSize 
	local itemData = param.itemData 
	self._num = param.num 
	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("huodong/reward_information_item.ccbi", proxy, self._rootnode) 
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	self:refreshItem(itemData)

	return self
end

function RewardInfoCell:refresh(itemData)
	self:refreshItem(itemData)
end


return RewardInfoCell
