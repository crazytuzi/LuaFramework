GgModel = BaseClass(LuaModel)

function GgModel:__init( ... )
end

function GgModel:GetPanelTabData()
	local rtnTabData = {}
	local cfgData = GetCfgData("system"):Get(5)
		if cfgData then
			cfgData = cfgData.data
			for i = 1, #cfgData do
				local cfgInfo = StringSplit(cfgData[i], "_")
				table.insert(rtnTabData, {cfgInfo[1], cfgInfo[2]})
			end
		end
	return rtnTabData
end

function GgModel:GetInstance()
	if GgModel.inst == nil then
		GgModel.inst = GgModel.New()
	end
	return GgModel.inst
end

function GgModel:__delete()
	GgModel.inst=nil
	day = nil
end

--设置公共打开记录
--一天只打开一次
function GgModel:SetNoticeOpenRecord()
	DataMgr.WriteData(GgConst.OpenRecordKey , {time = os.date("%x")})
end

--获取公告打开记录
function GgModel:GetNoticeOpenRecord()
	return DataMgr.ReadData(GgConst.OpenRecordKey , {})
end

--是否可以打开公共（一天只打开一次）
function GgModel:IsCanOpenNotice()
	local openRecord = self:GetNoticeOpenRecord()
	if not TableIsEmpty(openRecord) then
		local curDate = os.date("%x")
		local curDataSplitList = StringSplit(curDate , "/") --“月/日/年“
		local recordDate = openRecord.time
		local recordDateSplitList = StringSplit(recordDate , "/") --“月/日/年“
		for index = 1 , #curDataSplitList do
			local v = recordDateSplitList[index]
			if v and tonumber(curDataSplitList[index]) > tonumber(v) then
				return true
			end
		end
	else
		return true
	end
	return false
end