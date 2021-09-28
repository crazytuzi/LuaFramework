--伤害源特效
SourceEffect =BaseClass()
SourceEffect.Source_id = 10000

function SourceEffect:__init()
	self.id = SourceEffect.Source_id
	SourceEffect.Source_id = SourceEffect.Source_id + 1

	local go = GameObject.New("SourceEffect"..self.id)
	go.layer = LayerMask.NameToLayer("FlyEffect")
	self.gameObject = go
	self.transform = go.transform

	self.lifeTime = 0 --生命周期
	self.canFly = false
	self.moveHitTarget = nil --已受击列表
end

function SourceEffect:SetData(fighter, skillVo, moveModelVo)
	if fighter == nil or ToLuaIsNull(fighter.transform) then return end
	self.fighter = fighter
	self.skillVo = skillVo
	self.moveModelVo = moveModelVo
	self.moveHitTarget = {}
	local ftf =  self.fighter.transform
	self.transform.localRotation = ftf.localRotation
	self.transform.position = ftf.position

	local targetPos = ftf.position + ftf.forward*(self.moveModelVo.n32Distance *0.01)
	self.speed = self.moveModelVo.n32Speed *0.01
	self.direct = (targetPos - ftf.position):Normalize()
	local time = (self.moveModelVo.n32Distance *0.01) / (self.moveModelVo.n32Speed *0.01)
	self.lifeTime = time

	local effectName = self.moveModelVo.MovePartical[1]
	if effectName then
		EffectMgr.BindTo(effectName, self.gameObject, self.lifeTime)
	end

	self.canFly = false
end

function SourceEffect:Play()
	DelayCall(function() 
		self.canFly = true
	end, 0.22)
end

function SourceEffect:Update()
	if not self.canFly then return end
	if self.lifeTime <= 0 then
		EffectTool.RemoveEffect(self.effect, true)
		SceneController:GetInstance():GetScene():RemoveSourceEffect( self.id )
	else
		self:Move()
		self:Check()
	end
	self.lifeTime = self.lifeTime - Time.deltaTime
end

function SourceEffect:Move()
	self.transform.position = self.transform.position + self.direct * self.speed * Time.deltaTime
end

function SourceEffect:Check()
	if ToLuaIsNull(self.fighter.transform) or ToLuaIsNull(self.transform) then return end
	local targetList = SkillManager.ResultTargetCheck(self.skillVo, self.moveModelVo, self.transform, self.fighter)
	if targetList and #targetList > 0 then
		local newHitTargets = {}
		for i = 1, #targetList do
			local hit = true
			for j = 1, #self.moveHitTarget do
				if self.moveHitTarget[j] == targetList[i] then
					hit = false
					break
				end
			end
			if hit then
				table.insert(self.moveHitTarget, targetList[i])		
				table.insert(newHitTargets, targetList[i])			
			end
		end
		if #newHitTargets > 0 then
			SkillManager.SendSkillAffectTargets(self.fighter.guid, self.skillVo.un32SkillID, newHitTargets, self.fighter, 
												self.moveModelVo.asSkillModelList[1], nil, newHitTargets[1].guid)
		end
	end
end

function SourceEffect:SetFlyEffect( gameObject, pos )
	LivingThing.SetFlyEffect(self, gameObject, pos)
end

function SourceEffect:__delete()
	if self.gameObject then	-- 清理VO的事件
		destroyImmediate(self.gameObject)
	end
	self.gameObject = nil
	self.transform = nil
	self.emptyPos = nil
	self.moveHitTarget = nil	
end