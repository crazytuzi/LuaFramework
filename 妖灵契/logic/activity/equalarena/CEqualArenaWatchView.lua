local CEqualArenaWatchView = class("CEqualArenaWatchView", CArenaWatchView)

function CEqualArenaWatchView.InitContent(self)
	CArenaWatchView.InitContent(self)
	self.m_TabButtonGrid:SetActive(false)
end

function CEqualArenaWatchView.SetData(self)
	local basescore = -1
	self.m_WatchData = g_EqualArenaCtrl.m_WatchInfo
	for i,v in ipairs(data.equalarenadata.SortId) do
		if self.m_WatchData[v] ~= nil then
			if self.m_TabButtonArr[i] == nil then 
				self.m_TabButtonArr[i] = self:CreateTabButton()
			end
			self.m_TabButtonArr[i]:SetActive(true)
			self.m_TabButtonDic[self.m_WatchData[v].stage] = self.m_TabButtonArr[i]
			local gradeData = g_EqualArenaCtrl:GetArenaGradeData(self.m_WatchData[v].stage)
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

-- function CEqualArenaWatchView.OnClickReplay(self, oRecordBox)
-- 	if g_ActivityCtrl:ActivityBlockContrl("watchreplay") then
-- 		netarena.C2GSArenaReplayByRecordId(oRecordBox.m_id)
-- 	end
-- end

return CEqualArenaWatchView