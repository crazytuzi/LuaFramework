local CChoukaCtrl = class("CChoukaCtrl", CCtrlBase)

function CChoukaCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ChoukaRoot = nil
	self.m_IsInChouka = false
	self.m_Layer = UnityEngine.LayerMask.NameToLayer("CreateRole")
	self.m_RandomList = {}
	self.m_NRandomList = {}
	local t = {1754, 1753, 1755}
	for pid, cdata in pairs(data.partnerdata.DATA) do
		if cdata.show_type == 1 then
			if not table.index(t, cdata.partner_type) then
				if cdata.rare > 1 then
					table.insert(self.m_RandomList, cdata.shape)
				end
				if cdata.rare < 2 then
					table.insert(self.m_NRandomList, cdata.shape)
				end
			end
		end
	end
	self:ResetCtrl()
end

function CChoukaCtrl.ResetCtrl(self)
	self.m_ResultList = {}
	self.m_ModelData = {}
	self.m_ResultDesc = ""
	self.m_RedrawCost = 0
end

function CChoukaCtrl.GetLayer(self)
	return self.m_Layer
end

function CChoukaCtrl.IsInChouka(self)
	return self.m_IsInChouka
end

function CChoukaCtrl.StartChouka(self)
	if self:IsForbit() or self.m_IsInChouka then
		return
	end
	self.m_IsInChouka = true
	self.m_ChoukaRoot = CObject.New(UnityEngine.GameObject.New("ChoukaRoot"))
	g_MapCtrl:AddCtrlEvent(self.m_ChoukaRoot, callback(self, "OnMapEvent"))
	g_TeamCtrl:AddCtrlEvent(self.m_ChoukaRoot, callback(self, "OnTeamEvent"))
	self:HideMainMenu()
	self:ShowView()
	--netpartner.C2GSOpenDrawCardUI()
end

--先加载界面，再显示地图
function CChoukaCtrl.ShowView(self)
	self:InitRoot()
	CLuckyDrawView:ShowView()
end

function CChoukaCtrl.InitRoot(self)
	g_MapCtrl:Clear(false)
	--g_MapCtrl:Load(6300, 1)
	g_ViewCtrl:CloseAll({"CMainMenuView", "CLuckyDrawView", "CGuideView", "CBulletScreenView"})
	local mainmenuView = CMainMenuView:GetView()
	if mainmenuView then
		mainmenuView:SetActive(false)
	end
	self:InitWHCamera()
end


function CChoukaCtrl.Close(self)
	if self.m_IsInChouka then
		netpartner.C2GSCloseDrawCardUI()
	end
end

function CChoukaCtrl.ExitChouka(self)
	if self.m_ChoukaRoot then
		g_MapCtrl:DelCtrlEvent(self.m_ChoukaRoot, callback(self, "OnMapEvent"))
		g_MapCtrl:DelCtrlEvent(self.m_ChoukaRoot, callback(self, "OnTeamEvent"))
		self.m_IsInChouka = false
		self:ClearActor()
		self:CloseWHEffect()
		self:CloseWLEffect()
		self:ClearModels()
		self:ShowMainMenu()
		self.m_ChoukaRoot:Destroy()
		self.m_ChoukaRoot = nil
		g_CameraCtrl:GetEffectCamera():SetEnabled(false)
		g_CameraCtrl:AutoActive()
	end
end

function CChoukaCtrl.SetResult(self, itype, partner_list, desc, redraw_cost)
	self:StartChouka()
	self:HideBuilding()
	self:HideDrawView()
	self.m_ResultType = itype
	self.m_ResultList = table.copy(partner_list)
	self.m_ResultDesc = desc or ""
	self.m_RedrawCost = redraw_cost or 0
	if itype == 1 then
		self:ShowWLResult()
	else
		if #partner_list == 5 then
			self.m_ResultType = 3
			self:ResortResult()
			self:ShowWLResult()
		else
			self:ShowWHResult()
		end
	end
end

function CChoukaCtrl.ResortResult(self)
	local maxindex = nil
	local maxrare = 2
	local lPartnerList = {}
	for i, iParID in ipairs(self.m_ResultList) do
		local oPartner = g_PartnerCtrl:GetPartner(iParID)
		table.insert(lPartnerList, oPartner)
	end
	table.sort(lPartnerList, function (a, b)
		if a:GetValue("rare") ~= b:GetValue("rare") then
			return a:GetValue("rare") > b:GetValue("rare")
		end
		return false
	end)
	self.m_ResultList = {}
	local list = {3, 2, 4, 1, 5}
	for i, oPartner in ipairs(lPartnerList) do
		self.m_ResultList[list[i]] = oPartner.m_ID
	end
end

function CChoukaCtrl.OnMapEvent(self, oCtrl)
	local iResID = g_MapCtrl:GetResID()
	if self.m_IsInChouka and (iResID== 6200 or iResID == 6300)then
		if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
			local obj = oCtrl.m_EventData
			obj:SetParent(self.m_ChoukaRoot.m_Transform)
			self:OnMapLoadDone()
		end
	
	else
		if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
			self:ExitChouka(self)
		end
	end
end


function CChoukaCtrl.OnTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam then
		self:Close()
	end
end

function CChoukaCtrl.OnMapLoadDone(self)
	local obj = g_MapCtrl:GetCurMapObj()
	local resid = g_MapCtrl:GetResID()
	g_CameraCtrl:AutoActive()
	if resid == 6200 then

	elseif resid == 6300 then
		self.m_ModelData = {}
		local zhuzi = obj:Find("Model"):Find("6300_05")
		self.m_ModelData["zhuzi"] =  CObject.New(zhuzi.gameObject)
		if self.m_ResultType == 1 then
			self:StartWLEffect()
		elseif self.m_ResultType == 3 then
			self:StartWLEffect()
		else
			self:StartWHEffect()
		end
	end
end

function CChoukaCtrl.HideDrawView(self)
	local oView = CLuckyDrawView:GetView()
	if oView then
		oView:ShowSubPage()
	else
		CLuckyDrawView:ShowView(function (oView)
			oView:ShowSubPage()
		end)
	end
end

function CChoukaCtrl.HideBuilding(self)
	if self.m_ModelData["jianzhu"] then
		self.m_ModelData["jianzhu"].m_GameObject:SetActive(false)
	end
end

function CChoukaCtrl.HideMainMenu()
	g_NotifyCtrl:HideConnect()
	local mainmenuView = CMainMenuView:GetView()
	if mainmenuView then
		mainmenuView:SetActive(false)
		mainmenuView.m_GroupName = nil
	end
	g_ViewCtrl:CloseAll({"CMainMenuView", "CGuideView"})
	g_MapTouchCtrl:StopAutoWalk()
end

function CChoukaCtrl.ShowMainMenu()
	local mainmenuView = CMainMenuView:GetView()
	if mainmenuView then
		mainmenuView:SetActive(true)
		mainmenuView.m_GroupName = "main"
	end
end

function CChoukaCtrl.IsForbit(self)
	if g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeave() then
		g_NotifyCtrl:FloatMsg("请先暂离队伍再进行招募")
		return true
	end
	
	if g_WarCtrl:IsWar() then
		g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
		return true
	end
	return false
end

function CChoukaCtrl.ShowMainPage(self, itype)
	self:ClearActor()
	if itype == 1 then
		self:CloseWLEffect()
		self:ClearModels()
		g_MapCtrl:Load(6200, 1)
		self:InitWHCamera()
	else
		if self.m_ModelData and self.m_ModelData["jianzhu"] then
			self.m_ModelData["jianzhu"].m_GameObject:SetActive(true)
		end
		self:ClearModels()
		self:CloseWHEffect()
		g_MapCtrl:Load(6200, 1)
		self:InitWHCamera()
	end
end

function CChoukaCtrl.ForceShowMain(self)
	if not self.m_MoveCameraEffect then
		CLuckyDrawView:ShowView(function (oView)
			oView.m_Container:SetActive(true)
			oView:ShowMain()
		end)
		self:InitWHCamera()
	end
end

--开始镜头移动
function CChoukaCtrl.MoveStartCamera(self)
	local function cb()
		CLuckyDrawView:ShowView(function (oView)
			oView.m_Container:SetActive(true)
			oView:ShowMain()
		end)
		if self.m_MoveCameraEffect then
			self.m_MoveCameraEffect:Destroy()
			self.m_MoveCameraEffect = nil
		end
	end
	self.m_MoveCameraEffect = CAnimatorEffect.New("Effect/UI/ui_eff_6200/Prefabs/scene_6200_camera_02.prefab", self.m_Layer, false)
	self.m_MoveCameraEffect:AnimObj(g_CameraCtrl:GetChoukaCamera())
	Utils.AddTimer(cb, 0, 1)
end

function CChoukaCtrl.ClearModels(self)
	self.m_ModelData = {}
end

function CChoukaCtrl.SetBtnShow(self, bShow)
	local oView = CLuckyDrawView:GetView()
	if oView then
		oView:SetBtnShow(bShow)
	end
	
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	local oBulletView = CBulletScreenView:GetView()
	if istate == 1 and oBulletView then
		oBulletView:SetActive(bShow)
	end
end

------------------------武魂抽卡-------------------

function CChoukaCtrl.InitWHCamera(self)
	local oCamera = g_CameraCtrl:GetChoukaCamera()
	oCamera:SetLocalPos(Vector3.New(0, 0.124, -8.125))
	oCamera:SetLocalRotation(Quaternion.Euler(0.6679, 0, 0))
end

function CChoukaCtrl.ShowWHResult(self)
	self:ClearActor()
	g_MapCtrl:Load(6300, 1)
end

function CChoukaCtrl.StartWHEffect(self)
	self:InitWLCamera()
	self:CloseWHEffect()
	self.m_WHEffect = CEffect.New("Effect/UI/ui_eff_6200/Prefabs/ui_eff_6200_pr_01.prefab", self.m_Layer, false, callback(self, "OnWHEffectDone"))
	self:DoRotationEffect()
end

function CChoukaCtrl.OnWHEffectDone(self)
	local t = 0
	local bCreateEffect, bCreateModel, bResultEffect, bResultEffect2 = false, false, false, false
	local function update(dt)
		t = t + dt
		if not bCreateEffect and t >= 0.85 then
			bCreateEffect = true
			self:CreateWHEffect()
		end
		if not bResultEffect and t >= 1.75 then
			bResultEffect = true
			self:DoResultEffect()
		end
		if not bResultEffect2 and t >= 2.5 then
			self:DoResultEffect2()
			bResultEffect2 = true
		end
		if not bCreateModel and t >= 3.75 then
			bCreateModel = true
			self:ShowWHModel()
		end
		if t >= 7 then
			self:CloseWHEffect()
			self:SetBtnShow(true)
			return false
		end
		return true
	end
	if self.m_WHEffectTimer then
		Utils.DelTimer(self.m_WHEffectTimer)
	end
	self:SetBtnShow(false)
	self.m_WHEffectTimer = Utils.AddTimer(update, 0.1, 0)
end

function CChoukaCtrl.CreateWHEffect(self)
	self:CreateWLEffectCamera()
	local width = 1.5
	local iAmount = #self.m_ResultList
	local k, b = width/2, -width/2
	local startX = k*iAmount +b
	if self.m_WHEffectList then
		for _, effect in ipairs(self.m_WHEffectList) do
			effect:Destroy()
		end
	end
	self.m_WHEffectList = {}
	for i = 1, iAmount do
		local effect = CEffect.New("Effect/UI/ui_eff_6200/Prefabs/ui_eff_6200_pr.prefab", self.m_Layer, false)
		effect:SetLocalPos(Vector3.New(startX - (i-1) * width, 0, 0))
		table.insert(self.m_WHEffectList, effect)
	end
	--延时1.1s出现
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		for i = 1, iAmount do
			local effect = CEffect.New("Effect/UI/ui_eff_6200/Prefabs/ui_eff_6200_zhaohuan.prefab", define.Layer.Effect, false)
			effect:SetLocalPos(Vector3.New(startX - (i-1) * width, 0, 0))
			table.insert(self.m_WHEffectList, effect)
		end
	end

	Utils.AddTimer(delay, 0, 2.65)
end

function CChoukaCtrl.ShowWHModel(self)
	local oView = CLuckyDrawView:GetView()
	if oView then
		oView:SetResult(2, self.m_ResultList or {}, self.m_ResultDesc, self.m_RedrawCost)
	else
		CLuckyDrawView:ShowView(function(oView)
			oView:SetResult(2, self.m_ResultList or {}, self.m_ResultDesc, self.m_RedrawCost)
		end)
	end
	local parid = self.m_ResultList[1]
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	if not oPartner then
		return
	end
	local dModelInfo = oPartner:GetValue("model_info")
	if not self.m_WHActor then
		self.m_WHActor = CActor.New()
		self.m_WHActor:SetName("wh_actor")
		self.m_WHActor:SetLayer(self.m_Layer)
		self.m_WHActor:SetParent(self.m_ChoukaRoot.m_Transform)
		self.m_WHActor:SetLocalPos(Vector3.New(0, 1, 3))
	end
	local c = self.m_WHActor:GetMatColor()
	local action = CActionColor.New(self.m_WHActor, 1.4, "SetMatColor", Color.New(c.r, c.g, c.b, 0), Color.New(c.r, c.g, c.b, 1))
	g_ActionCtrl:AddAction(action)
	self.m_WHActor:ChangeShape(dModelInfo.shape, dModelInfo, function() 
			if Utils.IsExist(self.m_WHActor) then
				self.m_WHActor:CrossFade("show")
				self:PlayVoice(oPartner:GetValue("sounds"))
			end
		end)
end

function CChoukaCtrl.PlayVoice(self, soundsList)
	if soundsList and #soundsList > 0 then
		local filename = table.randomvalue(soundsList)
		filename = string.format("Audio/Sound/Magic/%s.wav", filename)
		g_AudioCtrl:PlaySingle(filename)
	end
end

function CChoukaCtrl.ClearActor(self)
	if self.m_WHActor then
		self.m_WHActor:Destroy()
		self.m_WHActor = nil
	end
end

function CChoukaCtrl.ShowActor(self, bShow)
	if self.m_WHActor then
		self.m_WHActor:SetActive(bShow)
	end
end

function CChoukaCtrl.CloseWHEffect(self)
	if self.m_MoveCameraEffect then
		self.m_MoveCameraEffect:Destroy()
	end
	self.m_MoveCameraEffect = nil
	if self.m_WHEffect then
		self.m_WHEffect:Destroy()
	end
	if self.m_WHEffect2 then
		self.m_WHEffect2:Destroy()
	end
	if self.m_ResultEffect then
		self.m_ResultEffect:Destroy()
	end
	if self.m_WHEffectTimer then
		Utils.DelTimer(self.m_WHEffectTimer)
		self.m_WHEffectTimer = nil
		self:SetBtnShow(true)
	end
	
	if self.m_WHEffectList then
		for _, effect in ipairs(self.m_WHEffectList) do
			effect:Destroy()
		end
	end
	self.m_WHEffectList = {}
	
	self.m_WHEffect = nil
	self.m_WHEffect2 = nil
	self.m_ResultEffect = nil
end

--武灵抽卡

function CChoukaCtrl.ShowWLResult(self)
	self:ClearModels()
	g_MapCtrl:Load(6300, 1)
end

function CChoukaCtrl.StartWLEffect(self)
	self:InitWLCamera()
	self:CloseWLEffect()
	self.m_WLEffect = CEffect.New("Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_pr_01.prefab", self.m_Layer, false, callback(self, "OnWLEffectDone"))
	self:DoRotationEffect()
end

function CChoukaCtrl.InitWLCamera(self)
	local oCamera = g_CameraCtrl:GetChoukaCamera()
	oCamera:SetLocalPos(Vector3.New(0, 3.8, 11.8))
	oCamera:SetLocalRotation(Quaternion.Euler(11.93, 180, 0))
end

function CChoukaCtrl.OnWLEffectDone(self)
	local t = 0
	local bCreateEffect, bCreateModel = false, false
	local function update(dt)
		t = t + dt
		if not bCreateEffect and t >= 1.6 then
			bCreateEffect = true
			self:CreateWLEffect()
		end
		if not bCreateModel and t >= 2.7 then
			bCreateModel = true
			self:ShowWLModel()
		end
		if t >= 5 then
			self:CloseWLEffect()
			self:SetBtnShow(true)
			return false
		end
		return true
	end
	if self.m_WLEffectTimer then
		Utils.DelTimer(self.m_WLEffectTimer)
	end
	self:SetBtnShow(false)
	self.m_WLEffectTimer = Utils.AddTimer(update, 0.1, 0)
end

function CChoukaCtrl.CreateWLEffectCamera(self)
	local effectCamera = g_CameraCtrl:GetEffectCamera()
	effectCamera:SetEnabled(true)
	effectCamera:SetDepth(define.Layer.Effect)
	effectCamera:SetCullingMask(0)
	effectCamera:OpenCullingMask(define.Layer.Effect)
	effectCamera:SetFieldOfView(26)
	effectCamera:SetLocalPos(Vector3.New(0, 3.8, 11.8))
	effectCamera:SetLocalRotation(Quaternion.Euler(11.93, 180, 0))
end

function CChoukaCtrl.CreateWLEffect(self)
	self:CreateWLEffectCamera()
	local width = 1.5
	local iAmount = #self.m_ResultList
	local k, b = width/2, -width/2
	local startX = k*iAmount +b
	if self.m_WLEffectList then
		for _, effect in ipairs(self.m_WLEffectList) do
			effect:Destroy()
		end
	end
	self.m_WLEffectList = {}
	for i = 1, iAmount do
		local effect = CEffect.New("Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_pr_02.prefab", self.m_Layer, false)
		effect:SetLocalPos(Vector3.New(startX - (i-1) * width, 0, 0))
		table.insert(self.m_WLEffectList, effect)
	end
	--延时1.1s出现
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		for i = 1, iAmount do
			local effect = CEffect.New("Effect/UI/ui_eff_6300/Prefabs/ui_eff_6300_zhaohuan.prefab", define.Layer.Effect, false)
			effect:SetLocalPos(Vector3.New(startX - (i-1) * width, 0, 0))
			table.insert(self.m_WLEffectList, effect)
		end
	end

	Utils.AddTimer(delay, 0, 1.1)
end

function CChoukaCtrl.DoRotationEffect(self)
	if self.m_ResultType == 1 then
		self:CreateWLShadow()
	elseif self.m_ResultType == 3 then
		self:CreateWLShadow()
	else
		self:CreateWHShadow()
	end
	local iRotate = 360
	if #self.m_ResultList % 2 == 0 then
		iRotate = 360 - 36/2
	end
	local vRotate = self.m_ModelData["zhuzi"]:GetRotation().eulerAngles
	if 360 - vRotate.y < 20 then
		iRotate = iRotate +  (360 - vRotate.y)
	end
	local tween = DOTween.DOLocalRotate(self.m_ModelData["zhuzi"].m_Transform, Vector3.New(0, 0, iRotate), 2, enum.DOTween.RotateMode.LocalAxisAdd)
	DOTween.SetEase(tween, enum.DOTween.Ease.InOutCubic)
end

function CChoukaCtrl.DoResultEffect(self)
	self:CreateWLEffectCamera()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ResultList[1])
	if oPartner then
		local iShape = oPartner:GetValue("shape")
		local effect = CChoukaEffect2.New(iShape, self.m_Layer)
		self.m_ResultEffect = effect
	end
end

function CChoukaCtrl.DoResultEffect2(self)
	local oView = CLuckyDrawView:GetView()
	if oView then
		oView:DoResultEffect2(self.m_ResultList[1])
	end
end

function CChoukaCtrl.GetDrawList(self)
	if self.m_ResultType == 1 or self.m_ResultType == 3 then
		local partnerList = self:GetNRandomList(5)
		local iAmount = #self.m_ResultList
		local idx = 4 - math.round(iAmount/2)
		for i = idx, idx + iAmount -1 do
			local iPartnerID = self.m_ResultList[i-idx+1]
			partnerList[i] = g_PartnerCtrl:GetPartner(iPartnerID):GetValue("partner_type")
		end
		local drawList = {}
		for i = 1, 10 do
			drawList[i] = partnerList[(-i+13)%5+1]
		end
		return drawList
	else
		local iPartnerID = self.m_ResultList[1]
		local drawList = self:GetRandomList(10)
		local iShape = g_PartnerCtrl:GetPartner(iPartnerID):GetValue("partner_type") or 301
		drawList[1] = iShape
		return drawList
	end
end

function CChoukaCtrl.GetRandomList(self, num)
	table.shuffle(self.m_RandomList)
	local list = {}
	for i = 1, num do
		list[i] = self.m_RandomList[i] or 301
	end
	return list
end

function CChoukaCtrl.GetNRandomList(self, num)
	table.shuffle(self.m_NRandomList)
	local list = {}
	for i = 1, num do
		list[i] = self.m_NRandomList[i] or 301
	end
	return list
end

function CChoukaCtrl.CreateWLShadow(self)
	if self.m_ShadowEffectList then
		for _, oEffect in ipairs(self.m_ShadowEffectList) do
			oEffect:Destroy()
		end
	end
	self.m_ShadowEffectList = {}
	local drawList = self:GetDrawList()
	local R = 2.1
	for i = 1, 10 do
		local effect = CChoukaEffect.New(drawList[i], 1, self.m_ModelData["zhuzi"], self.m_Layer)
		effect:SetLocalRotation(Quaternion.Euler(0, 0, -36*(i-1)))
		local x = R * math.sin(36*(i-1)*2*math.pi / 360)
		local y = R * math.cos(36*(i-1)*2*math.pi / 360)
		effect:SetLocalPos(Vector3.New(x, y, 0.3))
		self.m_ShadowEffectList[i] = effect
	end
end

function CChoukaCtrl.CreateWHShadow(self)
	if self.m_ShadowEffectList then
		for _, oEffect in ipairs(self.m_ShadowEffectList) do
			oEffect:Destroy()
		end
	end
	self.m_ShadowEffectList = {}
	local drawList = self:GetDrawList()
	local R = 2.1
	for i = 1, 10 do
		local effect = nil
		if i == 1 then
			effect = CChoukaEffect.New(drawList[i], 1, self.m_ModelData["zhuzi"], self.m_Layer)
		else
			effect = CChoukaEffect.New(drawList[i], 2, self.m_ModelData["zhuzi"], self.m_Layer)
		end

		effect:SetLocalRotation(Quaternion.Euler(0, 0, -36*(i-1)))
		local x = R * math.sin(36*(i-1)*2*math.pi / 360)
		local y = R * math.cos(36*(i-1)*2*math.pi / 360)
		effect:SetLocalPos(Vector3.New(x, y, 0.3))
		self.m_ShadowEffectList[i] = effect
	end
end

function CChoukaCtrl.ShowWLModel(self)
	local oView = CLuckyDrawView:GetView()
	local itype = self.m_ResultType or 1
	if oView then
		oView:SetResult(itype, self.m_ResultList or {})
	else
		CLuckyDrawView:ShowView(function(oView)
			oView:SetResult(itype, self.m_ResultList or {})
		end)
	end
end

function CChoukaCtrl.CloseWLEffect(self)
	if self.m_WLEffect then
		self.m_WLEffect:Destroy()
	end
	if self.m_WLEffectList then
		for _, oEffect in ipairs(self.m_WLEffectList) do
			oEffect:Destroy()
		end
	end
	if self.m_WLEffectTimer then
		Utils.DelTimer(self.m_WLEffectTimer)
		self.m_WLEffectTimer = nil
		self:SetBtnShow(true)
	end
	if self.m_ShadowEffectList then
		for _, oEffect in ipairs(self.m_ShadowEffectList) do
			oEffect:Destroy()
		end
	end
	self.m_ShadowEffectList = {}

	self.m_WLEffect = nil
	self.m_WLEffectList = {}
end

function CChoukaCtrl.SyncCardPos(self, oCard, iEffectIdx)
	local width = 1.5
	local iAmount = #self.m_ResultList
	local k, b = width/2, -width/2
	local startX = k*iAmount +b
	local oChoukaCam = g_CameraCtrl:GetChoukaCamera()
	local oUICam = g_CameraCtrl:GetUICamera()
	local viewPos = oChoukaCam:WorldToViewportPoint(Vector3.New(startX - (iEffectIdx-1) * width, 0.7, 0))
	local oUIPos = oUICam:ViewportToWorldPoint(viewPos)
	oUIPos.z = 0
	oCard:SetPos(oUIPos)
end


return CChoukaCtrl