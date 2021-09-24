--碎片突破成配件  需要的物品多
function api_accessory_breachfragment(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid = request.uid

    local fid = request.params.fid 

    local aid = request.params.aid
    
    --use=2
    if uid == nil or fid =='' then
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

    local count=mAccessory.getFragment(fid)
    if  count==0  then
        response.ret = -9014
        return response
    end    


    local fragmentconfig = getConfig("accessory.fragmentCfg."..fid)
    local composeNum =tonumber(fragmentconfig['composeNum'])  --升级成配件需要的碎片数量
    local output = fragmentconfig['output']         --升级成哪种配件如果是空 就是万能碎片

    if output =="" then 
        response.ret = -9015
        return response
    end
    --不是橙色的不能突破
    if fragmentconfig.quality~=4 then
        response.ret = -9020
        return response
    end

    local havecount = mAccessory.getInfoCount()
    local iMaxCount = getConfig("accessory.aCapacity")
    --havecount=48
    if havecount >=iMaxCount then
        response.ret = -9016
        return response
    end
    
    if type(fragmentconfig.breach)~='table' then
        response.ret = -9020
        return response
    end
    local accessid,access =mAccessory.getAccessoryId(aid)
    if not next(access) then
        response.ret = -9005
        return response
    end

    local breachNeedSmeltLv = getConfig("accessory.breachNeedSmeltLv")

    if access[3]<breachNeedSmeltLv then
        response.ret = -9021
        return response
    end
    --ptb:p(mAccessory.toArray(true))  
    --先把配件分解了
    local  qlevel = tonumber(access[2])
    local  jlevel = tonumber(access[3])
    local  succ   = access[4]
    local resolveAccessoryProp = getConfig("accessory.resolveAccessoryProp")
    local aCfg = getConfig("accessory.aCfg."..accessid)
    local part = tonumber(aCfg['part'])
    local quality=tonumber(aCfg['quality'])
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
    if jlevel>0 then
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
    local ret=mAccessory.delAccessory(aid)
    if not ret then
        response.ret=-1
        return response
    end

      
    local ret = mAccessory.useFragment(fid,composeNum)

    if not ret then
        response.ret = -9017
        return response
    end

    local props =fragmentconfig.breach.props

    if type(props)=='table' and next(props) then
        for k,v in pairs(props) do
            local ret= mAccessory.useProp(k,v)
            if not ret then
                response.ret = -9012
                return response
            end
        end
    end
    

    local fragments =fragmentconfig.breach.fragment
    if type(fragments)=='table' and next(fragments) then
        for k,v in pairs(fragments) do
            local ret= mAccessory.useFragment(k,v)
            if not ret then
                response.ret =-9017
                return response
            end
        end
    end
    --然后扣道具

    --最后加配件

    local result,aid=mAccessory.addAccessory({output,0,0,succ})
    --ptb:p(mAccessory.toArray(true))
    if result then
          if uobjs.save() then 

                 -- stats
             --regStats('accessory',{item= 'fUpgradeAnum.' .. (output or ''),num=1})

             processEventsAfterSave()
             response.data.accessory={}
             response.data.accessory.info={}
             response.data.accessory.props={}
             response.data.accessory.props =mAccessory.props
             response.data.accessory.info[aid]={output,0,0}
             response.data.accessory.fragment={}
             response.data.accessory.fragment =mAccessory.fragment
             response.ret = 0        
             response.msg = 'Success'    
                
         end    
         
     end
    return response

end