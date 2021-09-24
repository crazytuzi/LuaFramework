--
-- desc: 幸运锦鲤
-- user: chenyunhe
--
local function api_active_xyjl(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'xyjl', 
    }
    self._cronApi = {
        ["action_randjl"] = true,
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'xyjl'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end

    function self.before(request)
   
    end

     -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

          -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false

        -- 参与券
        if not mUseractive.info[self.aname].xyjl_a1 then
            flag = true
            mUseractive.info[self.aname].xyjl_a1 = 0
        end

        -- 参与时间
        if not mUseractive.info[self.aname].jt then
            flag = true
            mUseractive.info[self.aname].jt = 0
        end

        -- 今日充值钻石数
        if not mUseractive.info[self.aname].td then
            flag = true
            mUseractive.info[self.aname].td = 0
        end

        if mUseractive.info[self.aname].t~=weeTs then
            mUseractive.info[self.aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
              table.insert(mUseractive.info[self.aname].task,0) -- 0未完成 1可领取 2已领取   
            end

            mUseractive.info[self.aname].t = weeTs -- 任务刷新时间
            mUseractive.info[self.aname].td = 0-- 今日充值钻石数
            flag = true
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        local last = self.getlast(mUseractive.info[self.aname].st)
        if type(last)=='table' and next(last)  and tonumber(last.uid)>0 then
            response.data[self.aname].lastuid = last.uid
            response.data[self.aname].lastuname = last.nickname
            response.data[self.aname].lastserver = last.zoneid
            response.data[self.aname].lastpic = last.pic
        end

        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 判断时间是否为锁定区间
    function self.checktime()
        local ts = getClientTs()
        local weeTs = getWeeTs()
        if ts>weeTs+23*3600+60 and ts<weeTs+24*3600 then
            return false
        end

        return true
    end

    -- 领取任务奖励
    function self.action_treward(request)
        local response = self.response
        local uid=request.uid
        local tid = request.params.tid
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if not tid or not self.checktime() then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].t~=weeTs then
            mUseractive.info[self.aname].task = {}
            for k,v in pairs(activeCfg.serverreward.taskList) do
              table.insert(mUseractive.info[self.aname].task,0) -- 0未完成 1可领取 2已领取   
            end

            mUseractive.info[self.aname].t = weeTs -- 任务刷新时间
            mUseractive.info[self.aname].td = 0-- 今日充值钻石数
        end

        if mUseractive.info[self.aname].task[tid]~=1 then
            response.ret = -102
            return response
        end

        local tkcfg = activeCfg.serverreward.taskList[tid]
        if not tkcfg then
            response.ret = -120
            return response
        end

        local report = {}
        local reward = {}
        local actprop = {}
        for k,v in pairs(tkcfg.r) do
            if string.find(k,"xyjl_a1") then   
                actprop[k] = (actprop[k] or 0) + v
            else
                reward[k] = (reward[k] or 0) + v
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end

            for k,v in pairs(reward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if next(actprop) then
            for k,v in pairs(actprop) do
                mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                table.insert(report,self.formatreward({[k]=v}))
            end
        end

        mUseractive.info[self.aname].task[tid] = 2
        if uobjs.save() then
            processEventsAfterSave()
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report 
           
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response   
    end

    -- 参与
    function self.action_join(request)
        local uid = request.uid
        local zid = getZoneId()
        local response = self.response
        local ts = getClientTs()
        local weeTs = getWeeTs()

        if not self.checktime() then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

          -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)         

        if mUseractive.info[self.aname].jt==weeTs then
            response.ret = -102
            return response
        end

        if (mUseractive.info[self.aname].xyjl_a1 or 0)<=0 then
            response.ret = -102
            return response
        end

        mUseractive.info[self.aname].jt=weeTs
        mUseractive.info[self.aname].xyjl_a1 = mUseractive.info[self.aname].xyjl_a1 - 1            
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()

            local senddata={
                zid=zid,
                acname=self.aname,
                st = mUseractive.info[self.aname].st,
                index = self.getnum(mUseractive.info[self.aname].st),
                nickname = mUserinfo.nickname,
                pic = mUserinfo.pic,
                uid = 0,
                score = activeCfg.joinRate[mUserinfo.vip] or 0,
                act = 0,-- 1 设定内部号或者指定号
            }

            local flags = mUserinfo.flags or {}
            if table.contains({1,2},senddata.index) and senddata.score>0 and not flags.xyjl then
                require("lib.crossActivity").upxyjl(senddata) 
            end

            response.data[self.aname] = mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 判断是第几轮
    function self.getnum(ast)
        local ts = getClientTs()
        return math.floor(math.abs(ts-getWeeTs(ast))/(24*3600)) + 1
    end

    -- 获取上一期获奖玩家信息 st活动开启时间 index  第几轮的
    function self.getlast(st)
        local num = self.getnum(st)
        local weeTs = getWeeTs()
        local ts = getClientTs()
        if num>1 and ts<weeTs+23*3600 then
            num = num-1
        end

        local index = num+1000
        local redkey = "last_xyjl_"..index.."_"..st
        local redis = getRedis()
        local lastdata = json.decode(redis:get(redkey))
        if type(lastdata)=='table' and next(lastdata) then
            local last = {}
            if tonumber(lastdata.uid)>0 then
                return {uid=tonumber(lastdata.uid),pic=tonumber(lastdata.pic),nickname=lastdata.nickname,zoneid=tonumber(lastdata.zoneid)}
            end
        end
        local senddata={
            st = st,
            index = index,
            act = 0,
        }
        local r = require("lib.crossActivity").lastresult(senddata)
        if type(r)=='table' and next(r)  and tonumber(r.uid)>0 then
            local tmp = {uid=tonumber(r.uid),pic=tonumber(r.alliancename),nickname=r.nickname,zoneid=r.zoneid}
            redis:set(redkey,json.encode(tmp))
            redis:expireat(redkey,weeTs+86400*2)
            return tmp
        end

        return r
    end

    -- 内定玩家
    function self.nduser(index)
        local plat = getClientPlat()
        local xyjlCfg=getConfig("xyjlCfg")
        if type(xyjlCfg[plat])=='table' and type(xyjlCfg[plat][index])=='table' and next(xyjlCfg[plat][index]) then
            return true,xyjlCfg[plat][index] 
        end

        return false,{}
    end

    -- 随机本服的锦鲤
    function self.action_randjl(request)
        local response = self.response
        require "model.active"
        local zid=getZoneId()
        
        local ts = getClientTs()
        local weeTs = getWeeTs()
       
        local mActive = model_active()
        local actives = mActive.toArray()

        if type(actives) == 'table' and actives[self.aname] then
            local ainfo = actives[self.aname]
            local st = tonumber(ainfo.st)
            local et = tonumber(ainfo.et)

            -- 获取第几轮
            local index = self.getnum(st) 
            local ndflag,ndcfg = self.nduser(index)
            -- 如果不是内定 需要检测跨服上是否已经结算出服
            if not ndflag then
                local last = self.getlast(st)
                if type(last)~='table' or tonumber(last.zoneid)~=zid or tonumber(last.uid)>0 then
                    response.ret = 0
                    response.msg = 'Success'
                    return response
                end
            else
                -- 如果不是配置的服pass
                if ndcfg.zid~=zid then
                    response.ret = 0
                    response.msg = 'Success'
                    return response
                end
            end

            local activeCfg = getConfig("active/" .. self.aname)[tonumber(ainfo.cfg)]
            local pool = {{100},{},{}}
            local pool1 = {{100},{},{}} 
            local rflag = false

            if not ndflag then
                local result = getDbo():getAllRows("select uid,info from useractive where info like '%xyjl%'")  
                for k,v in pairs(result or {}) do
                    local info = json.decode(v.info)
                    local uid = tonumber(v.uid)

                    local fl = 0
                    -- 被选为锦鲤的玩家 不会再被选中
                    local uobjs = getUserObjs(uid,true)
                    local userinfo = uobjs.getModel('userinfo')
                    if type(userinfo.flags)=='table' and userinfo.flags.xyjl then
                        fl=1
                    end
                    local rate = activeCfg.rechargeRate[tonumber(userinfo.vip)] or 0
                    
                    -- 计算玩家的权重
                    local gems = math.ceil((info[self.aname].gems or 0)*rate)
                    if fl==0 and info[self.aname] and tonumber(info[self.aname].st)==st and tonumber(info[self.aname].jt or 0)==weeTs and gems>0 then
                        table.insert(pool[2],gems)
                        table.insert(pool[3],uid)
                        rflag = true
                    end

                    if fl==0 and info[self.aname] and tonumber(info[self.aname].st)==st and tonumber(info[self.aname].jt or 0)==weeTs then
                        table.insert(pool1[2],1)
                        table.insert(pool1[3],uid)
                    end
                end

                if not next(pool[2]) and next(pool1[2]) then
                    pool = copyTable(pool1)
                    rflag = true
                    writeLog('xyjl:pool为空，取pool1纠正',"xyjluid")
                end
            else
                pool = {{100},{100},{ndcfg.uid}}-- 设定内部号
                rflag = true
            end

            if rflag then
                local rd,rk = getRewardByPool(pool,1)
                local uid = tonumber(rd[1])

                local uobjs = getUserObjs(uid,true)
                local mUserinfo = uobjs.getModel('userinfo')

                -- 发邮件奖励
                local gift = 15
             
                local redkey = "xyjl_"..index.."_"..st
                local redis = getRedis()
                local sendflag = redis:get(redkey)

                if type(activeCfg.serverreward['carpGift'..index])=='table' and not sendflag then
                    local reward = {}
                    for k,v in pairs(activeCfg.serverreward['carpGift'..index]) do
                        reward[k] = (reward[k] or 0) + v   
                    end

                    writeLog('xyjl:随机uid='..uid..'---ts='..ts,"xyjluid")
                    -- 同步跨服结果
                    local senddata={
                        zid=zid,
                        acname=self.aname,
                        st = st,
                        index = 1000+index,
                        pic = mUserinfo.pic,
                        uid = uid,
                        nickname = mUserinfo.nickname,
                        score =  0,
                        act = ndflag and 1 or 0,
                    }

                    local r = require("lib.crossActivity").upxyjl(senddata)
                    if r then
                        --reward={h={props_p588=2,props_p230=1,props_p4917=2,props_p881=100},q={p={{p588=2,index=1},{p230=1,index=2},{p4917=2,index=3},{p881=100,index=4}}}},
                        local item = {h=reward,q=formatReward(reward)}
                        local content = {i=index}
                        -- 给玩家发邮件 标题和内容描述 这里只是占位
                        local ret = MAIL:mailSent(uid,0,uid,mUserinfo.nickname,'','锦鲤',content,1,0,gift,item)
                        if ret then
                            redis:set(redkey,1)
                            redis:expireat(redkey,et)

                            writeLog('xyjl发送邮件:uid'..uid..'ts='..ts,"xyjluid")
                        end

                        if type(mUserinfo.flags)~='table' then
                            mUserinfo.flags = {}
                        end
                        mUserinfo.flags.xyjl = 1
                    else
                        writeLog('xyjl更新跨服失败:senddata--'..json.encode(senddata),"xyjluid")
                    end
                    uobjs.save()
                end
            else
                writeLog('pool为空',"xyjluid")
            end            
        end
        writeLog('zid_ok'..zid,'xyjluid')
        response.ret = 0
        response.msg = 'Success'

        return response
    end
   
    return self
end

return api_active_xyjl
