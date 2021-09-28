-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_exchange_word = i3k_class("wnd_exchange_word", ui.wnd_base)

local LAYER_DUIDUIPENGT = "ui/widgets/duiduipengt"
local CONSUME_COUNT = 1  --固定消耗一个道具
local DAY_EXCHANGE_TIME = i3k_db_word_exchange_cfg.day_exchange_time  --每日可兑换次数

function wnd_exchange_word:ctor()
	self.member_last_times = {}  --人员的兑换次数map
end

function wnd_exchange_word:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.help_btn:onClick(self, self.onHelpBtn)
	self.scroll = self._layout.vars.scroll
end

function wnd_exchange_word:refresh(member_last_times)
	self.member_last_times = member_last_times
	self:updateScroll()
end

function wnd_exchange_word:updateScroll()
	self.scroll:removeAllChildren()
	for i, v in ipairs(i3k_db_word_exchange_require) do
		local ui = require(LAYER_DUIDUIPENGT)()
		local widgets = ui.vars

		local require_icon = {}
		local require_goods_icon = {}
		local require_goods_btn = {}
		local require_goods_count = {}

		local get_icon = {}
		local get_goods_icon = {}
		local get_goods_btn = {}
		local get_goods_count = {}
		
		for i = 1, 4 do
			require_icon[i] 		= widgets["require_icon"..i]
			require_goods_icon[i]	= widgets["require_goods_icon"..i]
			require_goods_btn[i] 	= widgets["require_goods_btn"..i]
			require_goods_count[i] 	= widgets["require_goods_count"..i]
		end

		for i = 1, 2 do
			get_icon[i]			= widgets["get_icon"..i]
			get_goods_icon[i]	= widgets["get_goods_icon"..i]
			get_goods_btn[i] 	= widgets["get_goods_btn"..i]
			get_goods_count[i]	= widgets["get_goods_count"..i]
		end
		for k = 1, 4 do
			if v.need_item[k] then
				local need_itemID = v.need_item[k]
				local need_itemCount = CONSUME_COUNT  --固定消耗1个

				require_goods_icon[k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(need_itemID, i3k_game_context:IsFemaleRole()))
				require_icon[k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(need_itemID))

				--[[
				local have_count = g_i3k_game_context:GetCommonItemCanUseCount(need_itemID)
				require_goods_count[k]:setTextColor(have_count >= need_itemCount and g_i3k_get_green_color() or g_i3k_get_red_color())
				require_goods_count[k]:setText(string.format("%d/%d", have_count, need_itemCount))
				]]
				require_goods_count[k]:setVisible(false)

				require_goods_btn[k]:onClick(self, self.showItemTips, need_itemID)

				require_icon[k]:setVisible(true)
			else
				require_icon[k]:setVisible(false)
			end
		end

		for k = 1, 2 do
			local reward = {}
			if k == 1 then
				reward = v.extra_rewards
			elseif k == 2 then
				if v.need_player_num ~= 1 then
					reward = g_i3k_db.i3k_db_get_exchange_word_base_reward()
				end
			end
			if reward.id then
				get_goods_icon[k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(reward.id,i3k_game_context:IsFemaleRole()))
				get_icon[k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(reward.id))
				get_goods_count[k]:setText(string.format("x%d", reward.count))
				get_goods_btn[k]:onClick(self, self.showItemTips, reward.id)
				get_icon[k]:setVisible(true)
			else
				get_icon[k]:setVisible(false)
			end
			
		end

		local exchangeBtn = widgets.exchange_btn
		exchangeBtn:onClick(self, self.onExchange, v.id)
		local isShow = self:isShowExchangeBtn(v.need_player_num)
		if isShow then
			exchangeBtn:enableWithChildren()
		else
			exchangeBtn:disableWithChildren()
		end

		widgets.reward_text:setText(i3k_get_string(15578))
		widgets.limit_time:setVisible(false)

		self.scroll:addItem(ui)
	end
end

function wnd_exchange_word:isShowExchangeBtn(playerNum)
	local isShow = false
	local allMembers = g_i3k_game_context:GetAllTeamMembers()
	if next(allMembers) then  --是组队状态
		if g_i3k_game_context:getLeaderToHandle() then  --判断自己是否是队长
			local membersCount = self:getMembersCount()
			isShow = playerNum == membersCount
		end
	else
		isShow = playerNum == 1
	end
	return isShow
end

function wnd_exchange_word:onExchange(sender, rewardId)
	local allMembers = g_i3k_game_context:GetAllTeamMembers()
	local isExchange = true
	for k, v in pairs(self.member_last_times) do
		local remain_time = DAY_EXCHANGE_TIME - v
		if remain_time <= 0 then
			if k ~= g_i3k_game_context:GetRoleId() then
				local name = allMembers[k] and allMembers[k].overview.name or ""
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15575, name))
				isExchange = false
			end
		end
	end

	if isExchange then
		if g_i3k_game_context:IsExcNeedShowTip(g_NPC_EXCHANGE_TYPE) then
			local tbl = {rewardId = rewardId}
			g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
			g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_NPC_EXCHANGE_TYPE, tbl)
		else
			i3k_sbean.exchange_words_req(rewardId)
		end
	end
end

function wnd_exchange_word:getMembersCount()
	local count = 0
	for k, v in pairs(self.member_last_times) do
		count = count + 1
	end
	return count
end

function wnd_exchange_word:showItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_exchange_word:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(15579))
end

function wnd_create(layout, ...)
	local wnd = wnd_exchange_word.new();
	wnd:create(layout, ...);
	return wnd;
end
