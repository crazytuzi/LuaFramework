--
-- desc:  拼多多
-- user: guohaojie
--

local function api_active_pdd(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        -- st =1993639726,
        aname = 'pdd',
        st = 0,
        pageSize = 10,

    }

    self._cronApi = {
        ["action_check"] = true,
    }

     -- 缓存key
    local function getCacheKey(flag)
        return getActiveCacheKey(self.aname,flag,self.st)
    end

    -- 获取订单排行
    local function getOrderRank(orderId)
        local cacheKey = getCacheKey("rank")
        local redis = getRedis()
        local rank = redis:zrevrank(cacheKey,orderId)
        if rank then 
            return tonumber(rank) + 1
        end
    end 

    -- 获取订单所在页
    -- 受pageSize影响
    local function getOrderPage(orderId)
        local rank = getOrderRank(orderId)
        if rank then
            local rowIndex = rank % self.pageSize
            if rowIndex == 0 then 
                rowIndex = self.pageSize 
            end
            return math.ceil(rank / self.pageSize), rowIndex

        end
    end

    -- 订单数据入库
    -- return orderId | nil
    local function setOrder2db(orderData)
        local db = getDbo()
        if db:insert("active_pdd",orderData) then
            return db:getlastautoid()
        end
    end

    --返回数据
    function self.rtdata(request)
        local orderkey = request["key"]
        local failorder={}

        for key,val in pairs(request["uids"]) do
            local get,uobjs = pcall(getUserObjs,val)

            if get  then
                local mUseractive = uobjs.getModel('useractive') 
                if not table.contains(mUseractive.info[self.aname].cdt["bykeys"],orderkey) and not table.contains(mUseractive.info[self.aname].cdt["mykeys"],orderkey) then
                    mUseractive.info[self.aname].ob[request["id"]]=mUseractive.info[self.aname].ob[request["id"]]+request["bn"]                 
                   
                    --修改自己发起的订单信息
                    if key ==1   then
                        if next(mUseractive.info[self.aname].cdt["uidkey"])  then
                            mUseractive.info[self.aname].cdt["sl"]=mUseractive.info[self.aname].cdt["sl"]-1
                            local my = self.table(mUseractive.info[self.aname].cdt["uidkey"])
                            local k = my[orderkey]
                            table.remove(mUseractive.info[self.aname].cdt["uidkey"],k)
                        end
                    end
                   
                    --修改别人参与的订单信息
                    if key ~=1   then
                        if next(mUseractive.info[self.aname].cdt["uidkeys"]) then
                            local cy = self.table(mUseractive.info[self.aname].cdt["uidkeys"])
                            local k = cy[orderkey]
                            table.remove(mUseractive.info[self.aname].cdt["uidkeys"],k)
                        end
                    end
                   
                end

                  --删除参与购买的
                if next(mUseractive.info[self.aname].cdt["bykeys"]) then
                    local by = self.table(mUseractive.info[self.aname].cdt["bykeys"])
                    local k = by[orderkey]
                    table.remove(mUseractive.info[self.aname].cdt["bykeys"],k)
                end
                   --删除自己购买的
                if next(mUseractive.info[self.aname].cdt["mykeys"]) then
                    local by = self.table(mUseractive.info[self.aname].cdt["mykeys"])
                    local k = by[orderkey]
                    table.remove(mUseractive.info[self.aname].cdt["mykeys"],k)
                end
                if  not uobjs.save() then 
                    table.insert(failorder,orderkey)
                end
               
            end
           
        end

        return failorder
    
    end


    --检查过期
    function self.action_check(request)      
        local response = self.response
        local redis = getRedis()
        local rankkey=getCacheKey("rank")
        local allkey =getCacheKey("all")
        local key = request.params.key
        local id = request.params.id
        local ts= getClientTs()      --当前时间
        local propskey =getCacheKey("gid"..id)
        
        if key ~=nil  then
            local dan  = json.decode(redis:hget(allkey,key))
              
            if  dan ~=nil then

                if ts >= dan["lt"] then

                    redis:zrem(rankkey,key)
                    redis:zrem(propskey,key)
                    redis:hdel(allkey,key)
                end
                local rt =  self.rtdata(dan)

                if next(rt) then               
                    writeLog(json.encode(rt), "acivte_pdd_faildata")
                end   

            end

            
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --通过页码找到本页数据
    --request{uid,page}
    function self.Getpagedata1(request)
        local uid = request.uid
        local page = request.page
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local dankeys = {}
        local mUseractive = uobjs.getModel('useractive')  
        local redis = getRedis()
        local allkey = getCacheKey("all")
        local rankkey = getCacheKey("rank")
        -- 获取排行榜订单号
    
        if page==1 then  
            if mUseractive.info[self.aname].cdt ~=nil  then

                if mUseractive.info[self.aname].cdt["uidkey"]~=nil then 
                    for kk,vv in pairs(mUseractive.info[self.aname].cdt["uidkey"] ) do
                        table.insert(dankeys,1,vv)
                    end
                end

                if mUseractive.info[self.aname].cdt["bykeys"] ~= nil then 
                    for kk,vv in pairs(mUseractive.info[self.aname].cdt["bykeys"] ) do
                        table.insert(dankeys,vv)
                    end
                end

                if mUseractive.info[self.aname].cdt["mykeys"] ~= nil then 
                    for kk,vv in pairs(mUseractive.info[self.aname].cdt["mykeys"] ) do
                        table.insert(dankeys,vv)
                    end
                end

                if mUseractive.info[self.aname].cdt["uidkeys"] ~= nil then 
                    for kk,vv in pairs(mUseractive.info[self.aname].cdt["uidkeys"] ) do
                        table.insert(dankeys,vv)
                    end
                end
                
            end
        end

        local pagekeys= redis:zrevrange(rankkey,(page-1)*10, page*10-1,'withscores')
        for kk,vv in pairs(pagekeys) do
            table.insert(dankeys,vv[1])
        end

        local list = {}
        if  next(dankeys) then 
            local pagedata = redis:hmget(allkey,dankeys)  --  all加zid  长度不等得修一下
            local list1 = {}

            for k1,v1 in pairs(pagedata) do 
                local  v1 = json.decode(v1)
                local page = {
                nickname=v1["nickname"],
                people=v1["people"],
                lt=v1["lt"],
                id=v1["id"],
                key=v1["key"],
                bn=v1["bn"],
                uid=v1["uid"],
            }
                table.insert(list1,page)
            end

            list=list1
        end
        return list
    end


    function self.before(request)

        local response = self.response    
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        if not uid then
            response.ret = -102
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)

        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        self.st = mUseractive.info[self.aname].st
    end

    --数组key,val转换
    function self.table(table)
        local newtable = {}
        for key,val in pairs(table) do
            newtable[val]=key
        end
        return newtable
    end

  
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        local ts= getClientTs()     --当前时间
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false   
        --购买条件
        if type(mUseractive.info[self.aname].cdt) ~='table' then
            flag = true
            mUseractive.info[self.aname].cdt = {}
            mUseractive.info[self.aname].cdt["sl"] = 0       --当前自己拼单的次数
            mUseractive.info[self.aname].cdt["bykeys"] = {}  --当前已经购买的所有订单号
            mUseractive.info[self.aname].cdt["mykeys"] = {}  --当前已经购买的自己订单号
            mUseractive.info[self.aname].cdt["uidkey"] = {}  --自己发起的拼单和失效
            mUseractive.info[self.aname].cdt["uidkeys"] = {} --自己参与的拼单和失效时间
            mUseractive.info[self.aname].cdt["endtm"] = ts   --最早过期时间
        end
        --可购买的礼包数量
        if type(mUseractive.info[self.aname].ob)   ~='table' then
            flag = true
            mUseractive.info[self.aname].ob = {}

            for k,v in pairs(activeCfg.serverreward.shopList) do
              mUseractive.info[self.aname].ob[k] = activeCfg.serverreward.shopList[k]["limit"]
            end
            
        end


        if mUseractive.info[self.aname].cdt~= nil then 
            flag =true
            if  mUseractive.info[self.aname].cdt["endtm"] <= ts  then
                local db = getDbo()
                local redis = getRedis()
                 -- 删除参与的订单并返回次数
                if next(mUseractive.info[self.aname].cdt["uidkeys"]) then 

                    for key,val in pairs(mUseractive.info[self.aname].cdt["uidkeys"]) do
                        if type(val) == "number" then
                            local result = db:getRow("select id,uid,bnum,bid,updated_at from active_pdd where updated_at < :ts and id = :id",{id=val,ts=ts})
                          
                            if result ~=nil  then
                                if  tonumber(result["updated_at"])  <= ts  then
                                    mUseractive.info[self.aname].ob[tonumber(result["bid"])]=mUseractive.info[self.aname].ob[tonumber(result["bid"])]+result["bnum"]
                                    table.remove(mUseractive.info[self.aname].cdt["uidkeys"],key)
                                   
                                    local rankkey=getCacheKey("rank")
                                    local allkey =getCacheKey("all")
                                    local propskey =getCacheKey("gid"..tonumber(result["bid"]))
                                    redis:zrem(rankkey,tonumber(result["id"]))
                                    redis:zrem(propskey,tonumber(result["id"]))
                                    redis:hdel(allkey,tonumber(result["id"]))
                                end
                            end

                        end
                    end 

                end
                 -- 删除发起的订单并返回次数
                if next(mUseractive.info[self.aname].cdt["uidkey"]) then 

                    for key,val in pairs(mUseractive.info[self.aname].cdt["uidkey"]) do
                        if type(val) == "number" then
                            local result = db:getRow("select id,uid,bnum,bid,updated_at from active_pdd where updated_at < :ts and id = :id",{id=val,ts=ts})                           
                            if result ~=nil  then

                                if  tonumber(result["updated_at"])  <= ts  then                                    
                                    mUseractive.info[self.aname].ob[tonumber(result["bid"])]=mUseractive.info[self.aname].ob[tonumber(result["bid"])]+result["bnum"]
                                    table.remove(mUseractive.info[self.aname].cdt["uidkey"],key)
                                    mUseractive.info[self.aname].cdt["sl"]=mUseractive.info[self.aname].cdt["sl"]-1
                                   
                                    local rankkey=getCacheKey("rank")
                                    local allkey =getCacheKey("all")
                                    local propskey =getCacheKey("gid"..tonumber(result["bid"]))

                                    redis:zrem(rankkey,tonumber(result["id"]))
                                    redis:zrem(propskey,tonumber(result["id"]))
                                    redis:hdel(allkey,tonumber(result["id"]))
                                end
                                
                            end

                        end
                    end 

                end
                -- 删除购买的订单不返回次数
                if next(mUseractive.info[self.aname].cdt["bykeys"]) then 

                    for key,val in pairs(mUseractive.info[self.aname].cdt["bykeys"]) do
                        if type(val) == "number" then
                            local result = db:getRow("select id,uid,bnum,bid,updated_at from active_pdd where updated_at < :ts and id = :id",{id=val,ts=ts})                           
                            if result ~=nil  then
                                if  tonumber(result["updated_at"])  <= ts  then

                                    table.remove(mUseractive.info[self.aname].cdt["bykeys"],key)
                      
                                    local rankkey=getCacheKey("rank")
                                    local allkey =getCacheKey("all")
                                    local propskey =getCacheKey("gid"..tonumber(result["bid"]))
                                    redis:zrem(rankkey,tonumber(result["id"]))
                                    redis:zrem(propskey,tonumber(result["id"]))
                                    redis:hdel(allkey,tonumber(result["id"]))
                                end
                                
                            end

                        end
                    end 

                end

                -- 删除购买的订单不返回次数
                 if next(mUseractive.info[self.aname].cdt["mykeys"]) then 

                    for key,val in pairs(mUseractive.info[self.aname].cdt["mykeys"]) do
                        if type(val) == "number" then
                            local result = db:getRow("select id,uid,bnum,bid,updated_at from active_pdd where updated_at < :ts and id = :id",{id=val,ts=ts})                           
                            if result ~=nil  then
                                if  tonumber(result["updated_at"]) <= ts  then
                                    table.remove(mUseractive.info[self.aname].cdt["mykeys"],key)
                                   
                                    local rankkey=getCacheKey("rank")
                                    local allkey =getCacheKey("all")
                                    local propskey =getCacheKey("gid"..tonumber(result["bid"]))

                                    redis:zrem(rankkey,tonumber(result["id"]))
                                    redis:zrem(propskey,tonumber(result["id"]))
                                    redis:hdel(allkey,tonumber(result["id"]))
                                end
                                
                            end

                        end
                    end 

                end
                
                local result = db:getRow("select uid,updated_at from active_pdd where updated_at >:ts and uid = :uid",{uid=uid,ts=ts})
                if result ~= nil   then
                    mUseractive.info[self.aname].cdt["endtm"]=result["updated_at"]
                else
                    mUseractive.info[self.aname].cdt["endtm"]=ts
                end            
            end

        end

        if flag then

            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'
        return response
       
    end 

        --直接买or发起拼单
    function self.action_buy(request)

        local uid = request.uid
        local response = self.response
        local id = tonumber(request.params.id) -- 任务id
        local ts= getClientTs()     --当前时间

        local weeTs = getWeeTs()    --  当前初始时间
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local id = request.params.id

        if not  activeCfg.serverreward.shopList[id] then
            response.ret=-102
            return response
        end

        local bn = request.params.bn
        local num = activeCfg.serverreward.shopList[id]["num"]
        local limit = activeCfg.serverreward.shopList[id]["limit"]
        local xt = activeCfg.lastTime     --拼单存在时间
        local lt = ts+xt                  --拼单失效时间
        local et = mUseractive.info[self.aname].et   --活动结束时间
        local allkey =getCacheKey("all")
        local rankkey=getCacheKey("rank")
        local propskey=getCacheKey("gid"..request.params.id)

        if not  table.contains({0,1,2},request.params.p)  then
            response.ret=-102
            return response
        end
       

        local tp = activeCfg.serverreward.shopList[id]["type"]
        --直接购买不受等级限制
        if tp ==1 and request.params.p ~= 0 then 
            if num > mUserinfo.level then 
                response.ret=-102
                return response
            end
        end

        if  request.params.bn > mUseractive.info[self.aname].ob[id] or request.params.bn<=0 then 
            response.ret=-102
            return response
        end

        --直接购买
        if request.params.p == 0  then    -- p 0直接购买2发起拼单1参与拼单

            local rewardCfg=activeCfg.serverreward.shopList[id].r 
            local reward = {}
             -- 配置判断
            if type(rewardCfg)~='table' or not next(rewardCfg) then
                response.ret=-102
                return response
            end

            for k,v in pairs(rewardCfg) do 
                reward[k]=v*request.params.bn
            end

            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
            local gems = request.params.bn *  activeCfg.serverreward.shopList[id]["price1"]

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end

            regActionLogs(uid,1,{action=270,item="",value=gems,params={num=bn}})
            mUseractive.info[self.aname]["ob"][id]=mUseractive.info[self.aname]["ob"][id]-request.params.bn
           
            if uobjs.save() then
                response.data[self.aname]=mUseractive.info[self.aname]
                response.data[self.aname].r=formatReward(reward)
                response.ret = 0
                response.msg = 'Success'
            else
                response.ret=-106
            end

            return response
        end

       
        -- 前往参与,给客户端返回列表页具体位置, 如果没有直接拼单
       if request.params.p ==1 then 

            local redis = getRedis()
            local rankkey= getCacheKey("rank")

            local maxnum =activeCfg.serverreward.shopList[id]["needNum"]-1    

            local tzdata = redis:zrangebyscore(propskey,bn*100,bn*100+maxnum,'withscores')   -- 取出符合范围的  
             --商品排行榜找到数据
            local rankdata = redis:zrevrange(rankkey,0,-1,'withscores')
             if next(tzdata) then
                local len = #tzdata
                local order = tzdata[len][1]
                local bigpage= math.ceil(redis:zcard(rankkey)/ self.pageSize)     --最大页码
                local page = getOrderPage(tzdata[len][1])
                local wz   = getOrderRank(tzdata[len][1])% self.pageSize           --获取位置
                if    wz  ==0  then  wz=10  end  
                -- 判断是否是第一页
                if  page ==1 then

                    if mUseractive.info[self.aname].cdt["uidkeys"]~=nil then 
                        
                        wz =wz+#mUseractive.info[self.aname].cdt["uidkeys"]
                    end

                    if mUseractive.info[self.aname].cdt["uidkey"]~=nil then
                        
                        wz =wz+#mUseractive.info[self.aname].cdt["uidkey"]
                    end
                    if mUseractive.info[self.aname].cdt["bykeys"]~=nil then 
                        
                        wz =wz+#mUseractive.info[self.aname].cdt["bykeys"]
                    end
                    if mUseractive.info[self.aname].cdt["mykeys"]~=nil then 
                        
                        wz =wz+#mUseractive.info[self.aname].cdt["mykeys"]
                    end
                 end

                 local list = {bigpage=bigpage,page=page,wz=wz}
                 response.ret = 0
                 response.data[self.aname]=list
                 response.msg = 'Success'


            end
          --排行榜没有找到数据，发起订单
            if not next(tzdata)  then

                if activeCfg.startLimit <= mUseractive.info[self.aname].cdt["sl"] then 
                    response.ret=-100  --已经发起
                    return response
                end 
                  
                local gems = activeCfg.startCost
                if activeCfg.isUp ==0 then
                    gems = activeCfg.startCost 
                end
                if activeCfg.isUp ==1 then
                    gems = activeCfg.startCost * bn
                end

                if not mUserinfo.useGem(gems) then
                    response.ret = -109
                    return response
                end
                  
                  
                mUseractive.info[self.aname].ob[id]=mUseractive.info[self.aname].ob[id]-request.params.bn
                mUseractive.info[self.aname].cdt["sl"]=mUseractive.info[self.aname].cdt["sl"]+1
                if mUseractive.info[self.aname].cdt["endtm"]  < ts  then
                    mUseractive.info[self.aname].cdt["endtm"]=lt
                end

                regActionLogs(uid,1,{action=274,item="",value=gems,params={num=bn}})

                local score = 1*10^7+lt-ts    --人数加时间
                local score2 = bn*100+1         --购买数量人数
                local sqdata = {bid=request.params.id, bnum=request.params.bn,uid=uid, updated_at=ts}
                local orderkey = setOrder2db(sqdata)
                -- mUseractive.info[self.aname].cdt["uidkey"][tostring(uidkey)] =lt
                table.insert(mUseractive.info[self.aname].cdt["uidkey"],orderkey)

                if uobjs.save() then

                    local redis = getRedis()   
                  
                    local  order = {
                        uids={uid}, nickname=mUserinfo.nickname, lt=lt,
                        people=1,id=id,
                        uid=uid, bn=request.params.bn ,
                        key=orderkey,status=0
                    }
                    redis:zadd(rankkey,score,orderkey)     --排行榜
                    redis:zadd(propskey,score2,orderkey)   --商品榜
                    redis:hset(allkey,orderkey,json.encode(order))        --所有数据
                    redis:expireat(allkey,et+86400)             --过期时间
                    redis:expireat(propskey,et+86400)           --过期时间
                    redis:expireat(rankkey,et+86400)            --过期时间

                    local cronParams = {cmd="active.pdd.check",uid=uid,params={key=orderkey,id=request.params.id}}
                    local checkret = setGameCron(cronParams,xt)
                    if not checkret then
                        response.ret = -1989
                        return response
                    end

                    response.ret = 0
                    response.data[self.aname]=mUseractive.info[self.aname]
                    response.msg = 'Success'
                end 
            end
            return response
        end

        --发起拼单
        if request.params.p == 2 then

            if activeCfg.startLimit <= mUseractive.info[self.aname].cdt["sl"] then 
                response.ret=-100  --已经发起
                return response
            end 
            
            local gems = activeCfg.startCost
            if activeCfg.isUp ==0 then
                gems = activeCfg.startCost 
            end
            if activeCfg.isUp ==1 then
                gems = activeCfg.startCost * bn 
            end
            regActionLogs(uid,1,{action=274,item="",value=gems,params={num=bn}})

            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=270,item="",value=gems,params={num=bn}})
   
            mUseractive.info[self.aname].ob[id]=mUseractive.info[self.aname].ob[id]-request.params.bn
            mUseractive.info[self.aname].cdt["sl"]=mUseractive.info[self.aname].cdt["sl"]+1

            if mUseractive.info[self.aname].cdt["endtm"]  < ts  then
                mUseractive.info[self.aname].cdt["endtm"]=lt
            end
                        
            local score = 1*10^7+lt-ts 
            local score2 = bn*100+1
            local sqdata = {bid=request.params.id, bnum=request.params.bn,uid=uid, updated_at=ts}
            local orderkey = setOrder2db(sqdata)
            table.insert(mUseractive.info[self.aname].cdt["uidkey"],orderkey)

            if uobjs.save() then

                local redis = getRedis()   
                 
                local  order = {
                    uids={uid}, nickname=mUserinfo.nickname, lt=lt,
                    people=1,id=id,
                    uid=uid, bn=request.params.bn ,
                    key=orderkey,status=0
                }
                redis:zadd(rankkey,score,orderkey)     --排行榜
                redis:zadd(propskey,score2,orderkey)   --商品榜
                redis:hset(allkey,orderkey,json.encode(order))        --所有数据
                redis:expireat(allkey,et+86400) 
                redis:expireat(propskey,et+86400) 
                redis:expireat(rankkey,et+86400) 

                local cronParams = {cmd="active.pdd.check",uid=uid,params={key=orderkey,id=request.params.id}}
                local checkret = setGameCron(cronParams,xt)                
                if not checkret then
                    response.ret = -1989
                    return response
                end
                response.ret = 0
                response.data[self.aname]=mUseractive.info[self.aname]
                response.msg = 'Success'
            end 
            return response
       end

    end 

    --参与拼单或者直接购买购买
    function self.action_pinorbuy(request)
        local uid = request.uid
        local response = self.response
        local id = tonumber(request.params.id) -- 任务id
        local ts= getClientTs()     --当前时间
        local weeTs = getWeeTs()    --  当前初始时间
        local cfg = getConfig("alienWeaponCfg")  --配置
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tp = activeCfg.serverreward.shopList[id]["type"]
        local ndnum = activeCfg.serverreward.shopList[id]["needNum"]
        local xt = activeCfg.lastTime     --拼单存在时间
        local lt = ts+xt

        local redis = getRedis()
        local key = request.params.key
        local allkey =getCacheKey("all")
        local propskey = getCacheKey("gid"..id)
        local rankkey =getCacheKey("rank")

        local fqnum = 0
        local cynum = 0
        if mUseractive.info[self.aname].cdt ~=nil then
            fqnum = #mUseractive.info[self.aname].cdt["uidkey"] +#mUseractive.info[self.aname].cdt["mykeys"]
            cynum = #mUseractive.info[self.aname].cdt["uidkeys"]+#mUseractive.info[self.aname].cdt["bykeys"]
        end

        --参与拼单
        if  request.params.p ==1 then
            --判断参与的订单是否是自己发起的和已经参与的
            if  next(mUseractive.info[self.aname].cdt["uidkey"]) then 
                for kk,vv in pairs(mUseractive.info[self.aname].cdt["uidkey"]) do

                    if vv ==key then
                        response.ret=-102
                        return response
                    end

                end
            end

            if  next(mUseractive.info[self.aname].cdt["uidkeys"]) then 

                for kk,vv in pairs(mUseractive.info[self.aname].cdt["uidkeys"]) do
                    if vv ==key then
                        response.ret=-102
                        return response
                    end
                end

            end
              --加锁
            if not commonLock(key,"pinorbuy_active") then
                response.ret = -5004  
                return response
            end
             
            local dan = json.decode(redis:hget(allkey,key))              --获取订单数据

            if  dan == nil then 
                response.ret = -102
                return response
            end

            if dan["bn"] > mUseractive.info[self.aname].ob[id] then      --判断参与数量是否足够
                commonUnlock(key,"pinorbuy_active")

                response.ret = -102
                return response
            end

              --判断是否拼满
            if dan["people"] >=activeCfg.serverreward.shopList[dan["id"]]["needNum"]  then

                commonUnlock(key,"pinorbuy_active")
                response.ret = 0
                local full = {isfull=1}
                response.data[self.aname]=full
                response.msg = 'Success'
                return response         
            end

             
                dan["people"] =dan["people"]+ 1
                table.insert(dan["uids"],uid)

              --参与消耗金币
            local gems = activeCfg.partCost
            if activeCfg.isUp ==1 then
                gems = activeCfg.partCost *  dan["bn"]
            end
            regActionLogs(uid,1,{action=275,item="",value=gems,params={num=dan["bn"]}})

            if not mUserinfo.useGem(gems) then
                commonUnlock(key,"pinorbuy_active")
                response.ret = -109
                return response
            end

            mUseractive.info[self.aname].ob[id]=mUseractive.info[self.aname].ob[id]-dan["bn"]
            table.insert(mUseractive.info[self.aname].cdt["uidkeys"],key)
            if mUseractive.info[self.aname].cdt["endtm"]  < ts  then
                mUseractive.info[self.aname].cdt["endtm"]=dan["lt"]
            end

            if uobjs.save() then

                redis:hset(allkey,key,json.encode(dan))   --修改缓存数据
                redis:zincrby(propskey,1,key)             --修改排行榜
                redis:zincrby(rankkey,10^7,key)           --修改排行榜
                commonUnlock(key,"pinorbuy_active")       --解锁
                local page = getOrderPage(key)
                local listdata = self.Getpagedata1({uid=uid,page=page})

                mUseractive.info[self.aname]["list"]=listdata
                mUseractive.info[self.aname]["fqnum"]=0
                mUseractive.info[self.aname]["cynum"]=0
                if  page==1  then
                    mUseractive.info[self.aname]["fqnum"]=#mUseractive.info[self.aname].cdt["uidkey"]+ #mUseractive.info[self.aname].cdt["mykeys"]
                    mUseractive.info[self.aname]["cynum"]=#mUseractive.info[self.aname].cdt["uidkeys"]+ #mUseractive.info[self.aname].cdt["bykeys"]
                end
                mUseractive.info[self.aname]["page"] =page
                response.ret = 0
                response.data[self.aname]=mUseractive.info[self.aname]
                response.msg = 'Success'
            end

            return response
        end

        --购买
        if request.params.p ==2 then

           local code = 0

            if  table.contains(mUseractive.info[self.aname].cdt["uidkey"],key)  then
                code =1
                for i,v in ipairs(mUseractive.info[self.aname].cdt["uidkey"]) do
                    if v == key then
                        table.remove(mUseractive.info[self.aname].cdt["uidkey"],i)
                        mUseractive.info[self.aname].cdt["sl"]=mUseractive.info[self.aname].cdt["sl"]-1
                    end
                end
                  -- table.insert(mUseractive.info[self.aname]["cdt"]["bykeys"],1,key)
                table.insert(mUseractive.info[self.aname]["cdt"]["mykeys"],1,key)
            end

            if  table.contains(mUseractive.info[self.aname].cdt["uidkeys"],key)  then
                code =2
                for i,v in ipairs(mUseractive.info[self.aname].cdt["uidkeys"]) do
                    if v == key then
                        table.remove(mUseractive.info[self.aname].cdt["uidkeys"],i)
                    end
                end
                table.insert(mUseractive.info[self.aname]["cdt"]["bykeys"],key)
            end

          --判断购买的是否是自己发起的和参与的
            if  code==0 then
                response.ret=-102
                return response
            end

            local dan = json.decode(redis:hget(allkey,key))              --获取订单数据
          -- --判断该订单是否拼满
         
            if dan["people"]<activeCfg.serverreward.shopList[id].needNum  then
                response.ret=-102
                return response
            end

            local  rewardCfg= activeCfg.serverreward.shopList[id].r 
            local  reward = {}

            local  gems = dan["bn"] *  activeCfg.serverreward.shopList[id]["price2"]      
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=276,item="",value=gems,params={num=dan["bn"]}})
           -- 配置判断
            if type(rewardCfg)~='table' or not next(rewardCfg) then
                response.ret=-102
                return response
            end

            for k,v in pairs(rewardCfg) do 
                reward[k]=v*request.params.bn
            end

            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end

            if uobjs.save() then
                local page = getOrderPage(key)
                local  listdata = self.Getpagedata1({uid=uid,page=page})
                mUseractive.info[self.aname]["list"]=listdata


                mUseractive.info[self.aname]["fqnum"]=0
                mUseractive.info[self.aname]["cynum"]=0
                if  page==1  then
                    mUseractive.info[self.aname]["fqnum"]=#mUseractive.info[self.aname].cdt["uidkey"]+ #mUseractive.info[self.aname].cdt["mykeys"]
                    mUseractive.info[self.aname]["cynum"]=#mUseractive.info[self.aname].cdt["uidkeys"]+ #mUseractive.info[self.aname].cdt["bykeys"]
                end
                mUseractive.info[self.aname]["page"] =page
                
                response.data[self.aname]=mUseractive.info[self.aname]
                response.data[self.aname].r=formatReward(reward)

                response.ret = 0
                response.msg = 'Success'
          else
                response.ret=-106
          end
          return response
        end

    end
   
    --列表展示页
    function self.action_page(request)
        local response = self.response
        local uid = request.uid
        local page = request.params.id
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local  list = {}
        local redis = getRedis()
        local rankkey =getCacheKey("rank")
        local bigpage= math.ceil(redis:zcard(rankkey)/ self.pageSize)     --最大页
        if    bigpage ==0 then bigpage=1 end 
        local data = {uid=uid,page=page}
        local fqnum = 0
        local cynum = 0
        if mUseractive.info[self.aname].cdt ~=nil then
            fqnum = #mUseractive.info[self.aname].cdt["uidkey"] +#mUseractive.info[self.aname].cdt["mykeys"]
            cynum = #mUseractive.info[self.aname].cdt["uidkeys"]+#mUseractive.info[self.aname].cdt["bykeys"]
        end
        local ll = {}
        ll.list = self.Getpagedata1(data)

        if  page== 1  then
            ll.fqnum=fqnum
            ll.cynum=cynum
        else
            ll.fqnum=0
            ll.cynum=0
        end
        
        ll.bigpage=bigpage
        ll.cdt=mUseractive.info[self.aname].cdt
        ll.ob=mUseractive.info[self.aname].ob

        response.ret = 0
        response.data.pdd=ll
        response.msg = 'Success'
        return response

    end
   
    -- 获取当前订单号所在的页码
    function self.action_getPage(request)

        local response = self.response
        local orderId = request.params.orderId

        if not orderId then
              response.ret = -102
              return response
        end
        
        response.data.page, response.data.wz = getOrderPage(orderId)

        if response.data.page==1 then
            local uid = request.uid
            local uobjs = getUserObjs(uid)
            uobjs.load({"userinfo",'useractive'})
            local mUseractive = uobjs.getModel('useractive')
            local cdt=mUseractive.info[self.aname].cdt
            local n = 0
            if mUseractive.info[self.aname].cdt ~=nil then
                  n= #cdt.mykeys+#cdt.bykeys+#cdt.uidkeys+#cdt.uidkey
            end
            response.data.wz=response.data.wz+n
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end
  
       return self
end

return api_active_pdd
