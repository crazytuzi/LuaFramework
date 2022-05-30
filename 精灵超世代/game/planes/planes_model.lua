-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-11-26
-- --------------------------------------------------------------------
PlanesModel = PlanesModel or BaseClass()

local _table_insert = table.insert
local _table_remove = table.remove

function PlanesModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PlanesModel:config()
    self.cur_dun_id = 0 -- 当前已选择的副本id，为0则没有选择
    self.cur_floor = 0  -- 当前所在层
    self.cur_dun_pro_val = 0 -- 当前选择的副本进度值
    self.max_dun_pro_val = 1 -- 当前选择的副本最大进度值
    self.can_chose_dun_list = {} -- 可选择的副本id列表
    self.can_get_award_dun_list = {} -- 可领取首通奖励的副本id列表
    self.got_award_dun_list = {} -- 已领取过首通奖励的副本id列表
    self.planes_reset_time = 0 -- 下次重置时间戳
    self.evt_vo_list = {} -- 所有格子事件的数据
    self.planes_bag_data = nil -- 位面背包数据 self.planes_bag_data[位置id] = data(协议23112的单个结构)
    self.planes_hero_data = {} -- 位面所有宝可梦数据（包括雇佣的宝可梦）

    self.is_holiday_open = false --是否活动开启中 --by lwc

    self.planes_red_list = {}
end
--是否活动开启中
function PlanesModel:isHolidayOpen()
    return self.is_holiday_open
end

--设置活动开启中
function PlanesModel:setHolidayOpen(is_holiday)
    if is_holiday then
        self.is_holiday_open = (is_holiday == 1)
    end
end

-- 设置当前选择的副本id
function PlanesModel:setCurDunId( dun_id )
    self.cur_dun_id = dun_id or 0
end

function PlanesModel:getCurDunId(  )
    return self.cur_dun_id
end

-- 设置当前所在层
function PlanesModel:setCurPlanesFloor( floor )
    self.cur_floor = floor or 0
end

function PlanesModel:getCurPlanesFloor(  )
    return self.cur_floor
end

-- 获取当前选择的副本id对应的战斗背景资源
function PlanesModel:getPlanesBattleBgId(  )
    local customs_cfg = Config.SecretDunData.data_customs[self.cur_dun_id]
    if customs_cfg then
        return customs_cfg.battle_bg_id
    end
end

-- 设置当前选择的副本的进度值
function PlanesModel:setCurDunProgressVal( val, max_val )
    self.cur_dun_pro_val = val or 0
    if max_val and max_val > 0 then
        self.max_dun_pro_val = max_val
    end

    -- 红点
    if (self.cur_dun_id == 0 or val ~= max_val) and not self.set_red_init then
        self.set_red_init = true
        self:updatePlanesRedStatus(PlanesConst.Red_Index.Login, true)
    end
end

function PlanesModel:getCurDunProgressVal(  )
    return self.cur_dun_pro_val, self.max_dun_pro_val
end

-- 设置当前可选择的副本id列表
function PlanesModel:setCanChoseDunList( dun_list )
    self.can_chose_dun_list = dun_list or {}
end

function PlanesModel:getCanChoseDunList(  )
    return self.can_chose_dun_list
end

-- 设置当前可领取奖励的副本id列表
function PlanesModel:setCanGetAwardDunList( dun_list )
    self.can_get_award_dun_list = dun_list or {}

    self:calculateAwardRedStatus()
end

-- 计算首通奖励红点
function PlanesModel:calculateAwardRedStatus(  )
    local red_status = false
    if tableLen(self.can_get_award_dun_list) > 0 then
        red_status = true
    end
    self:updatePlanesRedStatus(PlanesConst.Red_Index.Award, red_status)
end

-- 根据副本id判断是否可领取首通奖励
function PlanesModel:checkIsCanGetAwardByDunId( dun_id )
    local is_can_get = false
    for k,v in pairs(self.can_get_award_dun_list) do
        if v.can_reward_id == dun_id then
            is_can_get = true
            break
        end
    end
    return is_can_get
end

-- 根据副本id获取副本的状态
function PlanesModel:getPlanesDunStatusById( dun_id )
    local status = PlanesConst.Dun_Status.Lock -- 未解锁
    if self.cur_dun_id == 0 then -- 还没有选择任何一个副本
        for _,v in pairs(self.can_chose_dun_list) do
           if v.id == dun_id then
                status = PlanesConst.Dun_Status.Chose -- 可选择
                break
            end
        end
    else
        if self.cur_dun_id == dun_id then
            status = PlanesConst.Dun_Status.Select -- 选中的
        else
            for _,v in pairs(self.can_chose_dun_list) do
                if v.id == dun_id then
                     status = PlanesConst.Dun_Status.Close -- 已解锁但关闭的
                     break
                 end
             end
        end
    end
    return status
end

-- 根据副本id判断是否已通关
function PlanesModel:checkDunIsPassByDunId( dun_id )
    local is_pass = false
    if self.got_award_dun_list[dun_id] or self:checkIsCanGetAwardByDunId(dun_id) then -- 已领取或可领取通关奖励
        is_pass = true
    end
    return is_pass
end

-- 根据副本id获取未开启的提示
function PlanesModel:getPlanesLockTipsByDunId( dun_id )
    local dun_cfg = Config.SecretDunData.data_customs[dun_id]
    if dun_cfg then
        local is_pass = false
        -- 通关位面副本
        if dun_cfg.id_limit and dun_cfg.id_limit[1] then
            if self:checkDunIsPassByDunId(dun_cfg.id_limit[1]) then
                is_pass = true
            end
            if not is_pass then
                local dun_info = Config.SecretDunData.data_dun_info[dun_cfg.id_limit[1]]
                if dun_info then
                    return string.format(TI18N("通关[%s]开启"), dun_info.name or "")
                end
            end
        end
        -- 等级
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo.lev < dun_cfg.lev_limit then
            return string.format(TI18N("等级达%d级"), dun_cfg.lev_limit)
        end
        -- 战力
        if role_vo.power < dun_cfg.power_limit then
            return string.format(TI18N("战力达%d"), dun_cfg.power_limit)
        end
    end
end

-- 设置已领取过副本id的列表
function PlanesModel:setGotFirstAwardDunList( dun_list )
    self.got_award_dun_list = {}
    for k,v in pairs(dun_list) do
        self.got_award_dun_list[v.reward_id] = true
    end
end

-- 添加已领取首通副本奖励的id
function PlanesModel:addGotFirstAwardDunId( dun_id )
    self.got_award_dun_list[dun_id] = true

    -- 同时清掉可领取的副本id
    for k,v in pairs(self.can_get_award_dun_list) do
        if v.can_reward_id == dun_id then
            table.remove(self.can_get_award_dun_list, k)
            break
        end
    end

    self:calculateAwardRedStatus()
end

-- 通过副本id判断是否领取过首通奖励
function PlanesModel:checkIsGetAwardByDunId( dun_id )
    return self.got_award_dun_list[dun_id]
end

-- 设置下次重置时间戳
function PlanesModel:setPlanesResetTime( time )
    self.planes_reset_time = time
end

-- 获取重置剩余时间
function PlanesModel:getResetLessTime(  )
    local cur_time = GameNet:getInstance():getTime()
    local less_time = self.planes_reset_time - cur_time
    if less_time < 0 then less_time = 0 end
    return less_time
end

-- 设置形象id
function PlanesModel:setPlanesRoleLookId( look_id )
    self.planes_look_id = look_id
end

function PlanesModel:getPlanesRoleLookId(  )
    return self.planes_look_id
end

-- 设置所有格子事件的数据
function PlanesModel:setPlanesEvtVoList( data_list )
    self.evt_vo_list = {}
    for _,v in pairs(data_list) do
        if v.evtid > 0 then -- 只记录有事件的数据
            local evt_vo = PlanesEvtVo.New()
            evt_vo:updateData(v)
            self.evt_vo_list[v.index] = evt_vo
        end
    end
end

-- 更新事件数据
function PlanesModel:updatePlanesEvtVoList( data_list )
    local add_evt_vo_list = {}
    for _,v in pairs(data_list) do
        local evt_vo = self.evt_vo_list[v.index]
        if not evt_vo then -- 可能是之前事件为0的格子变为了非0的格子
            evt_vo = PlanesEvtVo.New()
            evt_vo:updateData(v)
            self.evt_vo_list[v.index] = evt_vo
            table.insert( add_evt_vo_list, evt_vo )
        else
            evt_vo:updateData(v)
        end
    end
    -- 通知场景新增地图事件显示
    if next(add_evt_vo_list) ~= nil then
        GlobalEvent:getInstance():Fire(PlanesEvent.Add_Evt_Data_Event, add_evt_vo_list)
    end
end

-- 获取同一事件组的正在显示的index
function PlanesModel:getPlanesSameGroupIndexList( group_id, index )
    local index_list = {}
    for k,evt_vo in pairs(self.evt_vo_list) do
        if evt_vo.index ~= index and evt_vo.is_hide == 0 and evt_vo.config and evt_vo.config.group_id == group_id then
            _table_insert(index_list, evt_vo.index)
        end
    end
    return index_list
end

-- 根据格子坐标判断对应的事件是否可行走 
-- is_check_status 为 true，则事件状态不为已完成，则都可以走(用于点击事件格子时)
-- 升降台特殊处理:仅根据升降台状态判断是否可行走
function PlanesModel:checkEvtCanWalkByGridIndex( index, is_check_status )
    local is_can_walk = true
    local evt_vo = self.evt_vo_list[index]
    if evt_vo then
        -- 事件类型不是不可破坏的障碍物、且状态没有完成，则可以走
        if is_check_status and evt_vo.config and evt_vo.config.type ~= PlanesConst.Evt_Type.Barrier and evt_vo.status ~= PlanesConst.Evt_State.Down then
            is_can_walk = true
        elseif evt_vo.config and evt_vo.config.type == PlanesConst.Evt_Type.Stage then -- 升降台
            if evt_vo.platform == 1 then -- 升起来了,不可走
                is_can_walk = false
            end
        -- 一个事件只有未完成且配置了不可行走时，才为不可行走
        elseif evt_vo.config and evt_vo.config.is_walk == 0 and evt_vo.status == PlanesConst.Evt_State.Doing then
            is_can_walk = false
        end
    end
    return is_can_walk
end

-- 根据格子坐标判断该坐标是否有事件
function PlanesModel:checkIsHaveEvtByGridIndex( index )
    if self.evt_vo_list[index] then
        return true
    end
    return false
end

-- 是否需要走到事件格子前停下来
-- 有事件、且事件未完成，则需要走到事件前一格停下来（出生点除外，出生点一直是未完成）
function PlanesModel:checkIsNeedStopPreGrid( index )
    local evt_vo = self.evt_vo_list[index]
    if evt_vo and evt_vo.status == PlanesConst.Evt_State.Doing and evt_vo.config and evt_vo.config.type ~= PlanesConst.Evt_Type.Start then
        return true
    end
    return false
end

function PlanesModel:getPlanesEvtVoList(  )
    return self.evt_vo_list
end

function PlanesModel:getPlanesEvtVoByGridIndex( index )
    return self.evt_vo_list[index]
end

-- 设置位面背包数据
function PlanesModel:setPlanesBagData( secret_item )
    secret_item = secret_item or {}
    self.planes_bag_data = {}
    for i,v in ipairs(secret_item) do
        self.planes_bag_data[v.id] = v
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Iint_Bag_Data_Event)
end

-- 获取全部位面背包数据
function PlanesModel:getPlanesBagData(  )
    return self.planes_bag_data
end

-- 更新、新增背包数据
function PlanesModel:updatePlanesBagData( data_list )
    if not self.planes_bag_data then return end
    local is_add = false
    for _,n_data in pairs(data_list) do
        if self.planes_bag_data[n_data.id] then
            -- for k,v in pairs(n_data) do
            --    self.planes_bag_data[n_data.id][k] = v
            -- end
            self.planes_bag_data[n_data.id].num = n_data.num --目前更新就只有数量
        else
            self.planes_bag_data[n_data.id] = n_data
            is_add = true
        end
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Bag_Data_Event, data_list, is_add)
end

-- 删除背包数据
function PlanesModel:deletePlanesBagData( data_list )
    if not self.planes_bag_data then return end
    for _,v in pairs(data_list) do
        self.planes_bag_data[v.id] = nil
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Delete_Bag_Data_Event, data_list)
end

-- 设置所有宝可梦数据
function PlanesModel:setAllPlanesHeroData( data )
    self.planes_hero_data = data
end

function PlanesModel:getAllPlanesHeroData(  )
    return self.planes_hero_data
end

function PlanesModel:getPlanesHireHeroData( id )
    for k,v in pairs(self.planes_hero_data) do
        if v.flag == 1 and v.partner_id == id then
            return v
        end
    end 
end

-- 更新我方宝可梦血量数据
function PlanesModel:updateMyHeroData( data_list )
    for _,n_data in pairs(data_list) do
        for k,o_data in pairs(self.planes_hero_data) do
            if o_data.flag == n_data.flag and o_data.partner_id == n_data.partner_id then
                o_data.hp_per = n_data.hp_per
                break
            end
        end 
    end
end

-- 获取宝可梦的剩余血量
function PlanesModel:getMyPlanesHeroHpPer( partner_id, flag )
    local hp_per = 100
    flag = flag or 0
    for k,v in pairs(self.planes_hero_data) do
        if v.flag == flag and v.partner_id == partner_id then
            hp_per = v.hp_per or 100
            break
        end
    end
    return hp_per
end

-- 是否有不满血的宝可梦
function PlanesModel:checkIsHaveHpNotFullHero(  )
    local is_have = false
    for k,v in pairs(self.planes_hero_data) do
        if v.hp_per < 100 then
            is_have = true
            break
        end
    end
    return is_have
end

-- 是否有死亡的宝可梦
function PlanesModel:checkIsHaveDieHero(  )
    local is_have = false
    for k,v in pairs(self.planes_hero_data) do
        if v.hp_per <= 0 then
            is_have = true
            break
        end
    end
    return is_have
end

-- 缓存剧情对话数据
function PlanesModel:setPlanesDramIdCache( dram_id )
    self.dram_id_cache = dram_id
end

function PlanesModel:getPlanesDramIdCache(  )
    return self.dram_id_cache
end

-- 红点
function PlanesModel:updatePlanesRedStatus( bid, status )
    if not self.planes_is_open then
        self.planes_is_open = PlanesController:getInstance():checkPlanesIsOpen(true)
    end
    if not self.planes_is_open then return end

    self.planes_red_list[bid] = status

    local red_status = self:getPlanesRedStatus()
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid = RedPointType.heroexpedit, status = red_status})
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Planes_Red_Event, bid, status)
end

function PlanesModel:getPlanesRedStatus(  )
    local red_status = false
    for k,v in pairs(self.planes_red_list) do
        if v then
            red_status = true
            break
        end
    end
    return red_status
end

function PlanesModel:getPlanesRedStatusByBid( bid )
    return self.planes_red_list[bid] or false
end

function PlanesModel:__delete()
end