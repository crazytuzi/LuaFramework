--
-- 发布远洋征战
-- chenyunhe
-- 
local function api_admin_setoceanexpedition(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
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

        local oecfg = getConfig("oceanExpedition")
        local sn = #servers
        local days = oecfg.rewardTime
        if sn<=2 then
            days = oecfg.rewardTime - 2
        elseif sn<=4 then
            days = oecfg.rewardTime - 1
        end

        local et = st + days * 86400-1
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()

        local oceaninfo,code = mServerbattle.getOceanExpeditionInfo()
        if code == 0 and next(oceaninfo) then
            response.ret = -101
            response.data.error = 'battle open'
            return response
        end


        local mOceanMatch = getModelObjs("oceanmatches")
        -- 设置加士气的活动
        if not mOceanMatch.setactive(st,bid) then
            response.ret = -100
            response.data.error = 'active failed'
            return response
        end
        local sflag =  mOceanMatch.startWar(bid,st,et,servers)
        if not sflag then
            response.data.error = 'start error'
            return response
        end

        local battleinfo = {
            bid = bid,
            st = st,
            et = et,
            servers = cfg.servers,
            type = 6,
            info = {},---此处必须为空table!!!!!
        }

        -- 没预热期 直接生成快照 否则通过定时脚本生成 cron.oceanexfcrank
        if oecfg.proTime==0 then
            -- 生成战力排行榜快照
            mOceanMatch.ranksnap(st,et)
        end


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
        local bid = request.params.bid
        local ts = getClientTs()
        if not bid then
            response.ret = -102
            return response
        end
   
        local mOceanMatch = getModelObjs("oceanmatches",bid)
      
        if not mOceanMatch then
            response.ret = -1
            return response
        end
        local spflag = mOceanMatch.stopWar(bid)
        if not spflag then
            response.ret = -101
            response.data.error = 'stop error'
           return response
        end

        if not mOceanMatch.setactive(0,bid) then
            response.ret = -100
            response.data.error = 'active failed'
            return response
        end

        if mOceanMatch then
            mOceanMatch.st = 0
            mOceanMatch.et = 0
            
            if not mOceanMatch.save() then
                response.ret = -1
                return response
            end
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.getinfo()
        local ts = getClientTs()
        local db = getDbo()
        local result = db:getRow("select bid,st,et,servers from serverbattlecfg where type=6 and et>"..ts.." limit 1")
        local r = {}

        local mOceanMatch = getModelObjs("oceanmatches")
        local oecfg = getConfig("oceanExpedition")
        if type(result)=='table' and next(result) then
            r.st = tonumber(result.st)
            r.et = tonumber(result.et)
            result.servers = json.decode(result.servers)
            r.stage = -1
            if ts>r.st then
                for i=0,5 do
                    local flag = mOceanMatch['isstage'..i](ts,r.st,oecfg,result)
                    if flag then
                        r.stage = i
                        break
                    end
                end
            end
            r.bid = result.bid     
            r.servers = result.servers
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
        local result = db:getRow("select bid,st,et,servers from serverbattlecfg where type=6 and et>"..ts.." limit 1")
        if type(result)=='table' and next(result) then
            return false
        end

        return true
    end

    -- 更新
    function self.action_upscore(request)
        local response = self.response
        local uid = request.uid
        local score = tonumber(request.params.score) or 0

        if not uid or score<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'oceanexpedition'})
        local mOcean = uobjs.getModel('oceanexpedition')
        mOcean.score = score

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end   

        return response
    end

    -- 查询参与玩家数据
    function self.action_getplayers(request)
        local response = self.response
        local uid = request.params.uid
        local zid = getZoneId()
        local info = self.getinfo()

        local list = {}
        if next(info) then
            local bid = info.bid
            local result = {}
            local db = getDbo()
            if uid then
                result = db:getAllRows(string.format("select uid,nickname,score from oceanexpedition where bid="..bid.." and uid="..uid.." order by fc desc"))
            else
                result = db:getAllRows(string.format("select uid,nickname,score from oceanexpedition where bid="..bid.." order by fc desc"))
            end
       
            if next(result) then
                for k,v in pairs(result) do
                    v.zid = zid
                    v.stage = info.stage or -1
                    table.insert(list,v)
                end
            end
        end
        
        response.data.list = list
        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- TODO
    -- function self.action_setact()
    --     local response = self.response
    --     local st = 1534521600
    --     local bid=1822
    --     local mOceanMatch = getModelObjs("oceanmatches")
    --     -- 设置加士气的活动
    --     if not mOceanMatch.setactive(st,bid) then
    --         response.ret = -100
    --         response.data.error = 'active failed'
    --         return response
    --     end

    --     response.ret = 0
    --     response.msg = 'success'

    --     return response
    -- end
   
    return self
end

return api_admin_setoceanexpedition