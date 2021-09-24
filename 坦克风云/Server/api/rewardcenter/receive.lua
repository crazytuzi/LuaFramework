-- 领取系统奖励
function api_rewardcenter_receive(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
	
	local ts = getClientTs()
    local uid = request.uid
    local ids = request.params.ids or {"gm.1436261975.1000001"}
	
    if uid == nil or not ids or type(ids) ~= 'table' then
        response.ret = -102
        return response
    end
	
	if #ids <= 0 or #ids > 20 then
		response.ret = -102
        return response
	end
	
	if moduleIsEnabled('rewardcenter') == 0 then
		response.ret = -314
        return response
	end
	
	require "lib.rewardcenter"

	local db = getDbo()
	db.conn:setautocommit(false)
	
	local uobjs = getUserObjs(uid)
	uobjs.load({"userinfo","troops", "props","bag","accessory","hero"})
	local rewardcenter = model_rewardcenter()
	local list = rewardcenter.getReward(ids)
	local success = {} -- 成功的条目
	local fail = {} -- 失败的条目
	local rtype=nil
	for i,v in pairs(list) do
		if v.id and v.st and v.et and ts >= tonumber(v.st) and ts <= tonumber(v.et) then
			if tonumber(v.uid) == tonumber(uid) then
				local reward = json.decode(v.reward) or {}
				local status = rewardcenter.receiveReward(v.id,uid) -- 领取标记
				
				if status then
					local ret = takeReward(uid,reward)
					if ret then 
						table.insert(success,v.id)
					else -- 领奖错误
						db.conn:rollback()
						response.ret = -403 
						return response
					end
				else -- 没有该记录 or 已经领取过
					table.insert(fail,v.id)
					--table.insert(fail,{v.id,1})
				end
			else -- 所属权错误
				table.insert(fail,v.id) 
				--table.insert(fail,{v.id,2}) 
			end
		else -- 过期
			table.insert(fail,v.id) 
			--table.insert(fail,{v.id,3}) 
		end
        if v.type=='aw' or v.type=='usw' or v.type=='mi' then
            rtype=1
        end
	end
	
	response.data.success = success
	response.data.fail = fail

    if uobjs.save() then
		if db.conn:commit() then
			response.ret = 0
		end
        
        local mUserinfo = uobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local mBag = uobjs.getModel('bag')
        local mTroop = uobjs.getModel('troops')
        local mAccessory = uobjs.getModel('accessory')
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.hero = mHero.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.troops = mTroop.toArray(true)
        if rtype==1 then
            response.data.accessory = mAccessory.toArray(true)
        end
    end

	return response
end
