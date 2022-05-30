-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
BattleDramaModel = BattleDramaModel or BaseClass()

function BattleDramaModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
    self.drama_data = {}
    self.quick_battle_data ={}
    self.mode_list = {} --章节列表
    self.cur_dun_list = {}
    self.init_dungeon_list = {} --当前章节
    self.has_open_num = 0
    self.root_wnd_pos = nil
    self.is_open_quick_battle_view = false --主要用于记录是否已经打开是红点
    self.buff_data = {}
    self.last_dun_id = 0
    self.auto_combat = nil

    self.dic_drama_rewrad_ids = {}

    self.hook_accumulate_data = {}       -- 估计累积挂机收益

    --挂机时间 单位分钟 --by lwc
    self.hook_max_time = 120  
end


function BattleDramaModel:setOpenQuickBattleStatus(status)
    self.is_open_quick_battle_view = status
end

function BattleDramaModel:getOpenQuickBattleStatus()
    return  self.is_open_quick_battle_view 
end

function BattleDramaModel:setBuffData(data)
    self.buff_data = data
    GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Drama_Buff_View ,data)
end

function BattleDramaModel:getBuffData()
    if self.buff_data then
        return self.buff_data
    end
end
--主要存储剧情副本的所有数据用于获取
function BattleDramaModel:setDramaData(data)
    if data then
        local need_event = false
        if self.drama_data and self.drama_data.max_dun_id ~= data.max_dun_id then
            need_event = true
        end

        if self.drama_data.max_dun_id == nil or self.drama_data.max_dun_id < data.max_dun_id then
            self.last_dun_id = self.drama_data.max_dun_id or data.max_dun_id 
        end

        self.drama_data = {mode = data.mode,
                            chapter_id = data.chapter_id,
                            dun_id = data.dun_id,
                            status = data.status,
                            cool_time = data.cool_time,
                            max_dun_id = data.max_dun_id,
                            auto_num = data.auto_num,
                            auto_num_max = data.auto_num_max,
                            last_dun_id = self.last_dun_id,
                            is_first = data.is_first
                          }               
        if data.mode_list then
            self.mode_list = data.mode_list
        end
        if need_event == true then
            GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Update_Max_Id, data.max_dun_id) 
        end
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Top_Update_Data,data)
    end
end

--更新部分剧情副本的所有数据用于获取
function BattleDramaModel:updateDramaData(data)
    if data and self.drama_data then
        local need_event = false
        if self.drama_data and self.drama_data.max_dun_id ~= data.max_dun_id then
            need_event = true
        end

        if self.drama_data.max_dun_id == nil or self.drama_data.max_dun_id < data.max_dun_id then
            self.last_dun_id = self.drama_data.max_dun_id or data.max_dun_id
        end
        if self.drama_data and self.drama_data.dun_id ~= data.dun_id then
            GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Update_Dun_Id, data.dun_id)
        end
        self.drama_data.mode = data.mode
        self.drama_data.chapter_id = data.chapter_id
        self.drama_data.dun_id = data.dun_id
        self.drama_data.status = data.status
        self.drama_data.cool_time = data.cool_time
        self.drama_data.max_dun_id = data.max_dun_id
        self.drama_data.last_dun_id = self.last_dun_id
        self.drama_data.is_first = data.is_first

        self:updateModeListInfo(data)
        if self.cur_dun_list and next(self.cur_dun_list or {}) ~= nil and self.cur_dun_list[data.dun_id]then
            self.cur_dun_list[data.dun_id].status = data.status
            if self.cur_dun_list[data.dun_id].status == 3 then
                self.cur_dun_list[data.dun_id].is_has = true
            end
            GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Update_Data, data)
        end
        if need_event then
            GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Update_Max_Id, data.max_dun_id)
        end
    end
end

--获取当前副本除列表外的信息
function BattleDramaModel:getDramaData()
    if self.drama_data and next(self.drama_data or {}) ~= nil then
        return self.drama_data
    end
end

--用于初始化当前显示关卡的信息展示
function BattleDramaModel:initDungeonList(mode,chapter_id)
    if Config.DungeonData.data_drama_info then
        local chapter_list = Config.DungeonData.data_drama_info[mode][chapter_id]
        if chapter_list then
            local list = {}
            local table_insert = table.insert
            for i, v in pairs(chapter_list) do
                table_insert(list, v)
            end
            table.sort(list, function(a, b)
                return a.id < b.id
            end)
            for i,v in ipairs(list) do
                local info_data = Config.DungeonData.data_drama_dungeon_info(v.id)
                self.init_dungeon_list[i] = {info_data = info_data}
                self.cur_dun_list[v.id] = { dun_id = v.id, status = 0, cool_time = 0, auto_num = 0, is_has = false }
            end
        end
       
        self:updateHadModeListInfo(mode,chapter_id)
    end
end

--==============================--
--desc:获取某个章节的副本总长度
--time:2018-06-06 02:13:11
--@model:
--@chapter_id:
--@return 
--==============================--
function BattleDramaModel:getChapterLength(model, chapter_id)
    if self.chapter_list == nil then
        self.chapter_list = {}
    end
    if self.chapter_list[getNorKey(model, chapter_id)] == nil then
        local sum = 0
        if Config.DungeonData.data_drama_info[model] ~= nil then
            local list = Config.DungeonData.data_drama_info[model][chapter_id]
            if list ~= nil then
                sum = tableLen(list)
            end
        end
        self.chapter_list[getNorKey(model, chapter_id)] = sum
    end
    return self.chapter_list[getNorKey(model, chapter_id)]
end

function BattleDramaModel:getInitDungeonList()
    if self.init_dungeon_list and next(self.init_dungeon_list or {}) ~= nil then
        return self.init_dungeon_list
    end
end
--获取初始化当前章节和难道所有副本信息
function BattleDramaModel:updateHadModeListInfo(mode,chapter_id)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(mode,chapter_id)
        if chapter_list then
            local dun_list = chapter_list.dun_list
            if dun_list then
                for i, v in ipairs(dun_list) do
                    local temp_data = self.cur_dun_list[v.dun_id]
                    if temp_data then
                        temp_data.dun_id = v.dun_id
                        temp_data.status = v.status
                        temp_data.cool_time = v.cool_time
                        temp_data.auto_num = v.auto_num
                        temp_data.is_has = true
                    end
                end
            end
        end
    end
end

function BattleDramaModel:getSingleBossData(dun_id)
    local data_list = {}
    local info_data = Config.DungeonData.data_drama_dungeon_info(dun_id)
    data_list.info_data = info_data
    local temp_data = {dun_id = data_list.id, status = 0 , cool_time = 0, auto_num = 0,is_has = false }
    data_list.v_data = self:getCurDungeonDunData(dun_id) or temp_data 
    return data_list
end

function BattleDramaModel:getChapterListByID(mode,chapter_id)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self.mode_list[mode].chapter_list
        local list = nil
        if chapter_list then
            for i, v in ipairs(chapter_list) do
                if v.chapter_id == chapter_id then
                    list = v
                    break
                end
            end
            return list
        end
    end
end



function BattleDramaModel:updateModeListInfo(data)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(data.mode,data.chapter_id)
        if chapter_list then
            local dun_list = chapter_list.dun_list
            if dun_list then
                local temp_has = true
                if data.status == 1 then
                    temp_has = false
                end
                local is_has = false
                for i, v in ipairs(dun_list) do
                    if data.dun_id == v.dun_id then
                        is_has = true
                        v.dun_id = data.dun_id
                        v.cool_time = data.cool_time
                        v.status = data.status
                        v.is_has = temp_has
                    end
                end
                if not is_has then
                    table.insert(dun_list,{dun_id = data.dun_id, status =data.status , cool_time = data.cool_time, auto_num = 0,is_has = temp_has})
                end
            end
        end
    end
end


function BattleDramaModel:getCurDunInfoByID(dun_id)
    if self.cur_dun_list then
        local config = self.cur_dun_list[dun_id]
        return config
    end
end
function BattleDramaModel:updateCurDunListInfo(data)
    if self.cur_dun_list and data then
        local config = self.cur_dun_list[data.dun_id]
        if config then
            config.auto_num = config.auto_num + data.num
        end
        self:updateSingleCurInfo(data)
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Boss_Update_Data,config)
    end
end

function BattleDramaModel:updateSingleCurInfo(data)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(self.drama_data.mode,self.drama_data.chapter_id)
        for i, v in ipairs(self.mode_list) do
            for k, v2 in ipairs(v.chapter_list) do
                for j, v3 in ipairs(v2.dun_list) do
                    if v3.dun_id == data.dun_id then
                        v3.dun_id = data.dun_id
                        v3.auto_num = v3.auto_num + data.num
                    end
                end
            end
        end
    end
end
--根据难度获取当前难道已通关信息
function BattleDramaModel:getModeListByMode(mode)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local mode_list = self.mode_list[mode]
        if mode_list then
            return  mode_list
        else
            return nil
        end 
    end
end

--根据难度和章节id去获取已通过的关卡数
function BattleDramaModel:getHasCurChapterPassListNum(mode,chapter_id)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(mode,chapter_id)
        local sum = 0
        if chapter_list then
            local dun_list = chapter_list.dun_list
            if dun_list then
                for i, v in ipairs(dun_list) do
                    if v.status == 3 then
                        sum = sum + 1 
                    end
                end
            end
        end
        return sum
    end
end

--根据难度和章节id去获取已通过的Boss关卡数
function BattleDramaModel:getHasCurChapterPassListBossNum(mode, chapter_id)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(mode, chapter_id)
        local sum = 1
        if chapter_list then
            local dun_list = chapter_list.dun_list
            if dun_list then
                for i, v in ipairs(dun_list) do
                    local config = Config.DungeonData.data_drama_dungeon_info(v.dun_id)
                    if v.status == 3 and config and config.is_big == TRUE then
                        sum = sum + 1
                    end
                end
            end
        end
        return sum
    end
end

--获取当前已经全部通过关卡的章节总数
function BattleDramaModel:getHasPassChapterPassList(mode)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self.mode_list[mode].chapter_list
        local sum = 0
        if chapter_list then
            for i, v in ipairs(chapter_list) do
                if v.status == 1 then --代表全部
                    sum = sum + 1
                end 
            end
        end
        return sum
    end
end

--获取当前通关的章节数
function BattleDramaModel:getCurMaxChapterId(mode)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self.mode_list[mode].chapter_list
        local chapter_id = 1
        if chapter_list then
            for i, v in ipairs(chapter_list) do
                if v.status == 1 then
                    if chapter_id <= v.chapter_id then
                        chapter_id = v.chapter_id
                    end
                end
            end
        end
        return chapter_id
    end
end

--获取已开启的总章节数
function BattleDramaModel:getOpenSumChapter(mode)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self.mode_list[mode].chapter_list
        local chapter_sum = 0
        if chapter_list then
            for i, v in ipairs(chapter_list) do
                chapter_sum = chapter_sum + 1
            end
        end
        return chapter_sum
    end
end



--获取当前切换章节通过最大的关卡ID
function BattleDramaModel:getHasPassChapterMaxDunId(mode,chapter_id)
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        local chapter_list = self:getChapterListByID(mode,chapter_id)
        local max_dun_id = 0
        if chapter_list then
            local dun_list = chapter_list.dun_list
            for i, v in ipairs(dun_list) do
                if v.dun_id > max_dun_id then
                    max_dun_id = v.dun_id
                end
            end            
        end
        return max_dun_id
    end
end

--快速挑战的数据
function BattleDramaModel:setQuickData(data)
    self.quick_battle_data = data
    if self.drama_data then
        self.drama_data.auto_num = data.auto_num
        self.drama_data.auto_num_max = data.auto_num_max
        self.drama_data.is_auto_combat = data.is_auto_combat
    end
    self:checkRedPoint()
    GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Quick_Battle_Data, data)
end


function BattleDramaModel:checkRedPoint()
    -- if self.is_open_quick_battle_view == false then
    --     local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['quick_swap_item'].val)
    --     if self.quick_battle_data.fast_combat_num == 0 or  num > 0 then
    --         MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.drama_scene, true)
    --     end
    -- else
        local status = self:getDramaRewardRedPointInfo()
        -- if status == false then
        --     if EncounterController then
        --         status = EncounterController:getInstance():getModel():getRedStatus()
        --     end
        -- end
        
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.drama_scene, status)
    -- end
end

--获取快速战斗数据
function BattleDramaModel:getQuickData()
    if self.quick_battle_data and next(self.quick_battle_data or {}) ~= nil then
        return self.quick_battle_data 
    end
end

function BattleDramaModel:getRootWndPos()
    return  self.root_wnd_pos
end
function BattleDramaModel:setRootWndPos(pos)
    self.root_wnd_pos = pos
end

--设置通关奖励
function BattleDramaModel:setDramaReward(data)
    self.drama_reward = data
    self.dic_drama_rewrad_ids = {} 
    for i,v in ipairs(data.list) do
        self.dic_drama_rewrad_ids[v.id] = true
    end
    self:checkRedPoint()
    GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Drama_Reward_Data,data)
end

--获取通关奖励的红点信息
function BattleDramaModel:getDramaRewardRedPointInfo()
    local drama_data = self:getDramaData()
    if self.dic_drama_rewrad_ids and drama_data and drama_data.max_dun_id then
        local config =  Config.DungeonData.data_drama_reward
        if config then
            for i,v in ipairs(config) do
                --当前最大关卡 比需求关卡 大 说明可领
                if drama_data.max_dun_id >= v.limit_id then
                    if not self.dic_drama_rewrad_ids[v.id] then
                        return true
                    end
                end
            end
        end 
    end

    return false
end

--获取已领取通关奖励信息 结构 self.dic_drama_rewrad_ids[序号] = true
function BattleDramaModel:getDicDramaRewardID()
    if self.dic_drama_rewrad_ids then
        return self.dic_drama_rewrad_ids
    end
end

--获取最新未领取的奖励的 关卡表信息
function BattleDramaModel:getNewDramaRewardID()
    local config =  Config.DungeonData.data_drama_reward
    if config then
        for i,v in ipairs(config) do
            if not self.dic_drama_rewrad_ids[v.id] then
                return v
            end
        end
    end
    return nil
end

--根据副本ID获取距离领取奖励的总关卡数
function BattleDramaModel:getOffsetNum(dun_id)
    if Config.DungeonData.data_drama_dungeon_info(dun_id) then
        local final_count = 0
        local max_count = 0
        local chapter_id = Config.DungeonData.data_drama_dungeon_info(dun_id).chapter_id
        local mode = Config.DungeonData.data_drama_dungeon_info(dun_id).mode
        if self.drama_data and Config.DungeonData.data_drama_info[mode] then
            local config = Config.DungeonData.data_drama_info[mode]
            if config and config[chapter_id] then
                for k, list in pairs(config) do
                    if k <= chapter_id then
                        for i, v1 in pairs(list) do
                            if v1.id <= dun_id then
                                max_count = max_count + 1
                            end
                        end
                    end
                end
            end
        end
        return max_count
    end
end


--获取当前已通关的的总数
function BattleDramaModel:getCurDungeonMaxNum()
    local sum = 0
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        for i, v in ipairs(self.mode_list) do
            for k, v2 in ipairs(v.chapter_list) do
                for j, v3 in ipairs(v2.dun_list) do
                    if v3.status == 3 then
                        sum = sum + 1
                    end
                end
            end
        end
    end
    return sum
end

--获取当前关卡单个数据
function BattleDramaModel:getCurDungeonDunData(dun_id)
    local data = nil
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        for i, v in ipairs(self.mode_list) do
            for k, v2 in ipairs(v.chapter_list) do
                for j, v3 in ipairs(v2.dun_list) do
                    if v3.dun_id == dun_id then
                        data = v3
                        break
                    end
                end
            end
        end
        return data
    end
end

--获取可扫荡的boss关卡
function BattleDramaModel:getMaxDungeonDunData(dun_id)
    local data = nil
    local temp_dun_id = 0
    if self.mode_list and next(self.mode_list or {}) ~= nil then
        for i, v in ipairs(self.mode_list) do
            for k, v2 in ipairs(v.chapter_list) do
                for j, v3 in ipairs(v2.dun_list) do
                    local config = Config.DungeonData.data_drama_dungeon_info(v3.dun_id)
                    if v3.dun_id >= temp_dun_id and v3.dun_id <= dun_id and config and config.is_big == TRUE then
                        data = v3
                        temp_dun_id = v3.dun_id
                    end
                end
            end
        end
        return data
    end
end


--判断是否开启新章节
function BattleDramaModel:getIsNewChapter()
    if self.drama_data then
        local is_open_new_chapter = false
        local cur_chapter = 1
        local is_last_chapter = false 
        if Config.DungeonData.data_drama_dungeon_info(self.drama_data.max_dun_id) then
            cur_chapter = Config.DungeonData.data_drama_dungeon_info(self.drama_data.max_dun_id).chapter_id
            local next_id = Config.DungeonData.data_drama_dungeon_info(self.drama_data.max_dun_id).next_id
            if next_id == 0 then
                is_last_chapter = true
            end
            if cur_chapter ~= self.drama_data.chapter_id then
                is_open_new_chapter = true
            end
        end
        local data = {is_open_new_chapter = is_open_new_chapter, cur_chapter = cur_chapter ,is_last_chapter = is_last_chapter }
        return data
    end    
end

--根据当前副本id来获取展示
function BattleDramaModel:getShowDescRewad(dun_id)
    local list = {}
    local index = 1

    if Config.DungeonData.data_drama_show_reward then
        for k, v in ipairs(Config.DungeonData.data_drama_show_reward) do
            if dun_id < v.id and index <= 3 then
                index = index + 1
                table.insert(list,v)
            end
        end
        table.sort(list,function (a,b)
            return  a.id < b.id
        end)
        return  list
    end
end

--获取当前最大的冒险值
function BattleDramaModel:getMaxEnergyMax()
    local energy_max = RoleController:getInstance():getRoleVo().energy_max or 0
    return energy_max
end

--获取boss关卡预览相关信息
function BattleDramaModel:getBossShowData()
    local chapter_list = {}
    local sum_chapter = self:getOpenSumChapter(self.drama_data.mode)
    if Config.DungeonData.data_drama_world_info then
        local world_list = Config.DungeonData.data_drama_world_info[self.drama_data.mode]
        local boss_reward_list = Config.DungeonData.data_drama_boss_show_reward
        for i, v in ipairs(world_list) do
            local boss_reward = boss_reward_list[i]
            if boss_reward and v.chapter_id <= sum_chapter + 1 then
                table.insert(chapter_list,v)
            end
        end
        return chapter_list
    end
end


function BattleDramaModel:config()
    self.chapter_rewards_dict = {}
    self.chapter_rewards_list = {}
end

function BattleDramaModel:__delete()
end

--==============================--
--desc:伙伴红点记录
--time:2018-10-10 07:24:59
--@data: {{bid = 4, status = is_show}} 
--@return 
--==============================--
function BattleDramaModel:setPartnerUpgradeRedStatus(data)
    -- if data == nil or next(data) == nil then return end
    -- if self.partner_red_status_list == nil then
    --     self.partner_red_status_list = {}
    -- end

    -- for i, v in pairs(data) do
    --     if v.bid ~= nil then
    --         self.partner_red_status_list[v.bid] = v
    --     end
    -- end
    -- GlobalEvent:getInstance():Fire(Battle_dramaEvent.UpdatePartnerRedStatus)
end

function BattleDramaModel:checkPartnerRedStatus()
    if self.partner_red_status_list == nil then return false end
    for k,v in pairs(self.partner_red_status_list) do
        if v.status == true then return true end
    end
    return false
end

--- 挂机累积时间
function BattleDramaModel:updateHookAccumulateTime(data)
    self.hook_accumulate_data = data
    GlobalEvent:getInstance():Fire(Battle_dramaEvent.UpdateHookAccumulateTime, self.hook_accumulate_data)
end

function BattleDramaModel:getHookAccumulateInfo()
    return self.hook_accumulate_data
end

-- 计算挂机奖励
function BattleDramaModel:calcHookItems(data)
    if not data then return end
    local lev = RoleController:getInstance():getRoleVo().lev or 0
    local items 
    for i, v in pairs(data.hook_lev_add or {}) do
        if lev >= v[1] then
            items = v[2]
            break
        end
    end
    if items then
        local temp = {}
        for i, v in pairs(items) do
            temp[v[1]] = v[2]
        end
        for i, v in pairs(data.per_hook_items) do
            temp[v[1]] = v[2] + (temp[v[1]] or 0)
        end
        items = {}
        for i, v in pairs(temp) do
            table.insert(items, {i,v})
        end
        return items
    else
        return data.per_hook_items
    end
end
