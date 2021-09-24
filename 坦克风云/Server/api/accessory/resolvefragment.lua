-- 分解碎片
function api_accessory_resolvefragment(request)

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

    local fid     = tostring(request.params.fid) or 0

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    local resolveFragmentProp = getConfig("accessory.resolveFragmentProp")
    local resolveFragmentCrystalsProp = getConfig("accessory.resolveFragmentCrystalsProp")
    --ptb:p(mAccessory)
    
    if uid == nil or method==0 then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ec') == 0 then
        response.ret = -9000
        return response
    end

    --method =1 分解一种碎片所有数量

    if method==1 then  
        local count =mAccessory.getFragment(fid)
        if count <=0 then
            response.ret = -9014 
            return response
        end
        local fragmentconfig = getConfig("accessory.fragmentCfg."..fid)
        local quality=tonumber(fragmentconfig['quality'])
        local part = tonumber(fragmentconfig['part'] or 1)
        local  addcount = count* tonumber(resolveFragmentProp[quality])
        local ret =mAccessory.useFragment(fid,count)

                        -- stats 
                        regStats('accessory_daily',{item= 'resolveFnum.' .. (fid or ''),num=count})

        if not ret then 
            response.ret = -1
               return response
        end
        local ret  = mAccessory.addProp('p4',addcount)

        if not ret then 
            response.ret = -1
               return response
        end
         -- 添加晶体
        local addCrystals =resolveFragmentCrystalsProp["part"..part][quality]
        if moduleIsEnabled('ecshop') == 1 then
            if type(addCrystals)=='table' and next(addCrystals) then
                for addkey,addval in pairs(addCrystals) do
                    local ret= mAccessory.addProp(addkey,addval*count)
                    if not ret then
                        response.ret=-1
                        return response
                    end
                end
            end
        end
        if uobjs.save() then 
            processEventsAfterSave()

                   response.data.accessory={}
                   response.data.accessory.fragment={}
                   response.data.accessory.fragment =mAccessory.fragment
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

    --method =2 分解同一品质的碎片
    local flag = true
    local addcount = 0
    if method==2 then
        if type(qualitydata)~='table' then
            response.ret = -9018
               return response
        end

        for k,quality in pairs(qualitydata) do

            if type(mAccessory.fragment)=='table' and next(mAccessory.fragment) then

                for fid,count in pairs(mAccessory.fragment) do
                    local fragmentconfig = getConfig("accessory.fragmentCfg."..fid)
                    local uquality=tonumber(fragmentconfig['quality'])
                    local part = tonumber(fragmentconfig['part'] or 1)
                    if uquality ==quality then

                        addcount = addcount+count* tonumber(resolveFragmentProp[quality])
                        flag =false

                        mAccessory.useFragment(fid,count)

                        -- stats
                        regStats('accessory_daily',{item= 'resolveFnum.' .. (fid or ''),num=count})
                         -- 添加晶体
                        local addCrystals =resolveFragmentCrystalsProp["part"..part][quality]
                        if moduleIsEnabled('ecshop') == 1 then
                            if type(addCrystals)=='table' and next(addCrystals) then
                                for addkey,addval in pairs(addCrystals) do
                                    local ret= mAccessory.addProp(addkey,addval*count)
                                    if not ret then
                                        response.ret=-1
                                        return response
                                    end
                                end
                                
                            end
                        end
                        
                    end
                    
                end
            end
        end


        if flag then

            response.ret=-9020
               return response

        end
        local ret  = mAccessory.addProp('p4',addcount)

        if not ret then 
            response.ret = -1
               return response
        end
        if addcount>0 then

            if uobjs.save() then 
                processEventsAfterSave()
                
                   response.data.accessory={}
                   response.data.accessory.fragment={}
                   response.data.accessory.fragment =mAccessory.fragment
                   response.data.accessory.props={}
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




end