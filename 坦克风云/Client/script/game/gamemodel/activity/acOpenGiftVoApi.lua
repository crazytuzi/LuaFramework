acOpenGiftVoApi = {}

function acOpenGiftVoApi:getAcVo()
	return activityVoApi:getActivityVo("openGift")
end

function acOpenGiftVoApi:getAcCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.discountData
	end
	return nil
end

function acOpenGiftVoApi:getBaseGoldNum()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.baseGoldNum
	end
    return 0
end

--今日是否领取水晶
function acOpenGiftVoApi:isTodayReceive()
   if self:getAcVo().t==G_getWeeTs(base.serverTime) then
      --凌晨时间跟当前凌晨时间相同则表示领过 不能领取
      return false
   else
      return true
   end
end

function acOpenGiftVoApi:setIsReceive()
    self:getAcVo().t=G_getWeeTs(base.serverTime)
end

-- 根据id得到折扣礼包的配置
function acOpenGiftVoApi:getCfgById(id)
	local acCfg = self:getAcCfg()
	for k,v in pairs(acCfg) do
		if tonumber(v.id) == tonumber(id) then
			return v
		end
	end
end

-- 根据id获取折扣礼包的已购买个数
function acOpenGiftVoApi:getBuyCountById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		for k,v in pairs(acCfg) do
			if tonumber(v.id) == tonumber(id) then
				return v.buynum
			end
		end
	end
	return 0
end

function acOpenGiftVoApi:addBuyCountById(id)
	local acCfg = self:getAcCfg()
	if acCfg ~= nil then
		for k,v in pairs(acCfg) do
			if tonumber(v.id) == tonumber(id) then
				v.buynum = v.buynum + 1
			end
		end
	end
end

function acOpenGiftVoApi:canReward()
	if acOpenGiftVoApi:isTodayReceive() then
		return true
	end
	return false
end

-- 从前一天过度到后一天时重新获取数据
function acOpenGiftVoApi:refresh()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间
        acVo.refresh = false --是否已刷新过数据
        self:updateDiscountData()
		activityVoApi:updateShowState(acVo)
		acVo.stateChanged = true
	end
end

function acOpenGiftVoApi:updateDiscountData(callback)
	local function callbackBuyprop(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	local acVo = self:getAcVo()
        	if acVo ~= nil then
        		acVo:updateDiscountData(sData.data)
                activityVoApi:updateShowState(acVo)
		        acVo.stateChanged = true
		        if callback ~= nil then
		        	callback()
		        end
		    end
        end

    end
    socketHelper:getOpenGift(callbackBuyprop,1)
end
