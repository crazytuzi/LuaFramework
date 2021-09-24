--
-- desc: 周年庆（2周年）
-- user: chenyunhe
--
local function api_active_anniversary2(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'anniversary2',
    }

	
    -- 领取连续充值奖励
    function self.action_lxreward(request)
 		local uid = request.uid
        local response = self.response
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not mUseractive.info[self.aname].lxr then
        	mUseractive.info[self.aname].lxr = 0
        end

        if mUseractive.info[self.aname].lx < activeCfg.rechargeDay then
        	response.ret = -102
        	return response
        end

        if  mUseractive.info[self.aname].lxr==1 then
        	response.ret = -1976
        	return response
        end

        local reward = {} 
        local report = {}
        for k,v in pairs(activeCfg.serverreward.rechargeGet) do
         	reward[v[1]]=(reward[v[1]] or 0)+v[2]
         	table.insert(report, formatReward({[v[1]]=v[2]}))
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname].lxr = 1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

    -- 单笔充值奖励
    function self.action_sigreward(request)
 		local uid = request.uid
        local response = self.response
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not mUseractive.info[self.aname].sn then
        	response.ret = -102
        	return response
        end

        local num = mUseractive.info[self.aname].sn
        if num < 0 then
        	response.ret = -102
        	return response
        end

        local reward = {} 
        local report = {}
        for k,v in pairs(activeCfg.serverreward.recharge1) do
         	reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
         	table.insert(report, formatReward({[v[1]]=v[2]*num}))
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname].sn = 0
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end

     -- 领取累计充值奖励
    function self.action_chargereward(request)
 		local uid = request.uid
        local response = self.response
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if not mUseractive.info[self.aname].gem then
        	response.ret = -102
        	return response
        end

        local total =mUseractive.info[self.aname].gem
        local num =math.floor((total-mUseractive.info[self.aname].gn*activeCfg.rechargeNum[2])/activeCfg.rechargeNum[2])

        if num <= 0 then
        	response.ret = -102
        	return response
        end

        local reward = {} 
        local report = {}
        for k,v in pairs(activeCfg.serverreward.recharge2) do
         	reward[v[1]]=(reward[v[1]] or 0)+v[2]*num
         	table.insert(report, formatReward({[v[1]]=v[2]*num}))
        end
  

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end

        mUseractive.info[self.aname].gn = (mUseractive.info[self.aname].gn or 0)+num
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response
    end



    -- 刷新
    function self.action_refresh(request)
        local response = self.response
        local weeTs = getWeeTs()
        local uid=request.uid
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 初始化航海日志
        local flag = false
        if type(mUseractive.info[self.aname].careerinfo) ~='table' then
        	flag = true
        	mUseractive.info[self.aname].careerinfo = {{},{},{},{},{}}
        	mUseractive.info[self.aname].cr = {0,0,0,0,0}
        end

        -- 1.注册时间
    	if not next(mUseractive.info[self.aname].careerinfo[1]) then
    		flag =  true
    		mUseractive.info[self.aname].careerinfo[1] ={mUserinfo.regdate}
    	end

        -- 2.加入军团时间和军团名称
		if mUserinfo.alliance>0 and not next(mUseractive.info[self.aname].careerinfo[2]) then
    		flag =  true
    		local adt = 0
	        local execRet,code = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,acallianceLevel=1}
	        if execRet and execRet.data then
	            adt = tonumber(execRet.data.join_at) or 0
	            mUseractive.info[self.aname].careerinfo[2] ={adt, mUserinfo.alliancename}
	        end
    	end

        -- 3.军功
		if not next(mUseractive.info[self.aname].careerinfo[3]) then
    		flag =  true
            if mUserinfo.rp>0 then
                mUseractive.info[self.aname].careerinfo[3] ={mUserinfo.rp}
            end
    	end    	
        -- 4.好友数
		if not next(mUseractive.info[self.aname].careerinfo[4]) then
    		flag =  true
    		local mFriends = uobjs.getModel('friends')
            if #mFriends.info>0 then
                mUseractive.info[self.aname].careerinfo[4] ={#mFriends.info}
            end	
    	end    	
        -- 5.游戏时长
		if not next(mUseractive.info[self.aname].careerinfo[5]) then
    		flag =  true
            if mUserinfo.olt>0 then
                mUseractive.info[self.aname].careerinfo[5] ={tonumber(string.format('%.2f',mUserinfo.olt/3600))}
            end	
    	end

        -- 累计充值钻石
        if mUseractive.info[self.aname].gem == nil then
        	flag = true
        	mUseractive.info[self.aname].gem  = 0
        	mUseractive.info[self.aname].gn  = 0 --累计充值可领取次数
        end
        -- 单次充值钻石
 		if mUseractive.info[self.aname].sn == nil then
        	flag = true
        	mUseractive.info[self.aname].sn  = 0-- 单次充值可领取次数
        end
        -- 连续充值 三天
		if mUseractive.info[self.aname].lx == nil  then
        	flag = true
        	mUseractive.info[self.aname].lx  = 0--连续充值次数
        	mUseractive.info[self.aname].lt  = 0--上次充值时间
            mUseractive.info[self.aname].lxr  = 0--是否领取连续充值奖励
        end

        -- 次数检测连续充值数据
        -- 如果一个玩家 第一天充了 第二天没充 第三天没充 连续值需要重置
        if mUseractive.info[self.aname].lx<3 then
            if weeTs-mUseractive.info[self.aname].lt>86400 then
                mUseractive.info[self.aname].lt = 0
                mUseractive.info[self.aname].lx = 0
            end
        end
    
        if mUseractive.info[self.aname].bn ==nil then
        	flag = true
        	mUseractive.info[self.aname].bn  = 0--已领取召回奖励的次数
        end

        if type(mUseractive.info[self.aname].support)~='table' then
        	mUseractive.info[self.aname].support={}
        	for k,v in pairs(activeCfg.supportNeed) do
        		table.insert(mUseractive.info[self.aname].support,0)
        	end
        end

        local score = 0 --全服积分
		local scoreInfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
    	if type(scoreInfo)=='table' then
        	 score = scoreInfo.info.count
        end

        -- 绑定数据
        if not mUseractive.info[self.aname].bd then
        	mUseractive.info[self.aname].bd = {}
        end

        local returncharge = 0
        if type(mUseractive.info[self.aname].bd)=='table' and tonumber(mUseractive.info[self.aname].u)==2 then
        	if not mUseractive.info[self.aname].rcn then
        		mUseractive.info[self.aname] .rcn = 0--活跃玩家已领取回归玩家充值奖励次数
        	end

        	local canGetN = 0
            for k,v in pairs(mUseractive.info[self.aname].bd) do
	 			local bindUobjs = getUserObjs(v)
	            local bindUseractive = bindUobjs.getModel('useractive')

	            if bindUseractive.info[self.aname].rc then
	            	local cng = math.floor(bindUseractive.info[self.aname].rc/activeCfg.returnRecharge)
	            	canGetN = canGetN + cng
	            end
            end

            returncharge = canGetN - mUseractive.info[self.aname] .rcn
            if returncharge>0 then      
                if mUseractive.info[self.aname].rcn+returncharge>=activeCfg.callrechargeGetLimit then
                    returncharge = activeCfg.callrechargeGetLimit - mUseractive.info[self.aname].rcn
                end 
            else
                returncharge=0
            end
         
        end

   

        if flag then
            if not uobjs.save() then
                response.ret = -106
                return response
            end
        end

        response.data[self.aname] = mUseractive.info[self.aname]
        response.data[self.aname].score = score
        response.data[self.aname].returncharge = returncharge
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 领取航海日志奖励
    function self.action_careerreward(request)
    	local response = self.response
        local uid= request.uid
        local item = request.params.item

        if not uid or not item then
        	response.ret = -102
        	return response
        end

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

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if mUserinfo.level < activeCfg.levelLimit then
        	response.ret = -102
        	return response
        end

        if not next(mUseractive.info[self.aname].careerinfo[item]) then
        	response.ret = -1981
        	return response
        end

        if mUseractive.info[self.aname].cr[item]==1 then
        	response.ret = -1976
        	return response
        end

       
        local reward = {}
        local clientReward = {}
        for k,v in pairs(activeCfg.serverreward['career'..item]) do
        	reward[v[1]] = (reward[v[1]] or 0) + v[2]
        	table.insert(clientReward,formatReward({[v[1]]=v[2]}))
        end

        if not takeReward(uid,reward) then
        	response.ret = -403
        	return response
        end
    	mUseractive.info[self.aname].cr[item] = 1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = clientReward
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response        
    end

    --使用蓝卡
    function self.action_usebluecard(request)
		local uid = request.uid
        local response = self.response
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)


        if  not mUseractive.info[self.aname].anv_a1 or mUseractive.info[self.aname].anv_a1<=0 then
        	response.ret = -1996
        	return response
        end

        local reward = {}
        local report = {}
        local spprop = {} -- 特殊道具
        for i=1,mUseractive.info[self.aname].anv_a1 do
    		local rw,rewkey= getRewardByPool(activeCfg.serverreward.pool1)
	        for k,v in pairs(rw) do
	        	
	        	if string.find(k,'anv') then
	        		spprop[k]=(spprop[k] or 0)+v
	        	else
	        		reward[k]=(reward[k] or 0)+v
	        	end
	        end
    	end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

    	if next(spprop) then
    		for k,v in pairs(spprop) do
    			 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
    			 table.insert(report,self.formatreward({[k]=v}))
    		end
    	end

        local score = 0 --全服积分
        local scoreInfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
        if type(scoreInfo)=='table' then
             score = scoreInfo.info.count
        end

      
        mUseractive.info[self.aname].anv_a1 = 0
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].score = score

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    	

    end

    function self.formatreward(rewards)
		local formatreward = {}
		local key = 'anv'
	   	formatreward[key] = {}
	    if type(rewards) == 'table' then
	        for k,v in pairs(rewards) do
	            formatreward[key][k] = v
	        end
	    end
	    return formatreward
	end

	-- 应援
	function self.action_support(request)
		local uid = request.uid
        local response = self.response
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
  

        -- 检测可合成数量
        local num = 0
        for i=1,4 do
        	if  not mUseractive.info[self.aname]['anv_b'..i] or mUseractive.info[self.aname]['anv_b'..i]<=0 then
	        	response.ret = -1996
	        	return response
        	end
        	if num==0 then
        		num = mUseractive.info[self.aname]['anv_b'..i]
        	end
        	if mUseractive.info[self.aname]['anv_b'..i]<num then
        		num = mUseractive.info[self.aname]['anv_b'..i]
        	end
        end

        local reward = {}
        local report = {}
        local spprop = {} -- 特殊道具
        for i=1,num do
    		local rw,rewkey= getRewardByPool(activeCfg.serverreward.singlePool)
	        for k,v in pairs(rw) do
	        	if string.find(k,'anv') then
	        		spprop[k]=(spprop[k] or 0)+v
	        	else
	        		reward[k]=(reward[k] or 0)+v
	        	end
	        end
    	end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

    	if next(spprop) then
    		for k,v in pairs(spprop) do
    			 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
    			 table.insert(report,self.formatreward({[k]=v}))
    		end
    	end

        -- 扣除道具
		for i=1,4 do
	    	mUseractive.info[self.aname]['anv_b'..i] = mUseractive.info[self.aname]['anv_b'..i] - num
        end

        -- 增加应援积分
       	local score = 0 --全服积分
		local scoreInfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
    	if type(scoreInfo)=='table' then
        	 score = scoreInfo.info.count 
        end

        score = score + num*activeCfg.supportScore
		if not setFreeData(self.aname..mUseractive.info[self.aname].st, {count=score}) then
        	 response.ret=-106
             return response
        end        

        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report
            response.data[self.aname].score = score

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    			
	end

	-- 领取全服应援奖励
	function self.action_spreward(request)
		local uid = request.uid
        local response = self.response
        local item = request.params.item
       
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid or not item then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
      

       	local score = 0 --全服积分
		local scoreInfo = getFreeData(self.aname..mUseractive.info[self.aname].st)
    	if type(scoreInfo)=='table' then
        	 score = scoreInfo.info.count 
        end

        if mUseractive.info[self.aname].support[item]==1 then
        	response.ret = -1976
        	return response
        end

        -- 积分判断
        if score<activeCfg.supportNeed[item] then
        	response.ret = -1996
        	return response
        end

        local reward = {}
        local report = {}
        local spprop = {} -- 特殊道具
        local rewardCfg = activeCfg.serverreward['gift'..item]
        if type(rewardCfg)~='table' then
        	response.ret = -102
        	return response
        end

        for k,v in pairs(rewardCfg) do
       		if string.find(v[1],'anv') then
	        	spprop[v[1]]=(spprop[v[1]] or 0)+v[2]
	        else
	        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
	        end
        end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

    	if next(spprop) then
    		for k,v in pairs(spprop) do
    			 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
    			 table.insert(report,self.formatreward({[k]=v}))
    		end
    	end

        mUseractive.info[self.aname].support[item]=1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    			

	end

	-- 分享facebook奖励
	function self.action_fbreward(request)
		local uid = request.uid
        local response = self.response

        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid  then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        -- 领取过
        if mUseractive.info[self.aname].fb==1 then
        	response.ret = -1976
        	return response
        end

        local reward = {}
        local report = {}
        local spprop = {} -- 特殊道具
        local rewardCfg = activeCfg.serverreward.fbreward
        if type(rewardCfg)~='table' then
        	response.ret = -102
        	return response
        end

        for k,v in pairs(rewardCfg) do
       		if string.find(v[1],'anv') then
	        	spprop[v[1]]=(spprop[v[1]] or 0)+v[2]
	        else
	        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
	        end
        end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

    	if next(spprop) then
    		for k,v in pairs(spprop) do
    			 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
    			 table.insert(report,self.formatreward({[k]=v}))
    		end
    	end

        mUseractive.info[self.aname].fb=1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    			

	end

	-- 分享红色卡片
	function self.action_share(request)
		local uid = request.uid
        local response = self.response

        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid  then
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

        local activeCfg = mUseractive.getActiveConfig(self.aname)

        if mUserinfo.alliance == 0 then
        	response.ret = -4005--未加入军团
        	return response
        end

        if not mUseractive.info[self.aname].anv_a2 or mUseractive.info[self.aname].anv_a2<=0 then
        	response.ret = -102
        	return response
        end

		-- 创建礼包
        local flagid = mUserinfo.alliance.."_"..ts
        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..flagid
        local redis = getRedis()
        local gnum = activeCfg.cardShare
        redis:hset(redkey,'num',gnum)
        local info = {
            id = flagid,
            sender = uid,
            uname = mUserinfo.nickname,
            allianceId =  mUserinfo.alliance,
            allianceName = mUserinfo.alliancename,
            ulist = {},
            nu = gnum ,
            ts = ts,
        }
        local data = json.encode(info)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,ts+86400*3)

        mUseractive.info[self.aname].anv_a2 = mUseractive.info[self.aname].anv_a2 - 1
        if uobjs.save() then
        	response.data[self.aname] =mUseractive.info[self.aname]
        	response.data.cardinfo = info
            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    	
	end

	-- 抢别人分享的红卡
	function self.action_grab(request)
 		local uid = request.uid
        local response = self.response
        local gid = request.params.id -- 分享编号
        local ts= getClientTs()

        if not uid or not gid then
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

        local alliance = mUserinfo.alliance
        if alliance==0 then
        	response.ret = -4005   --没加入军团 不能领取奖励
        	return response
        end

        local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..gid
        local redis = getRedis()
 		local giftinfo = json.decode(redis:hget(redkey,'info'))
		if type(giftinfo)~='table' or not next(giftinfo) then
			response.ret = -4001 --数据发生变化重试
			return response
		end

        -- 只能领取所在军团的礼包
		if alliance~=giftinfo.allianceId then
			response.ret = -2039
			return response
		end

	    local leftnum=tonumber(redis:hget(redkey,'num'))
	    if leftnum<=0 then
	    	response.ret = -30005
	    	return response
	    end

	    -- 需要判断当前玩家是否已领取  礼包是否能领取  是否是玩家发的
	    if giftinfo.sender == uid then
		    response.ret = -30004
		    return response
	    end

		for k,v in pairs(giftinfo.ulist) do
			if v[1]==uid then
				response.ret = -30001 --已领取
				return response
			end
    	end

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local reward = {}
		local spprop = {}
		local report = {}

		local result,rewardkey = getRewardByPool(activeCfg.serverreward.pool2,1)
		for k,v in pairs (result) do
			for rk,rv in pairs(v) do
				if string.find(rk,'anv') then
	        		spprop[rk]=(spprop[rk] or 0)+rv
		        else
	            	reward[rk]=(reward[rk] or 0)+rv
	            end
        	end
        end

	
        if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report,formatReward({[k]=v}))
	        end
    	end

    	if next(spprop) then
    		for k,v in pairs(spprop) do
    			 mUseractive.info[self.aname][k] = (mUseractive.info[self.aname][k] or 0) + v
    			 table.insert(report,self.formatreward({[k]=v}))
    		end
    	end

        table.insert(giftinfo.ulist,{uid,mUserinfo.nickname,report,ts})
		local data = json.encode(giftinfo)
        redis:hset(redkey,'info',data)
        redis:expireat(redkey,ts+86400*3)

        -- 减少礼包
		local left=redis:hincrby(redkey,"num",-1)
		if left<0 then
			response.ret =-30005 -- 超出上限
			return response
		end

        giftinfo.left = left
        giftinfo.received = 1
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data.reward = report
            response.data.sinfo = giftinfo
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response		

	end

	-- 查看分享的红卡领取情况
	function self.action_view(request)
		local uid = request.uid
        local response = self.response
        local sid = request.params.id
        if not uid or not sid then
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

        local alliance = mUserinfo.alliance
        if alliance==0 then
			response.ret = -4005   --未加入军团
        	return response
        end

  		local redkey = "zid."..getZoneId().."."..self.aname.."ts"..mUseractive.info[self.aname].st.."_"..sid
        local redis = getRedis()
 		local info = json.decode(redis:hget(redkey,'info'))
		if type(info)~='table' or not next(info) then
			response.ret = -4001 --数据发生变化重试
			return response
		end

		if alliance~=info.allianceId then
			response.ret = -2039
			return response
		end

		local received=0--没有领取过
	    for k,v in pairs(info.ulist) do
	        if v[1]==uid then
	            received=1
	            break
	        end
	    end			

		info.left = tonumber(redis:hget(redkey,'num')) or 0
		info.received = received
		response.ret = 0
		response.msg = "Success"
		response.data.sinfo = info

		return response		

	end

    -- 流失玩家绑定活跃玩家
    function self.action_bind(request)
        local response = self.response
        local ts = getClientTs()
        local uid = request.uid
        local inviteCode = request.params.inviteCode

        if not uid or not inviteCode then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].bd) ~= "table" then
            mUseractive.info[self.aname].bd = {}
        end

        -- 活跃玩家不能绑定或者自己已经绑定
        if mUseractive.info[self.aname].u ~= 1 or (#mUseractive.info[self.aname].bd >= 1) then
            response.ret = -1971
            return response
        end

        local bindUid = getUidByInviteCode(inviteCode)

        -- 玩家不存在或者是被绑定的玩家是自己
        -- 策划要求开多次活动时的邀请码要保护一致,有可能上次开的时候此玩家是一个活跃玩家,分配了一个激活码
        -- 本次活动成了为流失用户,然后输入邀请码的时候输入了老的
        if not bindUid or bindUid == uid then
            response.ret = -1972
            return response
        end

        local bindUobjs = getUserObjs(bindUid)
        local bindUseractive = bindUobjs.getModel('useractive')
        local bindUserinfo = bindUobjs.getModel('userinfo')
        if type(bindUseractive.info[self.aname].bd) ~= "table" then
            bindUseractive.info[self.aname].bd = {}
        end

        -- 只能把自己绑定在活跃玩家身上
        if bindUseractive.info[self.aname].u ~= 2 then
            response.ret = -1972
            return response
        end

        table.insert(bindUseractive.info[self.aname].bd,uid)--流失玩家id
        table.insert(mUseractive.info[self.aname].bd,{bindUid,0})--绑定活跃玩家id,有没有领取回归奖励

        if uobjs.save() and bindUobjs.save() then
            response.data[self.aname] = mUseractive.info[self.aname]
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 领取回归奖励
    function self.action_returnreward(request)
		local response = self.response
        local ts = getClientTs()
        local uid = request.uid

        if not uid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].bd) ~= "table" then
            mUseractive.info[self.aname].bd = {}
        end

        -- 只能流失玩家才可以领取奖励
        if mUseractive.info[self.aname].u ~= 1 or (#mUseractive.info[self.aname].bd < 1) then
            response.ret = -102
            return response
        end
        -- 已领取
        if mUseractive.info[self.aname].bd[1][2] ==1 then
        	response.ret = -1976
        	return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local reward = {}
        local report = {}
        for k,v in pairs(activeCfg.serverreward.returnGet) do
	        reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

        mUseractive.info[self.aname].bd[1][2] = 1
        if uobjs.save() then
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response

    end

    -- 活跃玩家领取召回奖励
    function self.action_backreward(request)
		local response = self.response
        local ts = getClientTs()
        local uid = request.uid

        if not uid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].bd) ~= "table" or mUseractive.info[self.aname].u~=2 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local getN = mUseractive.info[self.aname].bn or 0 --已领取的次数
        -- 领取次数达上限
        if getN >= activeCfg.callbackGetLimit then
        	response.ret = -1993
        	return response
        end

        local tN = #mUseractive.info[self.aname].bd or 0
        -- 不能领取了
        if tN < getN then
        	response.ret = -102
        	return response
        end


        local reward = {}
        local report = {}
        for k,v in pairs(activeCfg.serverreward.callbackGet) do
	        reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

        mUseractive.info[self.aname].bn = (mUseractive.info[self.aname].bn or 0) +1
        if uobjs.save() then
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    	

    end

    -- 领取流失玩家充值奖励
    function self.action_returncharge(request)
		local response = self.response
        local ts = getClientTs()
        local uid = request.uid

        if not uid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mUseractive = uobjs.getModel('useractive')
        local activeCfg = mUseractive.getActiveConfig(self.aname)

         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        if type(mUseractive.info[self.aname].bd) ~= "table" or mUseractive.info[self.aname].u~=2 then
            response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local getN = mUseractive.info[self.aname].rcn or 0 --已领取的次数
        -- 领取次数达上限
        if getN >= activeCfg.callrechargeGetLimit then
        	response.ret = -1993
        	return response
        end

        local reward = {}
        local report = {}
        for k,v in pairs(activeCfg.serverreward.callrechargeGet) do
	        reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

    	if next(reward) then
	 		if not takeReward(uid,reward) then
	        	response.ret = -403
	        	return response
	        end
	        for k,v in pairs(reward) do
	        	table.insert(report, formatReward({[k]=v}))
	        end
    	end

        mUseractive.info[self.aname].rcn = (mUseractive.info[self.aname].rcn or 0) +1
        if uobjs.save() then
        	response.data[self.aname] = mUseractive.info[self.aname]
            response.data[self.aname].reward = report

            response.ret = 0
            response.msg = 'Success'
        else
        	response.ret = -106
        end

        return response    	
    end

    -- 获取faccebook分享地址  跟啤酒节用的是通过一个数值
 	function self.action_fbURL(request)
		local uid = request.uid
        local response = self.response
        local zoneid = request.zoneid
        local ts= getClientTs()
        local weeTs = getWeeTs()

        if not uid or not zoneid then
        	response.ret = -102
        	return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')
        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

		local url = nil
        local redis =getRedis()
        local urlkey = "facebookshareurl"
        local fbkey = "zid."..getZoneId()..urlkey
	    local fburl=redis:get(fbkey)

        if fburl then
        	url = fburl
        else
            local freedata = getFreeData(urlkey)
            url = freedata.info.url
            redis:set(fbkey,url)	
        end

	    response.data.fb = mUseractive.info[self.aname].fb
	    response.data.url =  url
	    response.ret = 0
	    response.msg = 'Success'

	    return response
    end



    return self
end

return api_active_anniversary2
