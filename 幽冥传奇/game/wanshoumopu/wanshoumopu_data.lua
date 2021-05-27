WanShouMoPuData = WanShouMoPuData or BaseClass()

WanShouTypeEnum = 
{
	1,  ---万兽
	2,	---万魔
}

function WanShouMoPuData:__init()
	if WanShouMoPuData.Instance then
		ErrorLog("[WanShouMoPuData]:Attempt to create singleton twice!")
	end
	WanShouMoPuData.Instance = self

	self.page_infos = {}
	for k,v in ipairs(WanShouTypeEnum) do
		self.page_infos[k] = self:InitWanShouMoPuData(v)
	end	
	self.finish_task = 0
end

function WanShouMoPuData:__delete()
	WanShouMoPuData.Instance = nil
end


function WanShouMoPuData:InitWanShouMoPuData(type)
	local cfg_data = {}
	for k,v in ipairs(WanShouMoPuConfig) do
		if v.bossgroupid == type then
			table.insert(cfg_data,{consume = v.consume, level = v.level ,award = v.award, bossId = v.bossId, posInfo  = v.posInfo, tele_id= v.teleId, is_finish = 0 , index = k, type = v.bossgroupid})
		end
	end
	return cfg_data
end

function WanShouMoPuData:GetWanshouDataByType(type)
	return self.page_infos[type]
end	


function WanShouMoPuData:SetInfo(protocol)
	self.finish_task = protocol.finish_task
	for _, v in pairs(self.page_infos) do
		for _, v1 in pairs(v) do
			if v1.index < protocol.finish_task then
				v1.is_finish = 1
				break
			end	
		end	
	end
	-- local function sort_func()
	-- 	return function(a, b)
	-- 		if a.is_finish ~= b.is_finish  then
	-- 			return a.is_finish < b.is_finish 
	-- 		else
	-- 			return a.index < b.index
	-- 		end	
	-- 	end
	-- end
	-- for i = 1, 2 do
	-- 	table.sort(self.page_infos[i], sort_func())
	-- end
end

function WanShouMoPuData:GetTime()
	return self.finish_task
end

