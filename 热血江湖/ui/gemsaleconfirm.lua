-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_gemSaleConfirm = i3k_class("wnd_gemSaleConfirm", ui.wnd_base) 

-------------------------------------------------------
function wnd_gemSaleConfirm:ctor()
	self._id = 0 
	self._count = 0
end

function wnd_gemSaleConfirm:configure()
	local widgets = self._layout.vars
	widgets.ok_btn:onClick(self, self.onSureBtn)
	widgets.cancel_btn:onClick(self, self.onCloseUI)
	widgets.input_label:setInputFlag(EDITBOX_INPUT_MODE_SINGLELINE)
end

function wnd_gemSaleConfirm:refresh(id, count)
	self._id = id
	self._count = count 
	self._layout.vars.desc:setText(i3k_get_string(18065))
end

function wnd_gemSaleConfirm:onSureBtn(sender)
	local widgets = self._layout.vars
	local text = widgets.input_label:getText()
	
	if text ~= i3k_get_string(18066) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5307))
		return
	end
	
	i3k_sbean.bag_sellgem(self._id, self._count)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_gemSaleConfirm.new()
	wnd:create(layout, ...)
	return wnd;
end
