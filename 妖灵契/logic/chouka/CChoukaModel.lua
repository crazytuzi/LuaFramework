local CChoukaModel = class("CChoukaModel", CMapWalker)

function CChoukaModel.ctor(self, iType)
	CMapWalker.ctor(self)
	self:SetLayerDeep(UnityEngine.LayerMask.NameToLayer("CreateRole"))
	self.m_Actor:SetRoot(nil)
	self.m_Type = iType
	self:RefreshShape()
end


function CChoukaModel.OnChangeDone(self)
	self.m_Actor:SetModelOutline(0.01)
	self:SetLocalScale(Vector3.New(2, 2, 1))
	self:SetLayerDeep(self.m_GameObject.layer)
	--self:DoEffect()
end

function CChoukaModel.RefreshShape(self)
	if self.m_Type == 1 then
		self:ChangeShape(3007, {})
	else
		self:ChangeShape(3008, {})
	end
	self:InitPosType()
end

function CChoukaModel.InitPosType(self)
	if self.m_Type == 1 then
		self:SetLocalPos(Vector3.New(-1.5, 0.5, 0.1))
		self:SetLocalRotation(Vector3.New(0, 180, 0))
	else
		self:SetLocalPos(Vector3.New(1.5, 0.5, 0.1))
		self:SetLocalRotation(Vector3.New(0, 180, 0))
	end
end



return CChoukaModel