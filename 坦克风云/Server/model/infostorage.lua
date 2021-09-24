function model_infostorage(uid,data)
    local self = {
        uid = uid,
        info = {},
		updated_at = 0,
    }

   function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
                --删除过期活动信息
              
            end
        end

      
        for aname,ainfo in pairs(self.info or {}) do
            if type(ainfo)=='table' and ainfo.et then
                
                local ts = getClientTs()
                local expireTs = ts - 1296000
                if expireTs > ainfo.et then        
                    self.info[aname] = nil
                end
            end
        end

        return true
    end

    function self.toArray(format)
		local data = {}
		for k,v in pairs (self) do
			if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
				if format then
					if type(v) == 'table'  then
                        data[k] = v
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
				else
					data[k] = v
				end
			end
		end

		return data
	end

    -- 读取info
    function self.getInfo(key)
        local data = {}
        if type(self.info) ~= 'table' then self.info = {} end
		
		if not key then key = 'all' end
		if key == 'all' then
			for k,v in pairs(self.info) do
				data[k] = v
			end
		else
			if self.info[key] then
				data = self.info[key]
			end
		end

        return data
    end
	
	function self.setInfo(key,data)
		if type(self.info) ~= 'table' then self.info = {} end
		
		self.info[key] = data
	end
	
    return self
end	

