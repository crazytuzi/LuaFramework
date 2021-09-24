-- 战争雕像激活
-- action 1.激活英雄 2.一键激活
-- sid 雕像id
-- hid 激活单个英雄id
function api_statue_activate(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 战争雕像系统没有开启
    if not switchIsEnabled('statue') then
        response.ret = -27000
        return response
    end

    local uid = tonumber(request.uid)
    local action = tonumber(request.params.action)
    local sid = request.params.sid
    if not uid or not action or not sid then
        response.ret = -102
        return response
    end

    local ts = getClientTs()
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","statue"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')
    local mStatue = uobjs.getModel('statue')
    local statueCfg = getConfig("statueCfg")
    if not statueCfg.room[sid] then
        response.ret = -102
        return response
    end

    local roomCfg = statueCfg.room[sid]
    local needLv = roomCfg[1]
    local hcfg = roomCfg[2]
    if mUserinfo.level < needLv then
        response.ret = -27001
        return response
    end

    local oldfc = mUserinfo.fc
    if not mStatue.statue[sid] then
        mStatue.statue[sid] = {}
    end
    local statue = mStatue.statue[sid]

    -- 激活英雄
    if action == 1 then
        local hid = request.params.hid
        if not hid then
            response.ret = -102
            return response
        end

        local hero = mHero.hero[hid]
        if not hero or not hero[3] then
            response.ret = -27002
            return response
        end
        
        local hashero = false
        for k,v in pairs(hcfg) do
            if v == hid then
                hashero = true
            end
        end
        if not hashero then
            response.ret = -27002
            return response
        end

        if statue[hid] and statue[hid] == hero[3] then
            response.ret = -27003
            return response
        end
        
        if hero[3] > statueCfg.openStatue then
            mStatue.statue[sid][hid] = statueCfg.openStatue
        else
            mStatue.statue[sid][hid] = hero[3]
        end
        
    -- -- 激活技能
    -- elseif action == 2 then
    --     local level = request.params.level
    --     if not level then
    --         response.ret = -102
    --         return response
    --     end

    --     for k,v in pairs(hcfg) do
    --         if v and statue[v] and statue[v] >= level then
    --         else
    --             response.ret = -27004
    --             return response
    --         end
    --     end

    --     mStatue.statue[sid].s = level

    -- 一键激活
    elseif action == 2 then 
        for k,v in pairs(hcfg) do
            if v and mHero.hero[v] and mHero.hero[v][3] then
                if mHero.hero[v][3] > statueCfg.openStatue then
                    mStatue.statue[sid][v] = statueCfg.openStatue
                else
                    mStatue.statue[sid][v] = mHero.hero[v][3]
                end
            end
        end

        -- local skillLv
        -- for k,v in pairs(mStatue.statue[sid].h) do
        --     if not skillLv then
        --         skillLv = v
        --     elseif skillLv > v then
        --         skillLv = v
        --     end
        -- end

        -- if skillLv and skillLv > 0 then
        --     mStatue.statue[sid].s = skillLv
        -- end

    end

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.data.statue = mStatue.toArray(true)
        if oldfc ~= mUserinfo.fc then
            response.data.oldfc = oldfc
            response.data.newfc = mUserinfo.fc
        end
        response.ret = 0
        response.msg = 'Success'
    end
 
    return response
end