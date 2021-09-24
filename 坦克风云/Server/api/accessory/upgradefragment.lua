-- 配件合成碎片
function api_accessory_upgradefragment(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid = request.uid

    local fid = tostring(request.params.fid) or ''

    local use = tonumber(request.params.use) or 0
    
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

    --橙色的只能突破
    if fragmentconfig.quality==4 then
        response.ret = -9015
        return response
    end

    if output =="" then 
        response.ret = -9015
        return response
    end

    local havecount = mAccessory.getInfoCount()
    local iMaxCount = getConfig("accessory.aCapacity")
    --havecount=48
    if havecount >=iMaxCount then
        response.ret = -9016
        return response
    end
    if use >0 then
        if count<composeNum then

            local delcount =composeNum-count
            local f0count=mAccessory.getFragment('f0')
            if f0count< delcount then
                response.ret = -9017
                return response
            end
            
            mAccessory.useFragment('f0',delcount)    
            composeNum=composeNum-delcount
        end
    end

    local ret = mAccessory.useFragment(fid,composeNum)


    if not ret then
        response.ret = -9017
        return response
    end

    local result,aid=mAccessory.addAccessory({output,0,0})

    --print(ret)
    --ptb:p(mAccessory)
    if result then
         if uobjs.save() then 

                -- stats
                regStats('accessory',{item= 'fUpgradeAnum.' .. (output or ''),num=1})

                processEventsAfterSave()

                   response.data.accessory={}
                   response.data.accessory.info={}
                   response.data.accessory.info[aid]={output,0,0}
                   response.data.accessory.fragment={}
                   response.data.accessory.fragment =mAccessory.fragment
                response.ret = 0        
                response.msg = 'Success'
                return response
            else

                response.ret = -1
                response.msg = "save failed"
            end

    else
         response.ret=-1   
         return response
    end




end