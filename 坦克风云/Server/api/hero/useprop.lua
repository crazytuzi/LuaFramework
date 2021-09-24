-- 使用道具增加剩余经验

function api_hero_useprop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local pids = request.params.pids
    if uid == nil or pids==nil then
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
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    if type(pids)~='table' or not next(pids) then
        response.ret=-102
        return response
    end

    local addexp=0
    local propCfg = getConfig('prop')
    local cfg = propCfg[pid]
    for k,pid in pairs (pids) do
        local count=mBag.getPropNums(pid)
        if count>0 then
            local cfg = propCfg[pid]
            if cfg.useGetHeroPoint then
                addexp=addexp+cfg.useGetHeroPoint*count
                if not mBag.use(pid,count) then
                    response.ret =-1
                    return response
                end
            end
        end
    end

    if addexp<=0 then
        response=-102
        return response
    end

    mHero.changeExp(addexp)
    
    if uobjs.save()  then 
        response.data.hero={}
        response.data.hero.exp =mHero.exp
        response.ret = 0        
        response.msg = 'Success'
    end
    return response

end