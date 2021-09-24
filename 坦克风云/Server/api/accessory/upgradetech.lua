--  配件科技升级
function api_accessory_upgradetech(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('at') == 0 then
        response.ret = -9000
        return response
    end
    local uid = request.uid
    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    local sid=request.params.sid
    if uid == nil or p ==nil or t==nil then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag      = uobjs.getModel('bag')

    local access=mAccessory.getUsedAccessory(t,p)
    if  not next(access) then
        response.ret = -9005
        return response
    end
    local accessoryconfig=getConfig("accessory.aCfg."..access[1])
    if access[5]~=1  or  accessoryconfig.quality<4 then
        response.ret =-9043
        return response
    end
    local tankType=getConfig("accessorytech.tankType")
    if type(access[6])~='table' then access[6]={} end

    local version  =getVersionCfg()
    local tech     =access[6]
    local level    =tech[2] or 0
    local stype    =tech[1] or sid
    if level>=version.unlockAccTechLvl then
        response.ret=-9044
        return response
    end

    if tankType[t]==nil then
        response.ret=-102
        return response
    end
    if tankType[t][stype]==nil then
        response.ret=-102
        return response
    end

    if tankType[t][stype]==nil then
        response.ret=-102
        return response
    end


    if tankType[t][stype].cost[level+1]==nil then
        response.ret=-102
        return response
    end

    local pd= p:split('p') 
    local newp=tonumber(pd[2])
    if tankType[t][stype].cost[newp][level+1]==nil then
        response.ret=-102
        return response
    end
    local techconfig=tankType[t][stype].cost[newp][level+1]

    local props =techconfig.props
    if type(props)=='table' and next(props) then
        for k,v in pairs(props) do
            local ret= mAccessory.useProp(k,v)
            if not ret then
                response.ret = -9012
                return response
            end
        end
    end
    

    local fragments =techconfig.fragment
    if type(fragments)=='table' and next(fragments) then
        for k,v in pairs(fragments) do
            local ret= mAccessory.useFragment(k,v)
            if not ret then
                response.ret =-9017
                return response
            end
        end
    end

    local prop =techconfig.p
    if type(prop)=='table' and next(prop) then
         if not mBag.usemore(prop) then
            response.ret=-1996
            return response
        end
    end
    access[6]={sid,level+1}
     --  突破
    regKfkLogs(uid,'accessory',{
                addition={
                    {desc="配件科技强化后",value=access},
                    {desc="剩余材料",value=mAccessory.props},
                    {desc="剩余碎片",value=mAccessory.fragments},
                }
            }
        )

    if uobjs.save() then 
        processEventsAfterSave()
        response.data.accessory={}
        response.data.accessory.props={}
        response.data.accessory.props =mAccessory.props
        response.data.accessory.used = {}
        response.data.accessory.used = mAccessory.used
        response.data.accessory.fragment={}
        response.data.accessory.fragment =mAccessory.fragment
        response.ret = 0        
        response.msg = 'Success'    
                
    end    


   return response
end