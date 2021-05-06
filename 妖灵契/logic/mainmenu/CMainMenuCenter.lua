local CMainMenuCenter = class("CMainMenuCenter", CBox)

function CMainMenuCenter.ctor(self, obj)
	CBox.ctor(self, obj)
	
	self.m_AvatarBox = self:NewUI(1, CBox)
	self.m_BroadcastBox = self:NewUI(2, CBroadcastBox)
	self.m_TeamBox = self:NewUI(3, CBox)
	self.m_NpcListBox = self:NewUI(4, CBox)
	self.m_SceneNameLabel = self:NewUI(5, CLabel)
	self.m_TerraWarQueueBtn = self:NewUI(6, CButton)

	self.m_SceneNameLabel:SetActive(false)
	self.m_SceneNameLabelTweenAlpha = self.m_SceneNameLabel:GetComponent(classtype.TweenAlpha)
	self.m_SceneNameLabelTweenAlpha.enabled = false
	self:InitContent()
end

function CMainMenuCenter.InitContent(self)
	g_UITouchCtrl:TouchOutDetect(self.m_AvatarBox, callback(self, "HidePlayerAvatar"))
	self.m_AvatarBox:AddUIEvent("click", callback(self, "OnAvatar"))
	self:HidePlayerAvatar()

	self.m_TeamBox:SetActive(false)
	self.m_TeamBox.m_InviteBtn = self.m_TeamBox:NewUI(1, CButton)
	self.m_TeamBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnTeamInvite"))
	self.m_TeamBox.m_ApplyBtn = self.m_TeamBox:NewUI(2, CButton)
	self.m_TeamBox.m_ApplyBtn:AddUIEvent("click", callback(self, "OnTeamApply"))
	self:RefrehNotifyTip()

	-- 主界面NpcList Begin
	self.m_NpcListBox.m_Scroll = self.m_NpcListBox:NewUI(1, CScrollView)
	self.m_NpcListBox.m_Grid = self.m_NpcListBox:NewUI(2, CGrid)
	self.m_NpcListBox.m_NpcBoxClone = self.m_NpcListBox:NewUI(3, CBox)
	self.m_NpcListBox.m_BgSprite = self.m_NpcListBox:NewUI(4, CSprite)
	g_UITouchCtrl:TouchOutDetect(self.m_NpcListBox, function(obj)
		if self.m_NpcListBox:GetActive() then
			self.m_NpcListBox:SetActive(false)
		end
	end)
	self.m_NpcListBox:SetActive(false)
	self.m_NpcListBox.m_NpcBoxClone:SetActive(false)
	-- 主界面NpcList End

	--据点战排队状况
	self.m_TerraWarQueueBtn:SetActive(g_TerrawarCtrl:IsTerraWarQueue())
	self.m_TerraWarQueueBtn:AddUIEvent("click", callback(self, "OnWait"))

	g_TerrawarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTerrawarEvent"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
end

function CMainMenuCenter.BindMenuArea(self)
	-- local tweenPos = self.m_HBtnGrid:GetComponent(classtype.TweenPosition)
	-- local tweenRotation = self.m_HideBtn:GetComponent(classtype.TweenRotation)
	-- local callback = function()
	-- 	tweenRotation:Toggle()
	-- end
	-- local tweenPos_1 = self.m_BagContent:GetComponent(classtype.TweenPosition)
	-- g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Function, tweenPos, callback)
	-- g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Bag, tweenPos_1)
end

function CMainMenuCenter.OnTeamEvent(self, oCtrl)
	if  oCtrl.m_EventID == define.Team.Event.NotifyApply or
		 oCtrl.m_EventID == define.Team.Event.NotifyInvite or
		 oCtrl.m_EventID == define.Team.Event.DelInvite or
		 oCtrl.m_EventID == define.Team.Event.DelApply or 
		 oCtrl.m_EventID == define.Team.Event.DelTeam or 
		 oCtrl.m_EventID == define.Team.Event.AddTeam or 
		 oCtrl.m_EventID == define.Team.Event.MemberUpdate 
		 then
		self:RefrehNotifyTip()
	end
end

function CMainMenuCenter.OnMapEvent(self, oMapCtrl)
	if oMapCtrl.m_EventID == define.Map.Event.MapNpcList then
		self:InitNpcInfoList(oMapCtrl.m_EventData)
	elseif oMapCtrl.m_EventID == define.Map.Event.MapLoadDone then
		self:DelayCall(0, "MapLoadDoneProcess")
	end
end

function CMainMenuCenter.MapLoadDoneProcess(self)
	self:SetSceneNameLabel(g_MapCtrl:GetSceneName())
	self.m_TerraWarQueueBtn:SetActive(g_TerrawarCtrl:IsTerraWarQueue())
end

function CMainMenuCenter.OnTerrawarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Terrawar.Event.TerraWarQueue then
		self.m_TerraWarQueueBtn:SetActive(g_TerrawarCtrl:IsTerraWarQueue())
	end
end

function CMainMenuCenter.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.StartWar then
		self.m_TerraWarQueueBtn:SetActive(g_TerrawarCtrl:IsTerraWarQueue())
	end
end

function CMainMenuCenter.SetSceneNameLabel(self, sSceneName)
	if g_WarCtrl:IsWar() then
		self.m_SceneNameLabel:SetActive(false)
		self.m_SceneNameLabelTweenAlpha.enabled = false
		return
	end
	local lIgnore = {208000, 501000, 601000, 200400, 206100, 204100, 200100}
	if table.index(lIgnore, g_MapCtrl:GetLastMapID()) or table.index(lIgnore, g_MapCtrl:GetMapID()) then
		return
	end
	if not sSceneName or sSceneName == "" then
		return
	end
	self.m_SceneNameLabel:SetText(sSceneName)
	self.m_SceneNameLabel:SetActive(true)
	self.m_SceneNameLabelTweenAlpha.enabled = true
	self.m_SceneNameLabelTweenAlpha:ResetToBeginning()
	self.m_SceneNameLabelTweenAlpha:PlayForward()
end

function CMainMenuCenter.RefrehNotifyTip(self)
	if g_WarCtrl:IsWar() then
		self.m_TeamBox:SetActive(false)
		return
	end
	if g_TeamCtrl:IsJoinTeam() then 		
		if g_TeamCtrl:IsLeader() and table.count(g_TeamCtrl.m_UnreadApply) > 0 and g_TeamCtrl:IsLeader() then			
			self:TeamApply()
			return
		end
	else
		if table.count(g_TeamCtrl.m_UnreadInvite) > 0 then
			self:TeamInvite()
			return
		end
	end
	self.m_TeamBox:SetActive(false)
end

function CMainMenuCenter.ShowPlayerAvatar(self, pid)
	local heroSpr = self.m_AvatarBox:NewUI(1, CSprite)
	local player = g_MapCtrl:GetPlayer(pid)
	heroSpr:SpriteAvatar(player.m_Actor.m_Shape or player.m_Shape)
	self.m_AvatarBox:SetActive(true)
	self.m_AvatarBox.m_Pid = pid
end

function CMainMenuCenter.HidePlayerAvatar(self)
	local oView = CMainMenuView:GetView()
	
	self.m_AvatarBox:SetActive(false)
	self.m_AvatarBox.m_Pid = nil
end

function CMainMenuCenter.OnAvatar( self)
	local pid = self.m_AvatarBox.m_Pid
	if pid then
		g_AttrCtrl:GetPlayerInfo(pid, define.PlayerInfo.Style.Default)
	end
	self:HidePlayerAvatar()
end

function CMainMenuCenter.GetSelectedPid(self)
	return self.m_AvatarBox.m_Pid
end

function CMainMenuCenter.TeamApply(self)
	self.m_TeamBox:SetActive(true)
	self.m_TeamBox.m_InviteBtn:SetActive(false)
	self.m_TeamBox.m_ApplyBtn:SetActive(true)
end

function CMainMenuCenter.TeamInvite(self)
	self.m_TeamBox:SetActive(true)
	self.m_TeamBox.m_InviteBtn:SetActive(true)
	self.m_TeamBox.m_ApplyBtn:SetActive(false)
end

function CMainMenuCenter.OnTeamApply(self)
	self.m_TeamBox:SetActive(false)
	if next(g_TeamCtrl.m_Applys) then
			CTeamApplyView:ShowView()
		else
			g_NotifyCtrl:FloatMsg("暂时还没有人申请入队哦")
	end
end

function CMainMenuCenter.OnTeamInvite(self)
	self.m_TeamBox:SetActive(false)
	if next(g_TeamCtrl.m_Invites) then
		CTeamInviteView:ShowView()
	else
		g_NotifyCtrl:FloatMsg("暂时还没有人邀请你入队哦")
	end
end

function CMainMenuCenter.HideTeam( ... )
	-- body
end

-- 主界面NpcList信息列表
function CMainMenuCenter.InitNpcInfoList(self, npcInfoList)
	printc("点击重叠Npc展示信息")
	if npcInfoList and next(npcInfoList) and #npcInfoList > 1 then
		self.m_NpcListBox:SetActive(true)
		self.m_NpcListBox.m_Grid:Clear()
		for i,v in ipairs(npcInfoList) do
			local oNpcBox = self.m_NpcListBox.m_NpcBoxClone:Clone()
			oNpcBox:SetActive(true)
			oNpcBox.m_AatarSpr = oNpcBox:NewUI(1, CSprite)
			oNpcBox.m_NameLabel = oNpcBox:NewUI(2, CLabel)
			oNpcBox.m_DescLabel = oNpcBox:NewUI(3, CLabel)
			oNpcBox:AddUIEvent("click", function ()
				self.m_NpcListBox.m_Grid:Clear()
				self.m_NpcListBox:SetActive(false)
				if v.cb then
					v.cb()
				end
			end)
			oNpcBox.m_NameLabel:SetText(self:ConverName(v.name))
			oNpcBox.m_AatarSpr:SpriteAvatar(v.shape)
			if v.classname == "CMonsterNpc" then
				if v.npcaoi and v.npcaoi.inwar then
					oNpcBox.m_DescLabel:SetText("#R战斗中")
				else
					oNpcBox.m_DescLabel:SetText("#G可攻击")
				end
			end
			self.m_NpcListBox.m_Grid:AddChild(oNpcBox)
		end
		local max = self.m_NpcListBox.m_NpcBoxClone:GetHeight() * 4 + 8
		local cur = self.m_NpcListBox.m_NpcBoxClone:GetHeight() * #npcInfoList + 8
		--local bounds = UITools.CalculateRelativeWidgetBounds(self.m_NpcListBox.m_Grid.m_Transform)
		--local iHeight = math.min(max, bounds.max.y-bounds.min.y + 5)
		local iHeight = math.min(max, cur + 8)
		self.m_NpcListBox.m_BgSprite:SetHeight(iHeight)
		self.m_NpcListBox.m_Grid:Reposition()
		self.m_NpcListBox.m_Scroll:ResetPosition()
	else
		self.m_NpcListBox:SetActive(false)	
	end
end

function CMainMenuCenter.OnWait(self)
	nethuodong.C2GSGetListInfo()
end

--某些怪物名字带颜色，则把颜色替换为UI名字的颜色
function CMainMenuCenter.ConverName(self, oName)
	local name = oName
	local i, j = string.find(oName, "]") 
	if i and j and i == j then
		name = string.gsub(name, string.sub(name, 2, i - 1), "FFFFFF")
	else
		name = string.format("%s%s", "[FFFFFF]", name)
	end
	return name
end

return CMainMenuCenter