-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suit_equip = i3k_class("wnd_suit_equip", ui.wnd_base)

local LAYER_TZJMT	= "ui/widgets/tzjmt"
local LAYER_TZSXT	= "ui/widgets/tzjmt2"

--激活和未激活的图片
local is_activete = {1074,1075}
--专属和其他套装title
local title_icon = {1080,1081}

function wnd_suit_equip:ctor()
	self._all_att_root = {} 
	self.state = true
	self.suit_id = 0
end

function wnd_suit_equip:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	widgets.otherSuit_btn:onTouchEvent(self,self.onOtherSuitBtn)
	widgets.mySuit_btn:onTouchEvent(self,self.onMySuitBtn)
	widgets.mySuit_btn:stateToPressed()
	
	self.title_icon = self._layout.vars.title_icon 
	
	self.all_item_scroll = self._layout.vars.all_item_scroll
	self.item_scroll = self._layout.vars.item_scroll 
	self.suit_count = self._layout.vars.suit_count
	self.exp_slider = self._layout.vars.exp_slider
end

function wnd_suit_equip:refresh()
	if self.state then
		self:SetMyClassTypeData()
	else
		self:SetOtherClassTypeData()
	end
end

function wnd_suit_equip:SetMyClassTypeData()
	local _t = g_i3k_game_context:GetSuitData()
	self.title_icon:setImage(g_i3k_db.i3k_db_get_icon_path(title_icon[1]))
	local _temp_t = g_i3k_game_context:GetHaveSuitEquipData()
	local have_data = _temp_t.data2
	local effect_count = 0
	local equipData =_t.myData

	table.sort(equipData,function (a,b)
		return a.id < b.id
	end)
	local totle_num = _t.myCount

	self.item_scroll:removeAllChildren()
	local width = self.item_scroll:getContentSize().width
	self.item_scroll:setContainerSize(width, 0)
	local index = 0
	local suitIndex = 1
	for k,v in ipairs(equipData) do
		index = index + 1
		local item  = require(LAYER_TZJMT)()
		local is_have_icon = item.vars.is_have_icon
		is_have_icon:setImage(g_i3k_db.i3k_db_get_icon_path(is_activete[1])) 
		local tmp_equips = {}
		local tmp = v
		for a = 1, 6 do
			local tmp_root = string.format("equip%sRoot",a)
			item.vars[tmp_root]:hide()
			local tmp_id = string.format("part%sID",a)
			local equipid = tmp[tmp_id]
			if equipid ~= 0 then
				table.insert(tmp_equips,equipid)
			end
		end
		local tmp_args = {}
		tmp_args.id = tmp.id
		tmp_args.classType = tmp.classType
		if self.suit_id ~= 0 and self.suit_id == tmp.id then
			suitIndex = index
		end
		item.vars.detail_btn:onClick(self,self.onAttributeBtn,tmp_args)
		item.vars.suitName:setText(tmp.name)
		local is_have = true 
		for a = 1, tmp.count do
			local tmp_root = string.format("equip%sRoot",a)
			item.vars[tmp_root]:show()
			local tmp_bg = string.format("equip%sBg_icon",a)
			local equipBg = item.vars[tmp_bg]
			local tmp_icon = string.format("equip%s_icon",a)
			local equipIcon = item.vars[tmp_icon]
			
			local tmp_btn = string.format("equip_btn%s",a)
			local equip_btn = item.vars[tmp_btn]
			
			local equipid = tmp_equips[a]
			
			equip_btn:onClick(self,self.onItemTips,equipid)
			equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipid,g_i3k_game_context:IsFemaleRole()))
			equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipid))
			if have_data[equipid] then
				equipIcon:enable()
				equipBg:enable()
			else
				equipIcon:disable()
				equipBg:disable()
				is_have = false
			end
		end
		if not is_have then
			is_have_icon:setImage(g_i3k_db.i3k_db_get_icon_path(is_activete[2]))
		end
		self.item_scroll:addItem(item)
	end
	self.item_scroll:jumpToChildWithIndex(suitIndex)
	effect_count = g_i3k_db.i3k_db_get_suitEquip_effect_data(equipData)
	local tmp_str = string.format("%s/%s",effect_count,totle_num)
	self.suit_count:setText(tmp_str)
	self.exp_slider:setPercent(effect_count/totle_num*100)
	self:updateMyAttribute()
end

function wnd_suit_equip:SetOtherClassTypeData()
	local _t = g_i3k_game_context:GetSuitData()
	self.title_icon:setImage(g_i3k_db.i3k_db_get_icon_path(title_icon[2]))
	local equipData =_t.otherData
	table.sort(equipData,function (a,b)
		return a.id < b.id
	end)
	local totle_num = _t.otherCount

	local _temp_t = g_i3k_game_context:GetHaveSuitEquipData()
	local have_data = _temp_t.data2
	local effect_count = 0

	self.item_scroll:removeAllChildren()
	local width = self.item_scroll:getContentSize().width
	self.item_scroll:setContainerSize(width, 0)
	
	local index = 0
	local suitIndex = 1
	for k,v in ipairs(equipData) do
		index = index + 1
		local item  = require(LAYER_TZJMT)()
		local is_have_icon = item.vars.is_have_icon 
		is_have_icon:setImage(g_i3k_db.i3k_db_get_icon_path(is_activete[1]))
		local tmp_equips = {}
		local tmp = v
		for a= 1, 6 do
			local tmp_root = string.format("equip%sRoot",a)
			item.vars[tmp_root]:hide()
			local tmp_id = string.format("part%sID",a)
			local equipid = tmp[tmp_id]
			if equipid ~= 0 then
				table.insert(tmp_equips,equipid)
			end
		end
		local tmp_args = {}
		tmp_args.id = tmp.id
		tmp_args.classType = tmp.classType
		if self.suit_id ~= 0 and self.suit_id == tmp.id then
			suitIndex = index
		end
		item.vars.detail_btn:onClick(self,self.onAttributeBtn,tmp_args)
		item.vars.suitName:setText(tmp.name)
		local is_have = true 
		for a = 1, tmp.count do
			local tmp_root = string.format("equip%sRoot",a)
			item.vars[tmp_root]:show()
			local tmp_bg = string.format("equip%sBg_icon",a)
			local equipBg = item.vars[tmp_bg]
			local tmp_icon = string.format("equip%s_icon",a)
			local equipIcon = item.vars[tmp_icon]
			local equipid = tmp_equips[a]
			local tmp_btn = string.format("equip_btn%s",a)
			local equip_btn = item.vars[tmp_btn]
			
			equip_btn:onClick(self,self.onItemTips,equipid)
			equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipid,i3k_game_context:IsFemaleRole()))
			equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipid))
			if have_data[equipid] then
				equipIcon:enable()
				equipBg:enable()
			else
				equipIcon:disable()
				equipBg:disable()
				is_have = false 
			end
		end
		if not is_have then
			is_have_icon:setImage(g_i3k_db.i3k_db_get_icon_path(is_activete[2]))
		end
		self.item_scroll:addItem(item)
	end
	self.item_scroll:jumpToChildWithIndex(suitIndex)
	effect_count = g_i3k_db.i3k_db_get_suitEquip_effect_data(equipData)
	local tmp_str = string.format("%s/%s",effect_count,totle_num)
	self.suit_count:setText(tmp_str)
	self.exp_slider:setPercent(effect_count/totle_num*100)
	self:updateOtherAttribute()
end

function wnd_suit_equip:onItemTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end 

function wnd_suit_equip:updateMyAttribute()
	self:updateAttributeState()
	local _t = g_i3k_game_context:GetSuitData()
	local all_att = g_i3k_game_context:GetEffectSuits()
	local tmp_att = {}
	
	local my_attribute = _t.my_attribute
	self.all_item_scroll:removeAllChildren()
	for k,v in pairs(all_att.mysuit) do
		for a,b in ipairs(v) do
			if b.attribute ~= 0 then
				if tmp_att[b.attribute] then
					tmp_att[b.attribute] = tmp_att[b.attribute] + b.value
				else
					tmp_att[b.attribute] =  b.value
				end
			end 
		end
	end 
	local _index = 0
	for k,v in ipairs(my_attribute) do 
		_index = _index + 1
		local mark = _index%2
		local _layer = require(LAYER_TZSXT)()
		local bg_root1 = _layer.vars.bg_root1 
		local bg_root2 = _layer.vars.bg_root2
		if mark == 0 then
			bg_root1:show()
			bg_root2:hide()
		else
			bg_root1:hide()
			bg_root2:show()
		end
		local att_icon = _layer.vars.att_icon
		local att_name = _layer.vars.att_name
		local att_value = _layer.vars.att_value
		local value = tmp_att[v.attribute] or 0
		att_icon:setImage(g_i3k_db.i3k_db_get_attribute_icon(v.attribute))
		att_name:setText(g_i3k_db.i3k_db_get_attribute_name(v.attribute))
		--att_name:setTextColor(g_i3k_db.i3k_db_get_attribute_text_color(v.attribute))
		local tmp_str = string.format("+%s",value)
		att_value:setText(tmp_str)
		--att_value:setTextColor(g_i3k_db.i3k_db_get_attribute_value_color(v.attribute))
		self.all_item_scroll:addItem(_layer)
	end 
	

end 

function wnd_suit_equip:updateAttributeState()
	for k,v in ipairs(self._all_att_root) do
		v.attributeRoot:hide()
	end
end 

function wnd_suit_equip:updateOtherAttribute()
	self:updateAttributeState()
	local all_att = g_i3k_game_context:GetEffectSuits()
	local tmp_att = {}
	local _t = g_i3k_game_context:GetSuitData()
	local other_attribute = _t.other_attribute
	self.all_item_scroll:removeAllChildren()
	for k,v in pairs(all_att.othersuit) do
		for a,b in ipairs(v) do
			if b.attribute ~= 0 then
				if tmp_att[b.attribute] then
					tmp_att[b.attribute] = tmp_att[b.attribute] + b.value
				else
					tmp_att[b.attribute] =  b.value
				end
			end 
		end
	end 
	local _index = 0
	for k,v in ipairs(other_attribute) do 
		_index = _index + 1
		local mark = _index%2
		local _layer = require(LAYER_TZSXT)()
		local bg_root1 = _layer.vars.bg_root1 
		local bg_root2 = _layer.vars.bg_root2
		if mark == 0 then
			bg_root1:show()
			bg_root2:hide()
		else
			bg_root1:hide()
			bg_root2:show()
		end
		local att_icon = _layer.vars.att_icon
		local att_name = _layer.vars.att_name
		local att_value = _layer.vars.att_value
		local value = tmp_att[v.attribute] or 0
		att_icon:setImage(g_i3k_db.i3k_db_get_attribute_icon(v.attribute))
		att_name:setText(g_i3k_db.i3k_db_get_attribute_name(v.attribute))
		--att_name:setTextColor(g_i3k_db.i3k_db_get_attribute_text_color(v.attribute))
		local tmp_value = math.modf(value * g_AddArgs)
		local tmp_str = string.format("+%s",tmp_value)
		att_value:setText(tmp_str)
		--att_value:setTextColor(g_i3k_db.i3k_db_get_attribute_value_color(v.attribute))
		self.all_item_scroll:addItem(_layer)
	end
end 

function wnd_suit_equip:onAttributeBtn(sender,args)
	self.suit_id = args.id
	g_i3k_ui_mgr:OpenUI(eUIID_SuitAttributeTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuitAttributeTips,args.id,args.classType)
	
end

function wnd_suit_equip:onMySuitBtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local widgets = self._layout.vars
		widgets.mySuit_btn:stateToPressed()
		widgets.otherSuit_btn:stateToNormal()
		self.state = true
		self:SetMyClassTypeData()
	end
end

function wnd_suit_equip:onOtherSuitBtn(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local widgets = self._layout.vars
		widgets.mySuit_btn:stateToNormal()
		widgets.otherSuit_btn:stateToPressed()
		self.state = false
		self:SetOtherClassTypeData()
	end
end

--[[function wnd_suit_equip:onCloseBtn(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_SuitEquip)
	end
end--]]

function wnd_create(layout)
	local wnd = wnd_suit_equip.new();
		wnd:create(layout);
	return wnd;
end
