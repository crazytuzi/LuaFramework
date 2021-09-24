-- 获取对方的信息

function api_military_getinfo(request)
     local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
    local tid = tonumber(request.params.tid) or 0
    if tid <= 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(tid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena","hero"})    

    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mHero = uobjs.getModel('hero')
    -- local mWeapon = uobjs.getModel('weapon')
    local mUserarena = uobjs.getModel('userarena')
    local mSequip = uobjs.getModel('sequip')
    local mPlane = uobjs.getModel('plane')

    local hero={}
    if type(mHero.stats.m)=='table' and type(mHero.stats.m[1])=='table' then
        for k,v in pairs (mHero.stats.m[1]) do
            hero[k]=v
            if v~=0 and mHero.hero[v]~=nil then
                hero[k]=v.."-"..mHero.hero[v][3].."-"..mHero.hero[v][1]
            end
        end
    end
    -- local weapon={}
    -- if type(mWeapon.used)=='table' and next(mWeapon.used) then
    --      --ptb:p(mWeapon.used)
    --      for k,v in pairs (mWeapon.used) do
    --          weapon[k]=v
    --          if v~=0 and mWeapon.info[v]~=nil then
    --             weapon[k]=v.."-"..mWeapon.info[v][1]
    --         end
    --      end

    -- end

    local equipid = 0
    if type(mSequip.stats.m) =='table' and mSequip.stats.m[1] then
        equipid = mSequip.stats.m[1]
    end 

    response.data.troops=mUserarena.troops
    response.data.hero=hero
    -- response.data.weapon=weapon
    response.data.se=equipid
    response.data.plane  = mPlane.getPlaneFleet('m', 1)
    response.data.victory=mUserarena.victory
    response.ret = 0
    response.msg = 'Success'
    return response
end