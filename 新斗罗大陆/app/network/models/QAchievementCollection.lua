-- @Author: liaoxianbo
-- @Date:   2020-07-03 14:59:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-17 17:45:54

local QBaseModel = import("...models.QBaseModel")
local QAchievementCollection = class("QAchievementCollection", QBaseModel)
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QAchievementCollection.UPDATE_COLLEGE_STATE = "UPDATE_COLLEGE_STATE"

function QAchievementCollection:ctor(options)
    QAchievementCollection.super.ctor(self)
end

function QAchievementCollection:didappear()
	self:initData()
end

function QAchievementCollection:disappear()
	self:initData()
end

function QAchievementCollection:loginEnd()
	
	self._myColletionCellInfo = {} --子类成就任务完成情况
	local allCondtion = db:getStaticByName("collection_conditions")
	for _,v in pairs(allCondtion) do
		if not self._myColletionCellInfo[v.id] then
			self._myColletionCellInfo[v.id] = {}
		end

		self._myColletionCellInfo[v.id].id = v.id
		self._myColletionCellInfo[v.id].processNum = 0
		self._myColletionCellInfo[v.id].conditionNum = v.num
	end

end

function QAchievementCollection:initData()
	self._allAchievementCollections = {} --所有成就
	self._achievementCollectionCells = {} -- 成就子任务

	self._myColletionInfo = {}  --成就收集详情
end


function QAchievementCollection:openDialog()

	self:getMyInfoCollection(function()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAchievementCollection"})
	end,function()
		app.tip:floatTip("成就收藏册暂未开放")
	end)
end

function QAchievementCollection:analyzeColletionCondition(conditions)
	local cellconditionTbl = {}
	if conditions then
		local tbl = string.split(conditions,";")
		for _,v in pairs(tbl) do
			if v then
				local cellInfo = self:getAchievementTaskByCondition(tonumber(v))
				if cellInfo then
					table.insert(cellconditionTbl,cellInfo)
				end
			end
		end
	end

	return cellconditionTbl
end

function QAchievementCollection:analyzeColletionAwards(awardStr)
	local items = {}
	remote.items:analysisServerItem(awardStr,items)
	return items
end

function QAchievementCollection:getAllAchieveCollections()
	if q.isEmpty(self._allAchievementCollections) then
		local allAchievementCollections = db:getStaticByName("achievement_collection")
		for _,v in pairs(allAchievementCollections) do
			table.insert(self._allAchievementCollections,v)
		end
	end
	table.sort( self._allAchievementCollections, function(a,b)
		return tonumber(a.id) < tonumber(b.id)
	end )
	return self._allAchievementCollections
end

function QAchievementCollection:getAchievementConfigById(id)
	local allAchievements = self:getAllAchieveCollections()
	for _, configInfo in pairs(allAchievements) do
		if configInfo.collect_id == id then
			return configInfo
		end
	end

	return nil
end

function QAchievementCollection:getAchievementTaskByCondition( conditionId )
	if q.isEmpty(self._achievementCollectionCells) then
		self._achievementCollectionCells = db:getStaticByName("collection_conditions")
	end

	for _, cellInfo in pairs(self._achievementCollectionCells) do
		if cellInfo.id == conditionId then
			return cellInfo
		end
	end

	return nil
end

function QAchievementCollection:checkRedTipsById( collectId )
	local haveFinsh,finshNum = self:checkAchievementIsFinash(collectId)
	local isGetAwards = self:checkAchievementIsGetAwards(collectId)
	if haveFinsh and not isGetAwards then
		return true
	end

	return false
end

function QAchievementCollection:checkEntranceRedTips( )
	local allAchievements = self:getAllAchieveCollections()
	for _,v in pairs(allAchievements) do
		if self:checkRedTipsById(v.id) then
			return true
		end
	end

	return false
end

function QAchievementCollection:checkAchievementIsFinash(collectId)
	local receivedAward = self:checkAchievementIsGetAwards(collectId)
	if receivedAward then 
		return true 
	end
	local finshNum = 0
	for _,myCollegeInfo in pairs(self._myColletionInfo) do
		if myCollegeInfo.collectId == collectId then
			local targetIdTbl = string.split(myCollegeInfo.targetIds or "",";")
			if targetIdTbl then
				for _,v in pairs(targetIdTbl) do
					local tbl = string.split(v,"^")
					if tbl[1] then
						if self:checkMyCellCondtionState(tbl[1]) then
							finshNum = finshNum + 1
						end
					end
				end
			end
		end
	end
	print("完成的数量---collectId,finshNum=",collectId,finshNum)
	for _,v in pairs(self._allAchievementCollections) do
		if v.id == collectId then
			if finshNum >= v.num then
				return true
			end
		end
	end
	return false,finshNum
end

function QAchievementCollection:getMyCellCondtionInfoById( conditionId )
	local id = tonumber(conditionId)
	return self._myColletionCellInfo[id]
end

function QAchievementCollection:checkMyCellCondtionState(conditionId)
	local id = tonumber(conditionId)
	if not self._myColletionCellInfo[id] then return false end

	return self._myColletionCellInfo[id].processNum == self._myColletionCellInfo[id].conditionNum
end

function QAchievementCollection:checkAchievementIsGetAwards(collectId)
	for _,myCollegeInfo in pairs(self._myColletionInfo) do
		if myCollegeInfo.collectId == collectId then
			return myCollegeInfo.received
		end
	end

	return false
end


function QAchievementCollection:setAchievementIsGetAwards(collectId)
	for _,myCollegeInfo in pairs(self._myColletionInfo) do
		if myCollegeInfo.collectId == collectId then
			myCollegeInfo.received = true
			break
		end
	end

	self:dispatchEvent({name = QAchievementCollection.UPDATE_COLLEGE_STATE})
end
-- message CollectData{
--     optional int32 collectId = 1; // 收藏ID
--     optional bool received = 2; // 是否领奖
--     repeated string targetIds = 3; // 已收集的目标ID
-- }

function QAchievementCollection:updateMyInfoCollection( myCollegeInfo)
	self._myColletionInfo = myCollegeInfo
	for _,myCollegeInfo in pairs(self._myColletionInfo) do
		local targetIdTbl = string.split(myCollegeInfo.targetIds or "",";")
		if targetIdTbl then
			for _,v in pairs(targetIdTbl) do
				local tbl = string.split(v,"^")
				if tbl[1] and tbl[1] ~= "" then
					if not self._myColletionCellInfo[tonumber(tbl[1])] then
						self._myColletionCellInfo[tonumber(tbl[1])] = {}
					end
					self._myColletionCellInfo[tonumber(tbl[1])].processNum = tonumber(tbl[2] or 0)
				end
			end
		end
	end	
end

function QAchievementCollection:responseDataHandler( response,successFunc,failFunc )
	if response.collectResponse and response.collectResponse.collectData then
		self:updateMyInfoCollection(response.collectResponse.collectData or {})	
	end

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

function QAchievementCollection:getMyInfoCollection(success,fail )
    local request = {api = "COLLECT_GET"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

function QAchievementCollection:getCollectRewardRequest(id,success,fail)
	local getCollectRewardRequest = {collectId = id}
    local request = {api = "COLLECT_GET_REWARD",getCollectRewardRequest = getCollectRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:setAchievementIsGetAwards(id)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

return QAchievementCollection