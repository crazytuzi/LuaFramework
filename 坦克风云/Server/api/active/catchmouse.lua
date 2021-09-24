--desc:灭鼠计划
--user:chenyunhe

local function api_active_catchmouse(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
        aname = 'catchmouse',
    }

    -- 抽取奖励
    function self.action_reward(request)
        local response = self.response
        local uid = request.uid
        local free = request.params.free or nil -- 1:免费
        local num = request.params.num or 1 --抽取次数 1 或 10
        local actTowers= request.params.towers --激活的塔 {1,2,3,4,5}
        local ts = getClientTs()
        local weeTs = getWeeTs()

        if not table.contains({1,10},num) then
            response.ret = -102
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


       local activeCfg = mUseractive.getActiveConfig(self.aname)
       local mode=1 --攻击方式1：单体，2群体伤害
        -- 消耗钻石
        local gems = 0
        if free==1 then
        	 mUseractive.info[self.aname].v=1
	        -- 第一个塔是固定有的 且免费只有一个塔激活
	        actTowers={}
	        table.insert(actTowers,1)
        else
        	
        	if not table.contains(actTowers,1) then
	        	table.insert(actTowers,1)
	        end
	        local townum=#actTowers
			local tCost=activeCfg.towerCost[townum]

        	if num ==1 then
            	gems = activeCfg.cost1+tCost
	        else
	        	mode=2
	            num=10
	            gems = activeCfg.cost2+tCost
	        end

	        if not gems or gems <= 0 then
	            response.ret = -102
	            return response
	        end
        end

        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=167,item="",value=gems,params={num=num}})

        -- 结算结果
        local function makereward(result)
        	-- 如果出现橙色品质，需要判定出现指定物品的额次数
        	local function checklimit(index)
        		local rw,rewkey= getRewardByPool(activeCfg.serverreward['pool'..index])--老鼠en
        		if type(mUseractive.info[self.aname].lm)~='table' then
        			mUseractive.info[self.aname].lm={}
        	    end
                local limitkey={}
        	    for k,v in pairs(activeCfg.serverreward.limit) do 
        	    	limitkey[v[1]]=v[2]
        	    	if not mUseractive.info[self.aname].lm[v[1]] then
        	    		mUseractive.info[self.aname].lm[v[1]]=0
        	    	end
        	    end
 
        		for k,v in pairs(rw) do
        			--指定物品获取次数达到上限 需要重新随机处理
        			if table.contains(table.keys(limitkey),k) and mUseractive.info[self.aname].lm[k]>=limitkey[k] then
	        			 return checklimit(index)
	        		else
						if table.contains(table.keys(limitkey),k) then
							mUseractive.info[self.aname].lm[k]=(mUseractive.info[self.aname].lm[k] or 0)+1
        				end
        				return rw,rewkey
	        		end
        		end
        	end

        	local rwd={}
        	local report={}
        	for k,v in pairs(result) do
        		for i=1,v do
        			local rw,rewkey
					if k==5 then
	        			rw,rewkey=checklimit(k)
	        		else
	                    rw,rewkey= getRewardByPool(activeCfg.serverreward['pool'..k])--老鼠
	        		end
					for r,rv in pairs(rw) do
	        			rwd[r]=(rwd[r] or 0 )+rv
	        		end
        		end

        	end

 			for k,v in pairs(rwd) do
		        table.insert(report, formatReward({[k]=v}))
		    end

		    return rwd,report
        end

        -- 任务记录
	    local function recordtask(result,actTowers)
	    	if type(mUseractive.info[self.aname].task)~='table' or not next(mUseractive.info[self.aname].task) then
	        	mUseractive.info[self.aname].task={}
	        	for k,v in pairs(activeCfg.serverreward.taskList) do
	        		mUseractive.info[self.aname].task[k]={}
	        		mUseractive.info[self.aname].task[k].index=v[1].index
	        		mUseractive.info[self.aname].task[k].p=1
	        		mUseractive.info[self.aname].task[k].r=0 --0未完成、1可领取、2已领取
	        		if k=='m1' then
	        			mUseractive.info[self.aname].task[k].cur={0,0,0,0,0}--当前 击杀各种颜色
	        		else
	        			mUseractive.info[self.aname].task[k].cur=0 --当前数量
	        		end
	        	end
	        end

	        local total=0
	        for k,v in pairs(result) do
	        	 mUseractive.info[self.aname].task.m1.cur[k]=mUseractive.info[self.aname].task.m1.cur[k]+v
	        	 total=total+v
	        end

	        if #actTowers==5 then
	        	mUseractive.info[self.aname].task.m6.cur=mUseractive.info[self.aname].task.m6.cur+1
	        end


	        mUseractive.info[self.aname].task.m7.cur=mUseractive.info[self.aname].task.m7.cur+total
	    end


        local towersCfg=activeCfg.serverreward.towers
	    -----------------------------------------------准备老鼠数据
        --老鼠类
	    local mouseC=function(c,h,i,r,l)
            local self={
            	no=i,--生成顺序
                hp=h,--血量 
                t=c,--品质
                p=0,--路线中的位置
		        l=l,--移动过程
                r=r,--路线
            }
            -- 老鼠移动
            function self.move(positon)
            	self.p=positon
            end
            --掉血计算 a 受到攻击 t攻击类型
            function self.delhp(a,t)
            	self.hp=self.hp-a
                self.setStatus(t)
            end
            --设置状态
            function self.setStatus(t)
            	if self.hp>0 then
            		self.l[self.p]=t
            	else
            		self.l[self.p]=-1
            	end
            end

            return self
	    end
        -- 初始化老鼠
        local mice={}
	    for i=1,10 do
			local mouse,color = getRewardByPool(activeCfg.serverreward.balls)--老鼠
        	local road= getRewardByPool(activeCfg.serverreward.roadpool)--随机路线
        	local l={}---初始化攻击过程

        	for k,v in pairs(towersCfg) do
        		if next(v[road[1]])  then
        			for n=v[road[1]][1],v[road[1]][2] do
        				l[n]=0
        			end
        		end
        	end

            -- 颜色，血量，编号，路线
        	if i==1 then
        		local defhp=activeCfg.serverreward.balls[3][1]
        		table.insert(mice,mouseC(1,defhp,i,road[1],l))
        	else
        		table.insert(mice,mouseC(color[1],mouse[1],i,road[1],l))
        	end
	    end

	    ------------------------------------准备塔的数据
	    --塔类   
	    local towerC=function(affectroad,index,mode)
	       local self={
	          roads=affectroad,--{1,2,3}影响的路线
	          no=index,--塔的编号
	          m=mode,--攻击模式 1单体 2火力全开
	       }

           -- 查找可攻击对象
	       function self.find(objs)
	       	-----找到可攻击目标
	       	 local r={}
	       	 for k,v in pairs(objs) do
	       	 	if table.contains(self.roads,v.r) and v.hp>0 and self.check(v.r,v.p) then
	       	 		--单体攻击
	       	 		if self.m==1 then
	       	 			table.insert(r,v)
	       	 			break
	       	 		else--火力全开
	       	 			table.insert(r,v)
	       	 		end
                end
	       	 end

       	     return r
	       end

           --获取攻击
	       function self.attack(m)
				local a,t=self.getAtt()
		       	m.delhp(a,t)
	       end
           -- 塔攻击
	       function self.getAtt()
	       		setRandSeed()
				local rand=rand(1,100)
				local force=1
				if rand<=activeCfg.criticalRate*100 then
					force=2
					return activeCfg.attack[2],force
				end

				return activeCfg.attack[1],force
	       end
           --判断是否在塔的攻击范围 路线 位置
	       function self.check(r,p)
	       	  if p>=towersCfg[self.no][r][1] and p<=towersCfg[self.no][r][2] then
	       	  	return true
	       	  end

	       	  return false
	       end

	       return self

	    end

        local useTowers={}
	    --初始化塔  且是被激活的塔
        for k,v in pairs(towersCfg) do
        	if table.contains(actTowers,k) then
        		local affectroad={}
        		for i=1,3 do
        			if type(v[i])=='table' and next(v[i]) then
        				table.insert(affectroad,i)
        			end
        		end
        		table.insert(useTowers,towerC(affectroad,k,mode))
        	end
        end


        -- 老鼠移动速度 
        local space=activeCfg.miceSpace
        ----------  start -------
       	for i=1,activeCfg.pathLength do
       		local step=i
       		for k,v in pairs(mice) do
       			v.move(step)
       			step=step-space
       		end

       		for k,v in pairs(useTowers) do
       			for _,m in pairs(v.find(mice)) do
       				v.attack(m)
       			end
       		end
        end
        ----------end---------------

	    -- {r=1,t=1,l={1,1,1,1,0,0,0,0,0}}
        -- r 路线
        -- t 老鼠品质
        -- l 0未被打  1普通伤害 2暴击 －1死亡
        local function getresult(mice)
        	local  movelog={}
        	local  r={}
        	for k,v in pairs(mice) do
        		if type(movelog[v.no])~='table' then
        			movelog[v.no]={}
        		end
        		movelog[v.no].t=v.t
        		movelog[v.no].r=v.r

			    local key_table = {}
			    --取出所有的键  
			    for key,_ in pairs(v.l) do  
			       table.insert(key_table,key)  
			    end
                local tmp={}
			    --对所有键进行排序  
		        table.sort(key_table)  
		        for nu,key in pairs(key_table) do
		        	tmp[nu]=v.l[key]
	            end 
	            movelog[v.no].l=tmp
        		if v.hp<=0 then
        			r[v.t]=(r[v.t] or 0)+1
        		end
        	end
        	return movelog,r
        end

        local attacklog,result=getresult(mice)
        --如果一个老鼠都没打死 要默认给一个白色的
        if not next(result) then
        	table.insert(result,1)
        end

        local finalreward,report=makereward(result)
        recordtask(result,actTowers)


        if not takeReward(uid,finalreward) then
        	response.ret=-403
            return response
        end


        local clientReport= copyTable(report)
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward = harVerGifts('active','catchmouse',num)
            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward = hClientReward
            for k,v in pairs(hReward) do
                table.insert(report,formatReward({[k]=v}))
            end
        end

        if uobjs.save() then
            local redis =getRedis()
            local redkey ="zid."..getZoneId()..self.aname..mUseractive.info[self.aname].st.."uid."..uid
            local data =redis:get(redkey)
            data =json.decode(data)
            if type (data)~="table" then data={}  end
            table.insert(data,1,{ts,report,num})
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
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=clientReport
            response.data.attacklog=attacklog

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

         -- 活动检测
        local activStatus = mUseractive.getActiveStatus(self.aname)
        if activStatus ~= 1 then
            response.ret = activStatus
            return response
        end

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

    -- 获取任务列表
    function self.action_tasklist(request)
		local response = self.response
        local uid = request.uid
        if not uid then
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

        if not mUseractive.info[self.aname].ea then
            mUseractive.info[self.aname].ea=0--可领取的任务额外奖励数
            mUseractive.info[self.aname].er=0--已领取的个数
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        if type(mUseractive.info[self.aname].task)~='table' or not next(mUseractive.info[self.aname].task) then
        	mUseractive.info[self.aname].task={}
        	for k,v in pairs(activeCfg.serverreward.taskList) do
        		mUseractive.info[self.aname].task[k]={}
        		mUseractive.info[self.aname].task[k].index=v[1].index
        		mUseractive.info[self.aname].task[k].r=0 --0未完成、1可领取、2已领取
        		mUseractive.info[self.aname].task[k].p=1 --进度 1,2,3
				if k=='m1' then
        			mUseractive.info[self.aname].task[k].cur={0,0,0,0,0}--当前 击杀各种颜色
        		else
        			mUseractive.info[self.aname].task[k].cur=0 --当前数量
        		end
        	end
        	mUseractive.info[self.aname].ea=0--可领取的任务额外奖励数
        	mUseractive.info[self.aname].er=0--已领取的个数
        end

		local taskCfg=activeCfg.serverreward.taskList
        for k,v in pairs(mUseractive.info[self.aname].task) do
        	local kills=mUseractive.info[self.aname].k
        	local info=taskCfg[k][v.p]

        	if v.r==0 then
        		mUseractive.info[self.aname].task[k].con=info[1]
	        	if k=='m1' then----击杀蓝，紫，橙品质老鼠各N只
	        		local fg=true
	        		for i=3,5 do
	        			if mUseractive.info[self.aname].task[k].cur[i]<info[1] then
	        				fg=false
	        				break
	        			end
	        		end
	        		if fg then
	        			mUseractive.info[self.aname].task[k].r=1
	        		end
	        	elseif k=="m2" then----击杀X色老鼠20只（1-白，2-绿，3-蓝，4-紫，3-橙）
	        		mUseractive.info[self.aname].task[k].cur=mUseractive.info[self.aname].task.m1.cur[info[1]]
	        		if mUseractive.info[self.aname].task[k].cur>=25 then
	        			mUseractive.info[self.aname].task[k].r=1
	        		end
	        	elseif k=='m6' then--全部激活 进行N轮
	        		if mUseractive.info[self.aname].task[k].cur>=info[1] then
	        			mUseractive.info[self.aname].task[k].r=1
	        		end
	        	elseif k=="m7" then----累计击杀老鼠N只。
	        		if mUseractive.info[self.aname].task[k].cur>=info[1] then
	        			mUseractive.info[self.aname].task[k].r=1
	        		end
	        	end
                --每种类型任务链都完成可以领取奖励数记录
	        	if mUseractive.info[self.aname].task[k].r==1 and not info.next then
	        		mUseractive.info[self.aname].ea=(mUseractive.info[self.aname].ea or 0)+1
	        	end
        	end
        end

        local extranum=mUseractive.info[self.aname].ea-mUseractive.info[self.aname].er
        if uobjs.save() then
			response.data[self.aname] =mUseractive.info[self.aname]
			response.data[self.aname].extranum=extranum--额外可领取的奖励数
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response      
        
    end
    -- 领取任务奖励
    function self.action_taskreward(request)
		local response = self.response
        local uid = request.uid
        local taskType = request.params.type --任务类型
        local taskP=request.params.p -- 任务进度
       
        if not uid then
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
        local taskList = activeCfg.serverreward.taskList
        local taskCfg=taskList[taskType][taskP]
        if type(taskCfg)~='table' or not next(taskCfg) then
        	response.ret=-102
        	return response
        end

        local curtask=mUseractive.info[self.aname].task[taskType]
        -- 验证任务信息
        if type(curtask)~='table' or not next(curtask) or curtask.p~=taskP then
        	response.ret=-102
        	return response
        end

        if curtask.r~=1 then
        	response.ret=-102
        	return response
        end

        local reward={}
        for k,v in pairs(taskCfg.serverreward)  do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if  not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end

        if taskCfg.next then
        	mUseractive.info[self.aname].task[taskType].p=taskCfg.next
        	mUseractive.info[self.aname].task[taskType].index=taskList[taskType][taskCfg.next].index
        	mUseractive.info[self.aname].task[taskType].r=0
        	mUseractive.info[self.aname].task[taskType].con=taskList[taskType][taskCfg.next][1]

        else
        	mUseractive.info[self.aname].task[taskType].r=2
        end

        if uobjs.save() then
			response.data.reward=formatReward(reward)
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response

    end


    -- 领取完成每个任务链的额外奖励
    function self.action_extrareward(request)
		local response = self.response
        local uid = request.uid

        if not uid then
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

        if mUseractive.info[self.aname].er>=mUseractive.info[self.aname].ea then
 			response.ret = -102
            return response
        end

        local activeCfg = mUseractive.getActiveConfig(self.aname)
        local Extra = activeCfg.serverreward.taskExtra
        local reward={}
        for k,v in pairs(Extra)  do
        	reward[v[1]]=(reward[v[1]] or 0)+v[2]
        end

        if  not takeReward(uid,reward) then
        	response.ret=-403
        	return response
        end
    
        mUseractive.info[self.aname].er=(mUseractive.info[self.aname].er or 0)+1
        if uobjs.save() then
			response.data.reward=formatReward(reward)
	        response.ret = 0
	        response.msg = 'Success'
	    else
	    	response.ret=403
        end
        return response

    end

    return self
end

return api_active_catchmouse