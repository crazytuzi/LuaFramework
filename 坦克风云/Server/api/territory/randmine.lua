--
--矿点维护时间：两种矿，每天6:00到10:00锁定，不可进入采集，其中8:00-10:00军团长可以刷新两矿；
--两矿公用刷新次数，每天免费刷新次数总计为：3次，超出可用军团资金刷新；
--维护时间，每天6时-10时，为维护时间，此期间不可下矿采集；
--如玩家在维护时间内前内下矿成功，可继续采集；
--如玩家部队达到矿点时，处于矿点维护时间，则部队返回，无法采矿；
--刷新时间，每日8时-10时，为可刷新时间。
--系统刷新：每日8点系统刷新矿点，两矿分别刷新；
--8点起，锁定10s，防止系统刷新和团长刷新的并发情况；
--刷新时要根据当前军团的发展值生成最终产量；
--团长刷新：10s锁定时间过后，团长可随意刷新矿点（超过免费次数，需要扣费）
-- 暂时不用了
--


function api_territory_randmine(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local aid = request.params.aid
    local uid = request.uid
   

    if aid == nil or not uid  then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end
  
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
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

    local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if tonumber(ret.data.role)~=2 then
    	response.ret = -8008
    	return response
    end

    -- 每日刷新次数
    local ts= getClientTs()
    local weeTs = getWeeTs()

    local allianceCityCfg = getConfig('allianceCity')
    local sttime = weeTs + allianceCityCfg.lockToCollect[1][1]*3600+allianceCityCfg.lockToCollect[1][2]*60
    local edtime =  weeTs + allianceCityCfg.lockToCollect[2][1]*3600+allianceCityCfg.lockToCollect[2][2]*60
  
    -- -- 不在刷新时间内
    if ts>edtime or ts<sttime then
        response.ret = -8415
        return response
    end    

    if type(mAterritory.minerefresh) ~= 'table' then
        mAterritory.minerefresh={n=0,t=0}
    end



	if  mAterritory.minerefresh.t ~= weeTs then
		mAterritory.minerefresh.n = 0
        mAterritory.minerefresh.t = weeTs
        mAterritory.minerefresh.qr = 0
	end
    -- 已确认
    if mAterritory.minerefresh.qr ==1 then
        response.ret = -8423
        return response
    end

    local gems = 0

    mAterritory.minerefresh.n = mAterritory.minerefresh.n + 1
    if mAterritory.minerefresh.n > allianceCityCfg.freeNum then
        gems = allianceCityCfg.refreshCost + (mAterritory.minerefresh.n-allianceCityCfg.freeNum-1)*allianceCityCfg.refreshValue
    end


	-------
    local mAterritory = getModelObjs("aterritory",aid,false)

    if not mAterritory.randmine() then
    	response.ret = -102
    	return response
    end

    if gems>0 then
        regActionLogs(uid, 1, {action = 183, item = "", value = gems, params = {}})
        -- 消耗军团资金
        if not mUserinfo.useGem(gems) then
            response.ret = -109
            return response
        end

        if not uobjs.save() then
            response.ret = -106
            return response
        end
    end

    if mAterritory.saveData() then
        response.data.territory = mAterritory.formatedata()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -106
    end
    
    return response
end




