-- desc: 勋章兑换
-- user: liming
local function api_active_medal(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'medal',
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


        local flag = false
        if not mUseractive.info[self.aname].num then 
            flag = true
            mUseractive.info[self.aname].num = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].num,0)
                mUseractive.info[self.aname].num[i] = {}
                for j=1,2 do
                    table.insert(mUseractive.info[self.aname].num[i],0)
                end
            end
        end
        if not mUseractive.info[self.aname].gift then 
            flag = true
            mUseractive.info[self.aname].gift = {}
            for i=1,totalDay do
                table.insert(mUseractive.info[self.aname].gift,0)
                mUseractive.info[self.aname].gift[i] = {}
                for j=1,2 do
                    table.insert(mUseractive.info[self.aname].gift[i],0)
                end
            end
        end
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

    -- 兑换
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local item=request.params.item--兑换哪一个
        local nums=request.params.num or 1 --兑换个数
        nums = math.floor(nums)
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        -- 活动检测 
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local ts= getClientTs()
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = copyTable(activeCfg.serverreward.changeList[item])
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end

        -- 物品兑换次数不足
        if mUseractive.info[self.aname].num[currDay][item] + nums >iteminfo.changeLimit then
            response.ret=-23305
            return response
        end
        local cost = iteminfo.serverreward
        local tempcost = 0
        local tempmax = 0
        local cost1 = {}
        local cost2 = {}
        local cost3 = {}
        local step1 = math.ceil((mUseractive.info[self.aname].num[currDay][item] + nums)/iteminfo.upStep)
        local step2 = math.ceil((mUseractive.info[self.aname].num[currDay][item] + 1)/iteminfo.upStep)
        for k,v in pairs(cost) do
            tempcost = v+(step1-1)*(iteminfo.upCount[k])
            tempmax = v+(iteminfo.upLimit)*(iteminfo.upCount[k])
            if tempcost>tempmax then
                tempcost = tempmax
            end
            cost1[k] = tempcost
        end
        for k,v in pairs(cost) do
            tempcost = v+(step2-1)*(iteminfo.upCount[k])
            tempmax = v+(iteminfo.upLimit)*(iteminfo.upCount[k])
            if tempcost>tempmax then
                tempcost = tempmax
            end
            cost2[k] = tempcost
        end
        for k,v in pairs(cost1) do
            cost3[k] = ((v-cost2[k])/iteminfo.upCount[k])+1
        end
        local totalstep = 0
        if #cost3==1 then
            for k,v in pairs(cost3) do
                totalstep = v
            end
        else
            for k,v in pairs(cost3) do
                totalstep = v 
            end
        end
   
        local balance = (mUseractive.info[self.aname].num[currDay][item] + nums)%iteminfo.upStep

        for k,v in pairs(cost1) do
            local needcost = 0
            if totalstep==1 then
                needcost = needcost + nums*v
            else
                for i=totalstep,1,-1 do
                    if i==totalstep then
                            if (step1-1)>=iteminfo.upLimit then
                                needcost = needcost+(mUseractive.info[self.aname].num[currDay][item]+nums-iteminfo.upLimit*iteminfo.upStep)*v
                            else
                                if balance==0 then
                                    needcost = needcost + iteminfo.upStep*v
                                else
                                   needcost = needcost + balance*v
                               end
                            end
                    elseif i==1 then
                        if (step1-1)>=iteminfo.upLimit then
                            needcost = needcost+(nums-(mUseractive.info[self.aname].num[currDay][item]+nums-iteminfo.upLimit*iteminfo.upStep)-(totalstep-2)*iteminfo.upStep)*v
                        else
                            local midnum = totalstep-2
                            if midnum < 1 then
                               midnum = 0
                            end
                            if balance==0 then
                                if nums <= iteminfo.upStep then
                                    needcost = needcost + (nums-midnum*iteminfo.upStep)*v
                                else
                                    needcost = needcost + (nums-iteminfo.upStep-midnum*iteminfo.upStep)*v
                                end
                            else
                                needcost = needcost + (nums - balance - midnum*iteminfo.upStep)*v
                            end
                        end
                    else
                        needcost = needcost + iteminfo.upStep*v
                    end
                    v = v - iteminfo.upCount[k]
                end
            end
            cost1[k] = needcost
        end
        -- ptb:e(cost1)
        cost1 = formatReward(cost1)
        for k,v in pairs(cost1) do
            if k=='u' then
               if not mUserinfo.useGem(v.gems) then
                    response.ret = -109
                    return response
                end
                if v.gems>0 then
                    regActionLogs(uid,1,{action = 204, item = "", value = v.gems, params = {num = nums}})
                end 
            else
                if v ~= nil then
                    if not mBag.usemore(v) then
                        response.ret=-1996
                        return response
                    end
                end
            end
        end
       
        -- 增加兑换次数
        mUseractive.info[self.aname].num[currDay][item]=mUseractive.info[self.aname].num[currDay][item]+nums
        local tmpreward = iteminfo.gets
        local reward = {}
        local giftnum = 0
        for k,v in pairs(tmpreward) do
            giftnum = v*nums
            reward[k] = (reward[k] or 0) + giftnum
        end
        -- 增加物品个数
        mUseractive.info[self.aname].gift[currDay][item]=mUseractive.info[self.aname].gift[currDay][item]+giftnum
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].cost = cost1
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end
    

    return self
end

return api_active_medal
