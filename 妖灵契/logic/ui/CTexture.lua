local CTexture = class("CTexture", CWidget)

function CTexture.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_LoadingPath = nil
	self.m_Path = nil
	self.m_LoadingShape = nil
	self.m_LoadingDoneCb = nil
	self.m_AsyncLoad = true
	if self.m_UIWidget.material then
		self.m_UIWidget.material = self.m_UIWidget.material:Instantiate()
	end
end

function CTexture.SetAsyncLoad(self, bAsync)
	self.m_AsyncLoad = bAsync
end

function CTexture.SetShader(self, shader)
	self.m_UIWidget.shader = shader
end

function CTexture.SetMainTexture(self, texture)
	if Utils.IsNil(texture) then
		texture = nil
	end
	if self.m_UIWidget.mainTexture then
		g_ResCtrl:DelManagedAsset(self.m_UIWidget.mainTexture, self.m_GameObject)
	end
	self.m_UIWidget.mainTexture = texture
	if texture then
		if Utils.IsTypeOf(texture, classtype.Texture2D) then
			g_ResCtrl:AddManageAsset(self.m_UIWidget.mainTexture, self.m_GameObject, self.m_Path)
		end
	else
		self.m_Path = nil
	end
end

function CTexture.GetMainTexture(self)
	return self.m_UIWidget.mainTexture
end

function CTexture.LoadPath(self, path, cb)
	if self.m_LoadingPath == path then
		return
	elseif self.m_Path == path then
		if cb then
			cb(self)
		end
		return
	end
	self.m_LoadingPath = path
	self.m_LoadingDoneCb = cb
	-- if self.m_AsyncLoad then
		g_ResCtrl:LoadAsync(path, callback(self, "OnTexureLoadDone"))
	-- else
	-- 	g_ResCtrl:Load(path, callback(self, "OnTexureLoadDone"))
	-- end
end

function CTexture.OnTexureLoadDone(self, asset, path)
	if self.m_LoadingPath == path then
		self.m_LoadingPath = nil
		self.m_Path = path
		self:SetMainTexture(asset)
		if self.m_LoadingDoneCb then
			self.m_LoadingDoneCb(self)
		end
	end
end

function CTexture.LoadHalfPhoto(self, iShape, cb)
	local sPath = string.format("Texture/Photo/half_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d半身像资源,用默认造型9999.",iShape))
		sPath = "Texture/Photo/half_9999.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.LoadFullPhoto(self, iShape, cb)
	local sPath = string.format("Texture/Photo/full_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d原画资源,用默认造型9999.",iShape))
		sPath = "Texture/Photo/full_9999.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.LoadListPhoto(self, iShape, cb)
	local sPath = string.format("Texture/Photo/huoban_da_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d原画资源,用默认造型301.",iShape))
		sPath = "Texture/Photo/huoban_da_301.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.LoadArenaPhoto(self, iShape, cb)
	local sPath = string.format("Texture/Photo/arena_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d原画资源,用默认造型9999.",iShape))
		sPath = "Texture/Photo/full_9999.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.SnapFullPhoto(self, iShape, iScale)
	local config = g_DialogueCtrl:GetFullTextureSize(iShape)
	if config then
		local w, h = config[1], config[2]
		self:SetSize(w*iScale, h*iScale)
	end
end

function CTexture.GetFullPhotoOffSet(self, iShape, iScale)
	local offset = g_DialogueCtrl:GetFullTextureOffset(iShape)
	if offset then
		return offset[1], offset[2]
	end
	return 0, 0
end

function CTexture.LoadCardPhoto(self, iShape, cb)
	local sPath = string.format("Texture/Photo/card_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d卡牌资源,用默认造型9999.",iShape))
		sPath = "Texture/Photo/card_9999.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.LoadPartnerEquip(self, iPartnerEquip, cb)
	local sPath = string.format("Texture/PartnerEquip/bg_fw_%d.png", iPartnerEquip)
	if not g_ResCtrl:IsExist(sPath) then
		print(string.format("没有%d伙伴装备资源,用默认造型9999.",iPartnerEquip))
		sPath = "Texture/Photo/card_9999.png"
	end
	self:LoadPath(sPath , cb)
end

function CTexture.LoadDialogPhoto(self, iShape, cb, bRight)
	local function wrap()
		if Utils.IsExist(self) then
			-- local config = g_DialogueCtrl:GetDialogNpcConfig(iShape)
			-- if config then
			-- 	if bRight then
			-- 		if config.rightConfig then
			-- 			self:SetUVRect(UnityEngine.Rect.New(config.rightConfig.x , config.rightConfig.y , config.rightConfig.w, config.rightConfig.h))
			-- 		end
			-- 	else
			-- 		if config.leftConfig then
			-- 			self:SetUVRect(UnityEngine.Rect.New(config.leftConfig.x , config.leftConfig.y , config.leftConfig.w, config.leftConfig.h))
			-- 		end
			-- 	end
			-- end
		end
		self:MakePixelPerfect()
		if cb then
			cb()
		end
	end
	local sPath = string.format("Texture/Photo/dialogue_"..iShape..".png")
	self:LoadPath(sPath , wrap)
end

function CTexture.SetMainTextureNil(self)
	local sPath = "Texture/Photo/pic_none.png"
	self:LoadPath(sPath )
end

function CTexture.GetMaterial(self)
	return self.m_UIWidget.material
end

function CTexture.SetFlip(self, iFlip)
	self.m_UIWidget.flip = iFlip
end

function CTexture.GetFlip(self)
	return self.m_UIWidget.flip
end

function CTexture.SetGradientColor(self, color)
	if not self.m_UITexture then
		self.m_UITexture = self:GetMissingComponent(classtype.UITexture)
	end
	self.m_UITexture.gradientTop = color
	self.m_UITexture.gradientBottom = color
end

function CTexture.AutoResizeBoxCollider(self, bAuto)
	if not self.m_UITexture then
		self.m_UITexture = self:GetMissingComponent(classtype.UITexture)
	end
	self.m_UITexture.autoResizeBoxCollider = bAuto
end

function CTexture.SetFillAmount(self, iFillAmount)
	self.m_UIWidget.fillAmount = iFillAmount 
end

return CTexture