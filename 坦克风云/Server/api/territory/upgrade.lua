--
--desc:公海领地 建筑升级、建造
--user:chenyunhe
--
function api_territory_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = request.params.aid

    local bid = request.params.bid
    local bidindex = tonumber(string.sub(bid,2))
  

    if uid == nil or bid == nil or aid==nil or aid<=0 then
        response.ret = -102
        return response
    end

    -- 判断是不是军团长
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    if mUserinfo.alliance ~= aid then
        response.ret = - 102
        return response
    end

    if mUserinfo.alliance==0 or mUserinfo.alliance~=aid then
    	response.ret = -102
    	return response
    end

    --返回值role 2是军团长，1是副团长，0是普通成员
    local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if tonumber(ret.data.role)~=2 then
    	response.ret = -8008
    	return response
    end

    local mAterritory = getModelObjs("aterritory",aid)
    if mAterritory.status ~= 1 then
        response.ret = -102
        return response
    end

    local weeTs = getWeeTs()

    -- 领地维护不能建造 或者升级
    if mAterritory.maintenance() then
        response.ret = -8411
        return response
    end

    -- 是否解锁
    if not mAterritory.buildingIsUnlock(bidindex) then
        response.ret = -113
        return response
    end

    -- 正在升级中
    if mAterritory.checkIdInSlots(bid) then
        response.ret = -3002
        return response
    end

    local cfg = getConfig('allianceBuid')
    -- 如果是炮台 只能同时建造一个
    if cfg.btype[bid] ==6 then
        if mAterritory.checkBattery() then
            response.ret = -1997
            return response
        end
    end

    local currLevel = mAterritory[bid].lv or 0

    -- 最大等级限制
    if currLevel >= cfg.buildType[bidindex].maxLevel then
        response.ret = -121
        return response
    end

    local upLevel = 1 + currLevel

    local bRes = {}
    bRes.r1 = type(cfg.buildValue[bidindex].steel)=='tbale' and cfg.buildValue[bidindex].steel[upLevel] or 0 -- 铁
    bRes.r2 = type(cfg.buildValue[bidindex].al)=='table' and cfg.buildValue[bidindex].al[upLevel] or 0   -- 铝
    bRes.r3 = type(cfg.buildValue[bidindex].ti)=='table' and cfg.buildValue[bidindex].ti[upLevel]  or 0  -- 钛
    bRes.r4 = type(cfg.buildValue[bidindex].oil)=='table' and cfg.buildValue[bidindex].oil[upLevel] or 0  -- 石油
    bRes.r6 = type(cfg.buildValue[bidindex].ur)=='table' and cfg.buildValue[bidindex].ur[upLevel]  or 0  -- 铀矿
    bRes.r7 = type(cfg.buildValue[bidindex].gas)=='table' and cfg.buildValue[bidindex].gas[upLevel]  or 0 -- 天然气

    -- 使用资源
    if not mAterritory.useResource(bRes) then
        response.ret = -107
        return response
    end  
    
    -- 创建建造队列
    local iConsumeTime = cfg.buildValue[bidindex].time[upLevel]

    local ts = getClientTs()
    local bSlotInfo = {st=ts,id=bid}
    bSlotInfo.et = iConsumeTime + ts

   	-- 使用队列
    if not mAterritory.useSlot(bSlotInfo)  then
        response.ret = -1997
        return response
    end
    local cronParams = {cmd="territory.ckbqueue",params={aid=aid}}
    if not setGameCron(cronParams,iConsumeTime) then
        response.ret = -1989
        return response
    end


    processEventsBeforeSave()
    if mAterritory.saveData() then
        processEventsAfterSave()
        response.data.territory=mAterritory.formatedata()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	