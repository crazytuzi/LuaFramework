WarningEffect =BaseClass()
WarningEffect.WarningId = 100000

function WarningEffect:__init( vo )
	self.warningId = WarningEffect.WarningId
	WarningEffect.WarningId = WarningEffect.WarningId + 1

	local go = GameObject.New("WarningEffect"..self.warningId)
	go.layer = LayerMask.NameToLayer("FlyEffect")
	self.gameObject = go
	self.transform = go.transform

	self.lifeTime = 0 --生命周期
end

function WarningEffect:CreateEffect(effectName, target, lifeTime, targetPos, scale, isSetTargetParent)
	if target == nil or ToLuaIsNull(target.transform) then return end
	local ttf = target.transform
	self.lifeTime = lifeTime * 0.001
	self.transform.localRotation = ttf.localRotation
	self.transform.position = ttf.position

	self.effectKey = EffectMgr.BindTo(effectName, self.gameObject, self.lifeTime, nil, nil, nil, function(eid)
		local effect = EffectMgr.GetEffectById(eid)	
		effect.transform.localScale = scale				
	end)

	if targetPos then
		self.transform.position = targetPos
	end
	if isSetTargetParent then
		self.transform.parent = ttf
		self.transform.position = Vector3.zero
		self.transform.localPosition = targetPos
	end

end

function WarningEffect:Update()
	self.lifeTime = self.lifeTime - Time.deltaTime
	if self.lifeTime <= 0 then
		self:Release()
	end
end

function WarningEffect:Release()
	SceneController:GetInstance():GetScene():RemoveWarn( self.warningId )
end

function WarningEffect:__delete()
	-- 清理VO的事件
	if self.gameObject then	-- 清理VO的事件
		destroyImmediate(self.gameObject)
	end
	EffectMgr.RealseEffect(self.effectKey)
	self.gameObject = nil
	self.transform =nil
end