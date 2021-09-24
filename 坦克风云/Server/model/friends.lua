function model_friends(uid,data)
    local self = {
        uid=uid,
        info={},
        updated_at=0,
    }



    local meta = {
        __index = function(tb, key)
            return rawget(tb,tostring(key)) or rawget(tb,'f'..key) or 0
        end
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




    return self
end 

