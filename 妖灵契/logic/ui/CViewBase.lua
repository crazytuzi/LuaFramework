local CViewBase = class("CViewBase", CPanel, CGameObjContainer)

function CViewBase.ctor(self, path, cb)
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnViewLoad"), true)
	self.m_Path = path
	self.m_LoadDoneFunc = cb
	self.m_StrikeResult = false --是否处理了点穿事件,处理了点穿事件则不自动关闭界面
	self.m_BehidLayer = nil
	self.m_HideCB = nil
	self.m_ShowID = Utils.GetUniqueID() --id越大，越晚调用ShowView
	self.m_IsActive = nil
	--界面设置，以下为默认值，继承类自己设置需要的属性
	self.m_DepthType = "Dialog"  --层次
	self.m_GroupName = nil --界面组(只有一个界面会被显示)
	self.m_ExtendClose = nil --ClickOut, Black, Shelter
	self.m_BehindStrike = false --BehindView点击穿透
	self.m_OpenEffect = nil --打开界面动画 Scale
	self.m_IsDoingOpenEffect = false
	self.m_IsAlwaysShow = false -- 一直显示
	self.m_ShowCB = nil
	self.m_ChildViewRef = nil
end

function CViewBase.GetShowID(self)
	return self.m_ShowID
end

function CViewBase.SetShowID(self, id)
	self.m_ShowID = id
end

function CViewBase.SetShowCB(self, cb)
	self.m_ShowCB = cb
end

function CViewBase.ClearShowCB(self)
	self.m_ShowCB = nil
end

function CViewBase.SetLoadDoneCB(self, cb)
	self.m_LoadDoneFunc = cb
end

function CViewBase.SetHideCB(self, cb)
	self.m_HideCB = cb
end

function CViewBase.ShowView(cls, cb)
	return g_ViewCtrl:ShowView(cls, cb)
end

function CViewBase.GetView(cls)
	return g_ViewCtrl:GetView(cls)
end

function CViewBase.CloseView(cls)
	g_ViewCtrl:CloseView(cls)
end

function CViewBase.SetStrikeResult(self, b)
	self.m_StrikeResult = b
end

function CViewBase.GetStrikeResult(self)
	return self.m_StrikeResult
end

function CViewBase.SetActive(self, bActive, noMotion)
	if self.m_IsActive == bActive then
		return
	end
	self.m_IsActive = bActive 
	CPanel.SetActive(self, bActive)
	if bActive then
		local oRootObj = UITools.GetUIRootObj(self.m_IsAlwaysShow)
		local trans = oRootObj:GetTransform()
		if self:GetParent() ~= trans then
			self:SetParent(trans, false)
		end
		if not noMotion then
			self:StartOpenEffect()
		end
		self:ExtendClose()
		g_ViewCtrl:TopView(self)
		g_ViewCtrl:HideOther(self)
		g_ViewCtrl:RemoveGroupHide(self)
		self:OnShowView()
		g_MapCtrl:StopHeroWalk(self.classname)
		if self.m_ShowCB then
			self.m_ShowCB()
			self.m_ShowCB = nil
		end
	else
		self:DestroyBeindLayer()
		g_ViewCtrl:AddGroupHide(self)
		self:OnHideView()
		local cb = function ()
			g_GuideCtrl:TriggerAll()
		end
		Utils.AddTimer(cb, 0, 0)    
	end
end

function CViewBase.OnViewLoad(self, oClone, path)
	if oClone then
		if g_ViewCtrl:GetLoadingView(self.classtype) then
			g_ResCtrl:ManagedTextures(oClone)
			local oRootObj = UITools.GetUIRootObj(self.m_IsAlwaysShow)
			oClone.transform:SetParent(oRootObj:GetTransform(), false)
			CPanel.ctor(self, oClone)
			CGameObjContainer.ctor(self, oClone)
			self:OnCreateView()--获取控件
			self:OnShowView()
			if self.m_ShowCB then
				self.m_ShowCB()
				self.m_ShowCB = nil
			end
			if g_ViewCtrl:IsNeedShow(self) and self:IsCanShow() then
				self:SetActive(true) 
			else
				self:SetActive(false)
			end
			g_ViewCtrl:AddView(self.classtype, self)
			
			print(string.format("%s LoadDone!", self.classname))
			if self.m_LoadDoneFunc then
				self.m_LoadDoneFunc(self)
			end
		else
			oClone:Destroy()
			print(string.format("%s LoadDone, not in loadingview!", self.classname))
		end
		self:LoadDone() --画面结束加载时调用
	else
		g_NotifyCtrl:FloatMsg("界面加载出错了")
		g_ViewCtrl:SetLoadingView(self.classtype, nil)
		printerror(string.format("%s LoadError", self.classname))
	end
	g_GuideCtrl:TriggerCheck("view")
end

function CViewBase.ExtendClose(self)
	if not self.m_ExtendClose then
		return
	end
	local oBehind
	if self.m_BehidLayer then
		oBehind = self.m_BehidLayer
	else
		oBehind = CBehindLayer.New()
	end
	if self.m_ExtendClose == "Shelter" then
		oBehind:SetTextrueShow(true)
		oBehind:SetShelter(true)
	else
		oBehind:SetTextrueShow(self.m_ExtendClose == "Black")
	end
	oBehind:SetOwner(self)
	oBehind:SetLocalPos(Vector3.zero)
	self.m_BehidLayer = oBehind
end

function CViewBase.StartOpenEffect(self)
	local cb = function ()
		if Utils.IsExist(self) then
			self:OnOpenEffectDone()
		end
		g_GuideCtrl:TriggerAll()
	end
	self.m_IsDoingOpenEffect = false
	if self.m_OpenEffect == "Scale" then
		self.m_IsDoingOpenEffect = true
		self:SetLocalScale(Vector3.New(0.8, 0.8, 0.8))
		local tween = DOTween.DOScale(self.m_Transform, Vector3.New(1, 1, 1), 0.35)
		DOTween.OnComplete(tween, function ()
			Utils.AddTimer(cb, 0, 0)
			end)
		DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
	else
		Utils.AddTimer(cb, 0, 0)
	end
end

function CViewBase.DestroyBeindLayer(self)
	if self.m_BehidLayer then
		self.m_BehidLayer:Destroy()
		self.m_BehidLayer = nil
	end
end

--请调用CloseView()关闭界面
function CViewBase.Destroy(self)
	self:DestroyBeindLayer()
	self:CloseChildView()
	if self.m_PageList and #self.m_PageList > 0 then
		for _, page in ipairs(self.m_PageList) do
			if page:IsInit() then
				page:Destroy()
			end
		end
	end
	CPanel.Destroy(self)
	g_ResCtrl:CheckManagedAssetsLater()
end

function CViewBase.SetDepthDeep(self, depth)
	local iRelative = depth - self:GetDepth()
	self:RelativeSubPanelDepth(iRelative)
	self:SetDepth(depth)
	-- UITools.SetSubPanelDepthDeep(self)
	if self.m_BehidLayer then
		self.m_BehidLayer:SetDepth(depth-1)
	end
end

function CViewBase.RelativeSubPanelDepth(self, iRelative)
	local panels = self:GetComponentsInChildren(classtype.UIPanel, true)
	for i=0, panels.Length-1 do
		local panel = panels[i]
		panel.depth = panel.depth + iRelative
	end
end

function CViewBase.IsCanShow(self)
	return true
end

--关闭按钮的回调，比较通用放到ViewBase
function CViewBase.OnClose(self, o)
	self:CloseView()
end

--override function

--界面加载完成后调用,获取控件
function CViewBase.OnCreateView(self)
	--body
end

--界面SetActive True时调用
function CViewBase.OnShowView(self)
	--body
end

--界面SetActive False时调用
function CViewBase.OnHideView(self)
	--body
	if self.m_HideCB then
		self.m_HideCB()
	end
end

--界面加载完成时调用
function CViewBase.LoadDone(self)
	--body
end

function CViewBase.OnOpenEffectDone(self)
	self.m_IsDoingOpenEffect = false
end

function CViewBase.SetChildView(self, oView)
	self.m_ChildViewRef = weakref(oView)
end

function CViewBase.CloseChildView(self)
	local oView = getrefobj(self.m_ChildViewRef)
	if oView then
		oView:CloseView()
	end
	self.m_ChildViewRef = nil
end

return CViewBase