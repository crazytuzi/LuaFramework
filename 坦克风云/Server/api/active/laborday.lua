--
-- desc: 全民劳动(2018五一)
-- user: chenyunhe
--
local function api_active_laborday(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'laborday',
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

    -- 按积分领取奖励
    function self.action_sreward(request)
        local uid = request.uid
        local response = self.response
        local item = tonumber(request.params.item)

        if not item or item<=0 then
            response.ret =-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not activeCfg.supportNeed[item] then
            response.ret = -102
            return response
        end

		if type(mUseractive.info[self.aname].sr)~='table' then 
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].sr[item] ==  1 then
            response.ret = -1976
            return response
        end

        if mUseractive.info[self.aname].s < activeCfg.supportNeed[item] then
            response.ret = -1981
            return response
        end

        local reward = copyTable(activeCfg.serverreward['gift'..item])
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].sr[item] = 1
        if uobjs.save() then
            response.data.reward = formatReward(reward)
            response.data[self.aname] = mUseractive.info[self.aname]

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 商店购买
    function self.action_shopping(request)
        local response = self.response
        local uid=request.uid
        local itemid=request.params.item --购买哪一个
        local num=request.params.num or 1 --购买个数

        if not itemid or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local shopCfg = activeCfg.serverreward.shopList[itemid]

        if type(shopCfg) ~= 'table' then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].shop[itemid]+num > shopCfg.limit then
            response.ret = -1987
            return response
        end

        local gems = shopCfg.price *num
        if gems <=0 then
            response.ret = -120
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        local reward = {}
        for k,v in pairs(shopCfg.serverreward) do
            reward[k] = v * num
        end
      
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end
   
        if gems>0 then
            regActionLogs(uid,1,{action = 224, item = "", value = gems, params = {num = num}})
        end

        mUseractive.info[self.aname].shop[itemid] = (mUseractive.info[self.aname].shop[itemid] or 0) + num
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
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
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取任务奖励
    function self.action_treward(request)
        local response = self.response
        local uid=request.uid
        local tid=request.params.tid -- 任务下标
        local num = request.params.num or 1 

        if not tid or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

        local taskCfg = activeCfg.serverreward.taskList[tid]
        if type(taskCfg)~='table' then
            response.ret = -102
            return response
        end

        -- 完成次数限制
        if mUseractive.info[self.aname].task[tid][2]>=taskCfg.limit then
            response.ret = -1993
            return response
        end
        
        -- 领取奖励次数校验
        local cur = math.floor(mUseractive.info[self.aname].task[tid][1]/taskCfg.num)
        local canreceive = 0 -- 当前可领取奖励的次数
        if cur >= taskCfg.limit then
            canreceive = taskCfg.limit - mUseractive.info[self.aname].task[tid][2]
        else
            canreceive = cur - mUseractive.info[self.aname].task[tid][2]
        end
        if canreceive<=0 or num>canreceive then
            response.ret = -102
            return response
        end

        local reward = {}
        for k,v in pairs(taskCfg.serverreward) do
            reward[k] = v*num 
        end
      
        if not takeReward(uid,reward) then
            response.ret = -102
            return response
        end

        mUseractive.info[self.aname].task[tid][2] = (mUseractive.info[self.aname].task[tid][2] or 0) + num
        mUseractive.info[self.aname].s = (mUseractive.info[self.aname].s or 0) + taskCfg.score*num
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

    return self
end

return api_active_laborday
