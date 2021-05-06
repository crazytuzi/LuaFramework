local CViewCtrl = class("CViewCtrl", CCtrlBase)
define.Depth = {
	View = {
		Increase = 300, --同一pannel中view间隔300
	},
	Panel = {
		Increase = 30000, --pannel间隔30000
		Bottom = 0,
		Menu = 30000 * 1,
		Login = 30000 * 2,
		Dialog = 30000 * 3,
		Notify = 30000 * 4,
		Guide = 30000 * 5,
		WindowTip = 30000 * 6,
		Top = 30000 * 9,
		LockScreen = 30000 * 10,
	}
}
define.View = {
	Event = {
		OnShowView = 1,
	},
}

function CViewCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Views = {}
	self.m_GroupHideViews = {}
	self.m_LoadingViews = {}
	self.m_DontDestroyOnCloseeAll = {}
	self.m_EnvInfo = {}
	self.m_UnloadAtlasCounter = define.View.AtlasCount
	self.m_ScreenMaskPanel = nil
	self.m_LoginAfterCBs = {}
	self.m_LoginCbKey = nil
end

function CViewCtrl.SetScreenMask(self, iPercent)
	g_ResCtrl:LoadCloneAsync("UI/Misc/ScreenMask.prefab", function(oClone)
		local designw, designh = UITools.GetDesignSize()
		local oRoot = CObject.New(UnityEngine.GameObject.Find("GameRoot/UIRoot/Show"))
		oRoot:SetLocalPos(Vector3.New(0, 0, 0))
		oRoot:SetLocalScale(Vector3.New((1-iPercent*2), 1, 1))
		local panel = CPanel.New(oClone)
		panel:SetParent(oRoot:GetParent())
		local widget = CWidget.New(panel:Find("Container").gameObject)
		UITools.ResizeToRootSize(widget, 2, 2)

		local rootw, rooth = UITools.GetRootSize()
		local w = iPercent*rootw
		local ltexture = CTexture.New(panel:Find("Container/lTexture").gameObject)
		ltexture.m_UIWidget.rightAnchor.absolute = w
		ltexture:ResetAndUpdateAnchors()
		ltexture:SetWidth(w)
		
		local rtexture = CTexture.New(panel:Find("Container/rTexture").gameObject)
		rtexture.m_UIWidget.leftAnchor.absolute = w
		rtexture:ResetAndUpdateAnchors()
		rtexture:SetWidth(w)
		-- rtexture:SetActive(false)
		-- 
		self.m_ScreenMaskPanel = panel
	end)
end

function CViewCtrl.CloseInterface(self, type)
	if not g_LoginCtrl:HasLoginRole() then
		return
	end
	netopenui.C2GSCloseInterface(type)
end

function CViewCtrl.ShowView(self, cls, cb)
	local oView = self:GetView(cls)
	if not oView then
		oView = g_ResCtrl:GetObjectFromCache(cls.classname)
		if oView then
			local oRootObj = UITools.GetUIRootObj(oView.m_IsAlwaysShow)
			oView:SetParent(oRootObj:GetTransform(), false)
		end
	end
	if oView then
		oView:SetShowID(Utils.GetUniqueID())
		oView:SetActive(true)
		g_ViewCtrl:AddView(oView.classtype, oView)
		if cb then
			cb(oView)
		end
	else
		local oLodingView = self:GetLoadingView(cls)
		if oLodingView then
			oLodingView:SetLoadDoneCB(cb)
		else
			print(string.format("%s ShowView", cls.classname))
			oLodingView = cls.New(cb)
		end
		self:SetLoadingView(cls, oLodingView)
	end
	self:OnEvent(define.View.Event.OnShowView, cls.classname)
	return oView
end

function CViewCtrl.CloseView(self, cls)
	print(cls.classname, " CloseView")
	local oLoadingView = self:GetLoadingView(cls)
	if oLoadingView then
		self:SetLoadingView(cls, nil)
	else
		local oView = self:GetView(cls)
		if oView then
			self:DelView(oView.classtype)
			self:ShowOne(oView)
			oView:OnHideView()
			self:DontDestroyOnCloseAll(cls.classname, false)
			--每当有画面关闭的时候，判断当前是否要显示快捷使用
			g_ItemCtrl:LocalShowQuickUse()
			--每当有画面关闭的时候，判断是否有要显示的成就完成提示
			g_AchieveCtrl:CheckShowAchieveTips()
			if data.resdata.Config[cls.classname] then
				oView:SetActive(false)
				g_ResCtrl:PutObjectInCache(cls.classname, oView)
			else
				oView:Destroy()
				-- if oView.m_ExtendClose == "Black" then
				-- 	g_ResCtrl:CheckUnloadAtlas()
				-- end
			end
		end
	end
	local cb = function ()
		g_GuideCtrl:TriggerAll()
	end
	Utils.AddTimer(cb, 0, 0)
	self:CheckLoginAfterCallBack(cls.classname)		
end

function CViewCtrl.AddView(self, cls, oView)
	self:SetLoadingView(cls, nil)
	self.m_Views[cls.classname] = oView
	self:ViewChangeProcess()
end

function CViewCtrl.DelView(self, cls)
	self.m_Views[cls.classname] = nil
	self:ViewChangeProcess()
end

function CViewCtrl.GetView(self, cls)
	return self.m_Views[cls.classname]
end

function CViewCtrl.GetViewByName(self, classname)
	return self.m_Views[classname]
end

function CViewCtrl.GetViews(self)
	return self.m_Views
end

function CViewCtrl.GetViewCount(self)
	return table.count(self.m_Views)
end

function CViewCtrl.SetLoadingView(self, cls, oInstance)
	if oInstance then
		oInstance:SetShowID(Utils.GetUniqueID())
	end
	self.m_LoadingViews[cls.classname] = oInstance
end

function CViewCtrl.GetLoadingView(self, cls)
	return self.m_LoadingViews[cls.classname]
end

function CViewCtrl.TopView(self, oView)
	local sDepthType = oView.m_DepthType
	local iPanelBase = define.Depth.Panel[sDepthType]
	local iTop = iPanelBase
	local list = {}
	for _, v in pairs(self.m_Views) do
		if v.m_DepthType == sDepthType then
			table.insert(list, v)
			local d = v:GetDepth()
			if d > iTop then
				iTop = d
			end
		end
	end
	iTop = iTop + define.Depth.View.Increase
	oView:SetDepthDeep(iTop)
	if iTop > iPanelBase + define.Depth.Panel.Increase - define.Depth.View.Increase then --重置pannel中所有
		local iCur = iPanelBase
		table.sort(list, function(a,b) return a:GetDepth() < b:GetDepth() end)
		for i, v in ipairs(list) do
			iCur = iCur + define.Depth.View.Increase
			v:SetDepthDeep(iCur)
		end
	end
	if self.m_ScreenMaskPanel then
		self.m_ScreenMaskPanel:SetDepth(iTop+300)
	end
end

function CViewCtrl.HideOther(self, oView)
	local group = oView.m_GroupName
	if group then
		local lst = {}
		for _, v in pairs(self.m_Views) do
			if v.m_GroupName == group and v ~= oView and v:GetActive() then
				v:SetActive(false)
				self:AddGroupHide(v)
			end
		end
	end
end

function CViewCtrl.AddGroupHide(self, oView)
	self.m_GroupHideViews[oView:GetInstanceID()] = true
end

function CViewCtrl.RemoveGroupHide(self, oView)
	self.m_GroupHideViews[oView:GetInstanceID()] = nil
end

function CViewCtrl.ShowOne(self, oView)
	local group = oView.m_GroupName
	if not group then
		return
	end
	local lst = {}
	local oShowView = nil
	for _, v in pairs(self.m_Views) do
		if v.m_GroupName == group and v ~= oView then
			if self.m_GroupHideViews[v:GetInstanceID()] then
				if oShowView then
					if v:GetShowID() > oShowView:GetShowID() then
						oShowView = v
					end
				else
					oShowView = v
				end
			else
				oShowView = v
				break
			end
		end
	end

	if oShowView and self.m_GroupHideViews[oShowView:GetInstanceID()] then
		oShowView:SetActive(true)
	end
end

function CViewCtrl.IsNeedShow(self, oView)
	local group = oView.m_GroupName
	if not group then
		return true
	end
	for _, v in pairs(self.m_Views) do
		if v.m_GroupName == group and v ~= oView then
			if v:GetShowID() > oView:GetShowID()  then
				return false
			end
		end
	end
	return true
end

function CViewCtrl.CloseGroup(self, group)
	for k, oView in pairs(self.m_Views) do
		if oView.m_GroupName == group then
			self:DelView(oView.classtype)
			oView:Destroy()
		end
	end
end

function CViewCtrl.CloseAll(self, lExceptTable, bCheckDontDestory)
	printc("CViewCtrl.CloseAll-->", bCheckDontDestory)
	printtrace()
	local lExcept = table.copy(lExceptTable)
	local list = {"CLoginView", "CGmConsoleView", "CNotifyView", "CGmView", "CEditorTableView", "CBottomView", "CLoadingView", "CLockScreenView", "CTestWarView", "CAchieveFinishTipsView"}
	if lExcept then
		lExcept = table.extend(lExcept, list)
	else
		lExcept = list
	end
	if bCheckDontDestory then
		lExcept = table.extend(lExcept, self.m_DontDestroyOnCloseeAll)
		self.m_DontDestroyOnCloseeAll = {}
	end
	for k, v in pairs(self.m_Views) do
		if table.index(lExcept, k) == nil then
			printc("CloseAll-->CloseView: ", k)
			if v.CloseView then
				v:CloseView(v)
			else
				self:CloseView(v)
			end
		end
	end
	for k, v in pairs(self.m_LoadingViews) do
		if table.index(lExcept, k) == nil then
			self.m_LoadingViews[k] = nil
		end
	end
end

function CViewCtrl.SwitchScene(self)
	for k, v in pairs(self.m_Views) do
		if v.m_SwitchSceneClose then
			printc("SwitchScene-->CloseView: ", k)
			if v.CloseView then
				v:CloseView(v)
			else
				self:CloseView(v)
			end
		end
	end
	for k, v in pairs(self.m_LoadingViews) do
		if v.m_SwitchSceneClose then
			self.m_LoadingViews[k] = nil
		end
	end
end

function CViewCtrl.DontDestroyOnCloseAll(self, clsname, bDont)
	if bDont then
		if table.index(self.m_DontDestroyOnCloseeAll, clsname) == nil then
			table.insert(self.m_DontDestroyOnCloseeAll, clsname)
		end
	else
		local index = table.index(self.m_DontDestroyOnCloseeAll, clsname)
		if index ~= nil then
			table.remove(self.m_DontDestroyOnCloseeAll, index)
		end
	end
end

function CViewCtrl.ViewChangeProcess(self)
	local oView = CNotifyView:GetView()
	if oView then
		oView:UpdateExpbarVisible()
	end
	self:CheckLoginEffect()
end

function CViewCtrl.NoBehideLayer(self, lExcept)
	lExcept = lExcept or {}
	local b = true
	for i, oView in pairs(self.m_Views) do
		if table.key(lExcept, oView.classname) == nil and oView.classname ~= "CGmView" and oView.classname ~= "CLockScreenView" and oView.m_BehidLayer and oView.m_BehidLayer.m_Texture then
			return false
		end
	end
	if CLoginRewardView:GetView() or CDialogueMainView:GetView() or CTaskSlipMoveView:GetView() then
		return false	
	end
	return b
end

function CViewCtrl.HideBottomView(self)
	local oView = CBottomView:GetView()
	if oView then
		oView:SetActive(false)
	end
end

function CViewCtrl.ShowBottomView(self)
	local oView = CBottomView:GetView()
	if oView then
		oView:SetActive(true)
	end
end

function CViewCtrl.CheckLoginEffect(self)
	local oView = CLoginView:GetView()
	if not oView or g_AttrCtrl.pid > 0 then
		return
	end
	local bHide = false
	for _, v in pairs(self.m_Views) do
		if v.m_DepthType == "Dialog" and
			v:GetInstanceID() ~= oView:GetInstanceID() then
			bHide = true
			break
		end
	end
	oView:SetEffectShow(not bHide)
end

function CViewCtrl.SaveEnv(self, f)
	local oSaveView
	for i, oView in pairs(self.m_Views) do
		if not Utils.IsNil(oView) and f(oView) and oView:GetActive() then
			table.insert(self.m_EnvInfo, oView)
			oView:SetActive(false)
			self:RemoveGroupHide(oView)
		end
	end
	local function sortFunc(v1, v2)
		return v1:GetDepth() < v2:GetDepth()
	end
	table.sort(self.m_EnvInfo, sortFunc)
end

function CViewCtrl.RestoreEnv(self)
	for i,oView in ipairs(self.m_EnvInfo) do
		if not Utils.IsNil(oView) then
			oView:SetActive(true, true)
		end
	end
	self:ClearEnvInfo()
end

function CViewCtrl.ClearEnvInfo(self)
	self.m_EnvInfo = {}
end

function CViewCtrl.CheckLoginAfterCallBack(self, key)
	if key and key == self.m_LoginCbKey then
		self.m_LoginCbKey = false
		table.remove(self.m_LoginAfterCBs, 1)
	end
	if self.m_LoginCbKey then
		return
	end
	if next(self.m_LoginAfterCBs) then
		local d = self.m_LoginAfterCBs[1]
		if d and d.key and d.cb then
			self.m_LoginCbKey = d.key
			d.cb()
		end
	end
end

function CViewCtrl.AddLoginCallBack(self, key, cb)
	table.insert(self.m_LoginAfterCBs, {key = key, cb = cb})
	self:CheckLoginAfterCallBack()
end

return CViewCtrl