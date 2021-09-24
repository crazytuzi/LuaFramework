--
-- desc: 圣诞雪人
-- user: liming
--
local function api_active_snowman(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'snowman',
    }

    -- 随机奖励并获得积分
    function self.action_lottery(request)
        local uid = request.uid
        local response = self.response
        local num = tonumber(request.params.num)
        local free = tonumber(request.params.free) -- 0非免费 1免费
        local ts= getClientTs()
        local weeTs = getWeeTs()
       
        if not table.contains({0,1},free) or not table.contains({1,5},num) or not uid then
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
	            num = 5
	            gems = activeCfg.cost2
	        end
        end

        local reward = {}
        local report = {}
        local man = {}
        local fen = {}
        local totalscore = 0
        local sortlist = activeCfg.serverreward.sortlist
        for i=1,num do
            local rewardkey = getRewardByPool(activeCfg.serverreward.combins)[1]
            local sortReward = sortlist[rewardkey]
            local pool = 'pool'..sortReward.poolpick
            local sort = sortReward.sort
            local score = sortReward.score
            local tmpreward = getRewardByPool(activeCfg.serverreward[pool])
            for k,v in pairs(tmpreward) do
                table.insert(report, formatReward({[k]=v}))
                reward[k] = (reward[k] or 0) + v
            end
            table.insert(man,sort)
            table.insert(fen,score)
            totalscore = totalscore + score
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if gems>0 then
            regActionLogs(uid,1,{action = 193, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','snowman',num)
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
            
            table.insert(data,1,{ts,report,num,harCReward,totalscore})
            if next(data) then
                if #data >10 then
                    for i=#data,11 do
                        table.remove(data)
                    end
                end
                data=json.encode(data)
                redis:set(redkey,data)
                redis:expireat(redkey,mUseractive.info[self.aname].et+86400)
            end
            local scores = 0
            if mUserinfo.alliance > 0 then
                scores = self.savescore(mUseractive.info[self.aname].st,mUseractive.info[self.aname].et,mUserinfo.alliance,totalscore)
            end 
            response.data[self.aname] =mUseractive.info[self.aname]
            if next(harCReward) then
                response.data[self.aname].hReward=harCReward  -- 和谐版奖励
            end
            response.data[self.aname].reward = report -- 奖励
            if mUserinfo.alliance > 0 then
                response.data[self.aname].thisscore = totalscore --本次获得积分
                response.data[self.aname].fen = fen --本次获得积分
            end 
            
            response.data[self.aname].man = man -- 奖励
            response.data[self.aname].s = scores --军团积分
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

    -- 商店兑换
    function self.action_shopping(request)
        local response = self.response
        local uid=request.uid
        local itemid=request.params.item--兑换哪一个
        local num=request.params.num or 1 --兑换个数
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end 
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].shop)~='table' then
        	mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
            	table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        local iteminfo = activeCfg.serverreward.shopList[itemid]
        if type(iteminfo)~='table' then
            response.ret = -102
            return response
        end

        -- 物品兑换次数不足
        if mUseractive.info[self.aname].shop[itemid] + num >iteminfo.limit then
            response.ret=-23305
            return response
        end
        
        --解锁积分不足
        local s = self.acrank(mUseractive.info[self.aname].st,mUserinfo.alliance)
        if s < iteminfo.scoreLimit then
            response.ret = -20014
            return response
        end

        local gems = iteminfo.price*num
        --消耗钻石
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        if gems>0 then
            regActionLogs(uid,1,{action = 193, item = "", value = gems, params = {num = num}})
        end

        -- 增加兑换次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num

        local reward = {[iteminfo.serverreward[1]]=iteminfo.serverreward[2]*num}

        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end
        if uobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = formatReward(reward)
            response.data[self.aname].s = s
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response        
    end
    
     -- 领取奖励
    function self.action_gift(request)
        local uid = request.uid
        local index= request.params.index   
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        local mUserinfo = uobjs.getModel('userinfo')
        if index == nil then
            response.ret = -102
            return response
        end
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        --是否加入军团
        if mUserinfo.alliance == 0 then
            response.ret = -4005
            return response
        end
        --积分
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tmpgrade = activeCfg.supportNeed[index]
        local report = {}
        local reward = {} --普通道具
        local spprop = {} --特殊道具
        local score = self.acrank(mUseractive.info[self.aname].st,mUserinfo.alliance)
        if score<tmpgrade then
            response.ret = -108
            return response
        else
            local flag = mUseractive.info[self.aname].giftrecord[tonumber(index)]
            if flag == 1 then
                response.ret = -1976 --已领取过此宝箱
                return response
            else
                local rewardCfg = activeCfg.serverreward['gift'..index]
                local et = mUseractive.info[self.aname].et+86400
                
                for k,v in pairs(rewardCfg) do
                    reward[v[1]] = (reward[v[1]] or 0) + v[2]
                end
                if next(reward) then
                    for k,v in pairs(reward) do
                        table.insert(report, formatReward({[k]=v}))
                    end
                    if not takeReward(uid,reward) then
                        response.ret = -403
                        return response
                    end
                end
                mUseractive.info[self.aname].giftrecord[tonumber(index)] = 1
            end
        end
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].s = score
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
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local flag = false
        
        --商店
        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            mUseractive.info[self.aname].shop = {}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        --领奖记录
        if type(mUseractive.info[self.aname].giftrecord)~='table' then
            flag = true
            mUseractive.info[self.aname].giftrecord = {}
            for k,v in pairs(activeCfg.supportNeed) do
                table.insert(mUseractive.info[self.aname].giftrecord,0)
            end
        end

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end

        end
        response.data[self.aname] = mUseractive.info[self.aname]
        -- 军团积分
        response.data[self.aname].s = 0
        if mUserinfo.alliance>0 then
            local score = self.acrank(mUseractive.info[self.aname].st,mUserinfo.alliance)
            response.data[self.aname].s = score
        end
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 获取军团积分
    function self.acrank(st,id)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
        local redis = getRedis()
        local scorelist = json.decode(redis:get(redkey))
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
            scorelist = readRankfile(self.aname,st)
        end
        local aid = 'a'..id
        local score = scorelist[aid] or 0
        return score
    end
    --保存军团积分
    function self.savescore(st,et,id,totalscore)
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..st..'score'
        local redis = getRedis()
        local scorelist = json.decode(redis:get(redkey))
        if type(scorelist)~='table' or not next(scorelist) then
            scorelist = {}
            local list = readRankfile(self.aname,st)
            if next(list) then
                scorelist = list
            end
        end
        local aid = 'a'..id
        scorelist[aid] = (scorelist[aid] or 0) + totalscore
        redis:set(redkey,json.encode(scorelist))
        redis:expireat(redkey,et+86400)
        local ranklist = json.encode(scorelist)
        writeActiveRankLog(ranklist,self.aname,st) -- 写入日志
        
        local s = scorelist[aid]
        return s
    end

    return self
end

return api_active_snowman
