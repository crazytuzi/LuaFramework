-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-10
-- --------------------------------------------------------------------
MonopolyModel = MonopolyModel or BaseClass()

function MonopolyModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function MonopolyModel:config()
    self.monopoly_is_open = false -- 活动是否开启
    self.customs_data = {} -- 大富翁关卡基础数据(是否解锁、探索值)
    self.monopoly_map_data = {} -- 大富翁关卡场景数据
    self.cur_map_id = 0 -- 当前所在的场景
    self.buff_data = {} -- buff数据
    self.home_look_id = 0 -- 当前家园形象id

    self.wait_show_tips_data = {}  -- 待显示的tips数据
    self.wait_show_award_data = {} -- 待显示的奖励数据
end

-- 设置大富翁基础数据
function MonopolyModel:setMonopolyBaseInfo(data)
    -- 活动开启状态
    if data.flag and data.flag == 1 then
        self.monopoly_is_open = true
    else
        self.monopoly_is_open = false
    end
    -- 活动结束的时间戳
    self.end_time = data.end_time or 0
    -- 关卡基础数据
    self.customs_data = data.stage or {}
end

-- 活动结束时间戳
function MonopolyModel:getMonopolyEndTime()
    return self.end_time or 0
end

-- 关卡基础数据
function MonopolyModel:getMonopolyBaseInfo()
    return self.customs_data
end

-- 根据关卡id获取是否已经解锁
function MonopolyModel:getCustomsIsOpenById(id)
    local is_open = false
    for k, data in pairs(self.customs_data) do
        if data.id == id then
            is_open = (data.lock ~= 1)
            break
        end
    end
    return is_open
end

-- 家园当前形象id
function MonopolyModel:setHomeLookId(look_id)
    self.home_look_id = look_id
end

function MonopolyModel:getHomeLookId()
    return self.home_look_id
end

-- 根据关卡id获取当前个人探索值
function MonopolyModel:getDevelopValById(id)
    local dev_val = 0
    for k, data in pairs(self.customs_data) do
        if data.id == id then
            dev_val = data.develop or 0
            break
        end
    end
    return dev_val
end

-- 根据关卡id更新探索值
function MonopolyModel:updateDevelopValById(id, dev_val)
    for k, data in pairs(self.customs_data) do
        if data.id == id then
            data.develop = dev_val
            break
        end
    end
    GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Dev_Val_Event, id)
end

-- 根据关卡id获取当前公会探索值
function MonopolyModel:getGuildDevelopValById(id)
    local dev_val = 0
    for k, data in pairs(self.customs_data) do
        if data.id == id then
            dev_val = data.guild_develop or 0
            break
        end
    end
    return dev_val
end

-- 根据关卡id更新公会探索值
function MonopolyModel:updateGuildDevelopValById(id, dev_val)
    for k, data in pairs(self.customs_data) do
        if data.id == id then
            data.guild_develop = dev_val
            break
        end
    end
    GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Guild_Dev_Val_Event, id)
end

-- 活动是否开启
function MonopolyModel:checkMonopolyIsOpen()
    return self.monopoly_is_open
end

-- 更新大富翁关卡场景数据
function MonopolyModel:updateMonopolyMapData(data)
    local is_have = false
    for _, m_data in pairs(self.monopoly_map_data) do
        if m_data.id == data.id then
            for key, value in pairs(data) do
                m_data[key] = value
            end
            is_have = true
            break
        end
    end
    if not is_have then
        table.insert(self.monopoly_map_data, data)
    end
end

-- 将某个场景中的当前事件类型变为0
function MonopolyModel:clearMonopolyNowEvtType(id)
    for _, m_data in pairs(self.monopoly_map_data) do
        if m_data.id == id then
            m_data.now_type = 0
            break
        end
    end
    GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Now_Evt_Type_Event, id)
end

-- 更新某个场景中的某个位置的事件类型
function MonopolyModel:updateMonopolyEventType(id, pos, evt_type)
    for _, m_data in pairs(self.monopoly_map_data) do
        if m_data.id == id then
            for k, eData in pairs(m_data.events) do
                if eData.pos == pos then
                    eData.type = evt_type
                    break
                end
            end
            break
        end
    end
    GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Grid_Evt_Type_Event, id, pos, evt_type)
end

-- 根据关卡id获取场景数据
function MonopolyModel:getMonopolyMapDataById(id)
    for _, m_data in pairs(self.monopoly_map_data) do
        if m_data.id == id then
            return m_data
        end
    end
end

-- 设置当前所在的场景id
function MonopolyModel:setCurMonopolyMapId(map_id)
    self.cur_map_id = map_id
end

-- 是否是当前所在场景
function MonopolyModel:checkIsInCurMap(map_id)
    if self.cur_map_id == map_id then
        return true
    end
    return false
end

-- buff数据
function MonopolyModel:updateMonopolyBuffData(data)
    self.buff_data = data or {}
end

function MonopolyModel:getMonopolyBuffData()
    return self.buff_data
end

-- boss击杀数量
function MonopolyModel:updateMonopolyBossNum( data )
    self.boss_num_data = data
end

function MonopolyModel:getMonopolyBossNumData(  )
    return self.boss_num_data or {}
end

-- 圣夜奇境功能是否开启
function MonopolyModel:checkMonopolyIsOpen(not_tips)
    local role_vo = RoleController:getInstance():getRoleVo()
    local open_lv_limit_cfg = Config.MonopolyMapsData.data_const["open_lv_limit"]
    local open_day_limit_cfg = Config.MonopolyMapsData.data_const["open_day_limit"]
    if role_vo and open_lv_limit_cfg and open_day_limit_cfg then
        if role_vo.lev < open_lv_limit_cfg.val then
            if not not_tips then
                message(open_lv_limit_cfg.desc)
            end
            return false
        end
        if role_vo.open_day < open_day_limit_cfg.val then
            if not not_tips then
                message(open_day_limit_cfg.desc)
            end
            return false
        end
        return true
    end
    return false
end

-- 根据类型和阶段随机获取对话内容
function MonopolyModel:getRandomDialogByEvtAndStep(evt_type, step_id)
    if evt_type == MonopolyConst.Event_Type.Dialog then
        if not self.dialog_cfg or next(self.dialog_cfg) == nil then
            self.dialog_cfg = {}
            -- 按照阶段id缓存配置数据
            for k, cfg in pairs(Config.MonopolyMapsData.data_dialog[1] or {}) do
                if not self.dialog_cfg[cfg.step_id or 0] then
                    self.dialog_cfg[cfg.step_id or 0] = {}
                end
                table.insert(self.dialog_cfg[cfg.step_id or 0], cfg)
            end
        end
        local temp_cfg_list = self.dialog_cfg[step_id] or {}
        for k, cfg in pairs(self.dialog_cfg[0] or {}) do
            table.insert(temp_cfg_list, cfg)
        end
        local index = math.random(1, #temp_cfg_list)
        return temp_cfg_list[index]
    elseif evt_type == MonopolyConst.Event_Type.Flag then
        if not self.flag_cfg or next(self.flag_cfg) == nil then
            self.flag_cfg = {}
            -- 按照阶段id缓存配置数据
            for k, cfg in pairs(Config.MonopolyMapsData.data_dialog[2] or {}) do
                if not self.flag_cfg[cfg.step_id or 0] then
                    self.flag_cfg[cfg.step_id or 0] = {}
                end
                table.insert(self.flag_cfg[cfg.step_id or 0], cfg)
            end
        end
        local temp_cfg_list = self.flag_cfg[step_id] or {}
        for k, cfg in pairs(self.flag_cfg[0] or {}) do
            table.insert(temp_cfg_list, cfg)
        end
        local index = math.random(1, #temp_cfg_list)
        return temp_cfg_list[index]
    end
end

-- 添加待显示的tips内容
function MonopolyModel:addWaitShowTipsData(data)
    self.wait_show_tips_data = data or {}
end

function MonopolyModel:getWaitShowTipsData()
    return self.wait_show_tips_data
end

function MonopolyModel:clearWaitShowTipsData()
    self.wait_show_tips_data = {}
end

-- 添加待显示的奖励数据
function MonopolyModel:addWaitShowAwardData(data)
    for _, v in pairs(data) do
        table.insert(self.wait_show_award_data, v)
    end
end

function MonopolyModel:getWaitShowAwardData()
    return self.wait_show_award_data
end

function MonopolyModel:clearWaitShowAwardData()
    self.wait_show_award_data = {}
end

function MonopolyModel:__delete()
end