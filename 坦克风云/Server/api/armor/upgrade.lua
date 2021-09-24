-- 装甲升级

function api_armor_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local mid = request.params.mid
    local level=request.params.level or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","armor"})
    local mArmor = uobjs.getModel('armor')
    local mUserinfo = uobjs.getModel('userinfo')
    local armorCfg=getConfig('armorCfg')

    if mArmor.info[mid]==nil then
        response.ret=-102
        return response
    end
    local id=mArmor.info[mid][1]
    local lvl=mArmor.info[mid][2]
    local armor=armorCfg.matrixList[id]
    if type(armor)~='table' then
        response.ret=-102
        return response
    end
    local quality=armor.quality
    local part   =armor.part
    local maxlvl =armorCfg.upgradeMaxLv[quality] or 0
    if lvl+level>maxlvl then
        response.ret=-9051
        return response
    end
    if lvl+level>mUserinfo.level then
        response.ret=-9051
        return response 
    end
    local talexp=0
    for i=1,level do
        local needexp=armorCfg['upgradeResource'..quality][part][lvl+i]
        if mArmor.exp<needexp then
            response.ret=-9052
            return response
        end
        talexp=talexp+needexp
        mArmor.exp=mArmor.exp-needexp
    end
    
    mArmor.info[mid][2]=lvl+level
    regKfkLogs(uid,'armor',{
                addition={
                    {desc="升级装甲id",value=mid},
                    {desc="升级装甲信息",value={olvl=lvl,nlvl=mArmor.info[mid][2]}},
                    {desc="升级装甲消耗的经验",value=talexp},
                }
            }
    )
    -- 矩阵升级  
    activity_setopt(uid,'armorUp',{level=level,quality=quality})

    --德国七日狂欢 
    activity_setopt(uid,'sevendays',{act='armorup',v=mArmor.info,n=1})
    
    -- 成就数据
    updatePersonAchievement(uid,{'a2'})

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={info={}}
        response.data.armor.info[mid] =mArmor.info[mid]
        response.data.armor.exp =mArmor.exp
        response.ret = 0        
        response.msg = 'Success'
    end
    return response

end