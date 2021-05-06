local CExpandYJFbPage = class("CExpandYJFbPage", CPageBase)

function CExpandYJFbPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandYJFbPage.OnInitPage(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_TimeLabel = self:NewUI(2, CLabel)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_IconBox = self:NewUI(4, CBox)
	self.m_AutoFightBtn = self:NewUI(5, CButton)
	self.m_QuitBtn = self:NewUI(6, CButton)
	self.m_FightInfoSpr = self:NewUI(7, CSprite)
	self.m_ShowBox = self:NewUI(8, CBox)
	self.m_HideBox = self:NewUI(9, CBox)
	self.m_CloseBtn = self:NewUI(10, CButton)
	self.m_OpenBtn = self:NewUI(11, CButton)
	self.m_ScrollView= self:NewUI(12, CScrollView)

	self.m_Timer = nil
	self.m_ConditionLabelList = {}

	self:InitContent()
end

function CExpandYJFbPage.InitContent(self)
	self.m_IconBox:SetActive(false)
	self.m_AutoFightBtn:AddUIEvent("click", callback(self, "OnAuto"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuitFb"))
	self.m_FightInfoSpr:AddUIEvent("click", callback(self, "OnOpenFightInfo"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_OpenBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))	
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	self:RefreshGrid()
	self:RefreshAll(true)
end

function CExpandYJFbPage.RefreshGrid(self)
	local npcdata = data.yjfubendata.NPC
	local bossdata =data.yjfubendata.BossDesc
	local npclist = g_ActivityCtrl:GetYJFbCtrl():GetNpcList()
	if self:IsSameNpc(npclist) then
		return
	end
	self.m_NpcList = npclist
	self.m_Grid:Clear() 
	local behindlist = {}
	local index = 1
	for _, oNpc in pairs(npclist) do
		local id = oNpc.idx
		local v = npcdata[id]
		if v then
			local box = self.m_IconBox:Clone()
			box.m_Sprite = box:NewUI(1, CSprite)
			box.m_Label = box:NewUI(2, CLabel)
			box.m_ClickBox = box:NewUI(3, CButton)
			box.m_DescLabel = box:NewUI(4, CLabel)
			box.m_Sprite:SpriteAvatar(oNpc.shape)
			box.m_Label:SetText(oNpc.name)
			if bossdata[oNpc.bossid] and bossdata[oNpc.bossid].content then
				box.m_DescLabel:SetText(bossdata[oNpc.bossid].content)
			else
				box.m_DescLabel:SetText("")
			end
			box:SetActive(true)
			box.m_ClickBox:AddUIEvent("click", callback(self, "OnClickNpc", id))

			if index == 1 and not g_GuideCtrl:IsCustomGuideFinishByKey("show_YJFB_enter_effect") then
				box.m_ClickBox:AddEffect("bordermove", nil, nil, 2)
				g_GuideCtrl:ReqCustomGuideFinish("show_YJFB_enter_effect") 
			end			

			if oNpc.dead then
				box.m_Sprite:SetGrey(true)
				table.insert(behindlist, box)
			else
				box.m_Sprite:SetGrey(false)
				self.m_Grid:AddChild(box)
			end
			index = index + 1
		end
	end
	for _, box in ipairs(behindlist) do
		self.m_Grid:AddChild(box)
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CExpandYJFbPage.OnClickNpc(self, iNpcID, obj)
	if g_TeamCtrl:IsInTeam() and not g_TeamCtrl:IsLeader() then
		g_NotifyCtrl:FloatMsg("只有队长才能进行此操作")
		return
	end
	if self.m_LastTime and g_TimeCtrl:GetTimeS() - self.m_LastTime < 1 then
		g_NotifyCtrl:FloatMsg("你的操作过于频繁")
		return
	end
	nethuodong.C2GSYJFindNpc(iNpcID)
	self.m_LastTime = g_TimeCtrl:GetTimeS()
end

function CExpandYJFbPage.IsSameNpc(self, npcList)
	if not self.m_NpcList then
		return
	end
	if #self.m_NpcList ~= #npcList then
		return false
	end
	for i, obj in ipairs(self.m_NpcList) do
		for _, key in ipairs({"idx", "name", "dead", "shape", "bossid"}) do
			if obj[key] ~= npcList[i][key] then
				return false
			end
		end
	end
	return true
end

function CExpandYJFbPage.OnAuto(self)
	if g_TeamCtrl:IsJoinTeam() and  not g_TeamCtrl:IsLeader() then
		g_NotifyCtrl:FloatMsg("只有队长才能进行此操作")
		return
	end
	if g_ActivityCtrl:GetYJFbCtrl():IsAutoWar() then
		g_ActivityCtrl:GetYJFbCtrl():StopAutoFuben()
	else
		nethuodong.C2GSYJFubenOp(1)
	end
end

function CExpandYJFbPage.OnQuitFb(self)
	local str = "确定要退出副本吗？"
	if g_TeamCtrl:IsInTeam() then
		str = "退出副本后会离开队伍，是否确定？"
	end
	local args = 
	{
		msg = "确定要退出副本吗？",
		okCallback= function ( )
			nethuodong.C2GSYJFubenOp(2)
		end,
		cancelCallback = function ()
		end,
		okStr = "是",
		cancelStr = "否",
		countdown = 10,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CExpandYJFbPage.OnOpenFightInfo(self)
	nethuodong.C2GSYJFubenView(1001)
end

function CExpandYJFbPage.OnShowPage(self)
	self:RefreshBtn()
	self:RefreshAll(true)
	self:RefreshGrid()
end

function CExpandYJFbPage.RefreshBtn(self)
	if g_ActivityCtrl:GetYJFbCtrl():IsAutoWar() then
		self.m_AutoFightBtn:SetText("取消自动")
	else
		self.m_AutoFightBtn:SetText("自动战斗")
	end
end
function CExpandYJFbPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
	local yjCtrl = g_ActivityCtrl:GetYJFbCtrl()
	self.m_TitleLabel:SetText(yjCtrl:GetTitle())
	self.m_EndTime = yjCtrl:GetEndTime()
	if yjCtrl:IsInFuben() then
		local function timetUpdate()
			if Utils.IsNil(self) then
				return
			end
			
			if yjCtrl:IsInFuben() then
				local iSecond = self.m_EndTime - g_TimeCtrl:GetTimeS()
				local str = g_TimeCtrl:GetLeftTime(iSecond)
				if iSecond < 20*60 then
					self.m_TimeLabel:SetText(string.format("[FAE7B9]副本剩余时间：#R%s", str))
				else
					self.m_TimeLabel:SetText(string.format("[FAE7B9]副本剩余时间：%s", str))
				end
				return true
			else
				return false
			end
		
		end
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
		end
		self.m_Timer = Utils.AddTimer(timetUpdate, 0.2, 0)
	end
end

function CExpandYJFbPage.Destroy(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CPageBase.Destroy(self)
end

function CExpandYJFbPage.OnSetActive(self, b, isClick)	
	self.m_ShowBox:SetActive(b)
	self.m_HideBox:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end	
end

function CExpandYJFbPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

return CExpandYJFbPage