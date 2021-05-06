local CMarryCtrl = class("CMarryCtrl", CCtrlBase)

function CMarryCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CMarryCtrl.ResetCtrl(self)
	self.m_DefaultText = ""
	self.m_ComfirmText = ""
	self.m_ComfirmName = ""
	self.m_CanExpressTips = nil
	self.m_ChangeTitleCost = 0
	self.m_WaitResponseTime = 0
	self.m_PostFix = "恋人"
	self.m_LoverName = ""
	self.m_IsExpressing = false
	if self.m_Effect then
		self.m_Effect:Destroy()
		self.m_Effect = nil
	end
end

function CMarryCtrl.IsExpressing(self)
	return self.m_IsExpressing
end

function CMarryCtrl.UpdateEditText(self, sText)
	self.m_DefaultText = sText
end

function CMarryCtrl.OpenComfirmView(self, sText, sName, iTime)
	self.m_ComfirmText = sText
	self.m_ComfirmName = sName
	self.m_WaitResponseTime = iTime
	local function closeCb()
		if g_MarryCtrl.m_WaitResponseTime - g_TimeCtrl:GetTimeS() > 0 then
			CExpressComfirmView:ShowView()
		else
			nethuodong.C2GSExpressResponse(2)
			g_NotifyCtrl:FloatMsg("操作超时")
		end
	end
	CExpressAniView:ShowView(function (oView)
		oView:PlayAni()
		oView:SetCloseCb(closeCb)
	end)
end

function CMarryCtrl.GetDefaultText(self)
	if self.m_DefaultText == nil or self.m_DefaultText == "" then
		self.m_DefaultText = IOTools.GetRoleData("marry_express_edit")
	end
	if self.m_DefaultText == nil or self.m_DefaultText == "" then
		self.m_DefaultText = ""
	end
	return self.m_DefaultText
end

function CMarryCtrl.OpenApplyView(self, sTip)
	self.m_CanExpressTips = sTip
	CExpressApplyView:ShowView()
end

function CMarryCtrl.OnOpenResponse(self, bResult, iTime)
	if bResult then
		CExpressResponseView:ShowView(function (oView)
			oView:SetData(iTime - g_TimeCtrl:GetTimeS())
		end)
	else
		self:OnEvent(define.Marry.Event.OnResponse)
	end
end

function CMarryCtrl.OnExpressAction(self, iInvitorID, iTargetID, iEndTime)
	local oPlayer1 = g_MapCtrl:GetPlayer(iInvitorID)
	local oPlayer2 = g_MapCtrl:GetPlayer(iTargetID)
	if oPlayer1 == nil or oPlayer2 == nil then
		return
	end
	local motionID = 10004
	local oData = data.socialitydata.DATA[motionID]
	local function afterSetPos()
		local oSociatyInfo = {
			display_id = motionID,
			target = iTargetID,
			is_invite = 1,
			start_time = iEndTime,
		}
		g_SocialityCtrl:Play(oSociatyInfo, g_MapCtrl:GetPlayer(iInvitorID))
	end
	if iTargetID == g_AttrCtrl.pid then
		oPlayer1:SetPos(oPlayer2:GetPos())
	else
		oPlayer2:SetPos(oPlayer1:GetPos())
	end
	local function effectCb(oEffect)
		oEffect:SetPos(oPlayer1:GetPos())
	end
	self.m_Effect = CEffect.New("Effect/UI/ui_eff_house/Prefabs/marry_express.prefab", oPlayer1:GetLayer(), false, effectCb)
	oPlayer1.m_Actor:SetLocalRotation(Quaternion.Euler(0, oData.rotate_y, 0))
	Utils.AddTimer(afterSetPos, 0, 0)

	local npcID = g_MapCtrl:GetNpcIdByNpcType(5004)
	local oNpc
	if npcID then
		oNpc = g_MapCtrl:GetNpc(npcID)
	end
	if oNpc then
		oNpc:SendMessage("愿主从至圣所赐福于你们。")
	end
end

function CMarryCtrl.OnExpressResult(self, bResult)
	local oView = CExpressResponseView:GetView()
	if oView then
		oView:CloseView()
	end
	if bResult then
		self.m_IsExpressing = true
		oView = CMainMenuView:GetView()
		if oView then
			oView:OnHideView()
		end
		Utils.AddTimer(callback(self, "AfterExpress"), 5, 5)
	end
end

function CMarryCtrl.OpenEditTitleView(self, sPostFix, iCost, sName)
	self.m_ChangeTitleCost = iCost
	self.m_PostFix = sPostFix
	self.m_LoverName = sName
	if not self.m_IsExpressing then
		CExpressEditTitleView:ShowView()
	end
end

function CMarryCtrl.AfterExpress(self)
	self.m_IsExpressing = false
	if self.m_Effect then
		self.m_Effect:Destroy()
		self.m_Effect = nil
	end
	CExpressEditTitleView:ShowView()
	local oView = CMainMenuView:GetView()
	if oView then
		oView:OnHideView()
	end
end

function CMarryCtrl.Test(self)
	self:OnOpenResponse(true, 10)
	Utils.AddTimer(callback(self, "OnOpenResponse", false, 0), 5, 5)
end

function CMarryCtrl.SaveEdit(self, sText)
	self.m_DefaultText = sText
	IOTools.SetRoleData("marry_express_edit", sText)
end

function CMarryCtrl.TimeUp(self)
	local oView = CExpressComfirmView:GetView()
	if oView then
		oView:CloseView()
	end
	oView = CExpressResponseView:GetView()
	if oView then
		oView:CloseView()
	end
end

return CMarryCtrl