local CChoukaEffect = class("CChoukaEffect", CEffect)

function CChoukaEffect.ctor(self, iShape, itype, parentObj, layer, cached, cb)
	local path =  "Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_yingzi_001.prefab"
	if itype == 2 then
		path =  "Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_yingzi_002.prefab"
	end
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_Layer = layer
	self.m_Callback = cb
	self.m_Eff = nil
	self.m_Path = path
	self.m_Cached = cached
	self.m_TilingInfo = nil
	self.m_RotateNode = nil
	self.m_MainTexOriScale = {}
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnEffLoad"), true)
	if Utils.IsEditor() then
		self:SetName(path.."_"..g_EffectCtrl:GetIndex())
	end
	self:SetParent(self:GetParentTransform())
	self.m_CtorTime = g_TimeCtrl:GetTimeMS()
	self.m_RefAttach = nil
	self.m_Shape = iShape
	self.m_ParentObj = parentObj
	self:SetParent(parentObj.m_Transform)
end

function CChoukaEffect.OnEffLoadExt(self)
	local iShape = self.m_Shape
	local sPath = string.format("Texture/Photo/full_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d原画资源,用默认造型9999.",iShape))
		sPath = "Texture/Photo/full_9999.png"
	end
	self.m_Eff:SetActive(false)
	g_ResCtrl:LoadAsync(sPath, callback(self, "OnTextureLoadDone"), true)
end

function CChoukaEffect.OnTextureLoadDone(self, asset, path)
	local go = self.m_Eff:GetComponent(classtype.DataContainer).gameObjectValue
	local oMatList = Utils.GetMaterials({go})
	local oMat = oMatList[1]
	local oldTexture = oMat:GetTexture("_MainTex")
	if oldTexture then
		g_ResCtrl:DelManagedAsset(oldTexture, go)
	end
	g_ResCtrl:AddManageAsset(asset, go, path)
	oMat:SetTexture("_MainTex", asset)
	self.m_Eff:SetActive(true)
	local config = g_DialogueCtrl:GetFullTextureSize(self.m_Shape)
	if config then
		local w, h = config[1], config[2]
		local scaleW, scaleH = w / 580, h / 577
		go.transform.localScale = Vector3.New(scaleW, scaleH, 1)

	end
end

function CChoukaEffect.OnEffLoad(self, oClone, sPath)
	if oClone then
		self.m_LoadTime = g_TimeCtrl:GetTimeMS() - self.m_CtorTime
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform, false)
		self.m_Eff:SetCacheKey(sPath)
		if self.m_Layer then
			CObject.SetLayerDeep(self, self.m_Layer)
		end
		self:ProcessUI()
		self:ProcessTiling()
		self.m_Eff:SetActive(true)
		self:OnEffLoadExt()
		if self.m_Callback then
			self.m_Callback(self)
			self.m_Callback = nil
		end
	end
end

function CChoukaEffect.SetParent(self, mTransform)
	if mTransform then
		CObject.SetParent(self, mTransform)
	end
end

function CChoukaEffect.GetParentTransform(self)
	return nil
end

return CChoukaEffect