function model_rewardcenter()
	local self = {}
	
	function self.addReward(key,data)
		local db = getDbo()
		local n = db:insert('rewardcenter',data)
		local ret = (tonumber(n) or 0) > 0 

		if not ret then
			local logstr = getDateByTimeZone(nil,"%Y-%m-%d %H:%M:%S").. '.' .. (db:getQueryString() or '') ..'|error:'.. (db:getError() or '') .. '|ret:' .. (n or '')  
			writeLog('rewardcenter.addRward failed:' .. logstr,'rewardcenter')
		else
            local ts = getClientTs()
			local uid = data.uid or 0
			local total = self.getRewardNum(uid)
            local rtime
            local rewardSt = tonumber(data.st)
            if ts < rewardSt then
                rtime = ts + (rewardSt - ts) + 30
            end
			regSendMsg(uid,'rewardcenter.upnum.push',{total=total,rtime=rtime})
		end

		return ret
	end
	
	function self.getRewardNum(uid)
		local db = getDbo()
		local ts = getClientTs()
		local total = db:getRow("select count(*) as num from rewardcenter where uid = " .. uid .. " and st <= " .. ts .. " and et >= " .. ts .. " and  status = 0").num or 0
		
		return total
	end
	
	function self.getRewardList(uid,start,num)
		local start = start or 0
		local ts = getClientTs()
		local list = {}
		local db = getDbo()
		local result = {}
		local total = self.getRewardNum(uid)
		
		if not num then
			result = db:getAllRows("select id,type,title,st,et,info,reward from rewardcenter where uid = " .. uid .. " and  status = 0 order by et") -- 按发送时间降序
		else
			result = db:getAllRows("select id,type,title,st,et,info,reward from rewardcenter where uid = " .. uid .. " and st <= " .. ts .. " and et >= " .. ts .. " and status = 0 order by et limit " .. start .. ",".. num)
		end

		if result and type(result) == 'table' then
			local count = #result
			for i=1,count do
				local item = {
					id = result[i].id,
					type = result[i].type,
					title = result[i].title,
					st = result[i].st,
					et = result[i].et,
					info = result[i].info,
					reward = formatReward(json.decode(result[i].reward) or {}),
				}
				table.insert(list,item)
			end
		end

		return total,list
	end
    
    function self.getRewardListAllInfo(uid,start,num)
		local start = start or 0
		local ts = getClientTs()
		local list = {}
		local db = getDbo()
		local result = {}
		local total = self.getRewardNum(uid)
		
		if not num then
			result = db:getAllRows("select * from rewardcenter where uid = " .. uid .. "  order by et") -- 按发送时间降序
		else
			result = db:getAllRows("select * from rewardcenter where uid = " .. uid .. "  order by et limit " .. start .. ",".. num)
		end

		if result and type(result) == 'table' then
			local count = #result
			for i=1,count do
				local item = {
					id = result[i].id,
					type = result[i].type,
					title = result[i].title,
					st = result[i].st,
					et = result[i].et,
					status = result[i].status,
					info = result[i].info,
					reward = formatReward(json.decode(result[i].reward) or {}),
                    updated_at = result[i].updated_at
				}
				table.insert(list,item)
			end
		end

		return total,list
	end
	
	function self.getIdsQueryString(ids)
		local querystring = ""
		
		for i,v in pairs(ids) do
			querystring = querystring .. "'" .. v .. "'," 
		end
		
		querystring = string.sub(querystring,1,-2) or ''
		
		return querystring
	end
	
	function self.getReward(ids)
		if not ids or type(ids) ~= 'table' then
			return {}
		end

		local list = {}
		local db = getDbo()
		local ids = self.getIdsQueryString(ids)
		local result = db:getAllRows("select id,type,uid,title,st,et,info,reward from rewardcenter where id in ("..ids..") and `status` = 0 ") -- 按发送时间降序

		if result and type(result) == 'table' then
			local num = #result
			for i=1,num do
				local item = {
					id = result[i].id,
					type = result[i].type,
					uid = result[i].uid,
					title = result[i].title,
					st = result[i].st,
					et = result[i].et,
					info = result[i].info,
					reward = result[i].reward,
				}
				
				-- table.insert(list,item)
				if not list[result[i].id] then
					list[result[i].id] = item
				end
			end
		end

		return list
	end
	
	function self.receiveReward(id,uid)
		local db = getDbo()
		local n = db:update('rewardcenter',{status=1,updated_at=getClientTs()}," id = '" .. id .. "' and uid = " .. uid .. " ")
		local ret = (tonumber(n) or 0) > 0 
		
		return ret
	end
	
	function self.delExpireReward(expire)
		local db = getDbo()
		local expire = expire or 86400*5
		
        db:query("DELETE FROM rewardcenter WHERE (et + "..expire..") < UNIX_TIMESTAMP()")
	end

	return self
end