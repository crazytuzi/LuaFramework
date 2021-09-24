-- 猎鹰之眼技能(注意这里没有用Lib/map中的方法)
-- 暂时没有用到
local function getHeatLevel(data)
    local lv = 0
    if not data or data == "" then
        return lv
    end

    data = json.decode(data)

    if type(data) == 'table' and data.heat and data.heat.point then
        local heatCfg = getConfig('mapHeat')
        for k,v in ipairs(heatCfg.point4Lv) do
            if data.heat.point > v then
                lv = k
            else
                break
            end
        end
    end

    return lv
end

function api_skill_eagleeye(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local uobjs = getUserObjs(uid,true)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    
    local redis = getRedis()
    local cacheKey = string.format("z%s.eagleEyeMap",getZoneId())

    local data = redis:hget(cacheKey,uid)
    if data then data = json.decode(data) end

    if type(data) ~= "table" then
        data = {0}
    end

    local ts = getClientTs()
    local skillCfg = getConfig("skill")

    local cdTime = skillCfg.skillList.s301.skillCooldown * 3600

    if data[1] + cdTime <= ts then
        data[1] = ts
        data[2] = nil
        data[3] = nil

        local mUserinfo = uobjs.getModel('userinfo')
        local mSkill = uobjs.getModel('skills')

        local eagleeyeLv = mSkill.s301 or 0
        if eagleeyeLv <= 0 then
            response.ret = -2048
            return response
        end

        local skillRange = skillCfg.skillList.s301.skillRange + skillCfg.skillList.s301.skillValue * eagleeyeLv
        local originx = mUserinfo.mapx
        local originy = mUserinfo.mapy
        local scanArea = math.ceil(skillRange/2)

        local x1 = originx - scanArea
        local x2 = originx + scanArea
        local y1 = originy - scanArea
        local y2 = originy + scanArea

        if x1 < 1 then x1 = 1 end
        if y1 < 1 then y1 = 1 end
        if x2 > 600 then x2 = 600 end
        if y2 > 600 then y2 = 600 end

        local db = getDbo()
        local result = db:getAllRows("select id,x,y,oid,data from map where type>0 and type < 6 and x>=:x1 and x<=:x2 and y>=:y1 and y<=:y2 and oid > 0 and oid != :uid ",{x1=x1,x2=x2,y1=y1,y2=y2,uid=uid})

        if type(result) == "table" then
            for k,v in pairs(result) do
                if getHeatLevel(v.data) <= skillCfg.skillList.s301.quality then
                    data[2] = tonumber(v.x)
                    data[3] = tonumber(v.y)
                    break
                end
            end
        end

        redis:hset(cacheKey,uid,json.encode(data))
        redis:expire(cacheKey,43200)
    end

    response.data.eagleEyeMap = data

    response.ret = 0
    response.msg = 'Success'
    
    return response
end	