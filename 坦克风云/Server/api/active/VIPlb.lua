--
-- desc:   VIP礼包
-- user: guohaojie
--


local function api_active_VIPlb(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'VIPlb',
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
        if not mUseractive.info[self.aname].times then
            flag = true
            mUseractive.info[self.aname].times = activeCfg.buyLimit
        end
        if type(mUseractive.info[self.aname].vip) ~='table' then
            flag = true
            mUseractive.info[self.aname].vip = {}
            
        end
        if type(mUseractive.info[self.aname].r) ~='table' then
            flag = true
            mUseractive.info[self.aname].r = {}
            
        end
        if type(mUseractive.info[self.aname].rd) ~='table' then
            flag = true
            local  rdtable = {"1","2","3","4","5","6","7","8","9","10","11","12","13"}
            mUseractive.info[self.aname].rd = {}
            for k,v in pairs(rdtable) do
                mUseractive.info[self.aname].rd[k] = 0
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
    function self.action_viplb(request)
        local uid = request.uid
        local response = self.response
        local id = tonumber(request.params.id) -- 任务id
        local ts= getClientTs()     --当前时间
        local weeTs = getWeeTs()    --  当前初始时间
        local cfg = getConfig("alienWeaponCfg")  --配置

        if not  table.contains({1,2,3,4,5,6,7,8,9,10,11,12,13},id)  then
           response.ret=-102
           return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"troops"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mTroop = uobjs.getModel('troops')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local mvip = mUserinfo.vip
        local cvip = activeCfg.serverreward.shopList[id]["vip"]
        local gems = 0
        local  num = 1
        local tms =mUseractive.info[self.aname].times
        if #mUseractive.info[self.aname].vip ==0 then
        table.insert(mUseractive.info[self.aname].vip,"v"..id)
        else

            for k,v in pairs(mUseractive.info[self.aname].vip) do
                if "v"..id == v then
                    response.ret = -121
                    return response 
                end
            end
            if   #mUseractive.info[self.aname].vip >3  then
              response.ret = -1987
              return response
            end 

            table.insert(mUseractive.info[self.aname].vip,"v"..id)
        end
        if mvip<cvip then

            response.ret = -2006
            return response
        end
        if tms ==0 then
            response.ret = -1987
            return response
        end
        local reward = {}
        reward =activeCfg.serverreward['shopList'][id]["r"]
        gems   =activeCfg.serverreward['shopList'][id]["value"]
        mUseractive.info[self.aname].times=mUseractive.info[self.aname].times-1
        mUseractive.info[self.aname].rd[id]=1
        if not next(reward) then
            response.ret = -120
            return response
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=268,item="",value=gems,params={num=cnum}})
        
        if not takeReward(uid,reward) then
                response.ret = -403
                return response
        end

        -- local report = reward
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

return api_active_VIPlb