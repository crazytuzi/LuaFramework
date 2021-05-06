local CChainEffect = class("CChainEffect", CEffect)

function CChainEffect.ctor(self, path, layer, cached, cb)
	CEffect.ctor(self, path, layer, cached, cb)

	self.m_BeginObj = nil
	self.m_EndObj = nil
	self.m_Timer = nil
	self.m_LastBeginPos = nil
	self.m_LastEndPos = nil
end

function CChainEffect.CheckTimer(self)
	if not self.m_Timer and self.m_BeginObj and self.m_EndObj then
		self.m_Timer = Utils.AddTimer(callback(self, "UpdatePerFrame"), 0, 0)
	end
end

function CChainEffect.SetBeginObj(self, beginTrans)
	self.m_BeginObj = CObject.New(beginTrans.gameObject)
	self:CheckTimer()
end

function CChainEffect.SetEndObj(self, endTrans)
	self.m_EndObj = CObject.New(endTrans.gameObject)
	self:CheckTimer()
end

function CChainEffect.UpdatePerFrame(self)
	if Utils.IsExist(self.m_BeginObj) and Utils.IsExist(self.m_EndObj) then
		if self.m_BeginObj:GetActiveHierarchy() and self.m_EndObj:GetActiveHierarchy() then
			local layer = Utils.g_HiderLayer 
			if self.m_BeginObj:GetLayer() ~= layer and self.m_EndObj:GetLayer() ~= layer then
				local vBeginPos = self.m_BeginObj:GetPos()
				if self.m_LastBeginPos ~= vBeginPos then
					self:SetPos(vBeginPos)
					self.m_LastBeginPos = vBeginPos
				end
				local vEndPos = self.m_EndObj:GetPos()
				if self.m_LastEndPos ~= vEndPos then
					local dis = Vector3.Distance(vBeginPos, vEndPos)
					self:LookAt(vEndPos, self.m_EndObj:GetUp())
					self:SetLocalScale(Vector3.New(1, 1, dis))
					-- self:SetTiling(dis, 0)
					self.m_LastEndPos = vEndPos
				end
			else
				self:SetLocalScale(Vector3.New(0, 0, 0))
			end
		else
			self:SetLocalScale(Vector3.New(0, 0, 0))
		end
	else
		self:SetLocalScale(Vector3.New(0, 0, 0))
		self.m_Timer = nil
		return false
	end
	return true
end

function CChainEffect.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_BeginObj = nil
	self.m_EndObj = nil
	CEffect.Destroy(self)
end

return CChainEffect