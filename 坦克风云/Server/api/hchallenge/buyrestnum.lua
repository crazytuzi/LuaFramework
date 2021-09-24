function api_hchallenge_buyrestnum(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sid = request.params.sid or nil
    local free = request.params.free or nil
	local ts = getClientTs()
	local weeTs = getWeeTs(ts)
	
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
	local hChallengeCfg = getConfig('hChallengeCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'hchallenge'})
    local mUserinfo = uobjs.getModel('userinfo')
    local hchallenge = uobjs.getModel('hchallenge')
	local lastBuyTime = hchallenge.weets
	local rest = 0
	
	if lastBuyTime < weeTs then
        hchallenge.weets = ts
        hchallenge.refInfo()
	end

    local maxBuyNum = getClosestIndexValue(mUserinfo.vip+1,hChallengeCfg.resetNum) -- 取当前VIP等级下最多可重置次数
    local restNum = hchallenge.checkChallengekNum(sid,'r')
    local restCost = getClosestIndexValue(restNum + 1,hChallengeCfg.resetGems) -- 根据重置数取本次重置消耗
    -- print('restNum',restNum)
    -- print('maxBuyNum',maxBuyNum)
    -- print('restCost',restCost)
    if not maxBuyNum or not restCost then
        response.ret = -102
        return response
    end
    
    if restNum > 0 and restNum > maxBuyNum then -- 购买次数达到上限
        response.ret = -18022
        return response
    end
    
    if not mUserinfo.useGem(restCost) then
        response.ret = -109
        return response
    end
    
    regActionLogs(uid,1,{action=86,item="",value=restCost,params={}})
	
	hchallenge.restNum(sid)
    
    if uobjs.save() then          
        response.ret = 0    
        response.msg = 'Success'
		
		response.data.userinfo = mUserinfo.toArray(true)
		response.data.hchallenge = hchallenge.toArray(true)
    end
    
    return response
end