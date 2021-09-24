
--desc: 跨服战资比拼
--user: chenyunhe

function model_zzbp()
    local self = {
        groupid = 0,
        zones={},
        task={},
        gift={},
        st=0,
        et=0,
        updated_at = 0,
    }
    --  function self.bind()
    --     ptb:p('sdfsfa')
    --     local data = self.getCfg()
    --     if type(data) ~= 'table' then
    --         return false
    --     end
        
    --     for k,v in pairs (self) do
    --         local vType = type(v)
    --         if vType~="function" then
    --             if data[k] == nil then return false end
    --             if vType == 'number' then
    --                 self[k] = tonumber(data[k]) or data[k]
    --             else
    --                 self[k] = data[k]
    --             end
    --         end
    --     end

    --     return true
    -- end

    --获取活动配置
    function self.getCfg()
        local cfg = {}
        local db = getDbo()
        local result = db:getRow("select * from zzbp")
            
        if type(result)~='table' then
            return cfg
        end       
        return result 
    end


    -- 检测活动是否开启
    -- 返回值 是否开启，配置数据
    function self.check()
        local cfg = self.getCfg()
        if not next(cfg) then
            return false,{}
        end
     

        local ts = getClientTs()
        if ts>= tonumber(cfg.st) and ts <=tonumber(cfg.et) then
            return true,cfg
        end

        return false,cfg
    end

   
    -- 更新活动
    function self.upcfg(id,params)
        params.updated_at = getClientTs()    
        local db = getDbo()            
        local ret = db:update("zzbp",params,"id='".. (db.conn:escape(id) or 0) .. "'")        

        if ret and ret > 0 then
            return true
        end

        return false
    end

    -- 创建新活动数据
    function self.create(params)
        params.updated_at = getClientTs()    
        local db = getDbo()
        local ret = db:query("delete from zzbp")
        if ret then
            local flag = db:insert("zzbp",params)
            if flag and flag > 0 then
                return true
            end
        end

        return false
    end

    -- 清空当前服数据
    function self.cleandata()
        local db = getDbo()
        local ret = db:query("delete from zzbpuser")

        if not ret then
            writeLog('删除zzbpuser数据','zzbp_errorlog')
            return false
        end

        return true
    end

    -- 判断能都领取奖励
    function self.checkreceive(cfg)
        local ts = getClientTs()
        if ts>= tonumber(cfg.et)-86399-5400 and ts <=tonumber(cfg.et) then
            return true
        end

        return false
    end


    return self
end