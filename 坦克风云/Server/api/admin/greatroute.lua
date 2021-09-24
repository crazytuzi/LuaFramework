--
-- 伟大航线,管理工具接口
-- hwm
-- 
local function api_admin_greatroute(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    local BTYPE = 7

    -- 发布
    function self.action_set(request)
        local response = self.response
        local cfg = request.params
        if type(cfg)~='table' or not next(cfg) then
            response.ret = -102
            return response
        end

        local bid = tonumber(cfg.bid)
        local st = getWeeTs(tonumber(cfg.st))
        local servers = {}
        for k,v in pairs(cfg.servers) do
            table.insert(servers,tonumber(v))
        end

        if not self.checkset(st) then
            response.ret = -100
            return response
        end

        if bid<=0 or type(servers)~='table' or not next(servers) then
            response.ret = -102
            return response
        end

        local et = st + getConfig("greatRoute").main.totalTime * 86400 -1

        local mServerbattle = loadFuncModel("serverbattle")
        local matchInfo,code = mServerbattle.getGreatRouteInfo()
        if code == 0 and next(matchInfo) then
            response.ret = -101
            response.data.error = 'battle open'
            return response
        end

        local battleinfo = {
            bid = bid,
            st = st,
            et = et,
            servers = servers,
            type = BTYPE,
            info = {},---此处必须为空table!!!!!
        }

        local ret = mServerbattle.createserverbattlecfg(battleinfo)   
        if ret then 
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 根据bid关闭对应配置
    function self.action_close(request)
        local response = self.response
        local bid = tonumber(request.params.bid)
        local ts = getClientTs()
        if not bid then
            response.ret = -102
            return response
        end

        local mServerbattle = loadFuncModel("serverbattle")
        local matchInfo,code = mServerbattle.getGreatRouteInfo()
           
        if not matchInfo or not matchInfo.id or matchInfo.bid ~= bid then
            response.ret = -1
            return response
        end

        if not mServerbattle.setserverbattlecfg(matchInfo.id,{st=0,et=0,type=BTYPE}) then
            response.ret = -1
            return response
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.getinfo()
        local ts = getClientTs()
        local db = getDbo()
        local result = db:getRow("select bid,st,et,servers from serverbattlecfg where type=:btype and et> :ts limit 1",{btype=BTYPE,ts=ts})

        local r = {}
        if type(result)=='table' and next(result) then
            r.bid = result.bid   
            r.st = tonumber(result.st)
            r.et = tonumber(result.et)
            r.servers = json.decode(result.servers)
            r.stage = getModelObjs("agreatroute").getStage(r.st) or -1
        end

        return r
    end

    -- 查看  
    function self.action_view(request)
        local response = self.response
        response.data.info = self.getinfo()
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 能否配置
    function self.checkset(ts)
        local db = getDbo()
        local result = db:getRow("select bid,st,et,servers from serverbattlecfg where type=:btype and et> :ts limit 1",{btype=BTYPE,ts=ts})
        if type(result)=='table' and next(result) then
            return false
        end

        return true
    end
   
    return self
end

return api_admin_greatroute