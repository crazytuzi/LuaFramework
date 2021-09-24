-- 分解装甲

function api_armor_resolve(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid     = request.uid
    local mid     = request.params.mid
    local qualitys= request.params.quality
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
    local armorCfg=getConfig('armorCfg')
    local list={}
    if  mid~=nil then
        if mArmor.info[mid]==nil   then
            response.ret=-9055
            return response
        end
        if mArmor.checkUsed(mid) then
            response.ret=-102
            return response
        end
        table.insert(list,mArmor.info[mid])
        mArmor.delArmor(mid)
    end
    if type(qualitys)=="table" then
        local used={}
        for uk,uv in pairs(mArmor.used) do
            if next(uv) then
                for uak,uav in pairs (uv) do 
                    if uav~=0 then
                        table.insert(used,uav)
                    end
                end
            end
        end
        for qk,quality in pairs(qualitys) do
            if quality~=nil and quality>0 then
                for k,v in pairs (mArmor.info) do
                    local maid =v[1]
                    local tmpquality= armorCfg.matrixList[maid]['quality']
                    if tmpquality==quality then
                        local   flag=table.contains(used, k)
                        if not flag then
                            table.insert(list,v)
                            mArmor.delArmor(k)
                        end
                    end
                end
            end
        end
    end
    if not next(list) then
        response.ret=-102
        return response
    end
    local addexp=0
    for k,v in pairs (list) do
        local maid=v[1]
        local lvl =v[2]
        local cfg=armorCfg.matrixList[maid]['decompose']
        local quality=armorCfg.matrixList[maid]['quality']
        local part=armorCfg.matrixList[maid]['part']
        addexp=addexp+cfg.exp
        for i=1,lvl do
            local needexp=armorCfg['upgradeResource'..quality][part][i]
            addexp=addexp+math.floor(needexp*armorCfg.resolveupgradeResource)
        end
        
    end
    regKfkLogs(uid,'armor',{
                addition={
                    {desc="分解装甲列表",value=list},
                    {desc="分解装甲增加的经验",value=addexp},
                    
                }
            }
    )
    mArmor.exp=mArmor.exp+addexp
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={info={}}
        response.data.armor.info =mArmor.info
        response.data.armor.exp =mArmor.exp
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end
