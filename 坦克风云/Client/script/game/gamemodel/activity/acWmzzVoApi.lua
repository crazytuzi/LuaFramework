acWmzzVoApi = {
	name=nil,
}

function acWmzzVoApi:setActiveName(name)
	self.name=name
end

function acWmzzVoApi:getActiveName()
	return self.name or "wmzz"
end

function acWmzzVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end


-- 0 未领取  1 领取
function acWmzzVoApi:isDailyFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.c then
		local dailyFree=acVo.activeCfg.dailyFree
		if dailyFree-acVo.c>0 then
			return 0
		else
			return 1
		end
	end
	return 0
end

function acWmzzVoApi:getCostByType(type)
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		if type==1 then
			return acVo.activeCfg.gemCost
		elseif type==2 then
			return acVo.activeCfg.gemCost_10
		else
			return acVo.activeCfg.buyGemCost
		end
	end
	return 9999
end

function acWmzzVoApi:getFragT()
	local acVo=self:getAcVo()
	if acVo then
		return acVo.fragT or {}
	end
	return {}
end

function acWmzzVoApi:getComposeTankID()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local tankId=acVo.activeCfg.tankId
		return tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
	end
end

function acWmzzVoApi:getCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		return acVo.activeCfg
	end
	return {}
end

function acWmzzVoApi:showBattle()
	local acVo=self:getAcVo()
	require "luascript/script/game/scene/tank/tankShowData"
	if acVo and acVo.activeCfg then
		local aid=acVo.activeCfg.tankId
		local report={}--acVo.activeCfg.report
		if  tankShowData and tankShowData[aid] then
			report =  tankShowData[aid]
		end
		local battleStr=report
		local report=G_Json.decode(battleStr)
		local isAttacker=true
		local data={data={report=report},isAttacker=isAttacker,isReport=true}
		battleScene:initData(data)
	end
end

function acWmzzVoApi:canReward(activeName)
	local vo=self:getAcVo(activeName)
	if not vo then
		return false
	end
	if not vo.activeCfg then
		return false
	end
	return false
end

function acWmzzVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acWmzzVoApi:socketWmzz(refreshFunc,action,free,num,part)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			if refreshFunc then
				refreshFunc(sData.data.reward,sData.data.iscrit)
			end
		end
	end
	socketHelper:activityWmzz(callback,action,free,num,part)
end

function acWmzzVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
end

function acWmzzVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acWmzzVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acWmzzVoApi:clearAll()
	self.name=nil
end


