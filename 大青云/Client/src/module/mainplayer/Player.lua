_G.classlist['CPlayer'] = 'CPlayer'
_G.CPlayer = {}
CPlayer.objName = 'CPlayer'
function CPlayer:new(dwRoleID)
	local obj = {};
	obj.dwRoleID = dwRoleID;
    obj.objAvatar = nil; --对应的显示相关
	obj.setMoveMonitor = {} ;--监视器
	obj.setMoveActionList = {};--移动的队列
	obj.playerInfo = PlayerInfo:new() --属性信息
	obj.playerShowInfo = PlayerShowInfo:new() --外观信息
	obj.wuhunInfo = 0
	obj.buffInfo = BuffInfo:new()
	obj.stateInfo = StateInfo:new()
	obj.titleInfo = {}
	obj.titleImgUrl = {}
	obj.leisureTime = GetCurTime() + 10000
	obj.randomLeisureTime = math.random(1, 10) * 1000
    obj.stateMachine = StateMachine:new(obj)
    obj.stateMachine.currState = IdleState:new(obj)
	obj.pkState = 0;
	obj.battleState = false
	obj.camp = 0;
	obj.pkColorState = 0;  --名字颜色状态  1 灰色  2 红色
	obj.isShowHeadBoard = true
	obj.PatrolController = nil--巡逻管理器
	obj.recordCreateAct = nil
	obj.guildName = nil
	obj.guildId = nil
	obj.headBorad = nil
	obj.xianjieModelid=nil
	obj.xuanBingModelID=nil;
	obj.magicWeapon = nil
	obj.lingQi = nil
	obj.mingYu = nil
	obj.lingzhi = nil
	obj.lingzhiLevel = nil
	obj.nightState = false
	obj.vTitleImg = nil;
	obj.vflag = 0;
	obj.realmUrl = nil;
	obj.realm = 0;
	obj.xiuxianPfxTime = 30000
	obj.xiuxianLastTime = 0
	obj.useAvatarLoader = true
	obj.transformID = 0;
	obj.transform = nil;
	obj.eatType = 0;    --玩家吃饭的类型or椅子id
	obj.lockedState = false;
	-- for i,v in pairs(CPlayer) do
		-- if type(v) == "function" then
			-- obj[i] = v;
		-- end;
	-- end;
	setmetatable(obj, {__index = CPlayer})
	return obj;
end;

function CPlayer:Create(info,disabledEquipAct)
	
	self.dwRoleID = info.dwRoleID
	--创建avatar
	self.objAvatar = CPlayerAvatar:new()
	if disabledEquipAct then
		self.objAvatar.useAct = false;
	end
	
	if not self:IsSelf() then
		-- self.objAvatar.avatarLoader.lowPriority = true
	end
	if self.useAvatarLoader then
		-- self.objAvatar.avatarLoader:beginRecord(true)
	end
	
	--CMemoryDebug:AddObject('CPlayer.objAvatar', self.objAvatar)
	
	if not self.objAvatar:Create(info.dwRoleID, info.dwProf) then
		Debug("CPlayer:Create Create Role Error by Create")
		return false
	end
	self:InitPlayerInfo(info) --初始化playerInfo
	self:SetShenwuId(info.shenwuId or 0) --初始化神武

	--设置装备
	info.dwHorseID = MountUtil:GetModelIdByLevel(info.dwHorseID or 0, info.dwProf)
	if not self:DefShowInfo(info) then
		Debug("CPlayer:Create Set Default Equip Error")
		return  false
	end
	
	self.guildId = info.guildId or nil
	self.guildName = info.szGuildName or nil
	self.wuhunId = info.wuhun or 0
	self.icon = info.icon or 0 -- 头像id
	self:SetSitInfo(info.sitId or 0, info.sitIndex or 0)
	if self.recordCreateAct then
		self:recordCreateAct(info)
	end
	
	self:SetTitlePalyerInfo(info);
	self.objAvatar.objPlayer = self --记录自己, 用于更新自己在地图上的位置
	self:SetPKState(info.rolePkState or 0);
	self:SetUbit(info.ubit)
	--self.pkState = info.rolePkState or 0;
	self.magicWeapon = info.magicWeapon;
	self.lingQi = info.lingQi;
	self.mingYu = info.mingYu;
	self.camp = info.roleCamp or 0
	self.realm = info.roleRealm or 0;
	self.realmUrl = ResUtil:GetRealmIcon(self:GetReolm())
	self:SetLovelyPet(info.lovelypet or 0);             -- 萌宠
	self:SetWingId(info.dwWing or 0)                    -- 翅膀
	self:SetEquipGroup(info.suitflag or 0)
	self:SetFootprints(info.footprints or 0)
	self:SetTreasure(info.treasure or 0)
	self:SetServerId(info.serverId or 0)
	self:SetPartnerName(info.partnerName)
	self:SetPendantModelId(info.XianJieModelId or 0);   --仙界id
	self:SetXuanBingModelId(info.xuanBingId or 0); --玄兵ID
	self:SetTianshenId(info.TransferModel or 0,info.tianshenStart or 0,info.tianshenLv or 0,info.tianshenColor or 0);	--天神
	if self:IsSelf() then
		VplanModel:upDataVflag()
	else
		self.vflag = info.vflag or 0;
		self.vTitleImg = self:GetVTitleURL()
	end
	if info.lingzhi then 
		self:SetLingZhi(info.lingzhi);
	end
	if info.eatType then
		-- WriteLog(LogType.Normal,true,'-------------houxudong',info.eatType)
		self:SetLunchState(info.eatType)
	end
	self:SetZhuanZhi(info.zhuanZhiLv)
	-- 
	if self.useAvatarLoader then
		--self.objAvatar.avatarLoader:endRecord()
	end

	MagicWeaponFigureController:CreateMagicWeapon(self);
	LingQiFigureController:CreateMagicWeapon(self);
	MingYuFigureController:CreateMagicWeapon(self);
	return true
end

function CPlayer:Update(dwInterval)
    if self.objAvatar and self.objAvatar.objNode and self.objAvatar.objMesh then
		self:DrawHeadBoard()
		self:Leisure()
		if self.stateMachine then
			self.stateMachine:update()
		end

		if self.PatrolController then
			self.PatrolController:UpdatePatrol()
		end
		self:UpdateShenbing(dwInterval)
		self:UpdateLingqi(dwInterval)
		self:UpdateMingYu(dwInterval)
		self:PlayWuhunXiuXian(dwInterval)
		self:UpdateTianshen(dwInterval)
		if self.pet then
			self.pet:UpdatePos(dwInterval)
		end
		if self.npcGuild then
			self.npcGuild:UpdatePos(dwInterval);
		end
		
		if self.tianshen then
			self.tianshen:UpdatePos(dwInterval);
		end

		self:UpdateSitAreaPfx()
		
		if self.indicator then
			self.indicator.transform = self.objAvatar.objNode.transform;
			self.indicator:draw();
		end
		
	end
	self:UpdateBuff(dwInterval);
end;

CPlayer.editeSelected = false;
function CPlayer:SetEditeSelected(state)
	self.editeSelected = state;
	if state then
		if not self.indicator then
			self.indicator = _Indicator.new();
		end
	else
		self.indicator = nil;
	end
end

function CPlayer:GetEditeSelected()
	return self.editeSelected;
end

function CPlayer:PlayWuhunXiuXian(dwInterval)
	local wuhunId = self:GetWuhun()
	if self.dwRoleID == MainPlayerController:GetRoleID() then
		wuhunId = SpiritsModel:GetFushenWuhunId()
	end
	
	if not wuhunId or wuhunId == 0 then return end
	self.xiuxianLastTime = self.xiuxianLastTime + dwInterval
	if self.xiuxianLastTime >= self.xiuxianPfxTime then
		self.xiuxianLastTime = self.xiuxianLastTime - self.xiuxianPfxTime
		self:PlayWuhunXiuXianPfx(wuhunId)
	end
	
end

-- 播放武魂休闲特效
function CPlayer:PlayWuhunXiuXianPfx(wuhunId)
	-- if not wuhunId or wuhunId == 0 then return end
	-- local switchPfxId = nil
	-- if t_wuhun[wuhunId] then 
	-- 	switchPfxId = t_wuhun[wuhunId].active_ghost 
	-- elseif t_wuhunachieve[wuhunId] then 
	-- 	switchPfxId = t_wuhunachieve[wuhunId].active_ghost 
	-- end
	
	-- -- switchPfxId = "npc_xuanzhong.pfx"
	-- if not switchPfxId then return end
	
	-- local avatar = self:GetAvatar()
	-- if avatar then
	-- 	avatar:PlayerPfxOnSkeleton(switchPfxId)
	-- end
end

function CPlayer:GetNamePos()
	if self.headBorad then 
		return self.headBorad:GetNamePos(self)
	end
	return nil
end

function CPlayer:UpdateShenbing(dwInterval)

	if self.magicWeaponFigure and self.magicWeaponFigure:IsInMap() then
		MagicWeaponFigureController:ResetMagicWeaponPos(self)
		MagicWeaponFigureController:UpdateMagicWeaponPos(self)
		local pos = self.magicWeaponFigure:GetPos()
		local selfPos = self:GetPos()
		if pos and selfPos then
			local dis = GetDistanceTwoPoint(pos, selfPos)
			if dis > 100 then
				MagicWeaponFigureController:ResetMagicWeaponPos(self, true)
			end
		end
	end
end

function CPlayer:UpdateLingqi(dwInterval)

	if self.lingQiFigure and self.lingQiFigure:IsInMap() then
		LingQiFigureController:ResetMagicWeaponPos(self)
		LingQiFigureController:UpdateMagicWeaponPos(self)
		local pos = self.lingQiFigure:GetPos()
		local selfPos = self:GetPos()
		if pos and selfPos then
			local dis = GetDistanceTwoPoint(pos, selfPos)
			if dis > 100 then
				LingQiFigureController:ResetMagicWeaponPos(self, true)
			end
		end
	end
end

function CPlayer:UpdateMingYu(dwInterval)
--[[
	if self.mingYuFigure and self.mingYuFigure:IsInMap() then
		MingYuFigureController:ResetMagicWeaponPos(self)
		MingYuFigureController:UpdateMagicWeaponPos(self)
		local pos = self.mingYuFigure:GetPos()
		local selfPos = self:GetPos()
		if pos and selfPos then
			local dis = GetDistanceTwoPoint(pos, selfPos)
			if dis > 100 then
				MingYuFigureController:ResetMagicWeaponPos(self, true)
			end
		end
	end]]
end

function CPlayer:UpdateTianshen(dwInterval)
	if self.tianshen and self.tianshen:IsInMap() then
		TianShenController:ResetFollowTianshenPos(self)
		TianShenController:UpdateFollowTianshenPos(self)
		local pos = self.tianshen:GetPos()
		local selfPos = self:GetPos()
		if pos and selfPos then
			local dis = GetDistanceTwoPoint(pos, selfPos)
			if dis > 100 then
				TianShenController:ResetFollowTianshenPos(self, true)
			end
		end
	end
end

function CPlayer:AddPosMonitor(szName,objMonitor)
	self.setMoveMonitor[szName] = objMonitor;
end;
function CPlayer:DelPosMonitor(szName)
	self.setMoveMonitor[szName] = nil;
end;

--改变称号info
function CPlayer:SetTitlePalyerInfo(info)
	self.titleInfo = {info.title or 0, info.title1 or 0, info.title2 or 0}
	self:SetTitleUrl()
end
function CPlayer:SetZhChCamp(camp)
	self.camp = camp;
end;
--改变称号URL
function CPlayer:SetTitleUrl()
	self.titleImgUrl = TitleModel:GetImgByID(self.titleInfo);
	if self.headBorad then
		if self:IsSelf() then
			self.headBorad:OnChangeTitleSWF(TitleModel:GetNowTitleImg(), self)
		else
			self.headBorad:OnChangeTitleSWF(self.titleImgUrl, self)
		end
	end
end

function CPlayer:OnPosChange(newPos)
	for i , Monitor in pairs(self.setMoveMonitor) do
		if Monitor.OnPosChange then
			Monitor:OnPosChange(self,newPos);
		end;
	end;
end;

--获取玩家ID
function CPlayer:GetRoleID()
	return self.dwRoleID;
end;

function CPlayer:GetCid()
	return self.dwRoleID
end

function CPlayer:SetZhuanZhi(zhuanZhiLv)
	self.zhuanZhiLv = zhuanZhiLv or 0
	if self.headBorad then
		self.headBorad:OnChangeZhuanzhi(self.zhuanZhiLv)
	end
end

function CPlayer:IsSelf()
	return (self:GetRoleID() == MainPlayerController:GetRoleID())
end

local chairID = nil;
local chairDir = nil;
function CPlayer:UpdateShowEquip()
	local playerShowInfo = self:GetPlayerShowInfo()
	self:DefShowInfo(playerShowInfo)
end

--展示外观
function CPlayer:DefShowInfo(info)
    -- FTrace(info)
    --assert(info.dwArms ~= nil)
	--TODO @ytl
	
	if self.transform then
		return;
	end
	
	local prof = self.playerInfo[enAttrType.eaProf]
	self.objAvatar.fashions:SetFashions(info.dwFashionsHead, info.dwFashionsDress, info.dwFashionsArms, prof)
	
	local playerShowInfo = self:GetPlayerShowInfo()
	playerShowInfo.dwDress = info.dwDress
	playerShowInfo.dwArms = info.dwArms
	playerShowInfo.dwShoulder = info.dwShoulder
	playerShowInfo.dwFashionsHead = info.dwFashionsHead
	playerShowInfo.dwFashionsArms = info.dwFashionsArms
	playerShowInfo.dwFashionsDress = info.dwFashionsDress
	playerShowInfo.dwHorseID = info.dwHorseID
	playerShowInfo.dwWing = info.dwWing
	self.objAvatar:SetDress(info.dwDress or 0, info.dwFashionsHead or 0, info.dwFashionsDress or 0);
	self.objAvatar:SetArms(info.dwArms or 0, info.dwFashionsArms or 0);
	self.objAvatar:SetShoulder(info.dwShoulder or 0);
    self.objAvatar:SetMount(info.dwHorseID or 0);
	self:SetWingId(info.dwWing);
	self.objAvatar:UpdateFashions();
	local wuhunId = self:GetWuhun()
	SpiritsUtil:SetWuhunPfx(self:GetRoleID(), wuhunId, self:GetAvatar(), self:GetPlayerInfoByType(enAttrType.eaProf))
	return true
end

function CPlayer:GetHorseID()
	local playerShowInfo = self:GetPlayerShowInfo()
	return playerShowInfo.dwHorseID
end

function CPlayer:SetHorse()
	local oldID = self:GetHorseID()
	self.objAvatar:SetMount(oldID)
end

function CPlayer:GetHorse()
	return self:GetAvatar():GetHorse()
end

function CPlayer:ResetHorse()
	local oldID = self:GetHorseID()
	if oldID ~= 0 then
		self.objAvatar:SetMount(0)
		self.objAvatar:SetMount(oldID)
	end
end

function CPlayer:GetMagicWeapon()
	return self.magicWeapon;
end
function CPlayer:GetLingQi()
	return self.lingQi;
end
function CPlayer:GetMingYu()
	return self.mingYu;
end
function CPlayer:SetMagicWeaponVisible(shengbingVisible)
	local shenbing = self.magicWeaponFigure
	if shenbing and shenbing.objNode and shenbing.objNode.entity then
		shenbing.objNode.visible = shengbingVisible
	end
end
function CPlayer:SetLingQiVisible(lingqiVisible)
	local lingqi = self.lingQiFigure
	if lingqi and lingqi.objNode and lingqi.objNode.entity then
		lingqi.objNode.visible = lingqiVisible
	end
end
function CPlayer:SetMingYuVisible(mingyuVisible)
--	local mingyu = self.mingYuFigure
--	if mingyu and mingyu.objNode and mingyu.objNode.entity then
--		mingyu.objNode.visible = mingyuVisible
--	end
end
function CPlayer:SetMagicWeapon(weaponId)
	self.magicWeapon = weaponId;
	if not self.objAvatar:IsInMap() then return end;
	MagicWeaponFigureController:CreateMagicWeapon(self)
	if self:GetMagicWeaponFigure() and not self:GetMagicWeaponFigure():IsInMap() then
		local Pos = self.objAvatar:GetPos()
		local fDirValue = self.objAvatar:GetDirValue()
		self:GetMagicWeaponFigure():EnterMap(CPlayerMap.objSceneMap,Pos.x,Pos.y,fDirValue)
	end
end
function CPlayer:SetLingQi(weaponId)
	self.lingQi = weaponId;
	if not self.objAvatar:IsInMap() then return end;
	LingQiFigureController:CreateMagicWeapon(self)
	if self:GetLingQiFigure() and not self:GetLingQiFigure():IsInMap() then
		local Pos = self.objAvatar:GetPos()
		local fDirValue = self.objAvatar:GetDirValue()
		self:GetLingQiFigure():EnterMap(CPlayerMap.objSceneMap,Pos.x,Pos.y,fDirValue)
	end
end
function CPlayer:SetMingYu(weaponId)
	if not self.objAvatar:IsInMap() then return end;
	MingYuFigureController:RemoveMagicWeapon(self)
	self.mingYu = weaponId;
	MingYuFigureController:CreateMagicWeapon(self)
--	if self:GetMingYuFigure() and not self:GetMingYuFigure():IsInMap() then
--		local Pos = self.objAvatar:GetPos()
--		local fDirValue = self.objAvatar:GetDirValue()
--		self:GetMingYuFigure():EnterMap(CPlayerMap.objSceneMap,Pos.x,Pos.y,fDirValue)
--	end
end
--进入地图
function CPlayer:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	if self:GetMagicWeaponFigure() then
		self:GetMagicWeaponFigure():EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	end
	if self:GetLingQiFigure() then
		self:GetLingQiFigure():EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	end
--	if self:GetMingYuFigure() then
--		self:GetMingYuFigure():EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
--	end
	self.objAvatar:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	-- SpiritsUtil:SetWuhunPfx(self.dwRoleID, self:GetWuhun(), self.objAvatar, self:GetPlayerInfoByType(enAttrType.eaProf))
	if self.canShowNPCGuild then
		self:ShowNPCGuild();
	end
	self:SetPetModelId(LovelyPetUtil:GetLovelyPetModelId(self:GetLovelyPet()))
	self:SetWingId(self:GetWingId())
	self:SetTianshenId(self:GetTianshenId(),self.tianshenStar,self.tianshenLv,self.tianshenColor);
	if self.tianshen then
		self.tianshen:EnterMap(objSceneMap, fXPos, fYPos, fDirValue);
	end
	self.isEnterMap = true
end

--从地图里面删除
function CPlayer:ExitMap() 
	self:ClearTimePlan()
	if self:GetMagicWeaponFigure() then
		self:GetMagicWeaponFigure():ExitMap()
		self.magicWeaponFigure = nil
	end
	if self:GetLingQiFigure() then
		self:GetLingQiFigure():ExitMap()
		self.lingQiFigure = nil
	end
--	if self:GetMingYuFigure() then
--		self:GetMingYuFigure():ExitMap()
--		self.mingYuFigure = nil
--	end
	MingYuFigureController:ExitMap(self)
	if self.pet then
		self.pet:ExitMap()
		self.pet = nil
	end
	self:HideNPCGuild();
    if self.objAvatar then
	    self.objAvatar:ExitMap()
		self.objAvatar.objPlayer = nil
		self.objAvatar =  nil
	end
	if self.headBorad then self.headBorad:Destory() self.headBorad = nil end
	self.isEnterMap = nil
	self.avatarLoader = nil
	self.setMoveMonitor = nil
	self.setMoveActionList = nil
	self.playerInfo = nil
	self.playerShowInfo = nil
	self.buffInfo = nil
	self.stateInfo = nil
	self.titleInfo = nil
	if self.stateMachine then
		self.stateMachine.currState = nil
		self.stateMachine = nil
	end
	self.PatrolController = nil
	
	TianShenController:RemoveFollowTianshen(self);
end

--得到玩家的avatar
function CPlayer:GetAvatar()
	return self.objAvatar
end

--得到宠物pet
function CPlayer:GetPetAvatar()
	return self.pet
end

--得到玩家的位置
function CPlayer:GetPos() 
	if (not self.objAvatar) or (not self.objAvatar:IsInMap()) then
        return nil
	end
	return self.objAvatar:GetPos() 
end

function CPlayer:SetPos(x, y)
	if not self.objAvatar then
		return
	end
	self.objAvatar:StopMove({x = x, y = y, z = 0})
	self.objAvatar:ResetMat(x, y)
	MagicWeaponFigureController:ResetMagicWeaponPos(self, true)
	LingQiFigureController:ResetMagicWeaponPos(self, true)
	MingYuFigureController:ResetMagicWeaponPos(self, true)
	TianShenController:ResetFollowTianshenPos(self, true);
end

--得到玩家方向
function CPlayer:GetDirValue()
	if not self.objAvatar then
		return nil;
	end;
    return self.objAvatar:GetDirValue();
end;

function CPlayer:GetDir()
	return self:GetAvatar():GetDirValue()
end

function CPlayer:SetDirValue(dir)
    if not self.objAvatar then
        return nil;
    end;
    return self.objAvatar:SetDirValue(dir);
end;

function CPlayer:DrawHeadBoard()
	if not self:IsShowName() then
		return
	end

	local showHp = false
	if not self:IsSelf() and (self.showHp or SkillController.targetCid == self.dwRoleID) then
		showHp = true
	end
    local prof = self.playerInfo[enAttrType.eaProf]
    local name = self.playerInfo[enAttrType.eaName]
    local mePos = self:GetPos()
	
	if not self.headBorad then 
		if self:IsSelf() then
			self.headBorad = PlayerHeadBoard:new(TitleModel:GetNowTitleImg(),self.vTitleImg, self, self:GetRealmUrl())
		else
			self.headBorad = PlayerHeadBoard:new(self.titleImgUrl,self.vTitleImg, self, self:GetRealmUrl())
		end 
	end
	if not mePos then 
		Debug('Error:CPlayer self:GetPos() is nil') return 
	else 
		self.headBorad:Update(self,showHp)
		if self.nameChanged then self.nameChanged = false end
		if self.guildNameChanged then self.guildNameChanged = false end
	end
end
function CPlayer:GetObjType()
	return enEntType.eEntType_Player;
end;

--伤害型跳字
function CPlayer:AddSkipNumber(noticeType, value)
	local noticeInfo = nil
	if self:IsSelf() then
		if ArenaBattle.inArenaScene ~= 0 then
			return
		end
		noticeInfo = NOTICE["self"][noticeType]
	else
		noticeInfo = NOTICE["other"][noticeType]
	end
	if not noticeInfo then
		return
	end
	local skipConfig = noticeInfo.skipConfig
	local text = noticeInfo.text
	local number = math.abs(value)
	local arrParam = {
		config = skipConfig,
		text = text,
		number = number,
	}
	self:GetAvatar():DrawSkipNumber(arrParam)
end

-------------------------------------------------------------------------------
local dis = _Vector2.new()
function CPlayer:AddMoveTo(fromX, fromY, toX, toY, speed)
    local dwNum = #self.setMoveActionList
	if dwNum == 0 then
		dis.x = toX
		dis.y = toY
		self:DoMoveTo(dis, nil, false, speed)
		return
	end
	local moveInfo = {}
	moveInfo.dwType = 1
	moveInfo.fXSrc = fromX
	moveInfo.fYSrc = fromY
	moveInfo.fXDis = toX
	moveInfo.fYDis = toY
	moveInfo.fSpeed = speed
	moveInfo.bUseCanTo = false
	table.insert(self.setMoveActionList, moveInfo)
	self:ExecMoveActionList()
end

function CPlayer:AddMoveStop(x ,y, dir)
	local dwNum = #self.setMoveActionList
	if dwNum == 0 then
		dis.x = x
		dis.y = y
		self:DoStopMove(dis, dir)
		return
	end
	local moveInfo = {}
	moveInfo.dwType = 2
	moveInfo.fXStop = x
	moveInfo.fYStop = y
	moveInfo.fDirValue = dir
	table.insert(self.setMoveActionList, moveInfo)
	self:ExecMoveActionList()
end

function CPlayer:ExecMoveActionList()
	local info = self.setMoveActionList[1]
	if info == nil then
		return
	end
	if self:IsMoveState() then
		return
	end
	if info.dwType == 1 then
		dis.x = info.fXDis
		dis.y = info.fYDis
		self:DoMoveTo(dis, onMoveDone, info.bUseCanTo, info.fSpeed)
	end
	if info.dwType == 2 then
		dis.x = info.fXStop
		dis.y = info.fYStop
		self:DoStopMove(dis, info.fDirValue)
	end
	table.remove(self.setMoveActionList, 1)
	function onMoveDone()
		self:ExecMoveActionList()
	end
end

--玩家属性信息，不包含外观数据
function CPlayer:GetPlayerInfo()
	return self.playerInfo
end

function CPlayer:GetPlayerInfoByType(type)
	local playerInfo = self:GetPlayerInfo()
	return playerInfo[type]
end

function CPlayer:SetPlayerInfoByType(type, value)
	local playerInfo = self:GetPlayerInfo()
    if enAttrTypeName[type] then
    	playerInfo[type] = value
	end
end

--获取玩家外观信息	
function CPlayer:GetPlayerShowInfo()
	return self.playerShowInfo
end

--创建玩家时初始化玩家基础信息
function CPlayer:InitPlayerInfo(info)
	local playInfo = self:GetPlayerInfo()
	if not playInfo then
		return
	end
	for ntype, value in pairs(info) do
		if AttrNameToAttrType[ntype] then
			playInfo[AttrNameToAttrType[ntype]] = value
		end 
    end
end

--更新玩家属性信息
function CPlayer:UpdatePlayerInfo(info)
	if not info then
        assert(false, "fuck")
		return
	end
	local playerInfo = self:GetPlayerInfo()
	if not playerInfo then
		assert(false, "fuck")
        return
	end
	for attrType, value in pairs(info) do
        if enAttrTypeName[attrType] and attrType ~= enAttrType.eaName then
        	local oldValue = playerInfo[attrType]
        	playerInfo[attrType] = value
        	if attrType == enAttrType.eaHp then
        		self:ShowAttrAdd(attrType, value, oldValue)
        	elseif attrType == enAttrType.eaMp then
        		self:ShowAttrAdd(attrType, value, oldValue)
        	elseif attrType == enAttrType.eaMaxHp then

        	elseif attrType == enAttrType.eaMoveSpeed then
				self:UpdateSpeed()
			elseif attrType == enAttrType.eaMultiKill then
				if self:IsSelf() then
					self:ShowMultiKill()
				end
			elseif attrType == enAttrType.eaPiLao then
				Notifier:sendNotification(NotifyConsts.CavePiLaoChange);
			elseif attrType == enAttrType.eaDominJingLi then
				Notifier:sendNotification(NotifyConsts.DominateRouteAddJingLi);
			elseif attrType == enAttrType.eaWashLucky then
				Notifier:sendNotification(NotifyConsts.EquipSeniorJinglianLacky);
			elseif attrType == enAttrType.eaLevel then
				if self.headBorad then
					self.headBorad:UpdateLevelTitleInfo(self);
				end
			end
        end
    end
end

function CPlayer:ShowAttrAdd(attrType, newValue, oldValue)
	if not self:IsSelf() then
		return
	end
	if not oldValue then
		return
	end
	if not newValue then
		return
	end
	local value = newValue - oldValue
	if value <= 0 then
		return
	end
	value = math.ceil(value)
	if attrType == enAttrType.eaHp then
		self:AddSkipNumber(enBattleNoticeType.HP_ADD, value)
	elseif attrType == enAttrType.eaMp then
		self:AddSkipNumber(enBattleNoticeType.MP_ADD, value)
	end
end

function CPlayer:ShowMultiKill()
	if _G.sceneTest then return end
	local kill_number = self:GetPlayerInfoByType(enAttrType.eaMultiKill)
	SkillController:MultiKill(kill_number)
end

--获取玩家名字
function CPlayer:GetName()
	return self:GetPlayerInfoByType(enAttrType.eaName)
end


--更新玩家速度
function CPlayer:UpdateSpeed()
	local speed = self:GetPlayerInfoByType(enAttrType.eaMoveSpeed)
	self:GetAvatar():UpdateSpeed(speed)
	if self:GetMagicWeaponFigure() then
		self:GetMagicWeaponFigure():UpdateSpeed(speed)
	end
	if self:GetLingQiFigure() then
		self:GetLingQiFigure():UpdateSpeed(speed)
	end
--	if self:GetMingYuFigure() then
--		self:GetMingYuFigure():UpdateSpeed(speed)
--	end
end

function CPlayer:GetSpeed()
	return self:GetPlayerInfoByType(enAttrType.eaMoveSpeed)
end

function CPlayer:GetMagicWeaponFigure()
	return self.magicWeaponFigure
end
function CPlayer:GetLingQiFigure()
	return self.lingQiFigure
end
function CPlayer:GetMingYuFigure()
	return self.mingYuFigure
end
function CPlayer:ClearTarget()
	if self.dwRoleID == SkillController:GetCurrTargetCid() then
		SkillController:ClearTarget()
	end
end

--处理player死亡
function CPlayer:Dead()
	if self:IsSelf() then
		MountController:RemoveRideMount()
		MainPlayerController:ClearPlayerState()

	else
		local cid = self:GetRoleID()
		CPlayerMap:OnPlayerMountChange(cid, 0)
	end
	if TransformController:HasTransform(self.dwRoleID) then
		--死亡直接卸载变身数据
		TransformController:RemoveTransform(self.dwRoleID, true)
	end
	self:ClearTimePlan()
	self:ClearTarget()
	self:DoStopMove()
	local avatar = self:GetAvatar()
	if avatar then
		avatar:StopAllPfx()
		avatar:StopAllAction()
		avatar.setSkipNormal = {}
		avatar:PlayDeadAction()
		if avatar.wingAvatar then --现在没有死亡动作 先停止所有动作
			avatar.wingAvatar:StopAllAction()
		end
		if self.xianjieModelid and self.xianjieModelid~=0 then
		--	avatar:RemovePendant(self.xianjieModelid); 
		end
		if self.xuanBingModelID and self.xuanBingModelID ~= 0 then
			avatar:RemovePendant(self.xuanBingModelID);
		end

	end
	self:ResetPfx()
    self:SetDead(true)
end

--处理player复活
function CPlayer:Revive(posX, posY)
	self:SetPos(posX, posY)
    self:InitStateInfo()
	self:SetDead(false)
	self:ResetWuhunPfx()
	local avatar = self:GetAvatar()
	if avatar then
		avatar:ExecIdleAction()
		if avatar.wingAvatar then --现在没有死亡动作 先停止所有动作
			avatar.wingAvatar:ExecDefAction()
		end
		if self.xianjieModelid and self.xianjieModelid~=0 then
			--avatar:AddPendant(self.xianjieModelid);
		end
		if self.xuanBingModelID and self.xuanBingModelID ~= 0 then
			avatar:AddPendant(self.xuanBingModelID);
		end
	end
end

--获取player buff信息 对应BuffInfo.lua
function CPlayer:GetBuffInfo()
	return self.buffInfo
end

function CPlayer:Stun()

end

function CPlayer:StopStun()
	
end

function CPlayer:SetBattleState(battleState)
	local oldBattleState = self.battleState
	if self:IsSelf() then
		if self.battleState ~= battleState then
			if battleState == true then
				FloatManager:AddUserInfo(StrConfig["skill10001"])
			else
				FloatManager:AddUserInfo(StrConfig["skill10002"])
			end
		end 
		self.battleState = battleState
	end
	if oldBattleState ~= battleState then
		self:GetAvatar():SetAttackAction(battleState)
	end
end

function CPlayer:PlayHurtPfx(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local pfx_hurt = skillConfig.pfx_hurt
    if pfx_hurt and pfx_hurt ~= "" then
    	self:GetAvatar():PlayPfxOnBone("beatpoint", pfx_hurt, pfx_hurt)
    end
    if not self:NoSfxState() then
	    local soundId = skillConfig.gethit_sound_id
	    if soundId and t_music[soundId] then
	   		SoundManager:PlaySkillSfx(soundId)
	   	end
	end
end

function CPlayer:PlayHurtLight()

end

function CPlayer:IsPunish()
	local avatar = self:GetAvatar()
	if avatar.jumpState then
		return false
	end
	if avatar.flyState then
		return false
	end
	if avatar.rollState then
		return false
	end
	if avatar.knockBackState then
		return false
	end
	if avatar.stoneGazeState then
		return false
	end
	return true
end

function CPlayer:IsChanState()
	local avatar = self:GetAvatar()
	return (avatar.chanState ~= ChanSkillState.StateInit)
end

function CPlayer:IsPrepState()
	local avatar = self:GetAvatar()
	return (avatar.prepState ~= 0)
end

function CPlayer:IsDead()
	if self.isDead then
		return true
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_DEAD) == 1 then
		return true
	end
	return false
end

function CPlayer:InTransforming()
	return self:GetStateInfoByType(PlayerState.UNIT_BIT_BIANSHEN) == 1;
end

function CPlayer:SetDead(isDead)
	self.isDead = isDead
	local avatar = self:GetAvatar()
	if avatar then
		avatar.isDead = isDead
	end
end

function CPlayer:GetGuildId()
	return self.guildId
end
function CPlayer:SetPendantModelId(xianjieModelid)
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		xianjieModelid = 0
	end
   self.xianjieModelid = xianjieModelid
   local avatar = self:GetAvatar()
   if avatar then
   		avatar:SetPendantModelId(self.xianjieModelid)
   end
end
function CPlayer:SetXuanBingModelId(xuanBingModelID)
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		xuanBingModelID = 0
	end
	self.xuanBingModelID = xuanBingModelID
	local avatar = self:GetAvatar()
	if avatar then
		avatar:SetXuanBingModelId(self.xuanBingModelID)
	end
end
function CPlayer:SetGuildId()
	self.guildId = guildId
end

function CPlayer:GetGuildName()
	return self.guildName
end

function CPlayer:SetGuildName(guildName)
	self.guildName = guildName
end

function CPlayer:GetTeamId()
	
end

function CPlayer:GetWuhun()
	local wuhunId = 0
	if self.dwRoleID == MainPlayerController:GetRoleID() then
		wuhunId = SpiritsModel:GetFushenWuhunId()
	else
		wuhunId = self.wuhunId
	end
	return wuhunId
end

function CPlayer:SetWuhun(wuhunId)
	self.wuhunId = wuhunId
end

function CPlayer:PlaySkill(skillId, targetCid, targetPos)
	if TianShenController:PlaySkill(self,skillId, targetCid, targetPos) then
		return;
	end
	
	self:GetAvatar():PlaySkill(skillId, targetCid, targetPos)
	if self:IsSelf() then
		self:GetAvatar():PlaySkillSound(skillId)
	end
end

function CPlayer:StartSit()
	if self.sitting == true then
		self:StopSit()
	end
	local pfxId = self:GetSitPfxId()
	self:GetAvatar():PlaySitAction()
	self:GetAvatar():PlayerPfx(pfxId)
	self.sitting = true
end


function CPlayer:StopSit()
	if not self:GetAvatar() then
		return
	end
	if not self.sitting then
		return
	end
	local pfxId = self:GetSitPfxId()
	self:GetAvatar():StopSitAction()
	self:GetAvatar():StopPfx(pfxId)
	self.sitting = false
end

function CPlayer:GetSitPfxId()
	return SitController:IsInSitArea(self:GetRoleID()) and 10026 or 10009
end

function CPlayer:IsInSitArea()
	return SitController:IsInSitArea(self:GetRoleID())
end

function CPlayer:UpdateSitAreaPfx()
	if self.sitting == true 
		or not self:IsInSitArea()
		or StoryController:IsStorying() then
		self:StopSitAreaPfx()
	else
		self:StartSitAreaPfx()
	end
end

function CPlayer:StartSitAreaPfx()
	if not self.isSitAreaPfx then
		local horse = self:GetHorse()
		if horse then
			horse:PlayerPfx(10027)
		else
			self:GetAvatar():PlayerPfx(10027)
		end
		self.isSitAreaPfx = true
	end
end

function CPlayer:StopSitAreaPfx()
	if self.isSitAreaPfx then
		self:GetAvatar():StopPfx(10027)
		local horse = self:GetHorse()
		if horse then
			horse:StopPfx(10027)
		end
		self.isSitAreaPfx = false
	end
end

function CPlayer:ResetSitAreaPfx()
	if self.isSitAreaPfx then
		self:GetAvatar():StopPfx(10027)
		local horse = self:GetHorse()
		if horse then
			horse:StopPfx(10027)
			horse:PlayerPfx(10027)
		else
			self:GetAvatar():PlayerPfx(10027)
		end
	end
end

function CPlayer:SetSitInfo(sitId, sitIndex)
	self.sitInfo = {sitId = sitId, sitIndex = sitIndex}
end

function CPlayer:SetSitState(sitId, sitIndex)
	if not self.sitState then
		self.sitState = {id = 0, index = 0}
	end
	local sitState = {id = sitId, index = sitIndex}

	SitController:SetSitList(self:GetRoleID(), self.sitState, sitState)
	
	self.sitState = sitState
	local avatar = self:GetAvatar()
	if avatar then
		avatar.sitState = sitState
	end

	if not sitState or sitState.id == 0 then
		self:StopSit()
	else
		self:StartSit()
	end
end

function CPlayer:GetSitState()
	return self.sitState
end

function CPlayer:IsSitState()
	local sitState = self:GetSitState()
	if not sitState then
		return false
	end
	if sitState.id == 0 then
		return false
	end
	return true
end

function CPlayer:IsMoveState()
	return self:GetAvatar().moveState
end

function CPlayer:IsSkillPlaying()
	return self:GetAvatar().skillPlaying
end

function CPlayer:IsOnHorse()
	return self:GetAvatar():GetHorse()
end

function CPlayer:Leisure()
	local nowTime = GetCurTime()
	if not self:IsLeisureState() then
		self.leisureTime = nowTime
		-- self:StopLeisureAction()
	else
		if self.leisureTime and nowTime - self.leisureTime > _G.ROLE_XIUXIAN_GAP + self.randomLeisureTime then
			self:DoLeisureAction()
			self.leisureTime = nowTime
		end
	end
end

function CPlayer:UpdateBuff(interval)
	local buffInfo = self:GetBuffInfo();
	if buffInfo then
		buffInfo:Update(interval);
	end
end

function CPlayer:DoLeisureAction()
	self:GetAvatar():PlayLeisureAction()
end

function CPlayer:StopLeisureAction()
	self:GetAvatar():StopLeisureAction()
end

function CPlayer:IsLeisureState()
	if not self:GetAvatar() then
		return false
	end
	if self:IsDead() then
		return false
	end
	if not self:IsPunish() then
		return false
	end
	if self.isEatOnland  then    --正在地上吃饭状态下是不允许进入休闲状态
		return false
	end
	if self.isEatOnDesk  then    --正在桌边吃饭状态下是不允许进入休闲状态
		return false
	end
	if self:IsChanState() then
		return false
	end
	if self:IsPrepState() then
        return false
    end
    if self:IsMoveState() then
		return false
	end
	if self:IsSitState() then
		return false
	end
	-- if self:GetStateInfoByType(PlayerState.UNIT_BIT_GOD) == 1 then
	-- 	return false
	-- end
	-- if self:GetStateInfoByType(PlayerState.UNIT_BIT_INCOMBAT) == 1 then
	-- 	return false
	-- end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then
		return false
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_PALSY) == 1 then
		return false
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_HOLD) == 1 then
		return false
	end	
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_STUN) == 1 then
		return false
	end	
	if StoryController:IsStorying() then
		return false
	end 
	if GameController.loginState then
		return false
	end
	if CPlayerMap.bChangeMaping == true then
		return false
	end
	if CPlayerMap.changePosState == true then
		return false
	end
	if CPlayerMap.changeLineState == true then
		return false
	end
	if ArenaBattle.inArenaScene ~= 0 then
		return false
	end
	if self:IsSelf() then
		if MainPlayerController.standInState then
			return false
		end
	end
	return true
end

function CPlayer:GetStateInfo()
	return self.stateInfo
end

function CPlayer:GetStateInfoByType(stateType)
	return self.stateInfo:GetValue(stateType)
end
--玩家称号改变 self.titleInfo 已在身上穿戴的所有称号
--titleId替换掉self.titleInfo内一穿戴相同组的称号
function CPlayer:SetTitleInfo(titleId)
	for i , v in pairs(self.titleInfo) do
		if t_title[v] then
			if t_title[v].type == t_title[titleId].type then
				self.titleInfo[i] = titleId;
				self:SetTitleUrl();
				return;
			end
		end
	end
	self.titleInfo[t_title[titleId].type] = titleId;
	--table.push(self.titleInfo,titleId); --如果没有此类型称号  添加一个
	self:SetTitleUrl();
end
--玩家称号删除
function CPlayer:SetDeleteTitleInfo(titleId)
	if self:IsSelf() then
		self.headBorad:OnChangeTitleSWF(TitleModel:GetNowTitleImg(), self)
	else
		for i , v in pairs(self.titleInfo) do
			if v == titleId then
				self.titleInfo[i] = 0;
				self:SetTitleUrl();
				break;
			end
		end
	end
end
--更换玩家PK状态
function CPlayer:SetPKState(pkStateIndex)
	if pkStateIndex == 0 then
		self.pkColorState = 0;
	elseif pkStateIndex == 2 then 	--红名
		self.pkColorState = 2;
	elseif pkStateIndex == 3 then 	--灰名
		self.pkColorState = 1;
	end
	if self:IsSelf() then 
		MainRolePKModel.pkState = pkStateIndex;
	else
		self.pkState = pkStateIndex;
	end
end

--V标识
function CPlayer:SetVTitle(vflag)
	-- self.vflag = vflag;
	-- self.vTitleImg = nil;
	-- self:SetVTitleURl(self:GetVTitle());
end

--获取图片路径
function CPlayer:SetVTitleURl(vflag)
	if not self.headBorad then
		return
	end
	self.vTitleImg =  ResUtil:GetVIcon(vflag);
	self.headBorad:OnChangeVTitle(self:GetVTitleURL());
end

function CPlayer:GetVTitle()
	return self.vflag;
end

function CPlayer:GetVTitleURL()
	return self.vTitleImg;
end

function CPlayer:GetLovelyPet()
	return self.lovelypet;
end

--境界图标
function CPlayer:SetRealm(id)
	self.realm = id;
	if self.realm < 1 then
		return 
	end
	self:SetRealmUrl(self:GetReolm());
end

function CPlayer:SetRealmUrl(id)
	if not self.headBorad or id < 1 then
		return
	end
	self.realmUrl = ResUtil:GetRealmIcon(id)
	self.headBorad:OnChangeRealmIcon(self:GetRealmUrl())
end

function CPlayer:GetReolm()
	return self.realm;
end

function CPlayer:GetRealmUrl()
	return self.realmUrl;
end

function CPlayer:SetLovelyPet(lovelypet)
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		self.lovelypet = 0
		return
	end
	self.lovelypet = lovelypet;
end

function CPlayer:GetPKState(pkStateIndex)
	if self:IsSelf() then 
		return MainRolePKModel.pkState;
	else
		return self.pkState;
	end
end

function CPlayer:SetUbit(ubit)
	if not ubit then
		return
	end
	-- if self:IsDead() then
	-- 	return
	-- end
   	local stateInfo = self:GetStateInfo()
   	for i = 1, 32 do
   		local stateType = i
   		local bitNumber = math.pow(2, i)
   		local stateValue = bit.band(ubit, bitNumber) == bitNumber and 1 or 0
   		stateInfo:SetValue(stateType, stateValue)
   		if stateType == PlayerState.UNIT_BIT_MIDNIGHT then
			self:SetNightState(stateValue)
		elseif stateType == PlayerState.UNIT_BIT_AI_LOCKED then
			self:SetLockedState(stateValue)
		end
   	end
end

function CPlayer:ClearTimePlan()
	if self.battleTimer then
		TimerManager:UnRegisterTimer(self.battleTimer)
	end
	self.battleTimer = nil
	local avatar = self:GetAvatar()
	if avatar then
		if avatar.jumpOnHorseTime then
			TimerManager:UnRegisterTimer(avatar.jumpOnHorseTime)
		end
		if avatar.jumpTime then
			TimerManager:UnRegisterTimer(avatar.jumpTime)
		end
		if avatar.rollOnHorseTime then
			TimerManager:UnRegisterTimer(avatar.rollOnHorseTime)
		end
		if avatar.rollTime then
			TimerManager:UnRegisterTimer(avatar.rollTime)
		end
		if avatar.prepOnUITime then
			TimerManager:UnRegisterTimer(avatar.prepOnUITime)
		end
		if avatar.chanOnUITime then
			TimerManager:UnRegisterTimer(avatar.chanOnUITime)
		end
		if avatar.prepOnArenaTime then
			TimerManager:UnRegisterTimer(avatar.prepOnArenaTime)
		end
		if avatar.chanOnArenaTime then
			TimerManager:UnRegisterTimer(avatar.chanOnArenaTime)
		end
		if avatar.trapOnArenaTime then
			TimerManager:UnRegisterTimer(avatar.trapOnArenaTime)
		end
		if avatar.trapTime then
			TimerManager:UnRegisterTimer(avatar.trapTime)
		end
		if avatar.multiOnUITime then
			TimerManager:UnRegisterTimer(avatar.multiOnUITime)
		end
		if avatar.multiOnArenaTime then
			TimerManager:UnRegisterTimer(avatar.multiOnArenaTime)
		end
		if avatar.multiTime then
			TimerManager:UnRegisterTimer(avatar.multiTime)
		end
		avatar.jumpOnHorseTime = nil
		avatar.jumpTime = nil
		avatar.rollOnHorseTime = nil
		avatar.rollTime = nil
		avatar.prepOnUITime = nil
		avatar.chanOnUITime = nil
		avatar.prepOnArenaTime = nil
		avatar.chanOnArenaTime = nil
		avatar.trapOnArenaTime = nil
		avatar.trapTime = nil
		avatar.multiOnUITime = nil
		avatar.multiTime = nil
		avatar.multiOnArenaTime = nil
	end
end

function CPlayer:InitStateInfo()
	self.stateInfo = StateInfo:new()	
end

function CPlayer:InitBuffInfo()
	BuffController:ClearAllBuffByCid(self:GetRoleID())
	self.buffInfo = BuffInfo:new()
end

-- 开始巡逻
function CPlayer:SetPatrol(patrolData, patrolIndex)
	if not self.PatrolController then
		self.PatrolController = PatrolController:New(self, patrolData)
	end
	
	self.PatrolController:SetRun(patrolIndex)
end

--改变灵值
function CPlayer:SetLingZhi(num)
	self.lingzhi = num;
	self.lingzhiLevel = UIBeicangjieInfo:NumORLeve(num);
end

--获取灵值
function CPlayer:GetLingZhi()
	return self.lingzhi;
end

function CPlayer:GetLingzhiLevel()
	return self.lingzhiLevel;
end

--改变阵营
function CPlayer:SetCamp(num)
	self.camp = num;
end

function CPlayer:GetCamp()
	return self.camp;
end

function CPlayer:GetProf()
	return self:GetPlayerInfoByType(enAttrType.eaProf)
end

function CPlayer:GetDefSkillId()
	local prof = self:GetProf()
	return RoleConfig.ProfConfig[prof] and RoleConfig.ProfConfig[prof].dwSkillId or 0
end

--改变午夜PK
function CPlayer:SetNightState(num)
	self.nightState = (num == 1);
end

function CPlayer:GetNightState()
	return self.nightState;
end

function CPlayer:SetLockedState(num)
	local locked = num == 1;
	if locked and self.lockedState then
		return;
	end
	
	self.lockedState = locked;
	local avatar = self:GetAvatar();
	if not avatar then
		return
	end
	
	if locked then
		avatar:PlayerPfxOnSkeleton("v_player_xuanzhong.pfx");
	else
		avatar:StopPfxByName("v_player_xuanzhong.pfx");
	end

end

function CPlayer:GetLockedState()
	return self.lockedState;
end

function CPlayer:IsSafeArea()
	local pos = self:GetPos()
	if not pos then
		return false
	end
	local x, y = pos.x, pos.y
	local camp = self:GetCamp()
    local mapId = CPlayerMap:GetCurMapID()
    if not mapId then
    	return false
    end
    local mapInfo = t_map[mapId]
    if not mapInfo then
    	return false
    end
    local safeareaConfig = mapInfo.safearea
    if not safeareaConfig or safeareaConfig == "" then
    	return false
    end
    if mapInfo.safearea_type == 0 then
    	local list = GetPoundTable(safeareaConfig)
        for i = 1, #list do
            local point = list[i]
            local pointTable = GetCommaTable(point)
            local campConfig = tonumber(pointTable[1])
            if camp == campConfig or campConfig == 0 then
	            local x1, y1 = tonumber(pointTable[2]), tonumber(pointTable[3])
	            local x2, y2 = tonumber(pointTable[4]), tonumber(pointTable[5])
	            if ((x1 > x and x2 < x) or (x1 < x and x2 > x))
	            	and ((y1 > y and y2 < y) or (y1 < y and y2 > y)) then
	            	return true
	            end
	        end
        end
	elseif mapInfo.safearea_type == 1 then
		local list = GetPoundTable(safeareaConfig)
        for i = 1, #list do
            local point = list[i]
            local pointTable = GetCommaTable(point)
            local campConfig = tonumber(pointTable[1])
            if camp == campConfig or campConfig == 0 then
	            local pos1 = {x = tonumber(pointTable[2]), y = tonumber(pointTable[3])}
	            local pos2 = {x = tonumber(pointTable[4]), y = tonumber(pointTable[5])}
	            local pos3 = {x = tonumber(pointTable[6]), y = tonumber(pointTable[7])}
	            local pos4 = {x = tonumber(pointTable[8]), y = tonumber(pointTable[9])}
	            local pos5 = {x = x, y = y}
	            if IsContain(pos1, pos2, pos3, pos4, pos5) then
	            	return true
	            end
	        end
        end
	end

    return false
end

-- isHide 隐藏掉自己 显示自己 
function CPlayer:HideSelf(isHide)
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	if isHide then
		self.isShowHeadBoard = false
		avatar.objNode.visible = false
	else
		self.isShowHeadBoard = true
		avatar.objNode.visible = true
	end
end

function CPlayer:ShowNPCGuild()
	--[[if not self.canShowNPCGuild then return; end

	local cid = self:GetRoleID()
	if MainPlayerController:GetRoleID() ~= cid then
		return;
	end

	if self.npcGuild then
		return;
	end
	local pos = self:GetPos()
	if not pos then return; end
	local x = pos.x + math.random(5, 10)
	local y = pos.y + math.random(5, 10)
	self.npcGuild = NpcGuildAvatar:Create()
	self.npcGuild:EnterMap(x, y)
	self.npcGuild.ownerId = cid
	if MainPlayerController:GetRoleID() == cid then
		self.npcGuild.dnotDelete = true
	end]]
end

function CPlayer:HideNPCGuild()
	--[[self.canShowNPCGuild = false;
	if self.npcGuild then
		self.npcGuild:ExitMap();
		self.npcGuild = nil
	end]]
end

function CPlayer:GetNpcGuild()
	return self.npcGuild;
end

function CPlayer:NpcGuildTalk(str, duration)
	--[[local content = str;
	if content == "" then return; end
	if not self:GetNpcGuild() then
		UINpcGuildChat:Hide();
		return;
	end
	UINpcGuildChat:Set(content, self:GetNpcGuild(), duration);]]
end

function CPlayer:DoNpcGuildMoveToPos(pos)
	--[[if not self:GetNpcGuild() then return; end
	if not pos then return; end
	self:GetNpcGuild():DoMoveTo(pos);]]
end
function CPlayer:DoNpcGuildMoveToPosAttack(pos)
	--[[if not self:GetNpcGuild() then return; end
	if not pos then return; end
	self:GetNpcGuild():DoMoveTo(pos, nil, true);]]
end

function CPlayer:SetPetModelId(modelId)
	if GameController.loginState then
		return
	end

	if not modelId or modelId == 0 then
		if self.pet then
			self.pet:ExitMap()
			self.pet = nil
		end
		return
	end
	
	if self.pet then
		self.pet:ExitMap()
		self.pet = nil
	end
	local pos = self:GetPos()
	local x = pos.x + math.random(5, 10)
	local y = pos.y + math.random(5, 10)
	local cid = self:GetRoleID()
	self.pet = LovelyPetAvatar:Create(modelId)
	self.pet:EnterMap(x, y)
	self.pet.ownerId = cid
	if MainPlayerController:GetRoleID() == cid then
		self.pet.dnotDelete = true
	end

end



function CPlayer:SetWingModel(modelId)
	local roleAvatar = self:GetAvatar()
	if not roleAvatar then
		return
	end
	roleAvatar:SetWingModel(modelId)
end

function CPlayer:SetWingId(wingId)
	self.wing = wingId
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		wingId = 0
	end
	
	if self.objAvatar then
		self.objAvatar:SetWingModel(wingId);
	end
end

function CPlayer:GetWingId()
	return self.wing
end

function CPlayer:PlayHeti()
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	local wuhunId = self:GetWuhun()
	local pfx = SpiritsController:GetHetiPfx(wuhunId)
	if pfx and pfx ~= "" then
		avatar:PlayHetiAction()
		avatar:PlayerPfxOnSkeleton(pfx)
	end
end

--该状态下不播放音效
function CPlayer:NoSfxState()
	if ArenaBattle.inArenaScene ~= 0 then
		return true
	end
	return false
end

function CPlayer:DoStopMove(pos, dir)
	self:GetAvatar():DoStopMove(pos, dir)
	if self.pet then
		self.pet:DoStopMove(pos, dir)
	end
end

function CPlayer:DoMoveTo(pos, callback, bUseCanTo, speed, dwDis)
	self:GetAvatar():DoMoveTo(pos, callback, bUseCanTo, speed, dwDis)
	if self.pet then
		self.pet:DoMoveTo(pos, speed, dwDis)
	end
end

function CPlayer:GetScale()
	return self:GetAvatar():GetScale()
end

function CPlayer:SetScale(scaleValue)
    local avatar = self:GetAvatar()
	if avatar then
		avatar:SetScale(scaleValue)
	end
end

function CPlayer:SetPickNull()
    local avatar = self:GetAvatar()
	if avatar then
		avatar.pickFlag = enPickFlag.EPF_Null
	end
end

function CPlayer:IsPickNull()
	local avatar = self:GetAvatar()
	if avatar
		and avatar.pickFlag ~= enPickFlag.EPF_Null then
		return true
	end
	return false
end

function CPlayer:ResetWuhunPfx()
	local wuhunId = self:GetWuhun()
	local avatar = self:GetAvatar()
	local prof = self:GetPlayerInfoByType(enAttrType.eaProf)
	local roleId = self:GetRoleID()
	SpiritsUtil:SetWuhunPfx(roleId, wuhunId, avatar, prof)
end

function CPlayer:RemoveWuhunPfx()
	local wuhunId = self:GetWuhun()
	local avatar = self:GetAvatar()
	local prof = self:GetPlayerInfoByType(enAttrType.eaProf)
	SpiritsUtil:RemoveWuhunFushengPfx(wuhunId, prof, avatar)
end

function CPlayer:GetEquipGroup()
	return self.suitflag or 0
end

function CPlayer:SetEquipGroup(suitflag)
	self:ChangeEquipGroup(suitflag)
	self.suitflag = suitflag
end

function CPlayer:ChangeEquipGroup(newId)
	local oldId = self:GetEquipGroup()
	local avatar = self:GetAvatar()
	avatar:ChangeEquipGroup(oldId, newId)
end

function CPlayer:ResetEquipGroup()
	local oldId = self:GetEquipGroup()
	local newId = self:GetEquipGroup()
	local avatar = self:GetAvatar()
	avatar:ChangeEquipGroup(oldId, newId)
end

function CPlayer:ResetPfx()
	self:ResetWuhunPfx()
	self:ResetEquipGroup()
	self:ResetEquipPfx()
	self:ResetShenwuPfx()
end

function CPlayer:HidePet()
	local pet = self.pet
	if pet then
		if pet.objNode then
			pet.objNode.visible = false
		end
	end
end

function CPlayer:ShowPet()
	local pet = self.pet
	if pet then
		if pet.objNode then
			pet.objNode.visible = true
		end
	end
end

function CPlayer:IsShowName()
	if not self.isShowHeadBoard then
		return false
	end

	if not CPlayerControl.showName then
		return false
	end

	if not self:IsSelf() and SetSystemController.hidePlayerName then
		return false
	end

	local cid = self:GetCid()
	if not cid then 
		return false
	end

	if not self:IsSelf() 
		and not SetSystemController.hidePlayerName 
		and not SetSystemController.renderList[cid]
		and SetSystemController.showPlayerNumber ~= 0
		and not SetSystemController.showAllPlayer then
		return false
	end

	return true
end

function CPlayer:ResetEquipPfx()
	local avatar = self:GetAvatar()
	avatar:ResetEquipPfx()
end

function CPlayer:SetFootprints(footprints)
	local avatar = self:GetAvatar()
	self.footprints = footprints
	local prof = self:GetProf()
	local pfx = nil
	if footprint_pfx[footprints] then
		pfx = footprint_pfx[footprints][prof]
	end
	if pfx then
		avatar:SetFootprintPfx(nil)
		avatar:SetFootprintPfx(pfx)
	else
		avatar:SetFootprintPfx(nil)
	end
end

function CPlayer:ResetWing()
	self:SetWingModel(0)
	self:SetWingModel(self:GetWingId())
end

function CPlayer:SetTreasure(treasure)
	self.treasure = treasure
end

function CPlayer:GetTreasure()
	return self.treasure
end

function CPlayer:SetServerId(serverId)
	self.serverId = serverId
end

function CPlayer:GetServerId()
	return self.serverId
end

function CPlayer:SetPartnerName(partnerName)
	self.partnerName = partnerName
end

function CPlayer:GetPartnerName()
	return self.partnerName
end

function CPlayer:SetShenwuId(shenwuId)
	self:ChangeShenwuPfx(shenwuId)
	self.shenwuId = shenwuId
end

function CPlayer:GetShenwuId()
	return self.shenwuId or 0
end

function CPlayer:ChangeShenwuPfx(newId)
	local oldId = self:GetShenwuId()
	local avatar = self:GetAvatar()
	avatar:ChangeShenwuPfx(oldId, newId)
end

function CPlayer:ResetShenwuPfx()
	local avatar = self:GetAvatar()
	avatar:ResetShenwuPfx()
end

function CPlayer:AddPendant(id)
	local avatar = self:GetAvatar()
	avatar:AddPendant(id)
end
function CPlayer:RemovePendant(id)
	local avatar = self:GetAvatar()
	avatar:RemovePendant(id)
end
function CPlayer:SetTransform(model)
end

function CPlayer:SetTransformState(state,immediately)
	self.transform = state and TransformController or nil;
	local avatar = self:GetAvatar();
	avatar.transform = state and TransformController or nil;
	if immediately then
		self:UpdateAvatar();
	end
end

function CPlayer:UpdateAvatar()
	local avatar  = self:GetAvatar();
	local prof = self.playerInfo[enAttrType.eaProf];
	avatar:Create(self.dwRoleID,prof);
	if not self.transform then
		self:UpdateShowEquip();
	end
end

function CPlayer:SetEquipsActState(state)
	local avatar = self:GetAvatar();
	if not avatar then
		return;
	end
	avatar:SetEquipActState(state);
end

------------------------------------------------
------------------------------------------------

--将玩家绑定在椅子上
function CPlayer:SitChair(chair,sitting)
	if not chair then
		return;
	end
	local cAvatar = chair:GetAvatar();
	if not cAvatar then
		return;
	end

	local pAvatar = self:GetAvatar();
	if not pAvatar then
		return;
	end

	local mat = _Matrix3D.new();
	mat.parent = cAvatar.objNode.transform;
	--mat.ignoreRotation = true;
	pAvatar.objNode.transform:set(mat);
end

-- 设置吃饭的状态 1 地上吃饭  2 桌边吃饭
function CPlayer:SetLunchState( type)
	self.EatLunchType = type;
end

-- 其它玩家进入视野
function CPlayer:EatLunch( )
	if self.EatLunchType == "0_0" then         -- 进入视野没在吃饭
		if self.isEatOnDesk then
			self:StopZhuoBianEat()
		end
		if self.isEatOnland then
			self:StopLandEat()
		end
	elseif self.EatLunchType == "0_1" then     --地上吃饭
		self:StartLandEat()
	else
		local chair = CollectionController:GetCollection(self.EatLunchType);  --桌边吃饭
		self:SitChair(chair)
		self:StartZhuoBianEat()
	end
end

--adder:houxudong  date:2016/8/10 22:15:23
--开始桌边吃饭
function CPlayer:StartZhuoBianEat()
	-- if self.isEatOnDesk then
	-- 	return
	-- end
	if not self:GetAvatar() then
		return
	end
	self:GetAvatar():PlayZhuoBianEatAction()
	self.isEatOnDesk = true
	local cfg = t_consts[311]
	if not cfg then return; end
	local avatar = self:GetAvatar()
	if avatar then
		avatar:AddEquip(cfg.val1,true)
		avatar:AddEquip(cfg.val2,true)
	end
end

--停止桌边吃饭
function CPlayer:StopZhuoBianEat()
	-- if self.isEatOnDesk == false then
	-- 	return;
	-- end
	self.isEatOnDesk = false;
	if not self:GetAvatar() then
		return
	end
	self:GetAvatar():StopZhuoBianEatAction()
	local avatar = self:GetAvatar()
	local cfg = t_consts[311]
	if not cfg then return; end
	if avatar then
		avatar:RemoveEquip(cfg.val1)
		avatar:RemoveEquip(cfg.val2)
	end
end

--获取桌边吃饭的状态
function CPlayer:GetEatonChairState()
	return self.isEatOnDesk;
end

--开始地上吃饭
function CPlayer:StartLandEat()
	if self.isEatOnland then
		return
	end
	if not self:GetAvatar() then
		return
	end
	self:GetAvatar():PlayLandEatAction()
	self.isEatOnland = true
	local cfg = t_consts[311]
	if not cfg then return; end
	local avatar = self:GetAvatar()
	if avatar then
		avatar:AddEquip(cfg.val1,true)
		avatar:AddEquip(cfg.val2,true)
	end
end

--停止地上吃饭
function CPlayer:StopLandEat()
	-- if self.isEatOnland == false then
	-- 	return;
	-- end
	self.isEatOnland = false
	if not self:GetAvatar() then
		return
	end
	self:GetAvatar():StopLandEatAction()
	local cfg = t_consts[311]
	if not cfg then return; end
	if avatar then
		avatar:RemoveEquip(cfg.val1)
		avatar:RemoveEquip(cfg.val2)
	end
end

--获取地上吃饭的状态
function CPlayer:GetEatonLandState()
	return self.isEatOnland;
end

--进入大摆筵席活动时干掉仙界(如果他有的话)
function CPlayer:KillXianJie()
	local avatar = self:GetAvatar()
	if avatar then
		if self.xianjieModelid and self.xianjieModelid~=0 then
			--avatar:RemovePendant(self.xianjieModelid); 
		end
		if self.xuanBingModelID and self.xuanBingModelID~=0 then
			avatar:RemovePendant(self.xuanBingModelID);
		end
	end
end

--退出大摆筵席活动时复活仙界(如果他有的话)
function CPlayer:ReBornXianJie()
	local avatar = self:GetAvatar()
	if avatar then
		if self.xianjieModelid and self.xianjieModelid~=0 then
			--avatar:AddPendant(self.xianjieModelid); 
		end
		if self.xuanBingModelID and self.xuanBingModelID~=0 then
			avatar:AddPendant(self.xuanBingModelID);
		end
	end
end

--进入大摆筵席活动时干掉翅膀(如果他有的话)
function CPlayer:KillChiBang()
	local avatar = self:GetAvatar()
	if avatar then
		avatar:SetWingModel(0);
	end
end

--进入大摆筵席活动时穿上翅膀(如果他有的话)
function CPlayer:ReBornChiBang()
	local avatar = self:GetAvatar()
	if avatar then
		avatar:SetWingModel(self:GetWingId());
	end
end

function CPlayer:KillPet( )
	self:SetPetModelId(0)
	self:SetLovelyPet(0)
	self:HidePet()
end

function CPlayer:OnHideTianShen( )
	local tianshenAvatar = self.tianshen
	if tianshenAvatar and tianshenAvatar.objNode then
		tianshenAvatar.objNode.visible = false
	end
end

function CPlayer:SetTianshenId(id,star,lv,color)
	self.tianshenId = id;
	self.tianshenStar = star;
	self.tianshenLv = lv;
	self.tianshenColor = color;
	if not self.objAvatar:IsInMap() then return end;
	local avatar  = TianShenController:CreateFollowTianshen(self);
	
	if avatar and not avatar:IsInMap() then
		local Pos = self.objAvatar:GetPos();
		local fDirValue = self.objAvatar:GetDirValue();
		avatar:EnterMap(CPlayerMap.objSceneMap,Pos.x,Pos.y,fDirValue);
	end
end

function CPlayer:GetTianshenId()
	self.tianshenId = self.tianshenId or 0;
	return self.tianshenId;
end
------------------------------------------------
------------------------------------------------