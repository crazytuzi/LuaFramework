local CSpineTexture = class("CSpineTexture", CTexture)

function CSpineTexture.ctor(self, obj)
	CTexture.ctor(self, obj)
	self.m_DisplayTexture = nil --真正用来显示的Texture
	self.m_DisplayRenderTexture = nil
	self.m_LastRelativeSize = 1
	self.m_RelativeSize = 1
	self.m_SpineCamera = nil
	self.m_Path = nil
	if self.m_UIEventHandler then
		self:AddUIEvent("click", callback(self, "OnClick"))
	end
end

function CSpineTexture.GetFullPath(self, path, iShape)
	if path == nil then
		path = "Common"
	end
	return string.format("Spine/%s/%s/Prefabs/Spine%s.prefab", path, iShape, iShape)
end

function CSpineTexture.ChangeShape(self, iShape, cb, path, aspect)
	path = self:GetFullPath(path, iShape)
	if self.m_Path ~= path then
		self:Clear()
	end
	self.m_Path = path
	local dConfig = DataTools.GetSpineConfig(iShape, path)
	self.m_LastRelativeSize = self.m_RelativeSize
	self.m_RelativeSize = dConfig.relative_size
	self.m_UISize = dConfig.ui_size or 1
	self.m_SpineCamera = self:GetSpineCamera()
	aspect = aspect or self.m_SpineCamera.m_Camera.aspect
	local o = self:GetMainTexture(aspect)
	self.m_SpineCamera:SetRenderTexture(o)
	self.m_SpineCamera:ChangeShape(iShape, cb, self.m_Path)
end

function CSpineTexture.GetSpineCamera(self)
	if not self.m_SpineCamera then
		self.m_SpineCamera = g_CameraCtrl:GetSpineCamra()
		self.m_SpineCamera:SetOwner(self)
	end
	return self.m_SpineCamera
end

function CSpineTexture.GetSpineModel(self)
	local spineCamera = self:GetSpineCamera()
	if spineCamera then
		return spineCamera:GetSpineModel()
	end
end

function CSpineTexture.ShapeShop(self, iShape, cb, aspect)
	self:ChangeShape(iShape, cb, "Shop", aspect)
end

function CSpineTexture.ShapeOrg(self, iShape, cb)
	self:ChangeShape(iShape, cb, "Org")
end

function CSpineTexture.ShapeHouse(self, iShape, cb)
	self:ChangeShape(iShape, cb, "House")
end

function CSpineTexture.ShapeCommon(self, iShape, cb, aspect)
	self:ChangeShape(iShape, cb, "Common", aspect)
end

function CSpineTexture.ShapeCreateRole(self, iShape, cb, aspect)
	self:ChangeShape(iShape, cb, "CreateRole", aspect)
end

function CSpineTexture.SetWidth(self, iWidth)
	CTexture.SetWidth(self, iWidth)
	if self.m_DisplayTexture then
		self.m_DisplayTexture:SetWidth(iWidth*self.m_RelativeSize*self.m_UISize)
	end
end

function CSpineTexture.SetHeight(self, iHeight)
	CTexture.SetHeight(self, iHeight)
	if self.m_DisplayTexture then
		self.m_DisplayTexture:SetHeight(iHeight*self.m_RelativeSize*self.m_UISize)
	end
end

function CSpineTexture.SetSize(self, iWidth, iHeight)
	CTexture.SetWidth(self, iWidth)
	CTexture.SetHeight(self, iHeight)
	if self.m_DisplayTexture then
		self.m_DisplayTexture:SetHeight(iWidth*self.m_RelativeSize*self.m_UISize)
		self.m_DisplayTexture:SetHeight(iHeight*self.m_RelativeSize*self.m_UISize)
	end
end

function CSpineTexture.GetDisplayTexture(self)
	if not self.m_DisplayTexture then
		local obj = UnityEngine.GameObject.New()
		obj:AddComponent(classtype.UITexture)
		local oTexture = CTexture.New(obj)
		oTexture:SetPivot(self:GetPivot())
		oTexture:SetParent(self.m_Transform)
		oTexture:SetDepth(self:GetDepth())
		oTexture:SetLocalPos(Vector3.zero)
		oTexture:SetName("display")
		oTexture:SetFlip(self:GetFlip())
		oTexture:SetLayer(self:GetLayer())
		self.m_DisplayTexture = oTexture
	end
	
	return self.m_DisplayTexture
end

function CSpineTexture.GetMainTexture(self, aspect)
	local oTexture = self:GetDisplayTexture()
	if oTexture:GetMainTexture() and self.m_LastRelativeSize ~= self.m_RelativeSize then
		oTexture:SetMainTexture(nil)
	end
	local factor = UITools.GetPixelSizeAdjustment()
	local w = self:GetWidth() * self.m_RelativeSize * self.m_UISize
	local h = self:GetHeight() * self.m_RelativeSize * self.m_UISize


	if aspect then
		local iTextureAspect = (w/h)
		if iTextureAspect ~= aspect then
			if iTextureAspect < aspect then
				w = h * aspect
			elseif iTextureAspect > aspect then
				h = w / aspect
			end
			oTexture:SetSize(w, h)
		end
	end
	if not self.m_DisplayRenderTexture then
		local iFactor = 1 
		self.m_DisplayRenderTexture = UnityEngine.RenderTexture.GetTemporary(w*iFactor, h*iFactor, 16, 
			enum.RenderTextureFormat.Default, enum.RenderTextureReadWrite.Default, 1)
	end
	return self.m_DisplayRenderTexture
end

function CSpineTexture.CheckDisplayRenderTexture(self, oRenderTexture)
	local oTexture = self:GetDisplayTexture()
	if oTexture then
		oTexture:SetMainTexture(oRenderTexture)
	end
end


function CSpineTexture.OnClick(self)
	self:RandomPlayAnimation()
end

function CSpineTexture.RandomPlayAnimation(self)
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:RandomPlayAnimation()
	end
end

function CSpineTexture.SetAnimation(self, iTrackIndex, sAnimationName, bLoop, funStart, funComplete)
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:SetAnimation(iTrackIndex, sAnimationName, bLoop, funStart, funComplete)
		return true
	end
	return false
end

function CSpineTexture.AddAnimation(self, iTrackIndex, sAnimationName, bLoop, iDelay, funStart, funComplete)
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:AddAnimation(iTrackIndex, sAnimationName, bLoop, iDelay, funStart, funComplete)
		return true
	end
	return false
end

function CSpineTexture.StopAnimation(self)
	
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:StopAnimation()
	end
end

function CSpineTexture.SetTimeScale(self, iScale)
	
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:SetTimeScale(iScale)
	end
end

function CSpineTexture.SetSpineComplete(self, func)
	
	local oSpineModel = self:GetSpineModel()
	if oSpineModel then
		oSpineModel:SetSpineComplete(func)
	end
end

function CSpineTexture.SetMainTextureNil(self)
	self:Clear()
end

function CSpineTexture.Clear(self)
	if self.m_UIWidget.mainTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_UIWidget.mainTexture)
		self:SetMainTexture(nil)
		self.m_UIWidget.mainTexture = nil
	end
	if self.m_DisplayTexture then
		self.m_DisplayTexture:Destroy()
		self.m_DisplayTexture = nil
	end
	if self.m_DisplayRenderTexture then
		self.m_DisplayRenderTexture:Destroy()
		self.m_DisplayRenderTexture = nil
	end
	if self.m_SpineCamera then
		g_CameraCtrl:RecycleSpineCam(self.m_SpineCamera)
		self.m_SpineCamera = nil
	end
	self.m_Path = nil
end

function CSpineTexture.SetSequenceAnimation(self, anis)
	if anis and next(anis) then
		if #anis == 1 then
			self:SetAnimation(0, anis[1], true)
		else
			self:SetAnimation(0, anis[1], false)
			for i = 2, #anis do 
				self:AddAnimation(0, anis[i], i == #anis)
			end
		end
	end
end

return CSpineTexture