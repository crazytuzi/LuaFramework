-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_vip_store_buy_base = i3k_class("wnd_vip_store_buy_base",ui.wnd_base)

local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 0
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4

function wnd_vip_store_buy_base:ctor()
	self.sendcommond = {}
	self.item = {}
end

function wnd_vip_store_buy_base:configure()
	
end

function wnd_vip_store_buy_base:buyItem()
	if self:canAfford(self.item.finalprice) then
		if self:canBuyVIP(self.item) then
			if self.limitTimes == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
			else
				local test = {}
				test[self.item.iid] = self.item.icount
				if g_i3k_game_context:IsBagEnough(test) then
					self.sendcommond.count = 1
					local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
					if self.sendcommond.price > have and self.sendcommond.free == e_Type_vip_store_bangyuan then
						local effectiveTime = self.sendcommond.effectiveTime
						local id = self.sendcommond.id
						local gid = self.sendcommond.gid
						local count = self.sendcommond.count
						local free = self.sendcommond.free
						local price = self.sendcommond.price
						local itemname = self.sendcommond.itemname
						local finalcount = self.item.icount
						local currencyType = self:toCurrencyType(free)
						local callfunction = function(ok)
							if ok then
								i3k_sbean.mall_buy(effectiveTime, id, gid,count, currencyType, price, itemname, finalcount)
							end
						end
						local msg = ""
						if have == 0 then
							msg = i3k_get_string(217, self.sendcommond.price)
						else
							msg = i3k_get_string(299, have, (self.sendcommond.price - have))
						end
						g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
					else
						local free = self.sendcommond.free
						local currencyType = self:toCurrencyType(free)
						i3k_sbean.mall_buy(self.sendcommond.effectiveTime, self.sendcommond.id, self.sendcommond.gid, self.sendcommond.count, currencyType, self.sendcommond.price, self.sendcommond.itemname, self.item.icount)
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "isNeedRefreshLog")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "setStoreList", false)
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(213, self.item.vipReq))
		end
	else
		local fun =(function(ok)
			if ok then
				g_i3k_logic:OpenChannelPayUI()
			end
		end)
		if self.sendcommond.free == e_Type_vip_store_hongli then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3079))
		elseif self.sendcommond.free == e_Type_vip_store_longhun then
			g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的龙魂币不够哦，需要充值吗", fun)
		else
			g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
		end
	end
end

function wnd_vip_store_buy_base:canAfford(price)
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
		local fhave = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have + fhave >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIVIDEND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DRAGON_COIN)
		if have >= price then
			return true
		end
	end
	return false
end

function wnd_vip_store_buy_base:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false
		end
	end
	return true
end

function wnd_vip_store_buy_base:toCurrencyType(free)
	local currencyType = g_BASE_ITEM_DIAMOND
	if free == e_Type_vip_store_yuanbao then
		currencyType = -g_BASE_ITEM_DIAMOND
	elseif free == e_Type_vip_store_bangyuan then
		currencyType = g_BASE_ITEM_DIAMOND
	elseif free == e_Type_vip_store_hongli then
		currencyType = g_BASE_ITEM_DIVIDEND
	elseif free == e_Type_vip_store_longhun then
		currencyType = g_BASE_ITEM_DRAGON_COIN
	end
	return currencyType
end

function wnd_create(layout)
	local wnd = wnd_vip_store_buy_base.new()
		wnd:create(layout)
	return wnd;
end
