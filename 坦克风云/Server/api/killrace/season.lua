local function api_killrace_season(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }
    
    -- TODO 把每个服清数据的时间分开
    function self.before(request) 
        
    end
    
    function self.action_reset(request)
        local response = self.response
        local trackLog = {}

        local libKillRace = loadModel("lib.killrace")

        if libKillRace.isResetable() then
            local nextSeason = libKillRace.mkSeason(libKillRace.st,libKillRace.sinfo.season_offset,os.time()+86400)
            if nextSeason.st - libKillRace.sinfo.et ~= 1 then
                writeLog({nextSeason,libKillRace.toArray()})
                return response
            end

            local raceData = libKillRace.getRaceInfoFromDb()
            table.insert(trackLog,raceData)

            if (tonumber(raceData.season) > 0) and (tonumber(raceData.season_reset) ~= tonumber(nextSeason.season)) then
                require("model.userkillrace")
                local model = model_userkillrace()
                local columns = model.toArray()
                local cacheFields = {"userkillrace.uid","userkillrace.updated_at"}
                for k,v in pairs(columns) do
                    if type(v) == "table" then
                        columns[k] = "'" .. json.encode(v) .. "'"
                    end

                    table.insert(cacheFields,"userkillrace".. "." .. k)
                end

                columns.score = nil
                columns.uid = nil
                columns.nickname = nil
                columns.season = nextSeason.season
                columns.updated_at = os.time()

                local killRaceCfg = getConfig("killRaceCfg")
                local update = http_build_query(columns,',')

                local db = getDbo()
                assert(db.conn:setautocommit(false),'mysql transaction set failed')

                local sql = string.format("update userkillrace set score = score * %f,%s where season != %d",killRaceCfg.inherit[1],update,tonumber(nextSeason.season));
                db:query(sql)
                table.insert(trackLog,sql)

                sql = string.format("update userkillrace set score = %d where score > %d",killRaceCfg.inherit[2],killRaceCfg.inherit[2]);
                db:query(sql)
                table.insert(trackLog,sql)

                sql = string.format("delete from userkillrace where score < %d",killRaceCfg.inherit[3]);
                db:query(sql)
                table.insert(trackLog,sql)

                -- local delTs = os.time() - (killRaceCfg.season + killRaceCfg.offSeason ) * 3688 *24
                local delTs = os.time()
                sql = string.format("delete from killrace_changelog where updated_at <= %d",delTs);
                db:query(sql)
                table.insert(trackLog,sql)

                sql = string.format("delete from killrace_image where updated_at <= %d",delTs);
                db:query(sql)
                table.insert(trackLog,sql)

                sql = string.format("delete from killrace_battlelog where updated_at <= %d",delTs);
                db:query(sql)
                table.insert(trackLog,sql)

                local raceInfo = {
                    id=raceData.id,
                    season=nextSeason.season,
                    season_st=nextSeason.st,
                    season_et=nextSeason.et,
                    season_reset = raceData.season,
                    updated_at=os.time(),
                }

                db:update("killrace_season",raceInfo,{"id"})
                table.insert(trackLog,raceInfo)

                if db.conn:commit() then
                    local redis = getRedis()
                    local zid = getZoneId()
                    local cacheKey = libKillRace.getCacheKey("hashkillraceInfo")
                    redis:hmset(cacheKey,raceInfo)
                    redis:hdel(cacheKey,"apply_num")
                    
                    local userCacheKey = "z"..getZoneId()..".udata.*"
                    local result = redis:keys(userCacheKey)
                    if type(result) == "table" then
                        for k,v in pairs(result) do
                            redis:tk_hmdel(v,cacheFields)
                        end
                    end
                    table.insert(trackLog,userCacheKey)

                    local raceCacheKey = string.format("z%s.killrace.*.%s.%s*",zid,libKillRace.season,libKillRace.sinfo.st)
                    local result = redis:keys(raceCacheKey)
                    if type(result) == "table" then
                        for k,v in pairs(result) do
                            redis:del(v)
                        end
                    end
                    table.insert(trackLog,raceCacheKey)
                    table.insert(trackLog,"Success")

                    response.ret = 0   
                    response.msg = 'Success'
                else
                    db.conn:rollback()
                    table.insert(trackLog,"fail")
                end
                
                db.conn:setautocommit(true)
            end
        end

        writeLog(trackLog,"killrace")

        return response
    end

    -- function self.after() end

    return self
end

return api_killrace_season