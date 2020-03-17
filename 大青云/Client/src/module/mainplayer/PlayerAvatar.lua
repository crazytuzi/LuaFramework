_G.classlist['CPlayerAvatar'] = 'CPlayerAvatar'
_G.CPlayerAvatar = {}
CPlayerAvatar.objName = 'CPlayerAvatar'
setmetatable(CPlayerAvatar,{__index = CAvatar});
local playerAvatarMeta = {__index = CPlayerAvatar}
--对应的模型ID，骨骼ID，默认动画
function CPlayerAvatar:new()
    --Debug("CPlayerAvatar:new()")
	local obj = CAvatar:new();--玩家不设置主模型
    obj.avtName = "playerAvatar"
	obj.objHlBlender = _Blender.new();
	obj.objHlBlender:highlight(0x55555555);
	obj.setSkipNormal = {};		--头顶血相关的跳字队列
	obj.bHaveSkipNor = false;	--跳字队列是否有成员
	obj.dwLastSkipNormalShowTime = 0;
    obj.bIsAttack = false;
    obj.horse = nil; --坐骑
    --obj.rider = nil; --骑乘者
    --obj.riderMeshNull = _Mesh.new('');
    obj.animation_index = 1 --普通攻击索引
	obj.mountState = 2; --默认未骑乘
    obj.dwIdleAnimaID = nil;
    obj.dwMoveAnimaID = nil;
    --obj.bMoveing = false;
	-- 时装
	obj.fashions = PlayerFashions:New()
	obj.equips = {};
	obj.pendants = {};
	obj.equipActionDir = 0;			--方向,0表示从非战到战，1反之
	obj.xianjieModelID = 0;
	obj.xuanBingModelID = 0;			--玄兵ID
	obj.transform = nil;
	setmetatable(obj, playerAvatarMeta)
    return obj;
end;

function CPlayerAvatar:CreateNewAvatar(szMainMeshFile,szSklFile)
	local objAvatar = CPlayerAvatar:new();
	objAvatar.dwRoleID = self.dwRoleID; 
	objAvatar.dwProfID = self.dwProfID;
	return objAvatar;
end;
--通过VO创建Avatar
--{prof,arms,dress,fashionsHead,fashionsArms,fashionsDress,wuhunId}
function CPlayerAvatar:CreateByVO(vo)
	
	local fashionsHead = vo.fashionsHead or vo.fashionshead
	local fashionsDress = vo.fashionsDress or vo.fashionsdress
	local fashionsArms = vo.fashionsArms or vo.fashionsarms
	
	self:SetShenwuId(vo.shenwuId or 0)

	self.fashions:SetFashions(fashionsHead, fashionsDress, fashionsArms, vo.prof)
	self:Create(0,vo.prof);
	self:SetDress(vo.dress, fashionsHead, fashionsDress);
	self:SetArms(vo.arms,fashionsArms);
	self:SetShoulder(vo.shoulder or 0);
	self:SetWingModel(vo.wing or 0);
	self:UpdateFashions();
	
	if self.wuhunId and self.wuhunId>0 then
		SpiritsUtil:RemoveWuhunFushengPfx(self.wuhunId,self.dwProfID,self);
		self.wuhunId = 0;
	end
	if vo.wuhunId > 0 then
		SpiritsUtil:SetWuhunFushengPfx(vo.wuhunId,self.dwProfID,self);
		self.wuhunId = vo.wuhunId;
	end
	self:SetAttackAction(self.bIsAttack);
	self:AddEquipGroup(vo.suitflag or 0)
end
--创建默认
--需要角色id,职业等
function CPlayerAvatar:Create(dwRoleID,dwProfID)
	self.dwRoleID = dwRoleID; 
	self.dwProfID = dwProfID;
	local ProfConfig =  RoleConfig.ProfConfig[self.dwProfID];
	if not ProfConfig then
        Debug("CPlayerAvatar:Create ProfConfig Is Null"..dwProfID);
        return false;
    end;
	--设置骨骼 
	local szSklFile = ProfConfig.skl;
	if not szSklFile then
		Debug("CPlayerAvatar:Create szSklFile null");
		return false;
	end;

	self:StopAllAction();
	
	if self.transform then
		self:RemoveAllEquips();
		self.transform:CreateTransform(self);
		self:SetAttackAction(self.bIsAttack);
		self.transform:PlayBirthAction(self);
		return;
	end
	
	self:DeleteMesh('Body');
	
	self:ChangeSkl(szSklFile);
	--设置默认的默认动作 
	self:SetAttackAction(self.bIsAttack);
	return true;
end;
local animaDeltaTime = 30
function CPlayerAvatar:OnUpdate(e)
	self:UpdateSkipNumber();
    --[[
    if self.bMoveing == false then
        local animaMove = self:GetAnimation(self.szMoveAction)
        local tempDelta = animaMove.duration - animaMove.current
        if animaMove.isPlaying then
            Debug("##### CPlayerAvatar:OnUpdate", animaMove.current, animaMove.duration)
            if tempDelta < animaDeltaTime then
                Debug("#####bingo CPlayerAvatar:OnUpdate", animaMove.current, animaMove.duration)
                animaMove:stop()

            end
        end
    end
    --]]

    --实时动画计算
	--[[
    if self.horse and self.horse.objNode then
        self.objNode.transform:set(self.riderMeshNull.transform)
        local v = self.horse.objNode.transform:getTranslation()
        local r = self.horse.objNode.transform:getRotation()
        self.objNode.transform:mulRotationRight(r.x, r.y, r.z, r.r)
        self.objNode.transform:mulTranslationRight(v)

    else

    end
	--]]
	
	if (self.dwProfID == enProfType.eProfType_Sword 
		or self.dwProfID == enProfType.eProfType_Human
		or self.dwProfID == enProfType.eProfType_Sickle)
		and (GameController.currentState == nil 
			or StoryController:IsStorying()) then
		local weapon1 = self["WeaMesh"..'1']
		if weapon1 then
			local rwhBone = self:GetSkl():getBone('rwh')
			local mark = weapon1.graData:getMarker('rwh')
			if mark then
				weapon1.transform:set(mark)
				weapon1.transform:inverse()
				weapon1.transform.parent = rwhBone
			end																
		end
	elseif self.dwProfID == enProfType.eProfType_Woman 
		and (GameController.currentState == nil 
			or StoryController:IsStorying()) then
		for i = 1, 2 do
			local name = ""
			if i == 1 then
				name = "rwh"
			else
		        name = "lwh"
			end
			if self["WeaMesh"..i] then
				local rwhBone = self:GetSkl():getBone(name)
				local mark = self["WeaMesh"..i].graData:getMarker(name)
				if mark then
					self["WeaMesh"..i].transform:set(mark)
					self["WeaMesh"..i].transform:inverse()
					self["WeaMesh"..i].transform.parent = rwhBone
				end	
			end
		end
	end
	
	for i,pendant in pairs(self.pendants) do
		pendant:OnUpdate(e);
	end
	for k, equip in pairs(self.equips) do
		equip:OnUpdate()
	end
end

function CPlayerAvatar:GetRoleID()
	return self.dwRoleID;
end;

--设置职业
function CPlayerAvatar:SetProf(prof)
	if self.dwProfID == prof then
		return;
	end
	self.dwProfID = prof;
	self.dwDressId = nil;
	self.dwFaceId = nil;
	self.dwHairId = nil;
	local ProfConfig =  RoleConfig.ProfConfig[self.dwProfID];
	if not ProfConfig then return; end
	local szSklFile = ProfConfig.skl;
	if not szSklFile then return; end
	self:ChangeSkl(szSklFile);
	--设置默认的默认动作 
	self:SetAttackAction(self.bIsAttack);
end

--设置衣服
function CPlayerAvatar:SetDress(dressId, fashionsHead, fashionsDress)
	if self:NewSetDress(dressId) then
		return;
	end

	if self.new then
		self:TempCreate(dressId, fashionsHead, fashionsDress);
		return;
	end

	if self.dwDressId == dressId
		and self.fashionsHead == fashionsHead
		and self.fashionsDress == fashionsDress then
		return
	end

	local oldDressld = self.dwDressId
	local oldFashionsHead = self.fashionsHead
	local oldFashionsDress = self.fashionsDress
	
	local prof = self.dwProfID
	if not t_playerinfo[prof] then
		return
	end
	if not oldDressld or oldDressld == 0 then
		oldDressld = t_playerinfo[prof].dress
	end
	
	local oldModelFile = Assets:GetPartRes(oldDressld, prof)
	local oldPartTable = {}
	if oldModelFile and oldModelFile ~= "" then
		local oldDressTable = GetPoundTable(oldModelFile)
		oldPartTable = self:GetDressTable(oldDressTable)
	end
	if self.fashions then
		self.fashions:GetOldDressWithFashion(oldFashionsHead, oldFashionsDress, oldPartTable)
	end

	for k, v in pairs(oldPartTable) do
		self:DeleteMesh(k)
	end

	if self.dressPfx then
		for index, bonePfx in pairs(self.dressPfx) do
			local pfxName = bonePfx .. ".pfx"
		    self:StopPfxByName(pfxName)
		end
		self.dressPfx = nil
		self.dressBone = nil
	end

	if dressId == 0 then
		dressId = t_playerinfo[prof].dress
	end

	self.dwDressId = dressId
	if self:IsSelf() then
		local mapId = CPlayerMap:GetCurMapID()
		if mapId and mapId == 10100000 then
			local Showcfg = t_playerinfo[prof]
			dressId = Showcfg.create_dress
		end
	end

	local szModelFile = Assets:GetPartRes(dressId, prof)
	self.fashionsHead = fashionsHead 
	self.fashionsDress = fashionsDress
	if not szModelFile or szModelFile == "" then 
		Debug("CPlayerAvatar:SetDress error", debug.traceback(), dressId)
		return false
	end
	local pfxListString, boneListString = Assets:GetEquipPfx(dressId, prof)
	local dressTable = GetPoundTable(szModelFile)
	local partTable = self:GetDressTable(dressTable)
	if self.fashions and self.fashions:GetFashionsDress() then
		partTable = {}
		self.fashions:GetDressWithFashions(partTable)
		pfxListString, boneListString = self.fashions:GetFashionDressPfx(fashionsDress)
	end
	for k, v in pairs(partTable) do												
		self:SetPart(k, v)
	end
	if pfxListString and pfxListString ~= "" then
		local boneList = nil
		if boneListString and boneListString ~= "" then
			boneList = GetPoundTable(boneListString)
		end
		local pfxList = GetPoundTable(pfxListString)
		for index, bonePfx in pairs(pfxList) do
			local pfxName = bonePfx .. ".pfx"
			local boneName = bonePfx
			if boneList then
				boneName = boneList[index]
			end
		    self:PlayPfxOnBone(boneName, pfxName, pfxName)
		end
		self.dressPfx = pfxList
		self.dressBone = boneList
	else
		self.dressPfx = nil
		self.dressBone = nil
	end
end

function CPlayerAvatar:NewSetDress(dressId)
	self.dwDressId = self.dwDressId or 0;
	local oldId = Assets:GetPartResId(self.dwDressId or 0,self.dwProfID);
	oldId = self.equips[oldId] and oldId or 0;
	self.dwDressId = dressId or 0;
	if self.dwDressId == 0 then
		local prof = self.dwProfID;
		if t_playerinfo[prof] then
			self.dwDressId = t_playerinfo[prof].dress;
		end
	end
	local newId = Assets:GetPartResId(self.dwDressId,self.dwProfID);
	local changed = newId ~= oldId;
	if changed then
		self:RemoveEquip(oldId);
		self:AddEquip(newId,true);
		if self.dressPfx then
			for index, bonePfx in pairs(self.dressPfx) do
				local pfxName = bonePfx .. ".pfx"
				self:StopPfxByName(pfxName)
			end
			self.dressPfx = nil
			self.dressBone = nil
		end
		
		local pfxListString, boneListString = Assets:GetEquipPfx(self.dwDressId, self.dwProfID);
		if pfxListString and pfxListString ~= "" then
			local boneList = nil
			if boneListString and boneListString ~= "" then
				boneList = GetPoundTable(boneListString);
			end
			local pfxList = GetPoundTable(pfxListString);
			for index, bonePfx in pairs(pfxList) do
				local pfxName = bonePfx .. ".pfx";
				local boneName = bonePfx;
				if boneList then
					boneName = boneList[index];
				end
				self:PlayPfxOnBone(boneName, pfxName, pfxName);
			end
			self.dressPfx = pfxList;
			self.dressBone = boneList;
		else
			self.dressPfx = nil;
			self.dressBone = nil;
		end
	end
	return true;
end

function CPlayerAvatar:UpdateFashions()
	local fashions = self.fashions:GetFashions();
	--WriteLog(LogType.Normal,true,'CPlayerAvatar:UpdateFashions'..Utils.dump(fashions));
	for i,fashion in pairs(fashions) do
		if fashion.append then
			self:AddEquip(fashion.id,true);
		else
			self:RemoveEquip(fashion.id);
			self.fashions:RemoveFashion(fashion.id);
		end
	end
end

function CPlayerAvatar:AddEquip(equipId,unProf)
	if not equipId or equipId == 0 then
		return;
	end
	
	local equip = self.equips[equipId];
	local modelId = unProf and equipId or Assets:GetPartResId(equipId,self.dwProfID);
	if modelId == 0 then
		return;
	end
	
	local callback = self.useAct and function(equipId) self:EquipActionCompleted(equipId);end or nil;
	if not equip then
		equip = PlayerEquip:new(modelId);
		equip.queueActCompleted = callback;
		equip:Bind(self);
		self.equips[equipId] = equip;
	else
		equip.queueActCompleted = callback;
		equip:Refresh();
	end
	
	local ep = equip:GetPosition();
	for id,item in pairs(self.equips) do
		if item ~= equip then
			local ip = item:GetPosition();
			if _and(ep,ip) == ip then
				self:RemoveEquip(id);
			end
		end
	end
	
end

CPlayerAvatar.useAct = true;
function CPlayerAvatar:SetEquipActState(state)
	self.useAct = state;
	local callback = self.useAct and function(equipId) self:EquipActionCompleted(equipId);end or nil;
	for id,equip in pairs(self.equips) do
		equip.queueActCompleted = callback;
	end
end

function CPlayerAvatar:EquipActionCompleted(equipId)
	if not self.equips then
		TimerManager:UnRegisterTimer(self.equipTimer);
		self.equipTimer = nil;
		return
	end
	
	local completed = true;
	for id,equip in pairs(self.equips) do
		if equip.actionPlaying then
			if not equip.Loop then
				completed = false;
			end
			break;
		end
	end
	if not completed then
		return;
	end
	
	TimerManager:UnRegisterTimer(self.equipTimer);
	self.equipTimer = nil;
	
	if not self.bIsAttack then
		local callback = function ()
			if self.equipActionDir == PlayerEquip.ToBattleAction then
				self.equipActionDir = PlayerEquip.ToNormalAction;
			else
				self.equipActionDir = PlayerEquip.ToBattleAction;
			end
			for id,equip in pairs(self.equips) do
				local actnum = equip:GetMaxActionNum();
				if actnum ~= 0 then
					equip:PlayActionByDir(self.equipActionDir);
				end
			end
		end
		self.equipTimer = TimerManager:RegisterTimer(callback,RolePlayPartActInterval,1);
	end
end

function CPlayerAvatar:RemoveEquip(equipId)
	if not equipId then
		return;
	end
	local equip = self.equips[equipId];
	if not equip then
		return;
	end
	self.equips[equipId] = nil;
	equip:Destroy();
	return true;
end

function CPlayerAvatar:RemoveAllEquips()
	for k,equip in pairs(self.equips) do
		equip:Destroy();
		self.equips[k] = nil;
	end
	
	self.dwDressId = nil;
	self.dwArmsModalID = nil;
	self.dwShoulder = nil;
	self.dwHorseID = nil;
	self.dwWingId = nil;
	TimerManager:UnRegisterTimer(self.equipTimer);
	self.equipTimer = nil;
end

function CPlayerAvatar:ChangeAllEquipSan(battle)
	if battle then
		self.equipActionDir = PlayerEquip.ToBattleAction;
		TimerManager:UnRegisterTimer(self.equipTimer);
		self.equipTimer = nil;
	else
		self.equipActionDir = PlayerEquip.ToNormalAction;
	end
	
	local callback = self.useAct and function(equipId) self:EquipActionCompleted(equipId);end or nil;
	for k,equip in pairs(self.equips) do
		local actnum = equip:GetMaxActionNum();
		if actnum ~= 0 then
			if equip.battle ~= battle then
				equip.queueActCompleted = nil;
				equip:AllChangeBattleSan(battle);
				equip.queueActCompleted = callback;
			end
		end
	end
	
end

function CPlayerAvatar:RefreshAllEquip()
	for k,equip in pairs(self.equips) do
		equip:Refresh();
	end
end
function CPlayerAvatar:SetPendantModelId(id)
    
	if self.xianjieModelID == id then
		return
	end
	if self.xianjieModelID ~= 0 then
	--	self:RemovePendant(self.xianjieModelID)
	end

	self.xianjieModelID = id
  --  self:AddPendant(id);   
end
function CPlayerAvatar:SetXuanBingModelId(id)

	if self.xuanBingModelID == id then
		return
	end
	if self.xuanBingModelID ~= 0 then
		self:RemovePendant(self.xuanBingModelID)
	end

	self.xuanBingModelID = id
	self:AddPendant(id);
end
function CPlayerAvatar:AddPendant(pendantId)
	if not pendantId or pendantId == 0 then
		return;
	end
	local pendant = self.pendants[pendantId];
	if not pendant then
		pendant = PlayerPendant:new(pendantId);
		pendant:Bind(self);
		self.pendants[pendantId] = pendant;
	end
end

function CPlayerAvatar:RemovePendant(pendantId)
	if not pendantId then
		return;
	end
	local pendant = self.pendants[pendantId];
	if not pendant then
		return;
	end
	self.pendants[pendantId] = nil;
	pendant:Destroy();
end

function CPlayerAvatar:RefreshAllPendant()
	for k,pendant in pairs(self.pendants) do
		pendant:Refresh();
	end
end

function CPlayerAvatar:GetDressTable(dressTable)
	local resTable = {}
	
	if dressTable and #dressTable > 1 then
		for index, dressConfig in pairs(dressTable) do
			local dressFile = GetColonTable(dressConfig)
			resTable[dressFile[1]] = dressFile[2]
		end
	else
		local dressFile = GetColonTable(szModelFile)
		resTable[dressFile[1]] = dressFile[2]
	end
	
	return resTable
end

--设置武器模型
function CPlayerAvatar:SetArms(dwArmsModalID, fashionsArms)								--Weapon

	if self:NewSetArms(dwArmsModalID) then
		return;
	end
    --Debug("CPlayerAvatar:SetArms ", self.dwArmsModalID, dwArmsModalID, self.fashionsArms, fashionsArms, debug.traceback())
    if dwArmsModalID == 0 then
		dwArmsModalID = nil
	end
	if fashionsArms == 0 then
		fashionsArms = nil
	end
	if self.dwArmsModalID == dwArmsModalID 
		and self.fashionsArms == fashionsArms
		and not (self:IsSelf() and CPlayerMap.changeDress) then
		return
	end
	self.dwArmsModalID = dwArmsModalID
	self.fashionsArms = fashionsArms
	self:StartDefAction()
    self:ChangeArms()
end

function CPlayerAvatar:NewSetArms(dwArmsModalID)
	self.dwArmsModalID = self.dwArmsModalID or 0;
	local oldId = Assets:GetPartResId(self.dwArmsModalID or 0,self.dwProfID);
	oldId = self.equips[oldId] and oldId or 0;
	self.dwArmsModalID = dwArmsModalID or 0;
	if self.dwArmsModalID == 0 then
		local prof = self.dwProfID;
		if t_playerinfo[prof] then
			self.dwArmsModalID = t_playerinfo[prof].arm;
		end
	end
	local newId = Assets:GetPartResId(self.dwArmsModalID,self.dwProfID);
	local changed = newId ~= oldId;
	if changed then
		self:RemoveEquip(oldId);
		self:AddEquip(newId,true);
	end
	return true;
end

function CPlayerAvatar:SetShoulder(dwShoulder)
	self.dwShoulder = self.dwShoulder or 0;
	local oldId = Assets:GetPartResId(self.dwShoulder or 0,self.dwProfID);
	oldId = self.equips[oldId] and oldId or 0;
	self.dwShoulder = dwShoulder or 0;
	if self.dwShoulder == 0 then
		local prof = self.dwProfID;
		if t_playerinfo[prof] then
			self.dwShoulder = t_playerinfo[prof].shoulder;
		end
	end
	local newId = Assets:GetPartResId(self.dwShoulder,self.dwProfID);
	local changed = newId ~= oldId;
	if changed then
		self:RemoveEquip(oldId);
		self:AddEquip(newId,true);
	end
	return true;
end

--强制设置武器
function CPlayerAvatar:ForceSetArms(dwArmsModalID,fashionsArms)
    Debug("CPlayerAvatar:ForceSetArms ", dwArmsModalID)
    if dwArmsModalID == 0 and fashionsArms == 0 then
       return;
    end;
    self.dwArmsModalID = dwArmsModalID;
	self.fashionsArms = fashionsArms
    self:StartDefAction();
end

--设置武器状态:
--1=无
--2=背着
--3=拿着
_G.armState = {
	enArmsStateNull = 1,
	enArmsStateIdle = 2,
	enArmsStateUse = 3,
}
local hasRemovedText2D = false
local new = true;
function CPlayerAvatar:ChangeArms(forceType)

	if self.new then
		return;
	end
	
	--Debug(debug.traceback())
	for i = 1, 2 do
		if self["WeaMesh"..i] then
			self.objMesh:delSubMesh(self["WeaMesh"..i]) --从主模型中删除武器
			self.setAllPart["Arms"..i] = nil
			self["szName"..i] = nil
			self["szMaker"..i] = nil
		end
		self["WeaMesh"..i] = nil
	end

	if self.armPfx then
		for index, bonePfx in pairs(self.armPfx) do
			local pfxName = bonePfx .. ".pfx"
		    self:StopPfxByName(pfxName)
		end
		self.armPfx = nil
		self.armBone = nil
	end

	self:RemoveShenwuPfx(self.shenwuId)

	local fashionWeaponFile = nil
	local pfxListString = nil
	local boneListString = nil
	if self.fashions then
		fashionWeaponFile = self.fashions:GetFashionWeapon()
		pfxListString, boneListString = self.fashions:GetFashionArmPfx()
	end
	if ((not self.dwArmsModalID or self.dwArmsModalID == 0) and (not fashionWeaponFile))
		or forceType then
		return
	end
	local szArmsFile
	local armsModelId = self:GetArmsModelId()
	local isShowShenwuPfx = false
	if armsModelId and t_equip[armsModelId] then
		isShowShenwuPfx = true
	end
	if fashionWeaponFile then
		szArmsFile = fashionWeaponFile
		isShowShenwuPfx = false
		-- local szArmsFile1 = Assets:GetBinghunPartRes(armsModelId, self.dwProfID)
		-- if szArmsFile1 then
		-- 	szArmsFile = szArmsFile1
		-- 	pfxListString = Assets:GetBinghunEquipPfx(armsModelId, self.dwProfID)
		-- end
	else
		if self:IsSelf() and armsModelId and armsModelId ~= 0 then
			local mapId = CPlayerMap:GetCurMapID()
			if mapId and mapId == 10100000 then
				local Showcfg = t_playerinfo[self.dwProfID]
				armsModelId = Showcfg.create_arm
				CPlayerMap.changeDress = true
			end
		end
		szArmsFile = Assets:GetPartRes(armsModelId, self.dwProfID)
		pfxListString, boneListString = Assets:GetEquipPfx(armsModelId, self.dwProfID)
		local szArmsFile1 = Assets:GetBinghunPartRes(armsModelId, self.dwProfID)
		if szArmsFile1 then
			szArmsFile = szArmsFile1
			pfxListString, boneListString = Assets:GetBinghunEquipPfx(armsModelId, self.dwProfID)
			isShowShenwuPfx = false
		end
		local qizhanArms = Assets:GetQizhanPartRes(armsModelId, self.dwProfID)
		if qizhanArms then
			szArmsFile = qizhanArms
			pfxListString, boneListString = Assets:GetQizhanEquipPfx(armsModelId, self.dwProfID)
			isShowShenwuPfx = false
		end
	end

	if not szArmsFile then
		print("no arm weapon  WTF!!!")
		return
	end
	local armList = GetPoundTable(szArmsFile)
	if not armList then
		return
	end
	for i = 1, 2 do
		if armList[i] then
			local armInfo = GetVerticalTable(armList[i])
			local szName = nil
			local szMaker = nil
			if i == 1 then
				szName = "rwh"
				szMaker = "rwh"
			else
		        szName = "lwh"
				szMaker = "lwh" 
			end
		    if szName ~= self["szName"..i] and szMaker ~= self["szMaker"..i] then
				if not self["WeaMesh"..i] then
					self["WeaMesh"..i] = _Mesh.new(armInfo[1])
					if armInfo[2] then
						self["WeaMesh"..i]:setEnvironmentMap(_Image.new(armInfo[2]), true, 1) --溜光
						self["WeaMesh"..i].isPaint = true
						self["WeaMesh"..i].blender = _Blender.new()
						self["WeaMesh"..i].blender:environment(0, 0, FLOWLIGHT["arm"][1], FLOWLIGHT["arm"][4], FLOWLIGHT["arm"][5], FLOWLIGHT["arm"][2], false, FLOWLIGHT["arm"][3])
						self["WeaMesh"..i].blender.playMode = _Blender.PlayPingPong
					end
				end
				self["szName"..i] = szName
				self["szMaker"..i] = szMaker
				self["WeaMesh"..i].bArms = true
				
				--绑定在主角的某骨骼上
				self["WeaMesh"..i]:attachSkeleton(self:GetSkl(), szName, self["WeaMesh"..i].graData:getMarker(szMaker))
				
				for i, v in next, self["WeaMesh"..i]:getSubMeshs() do
					v.isPaint = true
				end
				self["WeaMesh"..i].isPaint = true 
				
				self["WeaMesh"..i]:enumMesh('', true, function(mesh, name)
					--Debug("WeaMesh: ", name)
					local i = mesh:getTexture(0)
					if i and i.resname ~= '' then
						--Debug('WeaMesh: ', i, i.resname)
						--高光处理
						local spemap = i.resname:gsub('.dds$','_h.dds')
						if spemap and spemap:find('dds') and spemap:find('_h') and _sys:fileExist(spemap, true) then
							--Debug('common set specularmap: ', spemap)
							mesh:setSpecularMap(_Image.new(spemap))
						end
																		
					end
				end)
					
				self.objMesh:addSubMesh(self["WeaMesh"..i])  	--添加到主模型上
				self.setAllPart["Arms"..i] = self["WeaMesh"..i]								
		    end
		end
	end

	if pfxListString and pfxListString ~= "" then
		local boneList = nil
		if boneListString and boneListString ~= "" then
			boneList = GetPoundTable(boneListString)
		end
		local pfxList = GetPoundTable(pfxListString)
		for index, bonePfx in pairs(pfxList) do
			local pfxName = bonePfx .. ".pfx"
			local boneName = bonePfx
			if boneList then
				boneName = boneList[index]
			end
		    self:PlayPfxOnBone(boneName, pfxName, pfxName)
		end
		self.armPfx = pfxList
		self.armBone = boneList
	else
		self.armPfx = nil
		self.armBone = nil
	end

	if isShowShenwuPfx == true  then
		self.isShowShenwuPfx = isShowShenwuPfx
		self:AddShenwuPfx(self.shenwuId)
	end

	if self.objSceneMap and self.objSceneMap.objScene then
		self:GetSkl().pfxPlayer.terrain = self.objSceneMap.objScene.terrain
	end

end

--是否应用法线贴图
function CPlayerAvatar:setBumpMap(flag)
	--Debug("##################")
	--[[for i, v in pairs (self.setAllPart) do									--For New
		--Debug(i, v)
		if v then
			v:enumMesh('', true, function(mesh, name)
				Debug("Mesh: ", name)
				local i = mesh:getTexture(0)
				if i and i.resname ~= '' then
										
					--法线处理
					local normalMap = i.resname:gsub('.dds$','_n.dds')
					if normalMap and normalMap:find('dds') and normalMap:find('_n') and _sys:fileExist(normalMap, true) then
						if (flag) then 
							Debug('Scene set setBumpMap: ', normalMap)
							mesh:setBumpMap(_Image.new(normalMap), true)
						else
							Debug('Scene unset setBumpMap: ', normalMap)
							mesh:setBumpMap(nil, true)
						end
					end
																					
				end
			end)	
		end
	end--]]
end



--设置坐骑
function CPlayerAvatar:SetMount(horseId)
	-- WriteLog(LogType.Normal,true,'CPlayerAvatar:SetMount-->>'..'horseId:'..tostring(horseId));
	
     if not self.objNode then
     	return
     end
	if horseId == nil then
		return
	end
	if self.dwHorseID == horseId  then
		return false;
	end; 
	self.dwHorseID = horseId;
	self:ChangeMoutState();
	return true;
end;

function CPlayerAvatar:ChangeMoutState()
    --下马过程
    if not self.dwHorseID or self.dwHorseID == 0 then
        --self.Control = CPlayerControl; --
        if self.horse then

			local trans = self.objNode.mesh.transform;
	        --self.horse.objMesh:delSubMesh(self.objMesh)
	        self.horse:Destroy()
	        self.horse = nil;
			--TODO adjust center point, left horse awc bone
			self.objNode.mesh = self.objMesh
			self.objMesh.transform = trans
			Debug("############## adjust center point, left horse awc bone")
        end
        self:ResetMoveMusic()
        self:ResetSitAreaPfx()
		self:SetAttackAction(self.bIsAttack);
        return;
    end;

    --上马过程
    local tbMountInfo = t_mountmodel[self.dwHorseID];
    if not tbMountInfo then
    	Debug("fuck CPlayerAvatar:ChangeMoutState() res error", dwHorseID)
    	return
    end
    if not tbMountInfo.skl_scene then
        assert(false, "fuck CPlayerAvatar:ChangeMoutState() res error");
    end;

    --初始化坐骑
    self.horse = CHorseAvatar:new()
	Debug("CHorseAvatar:new(): ", self.dwRoleID, self.dwHorseID, self.dwProfID)
    self.horse:Create(self.dwHorseID, self.dwProfID)
    --self.horse.objMesh.transform:mulScalingLeft(0.5, 0.5, 0.5)
    --同步下移动状态
    --self.horse.bMoveing = self.bMoveing
    self.horse.moveState = self.moveState
    local newMesh = _Mesh.new()
    --替换自己的mesh为坐骑的mesh
	self.objNode.mesh = newMesh
	--把自己挂在坐骑的awc点上
 	local boneMat = self.horse.objSkeleton:getBone("awc")
	boneMat.ignoreScaling = true;
	self.objMesh.transform = boneMat
	self.objMesh.name = "player"
	self.horse.objMesh.name = "horse"
	newMesh:addSubMesh(self.objMesh)
	newMesh:addSubMesh(self.horse.objMesh)
	--内部会自动替换成骑马状态的动作
	self:ResetMoveMusic()
	self:ResetSitAreaPfx()
    self:SetAttackAction(self.bIsAttack)
	
    if self.objSceneMap and self.objSceneMap.objScene then
		self.horse.objSkeleton.pfxPlayer.terrain = self.objSceneMap.objScene.terrain
	end
	
end;

--改变坐在椅子上的状态
function CPlayerAvatar:ChangeOnDeskState(chairID,chairDir)
	local collectionList = CollectionModel:GetCollectionList();  --得到玩家视野中所有的椅子
	local index = 0;
	if collectionList then
		for cid,collection in pairs(collectionList) do
			if collection then
				local posx,posy = collection:GetPos().x, collection:GetPos().y;
			end
		end
	end
end

---------------------------------------------------------------
--覆盖avatar方法
--------------------------------------------------------------- 
function CPlayerAvatar:DoStopMove(pos, dir)
	self:StopMove(pos, dir)
	--self:ChangeArms()
end

function CPlayerAvatar:DoMoveTo(pos, callback, bUseCanTo, speed, dwDis)
	self:MoveTo(pos, callback, speed, bUseCanTo, nil, dwDis)
	--self:ChangeArms()
end

function CPlayerAvatar:OnEnterScene(objNode)
    objNode.dwType = enEntType.eEntType_Player
end

local pos = _Vector2.new()
function CPlayerAvatar:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	pos.x = fXPos; pos.y = fYPos
	self:EnterSceneMap(objSceneMap, pos, fDirValue)
	self:SetAttackAction(self.bIsAttack);
	if self.objNode then
		self.objNode.dwType = enEntType.eEntType_Player
	end
	
	self:RefreshAllPendant();
	
end

function CPlayerAvatar:ExitMap()
	for i,equip in pairs(self.equips) do
		equip:Destroy();
	end
	for i,pendant in pairs(self.pendants) do
		pendant:Destroy();
	end
	self.equips = nil;
	self.pendants = nil;
	TimerManager:UnRegisterTimer(self.equipTimer);
	self.equipTimer = nil
	

	self.objHlBlender = nil;
	self.fashions = nil
	self:ExitSceneMap();
	self:Destroy()
    if self.horse then
    	self.horse:Destroy()
		self.horse.objMesh = nil;
        self.horse.objNode = nil;
    end
	DestroyTbl(self.setSkipNormal)
end

--切换战斗状态
function CPlayerAvatar:SetAttackAction(bIsAttack)
    self.bIsAttack = bIsAttack
	if self:IsSelf() and MainPlayerController.standInState then
		return
	end
	
	if self.transform then
		self.transform:SetAttackAction(self,bIsAttack);
		return;
	end
	
    if self.bIsAttack then
		self.dwIdleAnimaID = RoleConfig.attack_idle_san
		self.dwMoveAnimaID = RoleConfig.attack_move_san
	else
		self.dwIdleAnimaID = RoleConfig.idle_san
		self.dwMoveAnimaID = RoleConfig.move_san
	end
	self:StartDefAction()
	self:ChangeAllEquipSan(bIsAttack);
end

--播放动作
function CPlayerAvatar:StartDefAction()
	local idleAnimaName = self:GetAnimaFile(self.dwIdleAnimaID)
	if not idleAnimaName then
		Debug("CPlayerAvatar:StartDefAction dwIdleAnimaID is null ... ")
		return
	end

    local moveAnimaName = self:GetAnimaFile(self.dwMoveAnimaID)
	if not moveAnimaName then
		Debug("CPlayerAvatar:StartDefAction dwMoveAnimaID is null ... ")
        return
	end

	local deadState = self.isDead
	if deadState then
		return
	end

    if self:IsInSpecialState() or StoryController:IsStorying() then
		self:SetIdleAction(idleAnimaName, false)
		self:SetMoveAction(moveAnimaName)
	else
		self:SetIdleAction(idleAnimaName, true)
        self:SetMoveAction(moveAnimaName)
    end
end

function CPlayerAvatar:GetWuhunPfx(pfxString)
	if pfxString and pfxString ~= "" then
		return pfxString .. ".pfx"
	end
end

--获取动作ID
function CPlayerAvatar:GetAnimaFile(sanId)
    local result = 0
	if sanId == RoleConfig.dead_san
		or sanId == RoleConfig.collect_san1
		or sanId == RoleConfig.collect_san2
		or sanId == RoleConfig.sit_san
		or sanId == RoleConfig.lianhualu_san
		or sanId == RoleConfig.rankList_san
		or sanId == RoleConfig.team_san
		or sanId == RoleConfig.xiuxian_san
		or sanId == RoleConfig.superZuo_san
		or sanId == RoleConfig.superZhan_san
		or sanId == RoleConfig.heti_san
		or sanId == RoleConfig.shenzhuang_san
		or sanId == RoleConfig.shenzhuangidle_san
		or sanId == RoleConfig.wuhun_san_1
		or sanId == RoleConfig.wuhun_san_2
		or sanId == RoleConfig.wuhun_san_3
		or sanId == RoleConfig.wuhun_san_4 
		or sanId == RoleConfig.landEat_san            --坐在地上吃饭
		or sanId == RoleConfig.zhuobianEat_san then   --坐在桌边吃饭
		result = self.dwProfID .. "0000" .. sanId
	else
	    result = self.dwProfID .. '1'
		if self.dwArmsModalID or self.fashionsArms then
			result = result .. '2' --有武器
		else
			result = result .. '1'
		end;

		if self.bIsAttack then  --战斗状态
			result = result .. '2'
		else
			result = result .. '1'
		end
		result = result .. sanId
	    result = result .. '00'   --默认无坐骑阶数
	end
	
	result = tonumber(result)
	if t_rolemodel[result] then
		return t_rolemodel[result].san, t_rolemodel[result]
	end
	return nil
end

function CPlayerAvatar:GetHorse()
	return self.horse
end

--------------------技能相关--------------------------
function CPlayerAvatar:SetPrepState(prepState)
    self.prepState = prepState
end

function CPlayerAvatar:GetPrepState()
    return self.prepState
end

function CPlayerAvatar:IsSelf()
	return (self.objNode and self.objNode.bIsMe) and true or false
end

function CPlayerAvatar:PlaySkill(skillId, targetCid, targetPos)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_type = skillConfig.oper_type
    if not SkillAction[skill_type] then
    	return
   	end
   	if self:IsSelf() and MainPlayerController.standInState then
		return
	end
    self[SkillAction[skill_type]](self, skillId, targetCid, targetPos)
end

--播放音效
function CPlayerAvatar:PlaySkillSound(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    if not self:IsSelf() then
    	return
    end
 	if skillConfig.sound_id and t_music[skillConfig.sound_id] then
   		SoundManager:PlaySkillSfx(skillConfig.sound_id)
   	end
 end 

function CPlayerAvatar:StopSkillSound(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
	    return
	end
	if not self:IsSelf() then
		return
	end
	if skillConfig.sound_id and t_music[skillConfig.sound_id] then
		SoundManager:StopSkillSfx()
	end
end

function CPlayerAvatar:PlaySkillEndSound(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    if not self:IsSelf() then
    	return
    end
 	if skillConfig.end_sound_id and t_music[skillConfig.end_sound_id] then
 		self:StopSkillSound(skillId)
   		SoundManager:PlaySkillSfx(skillConfig.end_sound_id)
   	end
end

function CPlayerAvatar:PlayPrepSound(skillId)
	if self:IsSelf() then
		self:PlaySkillEndSound(skillId)
	end
end

function CPlayerAvatar:PlaySkillAnima(animaFile, loop, stopCallback)
	local zhujueFile = nil

	if self.horse then
		local string1 = "v_zhujue_" .. profString[self.dwProfID]
		local string2 = "v_ride_" .. self.horse.selfName
	    local string3 = "v_zhujue_" .. profString[self.dwProfID] .. "_zq"

	    --坐骑状态下 主角的技能动作
	    zhujueFile = GetHorseAnimaTable(animaFile, string1, string3)
    	
	    --坐骑状态下 坐骑的技能动作
	    --冲锋瞬移等位等位移技能用一个
	    --其他技能共用两个(随机)
	    local horseAnimaFile = nil
	    if string.find(animaFile, "chongfeng") or string.find(animaFile, "shunyi") then
	    	horseAnimaFile = string2 .. "_chongfeng.san"
	    else
	    	local index = math.random(1, 2)
	    	horseAnimaFile = string2 .. "_pugong_00" .. index .. ".san"
	   	end 
		self.horse:ExecAction(horseAnimaFile, false)
		
	else
		zhujueFile = animaFile
	end

	self:PlaySkillAction(zhujueFile, loop, stopCallback)

	if self.spiritsAvatar then
		local nameString = self.spiritsAvatar.name
		local fileName = GetWuHunAnimaTable(animaFile, nameString)
		if fileName and fileName ~= "" then
			self.spiritsAvatar:PlaySkillAction(fileName, loop)
		    self:PlaySkillAction(animaFile, loop, function()
				if self.spiritsAvatar then
					self.spiritsAvatar:StopAction(fileName)
				end
		    	if stopCallback then
		    		stopCallback()
		    	end
		    end)
		end
	end
	return zhujueFile
end

--普通技能
function CPlayerAvatar:PlayDefault(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaFile
	local animation = GetPoundTable(skill_action.animation)
	if #animation > 1 then
	    if self.animation_index < #animation then
	        self.animation_index = self.animation_index + 1
	    else
	        self.animation_index = 1
	    end
	    animaFile = animation[self.animation_index]
	else
		animaFile = skill_action.animation
	end
    self:PlaySkillAnima(animaFile, false)
end

--蓄力技能
function CPlayerAvatar:PlayPrep(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
    local animationAndPfx = GetCommaTable(animation[2])
    local animaFile1, animaFile2, animaFile3, pfx = animation[1], animationAndPfx[1], animation[3], animationAndPfx[2]
    if animaFile1 and animaFile2 then
        self:SetPrepState(1)
        self:PlaySkillAnima(animaFile1, false, function()
            if self:GetPrepState() == 1 then
                self:SetPrepState(2)
                if pfx then
                	self:PlaySkillPfx(skillId, pfx)
                end
                self:PlaySkillAnima(animaFile2, true, function() 
                	self:StopPfxByName(pfx)
                	self:SetPrepState(0)
                	if animaFile3 then
                		self:PlayPrepSound(skillId)
	                	self:PlaySkillAnima(animaFile3, false, function() end)
	                end
			    end)
			else
				self:SetPrepState(0)
			    if animaFile3 then
			    	self:PlayPrepSound(skillId)
                	self:PlaySkillAnima(animaFile3, false, function() end)
                end
            end
        end)
    end
end

--引导技能
function CPlayerAvatar:PlayChan(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]
	    if anima1 and anima2 and anima3 and self.chanState == ChanSkillState.StateInit then
	    	self:PlaySkillAnima(anima1, false, function()
	    		self.chanState = ChanSkillState.StateOne
		        self:PlaySkillAnima(anima2, true, function()
		        	self:PlaySkillAnima(anima3, false, function() end)
					if self.moveState == true then
		               self:ExecMoveAction()
		            end
		    		self.chanState = ChanSkillState.StateInit
			    end)
	    	end)
	    end
	else
		local anima1 = skill_action.animation
	    if anima1 and self.chanState == ChanSkillState.StateInit then
    		self.chanState = ChanSkillState.StateOne
	        self:PlaySkillAnima(anima1, true, function()
				if self.moveState == true then
	               self:ExecMoveAction()
	            end
	    		self.chanState = ChanSkillState.StateInit
		    end)
	    end
	end
end

--多段技能
function CPlayerAvatar:PlayMulti(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local time = skillConfig.multi_time
    local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]   
	    if anima1 and anima2 and anima3 then
	    	local animaName = anima2
	    	self:PlaySkillAnima(anima1, false, function()
		        animaName = self:PlaySkillAnima(anima2, true, function()
		        	self:PlaySkillAnima(anima3, false, function()
					end)
			    end)
	    	end)
	    	self.multiTime = TimerManager:RegisterTimer(function()
	        	self:StopActionNotStopPfx(animaName)
	        end, time, 1)
	    end
	else
		local anima1 = skill_action.animation
        local animaName = self:PlaySkillAnima(anima1, true, function() end)
    	self.multiTime = TimerManager:RegisterTimer(function()
        	self:StopAction(animaName)
        end, time, 1)
	end
end

--连续技能
function CPlayerAvatar:PlayCombo(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaFile = skill_action.animation
    if animaFile then
        self:PlaySkillAnima(animaFile, false)
    end
end

--采集技能
function CPlayerAvatar:PlayCollect(skillId, targetCid, targetPos)
    local animaFile = self:GetCollectAnima()
    if animaFile then
        self:PlaySkillAnima(animaFile, true)
    end
end

--翻滚技能
function CPlayerAvatar:PlayRoll(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
	local time = SkillController:GetRollTime(skillId)
    local animation = GetPoundTable(skill_action.animation)
    local rollAcitonFile, rollPfx, endPfx = animation[1], animation[2], animation[3]
    local selfPos = self:GetPos()
    self.rollState = true
    self.objNode.transform:mulTranslationRight(targetPos.x - selfPos.x, targetPos.y - selfPos.y, targetPos.z - selfPos.z, time)
    local animaName = self:PlaySkillAnima(rollAcitonFile, true)
    if rollPfx then
    	self:PlaySkillPfx(skillId, rollPfx)
    end
    self.rollTime = TimerManager:RegisterTimer(function()
        self.rollState = false
        self:StopAction(animaName)
        if rollPfx then
        	--self:StopPfxByName(rollPfx)
        end
        if endPfx then
        	self:PlaySkillPfx(skillId, endPfx)
        end
        --self:ExecIdleAction()
    end, time, 1)
end

--冲锋技能
function CPlayerAvatar:PlayJump(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
	local time = SkillController:GetRollTime(skillId)
    local animation = GetPoundTable(skill_action.animation)
	local jumpAcitonFile1 = animation[1]
	local selfPos = self:GetPos()
    self.jumpState = true
    self.objNode.transform:mulTranslationRight(targetPos.x - selfPos.x, targetPos.y - selfPos.y, targetPos.z - selfPos.z, time)
    self:PlaySkillAnima(jumpAcitonFile1, false)
    self.jumpTime = TimerManager:RegisterTimer(function()
        self.jumpState = false
    end, time, 1)
end

local mat = _Matrix3D.new()
local mat1 = _Matrix3D.new()
--武魂技能
function CPlayerAvatar:PlayWuhun(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local pfxType = skillConfig.pfx_type
    local animaTable = GetCommaTable(skillConfig.skill_action)
    if animaTable[2] and RoleConfig["wuhun_san_" .. animaTable[2]] then
		local animaFile = self:GetAnimaFile(RoleConfig["wuhun_san_" .. animaTable[2]])
		local pfxList = GetPoundTable(animaTable[1])
		local pfxFile = self:GetWuhunPfx(pfxList[1])
		local pfxFile1 = self:GetWuhunPfx(pfxList[2])
		if animaFile and animaFile ~= "" then
			self:PlaySkillAnima(animaFile, false)
		end
		if pfxFile then
			if self:IsHidePfx(skillId) then
				return
			end
	    	if pfxType == 2 then
	    		local pos = self:GetPos()
			    --local mat = _Matrix3D.new()
			    mat:setTranslation(pos.x, pos.y, pos.z)
			    self:PlayTrapPfx(skillId, pfxFile, mat)
			elseif pfxType == 3 then
				local targetChar = CharController:GetCharByCid(targetCid)
			    if not targetChar then
			    	return
			    end
			    local targetCharAvatar = targetChar:GetAvatar()
			    if not targetCharAvatar then
			    	return
			    end
			   	targetCharAvatar:PlayerPfxOnSkeleton(pfxFile)
			elseif pfxType == 4 then
				local pos = self:GetPos()
			    local faceto = self:GetDirValue()
			    local table = GetPoundTable(skillConfig.pfx_point)
			    local x, y = GetPosByDis(pos, faceto, table[1])
			    --local mat = _Matrix3D.new()
			    mat:setTranslation(pos.x, pos.y, pos.z)
			    --local mat1 = _Matrix3D.new()
			    mat1:setTranslation(x, y, pos.z)
			    local pfx = self:PlayTrapPfx(skillId, pfxFile, mat)
			    if not pfx then
			    	return
			    end
			    pfx.transform:mulTranslationRight(x - pos.x, y - pos.y, pos.z - pos.z, tonumber(table[2]))
			    self.trapTime = TimerManager:RegisterTimer(function()
			        self.objPP:stop(pfxFile, true)
			        if pfxFile1 and pfxFile1 ~= "" then
			        	self:PlayTrapPfx(skillId, pfxFile1, mat1)
			        end
			    end, tonumber(table[2]), 1)
			else
				self:PlaySkillPfx(skillId, pfxFile)
	    	end
	    end
	end
end

--陷阱技能
function CPlayerAvatar:PlayMoveTrap(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)

	self:PlaySkillAnima(animaTable[1], false)

	if animaTable[2] then
    	local table =  GetColonTable(animaTable[2])
    	if #table ~= 3 then
	        return
	    end
	    local pos = self:GetPos()
	    local szName = table[1]
	    local faceto = self:GetDirValue()
	    local x, y = GetPosByDis(pos, faceto, table[2])
	    --local mat = _Matrix3D.new()
	    mat:setTranslation(pos.x, pos.y, pos.z)
	    mat1:setTranslation(x, y, pos.z)
	    local pfx = self:PlayTrapPfx(skillId, szName, mat)
	    if not pfx then
	    	return
	    end
	    pfx.transform:mulTranslationRight(x - pos.x, y - pos.y, pos.z - pos.z, tonumber(table[3]))
	    self.trapTime = TimerManager:RegisterTimer(function()
	        self.objPP:stop(szName, true)
	        if animaTable[3] and animaTable[3] ~= "" then
	        	self:PlayTrapPfx(skillId, animaTable[3], mat1)
	        end
	    end, tonumber(table[3]), 1)
    end	
end

--陷阱技能
function CPlayerAvatar:PlayStaticTrap(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false)
	if animaTable[2] then
	    local pos = self:GetPos()
	    local szName = animaTable[2]
	    local mat = _Matrix3D.new()
	    mat:setTranslation(pos.x, pos.y, pos.z)
	    local pfx = self:PlayTrapPfx(skillId, szName, mat)
    end	
end

function CPlayerAvatar:PlayTragetPfx(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false)
	if animaTable[2] then
	    local targetChar, targetCharType = CharController:GetCharByCid(targetCid)
	    if not targetChar then
	    	return
	    end
	    local targetCharAvatar = targetChar:GetAvatar()
	    if not targetCharAvatar then
	    	return
	    end
	    if self:IsHidePfx(skillId) then
	    	return
	    end
	    local scaleMat = nil
	    if targetCharType == enEntType.eEntType_Monster then
	    	local scale = targetChar:GetScale()
	    	scale = 1/scale
	    	scaleMat = _Matrix3D.new()
	    	scaleMat:setScaling(scale, scale, scale)
	    end
	   	targetCharAvatar:PlayerPfxOnSkeleton(animaTable[2], scaleMat)
    end	
end

--神兵技能
function CPlayerAvatar:PlayShenbing(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	local dwRoleID = self.dwRoleID
	local player = CPlayerMap:GetPlayer(dwRoleID)
	if player and player.magicWeaponFigure then
		local magicWeaponID = player:GetMagicWeapon()
		local weaponCfg = t_shenbing[magicWeaponID]
		if not weaponCfg then
			return
		end
		local config = weaponCfg.skill_action
		local skill_action = t_skill_action[tonumber(config)]
		if not skill_action then
			return
		end
		local configTable = GetPoundTable(skill_action.animation)
		local action, pfx = configTable[1], configTable[2]
		if pfx and pfx ~= "" and targetPos then
			local z = CPlayerMap:GetSceneMap():getSceneHeight(targetPos.x, targetPos.y)
			local mat = _Matrix3D.new()
			mat:setTranslation(targetPos.x, targetPos.y, z)
			self:PlayTrapPfx(skillId, pfx, mat)
			player.magicWeaponFigure:Hide(4500)
		end
		if action and action ~= "" then
			player.magicWeaponFigure:ExecAction(action, false)
		end
	end
end
--灵器技能
function CPlayerAvatar:PlayLingqi(skillId, targetCid, targetPos)
--[[	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	local dwRoleID = self.dwRoleID
	local player = CPlayerMap:GetPlayer(dwRoleID)
	if player and player.lingQiFigure then
		local lingQiID = player:GetLingQi()
		local weaponCfg = t_lingqi[lingQiID]
		if not weaponCfg then
			return
		end
		local config = weaponCfg.skill_action
		local skill_action = t_skill_action[tonumber(config)]
		if not skill_action then
			return
		end
		local configTable = GetPoundTable(skill_action.animation)
		local action, pfx = configTable[1], configTable[2]
		if pfx and pfx ~= "" and targetPos then
			local z = CPlayerMap:GetSceneMap():getSceneHeight(targetPos.x, targetPos.y)
			local mat = _Matrix3D.new()
			mat:setTranslation(targetPos.x, targetPos.y, z)
			self:PlayTrapPfx(skillId, pfx, mat)
			player.lingQiFigure:Hide(4500)
		end
		if action and action ~= "" then
			player.lingQiFigure:ExecAction(action, false)
		end
	end]]
end
--玉佩技能
function CPlayerAvatar:PlayMingyu(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	local dwRoleID = self.dwRoleID
	local player = CPlayerMap:GetPlayer(dwRoleID)
	if player and player.mingYuFigure then
		local mingYuID = player:GetMingYu()
		local weaponCfg = t_mingyu[mingYuID]
		if not weaponCfg then
			return
		end
		local config = weaponCfg.skill_action
		local skill_action = t_skill_action[tonumber(config)]
		if not skill_action then
			return
		end
		local configTable = GetPoundTable(skill_action.animation)
		local action, pfx = configTable[1], configTable[2]
		if pfx and pfx ~= "" and targetPos then
			local z = CPlayerMap:GetSceneMap():getSceneHeight(targetPos.x, targetPos.y)
			local mat = _Matrix3D.new()
			mat:setTranslation(targetPos.x, targetPos.y, z)
			self:PlayTrapPfx(skillId, pfx, mat)
			player.mingYuFigure:Hide(4500)
		end
		if action and action ~= "" then
			player.mingYuFigure:ExecAction(action, false)
		end
	end
end
----------------------UI上播放技能--------------------------------------
function CPlayerAvatar:PlaySkillOnUI(skillId, callback)
	self.objSkeleton:stopAnimas()
	self.objSkeleton.pfxPlayer:stopAll(true)
	self.objSkeleton.pfxPlayer:clearParams()
	self:ExecIdleAction()
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_type = skillConfig.oper_type
    if not SkillAction[skill_type] then
    	return
   	end
   	if not self[SkillAction[skill_type] .. "OnUI"] then
   		return
   	end
    self[SkillAction[skill_type] .. "OnUI"](self, skillId, callback)
end

--普通技能
function CPlayerAvatar:PlayDefaultOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local selfPos = self:GetPos()
    local targetPos = {x = selfPos.x -0.5, y = selfPos.y - 1, z = 0}
    local isSpeicialSkill = false;
    local groupId = skill_action.id;
    if groupId == 102 or groupId == 302 or groupId == 402 then
		-- self.objNode.transform:mulTranslationRight(targetPos.x,targetPos.y,targetPos.z,900)
		isSpeicialSkill = true
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --玩家职业
		local x = 0;local y = 0;local z = 0;local time = 0;
		if prof == 1 then
			x,y,z = 1,2.1,1.05;
			time = 300
		elseif prof == 2 then  --妖姬
			--妖姬释放技能是旋转冲刺位移变化不明显被特效包住了，暂时不处理 
			-- self.objNode.transform:mulTranslationRight(targetPos.x,targetPos.y,targetPos.z,900)
		elseif prof == 3 then
			x,y,z = 1,2,1.05;
			time = 300
		elseif prof == 4 then
			x,y,z = 1,2,1.05;
			time = 300
		end
		local vec = _Vector3.new(x, y, z)
		self.objNode.transform:mulScalingRight(vec,time)
    end
	local animaFile = skill_action.animation
    self:PlaySkillAnima(animaFile, false, function()
    	if callback then
    		callback()
    		 if isSpeicialSkill then
    		end
    	end
    end)
end

--绝学技能
--@adder:houxudong
--@date:2016/7/26 14:09:00
function CPlayerAvatar:PlayMagicSkillOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
	local animaFile = skill_action.animation
    self:PlaySkillAnima(animaFile, false, function()
    	if callback then
    		callback()
    	end
    end)
end

--普攻技能多段播放
--@adder:houxudong 
--@date:2016/7/26 12:26:00
function CPlayerAvatar:PlayNormalAttackOnUI(skillId, callback)
	self.objSkeleton:stopAnimas()
	self.objSkeleton.pfxPlayer:stopAll(true)
	self.objSkeleton.pfxPlayer:clearParams()
	self:ExecIdleAction()
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]   --取得三段技能动作
	    if anima1 and anima2 and anima3 then
	    	self:PlaySkillAnima(anima1, false, function()
		        self:PlaySkillAnima(anima2, false, function()
		        	self:PlaySkillAnima(anima3, false, function()
		        		if callback then
		        			callback()
		        		end
					end)
			    end)
	    	end)
	    end
	else
		self:PlayDefaultOnUI(skillId, callback)
	end
end

--绝学技能UI上播放技能特殊处理
--@adder:houxudong
--@date:2016/7/26 16:03:25
function CPlayerAvatar:PlayTragetPfxForMagicSkillOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = split(skill_action.animation,"#")

	self:PlaySkillAnima(animaTable[1], false, function()
		if callback then
			self:StopAllPfx()
			callback()
		end
	end)
	-- 处理特效
	local animaTablepfx = skill_action.show_pfx
	-- trace(animaTablepfx)
	if animaTablepfx then
	    local pos = self:GetPos()
		local faceto = self:GetDirValue()
		local x, y = GetPosByDis(pos, faceto, 20)
	    local szName = animaTablepfx
	    local mat = _Matrix3D:new()
	    mat:setTranslation(x - pos.x, y - pos.y, 0)
	    local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    if mat then
	    	pfx.transform = mat
	    end
    end	
end

--蓄力技能
function CPlayerAvatar:PlayPrepOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
    local animationAndPfx = GetCommaTable(animation[2])
    local animaFile1, animaFile2, animaFile3, pfx = animation[1], animationAndPfx[1], animation[3], animationAndPfx[2]
    if animaFile1 and animaFile2 then
        self:PlaySkillAnima(animaFile1, false, function(self)
            if pfx then
            	self:PlayerPfxOnSkeleton(pfx)
            end
            self:PlaySkillAnima(animaFile2, true, function() 
            	if animaFile3 then
                	self:PlaySkillAnima(animaFile3, false, function()
                		if callback then
                			callback()
                		end
                	end)
                else
                	if callback then
                		callback()
                	end
                end
		    end)
		    if self.prepOnUITime then
	    		self:StopAction(animaFile2)
            	self:StopPfxByName(pfx)
	    		TimerManager:UnRegisterTimer(self.prepOnUITime)
	    	end
            self.prepOnUITime = TimerManager:RegisterTimer(function()
            	self:StopAction(animaFile2)
            	self:StopPfxByName(pfx)
            end, 1000, 1)
        end)
    end
end

--引导技能
function CPlayerAvatar:PlayChanOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
	local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]
	    if anima1 and anima2 and anima3 then
	    	self:PlaySkillAnima(anima1, false, function()
	    		self:PlaySkillAnima(anima2, true, function()
	    		end)
	    	end)
	    	if self.chanOnUITime then
	    		self:StopAction(anima2)
	    		TimerManager:UnRegisterTimer(self.chanOnUITime)
	    	end
	    	self.chanOnUITime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima2)
	        	if callback then
	        		callback()
	        	end
	        end, 2000, 1)
	    end
	else
		local anima1 = skill_action.animation
		self:PlaySkillAnima(anima1, true, function() end)
	    if anima1 then
	        self:PlaySkillAnima(anima1, true, function()
	        end)
	        if self.chanOnUITime then
	    		TimerManager:UnRegisterTimer(self.chanOnUITime)
	    	end
		    self.chanOnUITime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima1)
	        	if callback then
	        		callback()
	        	end
	        end, 2000, 1)
	    end
	end
end

--多段技能
function CPlayerAvatar:PlayMultiOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local time = skillConfig.multi_time
    local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]
	    if anima1 and anima2 and anima3 then
	    	self:PlaySkillAnima(anima1, false, function()
		        self:PlaySkillAnima(anima2, true, function()
		        	self:PlaySkillAnima(anima3, false, function()
		        		if callback then
		        			callback()
		        		end
					end)
			    end)
	    	end)
	    	self.multiOnUITime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima2)
	        end, time, 1)
	    end
	else
		local anima1 = skill_action.animation
        self:PlaySkillAnima(anima1, true, function()
        	if callback then
        		callback()
        	end
	    end)
    	self.multiOnUITime = TimerManager:RegisterTimer(function()
        	self:StopAction(anima1)
        end, time, 1)
	end
end

--连续技能
function CPlayerAvatar:PlayComboOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaFile = skill_action.animation
    if animaFile then
    	local anima = self.objSkeleton:addAnima(animaFile)
    	for i = 1, 4 do
        	anima:combine(self.objSkeleton:addAnima(animaFile))
        end
        anima:onStop(function()
	        if callback then
	            callback()
	        end
	    end)
        anima:onEvent(function(e)
	        if not self.objMesh.bIsMe then
	            if string.sub(e, 1, 3) == "sfx" then
	                return true
	            end
	        end
	        return false
	    end)
        anima:play()
    end
end

--冲锋技能
function CPlayerAvatar:PlayJumpOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
	local jumpAcitonFile1 = animation[1]
    self:PlaySkillAnima(jumpAcitonFile1, false, function()
    	if callback then
    		callback()
    	end
    end)
end

function CPlayerAvatar:PlayMoveTrapOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false)
	if animaTable[2] then
    	local table =  GetColonTable(animaTable[2])
    	if #table ~= 3 then
	        return
	    end
	    local pos = self:GetPos()
	    local szName = table[1]
	    local faceto = self:GetDirValue()
	    local x, y = GetPosByDis(pos, faceto, table[2])
	    --local mat = _Matrix3D.new()
	    mat:setTranslation(pos.x, pos.y, pos.z)
	    local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    pfx.transform:mulTranslationRight(x - pos.x, y - pos.y, pos.z - pos.z, tonumber(table[3]))
	    TimerManager:RegisterTimer(function()
	        self.objSkeleton.pfxPlayer:stop(szName, true)
	        if callback then
	        	callback()
	        end
	    end, tonumber(table[3]), 1)
    end	
end

function CPlayerAvatar:PlayStaticTrapOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false, function()
		if callback then
			callback()
		end
	end)
	if animaTable[2] then
	    local pos = self:GetPos()
	    local szName = animaTable[2]
	    --local mat = _Matrix3D.new()
	    mat:setTranslation(pos.x, pos.y, pos.z)
	    local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    if mat then
	    	pfx.transform = mat
	    end
    end	
end

function CPlayerAvatar:PlayTragetPfxOnUI(skillId, callback)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)

	self:PlaySkillAnima(animaTable[1], false, function()
		if callback then
			callback()

		end
	end)
	-- trace(animaTable)
	if animaTable[2] then
	    local pos = self:GetPos()
		local faceto = self:GetDirValue()
		local x, y = GetPosByDis(pos, faceto, 30)
	    local szName = animaTable[2]
	    local mat = _Matrix3D:new()
	    mat:setTranslation(x - pos.x, y - pos.y, 0)
	    local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    if mat then
	    	pfx.transform = mat
	    end
    end	
end

------------------------竞技场内播放技能--------------------------------
function CPlayerAvatar:PlaySkillOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_type = skillConfig.oper_type
    if not SkillAction[skill_type] then
    	return
   	end
    self[SkillAction[skill_type] .. "OnArena"](self, skillId)
end

--普通技能
function CPlayerAvatar:PlayDefaultOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaFile
	local animation = GetPoundTable(skill_action.animation)
	if #animation > 1 then
	    if self.animation_index < #animation then
	        self.animation_index = self.animation_index + 1
	    else
	        self.animation_index = 1
	    end
	    animaFile = animation[self.animation_index]
	else
		animaFile = skill_action.animation
	end
    self:PlaySkillAnima(animaFile, false)
end

--蓄力技能
function CPlayerAvatar:PlayPrepOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local time = math.min(skillConfig.prep_time, 1000)
    local animation = GetPoundTable(skill_action.animation)
    local animationAndPfx = GetCommaTable(animation[2])
    local animaFile1, animaFile2, animaFile3, pfx = animation[1], animationAndPfx[1], animation[3], animationAndPfx[2]
    if animaFile1 and animaFile2 then
        self:PlaySkillAnima(animaFile1, false, function(self)
            if pfx then
            	self:PlayerPfxOnSkeleton(pfx)
            end
            self:PlaySkillAnima(animaFile2, true, function() 
            	if animaFile3 then
                	self:PlaySkillAnima(animaFile3, false, function() end)
                end
		    end)
            self.prepOnArenaTime = TimerManager:RegisterTimer(function()
            	self:StopAction(animaFile2)
            	self:StopPfxByName(pfx)
            end, time, 1)
        end)
    end
end

--引导技能
function CPlayerAvatar:PlayChanOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local time = skillConfig.chant_time

	local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]
	    if anima1 and anima2 and anima3 then
	    	self:PlaySkillAnima(anima1, false, function()
	    		self:PlaySkillAnima(anima2, true, function() end)
	    	end)
	    	self.chanOnArenaTime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima2)
	        end, time, 1)
	    end
	else
		local anima1 = skill_action.animation
		self:PlaySkillAnima(anima1, true, function() end)
	    if anima1 then
	        self:PlaySkillAnima(anima1, true, function() end)
		    self.chanOnArenaTime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima1)
	        end, time, 1)
	    end
	end

end

--连续技能
function CPlayerAvatar:PlayComboOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local count = math.floor(skillConfig.combo_time/skillConfig.stiff_time)
    local animaFile = skill_action.animation
    if animaFile then
    	_sys.asyncLoad = true  -- 异步
    	local anima = self.objSkeleton:addAnima(animaFile)
    	for i = 1, count do
        	anima:combine(self.objSkeleton:addAnima(animaFile))
        end
        anima:onEvent(function(e)
	        if not self.objMesh.bIsMe then
	            if string.sub(e, 1, 3) == "sfx" then
	                return true
	            end
	        end
        	return false
    	end)
        anima:play()
    end
end

--冲锋技能
function CPlayerAvatar:PlayJumpOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animation = GetPoundTable(skill_action.animation)
	local jumpAcitonFile1 = animation[1]
    self:PlaySkillAnima(jumpAcitonFile1, false)
end

function CPlayerAvatar:PlayMoveTrapOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false)
	if animaTable[2] then
    	local table =  GetColonTable(animaTable[2])
    	if #table ~= 3 then
	        return
	    end
	    local pos = self:GetPos()
	    local szName = table[1]
	    local faceto = self:GetDirValue()
	    local x, y = GetPosByDis(pos, faceto, table[2])
	    --local mat = _Matrix3D.new()
	    mat:setTranslation(pos.x, pos.y, pos.z)
	   	local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    pfx.transform:mulTranslationRight(x - pos.x, y - pos.y, pos.z - pos.z, tonumber(table[3]))
	    self.trapOnArenaTime = TimerManager:RegisterTimer(function()
	        self.objSkeleton.pfxPlayer:stop(szName, true)
	    end, tonumber(table[3]), 1)
    end	
end

function CPlayerAvatar:PlayStaticTrapOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation)
	self:PlaySkillAnima(animaTable[1], false)
	if animaTable[2] then
		self:IsHidePfx(skillId)
	    local pos = self:GetPos()
	    local szName = animaTable[2]
	    mat:setTranslation(pos.x, pos.y, pos.z)
	    local pfx = self:SklPlayPfx(szName, szName)
	    if not pfx then
	    	return
	    end
	    if mat then
	    	pfx.transform = mat
	    end
    end	
end

--多段技能
function CPlayerAvatar:PlayMultiOnArena(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local time = skillConfig.multi_time
    local animation = GetPoundTable(skill_action.animation)
    if #animation == 3 then
		local anima1, anima2, anima3 = animation[1], animation[2], animation[3]
	    if anima1 and anima2 and anima3 then
	    	self:PlaySkillAnima(anima1, false, function()
		        self:PlaySkillAnima(anima2, true, function()
		        	self:PlaySkillAnima(anima3, false, function()
					end)
			    end)
	    	end)
	    	self.multiOnArenaTime = TimerManager:RegisterTimer(function()
	        	self:StopAction(anima2)
	        end, time, 1)
	    end
	else
		local anima1 = skill_action.animation
        self:PlaySkillAnima(anima1, true, function()
	    end)
    	self.multiOnArenaTime = TimerManager:RegisterTimer(function()
        	self:StopAction(anima1)
        end, time, 1)
	end
end

--------------------------------------------------------------------------
--播放合体动作
function CPlayerAvatar:PlayHetiAction()
	if self:IsInSpecialState() then
		return
	end
	local animaFile = self:GetAnimaFile(RoleConfig.heti_san)
	self:PlaySkillAnima(animaFile, false)
end



--adder:houxudong date:2016/8/10 18:22:25
--播放桌边吃饭动作
function CPlayerAvatar:PlayZhuoBianEatAction()
	local animaFile = self:GetAnimaFile(RoleConfig.zhuobianEat_san)
	self:SpiritsPlayAction(animaFile, true)
end

--停止桌边吃饭动作
function CPlayerAvatar:StopZhuoBianEatAction()
	local animaFile = self:GetAnimaFile(RoleConfig.zhuobianEat_san)
	self:SpiritsStopAction(animaFile)
end

--播放地上吃饭动作
function CPlayerAvatar:PlayLandEatAction()
	local animaFile = self:GetAnimaFile(RoleConfig.landEat_san)
	self:SpiritsPlayAction(animaFile, true)
end

--停止地上吃饭动作
function CPlayerAvatar:StopLandEatAction()
	local animaFile = self:GetAnimaFile(RoleConfig.landEat_san)
	self:SpiritsStopAction(animaFile)
end

--播放打坐动作
function CPlayerAvatar:PlaySitAction()
	local animaFile = self:GetAnimaFile(RoleConfig.sit_san)
	self:SpiritsPlayAction(animaFile, true)
end

--停止打坐动作
function CPlayerAvatar:StopSitAction()
	local animaFile = self:GetAnimaFile(RoleConfig.sit_san)
	self:SpiritsStopAction(animaFile)
end

-- 炼化炉动作
function CPlayerAvatar:PlayLianhualuAction()
	local animaFile = self:GetAnimaFile(RoleConfig.lianhualu_san)
	self:SpiritsPlayAction(animaFile, true)
end

-- 排行榜动作
function CPlayerAvatar:PlayRanklistAction()
	local animaFile = self:GetAnimaFile(RoleConfig.rankList_san)
	self:SpiritsPlayAction(animaFile, true)
end


-- 排行榜动作
function CPlayerAvatar:PlaySuperGloryZuoAction()
	local animaFile = self:GetAnimaFile(RoleConfig.superZuo_san)
	self:SpiritsPlayAction(animaFile, true)
end

-- 排行榜动作
function CPlayerAvatar:PlaySuperGloryZanAction()
	local animaFile = self:GetAnimaFile(RoleConfig.superZhan_san)
	self:SpiritsPlayAction(animaFile, true)
end


-- 组队动作
function CPlayerAvatar:PlayTeamAction()
	local animaFile = self:GetAnimaFile(RoleConfig.team_san)
	self:SpiritsPlayAction(animaFile, true)
end

--死亡动作
function CPlayerAvatar:PlayDeadAction()
	local actionFile = self:GetAnimaFile(RoleConfig.dead_san)
  	self:ExecAction(actionFile, false)
end

--播放休闲动作
function CPlayerAvatar:PlayLeisureAction()
	if self.transform then
		self.transform:PlayLeisureAction(self);
		return;
	end
	
	local animaFile = self:GetAnimaFile(RoleConfig.xiuxian_san)
	if animaFile and animaFile ~= "" then
		self:SpiritsPlayAction(animaFile, false)
	end
end

function CPlayerAvatar:StopLeisureAction()
	local animaFile = self:GetAnimaFile(RoleConfig.xiuxian_san)
	if animaFile and animaFile ~= "" then
		self:SpiritsStopAction(animaFile)
	end
end

function CPlayerAvatar:SpiritsPlayAction(animaFile, loop)
	local zhujueFile = animaFile
    if self.horse then
    	if self.horse.otherName and self.horse.otherName ~= ""
    		and self.horse.selfName and self.horse.selfName ~= "" then
	    	local string1 = "v_zhujue_" .. profString[self.dwProfID]
			local string2 = "v_ride_" .. self.horse.selfName
		    local string3 = "v_zhujue_" .. profString[self.dwProfID] .. "_zjzq_" .. self.horse.otherName
		    zhujueFile = GetHorseAnimaTable(animaFile, string1, string3)
	    	local horseFile = GetHorseAnimaTable(animaFile, string1, string2, true)
			self.horse:ExecAction(horseFile, loop)
	    end
    end
    if self.spiritsAvatar then
        local nameString = self.spiritsAvatar.name
       	if nameString and nameString ~= "" then
	        local fileName = GetWuHunAnimaTable(zhujueFile, nameString)
	        if fileName and fileName ~= "" then
	            self.spiritsAvatar:ExecAction(fileName, loop)
	        end
	    end
    end
   	self:ExecAction(zhujueFile, loop)
end

function CPlayerAvatar:SpiritsStopAction(animaFile)
	local zhujueFile = animaFile
    if self.horse then
    	if self.horse.otherName and self.horse.otherName ~= ""
    		and self.horse.selfName and self.horse.selfName ~= "" then
	    	local string1 = "v_zhujue_" .. profString[self.dwProfID]
			local string2 = "v_ride_" .. self.horse.selfName
		    local string3 = "v_zhujue_" .. profString[self.dwProfID] .. "_zjzq_" .. self.horse.otherName
		    zhujueFile = GetHorseAnimaTable(animaFile, string1, string3)
	    	local horseFile = GetHorseAnimaTable(animaFile, string1, string2, true)
			self.horse:StopAction(horseFile)
	    end
    end
    if self.spiritsAvatar then
        local nameString = self.spiritsAvatar.name
       	if nameString and nameString ~= "" then
	        local fileName = GetWuHunAnimaTable(zhujueFile, nameString)
	        if fileName and fileName ~= "" then
	            self.spiritsAvatar:StopAction(fileName)
	        end
	    end
    end
   	self:StopAction(zhujueFile)
end

--播放默认动作
function CPlayerAvatar:ExecIdleAction()
    self:SpiritsPlayAction(self.szIdleAction, true)
end

function CPlayerAvatar:StopIdleAction()
    self:SpiritsStopAction(self.szIdleAction)
end

--播放位移动作
function CPlayerAvatar:ExecMoveAction()
    self:SpiritsPlayAction(self.szMoveAction, true)
    self:PlayMoveMusic()
    self:PlayMovePfx()
end

function CPlayerAvatar:StopMoveAction()
    self:SpiritsStopAction(self.szMoveAction)
    self:StopMoveMusic()
    self:StopMovePfx()
end

function CPlayerAvatar:PlayMovePfx()
	self:StopMovePfx()
	if self.footprintPfx then
		self:PlayPfxOnBone("zuojiaoyin", self.footprintPfx["zuo"], self.footprintPfx["zuo"])
		--self:PlayPfxOnBone("youjiaoyin", self.footprintPfx["you"], self.footprintPfx["you"])
	end
end

function CPlayerAvatar:StopMovePfx()
	if self.footprintPfx then
		self:StopPfxByName(self.footprintPfx["zuo"], true)
		--self:StopPfxByName(self.footprintPfx["you"], true)
	end
end

--主角自身移动音效
function CPlayerAvatar:PlayMoveMusic()
	if self:IsSelf() then
        if not self.musicplaying or self.musicplaying == 0 then
            self.musicplaying = 1
            SoundManager:StopEffectSound()
            local musicId = MainPlayerController:GetMoveMusic()
           	SoundManager:PlayEffectSound(musicId)
        end
    end
end

function CPlayerAvatar:StopMoveMusic()
	if self:IsSelf() then
        if self.musicplaying and self.musicplaying == 1 then
            self.musicplaying = 0
            SoundManager:StopEffectSound()
        end
    end
end

function CPlayerAvatar:ResetMoveMusic()
	if self.moveState then
		self.musicplaying = nil
	end
end
----------------------飘字-----------------------------------
function CPlayerAvatar:DrawSkipNumber(arrParam)
	if self.isWinMin then
		return
	end
	local norNum = #self.setSkipNormal
	if norNum >= SkipNoticeConfig.MaxNum then
		return
	end
	table.insert(self.setSkipNormal, arrParam)
	self.bHaveSkipNor = true
end

function CPlayerAvatar:UpdateSkipNumber()
	self:UpdateSkipNormal()
end

function CPlayerAvatar:UpdateSkipNormal()
	if StoryController:IsStorying() then
		return
	end
	if self.bHaveSkipNor then
		if not self.setSkipNormal[1] then
			self.bHaveSkipNor = false
			return
		end
		if GetCurTime() - self.dwLastSkipNormalShowTime < SkipNoticeConfig.NormalTick then
			return
		end
		self:RenderSkipNumber(self.setSkipNormal[1])
		table.remove(self.setSkipNormal, 1)
	    self.dwLastSkipNormalShowTime = GetCurTime()
	end
end

-------------------窗口最小化时-------------------------
--窗口最小化
function CPlayerAvatar:OnWindowMin()
	self.setSkipNormal = {}
	self.bHaveSkipNor = false
	self.dwLastSkipNormalShowTime = 0
	self.isWinMin = true
end

--窗口恢复
function CPlayerAvatar:OnWindowBack()
	self.isWinMin = nil
end

----------------------------------剧情------------------------------------
-- 设置摄像机跟随
function CPlayerAvatar:SetCameraFollow()
	self.controlBySkn = false
	self.Control = CPlayerControl
end

function CPlayerAvatar:SetCameraFollowBySkn()
	self.controlBySkn = true
	self.Control = CPlayerControl
end

-- 取消摄像机跟随
function CPlayerAvatar:DisableCameraFollow()
	self.controlBySkn = false
	self.Control = nil
end

function CPlayerAvatar:GetPlayerPos()
	return self:GetPos()
end

function CPlayerAvatar:GetPlayerDirValue()
	return self:GetDirValue()
end

function CPlayerAvatar:SetPlayerPosValue(vecPos)
	if not vecPos then return end
	self:SetPos(vecPos)
end

function CPlayerAvatar:SetPlayerDirValue(dwDir)
	if not dwDir then return end
	self:SetDirValue(dwDir)
end

function CPlayerAvatar:SetPlayerPosAndDir(vecPos, dwDir)
	if not vecPos then return end
	if not dwDir then return end
	self:SetPos(vecPos)
	self:SetDirValue(dwDir)
end

function CPlayerAvatar:PlaySkillPfx(skillId, pfxFile, mat)
	if self:IsHidePfx(skillId) then
		return
	end
	local pfx = self:PlayerPfxOnSkeleton(pfxFile, mat)
	return pfx
end

function CPlayerAvatar:PlayTrapPfx(skillId, pfxFile, mat)
	if self:IsHidePfx(skillId) then
		return
	end

    if self.objSceneMap and self.objSceneMap.objScene then
        if self.objPP and self.objPP.terrain == nil then
            self.objPP.terrain = self.objSceneMap.objScene.terrain
        end
    end
    if not pfxFile or pfxFile == "" then
    	return
    end
	local pfx = self.objPP:play(pfxFile, pfxFile, mat)
	if not self:IsSelf() then
		local emts = pfx:getEmitters()
		for i, v in ipairs(emts) do
			v.graEvent:clearTags()
		end
    end

    pfx.keepInPlayer = false

    return pfx
end

local wMat = _Matrix3D.new()
local pos2d = _Vector2.new()
local pos3d = _Vector3.new()
local scale3d = _Vector3.new()
function CPlayerAvatar:PlaySkillNamePfx(pfxFile, imgFile)
	if self:IsHidePfx() then
		return
	end
    if self.objSceneMap and self.objSceneMap.objScene then
        if self.objPP and self.objPP.terrain == nil then
            self.objPP.terrain = self.objSceneMap.objScene.terrain
        end
    end
    local pos = self:GetPos()
    local mat = _Matrix3D.new()
    mat:setTranslation(pos.x, pos.y, pos.z)
    if not pfxFile or pfxFile == "" then
    	return
    end
	local pfx = self.objPP:play(pfxFile, pfxFile, mat)
	pfx.keepInPlayer = false
	if pfx then
		local emitter = pfx:getEmitters()
		if emitter and emitter[1] then
			local img = CResStation:GetImage(imgFile)
			emitter[1]:onRender(function()
		        _rd:pop3DMatrix(wMat)
		        wMat:getTranslation(pos3d)
		        wMat:getScaling(scale3d)
		        _rd:projectPoint(pos3d.x, pos3d.y, pos3d.z, pos2d)
		        _rd:push3DMatrix(wMat)
		        local x = pos2d.x
		        local y = pos2d.y
		        img:drawImage( x, y, x + img.w * scale3d.x, y + img.h * scale3d.x)
		    end)
		else
			print("error: ", "PlaySkillNamePfx() no emitter", pfxFile)
		end
	else
		print("error: ", "PlaySkillNamePfx() no file", pfxFile)
	end
    return pfx
end

function CPlayerAvatar:IsInSpecialState()
    if self.jumpState then
        return true
    end
    if self.flyState then
        return true
    end
    if self.rollState then
        return true
    end
    if self.knockBackState then
        return true
    end
    if self.stoneGazeState then
        return true
    end
    if self.chanState ~= ChanSkillState.StateInit then
        return true
    end
    if self.prepState ~= 0 then
        return true
    end
    -- if self.skillPlaying then
    --     return true
    -- end
    if self.sitState and self.sitState.id ~= 0 then
        return true
    end
    return false
end

function CPlayerAvatar:SetWingModel(modelId)
	if self:NewSetWing(modelId) then
		return;
	end

	if self.spiritsAvatar then
		self.objMesh:delSubMesh(self.spiritsAvatar.objMesh)
		self.spiritsAvatar:Destroy()
		self.spiritsAvatar = nil
	end
	if self.wingAvatar then
		self.objMesh:delSubMesh(self.wingAvatar.objMesh)
		self.wingAvatar:Destroy()
		self.wingAvatar = nil
	end
	if not modelId or modelId == 0 then
		return
	end
	local cfg = t_wing[modelId]
	if not cfg then
		return
	end
	if cfg.flag == 1 then
		local wingAvatar = WingAvatar:new(modelId)
		if not wingAvatar then
			return
		end
	    self.objMesh:addSubMesh(wingAvatar.objMesh)
	    self.spiritsAvatar = wingAvatar
	    wingAvatar:SetDefAction(self)
	else
		local wingAvatar = WingAvatar:new(modelId)
		if not wingAvatar then
			return
		end
	    local boneMat1 = self:GetSkl():getBone("chibang01")
		wingAvatar.objMesh.transform = boneMat1
	    self.objMesh:addSubMesh(wingAvatar.objMesh)
	    self.wingAvatar = wingAvatar
	    wingAvatar:ExecDefAction()
	end
end

function CPlayerAvatar:NewSetWing(wingId)
	self.dwWingId = self.dwWingId or 0;
	local cfg = t_wing[self.dwWingId];
	local oldId = cfg and cfg.wing_equipmodel or 0;
	oldId = self.equips[oldId] and oldId or 0;
	self.dwWingId = wingId or 0;
	cfg = t_wing[self.dwWingId];
	local newId = cfg and cfg.wing_equipmodel or 0;
	local changed = newId ~= oldId;
	if changed then
		self:RemoveEquip(oldId);
		self:AddEquip(newId,true);
	end
	return true;
end

-- 得到当前玩家的翅膀id
function CPlayerAvatar:GetWingId( )
	return self.dwWingId and self.dwWingId or nil;
end

function CPlayerAvatar:IsPickNull()
	if self.pickFlag ~= enPickFlag.EPF_Null then
		return true
	end
	return false
end

function CPlayerAvatar:ResetAnima()
	if self.objSkeleton then
		self.objSkeleton:stopAnimas()
		self.objSkeleton.pfxPlayer:stopAll(true)
		self.objSkeleton.pfxPlayer:clearParams()
		self:ExecIdleAction()
	end
end

function CPlayerAvatar:GetCollectAnima()
	return self:GetAnimaFile(RoleConfig["collect_san1"])
end

function CPlayerAvatar:PlayCollectEnd(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	local skill_action = skillConfig.skill_action
	if skill_action == "2" then
		local anima = self:GetAnimaFile(RoleConfig["collect_san2"])
		self:PlaySkillAnima(anima)
		self:PlayPrepSound(skillId)
	end
end

function CPlayerAvatar:ChangeEquipGroup(oldId, newId)
	self:DeleteEquipGroup(oldId)
	self:AddEquipGroup(newId)
end

function CPlayerAvatar:AddEquipGroup(id)
	local prof = self.dwProfID
	local list = self:GetIdList(id)
	for index, groupId in pairs(list) do
		local info = t_equipgrouphuizhang[groupId]
		if info then
			local pfxListString = info["pfxname" .. prof]
			if pfxListString and pfxListString ~= "" then
				local pfxList = GetPoundTable(pfxListString)
				for index, pfx in pairs(pfxList) do
					local pfxName = pfx .. ".pfx"
					local boneName = info["bonename"]
				    self:PlayPfxOnBone(boneName, pfxName, pfxName)
				end
			end
		end
	end
end

function CPlayerAvatar:DeleteEquipGroup(id)
	local prof = self.dwProfID
	local list = self:GetIdList(id)
	for index, groupId in pairs(list) do
		local info = t_equipgrouphuizhang[groupId]
		if info then
			local pfxListString = info["pfxname" .. prof]
			if pfxListString and pfxListString ~= "" then
				local pfxList = GetPoundTable(pfxListString)
				for index, pfx in pairs(pfxList) do
					local pfxName = pfx .. ".pfx"
				    self:StopPfxByName(pfxName)
				end
			end
		end
	end
end

function CPlayerAvatar:GetIdList(id)
	local id1 = math.floor(id / 10 ^ 4) % 10000
	local id2 = math.floor(id / 10 ^ 0) % 10000
	return {id1, id2}
end

function CPlayerAvatar:GetPlayer()
	local dwRoleID = self.dwRoleID
    local player = CPlayerMap:GetPlayer(dwRoleID)
    return player
end

function CPlayerAvatar:ResetSitAreaPfx()
	local player = self:GetPlayer()
	if player then
    	player:ResetSitAreaPfx()
    end
end

function CPlayerAvatar:PlayShenzhuangAction()
	local animaFile = self:GetAnimaFile(RoleConfig.shenzhuang_san)
	self:SpiritsPlayAction(animaFile, false)
end

function CPlayerAvatar:PlayShenzhuangIdleAction()
	local animaFile = self:GetAnimaFile(RoleConfig.shenzhuangidle_san)
	self:SpiritsPlayAction(animaFile, true)
end

function CPlayerAvatar:ResetEquipPfx()
	local pfxList1 = self.armPfx
	local boneList1 = self.armBone
	if pfxList1 then
		for index, bonePfx in pairs(pfxList1) do
			local pfxName = bonePfx .. ".pfx"
		    self:StopPfxByName(pfxName)
		end	
		for index, bonePfx in pairs(pfxList1) do
			local pfxName = bonePfx .. ".pfx"
			local boneName = bonePfx
			if boneList1 then
				boneName = boneList1[index]
			end
		    self:PlayPfxOnBone(boneName, pfxName, pfxName)
		end
	end

	local pfxList2 = self.dressPfx
	local boneList2 = self.dressBone
	if pfxList2 then
		for index, bonePfx in pairs(pfxList2) do
			local pfxName = bonePfx .. ".pfx"
		    self:StopPfxByName(pfxName)
		end
		for index, bonePfx in pairs(pfxList2) do
			local pfxName = bonePfx .. ".pfx"
			local boneName = bonePfx
			if boneList2 then
				boneName = boneList2[index]
			end
		    self:PlayPfxOnBone(boneName, pfxName, pfxName)
		end
	end
end

function CPlayerAvatar:GetArmsModelId()
	local armsModelId = self.dwArmsModalID
	if self:IsSelf()
		and MainPlayerController.addBinghunState then
		armsModelId = MainPlayerController.addBinghunState
	end
	return armsModelId
end

function CPlayerAvatar:SetFootprintPfx(pfx)
	if pfx then
		self.footprintPfx = pfx
		if self.movestate then
			self:PlayMovePfx()
		end
	else
		self:StopMovePfx()
		self.footprintPfx = nil
	end
end

function CPlayerAvatar:ChangeShenwuPfx(oldId, newId)
	self:RemoveShenwuPfx(oldId)
	self:AddShenwuPfx(newId)
	self:SetShenwuId(newId)
end

function CPlayerAvatar:SetShenwuId(id)
	self.shenwuId = id
end

function CPlayerAvatar:AddShenwuPfx(id)
	if not self.isShowShenwuPfx then
		return
	end
	local boneNameList = {"rwh", "lwh"}
	if id and id ~= 0 then
		local info = t_shenwu[id]
		if info then
			local prof = self.dwProfID
			local pfxString = info["sence_pfx" .. prof]
			if pfxString and pfxString ~= "" then
				local pfxNameList = GetPoundTable(pfxString)
				for index, bonePfx in pairs(pfxNameList) do
					local pfxName = bonePfx .. ".pfx"
				    self:PlayPfxOnBone(boneNameList[index], pfxName, pfxName)
				end
			end
		end
	end
end

function CPlayerAvatar:RemoveShenwuPfx(id)
	if id and id ~= 0 then
		local info = t_shenwu[id]
		if info then
			local prof = self.dwProfID
			local pfxString = info["sence_pfx" .. prof]
			if pfxString and pfxString ~= "" then
				local pfxNameList = GetPoundTable(pfxString)
				for index, bonePfx in pairs(pfxNameList) do
					local pfxName = bonePfx .. ".pfx"
				    self:StopPfxByName(pfxName)
				end
			end
		end
	end
end

function CPlayerAvatar:ResetShenwuPfx()
	self:ChangeShenwuPfx(self.shenwuId, self.shenwuId)
end

function CPlayerAvatar:SetPendantsVisible(visible)
	for i,pendant in pairs(self.pendants) do
		pendant:OnUpdate(e);
		pendant:SetVisible(visible);
	end
end

function CPlayerAvatar:DoExtendAnima(event)
	if not event then
		return;
	end;
	
	if not self.objNode then
		return;
	end
	
	if self.objNode.bIsMe then
		if string.find(event,'PointLight') then
			local script = 'local '..event..' return PointLight';
			local param = assert(loadstring(script))();
			-- CPlayerMap:PlayEffectLight(param);
		elseif string.find(event,'Radialblur') then
			local script = 'local '..event..' return Radialblur';
			local param = assert(loadstring(script))();
			-- CPlayerMap:PlayEffectBlur(param);
		end
	end
	
	if string.find(event,'PlayBlink') then
		local script = 'local '..event..' return PlayBlink';
		local param = assert(loadstring(script))();
		self:PlayPlayerBlink(param);
	end
	
	if string.find(event,'EquipAction') then
		local script = 'local '..event..' return EquipAction';
		local param = assert(loadstring(script))();
		self:PlayEquipAction(param);
	end

	if string.find(event, "Scale") then
		local script = 'local ' .. event..' return Scale'
		local param = assert(loadstring(script))()
		self:playShapeAction(param)
	end
end

function CPlayerAvatar:playShapeAction(param)
	if not param then
		return
	end

	for k, equip in pairs(self.equips) do
		equip:playShapeAction(param)
	end
end

function CPlayerAvatar:PlayEquipAction(param)
	if not param then
		return;
	end
	
	self.equipActionDir = param.dir;
	TimerManager:UnRegisterTimer(self.equipTimer);
	self.equipTimer = nil;
	for id,equip in pairs(self.equips) do
		local actnum = equip:GetMaxActionNum();
		if actnum ~= 0 then
			equip:PlayActionByParam(param.actions);
		end
	end
	
end

function CPlayerAvatar:PlayPlayerBlink(param)
	if not param then
		return;
	end
	local visible = param.visible;
	for id,equip in pairs(self.equips) do
		for index,avatar in pairs(equip.parts) do
			local sms = avatar.objMesh:getSubMeshs();
			-- for i,mesh in ipairs(sms) do
				if not avatar.objMesh.objBlender then
					avatar.objMesh.objBlender = _Blender.new()
				end
				avatar.objMesh.objBlender:blend(0xffffffff,0x00ffffff,3000);
			-- end
		end
	end
	
end

function CPlayerAvatar:PlayTianshen(skillId, targetCid, targetPos)
	if not self.objNode then
		return;
	end
	
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return
    end
    local animaTable = GetPoundTable(skill_action.animation);
	if not animaTable or #animaTable == 0 then
		return;
	end
	local file = animaTable[1];
	local playpfx = function(pfxfile)
		local scene = CPlayerMap:GetSceneMap();
		if not scene then
			return;
		end
		
		local pos = targetPos or self:GetPos();
		local mat = _Matrix3D.new();
		mat:setTranslation(pos.x, pos.y, pos.z);
		
		local player,name = scene:PlayerPfxByMat(pfxfile, pfxfile, mat);
		if not player then
			return;
		end
		
		local emitters = player:getEmitters();
		for i,emitter in ipairs(emitters) do
			local mesh = emitter.resMesh;
			if mesh and mesh ~='' then
			end
			emitter.transform:setRotation(self.objNode.transform:getRotation());
		end
	end
	
	if self.objNode and
			(self.objNode.dwType == enEntType.eEntType_MagicWeapon or
					self.objNode.dwType == enEntType.eEntType_LingQi or
					self.objNode.dwType == enEntType.eEntType_MingYu)
					then
		self:StopMove();
		-- local selfPos = self:GetPos();
		-- targetPos.z = selfPos.z;
		-- self.objNode.transform:mulTranslationRight(targetPos.x - selfPos.x, targetPos.y - selfPos.y, targetPos.z - selfPos.z)
	end
	
	if GetExtensionName(file) == 'pfx' then
		playpfx(file);
	else
		self:PlaySkillAnima(file,false);
	end
	
	if #animaTable <2 then
		return;
	end
	file = animaTable[2];
	if GetExtensionName(file) == 'pfx' then
		playpfx(file);
	else
		self:PlaySkillAnima(file,false);
	end
	
end














