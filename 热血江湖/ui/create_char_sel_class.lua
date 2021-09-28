-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_create_char_sel_class = i3k_class("wnd_create_char_sel_class", ui.wnd_base)


local EDITNAME

local cameraTime = 1
local iconsNomarl = {2344,2346,2348,2350,2352,4234,5938, 9693}
local iconsPress = {2345,2347,2349,2351,2353,4235,5937, 9692}

local COMMONCAREER = 1
local EXTRACAREER = 2
function wnd_create_char_sel_class:ctor()
	self._selCharIdx = 1
	self._careerType = COMMONCAREER
	self._auto_type = eFashFrom
	self._player_select_gender = 0 -- 玩家选择的性别
	self._oldChar = 1
	self._cameroMoveTime = 0
	self._player = nil
	self._entities = {}
	self._isPlayAction = false
	self._actionCountdown = 0
end

function wnd_create_char_sel_class:configure(...)
	--local arg = { ... };

	self._face		= 1;
	self._hairStyle	= 1;
	self._hairColor	= 1;

	self._layout.vars.btnPlay:onTouchEvent(self, self.onPlay)
	self._layout.vars.btnReturn:onTouchEvent(self, self.onReturn);


	self._wins =
	{
		{ btn = self._layout.vars.btnPlayer1, txt = self._layout.vars.labName1, ctype = 1, desc = 819 },
		{ btn = self._layout.vars.btnPlayer2, txt = self._layout.vars.labName2, ctype = 2, desc = 820 },
		{ btn = self._layout.vars.btnPlayer3, txt = self._layout.vars.labName3, ctype = 3, desc = 821 },
		{ btn = self._layout.vars.btnPlayer4, txt = self._layout.vars.labName4, ctype = 4, desc = 822 },
		{ btn = self._layout.vars.btnPlayer5, txt = self._layout.vars.labName5, ctype = 5, desc = 823 },
		{ btn = self._layout.vars.btnPlayer6, txt = self._layout.vars.labName5, ctype = 6, desc = 4236 },
		{ btn = self._layout.vars.btnPlayer7, txt = self._layout.vars.labName5, ctype = 7, desc = 5942 },
		{ btn = self._layout.vars.btnPlayer8, txt = self._layout.vars.labName5, ctype = 8, desc = 9761 },
	};--txt这个废弃了

	for k, v in ipairs(self._wins) do
		if v.btn then
			v.btn:setTag(k);
			v.btn:onTouchEvent(self, self.onCharTouch);
		end
	end
	self._role_icon = {
		self._layout.vars.daokeIcon,
		self._layout.vars.jianshiIcon,
		self._layout.vars.qianghaoIcon,
		self._layout.vars.gongshouIcon,
		self._layout.vars.yishiIcon,
		self._layout.vars.cikeIcon,
		self._layout.vars.fushiIcon,
		self._layout.vars.fistIcon,
	}


	self._layout.vars.rndName:onTouchEvent(self, self.randomName)
	--时装切换
	self.fashionBtn = 
	{
		[eBaseFrom] = self._layout.vars.base_form,
		[eFashFrom] = self._layout.vars.fash_form,
		[eFullFrom] = self._layout.vars.full_form,
		[eXieForm] = self._layout.vars.xie_form,
	}
	for k, v in pairs(self.fashionBtn) do
		v:onClick(self, self.onChangeFashion, k)

end

	self._layout.vars.editName:setMaxLength(i3k_db_common.inputlen.namelen)

	self._genderWins =
	{
		self._layout.vars.btnMale, self._layout.vars.btnFemale,
	};

	self._genderWins[eGENDER_MALE]:onTouchEvent(self, self.selectGender);
	self._genderWins[eGENDER_MALE]:setTag(eGENDER_MALE);
	self._genderWins[eGENDER_FEMALE]:onTouchEvent(self, self.selectGender);
	self._genderWins[eGENDER_FEMALE]:setTag(eGENDER_FEMALE);
	self._layout.vars.commonCareer:onClick(self, self.onChangeCareerPage, COMMONCAREER)
	self._layout.vars.extraCareer:onClick(self, self.onChangeCareerPage, EXTRACAREER)



end

function wnd_create_char_sel_class:onShow()
	if g_i3k_game_context:getFirstCreateRoleFlag() then
		self._layout.vars.btnReturn:hide()
	else
		self._layout.vars.btnReturn:show()
	end
end

function wnd_create_char_sel_class:refresh(charType, gender, onChangeCharFun, onSelGenderFun)
	self._selCharIdx = charType or 1
	self._selGenderType = gender or 1
	self.onSelCharTypeCB	= onChangeCharFun
	self.onSelGenderTypeCB	= onSelGenderFun
	self:updateRoleCharAnfGender()
	self:changeCamera()
	self:updateRoleModel()
end

function wnd_create_char_sel_class:updateRoleCharAnfGender()
	self._layout.vars.nameNode:show()
	self._layout.vars.btnPlay:show()
	self._layout.vars.extraCareer:stateToNormal(true)
	self._layout.vars.commonCareer:stateToPressed(true)
	self._layout.vars.outboundDesc:hide()
	self._selCharType	= self._wins[self._selCharIdx].ctype
	self._layout.vars.imgDesc:setImage(g_i3k_db.i3k_db_get_icon_path(self._wins[self._selCharIdx].desc))
	self:updateGenderBtn()
	self:updateFashionBtnState()
	self:updateCareerBtnState()
	self:updateRandomName()
end
function wnd_create_char_sel_class:updateGenderBtn()
	self._genderWins[self._selGenderType]:stateToPressed()
	self._genderWins[3 - self._selGenderType]:stateToNormal()
end
function wnd_create_char_sel_class:changeCamera()
	local camera = i3k_db_common.login.char[self._selCharIdx].camera1
	g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(camera.dir), i3k_vec3_to_engine(camera.right), i3k_vec3_to_engine(camera.pos))
end
function wnd_create_char_sel_class:updateCareerBtnState()
	if i3k_db_generals[self._selCharIdx].classType == EXTRACAREER then
		self._layout.vars.normalClass:hide()
		self._layout.vars.outClass:show()
	else
		self._layout.vars.normalClass:show()
		self._layout.vars.outClass:hide()
	end
	for k, v in ipairs(self._role_icon) do
		if self._selCharIdx == k then
			v:setImage(g_i3k_db.i3k_db_get_icon_path(iconsPress[k]))
		else
			v:setImage(g_i3k_db.i3k_db_get_icon_path(iconsNomarl[k]))
		end
	end
end
function wnd_create_char_sel_class:updateRoleModel(ai_type)
	--[[if self.onSelCharTypeCB then
		self.onSelCharTypeCB(self._selCharType, self._selGenderType, self._auto_type);
	end--]]
	if self.onSelGenderTypeCB then
		self._player = self.onSelGenderTypeCB(self._selCharType, self._selGenderType, self._auto_type, ai_type);
	end
end
function wnd_create_char_sel_class:updateFashionBtnState()
	for k, v in pairs(self.fashionBtn) do
		if self._auto_type == k then
			v:stateToPressed()
		else
			v:stateToNormal()
		end
	end
end
function wnd_create_char_sel_class:onChangeFashion(sender, fashionType)
	if self._isCameraMove then
		return
	end
	if self._isPlayAction then
		return
	end
	self._auto_type = fashionType
	if self.onChangeGenderCB then
		self._player = self.onChangeGenderCB(self._selGenderType, self._selCharType, false, fashionType, eAType_IDLE_JUST_STAND)
	end
	self:updateFashionBtnState()
end
function wnd_create_char_sel_class:selectGender(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._isCameraMove then
			return
		end
		if self._isPlayAction then
			return
		end
		local tag = sender:getTag();
		if self._selGenderType ~= tag then
			self._selGenderType = tag
			self._player_select_gender = tag
			self:updateGenderBtn()
			self:updateRoleModel()
			self:checkRandomName()
		end
	end
end
function wnd_create_char_sel_class:onCharTouch(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._isCameraMove then
			return
		end
		if self._isPlayAction then
			return
		end
		local tag = sender:getTag();
		if tag ~= self._selCharIdx then
			self:changClassType(tag)
			self:updateRoleModel()
		end
	end
end
function wnd_create_char_sel_class:changClassType(tag)
	self._selCharIdx = tag;
	local win = self._wins[tag]
	self._layout.vars.imgDesc:setImage(g_i3k_db.i3k_db_get_icon_path(win.desc));
	self._selCharType = win.ctype;
	if self._player_select_gender == 0 then
		local roleSex = i3k_db_generals[self._selCharIdx].roleSex
		self._selGenderType = roleSex
		self:updateGenderBtn()
		self:checkRandomName()
	end
	if i3k_db_generals[self._selCharType].fashionState ~= 0 then
		self._auto_type = i3k_db_generals[self._selCharType].fashionState
		self:updateFashionBtnState()
	end
	self:updateCareerBtnState()
end
function wnd_create_char_sel_class:onChangeCareerPage(sender, page)
	if self._isPlayAction then
		return
	end
	if not self._isCameraMove then
		if self._careerType ~= page then
			self._careerType = page
			self._oldChar = self._selCharIdx
			self._isPlayAction = false
			self._actionCountdown = 0
			self:deleteSpecialEntity()
			if page == COMMONCAREER then
				self._selCharIdx = 1
				self:updateRoleCharAnfGender()
				if i3k_db_generals[self._selCharType].fashionState ~= 0 then
					self._auto_type = i3k_db_generals[self._selCharType].fashionState
					self:updateFashionBtnState()
				end
				self:updateRoleModel(eAType_IDLE_JUST_STAND)
			else
				self:updateExtraCareerList()
			end
			self:createMovedCamera()
		end
	end
end
function wnd_create_char_sel_class:updateExtraCareerList()
	local outCareer = {}
	for k, v in pairs(i3k_db_generals) do
		if v.classType == EXTRACAREER then
			table.insert(outCareer, k)
		end
	end
	self._selCharIdx = outCareer[1]
	self._selCharType = outCareer[1]
	if i3k_db_generals[self._selCharType].fashionState ~= 0 then
		self._auto_type = i3k_db_generals[self._selCharType].fashionState
		self:updateFashionBtnState()
	end
	self._layout.vars.extraCareer:stateToPressed(true)
	self._layout.vars.commonCareer:stateToNormal(true)
	self._layout.vars.nameNode:hide()
	self._layout.vars.btnPlay:hide()
	self._layout.vars.outboundDesc:show()
	self._layout.vars.outboundDesc:setText(i3k_get_string(i3k_db_generals[self._selCharType].createDescription))
	self:updateExtraCareerInfo()
end
function wnd_create_char_sel_class:updateExtraCareerInfo()
	self:changClassType(self._selCharIdx)
	self:updateRoleModel(eAType_IDLE_JUST_STAND)
	--self:updateRoleModel()
end
function wnd_create_char_sel_class:createMovedCamera()
	self._isCameraMove = true
	self._cameroMoveTime = 0
	self:checkRoleSpecialAction()
end
function wnd_create_char_sel_class:onUpdate(dTime)
	if self._isCameraMove then
		self._cameroMoveTime = self._cameroMoveTime + dTime
		if self._cameroMoveTime >= cameraTime then
			self._isCameraMove = false
			self._cameroMoveTime = 0
			self:changeCamera()
			--self:checkRoleSpecialAction()
		else
			local oldCamera = i3k_db_common.login.char[self._oldChar].camera1
			local newCamera = i3k_db_common.login.char[self._selCharIdx].camera1
			local dir = {}
			local right = {}
			local pos = {}
			dir.x = (newCamera.dir.x - oldCamera.dir.x) * self._cameroMoveTime / cameraTime + oldCamera.dir.x
			dir.y = (newCamera.dir.y - oldCamera.dir.y) * self._cameroMoveTime / cameraTime + oldCamera.dir.y
			dir.z = (newCamera.dir.z - oldCamera.dir.z) * self._cameroMoveTime / cameraTime + oldCamera.dir.z
			right.x = (newCamera.right.x - oldCamera.right.x) * self._cameroMoveTime / cameraTime + oldCamera.right.x
			right.y = (newCamera.right.y - oldCamera.right.y) * self._cameroMoveTime / cameraTime + oldCamera.right.y
			right.z = (newCamera.right.z - oldCamera.right.z) * self._cameroMoveTime / cameraTime + oldCamera.right.z
			pos.x = (newCamera.pos.x - oldCamera.pos.x) * self._cameroMoveTime / cameraTime + oldCamera.pos.x
			pos.y = (newCamera.pos.y - oldCamera.pos.y) * self._cameroMoveTime / cameraTime + oldCamera.pos.y
			pos.z = (newCamera.pos.z - oldCamera.pos.z) * self._cameroMoveTime / cameraTime + oldCamera.pos.z
			g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(dir), i3k_vec3_to_engine(right), i3k_vec3_to_engine(pos))
		end
	end
	if self._isPlayAction then
		self._actionCountdown = self._actionCountdown + dTime
		if self._actionCountdown > i3k_db_generals[self._selCharType].actionLast / 1000 then
			self._isPlayAction = false
			self._actionCountdown = 0
			self:deleteSpecialEntity()
		end
	end
end
function wnd_create_char_sel_class:checkRandomName()
	local editName = self._layout.vars.editName
	local tmp_name = editName:getText()
	if tmp_name == EDITNAME then
		self:updateRandomName()
	end
end

function wnd_create_char_sel_class:randomName(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		self:updateRandomName();
	end
end

function wnd_create_char_sel_class:updateRandomName()
	local editName = self._layout.vars.editName;
	if editName then
		local ret, name = g_i3k_db.i3k_db_get_random_name(self._selGenderType);
		if ret then
			editName:setText(name)
			EDITNAME = name
		end
	end
end















function wnd_create_char_sel_class:onPlay(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._selCharType then
			g_i3k_game_context._roleData.newrole.charType = self._selCharType;

			if self.onNextStep then
			--	self.onNextStep(self._selCharType, self._selGenderType);
			end

			local editName = self._layout.vars.editName
			EDITNAME = editName:getText()
			local namecount = i3k_get_utf8_len(EDITNAME)
			if namecount <= i3k_db_common.inputlen.namelen and namecount>= i3k_db_common.inputlen.nameminlen  then
				if EDITNAME ~= "" then
					local fashion = g_i3k_db.i3k_db_get_general_fashion(self._selCharType, self._selGenderType);

					local roleInfo = g_i3k_game_context:GetRoleList()
					local cfg = g_i3k_game_context:GetUserCfg()
					if cfg then
						cfg:SetSelectRole(#roleInfo+1)
					end
					i3k_do_create_role(EDITNAME, self._selGenderType, fashion.faceSkin[self._face] or 1, fashion.hairSkin[(self._hairStyle - 1) * 3 + self._hairColor] or 1, self._selCharType)
					local SEntity = require("logic/entity/i3k_hero");

					local hero = SEntity.i3k_hero.new(i3k_gen_entity_guid_new(SEntity.i3k_hero.__cname, 99999), true);
					hero:SetViewDistance(i3k_db_common.filter.FilterRadius)
					g_i3k_mmengine:SetDistanceClipFactor(8);
					g_i3k_mmengine:SetNoClipDistance(40);
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(236))
			end
		end
	end
end

function wnd_create_char_sel_class:onReturn(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._isPlayAction then
			return
		end
		if self.onReturnCB then
			self.onReturnCB()
			local camera = i3k_db_common.login.camera1;
			local roleInfo = g_i3k_game_context:GetRoleList()
			if #roleInfo == 0 then
				camera = i3k_db_common.login.char[6].camera1
			end
			g_i3k_mmengine:UpdateCamera2("MainCamera", i3k_vec3_to_engine(camera.dir), i3k_vec3_to_engine(camera.right), i3k_vec3_to_engine(camera.pos));
		end
	end
end

function wnd_create_char_sel_class:checkRoleSpecialAction()
	if i3k_db_generals[self._selCharType].specialActionCondition == 0 then
		self:setPlayerAi()
	elseif i3k_db_generals[self._selCharType].specialActionCondition == 2 then
		self:createSpecialEntity()
	elseif i3k_db_generals[self._selCharType].specialActionCondition == 1 then
		local user_cfg = g_i3k_game_context:GetUserCfg()
		local action = user_cfg:GetSpecialActionPlay()
		if table.indexof(action, self._selCharType) then
			self:setPlayerAi()
		else
			self:createSpecialEntity()
			user_cfg:SetSpecialActionPlay(self._selCharType)
		end
	end
end
function wnd_create_char_sel_class:setPlayerAi()
	if self._player then
		self._player:RmvAiComp(eAType_IDLE_JUST_STAND)
		self._player:AddAiComp(eAType_IDLE_STAND)
	end
end
function wnd_create_char_sel_class:createSpecialEntity()
	self:deleteSpecialEntity()
	for k, v in ipairs(i3k_db_generals[self._selCharType].monstersAction) do
		local cfg = i3k_db_monster_special_actions[v]
		local SEntity = require("logic/entity/i3k_simple_entity");
		local entity = SEntity.i3k_simple_entity.new("i3k_simple_entity"..k)
		entity:Create(cfg.modelId)
		if entity then
			entity:SetFaceDir(0, 2.0 * math.pi * (cfg.rotate / 360) - math.pi * 0.5, 0);
			entity:SetHittable(false);
			entity:Show(true, true);
			entity:ShowTitleNode(false);
			entity:SetPos(i3k_world_pos_to_logic_pos(cfg.pos))
			local alist = {}
			table.insert(alist, {actionName = cfg.action, actloopTimes = 1})
			table.insert(alist, {actionName = "stand", actloopTimes = -1})
			entity:PlayActionList(alist, 1)
			table.insert(self._entities, entity)
		end
	end
	self._isPlayAction = true
	self._actionCountdown = 0
	self._player:RmvAiComp(eAType_IDLE_JUST_STAND)
	local alist = {}
	table.insert(alist, {actionName = i3k_db_generals[self._selCharType].heroAction, actloopTimes = 1})
	table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
	self._player:PlayActionList(alist, 1)
end
function wnd_create_char_sel_class:deleteSpecialEntity()
	for k, v in ipairs(self._entities) do
		v:Release()
	end
	self._entities = {}
end
function wnd_create_char_sel_class:setHeroDir(dy)
	if self._isPlayAction then
		return
	end
	self._player:SetFaceDir(0, dy, 0)
end
function wnd_create(layout, ...)
	local wnd = wnd_create_char_sel_class.new();
		wnd:create(layout, ...);

	return wnd;
end
