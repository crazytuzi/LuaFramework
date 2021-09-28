--[[
 --
 -- add by vicky
 -- 2014.09.09
 --
 --]]


local KaifuRewardCell = class("KaifuRewardCell", function()
	return CCTableViewCell:new()
end)


function KaifuRewardCell:getContentSize()
	-- return CCSizeMake(display.width, 200) 
	local proxy = CCBProxy:create()
    local rootNode = {}

	local node = CCBuilderReaderLoad("reward/kaifu_reward_item.ccbi", proxy, rootNode)
	local size = rootNode["itemBg"]:getContentSize()
	self:addChild(node)
	node:removeSelf()
    return size
end


-- 领取天数
function KaifuRewardCell:setTitle(index)
	self._rootnode["index"]:setString("第" .. index .. "天")
end


-- 领取按钮状态
function KaifuRewardCell:checkEnabled()
	local rewardBtn = self._rootnode["rewardBtn"]
	local rewarded = 0

	rewardBtn:setVisible(true)
	self._rootnode["tag_has_get"]:setVisible(false)

	if self._hasRewardDays ~= nil then
		for i, v in ipairs(self._hasRewardDays) do 
			if v == self._day then
				rewarded = 1
				break
			end
		end 
	end

	if self._day > self._curDay then
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
function KaifuRewardCell:updateItem(itemData)
	-- dump(itemData)
	for i, v in ipairs(itemData) do 
		local reward = self._rootnode["reward_" ..tostring(i)]
		reward:setVisible(true)

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

		local sz = rewardIcon:getContentSize() 
		local h 

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


function KaifuRewardCell:refreshItem(param)
	local itemData = param.itemData 
    self._day = param.day 

	self:setTitle(self._day)
	self:checkEnabled()
	
	self:updateItem(itemData)
end


function KaifuRewardCell:getIcon(index)
    return self._rootnode["reward_icon_" ..tostring(index)]
end


function KaifuRewardCell:setRewardEnabled(bEnable)
	self._rootnode["rewardBtn"]:setEnabled(bEnable) 
end


function KaifuRewardCell:create(param) 
	self._curDay = param.curDay 
	self._hasRewardDays = param.hasRewardDays 
	local viewSize = param.viewSize 
	local cellData = param.cellData 
	local rewardListener = param.rewardListener

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/kaifu_reward_item.ccbi", proxy, self._rootnode)
	node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	-- 领取按钮
	local rewardBtn = self._rootnode["rewardBtn"] 
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	        if rewardListener then 
	        	self:setRewardEnabled(false)  
	            rewardListener(self)
	        end 
	    end, CCControlEventTouchUpInside)

	self:refreshItem({
		day = cellData.day, 
		itemData = cellData.itemData
		})

	return self
end


function KaifuRewardCell:getDay()
	return self._day
end


function KaifuRewardCell:refresh(param)
	self:refreshItem(param)
end


-- 改变领取按钮的状态
function KaifuRewardCell:getReward(hasRewardDays)
	self._hasRewardDays = hasRewardDays 
	local rewardBtn = self._rootnode["rewardBtn"]
	-- rewardBtn:setEnabled(false)
	-- rewardBtn:setTitleForState(CCString:create("已领取"), CCControlStateDisabled)
	rewardBtn:setVisible(false)
	self._rootnode["tag_has_get"]:setVisible(true)
end



return KaifuRewardCell
