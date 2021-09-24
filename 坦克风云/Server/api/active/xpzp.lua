--desc:芯片装配
--user:liming
local function api_active_xpzp(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'xpzp',
    }
    -- 抓取奖励
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 抓取选项
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},free) or not table.contains({1,6},num) or not uid then
           response.ret=-102
           return response
        end
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
        -- 免费时 单抽
        if free ==1 and num>1 then
            response.ret = -102
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if mUseractive.info[self.aname].t < weeTs then
            mUseractive.info[self.aname].v = 0
            mUseractive.info[self.aname].t = weeTs
        end
        if mUseractive.info[self.aname].v==1 and free==1 then
            response.ret = -102
            return response
        end
        -- 判断是否有免费次数
        if mUseractive.info[self.aname].v == 0 and free ~=1 then
            response.ret = -102
            return response
        end
        -- 消耗钻石
        local gems = 0
        if free==1 then
             mUseractive.info[self.aname].v=1
        else
            if num ==1 then
                gems = activeCfg.cost1
            else
                num = activeCfg.poolNum-mUseractive.info[self.aname].l
                local x = mUseractive.info[self.aname].l + 1
                gems = activeCfg.cost2[x]
            end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
             regActionLogs(uid,1,{action=223,item="",value=gems,params={num=num}})
        end
        local reward={}
        local report={}
        local tmpreward = {}
        if mUseractive.info[self.aname].rlog == nil then
           mUseractive.info[self.aname].rlog = {}
        end
        local l = mUseractive.info[self.aname].l or 0
        for i=1,num do
            l = l + 1
            local lnum = l%activeCfg.poolNum
            if lnum==0 then
                l = activeCfg.poolNum
            else
                l = lnum  
                mUseractive.info[self.aname].l=l
            end
            local rate = 1
            local reward= copyTab(getRewardByPool(activeCfg.serverreward.randomPool1))
            table.insert(report,formatReward(reward))
            if l == activeCfg.poolNum  then
                -- 删除记录
                mUseractive.info[self.aname].rlog={}
                mUseractive.info[self.aname].l=0
                --特殊库翻倍
                rate = activeCfg.pool2Rate
                tmpreward = copyTab(getRewardByPool(activeCfg.serverreward.randomPool2))
                for k, v in pairs(tmpreward) do
                   tmpreward[k] = math.floor( v * rate )
                end
            end
            if next(tmpreward) then
                for k,v in pairs(tmpreward) do
                    reward[k] = (reward[k] or 0) + v
                end
                table.insert(report,formatReward(tmpreward))
            end
            if not takeReward(uid,reward) then
                response.ret = -403
                return response
            end
            if l~=activeCfg.poolNum then
                --记录一下位置
                table.insert(mUseractive.info[self.aname].rlog,formatReward(reward))
            end
            
        end  
        -- ptb:e(report) 
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','xpzp',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            table.insert(data,1,{ts,report,num,harCReward})
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
                response.data[self.aname].hReward=harCReward
            end
            response.data[self.aname].reward=report
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end
    -- 获取记录
    function self.action_getReportLog(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end
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
    

    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local weeTs = getWeeTs()
        if not uid then
            response.ret = -102
            return response
        end
        local ts= getClientTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUseractive.info[self.aname].l == nil then
            mUseractive.info[self.aname].l = 0
        end
        if mUseractive.info[self.aname].gems == nil then
            mUseractive.info[self.aname].gems = 0
        end
        if mUseractive.info[self.aname].buynum == nil then
           mUseractive.info[self.aname].buynum = 0
        end 
        if mUseractive.info[self.aname].rlog == nil then
           mUseractive.info[self.aname].rlog = {}
        end
        -- activity_setopt(uid,'xpzp',{act='charge',num=100})
        if not uobjs.save() then
            response.ret = -102
            return response
        end        
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end
    

    return self
end

return api_active_xpzp