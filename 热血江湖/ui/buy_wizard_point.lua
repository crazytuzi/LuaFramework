-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_buy_wizard_point = i3k_class("wnd_buy_wizard_point",ui.wnd_base)

local vitPrice = i3k_db_offline_exp.price
local pointValue = i3k_db_offline_exp.buyPoint

function wnd_buy_wizard_point:ctor()
	
end

function wnd_buy_wizard_point:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.buyBtn:onClick(self, self.onBuyPoint)
	
	self._detaileDesc = widgets.detaileDesc 
	self._diamondCount = widgets.diamondCount
	self._suo = widgets.suo
	self._nowPointNum = widgets.nowPointNum
	self._itemIcon = widgets.itemIcon
	self._pointNum = widgets.pointNum
end


function wnd_buy_wizard_point:refresh()
	self:updateData()
end

-- ui显示
function wnd_buy_wizard_point:updateData()
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	local number = wizardData.dayBuyPointTimes
	local needDiamond = vitPrice[number+1] and vitPrice[number+1] or vitPrice[#vitPrice]
	self._diamondCount:setText(needDiamond)
	self._nowPointNum:setText("当前修炼点数："..wizardData.funcPoint)
	local aa = g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_OFFLINE_POINT,i3k_game_context:IsFemaleRole())
	self._itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_OFFLINE_POINT,i3k_game_context:IsFemaleRole()))
	self._pointNum:setText(pointValue)
	self._detaileDesc:setText(i3k_get_string(802, needDiamond, i3k_db_offline_exp.buyPoint))	
end

--购买
function wnd_buy_wizard_point:onBuyPoint(sender)
	local wizardData = g_i3k_game_context:GetOfflineWizardData()
	if wizardData.funcPoint >= i3k_db_offline_exp.maxPoint then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(819))
		return
	end
	
	local number = g_i3k_game_context:GetOfflineWizardData().dayBuyPointTimes
	number = number + 1
	local needDiamond = vitPrice[number] and vitPrice[number] or vitPrice[#vitPrice]
	if g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND) < needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(146))
	else
		i3k_sbean.buy_offline_func_point(number, needDiamond)
	end
end

function wnd_create(layout)
	local wnd = wnd_buy_wizard_point.new()
	wnd:create(layout)
	return wnd
end
