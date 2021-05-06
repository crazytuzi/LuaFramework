local CPlayerInfoView = class("CPlayerInfoView", CViewBase)

function CPlayerInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/PlayerInfoView.prefab", cb)
	-- self.m_ExtendClose = "ClickOut"
end

function CPlayerInfoView.OnCreateView(self)
	self.AddrLabel = self:NewUI(1, CLabel)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnClone = self:NewUI(3, CButton)
	self.m_AvatarSpr = self:NewUI(4, CSprite)
	self.m_GradeLabel = self:NewUI(5, CLabel)
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_CloneBtn = self:NewUI(7, CButton)
	self.m_IDLabel = self:NewUI(8, CLabel)
	self.m_OrgLabel = self:NewUI(9, CLabel)
	self.m_Bg = self:NewUI(10, CSprite)
	self.m_SchoolLabel = self:NewUI(11, CLabel)
	self.m_TeamSelectBox = self:NewUI(12, CBox)

	self.m_Pid = nil
	self.m_TeamTargeList = {}

	self.m_BtnClone:SetActive(false)
	self.m_TeamSelectBox:SetActive(false)
	self.m_CloneBtn:AddUIEvent("click", callback(self, "OnCloneID"))
	g_UITouchCtrl:TouchOutDetect(self, function(obj)
		self:DelayClose()
	end)
end

function CPlayerInfoView.SetPlayerInfo(self, dInfo)
	self.m_Pid = dInfo.pid
	self.m_AvatarSpr:SpriteAvatar(dInfo.model_info.shape)

	self.m_GradeLabel:SetText(tostring(dInfo.grade))
	self.m_NameLabel:SetText(dInfo.name)
	self.m_IDLabel:SetText(string.format("ID：%d", dInfo.pid))
	if string.len(dInfo.org_name) > 0 then
		self.m_OrgLabel:SetText("[948e8a]公会：[fffbc8]" .. dInfo.org_name)
	else
		self.m_OrgLabel:SetText("")
	end
	local data =  data.schooldata.DATA[dInfo.school]
	self.m_SchoolLabel:SetText("[948e8a]职业：[fffbc8]狩猎者")
	self:BulidBtns(dInfo)
end

function CPlayerInfoView.OnCloneID(self)
	C_api.Utils.SetClipBoardText(tostring(self.m_Pid))
	g_NotifyCtrl:FloatMsg("已复制到剪切板")
end

function CPlayerInfoView.BulidBtns(self, dInfo)
	if g_FriendCtrl:IsBlackFriend(self.m_Pid) then
		self:CreateMaskBtn()
		self:ResizeBg()
		return
	end
	self:CreatePKBtn(dInfo)
	self:CreateTalkBtn()
	self:CreateFriendBtn()
	self:CreateTeamBtn(dInfo)
	self:AddButton("个人信息", function() netfriend.C2GSTakeDocunment(self.m_Pid) end)
	self:CreateMaskBtn()
	self:CreateOrgInfoBtn(dInfo)
	self:CreateReportBtn(dInfo)
	self:ResizeBg()
end

function CPlayerInfoView.ResizeBg(self)
	local w, h = self.m_Bg:GetSize()
	local h = 290
	local line = math.modf((self.m_BtnGrid:GetCount()+1)/2)
	h = h + math.max(0, line-1)*63
	self.m_Bg:SetSize(w, h)
end

function CPlayerInfoView.AddButton(self, sText, func, bIsAutoClose)
	if bIsAutoClose == nil then
		bIsAutoClose = true
	end
	local oBtn = self.m_BtnClone:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func()
		if Utils.IsExist(self) and bIsAutoClose then
			CPlayerInfoView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	oBtn:SetText(sText)
	self.m_BtnGrid:AddChild(oBtn)
end

function CPlayerInfoView.PK(self)
	if g_FieldBossCtrl:IsOpen() then
		nethuodong.C2GSFieldBossPk(self.m_Pid)
		return
	end
	
	if g_ActivityCtrl:ActivityBlockContrl("pk") then
		netplayer.C2GSPlayerPK(self.m_Pid)
	end
end

function CPlayerInfoView.CreatePKBtn(self, dInfo)
	if g_TeamPvpCtrl:IsInTeamPvpScene() then
		return
	end
	--if self:IsPKArea(self.m_Pid) then
		if dInfo.in_war == 1 then
			self:AddButton("观战", callback(self, "WatchWar"))
		elseif g_FieldBossCtrl:IsOpen() then
			self:AddButton("击杀", callback(self, "PK"))
		else
			self:AddButton("切磋", callback(self, "PK"))
		end
	--end
end

function CPlayerInfoView.IsPKArea(self, pid)
	--pk区域,2D地图编辑器编辑点
	local xMin, xMax = 4.64, 13.28
	local yMin, yMax = 8.8, 12.64
	local player = g_MapCtrl:GetPlayer(pid)
	if not player then 
		return
	end
	local pos = player:GetPos()
	return xMin <= pos.x and pos.x <= xMax and yMin <= pos.y and pos.y <= yMax and g_MapCtrl:GetMapID() == 101000
end

function CPlayerInfoView.CreateTalkBtn(self)
	if g_FriendCtrl:IsOpen() then
		self:AddButton("开始聊天", function() 
			CFriendMainView:ShowView(function (oView)
				oView:ShowTalk(self.m_Pid)
				end) 
			end)
	end
end

function CPlayerInfoView.CreateFriendBtn(self)
	local pid = self.m_Pid
	if g_FriendCtrl:IsOpen() then
		if g_FriendCtrl:IsMyFriend(pid) then
			self:AddButton("删除好友", function() g_FriendCtrl:ApplyDelFriend(pid) end)
		else
			self:AddButton("成为好友", function() g_FriendCtrl:ApplyFriend(pid) end)
		end
	end
end

function CPlayerInfoView.CreateMaskBtn(self)
	if g_FriendCtrl:IsOpen() then
		if not g_FriendCtrl:IsBlackFriend(self.m_Pid) then
			self:AddButton("加入黑名单", function() g_FriendCtrl:ShowBlackTip(self.m_Pid) end)
		else
			self:AddButton("取消黑名单", function() g_FriendCtrl:ApplyDelBlackFriend(self.m_Pid) end)
		end
	end
end

--创建申请入会按钮和邀请入会按钮
function CPlayerInfoView.CreateOrgInfoBtn(self, dInfo)
	if dInfo.org_id ~= 0 and g_AttrCtrl.org_id == 0 then
		self:AddButton("申请入会", function() g_OrgCtrl:ApplyJoinOrg(dInfo.org_id) end)
	elseif dInfo.org_id == 0 and g_AttrCtrl.org_id ~= 0 and g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos).invite == COrgCtrl.Has_Power then
		self:AddButton("邀请入会", callback(self,"InviteOrg"))
	end
end

--点击邀请入会按钮返回
function CPlayerInfoView.InviteOrg(self)
	netorg.C2GSInvited2Org(self.m_Pid)
end


--举报按钮
function CPlayerInfoView.CreateReportBtn(self, dInfo)
	self:AddButton("举报", function ( ... )
		CReportView:ShowView(function (oView)
			oView:UpdatePlayer(self.m_Pid, dInfo.name)
		end)
	end)
end

function CPlayerInfoView.CreateTeamBtn(self, dInfo)
	if g_TeamPvpCtrl:IsInTeamPvpScene() then
		self:AddButton("邀请组队", function() 
			if g_TeamPvpCtrl:GetMemberSize() > 1 then
				g_NotifyCtrl:FloatMsg("当前队伍已满员")
			else
				g_TeamPvpCtrl:SendInvite({self.m_Pid})
			end
		end, true)
		return
	end
	if dInfo.team_id == 0 then
		--如果未组队，则先组队,否则直接邀请
		if not g_TeamCtrl:IsJoinTeam() then
			self:AddButton("邀请组队", function()
				self:ShowTeamTargetSelect()
			 end, false)	
		else
			self:AddButton("邀请组队", function() 										
				g_TeamCtrl:C2GSInviteTeam(self.m_Pid) 				
			end, true)	
		end			

	else
		if not g_TeamCtrl:IsJoinTeam() then
			self:AddButton("申请入队", function() 
				if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSApplyTeam"]) then
					nettask.C2GSEnterShow(0, 0)
					netteam.C2GSApplyTeam(self.m_Pid) 
				end
			end)
		end
	end
end

function CPlayerInfoView.DelayClose(self)
	Utils.AddTimer(callback(self, "CloseView"), 0, 0.1) 
end

function CPlayerInfoView.WatchWar(self)
	if g_ActivityCtrl:ActivityBlockContrl("watchwar") then
		netplayer.C2GSWatchWar(self.m_Pid)
	end
end

function CPlayerInfoView.ShowTeamTargetSelect(self)
	self:InitTeamSelect()
	self:RefreshTarget()
end


function CPlayerInfoView.InitTeamSelect(self)
	local oPart = self.m_TeamSelectBox
	oPart.m_TargetBox = oPart:NewUI(1, CBox)
	oPart.m_SubTargetBox = oPart:NewUI(2, CBox)
	oPart.m_TargetTable = oPart:NewUI(3, CTable)
	oPart.m_TargetCloneBox = oPart:NewUI(4, CBox)
	oPart.m_SubTargetTable = oPart:NewUI(5, CTable)
	oPart.m_SubTargetCloneBox = oPart:NewUI(6, CBox) 
	oPart.m_SubTargetSrcollView = oPart:NewUI(7, CScrollView) 
	oPart.m_TargetCloneBox:SetActive(false)
	oPart.m_SubTargetBox:SetActive(false)
	oPart.m_SubTargetCloneBox:SetActive(false)
	oPart.m_LastSelectBox = nil
	oPart.m_TargetBoxList = {}
	oPart.m_SubTargetBoxList = {}
	oPart.m_AutoTeamData = DataTools.GetAutoteamData(g_AttrCtrl.grade)
end

function CPlayerInfoView.RefreshTarget(self)
	local oPart = self.m_TeamSelectBox
	local MainPool = {}
	for k,v in ipairs(oPart.m_AutoTeamData) do
		if v.parentId == 0 then
			table.insert(MainPool, v)
		end
	end
	for i, v in ipairs(MainPool) do
		local oBox = oPart.m_TargetBoxList[i]
		if not oBox then
			oBox = oPart.m_TargetCloneBox:Clone()
			table.insert(oPart.m_TargetBoxList, oBox)
			oBox.m_MainBtn = oBox:NewUI(1, CButton)
			oBox.m_MainLabel = oBox:NewUI(2, CLabel)
			oBox.m_MainSelSprite = oBox:NewUI(3, CSprite)
			oBox.m_SubTipsSprite = oBox:NewUI(4, CSprite)
			oPart.m_TargetTable:AddChild(oBox)		
		end
		oBox:SetActive(true)
		oBox.m_Id = v.id
		oBox.m_MainLabel:SetText(v.name)
		oBox.m_MainSelSprite:SetActive(false)
		oBox.m_MainBtn:AddUIEvent("click", callback(self, "ClickTargetItemBox", oBox))
		oBox.m_SubTargetTable = g_TeamCtrl:GetAutoTeamSubTargetTableByPartId(v.id, true)		
		oBox.m_SubTipsSprite:SetActive(#oBox.m_SubTargetTable > 0) 
	end
	oPart:SetActive(true)	
end

function CPlayerInfoView.ShowSubTarget(self, t)
	local oPart = self.m_TeamSelectBox
	if t and next(t) then
		oPart.m_SubTargetBox:SetActive(true)
		for i, v in ipairs(t) do
			local oBox = oPart.m_SubTargetBoxList[i]
			if not oBox then
				oBox = oPart.m_SubTargetCloneBox:Clone()
				oBox.m_MenuBox = oBox:NewUI(1, CBox)
				oBox.m_Label = oBox:NewUI(2, CLabel)
				oBox.m_SelectSpr = oBox:NewUI(3, CSprite)
				oBox.m_MenuBox:SetGroup(oPart.m_SubTargetTable:GetInstanceID())				
				oPart.m_SubTargetTable:AddChild(oBox)
				table.insert(oPart.m_SubTargetBoxList, oBox)
			end			
			oBox.m_SelectSpr:SetActive(false)
			oBox:SetActive(true)
			oBox.m_Label:SetText(v.sub_title_name)
			oBox.m_MenuBox:AddUIEvent("click", callback(self, "ClickSubTargetItemBox", v.id, oBox))
		end

		if #t < #oPart.m_SubTargetBoxList then
			for i = #t + 1, #oPart.m_SubTargetBoxList do
				local oBox = oPart.m_SubTargetBoxList[i]
				if oBox then
					oBox:SetActive(false)
				end
			end
		end
		oPart.m_SubTargetTable:Reposition()
		oPart.m_SubTargetSrcollView:ResetPosition()
	else
		oPart.m_SubTargetBox:SetActive(false)
	end
end

function CPlayerInfoView.ClickTargetItemBox(self, oBox)
	local oPart = self.m_TeamSelectBox
	if oBox then
		if #oBox.m_SubTargetTable > 0 then
			if oPart.m_LastSelectBox then				
				oPart.m_LastSelectBox.m_MainSelSprite:SetActive(false)
				oPart.m_LastSelectBox.m_SubTipsSprite:SetLocalRotation(Quaternion.Euler(0, 0, 0))				
				if oPart.m_LastSelectBox.m_Id == oBox.m_Id then
					self:ShowSubTarget()
					oPart.m_LastSelectBox = nil
					return
				end
			end
			oPart.m_LastSelectBox = oBox
			oBox.m_MainSelSprite:SetActive(true)
			oBox.m_SubTipsSprite:SetLocalRotation(Quaternion.Euler(0, 0, 90))
			self:ShowSubTarget(oBox.m_SubTargetTable)
		else
			g_TeamCtrl:C2GSInviteTeam(self.m_Pid, oBox.m_Id) 
			self:CloseView()
		end
	end
end

function CPlayerInfoView.ClickSubTargetItemBox(self, id)
	g_TeamCtrl:C2GSInviteTeam(self.m_Pid, id) 
	self:CloseView()
end

return CPlayerInfoView