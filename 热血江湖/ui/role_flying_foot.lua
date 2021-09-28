-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_flying_foot = i3k_class("wnd_role_flying_foot", ui.wnd_base)

local FOOTEFFECT = "ui/widgets/feishengjytxt"

function wnd_role_flying_foot:ctor()
	self._id = 1
	self._effects = {}
end

function wnd_role_flying_foot:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.unlockBtn:onClick(self, self.onUnlockBtn)
	self._layout.vars.itemBtn:onClick(self, self.onItemTips)
end

function wnd_role_flying_foot:refresh(effects)
	self._effects = effects
	self:setFootScroll()
	self:setRightItemData()
	self:changeHeroModel()
end

function wnd_role_flying_foot:changeHeroModel()
	local hero = i3k_game_get_player_hero()
	ui_set_hero_model(self._layout.vars.model, hero, g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), false, nil, i3k_db_common.engine.defaultRunAction)
	if hero then
		local effectId = 0
		if g_i3k_game_context:GetTransformBWtype() == 1 then
			effectId = i3k_db_feet_effect[self._id].justiceUIEffect
		else
			effectId = i3k_db_feet_effect[self._id].evilUIEffect
		end
		self:changeFootEffect(self._layout.vars.model, effectId)
	end
	self._layout.vars.model:setRotation(2.5,6.12,6.12);
end

function wnd_role_flying_foot:setFootScroll()
	self._layout.vars.effectScroll:removeAllChildren()
	for k, v in pairs(i3k_db_feet_effect) do
		local node = require(FOOTEFFECT)()
		node.vars.name:setText(v.name)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		if self._effects[k] then
			node.vars.lockText:hide()
		else
			node.vars.lockText:show()
		end
		node.vars.usingIcon:setVisible(k == g_i3k_game_context:getCurFootEffect())
		node.vars.icon:setTag(k)
		node.vars.icon:onClick(self, self.onChangeFootEffect, k)
		node.vars.chooseIcon:setVisible(k == self._id)
		self._layout.vars.effectScroll:addItem(node)
	end
end

function wnd_role_flying_foot:setRightItemData()
	local effect = i3k_db_feet_effect[self._id]
	self._layout.vars.name:setText(effect.name)
	self._layout.vars.desc:setText(effect.desc)
	self._layout.vars.unlockBtn:enableWithChildren()
	if effect.needItemId ~= 0 then
		self._layout.vars.itemBg:show()
		self._layout.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(effect.needItemId))
		self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(effect.needItemId))
		self._layout.vars.itemName:setText(g_i3k_db.i3k_db_get_common_item_name(effect.needItemId))
		self._layout.vars.suo:setVisible(effect.needItemId > 0)
		local bagItemCount = g_i3k_game_context:GetCommonItemCanUseCount(effect.needItemId)
		self._layout.vars.count:setText(bagItemCount.. "/"..effect.needItemCount)
		self._layout.vars.count:setTextColor(g_i3k_get_cond_color(bagItemCount >= effect.needItemCount))
		if self._effects[self._id] then
			self._layout.vars.itemBg:hide()
			if self._id ~= g_i3k_game_context:getCurFootEffect() then
				self._layout.vars.unlockName:setText(i3k_get_string(1692))
			else
				self._layout.vars.unlockBtn:disableWithChildren()
				self._layout.vars.unlockName:setText(i3k_get_string(1693))
			end
		else
			self._layout.vars.unlockName:setText(i3k_get_string(1694))
		end
	else
		self._layout.vars.itemBg:hide()
		if self._id ~= g_i3k_game_context:getCurFootEffect() then
			self._layout.vars.unlockName:setText(i3k_get_string(1692))
		else
			self._layout.vars.unlockBtn:disableWithChildren()
			self._layout.vars.unlockName:setText(i3k_get_string(1693))
		end
	end
end

function wnd_role_flying_foot:onUnlockBtn(sender)
	local effect = i3k_db_feet_effect[self._id]
	if effect.needItemId ~= 0 then
		if self._effects[self._id] then
			if self._id ~= g_i3k_game_context:getCurFootEffect() then
				i3k_sbean.footeffect_select(self._id)
			else
				--g_i3k_ui_mgr:PopupTipMessage("使用中")
			end
		else
			if g_i3k_game_context:GetCommonItemCanUseCount(effect.needItemId) < effect.needItemCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1695))
			else
				i3k_sbean.footeffect_unlock(self._id)
			end
		end
	else
		if self._id ~= g_i3k_game_context:getCurFootEffect() then
			i3k_sbean.footeffect_select(self._id)
		end
	end
end

function wnd_role_flying_foot:onItemTips(sender)
	local effect = i3k_db_feet_effect[self._id]
	if effect.needItemId ~= 0 then
		g_i3k_ui_mgr:ShowCommonItemInfo(effect.needItemId)
	end
end

function wnd_role_flying_foot:onChangeFootEffect(sender, id)
	self._id = id
	for k, v in ipairs(self._layout.vars.effectScroll:getAllChildren()) do
		if v.vars.icon:getTag() == id then
			v.vars.chooseIcon:show()
		else
			v.vars.chooseIcon:hide()
		end
	end
	self:setRightItemData()
	local effectid = 0
	if g_i3k_game_context:GetTransformBWtype() == 1 then
		effectid = i3k_db_feet_effect[id].justiceUIEffect
	else
		effectid = i3k_db_feet_effect[id].evilUIEffect
	end
	self:changeFootEffect(self._layout.vars.model, effectid)
	--self:changeHeroModel(id)
end

function wnd_role_flying_foot:unlockFootEffectId(id)
	if not self._effects then
		self._effects = {}
	end
	self._effects[id] = true
	for k, v in ipairs(self._layout.vars.effectScroll:getAllChildren()) do
		if v.vars.icon:getTag() == id then
			v.vars.lockText:hide()
		end
	end
	self:setRightItemData()
end

function wnd_role_flying_foot:onChangeFootEffectHandler(id)
	if not self._effects then
		self._effects = {}
	end
	self._effects[id] = true
	for k, v in ipairs(self._layout.vars.effectScroll:getAllChildren()) do
		if v.vars.icon:getTag() == id then
			v.vars.usingIcon:show()
		else
			v.vars.usingIcon:hide()
		end
	end
	self:setRightItemData()
end

function wnd_create(layout)
	local wnd = wnd_role_flying_foot.new()
	wnd:create(layout)
	return wnd
end
