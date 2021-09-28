--公共技能管理
SkillManager =BaseClass()

--使用技能
--@param fighter
--@param fightVo
function SkillManager.UseSkill(fighter, fightVo)
	local skill = SkillManager.GetSkill(fighter, fightVo.fightType)
	if skill then
		skill:UseSkill(fightVo)
	end
end

--获取技能
--@param fighter
--@param id
function SkillManager.GetSkill(fighter, id)
	local skillVo = SkillManager.GetSkillVo(id)
	if skillVo then
		local skill = Skill.New()
		skill:Init(fighter, skillVo, true)
		return skill
	end
	return nil
end

--获取技能Vo
function SkillManager.GetSkillVo(id)
	local skillVo = SkillVo.New(id)
	return skillVo
end

--获取技能表Vo
function SkillManager.GetStaticSkillVo(skillId)
	return GetCfgData("skill_CellNewSkillCfg"):Get(skillId) 
end

--获取模块数据
--@param id 模型数据id
function SkillManager.GetModelVoById(id)
	local CfgName = SkillVo.ModelCfgName
	local tmp = GetCfgData(CfgName.BufCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.EmitCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.MoveCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.RangeCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.SwitchCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.SummonCfg):Get(id)
	if tmp then return tmp end
	tmp = GetCfgData(CfgName.AccountCfg):Get(id)
	if tmp then return tmp end
	return nil
end

-----------------------------------功能接口 start-----------------------------------
--添加爆炸特效
function SkillManager:AddBomEffect(fighter, skillId)
	local skillVo = SkillManager.GetSkillVo( skillId )
	if #skillVo.bombAnimation > 0 and skillVo.targetType == SkillTargetType.Enemy then
		if skillVo.areaType == AreaType.OrganCircular then--机关点圆形
			if skillVo.targetType == SkillTargetType.My then
				local tarGridList = SkillManager.GetOrganCircularPos(self._figther, skillVo)
				if #tarGridList > 0 then--有坐标算出显示的特效
					-- for i = 1, #tarGridList do
					-- 	local grid = tarGridList[i]
					-- 	local ppos = Vector3.New(MapUtil.GridToLocalX(grid[1]), 0, MapUtil.GridToLocalX(grid[2]))
					-- 	EffectTool.AddEffect(self._figther.modelId, skillVo.bombAnimation, myPlayer, 0, false, nil, ppos, Vector3.New(grid[3], grid[3], grid[3]))
					-- end
				end
			end
		else
			local warningEffect = SceneController:GetInstance():GetScene():GetWarnByIndex( 1 )
			-- print(" ******************* 预警是否存在  ",warningEffect)
			if warningEffect then
				-- EffectTool.AddEffect(fighter.modelId, skillVo.bombAnimation, self._figther, nil, false, nil, warningEffect.transform.position)
				warningEffect:Release()
			else
			end
		end
	end
end

--获取机关点坐标
function SkillManager.GetOrganCircularPos(fighter, pointList)
	local fpos = fighter.transform.position
	local tarGridX = MapUtil.LocalToGridX( fpos.x )
	local tarGridZ = MapUtil.LocalToGridX( fpos.z )
	local tarGridList = {}

	if #pointList > 0 then--有坐标算出显示的特效
		for i = 1, #pointList do
			local v = pointList[i]
			table.insert(tarGridList, {tarGridX + v[1], tarGridZ + v[2], v[3] * 0.01})
		end
	end
	return tarGridList
end

--技能命中目标检测
--@param skillVo 技能数据
--@param modelVo 模块数据
--@param modelVo 模块数据
--@param judgeSource 检测源
--@param fighterOrGuid 战斗对象orGuid
--@param judgeSource 必中目标
function SkillManager.ResultTargetCheck(skillVo, modelVo, judgeSource, fighterOrGuid, hitTarget)
	local scene = SceneController:GetInstance():GetScene()
	local targetList = {}
	local enemy = nil
	--检测上层模块的判定源
	local judgeSourceTrans = judgeSource

	local fighter = nil
	if fighterOrGuid and not ToLuaIsNull(fighterOrGuid.transform) then
		fighter = fighterOrGuid
	else
		fighter = scene:GetThing(fighterOrGuid)
	end

	local enemyList = nil
	if fighter then
		if skillVo.eSkillTargetCate == 1 then --自己
			enemyList = {}
			table.insert(enemyList, fighter)
		elseif skillVo.eSkillTargetCate == 4 then --敌人
			enemyList = scene:GetEnemies(fighter.guid)
			if fighter:IsMainPlayer() or 
			   (fighter:IsSummonThing() and fighter.owner and fighter.owner.guid == scene:GetMainPlayer().guid) then
				enemyList = BattleManager.MapFilter(enemyList)  --角色|召唤物需要经过pk模式过滤
			end
		elseif skillVo.eSkillTargetCate == 6 then --所有友方单位
			enemyList = scene:GetFriends(fighter.guid, true)
		end
	end

	if enemyList == nil or #enemyList < 1 then return targetList end

	if modelVo.eSkillModelType == SkillVo.ModelType.RangeModel and judgeSourceTrans then
		local rangeTargets = {}
		if modelVo.eSkillShapeType == 1 then --矩形
			local length = modelVo.n32RangePar1[1][3] * 0.01
			local broad = (modelVo.n32RangePar2 * 0.01)*2 --n32RangePar2为左右变宽
			for i = 1, #enemyList do
				enemy = enemyList[i]
				local etf = enemy.transform
				if fighter then
					if not ToLuaIsNull(etf) and MapUtil.IsOnRect(judgeSourceTrans, etf, broad, length) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				else
					if not ToLuaIsNull(etf) and MapUtil.IsOnRect(judgeSourceTrans, etf, broad, length) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				end
			end
		elseif modelVo.eSkillShapeType == 2 then --扇形			
			local angle = 0
			local radius = 0 
			for i = 1, #enemyList do
				enemy = enemyList[i]
				angle = modelVo.n32RangePar2
				radius = modelVo.n32RangePar1[1][3] * 0.01 + enemy.hitRadius
				local etf = enemy.transform
				if fighter then
					if not ToLuaIsNull(etf) and MapUtil.IsOnSector(judgeSourceTrans, etf, angle, radius) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				else
					if not ToLuaIsNull(etf) and MapUtil.IsOnSector(judgeSourceTrans, etf, angle, radius) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				end
			end
		elseif modelVo.eSkillShapeType == 3 then --圆形
			local radius = 0 
			for i = 1, #enemyList do
				enemy = enemyList[i]
				radius = modelVo.n32RangePar1[1][3] * 0.01 + enemy.hitRadius
				local etf = enemy.transform
				if fighter then
					if not ToLuaIsNull(etf) and MapUtil.IsOnCircle(judgeSourceTrans, etf, radius) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				else
					if not ToLuaIsNull(etf) and MapUtil.IsOnCircle(judgeSourceTrans, etf, radius) then
						local targetinfo = {}
						targetinfo.target = enemy
						targetinfo.distance = Vector3.Distance(judgeSourceTrans.position, etf.position)
						table.insert(rangeTargets, targetinfo)
					end
				end
			end
		end

		SortTableByKey(rangeTargets, "distance", false)
		--是否有个数限制
		local eftCount = 0
		if modelVo.n32MaxEffectObj == 0 then --没有目标个数限制
			eftCount = #rangeTargets
		else --有效果数限制
			eftCount = modelVo.n32MaxEffectObj
		end
		for i = 1, eftCount do
			if rangeTargets[i] then
				table.insert(targetList, rangeTargets[i].target)				
			end
		end

	elseif modelVo.eSkillModelType == SkillVo.ModelType.EmitModel  then
		if hitTarget and not hitTarget:IsDie() then
			table.insert(targetList, hitTarget)
		end
	elseif modelVo.eSkillModelType == SkillVo.ModelType.BufModel and fighter  then
		if not fighter:IsDie() then
			table.insert(targetList, fighter)
		end
	elseif modelVo.eSkillModelType == SkillVo.ModelType.MoveModel and modelVo.IfMoveAttack == 1 then --移动
		local radius = 0 
		for i = 1, #enemyList do
			enemy = enemyList[i]
			radius = modelVo.IfRangeAttack * 0.01 + enemy.hitRadius
			local etf = enemy.transform
			if fighter then
				if fighter.guid ~= enemy.guid and not ToLuaIsNull(etf) and MapUtil.IsOnCircle(judgeSourceTrans, etf, radius) then
					table.insert(targetList, enemy)
				end
			else
				if fighterOrGuid ~= enemy.guid and not ToLuaIsNull(etf) and MapUtil.IsOnCircle(judgeSourceTrans, etf, radius) then
					table.insert(targetList, enemy)
				end
			end
		end
	end
	return targetList
end

--发送技能影响目标
--@param guid 目标Id 
--@param skillId 技能Id 
--@param targets 目标Id列表 
--@param figther 战斗对象 
--@param accountModelId 结算模块Id 
--@param wigId 地效Id 
--@param permissionGuid 同步权限guid 
function SkillManager.SendSkillAffectTargets(guid, skillId, targets, figther, accountModelId, wigId, permissionGuid)
	if not guid then
		-- debugFollow()
		logWarn("攻击源为空............")
	end
	if targets == nil or #targets < 1 or not guid then return end
	local msg = {}
	msg.guid = guid
	msg.skillId = skillId
	msg.targetIds = {}
	msg.figther = figther
	msg.permissionGuid = permissionGuid
	for i = 1, #targets do
		local target = targets[i]
		if not target:IsDie() then
			if target:IsSummonThing() and target.owner then 
				msg.permissionGuid = target.owner.guid --如果攻击目标中有玩家召唤物，则由该召唤物主人完成这次受击同步
			end
			table.insert(msg.targetIds, target.guid)
		end
	end
	msg.accountModelId = accountModelId
	msg.wigId = wigId
	GlobalDispatcher:DispatchEvent(EventName.Hit, msg)
end

-----------------------------------功能接口 end-----------------------------------