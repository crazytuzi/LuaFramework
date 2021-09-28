------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_add_item = i3k_class("wnd_gm_add_item", ui.wnd_base)

function wnd_gm_add_item:ctor()
	
end

function wnd_gm_add_item:configure()
	local widget = self._layout.vars
	self.idBox = widget.idBox
	self.valueBox = widget.valueBox
	self.idBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.valueBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_add_item:refresh(gmType)
	local widget = self._layout.vars
	self.idBox:setText("id")
	self.valueBox:setText("value")
	if gmType == g_GM_ADD_ITEM_BY_NAME then
		self.idBox:setInputMode(EDITBOX_INPUT_MODE_SINGLELINE)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_add_item:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmAddItem)
end

function wnd_gm_add_item:onSend(sender, gmType)
	local id = self.idBox:getText()
	local value = self.valueBox:getText()
	if id == "id" or value == "value" then
		g_i3k_ui_mgr:PopupTipMessage("请输入信息")
		return
	end
	if gmType == g_GM_ADD_ITEM_BY_NAME then
		gmType = g_ADD_ITEM
		for k,v in pairs(g_i3k_db.i3k_db_common_item_tbl) do
			for key,value in pairs(v) do
				if id == value.name then
					id = key
					break
				end
			end
		end
	end
	local text = string.format(g_GM_COMMAND[gmType], id, value) or ""
	i3k_sbean.world_msg_send_req(text)
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_add_item.new()
	wnd:create(layout, ...);
	return wnd
end
