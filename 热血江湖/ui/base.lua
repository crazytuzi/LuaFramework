-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
require("i3k_global");


-------------------------------------------------------
i3k_ui_callback = i3k_class("ui_callback");
function i3k_ui_callback:ctor()
	self._funcs = { };
	self._cnt	= 0;
end

function i3k_ui_callback:push(f)
	self._cnt = self._cnt + 1;

	table.insert(self._funcs, f);
end

function i3k_ui_callback:pop()
	local f = nil;

	if self._cnt > 0 then
		f = self._funcs[self._cnt];

		table.remove(self._funcs, self._cnt);

		self._cnt = self._cnt - 1;
	end

	return f;
end

function i3k_ui_callback:front()
	if self._cnt > 0 then
		return self._funcs[1];
	end

	return nil;
end

function i3k_ui_callback:back()
	if self._cnt > 0 then
		return self._funcs[self._cnt];
	end

	return nil;
end


-------------------------------------------------------

wnd_base = i3k_class("wnd_base", cc.Layer)

function wnd_base:ctor()
	self._uiLayer = nil;
end

function wnd_base:init()
	--self._uiLayer = cc.Layer:create();

	--self:addChild(self._uiLayer);
end

function wnd_base:configure(...)

end

function wnd_base:create(layout, ...)
	self:init();

	self._layout = require ("ui/layers/" .. layout)()
		self:addChild(self._layout.root);

	self:configure(...);
end

function wnd_base:isShow()
	return self:isVisible()
end

function wnd_base:show()
	self:setVisible(true);
end

function wnd_base:hide()
	self:setVisible(false);
end

function wnd_base:GetAnimationByAnisName(AnisName)
	return self._layout.anis[AnisName]
end

function wnd_base:GetChildByVarName(VarName)
	return self._layout.vars[VarName]
end

function wnd_base:setBubblePos(node, pos)
	local visibleOrigin = g_i3k_ui_mgr:GetVisibleOrigin()
	local winSize = cc.Director:getInstance():getWinSize();
	local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local propX = winSize.width/frameSize.width
	local propY = winSize.height/frameSize.height
	local proption = propX < propY and propX or propY

	local worldPos = cc.p(pos.x, frameSize.height - pos.y)
	worldPos.x = worldPos.x*proption+visibleOrigin.x
	worldPos.y = worldPos.y*proption
	node:setPosition(worldPos)
end

function wnd_base:onShow()
end

function wnd_base:onHide()
end

function wnd_base:onAddToSence()
	local starAnis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	local closeUIAfterPlay = self._layout and self._layout.layer and self._layout.layer.closeAfterOpenAni
	if starAnis then
		starAnis.play(function ()
			if closeUIAfterPlay then
				g_i3k_ui_mgr:CloseUI(self.__uiid)
			end
		end)
	end
	local sound = self._layout and self._layout.layer and self._layout.layer.soundEffectOpen
	if sound then
		i3k_game_play_sound(sound, 1)
	end
end

function wnd_base:onRemoveFromSence()

end

function wnd_base:onShowImpl()
	self:onAddToSence()
	self:onShow()
end

function wnd_base:onHideImpl()
	self:onRemoveFromSence()
	self:onHide()
end

function wnd_base:createFashionSkin(id, gender, fashionId, usefashion, isEffectFashion)
	local guid = "i3k_hero||1000000"
	local cfg = i3k_db_fashion_dress[fashionId]
	local reflect =cfg.fashionReflect
	if isEffectFashion and cfg.showModleId then
		reflect = cfg.showModleId
	end
	for k,v in pairs(reflect) do
		local argsname = "skin"..id..gender
		local skincfg = i3k_db_fashion_dress_skin[v][argsname]
		local partID = i3k_db_fashion_dress_skin[v].partid
		usefashion[partID] = {}
		for k1, v1 in ipairs(skincfg) do
			local scfg = i3k_db_skins[v1]
			local name = string.format("hero_Fashionskin_%s_%d_%d_%d_%d", guid, fashionId, cfg.fashionType, partID, k1);
			local info = {name = name,path = scfg.path,effectID = scfg.effectID}
			table.insert(usefashion[partID],info)
		end
	end
end

function wnd_base:createDefaultSkin(rcfg, defaultSkin, eFashion_Part)
	if rcfg then
		local scfg = i3k_db_skins[rcfg.skinID];
		if scfg then
			local skin = { };
			skin.path = scfg.path;
			skin.name = string.format("ui_hero_skin_%s_%d", "i3k_hero||1000000", eFashion_Part);
			skin.effectID = scfg.effectID
			defaultSkin[eFashion_Part] = { skin };
		end
	end
end

function wnd_base:effectLinkChild(effectID, partId, node)
	local cfg = i3k_db_effects[effectID];
	if cfg then
		if cfg.hs == '' or cfg.hs == 'default' then
			node:linkChild(cfg.path, string.format("ui_hero_fashion_%s_effect_%d_%d", "i3k_hero||1000000", partId, effectID), "", "", 0.0, cfg.radius);
		else
			node:linkChild(cfg.path, string.format("ui_hero_fashion_%s_effect_%d_%d", "i3k_hero||1000000", partId, effectID), cfg.hs, "", 0.0, cfg.radius);
		end
	end
end

function wnd_base:setEffectSkin(equip, node, partID)
	for _, v in ipairs(equip) do
		node:setSkin(v.path, v.name);
		if v.effectID and #v.effectID ~= 0 then
			for _, v1 in pairs(v.effectID) do
				if v1 ~= 0 then
					self:effectLinkChild(v1, partID, node);
				end
			end
		end
	end
end

function wnd_base:createModelWithCfg(modelTable)
	local node = modelTable.node
	local id = modelTable.id
	local bwType = modelTable.bwType
	local gender = modelTable.gender
	local face = modelTable.face
	local hair = modelTable.hair
	local equips = modelTable.equips
	local fashions = modelTable.fashions
	local isshow = modelTable.isshow
	local equipparts = modelTable.equipparts
	local armor = modelTable.armor
	local weaponSoulShow = modelTable.weaponSoulShow
	local isEffectFashion = modelTable.isEffectFashion
	local soaringDisplay = modelTable.soaringDisplay or {weaponDisplay = 0, footEffect = 0}
	local cfg = g_i3k_db.i3k_db_get_general(id)
	if not cfg then
		return false;
	end
	local fashion = g_i3k_db.i3k_db_get_general_fashion(id, gender or 1)
	local mcfg = i3k_db_models[fashion.modelID];
	if mcfg then
		node:setSprite(mcfg.path);
		node:setSprSize(mcfg.uiscale);
		local defaultSkin = { [eFashion_Face] = { }, [eFashion_Hair] = { }, [eFashion_Body] = { }, [eFashion_Weapon] = { }, };

		local guid = "i3k_hero||1000000"

		local rcfg = g_i3k_db.i3k_db_fashion_res[face];
		self:createDefaultSkin(rcfg, defaultSkin, eFashion_Face);
	
		local rcfg = g_i3k_db.i3k_db_fashion_res[hair];
		self:createDefaultSkin(rcfg, defaultSkin, eFashion_Hair);

		local rcfg = g_i3k_db.i3k_db_get_general_fashion_body_res(fashion);
		if rcfg then
			for k, v in ipairs(rcfg) do
				local scfg = i3k_db_skins[v];
				if scfg then
					local skin = { };
					skin.path = scfg.path;
					skin.name = string.format("ui_hero_skin_%s_%d_%d", guid, eFashion_Body, k);
					skin.effectID = scfg.effectID
					table.insert(defaultSkin[eFashion_Body], skin);
				end
			end
		end

		local rcfg = g_i3k_db.i3k_db_get_general_fashion_weapon_res(fashion);
		if rcfg then
			for k, v in ipairs(rcfg) do
				local scfg = i3k_db_skins[v];
				if scfg then
					local skin = { };
					skin.path = scfg.path;
					skin.name = string.format("ui_hero_skin_%s_%d_%d", guid, eFashion_Weapon, k);
					skin.effectID = scfg.effectID
					table.insert(defaultSkin[eFashion_Weapon], skin);
				end
			end
		end

		local usefashion = {}
		local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(soaringDisplay)
		if fashions[g_FashionType_Weapon] and weaponDisplay == g_FASTION_SHOW_TYPE then
			self:createFashionSkin(id, gender, fashions[g_FashionType_Weapon], usefashion, isEffectFashion);
		end
		if fashions[g_FashionType_Dress] and skinDisplay == g_WEAR_FASHION_SHOW_TYPE then
			self:createFashionSkin(id, gender, fashions[g_FashionType_Dress], usefashion, isEffectFashion);
		end

		-- first attach face skin
		local skin = defaultSkin[eFashion_Face];
		if usefashion[eFashion_Face] then
			skin = usefashion[eFashion_Face]
		end
		if skin then
			self:setEffectSkin(skin, node, eFashion_Face);
		end

		-- first attach face skin
		local skin = defaultSkin[eFashion_Hair];
		if usefashion[eFashion_Hair] then
			skin = usefashion[eFashion_Hair]
		end
		if skin then
			self:setEffectSkin(skin, node, eFashion_Hair);
		end
		
		if weaponSoulShow then
			hero_attach_weapon_Soul(id, node, weaponSoulShow)
		end
		local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(soaringDisplay)
		for k, v in pairs(i3k_db_equip_part) do
			local _equip = { valid = false, skins = { } };
			local _model = {valid = false, models = {}}
			local equip = equips[v.partId];
			if equip then
				local ecfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip)
				if ecfg then
					local ids = ecfg.skin_M_ID;
					if gender == eGENDER_FEMALE then
						ids = ecfg.skin_F_ID;
						if bwType == 1 then
							ids = ecfg.skin_ZF_ID;
						elseif bwType == 2 then
							ids = ecfg.skin_XF_ID;
						end
					else
						if bwType == 1 then
							ids = ecfg.skin_ZM_ID;
						elseif bwType == 2 then
							ids = ecfg.skin_XM_ID;
						end
					end
					if ids then
						if v.partId ~= eEquipFlying then
							for j, t in ipairs(ids) do
								local scfg = i3k_db_skins[t];
								if scfg then
									_equip.valid = true;
									local skin = { };
										skin.name = string.format("hero_skin_%s_%d_%d", guid, v.partId, j);
										skin.path = scfg.path;
										skin.effectID = scfg.effectID
									table.insert(_equip.skins, skin);
								end
							end
						elseif v.partId == eEquipFlying then
							for j, t in ipairs(ids) do
								local scfg = i3k_db_models[t];
								if scfg then
									_model.valid = true;
									table.insert(_model.models, {id = t, path = scfg.path, name = string.format("hero_fly_equip_%s", guid)})
								end
							end
						end
					end
				end
			end
			if v.partId == eEquipWeapon or v.partId == eEquipFlying then
				if usefashion[g_FashionType_Weapon] and weaponDisplay == g_FASTION_SHOW_TYPE and v.partId == eEquipWeapon then
					self:setEffectSkin(usefashion[g_FashionType_Weapon], node, eEquipWeapon)
				else
					if v.partId == eEquipWeapon and weaponDisplay == g_WEAPON_SHOW_TYPE then
						if equip and _equip.valid then
							self:setEffectSkin(_equip.skins, node, v.partId);
						else
							self:setEffectSkin(defaultSkin[v.partId], node, v.partId);
						end
					elseif v.partId == eEquipFlying and weaponDisplay == g_FLYING_SHOW_TYPE then
						if equip and  _model.valid then
							local function linkFunc(node, path, name, heroHangPoint, weaponHangPoint, offsetY, scale)
								node:linkChild(path, name, heroHangPoint, weaponHangPoint, offsetY, scale)
							end
							hero_attach_flying_equip(node, _model.models, linkFunc)
						else
							self:setEffectSkin(defaultSkin[eEquipWeapon], node, eEquipWeapon);
						end
					end
				end
			elseif v.partId == eEquipClothes or v.partId == eEquipFlyClothes then
				if fashions[g_FashionType_Dress] and skinDisplay == g_WEAR_FASHION_SHOW_TYPE and v.partId == eEquipClothes  then
					self:setEffectSkin(usefashion[eEquipClothes], node, eEquipClothes)
				else
					if v.partId == eEquipClothes and skinDisplay == g_WEAR_NORMAL_SHOW_TYPE then
						if  equip and _equip.valid then
							self:setEffectSkin(_equip.skins, node, v.partId);
						else
							self:setEffectSkin(defaultSkin[v.partId], node, v.partId);
						end
					elseif v.partId == eEquipFlyClothes and skinDisplay == g_WEAR_FLYING_SHOW_TYPE then
						if equip and _equip.valid then
							self:setEffectSkin(_equip.skins, node, eEquipClothes);
						else
							self:setEffectSkin(defaultSkin[eEquipClothes], node, eEquipClothes);
						end
					end
				end
			else
				if usefashion[v.partId] then
					self:setEffectSkin(usefashion[v.partId], node, v.partId);
				else
					if equip and _equip.valid then
						self:setEffectSkin(_equip.skins, node, v.partId);
					else
						if defaultSkin[v.partId] then
							self:setEffectSkin(defaultSkin[v.partId], node, v.partId)
						end
					end
				end
			end
		end
		if equipparts and weaponDisplay ~= g_FLYING_SHOW_TYPE then
			for k, v in pairs(equipparts) do
				local equipId = equips[k]
				local effectInfo = v.effectInfo or v.show
				local effectids = g_i3k_db.i3k_db_get_equip_effect_id_show(equipId, id, k, v.eqGrowLvl, v.eqEvoLvl, effectInfo)
				if effectids then
					for k2, v2 in pairs(effectids) do
						self:effectLinkChild(k2, k, node);
					end
				end
			end
		end
		if weaponDisplay == g_HEIRHOOM_SHOW_TYPE then
			local scfg = i3k_db_skins[g_i3k_game_context:getHeirloomSkinID(id)]
			if scfg then
				local name = string.format("hero_skin_%s_%d", guid, 1)
				node:setSkin(scfg.path, name)
			end
		end
		if soaringDisplay.footEffect ~= 0 then
			local effectid = 0
			if bwType == 1 then
				effectid = i3k_db_feet_effect[soaringDisplay.footEffect].justiceEffect
			else
				effectid = i3k_db_feet_effect[soaringDisplay.footEffect].evilEffect
			end
			self:changeFootEffect(node, effectid)
		end
		if armor and armor.id~=0 then
			local stage = armor.rank
			local effectId = i3k_db_under_wear_upStage[armor.id][stage].specialEffId
			for i,v in ipairs(effectId) do
				local cfg = i3k_db_effects[v]
				if cfg then
					local eid = 0
					if cfg.hs == '' or cfg.hs == 'default' then
						eid = node:linkChild(cfg.path, string.format("hero_armor_%s_stage_%s_effect_%s", armor.id, stage, v), "", "", 0.0, cfg.radius)
					else
						eid = node:linkChild(cfg.path, string.format("hero_armor_%s_stage_%s_effect_%s", armor.id, stage, v), cfg.hs, "", 0.0, cfg.radius)
					end
					if not node.effectId then
						node.effectId = {}
					end
					if eid~=0 then
						table.insert(node.effectId, eid)
					end
				end
			end
		end
		node:playAction("stand");
	end
end

function wnd_base:changeArmorEffect(node, id, stage , isShow)
	if node.effectId then
		for _,v in ipairs(node.effectId) do
			node:unlinkChild(v)
		end
		node.effectId = {}
	end
	
	if isShow ~= true and (g_i3k_game_context:GetUserCfg():GetIsHideAllArmorEffect() or g_i3k_game_context:getArmorHideEffect()) then return end --如果没有强制要求显示 并且屏蔽内甲特效 不显示

	local effectId = i3k_db_under_wear_upStage[id][stage].specialEffId
	for _,v in ipairs(effectId) do
		local cfg = i3k_db_effects[v]
		if cfg then
			local effect = 0
			local hero = i3k_game_get_player_hero()
			if cfg.hs == '' or cfg.hs == 'default' then
				effect = node:linkChild(cfg.path, string.format("hero_%s_ui_armor_%s_stage_%s_effect_%s", hero._guid, id, stage, v), "", "", 0.0, cfg.radius)
			else
				effect = node:linkChild(cfg.path, string.format("hero_%s_ui_armor_%s_stage_%s_effect_%s", hero._guid, id, stage, v), cfg.hs, "", 0.0, cfg.radius)
			end
			if effect~=0 then
				table.insert(node.effectId, effect)
			end
		end
	end
end

function wnd_base:changeFootEffect(node, effectId)
	if node.footEffectId then
		for _,v in ipairs(node.footEffectId) do
			node:unlinkChild(v)
		end
		node.footEffectId = {}
	end
	local cfg = i3k_db_effects[effectId]
	if cfg then
		local effect = 0
		local hero = i3k_game_get_player_hero()
		if cfg.hs == '' or cfg.hs == 'default' then
			effect = node:linkChild(cfg.path, string.format("hero_%s_foot_effect_%d", hero._guid, effectId), "", "", 0.0, cfg.radius)
		else
			effect = node:linkChild(cfg.path, string.format("hero_%s_foot_effect_%d", hero._guid, effectId), cfg.hs, "", 0.0, cfg.radius)
		end
		if effect~=0 then
			if not node.footEffectId then
				node.footEffectId = {}
			end
			table.insert(node.footEffectId, effect)
		end
	end
end

function wnd_base:onUpdate(dTime)
end


function wnd_base:refresh(...)
end

function wnd_base:onCloseUI(sender, cb)
	if cb then
		cb()
	end
	g_i3k_ui_mgr:CloseUI(self.__uiid)
end

function wnd_base:adaptorIsPad(isPad)
	if isPad then
		self._layout.vars.padtop:setVisible(true)
		self._layout.vars.padzs:setVisible(true)
		self._layout.vars.sjtop:setVisible(false)
	end
end

function wnd_base:SetMapImageContentsize(node,size)
	if g_i3k_ui_mgr:JudgeIsPad() then
		node.vars.image:setContentSize(size.width*0.75, size.height*0.75)
	else
		node.vars.image:setContentSize(size.width, size.height)
	end
end