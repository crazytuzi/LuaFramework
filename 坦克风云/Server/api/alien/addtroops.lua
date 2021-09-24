-- 改造坦克

function api_alien_addtroops(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local pid = request.params.id
    local tid = request.params.tid or 0
    local nums= tonumber(request.params.count) 
    local nums= math.abs(nums)
    local enum= tonumber(request.params.enum) or 0
    local enum= math.abs(enum)
    if uid ==nil or  pid==nil  then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo","bag","dailytask","troops","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')
    local mBag  = uobjs.getModel('bag')
    local mTroop =uobjs.getModel('troops')
    local alienTechCfg = getConfig("alienTechCfg")
    local mUseractive = uobjs.getModel('useractive')

    if alienTechCfg.talent[pid]==nil then
        response.ret=-16001
        return response
    end 
    local talentType=alienTechCfg.talent[pid][3]

    if talentType~=3 then
        response.ret=-16012
        return response
    end
    local resRate=1
    local rate=activity_setopt(uid,'taibumperweek',{rate=1})
    if rate~=nil and rate<1 and rate>0 then
        resRate= rate<resRate and rate or resRate
    end

    local aid=alienTechCfg.talent[pid][5]
    if type(aid)=='table' then
        if tid==0 then
            aid=aid[1]
        else
            local flag=table.contains(aid, tid) 
            if not flag then
                response.ret=-102
                return response
            end   
            aid=tid
        end
    end
    local tanks = {}
    --异星卡片
    local activStatus = mUseractive.getActiveStatus('aliencard')
    if activStatus==1 then
        rate,tanks = mUseractive.aliencard('aliencard',{act='add',rate=1,aid="troops_"..aid})
        if rate~=nil and rate<1 and rate>0 then
            resRate= rate<resRate and rate or resRate
        end
    end
  
    -- 无限活力
    local activStatus = mUseractive.getActiveStatus('luckcard')
    if activStatus==1 then
        rate,tanks=mUseractive.luckcard('luckcard',{rate=1,aid="troops_"..aid})
        if rate~=nil and rate<1 and rate>0 then
            resRate= rate<resRate and rate or resRate
        end
    end

    -- 无限火力2018
    local activStatus = mUseractive.getActiveStatus('luckcard2018')
    if activStatus==1 then
        rate,tanks=mUseractive.luckcard('luckcard2018',{aid="troops_"..aid})
        if rate~=nil and rate<1 and rate>0 then
            resRate= rate<resRate and rate or resRate
        end
    end
    
    -- 残骸打捞
    local chdlrate = activity_setopt(uid,'chdl',{aid=aid})
    if chdlrate and chdlrate>0 and chdlrate<1 then
        if type(tanks)~='table' then
            tanks = {}
        end
        table.insert(tanks,"troops_"..aid) 
        rate = chdlrate
        resRate= rate<resRate and rate or resRate
    end
    
    if mAlien.info[pid]==nil then
        local aflag = false
        local qflx2018 = activity_setopt(uid,'qflx2018')
        if type(qflx2018)=='table' and next(qflx2018) then
            if not table.contains(qflx2018,aid) then
                response.ret=-16013
                return response
            end
            aflag = true
        end

        if not aflag then
            if resRate>=1 then 
                response.ret=-16013
                return response
            end
        end

	resRate=1
	rate = nil
    end
  
    local cfg = getConfig('tank.' .. aid)

    local bTankConsume = cfg.upgradeShipConsume
    -- 升级需要消耗的坦克数
    local iTanks = bTankConsume[2] * nums
    local Consume={}
    -- 消耗精英的坦克去升级
    if enum>0 then
        iTanks=iTanks-enum
        local ctankid =bTankConsume[1]
        local ctankCfg=getConfig('tank.' .. ctankid)
        local etankid =ctankCfg.elite2Tank
        if  not mTroop.troops[etankid] or enum > mTroop.troops[etankid] or not mTroop.consumeTanks(etankid,enum) then 
            response.ret = -115
            return response
        end
        Consume[etankid]=(Consume[etankid] or 0)+enum
    end
    if iTanks>0 then
        if not mTroop.troops[bTankConsume[1]] or iTanks > mTroop.troops[bTankConsume[1]] or not mTroop.consumeTanks(bTankConsume[1],iTanks) then 
            response.ret = -115
            return response
        end
        Consume[bTankConsume[1]]=(Consume[bTankConsume[1]] or 0)+iTanks
    end
    regKfkLogs(uid,'tankChange',{
                addition={
                    {desc="改造减少坦克",value=Consume},
                    {desc="改造坦克id",value=aid},
                    {desc="改造坦克数量",value=nums},
                }
            }
        ) 

     -- 改装需要的道具
    local bPropConsume = cfg.upgradePropConsume
    if type(bPropConsume) == 'table' and next(bPropConsume) then
        local mBag = uobjs.getModel('bag')
        
        for _,v in ipairs(bPropConsume) do
            local tmpNum = v[2] * nums
            if not mBag.use(v[1],tmpNum) then
                response.ret = -1996
                return response
            end
        end
        response.data.bag = mBag.toArray(true)
    end

    
    local bRes = {}
    bRes.r4 = nums * cfg.alienUraniumConsume
    if resRate<1 then
        if mAlien.info[pid]~=nil then
            bRes.r4 =math.floor(bRes.r4 *resRate)
        end
    end
    if cfg.isSpecial==1 then
        
        bRes.r1 = nums * cfg.upgradeMetalConsume
        bRes.r2 = nums * cfg.upgradeOilConsume
        bRes.r3 = nums * cfg.upgradeSiliconConsume
        bRes.r4 = nums * cfg.upgradeUraniumConsume
        if resRate~=nil and resRate<1 and type(tanks)=='table' then
            if table.contains(tanks,"troops_"..aid) then
                for k,v in pairs (bRes) do
                    bRes[k]=v*resRate
                end
            end
        end
    end
    if not mUserinfo.useResource(bRes) then
        response.ret = -107
        return response
    end 

    mTroop.incrTanks(aid,nums)
    -- 战资比拼
    zzbpupdate(uid,{t='f8',id=aid,n=nums})
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        
    end
    return response

end