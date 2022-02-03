-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英段位赛 策划 星宇 后端 
-- <br/>Create: 2019-02-14
-- --------------------------------------------------------------------
ElitematchModel = ElitematchModel or BaseClass()

function ElitematchModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ElitematchModel:config()

    --当前状态 赋值 model.state = data.state
    self.state = nil

    --当前段位
    self.cur_elite_lev = 1
    --当前排名 0表示未上名
    self.cur_elite_rank = 0

    -- 红点
    self.redPoint = true

    --24900协议内容
    self.scdata = nil

    --24905协议内容
    self.scdata24905 = nil
    --战令信息
    self.orderaction_data = nil
    self.orderaction_first_red_status = 0 -- 0：没红点 1：有红点
end

function ElitematchModel:setSCData(scdata)
    if self.scdata == nil then
        self.scdata = scdata
    else
        for k,v in pairs(scdata) do
            if self.scdata[k] then
                self.scdata[k] = v
                if k == "rmb_status" then
                    self:setGiftStatus(v)
                end
            end
        end
    end
end

function ElitematchModel:getSCData(  )
    return self.scdata or {}
end

function ElitematchModel:getEliteLev()
    if not self.scdata then return 1 end
    return self.scdata.lev
end

function ElitematchModel:getEliteRank()
    if not self.scdata then return 0 end
    return self.scdata.rank
end

function ElitematchModel:setRedPoint(redPoint)
    self.redPoint = redPoint

end

--活动总红点
function ElitematchModel:getElitematchTotalRedPoint()
    local is_open = self:checkElitematchIsOpen(true)
    if is_open  then

        --有可以领的红点
        if self:getRewardRedpoint() then
            return true
        end

        --战令红点
        if self:getOrderactionRedpoint() then
            return true
        end

        --未开战不显示
        if self.scdata24905 and self.scdata24905.state == 0 then
            return false
        end
        --匹配次数够了
        if self:getMatchCountRedpoint() then
            return true
        end
        
        
    end
    return false
end

--获取匹配次数红点
function ElitematchModel:getMatchCountRedpoint()
    if not self.scdata then return false end

    if self.scdata.day_combat_count > 0 then
        return true
    end
    return false
end
--获取奖励红点
function ElitematchModel:getRewardRedpoint()
    if not self.scdata then return false end
    for i,v in ipairs(self.scdata.lev_reward) do
        if v.flag == 1 then --可领
            return true
        end
    end
    return false
end

function ElitematchModel:setEliteMatchFightTime(data)
    if self.scdata24905 == nil then
        self.scdata24905 = data
    else
        for k,v in pairs(data) do
            self.scdata24905[k] = v
        end
    end
    if self.scdata24905.end_time ~= 0 then
        if self.time_ticket == nil then
            self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                    self.scdata24905.end_time = self.scdata24905.end_time -1
                    if self.scdata24905.end_time <= 0 then
                        self:clearTimeTicket()
                        ElitematchController:getInstance():sender24905()
                    end
            end,1)
        end
    end
end


function ElitematchModel:clearTimeTicket()
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

--设置更新equip红点的记录
function ElitematchModel:setUpdateRedPoint(bool)
    self.is_redpoint_24900 = bool
    self.is_redpoint_24905 = bool
    self.is_redpoint_orderaction = bool
end

function ElitematchModel:setSCDataBack24900()
    self.is_redpoint_24900 = true
    self:checkRedPoint()
end
function ElitematchModel:setSCDataBack24905()
    self.is_redpoint_24905 = true
    self:checkRedPoint()
end
function ElitematchModel:setSCDataBackOrderaction()
    self.is_redpoint_orderaction = true
    self:checkRedPoint()
end

--need_check --必须检测
function ElitematchModel:checkRedPoint(need_check)
    if (self.is_redpoint_24905 and self.is_redpoint_24900 and self.is_redpoint_orderaction) or need_check == true then
        GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderRedStatus)
        local status, val = self:getElitematchTotalRedPoint()
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.eliteMatch, status = status})
    end
end

-- 精英大赛是否开启
--return 是否开启 , 限制类型 , 如果未开启会返回: 0 表示段位开启未开启 1. 表示 等级不足 2 表示世界等级不足
function ElitematchModel:checkElitematchIsOpen( not_tips )
    if self.scdata and self.scdata.state == 0 then
        if not not_tips then
            message(TI18N("精英段位赛未开启"))
        end
        return false, 0 ,TI18N("精英段位赛未开启")
    end

	-- 个人等级限制
    local role_lv_cfg = Config.ArenaEliteData.data_elite_const["open_person_lev_limit"]
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo and role_lv_cfg and role_vo.lev < role_lv_cfg.val then
        if not not_tips then
            message(role_lv_cfg.desc)
        end
        return false, 1 ,role_lv_cfg.desc
    end
    -- 世界等级限制
    local world_lv_cfg = Config.ArenaEliteData.data_elite_const["open_world_lev_limit"]
    local world_lev = RoleController:getInstance():getModel():getWorldLev()
    if world_lev and world_lv_cfg and world_lev < world_lv_cfg.val then
    	if not not_tips then
    		message(world_lv_cfg.desc)
    	end
        return false, 2 ,world_lv_cfg.desc
    end
    return true
end
--获取赛季
function ElitematchModel:setElitePeriod(period)
    self.elite_period = period
end
function ElitematchModel:getElitePeriod()
    return self.elite_period or 1
end
--获取赛季排行


--获取每天开启精英赛的剩余时间
--return is_open, time 
--如果 is_open = true time 表示剩余结束
--如果 is_open = false time 表示多少秒后开启
function ElitematchModel:getOpenMatchLessTime()
    --开始时间 {12,0,0}
    local open_time_val = Config.ArenaEliteData.data_elite_const["open_time"].val
    --开始持续秒数
    local max_times = Config.ArenaEliteData.data_elite_const["open_times"].val

    local zero_time = TimeTool.getToDayZeroTime()

    local h = open_time_val[1] or 0
    local m = open_time_val[2] or 0
    local s = open_time_val[3] or 0

    local temp_time =  h * 60 * 60 + m * 60 + s
    --开始时间
    local open_time = zero_time + temp_time
    --结束时间
    local end_time = open_time + max_times

    local cur_time = GameNet:getInstance():getTime()
    local is_open = true
    local time = 0 
    if open_time > cur_time then
        is_open = false
        time  = open_time - cur_time
    elseif cur_time > end_time then
        --说明需要过天了
        local tomorrow_time = zero_time + TimeTool.day2s()
        is_open = false
        time  = tomorrow_time - cur_time + temp_time
    else
        is_open = true
        time = end_time - cur_time
    end
    -- return is_open, time
    return true, time
end

--------------------------------战令-----------------------------------
function ElitematchModel:setOrderactionData(data)
    self.orderaction_data = data
    if data then
        self:setGiftStatus(data.rmb_status)
    end
end

--获取当前周期
function ElitematchModel:getCurPeriod()
	if self.orderaction_data and self.orderaction_data.period then
		return self.orderaction_data.period
	end
	return 1
end

--获取特权状态
function ElitematchModel:getGiftStatus()
	if self.rmb_status then
		return self.rmb_status
	end
	return 0
end

function ElitematchModel:getLevShowData(lev)
	if self.orderaction_data and self.orderaction_data.list and self.orderaction_data.list[lev] then
		return self.orderaction_data.list[lev]
	end
	return nil
end

--获取胜场
function ElitematchModel:getWinCounts()
	if self.orderaction_data and self.orderaction_data.win_count then
		return self.orderaction_data.win_count
	end
	return 0
end

function ElitematchModel:getCurDay()
	if self.orderaction_data and self.orderaction_data.cur_day then
		return self.orderaction_data.cur_day
	end
	return 1
end

function ElitematchModel:setOrderactionRedStatus(status)
    self.orderaction_first_red_status = status
end

--设置特权状态
function ElitematchModel:setGiftStatus(status)
	self.rmb_status = status
end

--获取战令红点
function ElitematchModel:getOrderactionRedpoint()
    if self.orderaction_first_red_status == 1 then
        return true
    end

    if not self.orderaction_data then return false end

    local lev_reward_list = Config.ArenaEliteWarOrderData.data_lev_reward_list
    if lev_reward_list and lev_reward_list[self.orderaction_data.period] then
        for i,v in ipairs(lev_reward_list[self.orderaction_data.period]) do --self.orderaction_data.list
            local status = 0
	    	local rmb_status = 0
            local lev_list = self:getLevShowData(v.lev)
            if lev_list then
                status = lev_list.award_status
                rmb_status = lev_list.rmb_award_status
            end
            if v.lev <= self.orderaction_data.lev then
                if status == 0 then --可领
                    return true
                elseif rmb_status == 0 and self.orderaction_data.rmb_status == 1 then --可领
                    return true
                end
            end
        end
    end
    
    return false
end

function ElitematchModel:__delete()
end