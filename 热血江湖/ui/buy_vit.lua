-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
require("i3k_global")

-------------------------------------------------------

wnd_buy_vit = i3k_class("wnd_buy_vit",ui.wnd_base)

local vitPrice = g_i3k_db.i3k_db_get_common_cfg().buyVit.price
VITVALUE = g_i3k_db.i3k_db_get_common_cfg().buyVit.vitValue

--title
BUY_VIT_DESC = 650

function wnd_buy_vit:ctor()

end

function wnd_buy_vit:configure()
	local widgets = self._layout.vars
	widgets.cancel_btn:onClick(self, self.cancelBtn)
	widgets.buy_btn:onClick(self, self.buyBtn)
	
	self.title_desc = widgets.title_desc
	self.item_icon = widgets.item_icon
	self.times_desc = widgets.times_desc
	self.detaile_desc = widgets.detaile_desc
	self.diamond_count = widgets.diamond_count
	self.vit_count = widgets.vit_count

	self.friends_go = widgets.friends_go
	self.production_go = widgets.production_go
	self.faction_go = widgets.faction_go
	self.friends_go:onClick(self,self.friendsGo)
	self.production_go:onClick(self,self.productionGo)
	self.faction_go:onClick(self,self.factionGo)

end

function wnd_buy_vit:friendsGo(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BuyVit)
	g_i3k_ui_mgr:CloseUI(eUIID_sweepActivity)
	g_i3k_logic:OpenMyFriendsUI()
end

function wnd_buy_vit:productionGo(sender)
  	local lel = g_i3k_game_context:GetLevel()
	g_i3k_ui_mgr:CloseUI(eUIID_sweepActivity)
	
  	if lel > 31 then 
  		g_i3k_ui_mgr:CloseUI(eUIID_BuyVit)
		g_i3k_logic:OpenProductUI(6,1)
	else
		g_i3k_logic:OpenProductUI(6,1)
	end
end

function wnd_buy_vit:factionGo(sender)
	local factionId = g_i3k_game_context:GetFactionSectId()
	if factionId ~= 0 then 
		g_i3k_ui_mgr:CloseUI(eUIID_BuyVit)
		g_i3k_ui_mgr:CloseUI(eUIID_sweepActivity)
		g_i3k_logic:OpenFactionDine()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(680))
	end
end

function wnd_buy_vit:refresh()
	self.title_desc:setImage(g_i3k_db.i3k_db_get_icon_path(BUY_VIT_DESC))
	local number = g_i3k_game_context:GetBuyVitTimes()
	local needDiamond = vitPrice[number+1] and vitPrice[number+1] or vitPrice[#vitPrice]
	self:updateVitTips(number, needDiamond)
end

function wnd_buy_vit:maxVitTimes()
	local viplvl = g_i3k_game_context:GetVipLevel()
	local dayMaxTimes = i3k_db_kungfu_vip[viplvl].buyVitTimes
	return dayMaxTimes
end

function wnd_buy_vit:buyBtn(sender)
	if g_i3k_game_context:GetVit() + VITVALUE > g_i3k_game_context:GetVitRealMax() then
		g_i3k_ui_mgr:PopupTipMessage("您当前体力充足，无需购买体力")
		return
	end
	
	local number = g_i3k_game_context:GetBuyVitTimes()
	number = number + 1
	if number > self:maxVitTimes() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(147))
		return
	end
	local needDiamond = vitPrice[number] and vitPrice[number] or vitPrice[#vitPrice]
	if g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND) < needDiamond then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(146))
		return
	else
		i3k_sbean.buy_vit(number)
	end
end

function wnd_buy_vit:updateVitTips(number,needDiamond)
	local timesStr = string.format("(今日可购买次数：%s/%s)", number, self:maxVitTimes())
	self.times_desc:setText(timesStr)
	if number == self:maxVitTimes() then
		self.times_desc:setTextColor(g_COLOR_VALUE_RED)
	end
	local detaileStr = string.format("在现有体力的基础上再获得%s体力", VITVALUE)
	self.detaile_desc:setText(detaileStr)
	self.diamond_count:setText(needDiamond)
	self.vit_count:setText(VITVALUE)
end

function wnd_buy_vit:cancelBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BuyVit)
end

function wnd_create(layout)
	local wnd = wnd_buy_vit.new()
	wnd:create(layout)
	return wnd
end
