-- 背包扩容
function api_armor_addbag(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
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
    local mUserinfo = uobjs.getModel('userinfo')
    local mArmor = uobjs.getModel('armor')
    local armorCfg=getConfig('armorCfg')
    mArmor.reffreecount(armorCfg)

   
    local storeHouseMaxNum=armorCfg.storeHouseMaxNum
    if mArmor.count>=storeHouseMaxNum then
        response.ret=-9053 
        return response
    end
    local num=mArmor.buynum or 0
    local num=num+1
    local addStoreHouseCost=armorCfg.addStoreHouseCost
    local gemCost=addStoreHouseCost[num] or addStoreHouseCost[#addStoreHouseCost]
    mArmor.buynum=num
    if not mUserinfo.useGem(gemCost) then
        response.ret = -109
        return response
    end
    mArmor.count=mArmor.count+armorCfg.addStoreHouseNum
    regActionLogs(uid,1,{action=157,item="",value=gemCost,params={num=num,count=mArmor.count}})
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={}
        response.data.armor.count =mArmor.count
        response.data.armor.buynum =mArmor.buynum
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end