--
-- desc: 团结之力
-- user: chenyunhe
--
local function api_active_unitepower(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'unitepower',
        rblimt = 50,-- 紅包列表数量
    }

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
    end

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'unitepower'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end

    function self.getascore(aid,st)
        local scorekey = 'unitepowerscore'..st
        local scorefilekey = 'unitepowerscore'
        local redis = getRedis()
        local unitepower = json.decode(redis:get(scorekey))

        if type(unitepower) ~= 'table' then
            unitepower = readRankfile(scorefilekey,st)
        end

        if type(unitepower) ~= 'table' then
            unitepower = {}
        end

        return tonumber(unitepower[aid]) or 0
    end

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local flag = mUseractive.initAct(self.aname)

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].ascore = mUserinfo.alliance==0 and 0 or self.getascore('a'..mUserinfo.alliance,mUseractive.info[self.aname].st)--军团积分
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_treward(request)
        local response = self.response
        local uid=request.uid
        local tid = request.params.tid -- 任务id

        if not tid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
       
        if mUserinfo.alliance <=0 then
            response.ret = -4005
            return response
        end
        local aid = 'a'..mUserinfo.alliance

        mUseractive.initAct(self.aname)-- 这里面会刷新数据
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local taskCfg = copyTable(activeCfg.serverreward.taskList[tid])
        if type(taskCfg) ~='table' then
            response.ret = -102
            return response
        end

        -- 检测可领取次数
        if mUseractive.info[self.aname].task[tid][2] >= taskCfg.limit then
            response.ret = -1993
            return response
        end

        local cur = mUseractive.info[self.aname].task[tid][2]
        local totalcanget = math.floor(mUseractive.info[self.aname].task[tid][1]/taskCfg.num)-cur

        local leftn = taskCfg.limit - cur 
        local canget = 0
        if totalcanget > leftn then
            canget = leftn
        else
            canget = totalcanget
        end

        if canget<=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local spprop = {}
        for k,v in pairs(taskCfg.serverreward) do
            if string.find(k,'unitepower') then
                spprop[k] = v * canget
            else
                reward[k] = v * canget
            end  
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        local getscore1 = spprop['unitepower_a1'] or 0 -- 个人积分
        local getscore2 = spprop['unitepower_a2'] or 0 -- 军团积分

        local report = {}
        table.insert(report,formatReward(reward))
        if next(spprop) then
            for k,v in pairs(spprop) do
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        mUseractive.info[self.aname].unitepower_a1 = (mUseractive.info[self.aname].unitepower_a1 or 0) + getscore1
        mUseractive.info[self.aname].task[tid][2] = mUseractive.info[self.aname].task[tid][2] + canget
        if uobjs.save() then        
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'

            if getscore2>0 then
                -- 记录军团积分
                local redis = getRedis()
                local scorekey = 'unitepowerscore'..mUseractive.info[self.aname].st
                local scorefilekey = 'unitepowerscore'
                local unitepower = json.decode(redis:get(scorekey))
                if type(unitepower) ~= 'table' then
                    unitepower = readRankfile(scorefilekey,mUseractive.info[self.aname].st)
                end

                if type(unitepower) ~= 'table' then
                    unitepower = {}
                end

                unitepower[aid] = (unitepower[aid] or 0) + getscore2
                local unitepowerfiledata = json.encode(unitepower)
                redis:set(scorekey,unitepowerfiledata) 
                redis:expireat(scorekey,mUseractive.info[self.aname].et+86400)
                writeActiveRankLog(unitepowerfiledata,scorefilekey,mUseractive.info[self.aname].st)
            end

            response.data[self.aname].ascore = self.getascore(aid,mUseractive.info[self.aname].st)
        else
            response.ret=-106
        end

        return response
    end

    -- 根据军团积分 领取奖励
    function self.action_sgift(request)
        local response = self.response
        local uid=request.uid
        local gid = request.params.gid -- 奖励下标

        if not gid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
       
        if mUserinfo.alliance <= 0 then
            response.ret = -4005
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aid = 'a'..mUserinfo.alliance   
        local ascore = self.getascore(aid,mUseractive.info[self.aname].st)
        if ascore < activeCfg.scoreNeed1[gid] then
            response.ret = -102
            return response
        end
    
        -- 检测可领取次数
        if mUseractive.info[self.aname].sgift[gid] >0 then
            response.ret = -1993
            return response
        end

        local reward = copyTable(activeCfg.serverreward['gift'..gid])
        if type(reward)~='table' then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].sgift[gid] = 1
        if uobjs.save() then        
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].ascore = ascore
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 商店购买
    function self.action_shop(request)
        local response = self.response
        local uid=request.uid
        local sid = request.params.sid -- 哪个商店
        local index = request.params.index -- 选择商店下物品的下标

        if not sid or not index then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
       
        if mUserinfo.alliance <= 0 then
            response.ret = -4005
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aid = 'a'..mUserinfo.alliance
        local ascore = self.getascore(aid,mUseractive.info[self.aname].st)
     
        if ascore < activeCfg.scoreNeed2[sid] then
            response.ret = -102
            return response
        end

        local shopCfg = copyTable(activeCfg.serverreward['shopList'..sid][index])
        if type(shopCfg)~='table' then
            response.ret = -102
            return response
        end
      
        -- 检测可领取次数
        if mUseractive.info[self.aname].shop[sid][index] >= shopCfg.limit then
            response.ret = -1993
            return response
        end

        local costGems = shopCfg.price  
        local usequan = math.ceil(costGems * activeCfg.discount[sid]) -- 每个商店代金券可以抵扣的百分比  需取配置
    
        if mUseractive.info[self.aname].quan>=usequan then
            mUseractive.info[self.aname].quan = mUseractive.info[self.aname].quan - usequan
        else
            usequan = mUseractive.info[self.aname].quan or 0
            mUseractive.info[self.aname].quan = 0
        end
        costGems = costGems - usequan

        if costGems <= 0 then
            response.ret = -102
            return response
        end

        if not mUserinfo.useGem(costGems) then
            response.ret = -108
            return response
        end

        if costGems > 0 then
            regActionLogs(uid,1,{action = 238, item = "", value = costGems, params = {}})
        end

        local reward = copyTable(shopCfg.serverreward)
        if type(reward)~='table' then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].shop[sid][index] = (mUseractive.info[self.aname].shop[sid][index] or 0) + 1
        if uobjs.save() then        
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].ascore = ascore
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response

    end

    -- 发红包
    function self.action_send(request)
        local uid = request.uid
        local response = self.response
        local item = request.params.item -- 发的哪种红包

        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -4005--未加入军团
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not activeCfg.scoreCost[item] then
            response.ret = -102
            return response
        end

        local costa1 = activeCfg.scoreCost[item]
        if not mUseractive.info[self.aname].unitepower_a1 or mUseractive.info[self.aname].unitepower_a1<costa1 then
            response.ret = -102
            return response
        end
        
        -- 创建红包
        local flagid = mUserinfo.alliance.."_"..ts
        local redkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."_"..flagid
        local redis = getRedis()
        --不能同一时间发送
        local redinfo=redis:hget(redkey,'info')
        local redbag=json.decode(redinfo)
        if type(redbag)=='table' and next(redbag) then
            response.ret=-100 --已经存在 
            return response
        end
        local sendquan = activeCfg.bagValue[item]-- 当前的红包代金券的价值
        local bags = self.makerb(sendquan,activeCfg.bagNum[item])
        if type(bags)~='table' or not next(bags) then
            response.ret = -102
            return response
        end

        local gnum = activeCfg.bagNum[item]
        redis:hset(redkey,'num',gnum)
        local info = {
            flagid, --id
            item,--红包类型
            uid,--uid
            mUserinfo.nickname,--昵称
            mUserinfo.pic,-- 头像
            mUserinfo.alliance,--军团id
            {},--领取玩家
            bags,--红包数据
            gnum ,--一共可领取次数
            ts,--创建时间
        }
   
        local data = json.encode(info)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,mUseractive.info[self.aname].et)
        local getquan = activeCfg.extraGet[item] or 0

        mUseractive.info[self.aname].unitepower_a1 = mUseractive.info[self.aname].unitepower_a1 - costa1
        mUseractive.info[self.aname].quan = mUseractive.info[self.aname].quan + activeCfg.extraGet[item]   
        if uobjs.save() then
            -- 记录本军团每个玩家发红包数据
            local alkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."_a"..mUserinfo.alliance
            local adata = json.decode(redis:get(alkey))
            if type(adata)~='table' then
                adata = {}
            end
 
            local flag = false
            for k,v in pairs(adata) do
                if v[1] == uid then
                    v[item+4] = (v[item+4] or 0) + 1
                    v[8] = v[8] + sendquan
                    flag = true
                    break
                end
            end
            if not flag  then
                local tmp = {0,0,0,0,0,0,0,0}--uid 头像 名称 创建时间  类型一个数 类型二 类型三  总价值
                tmp[1] = uid
                tmp[2] = mUserinfo.pic
                tmp[3] = mUserinfo.nickname
                tmp[4] = ts
                tmp[item+4] = 1
                tmp[8] = sendquan
                table.insert(adata,tmp)
            end
       
            redis:set(alkey,json.encode(adata))
            redis:expireat(alkey,mUseractive.info[self.aname].et)

            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].getquan = getquan
            response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,mUserinfo.alliance)--多余的 按时间从列表中刷掉
            response.data[self.aname].ascore = self.getascore('a'..mUserinfo.alliance,mUseractive.info[self.aname].st)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response     
    end

    -- 红包列表 保留指定条数 多余的按照领取状态 发送先后时间给清理
    function self.refreshlist(uid,st,aid)
        local baglist = {}
        if aid==0 then
            return baglist
        end
        local redis = getRedis()
        local redkeys=redis:keys("zid."..getZoneId()..self.aname..st.."_"..aid.."_*")

        local finished = {} -- 已被抢完的
        local nofinish = {} -- 未抢完
        if type(redkeys)=='table' and next(redkeys) then
            for k,v in pairs(redkeys) do
                local left = json.decode(redis:hget(v,'num'))
                local jsonde=json.decode(redis:hget(v,'info'))

                local tmp = {0,0,0,0,0,0,0,0} 
                tmp[1] = jsonde[4] -- 昵称 
                tmp[2] = jsonde[5] -- 头像  
                tmp[3] = jsonde[2] -- 类型 
                tmp[4] = left      -- 当前剩余 
                tmp[5] = jsonde[9] -- 总数量 
                tmp[6] = jsonde[10]-- 创建时间  
                tmp[7] = jsonde[1] -- 红包id
                tmp[8] = 0         -- 有没有被当前玩家领取
                local rflag = false
                for jk,jv in pairs(jsonde[7]) do
                    if jv[1]==uid then
                          rflag = true
                          break
                    end
                end

                if left == 0 or rflag then
                     tmp[8] = 1
                end
                if left == 0 then
                    table.insert(finished,tmp)
                else
                    table.insert(nofinish,tmp)
                end
            end
        end

        if next(nofinish) or next(finished) then
            table.sort(nofinish,function(a,b)
                return a[6] < b[6] 
            end)
 
            -- 超过指定数量 就去掉 保留最新的
            if #nofinish>self.rblimt then  
                local rem = #nofinish - self.rblimt
                for i=1,rem do
                    local tmp = nofinish[1]
                    local rkey = "zid."..getZoneId()..self.aname..st.."_"..tmp[7]
                    table.remove(nofinish,1)
                    redis:del(rkey)
                end

                return nofinish
            else -- 需要用已抢完的 且最新发的补全显示数量
    
                baglist = copyTable(nofinish)
                table.sort(finished,function(a,b)
                    return a[6] > b[6] 
                end)
 
                for k,v in pairs(finished) do
                    if v then
                        if #baglist<self.rblimt then
                            table.insert(baglist,v)
                        else-- 多余的清理了
                            local rkey = "zid."..getZoneId()..self.aname..st.."_"..v[7]
                            redis:del(rkey)
                        end       
                    end
                end
            end
        end

        return baglist
    end

    -- 获取红包列表
    function self.action_baglist(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].list = {}
        if mUserinfo.alliance > 0 then
            response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,mUserinfo.alliance)
        end

        response.ret = 0
        response.msg = 'Success'
      
        return response
    end

    -- 抢红包
    function self.action_grab(request)
        local uid = request.uid
        local response = self.response
        local rbid = request.params.id --红包id
        local ts= getClientTs()

        if not rbid then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local alliance = mUserinfo.alliance
        if alliance==0 then
            response.ret = -4005   --没加入军团 不能领取奖励
            return response
        end

        local redkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."_"..rbid
        local redis = getRedis()
        local giftinfo = json.decode(redis:hget(redkey,'info'))
        if type(giftinfo)~='table' or not next(giftinfo) then
            response.ret = -4001 --数据发生变化重试
            return response
        end

        -- 只能领取所在军团的礼包
        if alliance~=giftinfo[6] then
            response.ret = -1981
            return response
        end

        local leftnum=tonumber(redis:hget(redkey,'num'))
        if leftnum<=0 then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,alliance)--多余的 按时间从列表中刷掉
            response.data[self.aname].getquan = 0
            response.data[self.aname].rbinfo = giftinfo
            response.ret = 0
            response.msg = 'success'
            return response
        end

        for k,v in pairs(giftinfo[7]) do
            if v[1]==uid then
                response.data[self.aname] = mUseractive.info[self.aname]
                response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,alliance)--多余的 按时间从列表中刷掉
                response.data[self.aname].getquan = 0
                response.data[self.aname].rbinfo = giftinfo
                response.ret = 0
                response.msg = 'success'
                return response
            end
        end

        if type(giftinfo[7])~='table' then
            giftinfo[7] = {}
        end

        -- 减少礼包
        local left=redis:hincrby(redkey,"num",-1)
        if left<0 then
            response.ret = -4001 -- 超出上限
            return response
        end

        setRandSeed()
        local rand = rand(1,#giftinfo[8])
        local quan = giftinfo[8][rand] -- 本次可以获得券

        table.insert(giftinfo[7],{uid,mUserinfo.nickname,quan,ts})
        table.remove(giftinfo[8],rand)

        local data = json.encode(giftinfo)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,mUseractive.info[self.aname].et)

        mUseractive.info[self.aname].quan = mUseractive.info[self.aname].quan + quan 

        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,alliance)--多余的 按时间从列表中刷掉
            response.data[self.aname].getquan = quan
            response.data[self.aname].rbinfo = giftinfo
           
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response     
    end

    -- 分配红包  分配的代金券  可被抢次数
    function self.makerb(total,n)
         ------分配红包start-----------
         local function randbag(total,bn)
            local bags={}--分配的结果
            local totalquan =total--总金额
            local i=0
            local rate1=math.ceil(math.max(1,totalquan/20))
            local rate2=math.ceil(math.max(1,totalquan/2))
            while(i<bn)
            do
                if i<bn-1 then
                    setRandSeed()
                    local rand=math.floor(rand(100*rate1,math.min(100*rate2,100*(totalquan-rate1*(bn-i))))/100)
                    table.insert(bags,rand)
                    totalquan=totalquan-rand
                else
                    table.insert(bags,totalquan)
                end
                i=i+1
            end

            return bags
         end

        local bags={}
        -- 每个红包都要独立分配份数
        local getbags=randbag(total,n)
        for k,v in pairs(getbags)  do
            table.insert(bags,v)
        end
        ------分配红包end-----------
        return bags
    end

    -- 红包排行榜
    function self.action_rbrank(request)
        local uid = request.uid
        local response = self.response

        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -4005--未加入军团
            return response
        end

        -- 记录本军团每个玩家发红包数据
        local redis = getRedis()
        local alkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."_a"..mUserinfo.alliance
        local adata = json.decode(redis:get(alkey))
        if type(adata)~='table' then
            adata = {}
        else
            table.sort(adata,function(a,b)
                if a[8] == b[8] then
                    return a[4] < b[4]
                end
                return a[8] > b[8]
            end)
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].rank = adata
        response.data[self.aname].ascore = self.getascore('a'..mUserinfo.alliance,mUseractive.info[self.aname].st)
        response.ret = 0
        response.msg = 'Success'

        return response     
    end

    -- 一键抢红包 
    function self.action_easygrab(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','userinfo'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
       
        if mUserinfo.alliance <= 0 then
            response.ret = -4005
            return response
        end
        
        local allbags = self.refreshlist(uid,mUseractive.info[self.aname].st,mUserinfo.alliance)
        local getquan = 0
        if next(allbags) then
            local redis = getRedis()
            for k,v in pairs(allbags) do
                if v then
                    local rbid = v[7]
                    local redkey = "zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."_"..rbid
                   
                    local giftinfo = json.decode(redis:hget(redkey,'info'))
                    local leftnum=tonumber(redis:hget(redkey,'num'))
                    if type(giftinfo)=='table' and next(giftinfo) and leftnum>0 then
                        local flag = false
                        for gk,gv in pairs(giftinfo[7]) do
                            if gv[1]==uid then
                               flag = true
                               break
                            end
                        end
                        if not flag then
                            if type(giftinfo[7])~='table' then
                                giftinfo[7] = {}
                            end

                            -- 减少礼包
                            local left=redis:hincrby(redkey,"num",-1)
                            if left>=0 then
                                setRandSeed()
                                local rand = rand(1,#giftinfo[8])
                                local quan = giftinfo[8][rand]

                                table.insert(giftinfo[7],{uid,mUserinfo.nickname,quan,getClientTs()})
                                table.remove(giftinfo[8],rand)

                                local data = json.encode(giftinfo)
                                redis:hset(redkey,'info',data)
                                redis:expireat(redkey,mUseractive.info[self.aname].et)
                                getquan = getquan + quan
                            end
                        end
                    end
                end
            end
        end

        if getquan>0 then
            mUseractive.info[self.aname].quan = mUseractive.info[self.aname].quan + getquan
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].list = self.refreshlist(uid,mUseractive.info[self.aname].st,mUserinfo.alliance)
            response.data[self.aname].getquan = getquan
        else
            response.ret = -106
        end  

        return response
    end
   
    return self
end

return api_active_unitepower
