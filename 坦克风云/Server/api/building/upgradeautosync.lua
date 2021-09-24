function api_building_upgradeautosync(request)
     local response = {
        ret=-1,
        msg='error',
        data = {},
    }

      --没有开启自动升级
    if not getConfig("gameconfig").auto_build or getConfig("gameconfig").auto_build.enable~=1 then
        response.ret = -1
        return response
    end


    local uid = request.uid
    local bid = request.params.bid and 'b' .. request.params.bid
    local buildType = tonumber(request.params.buildType)

    if uid == nil or bid == nil or buildType == nil then
        response.ret = -102
        return response
    end



    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mBuildings = uobjs.getModel('buildings')

    -- 刷新队列
    mBuildings.update()

    -- 是否解锁
    if not mBuildings.buildingIsUnlock(bid,buildType) then
        response.ret = -113
        return response
    end

    -- 正在升级中
    if mBuildings.checkIdInSlots(bid) then
        response.ret = -3002
        return response
    end

    local cfg = getConfig('building.'..buildType)
    local currLevel = mBuildings[bid][2] or 0

    -- 当前地块等级不小于最大等级

    if currLevel  >= cfg.maxLevel then
        response.ret = -121
        return response
    end

    local upLevel = 1 + currLevel
	local discount = 1

	if buildType == 7 then
		local activeName = 'commandcentrelevelup';
        local mUseractive = uobjs.getModel('useractive')
        local activStatus = mUseractive.getActiveStatus(activeName)

        if activStatus == 1 then 
			local activeParams = {buildType=buildType,level=upLevel}
			local tmpdiscount = activity_setopt(uid,activeName,activeParams)
			if tmpdiscount > 0 and tmpdiscount <= 1 then
				discount = tmpdiscount
			end
        end
    end


	local iConsumeTime = cfg.timeConsumeArray[upLevel] * discount
    local bRes = {}
    bRes.r1 = cfg.metalConsumeArray[upLevel] * discount
    bRes.r2 = cfg.oilConsumeArray[upLevel] * discount
    bRes.r3 = cfg.siliconConsumeArray[upLevel] * discount
    bRes.r4 = cfg.uraniumConsumeArray[upLevel] * discount
    bRes.gold = cfg.moneyConsumeArray[upLevel] * discount

    -- 使用资源
    -- 浣跨敤璧勬簮
    if not mUserinfo.useResource(bRes) then
        response.ret = -107
        return response
    end

    -- 科技影响
    local techLevel =  tonumber(mTech.getTechLevel('t23'))
    --  区域战职位
    local mJob =uobjs.getModel('jobs')
    -- 1 就是建筑加速
    local value =mJob.getjobaddvalue(1)            

    iConsumeTime = iConsumeTime /(1+techLevel*0.05 + value)

	local ts = getClientTs()
    local bSlotInfo = {st=ts,id=bid,type=buildType}
    bSlotInfo.et = iConsumeTime + ts
    bSlotInfo.dis = discount

    -- 使用队列
    if not mBuildings.useSlot(bSlotInfo)    then
        response.ret = -1997
        return response
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    processEventsBeforeSave()

    if uobjs.save() then
		--writeLog("sync Success","error")
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.buildings = mBuildings.toArray(true)
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
		writeLog("sync failed","error")
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
