-- 添加装备的经验
function api_admin_setequip(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local equip = request.params.equip
    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"equip","userinfo"})
    local mEquip= uobjs.getModel('equip')

    if type(equip)=='table'  and next(equip) then
        for k,v in pairs(equip) do
            if mEquip[k]~=nil then
                mEquip[k]=v
            end
        end
    end


    if uobjs.save() then 
       
        response.data.equip = mEquip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response
end