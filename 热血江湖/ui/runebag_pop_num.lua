-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/add_sub")
--背包存入符文背包 多数据界面
-------------------------------------------------------

wnd_runeBag_pop_num = i3k_class("wnd_runeBag_pop_num",ui.wnd_add_sub)

local SALE_COUNT_TEXT 		= 1

function wnd_runeBag_pop_num:ctor()
	self._itemid = 0
	self._item_count = 0
end

function wnd_runeBag_pop_num:configure()
	local widgets = self._layout.vars
	

	self.sale_count = widgets.sale_count
	
	widgets.close:onClick(self, self.CloseUI)
	widgets.ok:onClick(self, self.okButton)
	
	self.add_btn = widgets.jia
	self.sub_btn = widgets.jian
	self.max_btn = widgets.max
	
	self.add_btn:onTouchEvent(self, self.onAdd)
	self.sub_btn:onTouchEvent(self,self.onSub)
	self.max_btn:onTouchEvent(self,self.onMax)
end

function wnd_runeBag_pop_num:okButton(sender)
	local itemTab = {}
	local tab = {}
	tab[self._itemid] = self.current_num
	if g_i3k_game_context:IsBagEnough(tab) then
		i3k_sbean.popRune(tab)
		
	else
		g_i3k_ui_mgr:PopupTipMessage("背包已满，无法提取符文")
		return
	end
	self:CloseUI()
end
function wnd_runeBag_pop_num:setSaleMoneyCount(count)
	self.sale_count:setText(count)
end

function wnd_runeBag_pop_num:updatefun()
	self._fun = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RuneBagPopNum,"setSaleMoneyCount",self.current_num)
	end
end 

function wnd_runeBag_pop_num:refresh(id, count)
	SALE_COUNT_TEXT = 1
	self._itemid = id
	self._item_count = count
	self.current_add_num = self._item_count
	self:setSaleMoneyCount(self.current_num)
	self:updatefun()
end

function wnd_runeBag_pop_num:CloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RuneBagPopNum)
end

function wnd_create(layout)
	local wnd = wnd_runeBag_pop_num.new()
	wnd:create(layout)
	return wnd
end
