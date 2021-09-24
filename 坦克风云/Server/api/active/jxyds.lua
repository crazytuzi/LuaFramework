--
-- desc: 军校优等生
-- user: chenyunhe
--
local function api_active_jxyds(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'jxyds',
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

        -- 充值钻石
        if not mUseractive.info[self.aname].gem then
            mUseractive.info[self.aname].gem = 0
            flag = true
        end

        --充值
        if not mUseractive.info[self.aname].ch then
            mUseractive.info[self.aname].ch = {}
            for k,v in pairs(activeCfg.serverreward.rechargeList) do
                table.insert(mUseractive.info[self.aname].ch,0)
            end
            flag = true
        end

        if type(mUseractive.info[self.aname].s)~='table' then
            mUseractive.info[self.aname].s  = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].s,0)
            end
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

    -- 商店
    function self.action_shop(request)
        local uid = request.uid
        local response = self.response
        local gid = request.params.gid -- 商品id
        local cprice = request.params.price -- 客户端算出的价格
        local num = request.params.num -- 购买的数量
        
        if not gid or cprice<=0 or num<=0 then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
      
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local itemCfg = activeCfg.serverreward.shopList[gid]
        if type(itemCfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].s[gid] + num>itemCfg.limit then
            response.ret = -121
            return response
        end

        -- 计算当前价格
        local charge = mUseractive.info[self.aname].gem
        local index = 0
        local chnum = #activeCfg.shopRecharge
        for i=chnum,1,-1 do
            if charge>=activeCfg.shopRecharge[i] then
                index = i
                break
            end
        end

        local sprice = 0
        if index == 0 then
            sprice = itemCfg.value[1]*num
        else
            sprice = itemCfg.value[index+1]*num
        end

        -- 验证一下客户端价格
        if cprice~=sprice then
            response.ret = -100
            return response
        end

        if cprice<=0 or sprice<=0 then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(itemCfg.serverreward) do
            reward[k] = v * num
        end
       
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(cprice) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=255,item="",value=cprice,params={num=num}})
        mUseractive.info[self.aname].s[gid] = (mUseractive.info[self.aname].s[gid] or 0) + num
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

    -- 领取充值奖励
    function self.action_reward(request)
        local uid = request.uid
        local response = self.response
        local id = request.params.id
        
        if id<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        if mUseractive.info[self.aname].ch[id]==1 then
            response.ret = 1976
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local chcfg = activeCfg.serverreward.rechargeList[id]
        if type(chcfg)~='table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].gem<chcfg.rechargeNum then
            response.ret = -102
            return response
        end

        if not takeReward(uid,chcfg.serverreward) then
            response.ret = -106
            return response
        end
        
        mUseractive.info[self.aname].ch[id]=1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(chcfg.serverreward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end


    return self
end

return api_active_jxyds
