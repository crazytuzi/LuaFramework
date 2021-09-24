-- 矩阵商店兑换
function api_armor_shop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local item= tonumber(request.params.item)
    local costGem = request.params.costGem
    local costItems = request.params.costItems

    if uid == nil or item == nil or type(costItems) ~= "table" then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end

    -- 商店开关关闭
    if moduleIsEnabled('arShop') == 0 then
        response.ret = -102
        return response
    end 
    
    local armorCfg=getConfig('armorCfg')
    local itemCfg = armorCfg.matrixShop[item]
    if not itemCfg then
        response.ret = -102
        return response
    end

    -- 客户端显示的钻石数与配置不一致
    if costGem < 10 or costGem ~= itemCfg.costGem then
        response.ret = -102
        response.itemCostGem = itemCfg.costGem
        return response
    end

    -- 需要消耗的数量不对
    if #costItems ~= itemCfg.costNum then
        response.ret = -102
        response.costNum = itemCfg.costNum
        return response
    end

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local mArmor = uobjs.getModel('armor')
    
    -- 商店冷却中,不能兑换装甲
    if not mArmor.checkShopCD() then
        response.ret = -9056
        return response
    end

    local returnExp = 0
    local costLog = {}

    for _,itemId in pairs(costItems) do
        local armorId, armorInfo = mArmor.getArmorId(itemId)
        if armorId ~= itemCfg.cost then
            response.ret = -102
            response.cost = itemCfg.cost
            return response
        end

        table.insert(costLog,armorInfo)
        returnExp = returnExp + mArmor.getReturnExp(itemId)

        if not mArmor.delArmor(itemId) then
            response.ret = -102
            response.err = "armor is not enough"
            return response
        end
    end

    if not mArmor.addArmor({itemCfg.get, 1}) then
        response.ret = -1
        response.err = "add armor failed"
        return response
    end

    mArmor.addExp(returnExp)
    mArmor.setShopAt()

    local gemCost = costGem
    if not mUserinfo.useGem(gemCost) then
        response.ret = -109
        return response
    end

    -- 矩阵商店兑换
    regActionLogs(uid,1,{action=260,item="",value=gemCost,params={item=item}})
    regKfkLogs(uid,'armor',{
            addition={
                {desc="商店兑换装甲消耗",value=costLog},
                {desc="增加的经验",value=returnExp},
            }
        }
    )

    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={
            info = mArmor.info,
            shopAt = mArmor.shopAt,
            
        }

        if returnExp > 0 then
            response.data.armor.reward={am={exp=returnExp}}
        end

        response.ret = 0    
        response.msg = 'Success'
    end

    return response
end