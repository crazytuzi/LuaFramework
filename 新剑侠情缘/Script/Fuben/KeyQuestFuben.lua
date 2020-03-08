local KeyQuestFuben = Fuben.KeyQuestFuben

function KeyQuestFuben:TrySignUp( ... )
    local bRet, szMsg = self:CanSignUp(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    RemoteServer.KeyQuestFubenRequest("PlayerSignUp");
end

function KeyQuestFuben:EnterFightMap( nFloor, tbTeamKeyInfo )
	self.nFloor = nFloor
	self:OnSynTeamKeyInfo(tbTeamKeyInfo)
	Ui:OpenWindow("HomeScreenFuben", "KeyQuestFuben", { nFloor = nFloor})
	--进下一层时还是重新注册吧
	if not self.bRegistNotofy then
		self.bRegistNotofy = true;
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self.OnSetPlayerName, self)  --同步设置玩家名字时

		local tbAllCanShowItemID = self:GetAllCanShowItems()
		local fnFilterItem = function (pItem)
			return tbAllCanShowItemID[pItem.dwTemplateId]
		end
		Ui:GetClass("ItemBox"):SetFilterItemFunc(fnFilterItem) 
	end
end

function KeyQuestFuben:OnEnterNewMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function KeyQuestFuben:OnLeaveCurMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function KeyQuestFuben:OnCloseBattleMap()
	if self.bRegistNotofy then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		self.bRegistNotofy = nil;
		Ui:GetClass("ItemBox"):SetFilterItemFunc(nil) 
	end
	self.nFloor = nil
	self.tbTeamKeyInfo = nil
	Ui:CloseWindow("HomeScreenFuben")
end

function KeyQuestFuben:OnSetPlayerName(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	if pNpc.dwTeamID == TeamMgr:GetTeamId() then --自己的 npc teamId 被OnSyncClientPlayer清掉了
		return
	end
	pNpc.SetName("神秘人");
end

--现在只有钥匙信息
function KeyQuestFuben:OnSynTeamKeyInfo( tbTeamKeyInfo )
	self.tbTeamKeyInfo = tbTeamKeyInfo
	UiNotify.OnNotify(UiNotify.emNOTIFY_KEY_QUEST_FUBEN_UPDATE, "team")
end

function KeyQuestFuben:IsMemberHasKey( dwRoleId )
	if self.tbTeamKeyInfo and self.tbTeamKeyInfo[dwRoleId] then
		return self.nFloor
	end
end