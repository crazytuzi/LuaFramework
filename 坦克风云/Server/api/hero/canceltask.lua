-- 取消正在授勋将领当前的任务

function api_hero_canceltask(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local sid = tonumber(request.params.sid) 
    if uid == nil or hid==nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('hero') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')
    local mBag = uobjs.getModel('bag')

    if type (mHero.hero[hid][4])~='table' then
        response.ret=-11002
        return response
    end

    if  type(mHero.feat)~='table' or not next(mHero.feat) then
        response.ret=-11027
        return response
    end

    if mHero.feat[1]~=hid then
        response.ret=-11027
        return response
    end
    local heroFeatCfg = getConfig('heroFeatCfg')
    local fusionLimit =heroFeatCfg.fusionLimit
    local p      =mHero.hero[hid][3]
    local cfgkey =p-fusionLimit+1
    local task   = heroFeatCfg.heroQuest[hid][cfgkey]
    local currTask = mHero.feat[2]
    if mHero.feat[2]>= #task  and  mHero.feat[3]>=task[#task][2] then
        -- response.ret=-11028
        -- return response
        --修改 第5步授勋 也是任务，可以放弃。
        currTask = currTask + 1
    end

    mHero.feat[3]=0
    mHero.hfeats[hid]= currTask
    mHero.feat={}
    if uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
    end
    return response



end