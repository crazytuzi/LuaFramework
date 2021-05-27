RecycleYBData = RecycleYBData or BaseClass()

function RecycleYBData:__init()
	if RecycleYBData.Instance then
		ErrorLog("[RecycleYBData]:Attempt to create singleton twice!")
	end

	RecycleYBData.Instance = self
	self.recycleinfo= {}
	self:InitOpenRecovercfg()
	self.recyjournal = {}
	self.recyprojournal = {}
	self.is_first_login = true
end

function RecycleYBData:__delete()
	RecycleYBData.Instance = nil
end

function RecycleYBData:InitOpenRecovercfg()
	self.recycleinfo= {}

	local cfg = OpenServiceAcitivityData.GetServerCfg(OPEN_SERVER_CFGS_NAME[8])
	if cfg == nil then return end
	for i,v in ipairs(cfg.Awards) do
		 table.insert(self.recycleinfo, {openDay =v.openDay  ,endDay =v.endDay  , idList = v.idList, desc = v.desc, showAwards = v.showAwards, state = 0 ,rest_cnt = 0,re_index = i})
	end
end

function RecycleYBData:RecycleYBProtocolInfo(protocol)
	for k,v in pairs(protocol.award_length) do
		self.recycleinfo[k].state = v.state  
		self.recycleinfo[k].rest_cnt = v.rest_cnt
		
	end	
	local data = protocol.award_prolength	
	for i = #data, 1, -1 do
		table.insert(self.recyprojournal,1, data[i])
	end
	local over_num = #self.recyprojournal - 3
	for i = 1 ,over_num , 1 do
		table.remove(self.recyprojournal, #self.recyprojournal)
	end
	local cur_recyprojournal = #self.recyprojournal
	data = protocol.describe_len
	for i = #data,1 ,-1 do
		table.insert(self.recyjournal,1,data[i])
	end
	local over_describe = #self.recyjournal - (10 - cur_recyprojournal)
	for i=1,over_describe , 1 do
		table.remove(self.recyjournal,#self.recyjournal)
	end
end
function RecycleYBData:CurRecycleData()
	return self.recycleinfo
end
function RecycleYBData:GetJournal()
	local journal = {}
	for i,v in ipairs(self.recyprojournal) do
		table.insert(journal,v)
	end
	for i,v in ipairs(self.recyjournal) do
		table.insert(journal,v)
	end
	return journal
end

function RecycleYBData:ProJournalNum()
	return #self.recyprojournal
end
function RecycleYBData:GetBoolShowEffect()
	local num = 0
	local cur_data = {}
	local opsever_time = OtherData.Instance:GetOpenServerDays()
	for i,v in ipairs(self.recycleinfo) do
		if self.recycleinfo[i].openDay ~= nil and self.recycleinfo[i].endDay ~= nil and self.recycleinfo[i].endDay >= opsever_time then
			table.insert( cur_data, self.recycleinfo[i] )
		elseif self.recycleinfo[i].openDay == nil and self.recycleinfo[i].endDay == nil  then
			table.insert( cur_data, self.recycleinfo[i] )
		end
	end

	for i,v in ipairs(cur_data) do	
		if v.rest_cnt ~= 0 and v.state ~= 2 then
		   	for i1,v1 in ipairs(v.idList) do
		   		local is_hasitem = ItemData.Instance:GetItem(v1)
		   		if is_hasitem then
		   		 	num =1
		   		 	break
		   		 end
		   	end
	   end
	   	if num > 0 then
	   		break
	   	end
	end
	
	return num 
end
function RecycleYBData:RecycleYBOpen()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local cfg = OpenServiceAcitivityData.GetServerCfg(OPEN_SERVER_CFGS_NAME[8])
	return OtherData.Instance:GetOpenServerDays() <= cfg.endDay and level >= cfg.OpenLevel

end