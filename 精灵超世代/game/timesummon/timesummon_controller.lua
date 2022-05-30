-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-02-20
-- --------------------------------------------------------------------
TimesummonController = TimesummonController or BaseClass(BaseController)

BattlePreviewParm = {    --宝可梦预览发送参数
    FirstCharge  = 1,     --超值首充（耶梦加）
	RecruitHero  = 2,     --风王降临
	ReturnActionSummon  = 3,     --回归抽奖
	FirstCharge2  = 4,     --超值首充（利维坦）
}

function TimesummonController:config()
    self.model = TimesummonModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function TimesummonController:getModel()
    return self.model
end

function TimesummonController:registerEvents()
end

------------------@ c2s
-- 请求限时召唤数据
function TimesummonController:requestTimeSummonData(  )
	local protocal = {}
    self:SendProtocal(23216, protocal)
end

-- 请求限时召唤
function TimesummonController:requestTimeSummon( times, recruit_type )
	local protocal = {}
	protocal.times = times
	protocal.recruit_type = recruit_type
    self:SendProtocal(23217, protocal)
end

-- 请求领取礼包
function TimesummonController:requestSummonGetAward(  )
	local protocal = {}
    self:SendProtocal(23218, protocal)
end

-- 请求宝可梦试玩(参数为1是超值首充，2是风王降临，其他发活动bid)
function TimesummonController:send23219( bid )
	local protocal = {}
	protocal.bid = bid
    self:SendProtocal(23219, protocal)
end

------------------@ s2c
function TimesummonController:registerProtocals()
	self:RegisterProtocal(23216, "handle23216")     -- 限时召唤数据
	self:RegisterProtocal(23217, "handle23217")     -- 限时召唤
	self:RegisterProtocal(23218, "handle23218")     -- 领取保底礼包
	self:RegisterProtocal(23219, "handle23219")     -- 请求宝可梦试玩

	self:RegisterProtocal(26521, "handle26521")     -- 精灵召唤数据
	self:RegisterProtocal(26522, "handle26522")     -- 精灵召唤
	self:RegisterProtocal(26523, "handle26523")     -- 领取保底礼包
	self:RegisterProtocal(26525, "handle26525")     -- 精灵抽奖结果

	
end

-- 限时召唤数据
function TimesummonController:handle23216( data )
	if data then
		GlobalEvent:getInstance():Fire(TimesummonEvent.Update_Summon_Data_Event, data)
	end
end

-- 限时召唤获得
function TimesummonController:handle23217( data )
	message(data.msg)
end

-- 领取保底礼包
function TimesummonController:handle23218( data )
	message(data.msg)
end

-- 宝可梦试玩
function TimesummonController:handle23219( data )
	message(data.msg)
	if data.flag == FALSE then
		BattleController:getInstance():csFightExit()
	end
end

------------------------@ 界面相关
-- 打开奖励预览 text_elite:内容描述类型
function TimesummonController:openTimeSummonAwardView( status, group_id, data,text_elite )
	if status == true then
		if self.summon_award_view == nil then
			self.summon_award_view = TimeSummonAwardView.New()
		end
		if self.summon_award_view:isOpen() == false then
			self.summon_award_view:open(group_id, data,text_elite)
		end
	else
		if self.summon_award_view then
			self.summon_award_view:close()
			self.summon_award_view = nil
		end
	end
end

-- 打开奖励进度
function TimesummonController:openTimeSummonProgressView( status, times, camp_id, up_hero_id, reward_list)
	if status == true then
		if self.summon_progress_view == nil then
			self.summon_progress_view = TimeSummonProgressView.New()
		end
		if self.summon_progress_view:isOpen() == false then
			self.summon_progress_view:open(times, camp_id, up_hero_id, reward_list)
		end
	else
		if self.summon_progress_view then
			self.summon_progress_view:close()
			self.summon_progress_view = nil
		end
	end
end

function TimesummonController:openTimeSummonpreviewWindow( status,index,bool)
	if status == true then
		if self.SummonpreviewWindow == nil then
			self.SummonpreviewWindow = TimeSummonPreviewWindow.New()
		end
		if self.SummonpreviewWindow:isOpen() == false then
			self.SummonpreviewWindow:open(index,bool)
		end
	else
		if self.SummonpreviewWindow then
			self.SummonpreviewWindow:close()
			self.SummonpreviewWindow = nil
		end
	end
end


------------------------------------精灵召唤协议------------------------------------
-- 请求精灵召唤数据
function TimesummonController:send26521(  )
	local protocal = {}
    self:SendProtocal(26521, protocal)
end

-- 精灵召唤数据
function TimesummonController:handle26521( data )
	if data then
		GlobalEvent:getInstance():Fire(TimesummonEvent.Update_Elfin_Summon_Data_Event, data)
	end
end


-- 请求精灵召唤
function TimesummonController:send26522( times, recruit_type ,is_return_gain)
	self.is_return_gain = is_return_gain	
	local protocal = {}
	protocal.times = times
	protocal.recruit_type = recruit_type
    self:SendProtocal(26522, protocal)
end

-- 精灵召唤获得
function TimesummonController:handle26522( data )
	message(data.msg)
end

-- 请求领取礼包
function TimesummonController:send26523( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(26523, protocal)
end

-- 领取保底礼包
function TimesummonController:handle26523( data )
	message(data.msg)
end

-- 精灵抽奖结果
function TimesummonController:handle26525( data )

	if self.is_return_gain == true then
		self:openActionTimeElfinSummonGainWindow(false)
		self:openActionTimeElfinSummonGainWindow(true,data,TRUE)
		GlobalEvent:getInstance():Fire(TimesummonEvent.Update_Elfin_Item_Event, data)
	else
		GlobalEvent:getInstance():Fire(TimesummonEvent.Update_Elfin_Summon_Rewards_Data_Event, data)
	end
	self.is_return_gain = false	
end

--召唤获得界面
function TimesummonController:openActionTimeElfinSummonGainWindow(status,data,is_call,elfin_summon_type)
    if status == false then
        if self.action_time_elfin_summon_gain_window ~= nil then
            self.action_time_elfin_summon_gain_window:close()
            self.action_time_elfin_summon_gain_window = nil
        end
    else
        if self.action_time_elfin_summon_gain_window == nil then
            self.action_time_elfin_summon_gain_window = ActionTimeElfinSummonGainWindow.New(is_call)
        end
        if self.action_time_elfin_summon_gain_window:isOpen() == false then
            self.action_time_elfin_summon_gain_window:open(data,is_call,elfin_summon_type)
        end
    end
end
-----------------------------------------------------------------------------------

--打开自选宝可梦
function TimesummonController:openHeroSelectView(status, data, cur_times)
    if status == false then
        if self.hero_select_view ~= nil then
            self.hero_select_view:close()
            self.hero_select_view = nil
        end
    else
        if self.hero_select_view == nil then
            self.hero_select_view = HeroSelectPanel.New()
        end
        if self.hero_select_view:isOpen() == false then
            self.hero_select_view:open(data, cur_times)
        end
    end
end


function TimesummonController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end