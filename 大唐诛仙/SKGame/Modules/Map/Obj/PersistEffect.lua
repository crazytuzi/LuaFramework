PersistEffect =BaseClass()

PersistEffect.id = 10000
function PersistEffect:__init(skillId, fighterGuid, releasePoint, leftTime, createGuid, delay)
	PersistEffect.id = PersistEffect.id + 1
	self.guid = createGuid or PersistEffect.id

	self.skillVo = SkillVo.New(skillId)

	self.fighterGuid = fighterGuid
	local scene = SceneController:GetInstance():GetScene()
	self.scene = scene
	self.fighter = scene:GetPlayer( self.fighterGuid ) or scene:GetMon( self.fighterGuid )
	self.rangeModelVo = self.skillVo.dependModelList[1]
	self.releasePoint = releasePoint
	self.delay = delay or 0

	if leftTime then
		self.leftTime = leftTime *0.001
	else
		self.leftTime = tonumber(self.rangeModelVo.n32LifeTime) *0.001
	end

	self.targets = {}
	self.canDestory = false

	local go = GameObject.New("PersistEffect"..self.guid)
	go.layer = LayerMask.NameToLayer("FlyEffect")
	self.gameObject = go
	self.transform = go.transform
	self.transform.position = self.releasePoint
	if self.fighter and not ToLuaIsNull(self.fighter.transform) then
		self.transform.localRotation = self.fighter.transform.rotation
	else
		self.transform.localRotation = Quaternion.Euler(0, 0, 0)
	end

	self.eftId = nil
	if not self.rangeModelVo or not self.rangeModelVo.RangePartical or not self.rangeModelVo.RangePartical[1] then return end
	self.eftId = EffectMgr.BindTo(self.rangeModelVo.RangePartical[1], self.gameObject, nil, nil, nil, nil, function(eid)
		self.effectObj = EffectMgr.GetEffectById(eid)
	end)
end

--持续性特效更新
function PersistEffect:Update()
	if self.delay > 0 then 
		self.delay = self.delay - Time.deltaTime
		return
	end
	if ToLuaIsNull(self.transform) then return end
	if self.canDestory then return end
	if self.leftTime <= 0 then 
		self.canDestory = true
		self:RemovePersistEffect()
	else
		--检测目标:先添加新的目标，再移除移出范围的目标
		local targetList = SkillManager.ResultTargetCheck(self.skillVo, self.rangeModelVo, self.transform, self.fighter or self.fighterGuid)
		if targetList and #targetList > 0 then
			local target = nil
			for i = 1, #targetList do --新目标
				target = targetList[i]
				local oldTargets = self.targets
				local inList = false
				for k, v in pairs(oldTargets) do --是否已在该特效目标列表
					if k == target then
						inList = true
						break
					end
				end
				if not inList then --不在该特效目标列表,检测是否在其他特效目标列表,防止叠加伤害
					local persistEffectList = self.scene.persistEffectList
					for i = 1, #persistEffectList do
						local otherTargets = persistEffectList[i].targets
						for k, _ in pairs(otherTargets) do
							if target == k then
								inList = true
								break
							end
						end
						if inList then break end
					end
				end
				if not inList then
					oldTargets[target] = {}
					oldTargets[target]["interval"] = 0
				end
			end

			local newTargets = self.targets
			for k, v in pairs(newTargets) do --检测是否有目标移出了范围
				local isOut = true
				for i = 1, #targetList do
					if targetList[i] == k then
						isOut = false
						break
					end
				end
				if isOut then
					newTargets[k] = nil
				end
			end
			self:PersistEffectHandle()
		end
	end
	self.leftTime = self.leftTime - Time.deltaTime
end

--移除检测
function PersistEffect:RemovePersistEffect()
	if self.canDestory == true then
		self.scene:RemoveWigSkill(self.guid)
	end
end

--持续特效效果处理
function PersistEffect:PersistEffectHandle()
	if self.canDestory then return end
	local targets = self.targets
	local maxInterval = self.rangeModelVo["n32RangeTimes"] *0.001
	local hurtTargets = {}
	for k, v in pairs(targets) do
		local target = k
		local interval = v["interval"]
		if interval <= 0 and not target:IsDie() then --触发结算
			table.insert(hurtTargets, target)
			v["interval"] = maxInterval
		else --跑结算cd
			v["interval"] = interval - Time.deltaTime
		end
	end

	if #hurtTargets > 0 then
		SkillManager.SendSkillAffectTargets(self.fighterGuid, self.skillVo.un32SkillID, hurtTargets, self.fighter, 
		self.rangeModelVo.dependModelList[1].un32SkillModelID, self.guid, hurtTargets[1].guid)
	end
end

function PersistEffect:__delete()
	if self.eftId then 
		EffectMgr.RealseEffect(self.eftId)
		self.eftId = nil
	end
	if self.gameObject then	-- 清理VO的事件
		destroyImmediate(self.gameObject)
	end
	self.gameObject = nil
	self.transform =nil
	self.skillVo = nil
	self.fighter = nil
	self.rangeModelVo = nil
	self.releasePoint = nil
	self.targets = nil
	self.canDestory = false
end