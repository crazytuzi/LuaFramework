--  升级英雄技能 
function api_hero_upgradeskill(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    local sid = request.params.sid 
    if uid == nil then
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
    if mHero.hero[hid][4][sid]==nil then
        response.ret=-11006
        return response
    end 

    local slevel =mHero.hero[hid][4][sid]
    local heroCfg = getConfig('heroListCfg.'..hid)
    local heroSkillLevel =0
    for k,v in pairs(heroCfg.skills) do

        if k==1 then
            heroSkillLevel=v[2][mHero.hero[hid][3]]   
        end
        if v[1]==sid then
            heroSkillLevel=v[2][mHero.hero[hid][3]]   
        end
    end
    if (slevel+1>heroSkillLevel) then
        response.ret=-11007
        return response
    end


    local heroSkillCfg=getConfig('heroSkillCfg.'..sid)
    
    local props =heroSkillCfg.breach[slevel].props

    if props==nil then
        response.ret=-11007
        return response
    end
    if next(props) then
        if not mBag.usemore(props) then
            response.ret=-11004
            return response
        end
    end
    
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='jk'})

    local ret = mHero.upgradeheroskilllevel(hid,sid,slevel+1)
    regActionLogs(uid,9,{action=904,item=hid..sid,value=0,params=props}) 
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
