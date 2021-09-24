--
-- desc: 装扮圣诞树
-- user: chenyunhe
--
local function api_active_dresstree(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'dresstree',
    }

    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'dresstree'
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        local flag = false
        if type(mUseractive.info[self.aname].giftlog) ~= 'table' then
        	flag = true
        	mUseractive.info[self.aname].giftlog = {}--圣诞树奖励
        	local activeCfg = mUseractive.getActiveConfig(self.aname)
        	local items = table.length(activeCfg.supportNeed)
        	for i = 1,items do
        		table.insert(mUseractive.info[self.aname].giftlog,0)
        	end
            table.insert(mUseractive.info[self.aname].giftlog,0)--最终大奖

            mUseractive.info[self.aname].gem = 0--累计充值
            mUseractive.info[self.aname].gn = 0 --累计充值领取奖励次数
            mUseractive.info[self.aname].single = 0 --单笔充值 可领取次数

            -- 三种道具
            mUseractive.info[self.aname].dresstree_a1 = 0
            mUseractive.info[self.aname].dresstree_a2 = 0
            mUseractive.info[self.aname].dresstree_a3 = 0
            --- 三种积分
            mUseractive.info[self.aname].s1 = 0--道具1对应获得积分
            mUseractive.info[self.aname].s2 = 0
            mUseractive.info[self.aname].s3 = 0

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
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 装扮
    function self.action_lottery(request)
        local response = self.response
        local uid=request.uid
        local itemid = request.params.id -- 装扮的是哪个区块
        if itemid > 3 or itemid < 1 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local proid = 'dresstree_a'..itemid
        local num = mUseractive.info[self.aname][proid] or 0
        if  num <=0 then
            response.ret = -102
            return response
        end

        local reward = {} -- 常规奖励
        local spprop = {} -- 属于本活动的道具
        for i=1,num do
            local result,rekey = getRewardByPool(activeCfg.serverreward['pool'..itemid],1)
            for k,v in pairs(result) do
                for vk,val in pairs(v) do
                    if string.find(vk,'dresstree') then
                        spprop[vk]=(spprop[vk] or 0)+val
                    else
                        reward[vk]=(reward[vk] or 0)+val
                    end
                end
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

        local score = num*activeCfg.getScore[itemid]
        mUseractive.info[self.aname][proid] = 0
        mUseractive.info[self.aname]['s'..itemid] =(mUseractive.info[self.aname]['s'..itemid] or 0) + score
        mUseractive.info[self.aname]['c'..itemid] =(mUseractive.info[self.aname]['c'..itemid] or 0) + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].getscore = score
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local gems = mUseractive.info[self.aname].gem or 0
        local gn = mUseractive.info[self.aname].gn or 0 
        local num = math.floor((gems-gn*activeCfg.rechargeNum[2])/activeCfg.rechargeNum[2])

        if num <= 0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local spprop = {}
        for  k,v in pairs(activeCfg.serverreward.recharge2) do
            if string.find(v[1],'dresstree') then
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

        mUseractive.info[self.aname].gn = mUseractive.info[self.aname].gn + 1  
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

    function self.action_single(request)
        local uid = request.uid
        local response = self.response

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local num = mUseractive.info[self.aname].single or 0
        if num <= 0 then
            response.ret = -102
            return response
        end

        local reward = {}
        local spprop = {}
        for  k,v in pairs(activeCfg.serverreward.recharge1) do
            if string.find(v[1],'dresstree') then
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

        mUseractive.info[self.aname].single = mUseractive.info[self.aname].single - 1
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

    -- 领取装扮区域奖励 包含大奖
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

        if mUseractive.info[self.aname].giftlog[item] == 1 then
            response.ret = -1976
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if item < 4 then
            local cnum = mUseractive.info[self.aname]['c'..item] or 0
            if cnum < activeCfg.supportNeed[item] then
                response.ret = -102
                return response
            end
        else 
            for i=1,3 do
                local cn = mUseractive.info[self.aname]['c'..i] or 0
                if cn < activeCfg.supportNeed[i] then
                    response.ret = -102
                    return response
                end
            end
        end

        local reward = {}
        local spprop = {}
        for  k,v in pairs(activeCfg.serverreward['gift'..item]) do
            if string.find(v[1],'dresstree') then
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
        if mUseractive.info[self.aname]['s'..iteminfo.type] < price then
            response.ret = -102
            return response
        end
       
        local reward ={}
        reward[iteminfo.serverreward[1]] = iteminfo.serverreward[2]*num
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end

        mUseractive.info[self.aname]['s'..iteminfo.type] = mUseractive.info[self.aname]['s'..iteminfo.type] - price
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
            if string.find(v[1],'dresstree') then
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
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not zoneid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
     

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

return api_active_dresstree
