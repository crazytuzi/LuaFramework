-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");


require("i3k_ui_mgr")

-------------------------------------------------------
wnd_npc_exchange = i3k_class("wnd_npc_exchange", ui.wnd_base)

local DHJLT = "ui/widgets/dhjlt"
local CARDNAME = {"月卡", "周卡", "逍遥卡"}

function wnd_npc_exchange:ctor()
	self.recordExchangeTimes = {}
	self.limit_time = 0
	self.npcId = nil
	self.exchangeId = nil
 
end

function wnd_npc_exchange:configure( )
	local widgets = self._layout.vars
	self.more_btn = widgets.more_btn
	self.scroll = widgets.scroll
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
	self.more_btn:onClick(self,self.onMoreClick)
	self.whichScrollJumpTo = nil
	widgets.duihuanBtn:onClick(self, self.onStateChange, "exchange")
	widgets.collectBtn:onClick(self, self.onStateChange, "collect")
end

function wnd_npc_exchange:onMoreClick()
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeNpcList)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChangeNpcList, "refresh")
end
 
function wnd_npc_exchange:refresh(npcId,exchangeId, state)
	local widgets = self._layout.vars
	self.recordExchangeTimes = g_i3k_game_context:GetRecordExchangeTimes()
	widgets.leftCount:setText(i3k_get_string(18272, i3k_db_npc_exchange_cfg.collectMaxNum - g_i3k_game_context:GetExchangeCollectCount()))
	self:updateCollectRed()
	self:updateTabState(state)
	local percent = widgets.scroll:getListPercent()
	if state == nil then state = self.state end
	if state == "collect" then
		self:updateCollectItems()
	else
	if npcId then
		self.npcId = npcId
	end
	if exchangeId then
		self.exchangeId = exchangeId
	end
	self:updateNpcExchangeItem()
	end
	if state == self.state then--是当前状态就跳转到当前进度
		self.scroll:jumpToListPercent(percent)
	end
	self.state = state or self.state or "exchange"
end

function wnd_npc_exchange:setNpcExchangeItem(ui, id, npcId, valid)
	local cfg = i3k_db_npc_exchange[id]
	local vars = ui.vars
	vars.jiangli_text:setText(cfg.exchange_goods_name)
	for e,s in ipairs(self.recordExchangeTimes) do
		if s.id == id then
			if cfg.limit_times == -1 then
				vars.limit_time:setText("次数不限")
			elseif cfg.limit_times >=0 then
				if cfg.special_card_type ~= 0 then
					vars.need_lvl:show()
					vars.is_double:show()
					vars.need_lvl:setText(string.format("需荣誉等级%s级", cfg.need_honor))
					vars.is_double:setText(string.format("%s用户双倍领取", CARDNAME[cfg.special_card_type]))
				elseif cfg.need_fiveTransform ~= 0 then
					vars.need_lvl:show()
					vars.is_double:hide()
					vars.need_lvl:setText(string.format(i3k_get_string(1405)))
				elseif cfg.need_forceType ~= 0 then
					local level = cfg.need_forceLvl
					local powerSideName = i3k_db_power_reputation[cfg.need_forceType].name
					local levelName = i3k_db_power_reputation_level[level].name
					vars.need_lvl:show()
					vars.need_lvl:setText(string.format("需要%s声望达到：%s", powerSideName, levelName))
				else
					vars.need_lvl:hide()
					vars.is_double:hide()
				end
				self.limit_time[id] = cfg.limit_times - s.limit_time
				if self.limit_time[id]== 0 then
					vars.limit_time:setTextColor(g_i3k_get_red_color())
					vars.exchange:disableWithChildren()   --次数不足，兑换按钮置灰
					vars.limit_time:setText(string.format("剩余%d%s",self.limit_time[id],"次"))
				else
					vars.limit_time:setText(string.format("剩余%d%s",self.limit_time[id],"次"))
				end
			end
		end
	end
	for k = 1, 3 do
		local icon = vars['require_icon'..k]
		local goods_id = cfg['require_goods_id'..k]
		if goods_id == 0 then
			icon:setVisible(false)
		else
			local require_icon = vars["require_goods_icon" .. k]
			local require_count = vars['require_goods_count' .. k]
			local item_btn = vars["require_goods_btn" .. k]
			local requireCount = cfg["require_goods_count" .. k]
			require_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(goods_id, g_i3k_game_context:IsFemaleRole()))
			icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(goods_id))
			local have = g_i3k_game_context:GetCommonItemCanUseCount(goods_id)
			if have < requireCount then
				vars.exchange:disableWithChildren(false)--道具数量不足，兑换按钮置灰
				require_count:setTextColor(g_i3k_get_cond_color(false))
			end
			if math.abs(goods_id) == g_BASE_ITEM_COIN then -- 铜钱
				require_count:setText(i3k_get_num_to_show(requireCount))
			else
				require_count:setText(have.."/"..requireCount)
			end
			item_btn:onClick(self, self.openTips, goods_id)
		end

		local get_goods_id = cfg["get_goods_id" .. k]
		local get_goods_icon = vars["get_goods_icon" .. k]
		local get_icon = vars["get_icon" .. k]
		local get_goods_count = vars["get_goods_count" .. k]
		local get_btn = vars["get_goods_btn" .. k]
		local getCount = cfg["get_goods_count" .. k]
		if get_goods_id == 0 then
			get_icon:setVisible(false)
		else
			get_goods_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(get_goods_id, g_i3k_game_context:IsFemaleRole()))
			get_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(get_goods_id))
			get_goods_count:setText("×" .. getCount)
			get_btn:onClick(self, self.openTips, get_goods_id)
		end
	end
	local tbl = {
		powerRep = {side = cfg.need_forceType, level = cfg.need_forceLvl},
		need_fiveTransform = cfg.need_fiveTransform,
		honor = cfg.need_honor,
		npcId = npcId,
		id = id,
	}
	for i = 1, 3 do
		tbl["goods_id" .. i] = cfg["require_goods_id" .. i]
		tbl["goods_count" .. i] = cfg["require_goods_count"..i]
	end
	vars.exchange:onClick(self, self.onExchange, tbl)
	local isCollect = g_i3k_game_context:IsExchangeCollected(npcId, id)
	vars.collectBtn:setVisible(not isCollect)
	vars.cancelBtn:setVisible(isCollect)
	vars.collectBtn:onClick(self, self.onCollectBtnClick, {npcId = npcId, id = id})
	vars.cancelBtn:onClick(self, self.onCancleBtnClick, {npcId = npcId, id = id})
	vars.deleteBtn:onClick(self, self.onCancleBtnClick, {npcId = npcId, id = id})
	vars.invalidMask:setVisible(valid == false)
end

function wnd_npc_exchange:updateNpcExchangeItem()

	self.scroll:removeAllChildren()
	local requires = {}
	for i,v in ipairs(i3k_db_npc_exchange) do
		local id = v.id
		for k,e in ipairs(self.exchangeId) do
			if id == e then
				local _layer = require(DHJLT)()
				table.insert(requires,{id = id,layer = _layer})
			end
		end
	end
	self.limit_time ={}
	for i,v in ipairs(requires) do




				
				

		self.scroll:addItem(v.layer)
		self:setNpcExchangeItem(v.layer, v.id, self.npcId)
	end
	
end

function wnd_npc_exchange:openTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_npc_exchange:checkPowerRep(tbl)
	if tbl.powerRep.side == 0 then
		return true
	end
	local info = g_i3k_game_context:getPowerRep()
	local value = info.fame[tbl.powerRep.side] or 0
	local level = g_i3k_db.i3k_db_power_rep_get_level(value)
	local name = i3k_db_power_reputation[tbl.powerRep.side].name
	if level < tbl.powerRep.level then
		return false
	end
	return true
end

function wnd_npc_exchange:onExchange(sender,tbl)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	if tbl.honor > 0 and tbl.honor > g_i3k_game_context:getFactionBusinessHonor() then
		g_i3k_ui_mgr:PopupTipMessage("荣耀等级不足")
	elseif tbl.need_fiveTransform > 0 and i3k_db_five_trans[fiveTrans.level + 1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1405))
	elseif not self:checkPowerRep(tbl) then
		local level = tbl.powerRep.level
		local powerSideName = i3k_db_power_reputation[tbl.powerRep.side].name
		local levelName = i3k_db_power_reputation_level[level].name
		g_i3k_ui_mgr:PopupTipMessage(string.format("需要%s声望达到：%s", powerSideName, levelName))
	else
		local minValue = self.limit_time[tbl.id]
		local Id = "goods_id"
		local Count = "goods_count"
		for i = 1, 3 do
			if tbl[Id .. i] ~= 0 then
				local number = g_i3k_game_context:GetCommonItemCanUseCount(tbl[Id .. i])
				local num = math.floor(number / tbl[Count .. i])
				minValue = math.min(num, minValue)
			end
		end
		if minValue == 1 then
			if g_i3k_game_context:IsExcNeedShowTip(g_NPC_EXCHANGE_TYPE) then
				g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
				g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_NPC_EXCHANGE_TYPE, tbl )
			else
				i3k_sbean.exchange_goods(tbl.npcId, tbl.id, 1 )
			end
		else 
			g_i3k_logic:OpenExchangeMoreUI(tbl, g_EXCHANGE_NPC)
			 
		end
	end
end
function wnd_npc_exchange:onStateChange(sender, state)
	self:refresh(nil, nil, state)
end
function wnd_npc_exchange:updateCollectItems()
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	local info = g_i3k_game_context:GetExchangeCollects()
	for i,v in ipairs(info) do
		local ui = require(DHJLT)()
		self.scroll:addItem(ui)
		self:setNpcExchangeItem(ui, v.exchangeId, v.npcId, v.valid)
	end
end
function wnd_npc_exchange:updateCollectRed()
	local widgets = self._layout.vars
	local info = g_i3k_game_context:GetExchangeCollects()
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	for i, v in ipairs(info) do
		local cfg = i3k_db_npc_exchange[v.exchangeId]
		local leftTime = self.recordExchangeTimes[v.exchangeId].limit_time
		if cfg.limit_times == -1 or cfg.limit_times - leftTime > 0 then
			local enough = true
			for ii = 1, 3 do
				local itemid = cfg["require_goods_id"..ii]
				local itemcount = cfg["require_goods_count"..ii]
				if itemid ~= 0 then
					local count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
					if count < itemcount then
						enough = false
						break
					end
				end
			end
			local honor = cfg.need_honor <= 0 or cfg.need_honor <= g_i3k_game_context:getFactionBusinessHonor()
			local transform = cfg.need_fiveTransform <= 0 or not i3k_db_five_trans[fiveTrans.level + 1] 
			local powerRep = self:checkPowerRep({
				powerRep = {
					side = cfg.need_forceType,
					level = cfg.need_forceLvl,
				}
			})
			if enough and honor and transform and powerRep then
				widgets.collectRed:setVisible(true)
				return
			end
		end
	end
	widgets.collectRed:setVisible(false)
end
	
function wnd_npc_exchange:updateTabState(state)
	local widgets = self._layout.vars
	if state == "exchange" then
		widgets.duihuanBtn:stateToPressed()
		widgets.collectBtn:stateToNormal()
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(9156))
	elseif state == "collect" then
		widgets.duihuanBtn:stateToNormal()
		widgets.collectBtn:stateToPressed()
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(9157))
	end
end

function wnd_npc_exchange:onCollectBtnClick(sender, info)
	if g_i3k_game_context:GetExchangeCollectCount() == i3k_db_npc_exchange_cfg.collectMaxNum then
		g_i3k_ui_mgr:PopupTipMessage("收藏次数已满")
	else
		local curNpcId = self.npcId
		local curExchangeId = self.exchangeId
		i3k_sbean.collect_exchange_item(info.npcId, info.id, function(npcId, exchangeId)
			g_i3k_game_context:SetExchangeCollectState(npcId, exchangeId, true)
			g_i3k_ui_mgr:RefreshUI(eUIID_npcExchange)
		end)
	end
end
function wnd_npc_exchange:onCancleBtnClick(sender, info)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18273), function(bValue)
		if bValue then
			i3k_sbean.cancel_collect_exchange_item(info.npcId, info.id, function(npcId, exchangeId)
				g_i3k_game_context:SetExchangeCollectState(npcId, exchangeId, false)
				g_i3k_ui_mgr:RefreshUI(eUIID_npcExchange)		
			end)
		end
	end)
end
function wnd_create(layout)
	local wnd = wnd_npc_exchange.new()
	wnd:create(layout)
	return wnd
end
