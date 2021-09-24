--  授勋英雄
--  使用几种道具升级一次成功 会解锁技能
function api_hero_feathero(request)
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

    if moduleIsEnabled('herofeat') == 0 then
        response.ret = -11020
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
    local itemid=heroCfg.getSkillItem
    local level =mHero.hero[hid][1]
    if level<heroCfg.heroLevel[userheroThrouh] then
         -- 突破需要英雄等级不足
        response.ret=-11015
        return response
    end
    local version  =getVersionCfg()

    if type(mHero.feat)~='table' or not next(mHero.feat) then
        response.ret=-11023
        return response
    end
    local heroFeatCfg=getConfig('heroFeatCfg')
    local featThrouh=userheroThrouh-heroFeatCfg.fusionLimit
    local task = heroFeatCfg.heroQuest[hid][featThrouh+1]
    local len =#task
    if mHero.feat[1]~=hid or  mHero.feat[2]<len  or  mHero.feat[3]<task[len][2]  then
        response.ret=-11023
        return response
    end

    local herolistCfg = getConfig('heroListCfg.'..hid)
    local Throuh=herolistCfg.throuh
    local fusionId=herolistCfg.fusionId

    local props = Throuh[userheroThrouh].props
    local soul = Throuh[userheroThrouh].soul
    if props==nil and soul==nil then
        response.ret=-11003
        return response
    end

    if next(props) and type(props)=="table"  then
        if not mBag.usemore(props) then
            response.ret=-11004
            return response
        end
    end

    if type(soul)=="table" and next(soul) then
        if not mHero.usemoresoul(soul) then
            response.ret=-11005
            return response
        end
    end

    local ret =mHero.updateheroThrouh(hid,userheroThrouh,heroCfg.throuhHeroLevel)
    local newskill = nil
    if mHero.hero[hid][5]~=nil then
        newskill=mHero.rankSkillHero(hid,1,2)
    else
        newskill=mHero.rankSkillHero(hid,1)
    end
    if newskill==nil or newskill[1]==nil then
        return response
    end
    if mHero.soul[fusionId]~=nil and mHero.soul[fusionId]>0 then
        local count=mHero.soul[fusionId]
        local ret= mBag.add(itemid,count)
        if not ret then
            response.ret=-1998
            return response
        end
        mHero.soul[fusionId]=nil
        response.data.bag = mBag.toArray(true)
    end
   
    if mHero.hero[hid][5]~=nil then
        if type(mHero.hero[hid][7])~="table"  then mHero.hero[hid][7]={} end
        table.insert(mHero.hero[hid][7],newskill[1])
    else
        mHero.hero[hid][5]=newskill[1]
    end
    mHero.feat={}
    regActionLogs(uid,9,{action=901,item=hid,value=userheroThrouh+1,params={props=props,soul=soul,newskill=newskill}}) 

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