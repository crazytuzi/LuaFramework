local data_battle_battle = require("data.data_battle_battle")
local data_item_item = require("data.data_item_item")

local LianzhanLayer = class("LianzhanLayer", function()
	return require("utility.ShadeLayer").new()
end)

local ItemTop = class("ItemTop", function(index, lvData, data, otherRewardNum)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("battle/lianzhan_item_top.ccbi", proxy, rootnode)
	local getNumByIndex = function(index)
		if index == 1 then
			return common:getLanguageString("@OneTxt")
		elseif index == 2 then
			return common:getLanguageString("@TwoTxt")
		elseif index == 3 then
			return common:getLanguageString("@ThreeTxt")
		elseif index == 4 then
			return common:getLanguageString("@FourTxt")
		elseif index == 5 then
			return common:getLanguageString("@FiveTxt")
		elseif index == 6 then
			return common:getLanguageString("@SixTxt")
		elseif index == 7 then
			return common:getLanguageString("@SevenTxt")
		elseif index == 8 then
			return common:getLanguageString("@EightTxt")
		elseif index == 9 then
			return common:getLanguageString("@NineTxt")
		elseif index == 10 then
			return common:getLanguageString("@TenTxt")
		end
	end
	local numLbl = rootnode.num_lbl
	numLbl:setString(common:getLanguageString("@DI") .. tostring(getNumByIndex(index)) .. common:getLanguageString("@Next"))
	if otherRewardNum <= 0 then
		rootnode.get_reward_lbl:setVisible(false)
	end
	if data.exp == nil then
		data.exp = 0
	end
	if data.silver == nil then
		data.silver = 0
	end
	if data.xiahun == nil then
		data.xiahun = 0
	end
	rootnode.expLbl:setString(tostring(data.exp or 0))
	rootnode.silverLbl:setString(tostring(data.silver or 0))
	rootnode.xiahunLbl:setString(tostring(data.xiahun or 0))
	local lv, exp, maxExp
	if lvData == nil then
		lv = game.player:getLevel()
		exp = game.player:getExp()
		maxExp = game.player:getMaxExp()
	else
		lv = lvData.lv
		exp = lvData.exp
		maxExp = lvData.limit
	end
	rootnode.lvLbl:setString("LV " .. tostring(lv))
	local percent = exp / maxExp
	local bar = rootnode.addBar
	bar:setTextureRect(CCRectMake(bar:getTextureRect().x, bar:getTextureRect().y, bar:getTextureRect().width * percent, bar:getTextureRect().height))
	alignNodesOneByOne(rootnode.xiahunLbl1, rootnode.micon1)
	alignNodesOneByOne(rootnode.micon1, rootnode.expLbl)
	alignNodesOneByOne(rootnode.xiahunLbl2, rootnode.micon2)
	alignNodesOneByOne(rootnode.micon2, rootnode.silverLbl)
	alignNodesOneByOne(rootnode.xiahunLbl3, rootnode.micon3)
	alignNodesOneByOne(rootnode.micon3, rootnode.xiahunLbl)
	return node
end)
local ItemBottom = class("ItemBottom", function(data, startIndex, endIndex)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("battle/lianzhan_item_bottom.ccbi", proxy, rootnode)
	local num
	if #data == 2 then
		num = 2
		rootnode.reward_node_2:setVisible(true)
		rootnode.reward_node_1:setVisible(false)
	else
		num = 1
		rootnode.reward_node_1:setVisible(true)
		rootnode.reward_node_2:setVisible(false)
	end
	for i, v in ipairs(data) do
		if startIndex <= i and i <= endIndex then
			local iconType = ResMgr.getResType(v.t)
			local tmpIndex = i - startIndex + 1
			local rewardIcon = rootnode["reward_icon_" .. num .. "_" .. tostring(tmpIndex)]
			ResMgr.refreshIcon({
			id = v.id,
			resType = iconType,
			itemBg = rewardIcon,
			itemType = v.t
			})
			local canhunIcon = rootnode["reward_canhun_" .. num .. "_" .. tmpIndex]
			local suipianIcon = rootnode["reward_suipian_" .. num .. "_" .. tmpIndex]
			canhunIcon:setVisible(false)
			suipianIcon:setVisible(false)
			local nameLbl = rootnode["reward_name_" .. num .. "_" .. tmpIndex]
			local nameColor = ResMgr.getItemNameColorByType(v.id, iconType)
			local name = ResMgr.getItemNameByType(v.id, iconType)
			nameLbl:setString(name)
			nameLbl:setColor(nameColor)
			local numKey = "reward_num_" .. num .. "_" .. tostring(tmpIndex)
			local numLbl = ui.newTTFLabelWithOutline({
			text = tostring(v.n),
			size = 22,
			color = display.COLOR_GREEN,
			outlineColor = display.COLOR_BLACK,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_LEFT
			})
			ResMgr.replaceKeyLableEx(numLbl, rootnode, numKey, 0, 0)
			numLbl:align(display.RIGHT_BOTTOM)
		end
	end
	return node
end)

function LianzhanLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self._id = param.id
	self._closeListener = param.closeListener
	local data = param.data
	local totalNum = data["1"]
	local baseRewardList = {}
	local rewardList = {}
	local lvList = data["3"]
	for j, value in ipairs(data["2"]) do
		local rewards = {}
		local baseReward = {silver=0,exp=0,xiahun=0}
		for i, v in ipairs(value) do
			if v.id == 2 then
				baseReward.silver = baseReward.silver + v.n
			elseif v.id == 6 then
				baseReward.exp = baseReward.exp + v.n
			elseif v.id == 7 then
				baseReward.xiahun = baseReward.xiahun + v.n
			else
				table.insert(rewards, v)
			end
		end
		table.insert(baseRewardList, baseReward)
		table.insert(rewardList, rewards)
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("battle/lianzhan_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self.m_ccbNode = node
	local levelData = data_battle_battle[self._id]
	local levelNameLbl = self._rootnode.level_name
	levelNameLbl:setString(tostring(levelData.name))
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		local submapID = game.player.m_cur_normal_fuben_ID
		local data_field_field = require("data.data_field_field")
		local clickedBigMapId = data_field_field[submapID].world
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local function _callback(errorCode, mapData)
			if errorCode == "" then
				if self._closeListener then
					self._closeListener()
					self._closeListener = nil
				end
			else
				CCMessageBox(errorCode, "server data error")
			end
		end
		_callback("", nil)
	end,
	CCControlEventTouchUpInside)
	local height = 0
	for i = 1, totalNum do
		local baseReward = baseRewardList[i]
		if baseReward ~= nil then
			local otherRewards = rewardList[i]
			local otherRdNum = 0
			if otherRewards ~= nil then
				otherRdNum = #otherRewards
			end
			local lv = lvList[i]
			local itemTop = ItemTop.new(i, lv, baseReward, otherRdNum)
			itemTop:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height)
			self._rootnode.contentView:addChild(itemTop)
			height = height + itemTop:getContentSize().height
			if otherRewards == nil or #otherRewards <= 0 then
				height = height - 40
			elseif otherRewards ~= nil then
				local num
				if #otherRewards % 3 == 0 then
					num = #otherRewards / 3
				else
					num = #otherRewards / 3 + 1
				end
				for i = 1, num do
					local startIndex = 1
					startIndex = startIndex + (i - 1) * 3
					local endIndex = i * 3
					local itemBottom = ItemBottom.new(otherRewards, startIndex, endIndex)
					itemBottom:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height)
					self._rootnode.contentView:addChild(itemBottom)
					height = height + itemBottom:getContentSize().height
				end
			end
		end
	end
	local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	self._rootnode.scrollView:updateInset()
	self._rootnode.scrollView:setContentOffset(cc.p(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
end

function LianzhanLayer:onExit()
	display.removeSpriteFramesWithFile("ui/ui_lianzhan.plist", "ui/ui_lianzhan.png")
	display.removeSpriteFramesWithFile("ui/ui_weijiao_yishou.plist", "ui/ui_weijiao_yishou.png")
	display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
	display.removeSpriteFramesWithFile("ui/ui_shengji.plist", "ui/ui_shengji.png")
	display.removeSpriteFramesWithFile("ui/ui_battle_win.plist", "ui/ui_battle_win.png")
	display.removeSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return LianzhanLayer