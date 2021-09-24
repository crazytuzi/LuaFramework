-- desc:将领重生
-- user:chenyunhe
-- 注：将领重生 将领星数不重置

function api_hero_rebirth(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

	if moduleIsEnabled('hero') == 0 then
	    response.ret = -11000
	    return response
	end

    if moduleIsEnabled('herorebirth') == 0 then
	    response.ret = -180
	    return response
	end	

	local uid = request.uid
	local hid = request.params.hid --将领id
	local action = request.params.act or 1 --1预览 2重生
	local costType = request.params.type -- 消耗物品类型 1 道具 2 钻石
	local aname = request.params.aname   -- 活动名称  如果有活动就判断
	

	if not uid or not hid or not table.contains({1,2},action) or  not table.contains({1,2},costType) then
	   response.ret=-102
	   return response
	end

	local uobjs = getUserObjs(uid)
	uobjs.load({"userinfo",'useractive'})
	local mHero = uobjs.getModel('hero')
	local mBag = uobjs.getModel('bag')
	local mUserinfo = uobjs.getModel('userinfo')
	local mEquip= uobjs.getModel('equip')


	local heroinfo=copyTable(mHero.hero[hid]) or {} 
	local equipinfo=copyTable(mEquip.info[hid]) or {}

	if aname and string.len(aname)>0 then
	    -- 活动检测
	    local mUseractive = uobjs.getModel('useractive')
		local activStatus = mUseractive.getActiveStatus(aname)
		if activStatus ~= 1 then
		    response.ret = activStatus
		    return response
		end		
	end

	local flag,r=mHero.rebirth(hid,action)
	--判断是否满足条件
	if flag~=1 then
	    response.ret=flag
	    return response
	end


	if action==1 then
	    response.ret = 0
	    response.data.preview=r
	else
	    --使用道具
	    if costType==1 then
	        local herorebirthCfg = getConfig('herorebirth')
	        local useprop=herorebirthCfg.useItem
	        local usenum=herorebirthCfg.useNum
	        local pid=useprop:split('_')
	        if not mBag.use(pid[2],usenum) then
	            response.ret=-1996
	            return response
	        end

	    --使用钻石
	    else
	        if r.costGems<=0 then
	            response.ret=-102
	            return response
	        end
	        if not mUserinfo.useGem(r.costGems) then
	            response.ret = -109
	            return response
	        end

			if r.costGems>0 then
	        	 regActionLogs(uid,1,{action=176,item="",value=r.costGems,params={}})
	        end	        
	    end
	    
	    --刷新战力
	    regEventBeforeSave(uid,'e1')
	    processEventsBeforeSave()
	    if uobjs.save() then
	        processEventsAfterSave()
	        response.data.reward=r
	        local jsonstr=json.encode(r)
	        local jsonhero=json.encode(heroinfo)
	        local jsonequp=json.encode(equipinfo)
	        writeLog('uid='..uid..'--hid='..hid..'--return='..jsonstr..'--heroinfo='..jsonhero..'--equipinfo='..jsonequp,"herorebirth")
	        response.data.hero =mHero.toArray(true)
	        response.data.equip =mEquip.toArray(true)
	        response.ret = 0
	        response.msg = 'Success'
	    else
	        response.ret=-106  
	    end
	end

	return response    

    
end