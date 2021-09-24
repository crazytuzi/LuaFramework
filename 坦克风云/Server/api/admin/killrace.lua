local function api_admin_killrace(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },

        tbName = "killrace_season",
    }

    function self.getRules()
        return {
            ["action_newSeason"] = {
                st = {"required","number"},
            },
        }
    end

    function self.before(request) 
        self.currTime = os.time()
    end

    function self.action_new(request)
        local response = self.response
        
        -- 赛季开始时间戳
        local st = request.params.st

        -- 已开赛季
        local season_offset = request.params.season_offset or 0

        local currTime = self.currTime

        -- 时间必需是0点
        if st ~= getWeeTs(st) then
            response.ret = -102
            response.err = "st err"
            response.data.weets = getWeeTs(st)
            return response
        end
        
        -- 10年
        local et = st + 24 * 3600 * 365 * 10

        local libKillRace = loadModel("lib.killrace",{init=true})
        local seasonInfo = libKillRace.mkSeason(st,season_offset)

        local db = getDbo()
        local res = self.season()
        if res then
            response.ret = -102
            response.err = "the season exists"
            response.data.season = res
            return response
        end

        local raceInfo = {
            st=st,
            et=et,
            season_offset=season_offset,
            season=seasonInfo.season,
            season_st=seasonInfo.st,
            season_et=seasonInfo.et,
            season_reset = 0,
            updated_at=currTime,
        }

        local ret = getDbo():insert(self.tbName,raceInfo)

        if ret < 1 then
            response.ret = -1
            response.err = db:getError()
            return response
        end

        local cacheKey = libKillRace.getCacheKey("hashkillraceInfo")
        getRedis():hmset(cacheKey,raceInfo)

        -- TODO 对上一赛季的数据进行清理

        response.data.season = self.season()
        response.ret = 0        
        response.msg = 'Success'

        return response
    end

    function self.action_update(request)
        local response = self.response

        -- 赛季开始时间戳
        local st = request.params.st

        -- 已开赛季
        local season_offset = request.params.season_offset
        
        -- 时间必需是0点
        if st ~= getWeeTs(st) then
            response.ret = -102
            response.err = "st err"
            response.data.weets = getWeeTs(st)
            return response
        end
        
        local db = getDbo()
        local res = self.season()

        if not res then
            response.ret = -102
            response.err = "season data is not exists"
            return response
        end

        local libKillRace = loadModel("lib.killrace",{init=true})
        local seasonInfo = libKillRace.mkSeason(st,season_offset)

        local raceInfo = {
            id=res.id,
            st=st,
            et=et,
            season_offset=season_offset,
            season=seasonInfo.season,
            season_st=seasonInfo.st,
            season_et=seasonInfo.et,
            updated_at=currTime,
        }

        local ret = getDbo():update(self.tbName,raceInfo,{"id"})
        if ret < 1 then
            response.ret = -1
            response.err = db:getError()
            return response
        end

        local cacheKey = libKillRace.getCacheKey("hashkillraceInfo")
        getRedis():hmset(cacheKey,raceInfo)

        -- TODO 对上一赛季的数据进行清理

        response.data.season = self.season()
        response.ret = 0        
        response.msg = 'Success'

        return response
    end

    function self.action_get()
        local response = self.response
        local libKillRace = loadModel("lib.killrace",{init=true})
        local killraceData = libKillRace.toArray()

        if killraceData.st > 0 and killraceData.et > 0 then
            response.data = killraceData
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_detail(request)
        local response = self.response
        local libKillRace = loadModel("lib.killrace",{init=true})

        response.data.season = libKillRace.toArray()
        response.data.switch = moduleIsEnabled('kRace')
        response.data.apply_num = libKillRace.getApplyNum()

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_getuser(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        local userkillrace = mKillrace.toArray()

        response.data.userkillrace = {
            uid = uid,
            nickname = userkillrace.nickname,
            grade = userkillrace.grade,
            queue = userkillrace.queue,
            troops = userkillrace.troops,
            score = userkillrace.score,
            kcoin = userkillrace.kcoin,
            total_killed = userkillrace.total_killed,
            grade_battle_num = userkillrace.grade_battle_num,
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- TODO 管理工具加验证
    function self.action_setuser(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mKillrace = uobjs.getModel("userkillrace")

        local killRaceCfg = getConfig("killRaceCfg")
        local libKillRace = loadModel("lib.killrace")
        local killRaceVerCfg = libKillRace.getRaceVerCfg()

        for k,v in pairs(request.params) do
            if mKillrace[k] then
                if k == "grade" then
                    local grade = tonumber(request.params.grade)
                    local queue = tonumber(request.params.queue)
                    if mKillrace.grade ~= grade or mKillrace.queue ~= queue then
                        if mKillrace.grade_task < grade then
                            mKillrace.grade_task = tonumber(request.params.grade)
                        end

                        mKillrace.grade = grade
                        mKillrace.queue = queue

                        if mKillrace.grade > mKillrace.max_grade then
                            mKillrace.max_grade = mKillrace.grade
                        end

                        if killRaceCfg.levelTask[mKillrace.grade] then
                            mKillrace.total_killed = killRaceCfg.levelTask[mKillrace.grade].t[2]
                            mKillrace.grade_battle_num = killRaceCfg.levelTask[mKillrace.grade].t[3]
                            mKillrace.score = killRaceVerCfg.groupMsg[mKillrace.grade][mKillrace.queue].scoreRequire
                        end

                        break
                    end
                elseif k == "troops" then
                    if type(v) == "table" then
                        mKillrace[k] = v
                    end
                elseif k == "score" or k == "kcoin" or k == "total_killed" or k=="grade_battle_num" then
                    mKillrace[k] = math.floor(tonumber(v) or 0)
                end
            end
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    --[[
        获取当前
    ]]
    function self.season()
        return getDbo():getRow(string.format("select id,st,et,season_offset from %s",self.tbName))
    end

    -- function self.after() end

    return self
end

return api_admin_killrace