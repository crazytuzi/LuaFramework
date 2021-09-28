--[[
 --
 -- add by vicky
 -- 2014.08.04
 --
 --]]

local DailyLoginCell = class("DailyLoginCell", function()
	return CCTableViewCell:new()
end)


function DailyLoginCell:getContentSize()
	-- return CCSizeMake(display.width, 200)
	local proxy = CCBProxy:create()
    local rootNode = {}

	local node = CCBuilderReaderLoad("reward/daily_login_item.ccbi", proxy, rootNode)
	local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end


-- 签到天数
function DailyLoginCell:setTitle(index)
	local days = self.totalDays - 1
	if (index > days) then
		self._rootnode["index"]:setString("签到" .. days .. "天以上")
	else
		self._rootnode["index"]:setString("签到第" .. index .. "天")
	end
end

function DailyLoginCell:getTutoBtn()
	return self._rootnode["rewardBtn"]
end


-- 领取按钮状态
function DailyLoginCell:checkEnabled(index)
	local rewardBtn = self._rootnode["rewardBtn"]
	local curDay_index = self.curDay - 1

	rewardBtn:setVisible(true)
	self._rootnode["tag_has_get"]:setVisible(false)

	if (index ~= curDay_index) then 
		rewardBtn:setEnabled(false)
		if (index < curDay_index) then
			-- rewardBtn:setTitleForState(CCString:create("已签到"), CCControlStateDisabled)
			rewardBtn:setVisible(false)
			self._rootnode["tag_has_get"]:setVisible(true)
		else 
			-- rewardBtn:setTitleForState(CCString:create("签到"), CCControlStateDisabled)
		end
	else 
		if(self.isSign) then 
			-- rewardBtn:setEnabled(false)
			-- rewardBtn:setTitleForState(CCString:create("已签到"), CCControlStateDisabled)
			rewardBtn:setVisible(false)
			self._rootnode["tag_has_get"]:setVisible(true)
		else 
			rewardBtn:setEnabled(true)
			-- rewardBtn:setTitleForState(CCString:create("签到"), CCControlStateNormal)
		end
	end
end


-- 更新奖励图标、名称、数量
function DailyLoginCell:updateItem(itemData)
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


function DailyLoginCell:refreshItem(param)
	local index = param.index 
	local itemData = param.itemData

	self:setTitle(index + 1)
	self:checkEnabled(index)
	
	self:updateItem(itemData)
end


function DailyLoginCell:getIcon(index)
    return self._rootnode["reward_icon_" ..tostring(index)]
end


function DailyLoginCell:setRewardEnabled(bEnable)
	self._rootnode["rewardBtn"]:setEnabled(bEnable) 
end


function DailyLoginCell:create(param)
	self.cellIndex = param.id
	self.curDay = param.curDay
	self.isSign = param.isSign
	self.viewSize = param.viewSize
	self.totalDays = param.totalDays

	local cellData = param.cellData 
	local rewardListener = param.rewardListener 
	local informationListener = param.informationListener

	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/daily_login_item.ccbi", proxy, self._rootnode)
	node:setPosition(self.viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
	self:addChild(node)

	-- 领取按钮
	local rewardBtn = self._rootnode["rewardBtn"] 
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
	        if rewardListener then
	        	rewardBtn:setEnabled(false) 
	        	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	            rewardListener(self)
	        end
	    end, CCControlEventTouchUpInside)

	self:refreshItem({
		index = self.cellIndex, 
		itemData = cellData.itemData
		})

	--self:runEnterAnim()
	return self
end


-- 添加到列表中时的动画
function DailyLoginCell:runEnterAnim()
	
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
		CCCallFuncN:create(function()
			self:setPosition(CCPoint((self:getContentSize().width * 0.5 + display.width * 0.5), self:getPositionY()))
		end), 
		CCDelayTime:create(delayTime), 
		CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width/2 + display.width/2), 0))
		})

	self:runAction(sequence)
end


function DailyLoginCell:refresh(param)
	self:refreshItem(param)
end


-- 改变领取按钮的状态
function DailyLoginCell:getReward(isSign)
	self.isSign = isSign 
	local rewardBtn = self._rootnode["rewardBtn"]
	-- rewardBtn:setEnabled(false)
	-- rewardBtn:setTitleForState(CCString:create("已签到"), CCControlStateDisabled)
	rewardBtn:setVisible(false)
	self._rootnode["tag_has_get"]:setVisible(true)
end


return DailyLoginCell
