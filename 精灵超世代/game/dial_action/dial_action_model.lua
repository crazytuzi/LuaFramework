-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: htp
-- @editor: htp
-- @description:
--      转盘活动
-- <br/>Create: 2019-03-22
-- --------------------------------------------------------------------
DialActionModel = DialActionModel or BaseClass()

function DialActionModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function DialActionModel:config()
	self.dial_data = {}
	self.myself_record_data = {}
	self.all_record_data = {}
	self.no_ani_flag = false -- 跳过动画的标识
	self.remind_flag = true  -- 点击抽奖时是否弹窗提醒
	self.award_red_status = false -- 积分奖励红点
end

-- 设置转盘数据
function DialActionModel:setDialData( data )
	self.dial_data = data
	self:checkDialAwardRedStatus()
end

-- 获取转盘数据
function DialActionModel:getDialData(  )
	return self.dial_data
end

-- 获取转盘数据中的等级
function DialActionModel:getDialHolidayLv(  )
	if self.dial_data then
		return self.dial_data.holiday_lev
	end
	return 1
end

-- 更新奖池数值
function DialActionModel:updateDialGoldNum( num )
	if self.dial_data then
		self.dial_data.gold = num
	end
end

-- 获取奖池数值
function DialActionModel:getDialGoldNum(  )
	if self.dial_data then
		return self.dial_data.gold
	end
	return 0
end

-- 获取转盘积分数据
function DialActionModel:getDialScore(  )
	if self.dial_data then
		return self.dial_data.num
	end
	return 0
end

-- 获取转盘积分奖励数据
function DialActionModel:getDialAwardData(  )
	if self.dial_data then
		return self.dial_data.award_list or {}
	end
	return {}
end

-- 是否跳过动画
function DialActionModel:setIsNoAniFlag( status )
	self.no_ani_flag = status
end

function DialActionModel:getIsNoAniFlag(  )
	return self.no_ani_flag
end

-- 是否弹窗提醒
function DialActionModel:setRemindFlag( status )
	self.remind_flag = status
end

function DialActionModel:getRemindFlag(  )
	return self.remind_flag
end

-- 个人转盘记录
function DialActionModel:setMyselfDialRecordData( data )
	self.myself_record_data = data
end

function DialActionModel:getMyselfDialRecordData(  )
	return self.myself_record_data
end

-- 全服转盘记录
function DialActionModel:setAllDialRecordData( data )
	self.all_record_data = data
end

function DialActionModel:getAllDialRecordData(  )
	return self.all_record_data
end

-- 转盘活动剩余时间
function DialActionModel:checkDialAwardRedStatus(  )
	local red_status = false
	if self.dial_data then
		for k,v in pairs(self.dial_data.award_list) do
			if v.status == 1 then
				red_status = true
				break
			end
		end
	end
	self.award_red_status = red_status
end

function DialActionModel:getDialAwardResStatus(  )
	return self.award_red_status
end

function DialActionModel:__delete()
end