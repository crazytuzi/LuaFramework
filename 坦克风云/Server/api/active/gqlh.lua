--
-- desc: 国庆礼花
-- user: chenyunhe
-- 每种颜色球增加对应的分数
-- 额外增加分数（1-对子，2-三条，3-四条，4-带金色全不一样，5-不带金色全不一样，6-全金色）
--
local function api_active_gqlh(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'gqlh',
    }

    -- 礼花 随机奖励和积分
    function self.action_fireworks(request)
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

        if not mUseractive.info[self.aname].s then
        	mUseractive.info[self.aname].s=0
        end    

        local function getscore(f,activeCfg)
          
            local score = 0
            -- 计算分数
            -- 1.基础得分
            for k,v in pairs(f) do
                score = score + activeCfg.serverreward.mainPool[4][k]*v
                -- if v==2 then
                --     score = score + activeCfg.serverreward.extraScore[1]
                -- elseif v==3 then
                --     score = score + activeCfg.serverreward.extraScore[2]
                -- end
            end
           
            -- 额外加分
            local extscore = 0
            local length = table.length(f)
            local  keys = table.keys(f)
            if length == 1 then
                if table.contains(keys,5) then
                    -- 四个全是金球
                    extscore = activeCfg.serverreward.extraScore[6]
                else
                    -- 四个同样的其他球（四条）
                    extscore = activeCfg.serverreward.extraScore[3]
                end

            elseif length == 2 then
                -- 如果两个是  2:2 、1:3
                if table.contains(keys,5) then
                    extscore = activeCfg.serverreward.extraScore[3]
                else
                   if table.contains(f,2) then-- 2:2的格式
                        extscore = 2*activeCfg.serverreward.extraScore[1]
                   else
                        -- 1:3的格式
                        extscore = activeCfg.serverreward.extraScore[2]
                   end
                end
            elseif length == 3 then
                if table.contains(keys,5) then--含1金或2金 
                    extscore = activeCfg.serverreward.extraScore[2]
                else
                    -- 不含金球
                    extscore = activeCfg.serverreward.extraScore[1]
                end
            elseif length == 4 then 
                if table.contains(keys,5) then
                     -- 四个不一样 含金球
                     extscore = activeCfg.serverreward.extraScore[4]
                else
                     -- 四个一样 不含金球
                     extscore = activeCfg.serverreward.extraScore[5]
                end
            end

            return score+extscore
        end
        
        local allfirework = {}
        local reward = {}
        local report = {}
        local gn = 0 --金色球个数
        local finalscore = 0
        for i=1,num do
            local fire = {}
            local single = {}
        	for n=1,4 do
        		local result,rewardkey = getRewardByPool(activeCfg.serverreward.mainPool)
                fire[result[1]] = (fire[result[1]] or 0) +1
                -- 金色求数量
                if result[1]==5 then
                    gn = gn+1
                end
                table.insert(single,result[1])
	 		end

            table.insert(allfirework,single)

            local score= getscore(fire,activeCfg)
            mUseractive.info[self.aname].s=(mUseractive.info[self.aname].s or 0)+score
   
            local matchpool = 1
            for s=#activeCfg.serverreward.matchScore,1,-1 do
                if score>=activeCfg.serverreward.matchScore[s] then
                    matchpool = s
                    break
                end
            end
  
            local rd,rk = getRewardByPool(activeCfg.serverreward['pool'..matchpool],1)
            for k,v in pairs(rd) do
                 for rkey,rval in pairs(v) do
                    reward[rkey]=(reward[rkey] or 0)+rval
                end
            end
  
            -- 如果存在金色球 需要给额外奖励
            if gn>0 then
                local gd,gk = getRewardByPool(activeCfg.serverreward.goldpool,1)
                for k,v in pairs(gd) do
                     for gkey,gval in pairs(v) do
                        reward[gkey]=(reward[gkey] or 0)+gval
                    end
                end
            end

            finalscore = finalscore+score
        end

        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
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
            regActionLogs(uid,1,{action = 178, item = "", value = gems, params = {num = num}})
        end

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') == 1 then
            local hReward,hClientReward = harVerGifts('active','gqlh',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
        end

        local gnum = 0
        local fdinfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(fdinfo)=='table' then
            gnum = fdinfo.info.count
        end
    
        if gn>0 then
            gnum = gnum + gn -- 累计金色球数量
            if not setFreeData(self.aname..mUseractive.info[self.aname].st, {count=gnum}) then
                 response.ret=-106
                 return response
            end
        end

        if uobjs.save() then
 			local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={} end
            
            table.insert(data,1,{ts,report,num,harCReward,finalscore})
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
            response.data[self.aname].allreward = report 
            response.data[self.aname].finalscore = finalscore
            response.data[self.aname].goldballs = gnum -- 全服金色球数
            response.data[self.aname].allfirework = allfirework -- 礼花结果
      
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

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].shop)~='table' then
        	mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
            	table.insert(mUseractive.info[self.aname].shop,0)
            end
        end
        
        local iteminfo=activeCfg.serverreward.shopList[itemid]
        if type(iteminfo)~='table' then
        	response.ret=-102
        	return response
        end

        -- 物品兑换次数不足
        if mUseractive.info[self.aname].shop[itemid]>iteminfo.limit then
            response.ret=-23305
            return response
        end
    
        local coststore=iteminfo.price*num
        -- 积分数量不足
        if mUseractive.info[self.aname].s<coststore then
            response.ret=-1996
            return response
        end 

        -- 增加兑换次数
        mUseractive.info[self.aname].shop[itemid]=mUseractive.info[self.aname].shop[itemid]+num
        mUseractive.info[self.aname].s=mUseractive.info[self.aname].s-coststore

        local reward={[iteminfo.serverreward[1]]=iteminfo.serverreward[2]*num}
        if not takeReward(uid,reward) then
            response.ret=-102
            return response
        end

        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].allreward = formatReward(reward)
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
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end
        local flag = false
        -- 积分
        if mUseractive.info[self.aname].s==nil  then
            flag = true
            mUseractive.info[self.aname].s=0
        end

        if type(mUseractive.info[self.aname].shop)~='table' then
            flag = true
            local activeCfg = mUseractive.getActiveConfig(self.aname)
            mUseractive.info[self.aname].shop={}
            for k,v in pairs(activeCfg.serverreward.shopList) do
                table.insert(mUseractive.info[self.aname].shop,0)
            end

            mUseractive.info[self.aname].grlist={}--- 全服奖励列表
            for i=1,#activeCfg.serverreward.goldNum do
                table.insert(mUseractive.info[self.aname].grlist,0)
            end
        end

       
        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end

        end
        -- 当前全服金色求出现的数量
        local gnum = 0 
        local fdinfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(fdinfo)=='table' then
            gnum = fdinfo.info.count
        end        

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].goldballs = gnum
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取全服领取奖励
    function self.action_reward(request)
        local response = self.response
        local uid=request.uid
        local item =  request.params.item

        if not uid or item<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].grlist)~='table' then
            response.ret =-102
            return response
        end
    
        -- 领取过
        if mUseractive.info[self.aname].grlist[item]==1 then
            response.ret = -1976
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if item>#activeCfg.serverreward.goldNum then
            response.ret = -102
            return respons
        end
        local gnum = 0
        local fdinfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(fdinfo)=='table' then
            gnum = fdinfo.info.count
        end

        if gnum<activeCfg.serverreward.goldNum[item] then
            response.ret = -1981
            return response
        end

        local reward = {}
        local clientReward = {}
        for k,v in pairs(activeCfg.serverreward['gift'..item]) do
            reward[v[1]]=(reward[v[1]] or 0)+v[2]
            table.insert(clientReward, formatReward({[v[1]]=v[2]}))
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].grlist[item] = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data.allreward = clientReward
            response.ret = 0
            response.msg = 'Success'
        else
          response.ret=-106
        end

        return response
    end

    return self
end

return api_active_gqlh
