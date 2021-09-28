-- modify by zhangbing 2018/07/18
-- eUIID_HuoBan
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_huobanRecall= i3k_class("wnd_huobanRecall",ui.wnd_base)

local WIDGETS_HUOBANT1 = "ui/widgets/huobant1"
local WIDGETS_HUOBANT2 = "ui/widgets/huobant2"
local DB_BASE = i3k_clone(i3k_db_partner_base)
local DB_DETAILS = i3k_clone(i3k_db_partner_details)

-- 右侧三个页签定义
local MAIN_STATE		= 1 -- 主页
local FRIEDN_STATE		= 2 -- 友情礼
local INVITE_STATE		= 3 -- 邀请礼

-- 领取礼包的类型定义
local LEVEL_AWARD_TYPE			= 1 --练级送礼
local CONSUME_AWARD_TYPE		= 2 --消费送礼
local PROMOTE_AWARD_TYPE		= 3 --提升送礼
local POWER_AWARD_TYPE			= 4 --战力礼包
local ACTIVE_AWARD_TYPE			= 5 --活跃礼包
local ICE_AWARD_TYPE			= 6 --破冰好礼
local INTEGRAL_AWARD_TYPE		= 7 --积分送礼
local OLD_AWARD_TYPE			= 8 --老友记

-- 计时变量
local timeCounter = 0

function wnd_huobanRecall:ctor()
	self._showType = 0 --右侧三个按钮：主页，友情礼，邀请礼
	self._code = nil -- 伙伴码
	self._info = {} -- 服务器同步的信息
	self._fightPower = 0
	-- self._force = false --暂时不用注释
end

function wnd_huobanRecall:configure()
	local widgets = self._layout.vars

	self.typeButton = {
		{btn = widgets.main_btn,	root = widgets.main_root,	red = widgets.main_red},
		{btn = widgets.friend_btn,	root = widgets.friend_root,	red = widgets.friend_red},
		{btn = widgets.invte_btn,	root = widgets.invte_root,	red = widgets.invte_red},		
	}
	for i, e in ipairs(self.typeButton) do
		e.btn:onClick(self, self.onTypeChanged, i)
	end
	--主页type
	self.lowLvlBg		= widgets.lowLvlBg
	self.highLvlBg		= widgets.highLvlBg
	self.codeLabel		= widgets.codeLabel
	widgets.copy_code_btn:onClick(self, self.copyCode)
	widgets.dj_help_btn:onClick(self, self.onHelp)
	widgets.gj_help_btn:onClick(self, self.onHelp)
	widgets.dj_fill_code_btn:onClick(self, self.fillCode)
	widgets.gj_fill_code_btn:onClick(self, self.fillCode)
	widgets.copy_all_btn:onClick(self, self.copyAll)

	self.friend_scroll		= widgets.friend_scroll
	self.friendDesc			= widgets.friendDesc
	self.invte_scroll		= widgets.invte_scroll
	self.inviteDesc			= widgets.inviteDesc
	self.integral_lay		= widgets.integral_lay
	self.invte_num			= widgets.invte_num
	widgets.details_btn:onClick(self, self.openHuobanBonus)

	self.scrollTab = {
		[FRIEDN_STATE]	= self.friend_scroll,
		[INVITE_STATE]	= self.invte_scroll	
	}
	widgets.close_btn :onClick(self, self.onCloseUI)
end

function wnd_huobanRecall:refresh(code, info, fightPower, showType, bindCode)
	self._code = code
	self._info = info
	self._fightPower = fightPower
	self._showType = showType or self._showType
	self._bindCode = bindCode
	-- 默认打开主页页签
	self:changeShowTypeImpl(self._showType == 0 and MAIN_STATE or self._showType, self._showType ~= 0)
	self:updateTabBtnRedPoint(self:getAwardData())
end

function wnd_huobanRecall:onTypeChanged(sender, showType)
	self:changeShowTypeImpl(showType)
end

function wnd_huobanRecall:changeShowTypeImpl(showType, force)
	if self._showType ~= showType or force then
		-- self._force = force
		self._showType = showType
		if showType == MAIN_STATE then
			self:loadMainInfo(g_i3k_game_context:GetLevel(), self._code)
		elseif showType == FRIEDN_STATE then
			self:loadFriendScroll()
			self.friendDesc:setText(i3k_get_string(17362))
		elseif showType == INVITE_STATE then
			self:loadInviteScroll()
			self:loadInviteInfo(self._info.underRoleIds)
		end
		self:updateTypeChangeState(self._showType)
	end
end

function wnd_huobanRecall:updateTypeChangeState(showType)
	for i, e in ipairs(self.typeButton) do
		local vis = i == showType
		if vis then
			e.btn:stateToPressed()
		else
			e.btn:stateToNormal()
		end
		e.root:setVisible(vis)
	end
end

--更新页签红点
function wnd_huobanRecall:updateTabBtnRedPoint(awardData)
	local isShowFriendRed = false
	local isShowInviteRed = false
	for i, v in ipairs(awardData) do
		local cfg = v.cfg
		local isCoolTime = v.coolTime <= 0

		if cfg.tabType == g_PARTNER_FRIEND_AWARD_TYPE then
			local condition = self:getCanGain(i, cfg, v.isComplete) and isCoolTime
			isShowFriendRed = isShowFriendRed or condition
		elseif cfg.tabType == g_PARTNER_FRIEND_INVITE_TYPE then
			local condition = self:getCanGain(i, cfg, v.isComplete) and isCoolTime
			isShowInviteRed = isShowInviteRed or condition
		end
	end
	self.typeButton[FRIEDN_STATE].red:setVisible(isShowFriendRed)
	self.typeButton[INVITE_STATE].red:setVisible(isShowInviteRed)
end

------- ### 主页 ### ------
-- 等级底板显隐
function wnd_huobanRecall:loadMainInfo(lvl, code)
	self.lowLvlBg:setVisible(lvl < DB_BASE.cfg.haveCodeLvl)
	self.highLvlBg:setVisible(lvl >= DB_BASE.cfg.haveCodeLvl)
	self.codeLabel:setText(i3k_get_string(17384, code))
	self._layout.vars.fillHuoBanCodeTxt:setText(i3k_get_string(self._bindCode ~= "" and 18213 or 18216))
end

-- 复制伙伴码
function wnd_huobanRecall:copyCode(sender)
	i3k_copy_to_clipboard(self._code)
end

-- 帮助
function wnd_huobanRecall:onHelp(sender)
	local cfg = DB_BASE.cfg
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17358, cfg.openLvl, cfg.maxLvl, cfg.offlineDay, cfg.oldPlayerLvl))
end

function wnd_huobanRecall:fillCode(sender)
	if self._bindCode ~= "" then
		g_i3k_ui_mgr:OpenUI(eUIID_HuoBanUnbind)
		g_i3k_ui_mgr:RefreshUI(eUIID_HuoBanUnbind, self._bindCode)
	else
	g_i3k_ui_mgr:OpenUI(eUIID_HuoBanCode)
	g_i3k_ui_mgr:RefreshUI(eUIID_HuoBanCode, self._info.upperRoleId)
	end
end

--伙伴码+欢迎语
function wnd_huobanRecall:copyAll(sender)
	local welcomeDescCfg = i3k_db_partner_welcome_desc 
	local rnd = i3k_engine_get_rnd_u(1, #welcomeDescCfg)
	local cfg = welcomeDescCfg[rnd]
	i3k_copy_to_clipboard(string.format(cfg.desc, self._code))
end

------- ### 友情礼 ### ------
function wnd_huobanRecall:loadFriendScroll()
	local scroll = self.friend_scroll
	scroll:removeAllChildren()
	if self._info.honorReward == 0 then --没有领取过才加到列表里
		self:loadHonorAward(scroll, WIDGETS_HUOBANT1)
	end

	self:loadMapCopyAward(scroll, WIDGETS_HUOBANT1)
	
	self:loadAwardScroll(scroll, WIDGETS_HUOBANT1, g_PARTNER_FRIEND_AWARD_TYPE)
end

function wnd_huobanRecall:loadHonorAward(scroll, widget)
	local cfg = DB_BASE.honourBack
	local regressionTime = self._info.regressionTime
	local coolCD = regressionTime > 0 and cfg.oldPlayerCool or cfg.normalPlayerCool
	local node = require(widget)()
	local coolTime = self._info.bindTime + coolCD - i3k_game_get_time()
	local desc = i3k_get_string(cfg.txtID, i3k_get_time_show_text_simple(coolTime))
	node.vars.cd_time:setVisible(false) --荣耀归来不显示cd
	node.vars.term:setText(desc)
	node.vars.term:setVisible(self._info.bindTime > 0 and coolTime > 0) --绑定后才可显示
	node.vars.receiveBtn:onClick(self, self.onReceiveHonour, cfg.awardItems)
	node.vars.receiveBtn:SetIsableWithChildren(self._info.bindTime > 0 and coolTime <= 0)
	self:updateCells(scroll, node, cfg)
end

function wnd_huobanRecall:onReceiveHonour(sender, items)
	if self:isBindTips() then
		return false
	end
	i3k_sbean.receive_partner_honour_reward(items)
end

function wnd_huobanRecall:loadMapCopyAward(scroll, widget)
	local roleLvl = g_i3k_game_context:GetLevel()
	local cfg = DB_BASE.mapCopy
	local dungeonCfg = i3k_db_NpcDungeon[cfg.npcDungeonID]
	if dungeonCfg then
		local isComplete = g_i3k_game_context:getNpcDungeonEnterTimes(cfg.npcDungeonID) >= dungeonCfg.joinCnt
		local node = require(widget)()
		local condition = roleLvl >= dungeonCfg.openLevel and (dungeonCfg.maxLvl and roleLvl <= dungeonCfg.maxLvl)
		node.vars.cd_time:setVisible(false) --专属副本没有cd
		node.vars.term:setTextColor(g_i3k_get_cond_color(condition))
		node.vars.term:setText(i3k_get_string(17349, dungeonCfg.openLevel, dungeonCfg.maxLvl))
		node.vars.receiveBtn:onClick(self, self.onGotoNpc, {cfg = dungeonCfg, condition = condition})
		node.vars.btn_name:setText("前往")
		node.vars.specialDesc:show()
		node.vars.specialDesc:setText(i3k_get_string(17364, dungeonCfg.joinCnt))
		node.vars.receiveBtn:SetIsableWithChildren(not isComplete and self._info.bindTime > 0)
		node.vars.out_icon:setVisible(isComplete)
		self:updateCells(scroll, node, cfg)
	end
end

function wnd_huobanRecall:onGotoNpc(sender, info)
	if not info.condition then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17385))
	end
	g_i3k_game_context:GotoNpc(info.cfg.npcId)
	self:onCloseUI()
end

------- ### 邀请礼 ### ------
function wnd_huobanRecall:loadInviteInfo(info)
	local score = 0
	local bindNum = 0
	for _, v in pairs(info) do 
		score = score + v.score
		bindNum = bindNum + 1
	end
	self.inviteDesc:setText(i3k_get_string(17363))
	self.invte_num:setText(string.format("%s/%s", bindNum, DB_BASE.cfg.downLineNums)) 
	self.integral_lay:setText(score)
end

function wnd_huobanRecall:loadInviteScroll()
	self.invte_scroll:removeAllChildren()
	
	self:loadAwardScroll(self.invte_scroll, WIDGETS_HUOBANT2, g_PARTNER_FRIEND_INVITE_TYPE)
end

function wnd_huobanRecall:openHuobanBonus(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_HuoBanBonus)
	g_i3k_ui_mgr:RefreshUI(eUIID_HuoBanBonus, self._info.underRoleIds)
end

--获取需要显示的奖励数据
function wnd_huobanRecall:getAwardData()
	local awardData = {}
	local tag = 0

	local parterReward = self._info.parterReward
	for i, v in ipairs(DB_DETAILS) do
		local rewardInfo = parterReward[i]
		local rewardID = 1 -- 没有领取过奖励 初始是1
		local coolTime = 0
		local cfg = v[rewardID]
		local isComplete = false
		if rewardInfo and rewardInfo.lastRewardId ~= 0 then
			local lastId = rewardInfo.lastRewardId
			local coolCD = v[lastId].coolingTime
			coolTime = coolCD + rewardInfo.lastRewardTime - i3k_game_get_time()
			isComplete = lastId == #v
			rewardID = lastId + 1
			cfg = v[rewardID] or v[#v]
		end
		tag = tag + 1
		table.insert(awardData, {rewardID = rewardID, coolTime = coolTime, cfg = cfg, isComplete = isComplete, tag = tag})
	end
	return awardData
end

-- 友情礼，邀请礼，列表
function wnd_huobanRecall:loadAwardScroll(scroll, widget, aType)
	local awardData = self:getAwardData()
	for i, v in ipairs(awardData) do
		local coolTime = v.coolTime
		local rewardID = v.rewardID
		local cfg = v.cfg
		local isComplete = v.isComplete

		if cfg.tabType == aType then
			local node = require(widget)()
			local condition = self:getCanGain(i, cfg, isComplete)
			local desc = cfg.param ~= 0 and i3k_get_string(cfg.txtID, cfg.target, cfg.param) or i3k_get_string(cfg.txtID, cfg.target)
			node.vars.term:setTextColor(g_i3k_get_cond_color(condition))
			node.vars.term:setText(desc)
			node.vars.receiveBtn:setTag(v.tag)
			node.vars.cd_time:setVisible(coolTime > 0)
			node.vars.cd_time:setText(i3k_get_string(17348, i3k_get_time_show_text_simple(coolTime)))
			node.vars.receiveBtn:onClick(self, self.onReceiveBtn, {awType = i, awardId = rewardID, cfg = cfg})
			node.vars.red_point:setVisible(condition and coolTime <= 0)
			node.vars.receiveBtn:SetIsableWithChildren(condition and coolTime <= 0)
			node.vars.out_icon:setVisible(isComplete)
			self:updateCells(scroll, node, cfg)
		end
	end
end

function wnd_huobanRecall:updateCells(scroll, node, cfg)
	node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconID))
	node.vars.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.titleIconID))
	self:loadAwardItems(node.vars, cfg.awardItems)
	scroll:addItem(node)
end

-- 奖励物品展示
function wnd_huobanRecall:loadAwardItems(widget, awardItems)
	local nodeWidth = widget.itemRoot:getSize().width
	local totalNum = awardItems and #awardItems or 0
	if awardItems then
		for i = 1, 4 do
			local itemBg = widget["item_bg"..i]
			local item = awardItems[i]
			if item ~= nil then
				local id = item.itemID
				itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
				widget["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
				widget["count"..i]:setText(i3k_get_num_to_show(item.itemCount))
				widget["suo"..i]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
				widget["itemBtn"..i]:onClick(self, self.onItemTips, id)
				itemBg:setPositionX(nodeWidth * i / (totalNum + 1)) --奖励物品居中显示设置
			end
			itemBg:setVisible(item ~= nil and item.itemID ~= 0)
		end
	end
	widget.itemsBg:setVisible(totalNum ~= 0)
end

-- common
function wnd_huobanRecall:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_huobanRecall:isBindTips()
	if self._info.bindTime <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17386))
		return true
	end
	return false
end

function wnd_huobanRecall:isInviteTips()
	local underRoleIds = self._info.underRoleIds
	if table.nums(underRoleIds) <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17387))
		return true
	end
	return false
end

--领取详情配置奖励
function wnd_huobanRecall:onReceiveBtn(sender, info)
	local tabType = info.cfg.tabType
	if tabType == g_PARTNER_FRIEND_AWARD_TYPE then
		if self:isBindTips() then
			return false
		end
	elseif tabType == g_PARTNER_FRIEND_AWARD_TYPE then
		if self:isInviteTips() then
			return false
		end
	end
	i3k_sbean.receive_partner_reward(info.awType, info.awardId, info.cfg.awardItems)
end

-- 是否可以领取礼包类型函数
function wnd_huobanRecall:getLevelTerm(cfg)
	local roleLvl = g_i3k_game_context:GetLevel()
	return roleLvl >= cfg.target
end

function wnd_huobanRecall:getConsumeTerm(cfg)
	local consumeDiamond = self._info.diamond
	return consumeDiamond >= cfg.target
end

function wnd_huobanRecall:getPromoteTerm(cfg)
	local power = self._fightPower
	return power >= cfg.target
end

function wnd_huobanRecall:getPowerTerm(cfg)
	local needPlayerCnt = cfg.target
	local needFightPower = cfg.param

	local curPlayerCnt = 0
	local underRoleIds = self._info.underRoleIds
	for _, v in pairs(underRoleIds) do
		if v.maxFightPower > needFightPower then
			curPlayerCnt = curPlayerCnt + 1
		end
	end
	return curPlayerCnt >= needPlayerCnt
end

function wnd_huobanRecall:getActiveTerm(cfg)
	local needActive = cfg.target

	local totalActive = 0
	local underRoleIds = self._info.underRoleIds
	for _, v in pairs(underRoleIds) do
		totalActive = totalActive + v.activity
	end
	return totalActive >= needActive
end

function wnd_huobanRecall:getIceTerm(cfg)
	local needInviteCnt = cfg.target

	local underRoleIds = self._info.underRoleIds
	return table.nums(underRoleIds) >= needInviteCnt
end

function wnd_huobanRecall:getScoreTerm(cfg)
	local needScore = cfg.target

	local totalScore = 0
	local underRoleIds = self._info.underRoleIds
	for _, v in pairs(underRoleIds) do
		totalScore = totalScore + v.score
	end
	return totalScore >= needScore
end

function wnd_huobanRecall:getOldTerm(cfg)
	local needOldPlayer = cfg.target

	local curOldPlayer = 0
	local underRoleIds = self._info.underRoleIds
	for _, v in pairs(underRoleIds) do
		if v.isRegression > 0 then
			curOldPlayer = curOldPlayer + 1
		end
	end
	return curOldPlayer >= needOldPlayer
end

-- 放到类型函数下面最下面
local funcTypeTbl =
{
	[LEVEL_AWARD_TYPE]				= wnd_huobanRecall.getLevelTerm,
	[CONSUME_AWARD_TYPE]			= wnd_huobanRecall.getConsumeTerm,
	[PROMOTE_AWARD_TYPE]			= wnd_huobanRecall.getPromoteTerm,
	[POWER_AWARD_TYPE]				= wnd_huobanRecall.getPowerTerm,
	[ACTIVE_AWARD_TYPE]				= wnd_huobanRecall.getActiveTerm,
	[ICE_AWARD_TYPE]				= wnd_huobanRecall.getIceTerm,
	[INTEGRAL_AWARD_TYPE]			= wnd_huobanRecall.getScoreTerm,
	[OLD_AWARD_TYPE]				= wnd_huobanRecall.getOldTerm,
}

function wnd_huobanRecall:getCanGain(awardType, cfg, isComplete)
	local partnerType = cfg.tabType
	if partnerType == g_PARTNER_FRIEND_AWARD_TYPE then
		if self._info.bindTime <= 0 then -- 是否绑定
			return false
		end
	end

	if isComplete then
		return false
	end

	local func = funcTypeTbl[awardType]
	if func then
		return func(self, cfg)
	end
	return false
end

function wnd_huobanRecall:onUpdate(dTime)
	timeCounter = timeCounter + dTime
	if timeCounter > 1 then
		local awardData = self:getAwardData()
		local scroll = self.scrollTab[self._showType]
		if scroll then
			local allChildren = scroll:getAllChildren()
			for i, v in ipairs(allChildren) do
				local tag = v.vars.receiveBtn:getTag()
				if v.vars.cd_time:isVisible() and tag then
					local info = awardData[tag]
					local condition = self:getCanGain(tag, info.cfg, info.isComplete)
					v.vars.cd_time:setVisible(info.coolTime > 0)
					v.vars.cd_time:setText(i3k_get_string(17348, i3k_get_time_show_text_simple(info.coolTime)))
					v.vars.red_point:setVisible(condition and info.coolTime <= 0)
					v.vars.receiveBtn:SetIsableWithChildren(condition and info.coolTime <= 0)
				end
			end
		end

		self:updateTabBtnRedPoint(awardData)
		timeCounter = 0 -- 清零
	end
end

function wnd_create(layout)
	local wnd = wnd_huobanRecall.new()
	wnd:create(layout)
	return wnd
end
