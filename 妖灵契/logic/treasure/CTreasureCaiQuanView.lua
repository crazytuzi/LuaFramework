local CTreasureCaiQuanView = class("CTreasureCaiQuanView", CViewBase)

function CTreasureCaiQuanView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasureCaiQuanView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"

	self.SYSCHOICE = {
		--1剪刀，2石头，3布
		[1] = "pic_npc_jiandao",
		[2] = "pic_npc_quantou",
		[3] = "pic_npc_bu",
	}
	self.MYCHOICE={
		--1剪刀，2石头，3布
		[1] = "pic_wanjia_jiandao",
		[2] = "pic_wanjia_quantou",
		[3] = "pic_wanjia_bu",
	}

	self.RECORD = {
		[0] = "pic_caiquan_zhandoujilushibai",
		[1] = "pic_caiquan_zhandoujilushengli",
		[2] = "pic_caiquan_zhandoujilushengli",
	}

	self.m_MyChoice = nil
	self.m_SysChoice = nil
	self.m_AutoAgain = nil
end

function CTreasureCaiQuanView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_SysBox = self:NewUI(3, CBox)
	self.m_SysTweenRotation = self.m_SysBox:GetComponent(classtype.TweenRotation)
	self.m_SysTweenRotation.enabled = false
	self.m_MyBox = self:NewUI(4, CBox)
	self.m_MyTweenRotation = self.m_MyBox:GetComponent(classtype.TweenRotation)
	self.m_MyTweenRotation.enabled = false
	self.m_ChooseGrid = self:NewUI(5, CGrid)
	self.m_ResultTexture = self:NewUI(6, CTexture)
	self.m_ResetLabel = self:NewUI(7, CLabel)
	self.m_VSSprite = self:NewUI(8, CSprite)
	self.m_RecordGrid = self:NewUI(9, CGrid)
	self.m_RecordSpriteClone = self:NewUI(10, CSprite)
	self.m_RecordBG = self:NewUI(11, CSprite)
	self.m_SpineTexture = self:NewUI(12, CSpineTexture)
	self.m_BGTexture = self:NewUI(13, CTexture)
	self.m_PKEffNode = self:NewUI(14, CWidget)
	self.m_PingEffNode = self:NewUI(15, CWidget)
	self.m_YingEffNode = self:NewUI(16, CWidget)
	self.m_FuEffNode = self:NewUI(17, CWidget)
	self.m_ShengEffNode = self:NewUI(18, CWidget)

	g_NetCtrl:SetCacheProto("treasure", true)
	g_NetCtrl:ClearCacheProto("treasure", true)	
	
	self:InitContent()
	self.m_PKEffNode:SetActive(false)
	self.m_PingEffNode:SetActive(false)
	self.m_YingEffNode:SetActive(false)
	self.m_FuEffNode:SetActive(false)
	self.m_ShengEffNode:SetActive(false)
	self.m_SpineTexture:ShapeCommon(1150, function ()
		self.m_SpineTexture:SetAnimation(0, "idle", true)
	end)
	self:InitEffect("Effect/UI/ui_eff_treasure/Prefabs/treasure_fgpk.prefab", self.m_PKEffNode)
	self:InitEffect("Effect/UI/ui_eff_treasure/Prefabs/treasure_fgdraw.prefab", self.m_PingEffNode)
	self:InitEffect("Effect/UI/ui_eff_treasure/Prefabs/treasure_fgfail.prefab", self.m_FuEffNode)
	self:InitEffect("Effect/UI/ui_eff_treasure/Prefabs/treasure_fgwin.prefab", self.m_YingEffNode)
	self:InitEffect("Effect/UI/ui_eff_treasure/Prefabs/treasure_win.prefab", self.m_ShengEffNode)
end

function CTreasureCaiQuanView.InitEffect(self, sPath, oNode)
	local ref = weakref(self.m_BGTexture)
	local function onpkeffload(oClone, errcode)
		if Utils.IsNil(self) then
			oClone:Destroy()
			return
		end
		local oAttach = getrefobj(ref)
		if oClone and oAttach then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oNode.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			mRenderQ.attachGameObject = oAttach.m_GameObject
		end
	end
	g_ResCtrl:LoadCloneAsync(sPath, onpkeffload)
end

function CTreasureCaiQuanView.EffectPlay(self, oNode)
	oNode:SetActive(true)
	if oNode.m_Timer then
		Utils.DelTimer(oNode.m_Timer)
		oNode.m_Timer = nil
	end
	local function autohide()
		if Utils.IsNil(self) then
			return
		end
		oNode:SetActive(false)
	end
	oNode.m_Timer = Utils.AddTimer(autohide, 3, 3)
end

function CTreasureCaiQuanView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)

	self.m_ResultTexture:SetActive(false)
	self.m_ResetLabel:SetActive(false)
	self.m_SysBox:SetActive(false)
	self.m_MyBox:SetActive(false)
	self.m_VSSprite:SetActive(false)
	self.m_ChooseGrid:SetActive(true)
	self.m_RecordSpriteClone:SetActive(false)
	self.m_RecordBG:SetActive(false)
	self.m_SysBox.m_Sprite = self.m_SysBox:NewUI(1, CSprite)
	self.m_MyBox.m_Sprite = self.m_MyBox:NewUI(1, CSprite)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ResultTexture:AddUIEvent("click", callback(self, "OnReset"))

	self.m_ChooseGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_Idx = idx
		oBox.m_Sprite = oBox:NewUI(1, CSprite)
		oBox:AddUIEvent("click", callback(self, "OnChooseBox"))
		return oBox
	end)
end

function CTreasureCaiQuanView.ResetView(self)
	self.m_IsResult = false
	self.m_ResultTexture:SetActive(false)
	self.m_ResetLabel:SetActive(false)
	self.m_ChooseGrid:SetActive(true)
	self.m_RecordBG:SetActive(false)
	self.m_SpineTexture:SetAnimation(0, "idle", true)
end

function CTreasureCaiQuanView.SetSessionidx(self, sessionidx)
	self.m_Sessionidx = sessionidx
end

function CTreasureCaiQuanView.ShowCaiQuanResult(self, syschoice, result, sessionidx)
	self.m_SysChoice = syschoice
	self.m_ResultType = result
	self.m_IsResult = true
	self.m_Sessionidx = sessionidx
	self.m_AutoAgain = result == 0 or result == 2
end

function CTreasureCaiQuanView.ShowResultAnim(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_VSSprite:SetActive(false)
	self:EffectPlay(self.m_PKEffNode)
	self.m_MyBox:SetActive(true)
	self.m_SysBox:SetActive(true)
	self.m_SysTweenRotation.enabled = true
	self.m_MyTweenRotation.enabled = true
	self.m_MyBox.m_Sprite:SetSpriteName(self.MYCHOICE[2])
	self.m_SysBox.m_Sprite:SetSpriteName(self.SYSCHOICE[2])
	self.m_SpineTexture:SetAnimation(0, "defy", true)
	local result = false
	local function anim()
		if Utils.IsNil(self) then
			return
		end
		if result then
			self.m_ResultTexture:SetActive(true)
			if self.m_ResultType == 0 then
				self:EffectPlay(self.m_FuEffNode)
				self.m_SpineTexture:SetAnimation(0, "win", true)
			elseif self.m_ResultType == 1 then
				self:EffectPlay(self.m_YingEffNode)
				self.m_SpineTexture:SetAnimation(0, "lose", true)
			elseif self.m_ResultType == 2 then
				self:EffectPlay(self.m_PingEffNode)
				self.m_SpineTexture:SetAnimation(0, "deuce", true)
			end
			self.m_ResetLabel:SetActive(self.m_AutoAgain)
			self:AutoAgain(self.m_AutoAgain)
			return false
		else
			result = true
			self.m_SysTweenRotation.enabled = false
			self.m_MyTweenRotation.enabled = false
			self.m_MyBox:SetLocalRotation(Quaternion.Euler(0,0,0))
			self.m_SysBox:SetLocalRotation(Quaternion.Euler(0,0,0))
			self.m_MyBox.m_Sprite:SetSpriteName(self.MYCHOICE[self.m_MyChoice])
			self.m_SysBox.m_Sprite:SetSpriteName(self.SYSCHOICE[self.m_SysChoice])
			return true
		end
	end
	self.m_Timer = Utils.AddTimer(anim, 1, 1)
end

function CTreasureCaiQuanView.OnChooseBox(self, oBox)
	self.m_MyChoice = oBox.m_Idx
	self.m_ChooseGrid:SetActive(false)
	netother.C2GSCallback(self.m_Sessionidx, self.m_MyChoice)
	self:ShowResultAnim()
end

function CTreasureCaiQuanView.OnReset(self, obj)
	if self.m_AutoAgain then
		self:ResetView()
		self:ClearAutoAgainTimer()
		netother.C2GSCallback(self.m_Sessionidx, 1)
	else
		self:CloseView()
	end
end

function CTreasureCaiQuanView.ClearAutoAgainTimer(self)
	if self.m_AutoAgainTimer then
		Utils.DelTimer(self.m_AutoAgainTimer)
		self.m_AutoAgainTimer = nil
	end
end

function CTreasureCaiQuanView.AutoAgain(self, bAuto)
	if bAuto then
		self:ClearAutoAgainTimer()
		local iTime = 5
		local function auto()
			if Utils.IsNil(self) then
     			return false
     		end
			if iTime <= 0 then
				self:OnReset()
				return false
			else
				iTime = iTime - 1
				self.m_ResetLabel:SetText(string.format("点击再来一次(%dS)", iTime))
				return true
			end
		end
		self.m_AutoAgainTimer = Utils.AddTimer(auto, 1, 0)
	else
		self.m_AutoAgainTimer = Utils.AddTimer(callback(self, "CloseView"), 2, 2)
	end
end

function CTreasureCaiQuanView.SetRecord(self, record)
	if record and #record > 0 then
		self.m_RecordGrid:Clear()
		for i,v in ipairs(record) do
			if v.result ~= 3 and v.sys_choice and v.player_choice then
				self.m_VSSprite:SetActive(true)
				self.m_RecordBG:SetActive(true)
				local oSprite = self.m_RecordSpriteClone:Clone()
				oSprite:SetActive(true)
				oSprite:SetSpriteName(self.RECORD[v.result])
				self.m_MyBox:SetActive(true)
				self.m_SysBox:SetActive(true)
				self.m_MyBox.m_Sprite:SetSpriteName(self.MYCHOICE[v.player_choice])
				self.m_SysBox.m_Sprite:SetSpriteName(self.SYSCHOICE[v.sys_choice])
				self.m_RecordGrid:AddChild(oSprite)
			end
		end
		self.m_RecordGrid:Reposition()
	else
		printc("--record数据异常--")
		self:CloseView()
	end
end

function CTreasureCaiQuanView.SetCaiQuanGameEnd(self, result)
	self.m_GameEndResult = result
end

function CTreasureCaiQuanView.ShowCaiQuanGameEnd(self)
	if self.m_GameEndResult == 0 then --失败
		g_NotifyCtrl:FloatMsg("游戏结束，即将退出副本")
	elseif self.m_GameEndResult == 1 then --胜利
		self.m_ResultTexture:SetActive(true)
		self.m_ResetLabel:SetActive(false)
		self.m_SysBox:SetActive(false)
		self.m_MyBox:SetActive(false)
		self.m_VSSprite:SetActive(false)
		self.m_ChooseGrid:SetActive(false)
		self.m_RecordSpriteClone:SetActive(false)
		self.m_RecordBG:SetActive(false)
		self:EffectPlay(self.m_ShengEffNode)
		g_NotifyCtrl:FloatMsg("游戏胜利，即将退出副本")
	end
	self.m_GameEndResult = nil
	Utils.AddTimer(callback(self, "CloseView"), 2, 2)
end

function CTreasureCaiQuanView.DelayClose(self, cb)
	if self.m_IsResult then
		self.m_CloseViewCB = cb
	else
		self:CloseView()
	end
end

function CTreasureCaiQuanView.CloseView(self)
	if self.m_GameEndResult then
		self:ShowCaiQuanGameEnd()
		return
	end
	g_NetCtrl:SetCacheProto("treasure", false)
	g_NetCtrl:ClearCacheProto("treasure", true)	
	CViewBase.CloseView(self)
end

return CTreasureCaiQuanView