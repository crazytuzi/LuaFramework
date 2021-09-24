--
-- desc: 充值团购
-- user: guohaojie
--

local function api_active_cztg(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'cztg',
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
        local uact = mUseractive.info[self.aname]
        local ts= getClientTs()  
       
        local currDay = math.floor(math.abs(ts-uact.st)/(24*3600)) + 1;
         -- 记录时间
        if not uact.time then
            flag = true
            uact.time  = getWeeTs()  
            uact.t= currDay 
        end
        --军团小任务状态状态
        if type(uact.atask) ~= 'table' then
            flag = true
            uact.atask = {}  
            for key,val in pairs(activeCfg.serverreward.list2[uact.t]) do

                table.insert(uact.atask,{})
                for kk,vv in pairs(activeCfg.serverreward.list2[uact.t][key]) do
                    table.insert(uact.atask[key],0)--012, 未,可,已领取
                end

            end
        end

        --全服小任务状态状态
        if type(uact.stask) ~= 'table' then
            flag = true
            uact.stask = {}  
            for key,val in pairs(activeCfg.serverreward.list1[uact.t]) do

                table.insert(uact.stask,{})
                for kk,vv in pairs(activeCfg.serverreward.list1[uact.t][key]) do
                    table.insert(uact.stask[key],0)--012, 未,可,已领取
                end

            end
        end
        -- 
        if not uact.gems then
            flag = true
            uact.gems = 0  
        end
        -- 1未发送  2已发送
        if not uact.send then
            flag = true
            uact.send = 1  
        end
        -- 隔天初始化个人数据
        if  uact.time ~= getWeeTs() then
            flag = true
            for key,val in pairs(uact.atask) do
                for kk,vv in pairs(val) do
                    uact.atask[key][kk]=0
                end
            end
            for key,val in pairs(uact.stask) do
                for kk,vv in pairs(val) do
                    uact.stask[key][kk]=0
                end
            end
            uact.t=currDay
            uact.gems=0 
            uact.send=1
            uact.time = getWeeTs()           
        end

        local aid = mUserinfo.alliance
        local aAllianceActive = {}
        local activeObj = {}

        if aid>0 then

            flag = true
            aAllianceActive = getModelObjs("allianceactive",aid)          
            activeObj = aAllianceActive.getActiveObj(self.aname) 
            --  隔天初始化军团数据
            if activeObj.activeInfo.ats ~=nil and activeObj.activeInfo.ats ~=getWeeTs() then
                local result=  aAllianceActive.getActiveObj(self.aname):remake(activeCfg.rGetLimit,id)                      
            end
            --  判断是否完成军团任务
            for key,val in pairs(activeCfg.rechargeNum) do                
                if activeObj.activeInfo.legion ~=nil and activeObj.activeInfo.legion >= val and uact.atask[key][1]==0 then
                    uact.atask[key][1]=1                  
                end
            end  
        end
        -- 获取全服完成人数
        local senddata={
                zid=request.zoneid,
                aid = currDay,
                acname=self.aname,
                st = uact.st,
            }
        local  result = require("lib.crossActivity").cztgFind(senddata)
        local  pnum = 0

        if  next(result.data) then 

            flag = true
            pnum=tonumber(result.data.score)

            for key,val in pairs(activeCfg.playerNum) do 
                     
                if  pnum >= val and uact.stask[key][1] ==0 then
                   mUseractive.info[self.aname].stask[key][1]=1       
                end
             end 
        end
        


        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
	    processEventsAfterSave()
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].legion = 0
        response.data[self.aname].pnum = pnum
        if aid>0 then
            response.data[self.aname].legion = activeObj.activeInfo.legion or 0
        end

        response.ret = 0
        response.msg = 'Success'
        return response
       
    end

     -- 领取奖励
    function self.action_sreward(request)
        local response = self.response
        local id = request.params.id
        local page = request.params.page

        if  not table.contains({1,2},page)  then
            response.ret = -102
            return response
        end

        local tid = request.params.tid
        local uid=request.uid

        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        

        local day = mUseractive.info[self.aname].t
        local list = 'list'..page
        --判断id和tid参数
        if not activeCfg.serverreward[list][day][id]  then
            response.ret = -102
            return response
        end

        if not activeCfg.serverreward[list][day][id][tid]  then
            response.ret = -102
            return response
        end

        local task = 'stask'
        -- 隔天初始化个人数据
        if  mUseractive.info[self.aname].time ~= getWeeTs() then
            flag = true
            
            for key,val in pairs(mUseractive.info[self.aname].atask) do
                for kk,vv in pairs(val) do
                    mUseractive.info[self.aname].atask[key][kk]=0
                end
            end
            for key,val in pairs(mUseractive.info[self.aname].stask) do
                for kk,vv in pairs(val) do
                    mUseractive.info[self.aname].atask[key][kk]=0
                end
            end
            mUseractive.info[self.aname].t=uact.t+1
            mUseractive.info[self.aname].gems=0 
            mUseractive.info[self.aname].send=1
            umUseractive.info[self.aname].time = getWeeTs()           
        end
       
        --军团
        local aAllianceActive = {}
        local activeObj = {}
        local aid = mUserinfo.alliance
        if page ==2 then
            task ='atask'
            if aid <=0 then
                response.ret = -102
                return response
            end

            aAllianceActive = getModelObjs("allianceactive",aid)          
            activeObj = aAllianceActive.getActiveObj(self.aname) 
            --  隔天初始化军团数据
            if activeObj.activeInfo.ats ~=nil and activeObj.activeInfo.ats ~=getWeeTs() then
                local result=  aAllianceActive.getActiveObj(self.aname):remake(activeCfg.rGetLimit,id)                      
            end

        end  
        
        --判断是否领取
        if mUseractive.info[self.aname][task][id][tid] ~= 1 then
            response.ret = -102
            return response
        end

        mUseractive.info[self.aname][task][id][tid]=2

        local reward = activeCfg.serverreward[list][day][id][tid].r
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

            -- 全服
            if page==1 then
                -- 获取全服完成人数
                local senddata={
                        zid=request.zoneid,
                        aid = mUseractive.info[self.aname].t,
                        acname=self.aname,
                        st = mUseractive.info[self.aname].st,
                    }
                local  result = require("lib.crossActivity").cztgFind(senddata)
                local  pnum = 0
                if  next(result.data) then 
                    response.data[self.aname].pnum=tonumber(result.data.score)
                end   
            end
            if page ==2 and aid >0 then 
                response.data[self.aname].legion = activeObj.activeInfo.legion or 0
            end

            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end


       return self
end

return api_active_cztg