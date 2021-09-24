acMysteryBoxVoApi = {}

function acMysteryBoxVoApi:getAcVo()
    return activityVoApi:getActivityVo("smbx")
end

function acMysteryBoxVoApi:getTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return ""
end

function acMysteryBoxVoApi:canReward()
	return false
end

function acMysteryBoxVoApi:getActiveTitle()
	local vo = self:getAcVo()
	if vo and vo.activeTitle then
		return vo.activeTitle
	end
	return ""
end

function acMysteryBoxVoApi:getActiveDesc()
	local vo = self:getAcVo()
	if vo and vo.activeDesc then
		return vo.activeDesc
	end
	return ""
end

function acMysteryBoxVoApi:getShopList()
	local vo = self:getAcVo()
	if vo and vo.shopList then
		table.sort(vo.shopList, function(a, b) return a.index < b.index end)
		return vo.shopList
	end
end

function acMysteryBoxVoApi:getRechargeData(index)
	local vo = self:getAcVo()
	if vo and vo.rewardData then
		return vo.rewardData["t" .. index]
	end
end

function acMysteryBoxVoApi:checkOverDayData()
	local flag = false
	local vo = self:getAcVo()
	-- if vo and vo.shopList and vo.lastTimer and G_getWeeTs(base.serverTime) ~= G_getWeeTs(vo.lastTimer) then
	if vo and vo.shopList then
		for k, v in pairs(vo.shopList) do
			if v.rtype == 1 then --每日重置类型
				local rState, rNum, rTs = 0, 0
				local rData = self:getRechargeData(v.index)
				if rData then
					rState = (rData[1] or 0) --充值状态  默认 0 未充值； 1 已充值； 2 已领取
					rNum = (rData[2] or 0) --领取次数
					rTs = rData[3] --上一次操作的时间戳
				end
				if rState == 2 and rNum >= v.limit and rTs and G_getWeeTs(base.serverTime) ~= G_getWeeTs(rTs) then
					vo.rewardData["t" .. v.index][1] = 0
					vo.rewardData["t" .. v.index][2] = 0
					flag = true
				end
			end
		end
	end
	return flag
end

--领取奖励接口
--@rewardIndex : 奖励索引
function acMysteryBoxVoApi:requestReward(callback, rewardIndex)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.smbx then
        			self:updateData(sData.data.smbx)
        		end
	        	if type(callback) == "function" then
	        		callback()
	        	end
	        end
        end
    end
	socketHelper:acMysteryBoxReward(socketCallback, rewardIndex)
end

function acMysteryBoxVoApi:isCanEnter(isShowTip)
	local vo = self:getAcVo()
	if vo then
		if vo.openLv and vo.openVip then
			local startLv = tonumber(vo.openLv[1]) or 0
			local endLv = tonumber(vo.openLv[2]) or 99999
			local startVip = tonumber(vo.openVip[1]) or 0
			local endVip = tonumber(vo.openVip[2]) or 99999
			local playerLv = playerVoApi:getPlayerLevel()
			local playerVip = playerVoApi:getVipLevel()
			if playerLv >= startLv and playerLv <= endLv and playerVip >= startVip and playerVip <= endVip then
				return true
			end
			if isShowTip then
				local tipStr
				if not (playerLv >= startLv and playerLv <= endLv) then
					tipStr = getlocal("lv_not_enough")
				elseif not (playerVip >= startVip and playerVip <= endVip) then
					tipStr = getlocal("backstage2006")
				end
				if tipStr then
					smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
				end
			end
		end
	end
	return false
end

function acMysteryBoxVoApi:updateData(data)
	if data then
        local vo = self:getAcVo()
        if vo then
        	vo:updateData(data)
        	activityVoApi:updateShowState(vo)
        end
    end
end

function acMysteryBoxVoApi:clearAll()
end
