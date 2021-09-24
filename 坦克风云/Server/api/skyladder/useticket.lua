function api_skyladder_useticket(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    if moduleIsEnabled('ladder') == 0 then
        response.ret = -19000
        return response
    end
    
    local uid = request.uid
    local sid = request.params.sid

    if uid == nil or sid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')
    local mBag = uobjs.getModel('bag')
    local mUseractive
	local ret
    
    -- 刷新生产队列
    mProp.update()

    local cfg = getConfig('skyladderCfg')
    local pShopItems = cfg.pShopItems
    local bPropInfo = pShopItems[sid]
	local reward = bPropInfo.serverReward
    local needItem = cfg.buyitem
	local needNum = bPropInfo.price
	local flag = false
	local haveNum = mBag.getPropNums(needItem)
    if haveNum <=0 or haveNum < needNum or not mBag.use(needItem,needNum) then
        response.ret = -1982
        return response
    end

	ret = takeReward(uid,reward)


    processEventsBeforeSave()

    if ret and uobjs.save() then           
        processEventsAfterSave()

        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        response.data.bag = mBag.toArray(true)
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	