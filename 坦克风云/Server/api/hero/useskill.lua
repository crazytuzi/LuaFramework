-- 将领领悟使用新技能

function api_hero_useskill(request)
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
    
    if mHero.finfo[hid][sid]==nil or type(mHero.finfo[hid][sid])~='table' then
        response.ret=-11026
        return response
    end
    regActionLogs(uid,9,{action=905,item=hid,value=0,params=request.params}) 
    local heroFeatCfg=getConfig('heroFeatCfg')
    local tianming=heroFeatCfg.tianming
    local tianmingglag=false
    for k,v in pairs (mHero.finfo[hid][sid]) do
        if k==tianming.id then
            tianmingglag=true
        end
    end
    -- 随机给基础技能增加一级
    if tianmingglag==true then
        setRandSeed()
        local function getSkill(cfg) 
            local tal=0
            local tmp={}
            for k,v in pairs (cfg) do
                tal=tal+v
                table.insert(tmp,tal)
            end
            local seed = rand(1, tal)
            for k,v in pairs (tmp) do
                if seed<=v then
                    return k
                end
            end
        end
        local flag=false
        local heroCfg = getConfig('heroListCfg.'..hid)
        local randtab ={}
        local skilltab={}
        for sid ,lvl in pairs (mHero.hero[hid][4]) do 
            local heroSkillLevel =0
            for sk,sv in pairs (heroCfg.skills) do
                if sk==1 then
                    heroSkillLevel=sv[2][mHero.hero[hid][3]]   
                end
                if sv[1]==sid then
                    heroSkillLevel=sv[2][mHero.hero[hid][3]] 
                    break  
                end
            end

            table.insert(skilltab,sid)
            if lvl<heroSkillLevel then
                flag=true
                local num=heroFeatCfg.weight[lvl]
                if #randtab>0 then
                    num=num*heroFeatCfg.multiple
                end
                table.insert(randtab,num)
            else
                table.insert(randtab,0)    
            end
        end
        if flag==false then
            response.ret=-11029
            return response
        end
        -- 获取技能key
        local key=getSkill(randtab)
        mHero.hero[hid][4][skilltab[key]]=mHero.hero[hid][4][skilltab[key]]+1
    else
        if mHero.hero[hid][8]~=nil then
            local key=mHero.hero[hid][8]-1
            if mHero.hero[hid][7][key]==nil then
                response.ret=-102 
                return response
            end
            mHero.hero[hid][7][key]=mHero.finfo[hid][sid]
        else
            mHero.hero[hid][5]=mHero.finfo[hid][sid]
        end
    end
    
    
    mHero.finfo[hid]=nil
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
     if uobjs.save() then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end
