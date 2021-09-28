-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bag_extend = i3k_class("wnd_bag_extend", ui.wnd_base)

function wnd_bag_extend:ctor()
	self.warehouseType = nil;
	self.useItem = -1
	self.info = {}
end

function wnd_bag_extend:configure()
	self._layout.vars.useMoneyBtn:onClick(self, self.onUseMoneyBtn)
	self._layout.vars.useItemBtn:onClick(self, self.onUseItemBtn)
	self._layout.vars.ok:onClick(self, self.onExtendBtn)
end

function wnd_bag_extend:refresh(info)
	local vars = self._layout.vars;
	self.info = info
	self.warehouseType = info.warehouseType;
	vars.desc:setText(info.desc);
	vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.itemId == 0 and 106 or info.itemId))
	vars.item_icon:setImage(info.itemId == 0 and g_i3k_db.i3k_db_get_icon_path(2396) or g_i3k_db.i3k_db_get_common_item_icon_path(info.itemId,g_i3k_game_context:IsFemaleRole()))
	vars.btn:onClick(self,function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(info.itemId)
	end)	
	vars.costCount:setText("X" .. info.costCount);
	vars.itemCount:setText("X" .. info.itemCount);
	vars.cancel:onClick(self,self.onClose);
	if g_i3k_game_context:GetCommonItemCanUseCount(info.itemId) >= info.itemCount then
		self:onUseItemBtn()
	else
		self:onUseMoneyBtn()
	end
end

function wnd_bag_extend:onUseMoneyBtn(sender)
	self._layout.vars.useMoney:setVisible(true);
	self._layout.vars.useItem:setVisible(false);
	self.useItem = 0;
end

function wnd_bag_extend:onUseItemBtn(sender)
	self._layout.vars.useMoney:setVisible(false);
	self._layout.vars.useItem:setVisible(true);
	self.useItem = 1;
end
	
function wnd_bag_extend:onExtendBtn(sender)
	if self.useItem == -1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15480))
			return
		end
	if self.useItem == 0 then
		if g_i3k_game_context:GetDiamondCanUse(false) < self.info.costCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(328))
				return
			end
		else
		if g_i3k_game_context:GetCommonItemCanUseCount(self.info.itemId) < self.info.itemCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15476))
				return
			end
			end	
		if self.warehouseType then
		i3k_sbean.expand_warehouse(self.info.expandTimes, self.warehouseType, self.useItem, self.info)
		else
		i3k_sbean.bag_expand(self.info.expandTimes, self.useItem, self.info)
		end
end

function wnd_bag_extend:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_Bag_extend)
end

function wnd_create(layout, ...)
	local wnd = wnd_bag_extend.new()
		wnd:create(layout, ...)
	return wnd
end