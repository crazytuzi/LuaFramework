-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: htp
-- @editor: htp
-- @description:
--      转盘活动
-- <br/>Create: 2019-03-22
-- --------------------------------------------------------------------
DialActionController = DialActionController or BaseClass(BaseController)

function DialActionController:config()
    self.model = DialActionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function DialActionController:getModel()
    return self.model
end

function DialActionController:registerEvents()
end

------------------@ c2s
-- 请求转盘数据
function DialActionController:sender16670(  )
    self:SendProtocal(16670, {})
end

-- 请求转盘抽奖
function DialActionController:sender16671( count, flag )
	local protocal = {}
	protocal.count = count
	protocal.flag = flag
    self:SendProtocal(16671, protocal)
end

-- 告知后端动画播放完毕
function DialActionController:sender16672(  )
	self:SendProtocal(16672, {})
end

-- 请求领取积分奖励
function DialActionController:sender16673( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(16673, protocal)
end

-- 请求转盘日志
function DialActionController:sender16674( type )
	local protocal = {}
	protocal.type = type
    self:SendProtocal(16674, protocal)
end

-- 请求购买次数
function DialActionController:sender16675( num )
	local protocal = {}
	protocal.num = num
    self:SendProtocal(16675, protocal)
end

----------------------@ s2c
function DialActionController:registerProtocals()
	self:RegisterProtocal(16670, "handle16670")     -- 转盘数据
	self:RegisterProtocal(16671, "handle16671")     -- 抽奖返回
	self:RegisterProtocal(16672, "handle16672")     -- 奖励数据
	self:RegisterProtocal(16673, "handle16673")     -- 领取积分奖励
	self:RegisterProtocal(16674, "handle16674")     -- 转盘日志
	self:RegisterProtocal(16675, "handle16675")     -- 购买次数
	self:RegisterProtocal(16676, "handle16676")     -- 购买次数
end

-- 转盘数据
function DialActionController:handle16670( data )
	if data then
		self.model:setDialData(data)
		GlobalEvent:getInstance():Fire(DialActionEvent.Update_Dial_Data_Event, data)
	end
end

-- 抽奖结果
function DialActionController:handle16671( data )
	if data then
		message(data.msg)
		if data.result == TRUE and data.flag == 0 then -- 设置为播放动画时才分发事件
			GlobalEvent:getInstance():Fire(DialActionEvent.Update_Dial_Result_Event, data.id)
		end
	end
end

-- 奖励数据
function DialActionController:handle16672( data )
	if data then
		ActionController:getInstance():openTreasureGetItemWindow(true, data.awards2, data.count, 3)
	end
end

-- 领取积分奖励
function DialActionController:handle16673( data )
	if data then
		message(data.msg)
	end
end

-- 转盘日志
function DialActionController:handle16674( data )
	if data then
		if data.type == 1 then -- 个人
			self.model:setMyselfDialRecordData(data.log_list)
		elseif data.type == 2 then -- 全服
			self.model:setAllDialRecordData(data.log_list)
		end
		GlobalEvent:getInstance():Fire(DialActionEvent.Update_Dial_Record_Event, data.type)
	end
end

-- 购买次数
function DialActionController:handle16675( data )
	if data then
		message(data.msg)
	end
end

-- 更新奖池数值
function DialActionController:handle16676( data )
	if data then
		self.model:updateDialGoldNum(data.gold)
		GlobalEvent:getInstance():Fire(DialActionEvent.Update_Dial_Gold_Event)
	end
end

--------------------------@ 界面相关
-- 获奖记录界面
function DialActionController:openDialRecordWindow( status )
	if status == true then
		if self.dial_record_wnd == nil then
			self.dial_record_wnd = DialRecordWindow.New()
		end
		if self.dial_record_wnd:isOpen() == false then
			self.dial_record_wnd:open()
		end
	else
		if self.dial_record_wnd then
			self.dial_record_wnd:close()
			self.dial_record_wnd = nil
		end
	end
end

-- 积分奖励
function DialActionController:openDialAwardWindow( status )
	if status == true then
		if self.dial_award_wnd == nil then
			self.dial_award_wnd = DialAwardWindow.New()
		end
		if self.dial_award_wnd:isOpen() == false then
			self.dial_award_wnd:open()
		end
	else
		if self.dial_award_wnd then
			self.dial_award_wnd:close()
			self.dial_award_wnd = nil
		end
	end
end

function DialActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end