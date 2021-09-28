-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bill_board_common_layer = i3k_class("wnd_bill_board_common_layer", ui.wnd_base)

function wnd_bill_board_common_layer:ctor()
	self.zf        = 0
	self.id        = 0
	self.content   = nil
	self.stay_time = 0
	self.anonymous = 1	
	self.isrewrite = 0
	self.cost      = 0
	self.cost_type = 0
end

function wnd_bill_board_common_layer:configure()
	local widgets = self._layout.vars
	self._layout.vars.cancel:onClick(self, self.onCloseUI)
	self._layout.vars.ok:onClick(self,self.onOkFunc)
	self.desc = widgets.desc
end

function wnd_bill_board_common_layer:onCloseUI()
	g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_CL)
end

function wnd_bill_board_common_layer:onOkFunc()
	local zf        = self.zf
	local id        = self.id
	local content   = self.content
	local stay_time = self.stay_time
	local anonymous = self.anonymous
	local isrewrite = self.isrewrite
	local cost      = self.cost
	local cost_type = self.cost_type
	if cost_type == 1 and g_i3k_game_context:GetDiamondCanUse(true) < cost then
		return g_i3k_ui_mgr:PopupTipMessage("您所持有的元宝不足，不能发布布告")
	elseif cost_type == 2 and g_i3k_game_context:GetMoneyCanUse(true) < cost then
		return g_i3k_ui_mgr:PopupTipMessage("您所持有的铜钱不足，不能发布布告")
	end
	i3k_sbean.add_bill_board(self.zf,self.id,self.content,self.stay_time,self.anonymous,self.isrewrite,self.cost,self.cost_type)
end

function wnd_bill_board_common_layer:refresh(zf,id,content,stay_time,cost,anonymous,isrewrite,cost_type)
	self.zf        = zf
	self.id        = id
	self.content   = content
	self.stay_time = stay_time
	self.cost      = cost
	self.anonymous = anonymous
	self.isrewrite = isrewrite
	self.cost_type = cost_type
	if cost_type == 1 then 
		self.desc:setText(string.format("是否花费%d%s",cost,"元宝发布"))
	elseif cost_type == 2 then
		self.desc:setText(string.format("是否花费%d%s",cost,"铜钱发布"))
	end
end

function wnd_create(layout)
	local wnd = wnd_bill_board_common_layer.new()
	wnd:create(layout)
	return wnd
end
