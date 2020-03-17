--[[
运营活动UI
2015-10-12 11:44:42
liyuan
]]
------------------------------------------------------------
_G.OperActUIManager = {};
OperActUIManager.currentGroupId = 0
OperActUIManager.itemlist = {}
OperActUIManager.currentPage = 1
OperActUIManager.ShowNum = 10
OperActUIManager.NewData = 24
OperActUIManager.timerId = nil

-- 打开关闭主面板
function OperActUIManager:ShowHideOperActUI(iconType)
	-- print(debug.traceback())
	local actUI = OperactivitiesConsts.BtnUIMap[iconType]
	
	if actUI:IsShow() then
		if self:IsUseMainPanel(iconType) and actUI.currentIconId ~= iconType then
			actUI.isNoTween = true
			actUI:Hide();
			actUI:Show(iconType);
		else
			actUI:Hide();			
		end
	else
		actUI:Show(iconType);		
	end	
end

function OperActUIManager:IsUseMainPanel(iconId)
	if iconId == OperactivitiesConsts.iconHuodong1 or iconId == OperactivitiesConsts.iconHuodong2 or iconId == OperactivitiesConsts.iconHuodong4 or iconId == OperactivitiesConsts.iconHuodong5 then
		return true
	end	
	
	return false
end

function OperActUIManager:HideOperActUI(iconType)

end

-- 打开关闭子面板
function OperActUIManager:ShowChildUI(groupId, isFirst)
	if groupId == self.currentGroupId and (not isFirst) then
		FPrint('重复打开运营活动组：'..groupId)
		return
	end

	local childName = self:GetChildUIByGroupId(groupId)
	
	if not childName or childName == "" then FPrint('error:运营活动没有找到子面板'..groupId) end
	self.currentGroupId = groupId
	Notifier:sendNotification(NotifyConsts.OpenChildPanelByGroupId, {childName = childName});
end

function OperActUIManager:HideChildUI(groupId)

end

-- 获得子面板
function OperActUIManager:GetChildUIByGroupId(groupId)
	local mainType, subType = OperactivitiesModel:GetOperActType(groupId)
	for k,v in pairs (t_uiframe) do
		-- FPrint('获得子面板'..mainType..':'..subType)
		-- FTrace(v)
		if v.type == mainType and v.subtype == subType then
			return v.ui_frame
		end
	end
	
	return nil	
end

-- 得到子页签列表
function OperActUIManager:GetTabList(iconType)
	self.itemlist = {};
	-- FTrace(OperactivitiesModel.groupSortArr)
	
	local firstGroupId = nil
	for i,groupId in ipairs(OperactivitiesModel.groupSortArr) do
		if self:CheckGroupIsOpen(groupId) then
			local groupVO = OperactivitiesModel.groupList[groupId]
			local actVO = groupVO[1]
			if actVO and actVO.btn == iconType then
				local itemUIData = {}
				itemUIData.actId = actVO.id
				itemUIData.btnName = actVO.groupName or 'groupTxt'
				itemUIData.txtGroupId = groupId
				itemUIData.group = actVO.group	
				itemUIData.isDuihuan = actVO.mainType					
				itemUIData.isAward = OperactivitiesModel:GetGroupAwardNumById(groupId) or 0
				FPrint('OperactivitiesModel:GetGroupAwardNumById'..itemUIData.isAward)
				local isFirstDay = OperactivitiesModel:GetStartIsFirstDay(groupId)
				
				local startTime = OperactivitiesModel:GetGroupStartTimeByGroupId(groupId)
				local startHort = math.floor(startTime/3600)
				if startHort < OperActUIManager.NewData and startHort >= 0 then
					if not isFirstDay then
						itemUIData.isNew = 1					
					else
						itemUIData.isNew = -1
					end
				else
					itemUIData.isNew = -1
				end
				-- FPrint('得到子页签列表'..actVO.group)
				
				table.push(self.itemlist,itemUIData);					
			end	
		end		
	end
	
	if #self.itemlist <= 0 then
		return nil, nil;
	end
	
	local resItemList = {}
	local startIndex = self:GetStartIndex()
	local endIndex = startIndex + OperActUIManager.ShowNum - 1
	if endIndex > #self.itemlist then
		endIndex = #self.itemlist
	end
	-- FPrint(startIndex..':'..endIndex)
	-- FTrace(self.itemlist)
	for i = startIndex, endIndex do
		FPrint(i)
		table.push(resItemList,UIData.encode(self.itemlist[i]));
	end
	
	
	firstGroupId = self.itemlist[startIndex].group
	
	-- FPrint('分页'..startIndex..':'..endIndex..':'..#self.itemlist)
	-- FPrint('firstGroupId'.. firstGroupId)
	return resItemList, firstGroupId;
end

function OperActUIManager:CheckGroupIsOpen(groupId)
	if not OperactivitiesModel:GetOperActGroupIsShow(groupId) then return false end
	if not OperactivitiesModel:GetPriorityIsShow(groupId) then return false end
	if not OperactivitiesModel:GetNeedActivityIsShow(groupId) then return false end
	
	return true
end

-- 总的活动组数
function OperActUIManager:GetItemNum()
	return #self.itemlist
end

-- 起始活动组
function OperActUIManager:GetStartIndex()
	
	local maxPage = math.ceil(self:GetItemNum()/OperActUIManager.ShowNum)
	if maxPage <= 0 then maxPage = 1 end
	if self.currentPage < 1 then
		self.currentPage = 1		
	end
	
	if self.currentPage > maxPage then
		self.currentPage = maxPage		
	end
	
	return (self.currentPage - 1)*OperActUIManager.ShowNum + 1
end



