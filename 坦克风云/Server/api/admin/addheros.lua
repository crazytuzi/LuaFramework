--管理工具加英雄

function api_admin_addheros(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local hero = request.params.hero 
    local soul = request.params.soul 
    local skills =request.params.skills
    local delhid =request.params.delhid 
    local setsoul = request.params.setsoul 

    if uid == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mHero= uobjs.getModel('hero')


    local ret=false
    if type(hero)=='table' and next (hero) then
        for k,v in pairs(hero) do
             ret =mHero.addhero(k,tonumber(v))
        end
    end
    
    if type(soul)=='table' and next(soul) then
        for k,v in pairs (soul) do
            ret =mHero.addsoul(k,tonumber(v))
        end
    end

    if type(skills)=='table' and next(skills) then
        for k,v in pairs(skills) do
            for k1,v1 in pairs(v) do
                ret=mHero.upgradeheroskilllevel(k,k1,tonumber(v1))
            end
        end
    end
    if delhid~=nil  then
        ret =mHero.deleteHero(delhid)
    end

    --设置英魂
    if type(setsoul)=='table' and next(setsoul) then
        for k,v in pairs (setsoul) do
            ret =mHero.setSoulById(k,tonumber(v))
        end
    end


    if uobjs.save() and ret  then 
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end