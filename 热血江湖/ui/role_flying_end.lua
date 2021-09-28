-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-----------------------DISCARDED--------------------------------
wnd_role_flying_end = i3k_class("wnd_role_flying_end", ui.wnd_base)

function wnd_role_flying_end:ctor()
	--self._flyId = 1
end

function wnd_role_flying_end:configure()
	self._layout.vars.goBtn:onClick(self, self.onGoBtn)
end

function wnd_role_flying_end:refresh(flyId)
	--self._flyId = flyId
	local index = g_i3k_game_context:GetRoleType() * 2 + g_i3k_game_context:GetTransformBWtype() - 2
	local weaponId = i3k_db_role_flying[flyId].weaponId[index]
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(weaponId)
	local weaponModel = 0
	if g_i3k_game_context:GetTransformBWtype() == 1 then
		if g_i3k_game_context:IsFemaleRole() then
			weaponModel = equipCfg.skin_ZF_ID
		else
			weaponModel = equipCfg.skin_ZM_ID
		end
	else
		if g_i3k_game_context:IsFemaleRole() then
			weaponModel = equipCfg.skin_XF_ID
		else
			weaponModel = equipCfg.skin_XM_ID
		end
	end
	ui_set_hero_model(self._layout.vars.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(), false, nil, i3k_db_common.engine.defaultRunAction)
	local hero = i3k_game_get_player_hero()
	if hero and hero._soaringDisplay.footEffect ~= 0 then
		local effectId = 0
		if g_i3k_game_context:GetTransformBWtype() == 1 then
			effectId = i3k_db_feet_effect[hero._soaringDisplay.footEffect].justiceUIEffect
		else
			effectId = i3k_db_feet_effect[hero._soaringDisplay.footEffect].evilUIEffect
		end
		self:changeFootEffect(self._layout.vars.hero_module, effectId)
	end
	ui_set_hero_model(self._layout.vars.weapon_module, weaponModel[1])
	self._layout.vars.hero_module:setRotation(0.5,0,6.12);
	self:updateFlyingProperty(flyId)
end

function wnd_role_flying_end:onGoBtn(sender)
	g_i3k_logic:OpenBagUI()
	self:onCloseUI()
end

function wnd_role_flying_end:updateFlyingProperty(flyId)
	local flyingData = i3k_db_role_flying[flyId]
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(flyingData.property) do
		if v.id ~= 0 then
			local node = require("ui/widgets/feishengcgt")()
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
			node.vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
			node.vars.value:setText(i3k_get_prop_show(v.id, v.value))
			self._layout.vars.scroll:addItem(node)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_role_flying_end.new()
	wnd:create(layout)
	return wnd
end