BattleManager =BaseClass()

-- local distance = skillVo.distance*MapUtil.S2C -- 射程
-- local beStorage = skillVo.beStorage -- 是否蓄力 蓄力不可被打断 0=不蓄力 1=蓄力
-- local singAction = skillVo.singAction -- 吟唱动作
-- local singTime = skillVo.singTime/1000 -- 吟唱时间毫秒
-- local singanimation -- 吟唱特效
-- local aimanimation -- 瞄准特效
-- local attackAction -- 施法动作
-- local attackanimation -- 施法特效
-- local flyingAnimation -- 弹道飞行特效
-- local bombAnimation -- 爆炸特效
-- local runinterval -- 作用间隔时间
-- local lasttime -- 持续时间
-- local flySpeed -- 弹道速度
-- local rundelay -- 生效时间（用于无弹道技能）
-- local attacknum -- 攻击次数
-- local beMove-- 是否移动判定 0=不移动判定 1=移动判定（对弹道4，8，9作用)
-- local beTrack-- 是否跟踪 0=不跟踪 1=跟踪 （对弹道3，4，5，6作用）
-- local areaType-- 范围类型 0=单体 1=矩形 2=扇形 3=圆形 4=职业点名 5=随机点名 6=全屏反选
-- local areaValue1-- 范围参数1 0:无 1:长 2:半径 3:半径 4:职业ID 5:目标数量
-- local areaValue2-- 范围参数2 0:无 1:宽 2:角度 3:无 4:无 5:无
-- local areaValue3-- 范围参数3 0:无 1:无 2:无 3:无 4:无 5:无
-- local ballisticType-- 弹道类型 1=目标点 2=自身锚点 3=单向抛物 4=单向直射 5=雨系降落 6=冲锋 7=瞬移 8=3方向直射 9=6方向直射

BattleManager.Auto = 0
BattleManager.TYPE = {
	NONE = -1,
	HATE = 0, -- 仇敌
	MONSTER = 1, -- 怪物
	FRIEND = 2, -- 队友(支援)
}

BattleManager.LockTarget = nil

--寻找攻击目标
function BattleManager.FindAttackTarget(previewType, distance, isAutoFight)
	local scene = SceneController:GetInstance():GetScene()
	if not scene or not scene:GetMainPlayer() then return end
	local mainPlayer = scene:GetMainPlayer()
	local mixtureList = scene:GetEnemies(mainPlayer.guid)
	local targetRangeList = {}
	local target = nil
	local maybeTargets = BattleManager.MapFilter(mixtureList)

	local mtf = mainPlayer.transform
	if maybeTargets then
		if isAutoFight then  --自动挂机
			local origaltargets = MapUtil.GetRangeTargets(mtf, maybeTargets, 360, distance)
			local targets = BattleManager.DefaultTargetFilter(origaltargets)
			local minHpTarget = nil
			local filterTemp = {}
			for i = 1, #targets do
				local tar = targets[i]
				if not tar:IsDie() then
					local tempVo = {}
					tempVo.index = i
					tempVo.hpPercent = tar.vo.hp/tar.vo.hpMax
					tempVo.distance = Vector3.Distance(mtf.position, tar.transform.position)
					table.insert(filterTemp, tempVo)
				end
			end
			SortTableBy2Key(filterTemp, "hpPercent", "distance", true, true)
			if filterTemp[1] then
				return targets[filterTemp[1].index]
			else
				return nil
			end
		end
		if previewType == PreviewType.PointToCenterSector90 then --指向扇形中心线单选(90°)
			return MapUtil.GetRangeMinAngleTarget(mtf, maybeTargets, 90, distance)
		else
			local fightTarget = nil
			--1级目标:角色正前方90°选择
			fightTarget = MapUtil.GetRangeTargets(mtf, maybeTargets, 359, distance)
			if fightTarget then
				fightTarget = MapUtil.GetNearestTarget(mtf, fightTarget)
			end

			--2级目标:施法范围圆形选择
			if not fightTarget then
				fightTarget = MapUtil.GetRangeNearestTarget(mainPlayer, maybeTargets, distance)

			end

			return fightTarget
		end
	else
		return nil
	end
end

--地图目标过滤
function BattleManager.MapFilter(targets)
	local sceneModel = SceneModel:GetInstance()
	local mapPkModel = sceneModel:GetPkModel()
	if mapPkModel == 1 then --和平地图（怪）
		local filterTarget = {}
		for i = 1, #targets do
			local target  = targets[i]
			if target and target:IsMonster() then
				table.insert(filterTarget, target)
			end
		end
		return filterTarget
	end

	if mapPkModel == 2 then --安全地图(怪, 红名玩家)
		local filterTarget = {}
		for i = 1, #targets do
			local target  = targets[i]
			if target and (target:IsMonster() or (target:IsHuman() and target.vo and target.vo.nameColor == 3) or 
				(target:IsSummonThing() and target:GetOwnerPlayer() and target:GetOwnerPlayer().vo and (target:GetOwnerPlayer().vo.nameColor == 2 or target:GetOwnerPlayer().vo.nameColor == 3)) ) then
				table.insert(filterTarget, target)
			end
		end
		return filterTarget
	end

	if mapPkModel == 3 or mapPkModel == 4 then --pk地图(走pk模式过滤)
		return BattleManager.PkModelFilter(targets)
	end
end

--pk模式目标过滤
function BattleManager.PkModelFilter(targets)
	if targets == nil then return nil end
	local mainRole = SceneModel:GetInstance():GetMainPlayer()
	if not mainRole then return {} end

	local pkModel = mainRole.pkModel --PK模式 1:和平 2:善恶 3:帮派 4:家族 5:全体 
	if pkModel == PkModel.Type.All then --5:全体(怪, 所有玩家)
		return targets
	end

	if pkModel == PkModel.Type.Peace then --和平(怪)
		local filterTarget = {}
		for i = 1, #targets do
			local target  = targets[i]
			if target and target:IsMonster() then
				table.insert(filterTarget, target)
			end
		end
		return filterTarget
	end

	if pkModel == PkModel.Type.Family then --家族(怪, 非本家族玩家, 非本家族玩家的召唤兽)
		return targets
	end

	if pkModel == PkModel.Type.Clan then --帮派(怪, 非本帮派玩家, 非本帮派玩家的召唤兽)
		return targets
	end

	if pkModel == PkModel.Type.GoodEvil then --善恶(怪, 灰名、红名玩家，灰名、红名玩家的召唤兽)
		local filterTarget = {}
		for i = 1, #targets do
			local target  = targets[i]
			if target and (target:IsMonster() or (target:IsHuman() and (target.vo.nameColor == 2 or target.vo.nameColor == 3) ) or 
				(target:IsSummonThing() and target:GetOwnerPlayer() and target:GetOwnerPlayer().vo and (target:GetOwnerPlayer().vo.nameColor == 2 or target:GetOwnerPlayer().vo.nameColor == 3) )) then
				table.insert(filterTarget, target)
			end
		end
		return filterTarget
	end
end

--自动战斗，目标选择默认过滤器
function BattleManager.DefaultTargetFilter(targets)
	local rtnTargets = {}
	if targets ~= nil then
		for i = 1 , #targets do
			local curTarget = targets[i]
			if curTarget then
				if (curTarget:IsHuman() and curTarget.vo and curTarget.vo.playerId and ZDModel:GetInstance():IsTeamMate(curTarget.vo.playerId))  or
					(curTarget:IsSummonThing() and curTarget:GetOwnerPlayer() and curTarget:GetOwnerPlayer().vo and curTarget:GetOwnerPlayer().vo.playerId and ZDModel:GetInstance():IsTeamMate(curTarget:GetOwnerPlayer().vo.playerId)) then
				else
					table.insert(rtnTargets , curTarget)
				end
			end
		end
	end
	return rtnTargets
end

function BattleManager:__init(battleVo, obj, scene) -- , sceneCtrl

	self:InitEvent()

	self.id = BattleManager.Auto
	self.info = {} -- 信息列表 {skillVo, 可攻击列表, 对象处理[0：位置，1：对象], 当前}
	self.autoMove = false -- 需要自动移动

	BattleManager.Auto = BattleManager.Auto + 1
	self.type = battleVo.type --施法类型
	self.skillVo = battleVo.skillVo --技能vo
	self.fightDir = battleVo.dirAngle --方向
	self.targetObj = battleVo.monster --技能目标
	self.targetPoint = battleVo.targetPoint --目标释放点
	self.isAiControl = battleVo.isAiControl --是否ai触发技能
	self.fightDistance = self.skillVo.fReleaseDist * 0.01
	self.fighter = obj --攻击者
	self.scene = scene --场景view
	self.inited = true

	--(ai控制)或者(目标为敌人且没有选定目标),则执行自动选定目标和攻击方向逻辑
	if self.isAiControl or (not self.targetObj and self.skillVo.eSkillTargetCate == 4) then 
		if BattleManager.LockTarget and not BattleManager.LockTarget:IsDie() and not ToLuaIsNull(BattleManager.LockTarget.transform) and 
			Vector3.Distance(self.fighter.transform.position, BattleManager.LockTarget.transform.position) <= self.fightDistance then
			self.targetObj = BattleManager.LockTarget
		else
			self.targetObj = BattleManager.FindAttackTarget(self.type, self.fightDistance) --尝试搜索范围目标
		end

		BattleManager.LockTarget = self.targetObj

		if battleVo.canAutoAim and self.targetObj then
			local fightRot = MapUtil.GetRotation(self.fighter.transform.position, self.targetObj.transform.position)
			self.fightDir = fightRot and fightRot.eulerAngles.y or 0
		end
	end

	self.fighter:SetBattle(self)
	if self.type == PreviewType.GroundAttack then --地面施法
		if self.isAiControl then
			self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, "-1", self.skillVo.un32SkillID, self.fightDir, nil, nil, self.targetObj.transform.position, self.isAiControl)
		else
			self.fightDir = MapUtil.NoDirMark --不做转向操作
			self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, "-1", self.skillVo.un32SkillID, self.fightDir, nil, nil, self.targetPoint, self.isAiControl)
		end
	elseif self.skillVo.eSkillTargetCate == 4 then --目标为敌人
		if self.targetObj then --目标不为空
			if self.skillVo.skillType == 1 then --发射技能 需转向目标
				self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, self.targetObj.guid, self.skillVo.un32SkillID, self.fightDir, self.targetObj, self.skillVo.fReleaseDist / 100, self.targetPoint, self.isAiControl)
			elseif self.skillVo.skillType == 2 then -- 冲锋技能 需转向但不锁定目标
				self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, MapUtil.NoTargetMark, self.skillVo.un32SkillID, self.fightDir, self.targetObj, self.skillVo.fReleaseDist / 100, self.targetPoint, self.isAiControl)
			else --非发射非冲锋技能
				self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, self.targetObj.guid, self.skillVo.un32SkillID, self.fightDir, self.targetObj, self.skillVo.fReleaseDist / 100, self.targetPoint, self.isAiControl)
			end
		else --空放逻辑
			if self.skillVo.bIfNomalAttack ~= 1 and self.skillVo.skillType == 1 then --非普攻且是发射技能且范围内没有目标则不能空放
				Message:GetInstance():TipsMsg(SkillTipsConst.NoAttackTarget)
			else
				self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, "-1", self.skillVo.un32SkillID, self.fightDir, nil, nil, nil, nil)
			end
		end
	elseif self.skillVo.eSkillTargetCate == 1 then --目标为自身
		self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, self.fighter.guid, self.skillVo.un32SkillID, self.fightDir, nil, nil, nil, self.isAiControl)
	elseif self.skillVo.eSkillTargetCate == 6 then --所有友方单位
		self.fighter:SkillTrigger(self.skillVo.skillAudio, self.type, self.fighter.guid, self.skillVo.un32SkillID, self.fightDir, nil, nil, nil, self.isAiControl)
	end
end

-- function BattleManager:Update()
-- 	if not self.inited then return end
-- end

function BattleManager:InitEvent()
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.PkModelChange , function(data) self:HandlePkModelChange(data) end)
end

function BattleManager:HandlePkModelChange(data)
	BattleManager.LockTarget = nil
end

function BattleManager:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler4)
end

function BattleManager:__delete()
	self:CleanEvent()
	self.inited = false
end