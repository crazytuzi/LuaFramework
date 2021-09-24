--desc: 万圣节狂欢 2017
--user:chenyunhe
local function api_active_wsjkh(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="wsjkh",
    }

    -- 刷新
    function self.action_refresh(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local flag = false
        if type(mUseractive.info[self.aname].ngjl)~='table' then
            flag =  true
            mUseractive.info[self.aname].ngjl={}--初始化
            -- 每个积分点领取状态
            for i=1,#activeCfg.supportNeed do
                table.insert(mUseractive.info[self.aname].ngjl,0)
            end

            mUseractive.info[self.aname].wsjkh_a1 = 0
            mUseractive.info[self.aname].wsjkh_a2 = 0
            mUseractive.info[self.aname].wsjkh_a3 = 0
            mUseractive.info[self.aname].wsjkh_a4 = 0
        end

        -- 累计充值钻石
        if not mUseractive.info[self.aname].gems then
            flag =  true
            mUseractive.info[self.aname].gems = 0 --总充值钻石数
            mUseractive.info[self.aname].cn = 0 --已领取次数
        end

        -- 购买礼包次数
        if not mUseractive.info[self.aname].bn then
            flag =  true
            mUseractive.info[self.aname].bn = 0
        end

        -- 获得积分
        if not mUseractive.info[self.aname].s then
            flag =  true
            mUseractive.info[self.aname].s = 0
        end
        -- 军团积分排行榜奖励 领取状态
        if not mUseractive.info[self.aname].rk then
            flag =  true
            mUseractive.info[self.aname].rk = 0 -- 0未领取 1已领取
            mUseractive.info[self.aname].ranklog = -1-- 领取时的排名
        end

        if not mUseractive.info[self.aname].fb then
            flag =  true
            mUseractive.info[self.aname].fb = 0 --有没有领取facebook分享奖励
        end


        -- 军团积分
        local ascore = 0
        if mUserinfo.alliance>0 then
            local redis =getRedis()
            local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
            local scorelist = json.decode(redis:get(scorekey))

            if type(scorelist)~='table' or not next(scorelist) then
                scorelist = {}
            end

            for k,v in pairs(scorelist) do
                if tonumber(v[1]) == mUserinfo.alliance then
                   ascore = v[3]
                   break
                end
            end
        end
    
        if flag then
            if not uobjs.save() then
                response.ret = -1
                response.msg = 'success'
                return response
            end

        end

        response.data[self.aname] =mUseractive.info[self.aname]
        response.data[self.aname].ascore = ascore
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 购买礼包
    function self.action_buygift(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        
        -- 只能领取排行榜奖励
        if ts > tonumber(self.rdtime(mUseractive.info[self.aname].cfg,mUseractive.info[self.aname].et)) then
            response.ret =-1989
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local rewardCfg = activeCfg.serverreward.recharge1
        local gems = activeCfg.cost
  
        if tonumber(gems) <=0 then
            response.ret = -1
            return response
        end

        local bn = mUseractive.info[self.aname].bn or 0
        if bn>=activeCfg.buyLimit then
            response.ret = -1987
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        local reward = {}
        local spprop = {}
        for k,v in pairs(rewardCfg) do
            if string.find(v[1],'wsjkh') then
                spprop[v[1]]=(spprop[v[1]] or 0)+v[2]
            else
                reward[v[1]]=(reward[v[1]] or 0)+v[2]
            end
        end

        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end

        if gems>0 then
           regActionLogs(uid, 1, {action = 187, item = "", value = gems, params = {num = 1}})
        end

        mUseractive.info[self.aname].bn = (mUseractive.info[self.aname].bn or 0) + 1 
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret  = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
     

        return response
    end

    function self.formatreward(rewards)
		local formatreward = {}
		local key = 'wsjkh'
	   	formatreward[key] = {}
	    if type(rewards) == 'table' then
	        for k,v in pairs(rewards) do
	            formatreward[key][k] = v
	        end
	    end
	    return formatreward
	end

    -- 领取累计钻石奖励  一次性领取所有的奖励
    function self.action_chargereward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        -- 只能领取排行榜奖励
        if ts > tonumber(self.rdtime(mUseractive.info[self.aname].cfg,mUseractive.info[self.aname].et)) then
            response.ret =-1989
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local rewardCfg = activeCfg.serverreward.recharge2
        local totalgems = mUseractive.info[self.aname].gems or 0
        local totalcn = mUseractive.info[self.aname].cn or 0
        local num = math.floor((totalgems-totalcn*activeCfg.rechargeNum)/activeCfg.rechargeNum)
   
        if num <=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local spprop = {}
        for k,v in pairs(rewardCfg) do
            if string.find(v[1],'wsjkh') then
                spprop[v[1]]=(spprop[v[1]] or 0)+v[2]*num
            else
                reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
            end
        end

        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end

        mUseractive.info[self.aname].cn =  (mUseractive.info[self.aname].cn or 0) + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret  = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
     

        return response

    end

    -- 填充南瓜
    function self.action_fill(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
     
        local items = request.params
        if not uid or type(items)~='table' or not next(items) then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        -- 只能领取排行榜奖励
        if ts > tonumber(self.rdtime(mUseractive.info[self.aname].cfg,mUseractive.info[self.aname].et)) then
            response.ret =-1989
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local score = 0

        -- 检测参数和玩家当前拥有的数量
        for k,v in pairs(items) do
            if not mUseractive.info[self.aname][k]  then
                response.ret = -102
                return response
            end

            if mUseractive.info[self.aname][k]<v then
                response.ret = -1996
                return response
            end
            if v > 0  then
                mUseractive.info[self.aname][k] = mUseractive.info[self.aname][k] - v
                score = (activeCfg.serverreward.candyScore[k] or 0)*v + score
            end
        end

        local reward = {}
        for k,v in pairs(items) do
            local index = string.sub(k,-1)    
            if v>0 then
                for i=1,v do
                    local result,rewardkey
                    result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..index],1)
                    for k,v in pairs(result) do
                        for rk,rv in pairs(v) do
                            reward[rk]=(reward[rk] or 0)+rv
                        end
                    end
                end
            end
        end
       
        local clientReward = {}
        for k,v in pairs(reward) do
            table.insert(clientReward, formatReward({[k] = v})) 
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        if mUserinfo.alliance == 0 then
            score = 0
        end

        mUseractive.info[self.aname].s = (mUseractive.info[self.aname].s or 0) + score
        local ascore = 0
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            if mUserinfo.alliance>0 then
                if ts < tonumber(self.rdtime(mUseractive.info[self.aname].cfg,mUseractive.info[self.aname].et)) then
                    local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..mUserinfo.alliance
                   
                    local redis = getRedis()
                    local ranklist = json.decode(redis:get(redkey))

                    if type(ranklist)~='table' or not next(ranklist) then
                        ranklist = {}
                    end
                    local uexist = false
                    for k,v in pairs(ranklist) do
                        if v[1]==uid then
                            uexist = true
                            v[3] = v[3] + score
                            break
                        end
                    end
                    if not uexist then
                        table.insert(ranklist,{uid,mUserinfo.nickname,score})
                    end
                  
                    redis:set(redkey,json.encode(ranklist))
                    redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
                 

                    local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
                    local scorelist = json.decode(redis:get(scorekey))

                    if type(scorelist)~='table' or not next(scorelist) then
                        scorelist = {}
                    end

                    local aexit = false
                    local setRet,code=M_alliance.getalliance{aid=mUserinfo.alliance}
                    if type(setRet['data'])=='table' and next(setRet['data']) then
                        for k,v in pairs(scorelist) do
                            if tonumber(v[1]) == mUserinfo.alliance then
                                v[2] = setRet['data']['alliance']['name']
                                v[3] = v[3] + score
                                v[4] = setRet['data']['alliance']['num']
                                v[5] = json.decode(setRet['data']['alliance']['logo'])
                                ascore = v[3]

                                aexit = true
                                break
                            end
                        end

                        if not aexit then
                            table.insert(scorelist,{mUserinfo.alliance,setRet['data']['alliance']['name'],score,setRet['data']['alliance']['num'],json.decode(setRet['data']['alliance']['logo'])})
                            ascore = score
                        end

                        redis:set(scorekey,json.encode(scorelist))
                        redis:expireat(scorekey,mUseractive.info[self.aname].et+86400)
                  
                        
                    end
                end
            end

            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = clientReward     
            response.data[self.aname].score = score
            response.data[self.aname].ascore = ascore
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        
        return response
    end 

    -- 查看军团内部积分排行榜
    function self.action_memrank(request)
        local uid = request.uid
        local response = self.response
 
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local ranklist
        if mUserinfo.alliance>0 then
            local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..mUserinfo.alliance
            local redis = getRedis()
            ranklist = json.decode(redis:get(redkey))
            if type(ranklist)~='table' or not next(ranklist) then
                ranklist = {}
            else
                -- 排序
                table.sort( ranklist,function ( a,b )  
                    -- body 
                    if a[3]==b[3] then  
                        return a[3] >b [3]  
                    end  
                  
                    return a[3] > b[3]  
                end ) 
            end
        end

        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].mrank = ranklist

        return response
    end

    -- 军团积分排行榜
    function self.acrank(st,et)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
        local redis = getRedis()
        local scorelist = json.decode(redis:get(redkey))
       
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
            local list = readRankfile(self.aname,st)
            if type(list) == 'table' then
                redis:set(redkey,json.encode(list))
                redis:expireat(redkey,et+86400)
                scorelist = list
            end
        else
            -- 排序
            table.sort( scorelist,function ( a,b )  
                -- body  
                if a[3]==b[3] then  
                    return a[3] >b [3]  
                end  
              
                return a[3] > b[3]  
            end ) 

            local ranklist = json.encode(scorelist)
            writeActiveRankLog(ranklist,self.aname,st) -- 排行榜记录日志
        end

        local list = {}
        local num = 0 -- 显示前20条
        for k,v in pairs(scorelist) do
            if num>=20 then
                break
            end
            table.insert(list,v)
            num = num + 1 
        end

        return list
    end

    -- 获取排行榜数据
    function self.action_getRank(request)
        local uid = request.uid
        local response = self.response
 
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local ranklist = {}
        local currank = -1

        ranklist = self.acrank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et)
        for k,v in pairs(ranklist) do
            if v[1] == mUserinfo.alliance then
                currank = k
                break
            end
        end

        
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].arank = ranklist
        response.data[self.aname].currank = currank

        return response
    end

    -- 领取排行榜奖励
    function self.action_rankReward(request)
        local uid = request.uid
        local response = self.response
        local rank = request.params.rank
        local ts = getClientTs()
 
        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local lt = tonumber(self.rdtime(mUseractive.info[self.aname].cfg,mUseractive.info[self.aname].et))
        
        -- 时间还没到
        if ts < lt then
            response.ret =-1978
            return response
        end

        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end

        -- 最后一天加入军团的玩家不能领取
        local execRet = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,acallianceLevel=1}
        local joinAt = tonumber(execRet.data.join_at) or 0
        if joinAt >= lt then
            response.ret = -102
            return response
        end

        if not mUseractive.info[self.aname].rk then
            mUseractive.info[self.aname].rk = 0
            mUseractive.info[self.aname].ranklog = -1
        end
        
        -- 已经领取奖励
        if mUseractive.info[self.aname].rk == 1 then
            response.ret = -1976
            return response
        end
        
        -- 获取排名
        local myrank = -1
        local ranklist = self.acrank(mUseractive.info[self.aname].st)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local aid= tonumber(v[1])
                if aid == mUserinfo.alliance then
                    myrank = k
                    break
                end
            end
        else
            response.ret = -1975
            return response
        end 

        if myrank ~= rank then
            response.ret = -102
            return response
        end

        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 判断排名获得奖励下标
        local matchgift = 0
        for k,v in pairs(activeCfg.section) do
            if myrank>=v[1] and myrank<=v[2] then
                matchgift = k
            end
        end

        if matchgift == 0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local clientReward = {}
        for k,v in pairs(activeCfg.serverreward['rank'..matchgift]) do
           reward[v[1]] = (reward[v[1]] or 0) + v[2]
           table.insert(clientReward, formatReward({[v[1]] = v[2]})) 
        end

        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].rk = 1
        mUseractive.info[self.aname].rank = myrank

        processEventsBeforeSave()

        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data.reward = clientReward
            response.data[self.aname] = mUseractive.info[self.aname]
        else
            response.ret = -106
        end

        return response
    end

    -- 获取军团积分南瓜奖励
    function self.action_scoreReward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local item =  request.params.item or 0

        if not uid  then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local needScore = activeCfg.supportNeed[item] or 0

        if needScore ==  0 then
            response.ret = -102
            return response
        end

        local redis = getRedis()
        local scorekey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'score'
        local scorelist = json.decode(redis:get(scorekey))
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
        end

        local curscore =  0
        for k,v in pairs(scorelist) do
            if tonumber(v[1]) == mUserinfo.alliance then
               curscore = tonumber(v[3])
               break
            end
        end
        
        if curscore < needScore then
            response.ret = -1981
            return response
        end

        if type(mUseractive.info[self.aname].ngjl)~='table' then
            flag =  true
            mUseractive.info[self.aname].ngjl={}--初始化
            -- 每个积分点领取状态
            for i=1,#activeCfg.supportNeed do
                table.insert(mUseractive.info[self.aname].ngjl,0)
            end
        end

        if mUseractive.info[self.aname].ngjl[item] ==1 then
            response.ret = -1976
            return response
        end

        local rewardCfg = activeCfg.serverreward['gift'..item]
        local reward = {}
        local clientReward = {}
        for k,v in pairs(rewardCfg) do
           reward[v[1]] = (reward[v[1]] or 0) + v[2]
           table.insert(clientReward, formatReward({[v[1]] = v[2]})) 
        end

        if not takeReward(uid, reward) then
            response.ret = -403
            return response
        end

        mUseractive.info[self.aname].ngjl[item] = 1
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'success'
            response.data.reward = clientReward
            response.data[self.aname] = mUseractive.info[self.aname]
        else
            response.ret = -106
        end

        return response
    end

    -- facebook分享奖励
    function self.action_fbreward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 已经领取过
        if mUseractive.info[self.aname].fb==1 then
            response.ret=-1976
            return response
        end

        local rewardCfg = activeCfg.serverreward.fbreward

        local reward = {}
        local spprop = {}
     
        for k,v in pairs(rewardCfg) do
            if string.find(v[1],'wsjkh') then
                spprop[v[1]]=(spprop[v[1]] or 0)+v[2]
            else
                reward[v[1]]=(reward[v[1]] or 0)+v[2]
            end
        end
        local report = {}
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end

        -- 修改状态
        mUseractive.info[self.aname].fb = 1 
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    --facebook分享地址 https://www.facebook.com/Flotten-Kommando-Community-681743588593889
    function self.action_fbURL(request)
        local uid = request.uid
        local response = self.response
        local zoneid = request.zoneid
        local lang = request.lang
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid or not zoneid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local url = nil
        local urlkey = "facebookshareurl"
        local freedata = getFreeData(urlkey)
        url = freedata.info[lang] or nil
         
        response.data.fb = mUseractive.info[self.aname].fb or 0
        response.data.url =  url
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领奖期时间判断
    function self.rdtime(cfg,et)
        local diff = 86400
       
        return et-diff
    end
    
    return self
end

return api_active_wsjkh
