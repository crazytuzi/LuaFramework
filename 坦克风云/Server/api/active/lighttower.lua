--desc: 点亮铁塔
--user:chenyunhe
local function api_active_lighttower(request)
	local self={
	    response={
	       ret=-1,
	       msg='error',
           data={},
		},
		aname="lighttower",
    }

    --领取任务奖励 领取任务之后需要重新给玩家刷新任务数据
    function self.action_taskreward(request)
        local response = self.response
        local uid = request.uid
        local tid=request.params.tid --任务奖励
        local weeTs = getWeeTs()

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
       
		if tid~=mUseractive.info[self.aname].tw.tk.id then
           response.ret=-102
           return response
        end
        --  判断是否完成
        if mUseractive.info[self.aname].tw.tk.r~=1 then
        	response.ret=-102
        	return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local tklayer=mUseractive.info[self.aname].tw.tk.l
        local rewardCfg=activeCfg.serverreward.changedTask[tid].serverreward[tklayer]

        local reward={}
        for k,v in pairs(rewardCfg) do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end
        --给自己和全服增加贡献值
        local attribution=activeCfg.serverreward.changedTask[tid].attribute[tklayer]
        mUseractive.info[self.aname].tw.pg=mUseractive.info[self.aname].tw.pg+attribution        

        -- 重新设置玩家的任务数据
  		local allatt=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local atttri=0
        if type(allatt)=='table' then
        	atttri=allatt.info.count
        end

        atttri=atttri+attribution
        if not setFreeData(self.aname..mUseractive.info[self.aname].st, {count=atttri}) then
        	 response.ret=-106
             return response
        end

	    local serverlayer=1--当前的层数
		local tmpatt=atttri
        for i=1,#activeCfg.needScore do
        	tmpatt=tmpatt-activeCfg.needScore[i]
        	if tmpatt<0 then
               serverlayer=i
               break
        	end
        end

    	local tasks={}
    	for k,v in pairs(activeCfg.serverreward.changedTask) do
    		if mUserinfo.level>=v.levelLimit then
    			table.insert(tasks,k)
    		end
    	end
    	--每次随机到不同类型的任务
    	local lasttype=mUseractive.info[self.aname].tw.tk.ty
    	local function randtask(lasttype,tasks)
	        setRandSeed()
	        local rd=rand(1,#tasks)
	        local rtask=activeCfg.serverreward.changedTask[rd]
	        if rtask.key==lasttype then
	        	return randtask(lasttype,tasks)
	        else
	        	return rtask,rd
	        end	
    	end
    	
        local curtask,trd=randtask(lasttype,tasks)
        local rflag=0
        if atttri>=activeCfg.totalScore then
        	rflag=2
        end
        --获取任务： 任务类型  编号 当前值 完成条件 分配任务时的层数 使用钻石 领取状态0未完成 1可领取 2不可做的任务
        mUseractive.info[self.aname].tw.tk={ty=curtask.key,id=trd,cu=0,con=curtask.needNum[serverlayer],l=serverlayer,gem=curtask.gemcost[serverlayer],r=rflag}
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].totalAtt =activeCfg.totalScore
            response.data[self.aname].allserveratt =atttri
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
	    else
	        response.ret=-106
	    end

	    return response
    end

    -- 使用钻石完成任务
    function self.action_usegem(request)
    	local uid = request.uid
        local response = self.response
        local tid= request.params.tid --任务编号
        local ts= getClientTs()
        local weeTs = getWeeTs()

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
        
        if tid~=mUseractive.info[self.aname].tw.tk.id then
           response.ret=-102
           return response
        end

        if not mUseractive.info[self.aname].tw.tk.gem then
        	response.ret=-102
        	return response
        end

        local gems=0
        if mUseractive.info[self.aname].tw.tk.gem and mUseractive.info[self.aname].tw.tk.gem>0 then
        	gems=mUseractive.info[self.aname].tw.tk.gem
        end
        -- 消极的钻石不能为0
        if gems==0 then
        	response.ret=-1
        	return response
        end

		if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=168,item="",value=gems,params={num=tid}})

        -- 修改任务状态
        mUseractive.info[self.aname].tw.tk.r=1
        mUseractive.info[self.aname].tw.tk.cu= mUseractive.info[self.aname].tw.tk.con

        -- 总贡献值
    	local allatt=getFreeData(self.aname..mUseractive.info[self.aname].st)
    	local atttri=0
        if type(allatt)=='table'  then
        	atttri=allatt.info.count
        end

		if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].totalAtt =activeCfg.totalScore
            response.data[self.aname].allserveratt =atttri
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response 
    end


    -- 获取当前塔的信息
    function self.action_towerinfo(request)
    	--当前任务
    	--玩家当前的贡献度
    	--每层贡献领取状态
        --大奖领取的状态
		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

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
        --全服贡献值
        local allatt=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local atttri=0
        if type(allatt)=='table'  then
        	atttri=allatt.info.count
        end

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local serverlayer=1--当前的层数
		local tmpatt=atttri
        for i=1,#activeCfg.needScore do
        	tmpatt=tmpatt-activeCfg.needScore[i]
        	if tmpatt<0 then
               serverlayer=i
               break
        	end
        end

        if type(mUseractive.info[self.aname].tw)~='table' then
        	mUseractive.info[self.aname].tw={}--初始化
        	mUseractive.info[self.aname].tw.pg=0  -- 个人贡献值
        	mUseractive.info[self.aname].tw.r={}--每层领取状态
        	--每层领取状态
        	local layers=activeCfg.height+1--所有层  +1代表的是最重的奖励领取状态
        	for i=1,layers do
        		table.insert(mUseractive.info[self.aname].tw.r,0)
        	end

        	-- 初始化玩家的任务 在小于等于玩家的等级中随机任务
        	local tasks={}
        	for k,v in pairs(activeCfg.serverreward.changedTask) do
        		if mUserinfo.level>=v.levelLimit then
        			table.insert(tasks,k)
        		end
        	end

			setRandSeed()
            local rd=rand(1,#tasks)
            local curtask=activeCfg.serverreward.changedTask[rd]
            --获取任务： 任务类型  编号 当前值 完成条件 分配任务时的层数 使用钻石 领取状态0未完成 1可领取
            local rflag=0
            if atttri>=activeCfg.totalScore then
            	rflag=2
            end
            mUseractive.info[self.aname].tw.tk={ty=curtask.key,id=rd,cu=0,con=curtask.needNum[serverlayer],l=serverlayer,gem=curtask.gemcost[serverlayer],r=rflag}
        end

        --如果全服贡献度达到上限  没完成当前任务的玩家可以继续完成任务  已完成的不再刷新任务
     
        if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].totalAtt =activeCfg.totalScore
            response.data[self.aname].allserveratt =atttri
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response        

    end

    --领取每层贡献奖励
    function self.action_layerreward(request)
		local uid = request.uid
        local response = self.response
        local layer=request.params.layer--领取奖励的层数
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
         --全服贡献值
        local allatt=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local atttri=0
        if type(allatt)=='table'  then
        	atttri=allatt.info.count
        end

		local serverlayer=1--当前的层数
		local tmp={}
		local attval=0
        for i=1,#activeCfg.needScore do
        	attval=attval+activeCfg.needScore[i]
        	table.insert(tmp,attval)
        end

        if atttri<tmp[layer] then
           response.ret=-102
           return response
        end

        -- 已经领取过
        if mUseractive.info[self.aname].tw.r[layer]==1 then
        	response.ret=-1976
        	return response
        end

        local rewardCfg=activeCfg.serverreward.allReward[layer]
        local reward={}
        for k,v in pairs(rewardCfg) do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end
        --修改状态
        mUseractive.info[self.aname].tw.r[layer]=1
		if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].totalAtt =activeCfg.totalScore
            response.data[self.aname].allserveratt =atttri
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'

	    else
	        response.ret=-106
	    end	

	    return response
	 end

    -- 获取最终的大奖
    function self.action_finalgift(request)
		local uid = request.uid
        local response = self.response
        local ts= getClientTs()
        local weeTs = getWeeTs()

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","props","bag",'useractive'})
        local mUseractive = uobjs.getModel('useractive')

        -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

        
        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local ind=activeCfg.height+1
        -- 已经领取过
        if mUseractive.info[self.aname].tw.r[ind]==1 then
        	response.ret=-1976
        	return response
        end

         --全服贡献值
        local allatt=getFreeData(self.aname..mUseractive.info[self.aname].st)
        local atttri=0
        if type(allatt)=='table'  then
        	atttri=allatt.info.count
        end

        -- 全服的贡献值不够
        if activeCfg.totalScore>atttri then
           response.ret=-102
           return response
        end

        local personal=mUseractive.info[self.aname].tw.pg
        local index=0
        for i=#activeCfg.specialReward,1,-1 do
        	if personal>=activeCfg.specialReward[i] then
        		index=i
        		break
        	end
        end

        if index==0 then
        	response.ret=-102
        	return response
        end

        local rewardCfg=activeCfg.serverreward.specialReward[index]
        local reward={}
        for k,v in pairs(rewardCfg) do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        -- 修改状态
        mUseractive.info[self.aname].tw.r[ind]=1 
        mUseractive.info[self.aname].allserveratt=atttri--全服贡献值
		if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].totalAtt =activeCfg.totalScore
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response
    end

    -- 获取国庆商店数据
    function self.action_shoplist(request)
       local response=self.response
       local  uid=request.uid
       local weeTs=getWeeTs()
       local ts= getClientTs()
       local uobjs=getUserObjs(uid)
       uobjs.load({"useractive"})
       local mUseractive=uobjs.getModel('useractive')

       --活动检测
       local activStatus=mUseractive.getActiveStatus(self.aname)
       if activStatus~=1 then
       	  response.ret=activStatus
       	  return response
       end

       -- 根据活动第几天 生成相应的任务数据和商店列表
 	   local st = mUseractive.info[self.aname].st or 0
       local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
       if currDay>3 then
       	  response.ret=-124
       	  return response
       end
       
       local activeCfg = mUseractive.getActiveConfig(self.aname)
 	   local recharge=activeCfg.serverreward.recharge[currDay]
       if type(recharge)~='table' or not next(recharge) then
       	  response.ret=-102
       	  return response
       end

       local discount=activeCfg.serverreward.discount[currDay]
       if  type(discount)~='table' then
       	 response.ret=-102
       	 return response
       end

       if type(mUseractive.info[self.aname].sh)~='table' then
       	  mUseractive.info[self.aname].sh={}
       	  --充值
       	  mUseractive.info[self.aname].sh.c={g=0,r={0,0}}--g累计充值钻石 r[1]每日充值任意钻石  r[2]累计充值 0未领取 1 可领取 2已领取
          -- local buynum={}
          -- for i=1,#discount do
          --	table.insert(buynum,0)
          --end
          --商店
          -- mUseractive.info[self.aname].sh.p=buynum
       end

       -- 商店
       if type(mUseractive.info[self.aname].sh.p)~='table' then
            mUseractive.info[self.aname].sh.p={}
            for i=1,#discount do
                mUseractive.info[self.aname].sh.p[i]=0
            end
       end

       if mUseractive.info[self.aname].t < weeTs then
       	  mUseractive.info[self.aname].t = weeTs
       	  --重置玩家的商店购买记录
          for i=1,#discount do
          	mUseractive.info[self.aname].sh.p[i]=0
          end
       	  --重置每日充值任务
       	   mUseractive.info[self.aname].sh.c={g=0,r={0,0}}
       end

       if uobjs.save() then
            response.data[self.aname] =mUseractive.info[self.aname]
            response.data[self.aname].currDay=currDay
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end

        return response

    end

    -- 商店购买
    function self.action_shopping(request)
		local uid = request.uid
        local response = self.response
        local item= request.params.item-- 具体购买的物品
        local ts= getClientTs()
        local weeTs = getWeeTs()

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

       local st = mUseractive.info[self.aname].st or 0
	   local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
       if currDay>3 then
       	  response.ret=-102
       	  return response
       end        

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local iteminfo=activeCfg.serverreward.discount[currDay][item]
		if type(iteminfo)~='table' then
			response.ret=-102
			return response
		end

		--判断购买次数
		if mUseractive.info[self.aname].sh.p[item]>=iteminfo[2] then
			response.ret=-21030
			return response
		end

        local gems=iteminfo[1]
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=168,item="",value=gems,params={num=1}})

		local rewardCfg=iteminfo[3]
		local reward={}
		for k,v in pairs(iteminfo[3]) do
			reward[v[1]]=(reward[v[1]] or 0)+v[2]
		end

        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end

        mUseractive.info[self.aname].sh.p[item]=mUseractive.info[self.aname].sh.p[item]+1
		if uobjs.save() then
			response.data[self.aname] =mUseractive.info[self.aname]
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response
    end

    --领取国庆商店充值任务奖励
    function self.action_daycharge(request)
		local uid = request.uid
        local response = self.response
        local item= request.params.item-- 1:每日任意充值 2每日累计充值
        local ts= getClientTs()
        local weeTs = getWeeTs()



        if not table.contains({1,2},item) then
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

        --判断是否已经领取过
        if mUseractive.info[self.aname].sh.c.r[item]~=1 then
        	response.ret=-102
        	return response
        end
        local st = mUseractive.info[self.aname].st or 0
  		local currDay = math.floor(math.abs(ts-getWeeTs(st))/(24*3600)) + 1;
        if currDay>3 then
       	  response.ret=-102
       	  return response
        end

		local activeCfg = mUseractive.getActiveConfig(self.aname)
		local iteminfo=activeCfg.serverreward.recharge[currDay][item]
		if type(iteminfo)~='table' then
			response.ret=-102
			return response
		end
        
        local reward={}
        for k,v in pairs(iteminfo[2]) do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]

        end

 		if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end        

		mUseractive.info[self.aname].sh.c.r[item]=2
		if uobjs.save() then
			response.data[self.aname] =mUseractive.info[self.aname]
            response.data.reward=formatReward(reward)
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret=-106
        end
        return response        

    end

    return self
end

return api_active_lighttower
