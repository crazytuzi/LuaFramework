local CObject = class("CObject", CDelayCallBase)

function CObject.ctor(self, obj)
	CDelayCallBase.ctor(self)
	self.m_GameObject = obj
	self.m_Transform = obj.transform
	self.m_InstanceID = nil
	self.m_CacheKey = ""
	self.m_UITweeners = nil
	self.m_DestroyOnRecycle = nil
	self.m_FindTrans = {}
	self.m_IsDestroy = false
end

function CObject.GetTransform(self)
	return self.m_Transform
end

function CObject.InitUITwener(self, bChilds)
	if not self.m_UITweeners then
		local list1 = Utils.ArrayToList(self:GetComponents(classtype.UITweener))
		if bChilds then
			local list2 = Utils.ArrayToList(self:GetComponentsInChildren(classtype.UITweener, true))
			self.m_UITweeners = table.extend(list1, list2)
		else
			self.m_UITweeners = list1
		end
	end
end

function CObject.AddDestroyOnRecycle(self, obj)
	if not self.m_DestroyOnRecycle then
		self.m_DestroyOnRecycle = {}
	end
	table.insert(self.m_DestroyOnRecycle, weakref(obj))
end

function CObject.Recycle(self)
	if self.m_DestroyOnRecycle then
		for _, ref in pairs(self.m_DestroyOnRecycle) do
			local obj = getrefobj(ref)
			if obj then
				obj:Destroy()
			end
		end
		self.m_DestroyOnRecycle = nil
	end
end

function CObject.SetUITweenDuration(self, iTime)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener.duration = iTime
	end
end

function CObject.UITweenPlay(self)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener:ResetToBeginning()
		tweener:PlayForward()
	end
end

function CObject.UITweenStop(self)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener.tweenFactor = 1
	end
end

function CObject.UITweenEnabled(self, enabled)
	self:InitUITwener()
	for i, tweener in ipairs(self.m_UITweeners) do
		tweener.enabled = enabled
	end
end


function CObject.SetCacheKey(self, sPath)
	self.m_CacheKey = sPath
end

function CObject.GetCacheKey(self)
	return self.m_CacheKey
end

function CObject.GetForward(self)
	return self.m_Transform.forward
end

function CObject.SetForward(self, v)
	self.m_Transform.forward = v
end

function CObject.GetUp(self)
	return self.m_Transform.up
end

function CObject.GetRight(self)
	return self.m_Transform.right
end

function CObject.SetName(self, sName)
	self.m_GameObject.name = sName
end

function CObject.GetName(self)
	return self.m_GameObject.name
end

function CObject.AddComponent(self, sType)
	return self.m_GameObject:AddComponent(sType)
end

function CObject.GetComponent(self, sType)
	return self.m_GameObject:GetComponent(sType)
end

function CObject.GetComponents(self, sType)
	return self.m_GameObject:GetComponents(sType)
end

function CObject.GetComponentInChildren(self, classtype)
	return self.m_GameObject:GetComponentInChildren(classtype)
end

function CObject.GetComponentsInChildren(self, classtype, includeInactive)
	return self.m_GameObject:GetComponentsInChildren(classtype, includeInactive)
end

function CObject.GetComponentInParent(self, classtype)
	return self.m_GameObject:GetComponentInParent(classtype)
end

function CObject.GetMissingComponent(self, sType)
	return self.m_GameObject:GetMissingComponent(sType)
end

function CObject.SetAsFirstSibling(self)
	self.m_Transform:SetAsFirstSibling()
end

function CObject.SetAsLastSibling(self)
	self.m_Transform:SetAsLastSibling()
end

function CObject.SetSiblingIndex(self, index)
	self.m_Transform:SetSiblingIndex(index)
end

function CObject.GetSiblingIndex(self)
	return self.m_Transform:GetSiblingIndex()
end

function CObject.Find(self, s)
	if not self.m_FindTrans[s] then
		self.m_FindTrans[s] = self.m_Transform:Find(s)
	end
	return self.m_FindTrans[s]
end

function CObject.GetChild(self, idx)
	return self.m_Transform:GetChild(idx - 1)
end

function CObject.SetParent(self, parent, bWorldPositionStays)
	local bWorldPositionStays = bWorldPositionStays or false
	self.m_Transform:SetParent(parent, bWorldPositionStays)
end

function CObject.GetLayer(self)
	return self.m_GameObject.layer
end

function CObject.SetLayer(self, layer)
	self.m_GameObject.layer = layer
end

function CObject.SetLayerDeep(self, layer)
	NGUI.NGUITools.SetLayer(self.m_GameObject, layer)
end

function CObject.GetParent(self)
	return self.m_Transform.parent
end

function CObject.SetLocalPos(self, v3)
	self.m_Transform.localPosition = v3
end

function CObject.GetLocalPos(self)
	return self.m_Transform.localPosition
end

function CObject.SetPos(self, v3)
	self.m_Transform.position = v3
end

function CObject.GetPos(self)
	return self.m_Transform.position
end


function CObject.SetLocalPosX(self, x)
	local p = self:GetLocalPos()
	p.x = x
	self:SetLocalPos(p)
end

function CObject.SetLocalRotation(self, quaternion)
	self.m_Transform.localRotation = quaternion
end

function CObject.GetLocalRotation(self)
	return self.m_Transform.localRotation
end

function CObject.SetRotation(self, quaternion)
	self.m_Transform.rotation = quaternion
end

function CObject.GetRotation(self)
	return self.m_Transform.rotation
end

function CObject.SetEulerAngles(self, angle)
	self.m_Transform.eulerAngles = angle
end

function CObject.SetLocalEulerAngles(self, angle)
	self.m_Transform.localEulerAngles = angle
end

function CObject.GetEulerAngles(self)
	return self.m_Transform.eulerAngles
end

function CObject.GetLocalEulerAngles(self)
	return self.m_Transform.localEulerAngles
end

function CObject.SetLocalScale(self, v3)
	self.m_Transform.localScale = v3
end

function CObject.GetLocalScale(self)
	return self.m_Transform.localScale
end

function CObject.ReActive(self)
	self:SetActive(false)
	self:SetActive(true)
end

function CObject.SetActive(self, bActive)
	self.m_GameObject:SetActive(bActive)
end

function CObject.GetActive(self)
	return self.m_GameObject.activeSelf
end

function CObject.GetActiveHierarchy(self)
	return self.m_GameObject.activeInHierarchy
end

function CObject.Destroy(self)
	if not self:IsDestroy() then
		self.m_GameObject:Destroy()
	end
	self.m_IsDestroy = true
end

function CObject.GetInstanceID(self)
	if not self.m_InstanceID then
		self.m_InstanceID = self.m_GameObject:GetInstanceID()
	end
	return self.m_InstanceID
end

function CObject.SetSiblingIndex(self, index)
	self.m_Transform:SetSiblingIndex(index)
end

function CObject.IsDestroy(self)
	if not self.m_IsDestroy then
		self.m_IsDestroy = not C_api.Utils.IsObjectExist(self.m_GameObject)
	end
	return self.m_IsDestroy
end

function CObject.InverseTransformPoint(self, worldPoint)
	return self.m_Transform:InverseTransformPoint(worldPoint)
end

function CObject.InverseTransformVector(self, worldVec)
	return self.m_Transform:InverseTransformVector(worldVec)
end

function CObject.InverseTransformDirection(self, worldDir)
	return self.m_Transform:InverseTransformDirection(worldDir)
end

function CObject.TransformPoint(self, lcoalPoint)
	return self.m_Transform:TransformPoint(lcoalPoint)
end

function CObject.TransformVector(self, localVec)
	return self.m_Transform:TransformVector(localVec)
end

function CObject.TransformDirection(self, lcoalDir)
	return self.m_Transform:TransformDirection(lcoalDir)
end

function CObject.Translate(self, v, space)
	space = space or enum.Space.Self
	self.m_Transform:Translate(v, space)
end

function CObject.RotateAround(self, vPoint, vAxis, iAngle)
	self.m_Transform:RotateAround(vPoint, vAxis, iAngle)
end

function CObject.Rotate(self, iEulerAngle)
	self.m_Transform:Rotate(iEulerAngle)
end

function CObject.LookAt(self, transOrPos, vDirUp)
	self.m_Transform:LookAt(transOrPos, vDirUp)
end

function CObject.Clone(self, ...)
	local obj = self.m_GameObject:Instantiate()
	return self.classtype.New(obj, ...)
end

function CObject.CloneAnsy(self, func, ...)
	local args = {...}
	local len = select("#", ...)
	local clonefunc = function()
		if Utils.IsExist(self) then
			local obj = self:Clone(unpack(args, 1, len))
			local success, bRet = xxpcall(func, obj)
			local b = success and bRet~=false
			if not b then
				obj:Destroy()
			end
			return b
		else
			return false
		end
	end
	g_ResCtrl:InsertInCloneList(self.m_CacheKey, clonefunc)
end

return CObject