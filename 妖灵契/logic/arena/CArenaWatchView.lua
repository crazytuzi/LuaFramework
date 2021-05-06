local CArenaWatchView = class("CArenaWatchView", CViewBase)

function CArenaWatchView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaWatchView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CArenaWatchView.OnCreateView(self)
	self.m_CloseButton = self:NewUI(1, CButton)
	self.m_RecordScrollView = self:NewUI(2, CScrollView)
	self.m_RecordGrid = self:NewUI(3, CGrid)
	self.m_RecordBox = self:NewUI(4, CBox)
	self.m_TabButtonGrid = self:NewUI(5, CGrid)
	self.m_TabButtonBox = self:NewUI(6, CBox)
	self:InitContent()
end

function CArenaWatchView.InitContent(self)
	self.m_TabButtonDic = {}
	self.m_TabButtonArr = {}
	self.m_RecordBoxArr = {}
	self.m_DefaultGradeId = nil
	self.m_CurrentBtn = nil

	self.m_RecordBox:SetActive(false)
	self.m_TabButtonBox:SetActive(false)
	self.m_CloseButton:AddUIEvent("click", callback(self, "OnClose"))
	self:SetData()
end

function CArenaWatchView.SetData(self)
	local basescore = -1
	self.m_WatchData = g_ArenaCtrl.m_WatchInfo
	for i,v in ipairs(data.arenadata.SortId) do
		if self.m_WatchData[v] ~= nil then
			if self.m_TabButtonArr[i] == nil then 
				self.m_TabButtonArr[i] = self:CreateTabButton()
			end
			self.m_TabButtonArr[i]:SetActive(true)
			self.m_TabButtonDic[self.m_WatchData[v].stage] = self.m_TabButtonArr[i]
			local gradeData = g_ArenaCtrl:GetArenaGradeData(self.m_WatchData[v].stage)
			self.m_TabButtonArr[i]:SetData(self.m_WatchData[v].history_info, gradeData)
			if gradeData.basescore > basescore then
				basescore = gradeData.basescore
				self.m_DefaultGradeId = gradeData.id
			end
		end
	end

	if self.m_TabButtonDic[self.m_DefaultGradeId] ~= nil then
		self:OnChangeTab(self.m_TabButtonDic[self.m_DefaultGradeId])
	end
end

function CArenaWatchView.OnChangeTab(self, oBox)
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn:SetSelect(false)
	end
	self.m_CurrentBtn = oBox
	self.m_CurrentBtn:SetSelect(true)
	local count = 0
	if oBox.m_HistoryData ~= nil then
		for i,v in ipairs(oBox.m_HistoryData) do
			count = count + 1
			if self.m_RecordBoxArr[count] == nil then
				self.m_RecordBoxArr[count] = self:CreateRecord()
			end
			self.m_RecordBoxArr[count]:SetData(v)
			self.m_RecordBoxArr[count]:SetActive(true)
		end
	end
	count = count + 1
	for i = count, #self.m_RecordBoxArr do
		self.m_RecordBoxArr[i]:SetActive(false)
	end
	self.m_RecordGrid:Reposition()
	self.m_RecordScrollView:ResetPosition()
end

function CArenaWatchView.CreateTabButton(self)
	local oBtnBox = self.m_TabButtonBox:Clone()
	oBtnBox.m_OnSelectSprite = oBtnBox:NewUI(1, CSprite)
	oBtnBox.m_Label = oBtnBox:NewUI(2, CLabel)
	oBtnBox.m_SelectLabel = oBtnBox:NewUI(3, CLabel)

	oBtnBox:SetActive(true)
	self.m_TabButtonGrid:AddChild(oBtnBox)
	oBtnBox:AddUIEvent("click", callback(self, "OnChangeTab", oBtnBox))

	function oBtnBox.SetData(self, historyData, gradeData)
		oBtnBox.m_GradeData = gradeData
		oBtnBox.m_HistoryData = historyData
		oBtnBox.m_Label:SetText(gradeData.name)
		oBtnBox.m_SelectLabel:SetText(gradeData.name)
	end

	function oBtnBox.SetSelect(self, bValue)
		oBtnBox.m_Label:SetActive(not bValue)
		oBtnBox.m_OnSelectSprite:SetActive(bValue)
	end
	oBtnBox:SetSelect(false)
	return oBtnBox
end

function CArenaWatchView.CreateRecord(self)
	local oRecordBox = self.m_RecordBox:Clone()
	oRecordBox:SetActive(true)
	oRecordBox.m_PlayerArmyTable = oRecordBox:NewUI(1, CTable)
	oRecordBox.m_EnemyTable = oRecordBox:NewUI(2, CTable)
	oRecordBox.m_EnemyNameLabel = oRecordBox:NewUI(3, CLabel)
	oRecordBox.m_EnemyPointLabel = oRecordBox:NewUI(4, CLabel)
	oRecordBox.m_PlayerNameLabel = oRecordBox:NewUI(5, CLabel)
	oRecordBox.m_PlayerPointLabel = oRecordBox:NewUI(6, CLabel)
	oRecordBox.m_ReplayBtn = oRecordBox:NewUI(7, CBox)
	oRecordBox.m_PlayerSprite = oRecordBox:NewUI(8, CSprite)
	oRecordBox.m_EnemySprite = oRecordBox:NewUI(9, CSprite)

	self.m_RecordGrid:AddChild(oRecordBox)

	oRecordBox.m_ReplayBtn:AddUIEvent("click", callback(self, "OnClickReplay", oRecordBox))
	oRecordBox.m_PlayerAvatarArr = {}
	oRecordBox.m_EnemyAvatarArr = {}
	function oRecordBox.SetData(self, data)
		local count = 1
		local function SetChild(obj, index)
			local oSprite = CSprite.New(obj)
			if data.playerInfo[count].partner[index] then
				oSprite:SetSpriteName(tostring(data.playerInfo[count].partner[index]))
				oSprite:SetActive(true)
			else
				oSprite:SetActive(false)
			end
			return oSprite
		end
		oRecordBox.m_id = data.fid

		for i = 1, #data.playerInfo do
			count = i
			if i == 1 then
				oRecordBox.m_PlayerArmyTable:InitChild(SetChild)
				oRecordBox.m_PlayerNameLabel:SetText(data.playerInfo[i].name)
				oRecordBox.m_PlayerPointLabel:SetText(tostring(data.playerInfo[i].point))
				oRecordBox.m_PlayerSprite:SetSpriteName(tostring(data.playerInfo[count].shape))
			else
				oRecordBox.m_EnemyTable:InitChild(SetChild)
				oRecordBox.m_EnemyNameLabel:SetText(data.playerInfo[i].name)
				oRecordBox.m_EnemyPointLabel:SetText(tostring(data.playerInfo[i].point))
				oRecordBox.m_EnemySprite:SetSpriteName(tostring(data.playerInfo[count].shape))
			end
		end
	end
	return oRecordBox
end

function CArenaWatchView.OnClickReplay(self, oRecordBox)
	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
		netarena.C2GSArenaReplayByRecordId(oRecordBox.m_id, 1)
	end
end

return CArenaWatchView