local CTravelFriendInviteView = class("CTravelFriendInviteView", CViewBase)

function CTravelFriendInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelFriendInviteView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTravelFriendInviteView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IgnoreAllBtn = self:NewUI(2, CButton)
	self.m_InviteCountLabel = self:NewUI(3, CLabel)
	self.m_FriendGrid = self:NewUI(4, CGrid)
	self.m_FriendBox = self:NewUI(5, CBox)

	self:InitContent()
	--请求好友邀请数据
	nettravel.C2GSQueryTravelInvite()
end

function CTravelFriendInviteView.InitContent(self)
	self.m_FriendBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_IgnoreAllBtn:AddUIEvent("click", callback(self, "OnIgnoreAllBtn"))
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	self:RefreshFriendGrid()
end

function CTravelFriendInviteView.OnTravelCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Travel.Event.MineInvite then
		self:RefreshFriendGrid()
	end
end

function CTravelFriendInviteView.OnIgnoreAllBtn(self, oBtn)
	nettravel.C2GSClearTravelInvite()
end

function CTravelFriendInviteView.RefreshFriendGrid(self)
	self.m_FriendGrid:Clear()
	local lData = g_TravelCtrl:GetFrd2MineInviteInfo()
	local function sort(a, b)
		return a.invite_time > b.invite_time
	end
	if lData then
		table.sort(lData, sort)
		for i,dData in ipairs(lData) do
			local oFriendBox = self:CreateFriendBox(dData)
			if oFriendBox then
				self.m_FriendGrid:AddChild(oFriendBox)
			end
		end
		self.m_FriendGrid:Reposition()
	end
	local iCount = self.m_FriendGrid:GetCount()
	self.m_InviteCountLabel:SetText(string.format("共有%d条邀请", iCount))
end

function CTravelFriendInviteView.CreateFriendBox(self, dData)
	if dData and dData.frd_pid then 
		local frdobj = g_FriendCtrl:GetFriend(dData.frd_pid)
		if frdobj then
			local oFriendBox = self.m_FriendBox:Clone()
			oFriendBox:SetActive(true)
			oFriendBox.m_NameLabel = oFriendBox:NewUI(1, CLabel)
			oFriendBox.m_HeadSprite = oFriendBox:NewUI(2, CSprite)
			oFriendBox.m_TimeLabel = oFriendBox:NewUI(3, CLabel)
			oFriendBox.m_DescLabel = oFriendBox:NewUI(4, CLabel)
			oFriendBox.m_GotoBtn = oFriendBox:NewUI(5, CButton)
			oFriendBox.m_IgnoreBtn = oFriendBox:NewUI(6, CButton)
			oFriendBox.m_GradeLabel = oFriendBox:NewUI(7, CLabel)
			oFriendBox.m_StateLabel = oFriendBox:NewUI(8, CLabel)
			oFriendBox.m_GotoBtn:AddUIEvent("click", callback(self, "OnGotoBtn", oFriendBox))
			oFriendBox.m_IgnoreBtn:AddUIEvent("click", callback(self, "OnIgnoreBtn", oFriendBox))
			
			oFriendBox.m_PID = dData.frd_pid
			oFriendBox.m_NameLabel:SetText(dData.frd_name)
			
			oFriendBox.m_GradeLabel:SetText(frdobj.grade)
			oFriendBox.m_HeadSprite:SpriteAvatar(dData.frd_shape)
			oFriendBox.m_DescLabel:SetText(dData.invite_content)
			local sState = ""
			if dData.travel == 1 then
				sState = "[604732FF]状态：游历中[-]"
				if dData.frd_travel == 1 then
					sState = sState.."[ff2828FF](已存在游历伙伴)[-]"
				else
					sState = sState.."[008a3aFF](未存在游历伙伴)[-]"
				end
				oFriendBox.m_TimeLabel:SetActive(true)
			else
				sState = "[604732FF]状态：未进行游历[-]"
				oFriendBox.m_TimeLabel:SetActive(false)
			end
			oFriendBox.m_StateLabel:SetText(sState)

			--local txt = self:GetTimeTxt(dData.invite_time)
			if oFriendBox.m_Timer then
				Utils.DelTimer(oFriendBox.m_Timer)
				oFriendBox.m_Timer = nil
			end
			local time = dData.end_time and dData.end_time - g_TimeCtrl:GetTimeS() or 0
			local function countdown()
				if Utils.IsNil(self) or Utils.IsNil(oFriendBox) then
					return 
				end
				if time > 0 then
					oFriendBox.m_TimeLabel:SetText(string.format("时间：%s", g_TimeCtrl:GetLeftTime(time, true)))
					time = time - 1
					return true
				end
			end
			oFriendBox.m_Timer = Utils.AddTimer(countdown, 1, 0)
			return oFriendBox
		end
	end
end

function CTravelFriendInviteView.GetTimeTxt(self, invite_time)
	local txt = ""
	local info = g_TimeCtrl:GetTimeInfo(g_TimeCtrl:GetTimeS() - invite_time)
	txt = info.hour.."小时"..info.min.."分钟"..info.sec.."秒"
	if info.hour and info.hour > 0 then
		txt = info.hour.."小时前"
	elseif info.min and info.min > 0 then
		txt = info.min.."分钟前"
	else
		txt = info.sec.."秒前"
	end
	return txt
end

function CTravelFriendInviteView.OnGotoBtn(self, oFriendBox)
	nettravel.C2GSGetFrdTravelInfo(oFriendBox.m_PID)
	self:CloseView()
end

function CTravelFriendInviteView.OnIgnoreBtn(self, oFriendBox)
	nettravel.C2GSDelTravelInvite(oFriendBox.m_PID)
end

return CTravelFriendInviteView