-- desc: 连续消费
-- user: liming
local function api_active_lxxf(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'lxxf',
    }

    -- 初始化数据
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        if not uid then
            response.ret = -102
            return response
        end

        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        local totalDay = math.ceil(math.abs(mUseractive.info[self.aname].et - mUseractive.info[self.aname].st)/(24*3600))
        -- 初始化签到
        local flag = false
        if not mUseractive.info[self.aname].dayInfo then 
            flag = true
            mUseractive.info[self.aname].dayInfo = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].dayInfo,0)
            end
        end
        if not mUseractive.info[self.aname].giftlog then 
            flag = true
            mUseractive.info[self.aname].giftlog = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].giftlog,0)
            end
            table.insert(mUseractive.info[self.aname].giftlog,0)
        end
        if not mUseractive.info[self.aname].count then 
            flag = true
            mUseractive.info[self.aname].count = 0 
        end
        -- test
        -- local gems=150       
        -- if not mUserinfo.useGem(gems) then
        --     response.ret = -109
        --     return response
        -- end
        -- flag=1

        if flag then
            if not uobjs.save() then
                response.ret = -102
                return response
            end
        end 
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取奖励
    function self.action_gift(request)
        local response = self.response
        local uid = request.uid
        local id = request.params.id  
        
        if not uid or not id then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')   
        local activeCfg = mUseractive.getActiveConfig(self.aname)
   
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if not mUseractive.info[self.aname].dayInfo then
            response.ret = -102
            return response
        end

        if not mUseractive.info[self.aname].giftlog then
            response.ret = -102
            return response
        end
        
        local bigReward = copyTable(activeCfg.serverreward.bigReward)
        local days = copyTable(activeCfg.serverreward.days)
        bigReward = bigReward[1]
        local day
        local needcharge
        local smallReward
        for k,v in pairs(days) do
            day = k
            needcharge = v[1]
            smallReward = v[2]
        end
      
        if mUseractive.info[self.aname].giftlog[id] == 1 then
            response.ret = -1976
            return response
        end
        local maxId = #mUseractive.info[self.aname].giftlog
        local reward = {}
        local report = {}
        local num = 0
        local maxnum = 0 --最大连续次数
        if id == maxId then
            for k,v in pairs(mUseractive.info[self.aname].dayInfo) do
                if v < needcharge then
                    if num > maxnum then
                        maxnum = num
                    end
                    num = 0
                else
                    num = num + 1
                    if num > maxnum then
                        maxnum = num
                    end
                end
            end
            if maxnum < day then
                response.ret = -1981
                return response
            end
            reward = bigReward
            table.insert(report, formatReward(bigReward))
        else
            if not table.contains(table.keys(mUseractive.info[self.aname].dayInfo),id) then
                response.ret = -102
                return response
            end
            if mUseractive.info[self.aname].dayInfo[id]<needcharge then
                response.ret = -1981
                return response
            end
            for k,v in pairs(smallReward) do
                reward[v[1]] = (reward[v[1]] or 0) + v[2]
                table.insert(report, formatReward({[v[1]]=v[2]}))
            end
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        mUseractive.info[self.aname].giftlog[id] = 1
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
    
    -- 单日补签
    function self.action_single(request)
        local response = self.response
        local uid=request.uid
        local id = request.params.id  
        if not uid or not id then
            response.ret = -102
            return response
        end
        local weeTs = getWeeTs()
        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1

        local totalDay = math.ceil(math.abs(mUseractive.info[self.aname].et - mUseractive.info[self.aname].st)/(24*3600))
        
        if not mUseractive.info[self.aname].dayInfo then 
            response.ret = -102
            return response
        end
        if id >= currDay then
            response.ret = -102
            return response
        end

        local supply = activeCfg.supply

        local count = mUseractive.info[self.aname].count + 1

        if count > #supply then
            count =  #supply
        end

        local gems = supply[count]
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        
        local days = copyTable(activeCfg.serverreward.days)
        local needcharge
        for k,v in pairs(days) do
            needcharge = v[1]
        end

        mUseractive.info[self.aname].count = mUseractive.info[self.aname].count + 1
        mUseractive.info[self.aname].dayInfo[id] = needcharge
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 全部补签
    function self.action_all(request)
        local response = self.response
        local uid=request.uid
        if not uid then
            response.ret = -102
            return response
        end
        local weeTs = getWeeTs()
        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 当前是第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1

        -- currDay = 13

        local totalDay = math.ceil(math.abs(mUseractive.info[self.aname].et - mUseractive.info[self.aname].st)/(24*3600))

        if not mUseractive.info[self.aname].dayInfo then 
            response.ret = -102
            return response
        end
        local days = copyTable(activeCfg.serverreward.days)
        local day
        local needday
        local needcharge
        local tempnum = 0
        local num = 0--补签次数
        for k,v in pairs(days) do
            needday = k
            day = k + 1
            needcharge = v[1]
        end
        local tablenum = {}
        local temptablenum = {}
        local b = currDay - needday 
        if mUseractive.info[self.aname].dayInfo[currDay] >= needcharge then
            b = currDay - needday + 1
        end
        if b < 1 then
            for k,v in pairs(mUseractive.info[self.aname].dayInfo) do
                if k >= currDay then
                    break
                end
                if v < needcharge then
                    num = num + 1
                    table.insert(tablenum,k) 
                end
            end
        else
            local c = 0
            for a=1,b do
                c = 0
                tempnum = 0 
                temptablenum = {}
                for k,v in pairs(mUseractive.info[self.aname].dayInfo) do
                    if c >= needday then
                        break
                    end
                    if k >= a then
                        if v < needcharge then
                           tempnum = tempnum + 1
                           table.insert(temptablenum,k)
                        end 
                        c = c + 1
                    end  
                end
                if a == 1 then 
                    num = tempnum
                    tablenum = temptablenum
                else
                    if tempnum < num then
                        num = tempnum
                        tablenum = temptablenum
                    end
                end
            end 
        end
        
        --不需要补签
        if num < 1 then 
            response.ret = -102
            return response
        end
        local gems = 0
        local supply = activeCfg.supply
        local i = mUseractive.info[self.aname].count + 1
        local j = mUseractive.info[self.aname].count + num
    
        for i=i,j do 
           if i > #supply then
              i =  #supply
           end
           gems = gems + supply[i]
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems > 0 then
            regActionLogs(uid, 1, {action = 197, item = "", value = gems, params = {num = num}})
        end
        for k,v in pairs(tablenum) do
            mUseractive.info[self.aname].dayInfo[v] = needcharge
        end
        mUseractive.info[self.aname].count = mUseractive.info[self.aname].count + num
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data.tablenum = tablenum
            response.data.gems = gems
            response.data.num = num
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end
    

    return self
end

return api_active_lxxf
