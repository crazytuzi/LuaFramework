-- 卡夫卡馈赠
-- 参数：
-- action 1 选择奖励，2 领取奖励
-- cid 金币档位，mid 奖励序号

function api_active_kafkagift(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
	local cid = tonumber(request.params.cid) or nil
	local mid = tonumber(request.params.mid) or nil
	local ts = getClientTs()
	local weeTs = getWeeTs()
	
    if uid == nil or cid == nil or mid == nil then
        response.ret = -102
        return response
    end

    local aname = 'kafkagift'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
	local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    --activity_setopt(uid,'totalRecharge',{num=gold_num})
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
	
	local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
	local maxReward = #activeCfg.cost or 0
	local currNeedCost = activeCfg.cost[cid] or nil
	
	if maxReward <= 0 or not currNeedCost then -- 配置不对
		response.ret = -102
		return response
	end
	
	if mUseractive.info[aname].t < weeTs then
		mUseractive.info[aname].t = weeTs
		mUseractive.info[aname].v = 0
		mUseractive.info[aname].flag = nil
		mUseractive.info[aname].mark = nil
	end

	if mUseractive.info[aname].v < currNeedCost then -- 充值金币数不够
		response.ret = -1981
		return response
	end
	
	if not mUseractive.info[aname].flag or type(mUseractive.info[aname].flag) ~= 'table' then
		mUseractive.info[aname].flag = {}
		for i=1,maxReward do
			mUseractive.info[aname].flag[i] = 0
		end
	end
	
	if not mUseractive.info[aname].mark or type(mUseractive.info[aname].mark) ~= 'table' then
		mUseractive.info[aname].mark = {}
		for i=1,maxReward do
			mUseractive.info[aname].mark[i] = 0
		end
	end
	
	if mUseractive.info[aname].flag[cid] == 1 then
		response.ret = -1976
		return response
	end
	
	if not mid or mid == 0 then
		response.ret = -2031
		return response
	end

	if not activeCfg.rule.r1[cid] or not activeCfg.rule.r1[cid][mid] then
		response.ret = -102
		return response
	end
	
	if mUserinfo.vip < activeCfg.rule.r1[cid][mid] then
		response.ret = -1981
		return response
	end

	
	if not activeCfg.serverreward.r1[cid] or not activeCfg.serverreward.r1[cid][mid] or type(activeCfg.serverreward.r1[cid][mid]) ~= 'table' then
		response.ret = -102
		return response
	end
	
	if not activeCfg.serverreward.r2[cid] or type(activeCfg.serverreward.r2[cid]) ~= 'table' then
		response.ret = -102
		return response
	end
	
	local reward = {}
	local reward1 = activeCfg.serverreward.r1[cid][mid]
	local reward2 = activeCfg.serverreward.r2[cid]
	
	for i,v in pairs(reward1) do
		reward[i] = (reward[i] or 0) +v
	end
	
	for i,v in pairs(reward2) do
		reward[i] = (reward[i] or 0) +v
	end
	
	-- ptb:p(reward)
	
	if not takeReward(uid,reward) then        
		response.ret = -403 
		return response
	end

	mUseractive.info[aname].flag[cid] = 1
	mUseractive.info[aname].mark[cid] = mid
	mUseractive.info[aname].t = weeTs

    processEventsBeforeSave()

    if  uobjs.save() then        
        processEventsAfterSave()
		
        response.ret = 0
		response.data.aname = mUseractive.info[aname]
		response.data.accessory = mAccessory.toArray(true)
		response.data.bag = mBag.toArray(true)
		response.data.troops = mTroops.toArray(true)
		response.data.userinfo = mUserinfo.toArray(true)
		-- response.data.reward = formatReward(reward)
        response.msg = 'Success'
    end
    
    return response
end
