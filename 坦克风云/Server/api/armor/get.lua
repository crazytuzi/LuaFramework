--获取配件

function api_armor_get(request)
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
    local mArmor = uobjs.getModel('armor')
    local armorCfg=getConfig('armorCfg')
    mArmor.reffreecount(armorCfg)
    response.data.armor =mArmor.toArray(true)
    response.ret = 0        
    response.msg = 'Success'
    return response
end