acFlashSaleVoApi = {}

function acFlashSaleVoApi:getAcVo()
    return activityVoApi:getActivityVo("xsjx2020")
end

function acFlashSaleVoApi:netRequest(netKey, params, callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.xsjx2020 then
        			self:updateData(sData.data.xsjx2020)

        			--替换前端的配置（因配置过长，所以放在get接口单独返回一下活动奖池的配置）
        			if netKey == "get" and sData.data.xsjx2020.client then
        				local vo = self:getAcVo()
        				if vo and vo.activeCfg then
        					for k,v in pairs(sData.data.xsjx2020.client) do
        						vo.activeCfg[k] = v
        					end
        				end
        			end

        		end
	        	if type(callback) == "function" then
	        		callback(sData.data.xsjx2020 or sData.data)
	        	end
	        end
        end
    end
	socketHelper:sendReq("active.xsjx2020." .. netKey, params, socketCallback)
end

--获取今日名单
function acFlashSaleVoApi:getTodayList()
	local vo = self:getAcVo()
	if vo and vo.st then
		local httpURL = "http://" .. base.serverIp .. "/tank-server/public/index.php/api/active/log"
		local requestParams = string.format("uid=%s&zoneid=%s&activeSt=%s", playerVoApi:getUid(), base.curZoneID, vo.st)
		local responseStr = G_sendHttpRequestPost(httpURL, requestParams)
		if responseStr and responseStr ~= "" then
			print("cjl ------>>> http URL:\n", httpURL .. "?" .. requestParams)
			print("cjl ------>>> http response:\n", responseStr)
			local sData = G_Json.decode(responseStr)
			if sData and sData.ret == 0 then
				return sData.data
			end
		end
	end
end

function acFlashSaleVoApi:canReward()
	if self:isFreeGift() then
		return true
	end
	local curLvGiftData, curLvRewardData = self:getCurLvGiftData()
	if type(curLvGiftData) == "table" then
		for k, v in pairs(curLvGiftData) do
			local rData = self:getRechargeData(v.rechargeId)
			if rData and rData[1] == 1 then
				return true
			end
		end
	end
	return false
end

function acFlashSaleVoApi:getCurLvKey()
	local vo = self:getAcVo()
	if vo and vo.themeReward then
		local playerLv = vo.playerLv or 0
		for k, v in pairs(vo.themeReward) do
			local kStr = Split(k, "_")
			if playerLv >= tonumber(kStr[1]) and playerLv <= tonumber(kStr[2]) then
				return k, v
			end
		end
	end
end

function acFlashSaleVoApi:getGiftName(idx)
	return getlocal("acFlashSale_giftName" .. idx)
end

function acFlashSaleVoApi:getGiftNameByRechargeId(rechargeId)
	local curLvGiftData, curLvRewardData = self:getCurLvGiftData()
	if curLvGiftData then
		for k, v in pairs(curLvGiftData) do
			if v.rechargeId == rechargeId then
				return self:getGiftName(k)
			end
		end
	end
	return ""
end

function acFlashSaleVoApi:getCurLvGiftData()
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		local curLvKey, lvData = self:getCurLvKey()
		if curLvKey then
			return vo.activeCfg[curLvKey], lvData
		end
	end
end

--判断是否可以赠送
function acFlashSaleVoApi:isCanGiveOut(rechargeId)
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		return (vo.activeCfg.sendId == rechargeId)
	end
	return false
end

--获取每日可赠送次数
function acFlashSaleVoApi:getGiveNum()
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		return (vo.activeCfg.num or 0)
	end
	return 0
end

function acFlashSaleVoApi:getRechargeData(rechargeId)
	local vo = self:getAcVo()
	if vo and vo.creward then
		return vo.creward[tostring(rechargeId)]
	end
end

--是否可以领取免费礼包
function acFlashSaleVoApi:isFreeGift()
	local vo = self:getAcVo()
	if vo and vo.free then
		if vo.free[1] == 1 then --已领取
			if base.serverTime - G_getWeeTs(base.serverTime) < acFlashSaleVoApi:getOverDayDelayTime() then
				return false
			else
				return G_getWeeTs(vo.free[2]) ~= G_getWeeTs(base.serverTime) --跨天了
			end
		end
	end
	return true
end

--免费礼包的限制等级
function acFlashSaleVoApi:freeLimitLv()
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		return (vo.activeCfg.Lv or 0)
	end
	return 0
end

--是否为领奖时间(活动最后一天)
function acFlashSaleVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo and vo.et then
		return base.serverTime > (vo.et - 86400)
	end
	return false
end

--获取跨天刷新的延迟时间
function acFlashSaleVoApi:getOverDayDelayTime()
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.nd then
		return vo.activeCfg.nd
	end
	return 1
end

function acFlashSaleVoApi:showRecordSmallDialog(layerNum, logData)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acFlashSaleSmallDialog"
	acFlashSaleSmallDialog:showRecord(layerNum, getlocal("buyLogTitle"), logData)
end

function acFlashSaleVoApi:showPreviewSmallDialog(layerNum, rewardTb, bdNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acFlashSaleSmallDialog"
	acFlashSaleSmallDialog:showPreviewReward(layerNum, getlocal("acFlashSale_previewAllText"), rewardTb, bdNum)
end

function acFlashSaleVoApi:showFriendListSmallDialog(layerNum, paramsTb)
	acFlashSaleVoApi:netRequest("friendlist", {}, function(data)
		local friendTb
		if data then
			friendTb = data.flist
			require "luascript/script/game/scene/gamedialog/activityAndNote/acFlashSaleSmallDialog"
			acFlashSaleSmallDialog:showFriendList(layerNum, getlocal("activity_peijianhuzeng_selectFriend"), friendTb, paramsTb)
		end
	end)
end

function acFlashSaleVoApi:showTodayListDetailsSmallDialog(layerNum, listData)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acFlashSaleSmallDialog"
	acFlashSaleSmallDialog:showTodayListDetails(layerNum, listData)
end

--是否需要替换配置
function acFlashSaleVoApi:isChangeCfg()
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.key then
		return vo.activeCfg.key[1] ~= vo.activeCfg.key[2]
	end
	return false
end

function acFlashSaleVoApi:updateData(data)
	if data then
        local vo = self:getAcVo()
        if vo then
        	vo:updateData(data)
        	activityVoApi:updateShowState(vo)
        end
    end
end

function acFlashSaleVoApi:clearAll()
end