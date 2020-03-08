
function RankBoard:OnGetRanBoadData(tbData, szKey, nPage, tbMyRankInfo)
	self.tbAllData[szKey][nPage] = tbData
	self.tbUpdateDataTime[szKey] =  self.tbUpdateDataTime[szKey] or {}
	self.tbUpdateDataTime[szKey][nPage] =  GetTime();
	if tbMyRankInfo then
		self.tbMyRankInfo[szKey] = tbMyRankInfo --同时把最大页面也放进去
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA, szKey, nPage)
end

function RankBoard:CheckUpdateData(szKey, nPage)
	if not self.tbAllData[szKey] then
		return
	end
	local tbData = RankBoard.tbAllData[szKey][nPage]
	local bHasMy = self.tbMyRankInfo[szKey] and true or false;
	if not tbData then
		RemoteServer.OpenRankBoard(szKey, nPage, not bHasMy)
		return
	end

	local nUpdateTime = self.tbUpdateDataTime[szKey] and self.tbUpdateDataTime[szKey][nPage]
	if not nUpdateTime or GetTime() - nUpdateTime  > self.nRequestDelay then
		RemoteServer.OpenRankBoard(szKey, nPage, true)
	end
	return tbData
end

function RankBoard:ClientInit()
	self.tbAllData = {};
	self.tbUpdateDataTime = {}
	self.tbMyRankInfo  = {} -- 现在请求排行数据用的时间间隔参数都是 self.tbUpdateDataTime，所以放一起请求返回了
	for k,v in pairs(self.tbSetting) do
		self.tbAllData[k] = {}
	end
	self.tbOriShowKeys = nil;
end

function RankBoard:ResetRankboardKeys(  )
	self.tbOriShowKeys = nil;
end

function RankBoard:GetUiShowOriShowKeys( ... )
	if self.tbOriShowKeys then
		return self.tbOriShowKeys
	end
	local tbOriShowKeys = {}

	for k,v in pairs(RankBoard.tbSetting) do
		if (v.TimeFrame == "" or GetTimeFrameState(v.TimeFrame) == 1) and
			(Lib:IsEmptyStr(v.ActivityType) or Activity:__IsActInProcessByType(v.ActivityType)) and
			v.NoShowInMaiPanel == 0 then
			if Lib:IsEmptyStr(v.Sub)  then	
				table.insert(tbOriShowKeys, v)
			else			
				local tbMainKey;
				for i2, v2 in ipairs(tbOriShowKeys) do
					if v2.Key == v.Sub then
						tbMainKey = v2;
						break;
					end
				end
				if not tbMainKey then
					table.insert(tbOriShowKeys, { Name = v.Sub, Key = v.Sub , ID = v.ID, tbSubs = {}, nIndex = v.nIndex} )
					tbMainKey = tbOriShowKeys[#tbOriShowKeys]
				end
				v.bSub = true
				table.insert(tbMainKey.tbSubs, v)
				if v.ID < tbMainKey.ID then
					tbMainKey.ID =  v.ID;
				end

				if v.nIndex < tbMainKey.nIndex then
					tbMainKey.nIndex =  v.nIndex;
				end
			end
		end
	end

	local fnSort = function(a,b)
		if a.Key=="ZhongQiuJie" or b.Key=="ZhongQiuJie" then
			return a.Key=="ZhongQiuJie"
		end
		return a.nIndex < b.nIndex
	end

	

	table.sort( tbOriShowKeys, fnSort)

	for i,v in ipairs(tbOriShowKeys) do
		if v.tbSubs then
			table.sort(v.tbSubs, fnSort)	
			if version_tx and not Client:IsCloseIOSEntry() and not Sdk:IsPCVersion() and v.Name == "战力" then
				table.insert(v.tbSubs, {Name = "全区服战力", Key = "GlobalPowerRank", bSub = true});
			end
		end
	end

	self.tbOriShowKeys = tbOriShowKeys
	return tbOriShowKeys
end

RankBoard:ClientInit()

