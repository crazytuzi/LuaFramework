function model_zzbpuser(uid,data)
    local self = {
        uid=uid,
        score = 0,-- 当前获得的积分
        task={},--任务
        person={}, -- 个人积分领取奖励记录
        server={}, -- 全服积分领取奖励记录
        rank = 0,-- 是否领取个人积分排行榜奖励
        fserver = 0, -- 是否领取积分第一服务器奖励
        receive = 0,-- 是否接收过其他人送的奖励
        senduid = 0,-- 转赠的玩家
        tlog = {},-- 记录玩家每天各任务的积分
        updated_at=0,   
    }

    -- model保存之后 需要处理的数据
    local pending = {}

    -- userobjs 保存后 处理数据
    function self.saveAfter()  
        if next(pending) then
            -- writeLog('战资比拼更新跨服积分:'..self.uid..'nickname='..pending.nickname..'level='..pending.score..' score= '..pending.score,'zzbp') 
            -- 记录zid uid uname score groupid updated_at
            -- 更新跨服表数据
            local groupid = tonumber(pending.groupid)
            local senddata = {
                  groupid = groupid,
                  zid     = getZoneId(),
                  uid     = self.uid,
                  nickname  = pending.nickname,
                  level = pending.level,
                  score = pending.score,
                  updated_at = getClientTs(),
            }


            local http = require("socket.http")
            http.TIMEOUT= 5
            local crossrank = getConfig("config.crossrank")
            local url = "http://"..crossrank.httphost.."/tank-server/public/index.php/api/zzbp/zzbp?"

            local postdata = {action=1,params=json.encode(senddata)}
            local respbody = http.request(url,formPostData(postdata))
            respbody = json.decode(respbody)
         
            if respbody.ret ~= 0 then
                writeLog(json.encode(senddata),'zzbp_errorlog')
                return false
            else
                if type(pending.task)=='table' and next(pending.task) then
                    local redis = getRedis()
                    -- 记录全服每天各个任务获得积分数 后期给游戏做数据调整参考依据
                    local tscorekey = "zid."..getZoneId()..'zzbp'..pending.st..'tscore'
                    local tscore =json.decode(redis:get(tscorekey))
                    if type(tscore)~='table' then
                        tscore = {}
                    end

                    local zzbptaskscore = readRankfile('zzbptaskscore',pending.st)
                    if type(zzbptaskscore) ~= 'table' then
                        zzbptaskscore = {}
                    end

                    for k,v in pairs(pending.task) do
                        if type(tscore[k])~='table' then
                            tscore[k] = {}
                        end
                        if type(v)=='table' and next(v) then
                            for kv,val in pairs(v) do
                                tscore[k][kv] =val + (tonumber(tscore[k][kv]) or 0)
                                zzbptaskscore[kv] = (zzbptaskscore[kv] or 0) + val
                            end
                        end 
                    end
                       
                    redis:set(tscorekey,json.encode(tscore)) 
                    redis:expireat(tscorekey,getClientTs()+7*86400)

                    local zzbpfiledate = json.encode(zzbptaskscore)
                    writeActiveRankLog(zzbpfiledate,'zzbptaskscore',pending.st) -- 排行榜记录日志

                end
            end
            pending = {}
        end
    end

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
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end
          

        return data
    end

    -- 获取全服总积分
    function self.serverscore(cfg)
        local redis = getRedis()
        local cachekey = "zid."..getZoneId()..'zzbp'..cfg.groupid
        local score = tonumber(redis:get(cachekey)) or 0
        if score>0 then
            return score
        else
            local db = getDbo()
            local result = db:getRow("select sum(`score`) as total from zzbpuser")
            if type(result)~='table' then
                return 0
            end 

            local totalscore = result.total or 0
            redis:set(cachekey,totalscore) 
            redis:expireat(cachekey,getClientTs()+7*86400)
            return totalscore
        end
    end

    -- 更新玩家的积分 {level=mUserinfo.level,nickname=mUserinfo.nickname,day=day,score=score}
    function self.upscore(params,cfg,exparams)
        local day = exparams.day
        local score = exparams.score
        if score>0 then
            self.score = self.score + score

            -- 记录玩家每天各任务获得积分 分析数据用
            self.settlog(day,score,params.t)

            local redis = getRedis()
            local cachekey = "zid."..getZoneId()..'zzbp'..cfg.groupid
            redis:del(cachekey)

            -- save()之后需要处理的数据
            pending.groupid = cfg.groupid
            pending.nickname = exparams.nickname
            pending.level = exparams.level
            pending.score = self.score 

            if not pending.task  or type(pending.task)~='table' then
                pending.task = {}
            end

            if type(pending.task[day])~='table' then
                pending.task[day] = {}
            end
            pending.task[day][params.t] = (pending.task[day][params.t] or 0) + exparams.score
            pending.st = tonumber(cfg.st)  
        end

        return true
    end

    -- 计算玩家触发任务获得积分
    -- 每种任务如果结算完 数量有剩余 则需要保留
    function self.getScore(taskcfg,params)
        local score = 0
        if type(taskcfg.pa)=='number' then
            local num = self.task[params.t] or 0
            -- 资源值
            if params.t == 'f1' then
                for k,v in pairs(params.n) do
                    num = num + v
                end
            else
                num = num + params.n 
            end
            local n = math.floor(num/taskcfg.n)
            score = n*taskcfg.pa
         
            extra = num - taskcfg.n*n
            if extra >= 0 then
                self.task[params.t] = extra
            end
        else
            local len = #taskcfg.pa[1]
            -- 升级指挥中心和科技中心
            if table.contains({'f5','f6'},params.t) then
                local gid = 0

                for i=len,1,-1 do
                    if params.n>=taskcfg.pa[1][i] then
                        gid = i
                        break
                    end
                end
         
                if gid>0 then
                    score = taskcfg.pa[2][gid]
                end
        
            else
                local gid = 0
                -- 生产战舰/改装战舰/击杀海盗
                if table.contains({'f7','f8'},params.t) then
                    local cfg = getConfig('tank.' .. params.id)
                    for i=len,1,-1 do
                        if cfg.level>=taskcfg.pa[1][i] then
                            gid = i
                            break
                        end
                    end

                    writeLog('战资比拼f7,f8:uid='..self.uid..'t='..params.t..'id='..params.id..'num='..params.n,'zzbp')
                end

                -- 击杀海盗 
                if params.t == 'f9' then
                    for i=len,1,-1 do
                        if params.id >= taskcfg.pa[1][i] then
                            gid = i
                            break
                        end
                    end
                end

                -- 获得x个品质的超级装备
                if params.t == 'f10' then
                    local cfg = getConfig("superEquipListCfg.equipListCfg."..params.id)
                    for i=len,1,-1 do
                        if cfg.color>=taskcfg.pa[1][i] then
                            gid = i
                            break
                        end
                    end
                end

                -- 进行贸易护航N次 / 掠夺N次贸易护航
                if table.contains({'f12','f13'},params.t) then
                    for i=len,1,-1 do
                        if params.id >= taskcfg.pa[1][i] then
                            gid = i
                            break
                        end
                    end
                end

                -- 合成宝石
                if params.t == 'f14' then
                    if params.id then
                        local jid = tonumber(string.sub(params.id,2)) 
                        local lv = jid%10
                        if lv ==0 then
                            lv = 10
                        end
                        for i=len,1,-1 do
                            if lv >= taskcfg.pa[1][i] then
                                gid = i
                                break
                            end
                        end
                    end
                   
                end
          

                if gid>0 then
                    local num = params.n
                    local key = 'i'..gid
                    if type(self.task[params.t])=='table' then
                        num =num + (self.task[params.t][key] or 0)
                    end

                    local n = math.floor(num/taskcfg.n)
                    score = n*taskcfg.pa[2][gid]
                    extra = num - taskcfg.n*n
                    if extra >= 0 then
                        if type(self.task[params.t])~='table' then
                            self.task[params.t] = {}
                        end
                        self.task[params.t][key] = extra
                    end
                end
            end 
        end

        return score
       
    end

    -- 玩家每天各任务获得积分记录 
    -- day:哪一天
    -- score:获得积分
    -- t:任务
    function self.settlog(day,score,t)
        if type(self.tlog) ~= 'table' then
            self.tlog = {}
        end

        if type(self.tlog[day]) ~= 'table' then
            self.tlog[day] = {}
        end

        self.tlog[day][t] = (tonumber(self.tlog[day][t]) or 0) + score

    end

    return self
end