local CWarrior = class("CWarrior", CObject, CBindObjBase)
define.Warrior = 
{	Event_BeginHit = 1,
	Event_Hurt = 2,
	Event_EndHit = 3,
	Run_Speed = 10,
	BindObjs = {
		warrior_replace = {hud="CWarriorReplaceHud", body="head", type="hud"},
		warrior_order = {hud="CWarriorOrderHud", body="waist", type="hud"},
		warrior_tip = {path="Effect/Game/game_eff_1001/Prefabs/game_eff_1001.prefab",
						body="foot", type="effect", offset=Vector3.New(0, 0, 0),cached= true},
		warrior_select = {path="Effect/Game/game_eff_1002/Prefabs/game_eff_1002.prefab",
						body="waist", type="effect", offset=Vector3.New(0, -0.1, 0),cached= true},
		light = {path="Effect/Game/game_eff_1005/Prefabs/game_eff_1005.prefab",
						body="foot", offset=Vector3.New(0, 0, 0), type="effect"},
		warrior_skill = {hud="CWarriorMagicHud", body="head", type="hud"},
		warrior_jihuo = {hud="CWarriorJiHuoHud", body="waist", type="hud"},
		warrior_addsp = {hud="CWarriorAddSpHud", body="waist", type="hud"},
		warrior_command = {hud="CWarriorCommandHud", body="waist", type="hud"},
		warrior_lock = {hud="CWarriorLockHud", body="waist", type="hud"},
		warrior_level = {hud="CLevelHud", body="head", type="hud"},
		guideTipsHud = {hud = "CGuideTipsHud", body="foot", offset=Vector3.New(0, 20, 0), type="hud"},
	},
	Type = {
		Player = 1,
		Npc = 2,
		Partner = 4,
		OfflinePlayer = 5,  --离线玩家
		OfflinePartner = 6, --离线伙伴
	},
	NpcWarriorType = {
		Normal = 0,
		Boss = 1,
	},
}
CWarrior.g_TestActorID = nil

function CWarrior.ctor(self, wid)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/Warrior.prefab")
	CObject.ctor(self, obj)
	CBindObjBase.ctor(self, obj)
	self.m_IsWarrior = true
	self.m_IsIgnoreTimescale = false
	self:SetBindData(define.Warrior.BindObjs)
	self.m_RotateObj = CObject.New(self:Find("rotate_node").gameObject)
	self.m_ID = wid --战士ID
	self.m_Pid = nil
	self.m_CampID = nil
	self.m_CampPos = nil
	self.m_OwnerWid = nil
	self.m_Type = nil --战士类型
	self.m_IsAlly = nil
	self.m_PartnerID = nil
	self.m_Speed = 0
	self.m_Name = ""
	self.m_Level = 0
	self.m_EventState = {}
	self.m_BusyFlags = {}
	self.m_BoutVary = {} -- 当前回合状态的改变
	self.m_OriginPos = Vector3.zero
	self.m_Status = {}
	self.m_Buffs = {}
	self.m_DontHitBuffs = {}
	self.m_MagicCD = {}
	self.m_IsAlive = true
	self.m_IsOrderTarget = false
	self.m_MagicAndLevelList = {}
	self.m_MagicList = {}
	self.m_IsOrderDone = false
	self.m_IsJiHuo = false
	self.m_CheckErrBout = nil
	self.m_IsCanTouch = true
	self.m_NpcSpSkill = nil --skill_id, sum_grid, cur_grid
	self.m_NpcWarriorType = nil -- npc战斗类型 0普通怪 1boss
	self.m_DizzyBuffs = {}
	self.m_ShowSkills = nil --显示技能
	self.m_LockHide = false --锁定隐藏 
	self.m_HitInfo = {timer=nil, stand=0, step=0, goback = false, begin_pos=nil}
	-- self.m_ShadowObj = CObject.New(self:Find("shadow").gameObject)
	-- self.m_ShadowObj:SetActive(false)
	self.m_Actor = CActor.New()
	local tConfigObjs = {
		size_obj = self,
		collider = self:GetComponent(classtype.CapsuleCollider),
		head_trans = self.m_HeadTrans,
		waist_trans = self.m_WaistTrans,
		foot_trans = self.m_FootTrans,
	}
	self.m_Actor:SetConfigObjs(tConfigObjs)
	self.m_Actor:SetParent(self.m_RotateObj.m_Transform, false)
	self.m_Actor:SetDefaultState("idleWar")
	self.m_Actor:SetRoot(g_WarCtrl:GetRoot())
	self.m_PlayMagicID = nil
	self.m_BloodPercent = nil
	self.m_ActionDone = false
	self.m_DefaultMatColor = nil

	self:AddInitHud("light")
	self:AddInitHud("warrior_select")
	self:AddInitHud("warrior_order")
	self:AddInitHud("warrior_damage")
	self:AddInitHud("warrior_buff")
	self:AddInitHud("warrior_replace")
	self:AddInitHud("warrior_stargrid")
	self:AddInitHud("warrior_skill")
	self:AddInitHud("warrior_jihuo")
	self:AddInitHud("warrior_addsp")
	self:AddInitHud("warrior_command")
	self:AddInitHud("warrior_lock")
	self:AddInitHud("warrior_level")
	self:AddInitHud("guideTipsHud")
	self:AddInitHud("blood", function(oHud) 
		if Utils.IsExist(self) then
			local sSprName = self:IsAlly() and "pic_hud_xuetiao" or "pic_hud_xuetiao" --"pic_xuetiao_huang" or "pic_xuetiao_hong"
			oHud:SetSprite(sSprName)
		end
	end)
	-- if wid == 1 then
	-- 	CWarrior.g_TestActorID = self.m_Actor:GetInstanceID()
	-- end
	-- self:AddHud("warrior_select_ui", CWarriorSelectHud, self.m_WaistTrans, function(oHud) oHud:SetWarrior(self) end, false)
	self.m_FloatHitInfo = {rise_timer=nil, down_timer=nil, restore_timer=nil ,atkids ={},record = false}
	self:ExtraInit()
end

function CWarrior.ExtraInit(self)
	self.m_Actor:SetOffsetScale(1.1)
	self.m_DefaultMatColor = self.m_Actor:GetMatColor()
end

function CWarrior.ShowWarrior(self)
	if self.m_LockHide then
		return
	end
	Utils.ShowObject(self)
	self.m_Actor:ShowSubModels()
end

function CWarrior.HasDontHitBuff(self)
	for k, v in pairs(self.m_DontHitBuffs) do
		return true
	end
	return false
end

function CWarrior.HideWarrior(self)
	if self.m_LockHide then
		return
	end
	Utils.HideObject(self)
	self.m_Actor:HideSubModels()
end

function CWarrior.LockHide(self)
	self.m_LockHide = false
	self:HideWarrior()
	self.m_LockHide = true
end

function CWarrior.SetMatColor(self, color)
	self.m_Actor:SetMatColor(color)
	if color.a == 0 then
		self:HideWarrior()
	else
		self:ShowWarrior()
	end
end

function CWarrior.ReSetDefaultMatColor(self)
	if self.m_DefaultMatColor then
		self:SetMatColor(self.m_DefaultMatColor )
	end
end

function CWarrior.GetMatColor(self)
	return self.m_Actor.m_MatColor
end


function CWarrior.ShowReplaceActor(self)
	local function black()
		if Utils.IsNil(self) then
			return
		end
		g_WarCtrl:WarriorStatusChange(self.m_ID)
		self:SetLayerDeep(self.m_GameObject.layer)
		self:CrossFade(self:GetState())
		self:SetMatColor(Color.black*0.9)
	end
	self.m_Actor:ChangeShape(301, {shape=301}, black)
end

function CWarrior.SetTouchEnabled(self, b)
	self.m_IsCanTouch = b
end

function CWarrior.GetTouchEnabled(self)
	return self.m_IsCanTouch
end

function CWarrior.AddFloatAtkId(self, atkid, cnt)
	self.m_FloatHitInfo.record  = true
	self.m_FloatHitInfo.atkids[atkid] = cnt
end

function CWarrior.SubFloatAtkId(self, atkid)
	local iCnt = self.m_FloatHitInfo.atkids[atkid]
	if iCnt and iCnt > 0 then 
		self.m_FloatHitInfo.atkids[atkid] = iCnt - 1
	else
		self.m_FloatHitInfo.atkids[atkid] = nil
	end
end

function CWarrior.IsFloatAtkID(self, id)
	do return true end
end

function CWarrior.SetPlayMagicID(self, i)
	self.m_PlayMagicID = i
	if self.m_NpcSpSkill then
		if self.m_NpcSpSkill.skill_id == i then
			self.m_NpcSpSkill.cur_grid = 0
			self:RefreshNpcSkill()
		end
	end
end

function CWarrior.WarSkill(self, dVary)
	if Utils.IsNil(self) then
		return
	end
	local oShowWarSkillCmd, idx = self:ShowWarSkillCmd(dVary)
	if oShowWarSkillCmd then
		oShowWarSkillCmd:Excute()
		table.remove(dVary.skill_list, idx)
	end
	self:UpdateStatus(dVary)
end

function CWarrior.ShowWarSkillCmd(self, dVary)
	if dVary.skill_list and next(dVary.skill_list) then
		return dVary.skill_list[1], 1
	end
end

function CWarrior.ShowWarSkillByClient(self, iMagic, alive_time)
	local trans = self:GetBindTrans("head")
	self:AddHud("warrior_skill", CWarriorMagicHud, trans, function(oHud) oHud:ShowWarSkillByClient(iMagic, alive_time) end, false)
end

function CWarrior.ShowWarSkillByServer(self, iMagic, iType)
	if iType == 6 then
		self:CreateBuffAni(iMagic)
	end
	local trans = self:GetBindTrans("head")
	self:AddHud("warrior_skill", CWarriorMagicHud, trans, function(oHud) oHud:ShowWarSkillByServer(iMagic, iType) end, false)
end

function CWarrior.SetUseMagic(self, iMagic)
	local trans = self:GetBindTrans("head")
	self:AddHud("warrior_skill", CWarriorMagicHud, trans, function(oHud) oHud:SetUseMagic(iMagic) end, false)
end

function CWarrior.ShowWarriorAddSp(self, iSp)
	local trans = self:GetBindTrans("waist")
	self:AddHud("warrior_addsp", CWarriorAddSpHud, trans, function(oHud) oHud:ShowWarAddSpEffect(iSp) end, false)
end

function CWarrior.SetWarriorCommand(self, sCommand)
	local trans = self:GetBindTrans("waist")
	self:AddHud("warrior_command", CWarriorCommandHud, trans, function(oHud) oHud:SetWarriorCommand(sCommand, self:IsAlly()) end, false)
end

function CWarrior.SetLevel(self, lv)
	if self.m_NpcWarriorType == 1 then
		--boss怪不显示
		return
	end
	local trans = self:GetBindTrans("head")
	self:AddHud("warrior_level", CLevelHud, trans, function(oHud) oHud:SetLevel(lv) end, false)	
end

function CWarrior.CheckWarBattleCmd(self)
	local cmd = g_WarCtrl:GetCacheWarBattleCmd(self.m_ID)
	if cmd then
		self:SetWarriorCommand(cmd)
	end
end

function CWarrior.SetSpeed(self, iSpeed)
	self.m_Speed = iSpeed
end

function CWarrior.SetActionDone(self, b)
	self.m_ActionDone = b
end

function CWarrior.IsActionDone(self)
	return self.m_ActionDone
end

function CWarrior.GetSpeed(self)
	return self.m_Speed
end

function CWarrior.SetOrderDone(self, bDone)
	if bDone then
		self:DelHud("warrior_order")
	else
		local trans = self:GetBindTrans("waist")
		self:AddHud("warrior_order", CWarriorOrderHud, trans, function(oHud)
			oHud:SetReady(false) 
			end, false)
	end

	self.m_IsOrderDone = bDone
end

function CWarrior.SetReady(self, bDone)
	local trans = self:GetBindTrans("waist")
	self:AddHud("warrior_order", CWarriorOrderHud, trans, function(oHud) oHud:SetReady(bDone) end, false)
end

function CWarrior.IsOrderDone(self)
	return self.m_IsOrderDone
end

function CWarrior.ShowDamage(self, damage, iscrit, bDamageFollow, damage_type)
	local wartype = g_WarCtrl:GetWarType()
	--[[
	if wartype == define.War.Type.Boss or wartype == define.War.Type.BossKing then
		if not self:IsAlly() and self.m_CampPos == 1 then
			local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
			if dInfo and dInfo.hp_max ~= 0 then
				g_ActivityCtrl:RefreshBossHP(dInfo.hp+damage, dInfo.hp_max)
			end
		end
	else
	]]
	if wartype == define.War.Type.OrgBoss then
		if not self:IsAlly() and self.m_CampPos == 1 then
			local dInfo = g_OrgCtrl:GetOrgBossInfo()
			if dInfo and dInfo.hp_max ~= 0 then
				g_OrgCtrl:UpdateOrgFBBossHP(dInfo.boss_id, dInfo.hp_max, dInfo.hp+damage)
			end
		end
	elseif wartype == define.War.Type.MonsterAtkCity then
		if not self:IsAlly() and self.m_CampPos == 1 then
			local hp = g_MonsterAtkCityCtrl.m_BossHP
			local hp_max = g_MonsterAtkCityCtrl.m_BossHPMax
			if hp < hp_max then
				g_MonsterAtkCityCtrl:OnReceiveMSBossHP(hp + damage, hp_max)
			end
		end
	end

	self:AddHud("warrior_damage", CWarriorDamageHud, self.m_WaistTrans, 
		function(oHud) 
			oHud:ShowDamage(damage, iscrit, bDamageFollow, damage_type)
		end, true)
end

function CWarrior.GetLocalForward(self)
	return g_WarCtrl:GetRoot():InverseTransformDirection(self.m_RotateObj:GetForward())
end

function CWarrior.GetLocalUp(self)
	return g_WarCtrl:GetRoot():InverseTransformDirection(self.m_RotateObj:GetUp())
end

function CWarrior.IsCanReplace(self)
	return self.m_PartnerID and self.m_OwnerWid == g_WarCtrl.m_HeroWid
end

function CWarrior.RefreshBuff(self, buffid, bout, level, bTips, iFromWid)
	local dBuffInfo = self.m_Buffs[buffid]
	local bDeleteBuff = bout <= 0 or level <= 0
	if dBuffInfo then
		if bDeleteBuff then
			if dBuffInfo.obj then
				dBuffInfo.obj:Clear()
			end
			dBuffInfo = nil
			self:ProcessSpecailBuff(buffid, false)
		else
			dBuffInfo.bout = bout
			dBuffInfo.level = level
		end
	elseif not bDeleteBuff then
		local obj
		local dBuffData = data.buffdata.DATA[buffid]
		if dBuffData and dBuffData.show_effect == 1 then
			obj = CWarBuff.New(buffid, self)
			obj:SetFromWid(iFromWid)
		end
		dBuffInfo = {
			obj = obj,
			bout = bout,
			level = level,
			buff_id = buffid,
		}

		self:ProcessSpecailBuff(buffid, true)
	end
	if dBuffInfo and dBuffInfo.obj then
		dBuffInfo.obj:SetLevel(level)
	end
	self.m_Buffs[buffid] = dBuffInfo
	if self:IsNpcWarriorTypeBoss() then
		local oView = CWarBossView:GetView()
		if oView then
			oView:RefreshBuff(buffid, bout, level, bTips) 
		end
		local bOnlyFloat = true
		self:AddHud("warrior_buff", CWarriorBuffHud, self.m_HeadTrans, 
		function(oHud) 
			oHud:RefreshBuff(buffid, bout, level, bTips, bOnlyFloat) 
		end, true)
	else
		self:AddHud("warrior_buff", CWarriorBuffHud, self.m_HeadTrans, 
				function(oHud) 
					oHud:RefreshBuff(buffid, bout, level, bTips) 
				end, true)
	end
	local oView = CWarTargetDetailView:GetView()
	if oView and oView:GetWarrior() == self then
		oView:RefreshBuffTable()
	end
end

function CWarrior.CreateBuffAni(self, buffid)
	local obj = CWarBuff.New(buffid, self)
	obj:SetLevel(1)
	Utils.AddScaledTimer(objcall(obj, function(o) o:Clear()end), 0, 0.5)
end

function CWarrior.SetJihuoTag(self, b)
	self.m_IsJiHuo = b
	if b then
		self:AddBindObj("warrior_jihuo")
	else
		self:DelBindObj("warrior_jihuo")
	end
end

function CWarrior.SetGuideTips(self, b)
	if b then
		self:AddBindObj("guideTipsHud")
	else
		self:DelBindObj("guideTipsHud")
	end
end

function CWarrior.SetLockTag(self, b, iLevel)
	self.m_IsFightLock = b
	if b then
		self:AddHud("warrior_lock", CWarriorLockHud, self.m_WaistTrans, 
		function(oHud) 
			oHud:SetLevel(iLevel) 
		end, false)
	else
		self:DelBindObj("warrior_lock")
	end
end

function CWarrior.IsJiHuo(self)
	return self.m_IsJiHuo
end

function CWarrior.ProcessSpecailBuff(self, buffid, bAdd)
	if buffid == 1017 or buffid == 1019 then
		self.m_DizzyBuffs[buffid] = bAdd and 1 or nil
		local dAnimMap
		if table.count(self.m_DizzyBuffs) > 0 then
			self.m_Actor:SetStateMap("dizzy", {idleWar="dizzy"})
			if self:IsAlive() then
				self:CrossFade("dizzy", 0.05)
			end
		else
			self.m_Actor:SetStateMap("dizzy", nil)
			if self:IsAlive() then
				self:CrossFade("idleWar", 0.05)
			end
		end
	elseif buffid == 1001 or buffid == 1035 then
		if bAdd then
			self.m_DontHitBuffs[buffid] = true
		else
			self.m_DontHitBuffs[buffid] = nil
		end
	end
end

function CWarrior.ProcessBuffBeforeHit(self, dVary)
	if dVary.buff_list and next(dVary.buff_list) then
		for i, oCmd in ipairs(dVary.buff_list) do
			oCmd:Excute()
		end
		dVary.buff_list = {}
	end
end

function CWarrior.Bout(self, dontBoutCD)
	if not dontBoutCD then
		self:BuffBout()
		self:MagicCDBout()
	end
	self.m_FloatHitInfo.atkids = {}
	self.m_FloatHitInfo.record = false
	self:CheckError()

	if not g_WarCtrl.m_IsWarStart and self.m_NpcSpSkill and self:IsAlive() then
		local iCur = self.m_NpcSpSkill.cur_grid
		local iMax = self.m_NpcSpSkill.sum_grid
		if iCur and iMax then
			if g_WarCtrl:GetNewWaveTag() then
				iCur = math.min(iCur, iMax)
			else
				iCur = math.min(iCur+1, iMax)
			end
		end
		self.m_NpcSpSkill.cur_grid = iCur
		self:RefreshNpcSkill()
	end
end

function CWarrior.RefreshNpcSkill(self)
	if self.m_NpcSpSkill and self:IsAlive() and not g_WarCtrl.m_IsWarStart then
		local iCur = self.m_NpcSpSkill.cur_grid
		local iMax = self.m_NpcSpSkill.sum_grid
		if self:IsNpcWarriorTypeBoss() then
			local oView = CWarBossView:GetView()
			if oView then
				oView:SetStar(iCur, iMax)
			end
		else
			self:AddHud("warrior_stargrid", CStarGridHud, self.m_HeadTrans, 
				function(oHud) 
					oHud:SetStar(iCur, iMax) 
				end, 
			true)
		end
	end
end

function CWarrior.CheckError(self) --防止没归位或死亡没倒地
	local iBout = g_WarCtrl:GetBout()
	if self.m_CheckErrBout ~= iBout and not self:IsAlive() then
		self.m_CheckErrBout = iBout
		local dis = WarTools.GetHorizontalDis(self:GetLocalPos(), self.m_OriginPos)
		if dis > 0.2 then
			print("CheckError 归位,", dis)
			self:FaceDefault()
			local c = self.m_Actor:GetMatColor()
			local function show(obj)
				obj:SetLocalPos(obj.m_OriginPos)
				local oShowAction = CActionColor.New(obj.m_Actor, 0.25,  "SetMatColor", Color.New(c.r, c.g, c.b, 0), c)
				g_ActionCtrl:AddAction(oShowAction)
			end
			local oHideAction = CActionColor.New(self.m_Actor, 0.25,  "SetMatColor", Color.New(c.r, c.g, c.b, c.a * 0.5), Color.New(c.r, c.g, c.b, 0))
			oHideAction:SetEndCallback(objcall(self, show))
			g_ActionCtrl:AddAction(oHideAction)
		end
		self.m_RotateObj:SetLocalPos(Vector3.zero)
	end
end

function CWarrior.BuffBout(self)
	-- for id, dBuffInfo in pairs(self.m_Buffs) do
	-- 	local dData = data.buffdata.DATA[id]
	-- 	if dData and dData.sub_type == define.War.Buff_Sub.BoutEnd and dBuffInfo.bout ~= define.War.Infinite_Buff_Bout then
	-- 		self:RefreshBuff(id, dBuffInfo.bout - 1, dBuffInfo.level)
	-- 	end
	-- end
end

function CWarrior.MagicCDBout(self)
	for id, bout in pairs(self.m_MagicCD) do
		local newbout = self.m_MagicCD[id] - 1
		self.m_MagicCD[id] = newbout<=0 and nil or newbout
	end
end

function CWarrior.SetMagicCD(self, magid, bout)
	self.m_MagicCD[magid] = bout
end

function CWarrior.GetMagicCD(self, magid)
	local cd = self.m_MagicCD[magid] or 0
	return cd
end

function CWarrior.ClearBuff(self)
	for id, dBuffInfo in pairs(self.m_Buffs) do
		self:RefreshBuff(id, 0, dBuffInfo.level)
	end
	self.m_Buffs = {}
end

function CWarrior.GetBuffList(self)
	return table.dict2list(self.m_Buffs, "buff_id")
end

--bNotAnim是否只设置值，不播动作
function CWarrior.SetAlive(self, bAlive, bNotAnim)
	local iOldAlive = self.m_IsAlive 
	self.m_IsAlive = bAlive
	if Utils.IsNil(self) then
		return
	end
	if not bNotAnim then
		if self:IsBusy() then
			print("CWarrior.SetAlive->busy状态，不播死亡")
			table.print(self.m_BusyFlags)
		else
			if bAlive then
				self:Relive()
			else
				self:Die()
			end
		end
	end
	if iOldAlive ~= bAlive then
		g_WarCtrl:WarriorAliveChange(self.m_ID)
	end
end

function CWarrior.IsNearOriPos(self, pos)
	return WarTools.GetHorizontalDis(pos, self.m_OriginPos) < 0.005
end

function CWarrior.Relive(self)
	self.m_Actor:LockState(nil)
	if self:GetState() == "die" then
		self:CrossFade("rise")
		local dClipInfo = self.m_Actor:GetAnimClipInfo("rise")
		self:WaitTime(dClipInfo.length)
	end
	self.m_BloodPercent = nil
	self:RefreshBlood()
	self:RefreshNpcSkill()
	self:RefreshLevel()
end

function CWarrior.RefreshLevel(self)
	local sState = self:GetState()
	if sState == "die" then
		self:SetLevel(0)
	else
		self:SetLevel(self.m_Level)
	end
end

function CWarrior.SetBlood(self, percent)
	if self.m_BloodPercent == percent then
		return
	end
	self.m_BloodPercent = percent
	if self:IsAlive() or self:GetState() ~= "die" then
		local trans = self:GetBindTrans("head")
		self:AddHud("blood", CBloodHud, trans, function(oHud) oHud:SetHP(percent) end, false)
	end
end

function CWarrior.Die(self, iNormaized)
	if self:IsBusy() then
		return
	end
	local sState = self:GetState()
	if sState ~= "die" then
		iNormaized = iNormaized or 0
		self:Play("die", iNormaized)
		local dClipInfo = self.m_Actor:GetAnimClipInfo("die")
		local iWaitTime = dClipInfo.length * (1-iNormaized)
		if iNormaized < 1 then
			self:WaitTime(iWaitTime)
		end
		local angle = self:GetDefalutRotateAngle()
		DOTween.DOLocalRotate(self.m_RotateObj.m_Transform, angle, iWaitTime)
	end
	self.m_Actor:LockState("die")
	self:DelBindObj("blood")
	self:DelBindObj("warrior_stargrid")
	self:RefreshLevel()
end

function CWarrior.UpdateOriginPos(self)
	local pos = g_WarCtrl:GetLinupPos(self:IsAlly(), self.m_CampPos)
	self.m_OriginPos = pos
	self:SetLocalPos(pos)
	self.m_Actor:SetLocalPos(Vector3.zero)
	self:FaceDefault()
	self.m_Actor:SetFixedPos(pos)
	local angle = self:GetDefalutRotateAngle()
	g_MagicCtrl.m_CalcPosObject:SetParent(self.m_Transform, false)
	g_MagicCtrl.m_CalcPosObject:SetLocalPos(Vector3.zero)
	g_MagicCtrl.m_CalcPosObject:SetLocalEulerAngles(angle)
	self.m_Actor:SetDefaultAnlge(g_MagicCtrl.m_CalcPosObject:GetEulerAngles())
	self.m_Actor:UpdateSubModels()
	g_MagicCtrl:ResetCalcPosObject()
end

function CWarrior.SetStatus(self, dStatus)
	self.m_Status = dStatus
	self:UpdateAutoSkill()
	self:RefreshBlood()
	g_WarCtrl:WarriorStatusChange(self.m_ID)
end

function CWarrior.UpdateAutoSkill(self)
	if not self:IsAlly() then
		return
	end
	if self:IsAlly() and self.m_ID == g_WarCtrl.m_HeroWid or
		(self.m_OwnerWid and self.m_OwnerWid == g_WarCtrl.m_HeroWid and #self.m_MagicList > 0) then
		if self:GetAutoMagic() then
			if self.m_ID == g_WarCtrl.m_HeroWid then
				g_WarOrderCtrl:ChangeAutoMagic("hero", self:GetAutoMagic(), true)
			else
				g_WarOrderCtrl:ChangeAutoMagic(self.m_PartnerID, self:GetAutoMagic(), true)
			end
		end
		g_WarCtrl:AutoMagicChange(self.m_ID)
	end
end

function CWarrior.GetAutoMagic(self)
	if self.m_Status and self.m_Status.auto_skill and self.m_Status.auto_skill ~= 0 then
		return self.m_Status.auto_skill
	end
end

function CWarrior.UpdateStatus(self, dVary)
	local bChange = false
	for k, v in pairs(self.m_Status) do
		local new = dVary[k]
		if new and v ~= new then
			self.m_Status[k] = new
			if k == "auto_skill" then
				self:UpdateAutoSkill()
			else
				bChange = true
			end
		end
	end
	self:RefreshBlood(dVary)
	if dVary.model_info then
		self:ChangeShape(dVary.model_info.shape, dVary.model_info)
	end
	if bChange then
		g_WarCtrl:WarriorStatusChange(self.m_ID)
	end
end

function CWarrior.Destroy(self)
	self:ClearBindObjs()
	self:ClearBuff()
	self.m_Actor:Destroy()
	CObject.Destroy(self)
end

function CWarrior.IsAlly(self)
	if self.m_IsAlly == nil then
		if self.m_CampID ~= g_WarCtrl:GetAllyCamp() then
			self.m_IsAlly = false
		elseif g_WarCtrl:GetViewSide() and self.m_CampID == g_WarCtrl:GetViewSide() then
			self.m_IsAlly = true
		elseif g_WarCtrl:GetHeroPid() and self.m_Pid == g_WarCtrl:GetHeroPid() then
			self.m_IsAlly = true
		elseif self.m_CampID == g_WarCtrl:GetAllyCamp() then
			self.m_IsAlly = true
		else
			self.m_IsAlly = false
		end
	end
	return self.m_IsAlly
end

function CWarrior.SetOriginPos(self, pos)
	self.m_OriginPos = pos
end

function CWarrior.GetOriginPos(self)
	return self.m_OriginPos
end

function CWarrior.ChangeShape(self, iShape, tDesc)
	self.m_Actor:ChangeShape(iShape, tDesc, callback(self, "OnChangeDone"))
end

function CWarrior.GetCurDesc(self)
	return self.m_Actor:GetModelInfo()
end

function CWarrior.OnChangeDone(self)
	self.m_Actor:LoadMaterial("Material/shadow.mat")
	local iShape = self:GetShape()
	self.m_Actor:SetModelOutline(data.modeldata.Outline[iShape]  or 0.01)
	self.m_Actor:MainModelCall(CRenderObject.SetShadowHeight, 0.01)
	g_WarCtrl:WarriorStatusChange(self.m_ID)
	self:SetLayerDeep(self.m_GameObject.layer)
	self:CrossFade(self:GetState())
end

function CWarrior.Play(self, state, normalizedTime)
	self.m_Actor:Play(state, normalizedTime)
end

function CWarrior.CrossFade(self, state, duration, normalizedTime)
	self.m_Actor:CrossFade(state, duration, normalizedTime)
end

function CWarrior.PlayInFixedTime(self, state, fixedTime)
	self.m_Actor:PlayInFixedTime(state,fixedTime)
end

function CWarrior.CrossFadeInFixedTime(self, state, duration, fixedTime)
	self.m_Actor:CrossFadeInFixedTime(state, duration, fixedTime)
end


function CWarrior.SetBusy(self, b, sType)
	sType = sType or "main"
	self.m_BusyFlags[sType] = b
end

function CWarrior.IsBusy(self, sType)
	if not Utils.IsExist(self) then
		return false
	end
	if sType then
		return self.m_BusyFlags[sType]
	end
	for k, v in pairs(self.m_BusyFlags) do
		if v == true then
			return true
		end
	end
	return false
end

function CWarrior.WaitTime(self, time)
	local key = "WaitTime"..tostring(time)
	self:SetBusy(true, key)
	Utils.AddScaledTimer(callback(self, "SetBusy", false, key), time, time)
end

function CWarrior.BeginHit(self, atkObj, dVary, bFaceAtk, bAnim, bConsiderHight)
	if Utils.IsNil(self) then
		return
	end
	local oDamageCmd = self:GetCmdInVary(dVary, "damage_list")
	if not oDamageCmd then
		return
	end
	if self:GetState() == "die" then
		WarTools.Print("die, BeginHit:", self:GetName())
		return
	end
	self.m_EventState = {}

	if oDamageCmd.damage > 0 then

	else
		oDamageCmd.has_hit = true
		if oDamageCmd.type == 1 then
			self:Dodge()
		elseif oDamageCmd.type == 2 then
			-- self:SetBusy(true, "defend")
			-- local requiredata = {
			-- 	refAtkObj = weakref(atkObj),
			-- 	refVicObjs = {weakref(self)},
			-- }
			-- local oMagicUnit = g_MagicCtrl:NewMagicUnit(define.Magic.Defend_ID, 1, requiredata)
			-- oMagicUnit:SetLayer(UnityEngine.LayerMask.NameToLayer("War"))
			-- oMagicUnit:SetEndCallback(function() self:SetBusy(false, "defend") end)
		else
			-- if self:IsFloatAtkID(atkObj.m_ID) then
			-- 	if bAnim then
			-- 		self:FloatHit()
			-- 	end
				-- self:SubFloatAtkId(atkObj.m_ID)
			-- end
			-- else
			if bFaceAtk and atkObj and not self:HasDontHitBuff() then
				if bConsiderHight then
					self:LookAtPos(atkObj:GetLocalPos())
				else
					local pos = atkObj:GetLocalPos()
					local selfPos = self:GetLocalPos()
					self:LookAtPos(Vector3.New(pos.x, selfPos.y, pos.z))
				end
			end
			if bAnim then
				self:Hit()
			end
			-- end
		end
	end
end

function CWarrior.Attack(self)
	if Utils.IsNil(self) then
		return
	end
	self.m_EventState = {}
	self.m_Actor:AdjustSpeedPlay("attack1", 0.7)
	self.m_Actor:FixedEvent("attack1", 0, callback(self, "InsertEventState", 1))
	self.m_Actor:FixedEvent("attack1", 0.7, callback(self, "InsertEventState", 2))
	self.m_Actor:FixedEvent("attack1", 0.7, callback(self, "InsertEventState", 3))
end

--浮空测试参数
CWarrior.up_speed = 4.5
CWarrior.up_time = 0.35
CWarrior.hit_speed = 3.5
CWarrior.hit_time = 0.35
CWarrior.down_time = 0.7
CWarrior.lie_time = 0.5

function CWarrior.FloatHit(self)
	if self:HasDontHitBuff() then
		return
	end
	if data.modeldata.NoFloatHit[self:GetShape()] then
		self:Hit()
		return
	end
	if self.m_HitInfo.timer then
		self:StopHit()
	end
	DOTween.DOKill(self.m_Actor.m_Transform, false)
	local oMoveObj = self.m_Actor
	local sState = self.m_Actor:GetState()
	local iTime
	if sState == "idleWar" then
		iTime = CWarrior.up_time
		local pos = oMoveObj:GetLocalPos()
		pos.y = pos.y + CWarrior.up_speed * iTime
		local tween = DOTween.DOLocalMove(oMoveObj.m_Transform, pos, iTime)
		self.m_Actor:AdjustSpeedPlay("upFloat", iTime)
		self:WaitTime(iTime)
	else
		iTime = CWarrior.hit_time
		local pos = oMoveObj:GetLocalPos()
		local iMax = CWarrior.up_speed * CWarrior.up_time
		pos.y = pos.y + Mathf.Lerp(0, CWarrior.hit_speed*iTime, 1-(pos.y/iMax))
		DOTween.DOLocalMove(oMoveObj.m_Transform, pos, iTime)
		self.m_Actor:AdjustSpeedPlay("hitFloat", iTime)
		self:WaitTime(iTime)
	end
	local restore = objcall(self, function(obj)
		obj:FaceDefault()
		obj:SetBusy(false, "floating")
		obj.m_FloatHitInfo.restore_timer = nil
		if obj:IsAlive() then
			obj.m_Actor:CrossFade("idleWar", 0.2)
		else
			obj:Die(0.3)
		end
	end)
	local rise = objcall(self, function(obj)
		local pos = oMoveObj:GetLocalPos()
		pos.y = 0
		oMoveObj:SetLocalPos(pos)
		local time = 0
		if obj:IsAlive() then
			obj.m_Actor:Play("rise")
			local dClipInfo = obj.m_Actor:GetAnimClipInfo("rise")
			time = dClipInfo.length
		end
		if time > 0 then
			obj.m_FloatHitInfo.restore_timer = Utils.AddScaledTimer(restore, 0, time)
		else
			restore()
		end
	end)
	local down = objcall(self, function(obj)
		local pos = oMoveObj:GetLocalPos()
		pos.y = 0
		obj.m_Actor:AdjustSpeedPlay("downFloat", CWarrior.down_time)
		local tween = DOTween.DOLocalMove(oMoveObj.m_Transform, pos, CWarrior.down_time)
		DOTween.SetEase(tween, enum.DOTween.Ease.InCirc)
		obj.m_FloatHitInfo.rise_timer = Utils.AddScaledTimer(rise, 0, CWarrior.down_time+CWarrior.lie_time)
		obj.m_FloatHitInfo.down_timer = nil
	end)
	if self.m_FloatHitInfo.down_timer then
		Utils.DelTimer(self.m_FloatHitInfo.down_timer)
	end
	if self.m_FloatHitInfo.restore_timer then
		Utils.DelTimer(self.m_FloatHitInfo.restore_timer)
		self.m_FloatHitInfo.restore_timer = nil
	end
	if self.m_FloatHitInfo.rise_timer then
		Utils.DelTimer(self.m_FloatHitInfo.rise_timer)
		self.m_FloatHitInfo.rise_timer = nil
	end
	self:SetBusy(true, "floating")
	self.m_FloatHitInfo.down_timer = Utils.AddScaledTimer(down, iTime, iTime)
end

function CWarrior.StopHit(self)
	if not self then
		return
	end
	if self.m_HitInfo.timer then
		Utils.DelTimer(self.m_HitInfo.timer)
		if self.m_HitInfo.begin_pos and WarTools.GetHorizontalDis(self.m_HitInfo.begin_pos, self:GetLocalPos()) < 0.005 then
			self:SetLocalPos(self.m_HitInfo.begin_pos)
		end
	end
	self:EndHit(false)
	self.m_HitInfo = {timer=nil, stand=0, step=0, goback = false, begin_pos=nil}
end

function CWarrior.Hit(self)
	if self:HasDontHitBuff() then
		return
	end
	if self:IsBusy("floating") then
		self:FloatHit()
		print("浮空中播放受击")
		return
	end
	if self:GetState() == "die" then
		WarTools.Print("die, Hit:", self:GetName())
		return
	end
	local iKeyFrame = self.m_Actor:GetHitKeyFrame()
	local iBackTime = ModelTools.FrameToTime(iKeyFrame)
	local iSpeed = 0.05 / iBackTime
	local dir = self:InverseTransformDirection(self.m_RotateObj:GetForward())
	if self.m_HitInfo.goback then
		self.m_HitInfo.goback = false
	end
	local iMax = iBackTime*1.5
	self.m_HitInfo.stand = self.m_HitInfo.stand + Mathf.Lerp(0, iBackTime*0.7, (iMax-self.m_HitInfo.stand)/iMax)
	local function hitstep(obj, dt)
		if not obj:IsAlive() then
			WarTools.Print("已死亡目标Hit", obj:GetName())
			obj.m_HitInfo.timer = nil
			return false
		end
		if obj.m_HitInfo.goback then
			if obj.m_HitInfo.step < 0 then
				local sState = obj.m_Actor:GetState()
				if obj.m_HitInfo.begin_pos and WarTools.GetHorizontalDis(obj.m_HitInfo.begin_pos, obj:GetLocalPos()) < 0.005 then
					obj:SetLocalPos(obj.m_HitInfo.begin_pos)
				end
				if sState == "hit2" or sState == "hit1" then
					obj:EndHit(true)
				end
				obj.m_HitInfo.timer = nil
				obj.m_HitInfo.step = 0
				return false
			else
				obj:Translate(dir * iSpeed * dt)
				obj.m_HitInfo.step = obj.m_HitInfo.step - dt
			end
		else
			if obj.m_HitInfo.step >= iBackTime then
				if obj.m_HitInfo.stand > 0 then
					obj.m_HitInfo.stand = obj.m_HitInfo.stand - dt
				else
					obj.m_HitInfo.stand = 0
					obj.m_Actor:CrossFade("hit2", 0.05)
					obj.m_HitInfo.goback = true
				end
			else
				obj:Translate(dir * -iSpeed * dt)
				obj.m_HitInfo.step = obj.m_HitInfo.step + dt
			end
		end
		return true
	end
	if not self.m_HitInfo.timer then
		self.m_HitInfo.begin_pos = self:GetLocalPos()
		self.m_HitInfo.timer = Utils.AddScaledTimer(objcall(self, hitstep), 0, 0)
	end
	local iNormalized = 0
	if self:GetState() == "hit2" then
		iNormalized = math.min(1, math.max(0, self.m_HitInfo.step / iBackTime) - 0.3)
	else
		if self.m_HitInfo.goback==false and 
			self.m_HitInfo.step >= iBackTime and 
			self.m_HitInfo.stand > 0 then
			iNormalized = 0.7
		else
			iNormalized = math.min(1, math.max(0, (self.m_HitInfo.step / iBackTime) - 0.3))
		end
	end
	self.m_Actor:Play("hit1", iNormalized)
end

function CWarrior.Hurt(self, dVary, bDamageFollow)
	if Utils.IsNil(self) then
		return
	end
	local oDamageCmd, idx = self:GetCmdInVary(dVary, "damage_list")
	if oDamageCmd then
		oDamageCmd.damage_follow = bDamageFollow
		oDamageCmd:Excute()
		table.remove(dVary.damage_list, idx)
	end

	local oSpCmd, idx = self:GetCmdInVary(dVary, "sp_list")
	if oSpCmd then
		oSpCmd:Excute()
		table.remove(dVary.sp_list, idx)
	end
	self:UpdateStatus(dVary)
end

--反伤
function CWarrior.CounterHurt(self, dVary)
	if Utils.IsNil(self) then
		return
	end
	local oDamageCmd, idx = self:GetCmdInVary(dVary, "counterhurt_list")
	if oDamageCmd then
		oDamageCmd.damage_follow = true
		oDamageCmd:Excute()
		table.remove(dVary.counterhurt_list, idx)
	end
	self:UpdateStatus(dVary)
end

function CWarrior.GetCmdInVary(self, dVary, sListName)
	local list = dVary[sListName]
	if list and next(list) then
		return list[1], 1
	end
end

function CWarrior.RefreshBlood(self, dVary)
	local hp = self.m_Status.hp or 0
	local max_hp = self.m_Status.max_hp or 0
	if dVary and dVary.hp_list and next(dVary.hp_list) then
		local t = dVary.hp_list[1]
		if t.hp then
			hp = t.hp
			self.m_Status["hp"] = hp
		end
		if t.max_hp then
			max_hp = t.max_hp
			self.m_Status["max_hp"] = max_hp
		end
		table.remove(dVary.hp_list, 1)
	end
	local wartype = g_WarCtrl:GetWarType()
	if self:IsNpcWarriorTypeBoss() and 
		(wartype == define.War.Type.Boss 
			or wartype == define.War.Type.BossKing 
			or wartype == define.War.Type.OrgBoss 
			or wartype == define.War.Type.FieldBoss
			or wartype == define.War.Type.MonsterAtkCity) then
		--世界boss和公会boss的血量有单独协议控制
		return
	end
	--boss怪出界面
	if self:IsNpcWarriorTypeBoss() then
		local oView = CWarBossView:GetView()
		if oView then
			oView:RefreshHPSlider(hp/max_hp)
			return
		end
		return
	end
	self:SetBlood(hp/max_hp)
end

function CWarrior.GetStatus(self)
	return self.m_Status
end

function CWarrior.IsAlive(self)
	return self.m_IsAlive
end

function CWarrior.EndHit(self, bFaceDefalut)
	if self:IsAlive() then
		self:CrossFade("idleWar")
		if bFaceDefalut then
			self:FaceDefault()
		end
	end
end

function CWarrior.GetDefalutRotateAngle(self)
	if self:IsAlly() then
		return Vector3.New(0, -45, 0)
	else
		return Vector3.New(0, 135, 0)
	end
end

function CWarrior.ShowSelSpr(self, bShow)
	if bShow then
		self:AddBindObj("warrior_select")
		-- self:AddBindObj("warrior_select_ui")
	else
		self:DelBindObj("warrior_select")
		-- self:DelBindObj("warrior_select_ui")
	end
	self.m_IsOrderTarget = bShow
end

function CWarrior.IsOrderTarget(self)
	return self.m_IsOrderTarget
end

function CWarrior.GetState(self)
	return self.m_Actor:GetState()
end

function CWarrior.GetShape(self)
	return self.m_Actor:GetShape()
end

--hud
function CWarrior.GetHudCamera(self)
	return g_CameraCtrl:GetWarCamera()
end


function CWarrior.SetName(self, name)
	self.m_Name = name
	if Utils.IsEditor() then
		-- name = name or ""
		-- if self.m_PartnerID then
		-- 	name = name.."_"..tostring(self.m_PartnerID)
		-- end
		CObject.SetName(self, string.format("wid:%s-%s", self.m_ID, name))
		self.m_Actor:SetName(string.format("wid:%s-%s_actor", self.m_ID, name))
		-- name = string.format("wid:%s\npos:%s\n%s", self.m_ID, self.m_CampPos, name)
	end
	self:SetNameHud(name)
end

function CWarrior.GetName(self)
	return self.m_Name
end

--行为
function CWarrior.GoBack(self, iSpeed)
	if not self:IsAlive() then
		self:SetBusy(false, "go_back")
		return
	end
	local angle = self:GetDefalutRotateAngle()
	local cb = function (oWarrior)
		if Utils.IsExist(oWarrior) then
			oWarrior:SetBusy(false, "go_back")
		end
		return 0.2
	end
	self:RunTo(self.m_OriginPos, iSpeed, angle, cb)
end

function CWarrior.RunTo(self, endPos, iSpeed, endAngle, cb)
	if Utils.IsNil(self) then
		return
	end
	local curpos = self:GetLocalPos()
	local dis = WarTools.GetHorizontalDis(curpos, endPos)
	if dis > 0.01 then
		local notbusy = objcall(self, function(obj)
				obj:SetBusy(false, "RunTo")
			end)
		local onEnd = objcall(self, function(obj)
			if endAngle then
				obj.m_RotateObj:SetLocalEulerAngles(endAngle)
			end
			local iTime = 0.2
			obj:CrossFade("idleWar")
			if cb then
				local ret = cb(obj)
				if type(ret) == "number" then
					iTime = ret
				end
			end
			Utils.AddScaledTimer(notbusy, 0, iTime)	
		end)
		iSpeed = iSpeed or define.Warrior.Run_Speed
		local t = dis / iSpeed
		self:LookAtPos(endPos)
		self.m_Actor:AdjustSpeedPlay("run", 0.4)
		DOTween.OnComplete(DOTween.DOLocalMove(self.m_Transform, endPos, t), onEnd)
		self:SetBusy(true, "RunTo")
	else
		if cb then
			cb(self)
		end
		if endAngle then
			self.m_RotateObj:SetLocalEulerAngles(endAngle)
		end
	end
end

function CWarrior.FaceDefault(self)
	local angle = self:GetDefalutRotateAngle()
	if self.m_RotateObj:GetLocalEulerAngles() ~= angle then
		DOTween.DOLocalRotate(self.m_RotateObj.m_Transform, angle, 0.1)
	end
end

function CWarrior.LookAtPos(self, localPos, time)
	if Utils.IsNil(self) then
		return
	end
	local pos = self:GetLocalPos()
	local dir = WarTools.GetWorldDir(pos, localPos)
	if dir.x == 0 and dir.z == 0 then
		return
	end
	local time = time or 0
	local dirForward = self:InverseTransformDirection(dir)
	local dirUp = self:InverseTransformDirection(self.m_Transform.up)
	local r = Quaternion.LookRotation(dirForward, dirUp)
	if not self:IsBusy("floating") then
		DOTween.DOKill(self.m_RotateObj.m_Transform, false)
	end
	if time == 0 then
		self.m_RotateObj:SetLocalRotation(r)
	else
		DOTween.DOLocalRotateQuaternion(self.m_RotateObj.m_Transform, r, time)
	end
end

function CWarrior.Escape(self, success)
	self:StopHit()
	local dir = self:GetLocalForward() * -1
	local iRotateTime = 0.3
	self:LookAtPos(self:GetLocalPos() + dir, iRotateTime)
	self.m_Actor:LockState(nil)
	self:Play("run")
	self:SetBusy(true, "Escape")

	local function step(obj)
		if success then
			local iTime = 0.8
			local function onEnd()
				obj:SetBusy(false, "Escape")
				g_WarCtrl:DelWarrior(obj.m_ID)
			end
			local pos = obj:GetPos()
			local endPos = WarTools.OutViewPortPos(pos, dir*0.1, 0.8)
			DOTween.OnComplete(DOTween.DOMove(obj.m_Transform, endPos, 0.8), onEnd)
		else
			obj:CrossFade("die")
			local function idle(obj1)
				obj1:CrossFade("idleWar", 0.2)
				obj1:FaceDefault()
				obj1:SetBusy(false, "Escape")
			end
			Utils.AddScaledTimer(objcall(obj, idle), 0, 1.5)
		end
	end
	Utils.AddScaledTimer(objcall(self, step), 0, iRotateTime + 0.8)
end

function CWarrior.FlyOut(self)
	if Utils.IsNil(self) then
		return
	end
	local dir = self:GetLocalForward() * -1
	self:SetBusy(true, "FlyOut")

	local iTime = 0.8
	local iStartY = self.m_RotateObj:GetLocalEulerAngles().y
	local endRotate = Vector3.New(0, iStartY+1080, 0)
	DOTween.DOLocalRotate(self.m_RotateObj.m_Transform, endRotate, iTime, enum.DOTween.RotateMode.LocalAxisAdd)
	local pos = self:GetPos()
	local endPos = WarTools.OutViewPortPos(pos, dir*0.1, iTime)
	local function onEnd(obj)
		obj:SetBusy(false, "FlyOut")
		g_WarCtrl:DelWarrior(obj.m_ID)
	end
	DOTween.OnComplete(DOTween.DOMove(self.m_Transform, endPos, iTime), objcall(self, onEnd))
end

function CWarrior.Blink(self)
	if Utils.IsNil(self) then
		return
	end
	self:SetBusy(true, "Blink")
	local iStep = 0
	local iMaxStep = 2
	local function step(obj)
		if iStep > iMaxStep then
			obj:SetBusy(false, "Blink")
			g_WarCtrl:DelWarrior(obj.m_ID)
			return false
		end
		if iStep % 2 == 0 then
			Utils.HideObject(obj)
		else
			Utils.ShowObject(obj)
		end
		iStep = iStep + 1
		return true
	end
	Utils.AddScaledTimer(objcall(self, step), 0.1, 0)
end

function CWarrior.FadeDel(self)
	if not g_WarCtrl.m_ReciveResultProto then
		local function del(obj)
			obj:SetBusy(false, "FadeDel")
			g_WarCtrl:DelWarrior(obj.m_ID)
		end
		local c = self.m_Actor:GetMatColor()
		local action = CActionColor.New(self.m_Actor, 0.5,  "SetMatColor", Color.New(c.r, c.g, c.b, c.a * 0.5), Color.New(c.r, c.g, c.b, 0))
		action:SetEndCallback(objcall(self, del))
		g_ActionCtrl:AddAction(action)
		self:SetBusy(true, "FadeDel")
	end
end

function CWarrior.DelAndDie(self)
	if Utils.IsNil(self) then
		return
	end
	self:StopHit()
	if self:GetState() == "die" then
		self:FadeDel()
	else
		self.m_Actor:CrossFade("die", 0.1, 0, 1, callback(self, "FadeDel"))
	end
end

function CWarrior.Dodge(self)
	-- self:SetBusy(true, "Dodge")
	-- local iStep = 0
	-- local bGoBack = false
	-- local iSpeed = 0.1
	-- local iMaxStep = 0.75/ iSpeed
	-- local dir = self:InverseTransformDirection(self.m_RotateObj:GetForward())
	-- local function step()
	-- 	if Utils.IsNil(self) then
	-- 		return
	-- 	end
	-- 	if bGoBack then
	-- 		self:Translate(dir * iSpeed)
	-- 		iStep = iStep - 1
	-- 		if iStep < 0 then
	-- 			self:SetLocalPos(self.m_OriginPos)
	-- 			self:SetBusy(false, "Dodge")
	-- 			return false
	-- 		end
	-- 	else
	-- 		self:Translate(dir * -iSpeed)
	-- 		iStep = iStep + 1
	-- 		if iStep >= iMaxStep then
	-- 			bGoBack = true
	-- 		end
	-- 	end
	-- 	return true
	-- end
	-- Utils.AddScaledTimer(step, 0, 0)
end

function CWarrior.StartCheckEvent(self, state)
	self.m_EventState = {}
	local t = DataTools.GetAnimEventData(self:GetShape(), state)
	if t then
		for i, time in ipairs(t) do
			self.m_Actor:FixedEvent(state, time, callback(self, "InsertEventState", i))
		end
	end
end

function CWarrior.InsertEventState(self, iEvent, time)
	table.insert(self.m_EventState, iEvent)
end

function CWarrior.IsHeroOwn(self)
	if self.m_ID == g_WarCtrl.m_HeroWid then
		return true
	elseif self.m_OwnerWid and self.m_OwnerWid == g_WarCtrl.m_HeroWid then
		return true
	else
		return false
	end
end

function CWarrior.IsPlayerModel(self)
	return data.modeldata.PLAYER_MODEL[self:GetShape()]
end


function CWarrior.IsNpcWarriorTypeBoss(self)
	return self.m_NpcWarriorType == define.Warrior.NpcWarriorType.Boss
end

function CWarrior.GetMagicLevel(self, skid)
	local level = 0
	if next(self.m_MagicAndLevelList) then
		for i = 1, #self.m_MagicAndLevelList do
			local v = self.m_MagicAndLevelList[i]
			if type(v) == "table" and v.id and skid == v.id then
				level = v.level
				break
			end
		end
	end
	level = level or 0
	return level
end

function CWarrior.GetActor(self)
	return self.m_Actor
end

function CWarrior.IsCanOrder(self)
	if self.m_ID == g_WarCtrl.m_HeroWid then
		return true
	else
		return self.m_OwnerWid and (self.m_OwnerWid == g_WarCtrl.m_HeroWid)
	end
end

function CWarrior.HasBanSpBuff(self)
	local bufflist = {1018}
	for id, dBuff in pairs(self.m_Buffs) do
		if table.index(bufflist, id) then
			return true
		end
	end
	return false
end

return CWarrior