--配件突破颜色
function api_accessory_breach(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    local b = request.params.b 
    
    if uid == nil or p ==nil or t==nil then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ec') == 0 then
        response.ret = -9000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')

    local access=mAccessory.getUsedAccessory(t,p)
    if  not next(access) then
        response.ret = -9005
        return response
    end
    local accessoryconfig=getConfig("accessory.aCfg."..access[1])
    if type(accessoryconfig.breach)~='table' then
        response.ret =-9039
        return response
    end
    local breachNeedSmeltLv = accessoryconfig.breach.blvl or 0

    if access[3]<breachNeedSmeltLv then
        response.ret = -9021
        return response
    end

    local  qlevel = tonumber(access[2])
    local  jlevel = tonumber(access[3])
    local  succ   = access[4]
    local  bang   = access[5]
    local  tech   = access[6]

    if qlevel==4 then
        if bang~=1 then-- 突破到红色 需要绑定
            response.ret = -9036
            return response
        end
    end
    if bang==1 then
        succ=succ or {}
    end
    local resolveAccessoryProp = getConfig("accessory.resolveAccessoryProp")
    local aCfg = accessoryconfig
    local part = tonumber(aCfg['part'])
    local quality=tonumber(aCfg['quality']) 
    local smeltMoney=getConfig("accessory.smeltMoney")
    if qlevel>0 then
        local upgradeResource='upgradeResource'
        upgradeResource=upgradeResource..quality

        local resource =  getConfig("accessory."..upgradeResource)

        local resolveupgradeResource = getConfig("accessory.resolveupgradeResource")
        local addResource = {}
        for var=1,qlevel do
            local useResource = resource[part][var]
            for k,v in pairs(useResource) do
                local addcount = math.floor(tonumber(v)*resolveupgradeResource)
                local CurrCount= tonumber(addResource[k]) or 0
                addResource[k] = CurrCount+addcount
            end
        end
        if next(addResource) then
            local ret=mUserinfo.addResource(addResource)
            if not ret then
                response.ret = -403
                return response
            end
            response.data.reward={u=addResource}

        end
    end
    if jlevel>0 and b~=1 then
            --精炼等级大于0
            local addProps = {}
            local smeltPropNum='smeltPropNum'
            smeltPropNum=smeltPropNum..quality
            local resource =  getConfig("accessory."..smeltPropNum)    
            local resolveRefineResource = getConfig("accessory.resolveRefineResource")
            for var=1,jlevel do
                local useResource = resource[var]
                for k,v in pairs(useResource) do
                    if k~='p5' then
                            local addcount = math.floor(tonumber(v)*resolveRefineResource)
                            local CurrCount= tonumber(addProps[k]) or 0
                            addProps[k] = CurrCount+addcount
                        end
                end
            end
            if next(addProps) then
                local ret= mAccessory.addProps(addProps)

                if not ret then
                    response.ret=-1
                    return response
                end
            end
    end
    local addp4  =tonumber(resolveAccessoryProp["part"..part][quality])
    local ret=mAccessory.addProp('p4',addp4)
    if not ret then
        response.ret=-1
        return response
    end
   
    local props =accessoryconfig.breach.props
    if type(props)=='table' and next(props) then
        for k,v in pairs(props) do
            local ret= mAccessory.useProp(k,v)
            if not ret then
                response.ret = -9012
                return response
            end
        end
    end


    local fragments =accessoryconfig.breach.fragment
    if type(fragments)=='table' and next(fragments) then
        for k,v in pairs(fragments) do
            local ret= mAccessory.useFragment(k,v)
            if not ret then
                response.ret =-9017
                return response
            end
        end
    end

    local cjlevel=0
    if b==1 then
        local gemCost=smeltMoney[jlevel]
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=149,item="",value=gemCost,params={access,jlevel}})
        cjlevel=jlevel
    end 

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    mAccessory.used[t][p]={accessoryconfig.breach.get,0,cjlevel,succ,bang,tech}
    --  突破
    regKfkLogs(uid,'accessory',{
                addition={
                    {desc="配件突破",value={access,p,t}},
                    {desc="剩余材料",value=mAccessory.props},
                    {desc="剩余碎片",value=mAccessory.fragments},
                    {desc="配件突破后",value=mAccessory.used[t][p]},
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