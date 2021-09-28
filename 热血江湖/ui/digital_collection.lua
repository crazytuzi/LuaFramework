module(..., package.seeall)

local require = require;

local ui = require("ui/base");

wnd_digital_collection = i3k_class("digital_collection", ui.wnd_base)

local EXCHANGE = "ui/widgets/jishulingjiangt"

function wnd_digital_collection:ctor()
	self.npcId = nil
	self.exchangeId = {}
end

function wnd_digital_collection:configure()
	local widgets = self._layout.vars
	self.wizardScroll = widgets.wizardScroll
	--self.desc = widgets.desc
	widgets.closeBtn:onClick(self, self.onClose)
	widgets.helpBtn:onClick(self, self.onHelp)
end

function wnd_digital_collection:refresh(npcId, exchangeId)
	self.npcId = npcId
	self.exchangeId = exchangeId
	--self.desc:setText("活动配置")
	self:updatewizardScroll()
end

function wnd_digital_collection:updatewizardScroll()
	local haveExchange = g_i3k_game_context:GetRecordExchangeTimes()
	self.wizardScroll:removeAllChildren()
	for k, v in ipairs(self.exchangeId) do
		local _layer = require(EXCHANGE)()
		local widgets = _layer.vars
		widgets.get_icon:hide()
		self.wizardScroll:addItem(_layer)
		local exchangeData = i3k_db_npc_exchange[v]
		local require_goods_icon = {
			[1] = widgets.require_goods_icon1,
			[2] = widgets.require_goods_icon2,
			[3] = widgets.require_goods_icon3
		}
		local require_icon = {
			[1] = widgets.require_icon1,
			[2] = widgets.require_icon2,
			[3] = widgets.require_icon3
		}
		local require_goods_btn = {
			[1] = widgets.require_goods_btn1,
			[2] = widgets.require_goods_btn2,
			[3] = widgets.require_goods_btn3
		}
		local require_good_count = {
			[1] = widgets.require_goods_count1,
			[2] = widgets.require_goods_count2,
			[3] = widgets.require_goods_count3
		}
		local require_goods_id = {
			[1] = i3k_db_npc_exchange[v].require_goods_id1, 
			[2] = i3k_db_npc_exchange[v].require_goods_id2,
			[3] = i3k_db_npc_exchange[v].require_goods_id3
		}
		local get_goods_id = {
			[1] = i3k_db_npc_exchange[v].get_goods_id1,
			[2] = i3k_db_npc_exchange[v].get_goods_id2,
			[3] = i3k_db_npc_exchange[v].get_goods_id3
		}
		local require_goods_count = {
			[1] = i3k_db_npc_exchange[v].require_goods_count1,
			[2] = i3k_db_npc_exchange[v].require_goods_count2,
			[3] = i3k_db_npc_exchange[v].require_goods_count3
		}
		local get_goods_count = {
			[1] = i3k_db_npc_exchange[v].get_goods_count1,
			[2] = i3k_db_npc_exchange[v].get_goods_count2,
			[3] = i3k_db_npc_exchange[v].get_goods_count3
		}
		local show_icon = {
			[1] = i3k_db_national_exchange[k].require_id1,
			[2] = i3k_db_national_exchange[k].require_id2,
			[3] = i3k_db_national_exchange[k].require_id3
		}
		local isEnough = true
		local gift = {}
		local getItem = {}
		for i = 1, 3 do
			require_icon[i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(show_icon[i]))
			require_goods_btn[i]:onClick(self, self.onItem, show_icon[i])
			require_goods_icon[i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(show_icon[i], g_i3k_game_context:IsFemaleRole()))
			require_good_count[i]:hide()
			if require_goods_id[i] ~= 0 then
				if require_goods_count[i] > g_i3k_game_context:GetCommonItemCanUseCount(require_goods_id[i]) then
					isEnough = false
					require_good_count[i]:setTextColor(g_i3k_get_red_color())
				end
			end
			if get_goods_id[i] ~= 0 then
				table.insert(gift, {ItemID = get_goods_id[i], count = get_goods_count[i]})
				getItem[get_goods_id[i]] = get_goods_count[i]
			end
		end
		widgets.leftTimes:setText("剩余次数："..(i3k_db_npc_exchange[v].limit_times - haveExchange[v].limit_time))
		if haveExchange[v].limit_time >= i3k_db_npc_exchange[v].limit_times then
			widgets.exchange_btn:hide()
			widgets.finish:show()
			widgets.openedBox:show()
			widgets.closedBox:hide()
			widgets.reward_btn:onClick(self, self.isGet)
			--宝箱打开状态，不可点击
		else
			--宝箱非打开状态
			widgets.exchange_btn:show()
			widgets.finish:hide()
			widgets.openedBox:hide()
			widgets.closedBox:show()
			if isEnough then
				widgets.exchange_btn:enableWithChildren()
				_layer.anis.c_bx5.play()
			else
				widgets.exchange_btn:disableWithChildren()
				_layer.anis.c_bx5.stop()
			end
			widgets.reward_btn:onClick(self, self.onExchangeInfo, gift)
			widgets.exchange_btn:onClick(self, self.onExchange, {npcId = self.npcId, id = v, getItem = getItem})
		end
	end
end

function wnd_digital_collection:onItem(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_digital_collection:onExchange(sender, itemData)
	if g_i3k_game_context:IsBagEnough(itemData.getItem) then
		i3k_sbean.exchange_goods(itemData.npcId, itemData.id, 1)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包已满")
	end
end

function wnd_digital_collection:onExchangeInfo(sender, gift)
	g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips, gift)
end

function wnd_digital_collection:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_DigitalCollection)
end

function wnd_digital_collection:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16404))
end

function wnd_digital_collection:isGet(sender)
	g_i3k_ui_mgr:PopupTipMessage("已领取")
end

function wnd_digital_collection:showGetItem(exchangId, exchangeCnt)
	local get_goods_id = {
		[1] = i3k_db_npc_exchange[exchangId].get_goods_id1,
		[2] = i3k_db_npc_exchange[exchangId].get_goods_id2,
		[3] = i3k_db_npc_exchange[exchangId].get_goods_id3
	}
	local get_goods_count = {
		[1] = i3k_db_npc_exchange[exchangId].get_goods_count1,
		[2] = i3k_db_npc_exchange[exchangId].get_goods_count2,
		[3] = i3k_db_npc_exchange[exchangId].get_goods_count3
	}
	local get_goods = {}
	for k = 1, 3 do
		if get_goods_id[k] ~= 0 then
			table.insert(get_goods, {id = get_goods_id[k], count = get_goods_count[k] * exchangeCnt})
		end
	end
	g_i3k_ui_mgr:ShowGainItemInfo(get_goods)
end

function wnd_create(layout)
	local wnd = wnd_digital_collection.new()
	wnd:create(layout)
	return wnd
end
