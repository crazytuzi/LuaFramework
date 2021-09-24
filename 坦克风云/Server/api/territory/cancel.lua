-- 取消建造
function api_territory_cancel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = request.params.aid
    local bid = request.params.bid
    local bidindex = tonumber(string.sub(bid,2))

    if uid == nil or bid == nil or aid == nil  then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","atmember"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAterritory = getModelObjs("aterritory",aid)

    if mAterritory.status ~= 1 then
        response.ret = -102
        return response
    end    

    if mUserinfo.alliance==0 or mUserinfo.alliance ~= aid then
        response.ret = - 102
        return response
    end
    --返回值role 2是军团长，1是副团长，0是普通成员
    local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if tonumber(ret.data.role)~=2 then
    	response.ret = -8008
    	return response
    end

    local iSlotKey = mAterritory.checkIdInSlots(bid)
    local bSlot = mAterritory.bqueue[iSlotKey]
    local currLevel = mAterritory[bid].lv or 0

    if type(bSlot) ~= 'table' then
        response.ret = -8450
        return response
    end


    -- 计算返还的资源量
    local cfg = getConfig('allianceBuid')
    local percent = getConfig('allianceCity.cancelReward') --返回资源比例

    local upLevel = 1 + (tonumber(mAterritory[bid].lv) or 0)
    local bRes = {}

    bRes.r1 = type(cfg.buildValue[bidindex].steel)=='tbale' and math.floor(percent*cfg.buildValue[bidindex].steel[upLevel]) or 0 -- 铁
    bRes.r2 = type(cfg.buildValue[bidindex].al)=='table' and math.floor(percent*cfg.buildValue[bidindex].al[upLevel]) or 0   -- 铝
    bRes.r3 = type(cfg.buildValue[bidindex].ti)=='table' and math.floor(percent*cfg.buildValue[bidindex].ti[upLevel])  or 0  -- 钛
    bRes.r4 = type(cfg.buildValue[bidindex].oil)=='table' and math.floor(percent*cfg.buildValue[bidindex].oil[upLevel]) or 0  -- 石油
    bRes.r6 = type(cfg.buildValue[bidindex].ur)=='table' and math.floor(percent*cfg.buildValue[bidindex].ur[upLevel])   or 0  -- 铀矿
    bRes.r7 = type(cfg.buildValue[bidindex].gas)=='table' and math.floor(percent*cfg.buildValue[bidindex].gas[upLevel])  or 0 -- 天然气
   
    -- 返还资源
    if not mAterritory.addResource(bRes) then
        response.ret = -1991
        return response
    end

    -- 释放使用的队列
    if not mAterritory.openSlot(iSlotKey) then
        response.ret = -1992
        return response
    end

    processEventsBeforeSave()    

    if mAterritory.saveData() then
        response.data.territory = mAterritory.formatedata()
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else			
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
