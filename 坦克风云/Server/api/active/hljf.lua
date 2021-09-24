--
-- desc: 欢乐积分
-- user: guohaojie
--

local function api_active_hljf(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'hljf',
    }

    function self.action_refresh(request)

        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        local ts= getClientTs()     --当前时间
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false 

        if  not mUseractive.info[self.aname].free  then
            flag= true
            mUseractive.info[self.aname].free =  0 --免费抽奖次数
        end
        if  not mUseractive.info[self.aname].score  then
            flag= true
            mUseractive.info[self.aname].score = 0 --总积分
        end
        if  not mUseractive.info[self.aname].point  then
            flag= true
            mUseractive.info[self.aname].point = 0 --总积分
        end
       
       
        -- 可兑换的次数和已领取次数记录
        if type(mUseractive.info[self.aname].task) ~='table' then
            flag = true
            mUseractive.info[self.aname].task = {}        
            for key,val in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].task,val["limit"])--当前完成数量  领取次数
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

    --兑换
    function self.action_exchange(request)
         -- body
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)  --兑换数量
        local id   = tonumber(request.params.id)  --商品id 
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local ts  = getClientTs()
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local mact = mUseractive.info[self.aname]

        if not activeCfg.serverreward.shopList[id]  then
                response.ret=-102
                return response
        end
        if num <= 0   then
                response.ret=-102
                return response
        end

        if num >mUseractive.info[self.aname].task[id]   then
                response.ret=-102
                return response
        end
        if num * activeCfg.serverreward.shopList[id]["num"] >mact.score  then
                response.ret=-102
                return response
        end

        local rewardCfg=activeCfg.serverreward.shopList[id].r 
        local reward = {}
        local report = {}
        for k,v in pairs(rewardCfg) do 
            reward[k]=v*num
        end 
        table.insert(report,reward)

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mact.score = mact.score-num * activeCfg.serverreward.shopList[id]["num"]
        mact.point = mact.point-num * activeCfg.serverreward.shopList[id]["num"]
        mact.task[id] = mact.task[id]-num

  
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


    -- 抽奖
    function self.action_lottery(request)
        
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)  -- 0-9
        local p   = tonumber(request.params.p)    --0 单次  1多次
        local lk  = tonumber(request.params.lk)   --0 未锁  1-3锁定位置
        local free  = tonumber(request.params.free)   --0 未锁  1-3锁定位置
        local ts  = getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},p) or not table.contains({0,1},free) or not table.contains({0,1,2,3,4,5,6,7,8,9,10},num) or not table.contains({0,1,2,3},lk)  then
            response.ret=-102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local gems = 0
        local rnum = 1   --抽奖数量
        --刷新每日的免费次数
        if mUseractive.info[self.aname].t ~= weeTs      then
            mUseractive.info[self.aname].free = 1
            mUseractive.info[self.aname].t = weeTs              
        else
            mUseractive.info[self.aname].free = 0
            mUseractive.info[self.aname].t = weeTs
        end
        if p ==0 then 
            -- 判断是否有免费次数
            if mUseractive.info[self.aname].free==1 then
                if  free ~=1  then
                    response.ret=-102
                    return response
                end 
              
            end

            if mUseractive.info[self.aname].free==0 then
                if free ~= 0  then
                    response.ret=-102
                    return response
                end
                --锁定数字花费的金币不同
                gems=activeCfg.cost1[1]
                if table.contains({1,2,3},lk)  then
                    if num ==0  then
                        response.ret=-102
                        return response
                    end
                    gems=activeCfg.cost1[2]
                end        
            end
                     
        end

        if p ==1  then
            if mUseractive.info[self.aname].free==1  or free ==1 then
                response.ret=-102
                return response
            end

            gems=activeCfg.cost2[1]
            if table.contains({1,2,3},lk)  then
                if num ==0  then
                    response.ret=-102
                    return response
                end
                gems=activeCfg.cost2[2]
            end 
            rnum=activeCfg.costMul
        end

        local reward = {}
        local ldata = {}
        local score = mUseractive.info[self.aname].score   --总分数

        if  score >=0  and score < activeCfg.switchScore[1] then
            local  one = {uid=uid,id=1,lk=lk,num=num,rnum=rnum}
            ldata=self.lot(one)
                
        end

        if  score >=activeCfg.switchScore[1] and score <activeCfg.switchScore[2] then
            local  one = {uid=uid,id=2,lk=lk,num=num,rnum=rnum}
            ldata=self.lot(one)

        end

        if  score >=activeCfg.switchScore[2] and score <activeCfg.switchScore[3] then
            local  one = {uid=uid,id=3,lk=lk,num=num,rnum=rnum}
            ldata=self.lot(one)
        end

        if  score >=activeCfg.switchScore[3]  then   
            local  one = {uid=uid,id=4,lk=lk,num=num,rnum=rnum}
            ldata=self.lot(one)
        end
        local len = #ldata["abc"]
        mUseractive.info[self.aname].score=ldata["score"]
        mUseractive.info[self.aname].point=ldata["score"]
        mUseractive.info[self.aname].lastnum=ldata["abc"][len]
        local reward = ldata["rd"]

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=272,item="",value=gems,params={num=rnum}}) 
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
            
            table.insert(data,1,{ts,ldata["score"],ldata["se"],ldata["hr"],ldata["r"]})
            if next(data) then
                    for i=#data,11,-1 do
                        table.remove(data)
                    end

                    data=json.encode(data)
                    redis:set(redkey,data)
                    redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end 
            ldata.t=mUseractive.info[self.aname].t
            mUseractive.info[self.aname]=ldata
            mUseractive.info[self.aname].lk=lk
            mUseractive.info[self.aname].t=mUseractive.info[self.aname].t
            mUseractive.info[self.aname].lastnum=ldata["abc"][len]
            response.data[self.aname] =mUseractive.info[self.aname]
                       
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    --单次抽
    function self.lot(request)
        local uobjs = getUserObjs(request.uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local id  = request.id
        local lk  = request.lk
        local num = request.num
        local rnum = request.rnum
        local uid = request.uid

        local reward = {}     --奖励
        local abc = {}        --记录三个数字
        local points = {}     --记录每次积分和
        local se = 0          --单次积分和
        local a = 0     
        local b = 0
        local c = 0
        local score = mUseractive.info[self.aname].point   --总分数

        for i=1,request.rnum do
            
            local result,rewardkey = getRewardByPool(activeCfg.serverreward["pool"..id],1)
            local result1,rewardkey1 = getRewardByPool(activeCfg.serverreward["pool"..id],1)
            
            if lk==1 then
                a=num   b=result[1]   c =result1[1]   se=a+b+c
                if a==b and b==c then  se=se*activeCfg.scoreMul end 
            end

            if lk==2 then
                b=num   a=result[1]   c =result1[1]   se=a+b+c
                if a==b and b==c then  se= se*activeCfg.scoreMul end
            end

            if lk==3 then   
                c=num   a=result[1]   b =result1[1]   se=a+b+c
                if a==b and b==c then  se= se*activeCfg.scoreMul end

            end

            if lk==0 then
                local result2,rewardkey2 = getRewardByPool(activeCfg.serverreward['pool1'],1)
                a =result[1]  b =result1[1] c=result2[1]  se=a+b+c
                if a==b and b==c then  se= se*activeCfg.scoreMul end
            end

            local rewardCfg=activeCfg.serverreward.itemGet

            for key,val in pairs(rewardCfg) do
                reward[key]=(reward[key] or 0)+val*se
            end

            table.insert(abc,{a,b,c})
            table.insert(points,se)
            score=score+se
        end
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','hljf',rnum)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        local list = {abc=abc,se=points,score=score,r={formatReward(reward)},hr=harCReward,rd=reward}
        return list

    end
  
       return self
end

return api_active_hljf
