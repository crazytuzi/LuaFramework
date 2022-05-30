-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼数据控制
-- <br/>Create: 2018-08-15
-- --------------------------------------------------------------------
Endless_trailModel = Endless_trailModel or BaseClass()

function Endless_trailModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function Endless_trailModel:config()
    self.role_rank_list = {}
    -- self.first_item_list = {}
    -- self.five_item_list = {}
    -- self.rank_item_list = {}
    self.endless_data = {}
    self.first_data = {}
    self.send_partner = {}
    self.hire_partner_list = {}
    self.has_hire_partner_list = {} --已雇佣的
    self.is_first_get = {}
    self.is_award_get = false
    self.is_award_get_new = false
    
    self.is_send_partner = false
    self.endless_battle_data = nil
    -- self:getFirstKindList()
    -- self:getFiveKindList()
    -- self:getRankKindList()
end

--[[
    @desc: 设置无尽试炼基础信息
    author:{author}
    time:2018-08-20 11:56:42
    --@data: 
    @return:
]]
function Endless_trailModel:setEndlessData(data)
    if data then
        if data.type == 0 then
            data.day_pass_round = 0
            data.new_day_pass_round = 0
            data.is_reward = 0
        end
        self.endless_data = data
        self:checkRedPoint()
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_BASE_DATA)
    end
end

--[[
    @desc: 获取无尽试炼基础信息
    author:{author}
    time:2018-08-20 11:56:42
    --@data: 
    @return:
]]

function Endless_trailModel:getEndlessData()
    if  self.endless_data and next(self.endless_data or {}) ~= nil   then
        return  self.endless_data 
    end
end

--刷新排行榜信息
function Endless_trailModel:updateRankInfo(data)
    if data and self.endless_data and next(self.endless_data or {}) ~= nil then
        if self.endless_data.type == Endless_trailEvent.endless_type.old then
            self.endless_data.my_idx = data.my_idx
            self.endless_data.rank_list = data.rank_list
        elseif self.endless_data.type ~= 0 then
            self.endless_data.new_my_idx = data.my_idx
            self.endless_data.new_rank_list = data.rank_list
        end
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_RANK_DATA)
    end
end

--[[
    @desc: 设置首通奖励展示
    author:{author}
    time:2018-08-20 11:58:06
    --@data: 
    @return:
]]
function Endless_trailModel:setFirstData(data)
    if data then
        self.first_data[data.type] = data
        self:checkRedPoint()
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_FIRST_DATA)
    end
end

function Endless_trailModel:setFirstStatus(data)
    if data then
        self.first_status = data
        self:checkRedPoint()
    end
end

--[[
    @desc: 获取首通奖励
    author:{author}
    time:2018-08-20 11:58:20
    --@data: 
    @return:
]]
function Endless_trailModel:getFirstData(type)
    if self.first_data and next(self.first_data or {}) ~= nil  then
        return self.first_data[type] 
    end
end

--[[
    @desc: 已派遣的伙伴信息
    author:{author}
    time:2018-08-20 14:42:39
    --@data: 
    @return:
]]
function Endless_trailModel:setSendPartnerData(data)
   self.send_partner = data
   GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_SENDPARTNER_DATA, data)
   self:checkRedPoint()
end

function Endless_trailModel:getSendPartnerData()
    if self.send_partner and next(self.send_partner or {}) ~= nil then
        return self.send_partner
    end
end

--[[
    @desc: 可雇佣伙伴的信息
    author:{author}
    time:2018-08-20 15:27:20
    --@data: 
    @return:
]]
function Endless_trailModel:setHirePartnerData(data)
    self.hire_partner_list = data
    GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_HIREPARNER_DATA, data)
end

function Endless_trailModel:getHirePartnerData()
    if self.hire_partner_list and next(self.hire_partner_list or {}) ~= nil then
        return self.hire_partner_list
    end
end

--[[
    @desc: 已雇佣的伙伴列表
    author:{author}
    time:2018-08-20 17:57:28
    @return:
]]
function Endless_trailModel:setHasHirePartnerData(data)
    self.has_hire_partner_list = data
    GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_HASHIREPARNER_DATA, data)
end

function Endless_trailModel:getHasHirePartnerData()
    if self.has_hire_partner_list and next(self.has_hire_partner_list or {}) ~= nil then
        return self.has_hire_partner_list
    end
end


function Endless_trailModel:setEndlessBattleData(data)
    self.endless_battle_data = data
    GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_ENDLESSBATTLE_DATA, data)
end

function Endless_trailModel:getEndlessBattleData()
    if self.endless_battle_data then
        return self.endless_battle_data
    end
end

--获取前三个
function Endless_trailModel:getRaknRoleTopThreeList(type)
    local list = {{rank = 1, name = TI18N("虚位以待")}, {rank = 2, name = TI18N("虚位以待")}, {rank = 3, name = TI18N("虚位以待")}}
    local rank_list = self.endless_data.new_rank_list
    if type == Endless_trailEvent.endless_type.old then
        rank_list = self.endless_data.rank_list
    end
    
    if rank_list and next(rank_list or {}) ~= nil then
        for i, v in ipairs(rank_list) do
            for i2, v1 in ipairs(list) do
                if v.idx == v1.rank then
                    list[i2] = v
                end
            end
        end
    end
    return list
end

--获取首通奖励种类
-- function Endless_trailModel:getFirstKindList()
--     if next(self.first_item_list or {}) == nil then
--         if Config.EndlessData.data_first_data then
--             local temp_id = 0
--             for i,v in ipairs(Config.EndlessData.data_first_data) do
--                 local items = v.items
--                 for i1,v1 in ipairs(items) do
--                     local bid = v1[1]
--                     if not self:is_include(bid,self.first_item_list) then
--                         table.insert(self.first_item_list,{bid = bid})
--                     end
--                  end
--             end
--         end
--     end
-- end

-- function Endless_trailModel:getFirstList( ... )
--     if self.first_item_list then
--         return self.first_item_list
--     end
-- end

--获取5次的奖励
-- function Endless_trailModel:getFiveKindList()
--     if next(self.five_item_list or {}) == nil then
--         if Config.EndlessData.data_floor_data then
--             local temp_id = 0
--             for i, v in pairs(Config.EndlessData.data_floor_data) do
--                 local items = v.items
--                 for i1, v1 in ipairs(items) do
--                     local bid = v1[1]
--                     if not self:is_include(bid, self.five_item_list) then
--                         table.insert(self.five_item_list, {bid = bid})
--                     end
--                 end
--             end
--         end
--     end
-- end

-- function Endless_trailModel:getFiveList(...)
--     if self.five_item_list then
--         return self.five_item_list
--     end
-- end

--排行种类获取
-- function Endless_trailModel:getRankKindList()
--     if next(self.rank_item_list or {}) == nil then
--         if Config.EndlessData.data_rank_reward_data then
--             local temp_id = 0
--             for i, v in pairs(Config.EndlessData.data_rank_reward_data) do
--                 local items = v.items
--                 for i1, v1 in ipairs(items) do
--                     local bid = v1[1]
--                     if not self:is_include(bid, self.rank_item_list) then
--                         table.insert(self.rank_item_list, {bid = bid})
--                     end
--                 end
--             end
--         end
--     end
-- end

--红点判断
function Endless_trailModel:checkRedPoint()
    local is_open = MainuiController:getInstance():checkMainFunctionOpenStatus(MainuiConst.btn_index.esecsice, MainuiConst.function_type.main, true)
    if is_open == false then return false end
    
    --先判断首通奖励是否领取
    if self.first_data and next(self.first_data or {}) ~= nil then
        for k,v in pairs(self.first_data) do
            if v.status == 1 then
                if k == Endless_trailEvent.endless_type.old then
                    self.is_first_get[k] = true
                elseif self.ctrl:checkNewEndLessIsOpen() == true then
                    self.is_first_get[k] = true
                else
                    self.is_first_get[k] = false
                end
            else
                self.is_first_get[k] = false
            end
        end
       
       GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_REDPOINT_FIRST_DATA)
    end
    --再判断是否已获所有日常奖励结算(开始挑战按钮的红点，，改成只要进去挑战过，就不会有红点提示)
    if self.endless_data and self.endless_data.day_pass_round then
        if tonumber(self.endless_data.day_pass_round) > 0 or (self.endless_data.type ~= 0 and self.endless_data.type ~= Endless_trailEvent.endless_type.old) then
            self.is_award_get = false
        else
            self.is_award_get = true
        end
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_REDPOINT_REWARD_DATA)
    end

    if self.endless_data and self.endless_data.new_day_pass_round and self.ctrl:checkNewEndLessIsOpen() == true then
        if tonumber(self.endless_data.new_day_pass_round) > 0 or (self.endless_data.type ~= 0 and self.endless_data.type ~= self.endless_data.select_type) then
            self.is_award_get_new = false
        else
            self.is_award_get_new = true
        end
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_REDPOINT_REWARD_DATA)
    end

    --再判断是否已上阵
    if self.endless_data then
        if self.endless_data.is_appoint == 0 and self.send_partner and next(self.send_partner.list or {}) == nil then--没派出
            self.is_send_partner = true
        else
            self.is_send_partner = false
        end
    end
    self:enterRedPoint()
    local is_show_red = self:checkRedStatus()
    --设置入口红点
    GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_REDPOINT_SENDPARTNER_DATA)
    GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_ESECSICE_ENDLESS_REDPOINT)

    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid=RedPointType.endless, status=is_show_red}) 
end

--入口等级未到的时候不显示红点
function Endless_trailModel:enterRedPoint()
    local open_data = Config.DailyplayData.data_exerciseactivity
    if open_data and open_data[EsecsiceConst.exercise_index.stonedungeon] then
        local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data[EsecsiceConst.exercise_index.stonedungeon].activate)
        if bool == false then
            self.is_first_get = {}
            self.is_send_partner = false
            self.is_award_get = false
            self.is_award_get_new = false
            self.first_status = false
        end
    end
end

--获取首通红点状态
function Endless_trailModel:getFirstGet(type)
    if self.is_first_get and next(self.is_first_get or {}) ~= nil and self.is_first_get[type] then
        return self.is_first_get[type]
    end
    return false
end

--获取是否已经派遣伙伴
function Endless_trailModel:getIsSendPartner()
    return self.is_send_partner
end

--获取是否已获所有日常奖励结算
function Endless_trailModel:getIsGetAllReward(  )
    return self.is_award_get
end

--获取是否已获所有日常奖励结算 新版
function Endless_trailModel:getIsGetAllRewardNew(  )
    return self.is_award_get_new
end

function Endless_trailModel:checkRedStatus()
    local status = false
    if self.first_status and self.first_status == true then
        status = true
    else
        if self.is_first_get and next(self.is_first_get or {}) ~= nil then
            for k,v in pairs(self.is_first_get) do
                if v == true then
                    status = true
                    break
                end
            end
        end
    end
    
    return status or self.is_send_partner or self.is_award_get or self.is_award_get_new
end

-- --根据当前通关获取临近的可以领取奖励
-- function Endless_trailModel:getNearFirstRewardByID(id)
--     if Config.EndlessData.data_first_data then
--         for i, v in ipairs(Config.EndlessData.data_first_data) do
--             if id == v.id then
--                 return v
--             end 
--         end
--     end
-- end


-- function Endless_trailModel:getRankList(...)
--     if self.rank_item_list then
--         return self.rank_item_list
--     end
-- end


function Endless_trailModel:is_include(value, list)
    for k, v in ipairs(list) do
        if v.bid == value then
            return true
        end
    end
    return false
end


function Endless_trailModel:__delete()
end
