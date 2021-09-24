acNewTechVoApi = {
}

function acNewTechVoApi:getAcVo()
	return activityVoApi:getActivityVo("newTech")
end

function acNewTechVoApi:getTimeStr()
	local vo=self:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	return timeStr
end

function acNewTechVoApi:getAcCfg()
	local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.reward
    end
    return nil
end


function acNewTechVoApi:getTechCfgByTab(tabId)
	local acVo = self:getAcVo()
    if acVo ~= nil then
    	if tabId == 1 and acVo.pa ~= nil then
            return acVo.pa
        elseif tabId == 2 and acVo.pb ~= nil then
        	return acVo.pb
        end
        return {}
    end
    return {}
end


function acNewTechVoApi:getTechNumByTab(tabId)
	local cfg = self:getTechCfgByTab(tabId)
	return SizeOfTable(cfg)
end

-- 判断得到的道具是否是超强道具，用来显示金边框
function acNewTechVoApi:checkIfIsStrong(pid)
	local acVo = self:getAcVo()
    if acVo ~= nil and acVo.pool ~= nil then
    	for k,v in pairs(acVo.pool) do
    		if v == pid then
    			return true
    		end
    	end
    end
    return false
end

function acNewTechVoApi:canReward()
    local cfg = nil
    local pSid = nil -- 需要的道具
    local needNum = 0 -- 需要的道具个数
    local ownNum = 0 -- 拥有的道具数量
    for i=1,2 do
        cfg = self:getTechCfgByTab(i)
        for k,v in pairs(cfg) do
            pSid = v[1] -- 需要的道具
            needNum = v[2] -- 需要的道具个数
            ownNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pSid)))
            if ownNum >= needNum then
                return true
            end
        end
    end
	return false
end

function acNewTechVoApi:afterExchange()
    local vo = self:getAcVo()
    if vo ~= nil then
        activityVoApi:updateShowState(vo)
        vo.stateChanged = true -- 强制更新数据
    end
end


