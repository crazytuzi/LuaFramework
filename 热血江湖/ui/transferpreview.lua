module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/profile")

wnd_transferPreview = i3k_class("wnd_transferPreview", ui.wnd_profile)

function wnd_transferPreview:ctor()
	self._prfValue = 1
	self.info = {trfLvl = 1, bwType = 0}
	self._skillId = 0
	self._cfg = nil
	self._cfgM = nil
	self._showTick = 0
	self._isShow = 0
	self._pressBtn = nil
	self._pressBtn2 = nil
	self._gender = 1
	self._transformLvl = #i3k_db_zhuanzhi[1] - 1
	self._isChangePrf = false
	self._titleName = ""
	self._isBiography = false
end

function wnd_transferPreview:configure()
	local vars =  self._layout.vars
	self.hero_module = vars.roleModel
	self.skRoot = vars.skDescRoot
	vars.close_btn:onClick(self,self.onCloseUI)
	vars.rotationBtn:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self.revolve = vars.rotationBtn
	vars.changebtn:onClick(self, self.goToChange)
	self.changebtn = vars.changebtn
	self.chName = vars.chName
	self.titleImg = vars.titleImg
end

function wnd_transferPreview:onHide()
	self._pressBtn = nil
	self._pressBtn2 = nil
end

function wnd_transferPreview:refresh(isChangePrf, biographyId)
	self._prfValue = g_i3k_game_context:GetRoleType()
	if biographyId then
		self._prfValue = biographyId
		self._isBiography = true
	end
	self._cfg = i3k_db_zhuanzhi[self._prfValue]
	self._cfgM = self._cfg[self.info.trfLvl][self.info.bwType]
	self._gender = g_i3k_game_context:GetRoleGender();
	self._isChangePrf = isChangePrf

	if isChangePrf then
		self.titleImg:setImage(i3k_db_icons[4238].path)
	end

	local uiVars = self._layout.vars
	uiVars.prfBtn:onClick(self, self.changeTProfession, {trfLvl = 1, bwType = 0})
	uiVars.prfBtn:stateToPressed()
	self._pressBtn2 = uiVars.prfBtn
	for i=1 , self._transformLvl do
		local x = i + 1
		uiVars["wskBtn"..i]:onClick(self, self.changeTProfession, {trfLvl = x, bwType = 1})
		uiVars["bskBtn"..i]:onClick(self, self.changeTProfession, {trfLvl = x, bwType = 2})
	end
	for i = 1 , 2 do
		uiVars["skBtn"..i]:onTouchEvent(self,self.playAction, i)
	end

	for i = 1 , #i3k_db_generals do
		if self._isBiography then
			if i == self._prfValue then
				uiVars["prfBtn"..i]:stateToPressed()
			else
				uiVars["prfBtn"..i]:disable()
			end
		else
			uiVars["prfBtn"..i]:enable()
		uiVars["prfBtn"..i]:onClick(self, self.changeProfession, i)
		if i == self._prfValue then
			self._pressBtn = uiVars["prfBtn"..i]
			self._pressBtn:stateToPressed()
			end
		end
	end
	self:updateModel()
	self:updateInfo()
	self:updateChangePrf(self.info.bwType)
end

function wnd_transferPreview:changeTProfession(sender, args)
	if self.info ~= args then
		self.info = args
		self._cfgM = self._cfg[args.trfLvl][args.bwType]
		self._pressBtn2:stateToNormal()
		sender:stateToPressed()
		self._pressBtn2 = sender
		self:updateInfo()
		self:updateModel()
		self:updateChangePrf(args.bwType)
	end
end

-- function wnd_transferPreview:onUpdate(dTime)
-- 	self._showTick = self._showTick + dTime
-- 	if self._showTick > 0.7 and self._isShow == 1 then
-- 		self._isShow = 2
-- 		self.skRoot:show()
-- 		self._layout.vars.skDesc:setText(i3k_db_skills[self._skillId].desc)
-- 	end
-- end

-- 获取选中技能或是心法的描述
function wnd_transferPreview:getSelectSkillOrXinfaDesc(skillID)
	if skillID < 0 then
		local xinfaCfg = i3k_db_xinfa[-skillID]
		local effectDesc = xinfaCfg.effectDesc[1]
		local xinfaName = xinfaCfg.name
		return "[气功]"..effectDesc
	end
	return i3k_db_skills[skillID].desc
end

function wnd_transferPreview:getSelectSkillOrXinfaName(skillID)
	if skillID < 0 then
		local xinfaCfg = i3k_db_xinfa[-skillID]
		local xinfaName = xinfaCfg.name
		return xinfaName
	end
	return i3k_db_skills[skillID].name
end

function wnd_transferPreview:playAction(sender,event,index)
	local skillId = self._cfgM["skill"..index]
	if event == ccui.TouchEventType.began then
		if skillId == 0 then
			skillId = -self._cfgM.newQiGongID -- 气功id设置为负值，与技能做出区别
		end
		if self._skillId ~= skillId then
			self._skillId = skillId
			self.skRoot:show()
			self._layout.vars.skDesc:setText(self:getSelectSkillOrXinfaDesc(skillId))
		end
	elseif event == ccui.TouchEventType.canceled then
		self._skillId = 0
		self.skRoot:hide()
	elseif event == ccui.TouchEventType.ended then
		self._skillId = 0
		if skillId ~= 0 then
			self.hero_module:pushActionList(i3k_db_skills[skillId].action, 1)
			self.hero_module:pushActionList("stand", -1)
			self.hero_module:playActionList()
		end
		self.skRoot:hide()
	end
end

function wnd_transferPreview:getSkin(eqCfg)
	if self._gender == 1 then
		if self.info.bwType == 1 then
			return eqCfg.skin_ZM_ID
		elseif self.info.bwType == 2 then
			return eqCfg.skin_XM_ID
		else
			return eqCfg.skin_M_ID
		end
	else
		if self.info.bwType == 1 then
			return eqCfg.skin_ZF_ID
		elseif self.info.bwType == 2 then
			return eqCfg.skin_XF_ID
		else
			return eqCfg.skin_F_ID
		end
	end

end

function wnd_transferPreview:updateModel()
	local fashionId = i3k_db_generals[self._prfValue].fashion[self._gender]
	local fashionCfg = i3k_db_general_fashion[fashionId]
	ui_set_hero_model(self.hero_module, fashionCfg.modelID)
	local face = i3k_db_fashion_res[fashionCfg.faceSkin[1]].skinID
	local hair = self:getSkin(g_i3k_db.i3k_db_get_equip_item_cfg(self._cfgM.hairId))
	local weapon = self:getSkin(g_i3k_db.i3k_db_get_equip_item_cfg(self._cfgM.weaponId))
	local cuirass = self:getSkin(g_i3k_db.i3k_db_get_equip_item_cfg(self._cfgM.cuirassId))

	self.hero_module:setSkin(i3k_db_skins[face].path,"face")

	for i,v in ipairs(hair) do
		if v > 0 then
			self.hero_module:setSkin(i3k_db_skins[v].path,"hair"..i)
		end
	end

	for i,v in ipairs(weapon) do
		if v > 0 then
			self.hero_module:setSkin(i3k_db_skins[v].path,"weapon"..i)
		end
	end

	for i,v in ipairs(cuirass) do
		if v > 0 then
			self.hero_module:setSkin(i3k_db_skins[v].path,"cuirass"..i)
		end
	end
end

function wnd_transferPreview:updateInfo()
	local vars = self._layout.vars
	vars.prfName:setText(self._cfg[1][0].name)
	vars.prfIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[self._prfValue].classImg))
	if self._skillId > 0 then
		vars.skDesc:setText(i3k_db_skills[self._skillId].desc)
	else
		self.skRoot:hide()
	end
	vars.prfName2:setText(self._cfgM.name)
	vars.prfDesc:setText(self._cfgM.desc)
	for i = 1 , 2 do
		local skillID = self._cfgM["skill"..i]
		if skillID > 0 then
			vars["skImg"..i]:setImage(g_i3k_db.i3k_db_get_skill_icon_path(self._cfgM["skill"..i]))
			if vars["skillRoot"..i] and vars["xinfaRoot"..i] then
				vars["skillRoot"..i]:show()
				vars["xinfaRoot"..i]:hide()
			end
		else
			vars["skillRoot"..i]:hide()
			vars["xinfaRoot"..i]:show()
			if skillID == 0 then
				skillID = self._cfgM.newQiGongID -- 气功id设置为负值，与技能做出区别
			end
			local qigongBookID = i3k_db_xinfa[skillID].itemID
			vars["xinfaBg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(qigongBookID))
			vars["xinfaIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(qigongBookID, g_i3k_game_context:IsFemaleRole()))
			vars["xinfaBtn"..i]:onTouchEvent(self,self.playAction, i)
		end
	end
	for i=1 , self._transformLvl do
		local x = i + 1
		vars["wskTxt"..i]:setText(self._cfg[x][1].name)
		vars["bskTxt"..i]:setText(self._cfg[x][2].name)
	end
end

function wnd_transferPreview:changeProfession(sender, args)
	if self._prfValue ~= args then
		self._cfg = i3k_db_zhuanzhi[args]
		self._cfgM = self._cfg[self.info.trfLvl][self.info.bwType]
		self._pressBtn:stateToNormal()
		sender:stateToPressed()
		self._pressBtn = sender
		self._prfValue = args
		self:updateModel()
		self:updateInfo()
		self:updateChangePrf(self.info.bwType)
	end
end

function wnd_transferPreview:updateChangePrf(bwType)
	if not self._isChangePrf then
		return
	end
	self.changebtn:show()
	self.chName:show()
	self.changebtn:disable()
	self.chName:setText(i3k_get_string(1048))
	if g_i3k_game_context:GetTransformLvl() == self.info.trfLvl and not(g_i3k_game_context:GetRoleType() == self._prfValue and g_i3k_game_context:GetTransformBWtype() == bwType) then
		self._titleName = string.format("%s-%s-%s", i3k_db_generals[self._prfValue].name, i3k_get_transfer_type_desc(bwType), self._cfgM.name)
		self.chName:setText(i3k_get_string(1051, self._titleName))
		self.changebtn:enable()
	end
end

function wnd_transferPreview:goToChange( )
	if not g_i3k_game_context:IsOnHugMode() then
		if self._isBiography then
			g_i3k_ui_mgr:OpenUI(eUIID_ChangeProfession)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChangeProfession, 0, self._titleName, self.info.bwType, self._prfValue, g_BIOGRAPHY_TRANSFORM_FORWARD)
		else
			if i3k_db_generals[self._prfValue].classType == 2 then
				local state = g_i3k_game_context:isCanTransformBack(self._prfValue)
				if state == g_BIOGIAPHY_STATE_FINISH then
					g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(18530))
				elseif state == g_BIOGIAPHY_STATE_UNFINISH then
					g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(18530))
					--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18508))
				else
		i3k_sbean.sync_last_change_pro_timeReq(self._titleName, self.info.bwType, self._prfValue)
				end
			else
				i3k_sbean.sync_last_change_pro_timeReq(self._titleName, self.info.bwType, self._prfValue)
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17058))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_transferPreview.new()
	wnd:create(layout, ...)
	return wnd;
end
