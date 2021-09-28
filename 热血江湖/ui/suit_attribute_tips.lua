-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_suit_attribute_tips = i3k_class("wnd_suit_attribute_tips", ui.wnd_base)

function wnd_suit_attribute_tips:ctor()
	self._id = nil
	self._classType = nil 
end

function wnd_suit_attribute_tips:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.buy_btn = self._layout.vars.buy_btn
	self.buy_btn:onTouchEvent(self,self.onBuy)
end

function wnd_suit_attribute_tips:refresh(id,classType)
	self._id = id
	self._classType = classType
	
	local tmp_data = g_i3k_db.i3k_db_get_suitEquip_lastOne(id)
	if tmp_data.count == g_i3k_db.i3k_db_get_suitEquip_have_count(id) then
		self.buy_btn:hide()
	end 
	self:setData()
end

function wnd_suit_attribute_tips:setData()

	local widgets = self._layout.vars
	local tmp_data = g_i3k_db.i3k_db_get_suitEquip_lastOne(self._id)
	local have_count = g_i3k_db.i3k_db_get_suitEquip_have_count(self._id)
	widgets.name_label:setText(tmp_data.name)
	local tmp_str = string.format("已经收集套装：%s/%s",have_count,tmp_data.count)
	widgets.count_label:setText(tmp_str)
	local  my_type = g_i3k_game_context:GetRoleType()
	for i=1,5 do
		local tmp_str = string.format("attribute_name%s",i)
		local attribute_name = widgets[tmp_str]
		local tmp_str = string.format("attribute%s",i)
		local _attribute = tmp_data[tmp_str]
		local tmp_root = string.format("att_root%s",i)
		local att_root = self._layout.vars[tmp_root]
		local tmp_icon = string.format("att_icon%s",i)
		local att_icon = self._layout.vars[tmp_icon]
		if _attribute ~= 0 then
			local name = g_i3k_db.i3k_db_get_attribute_name(_attribute)
			local textColor = g_i3k_db.i3k_db_get_attribute_text_color(_attribute)
			local valuColor = g_i3k_db.i3k_db_get_attribute_value_color(_attribute)
			attribute_name:setText(name)
			--attribute_name:setTextColor(textColor)
			att_icon:setImage(g_i3k_db.i3k_db_get_attribute_icon(_attribute))
			local tmp_str = string.format("value%s",i)
			local value = widgets[tmp_str]
			local tmp_str = string.format("value%s",i)
			local tmp_value = tmp_data[tmp_str]
			if my_type ~= self._classType then
				tmp_value = math.modf(tmp_value * g_AddArgs)
			end
			local tmp_str = string.format("+%s",tmp_value)
			value:setText(tmp_str)
			--value:setTextColor(valuColor)
		else
			att_root:hide()
		end 
	end
end

function wnd_suit_attribute_tips:onBuy(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tmp_data = g_i3k_db.i3k_db_get_suitEquip_lastOne(self._id)
		local have_count = g_i3k_db.i3k_db_get_suitEquip_have_count(self._id)
		local max_count = tmp_data.count
		local buyEquipId = g_i3k_db.i3k_db_get_suitEquip_last_id(self._id)
		local cfg = g_i3k_db.i3k_db_get_all_suit_data(self._id)
		if max_count - have_count == 1 then
			if g_i3k_game_context:IsBagEnough({[buyEquipId] = 1}) then
				local ingot = cfg.ingot
				local suit_id = self._id
				local fun = (function(ok)
					if ok then
						if g_i3k_game_context:GetDiamond(true) < ingot then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(216))
						else
							i3k_sbean.buy_suite(suit_id, buyEquipId)
						end
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(335, ingot, g_i3k_db.i3k_db_get_common_item_name(buyEquipId)), fun)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("只有剩一件装备时，才可以购买")
			return
		end
	end
end

--[[function wnd_suit_attribute_tips:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_SuitAttributeTips)
	end
end--]]

function wnd_create(layout)
	local wnd = wnd_suit_attribute_tips.new();
		wnd:create(layout);
	return wnd;
end
