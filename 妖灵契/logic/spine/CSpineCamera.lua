local CSpineCamera = class("CSpineCamera", CCamera, CGameObjContainer)

function CSpineCamera.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/SpineCamera.prefab")
	CCamera.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_PosObj = self:NewUI(1, CObject)
	self.m_SpineModel = nil
	self.m_RenderTexture = nil
	self.m_Shape = nil
end

function CSpineCamera.SetRenderTexture(self, renderTexture)
	self.m_RenderTexture = renderTexture
	self:SetTargetTexture(renderTexture)
end

function CSpineCamera.ChangeShape(self, iShape, cb, path)
	self.m_Shape = iShape
	self.m_Path = path
	self:ChangeShapeByPath(iShape, cb, path)
end

function CSpineCamera.ChangeShapeByPath(self, iShape, cb, path)
	self:Load(path, cb)
end

function CSpineCamera.Load(self, path, cb)
	if not self.m_SpineModel then
		self.m_LoadDoneCb = cb
		g_ResCtrl:LoadCloneAsync(path, callback(self, "OnChangeDone"), self.m_PriorLoad)
	else
		if cb then
			cb()
		end
	end
end

function CSpineCamera.CheckOwnerDisplay(self)
	local oOwenr = self:GetOwner()
	if oOwenr then
		self:SetActive(true)
		oOwenr:CheckDisplayRenderTexture(self.m_RenderTexture)
	end
end

function CSpineCamera.OnChangeDone(self, oClone, sPath)
	if oClone then
		if not self.m_Path then
			oClone:Destroy()
			return
		end
		self:CheckOwnerDisplay()
		self:ClearModel()
		self.m_SpineModel = CSpineModel.New(oClone)
		self.m_SpineModel:SetParent(self.m_PosObj.m_Transform)
		self.m_SpineModel:SetLayerDeep(self.m_GameObject.layer)
		self:Resize()
		if self.m_LoadDoneCb then
			self.m_LoadDoneCb()
			self.m_LoadDoneCb = nil
		end
	end
end


function CSpineCamera.Resize(self)
	if self.m_Shape then
		local dConfig =  DataTools.GetSpineConfig(self.m_Shape)
		local size = dConfig.size * (self.m_SpineModel.scale or 1)
		local oSizeObj = self.m_SpineModel or self
		oSizeObj:SetLocalScale(Vector3.New(size, size, size))
		local pos = dConfig.pos
		if pos then
			self.m_PosObj:SetLocalPos(Vector3.New(pos.x, pos.y, 10))
		else
			self.m_PosObj:SetLocalPos(Vector3.New(0, 0, 10))
			printc(string.format("请注意：%s: spine缺少配置pos", self.m_Shape))
		end
	end
end

function CSpineCamera.SetOwner(self, o)
	self.m_OwnerRef = weakref(o)
end

function CSpineCamera.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CSpineCamera.GetSpineModel(self)
	return self.m_SpineModel
end

function CSpineCamera.ClearTexture(self)
	if self.m_RenderTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_RenderTexture)
		self.m_RenderTexture = nil
		self:SetTargetTexture(nil)
	end
end

function CSpineCamera.ClearSpine(self)
	self.m_Path = nil
	self:ClearTexture()
	self:ClearModel()
end

function CSpineCamera.ClearModel(self)
	if self.m_SpineModel then
		self.m_SpineModel:Destroy()
		self.m_SpineModel = nil
	end
end

function CSpineCamera.Destroy(self)
	self:ClearSpine()
	CCamera.Destroy(self)
end

return CSpineCamera