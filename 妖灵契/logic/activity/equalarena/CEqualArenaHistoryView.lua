local CEqualArenaHistoryView = class("CEqualArenaHistoryView", CArenaHistoryView)

function CEqualArenaHistoryView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/EqualArena/EqualArenaHistoryView.prefab", ob)
	self.m_ExtendClose = "Black"
	self.m_HistoryCellArr = {}
	self.m_HistoryCellDic = {}
end

function CEqualArenaHistoryView.InitContent(self)
	self:InitSharePart()
	self.m_HistoryCell:SetActive(false)
	self:SetData()
end

function CEqualArenaHistoryView.ShowSharePart(self, oHistoryCell)
	self.m_SharePart:SetActive(true)
	self.m_CurrentCell = oHistoryCell
end

function CEqualArenaHistoryView.SetData(self)
	self.m_Data = g_EqualArenaCtrl.m_HistoryInfoSort
	local count = 0
	for i = 1, #self.m_Data do
		count = count + 1
		if self.m_HistoryCellArr[count] == nil then
			self.m_HistoryCellArr[count] = self:CreateCell()
		end
		self.m_HistoryCellArr[count]:SetData(g_EqualArenaCtrl.m_HistoryInfo[self.m_Data[#self.m_Data - i + 1]])
		self.m_HistoryCellDic[self.m_Data[#self.m_Data - i + 1]] = self.m_HistoryCellArr[count]
		self.m_HistoryCellArr[count]:SetActive(true)
	end
	count = count + 1
	for i = count, #self.m_HistoryCellArr do
		self.m_HistoryCellArr[i]:SetActive(false)
	end
end

-- function CEqualArenaHistoryView.OnClickReplay(self, oHistoryCell)
-- 	-- printc("OnClickReplay: " .. oHistoryCell.m_id)
-- 	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
-- 		netarena.C2GSArenaReplayByRecordId(oHistoryCell.m_id, 1)
-- 	end
-- 	-- g_NotifyCtrl:FloatMsg("该功能暂未开放")
-- end

return CEqualArenaHistoryView
