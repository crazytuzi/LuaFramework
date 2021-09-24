function model_serverbattle()
    local self = {
        rkey = '',
        --所有比赛
        allinfo = {},
    }

    local privateBattleCfgs = {}

    function self.bind()
        local serverbattlecfgs = self.getValidserverbattlecfgs()
        if type(serverbattlecfgs) == 'table' then
            for k,v in pairs(serverbattlecfgs) do
                self[k] = v 
            end
            self.allinfo = serverbattlecfgs
        end
    end

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then              
                data[k] = v
            end
        end

        return data
    end
    --获取id的信息
    function self.getserverbattlecfg(btype,mtethod)

        local ts=getClientTs()
        local forwardNum = 7200
        
        local redis = getRedis()
        local key =self.rkey.."."..btype
        local serverbattlecfgs = redis:hgetall(key)

        if mtethod==1 or btype==6 then
            serverbattlecfgs=nil
        end
        if type(serverbattlecfgs) ~="table" or not(next(serverbattlecfgs))  then

            local db = getDbo()
            local result = db:getAllRows("select * from  serverbattlecfg where et > :ts and type=:type ",{ts=ts,type=btype})
           
            if result then

                serverbattlecfgs = result
                local et=0
                for k,v in pairs(result) do
                    redis:hmset(key,k,json.encode(v))
                    et  =tonumber(v.et)
                end
                redis:expire(key,et-ts)
            else
                return serverbattlecfgs
            end
        else
            for k,v in pairs(serverbattlecfgs) do
                serverbattlecfgs[k] = json.decode(v)  or v
            end    
        end       
        return serverbattlecfgs 
    end


    function self.getserverplatfrombattlecfg()
        local ts=getClientTs()
        local forwardNum = 7200
        local btype=4
        local redis = getRedis()
        local key =self.rkey.."."..btype
        local serverbattlecfgs =redis:hgetall(key)
        if type(serverbattlecfgs) ~="table" or not(next(serverbattlecfgs))  then
            local db = getDbo()
            local result = db:getRow("select * from  serverbattlecfg where et > :ts and type=:type ",{ts=ts,type=btype})
                
            if result and type(result)=='table' and next(result) then
                serverbattlecfgs = result
                serverbattlecfgs['bid']='b'..result['bid']
                local et=0
                for k,v in pairs(serverbattlecfgs) do
                    redis:hmset(key,k,json.encode(v))
                end
                et =tonumber(serverbattlecfgs.et)
                redis:expire(key,et-ts)
            else
                return serverbattlecfgs,0
            end
        else
            for k,v in pairs(serverbattlecfgs) do
                serverbattlecfgs[k] = json.decode(v)  or v
            end    
        end       
        return serverbattlecfgs,0 
    end

    function self.serverbattlecfgByid(id)
        local serverbattlecfgs = {}
        local ts=getClientTs()
        local db = getDbo()
        local result = db:getAllRows("select * from  serverbattlecfg where id =:id and et>:ts",{id=id,ts=ts})
            
        if result then
            serverbattlecfgs = result[1]
        end       
        return serverbattlecfgs 
    end
   

    function self.getValidserverbattlecfgs()    
        local ts = getClientTs()
 
        local serverbattlecfgs={}
        local db = getDbo()
        local result = db:getAllRows("select * from serverbattlecfg where   et > :currTs ",{currTs=ts})
            
        if next(result)  then
                serverbattlecfgs = result
        end
        
        return serverbattlecfgs 
    end

    -- 更新跨服战信息
    function self.setserverbattlecfg(id,params)

        if params.updated_at==nil then
            params.updated_at = getClientTs()
        end
          

        local db = getDbo()            
        local ret = db:update("serverbattlecfg",params,"id='".. (db.conn:escape(id) or 0) .. "'")    
        
        local deltype =params.type or 1 
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey.."."..deltype) == 1 then
                redis:del(self.rkey..".history."..deltype)
                return true
            end
            return true
        end
    end

    --清除缓存
    function self.clearBattleCache(deltype)
        local redis = getRedis()
        if redis:del(self.rkey.."."..deltype) == 1 then
            redis:del(self.rkey..".history."..deltype)
            return true
        end
        return true
    end

    function self.delserverbattle(id,btype)
        local db = getDbo()            
        local ret = db:query("delete  from serverbattlecfg  where id ="..id)     
        
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey.."."..btype) == 1 then
                redis:del(self.rkey..".history."..btype)
                return true
            end
            return true
        end
    end

    -- 创建新活动数据
    function self.createserverbattlecfg(params)
        params.updated_at = getClientTs()    

        local db = getDbo()
        local ret = db:insert("serverbattlecfg",params)
        if ret and ret > 0 then
            local redis = getRedis()
            if redis:del(self.rkey.."."..params.type) == 1 then
                redis:del(self.rkey..".history."..params.type)
                return true
            end
           return true
        end
    end

    function self.setRkey()
        local zoneid = 'z' .. getZoneId()
        self.rkey = zoneid .. ".serverbattlecfg"
    end

    -- loginAt 登陆时间
    function self.getTitleList(loginAt,uid)
        local data = {}
        local newserverbattlecfgNum = 0
        local ts = getClientTs()
        local serverbattlecfgCfg = getConfig("serverbattlecfg") 

        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'updated_at' and k~= 'rkey' then
                data[k] = {
                    sortId=v.sortId,
                    st=v.st,
                    et=v.et,                    
                }

                if tonumber(v.type) == 10 then
                    data[k].data = serverbattlecfgCfg[k].data
                end

                if (tonumber(v.st) or 0) > loginAt and tonumber(v.st) <= ts then
                    newserverbattlecfgNum = newserverbattlecfgNum + 1
                end
            end
        end

        -- if uid == 1009218 or uid == 1003172 then
        --     data.fbReward = {
        --         st = 1394957400,
        --         et = 1395287400,
        --     }
        -- end

        return data,newserverbattlecfgNum
    end

    --获取跨服战信息
    --
    --return table
    function self.getAcrossBattleInfoTmp()

        local result = {}
        local battleInfo = self.getserverbattlecfg(2)
        if not next(battleInfo) then
            return result, -20001
        end
        local tmpBattleInfo = {}
        for _, v in pairs(battleInfo) do
            tmpBattleInfo = v
            tmpBattleInfo.bid='b'..tmpBattleInfo.bid
        end
        result = tmpBattleInfo
        return result
    end

    -- 获取世界大战的信息
    function self.getWorldWarBattleInfo()
        local result = {}
        local tmpBattleInfo={}
        local battleInfo = self.getserverbattlecfg(3)
        if not next(battleInfo) then
            return result, -22001 
        end
        for k,v in pairs(battleInfo) do
            tmpBattleInfo['bid'] ='b'..v['bid']
            tmpBattleInfo['round']=1
            tmpBattleInfo['st'] = v['st']
            tmpBattleInfo['et'] = v['et']
            tmpBattleInfo['servers'] = json.decode(v['servers'])
        end
        
        return tmpBattleInfo,0
     end 

     function self.getserverareabattlecfg()
        local result = {}
        local tmpBattleInfo={}
        local battleInfo = self.getserverbattlecfg(5)
        if not next(battleInfo) then
            return result, -22001 
        end
        for k,v in pairs(battleInfo) do
            tmpBattleInfo['bid'] ='b'..v['bid']
            tmpBattleInfo['round']=1
            tmpBattleInfo['st'] = v['st']
            tmpBattleInfo['et'] = v['et']
            tmpBattleInfo['servers'] = json.decode(v['servers'])
        end
        
        return tmpBattleInfo,0
     end

    function self.getAcrossBattleInfo()

        local result = {}
        local battleInfo = self.getserverbattlecfg(2)
        if not next(battleInfo) then
            return result, -20001
        end

        local tmpBattleInfo = {}
        for _, v in pairs(battleInfo) do
            tmpBattleInfo = v
        end
        local nowTime = getClientTs()
        local roundBattle = {}
        local st = tonumber(tmpBattleInfo.st)
        local et = 0
        local sevCfg = getConfig("serverWarTeamCfg")
        for i=1, tonumber(tmpBattleInfo.round) do
            local weelTs = getWeeTs(st)
            local diffTime = st - weelTs
            local plusTime = 0
            if diffTime > (sevCfg.startBattleTs[1][1] * 3600 + sevCfg.startBattleTs[1][2] * 60) then
                plusTime = 24 * 3600
            end
            if i ~= 1 then
                st = weelTs +  (sevCfg.preparetime + sevCfg.signuptime + sevCfg.durationtime + tmpBattleInfo.gap) * 24 * 3600 + plusTime
            end
            et = st + (sevCfg.preparetime + sevCfg.signuptime + sevCfg.durationtime) * 24 * 3600
            if nowTime >= st and nowTime <= et then
                roundBattle['round'] = i
                roundBattle['st'] = st
                roundBattle['et'] = et
                break
            end
        end

        if not next(roundBattle) then
            return roundBattle, -21102
        end

        -- tmpBattleInfo.bid =  'b'..tmpBattleInfo.bid..roundBattle['round']
        tmpBattleInfo.bid =  'b'..tmpBattleInfo.bid
        tmpBattleInfo.st = roundBattle['st']
        tmpBattleInfo.et = roundBattle['et']
        tmpBattleInfo.prefixBid = tmpBattleInfo.bid

        return tmpBattleInfo,0
    end

    --得到正在进行第几轮比赛
    --
    --params int type 类型1个人， 类型2是军团跨服
    --params int time 时间戳
    --
    --return table
    function self.getRoundInfo(type, nowTime)

        local roundBattle = {}
        if not type then
            type = 1
        end
        local battleInfo = self.getserverbattlecfg(type)
        if not next(battleInfo) then
            return roundBattle, -20001
        end
        local tmpBattleInfo = {}
        for _, v in pairs(battleInfo) do
            tmpBattleInfo = v
        end
        if not nowTime then
            nowTime = getClientTs()
        end
        local st = tonumber(tmpBattleInfo.st)
        local et = 0
        local sevCfg = getConfig("serverWarPersonalCfg")
        for i=1, tonumber(tmpBattleInfo.round) do
            local weelTs = getWeeTs(st)
            local diffTime = st - weelTs
            local plusTime = 0
            if diffTime > (sevCfg.startBattleTs[1][1] * 3600 + sevCfg.startBattleTs[1][2] * 60) then
                plusTime = 24 * 3600
            end
            if i ~= 1 then
                st = weelTs +  (sevCfg.preparetime + sevCfg.durationtime + tmpBattleInfo.gap) * 24 * 3600 + plusTime
            end
            et = st + (sevCfg.preparetime + sevCfg.durationtime) * 24 * 3600
            if nowTime >= st and nowTime <= et then
                roundBattle['round'] = i
                roundBattle['st'] = st
                roundBattle['et'] = et
                break;
            end
        end

        if not next(roundBattle) then
            return roundBattle, -20002
        end

        for item, info in pairs(tmpBattleInfo) do
            if item ~='st' and item ~= 'et' and item ~= 'gap' and item ~= 'round' then
                roundBattle[item] = info
                if item == 'reward' then
                    roundBattle[item] = json.decode(info)
                end
            end
        end

        return roundBattle, 0
    end
    
    --获取id的信息
    function self.getserverbattlehistorycfg(btype,mtethod)
        local ts=getClientTs()
        
        local redis = getRedis()
        local key =self.rkey..".history."..btype
        local serverbattlecfgs = json.decode(redis:get(key))
        
        if mtethod==1 then
            serverbattlecfgs=nil
        end
        
        if type(serverbattlecfgs) ~="table" or not(next(serverbattlecfgs))  then
            local db = getDbo()
            local result = db:getRow("select * from serverbattlecfg where type=:type order by et desc",{ts=ts,type=btype})
                
            if result then
                serverbattlecfgs = result
                redis:set(key,json.encode(serverbattlecfgs))
            else
                return serverbattlecfgs
            end
        else
            for k,v in pairs(serverbattlecfgs) do
                serverbattlecfgs[k] = json.decode(v)  or v
            end    
        end       
        return serverbattlecfgs 
    end


    -- 军团跨服战或者怒海争锋 不能加入或者退出军团
    -- btype 1 退出 2 加入
    function self.joinorquit(btype)
        local ts = getClientTs()
        local amMatchinfo, code = self.getAcrossBattleInfo()
        if code == 0 and next(amMatchinfo) then
            if ts > tonumber(amMatchinfo.st) and ts < tonumber(amMatchinfo.et) then
                if btype==1 then
                    return -27012
                else
                    return -27013
                end   
            end
        end

        -- 5 区域跨服战
        local anMatchinfo,code = self.getserverareabattlecfg()
        if code == 0 and next(anMatchinfo) then
            if ts > tonumber(anMatchinfo.st) and ts < tonumber(anMatchinfo.et) then
                if btype == 1 then
                    return -27014
                else
                    return -27015
                end
            end
        end

        return 0
    end

    -- 远洋征战  flag为true或者false 
    -- 当flag为true时只是用于登陆给客户端显示在开启或者即将开启的配置
    function self.getOceanExpeditionInfo(flag)
        local battleType = 6
        local code = 0

        if privateBattleCfgs[battleType] then
            return privateBattleCfgs[battleType], code
        end

        local result = {}
        local battleInfo = self.getserverbattlecfg(battleType)
        if not next(battleInfo) then
            code = -27022
            privateBattleCfgs[battleType] = result
            return privateBattleCfgs[battleType], code
        end
   
        local tmpBattleInfo = {}
        for _, v in pairs(battleInfo) do
            tmpBattleInfo = v
        end

        local nowTime = getClientTs()
        local st = tonumber(tmpBattleInfo.st)
        local et = tonumber(tmpBattleInfo.et)

        -- 只有登录时候用flag
        if flag then
            result.st = st
            result.et = et
            return result,0
        end
   
        if nowTime>=st and nowTime<=et then
            result.id = tonumber(tmpBattleInfo.id)
            result.st = st
            result.et = et
            result.bid = tonumber(tmpBattleInfo.bid)
            result.info = json.decode(tmpBattleInfo.info) or {}
            result.servers = json.decode(tmpBattleInfo.servers) or {}
            result.ext1 = tonumber(tmpBattleInfo.ext1)
            privateBattleCfgs[battleType] = result
        else
            -- TODO ???
            -- privateBattleCfgs[battleType] = tmpBattleInfo
            privateBattleCfgs[battleType] = {}
            code = -27022
        end

        return privateBattleCfgs[battleType], code
    end

    -- 伟大航线
    function self.getGreatRouteInfo(flag)
        local battleType = 7
        local code = 0
        
        if privateBattleCfgs[battleType] then
            return privateBattleCfgs[battleType], code
        end

        local result = {}
        local battleInfo = self.getserverbattlecfg(battleType)
        if not next(battleInfo) then
            code = -27022
            privateBattleCfgs[battleType] = result
            return privateBattleCfgs[battleType], code
        end
   
        local tmpBattleInfo = {}
        for _, v in pairs(battleInfo) do
            tmpBattleInfo = v
        end

        local nowTime = getClientTs()
        local st = tonumber(tmpBattleInfo.st)
        local et = tonumber(tmpBattleInfo.et)

        -- 只有登录时候用flag
        if flag then
            result.st = st
            result.et = et
            return result,0
        end
   
        if nowTime>=st and nowTime<=et then
            result.id = tonumber(tmpBattleInfo.id)
            result.st = st
            result.et = et
            result.bid = tonumber(tmpBattleInfo.bid)
            result.info = json.decode(tmpBattleInfo.info) or {}
            result.servers = json.decode(tmpBattleInfo.servers) or {}
            result.ext1 = tonumber(tmpBattleInfo.ext1)
            privateBattleCfgs[battleType] = result
        else
            -- TODO ???
            -- privateBattleCfgs[battleType] = tmpBattleInfo
            privateBattleCfgs[battleType] = {}
            code = -27022
        end

        return privateBattleCfgs[battleType], code
    end

    self.setRkey()
    --self.bind()

    return self

end