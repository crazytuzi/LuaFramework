function model_picstore(uid,data)
    local self = {
        uid=uid,
        p={},
	b={},
        a={},
        e={},
        updated_at=0,
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
            end
        end

	if self.b=='' then
            self.b={}
        end

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    -- 添加 头像 头像框 挂件 聊天气泡
    function self.addpic(pid)
    	if not self.checkpid(pid) then
    		return false
    	end
 		local subp=string.sub(pid,1,1)
    	if type(self[subp])~='table' then
    		self[subp]={}
    	end

    	if not table.contains(self[subp], pid) then
    		table.insert(self[subp],pid)
    	end
        return true
    end

    -- 检测类型是否正确
    function self.checkpid(pid)
        local subp=string.sub(pid,1,1)
        if not table.contains({"p","b","a","e"},subp) then
            return false
        end

        return true
    end   

    return self
end