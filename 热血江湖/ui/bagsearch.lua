-------------------------------------------------------
module(..., package.seeall)

local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_bagSearch = i3k_class("wnd_bagSearch", ui.wnd_base)  

--0.背包搜索，1.仓库搜索，2.仓库背包搜索 	
local BAGTYPE = 0
local CKTYPE = 1
local CKBAGTYPE = 2
function wnd_bagSearch:ctor()
	self.searchType = 0 
	self.warehouseType =1 
	self.count = 0
end

function wnd_bagSearch:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.okBtnHandler) 		--确认按钮
	widgets.quxiao:onClick(self, self.quxiaoBtnHandler) --取消按钮
end

function wnd_bagSearch:setSearchType(searchType)
	self.searchType = searchType
end
 
function wnd_bagSearch:setWarehouseType(warehouseType)
	 self.warehouseType = warehouseType
end
--取消按钮
function wnd_bagSearch:quxiaoBtnHandler(sender)
	 g_i3k_ui_mgr:CloseUI(eUIID_BagSearch)
end

--确定按钮
function wnd_bagSearch:okBtnHandler(sender)
	local s = self._layout.vars.edit:getText() --获取输入框信息
	local keyWord = string.gsub(s, "^%s*(.-)%s*$", "%1")  --格式化字符串
	 
	if keyWord and #keyWord > 0 then 
		if self.searchType == 1 then
			self:searchItemInWarehouse(keyWord)
		else 
			self:searchItemInBag(keyWord)			 --查找背包相关物品
		end	
		g_i3k_ui_mgr:CloseUI(eUIID_BagSearch)
	else 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17313))
	end
end

--查找关键字
function wnd_bagSearch:searchItemInBag(keyWord)
	local _, BagItems = g_i3k_game_context:GetBagInfo()
	local newTab=g_i3k_db.i3k_db_get_items_after_search(BagItems,keyWord)
	self.count = g_i3k_db.i3k_db_get_search_items_count(newTab)
	self:afterSearch(newTab,keyWord)
end 

function wnd_bagSearch:afterSearch(tab,keyWord)
	if self.searchType==BAGTYPE then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag,"deepBag")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag,"updateSearchBag",self.count,tab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag,"setSearchName",keyWord)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag,"closeSearchBtn")
		
	elseif self.searchType == CKTYPE and table.nums(tab)==0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"CKNoItemTips")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"isCkSearch")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"haveItems",false)
	elseif self.searchType == CKTYPE then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"isCkSearch") 
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"updateBag",self.searchType,self.count,tab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"setCkSearchName",keyWord)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"haveItems",true)
	elseif self.searchType == CKBAGTYPE and table.nums(tab)==0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"BagNoItemTips")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"isBagSearch") 
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"isBagSearch") 
	    g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"updateBag",self.searchType,self.count,tab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Warehouse,"setBagSearchName",keyWord)
 
	end
end

function wnd_bagSearch:searchItemInWarehouse(keyWord)
	local _, BagItems = g_i3k_game_context:GetWarehouseInfoForType(self.warehouseType)
	local newTab=g_i3k_db.i3k_db_get_items_after_search(BagItems,keyWord)
	self.count=g_i3k_db.i3k_db_get_search_items_count(newTab)
	self:afterSearch(newTab,keyWord)
end

function wnd_create(layout)
	local wnd = wnd_bagSearch.new()
		wnd:create(layout)
	return wnd
end


 
