-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_fashion_dress_tips = i3k_class("wnd_fashion_dress_tips",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"

local STORAGE_OPEN_LVL = i3k_db_fashion_base_info.wardrobe_open_lvl  --衣橱和精纺功能开启等级

function wnd_fashion_dress_tips:ctor()
	self._id = nil
	self.fashionId = nil
	self.isShow = nil
end

function wnd_fashion_dress_tips:configure()
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
	widgets.storage_btn:onClick(self, self.onStorageBtn)

	self.spinning_btn = widgets.jingfangbtn  --精仿按钮
	widgets.jingfangbtn:onClick(self, self.onSpinningBtn)

	widgets.sale_btn:onClick(self, self.onSaleBtn)
	widgets.globel_btn:onClick(self, self.closeButton)
end

function wnd_fashion_dress_tips:refresh(id, isShow, getPathway, isWarehouse, sex, isStorage, isSpinning)
	self:updateTips(id, isShow)
	if isWarehouse then
		local str = isWarehouse.around == 1 and "取出仓库" or "存入仓库"
		self.use_label:setText(str)
		self.sale_btn:hide()
		self.storage_btn:hide()
		self.spinning_btn:hide()
		if isWarehouse.isCanSave then
			self.sale_btn:show()
			self.sale_btn:onClick(self, self.onSaleBtn, isWarehouse)
		end
	else
		self:updateUseTips(getPathway, sex)
		self:updateStorageBtn(isStorage)
		self:updateSpinningBtn(isSpinning)
	end
end

function wnd_fashion_dress_tips:updateTips(id, isShow)
	self._id = id
	if isShow then
		self.isShow = isShow
	end
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
	local prop = g_i3k_game_context:GetPropertyByFashionId(cfg.args1)
	local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
	self.fashionId = cfg.args1
	
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

	local cfg = g_i3k_db.i3k_db_get_fashion_cfg(self.fashionId)
	if cfg.fashionType == 2 then  --是否是时装形象
		local is_spinning = g_i3k_game_context:GetFashionIsSpinning(self.fashionId)
		self.is_spinning:setText(is_spinning and string.format("已精纺") or string.format("未精纺"))
		self.is_spinning:setTextColor(g_i3k_get_cond_color(is_spinning))
		self.is_spinning:show()
	else
		self.is_spinning:hide()
	end

	self:updateScroll(prop)
end

function wnd_fashion_dress_tips:updateScroll(prop)
	self.scroll:removeAllChildren()
	
	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(string.format("基础属性"))
	self.scroll:addItem(des)
	
	for k, v in ipairs(prop) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[v.id]
		local _desc = _t.desc
		_desc = _desc.." :"
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		des.vars.value:setText(i3k_get_prop_show(v.id, v.value))
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end
end

function wnd_fashion_dress_tips:updateUseTips(getPathway, sex)
	self.global:setVisible(self.isShow == nil)
	local test2 = g_i3k_db.i3k_db_get_fashion_is_wear(self.fashionId)
	if self.isShow then
		self.sale_btn:show()
		local desc
		if not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) > 0 then
			desc = string.format("启动")
		elseif not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) <= 0 then
			if (not g_i3k_db.i3k_db_get_fashion_by_sex(self.fashionId)) or (getPathway and getPathway ~= 1)then
				self.sale_btn:hide()
			end
			desc = string.format("购买")
		elseif g_i3k_db.i3k_db_get_fashion_is_wear(self.fashionId) then
			self.sale_btn:hide()
		elseif  g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then
			desc = string.format("穿戴")
			if not g_i3k_db.i3k_db_get_fashion_by_sex(self.fashionId) or g_i3k_game_context:GetFashionInStorage(self.fashionId) or not g_i3k_db.i3k_db_is_fashion_match_wear_bwtype(self.fashionId,g_i3k_game_context:GetTransformBWtype()) then
				self.sale_btn:hide();
			end
		end
		self.use_label:setText(desc)
	end
end

--衣橱按钮的显示和隐藏
function wnd_fashion_dress_tips:updateStorageBtn(isShowBtn)
	if not isShowBtn then
		self.storage_btn:setVisible(isShowBtn)
		return
	end
	local isShowStorage = false
	local cfg = g_i3k_db.i3k_db_get_fashion_cfg(self.fashionId)
	if cfg.fashionType == 2 then  --是否是时装形象
		if g_i3k_game_context:GetLevel() >= STORAGE_OPEN_LVL then
			if g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then  --是否激活该时装
				if not g_i3k_db.i3k_db_get_fashion_is_wear(self.fashionId) then  --是否装备了该时装
					if not g_i3k_game_context:GetFashionInStorage(self.fashionId) then  --是否已经存储在衣橱
						isShowStorage = true
					end
				end
			end
		end
	end
	self.storage_btn:setVisible(isShowStorage)
end

function wnd_fashion_dress_tips:onStorageBtn(sender)
	if not g_i3k_game_context:GetFashionIsSpinning(self.fashionId) then
		g_i3k_ui_mgr:PopupTipMessage("您需要至少精纺过一次此披风，方可放入衣橱")
	elseif g_i3k_game_context:GetStorageIsMax() then
		g_i3k_ui_mgr:PopupTipMessage("您的衣橱已满")
	else
		i3k_sbean.fashion_putwardrobe(self.fashionId)
	end
end

--精纺按钮的显示和隐藏
function wnd_fashion_dress_tips:updateSpinningBtn(isShowBtn)
	if not isShowBtn then
		self.spinning_btn:setVisible(isShowBtn)
		return
	end
	
	local isShowSpinning = false
	local cfg = g_i3k_db.i3k_db_get_fashion_cfg(self.fashionId)
	if cfg.fashionType == 2 then  --是否是时装形象
		if g_i3k_game_context:GetLevel() >= STORAGE_OPEN_LVL then
			if g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then  --是否激活该时装
				if not g_i3k_game_context:GetFashionInStorage(self.fashionId) then  --是否已经存储在衣橱
					isShowSpinning = true
				end
			end
		end
	end
	self.spinning_btn:setVisible(isShowSpinning)
end

function wnd_fashion_dress_tips:onSpinningBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FashionSpinning)
	g_i3k_ui_mgr:RefreshUI(eUIID_FashionSpinning, self.fashionId)
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
end

function wnd_fashion_dress_tips:onActivationBtn(sender)
	if not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then
		self:activationFashion()
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("您已经拥有此时装。"))
	end
end

function wnd_fashion_dress_tips:activationFashion()
	if not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then
		local desc = string.format("确定启动%s时装？", g_i3k_db.i3k_db_get_common_item_name(self._id))
		local fun = (function(ok)
			if ok then
				if g_i3k_game_context:GetLevel() >= g_i3k_db.i3k_db_get_common_item_level_require(self._id) then
					local id = self._id
					id = g_i3k_game_context:GetCommonItemCount(id) > 0 and id or -id
					i3k_sbean.bag_useitemfashion(id)
					g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
				else
					g_i3k_ui_mgr:PopupTipMessage(string.format("所需等级不足，少年加油阿！"))
				end
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("您已经拥有此时装。"))
	end
	
end

function wnd_fashion_dress_tips:onSaleBtn(sender, isWarehouse)
	if isWarehouse then
		local str = isWarehouse.around == 1 and "取出仓库(测试)" or "存入仓库(测试)"
		--g_i3k_ui_mgr:PopupTipMessage(str)
		g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
		if isWarehouse.around == 1 then
			i3k_sbean.goto_take_out_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		elseif isWarehouse.around == 2 then
			i3k_sbean.goto_put_in_warehouse(isWarehouse.id, isWarehouse.count, isWarehouse.warehouseType)
		end
	else
		if self.isShow then
			if not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) > 0 then --激活
				self:activationFashion()
			elseif not g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) and g_i3k_game_context:GetCommonItemCanUseCount(self._id) <= 0 then --购买
				local tmp = g_i3k_db.i3k_db_get_isShow_btn(self._id)
				if tmp and tmp.showBuyBtn == 1 and g_i3k_game_context:GetLevel() >= tmp.showLevel then
					g_i3k_logic:OpenVipStoreUI(tmp.showType, tmp.isBound, tmp.id)
				else
					g_i3k_logic:OpenVipStoreUI(3)
				end
				g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
				g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
			elseif g_i3k_db.i3k_db_get_fashion_is_wear(self.fashionId) then
				g_i3k_ui_mgr:PopupTipMessage(string.format("使用该时装中"))
			elseif  g_i3k_db.i3k_db_get_fashion_is_have(self.fashionId) then --穿戴时装
				i3k_sbean.fashion_upwear(self.fashionId)
				g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
			end
		end
	end
	
end

function wnd_fashion_dress_tips:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDressTips)
end

function wnd_create(layout)
	local wnd = wnd_fashion_dress_tips.new()
	wnd:create(layout)
	return wnd
end
