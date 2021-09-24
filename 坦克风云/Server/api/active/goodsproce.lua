--desc:物资加工
--user:liming
local function api_active_goodsproce(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'goodsproce',
    }
    function self.formatreward(rewards)
        local formatreward = {}
        local key = 'goodsproce'
        formatreward[key] = {}
        if type(rewards) == 'table' then
            for k,v in pairs(rewards) do
                formatreward[key][k] = v
            end 
        end
        return formatreward
    end
    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local uid=request.uid
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
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
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].shop) ~= 'table' then
            -- 三种道具积分  
            for k,v in pairs(activeCfg.scoreItem) do
                mUseractive.info[self.aname][v] = 0
            end
            mUseractive.info[self.aname].shop = {}
            for _,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        if not uobjs.save() then
            response.ret = -106
            return response
        end
        response.data[self.aname] = mUseractive.info[self.aname]
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 抽奖
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num) -- 1单抽 10十连抽
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local train = request.params.t --抽奖类型 1初级 2中级 3高级
        local ts= getClientTs()
        local weeTs = getWeeTs()
        if not table.contains({0,1},free) or not table.contains({1,10},num) and not table.contains({1,2,3},train)  then
       	   response.ret=-102
       	   return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive',"alienweapon"})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local mAweapon = uobjs.getModel('alienweapon')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        -- 消耗钻石
        local gems = 0
        -- 中级是有免费的
        if train ==2 then 
            -- 免费时 单抽
            if free ==1 and num>1 then
                response.ret = -102
                return response
            end

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

            if free==1 then
                 mUseractive.info[self.aname].v=1
            else
                if num ==1 then
                    gems = activeCfg.cost1[train]
                else
                    num = 10
                    gems = activeCfg.cost2[train]
                end
            end
        else
            if free ==1 then
                response.ret = -102
                return response
            end
            if num ==1 then
                gems = activeCfg.cost1[train]
            else
                num = 10
                gems = activeCfg.cost2[train]
            end
        end
        local reward={}
        local report={}
        local spprop = {}
        local scoreItem = activeCfg.scoreItem
        local totalscore = 0
        for i=1,num do 
	 		local result,rewardkey = getRewardByPool(activeCfg.serverreward['pool'..train],1)
            for k,v in pairs (result) do
                for rk,rv in pairs(v) do
                    reward[rk]=(reward[rk] or 0)+rv
                end
            end
            local score = activeCfg.serverreward['pool'..train].score[rewardkey[1]] 
            totalscore = totalscore + score
            local tmpspprop = {}
            if #scoreItem==1 then
                tmpspprop[scoreItem[1]] = score
            else
                tmpspprop[scoreItem[train]] = score
            end
            for k,v in pairs(tmpspprop) do
                spprop[k] = (spprop[k] or 0) + v
            end
        end
        if not takeReward(uid,reward) then    
            response.ret=-403
            return response
        end
        --test
        -- mUseractive.info[self.aname].goodsproce_a1=500
        -- mUseractive.info[self.aname].goodsproce_a2=500
        -- mUseractive.info[self.aname].goodsproce_a3=500
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
        if next(spprop) then
            for k,v in pairs(spprop) do
                 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
                 table.insert(report,self.formatreward({[k]=v}))
            end
        end
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=221,item="",value=gems,params={num=num}})
        local clientReport= copyTable(report)
        -- 和谐版判断
        local hnum = 0
        if num==1 and train==1 then
            hnum = 1
        end
        if num==10 and train==1 then
            hnum = 10
        end
        if num==1 and train==2 then
            hnum = 2
        end
        if num==10 and train==2 then
            hnum = 20
        end
        if num==1 and train==3 then
            hnum = 3
        end
        if num==10 and train==3 then
            hnum = 30
        end
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','goodsproce',hnum)
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
            if type (data)~="table" then data={}  end
            table.insert(data,1,{ts,report,num,harCReward,train,totalscore})
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
            response.data[self.aname].reward=clientReport
            response.data[self.aname].score= totalscore --分数
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
    --  商店兑换
    function self.action_exchange(request)
        local response = self.response
        local uid=request.uid
        local item = tonumber(request.params.id)
        local num = request.params.n or 1
        num = tonumber(num)
        if not item then
            response.ret =-102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local iteminfo = activeCfg.serverreward.shopList[item]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end
        if type(mUseractive.info[self.aname].shop)~='table' then
            response.ret = -102
            return response     
        end
        if mUseractive.info[self.aname].shop[item]+num>iteminfo.limit then
            response.ret = -1987
            return response
        end
        local price = iteminfo.price*num
        local scorekey = activeCfg.scoreItem[iteminfo.type]
        if mUseractive.info[self.aname][scorekey] < price then
            response.ret = -102
            return response
        end
        local reward ={}
        reward[iteminfo.serverreward[1]] = iteminfo.serverreward[2]*num
        if not takeReward(uid,reward) then
            response.ret =-403
            return response
        end
        mUseractive.info[self.aname][scorekey] = mUseractive.info[self.aname][scorekey] - price
        mUseractive.info[self.aname].shop[item] = mUseractive.info[self.aname].shop[item] + num
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

return api_active_goodsproce