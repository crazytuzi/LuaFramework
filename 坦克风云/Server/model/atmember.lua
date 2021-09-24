-- 公海领地成员数据
function model_atmember(uid,data)
    local self = {
        uid = uid,
        aid = 0,
        seacoin = 0,-- 公海币
        task = {}, --任务
        crack = {n=0,t=0},-- fn每日免费次数 lt上次免费破译时间 cn钻石破译次数
        collect = 0,--每天采集的次数
        daytime = 0,--每日时间标识
        killcount = 0,-- 击杀海盗
        kill_at = 0,--击杀海初始化时间
        killreward = 0,-- 击杀海盗领取奖励标记
        warscore = 0, -- 领海战积分
        warreward = 0, -- 领海战领奖标识
        war_at = 0, -- 上次领海战的时间
        atcontri={n=0,t=0,ts=0},--当前军团任务的贡献度  ts用于判断玩家贡献先后顺序
        updated_at=0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

 		if self.aid==0 then
        	local uobjs = getUserObjs(uid)
	    	uobjs.load({"userinfo"})
	    	local mUserinfo = uobjs.getModel('userinfo')
	    	if mUserinfo.alliance > 0 then
	    		self.aid = mUserinfo.alliance
	    	end
        end

        -- 更新每日需要重置的数据
        self.upDay()

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~='uid' and k~= 'updated_at' then
                    if format then
                        data[k] = v
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end
    
    -- 使用公海币
    function self.useSeacoin(num)
        num = math.ceil(math.abs(tonumber(num)))
        if self.seacoin<num then return false end

        self.seacoin = self.seacoin - num
        return true
    end

    -- 增加公海币
    function self.addSeacoin(num)
		num = math.ceil(math.abs(tonumber(num)))
        self.seacoin = self.seacoin + num
        return true    	
    end
    
    -- 重置成员数据
    function self.resetMember()
    	self.killcount = 0
        self.seacoin = 0
        self.task = {} --任务
        self.crack = {n=0,t=0}--t 每日破译密码时间标识 fn每日免费次数 lt上次免费破译时间 cn钻石破译次数
        self.collect = 0
        self.aid = 0
        self.atcontri={n=0,t=0}

    	return true
    end

    -- 增加采集次数
    function self.addCollectNum(num)
    	self.collect = self.collect+num

    	return true
    end

    -- 初始化采集次数
    function self.upDay()
    	local ts= getClientTs()
        local weeTs = getWeeTs()
        if self.daytime ~= weeTs then
	        self.daytime= weeTs -- 每日时间标识
	        self.collect= 0 -- 每日采集次数

            local t = {self.warscore,self.warreward,self.war_at}
            -- writeLog({"daytime",self.uid,os.time(),t,{},getRequestCmd()},"seawar")
        end

        if self.war_at > 0 then
            local warTime = getModelObjs("aterritory").getWarTime()
            local t = {self.warscore,self.warreward,self.war_at,warTime.warSt}
            if self.war_at < warTime.warSt then
                self.warscore = 0
                self.warreward = 0
                self.war_at = 0
            end

            local t1 = {self.warscore,self.warreward,self.war_at}
            -- writeLog({"resetWarFlag",self.uid,os.time(),t,t1,getRequestCmd()},"seawar")
        end
    end


	-- 获得击杀海盗数量前50
    function self.killlist()
        local list = {}
        -- 判断是否是新一周的数据
        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceBuidCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end

        -- 以上周结束时未标识
        local lastInit = weeTs-(weekday-1)*86400-2*3600
        if weekday == 7 and ts>weeTs+22*3600 then
            lastInit = weeTs+22*3600
        end
        local redis = getRedis()
        local key = "z"..getZoneId()..".territory.personalrank"..lastInit
        local result = redis:get(key)
        --result = {} --TODO
        if type(result) == "table" and next(result) then
            list=result
        else
            local db = getDbo()
            local result = db:getAllRows(string.format("select uid,aid,killcount from atmember where kill_at="..lastInit.." and killcount>0 order by killcount desc limit 50"))
            if type(result)=='table' and next(result) then
                local i = 1
                for k,v in pairs(result) do
			 		local uobjs = getUserObjs(tonumber(v.uid))
			        uobjs.load({"userinfo"})
			        local mUserinfo = uobjs.getModel('userinfo')
                    table.insert(list,{i,v.uid,mUserinfo.nickname,v.aid,mUserinfo.alliancename,v.killcount})
                    i = i + 1
                end
				redis:set(key,json.encode(list))
                redis:expireat(key,lastInit+7*86400)  
            end
        end

        return list
    end

    -- 更新击杀海盗
    function self.upKill(num)
        local mAterritory = getModelObjs("aterritory",self.aid)
        if not mAterritory.isNormal() then return false end
       
    	local ts= os.time()
    	local weeTs = getWeeTs()
    	local allianceBuidCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end
        
        local sttime = weeTs+allianceBuidCfg.settlementTime[2]*3600+allianceBuidCfg.settlementTime[3]*60
        local edtime = weeTs + 22*3600

        -- 领奖期间不更新击杀数(保证排行榜不发生改变)
        if weekday ==  allianceBuidCfg.settlementTime[1] and ts>sttime and ts<edtime then
            return false
        end

        -- 如果不是上周的22点 需要重置数据
        local lastInit = weeTs-(weekday-1)*86400-2*3600
        if weekday == 7 and ts>weeTs + 22*3600 then
            lastInit = edtime
        end
        if self.kill_at ~= lastInit  then
            self.killcount = 0
            self.kill_at = lastInit
            self.killreward = 0
        end
    	self.killcount =  self.killcount + num

        local redis = getRedis()
        local key = "z"..getZoneId()..".territory.personalrank"..lastInit
        local result = redis:del(key)

    	return true
    end

    -- 设置采集领地特殊资源时长
    -- param int st 开始采集的时间(以此确定生产速度)
    -- param int 得到的公海币
    function self.setCollectedTime(st,time)
        local allianceCityCfg = getConfig("allianceCity") 
        if time > allianceCityCfg.collectTime then
            time = allianceCityCfg.collectTime
        end

        local speed = allianceCityCfg.collectg1
        local mTerritory = getModelObjs("aterritory")
        if mTerritory.isLossCollectTime(st) then
            speed = speed * 2
        elseif mTerritory.isDoubleCollectTime(st) then
            speed = speed / 2
        end

        local coinNum = math.floor(time/speed)
        if coinNum > 0 then
            self.addSeacoin(coinNum)
        end

        return coinNum
    end

    -- 增加领海战积分
    function self.addSeaWarScore(score)
        -- TODO 这得加判断是否在开战期间
        if score > 0 then
            self.warscore = self.warscore + math.floor(score)
            self.war_at = os.time()
        end

        local warCfg = getConfig('allianceDomainWar')
        if self.warscore > warCfg.SumLimitPoint then
            self.warscore = warCfg.SumLimitPoint
        end

        return self.warscore
    end

    function self.setWarUserRankRewardFlag()
        -- writeLog({"setWarUserRankRewardFlag",self.uid,os.time(),self.warreward,getRequestCmd()},"seawar")
        self.warreward = bit32.bor(self.warreward,1);
        self.war_at = os.time()
    end

    function self.getWarUserRankRewardFlag()
        -- writeLog({"getWarUserRankRewardFlag",self.uid,os.time(),self.warreward,getRequestCmd()},"seawar")
        return bit32.band(1,self.warreward) == 1
    end

    function self.setWarAllianceRankRewardFlag()
        -- writeLog({"setWarAllianceRankRewardFlag",self.uid,os.time(),self.warreward,getRequestCmd()},"seawar")
        self.warreward = bit32.bor(self.warreward,2);
        self.war_at = os.time()
    end

    function self.getWarAllianceRankRewardFlag()
        -- writeLog({"getWarAllianceRankRewardFlag",self.uid,os.time(),self.warreward,getRequestCmd()},"seawar")
        return bit32.band(2,self.warreward) == 2
    end

    -- 能否采集
    -- return bool
    function self.canCollect()
        local allianceCityCfg = getConfig("allianceCity")
        return self.collect < allianceCityCfg.collectNum
    end

    -- 个人任务 
    function self.setTask()
    	local saveflag = false
 		local ts= getClientTs()
	    local weeTs = getWeeTs()

  		local allianceCityCfg = getConfig('allianceCity')
        local flagtime = weeTs + allianceCityCfg.mainTime[1][1]*3600

        if not self.task.upt then
        	self.task.upt = 0
        end
        local refreshtime = 0 -- 刷新时间标识
        -- 获取刷新时间标识
        if ts > weeTs and ts < flagtime then
        	refreshtime = flagtime-86400
        else
        	refreshtime = flagtime
        end
    
        -- TODO
		--self.task.upt=0
        if self.task.upt ~= refreshtime or not next(self.task) then
        	self.task.tk = {}
        	self.task.upt = refreshtime
			local allianceCityCfg = getConfig('allianceCity')
	   		local pool = {
	              {0,100},--随机两个不同的
	              allianceCityCfg.task.personRatio,
	              {},
	        }
	        for i=1,#allianceCityCfg.task.taskList[1] do
	        	table.insert(pool[3],i)
	        end
	        local result,rkey =  getRewardByPool(pool)

			for k,v in pairs(result) do
				local tk = {}
		        local pTask = randVal(allianceCityCfg.task.taskList[1][v].ratio)
				tk.tid = v..'_'..pTask
				
				if v== 3 then --四种资源各xx
					tk.cur = {r1=0,r2=0,r3=0,r4=0}
				else
					tk.cur = 0
				end
				tk.con = self.taskCon(tk.tid)

				table.insert(self.task.tk,tk)
			end

			self.task.rflag = {0,0,0}-- 军团任务 个人任务1 个人任务2

	        saveflag = true
        end
      
        return self.task,saveflag
    end

    function self.getTask()
    	return self.setTask()
    end

    function self.uptask(params)
     	-- 为军团仓库提供天然气
		-- 为军团仓库提供铀
		-- 累计采集四项基础资源一定数量
		-- 获得一定量的军功
		-- 在公海上,与其他玩家发生一定次数的战斗
        local mTerritory = getModelObjs("aterritory",params.aid,true)
        if not mTerritory.isNormal() then return false end
        
        local task,flag = self.setTask()
        if not next(task) then return false end

        for k,v in pairs(self.task.tk) do
        	local tid = v.tid
	        local keys = tid:split('_')
	        -- 任务是否在应用中
	        if params.act == tonumber(keys[1]) then
	        	if tonumber(keys[1])==3 then
                    local allianceCityCfg = getConfig('allianceCity')
                    local resourceCfg = {r1=true,r2=true,r3=true,r4=true}
                    local t = {}
                    for k,v in pairs(params.val) do
                        if resourceCfg[k] then
                            t[k] = math.floor( v * allianceCityCfg.collectResValue )
                        end
                    end
	        		for i=1,4 do
                 		v.cur['r'..i] = v.cur['r'..i] + (t['r'..i] or 0)
            		end
	            else
 					v.cur = v.cur + params.num
	        	end
	        end
        end

        return true
    end


    -- 删除击杀海盗排行榜 领地排行榜 缓存
    function self.delrank()
        local redis = getRedis() 
        local redkeys=redis:keys("z"..getZoneId()..".territory.personalrank*")
        if type(redkeys)=='table' and next(redkeys) then
            for k,v in pairs(redkeys) do
                redis:del(v)
            end
        end
    end
    
    -- 计算任务完成条件
    -- keys 任务编号
    function self.taskCon(tid)
        local keys = tid:split('_')
        local mTerritory = getModelObjs("aterritory",self.aid,true)
        local allianceCityCfg = getConfig('allianceCity')
        local allianceBuidCfg = getConfig('allianceBuid')
        local taskinfo = allianceCityCfg.task.taskList[1][tonumber(keys[1])].list[tonumber(keys[2])]
        local finish = 99999999
         -- 1 为军团仓库提供天然气   天然气矿等级对应的矿点产出*基础系数
        if tonumber(keys[1])==1 then
            local lv = mTerritory.b5.lv>0 and mTerritory.b5.lv or 1
            finish = math.floor(allianceBuidCfg.buildValue[5][3][lv]*taskinfo[1]) 
        end
        -- 2 为军团仓库提供铀       铀矿等级对应的矿点产出*基础系数
        if tonumber(keys[1])==2 then
            local lv = mTerritory.b4.lv>0 and mTerritory.b4.lv or 1
            finish = math.floor(allianceBuidCfg.buildValue[4][3][lv]*taskinfo[1]) 
        end
        -- 3 累计采集四项基础资源一定数量     基础*主基地等级
        if tonumber(keys[1])==3 then
            local lv = mTerritory.b1.lv>0 and mTerritory.b1.lv or 1
            finish = math.floor(taskinfo[1]*lv)
        end
        -- 4 获得一定量的军功         基础*主基地等级
        if tonumber(keys[1])==4 then
            local lv = mTerritory.b1.lv>0 and mTerritory.b1.lv or 1
            finish = math.floor(taskinfo[1]*lv)
        end
        -- 5 在公海上,与其他玩家发生一定次数的战斗     固定
        if tonumber(keys[1])==5 then 
            finish = taskinfo[1]
        end

        return finish
    end

    function self.getTerritoryObj(readOnly)
        if self.aid > 0 then
            return getModelObjs("aterritory",self.aid,readOnly)
        end
    end

    ----------------------------------------------------------------------------------------------------------------

    return self
end
