--- 将领受训 领悟

function api_hero_apperception(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid
    local method = tonumber(request.params.type)
    local ption  = tonumber(request.params.ption)
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
    local mUserinfo = uobjs.getModel('userinfo')
    if type (mHero.hero[hid]) ~='table' then
        -- 英雄不存在
        response.ret=-11002
        return response
    end


    local userheroThrouh =mHero.hero[hid][3]
    local heroCfg=getConfig('heroCfg')
    local level =mHero.hero[hid][1]
    local version  =getVersionCfg()

    if mHero.hero[hid][3]<5 then
        response.ret=-11025
        return response
    end

    local heroFeatCfg = getConfig('heroFeatCfg')
    local  gemCost=0
    local ServerProp=heroFeatCfg.ServerPropCost
    local count =mHero.hero[hid][6] or 0
    count=count+1
    if method==1 then
        if ServerProp[count]~=nil then
            gemCost=heroFeatCfg.gemCost[count]
        else
            gemCost=heroFeatCfg.gemCost[#heroFeatCfg.gemCost]
        end
       
        if ption~=nil then
            local key=ption-1
            gemCost=heroFeatCfg.gemCost2[key] or 0
        end
         if gemCost<=0 then
            return  response 
        end
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
    else
        local item={}
        if ServerProp[count]~=nil then
            item=ServerProp[count]
        else
            item=ServerProp[#ServerProp]
        end
        if ption~=nil then
            local key=ption-1
            item=heroFeatCfg.ServerPropCost2[key]
            if item==nil then
                response.ret=-102
                return response
            end
        end
        if not mBag.usemore(item) then
            response.ret=-1996
            return response
        end
        response.data.bag = mBag.toArray(true)
    end
    --二次授勋三个技能
    local skillChoiceCount=2
    local Choicekey=mHero.hero[hid][3]-heroFeatCfg.fusionLimit-1
    local skillChoice2=heroFeatCfg.skillChoice2
    -- 有个特殊的天命技能
    local flag=false
    if skillChoice2[Choicekey]~=nil then
        skillChoiceCount=skillChoice2[Choicekey]
        setRandSeed()
        local randnum=rand(1,1000)
        -- 出天命的概率 这个出现还要检测玩家的技能是否满级
        if (heroFeatCfg.ratio*1000>=randnum) then
            local heroCfg = getConfig('heroListCfg.'..hid)
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
                if lvl<heroSkillLevel then
                    flag=true
                    break
                end
            end
            if flag then    
                skillChoiceCount=skillChoiceCount-1
            end
        end
    end
    local newskill=mHero.rankSkillHero(hid,skillChoiceCount,ption)
    local skillChoice2=heroFeatCfg.skillChoice2
    if flag==true then
        local  tianming=getConfig('heroFeatCfg.tianming')
        table.insert(newskill,{[tianming.id]=1})
    end
    
    if newskill==nil or newskill[1]==nil then
        return response
    end
    if gemCost>0 then
        regActionLogs(uid,1,{action=72,item="",value=gemCost,params={hid=newskill,type=method}})
    end
    mHero.finfo[hid]=newskill
    mHero.hero[hid][6]=(mHero.hero[hid][6] or 0)+1
    mHero.hero[hid][8]=ption
    mHero.refreshFeat("t9",hid,1)
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.newskill =newskill
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
    
end