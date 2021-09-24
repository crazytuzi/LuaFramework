--
-- desc: 异星超乐透
-- user: guohaojie
--
local function api_active_yxclt(request)
    local self = {
    response = {
    ret = -1,
    msg ='error',
    data = {},
    },
    aname = 'yxclt',
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
    -- 可领取次数和已领取次数记录
    if type(mUseractive.info[self.aname].task) ~='table' then
        flag = true
        mUseractive.info[self.aname].task = {}        
        for k,v in pairs(activeCfg.serverreward.taskList) do
            table.insert(mUseractive.info[self.aname].task,{0,0})--当前完成数量  领取次数
        end
    end
    if not mUseractive.info[self.aname].times then
        flag = true
        mUseractive.info[self.aname].times = 0 
    end
    if not mUseractive.info[self.aname].ct then
        flag = true
        mUseractive.info[self.aname].ct = weeTs 
    end
    if type(mUseractive.info[self.aname].rd) ~='table' then
        flag = true
        local  rdtable = {"1","2","3","4","5","6"}
        mUseractive.info[self.aname].rd = {}
        for k,v in pairs(rdtable) do
            mUseractive.info[self.aname].rd[k] = 0
        end
    end
    if mUseractive.info[self.aname].ct ~= weeTs then
        flag = true
        for k,v in pairs(mUseractive.info[self.aname]["task"]) do
            mUseractive.info[self.aname]["task"][k][1]=0
            mUseractive.info[self.aname]["task"][k][2]=0
        end
        mUseractive.info[self.aname].ct = weeTs

    end
    if  mUseractive.info[self.aname].task[2][1]  >= activeCfg.serverreward.taskList[2]["num"] and mUseractive.info[self.aname].task[2][2] == 0 then
        flag = true
        mUseractive.info[self.aname].task[2][2] =1
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
 -- 获取记录
function self.action_getReportLog(request)
    local response = self.response
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local redis =getRedis()
    local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
    local data =redis:get(redkey)
    data =json.decode(data)
    if type(data) ~= 'table' then data = {} end
    response.ret = 0
    response.msg = 'Success'
    response.data.report=data
    return response
end

-- 抽奖
function self.action_lottery(request)
    local uid = request.uid
    local response = self.response
    local num = tonumber(request.params.num) --  冲击阶段
    local free = tonumber(request.params.free) -- 0非免费 1免费
    local tp = request.params.tp -- 抽奖类型 1冲击 2通关
    local ts= getClientTs()     --当前时间
    local weeTs = getWeeTs()    --  当前初始时间
    local cfg = getConfig("alienWeaponCfg")  --配置
    if not table.contains({0,1},free) or not table.contains({1,2,3,4,5,6},num) or not table.contains({1,2},tp)  then
       response.ret=-102
       return response
   end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","props","bag",'useractive',"troops"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local activeCfg = mUseractive.getActiveConfig(self.aname)
    local gems = 0
    local cnum = 1
    if mUseractive.info[self.aname].times ~= num-1 then
       response.ret=-102
       return response
    end
    if mUseractive.info[self.aname].times == 0 then
        for i=1,6  do
            mUseractive.info[self.aname].rd[i]= 0
        end
    end
    if mUseractive.info[self.aname].t ~= weeTs then
        mUseractive.info[self.aname].v = 1
        mUseractive.info[self.aname].t = weeTs
        for k,v in pairs(mUseractive.info[self.aname]["task"]) do
            mUseractive.info[self.aname]["task"][k][1]=0
            mUseractive.info[self.aname]["task"][k][2]=0
        end
        mUseractive.info[self.aname].ct = weeTs
    else
        mUseractive.info[self.aname].v = 0
        mUseractive.info[self.aname].t = weeTs
        mUseractive.info[self.aname].ct = weeTs
    end
    -- 冲击
    if tp ==1 then 
        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v==0 and free==1 then
            response.ret = -102
            return response
        end
        if mUseractive.info[self.aname].v ==1 and free ~=1 then
            response.ret = -102
            return response
        end
        if free~=1 then
         gems = activeCfg.cost1
        end
    else
        if free ==1 or mUseractive.info[self.aname].v==1 then
        response.ret = -102
        return response
        end
        cnum = 6-mUseractive.info[self.aname].times
        local gid=mUseractive.info[self.aname].times+1
        gems = activeCfg.cost2[gid]
    end
    local reward={}
    local report={}
    if tp ==1  then
     mUseractive.info[self.aname].task[1][1]= mUseractive.info[self.aname].task[1][1] +  1
        if  mUseractive.info[self.aname].task[1][1] >= activeCfg.serverreward.taskList[1]["num"] then
          if mUseractive.info[self.aname].task[1][2] ~=2 then
              mUseractive.info[self.aname].task[1][2] =1
          end
        end
    else
     mUseractive.info[self.aname].task[2][1]= mUseractive.info[self.aname].task[2][1]+  1
         if  mUseractive.info[self.aname].task[2][1] >= activeCfg.serverreward.taskList[2]["num"] then
           if mUseractive.info[self.aname].task[2][2] ~=2 then
              mUseractive.info[self.aname].task[2][2] =1
          end
        end
    end
    for i=1, cnum do 
        local tmp ={}
        local x = mUseractive.info[self.aname].times+1
        if x<6 then
            local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool1'],1)
            for k,v in pairs (result) do
              for rk,rv in pairs(v) do
                reward[rk]=(reward[rk] or 0)+rv
                tmp[rk] = (tmp[rk] or 0) + rv
            end
        end 
    end
    mUseractive.info[self.aname].times= mUseractive.info[self.aname].times +  1  
    if x==6 then
        if  tp==1 then
            mUseractive.info[self.aname].task[2][1]= mUseractive.info[self.aname].task[2][1]+  1
            if  mUseractive.info[self.aname].task[2][1]  == activeCfg.serverreward.taskList[2]["num"] then
                mUseractive.info[self.aname].task[2][2] =1
            end
        end
        local result1,rewardkey1 = getRewardByPool(activeCfg.serverreward['pool2'],1)
        for k1,v1 in pairs (result1) do
          for rk1,rv1 in pairs(v1) do
            reward[rk1]=(reward[rk1] or 0)+rv1
            tmp[rk1] = (tmp[rk1] or 0) + rv1
          end
        end 
        mUseractive.info[self.aname].times=0
    end
    mUseractive.info[self.aname].rd[x]=formatReward(tmp)
        if tp ==1  then
            report = formatReward(tmp)
        else
            report = formatReward(reward)
        end
    end
    if not next(reward) then
        response.ret = -120
        return response
    end
    for kk,vv in pairs(reward) do
        local cc =kk:split('_')
        if cc[2] ~= 'exp' then
            local aw = cfg.fragmentList[cc[2]]["weaponId"]
            local col = cfg.weaponList[aw]["color"]
            if col == 4 then
                mUseractive.info[self.aname].task[3][1]= mUseractive.info[self.aname].task[3][1]+  vv

                if  mUseractive.info[self.aname].task[3][1] >= activeCfg.serverreward.taskList[3]["num"] then
                    if mUseractive.info[self.aname].task[3][2]~=2 then
                      mUseractive.info[self.aname].task[3][2] =1
                    end
                end
            end
            if col == 5 then
                mUseractive.info[self.aname].task[4][1]= mUseractive.info[self.aname].task[4][1]+  vv
                if  mUseractive.info[self.aname].task[4][1] >= activeCfg.serverreward.taskList[4]["num"] then
                    if mUseractive.info[self.aname].task[4][2]~=2 then
                          mUseractive.info[self.aname].task[4][2] =1
                    end
                end
            end
        end
    end
    if gems>0 then
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=265,item="",value=gems,params={num=cnum}})
    end
    mUseractive.info[self.aname].task[5][1]= mUseractive.info[self.aname].task[5][1] +  gems
    if  mUseractive.info[self.aname].task[5][1] >= activeCfg.serverreward.taskList[5]["num"] then
        if mUseractive.info[self.aname].task[5][2]~=2 then
          mUseractive.info[self.aname].task[5][2] =1
        end
    end
           -- 和谐版判断
    local harCReward={}
    if moduleIsEnabled('harmonyversion') == 1 then
    local hReward,hClientReward = harVerGifts('active','yxclt',cnum)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        harCReward = hClientReward
    end
    if not takeReward(uid,reward) then
        response.ret = -403
        return response
    end
    if uobjs.save() then
    local redis =getRedis()
    local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
    local data =redis:get(redkey)
    data =json.decode(data)
    if type (data)~="table" then data={} end   
    table.insert(data,1,{ts,report,cnum,harCReward})
    if next(data) then
        for i=#data,11,-1 do
            table.remove(data)
        end
        data=json.encode(data)
        redis:set(redkey,data)
        redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
    end         
    response.data[self.aname] =mUseractive.info[self.aname]
    if next(harCReward) then
            response.data[self.aname].hReward=harCReward  -- 和谐版奖励
        end
        response.data[self.aname].reward = report -- 奖励
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret=-106
    end
    return response
end

-- 领取任务奖励
function self.action_tasks(request)
    local response=self.response
    local uid=request.uid
    local tid=request.params.tid
    if not tid or not uid then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local activeCfg = mUseractive.getActiveConfig(self.aname)
    local weeTs = getWeeTs()    --  当前初始时间
    --每日刷新
    if mUseractive.info[self.aname].ct ~= weeTs then
        for k,v in pairs(mUseractive.info[self.aname]["rd"]) do
            if mUseractive.info[self.aname]["rd"][k] ~= 0 then
                mUseractive.info[self.aname]["rd"][k]["aw"]=nil
            end
        end
        for k,v in pairs(mUseractive.info[self.aname]["task"]) do
            mUseractive.info[self.aname]["task"][k][1]=0
            mUseractive.info[self.aname]["task"][k][2]=0
        end
        mUseractive.info[self.aname].ct = weeTs

    end
    if mUseractive.info[self.aname].task[tid][2] ==0 then
        response.ret=-1981
        return response
    end
    -- 已领取
    if mUseractive.info[self.aname].task[tid][2]==2 then
        response.ret=-8037
        return response
    end
    --其他值
    if mUseractive.info[self.aname].task[tid][2]~=1 then
        response.ret=-102
        return response
    end

    local activeCfg = mUseractive.getActiveConfig(self.aname)
    local rewardCfg=activeCfg.serverreward.taskList[tid].r
    --配置判断
    if type(rewardCfg)~='table' or not next(rewardCfg) then
        response.ret=-102
        return response
    end
    if not takeReward(uid,rewardCfg) then
        response.ret=-403
        return response
    end
    mUseractive.info[self.aname].task[tid][2] =2
    if uobjs.save() then
        response.data[self.aname]=mUseractive.info[self.aname]
        response.data[self.aname].reward=formatReward(rewardCfg)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret=-106
    end
    return response
end
return self
end
return api_active_yxclt
