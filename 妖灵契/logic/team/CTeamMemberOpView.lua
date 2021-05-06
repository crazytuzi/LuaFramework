local CTeamMemberOpView = class("CTeamMemberOpView", CViewBase)

function CTeamMemberOpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamMemberOpView.prefab", cb)
	--界面设置
	self.m_GroupName = "teamsub"
	self.m_ExtendClose = "ClickOut"
	self.m_BehindStrike = false
end

function CTeamMemberOpView.OnCreateView(self)
	self.m_OpTable = self:NewUI(1, CTable)
	self.m_OpBtn = self:NewUI(2, CButton, true, false)
	self.m_Bg = self:NewUI(3, CSprite)
	self.m_ArrowSpr = self:NewUI(4, CSprite)
	self.m_Owner = nil

	self.m_OpBtn:SetActive(false)
	self.m_Pid = nil
	self.m_PartId = nil
	self.m_IsMember = nil   --当前显示的玩家，还是出战伙伴
end

function CTeamMemberOpView.ShowExpandViewOp(self, pid)
	self.m_Pid = pid
	self.m_IsMember = true
	local bLeader = g_TeamCtrl:IsLeader()
	local bSelf = g_AttrCtrl.pid == pid
	local bInTeam = g_TeamCtrl:IsInTeam()
	local bLeave = g_TeamCtrl:IsLeave()
	local bCommander = g_TeamCtrl:IsCommander(self.m_Pid)
	local haveBtn = false

	self.m_OpTable:Clear()
	local cnt = 0

	if bLeader and g_TeamCtrl:IsInTeam(pid) and not bSelf then
		self:AddOp("任命队长", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSetLeader"]) then
					netteam.C2GSSetLeader(pid)
				end
			 end)
		cnt = cnt + 1
		haveBtn = true
	end

	if bLeader and g_TeamCtrl:IsInTeam(pid) and not bSelf and bCommander then
		self:AddOp("收回指挥", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAwardWarBattleCommand"]) then
					netteam.C2GSAwardWarBattleCommand(pid, 2)
				end
			 end)
		cnt = cnt + 1
		haveBtn = true
	end

	if bLeader and g_TeamCtrl:IsInTeam(pid) and not bSelf and not bCommander then
		self:AddOp("任命指挥", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAwardWarBattleCommand"]) then
					netteam.C2GSAwardWarBattleCommand(pid, 1)
				end
			 end)
		cnt = cnt + 1
		haveBtn = true
	end

	if (bLeader and not bSelf) then
		self:AddOp("请离队伍", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSKickOutTeam"]) then
					netteam.C2GSKickOutTeam(pid)
				end
			 end)
		cnt = cnt + 1
		haveBtn = true
	end

	if bLeader and g_TeamCtrl:IsLeave(pid) then
		self:AddOp("队友召唤", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamSummon"]) then
					netteam.C2GSTeamSummon(pid) 
				end
			end)
		cnt = cnt + 1
		haveBtn = true
	end

	-- if not bSelf then
	-- 	self:AddOp("查看信息", callback(self, "ShowPlayerInfo", pid))
	-- end

	if not bLeader and bSelf then
		if bLeave then
			self:AddOp("回归队伍", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSBackTeam"]) then
					netteam.C2GSBackTeam() 
				end
			end)
		else
			self:AddOp("暂离队伍", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSShortLeave"]) then
					netteam.C2GSShortLeave() 
				end
			end)
		end
		cnt = cnt + 1
		haveBtn = true
	end

	if bSelf then
		self:AddOp("离开队伍", function() 
			if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveTeam"]) then
				netteam.C2GSLeaveTeam()
			end
		 end)
		cnt = cnt + 1
		haveBtn = true
	end

	if bInTeam and not bLeader and g_TeamCtrl:IsLeader(pid) then
		local oBtn = self:AddOp("接管队长", function() self:ApplyLeader() end)
		cnt = cnt + 1
		haveBtn = true
	end

	if not haveBtn then
		self.m_Bg:SetActive(false)
		Utils.AddTimer(function ( )	self:CloseView() end, 0, 0.1)	
	else
		self:ReSetBgSprite(cnt)
		self:ResizeBg()
	end
end

function CTeamMemberOpView.ShowTeamViewOp(self, pid)
	self.m_Pid = pid
	self.m_IsMember = true 
	self.m_OpTable:Clear()

	local bOffline = g_TeamCtrl:IsOffline(pid)
	local bLeave = g_TeamCtrl:IsLeave(pid)
	local bCommander = g_TeamCtrl:IsCommander(self.m_Pid)

	local bFriend = g_FriendCtrl:IsMyFriend(pid)
	local cnt = 0
	
	--self:AddOp("查看信息", callback(self, "ShowPlayerInfo", pid))
	self:AddOp("开始聊天", callback(self, "ShowChatWindow", pid))
	cnt = cnt + 1

	if not bFriend then 
		self:AddOp("加为好友", callback(self, "ShowAddFriend", pid))
		cnt = cnt + 1
	end

	if g_TeamCtrl:IsLeader() then
		self:AddOp("请离队伍", function() 
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSKickOutTeam"]) then
						netteam.C2GSKickOutTeam(pid) 
					end
				end)
		cnt = cnt + 1

		if not bLeave and not bOffline then
			self:AddOp("移交队长", function() 
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSSetLeader"]) then
						netteam.C2GSSetLeader(pid) 
					end
				end)
			cnt = cnt + 1
		end 

		if bCommander and g_TeamCtrl:IsInTeam(pid) then
			self:AddOp("收回指挥", function() 
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAwardWarBattleCommand"]) then
						netteam.C2GSAwardWarBattleCommand(pid, 2)
					end
				 end)
			cnt = cnt + 1
		end

		if not bCommander and g_TeamCtrl:IsInTeam(pid) then
			self:AddOp("任命指挥", function() 
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSAwardWarBattleCommand"]) then
						netteam.C2GSAwardWarBattleCommand(pid, 1)
					end
				 end)
			cnt = cnt + 1
		end

		if bLeave then
			self:AddOp("队友召唤", function() 
					if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTeamSummon"]) then
						netteam.C2GSTeamSummon(pid) 
					end
				end)
			cnt = cnt + 1
		end
		--self:AddOp("调整站位", callback(self, "SwitchPos", pid))
	
	else
		if g_TeamCtrl:IsInTeam() and g_TeamCtrl:IsLeader(pid) then
			local oBtn = self:AddOp("接管队长", function() self:ApplyLeader() end)
			cnt = cnt + 1
		end
	end
	self:ReSetBgSprite(cnt)
	self:ResizeBg()
end

function CTeamMemberOpView.ShowTeamViewPartnerOp( self, partId, pos, IsInTeam, IsLeader, owner)
	self.m_Owner = owner
	if not IsInTeam then
		self.m_PartId = partId
		self.m_OpTable:Clear()
		self:AddOp("更换伙伴", callback(self, "ShowPartnerList", partId, pos))
		if pos ~= define.Partner.Pos.Main and partId ~= nil then
			self:AddOp("休息", callback(self, "ChangePartner", partId, pos))
		end
	else
		if IsLeader then
			self.m_PartId = partId
			self.m_OpTable:Clear()
			self:AddOp("更换伙伴", callback(self, "ShowPartnerList", partId, pos))
			if pos ~= define.Partner.Pos.Main and partId ~= nil then
				self:AddOp("休息", callback(self, "ChangePartner", partId, pos))
			end
			self:ResizeBg()
		else
			--如果不是队长，则pos为1，paridid从自己的出战伙伴中获取
			pos = define.Partner.Pos.Main
			local partner = g_PartnerCtrl:GetMainFightPartner()
			partId = (partner ~= nil) and partner:GetValue("parid") or nil 	
			self.m_PartId = partId
			self.m_OpTable:Clear()
			self:AddOp("更换伙伴", callback(self, "ShowPartnerList", partId, pos))
			self:ResizeBg()
		end
	end
	self.m_IsMember = false
	self:ResizeBg()
end

function CTeamMemberOpView.ResizeBg(self)
	self.m_OpTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_OpTable.m_Transform)
	self.m_Bg:SetHeight(bounds.max.y - bounds.min.y + 30)
end

function CTeamMemberOpView.AddOp(self, sText, func)
	local oBtn = self.m_OpBtn:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func()
		if Utils.IsExist(self) then
			CTeamMemberOpView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	oBtn:SetText(sText)
	self.m_OpTable:AddChild(oBtn)
	return oBtn
end

function CTeamMemberOpView.ShowPlayerInfo(self, pid)
	g_AttrCtrl:GetPlayerInfo(pid, define.PlayerInfo.Style.Default)
end

function CTeamMemberOpView.ShowChatWindow(self, pid)
	CFriendMainView:ShowView(function (oView)
		oView:ShowTalk(pid)
	end) 
end

function CTeamMemberOpView.ShowAddFriend(self, pid)
	g_FriendCtrl:ApplyFriend(pid)
end

function CTeamMemberOpView.SwitchPos(self, pid)

end

function CTeamMemberOpView.ShowArrow(self)
	self.m_ArrowSpr:SetActive(true)
end

--接管队长
function CTeamMemberOpView.ApplyLeader(self)	
	if g_TeamCtrl:CanApplyLeader() then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSTakeOverLeader"]) then
			netteam.C2GSTakeOverLeader()
		end
	end
end

function CTeamMemberOpView.ShowPartnerList(self, partId, pos)
	if not self.m_Owner then
		return
	end
	CPartnerChooseView:ShowView(function (oView)
		oView:SetFilterCb(callback(self.m_Owner, "OnFilter"))
		oView:SetConfirmCb(callback(self.m_Owner, "OnChange", pos))
	end)
end

function CTeamMemberOpView.ChangePartner(self, partId, pos)
	g_PartnerCtrl:C2GSPartnerFight(pos, partId)
end

function CTeamMemberOpView.ReSetBgSprite(self, cnt)
	local sprName = ""
	if cnt == 1 then
		sprName = "pic_zjm_zudui_tuozhan_diwen_1"

	elseif cnt == 2 then
		sprName = "pic_zjm_zudui_tuozhan_diwen_2"

	else
		sprName = "pic_zjm_zudui_tuozhan_diwen_3"
	end
	self.m_Bg:SetSpriteName(sprName)
end

function CTeamMemberOpView.SetBg(self, sprName)
	self.m_Bg:SetSpriteName(sprName)
end

return CTeamMemberOpView