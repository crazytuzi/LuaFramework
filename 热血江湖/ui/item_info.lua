-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_item_info = i3k_class("wnd_item_info",ui.wnd_base)

function wnd_item_info:ctor()
	self.item_id = nil
	self.isMove = false
end

function wnd_item_info:configure()
	local widgets = self._layout.vars
	
	self.itemName_label = widgets.itemName_label
	self.item_bg = widgets.item_bg 
	self.item_icon = widgets.item_icon 
	self.itemGrade_lable = widgets.itemGrade_lable 
	self.itemDesc_label = widgets.itemDesc_label 
	self.get_label = widgets.get_label 
	self.sale = widgets.sale
	self.skillPanel = widgets.skillPanel
	self.mainPanel = widgets.mainPanel
	self.scroll = widgets.scroll
	
	
	self.close = widgets.globel_bt
	self.close:onTouchEvent(self, self.closeButton)
end


function wnd_item_info:refresh(id, hideBtn)
	
	self.item_id = id
	
	local icon = g_i3k_db.i3k_db_get_common_item_icon_path(self.item_id,i3k_game_context:IsFemaleRole())
	local name = g_i3k_db.i3k_db_get_common_item_name(self.item_id)
	local desc = g_i3k_db.i3k_db_get_common_item_desc(self.item_id)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(self.item_id)
	local name_colour = g_i3k_get_color_by_rank(item_rank)
	local grade_icon = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item_id)
	local get_way = g_i3k_db.i3k_db_get_common_item_source(self.item_id)
	
	self.item_icon:setImage(icon)
	self.itemName_label:setText(name)
	self.itemDesc_label:setText(desc)
	self.itemName_label:setTextColor(name_colour)
	self.item_bg:setImage(grade_icon)
	self.get_label:setText(get_way)
	
	self.itemGrade_lable:hide()
	local lvlReq = g_i3k_db.i3k_db_get_common_item_level_require(id)
	self.itemGrade_lable:setText(i3k_get_string(g_UseItem_Need_Level, lvlReq))
	self.itemGrade_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= lvlReq))
	self.itemGrade_lable:setVisible(lvlReq > 1)
	
	self.sale:hide()
	if not hideBtn then
		local tmp = g_i3k_db.i3k_db_get_isShow_btn(id)
		if tmp and tmp.showBuyBtn == 1 then
			if g_i3k_game_context:GetLevel() >= tmp.showLevel then
				self.sale:show()
				if i3k_db_new_item[id] and i3k_db_new_item[id].type == UseItemDiaryDecorate then
					if g_i3k_game_context:isHaveMoodDiaryDecorate(i3k_db_new_item[id].args1) then
						self._layout.vars.label2:setText("使用")
						self.sale:onClick(self, self.changeDiaryDecorate, i3k_db_new_item[id].args1)
					elseif g_i3k_game_context:GetCommonItemCanUseCount(id) > 0 then
						self._layout.vars.label2:setText("启动")
						self.sale:onClick(self, self.activiteDiaryDecorate, i3k_db_new_item[id].args1)
					else
						self._layout.vars.label2:setText("购买")
						tmp.id = id
						self.sale:onClick(self, self.intoVipStore, tmp)
					end
				elseif i3k_db_new_item[id] and i3k_db_new_item[id].type == UseItemHouseSkin then
					if g_i3k_game_context:isHaveHouseSkin(i3k_db_new_item[id].args1) then
						self._layout.vars.label2:setText("使用")
						self.sale:onClick(self, self.changeHouseSkin, i3k_db_new_item[id].args1)
					elseif g_i3k_game_context:GetCommonItemCanUseCount(id) > 0 then
						self._layout.vars.label2:setText("启动")
						self.sale:onClick(self, self.activiteHouseSkin, id)
					else
						self._layout.vars.label2:setText("购买")
						tmp.id = id
						self.sale:onClick(self, self.intoVipStore, tmp)
					end
				else
					tmp.id = id
					self.sale:onClick(self, self.intoVipStore, tmp)
				end
			end
		end
		
		if math.abs(id) == g_BASE_ITEM_COIN then
			self.sale:show()
			self.sale:onClick(self, self.goToBuyCoin)
		end
	end
	local isShowSkillPanel = i3k_show_skill_item_description(self.scroll, id)
	self.skillPanel:setVisible(isShowSkillPanel)
	if not isShowSkillPanel and not self.isMove then
		self.isMove = true
		local skillPanelPosition = self.skillPanel:getPosition()
		local mainPanelPosition = self.mainPanel:getPosition()
		self.mainPanel:setPosition((skillPanelPosition.x + mainPanelPosition.x) / 2, mainPanelPosition.y)
	end
end

function wnd_item_info:intoVipStore(sender, tmp)
	g_i3k_ui_mgr:CloseUI(eUIID_ItemInfo)
	if g_i3k_db.i3k_db_get_base_item_cfg(tmp.id) then
		g_i3k_logic:OpenBuyBaseItemUI(tmp.id)
	else
		g_i3k_logic:OpenVipStoreUI(tmp.showType, tmp.isBound, tmp.id)
	end
end

function wnd_item_info:goToBuyCoin(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ItemInfo)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_item_info:closeButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_ItemInfo)
	end
end

function wnd_item_info:changeDiaryDecorate(sender, decarateId)
	i3k_sbean.mood_diary_change_decorate(decarateId)
	self:onCloseUI()
end

function wnd_item_info:activiteDiaryDecorate(sender, decarateId)
	i3k_sbean.mood_diary_activite_decorate(decarateId)
	self:onCloseUI()
end

function wnd_item_info:changeHouseSkin(sender, skinId)
	local houseLvl = g_i3k_game_context:getCurHouseLevel()
	if i3k_db_home_land_house_skin[skinId].needHouseLvl > houseLvl then
		g_i3k_ui_mgr:PopupTipMessage(string.format("需要房屋%s级才能使用", i3k_db_home_land_house_skin[skinId].needHouseLvl))
	else
		i3k_sbean.house_skin_select(skinId)
	end
	self:onCloseUI()
end

function wnd_item_info:activiteHouseSkin(sender, itemId)
	i3k_sbean.bag_use_house_skin_item(itemId)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_item_info.new()
	wnd:create(layout)
	return wnd
end
