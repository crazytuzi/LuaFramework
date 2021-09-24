-- 装备

function model_equip(uid,data)
    local self = {
        uid = uid,
        e1=0,
        e2=0,
        e3=0,
        info={},
        last_at=0,
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
            end
        end

        return true
    end

    
    -- 添加物品
    function self.addResource(column,num)
        if self[column]~=nil then
            self[column]=self[column]+num
        end
        return true
    end
    -- 使用道具
    function self.useResource(data)
        if type(data)=='table' and next(data) then
            for k,v in pairs (data) do
                if self[k]-v <0 then
                    return  false
                end
                self[k]=self[k]-v
            end
            return true
        end 
        return false
     end 


    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        -- if type(v) == 'table'  then
                        --     if next(v) then data[k] = v end
                        -- elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        --end
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

    


    -----------------------------------------
    return self
end  