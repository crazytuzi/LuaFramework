CTitleCtrl = class("CTitleCtrl", CCtrlBase)

function CTitleCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTitleCtrl.ResetCtrl(self)
	self.m_TitleList = nil
	self.m_NewTitle = {}
end

function CTitleCtrl.LoginInit(self)
	nettitle.C2GSTitleInfoList()
end

function CTitleCtrl.GetTitleInfo(self, tid)
	if self.m_TitleList == nil then
		return nil
	end
	return self.m_TitleList[tid]
end

function CTitleCtrl.GetTitleName(self, dInfo)
	local sName = "暂无称号"
	if dInfo then
		for k,v in pairs(dInfo) do
			local titleData = data.titledata.DATA[v.tid]
			if titleData and titleData.isopen == 1 then
				if titleData.show_type == define.Title.ShowType.HeadTitle then
					return self.m_TitleList[v.tid].name
				-- elseif titleData.show_type == define.Title.ShowType.FootTitle then
				-- 	sName = self.m_TitleList[v.tid].name
				end
			end
		end
	end
	return sName
end

function CTitleCtrl.OnReceiveTitleList(self, titleList)
	self.m_TitleList = {}
	for k,v in pairs(titleList) do
		self.m_TitleList[v.tid] = v
	end
	self:OnEvent(define.Title.Event.OnGetTitleList)
end

function CTitleCtrl.ShowTitleView(self)
	CAttrChangeTitleView:ShowView()
end

function CTitleCtrl.UpdateTitleInfo(self, info)
	if self.m_TitleList == nil then
		return
	end
	self.m_TitleList[info.tid] = info
	self:OnEvent(define.Title.Event.OnUpdateTitleInfo, info.tid)
end

function CTitleCtrl.RemoveTitles(self, lTid)
	if self.m_TitleList == nil then
		return
	end
	for k,v in pairs(lTid) do
		self.m_TitleList[v] = {
			tid = v,
			name = "",
			progress = 0,
			left_time = 0,
			create_time = 0,
		}
	end
	self:OnEvent(define.Title.Event.RemoveTitles)
end

function CTitleCtrl.AddTitleInfo(self, info)
	local titleData = data.titledata.DATA[info.tid]
	if titleData.show_type == define.Title.ShowType.HeadTitle and titleData.isopen == 1 then
		table.insert(self.m_NewTitle, info)
		g_WindowTipCtrl:SetWindowTitleReward()
	end

	if self.m_TitleList == nil then
		return
	end
	self.m_TitleList[info.tid] = info
	self:OnEvent(define.Title.Event.OnUpdateTitleInfo, info.tid)
end

function CTitleCtrl.IsInChannel(self, list)
	self.m_Channel = g_SdkCtrl:GetSubChannelId()
	if list and #list > 0 then
		for k,v in pairs(list) do
			if v == self.m_Channel then
				return true
			end
		end
	else
		return true
	end
	return false
end

--获取需要展示的称谓ID列表
function CTitleCtrl.GetShowRecordIDs(self)
	local ids = {}
	local notGetIDs = {}

	for i,v in ipairs(data.titledata.ShowSort) do
		local titleData = data.titledata.DATA[v]
		if titleData.isopen == 1 and self.m_TitleList[v] and self:IsInChannel(titleData.channel) then
			if self.m_TitleList[v].progress >= titleData.condition_value and self.m_TitleList[v].create_time ~= 0 then
				table.insert(ids, v)
			else
				table.insert(notGetIDs, v)
			end
		end
	end
	for i,v in ipairs(notGetIDs) do
		table.insert(ids, v)
	end
	return ids
end

function CTitleCtrl.GetRoleList(self)
	local ids = {}
	local notGetIDs = {}
	
	for i,v in ipairs(data.titledata.ShowSort) do
		local titleData = data.titledata.DATA[v]
		if titleData.isopen == 1 and self.m_TitleList[v] and self:IsInChannel(titleData.channel) and titleData.type == 0 and titleData.group ~= 8 then
			if self.m_TitleList[v].progress >= titleData.condition_value and self.m_TitleList[v].create_time ~= 0 then
				table.insert(ids, v)
			else
				table.insert(notGetIDs, v)
			end
		end
	end
	for i,v in ipairs(notGetIDs) do
		table.insert(ids, v)
	end
	return ids
end

function CTitleCtrl.GetPartnerList(self)
	local ids = {}
	local notGetIDs = {}

	for i,v in ipairs(data.titledata.ShowSort) do
		local titleData = data.titledata.DATA[v]
		if titleData.isopen == 1 and self.m_TitleList[v] and self:IsInChannel(titleData.channel) and titleData.type == 1 then
			if self.m_TitleList[v].progress >= titleData.condition_value and self.m_TitleList[v].create_time ~= 0 then
				table.insert(ids, v)
			else
				table.insert(notGetIDs, v)
			end
		end
	end
	for i,v in ipairs(notGetIDs) do
		table.insert(ids, v)
	end
	return ids
end

function CTitleCtrl.GetPartnerTitle(self, iPartnerType)
	local ids = {}
	for i,v in ipairs(data.titledata.ShowSort) do
		local titleData = data.titledata.DATA[v]
		if table.index(titleData.type_effect, iPartnerType) then
			local titleObj = self:GetTitleInfo(v)
			if titleData.isopen == 1 and self:IsInChannel(titleData.channel) and titleData.type ==1 and titleObj then
				if titleObj.progress >= titleData.condition_value and titleObj.create_time ~= 0 then
					table.insert(ids, v)
				end
			end
		end
	end
	return ids
end


return CTitleCtrl