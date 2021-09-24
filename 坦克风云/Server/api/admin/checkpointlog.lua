function api_admin_checkpointlog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

	local db = getDbo()
    local result = {}
    local total = 0
    local allUser = db:getAllRows("select uid,bid,point,point1,point2,round1,round2,pointlog from userwar order by updated_at desc limit 500;")
    --local allUser = db:getAllRows("select uid,bid,point,point1,point2,round1,round2,pointlog from userwar where uid=30001827")

    if allUser and type(allUser) == 'table' then
        for i,v in pairs(allUser) do
            if v.uid then
                local uid = tonumber(v.uid)
                if v.pointlog then
                    local plog = json.decode(v.pointlog) or {}
                    if plog.rc then
                        for i,v in pairs(plog.rc) do
                            local rdate = os.date('%Y-%m-%d %H:%M:%S',v[1])
                            local y = getDateByTimeZone(v[1],'%Y')
                            local m = getDateByTimeZone(v[1],'%m')
                            local d = getDateByTimeZone(v[1],'%d')
                            local tab = {year=y,month=m,day=d,hour=0,min=0,sec=0}
                            --local tab = {year=y,month=m,day=d}
                            local day = os.time(tab)
                            local point = tonumber(v[3])

                            if point and point > 5 and (point%10 == 0) and (point ~= 10 or (point == 10 and (v[4] or 0) == 1)) and (point ~= 20 or (point == 20 and (v[4] or 0) == 2)) then
                                local reward = db:getRow("select info from rewardcenter where uid = :uid and FROM_UNIXTIME(st,'%Y%m%d') = FROM_UNIXTIME(:day,'%Y%m%d') and type='usw' ",{uid=uid,day=day})
                                if reward and type(reward) == 'table' then
                                    if reward.info then
                                        if type(reward.info) ~= 'table' then
                                            reward.info = json.decode(reward.info) or {}
                                        end
                                    end
                                    
                                    local r = tonumber(reward.info.r) or 0
                                    if r ~= tonumber((v[4] or 0)) then
                                        total = total + 1
                                        print(rdate,'uid='..uid,'r='..r,'point='..point,'round='..(v[4] or 0),json.encode(v))
                                    else
                                        --print('==',r,(v[4] or 0))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    print('total',total)
	response.ret = 0        
	response.msg = 'Success'

    return response
end
