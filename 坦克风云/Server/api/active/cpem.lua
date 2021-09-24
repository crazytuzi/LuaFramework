--
-- desc: 冲破噩梦
-- user: chenyunhe
--
local function api_active_cpem(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'cpem',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'cpem'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
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
    end

    -- 攻击boss
    function self.action_attack(request)
 		local uid = request.uid
        local response = self.response
        local p =  request.params.p -- 使用的炮弹
        local num = request.params.num -- 使用的数量
        local ts = getClientTs()
        
        if num<=0 or not table.contains({"cpem_a1","cpem_a2","cpem_a3","cpem_a4"},p) then
       	   response.ret=-102
       	   return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local aid = mUserinfo.alliance
        if aid<=0 then
            response.ret = -8012
            return response
        end

        if ts>tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -100
            return response
        end

        local activeObj = aAllianceActive.getActiveObj(self.aname) 
        if mUseractive.info[self.aname][p]<num then
            response.ret = -1996
            return response
        end

        local tytab = {cpem_a1=1,cpem_a2=2,cpem_a3=3,cpem_a4=4}
        -- 判断boss类型
        local damage = 0 
        local atttype = tytab[p]
        if activeObj.activeInfo.type==4 then
            -- 非特殊炮弹 都为普通伤害
            if atttype==4 then
                damage = activeCfg.damage[3] * num
            else
                damage = activeCfg.damage[1] * num
            end
        else
            -- boss类型不为4 按炮弹类型克制关系取伤害值
            if atttype == activeObj.activeInfo.type then
                damage = activeCfg.damage[2] * num
            elseif atttype==4 then
                damage = activeCfg.damage[3] * num
            else
                damage = activeCfg.damage[1] * num
            end
        end

        local reward = {}
        local mathpool = atttype==4 and 'pool2' or 'pool1'
        for i=1,num do
            local re,rkey = getRewardByPool(activeCfg.serverreward[mathpool],1) 
            for k,v in pairs(re) do
                for rk,rv in pairs(v) do
                   reward[rk] = (reward[rk] or 0) + rv
                end 
            end
        end    

        if not next(reward) then
            response.ret = -102
            return response
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname][p] = mUseractive.info[self.aname][p] - num
        if damage >0 then         
           local params = {}    
            params.allianceName=mUserinfo.alliancename
            params.damage = damage
            activeObj:addPoint(params)  
            mUseractive.info[self.aname].dm = (mUseractive.info[self.aname].dm or 0) + damage
            self.updamage(mUseractive,aid,uid,mUseractive.info[self.aname].dm,mUserinfo.pic,num,mUserinfo.nickname) 
        end

        if uobjs.save() then
            processEventsAfterSave()
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].damage = damage  -- 本次伤害

            -- 重新刷一下数据
            local activeObj = aAllianceActive.getActiveObj(self.aname) 
            response.data[self.aname].adamage = activeObj.activeInfo.damage or 0 -- 军团伤害
            response.data[self.aname].pdamage = mUseractive.info[self.aname].dm  -- 个人伤害
            response.data[self.aname].HP = activeObj.activeInfo.HP -- boss总血量
            response.data[self.aname].LEFTHP = activeObj.activeInfo.LEFTHP -- boss剩余血量
            response.data[self.aname].bosstype = activeObj.activeInfo.type -- boss类型
            response.data[self.aname].bossnum = activeObj.activeInfo.num -- boss轮数

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 排行榜列表
    function self.action_rankingList(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAllianceActive = getModelObjs("allianceactive",mUserinfo.alliance,true)
        local activeObj = mAllianceActive.getActiveObj(self.aname) 

        response.data[self.aname] = {rankingList = activeObj:getRankingList()}
        response.data[self.aname].rt = activeObj.activeInfo.rt or 0 -- 军团已领取奖励次数
        response.data[self.aname].damage = activeObj.activeInfo.damage or 0-- 总伤害值
        response.data[self.aname].pr = activeObj.activeInfo.pr -- 军团内伤害第一奖励是否被领取

        response.data[self.aname].r =  mUseractive.info[self.aname].r -- 玩家当前有没有领取排行榜奖励
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 排行榜奖励(跨服军团排行榜)
    function self.action_rankingReward(request)
        local response = self.response
        local uid = request.uid
        local ranking = request.params.ranking
        local zoneId = getZoneId()
        local ts = getClientTs()

        if not ranking then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if ts < tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local aid = uobjs.getModel('userinfo').alliance
        if aid <=0 then
            response.ret = -8012
            return response
        end

        if mUseractive.info[self.aname].r ==  1 then
            response.ret = -1976
            return response
        end

        local mAllianceActive = getModelObjs("allianceactive",aid)
        local activeObj = mAllianceActive.getActiveObj(self.aname)

        local myRanking = nil
        local rankingList = activeObj:getRankingList()
        if type(rankingList) == "table" then
            for k,v in pairs(rankingList) do
                if v[1] == zoneId and v[2] == aid and k == ranking and v[3] >= activeCfg.rLimit then
                    myRanking = k
                    break
                end
            end
        end

        if not myRanking then
            response.ret = -1981
            return response
        end

        local matchid = 0
        for k,v in pairs(activeCfg.section) do
            if myRanking >= v[1] and myRanking <= v[2] then
                matchid = k
                break
            end
        end

        if matchid==0 then
            response.ret = -102
            return response
        end

        -- 判断玩家个人排行榜是否第一
        local  flag  = false
        local plist,prank = self.urank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,aid,uid)
        if prank==1 then
            flag = true
        end

        if not activeObj.activeInfo.pr then
            activeObj.activeInfo.pr = 0
        end

        -- 军团领取次数+1
        activeObj.activeInfo.rt = (activeObj.activeInfo.rt or 0) + 1
        local reward = {}
        local pr = false-- 提示客户端是否领取到军团排行奖励
        -- 领取次数达到上限
        if activeObj.activeInfo.rt > activeCfg.rGetLimit then
            if flag and activeObj.activeInfo.pr==0 then
                for k,v in pairs(activeCfg.serverreward.trank[matchid]) do
                    reward[k] = (reward[k] or 0) + v
                end
                activeObj.activeInfo.pr = 1
            else
                response.ret = -1993
                return response
            end   
        else
            reward = copyTable(activeCfg.serverreward.rank[matchid])
            if flag and activeObj.activeInfo.pr==0 then
                for k,v in pairs(activeCfg.serverreward.trank[matchid]) do
                    reward[k] = (reward[k] or 0) + v
                end
                activeObj.activeInfo.pr = 1
            end
            pr = true
        end
        
        if not next(reward) then
            response.ret = -102
            response.err = "reward is nil"
            return response
        end

        -- 领奖
        if not takeReward(uid, reward) then
            response.ret = -1989
            return response
        end

        mUseractive.info[self.aname].r =  1
        regEventAfterSave(aid,'saveAllianceActive')
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            -- 玩家是否领取到了军团奖励
            if not pr then
                response.data[self.aname].r = 0
            end
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 任务界面
    function self.action_task(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local flag = false
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1

        if type(mUseractive.info[self.aname].tk)~='table' or mUseractive.info[self.aname].t~=weeTs  then
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local max = #v.limit
                local limit = currDay > max and v.limit[max] or v.limit[currDay]
            
                table.insert(mUseractive.info[self.aname].tk,{0,0,limit})-- 当前值 已领取次数 当天限制次数
            end
            mUseractive.info[self.aname].t=weeTs
            flag = true
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

    -- 任务列表中购买礼包
    function self.action_buygift(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        local ts = getClientTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if ts > tonumber(mUseractive.getAcet(self.aname, true)) then
            response.ret = -102
            return response
        end

        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        if type(mUseractive.info[self.aname].tk)~='table' or mUseractive.info[self.aname].t~=weeTs  then
            mUseractive.info[self.aname].tk = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
                local max = #v.limit
                local limit = currDay > max and v.limit[max] or v.limit[currDay]
                table.insert(mUseractive.info[self.aname].tk,{0,0,limit})-- 当前值 已领取次数 当天限制次数
            end
            mUseractive.info[self.aname].t = weeTs
        end

        local len = #activeCfg.serverreward.taskList
        if mUseractive.info[self.aname].tk[len][2]>=mUseractive.info[self.aname].tk[len][3] then
            response.ret = -121
            return response
        end

        local itemcfg = activeCfg.serverreward.taskList[len]
        if itemcfg.type~='hf' then
            response.ret = -120
            return response
        end

        local reward = {}
        local report = {}
        if itemcfg.r then
            for k,v in pairs(itemcfg.r) do
                if string.find(k,'cpem_') then
                    table.insert(report,self.formatreward({[k]=v}))
                    mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                else
                    reward[k] = v
                    table.insert(report,formatReward({[k]=v}))
                end    
            end
        end

        if itemcfg.pool then
            local re,rkey = getRewardByPool(activeCfg.serverreward[itemcfg.pool],1) 
            for k,v in pairs(re) do
                for rk,rv in pairs(v) do
                    table.insert(report,self.formatreward({[rk]=rv}))
                    mUseractive.info[self.aname][rk] = (mUseractive.info[self.aname][rk] or 0) + rv
                end 
            end
        end

        if not mUserinfo.useGem(itemcfg.num) then
            response.ret = -109
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end

        regActionLogs(uid,1,{action = 259, item = "", value = itemcfg.num, params = {}})
        mUseractive.info[self.aname].tk[len][2] = mUseractive.info[self.aname].tk[len][2] + 1 
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end
 
        return response
    end

    -- 打boss界面
    function self.action_boss(request)
        local response = self.response
        local uid=request.uid

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        -- 四种道具
        for i=1,4 do
            if not mUseractive.info[self.aname]['cpem_a'..i] then
                mUseractive.info[self.aname]['cpem_a'..i] = 0
            end 
        end

        if not mUseractive.info[self.aname].dm then
            mUseractive.info[self.aname].dm = 0
        end

        local aid = mUserinfo.alliance
        if aid<=0 then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].adamage = 0 -- 军团伤害
            response.data[self.aname].pdamage = 0  -- 个人伤害
            response.data[self.aname].HP = activeCfg.bossHp -- boss总血量
            response.data[self.aname].LEFTHP = activeCfg.bossHp -- boss剩余血量
            response.data[self.aname].bosstype = 1 -- boss类型
            response.data[self.aname].bossnum = 1 -- boss轮数
            response.ret = 0
            response.msg = 'Success'
            return response
        end

        local aAllianceActive = getModelObjs("allianceactive",aid)
        if not aAllianceActive then
            response.ret = -102
            return response
        end

        local activeObj = aAllianceActive.getActiveObj(self.aname)   
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].adamage = activeObj.activeInfo.damage or 0 -- 军团伤害
            response.data[self.aname].pdamage = mUseractive.info[self.aname].dm  -- 个人伤害
            response.data[self.aname].HP = activeObj.activeInfo.HP -- boss总血量
            response.data[self.aname].LEFTHP = activeObj.activeInfo.LEFTHP -- boss剩余血量
            response.data[self.aname].bosstype = activeObj.activeInfo.type -- boss类型
            response.data[self.aname].bossnum = activeObj.activeInfo.num -- boss轮数
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 个人伤害排行榜
    function self.action_damagerank(request)
        local uid = request.uid
        local response = self.response
 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo =  uobjs.getModel('userinfo')

        if mUserinfo.alliance<=0 then
            response.ret = -8012
            return response
        end
        response.ret = 0
        response.msg = 'success'
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].list = self.urank(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,mUserinfo.alliance,uid)
        return response
    end

    -- 更新个人伤害 
    -- aid 所在军团
    -- damage 本次伤害
    -- pic 头像
    -- 攻击次数
    function self.updamage(mUseractive,aid,uid,damage,pic,num,nickname)
        local ts= getClientTs()
        if aid>0 then
            if ts < tonumber(mUseractive.getAcet(self.aname, true)) then 
                local redis = getRedis()
                local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st..'aid_'..aid
                local damlist = json.decode(redis:get(redkey))

                if type(damlist)~='table' or not next(damlist) then
                    damlist = {}
                end

                local uexit = false
                for k,v in pairs(damlist) do
                    if tonumber(v[1]) == uid then
                        v[2] = nickname
                        v[3] = pic
                        v[4] = damage
                        v[5] = v[5] + num
                        uexit = true
                        break
                    end
                end

                if not uexit then
                    table.insert(damlist,{uid,nickname,pic,damage,num,ts})-- uid,昵称,头像,伤害,攻击次数,创建时间
                end

                redis:set(redkey,json.encode(damlist))
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)     
            end
        end
    end

    -- 军团成员个人积分排行榜
    function self.urank(st,et,aid,uid)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'aid_'..aid
        local redis = getRedis()
        local damlist = json.decode(redis:get(redkey))
       
        if type(damlist)~='table' or not next(damlist) then
            damlist = {}
        end
        -- 排序
        table.sort( damlist,function ( a,b )  
            -- body  
            if a[4]==b[4] then  
                return a[6] < b [6]
            end 
    
            return a[4] > b[4]  
        end )  

        local list = {}
        local myrank = 0
        local num = 0 -- 显示前5
        for k,v in pairs(damlist) do
            if num>=5 then
                break
            end    
            table.insert(list,v)  
            num = num + 1 
            if v[1]==uid then
                myrank = num
            end
        end

        return list,myrank
    end

    return self
end

return api_active_cpem
