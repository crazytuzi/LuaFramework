-- 升级英雄等级 吃经验
function api_hero_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local pid = request.params.pid
    local count  = tonumber(request.params.count) or 1
    if uid == nil or pid==nil or hid==nil or count<1 then
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

    if type (mHero.hero[hid]) ~='table' then
        response.ret=-11002
        return response
    end
    local level =mHero.hero[hid][1]+1
    local heroCfg = getConfig('heroCfg')
    local point = mHero.hero[hid][2]
    local p = mHero.hero[hid][3]

    local herolevel=heroCfg.heroLevel[p]

    local maxpoint =heroCfg.levelUP[p][herolevel+1]

    if point>=maxpoint then
            -- 英雄最大等级
        response.ret=-11013
        return response

    end       
    if level >mUserinfo.level then
        --人物等级不足
        response.ret=-11014
        return response
    end
    local propCfg = getConfig('prop')
    local cfg = propCfg[pid]

    -- -- 增加点数
 
    if cfg.useGetHeroPoint then 
        local ret= mHero.upgradeheropoint(hid,cfg.useGetHeroPoint*count,maxpoint,mUserinfo.level)
        if not ret then
             return response
        end
    else
        response.ret=-11009
        return response              
    end

    if not mBag.use(pid,count) then
        response.ret =-11012
        return response
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='js'})
  
    regActionLogs(uid,9,{action=903,item=hid,value=mHero.hero[hid][1],params={[pid]=count}})  
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end
