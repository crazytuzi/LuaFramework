--
-- desc: 马力全开
-- user: guohaojie
--
local function api_active_mlqk(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'mlqk',
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
        
        --能量值
        if not mUseractive.info[self.aname].energy  then
            flag = true
            mUseractive.info[self.aname].energy=0
        end
        -- 折扣
        if not mUseractive.info[self.aname].rebate  then
            flag = true
            mUseractive.info[self.aname].rebate=activeCfg.discount[1]
        end

        -- 商店 限购次数
        if type(mUseractive.info[self.aname].bnum) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].bnum = {}  
            for key,val in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].bnum,val['limit'])
            end
        end

        -- 领取状态
        if type(mUseractive.info[self.aname].task) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].task = {}  
            for key,val in pairs(activeCfg.serverreward.taskList) do
                table.insert(mUseractive.info[self.aname].task,{0,0,0,0})--[已经领取个数,当前进度,领取状态]
            end
        end
        --任务进度
        if type(mUseractive.info[self.aname].tkname) ~= 'table' then
            flag = true
            mUseractive.info[self.aname].tkname = {}  
            for key,val in pairs(activeCfg.taskid) do
                mUseractive.info[self.aname].tkname[key]=0
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

    --购买
    function self.action_shop(request)
        local response = self.response
        local bid = request.params.bid     --购买的商品id
        local num = request.params.num     --购买数量
        local dst = request.params.dst     --折扣
        local uid=request.uid
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        --判断bid
        if not activeCfg.serverreward.shopList[bid]  then
            response.ret = -102
            return response
        end
        --判断购买次数
        if num<=0 or num>activeCfg.serverreward.shopList[bid]["limit"] then
            response.ret = -102
            return response
        end
        --判断折扣
        if mUseractive.info[self.aname].rebate ~= dst then
            response.ret = -102
            return response
        end
        --判断是否购买次数是否足够
        if mUseractive.info[self.aname].bnum[bid]-num <0 then
            response.ret = -102
            return response
        end   
        mUseractive.info[self.aname].bnum[bid]=mUseractive.info[self.aname].bnum[bid]-num

        local result = activeCfg.serverreward.shopList[bid]["r"]
        local reward = {}
        for key,val in pairs(result) do
            reward[key]=val * num
        end
        if not next(reward) then
            response.ret = -120
            return response
        end

        local  tid = 1  --折扣对应的key
        for key,val in pairs(activeCfg.discount) do
            if mUseractive.info[self.aname].rebate == val then
                tid=key
            end
        end
        --取key为tid 的value
        local gems =  activeCfg.serverreward.shopList[bid].value[tid] *num      
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=279,item="",value=gems,params={num=num}})

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        
        if uobjs.save() then

            response.data[self.aname]=mUseractive.info[self.aname]
            response.data[self.aname].r=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end

     -- 领取奖励
    function self.action_reward(request)
        local response = self.response
        local id = request.params.id
        local uid=request.uid
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not activeCfg.serverreward.taskList[id]  then
            response.ret = -102
            return response
        end

        local muact = mUseractive.info[self.aname]
        
        local rid = muact.task[id][1]+1   --领取奖励id
        --校验领取数量
        if  rid > muact.task[id][2] or muact.task[id][3] ~=1 then
            response.ret = -102
            return response
        end
        --状态改变不可取
        if  rid == muact.task[id][2] then
            muact.task[id][3]=0
        end
        if  rid == #activeCfg.serverreward.taskList[id] then
            muact.task[id][3]=2
        end
        
        local reward  = {}

        local result = activeCfg.serverreward['taskList'][id][rid]["r"]
        for k,v in pairs (result) do
            if k =='mlqk_a1' then 
                muact.energy=muact.energy+v
            else
                reward[k]=(reward[k] or 0)+v
            end
        end
        muact.task[id][1]=rid
        for key,val in pairs(activeCfg.energyNeed) do
            if mUseractive.info[self.aname].energy >= val then
                mUseractive.info[self.aname].rebate =activeCfg.discount[key+1]
            end
        end
        if not next(reward) then
            response.ret = -120
            return response
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        
        if uobjs.save() then
            response.data[self.aname]=mUseractive.info[self.aname]
            response.data[self.aname].r=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end
   
       return self
end

return api_active_mlqk