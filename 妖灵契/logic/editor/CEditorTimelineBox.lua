local CEditorTimelineBox = class("CEditorTimelineBox", CBox)

function CEditorTimelineBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Sprite = self:NewUI(1, CSprite)
	self.m_BeginTimeLabel = self:NewUI(2, CLabel)
	self.m_EndTimeLabel = self:NewUI(3, CLabel)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_Data = {}
	self.m_RefreshValueCb = nil
	self.m_WidthPerSec = 0
end

function CEditorTimelineBox.SetWidthPerSec(self, i)
	self.m_WidthPerSec = i
end


function CEditorTimelineBox.SetData(self, dData)
	self.m_Data = dData
	local bAddCB = false
	if not self.m_RefreshValueCb  and dData.value_refresh_cb then
		bAddCB = true
		self.m_RefreshValueCb = dData.value_refresh_cb
	end
	if dData.length_time and dData.length_time ~= 0 then
		self.m_Sprite:SetWidth(dData.length_time*self.m_WidthPerSec)
		self.m_EndTimeLabel:SetText(tostring(dData.begin_time+dData.length_time))
		if bAddCB then
			self.m_EndTimeLabel:AddUIEvent("drag", callback(self, "OnDragging", "end"))
		end
	else
		self.m_EndTimeLabel:SetText("??")
	end
	local pos = self.m_Sprite:GetLocalPos()
	pos.x = dData.begin_time*self.m_WidthPerSec
	self.m_Sprite:SetLocalPos(pos)
	local s = string.gsub(dData.desc, "\n", " ")
	self.m_DescLabel:SetText(s)

	self.m_BeginTimeLabel:SetText(tostring(dData.begin_time))
	if bAddCB then
		self.m_BeginTimeLabel:AddUIEvent("drag", callback(self, "OnDragging", "begin"))
	end
end

function CEditorTimelineBox.OnDragging(self, sType, oLabel, dt, dt2)
	local bRefresh = false
	if sType == "begin" then
		local iEnd = tonumber(self.m_EndTimeLabel:GetText())
		local iNew = (oLabel:GetLocalPos().x+dt.x) / self.m_WidthPerSec
		iNew = tonumber(string.format("%.2f", iNew))
		if iNew >= 0 then
			self.m_Data.begin_time = iNew
			if iEnd and iNew < iEnd then
				self.m_Data.length_time = iEnd - iNew
			end
			bRefresh = true
		end
	else
		local iBegin = tonumber(self.m_BeginTimeLabel:GetText())
		local iNew = (oLabel:GetLocalPos().x+dt.x) / self.m_WidthPerSec
		iNew = tonumber(string.format("%.2f", iNew))
		if iNew > iBegin then
			self.m_Data.length_time = iNew-iBegin
			bRefresh = true
		end
	end
	if bRefresh then
		self:SetData(self.m_Data)
	end
end

function CEditorTimelineBox.OnDragEnd(self, sType, oLabel)
	if self.m_RefreshValueCb then
		self.m_RefreshValueCb(self.m_Data.idx, sType, tonumber(oLabel:GetText()))
	end
end

function CEditorTimelineBox.RefreshValue(self, bRefreshTable)
	local iBegin = tonumber(self.m_BeginTimeLabel:GetText())
	local iEnd = tonumber(self.m_EndTimeLabel:GetText())
	if iBegin then
		self.m_RefreshValueCb(self.m_Data.idx, "begin", iBegin, bRefreshTable and not iEnd)
	end
	if iEnd then
		self.m_RefreshValueCb(self.m_Data.idx, "end", iEnd, bRefreshTable)
	end
end

return CEditorTimelineBox