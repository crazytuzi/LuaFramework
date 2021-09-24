-- 刷新一下用户的军演排行榜
-- 军演中会出现不同的用户排名一样的情况，在这里修一下
function api_cron_refmilitaryrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local db = getDbo()
    local redis = getRedis()
    db:query("delete FROM `userarena` WHERE `ranking` =0 ")
    local res = db:getAllRows("select uid,ranking from userarena where ranking > 0 order by ranking ASC limit 200") 

    if type(res)=='table' and next(res) then
    	local r = 0
    	local zid = tostring(getZoneId())
    	local udataKey = "z".. zid ..".udata."
        for k,v in pairs (res) do
        	v.ranking = tonumber(v.ranking)
        	local oldRanking = v.ranking
    		while (v.ranking) <= r do
    			v.ranking = v.ranking + 1
    		end

            r=v.ranking

            if v.ranking > oldRanking  then
                db:update("userarena",{ranking=v.ranking,uid=v.uid},{"uid"})
                redis:del(udataKey..v.uid)
            end
        end

        redis:zremrangebyscore("z"..getZoneId()..".rank.arena",1,200)
    end    

    response.ret=0
    response.msg ='Success'
    return response
end
