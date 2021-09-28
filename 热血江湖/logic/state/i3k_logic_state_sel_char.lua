----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
local default_select_role = 7;
i3k_logic_state_sel_char = i3k_class("i3k_logic_state_sel_char", i3k_logic_state);
function i3k_logic_state_sel_char:ctor()
end

local eLoginMapID = 9999;

function i3k_logic_state_sel_char:Do(fsm, evt)
	local logic = i3k_game_get_logic();
	if logic then
		local loaded = function()
			self:OnMapLoaded();

		    g_i3k_game_context:SetMapEnter(true);
		end
		g_i3k_game_context:ResetLogicMap()
		g_i3k_mmengine:SetDistanceClipFactor(32);
		g_i3k_mmengine:SetNoClipDistance(800);
		local mcfg = i3k_db_combat_maps[eLoginMapID];
		if mcfg then
			logic:LoadMap(mcfg.path, Engine.SVector3(0, 0, 0):ToEngine(), "default", loaded, 0);
		end
	end


	self._charPos	= i3k_db_common.login.role.pos;--i3k_vec3(-0.7, -7.5, -43.0);
	self._charScl	= i3k_db_common.login.role.scale;
	self._touch		= { valid = false, x = 0, y = 0 };
	self._cameraLerp= { valid = false, timeLine = 0, duration = 1, src_pos = nil, tar_pos = nil, cur_pos = nil, src_right = nil, tar_right = nil, cur_right = nil, src_look = nil, tar_look = nil, cur_look = nil };



	return true;
end

function i3k_logic_state_sel_char:Leave(fsm, evt)
	if self._player then
		self._player:Release();
		self._player = nil;
	end
	g_i3k_mmengine:SetDistanceClipFactor(8);
	g_i3k_mmengine:SetNoClipDistance(40);
	g_i3k_ui_mgr:CloseUI(eUIID_SelChar);
	g_i3k_ui_mgr:CloseUI(eUIID_CSelectChar);

end

function i3k_logic_state_sel_char:OnUpdate(dTime)
	if self._player then
		self._player:OnUpdate(dTime);

		if self._cameraLerp.valid then
			self._cameraLerp.timeLine = self._cameraLerp.timeLine + dTime;
			if self._cameraLerp.timeLine > self._cameraLerp.duration then
				self._cameraLerp.timeLine = self._cameraLerp.duration;
			end

			self._cameraLerp.cur_pos = i3k_vec3_lerp(self._cameraLerp.src_pos, self._cameraLerp.tar_pos, self._cameraLerp.timeLine / self._cameraLerp.duration);
            self._cameraLerp.cur_right = i3k_vec3_lerp(self._cameraLerp.src_right, self._cameraLerp.tar_right, self._cameraLerp.timeLine / self._cameraLerp.duration);
            self._cameraLerp.cur_dir = i3k_vec3_lerp(self._cameraLerp.src_dir, self._cameraLerp.tar_dir, self._cameraLerp.timeLine / self._cameraLerp.duration);

			g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(self._cameraLerp.cur_dir), i3k_vec3_to_engine(self._cameraLerp.cur_right), i3k_vec3_to_engine(self._cameraLerp.cur_pos));

			if self._cameraLerp.timeLine >= self._cameraLerp.duration then
				self._cameraLerp.valid		= false;
				self._cameraLerp.timeLine	= 0;
			end
		end
	end

	return true;
end

function i3k_logic_state_sel_char:OnLogic(dTick)
	if self._player then
		self._player:OnLogic(dTick);
	end

	return true;
end

function i3k_logic_state_sel_char:OnMapLoaded()
	local camera = i3k_db_common.login.camera1;
	local roleInfo = g_i3k_game_context:GetRoleList()
	if #roleInfo == 0 then
		camera = i3k_db_common.login.char[6].camera1
	end
	g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(camera.dir), i3k_vec3_to_engine(camera.right), i3k_vec3_to_engine(camera.pos));
	g_i3k_game_handler:EnableObjHitTest(false, false);
	self:PrepareCharList();
end

function i3k_logic_state_sel_char:OnConfirm(suc, code)
	if suc then
		if code == eUSERROLELOGIN_OK then
			local logic = i3k_game_get_logic();
			if logic then
				logic:OnPlay();
			end
		end
	elseif code == eUSERLOGIN_CREATE_ROLE_NAME_USED then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3))
	end
end

function i3k_logic_state_sel_char:PrepareCharList()
	if self._player then
		self._player:Release();
		self._player = nil;
	end

	local ui = g_i3k_ui_mgr:OpenUI(eUIID_SelChar)
	g_i3k_ui_mgr:RefreshUI(eUIID_SelChar)
	if ui then
		ui.onSelectCharacter = function(idx)
			self:OnShowCharacter(idx);
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SelChar,"autoRole")

		ui.onPlayGame = function(idx)
			self:OnPlay(idx);
		end

		ui.onCreateCharacter = function()
			self:OnCreateCharacter(default_select_role, i3k_db_generals[default_select_role].roleSex,eFullFrom);
		end

		if g_i3k_game_context:getFirstCreateRoleFlag() then
			ui:createChar()
		end
	end
end

function i3k_logic_state_sel_char:OnCreateCharacter(charType, gender,formType)
	g_i3k_ui_mgr:CloseUI(eUIID_SelChar);

	local onChangeCharType = function(charType, gender,formType, ai_type)
		local fashion = g_i3k_db.i3k_db_get_general_fashion(charType, gender);

		return self:OnShowCustomCharacter(charType, gender, fashion.hairSkin[1], fashion.faceSkin[1], formType, ai_type );
	end

	local sel_class = g_i3k_ui_mgr:OpenUI(eUIID_CSelectChar)
					  g_i3k_ui_mgr:RefreshUI(eUIID_CSelectChar, charType, gender, onChangeCharType, onChangeCharType)
	if sel_class then
		sel_class.onReturnCB = function()
			g_i3k_ui_mgr:CloseUI(eUIID_CSelectChar);

			self:PrepareCharList();
		end
		sel_class.onChangeGenderCB = function(gender,char, base, fromType, ai_type)
			self._cselGendertype	= gender;
			self._fashion			= g_i3k_db.i3k_db_get_general_fashion(char, gender);

				self._cselHairType		= self._fashion.hairSkin[1];
				self._cselFaceType		= self._fashion.faceSkin[1];

			return self:OnShowCustomCharacter(char, self._cselGendertype, self._cselHairType, self._cselFaceType, fromType, ai_type);
		end
		sel_class.onNextStep = function(charType, genderType)
			g_i3k_ui_mgr:CloseUI(eUIID_CSelectChar);

			self._fashion			= g_i3k_db.i3k_db_get_general_fashion(charType, genderType);
			self._cselCharType		= charType;
			self._cselGendertype	= genderType;
			self._cselHairType		= self._fashion.hairSkin[1];
			self._cselFaceType		= self._fashion.faceSkin[1];
			self._cameraLerp.valid	= true;
			if not self._cameraLerp.cur_pos	then
				self._cameraLerp.src_pos = i3k_db_common.login.camera1.pos;
				self._cameraLerp.src_dir = i3k_db_common.login.camera1.dir;
				self._cameraLerp.src_right = i3k_db_common.login.camera1.right;
			else
				self._cameraLerp.src_pos = self._cameraLerp.cur_pos;
				self._cameraLerp.src_dir = self._cameraLerp.cur_dir;
				self._cameraLerp.src_right = self._cameraLerp.cur_right;
			end

			self._cameraLerp.tar_pos = i3k_db_common.login.camera2.pos;
			self._cameraLerp.tar_dir = i3k_db_common.login.camera2.dir;
			self._cameraLerp.tar_right = i3k_db_common.login.camera2.right;

			local create_char
			if create_char then
				create_char.onChangeGenderCB = function(gender, base, fromType, ai_type)
					self._cselGendertype	= gender;
					self._fashion			= g_i3k_db.i3k_db_get_general_fashion(self._cselCharType, gender);

					if base then
						self._cselHairType		= self._fashion.hairSkin[1];
						self._cselFaceType		= self._fashion.faceSkin[1];

						self:OnShowCustomCharacter(self._cselCharType, self._cselGendertype, self._cselHairType, self._cselFaceType, fromType, ai_type);
					else
						self:OnShowCustomCharacter(self._cselCharType, self._cselGendertype, self._cselHairType, self._cselFaceType, fromType, ai_type);
					end
				end

				create_char.onChangeHairCB = function(style, color)
					self._cselHairType = self._fashion.hairSkin[(style - 1) * 3 + color];

					self:OnChangeCharacterHairFashion(self._fashion, self._cselHairType);
				end

				create_char.onChangeFaceCB = function(face)
					self._cselFaceType = self._fashion.faceSkin[face];

					self:OnChangeCharacterFaceFashion(self._fashion, self._cselFaceType);
				end

				create_char.onReturnCB = function()

					self._cameraLerp.valid		= true;
					if not self._cameraLerp.cur_pos	then
						self._cameraLerp.src_pos = i3k_db_common.login.camera2.pos;
						self._cameraLerp.src_dir = i3k_db_common.login.camera2.dir;
						self._cameraLerp.src_right = i3k_db_common.login.camera2.right;
					else
						self._cameraLerp.src_pos = self._cameraLerp.cur_pos;
						self._cameraLerp.src_dir = self._cameraLerp.cur_dir;
						self._cameraLerp.src_right = self._cameraLerp.cur_right;
					end
					self._cameraLerp.tar_pos	= i3k_db_common.login.camera1.pos;
					self._cameraLerp.tar_dir	= i3k_db_common.login.camera1.dir;
					self._cameraLerp.tar_right = i3k_db_common.login.camera1.right;

					self:OnCreateCharacter(self._cselCharType, self._cselGendertype);
				end
			end
		end
	end
end

function i3k_logic_state_sel_char:OnPlay(idx)
	local logic = i3k_game_get_logic();
	if logic then
		logic:SelectCharacter(idx);
	end
end

function i3k_logic_state_sel_char:OnShowCharacter(idx)
	local roleInfo = g_i3k_game_context:GetRoleInfo();
	local roleList = g_i3k_game_context:GetRoleList()
	if roleInfo and roleList then
		local char = roleList[idx];
		if char then
			if self._player then
				self._player:Release();
				self._player = nil;
			end

			local SEntity = require("logic/entity/i3k_hero");

			local hero = SEntity.i3k_hero.new(i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, char._id + 99999), true);
			hero:SetSyncCreateRes(true)
			if not hero:Create(char._type, char._name, char._gender, char._hair, char._face, char._level, roleInfo.skills.all, false, false, nil, char._bwType, char._soaringDisplay) then
				hero = nil;
			end

			if hero then
				hero:SetFaceDir(0, 2.0 * math.pi * (i3k_db_common.login.role.rotation / 360) - math.pi * 0.5, 0);
				hero:SetHittable(false);
				hero:AddAiComp(eAType_IDLE_STAND);
				hero._soaringDisplay = char._soaringDisplay
				local weaponDisplay, skinDisplay = i3k_get_soaring_display_info(char._soaringDisplay)
				local equips = char._equips
				for k, v in pairs(equips) do
					hero:AttachEquip(v);
				end
				if char._level >= i3k_db_martial_soul_cfg.openLvl  then
					if char._weaponSoulShow and char._weaponSoulShow ~= 0 then
						local arg = {showId = char._weaponSoulShow, type = char._type};
						hero:AttachWeaponSoul(true,arg)
					end
				end
				local fashions = char._fashions
				local isshow = skinDisplay == g_WEAR_FASHION_SHOW_TYPE
				if fashions[g_FashionType_Dress] then
					hero:AttachFashion(fashions[g_FashionType_Dress], isshow, g_FashionType_Dress);
				end
				local isShowWeap = weaponDisplay == g_FASTION_SHOW_TYPE
				if fashions[g_FashionType_Weapon] then
					hero:AttachFashion(fashions[g_FashionType_Weapon], isShowWeap, g_FashionType_Weapon);
				end
				hero:changeWeaponShowType()
				if weaponDisplay ~= g_FLYING_SHOW_TYPE then
					hero:AttachEquipEffect(char._equipParts);
				end
				if char._soaringDisplay.footEffect and char._soaringDisplay.footEffect ~= 0 then
					hero:changeFootEffect(char._soaringDisplay.footEffect)
				end

				local action = i3k_db_common.engine.selectRoleEffect
				hero._armor.id = char._armor.id
				hero._armor.stage = char._armor.stage
				hero:SetArmorEffectHide(char._armor.hideEffect)
				hero:ChangeArmorEffect(true)
				hero:Show(true, true);
				hero:ShowTitleNode(false);
				hero:SetPos(i3k_world_pos_to_logic_pos(i3k_db_common.login.role.pos));
				hero:SetScale(hero._scale * i3k_db_common.login.role.scale);
				hero:Play(action, 1);
				hero:Play("stand", -1, true);
				hero:SetViewDistance(100000)

				self._player = hero;
			end
		end
	end
end

function i3k_logic_state_sel_char:OnShowCustomCharacter(charType, gender, hair, face, formType, ai_type)
	if self._player then
		self._player:Release();
		self._player = nil;
	end
	local SEntity = require("logic/entity/i3k_hero");

	local hero = SEntity.i3k_hero.new(i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, 99999), true);
	hero:SetSyncCreateRes(true)
	if not hero:Create(charType, "", gender, hair, face, 1, { }, false, false,formType) then
		hero = nil;
	end

	if hero then
		hero:SetFaceDir(0, 2.0 * math.pi * (i3k_db_common.login.char[charType].role.rotation / 360) - math.pi * 0.5, 0);
		hero:SetHittable(false);
		hero:AddAiComp(ai_type or eAType_IDLE_STAND );

		hero:Show(true, true);
		hero:ShowTitleNode(false);
		hero:SetPos(i3k_world_pos_to_logic_pos(i3k_db_common.login.char[charType].role.pos));
		hero:SetScale(hero._scale * i3k_db_common.login.char[charType].role.scale);
		--hero:Play(action, -1,true);
		--hero:Play("stand", -1, true);

		self._player = hero;
		hero:SetViewDistance(100000)
		return hero
	end
end

function i3k_logic_state_sel_char:OnChangeCharacterHairFashion(fashion, hair)
	if self._player then
		self._player:ChangeFashion(fashion, eFashion_Hair, hair);
	end
end

function i3k_logic_state_sel_char:OnChangeCharacterFaceFashion(fashion, face)
	if self._player then
		self._player:ChangeFashion(fashion, eFashion_Face, face);
	end
end

function i3k_logic_state_sel_char:OnTouchDown(handled, x, y)
	if handled == 0 then
		self._touch.valid = true;
		self._touch.x = x;
		self._touch.y = y;
	end
end

function i3k_logic_state_sel_char:OnDrag(handled, touchDown, x, y)
	if self._touch.valid then
		if self._player then
			local dx = self._touch.x - x;

			local dy = self._player._faceDir.y + (dx / g_i3k_game_handler:GetViewWidth()) * 2 * math.pi;
			if g_i3k_ui_mgr:InvokeUIFunction(eUIID_CSelectChar, "setHeroDir", dy) then
			else
			self._player:SetFaceDir(0, dy, 0);
			end
		end

		self._touch.x = x;
		self._touch.y = y;
	end
end

function i3k_logic_state_sel_char:OnTouchUp(handled, x, y)
	self._touch.valid = false;
end

function i3k_logic_state_sel_char:OnKeyUp(handled, key)
	if key == 41 then -- ~
		if self._player then
			g_i3k_ui_mgr:PopupTipMessage(((self._player._faceDir.y + math.pi * 0.5) * 180 / math.pi) % 360);
		end
	end
end
