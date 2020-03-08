
function DrinkHouse:OnEnterMap(nChannelId, szRandomName, szOrgName)
	self.nChannelId = nChannelId
	self.szOrgName = szOrgName
	if not self.bRegistNotofy then
		self.nRegisterEnterMapId = me.nMapTemplateId
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		self.bRegistNotofy = true;

		me.SendBlackBoardMsg("已自动开启在线托管");
	end
	me.GetNpc().SetName(szRandomName);
	ChatMgr:SetlDynamicChannelColor(nChannelId, self.tbDef.CHANNEL_COLOR)
	ChatMgr:SetChatRightPopupChannelType(nChannelId, "DrinkHouseChatRole", -180, -259)
	ChatMgr.tbVoiceAutoSettingNameMap[nChannelId] = "CheckPubVoice"
	Ui:OpenWindowListOverLap("QYHLeavePanel","DrinkHouse")

	Map:DoCmdWhenMapLoadFinish(me.nMapId, "DrinkHouse:UpdateSceneObjs")
end

function DrinkHouse:UpdateSceneObjs(  )
	local Effect = Ui.Effect
	for i,v in ipairs(DrinkHouse.tbDef.HIDE_OBJ) do
		Effect.SetSceneObjActive(v, false)
	end
end

function DrinkHouse:OnEnterNewMap(nMapTemplateId)
	if nMapTemplateId ~= self.nRegisterEnterMapId then
		self:OnCloseBattleMap();
	end
end

function DrinkHouse:OnLeaveCurMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function DrinkHouse:OnCloseBattleMap(  )
	if self.bRegistNotofy then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		self.bRegistNotofy = nil;
	end
	if self.nChannelId then
		ChatMgr:SetChatRightPopupChannelType(self.nChannelId, nil)
		ChatMgr.tbVoiceAutoSettingNameMap[self.nChannelId] = nil
		self.nChannelId = nil;
	end
	
	if self.szOrgName then
		me.GetNpc().SetName(self.szOrgName);
		self.szOrgName = nil
	end
	self.nRegisterEnterMapId = nil;
	self.nDrinkInviteTimeOut = nil
	DrinkHouse:RestoreDinkAction()
	Ui:CloseWindow("HomeScreenFuben")
	Ui:CloseWindow("NormalTopButton")
end

function DrinkHouse:InviteDrinkPopClick(dwRoleId)
	if not self:InviteDrinkPopAvaliable(me) then
		return
	end
	RemoteServer.DrinkHousePlayerRequest("InviteDrink", dwRoleId)
end

function DrinkHouse:SynDrinkInviteTimeOut(nDrinkInviteTimeOut)
	self.nDrinkInviteTimeOut = nDrinkInviteTimeOut
end

function DrinkHouse:RestoreDinkAction( )
	Operation:EnableWalking()
	AutoFight:StopFollowTeammate()
end


function DrinkHouse:OnEnterRentFuben()
	Fuben:ClearClientData()
	Ui:OpenWindow("HomeScreenFuben", "DrinkHouseFuben", {})
	if not self.bRegistNotofy then
		self.bRegistNotofy = true;
		self.nRegisterEnterMapId = me.nMapTemplateId
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
	end
	Map:DoCmdWhenMapLoadFinish(me.nMapId, "DrinkHouse:UpdateSceneObjs")
	Fuben:ShowLeave()
	Fuben:ShowHelp(self.tbRentDef.szUiHelpKey)
end

function DrinkHouse:OnEnterDinnerFuben()
	Fuben:ClearClientData()
	Ui:OpenWindow("HomeScreenFuben", "DrinkHouseFuben", {})
	if not self.bRegistNotofy then
		self.bRegistNotofy = true;
		self.nRegisterEnterMapId = me.nMapTemplateId
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
	end
	Map:DoCmdWhenMapLoadFinish(me.nMapId, "DrinkHouse:UpdateSceneObjs")
	Map:DoCmdWhenMapLoadFinish(me.nMapId, "DrinkHouse:HideTopButtonUp")
	Fuben:ShowLeave()
	Fuben:ShowHelp(self.tbDinnerDef.szUiHelpKey)
end

function DrinkHouse:HideTopButtonUp(  )
	Ui:OpenWindow("NormalTopButton")
	UiNotify.OnNotify(UiNotify.emNOTIFY_SWITCH_TOP_BUTTON_UP, "ShowDownParts")
end

function DrinkHouse:PlayDinnerFubenFirework(nId)
	self:PlayFirework(nId);
	for i = 1, DrinkHouse.tbDinnerDef.nFireworkTimes - 1 do
		Timer:Register(Env.GAME_FPS * DrinkHouse.tbDinnerDef.nFireworkTimeInterval * i, self.PlayFirework, self, nId);
	end
end

function DrinkHouse:PlayFirework(nId)
	local tbFirework = DrinkHouse.tbDinnerDef.tbPlayFireworkSetting[nId]
	if not tbFirework then
		return
	end
	for _, v in ipairs(tbFirework) do
		for i = 1, DrinkHouse.tbDinnerDef.nFireworkTimes do
			Ui:PlayEffect(unpack(v));
		end
	end
end