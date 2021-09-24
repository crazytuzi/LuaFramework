--  世界等级


function api_admin_worldlevel(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    } 


    local method = request.params.method
    local addexp = request.params.exp
    if method=="set" then 
        if moduleIsEnabled('wl')== 1 then
            local version  =getVersionCfg()
            local MaxLevel=tonumber(version.roleMaxLevel)-20
            updateWorldLevelExp(addexp,MaxLevel)
        end
    
    end 
    response.data.wlvl=getWorldLevel()
    response.data.wexp=getWorldLevelExp()
    return response

end    