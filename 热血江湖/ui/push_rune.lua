-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")
--背包存入符文背包 多数据界面
-------------------------------------------------------

wnd_push_rune = i3k_class("wnd_push_rune",ui.wnd_add_sub)

local SALE_COUNT_TEXT 		= 1

function wnd_push_rune:ctor()
	self._itemid = 0
	self._item_count = 0
end

function wnd_push_rune:configure()
	local widgets = self._layout.vars
	
	self.item_icon = widgets.item_icon
	self.item_bg = widgets.item_bg
	self.item_name = widgets.item_name
	self.item_count = widgets.item_count
	self.money_count = widgets.money_count
	self.money_icon = widgets.money_icon
	self.suo_icon = widgets.suo_icon
	self.item_desc = widgets.item_desc
	self.sale_count = widgets.sale_count
	
	widgets.cancel:onClick(self, self.cancelButton)
	widgets.ok:onClick(self, self.okButton)
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	--self._count_label = self.sale_count
	
	--self.current_add_num = 100 	--当前能够增加到的最大值
	self.money_root=widgets.money_root
	self.money_root:hide() 
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
end


function wnd_push_rune:cancelButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Push_Rune)
end

function wnd_push_rune:okButton(sender)
	local itemTab = {}
	if self.current_num > 0 then
		itemTab[self._itemid] = self.current_num
		i3k_sbean.pushRune(itemTab)
		g_i3k_ui_mgr:CloseUI(eUIID_Push_Rune)
	end	
end
function wnd_push_rune:setSaleMoneyCount(count)
	self.sale_count:setText(count)
end

function wnd_push_rune:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Push_Rune,"setSaleMoneyCount",self.current_num)
	end
end 


function wnd_push_rune:refresh(id, count)
	SALE_COUNT_TEXT = 1
	self._itemid = id
	self._item_count = count
	
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self._itemid)
	self.item_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(self._itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._itemid,i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._itemid))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._itemid))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_count:setText(self._item_count)
	self.current_add_num = self._item_count
	if self.current_num > g_edit_box_max then
		self.current_num = g_edit_box_max
	end
	if self.current_num < 1 then
		self.current_num = 1
	end
	self:setSaleMoneyCount(self.current_num)
	self:updatefun()
end

function wnd_create(layout)
	local wnd = wnd_push_rune.new()
	wnd:create(layout)
	return wnd
end
