_G.classlist['CharController'] = 'CharController'
_G.CharController = setmetatable({},{__index = IController})

CharController.name = "CharController"
CharController.objName = 'CharController'

function CharController:OnCharMoveToNotify(msg)
	msg.srcX = msg.srcX / 1000 
	msg.srcY = msg.srcY / 1000
	msg.disX = msg.disX / 1000
	msg.disY = msg.disY / 1000
	if msg.objType == enEntType.eEntType_Player then
	    CPlayerMap:OnPlayerMoveTo(msg.roleId, msg.srcX, msg.srcY,
	        msg.disX, msg.disY)
	elseif msg.objType == enEntType.eEntType_Monster then
		MonsterController:MoveTo(msg.roleId, msg.disX, msg.disY)
	elseif msg.objType == enEntType.eEntType_Npc then

	elseif msg.objType == enEntType.eEntType_LingShou then
		LSController:MoveTo(msg.roleId, msg.disX, msg.disY)
	elseif msg.objType == enEntType.eEntType_Collection then
		CollectionController:MoveTo(msg.roleId, msg.disX, msg.disY)
	elseif msg.objType == enEntType.eEntType_Patrol then
		HuncheController:MoveTo(msg.roleId, msg.disX, msg.disY)
	end
	msg = nil
end

function CharController:OnMonsterMoveToNotify(msg)
	msg.disX = msg.disX / 1000
	msg.disY = msg.disY / 1000
	MonsterController:MoveTo(msg.roleId, msg.disX, msg.disY)
	msg = nil
end

function CharController:OnCharMoveStopNotify(msg)
	msg.stopX = msg.stopX / 1000
	msg.stopY = msg.stopY / 1000
	msg.dir = msg.dir / 1000
	if msg.objType == enEntType.eEntType_Player then
		CPlayerMap:OnPlayerMoveEnd(msg.roleId, msg.stopX, msg.stopY, msg.dir)
	elseif msg.objType == enEntType.eEntType_Monster then
		MonsterController:StopMove(msg.roleId, msg.stopX, msg.stopY, msg.dir)
	elseif msg.objType == enEntType.eEntType_Npc then

	elseif msg.objType == enEntType.eEntType_LingShou then
		LSController:StopMove(msg.roleId, msg.stopX, msg.stopY, msg.dir)
	elseif msg.objType == enEntType.eEntType_Collection then
		CollectionController:StopMove(msg.roleId, msg.stopX, msg.stopY, msg.dir)
	elseif msg.objType == enEntType.eEntType_Patrol then
		HuncheController:StopMove(msg.roleId, msg.stopX, msg.stopY, msg.dir)	
	end

end

function CharController:OnCharChangeDir(msg)
    if msg.objType == enEntType.eEntType_Player then
        CharController:OnPlayerChangeDir(msg.guid, msg.dir)
    elseif msg.objType == enEntType.eEntType_Monster then
    elseif msg.objType == enEntType.eEntType_Npc then
    elseif msg.objType == enEntType.eEntType_LingShou then
    end
end

_G.onCharAdd = function(value)

	if ArenaBattle.inArenaScene ~= 0 then
		return
	end
	
	if CharController:CheckLimit(value.charType,1) then
		return;
	end
	
	value.x = value.x / 1000
    value.y = value.y / 1000
    value.faceto = value.faceto / 1000
	if value.charType == enEntType.eEntType_Player then
		value.dwRoleID = value.charId
		value.charId = nil
		value.speed = value.speed / 1000
		CPlayerMap:OnAddRole(value)
	elseif value.charType == enEntType.eEntType_Monster then
		value.speed = value.speed / 1000
		MonsterController:AddMonster(value)
	elseif value.charType == enEntType.eEntType_Npc then
		NpcController:AddNpcToNpcList(value)
	elseif value.charType == enEntType.eEntType_Item then
        MainPlayerController:AddItem(value)
    elseif value.charType == enEntType.eEntType_Collection then
    	CollectionController:AddCollectionList(value)
    elseif value.charType == enEntType.eEntType_Trap then
    	TrapController:AddTrap(value)
    elseif value.charType == enEntType.eEntType_Duke then
    	DukeController:AddDuke(value)
    elseif value.charType == enEntType.eEntType_LingShou then
    	value.speed = value.speed / 1000
    	LSController:AddLingShou(value)
    elseif value.charType == enEntType.eEntType_Portal then
    	value.id = value.configId
    	value.configId = nil
    	value.cid = value.charId
    	value.charId = nil
    	CPlayerMap:AddPortal(value)
    elseif value.charType == enEntType.eEntType_Patrol then
    	HuncheController:AddHunche(value)
	end
end

function CharController:OnCharDelete(msg)

	CharController:CheckLimit(msg.objType,-1);
	
    if msg.objType == enEntType.eEntType_Player then
        CPlayerMap:DelRole(msg.guid)
    elseif msg.objType == enEntType.eEntType_Monster then
        MonsterController:DeleteMonster(msg.guid)
    elseif msg.objType == enEntType.eEntType_Npc then
        local npcid  = NpcController:DeleteNpc(msg.guid)
    elseif msg.objType == enEntType.eEntType_Item then
        MainPlayerController:RemoveItem(msg.guid)
    elseif msg.objType == enEntType.eEntType_Collection then
        CollectionController:DeleteCollection(msg.guid)
    elseif msg.objType == enEntType.eEntType_Trap then
    	TrapController:DeleteTrap(msg.guid)
    elseif msg.objType == enEntType.eEntType_Duke then
    	DukeController:DeleteDuke(msg.guid)
    elseif msg.objType == enEntType.eEntType_LingShou then
    	LSController:DeleteLingShou(msg.guid)
    elseif msg.objType == enEntType.eEntType_Portal then
    	CPlayerMap:DeletePortal(msg.guid)
    elseif msg.objType == enEntType.eEntType_Patrol then
    	HuncheController:DeleteHunche(msg.guid)
    end

    if msg.guid == CCursorManager.CurrCharCid then
    	CCursorManager:DelState(CCursorManager.CurrCursor)
    end

end

function CharController:OnCharDead(value)
    if value.objType == enEntType.eEntType_Player then
        MainPlayerController:OnPlayerDead(value)
    elseif value.objType == enEntType.eEntType_Monster then
        MonsterController:OnDead(value)
		if DungeonModel:IsInDungeon() then
			DungeonModel:SetKillNum(value)
		end
    end
end

function CharController:OnChangePos(msg)
	local cid = msg.roleId
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		return
	end
	if charType == enEntType.eEntType_Player then
		MainPlayerController:OnChangePos(msg)
	elseif charType == enEntType.eEntType_LingShou then
		LSController:OnChangePos(msg)
	end
end

function CharController:Create()
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_OBJ_MOVE_TO_NOTIFY,self,self.OnCharMoveToNotify);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_MONSTER_MOVE_TO_NOTIFY,self,self.OnMonsterMoveToNotify);
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_OBJ_MOVE_STOP_NOTIFY,self,self.OnCharMoveStopNotify);
	MsgManager:RegisterCallBack(MsgType.SC_StateBitChanged,self,self.OnStateChange)
    MsgManager:RegisterCallBack(MsgType.SC_CHAR_CHANGE_DIR,self,self.OnCharChangeDir)
    CharAddCmd:create(onCharAdd):execute()
    MsgManager:RegisterCallBack(MsgType.SC_SCENE_OBJ_LEFT_NOTIFY,self,self.OnCharDelete)
    MsgManager:RegisterCallBack(MsgType.SC_ObjDeadInfo,self,self.OnCharDead)
   	MsgManager:RegisterCallBack(MsgType.SC_OBJ_ATTR_INFO, self, self.OnObjAttrInfoNotify)
   	MsgManager:RegisterCallBack(MsgType.SC_ChangePos, self, self.OnChangePos)
   	MsgManager:RegisterCallBack(MsgType.SC_UpdateTransferModel, self, self.OnTransform)
	
end

function CharController:Update()

end


function CharController:Destroy()

end

function CharController:OnBtnPick()

end

function CharController:OnRollOver()

end

function CharController:OnRollOut()

end

function CharController:OnEnterGame()

end

function CharController:GetCharByCid(cid)
	if CPlayerMap:GetPlayer(cid) then
		return CPlayerMap:GetPlayer(cid), enEntType.eEntType_Player
	elseif MonsterController:GetMonster(cid) then
		return MonsterController:GetMonster(cid), enEntType.eEntType_Monster
	elseif NpcController:GetNpc(cid) then
		return NpcController:GetNpc(cid), enEntType.eEntType_Npc
	elseif CollectionController:GetCollection(cid) then
		return CollectionController:GetCollection(cid), enEntType.eEntType_Collection
	elseif LSController:GetLingShou(cid) then
		return LSController:GetLingShou(cid), enEntType.eEntType_LingShou
	else
		return nil, nil
	end
end

function CharController:OnPlayerChangeDir(cid, fDirValue, nTime)
 	local char = CharController:GetCharByCid(cid)
 	if not char then
 		return
 	end
	CharController:ChangeDir(char, fDirValue, nTime)
end

function CharController:ChangeDir(char, fDirValue, nTime)
	if not char:GetAvatar() then
		return
	end
	char:GetAvatar():SetDirValue(fDirValue, nTime)
end

function CharController:OnObjAttrInfoNotify(msg)
	local charId = msg.roleId
	local charType = msg.objType
	local attrSize = msg.attrData_size
	local attrList = msg.attrData

	if charType == enEntType.eEntType_Player then
		local info = {}
		info.roleId = charId
		for k, v in pairs(attrList) do
			info[v.type] = v.value
		end
		CPlayerMap:onObjAttrInfoNotify(info.roleId, info)  --3
	elseif charType == enEntType.eEntType_Monster then
		--todo 改成monster info
		local monster = MonsterController:GetMonster(charId)
		if monster then
			for i = 1, #attrList do
				if attrList[i].type == enAttrType.eaHp then
					monster:UpdateHPInfo(attrList[i].value, nil)
				elseif attrList[i].type == enAttrType.eaMaxHp then
					monster:UpdateHPInfo(nil, attrList[i].value)
				elseif attrList[i].type == enAttrType.eaMoveSpeed then
					monster:UpdateSpeed(attrList[i].value)
				end
			end
		end
	elseif charType == enEntType.eEntType_LingShou then
		local ls = LSController:GetLingShou(charId);
		if ls then
			for i = 1, #attrList do
				if attrList[i].type == enAttrType.eaMoveSpeed then
					ls:UpdateSpeed(attrList[i].value);
				end
			end
		end
	end
	--更新UI目标显示
	local char = self:GetCharByCid( charId )
	if TargetManager:CheckIsTarget(char) then
		TargetManager:UpdateTarget(attrList);
	end
	
	msg.roleId = nil
	msg.objType = nil
	msg.attrData_size = nil
	msg.attrData = nil
end

function CharController:OnStateChange(msg)
	local cid = msg.roleID
	local stateType = msg.idx
	local stateValue = msg.set
	local char, charType = CharController:GetCharByCid(cid)
    if not char then
        return
    end

   	if charType == enEntType.eEntType_Monster or charType == enEntType.eEntType_Player then
   		local stateInfo = char:GetStateInfo()
   		stateInfo:SetValue(stateType, stateValue)
   	end

   	if stateType == PlayerState.UNIT_BIT_RAMPAGE then
   		if cid == MainPlayerController:GetRoleID() then
   			MainPlayerController:SetRampage(stateValue)
   		end
	elseif stateType == PlayerState.UNIT_BIT_INCOMBAT then
--		 if stateValue == 1 then
--			 char:SetBattleState(true)
--			 if charType == enEntType.eEntType_Player then
--				 if char.battleTimer then
--		             TimerManager:UnRegisterTimer(char.battleTimer)
--		         end
--		     end
--	     else
--	    	 char:SetBattleState(false)
--	     end  --@yantielei
		if charType == enEntType.eEntType_Monster then
			if stateValue == 1 then
				char:SetBattleState(true)
			else
				char:SetBattleState(false)
			end
		end
	elseif stateType == PlayerState.UNIT_BIT_MIDNIGHT then
		if charType == enEntType.eEntType_Player then
			char:SetNightState(stateValue)
		end
	elseif stateType == PlayerState.UNIT_BIT_HOLD then
		if cid == MainPlayerController:GetRoleID() then
			if MainPlayerController:IsMoveState() then
		        MainPlayerController:StopMove()
		    end
		end
	elseif stateType == PlayerState.UNIT_BIT_IN_PK then
		char:SetBattleState(stateValue == 1)
	elseif stateType == PlayerState.UNIT_BIT_BIANSHEN then
		if cid == MainPlayerController:GetRoleID() then
		end
	elseif stateType == PlayerState.UNIT_BIT_AI_LOCKED then
		char:SetLockedState(stateValue)
	end
end

function CharController:HidePlayerAndMonster(npcId, bShowNpc)
	local avatar = nil
	for cid, monster in pairs(MonsterModel:GetMonsterList()) do
		monster.isShowHeadBoard = false
		avatar = monster:GetAvatar()
		if avatar.ClearSkipNumber then
			avatar:ClearSkipNumber()
		end
		
		if avatar and avatar.objNode and avatar.objNode.entity then
			avatar.objNode.visible = false
		end
	end
	
	for cid, collection in pairs(CollectionModel.collectionList) do
		avatar = collection:GetAvatar()
		--collection.isHideName = true
		if avatar and avatar.objNode and avatar.objNode.entity then
			avatar.objNode.visible = false
		end
	end
	
	local selfCid = MainPlayerController:GetRoleID()
	for cid, player in pairs(CPlayerMap:GetAllPlayer()) do
		player.isShowHeadBoard = false
		player:SetMagicWeaponVisible(false)
		player:SetLingQiVisible(false)
		player:SetMingYuVisible(false)
		player:HidePet()
		if cid ~= selfCid then
			avatar = player:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = false
			end
		end
	end
	
	for cid, npc in pairs(NpcModel:GetStoryNpcList()) do
		npc.isShowHeadBoard = false
	end
	if not bShowNpc then
		for cid, npc in pairs(NpcModel:GetNpcList()) do
			npc.isShowHeadBoard = false
			if not npcId or npcId ~= npc.npcId then
				avatar = npc:GetAvatar()
				if avatar and avatar.objNode and avatar.objNode.entity then
					avatar.objNode.visible = false
				end
			end
		end
	else
		for cid, npc in pairs(NpcModel:GetNpcList()) do
			if not npc.isHide then
				avatar = npc:GetAvatar()
				if avatar and avatar.objNode and avatar.objNode.entity then
					avatar.objNode.visible = true			
				end
			end
		end
	end

	for cid, lingshou in pairs(LSModel:GetLingShouList()) do
		avatar = lingshou:GetAvatar()
		if avatar and avatar.objNode and avatar.objNode.entity then
			avatar.objNode.visible = false			
		end
	end

	for cid, trap in pairs(TrapModel:GetTrapList()) do
		trap:Delete()
	end
	
end

function CharController:ShowPlayerAndMonster()
	local avatar = nil
	for cid, monster in pairs(MonsterModel:GetMonsterList()) do
		if not monster.isHide then
			avatar = monster:GetAvatar()
			monster.isShowHeadBoard = true
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = true
			end
		end
	end
	
	for cid, collection in pairs(CollectionModel.collectionList) do
		if not collection.isHide then
			if collection.isShowHeadBoard then
				--collection.isHideName = false
			end
			avatar = collection:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = true
			end
		end
	end
	
	local selfCid = MainPlayerController:GetRoleID()
	for cid, player in pairs(CPlayerMap:GetAllPlayer()) do
		player.isShowHeadBoard = true
		player:SetMagicWeaponVisible(true)
		player:SetLingQiVisible(true)
		player:SetMingYuVisible(true)
		player:ShowPet()
		if cid ~= selfCid then
			avatar = player:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = true
			end
		end
	end
	
	for cid, npc in pairs(NpcModel:GetStoryNpcList()) do
		npc.isShowHeadBoard = true
	end
	for cid, npc in pairs(NpcModel:GetNpcList()) do
		if not npc.isHide then
			npc.isShowHeadBoard = true
			avatar = npc:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = true			
			end
		end
	end
	
	for cid, lingshou in pairs(LSModel:GetLingShouList()) do
		avatar = lingshou:GetAvatar()
		if avatar and avatar.objNode and avatar.objNode.entity then
			avatar.objNode.visible = true			
		end
	end

	for cid, trap in pairs(TrapModel:GetTrapList()) do
		trap:Show()
	end

end

function CharController:ShowDropItem()
	local avatar = nil
	for i,item in pairs(MainPlayerModel.allDropItem) do
		if item then
			item.isShowName = true
			avatar = item:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = true
			end
		end;
	end;
end

function CharController:HideDropItem()
	local avatar = nil
	for i,item in pairs(MainPlayerModel.allDropItem) do
		if item then
			item.isShowName = false
			avatar = item:GetAvatar()
			if avatar and avatar.objNode and avatar.objNode.entity then
				avatar.objNode.visible = false
			end
		end;
	end;
end

function CharController:ShowMapScriptNode()
	for _, mapScriptNode in pairs(CPlayerMap.allMapScriptNode) do
		if mapScriptNode
			and mapScriptNode.objNode
			and mapScriptNode.nodeType ~= 1 then
			mapScriptNode.objNode.visible = true
		end
	end
end

function CharController:HideMapScriptNode()
	for _, mapScriptNode in pairs(CPlayerMap.allMapScriptNode) do
		if mapScriptNode
			and mapScriptNode.objNode
			and mapScriptNode.nodeType ~= 1 then
			mapScriptNode.objNode.visible = false
		end
	end
end

function CharController:OnTransform(msg)
	local char, charType = CharController:GetCharByCid(msg.uid);
	if not char then
		return;
	end
	
	char:SetTianshenId(msg.model,msg.star,msg.level,msg.color);
	local toTransform = TransformController:SetTransform(msg.uid,msg.model,true);
	
	if msg.uid == MainPlayerController:GetRoleID() then
		if toTransform then
			TianShenController:TransformUpdate(msg.model ~=0,msg.model);  
		end
   	end
end

CharController.limits = {};
function CharController:SetCountLimit(type,count)
	count = count or 0;
	if count>0 then
		local info = self.limits[type];
		info = info or {};
		self.limits[type] = info;
		info.limit = count;
		info.count = info.count or 0;
		info.count = math.min(count,info.count);
	else
		self.limits[type] = nil;
	end
end

function CharController:CheckLimit(type,coefficient)
	local info = self.limits[type];
	if not info then
		return;
	end
	info.count = info.count + coefficient;
	info.count = math.max(info.count,0);
	info.count = math.min(info.count,info.limit);
	return info.count==info.limit;
end

function CharController:ClearAllLimits()
	for type,info in pairs(self.limits) do
		self.limits[type] = nil;
	end
end

function CharController:ResetLimits()
	for type,info in pairs(self.limits) do
		info.count = 0;
	end
end

function CharController:OnLeaveSceneMap()
	self:ResetLimits();
end


