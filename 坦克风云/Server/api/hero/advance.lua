--  突破英雄
--  使用几种道具升级一次成功 会解锁技能
function api_hero_advance(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid  
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

    if type (mHero.hero[hid]) ~='table' then
        -- 英雄不存在
        response.ret=-11002
        return response
    end

    local userheroThrouh =mHero.hero[hid][3]
    local heroCfg=getConfig('heroCfg')
    local level =mHero.hero[hid][1]
    if level<heroCfg.heroLevel[userheroThrouh] then
         -- 突破需要英雄等级不足
        response.ret=-11015
        return response
    end
    local version  =getVersionCfg()

    if userheroThrouh>=version.unlockHeroThrouh then
        -- 英雄最大品阶
        response.ret=-11003
        return response
    end
    
    local herolistCfg = getConfig('heroListCfg.'..hid)
    local Throuh=herolistCfg.throuh

    local props = Throuh[userheroThrouh].props
    local soul = Throuh[userheroThrouh].soul
    if props==nil and soul==nil then
        response.ret=-11003
        return response
    end
    if next(props)  then
        if not mBag.usemore(props) then
            response.ret=-11004
            return response
        end
    end

    if next(soul) then
        if not mHero.usemoresoul(soul) then
            response.ret=-11005
            return response
        end
    end

    local ret =mHero.updatehero(hid,userheroThrouh,heroCfg.throuhHeroLevel)
    regActionLogs(uid,9,{action=901,item=hid,value=userheroThrouh+1,params={props=props,soul=soul}})  
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() and ret then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'


    end
    return response


end