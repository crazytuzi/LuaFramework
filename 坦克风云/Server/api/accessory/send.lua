--  赠送配件

function api_accessory_send(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid = request.uid

    local mid = request.params.mid

    local aid     = tostring(request.params.aid) 


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag      = uobjs.getModel('bag')
    local accessid,access=mAccessory.getAccessoryId(aid)
    local pid='p904'
    local use = mBag.use(pid,1)
    if not use then
        response.ret=-1996
        return response
    end

    if accessid==nil then
        response.ret=-9001
        return response
    end
    local accessconfig = getConfig("accessory.aCfg."..accessid)
    if not next(accessconfig) then
        response.ret =-9002  
        return response
    end
    if accessconfig.pId==nil then
        response.ret =-9002
        return response
    end

    if access[2]>0 or access[3]>0 then
        response.ret =-102
        return response
    end 
    local pId=accessconfig.pId
    mAccessory.delAccessory(aid)
    if uobjs.save() then 
        local item={}
        item.h={["props_p"..pId]=1}
        item.q={p={{["p"..pId]=1}}}
        item.f={0}
        local title=31
        local content={type=31,name=mUserinfo.nickname}
        local ret = MAIL:mailSent(mid,1,mid,mUserinfo.nickname,'',title,content,1,0,2,item)
        response.data.accessory={}
        response.data.accessory.info={}
        response.data.accessory.info=mAccessory.info
        response.data.bag = mBag.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response




end