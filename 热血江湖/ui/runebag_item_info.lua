-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_runeBag_Item_Info = i3k_class("wnd_runeBag_Item_Info",ui.wnd_base)

function wnd_runeBag_Item_Info:ctor()
	self.id = 0
	self.use_times = 0
	self._assignCount = 0
end

function wnd_runeBag_Item_Info:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self, self.closeButton)

	self.itemName_label = widgets.itemName_label
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	
	self.itemDesc_label = widgets.itemDesc_label
	self.get_label = widgets.get_label

	self.pushBag_Btn = widgets.pushBag_Btn
	self.pushLabel = widgets.pushLabel	
	self.pushBag_Btn:onClick(self, self.onPushBagBtn)
	
	self.equipBtn= widgets.equipBtn
	self.equipLabel	 = widgets.equipLabel	
	self.equipBtn:onClick(self, self.onEquipBtn)

end

--当前内甲id，当前插槽id，当前符文id，标记，tab
function wnd_runeBag_Item_Info:refresh(curArmorId ,soltType,curRuneId,index ,tab)
	--index 标记 卸下还是提取
	--slotTag 卸下时 表示为哪套插槽
	if tab then
		self.tab = tab 
	end	
	self.curArmorId = curArmorId
	self.soltType = soltType
	self.id = curRuneId
	local itemid  = curRuneId > 0 and curRuneId or -curRuneId
	local data = i3k_db_under_wear_rune[itemid]

	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemid)

	self.itemName_label:setTextColor(g_i3k_get_color_by_rank(item_rank))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	
	self.itemDesc_label:setText(data.runeAttr)
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(itemid))
	self.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))	
	self:showBtn(index)
end

function wnd_runeBag_Item_Info:showBtn(index)
	self.index = index
	self.equipBtn:hide()
	if index ==1 then --提取
		self.pushLabel:setText("提取")
		self.equipBtn:show()
	elseif  index ==2 then
		self.pushLabel:setText("卸下")
	elseif index == 3 then
		self.pushBag_Btn:hide()
	end
end

function wnd_runeBag_Item_Info:onPushBagBtn(sender)
	if self.index ==1 then --提取		
		g_i3k_ui_mgr:OpenUI(eUIID_RuneBagPopNum)
		g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagPopNum, self.id, g_i3k_game_context:GetRuneItemCount(self.id))
		self:closeButton()
	elseif self.index ==2 then  --卸下
		--todo 发协议 内甲id 插槽id 槽内id  符文id  
		--{ underWear = self.index ,slotGroupIndex = self.showType , slotIndex = slotTag,runeId = runeId}
		--前四个位需要参数，第五位为是卸载标记 后两个标记 是否为替换镶嵌
		i3k_sbean.runeToSoltEquip(self.tab.underWear ,self.tab.slotGroupIndex ,self.tab.slotIndex  ,0 ,self.tab.runeId,false ,self.tab.runeId) 
		self:closeButton()
	else
			
	end	
end

function wnd_runeBag_Item_Info:onEquipBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Under_Wear_Rune_Equip)
	g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Rune_Equip, self.id ,self.soltType,self.curArmorId )
	self:closeButton()
end

function wnd_runeBag_Item_Info:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RuneBagItemInfo)
end

function wnd_create(layout)
	local wnd = wnd_runeBag_Item_Info.new()
		wnd:create(layout)
	return wnd
end
