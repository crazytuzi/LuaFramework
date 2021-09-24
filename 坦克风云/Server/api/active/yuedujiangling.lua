function api_active_yuedujiangling(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}



    local uid = request.uid
	local action = request.params.action or nil
	
    if uid == nil or not action or action > 2 then
        response.ret = -102
        return response
    end

	local ts = getClientTs()
	local weeTs = getWeeTs()
    local aname = 'yuedujiangling'
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
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
	local cost = activeCfg.cost[action]
	
	if mUseractive.info[aname].t < weeTs then
		mUseractive.info[aname].t = weeTs
		mUseractive.info[aname].flag = {0,0}
		mUseractive.info[aname].record = {0,0}
	end
	
	if not mUseractive.info[aname].record or type(mUseractive.info[aname].record) ~= 'table' then
		mUseractive.info[aname].record = {0,0}
	end
	
	if not mUseractive.info[aname].flag or type(mUseractive.info[aname].flag) ~= 'table' then
		mUseractive.info[aname].flag = {0,0}
	end
	
	if mUseractive.info[aname].flag[action] ~= 0 then
		response.ret = -1976
		return response
	end
	
	mUseractive.info[aname].cost = nil
	
	if mUseractive.info[aname].record[action] < cost then
		response.ret = -1981
		return response
	end
    
	local reward = activeCfg.serverreward[action] or {}
	if not takeReward(uid,reward) then        
		response.ret = -403 
		return response
	end

	mUseractive.info[aname].flag[action] = 1
	mUseractive.info[aname].t = weeTs

    if uobjs.save() then
        response.ret = 0        
        response.data[aname]=mUseractive.info[aname]
        response.msg = 'Success'
    end
    
    return response
end