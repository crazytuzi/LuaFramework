--[[
 --
 -- add by vicky
 -- 2014.08.07
 --
 --]]


local LevelRewardCell = class("LevelRewardCell", function()
	return CCTableViewCell:new()
end)


function LevelRewardCell:getContentSize()
	-- return CCSizeMake(display.width, 200)
	local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("reward/level_reward_item.ccbi", proxy, rootNode)

	local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end


-- 签到天数
function LevelRewardCell:setTitle(index)
	self._rootnode["index"]:setString(self.level .. "级可领取")
end


-- 领取按钮状态
function LevelRewardCell:checkEnabled(index)
	local rewardBtn = self._rootnode["rewardBtn"]
	local rewarded = 0

	rewardBtn:setVisible(true)
	self._rootnode["tag_has_get"]:setVisible(false)

	if (self.hasRewardLvs ~= nil) then 
		for _, v in ipairs(self.hasRewardLvs) do
			if (v == self.level) then 
				rewarded = 1
				break
			end
		end
	end

	if (self.level > self.curLevel) then 
		rewardBtn:setEnabled(false)
		-- rewardBtn:setTitleForState(CCString:create("领取"), CCControlStateDisabled)
	else 
		if (rewarded == 1) then 
			-- rewardBtn:setEnabled(false)
			-- rewardBtn:setTitleForState(CCString:create("已领取"), CCControlStateDisabled)
			rewardBtn:setVisible(false)
			self._rootnode["tag_has_get"]:setVisible(true)
		else 
			rewardBtn:setEnabled(true)
			-- rewardBtn:setTitleForState(CCString:create("领取"), CCControlStateNormal)
		end
	end
end


-- 更新奖励图标、名称、数量
function LevelRewardCell:updateItem(itemData)
	-- dump(itemData)
	for i, v in ipairs(itemData) do 
		local reward = self._rootnode["reward_" ..tostring(i)]
		reward:setVisible(true)

		-- 图标
		local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
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

	-- 道具类型达不到4个时，剩余的道具框隐藏
	local count = #itemData
	while (count < 4) do
		self._rootnode["reward_" ..tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end


function LevelRewardCell:refreshItem(param)
	local index = param.index 
	local itemData = param.itemData

    self.level = param.level 

	self:setTitle(index + 1)
	self:checkEnabled(index)
	
	self:updateItem(itemData)
end

function LevelRewardCell:getIcon(index)
    return self._rootnode["reward_icon_" ..tostring(index)]
end


function LevelRewardCell:setRewardEnabled(bEnable)
	self._rootnode["rewardBtn"]:setEnabled(bEnable) 
end


function LevelRewardCell:create(param)
	self.cellIndex = param.id 
	self.level = param.level 
	self.curLevel = param.curLevel 
	self.hasRewardLvs = param.hasRewardLvs 
	self.viewSize = param.viewSize 

	local cellData = param.cellData 
	local rewardListener = param.rewardListener
	local informationListener = param.informationListener

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/level_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(self.viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	-- 领取按钮
	local rewardBtn = self._rootnode["rewardBtn"] 
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	        if rewardListener then
	        	rewardBtn:setEnabled(false) 
	            rewardListener(self)
	        end
	    end, CCControlEventTouchUpInside)

	self:refreshItem({
		index = self.cellIndex, 
		level = param.level, 
		itemData = cellData.itemData
		})

	return self
end


function LevelRewardCell:getLevel()
	return self.level
end


function LevelRewardCell:refresh(param)
	self:refreshItem(param)
end


-- 改变领取按钮的状态
function LevelRewardCell:getReward(hasRewardLvs)
	self.hasRewardLvs = hasRewardLvs
	local rewardBtn = self._rootnode["rewardBtn"]
	-- rewardBtn:setEnabled(false)
	-- rewardBtn:setTitleForState(CCString:create("已领取"), CCControlStateDisabled)
	rewardBtn:setVisible(false)
	self._rootnode["tag_has_get"]:setVisible(true) 
end



return LevelRewardCell