local CSocialityPart = class("CSocialityPart", CBox)

function CSocialityPart.ctor(self, cb)
	CBox.ctor(self, cb)
	self.m_SocialityBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CBox)
	self.m_MotionBtn = self:NewUI(3, CButton)
	self.m_PhotoBtn = self:NewUI(4, CButton)
	self.m_MotionPart = self:NewUI(5, CBox)
	self.m_MotionGrid = self:NewUI(6, CGrid)
	self.m_MotionBox = self:NewUI(7, CBox)
	self.m_SocialitySprite = self:NewUI(8, CBox)
	self.m_SocialityTween = self.m_SocialitySprite:GetComponent(classtype.TweenRotation)
	self.m_PlayerPart = self:NewUI(9, CBox)
	self.m_PlayerGrid = self:NewUI(10, CGrid)
	self.m_PlayerBox = self:NewUI(11, CBox)
	self.m_RefreshBtn = self:NewUI(12, CButton)
	self.m_MotionBtnSpr = self:NewUI(13, CSprite)
	
	self:InitContent()
end

function CSocialityPart.InitContent(self)
	self.m_LastTime = 0
	g_UITouchCtrl:TouchOutDetect(self.m_MotionPart, function(obj)
		self:DelayCall(0.1, "ClearSelect", nil)
	end)
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapCtrl"))
	-- g_SocialityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSocialityCtrl"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgCtrl"))
	self.m_SocialityBtn:AddUIEvent("click", callback(self, "OnSocialityBtn"))
	self.m_MotionBtn:AddUIEvent("click", callback(self, "OnMotionBtn"))
	self.m_PhotoBtn:AddUIEvent("click", callback(self, "OnPhotoBtn"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "RefreshPlayer"))
	self.m_MotionPart:SetActive(false)
	self:SetMotionBtnSpr(false)
	-- self.m_BtnGrid:SetActive(false)
	self.m_MotionBox:SetActive(false)
	self.m_PlayerBox:SetActive(false)
	self.m_PlayerPart:SetActive(false)
	self.m_CurrentMotionBox = nil
	self.m_PlayerBoxArr = {}
	-- self.m_HasOrgMemberList = false
	self:SetData()
end

-- function CSocialityPart.OnSocialityCtrl(self, oCtrl)
-- 	if oCtrl.m_EventID == define.Sociality.Event.OnReceivePlay then
-- 		self:ClearSelect()
-- 	end
-- end

function CSocialityPart.OnMapCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.EnterScene then
		self:Reset()
	end
end

function CSocialityPart.Reset(self)
	-- if self.m_BtnGrid:GetActive() then
	-- 	self.m_SocialityTween:Toggle()
	-- end
	self.m_MotionPart:SetActive(false)
	self:SetMotionBtnSpr(false)
	-- self.m_BtnGrid:SetActive(false)
	self.m_MotionBox:SetActive(false)
	self:ClearSelect()
end

function CSocialityPart.ClearSelect(self)
	if self.m_CurrentMotionBox then
		self.m_CurrentMotionBox.m_OnSelect:SetActive(false)
		self.m_CurrentMotionBox = nil
	end
	self.m_PlayerPart:SetActive(false)
end

function CSocialityPart.OnOrgCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.OpenSocail then
		self:RefreshPlayer()
	end
end

function CSocialityPart.SetData(self)
	for i,v in ipairs(data.socialitydata.Sort) do
		local oMotionBox = self:CreateMotionBox()
		oMotionBox:SetData(data.socialitydata.DATA[v])
		oMotionBox:SetActive(true)
	end
end

function CSocialityPart.CreateMotionBox(self)
	local oMotionBox = self.m_MotionBox:Clone()
	oMotionBox.m_Btn = oMotionBox:NewUI(1, CButton)
	oMotionBox.m_OnSelect = oMotionBox:NewUI(2, CBox)
	oMotionBox.m_Btn:AddUIEvent("click", callback(self, "OnSelectMotionBox", oMotionBox))
	oMotionBox.m_OnSelect:SetActive(false)
	self.m_MotionGrid:AddChild(oMotionBox)
	function oMotionBox.SetData(self, oData)
		oMotionBox.m_Data = oData
		oMotionBox.m_Btn:SetSpriteName(oData.icon)
	end
	return oMotionBox
end

function CSocialityPart.OnSelectMotionBox(self, oMotionBox)
 	if not g_ActivityCtrl:ActivityBlockContrl("sociality_part") then
    	return
  	end
	if self.m_CurrentMotionBox then
		self.m_CurrentMotionBox.m_OnSelect:SetActive(false)
	end
	if self.m_CurrentMotionBox == oMotionBox then
		self:ClearSelect()
		return
	else
		self.m_CurrentMotionBox = oMotionBox
		oMotionBox.m_OnSelect:SetActive(true)
	end
	
	if oMotionBox.m_Data.double == 1 then
		local targetPid = nil
		local oView = CMainMenuView:GetView()
		if oView then
			targetPid = oView.m_Center:GetSelectedPid()
		end
		if targetPid then
			self.m_PlayerPart:SetActive(false)
			self:SendMsg(oMotionBox.m_Data.id, targetPid)
		else
			-- if g_OrgCtrl:HasOrg() then
			-- 	if not self.m_OrgMemberList then
			-- 		g_OrgCtrl:GetMemberList(define.Org.HandleType.OpenSocail)
			-- 	else
					self:RefreshPlayer()
				-- end
			-- else
			-- 	self.m_HasOrgMemberList = false
				self:RefreshPlayer()
			-- end
			-- g_NotifyCtrl:FloatMsg("高难度动作，请选择其他玩家配合完成")
		end
	else
		self:SendMsg(oMotionBox.m_Data.id, 0)
		self:ClearSelect()
	end
end

function CSocialityPart.RefreshPlayer(self)
	-- self.m_HasOrgMemberList = true
	self.m_PlayerPart:SetActive(true)
	local playerList = g_MapCtrl:GetInSceenPlayer()
	local function sortFunc(v1, v2)
		local score1 = 0
		local score2 = 0
		if g_FriendCtrl:IsMyFriend(v1.m_Pid) then
			score1 = score1 + 100
		end
		if g_FriendCtrl:IsMyFriend(v2.m_Pid) then
			score2 = score2 + 100
		end
		-- if g_OrgCtrl:GetOrgMember(v1.m_Pid) then
		-- 	score1 = score1 + 10
		-- end
		-- if g_OrgCtrl:GetOrgMember(v2.m_Pid) then
		-- 	score2 = score2 + 10
		-- end
		if score1 == score2 then
			return v1.m_Pid > v2.m_Pid
		end
		return score1 > score2
	end
	local oHero = g_MapCtrl:GetHero()
	table.sort(playerList, sortFunc)
	for i,v in ipairs(playerList) do
		if v== oHero then
			table.remove(playerList, i)
			break
		end
	end

	for i,v in ipairs(playerList) do
		if self.m_PlayerBoxArr[i] == nil then
			self.m_PlayerBoxArr[i] = self:CreatePlayerBox()
		end
		self.m_PlayerBoxArr[i]:SetData(v)
		self.m_PlayerBoxArr[i]:SetActive(true)
	end
	for i= #playerList + 1, #self.m_PlayerBoxArr do
		self.m_PlayerBoxArr[i]:SetActive(false)
	end
	self.m_PlayerGrid:Reposition()
end

function CSocialityPart.CreatePlayerBox(self)
	local oPlayerBox = self.m_PlayerBox:Clone()
	oPlayerBox.m_Btn = oPlayerBox:NewUI(1, CBox)
	oPlayerBox.m_Label = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_SexSprite = oPlayerBox:NewUI(3, CSprite)
	self.m_PlayerGrid:AddChild(oPlayerBox)
	oPlayerBox.m_Btn:AddUIEvent("click", callback(self, "OnSelectPlayerBox", oPlayerBox))
	function oPlayerBox.SetData(self, oPlayer)
		oPlayerBox.m_Data = oPlayer
		oPlayerBox.m_Label:SetText(oPlayer.m_Name)
		if data.modeldata.IS_MAN[oPlayer.m_Actor:GetShape()] then
			oPlayerBox.m_SexSprite:SetSpriteName("pic_nanbiaozhi")
		else
			oPlayerBox.m_SexSprite:SetSpriteName("pic_nvbiaozhi")
		end
	end

	return oPlayerBox
end

function CSocialityPart.OnSelectPlayerBox(self, oPlayerBox)
	-- printc("oPlayerBox: " .. oPlayerBox.m_Data.m_Pid)
 	if not g_ActivityCtrl:ActivityBlockContrl("sociality_part") then
    	return
  	end	
	if self.m_CurrentMotionBox then
		self:SendMsg(self.m_CurrentMotionBox.m_Data.id, oPlayerBox.m_Data.m_Pid)
		
		self:ClearSelect()
	end
end

function CSocialityPart.OnSocialityBtn(self)
	self.m_SocialityTween:Toggle()
	-- self.m_BtnGrid:SetActive(not self.m_BtnGrid:GetActive())
	self.m_MotionPart:SetActive(false)
	self:SetMotionBtnSpr(false)
end

function CSocialityPart.OnMotionBtn(self)
	self.m_MotionPart:SetActive(not self.m_MotionPart:GetActive())
	self:SetMotionBtnSpr(self.m_MotionPart:GetActive())
	self.m_PlayerPart:SetActive(false)
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_Center:HidePlayerAvatar()
	end
end

function CSocialityPart.IsSelectingMotion(self)
	return self.m_BtnGrid:GetActive() and self.m_MotionPart:GetActive()
end

function CSocialityPart.OnPhotoBtn(self)
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
end

function CSocialityPart.OnSelectPlayer(self, oPlayer)
	if self.m_CurrentMotionBox and self.m_CurrentMotionBox.m_Data.double == 1 then
		self:SendMsg(self.m_CurrentMotionBox.m_Data.id, oPlayer.m_Pid)
		self:ClearSelect()
	end
end

function CSocialityPart.SendMsg(self, motionID, pid)
	local oHero = g_MapCtrl:GetHero()
	if g_TeamCtrl:IsInTeam() then
		g_NotifyCtrl:FloatMsg("组队状态下禁止操作，请先离队")
		return
	end

	local currentTime = g_TimeCtrl:GetTimeS()
	if currentTime - self.m_LastTime > 1 then
		self.m_LastTime = currentTime
		nethuodong.C2GSSocailDisplay(motionID, pid)
	else
		g_NotifyCtrl:FloatMsg("操作频繁，请稍后再试")
	end
end

function CSocialityPart.SetMotionBtnSpr(self, b)
	if b == true then
		self.m_MotionBtnSpr:SetSpriteName("pic_liaotian_biaoqing_2")
	else
		self.m_MotionBtnSpr:SetSpriteName("pic_liaotian_biaoqing_1")
	end
end

return CSocialityPart