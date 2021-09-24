
--批量升级碎片
function api_accessory_moreupfragment(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    response.data.accessory={}
    response.data.accessory.info={}
    local uid = request.uid

    
    local info = request.params.info or ''
    
    if uid == nil or info =='' then
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


    if type(info)~='table'  then
        return response
    end

    for k,fid in pairs(info) do
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
        

        local ret = mAccessory.useFragment(fid,composeNum)


        if not ret then
            response.ret = -9017
            return response
        end

        local result,aid=mAccessory.addAccessory({output,0,0})
        if not result then
            response.data.accessory=nil
            return response
        end
        response.data.accessory.info[aid]={output,0,0}
    end
    if uobjs.save() then 
            processEventsAfterSave()
            response.data.accessory.fragment={}
            response.data.accessory.fragment =mAccessory.fragment
            response.ret = 0        
            response.msg = 'Success'
    end

    return response




end