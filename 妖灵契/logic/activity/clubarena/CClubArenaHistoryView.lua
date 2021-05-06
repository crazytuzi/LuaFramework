local CClubArenaHistoryView = class("CClubArenaHistoryView", CViewBase)

function CClubArenaHistoryView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/ClubArena/ClubArenaHistoryView.prefab", ob)
	self.m_ExtendClose = "Black"
	self.m_HistoryCellArr = {}
	self.m_HistoryCellDic = {}
end

function CClubArenaHistoryView.OnCreateView(self)
	self.m_HistoryScrollView = self:NewUI(1, CScrollView)
	self.m_HistoryGrid = self:NewUI(2, CGrid)
	self.m_HistoryCell = self:NewUI(3, CBox)
	self.m_SharePart = self:NewUI(4, CBox)
	self:InitContent()
end

function CClubArenaHistoryView.InitContent(self)
	self:InitSharePart()
	self.m_HistoryCell:SetActive(false)
	--g_ClubArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnClubArenaCtrl"))
	self:SetData()
end

function CClubArenaHistoryView.InitSharePart(self)
	local oSharePart = self.m_SharePart
	oSharePart.m_ShareOrgBtn = oSharePart:NewUI(1, CButton)
	oSharePart.m_ShareWorldBtn = oSharePart:NewUI(2, CButton)
	oSharePart.m_CloseBtn = oSharePart:NewUI(3, CButton)

	oSharePart.m_ShareOrgBtn:AddUIEvent("click", callback(self, "OnClickShareOrg"))
	oSharePart.m_ShareWorldBtn:AddUIEvent("click", callback(self, "OnClickShareWorld"))
	oSharePart.m_CloseBtn:AddUIEvent("click", callback(self, "OnHideSharePart"))
	self.m_SharePart:SetActive(false)
end

function CClubArenaHistoryView.OnClickShareOrg(self)
	local currentCell = self.m_CurrentCell
	if g_AttrCtrl.org_id == 0 then
		g_NotifyCtrl:FloatMsg("请先加入公会")
	else
		g_ChatCtrl:SendMsg(LinkTools.GenerateFightRecordLink(currentCell.m_Fid, 1, g_AttrCtrl.name, currentCell.m_Name), define.Channel.Org)
		g_NotifyCtrl:FloatMsg("已分享到公会聊天")
	end
	self.m_SharePart:SetActive(false)
end

function CClubArenaHistoryView.OnClickShareWorld(self, pid)
	local currentCell = self.m_CurrentCell
	g_ChatCtrl:SendMsg(LinkTools.GenerateFightRecordLink(currentCell.m_Fid, 1, g_AttrCtrl.name, currentCell.m_Name), define.Channel.World)
	g_NotifyCtrl:FloatMsg("已分享到世界聊天")
	self.m_SharePart:SetActive(false)
end

function CClubArenaHistoryView.OnHideSharePart(self)
	self.m_SharePart:SetActive(false)
end

function CClubArenaHistoryView.SetData(self)
	self.m_Data = g_ClubArenaCtrl.m_HistoryInfo
	for i,v in ipairs(self.m_Data) do
		local oHistoryCell = self:CreateCell()
		self:UpdateCell(oHistoryCell, v)
		self.m_HistoryGrid:AddChild(oHistoryCell)
	end
	self.m_HistoryGrid:Reposition()
end

function CClubArenaHistoryView.CreateCell(self)
	local oHistoryCell = self.m_HistoryCell:Clone()
	oHistoryCell:SetActive(true)
	oHistoryCell.m_ResultSpr = oHistoryCell:NewUI(1, CSprite)
	oHistoryCell.m_ClubLabel = oHistoryCell:NewUI(2, CLabel)
	oHistoryCell.m_JianTouSpr = oHistoryCell:NewUI(3, CSprite)
	oHistoryCell.m_PlayerSpr = oHistoryCell:NewUI(4, CSprite)
	oHistoryCell.m_GradeLabel = oHistoryCell:NewUI(5, CLabel)
	oHistoryCell.m_NameLabel = oHistoryCell:NewUI(6, CLabel)
	oHistoryCell.m_TimeLabel = oHistoryCell:NewUI(7, CLabel)
	oHistoryCell.m_ReplayButton = oHistoryCell:NewUI(8, CButton)
	oHistoryCell.m_ShareButton = oHistoryCell:NewUI(9, CButton)
	oHistoryCell.m_ReplayButton:AddUIEvent("click", callback(self, "OnClickReplay", oHistoryCell))
	oHistoryCell.m_ShareButton:AddUIEvent("click", callback(self, "ShowSharePart", oHistoryCell))
	return oHistoryCell
end

function CClubArenaHistoryView.OnClickReplay(self, oHistoryCell)
	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
		netarena.C2GSArenaReplayByRecordId(oHistoryCell.m_Fid)
	end
end

function CClubArenaHistoryView.ShowSharePart(self, oHistoryCell)
	self.m_SharePart:SetActive(true)
	self.m_CurrentCell = oHistoryCell
end

function CClubArenaHistoryView.UpdateCell(self, oHistoryCell, d)
	oHistoryCell.m_Fid = tonumber(d.fid)
	oHistoryCell.m_Name = d.name
	if d.win == 1 then
		oHistoryCell.m_ResultSpr:SetSpriteName("pic_shengli")
	else
		oHistoryCell.m_ResultSpr:SetSpriteName("pic_shibai")
	end

	local txt = ""
	local info = g_TimeCtrl:GetTimeInfo(g_TimeCtrl:GetTimeS() - d.time)
	txt = info.hour.."小时"..info.min.."分钟"..info.sec.."秒"
	if info.hour and info.hour > 0 then
		txt = info.hour.."小时前"
	elseif info.min and info.min > 0 then
		txt = info.min.."分钟前"
	else
		txt = info.sec.."秒前"
	end
	oHistoryCell.m_TimeLabel:SetText(txt)
	oHistoryCell.m_GradeLabel:SetText(d.grade)
	oHistoryCell.m_PlayerSpr:SpriteAvatar(d.shape)
	if d.master and d.master == 1 then
		oHistoryCell.m_ClubLabel:SetText(data.clubarenadata.Config[d.club].desc.."主")
	elseif d.club then
		oHistoryCell.m_ClubLabel:SetText(data.clubarenadata.Config[d.club].desc)
	end
	if d.updown == 0 then
		oHistoryCell.m_JianTouSpr:SetActive(false)
	elseif d.updown == 1 then
		oHistoryCell.m_JianTouSpr:SetActive(true)
		oHistoryCell.m_JianTouSpr:SetSpriteName("pic_shangsheng")
	elseif d.updown == 0 then
		oHistoryCell.m_JianTouSpr:SetActive(true)
		oHistoryCell.m_JianTouSpr:SetSpriteName("pic_xiajiang")
	end
	oHistoryCell.m_NameLabel:SetText(d.name)
end

return CClubArenaHistoryView
