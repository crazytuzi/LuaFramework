-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WelfareModel = WelfareModel or BaseClass()

function WelfareModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function WelfareModel:config()
	self.daily_award_status = 1 -- 每日礼状态
end

--保存下月卡信息
function WelfareModel:setYueka(data)
	self.yueka_data = data 
end

function WelfareModel:getYueka()
	return self.yueka_data
end

--保存下今日充值次数
function WelfareModel:setRechargeCount( count )
	self.recharge_num = count
end

function WelfareModel:checkWelfareSubIsOpen(id)
	local config = Config.HolidayClientData.data_info[id]
	if config then
		local role_vo = RoleController:getInstance():getRoleVo()
		if not MAKELIFEBETTER or (MAKELIFEBETTER == true and config.is_verifyios == TRUE) then
			local status = MainuiController:getInstance():checkIsOpenByActivate(config.open_lev)
			if status == true then
				return true
			end
		end
	end
	return false
end 

--==============================--
--desc:判断月卡状态
--time:2018-09-11 09:27:55
--@return 
--==============================--
function WelfareModel:getYuekaStatus()
	local can_charge = true
	if not self:checkWelfareSubIsOpen(WelfareIcon.yueka) then 
		can_charge = false
	else
		if self.yueka_data == nil then
			can_charge = true
		else
			local cur_time = GameNet:getInstance():getTime()
			if self.yueka_data.card1_end_time and self.yueka_data.card2_end_time then
				can_charge = (self.yueka_data.card1_end_time<cur_time) or (self.yueka_data.card2_end_time < cur_time)
			end
		end
	end
	return can_charge
end

function WelfareModel:getRechargeCount( )
	return self.recharge_num or 0
end

--问卷调查
function WelfareModel:setQuestOpenData(data)
	self.questOpenData = data
end
function WelfareModel:getQuestOpenData()
	return self.questOpenData or {}
end

-- 每日礼领取状态
function WelfareModel:setDailyAwardStatus( status )
	self.daily_award_status = status

	if status == 0 then
		VipController:getInstance():setTipsGiftStatus(VIPREDPOINT.DAILY_AWARD, true)
	else
		VipController:getInstance():setTipsGiftStatus(VIPREDPOINT.DAILY_AWARD, false)
	end
end
function WelfareModel:getDailyAwardStatus(  )
	return self.daily_award_status
end

-- 每日礼包红点(有新礼包显示)
function WelfareModel:updateDailyGiftRedStatus( status )
	self.new_daily_award_red = status
	if status == true or self.daily_award_status == 0 then
		VipController:getInstance():setTipsGiftStatus(VIPREDPOINT.DAILY_AWARD, true)
	else
		VipController:getInstance():setTipsGiftStatus(VIPREDPOINT.DAILY_AWARD, false)
	end
	GlobalEvent:getInstance():Fire(WelfareEvent.Update_Daily_Gift_Red_Data)
end

-- 每日礼包红点
function WelfareModel:getDailyGiftRedStatus(  )
	if self.new_daily_award_red == true or self.daily_award_status == 0 then
		return true
	end
	return false
end

--1:宝可梦  2:神装
function WelfareModel:setWelfareShopData(index)
	if index == 1 then
		local data = Config.ExchangeData.data_shop_exchage_hero
		self.shop_hero_data = self:getConfigData(data, index)
	elseif index == 2 then
		local data = Config.ExchangeData.data_shop_exchage_cloth
		self.shop_cloth_data = self:getConfigData(data, index)
	end
end
function WelfareModel:getConfigData(data, index)
	if data then
		local list = {}
		local heaven_model = HeavenController:getInstance():getModel()
		for i,v in pairs(data) do
			if index == 1 then
				table.insert(list, v)
			elseif index == 2 then
				local status = heaven_model:checkIsOpenByScore(v.buy_condit)
				if status == true then
					table.insert(list, v)
				end
			end
		end
		table.sort(list, function(a,b) return a.order < b.order end)
		return list
	end
	return nil
end

function WelfareModel:getWelfareShopData(index)
	if index == 1 then
		if self.shop_hero_data then
			return self.shop_hero_data
		end
	elseif index == 2 then
		if self.shop_cloth_data then
			return self.shop_cloth_data
		end
	end
	return nil
end

--周月礼包充值ID
function WelfareModel:setMonthWeekChargeID(id)
	self.charge_id = id
end
function WelfareModel:getMonthWeekChargeID()
	if self.charge_id then
		return self.charge_id
	end
	return nil
end
--周礼包是否开启
function WelfareModel:setIsOpenWeekGift(is_open)
	self.week_is_open = is_open
end
function WelfareModel:getIsOpenWeekGift()
	-- if self.week_is_open then
	-- 	local status = false
	-- 	if self.week_is_open == 1 then
	-- 		status = true
	-- 	end
	-- 	return status
	-- end
	-- return false
	return true
end
function WelfareModel:__delete()
end