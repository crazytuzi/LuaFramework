-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_underwear_talentPoint_reset = i3k_class("wnd_underwear_talentPoint_reset",ui.wnd_base)

function wnd_underwear_talentPoint_reset:ctor()
	
end

function wnd_underwear_talentPoint_reset:configure()
	local widgets = self._layout.vars
	self._layout.vars.close:onClick(self,self.onCloseUI)
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.item_name= widgets.item_name
	self.item_count= widgets.item_count
	self.item_btn= widgets.item_btn
	self.item_suo= widgets.item_suo
	self.reset_btn= widgets.reset_btn
	self.reset_btn:onClick(self,self.onReset)
end

function wnd_underwear_talentPoint_reset:refresh(index,tab ,talentId)	
	self.index= index
	self.tab = tab 
	self:setPropData()
end

function wnd_underwear_talentPoint_reset:setPropData()
	self.prop = {}
	local index = 0
	local itemId = i3k_db_under_wear_alone.resetTalentUseItemId
	local itemNumsTab=i3k_db_under_wear_alone.resetTalentUseItemNums
	table.sort(itemNumsTab, function (a, b)
		return a<b
	end)
	local _,_,tiems = g_i3k_game_context:getUnderWearData()
	local index = #itemNumsTab
	local totalPropNum= itemNumsTab[tiems+1] 
	if  tiems+1> index then
		totalPropNum = itemNumsTab[index]
	end
	--需要的道具数目itemNumsTab[tiems+1]
	local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	local itemid = itemCount >= 0 and itemId or -itemId
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid))
	local count_color =totalPropNum <= itemCount and g_i3k_get_green_color() or g_i3k_get_red_color()
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	self.item_name:setTextColor(name_color)
	self.prop = {itemid=itemId, itemcount =totalPropNum}
	self.item_count:setText(itemCount.."/"..totalPropNum)
	self.item_count:setTextColor(count_color)
	self.canReset = totalPropNum <= itemCount
	self.item_btn:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
	end)
	self.item_suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemid))
end

function wnd_underwear_talentPoint_reset:onReset(sender)
	if self.canReset then
		i3k_sbean.upResetTalent(self.index ,self.tab,self.prop)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage("材料不足")	
	end
end

function wnd_underwear_talentPoint_reset:onCloseUI(sender)	
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Talent_Point_Reset)
end

function wnd_create(layout)
	local wnd = wnd_underwear_talentPoint_reset.new()
		wnd:create(layout)
	return wnd
end
