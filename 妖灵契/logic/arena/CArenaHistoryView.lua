local CArenaHistoryView = class("CArenaHistoryView", CViewBase)

function CArenaHistoryView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaHistoryView.prefab", ob)
	self.m_ExtendClose = "Black"
	self.m_HistoryCellArr = {}
	self.m_HistoryCellDic = {}
end

function CArenaHistoryView.OnCreateView(self)
	self.m_HistoryGrid = self:NewUI(2, CGrid)
	self.m_HistoryCell = self:NewUI(3, CBox)
	self.m_ShowingHistorySlot = self:NewUI(4, CBox)
	self.m_HistoryScrollView = self:NewUI(5, CScrollView)
	self.m_SharePart = self:NewUI(6, CBox)
	self:InitContent()
end

function CArenaHistoryView.InitContent(self)
	self:InitSharePart()
	self.m_HistoryCell:SetActive(false)
	g_ArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:SetData()
end

function CArenaHistoryView.InitSharePart(self)
	local oSharePart = self.m_SharePart
	oSharePart.m_ShareOrgBtn = oSharePart:NewUI(1, CButton)
	oSharePart.m_ShareFriendBtn = oSharePart:NewUI(2, CButton)
	oSharePart.m_SetShowingBtn = oSharePart:NewUI(3, CButton)
	oSharePart.m_CloseBtn = oSharePart:NewUI(4, CBox)
	oSharePart.m_ShowingMark = oSharePart:NewUI(5, CBox)

	oSharePart.m_ShareOrgBtn:AddUIEvent("click", callback(self, "OnClickShareOrg"))
	oSharePart.m_ShareFriendBtn:AddUIEvent("click", callback(self, "OnClickShareFriend"))
	oSharePart.m_SetShowingBtn:AddUIEvent("click", callback(self, "OnClickSetShowing"))
	oSharePart.m_CloseBtn:AddUIEvent("click", callback(self, "OnHideSharePart"))
	self.m_SharePart:SetActive(false)
end

function CArenaHistoryView.ShowSharePart(self, oHistoryCell)
	self.m_SharePart:SetActive(true)
	self.m_CurrentCell = oHistoryCell
	if oHistoryCell.m_id == g_ArenaCtrl.m_ShowingHistory.fid then
		self.m_SharePart.m_SetShowingBtn:SetActive(false)
		self.m_SharePart.m_ShowingMark:SetActive(true)
	else
		self.m_SharePart.m_SetShowingBtn:SetActive(true)
		self.m_SharePart.m_ShowingMark:SetActive(false)
	end
end

function CArenaHistoryView.OnClickShareOrg(self)
	local currentCell = self.m_CurrentCell
	if g_AttrCtrl.org_id == 0 then
		g_NotifyCtrl:FloatMsg("请先加入公会")
	else
		g_ChatCtrl:SendMsg(LinkTools.GenerateFightRecordLink(currentCell.m_id, currentCell.m_View, currentCell.m_PlayerName, currentCell.m_EnemyName), define.Channel.Org)
		g_NotifyCtrl:FloatMsg("已分享到公会聊天")
	end
	self.m_SharePart:SetActive(false)
end

function CArenaHistoryView.OnClickShareFriend(self, pid)
	-- printc("OnClickShareFriend")
	local currentCell = self.m_CurrentCell
	if CFriendMainView:GetView() ~= nil then
		CFriendMainView:CloseView()
	end
	CFriendMainView:ShowView(
		function (oView)
			oView.m_FriendPage:SetOpenTalkMsg(LinkTools.GenerateFightRecordLink(currentCell.m_id, currentCell.m_View, currentCell.m_PlayerName, currentCell.m_EnemyName))
		end)
	self.m_SharePart:SetActive(false)
end

function CArenaHistoryView.OnHideSharePart(self)
	self.m_SharePart:SetActive(false)
end

function CArenaHistoryView.OnClickSetShowing(self)
	if self.m_ShowingData.fid ~= "" then
		local windowConfirmInfo = {
			msg = "将替代现有展示",
			okStr = "是",
			cancelStr = "否",
			okCallback = function()
				netarena.C2GSArenaSetShowing(self.m_CurrentCell.m_id)
				self.m_SharePart:SetActive(false)
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		netarena.C2GSArenaSetShowing(self.m_CurrentCell.m_id)
		self.m_SharePart:SetActive(false)
	end
end


function CArenaHistoryView.SetData(self)
	self.m_Data = g_ArenaCtrl.m_HistoryInfoSort
	local count = 0
	-- for k,v in ipairs(self.m_Data) do
	for i = 1, #self.m_Data do
		count = count + 1
		if self.m_HistoryCellArr[count] == nil then
			self.m_HistoryCellArr[count] = self:CreateCell()
		end
		self.m_HistoryCellArr[count]:SetData(g_ArenaCtrl.m_HistoryInfo[self.m_Data[#self.m_Data - i + 1]])
		self.m_HistoryCellDic[self.m_Data[#self.m_Data - i + 1]] = self.m_HistoryCellArr[count]
		self.m_HistoryCellArr[count]:SetActive(true)
	end
	count = count + 1
	for i = count, #self.m_HistoryCellArr do
		self.m_HistoryCellArr[i]:SetActive(false)
	end
	self:SetShowing()
end

function CArenaHistoryView.SetShowing(self)
	self.m_ShowingData = g_ArenaCtrl.m_ShowingHistory
	if self.m_ShowingData.fid ~= "" then
		if self.m_ShowingBox == nil then
			self.m_ShowingBox = self:CreateCell()
		end
		self.m_ShowingBox:SetData(self.m_ShowingData)
		self.m_ShowingBox.m_TimeSprite:SetActive(false)
		self.m_ShowingBox:SetParent(self.m_ShowingHistorySlot.m_Transform)
	end
end

function CArenaHistoryView.OnRefreshUI(self)
	self.m_HistoryGrid:Reposition()
	self.m_HistoryScrollView:ResetPosition()
end

function CArenaHistoryView.CreateCell(self)
	local oHistoryCell = self.m_HistoryCell:Clone("oHistoryCell")
	oHistoryCell:SetActive(true)
	oHistoryCell.m_PlayerArmyTable = oHistoryCell:NewUI(1, CTable)
	oHistoryCell.m_EnemyTable = oHistoryCell:NewUI(2, CTable)
	oHistoryCell.m_EnemyNameLabel = oHistoryCell:NewUI(3, CLabel)
	oHistoryCell.m_ScoreLabel = oHistoryCell:NewUI(4, CLabel)
	oHistoryCell.m_ReplayButton = oHistoryCell:NewUI(5, CButton)
	oHistoryCell.m_ShareButton = oHistoryCell:NewUI(6, CButton)
	oHistoryCell.m_EnemyPointLabel = oHistoryCell:NewUI(7, CLabel)
	-- oHistoryCell.m_LoseLabel = oHistoryCell:NewUI(8, CLabel)
	-- oHistoryCell.m_WinSprite = oHistoryCell:NewUI(9, CSprite)
	-- oHistoryCell.m_LoseSprite = oHistoryCell:NewUI(10, CSprite)
	oHistoryCell.m_TimeLabel = oHistoryCell:NewUI(11, CLabel)
	oHistoryCell.m_PlayerSprite = oHistoryCell:NewUI(12, CSprite)
	oHistoryCell.m_EnemySprite = oHistoryCell:NewUI(13, CSprite)
	oHistoryCell.m_TimeSprite = oHistoryCell:NewUI(14, CSprite)
	oHistoryCell.m_ArmyNameLabel = oHistoryCell:NewUI(15, CLabel)
	oHistoryCell.m_ArmyPointLabel = oHistoryCell:NewUI(16, CLabel)

	oHistoryCell.m_ReplayButton:AddUIEvent("click", callback(self, "OnClickReplay", oHistoryCell))
	oHistoryCell.m_ShareButton:AddUIEvent("click", callback(self, "ShowSharePart", oHistoryCell))

	oHistoryCell.m_PlayerAvatarArr = {}
	oHistoryCell.m_EnemyAvatarArr = {}
	self.m_HistoryGrid:AddChild(oHistoryCell)

	function oHistoryCell.SetData(self, oData)
		local count = 1
		local function SetChild(obj, index)
			local oSprite = CSprite.New(obj)
			if oData.playerInfo[count].partner[index] then
				oSprite:SetSpriteName(tostring(oData.playerInfo[count].partner[index]))
				oSprite:SetActive(true)
			else
				oSprite:SetActive(false)
			end
			return oSprite
		end
		oHistoryCell.m_id = oData.fid

		for i = 1, #oData.playerInfo do
			count = i
			
			if oData.playerInfo[i].pid == g_AttrCtrl.pid then
				oHistoryCell.m_PlayerArmyTable:InitChild(SetChild)
				oHistoryCell.m_PlayerName = oData.playerInfo[i].name
				oHistoryCell.m_PlayerSprite:SetSpriteName(tostring(oData.playerInfo[count].shape))
				oHistoryCell.m_ArmyNameLabel:SetText(oData.playerInfo[i].name)
				oHistoryCell.m_ArmyPointLabel:SetText(tostring(oData.playerInfo[i].point))
				oHistoryCell.m_View = i
			else
				oHistoryCell.m_EnemyName = oData.playerInfo[i].name
				oHistoryCell.m_EnemyTable:InitChild(SetChild)
				oHistoryCell.m_EnemyNameLabel:SetText(oData.playerInfo[i].name)
				oHistoryCell.m_EnemyPointLabel:SetText(tostring(oData.playerInfo[i].point))
				oHistoryCell.m_EnemySprite:SetSpriteName(tostring(oData.playerInfo[count].shape))
			end
		end
		if oData.score > 0 then
			oHistoryCell.m_ScoreLabel:SetText("胜利" .. oData.score)
		else
			oHistoryCell.m_ScoreLabel:SetText("失败" .. oData.score)
		end
		-- if oData.score > 0 then
			-- oHistoryCell.m_WinSprite:SetActive(true)
			-- oHistoryCell.m_LoseSprite:SetActive(false)
			-- oHistoryCell.m_ScoreLabel:SetText(oData.score)
		-- else
			-- oHistoryCell.m_WinSprite:SetActive(false)
			-- oHistoryCell.m_LoseSprite:SetActive(true)
			-- oHistoryCell.m_LoseLabel:SetText(oData.score)
		-- end
		oHistoryCell.m_TimeLabel:SetText(g_ArenaCtrl:GetDateText(oData.time))
	end
	return oHistoryCell
end

function CArenaHistoryView.OnClickReplay(self, oHistoryCell)
	-- printc("OnClickReplay: " .. oHistoryCell.m_id)
	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
		netarena.C2GSArenaReplayByRecordId(oHistoryCell.m_id, oHistoryCell.m_View)
	end
	-- g_NotifyCtrl:FloatMsg("该功能暂未开放")
end

function CArenaHistoryView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Arena.Event.SetShowing then
		self:SetShowing()
	end
end

return CArenaHistoryView
