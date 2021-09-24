--
-- desc: VIP狂欢
-- user: chenyunhe
--
local function api_active_vipkh(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'vipkh',
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

    -- 刷新 初始化
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false  

        -- 累计充值
        if not mUseractive.info[self.aname].gems then
            flag = true
            mUseractive.info[self.aname].gems = 0
        end

        -- 商店
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                mUseractive.info[self.aname].shop[k] = {}
                for rk,rv in pairs(v) do
                    table.insert(mUseractive.info[self.aname].shop[k],0)
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

    -- 商店
    function self.action_shop(request)
        local uid = request.uid
        local response = self.response
        local sid = request.params.sid -- 下标
        local id = request.params.id   -- 商品的配置id
        local num = request.params.num -- 购买次数
        
        if not sid or not id or num<=0 then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].shop[sid])~='table' then
            response.ret = -102
            return response
        end

        local itemCfg = activeCfg.serverreward.shopList[sid][id]
        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        local index = 0
        for k,v in pairs(activeCfg.rechargeNum) do
            if mUseractive.info[self.aname].gems >= v then
                index = k
            end
        end

        if index==0 or sid>index then
            response.ret = -102
            return response
        end

        if mUserinfo.vip<itemCfg.vipNeed then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].shop[sid][id]+num>itemCfg.limit then
            response.ret = -121
            return response
        end
      
        local gems = itemCfg.value*num
        if gems<=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(itemCfg.r) do
            reward[k] = v*num
        end
       
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=281,item="",value=gems,params={num=num,sid=sid,id=id}})

        mUseractive.info[self.aname].shop[sid][id] = mUseractive.info[self.aname].shop[sid][id] + num
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end


    return self
end

return api_active_vipkh
