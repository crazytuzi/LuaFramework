--desc:悬赏任务
--user:chenyunhe
local function api_active_xuanshangtask(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'xuanshangtask',
    }
    -- 抽取奖励
    function self.action_getreward(request)
        local uid = request.uid
        local response = self.response
        local uid = request.uid
        local tid = tonumber(request.params.tid) -- 任务编号
        local tasktype=request.params.type  --任务类别
     
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].tk)~='table' or mUseractive.info[self.aname].tk[tasktype]['index']~=tid then
            response.ret = -102
            return response
        end

        if mUseractive.info[self.aname].tk[tasktype]['s']<=1 then
            response.ret = -1981
            return response
        end

        if mUseractive.info[self.aname].tk[tasktype]['s']==3 then
            response.ret = -1976
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local reward={}
        for k,v in pairs(activeCfg.serverreward.tasklist[tid].serverreward) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end
 
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

        mUseractive.info[self.aname].f=(mUseractive.info[self.aname].f or 0)+1
        mUseractive.info[self.aname].tk[tasktype]['s']=3

        local xsgold=activeCfg.serverreward.tasklist[tid].xsgold
        -- 悬赏金
        --完成当前的任务 会获得额外悬赏金
        if  mUseractive.info[self.aname].f==table.length(mUseractive.info[self.aname].tk) then
             xsgold=xsgold+activeCfg.extraReward
        end
        mUseractive.info[self.aname].xsgold = (mUseractive.info[self.aname].xsgold or 0)+xsgold

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 刷新任务列表
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        activity_setopt(uid,'xuanshangtask',{t=''})

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        

        return response
    end

    -- 重置任务列表
    function self.action_resettask(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].rn>=activeCfg.refreshNum then
            response.ret =-6007
            return response
        end

        activity_setopt(uid,'xuanshangtask',{t='init'})
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106                    
        end

        return response

    end

    -- 商店悬赏金兑换
    function self.action_shop(request)
         local response = self.response
         local uid=request.uid
         local itemid=request.params.item--兑换哪一个
         local sindex='i'..itemid
         local num=request.params.num or 1 --兑换个数

         local uobjs = getUserObjs(uid)
         uobjs.load({"userinfo",'useractive'})
         local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local itemkeys=table.keys(mUseractive.info[self.aname].shop)
        if not table.contains(itemkeys,sindex) then
            response.ret=-102
            return response
        end

        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo=activeCfg.serverreward.shopList[itemid]
     
        -- 物品兑换次数不足
        if mUseractive.info[self.aname].shop[sindex].n>iteminfo.limit then
            response.ret=-23305
            return response
        end
    
        local costxsGold=iteminfo.price*num
        -- 赏金数量不足
        if mUseractive.info[self.aname].xsgold<costxsGold then
            response.ret=-1996
            return response
        end 

        -- 增加兑换次数
        mUseractive.info[self.aname].shop[sindex].n=mUseractive.info[self.aname].shop[sindex].n+num
        mUseractive.info[self.aname].xsgold=mUseractive.info[self.aname].xsgold-costxsGold
        local reward={[iteminfo.serverreward[1]]=iteminfo.serverreward[2]*num}
 
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106                    
        end

        return response        
    end


    return self
end

return api_active_xuanshangtask