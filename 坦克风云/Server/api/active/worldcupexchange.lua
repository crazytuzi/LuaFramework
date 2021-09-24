--
-- desc: 世界杯-一球定天
-- user: chenyunhe
--
local function api_active_worldcupexchange(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'worldcupexchange',
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

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 当前是活动的第几天
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1

        local activeCfg =copyTable(mUseractive.getActiveConfig(self.aname)) 
        activeCfg.serverreward = nil
        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].t = getClientTs()
        response.data[self.aname].curday = currDay
        response.data.activeCfg = activeCfg
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 兑换
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local ts = getClientTs()
        local day =request.params.d or 0
        local item = request.params.item
        local index = request.params.index 
        local num =request.params.n or 0

        if day<=0 or num<=0 or  not table.contains({1,2,3},item) or index<=0 then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({'useractive','bag'})
        local mUseractive = uobjs.getModel('useractive')
        local mBag = uobjs.getModel('bag')

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local currDay = math.floor(math.abs(ts-getWeeTs(mUseractive.info[self.aname].st))/(24*3600)) + 1
        
        -- 能否兑换 判断
        if day~=currDay then
            response.ret = -102
            return response
        end

        local exid = activeCfg.days[item]
        if currDay < exid then
            response.ret = -102
            return response
        end

        local changeList = copyTable(activeCfg.serverreward['changeList'..item])
        if type(changeList)~= 'table' then
            response.ret = -102
            return response
        end

        if type(changeList[index])~='table' then
            response.ret = -102
            return response
        end

        for k,v in pairs(changeList[index].cost) do
            if not mBag.use(k, v*num) then
                response.ret = -1996
                return response
            end
        end

        local reward ={}
        for k,v in pairs(changeList[index].get) do
            reward[k] = v * num
        end
        
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end
      
        if uobjs.save() then        
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward=formatReward(reward)
            response.data[self.aname].curday = currDay
            response.data.bag = mBag.toArray(true)
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

        local reward = copyTable(activeCfg.serverreward.fbreward)
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
        local lang = request.lang
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
        local urlkey = "facebookshareurl"
       
        local freedata = getFreeData(urlkey)
        url = freedata.info[lang] or nil
        
        response.data.fb = mUseractive.info[self.aname].fb or 0
        response.data.url =  url
        response.ret = 0
        response.msg = 'Success'

        return response
    end
   
    return self
end

return api_active_worldcupexchange
