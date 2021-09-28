-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_underwear_rune_equip = i3k_class("wnd_underwear_rune_equip", ui.wnd_base)
--内甲解锁

function wnd_underwear_rune_equip:ctor()
end
function wnd_underwear_rune_equip:configure()
	local widgets = self._layout.vars
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self.wear_runeTab = {}
	for i=1, 6 do  --SoltItem1_bg  SoltItem1_icon SoltItem1_btn
		local SoltItem_bg =  string.format("SoltItem%s_bg",i)
		local SoltItem_icon = string.format("SoltItem%s_icon",i)
		local SoltItem_btn = string.format("SoltItem%s_btn",i)			
		self.wear_runeTab[i] = {SoltItem_bg= widgets[SoltItem_bg],SoltItem_icon= widgets[SoltItem_icon],SoltItem_btn= widgets[SoltItem_btn],}
	end
end


function wnd_underwear_rune_equip:refresh(rundid ,slotTag,curArmor )
	self.runid  = rundid
	self.showType  = slotTag
	self.curArmor  = curArmor
	self.soltGroupData  = g_i3k_game_context:getAnyUnderWearAnyData(curArmor,"soltGroupData")
	local data = self.soltGroupData[slotTag]	
	for k,v in ipairs(data.solts) do
		if v~=0 then
			self.wear_runeTab[k].SoltItem_icon:show()
			self.wear_runeTab[k].SoltItem_btn:show()
			-- self.wear_runeTab[k].SoltItem_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
			self.wear_runeTab[k].SoltItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
				
		else
			-- self.wear_runeTab[k].SoltItem_bg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
			self.wear_runeTab[k].SoltItem_icon:hide()
			--self.wear_runeTab[k].SoltItem_btn:hide()
		end
		self.wear_runeTab[k].SoltItem_btn:onClick(self, self.onUnloadItem,{slotTag = slotTag,slotIndex = k,runeid = v})--长按按钮
	end	
end
function wnd_underwear_rune_equip:onUnloadItem(sender ,tab)
	self.tab = tab
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune,"setRuneEquip",tab,self.runid,self.showType,self.curArmor )
	local solts = self.soltGroupData[self.showType].solts
	local runeId = self.runid
	local itemid =runeId >0 and runeId or -runeId
	self.iconPath= g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole())
	local mutexTab = i3k_db_under_wear_rune[itemid].mutexRuneIdTab
	local equipRuneName
	local wantEquipRuneName = i3k_db_under_wear_rune[itemid].runeName
	
	if solts[tab.slotIndex] == runeId then
		g_i3k_ui_mgr:PopupTipMessage("自身替换无效")
		self:onReturn()
		return
	end
	self.canEquip = true
	for i,v in ipairs(solts) do 
		for k,value in ipairs(mutexTab) do
			if value ==v or value ==-v then
				self.canEquip = false
				equipRuneName = i3k_db_under_wear_rune[value].runeName
				break
			else
				self.canEquip = true
			end
		end
		if not self.canEquip then
			break
		end
	end
	if 	self.canEquip then	
		if solts[tab.slotIndex]== 0 then --直接镶嵌
			self:runeToSoltEquip(tab.slotIndex,runeId,runeId ,false,runeId)
			self:setLeftShow(tab.slotIndex) --应该返回成功后安装
			self:onReturn()
			return
		else
			-- 代表 此处有装备
			self:runeToSoltEquip(tab.slotIndex,runeId ,runeId,true ,solts[tab.slotIndex])
			self:setLeftShow(tab.slotIndex) --应该返回成功后安装
			self:onReturn()
			return
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s与%s%s",equipRuneName,wantEquipRuneName,"不可同时装备"))
		self:onReturn()
		return
	end
end

function wnd_underwear_rune_equip:runeToSoltEquip(index,runeId ,equipId ,bool ,id)
	if g_i3k_game_context:runeLangIsGet(self.curArmor, self.showType, equipId, index, nil) then
		return
	end
	--todo 发协议 内甲id 插槽id 槽内id  符文id
	i3k_sbean.runeToSoltEquip(self.curArmor ,self.showType ,index ,runeId,equipId,bool ,id) 
	--回来要刷新界面
end

function wnd_underwear_rune_equip:setLeftShow()
	self.wear_runeTab[self.tab.slotIndex].SoltItem_btn:show()
	self.wear_runeTab[self.tab.slotIndex].SoltItem_btn:show()
	self.wear_runeTab[self.tab.slotIndex].SoltItem_icon:setImage(self.iconPath)
end

function wnd_underwear_rune_equip:onReturn()
	self:onCloseUI()
end

function wnd_underwear_rune_equip:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Rune_Equip)
end


function wnd_create(layout)
	local wnd = wnd_underwear_rune_equip.new();
	wnd:create(layout);
	return wnd;
end


