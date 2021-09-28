-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------

wnd_is_buy_wareHouse = i3k_class("wnd_is_buy_wareHouse",ui.wnd_base)

function wnd_is_buy_wareHouse:ctor()
	self._name = ""
end

function wnd_is_buy_wareHouse:configure()
	local widgets = self._layout.vars
	self.okBtn = widgets.ok 
	widgets.cancel:onClick(self,self.onCloseUI);
	self.okBtn:onClick(self, self.onOkBtn)
	self.desc = widgets.desc
end

function wnd_is_buy_wareHouse:refresh(grade)
	local needMoney = i3k_db_common.warehouse.unlockExpense
	self.desc:setText(i3k_get_string(3061 ,needMoney))
end

function wnd_is_buy_wareHouse:onOkBtn(sender)
	local needMoney = i3k_db_common.warehouse.unlockExpense
	i3k_sbean.unlock_private_warehouse(needMoney)
end

function wnd_create(layout)
	local wnd = wnd_is_buy_wareHouse.new()
		wnd:create(layout)
	return wnd
end
