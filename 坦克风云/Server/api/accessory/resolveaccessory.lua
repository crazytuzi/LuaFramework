-- 分解配件
function api_accessory_resolveaccessory(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid
    --1    单个分解传aid
    --2    批量分解传品质
    local method =tonumber(request.params.type) or 0
    local qualitydata =request.params.quality or 0

    local aid     = tostring(request.params.aid) or 0
    if uid == nil or method==0 then
        response.ret = -102
        return response
    end


    if moduleIsEnabled('ec')== 0 then
        response.ret = -9000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')    
    local resolveAccessoryProp = getConfig("accessory.resolveAccessoryProp")
    local resolveAccessoryCrystalsProp = getConfig("accessory.resolveAccessoryCrystalsProp")
    




    --分解单个配件
    response.data.accessory={}
    if method==1 then
        local addProps = {}
        local accessid,access=mAccessory.getAccessoryId(aid)
        if  accessid==nil then
            response.ret=-9001
            return response
        end
        
        local  qlevel = tonumber(access[2])
        local  jlevel = tonumber(access[3])

        local aCfg = getConfig("accessory.aCfg."..accessid)
        local part = tonumber(aCfg['part'])
        local quality=tonumber(aCfg['quality'])
        local  config = aCfg   
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
        addProps['p4']=(addProps['p4'] or 0)+addp4
        local kfkprops={addProps}
        if not ret then
               response.ret=-1
               return response
        end
        -- 添加晶体
        local addCrystals =resolveAccessoryCrystalsProp["part"..part][quality]
        if moduleIsEnabled('ecshop') == 1 then
            if type(addCrystals)=='table' and next(addCrystals) then
                local ret= mAccessory.addProps(addCrystals)
                table.insert(kfkprops,addCrystals)
                if not ret then
                    response.ret=-1
                    return response
                end
            end
        end

        local ret=mAccessory.delAccessory(aid)
        if not ret then
               response.ret=-1
               return response
        end
        regKfkLogs(uid,'accessory',{
                addition={
                    {desc="分解配件",value=access},
                    {desc="得到材料",value=kfkprops},
                    {desc="剩余材料",value=mAccessory.props},
                }
            }
        ) 

        -- stats                                                                        
        regStats('accessory_daily',{item= 'resolveAnum.' .. (access[1] or ''),num=1})
        if uobjs.save() then 

                processEventsAfterSave()
               
                response.data.accessory.info={}
                   response.data.accessory.info=mAccessory.info
                   response.data.accessory.props={}
                   response.data.accessory.props =mAccessory.props
                response.ret = 0        
                response.msg = 'Success'
                return response
            else

               response.ret = -1
               response.msg = "save failed"
        end
        return response    
    end



    --分解多品质配件
    if method==2 then
        if type(qualitydata) ~='table' then
            response.ret=-9018
               return response
        end

        local addProps = {}
        local addResource = {}
        local flag = true
        local resolveupgradeResource = getConfig("accessory.resolveupgradeResource")
        local resolveRefineResource = getConfig("accessory.resolveRefineResource")
        local kfkacc={}
        for k,quality in pairs(qualitydata) do
            if type(mAccessory.info)=='table' and next(mAccessory.info) then
                for key,val in pairs(mAccessory.info)do
                    if type(val) =='table' then
                        
                        local aCfg = getConfig("accessory.aCfg."..val[1])
                        local part = tonumber(aCfg['part'])
                        local uquality=tonumber(aCfg['quality'])
                        -- 添加晶体
                        
                        if uquality==quality then
                            table.insert(kfkacc,val)
                            -- 分解加晶体
                            if moduleIsEnabled('ecshop') == 1 then
                                local addCrystals =resolveAccessoryCrystalsProp["part"..part][quality]
                                for pk,pv in pairs(addCrystals) do
                                    local CurrCount= tonumber(addProps[pk]) or 0
                                    addProps[pk] = CurrCount+pv
                                end
                            end
                            
                            flag=false

                            if val[1] then
                                -- stats                                                                        
                                regStats('accessory_daily',{item= 'resolveAnum.' .. (val[1] or ''),num=1})
                            end

                            local qlevel =tonumber(val[2])
                            if qlevel>0 then
                                local upgradeResource='upgradeResource'
                                upgradeResource=upgradeResource..uquality

                                local resource =  getConfig("accessory."..upgradeResource)
                                for var=1,qlevel do
                                    local useResource = resource[part][var]
                                    for k,v in pairs(useResource) do
                                        local addcount = math.floor(tonumber(v)*resolveupgradeResource)
                                        -- print(addcount)
                                        local CurrCount= tonumber(addResource[k]) or 0
                                        addResource[k] = CurrCount+addcount
                                    end
                                end
                                
                            end

                            local jlevel = tonumber(val[3])
                            if jlevel>0 then

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
                            end

                            local iCurrCount = tonumber(addProps['p4']) or 0
                            local iAllCount = tonumber(resolveAccessoryProp["part"..part][uquality])     + iCurrCount
                            addProps['p4'] =iAllCount

                            mAccessory.delAccessory(key)

                        end

                    end
                end

            end

        end
        if flag then

            response.ret=-9019
               return response

        end
        if next(addProps) then
            local ret =mAccessory.addProps(addProps)
            if not ret then
                response.ret=-1
                   return response

            end
        end
        regKfkLogs(uid,'accessory',{
                addition={
                    {desc="分解配件",value=kfkacc},
                    {desc="得到材料",value=addProps},
                    {desc="剩余材料",value=mAccessory.props},
                    {desc="得到的资源",value=addResource},
                }
            }
        ) 

        if next(addResource) then
            local ret=mUserinfo.addResource(addResource)
            if not ret then
                response.ret = -403
                return response
            end
            response.data.reward={u=addResource}

        end
        if uobjs.save() then 
            processEventsAfterSave()
                
                   response.data.accessory={}
                   response.data.accessory.info={}
                   response.data.accessory.info=mAccessory.info
                   response.data.accessory.props ={}
                   response.data.accessory.props =mAccessory.props

                response.ret = 0        
                response.msg = 'Success'
                return response
            else

                response.ret = -1
                response.msg = "save failed"
        end

    end


    

end