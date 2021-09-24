-- desc: 圣帕特里克
-- user: liming
local function api_active_dresshat(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'dresshat',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'dresshat'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
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
        -- activity_setopt(uid,'dresshat',{act='charge',num=200})
        -- activity_setopt(uid,'dresshat',{act=6,num=1,w=1})
         --获取玩家捐献值
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local alldresshat_a1 = 0 --绿色
        local alldresshat_a2 = 0 --棕色
        local alldresshat_a3 = 0 --黄色
        if type(contribute)=='table' then
             alldresshat_a1 = contribute.info.alldresshat_a1  
             alldresshat_a2 = contribute.info.alldresshat_a2
             alldresshat_a3 = contribute.info.alldresshat_a3  
        end 
        local totaldresshat = 0
        for k,v in pairs(activeCfg.singleNeed) do
            totaldresshat = totaldresshat + v
        end
        local alldresshat = alldresshat_a1+alldresshat_a2+alldresshat_a3
        local rate = string.format("%.2f",alldresshat/totaldresshat)
        local flag = false
        if type(mUseractive.info[self.aname].giftlog) ~= 'table' then
        	flag = true
        	mUseractive.info[self.aname].giftlog = {}--帽子奖励
        	local activeCfg = mUseractive.getActiveConfig(self.aname)
        	local items = table.length(activeCfg.supportNeed)
        	for i = 1,items do
        		table.insert(mUseractive.info[self.aname].giftlog,0)
        	end

            mUseractive.info[self.aname].gem = 0--累计充值
            mUseractive.info[self.aname].gn = 0 --累计充值领取奖励次数

            -- 三种道具
            mUseractive.info[self.aname].dresshat_a1 = 0
            mUseractive.info[self.aname].dresshat_a2 = 0
            mUseractive.info[self.aname].dresshat_a3 = 0
            -- 积分
            mUseractive.info[self.aname].s = 0
            mUseractive.info[self.aname].c1 = 0--- 道具1使用的个数
            mUseractive.info[self.aname].c2 = 0
            mUseractive.info[self.aname].c3 = 0

            mUseractive.info[self.aname].shop = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
            mUseractive.info[self.aname].fb = 0 -- facebook分享奖励
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].alldresshat_a1 = alldresshat_a1
        response.data[self.aname].alldresshat_a2 = alldresshat_a2
        response.data[self.aname].alldresshat_a3 = alldresshat_a3
        response.data[self.aname].rate = rate
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 捐献
    function self.action_contribute(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- mUseractive.info[self.aname].dresshat_a1 = 500
        -- mUseractive.info[self.aname].dresshat_a2 = 500
        -- mUseractive.info[self.aname].dresshat_a3 = 500
        local dresshat_as = {}
        table.insert(dresshat_as,mUseractive.info[self.aname].dresshat_a1)
        table.insert(dresshat_as,mUseractive.info[self.aname].dresshat_a2)
        table.insert(dresshat_as,mUseractive.info[self.aname].dresshat_a3)
        local flag = false
        for k,v in pairs(dresshat_as) do
            if v > 0 then
               flag = true
               break
            end
        end
        if flag == false then
            response.ret = -102
            return response
        end
        local reward = {} -- 常规奖励
        local spprop = {} -- 属于本活动的道具
        local getScore = activeCfg.getScore
        local singleNeed = activeCfg.singleNeed
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local alldresshat_a1 = 0 --绿色
        local alldresshat_a2 = 0 --棕色
        local alldresshat_a3 = 0 --黄色
        if type(contribute)=='table' then
             alldresshat_a1 = contribute.info.alldresshat_a1  
             alldresshat_a2 = contribute.info.alldresshat_a2
             alldresshat_a3 = contribute.info.alldresshat_a3  
        end 
        local totaldresshat = 0
        for k,v in pairs(singleNeed) do
            totaldresshat = totaldresshat + v
        end
        local score = 0
        for id,num in pairs(dresshat_as) do
            if num > 0 then
                for i=1,num do
                    local result = getRewardByPool(activeCfg.serverreward['pool'..id])
                    for k,v in pairs(result) do
                        if string.find(k,'dresshat') then
                            spprop[k]=(spprop[k] or 0)+v
                        else
                            reward[k]=(reward[k] or 0)+v
                        end
                    end
                end
                mUseractive.info[self.aname].s = mUseractive.info[self.aname].s + getScore[id]*num
                mUseractive.info[self.aname]['c'..id] = mUseractive.info[self.aname]['c'..id] + num
                mUseractive.info[self.aname]['dresshat_a'..id] = 0
                score = score + getScore[id]*num
                if id==1 then
                    if alldresshat_a1 + num > singleNeed[id] then
                      alldresshat_a1 = singleNeed[id] 
                    else
                      alldresshat_a1 = alldresshat_a1 + num
                    end
                elseif id==2 then
                    if alldresshat_a2 + num > singleNeed[id] then
                      alldresshat_a2 = singleNeed[id] 
                    else
                      alldresshat_a2 = alldresshat_a2 + num
                    end
                else
                    if alldresshat_a3 + num > singleNeed[id] then
                      alldresshat_a3 = singleNeed[id] 
                    else
                      alldresshat_a3 = alldresshat_a3 + num
                    end
                end
            end
        end
        local alldresshat = alldresshat_a1+alldresshat_a2+alldresshat_a3
        local rate = string.format("%.2f",alldresshat/totaldresshat)
        if not setFreeData(self.aname..mUseractive.info[self.aname].st, {alldresshat_a1=alldresshat_a1,alldresshat_a2=alldresshat_a2,alldresshat_a3=alldresshat_a3}) then
             response.ret=-106
             return response
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
        local tmpspprop = {}
        local key = activeCfg.serverreward.scoreItem[1]
        tmpspprop[key] = (tmpspprop[key] or 0)+score
        for k,v in pairs(tmpspprop) do
            spprop[k]=(spprop[k] or 0)+v
        end
        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        -- ptb:e(mUseractive.info[self.aname])
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].getscore = score
            response.data[self.aname].alldresshat_a1 = alldresshat_a1
            response.data[self.aname].alldresshat_a2 = alldresshat_a2
            response.data[self.aname].alldresshat_a3 = alldresshat_a3
            response.data[self.aname].rate = rate
            response.ret  = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 累计充值奖励
    function self.action_charge(request)
        local uid = request.uid
        local response = self.response

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local num = mUseractive.info[self.aname].gn
        if num <= 0 then
            response.ret = -102
            return response
        end
        
        mUseractive.info[self.aname].gem = mUseractive.info[self.aname].gem - num*activeCfg.rechargeNum
        mUseractive.info[self.aname].gn = 0 

        local reward = {}
        local spprop = {}
        for  k,v in pairs(activeCfg.serverreward.recharge) do
            if string.find(k,'dresshat') then
                spprop[k]=(spprop[k] or 0)+v*num
            else
                reward[k]=(reward[k] or 0)+v*num
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
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    -- 领取全服奖励 
    function self.action_gift(request)
        local uid = request.uid
        local response = self.response
        local item = request.params.id

        if item > 4 or item < 1 then
            response.ret =-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].giftlog[item] == 1 then
            response.ret = -1976
            return response
        end
        local supportNeed = activeCfg.supportNeed[item]
        local contribute=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local alldresshat_a1 = 0 --绿色
        local alldresshat_a2 = 0 --棕色
        local alldresshat_a3 = 0 --黄色
        if type(contribute)=='table' then
             alldresshat_a1 = contribute.info.alldresshat_a1  
             alldresshat_a2 = contribute.info.alldresshat_a2
             alldresshat_a3 = contribute.info.alldresshat_a3  
        end 
        local alldresshat_as = alldresshat_a1 + alldresshat_a2 + alldresshat_a3
        if alldresshat_as < supportNeed then
            response.ret = -102
            return response
        end
        local reward = {}
        local spprop = {}
        for  k,v in pairs(activeCfg.serverreward['gift'..item]) do
            if string.find(k,'dresshat') then
                spprop[k]=(spprop[k] or 0)+v
            else
                reward[k]=(reward[k] or 0)+v
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
        mUseractive.info[self.aname].giftlog[item] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = -106
        end

        return response
    end

    --  商店兑换
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local item =  request.params.id
        local num = request.params.n or 1
        if not item then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = activeCfg.serverreward.shopList[item]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end
        if  type(mUseractive.info[self.aname].shop)~='table' then
            mUseractive.info[self.aname].shop = {}
            local snum = table.length(activeCfg.serverreward.shopList)
            for i=1,snum do
                table.insert(mUseractive.info[self.aname].shop,0)
            end         
        end
        if mUseractive.info[self.aname].shop[item]+num>iteminfo.limit then
            response.ret = -1987
            return response
        end
        local price = iteminfo.price*num
        if mUseractive.info[self.aname].s < price then
            response.ret = -102
            return response
        end
        local reward ={}
        reward[iteminfo.serverreward[1]] = iteminfo.serverreward[2]*num
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end

        mUseractive.info[self.aname].s = mUseractive.info[self.aname].s - price
        mUseractive.info[self.aname].shop[item] = mUseractive.info[self.aname].shop[item] + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end

    -- facebook分享奖励
    function self.action_fbreward(request)
        local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
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
            if string.find(k,'dresshat') then
                spprop[k]=(spprop[k] or 0)+v
            else
                reward[k]=(reward[k] or 0)+v
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
        local ts= getClientTs()
        local weeTs = getWeeTs()
        
        if not zoneid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if not uid then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 等级限制
        if mUserinfo.level<activeCfg.levelLimit then
            response.ret = -301
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local url = nil
        local redis = getRedis()
        local urlkey = "facebookshareurl"
        local fbkey = "zid."..getZoneId()..urlkey
        local fburl=redis:get(fbkey)

        if fburl then
            url = fburl
        else
            local freedata = getFreeData(urlkey)
            url = freedata.info.url
            redis:set(fbkey,url)    
        end

        response.data.fb = mUseractive.info[self.aname].fb or 0
        response.data.url =  url
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    return self
end

return api_active_dresshat
