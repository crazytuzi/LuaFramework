function model_userexpand(uid,data)
    local self = {
        uid = uid,
        uhead = {},
        utitle = {},
        skyladder = {},
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

    function self.getUnLockHead()
        local data = {}
        if type(self.uhead) ~= 'table' then self.uhead = {} end

        return self.uhead
    end
	
	function self.setUnLockHead(data)
		if type(self.uhead) ~= 'table' then self.uhead = {} end
		-- self.uhead[tostring(data)] = data
		table.insert(self.uhead,data)
	end
	
	function self.getUnLockTitle()
        local data = {}
        if type(self.utitle) ~= 'table' then self.utitle = {} end

        return self.utitle
    end
	
	function self.setUnLockTitle(data)
		if type(self.utitle) ~= 'table' then self.utitle = {} end
		
		table.insert(self.utitle,data)
	end

    function self.getMySkyladderData()
        local data = {}
        if type(self.skyladder) ~= 'table' then self.skyladder = {} end
        
        if not self.skyladder.cubid then
            self.skyladder.cubid = 0
        end
        
        if not self.skyladder.lsbid then
            self.skyladder.lsbid = 0
        end
        
        if not self.skyladder.curank then
            self.skyladder.curank = 0
        end
        
        if not self.skyladder.lsrank then
            self.skyladder.lsrank = 0
        end
        
        return self.skyladder
    end
    
    function self.setMySkyladderData(data)
		if type(self.skyladder) ~= 'table' then self.skyladder = {} end
		
        self.skyladder = data
	end
	
    return self
end	

