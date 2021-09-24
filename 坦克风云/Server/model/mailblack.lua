--
-- 邮件黑名单
-- User: luoning
-- Date: 14-10-30
-- Time: 下午4:44
--
function model_mailblack(uid,data)

    local self = {
        uid = uid,
        info= {},
        updated_at = 0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" and k ~= 'config' then
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
            if type(v)~="function" and k~= 'uid'  then
                if format then
                    if type(v) == 'table'  then
                        data[k] = v
                        -- if next(v) then data[k] = v end
                    elseif v~= '0' and v~='' then
                        data[k] = v
                    end
                else
                    data[k] = v
                end
            end
        end
        return data
    end

    -- 屏蔽用户
    function self.addBlackList(uid)
        local flag=table.contains(self.info, uid)
        if flag then
            return false
        end
        if type(self.info)=='table' then
            table.insert(self.info,uid)
            return true
        end
        return false
    end
    -- 移除屏蔽列表
    function self.removeBlackList(uid)
        if type(self.info)=='table' and  next(self.info) then
            for k,v in pairs(self.info) do
                if tonumber(v)==uid then
                    table.remove(self.info,k)
                    return true
                end
            end
        end
        return false
    end




    self.bind(data)
    --------------------------------------------------------------
    return self
end

