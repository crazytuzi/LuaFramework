-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-08-30
-- --------------------------------------------------------------------
EscortModel = EscortModel or BaseClass()

function EscortModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function EscortModel:config()
    self.escort_base_info = {}

    self.escort_my_info = {}        -- 我的基础数据
    self.escort_max_info = {}

    self.escort_red_list = {}

    self.is_double_time = false
end

--==============================--
--desc:缓存护送的基础数据
--time:2018-09-03 10:03:31
--@data:
--@return 
--==============================--
function EscortModel:updateEscortBaseInfo(data)
    self.escort_base_info = data
    GlobalEvent:getInstance():Fire(EscortEvent.UpdateEscortBaseEvent)
end

--==============================--
--desc:获取当前的护送列表
--time:2018-09-03 11:50:59
--@return 
--==============================--
function EscortModel:getPlunderList()
    if self.escort_base_info then
        return self.escort_base_info.plunders
    end
    return {}
end

function EscortModel:setDoubleTimes(code)
    self.is_double_time = (code == TRUE)
end

--==============================--
--desc:是都是双倍
--time:2018-09-05 11:22:24
--@return 
--==============================--
function EscortModel:isDoubleTimes()
    return self.is_double_time
end

--==============================--
--desc:我的基础数据
--time:2018-09-03 07:20:52
--@data:
--@return 
--==============================--
function EscortModel:setMyInfo(data)
    local plunder_count = data.plunder_count
    local be_plunder = false
    if self.escort_my_info and self.escort_my_info.plunder_count and self.escort_my_info.plunder_count < plunder_count then
        be_plunder = true
    end
    self.escort_my_info = data 

    local can_awards = (data.status==1 and data.end_time <= GameNet:getInstance():getTime())
    local have_times = (self:getMyCount(EscortConst.times_type.escort) < self:getMyMaxCount(EscortConst.times_type.escort) and data.status==0)

    -- 红点状态
    self.escort_red_list[RedPointType.escort] = have_times 
    self.escort_red_list[RedPointType.escort_awards] = can_awards 
    self.escort_red_list[RedPointType.escort_plunder] = be_plunder 

        
    -- 场景红点
    GlobalEvent:getInstance():Fire(EscortEvent.UpdateEscortMyInfoEvent) 
end

--==============================--
--desc:我的自身数据
--time:2018-09-04 10:31:07
--@return 
--==============================--
function EscortModel:getMyInfo()
    return self.escort_my_info
end

--==============================--
--desc:判断红点状态
--time:2018-09-06 03:34:01
--@type:
--@return 
--==============================--
function EscortModel:checkRedStatus(type)
    if self.escort_red_list then
        if type == nil then
            for k,v in pairs(self.escort_red_list) do
                if v == true then
                    return true
                end
            end
        else
            for k,v in pairs(self.escort_red_list) do
                if k == type then
                    return v
                end
            end
        end
    end
    return false
end

--==============================--
--desc:设置一些红点状态
--time:2018-09-06 03:54:54
--@bid:
--@status:
--@return 
--==============================--
function EscortModel:updateEscortRedStatus(bid, status)
	local _status = self.escort_red_list[bid]
	if _status == status then return end
	
	self.escort_red_list[bid] = status
	
	-- 更新场景红点状态
end


function EscortModel:getMyCount(type)
    if self.escort_my_info == nil or self.escort_my_info.datas == nil then return 0 end
    for i,v in ipairs(self.escort_my_info.datas) do
        if v.id == type then
            return v.val
        end
    end
    return 0
end

--==============================--
--desc:获取配置表里面的一些配置上线
--time:2018-09-05 08:54:12
--@type:
--@return 
--==============================---
function EscortModel:getMyMaxCount(type)
    if self.escort_max_info[type] then
        return self.escort_max_info[type]
    end
    local config = nil
    if type == EscortConst.times_type.escort then                   -- 每日护送上线
        config = Config.EscortData.data_const.escort_time 
    elseif type == EscortConst.times_type.plunder then              -- 每日掠夺上限
        config = Config.EscortData.data_const.plunder_time  
    elseif type == EscortConst.times_type.atk_back then             -- 每日复仇上限
        config = Config.EscortData.data_const.revenge_time  
    elseif type == EscortConst.times_type.help then                 -- 每日求助上限
        config = Config.EscortData.data_const.request_time  
    elseif type == EscortConst.times_type.do_help then              -- 每日帮助上限
        config = Config.EscortData.data_const.help_time  
    elseif type == EscortConst.times_type.refresh then              -- 每日免费次数上限
        config = Config.EscortData.data_const.free_refresh_time 
    else
        return 0
    end
    if config then
        self.escort_max_info[type] = config.val
        return config.val
    end
end

function EscortModel:__delete()
end
