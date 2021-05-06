local CAchieveInfoBox = class("CAchieveInfoBox", CBox)

function CAchieveInfoBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_Box = self:NewUI(3, CBox)
	self.m_AchlistList = nil
	self.m_AchieveDic = {}
	self:InitContent()
end

function CAchieveInfoBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CAchieveInfoBox.InitContent(self)
	self.m_Box:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_Box, 
		function(oBox)
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_DescLabel = oBox:NewUI(2, CLabel)
			oBox.m_ItemGrid = oBox:NewUI(3, CGrid)
			oBox.m_ItemBox = oBox:NewUI(4, CItemTipsBox)
			oBox.m_FinishBtn = oBox:NewUI(5, CButton)
			oBox.m_Slider = oBox:NewUI(6, CSlider)
			oBox.m_FinishedLabel = oBox:NewUI(7, CLabel)
			oBox.m_ItemBox:SetActive(false)
			oBox.m_ItemList = {}
			oBox.m_ItemGrid:Clear()
			return oBox
		end)
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			self:UpdateBox(oBox, dData)
			oBox:SetActive(true)
		else	
			oBox:SetActive(false)
		end
	end)
	
end

function CAchieveInfoBox.RefreshAchieveInfo(self, achlist)
	self.m_AchlistList = self:GetAchieveData(achlist)
	self.m_WrapContent:SetData(self.m_AchlistList, true)
	self.m_ScrollView:ResetPosition()
end

function CAchieveInfoBox.GetAchieveData(self, achlist)
	local data = data.achievedata.ACHIEVE
	local dict = {}
	local curBelong = self.m_ParentView:GetCurBelong()
	for k,v in pairs(data) do
		if v.belong == curBelong then
			v.cur = 0
			v.done = define.Achieve.Status.UnFinished 
			v.sort = 2
			dict[k] = v
		end
	end
	for i,v in ipairs(achlist) do
		if dict and dict[v.id] then
			dict[v.id].cur = v.cur
			dict[v.id].done = v.done 
			--排序 完成<未完成<已完成
			if v.done == define.Achieve.Status.Finishing then
				dict[v.id].sort = 1
			elseif v.done == define.Achieve.Status.UnFinished then
				dict[v.id].sort = 2
			elseif v.done == define.Achieve.Status.Finished then
				dict[v.id].sort = 3
			end
		end
	end
	local dAchieve = {}
	for k,v in pairs(dict) do
		if v.done == define.Achieve.Status.Finished then
			if v.doneshow == 1 then
				table.insert(dAchieve, v)
			end
		else
			if v.needdone and v.needdone ~= 0 then
				if dict[v.needdone] and dict[v.needdone].done == define.Achieve.Status.Finished then
					table.insert(dAchieve, v)
				end
			elseif v.needdone == 0 then
				table.insert(dAchieve, v)
			end
		end
	end
	table.sort(dAchieve, function (a, b)
		if a.sort == b.sort then
			return a.sub_direction < b.sub_direction 
		else
			return a.sort < b. sort
		end
	end)

	return dAchieve
end

function CAchieveInfoBox.UpdateBox(self, oBox, dAchieve)
	self.m_AchieveDic[oBox:GetInstanceID()] = oBox
	oBox.m_FinishBtn:SetActive(false)
	oBox.m_Slider:SetActive(false)
	oBox.m_FinishedLabel:SetActive(false)

	oBox.m_AchieveID = dAchieve.id
	oBox.m_Condition = dAchieve.condition
	oBox.m_NameLabel:SetText(dAchieve.name)
	oBox.m_DescLabel:SetText(dAchieve.desc)

	if not dAchieve.done or dAchieve.done == define.Achieve.Status.UnFinished then
		oBox.m_Slider:SetActive(true)
		local cur = dAchieve.cur or 0
		oBox.m_Slider:SetValue(cur / oBox.m_Condition)
		oBox.m_Slider:SetSliderText(string.format("%s/%s", string.numberConvert(cur), string.numberConvert(oBox.m_Condition)))
	elseif dAchieve.done == define.Achieve.Status.Finishing then
		oBox.m_FinishBtn:SetActive(true)
	elseif dAchieve.done == define.Achieve.Status.Finished then
		oBox.m_FinishedLabel:SetActive(true)
	end
	
	oBox.m_FinishBtn:AddUIEvent("click", callback(self, "OnFinish", oBox.m_AchieveID))
	
	for i,v in ipairs(oBox.m_ItemList) do
		if v then
			v:SetActive(false)
		end
	end

	local lRewardItem = {[1]={num=dAchieve.point,sid=[[1023]],},}
	table.extend(lRewardItem, dAchieve.rewarditem)
	for i,v in ipairs(lRewardItem) do
		local box = oBox.m_ItemList[i]
		if box then
			box:SetActive(true)
		else
			box = oBox.m_ItemBox:Clone()
			box:SetActive(true)
			table.insert(oBox.m_ItemList, box)
			oBox.m_ItemGrid:AddChild(box)
		end
		if string.find(v.sid, "value") then
			local sid, value = g_ItemCtrl:SplitSidAndValue(v.sid)
			box:SetItemData(sid, value, nil, {isLocal = true})
		elseif string.find(v.sid, "partner") then
			local sid, parId = g_ItemCtrl:SplitSidAndValue(v.sid)
			box:SetItemData(sid, v.num, parId, {isLocal = true})
		else
			box:SetItemData(tonumber(v.sid), v.num, nil, {isLocal = true})
		end
	end
	oBox.m_ItemGrid:Reposition()

	return oBox
end

function CAchieveInfoBox.OnFinish(self, iAchieve, obj)
	--printc("领取成就奖励:", iAchieve)
	g_AchieveCtrl:C2GSAchieveReward(iAchieve)
end

function CAchieveInfoBox.RefreshAchieve(self, info)
	if info then
		for k,oBox in pairs(self.m_AchieveDic) do
			if oBox.m_AchieveID == info.id then
				local cur = info.cur or 0
				if cur >= oBox.m_Condition then
					oBox.m_FinishBtn:SetActive(true)
					oBox.m_FinishedLabel:SetActive(false)
				else
					oBox.m_Slider:SetValue(cur / oBox.m_Condition)
					oBox.m_Slider:SetSliderText(string.format("%s/%s", string.numberConvert(cur), string.numberConvert(oBox.m_Condition)))
				end
				return
			end
		end
		local oBox = self.m_AchieveDic and self.m_AchieveDic[info.id]
		for i,v in ipairs(self.m_AchlistList) do
			if v.id == info.id then
				v = info
			end
		end
		self.m_WrapContent:SetData(self.m_AchlistList, true)
	end
end

return CAchieveInfoBox