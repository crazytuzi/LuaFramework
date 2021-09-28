module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_tripWizardItem = i3k_class("wnd_tripWizardItem", ui.wnd_base)
local ITEM = "ui/widgets/lxjst"
function wnd_tripWizardItem:ctor()
	self._curindex = nil;
	self._needItem = {}
end
function wnd_tripWizardItem:configure()
    local widgets = self._layout.vars
	self.itemScroll = widgets.itemScroll
	self.desc 		= widgets.desc
	widgets.ok:onClick(self, self.onOkBtn)
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_tripWizardItem:refresh(curindex)
	self.curindex = curindex;
	self:updateScroll()
end

function wnd_tripWizardItem:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_tripWizardItem:updateScroll()
	self.desc:setText(i3k_get_string(17087))
	self.itemScroll:removeAllChildren()
	self._needItem = {}
	for i , v in ipairs(i3k_db_arder_pet[self.curindex].needItem) do
		if v.id ~=0 and v.count ~= 0 then
			table.insert(self._needItem, v)
		end
	end
	for _, e in ipairs(self._needItem) do
		local node = require(ITEM)()
		local widget = node.vars
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.id))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id,i3k_game_context:IsFemaleRole()))
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
		if e.id == g_BASE_ITEM_DIAMOND or e.id == g_BASE_ITEM_COIN then
			widget.item_count:setText(e.count)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.id) .."/".. e.count)
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count))
		widget.btn:onClick(self, self.onItemTips, e.id);
		self.itemScroll:addItem(node)
	end
end

function wnd_tripWizardItem:isCanTrip()
	local num = 0;
	for i,e in ipairs(self._needItem) do
		if g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count then
			num = num + 1;
		end
	end
	if num == #self._needItem then
		return true;
	end
	return false;
end

function wnd_tripWizardItem:onOkBtn(sender)
	if self:isCanTrip() then
		i3k_sbean.wizardTripStart(self.curindex, self._needItem)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17079))
	end
end

function wnd_create(layout)
	local wnd = wnd_tripWizardItem.new();
		wnd:create(layout);
	return wnd;
end
