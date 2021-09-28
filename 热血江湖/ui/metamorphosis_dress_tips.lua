-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")
-------------------------------------------------------

wnd_metamorphosis_dress_tips = i3k_class("wnd_metamorphosis_dress_tips",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/sztipst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"

local STORAGE_OPEN_LVL = i3k_db_fashion_base_info.wardrobe_open_lvl  --衣橱和精纺功能开启等级

function wnd_metamorphosis_dress_tips:ctor()
	self._id = nil
	self.metamorphosisID = nil
end

function wnd_metamorphosis_dress_tips:configure()
	local widgets = self._layout.vars
	
	self.item_name = widgets.item_name
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.power_value = widgets.power_value
	self.level_label = widgets.level_label
	self.is_spinning = widgets.is_free  --精纺标志
	self.get_label = widgets.get_label
	self.scroll = widgets.scroll
	self.use_label = widgets.use_label
	self.sale_btn = widgets.sale_btn
	self.global = widgets.global
	self.storage_btn = widgets.storage_btn  --衣橱按钮
	self.itemsTypeName = widgets.part1		--类型
	widgets.storage_btn:onClick(self, self.onStorageBtn)

	self.spinning_btn = widgets.jingfangbtn  --精仿按钮
	widgets.jingfangbtn:onClick(self, self.onSpinningBtn)
           
	widgets.sale_btn:onClick(self, self.onSaleBtn)
	widgets.globel_btn:onClick(self, self.closeButton)
end

function wnd_metamorphosis_dress_tips:refresh(id, isWarehouse)
	self:updateTips(id)
	if isWarehouse then
		local str = isWarehouse.around == 1 and i3k_get_string(1597) or i3k_get_string(1598)
		self.use_label:setText(str)
		self.sale_btn:hide()
		self.storage_btn:hide()
		self.spinning_btn:hide()
		if isWarehouse.isCanSave then
			self.sale_btn:show()
			self.sale_btn:onClick(self, self.onSaleBtn, isWarehouse)
		end
	else
		self:updateUseTips(id)
	end
	self.storage_btn:setVisible(false)
	self.spinning_btn:setVisible(false)
	self.itemsTypeName:setText(i3k_get_string(1573))
	--self:updateSpinningBtn(isSpinning)
end

function wnd_metamorphosis_dress_tips:updateTips(id)
	self._id = id
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
	local prop = g_i3k_game_context:GetPropertyByMetamorphosisId(cfg.args1)
	local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
	self.metamorphosisID = cfg.args1
	
	local lvlReq = g_i3k_db.i3k_db_get_common_item_level_require(id)
	self.level_label:setVisible(lvlReq > 1)
	local str = string.format("%s级", lvlReq)
	self.level_label:setText(str)
	self.level_label:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= lvlReq ))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(id))
	self.power_value:setText(power)

	self.is_spinning:hide()

	self:updateScroll(prop)
end

function wnd_metamorphosis_dress_tips:updateScroll(prop)
	self.scroll:removeAllChildren()

	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(i3k_get_string(5118))
	self.scroll:addItem(des)
	
	for k, v in ipairs(prop) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[v.id]
		local _desc = _t.desc
		_desc = _desc.." :"..i3k_get_prop_show(v.id, v.value)
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		--des.vars.value:setText(i3k_get_prop_show(v.id, v.value))
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end
	
	local changeID = i3k_db_metamorphosis[self.metamorphosisID ].changeID
	local skills = i3k_db_missionmode_cfg[changeID].skills
	if skills[1].skillid == 0 then return end
	local skill = require(LAYER_ZBTIPST3)()
	skill.vars.desc:setText(i3k_get_string(1577))
	self.scroll:addItem(skill)
	
	for k, v in ipairs(skills) do
		if v.skillid == 0 then break end
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_skills[v.skillid];
		local _desc = _t.name
		_desc = _desc.." :".._t.desc
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		--des.vars.value:setText(_t.desc)
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end
end

function wnd_metamorphosis_dress_tips:updateUseTips(id)
	self.global:setVisible(false)
	
	self.sale_btn:show()
	local desc
	if not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) > 0 then
		desc = i3k_get_string(1581)
	elseif not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) <= 0 then
		local tmp = g_i3k_db.i3k_db_get_isShow_btn(id)
		if  not tmp  then	
			self.sale_btn:hide()
		end
		desc = i3k_get_string(1582)
	elseif g_i3k_db.i3k_db_get_metamorphosis_is_wear(self.metamorphosisID) then
		self.sale_btn:hide()
	elseif  g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) then
		desc = i3k_get_string(1583)		
	end
	self.use_label:setText(desc)
end


--[[
function wnd_metamorphosis_dress_tips:onActivationBtn(sender)
	if not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) then
		self:activationFashion()
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("您已经拥有此时装。"))
	end
end--]]

function wnd_metamorphosis_dress_tips:activationFashion()
	if not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) then
		local desc = i3k_get_string(1580, g_i3k_db.i3k_db_get_common_item_name(self._id))
		local fun = (function(ok)
			if ok then
				if g_i3k_game_context:GetLevel() >= g_i3k_db.i3k_db_get_common_item_level_require(self._id) then
					local id = self._id
					id = g_i3k_game_context:GetCommonItemCount(id) > 0 and id or -id
					i3k_sbean.bag_metamorphosis_activation(id)
					g_i3k_ui_mgr:CloseUI(eUIID_MetamorphosisDressTips)
				else
					g_i3k_ui_mgr:PopupTipMessage(string.format("所需等级不足，少年加油阿！"))
				end
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1578))
	end
	
end

function wnd_metamorphosis_dress_tips:onSaleBtn(sender, isWarehouse)
    if isWarehouse then
		--local str = isWarehouse.around == 1 and "取出仓库(测试)" or "存入仓库(测试)"
		--g_i3k_ui_mgr:PopupTipMessage(str)
		g_i3k_ui_mgr:CloseUI(eUIID_MetamorphosisDressTips)
		if isWarehouse.around == 1 then
			i3k_sbean.goto_take_out_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		elseif isWarehouse.around == 2 then
			i3k_sbean.goto_put_in_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		end
	else
		if not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) > 0 then --激活
			self:activationFashion()
		elseif not g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) <= 0 then --购买
			local tmp = g_i3k_db.i3k_db_get_isShow_btn(self._id)
			if tmp and tmp.showBuyBtn == 1 and g_i3k_game_context:GetLevel() >= tmp.showLevel then
				g_i3k_logic:OpenVipStoreUI(tmp.showType, tmp.isBound, tmp.id)
			else
				g_i3k_logic:OpenVipStoreUI(3)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_MetamorphosisDressTips)
			g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
		elseif g_i3k_db.i3k_db_get_metamorphosis_is_wear(self.metamorphosisID) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1579))
		elseif  g_i3k_db.i3k_db_get_metamorphosis_is_have(self.metamorphosisID) then --穿戴时装
			i3k_sbean.metamorphosis_set(self.metamorphosisID)
			g_i3k_ui_mgr:CloseUI(eUIID_MetamorphosisDressTips)
		end
	end
	
end

function wnd_metamorphosis_dress_tips:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_MetamorphosisDressTips)
end

function wnd_create(layout)
	local wnd = wnd_metamorphosis_dress_tips.new()
	wnd:create(layout)
	return wnd
end
