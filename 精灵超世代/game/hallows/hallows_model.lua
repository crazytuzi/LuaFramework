-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-09-25
-- --------------------------------------------------------------------
HallowsModel = HallowsModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort

function HallowsModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HallowsModel:config()
    self.hallows_list = {}  -- 神器数据列表
    self.hallows_magic_list = {}  -- 幻化数据列表
    self.magic_task_list = {}     -- 幻化任务列表
    self.magic_attrs = {}

    self.open_flag = false  -- 该玩家是否打开过神器界面
    self.had_request = false
    self.attr_ratio_list = {}

    self.hallows_red_list = {} -- 红点数据
end

--==============================--
--desc:更新圣器数据
--time:2018-09-27 02:51:24
--@data:
--@return 
--==============================--
function HallowsModel:updateHallowsInfo(data)
    if data == nil then return end
    for i,v in ipairs(data.hallows) do
        local hallows_vo = self.hallows_list[v.id]
        if hallows_vo == nil then
            hallows_vo = HallowsVo.New()
            self.hallows_list[v.id] = hallows_vo 
        end
        hallows_vo:initAttributeData(v)
    end
    
    -- 计算神器红点
    self:checkHallowsRedStatus()
end

--==============================--
--desc:新增或者更新一个圣器
--time:2018-09-27 03:50:35
--@data:
--@return 
--==============================--
function HallowsModel:updateHallowsData(data)
    local hallows_vo = self:getHallowsById(data.id)
    if hallows_vo == nil then
        hallows_vo = HallowsVo.New()
        self.hallows_list[data.id] = hallows_vo 
    end
    hallows_vo:initAttributeData(data)

    -- 计算神器红点
    self:checkHallowsRedStatus()
end

--==============================--
--desc:监测红点
--time:2018-09-27 03:52:45
--@data:
--@return 
--==============================--
function HallowsModel:updateHallowsRedStatus( bid, status )
    local _status = self.hallows_red_list[bid]
    if _status == status then return end

    self.hallows_red_list[bid] = status

    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.hallows, {bid = bid, status = status})
    GlobalEvent:getInstance():Fire(HallowsEvent.HallowsRedStatus, bid, status)
end

-- 根据红点类型判断是否显示红点
function HallowsModel:checkRedIsShowByRedType( redType )
    return self.hallows_red_list[redType] or false
end

-- 判断神器是否有红点
function HallowsModel:getHallowsRedStatus(  )
    local red_status = false
    for k,v in pairs(self.hallows_red_list) do
        if v == true then
            red_status = true
            break
        end
    end
    return red_status
end

 -- 按照等级、进度、id排序，取出第一个神器来判断红点
function HallowsModel:sortHallowsFunc(objA, objB)
    if objA.step ~= objB.step then
        return objA.step > objB.step
    elseif objA.lucky ~= objB.lucky then
        return objA.lucky > objB.lucky
    else
        return objA.id > objB.id
    end
end

function HallowsModel:checkHallowsRedStatus()
    local show_red = false
    if self:checkIsHaveAllHallows() then --是否激活所有神器
        local hallows_list = deepCopy(self.hallows_list)
        table_sort(hallows_list, function(objA, objB) return self:sortHallowsFunc(objA, objB) end)
        local hallows_vo = hallows_list[1]
        if hallows_vo then
            self:setRedHallowsId(hallows_vo.id)
            local role_vo = RoleController:getInstance():getRoleVo()
            -- 神器升级
            local hallows_config = Config.HallowsData.data_info(getNorKey(hallows_vo.id, hallows_vo.step))
            local cost_config = hallows_config.loss
            if cost_config and next(cost_config) ~= nil then
                for k,v in pairs(cost_config) do
                    local bid = v[1]
                    local num = v[2]
                    local have_num = 0
                    local assert = Config.ItemData.data_assets_id2label[bid]
                    if assert then
                        have_num = role_vo[assert]
                    else
                        have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    end
                    if have_num < num then
                        show_red = false
                        break
                    else
                        show_red = true
                    end
                end
            end
            self:updateHallowsRedStatus(HallowsConst.Red_Index.hallows_lvup, show_red)

            -- 神器技能升级
            show_red = false
            -- 神器技能升级
            local skill_config = Config.HallowsData.data_skill_up(getNorKey(hallows_vo.id, hallows_vo.skill_lev))
            if skill_config and skill_config.lev_limit ~= 0 and skill_config.lev_limit <= hallows_vo.step then
                local cost_config = skill_config.lose
                if cost_config and next(cost_config) ~= nil then
                    for k,v in pairs(cost_config) do
                        local bid = v[1]
                        local num = v[2]
                        local have_num = 0
                        local assert = Config.ItemData.data_assets_id2label[bid]
                        if assert then
                            have_num = role_vo[assert]
                        else
                            have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                        end
                        if have_num < num then
                            show_red = false
                            break
                        else
                            show_red = true
                        end
                    end
                end
            end
            self:updateHallowsRedStatus(HallowsConst.Red_Index.skill_lvup, show_red)

            -- 神器精炼升级
            show_red = false
            local is_open = self:getHallowsRefineIsOpen()
            if is_open then
                local refine_cfg = Config.HallowsRefineData.data_refine[hallows_vo.id]
                if refine_cfg then
                    local hallows_refine_cfg = refine_cfg[hallows_vo.refine_lev+1]
                    if hallows_refine_cfg then
                        local cost_config = hallows_refine_cfg.expend
                        local need_lev = hallows_refine_cfg.need_lev
                        if cost_config and need_lev <= hallows_vo.step then
                            for k,v in pairs(cost_config) do
                                local bid = v[1]
                                local num = v[2]
                                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                                if have_num < num then
                                    show_red = false
                                    break
                                else
                                    show_red = true
                                end
                            end
                        end
                    end
                end
            end
            self:updateHallowsRedStatus(HallowsConst.Red_Index.refine_lvup, show_red)

            -- 是否可以使用圣印石
            show_red = false
            local trace_config = Config.HallowsData.data_trace_cost(getNorKey(hallows_vo.id, hallows_vo.step))
            local id_stone_config = Config.HallowsData.data_const["id_stone"]
            if trace_config and id_stone_config then
                local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(id_stone_config.val)
                if hallows_vo.seal < trace_config.num and have_num > 0 then
                    show_red = true
                end
            end
            self:updateHallowsRedStatus(HallowsConst.Red_Index.stone_use, show_red)
        end

        -- 当从神器任务界面变为神器界面时，要先清一下任务的红点
        if self:checkRedIsShowByRedType(HallowsConst.Red_Index.task_award) then
            self:updateHallowsRedStatus(HallowsConst.Red_Index.task_award, false)
        end
    else
        show_red = self:checkHallowsAwardTips()
        self:updateHallowsRedStatus(HallowsConst.Red_Index.task_award, show_red)
    end
end

-- 保存一下显示红点的神器id(等级最高的)
function HallowsModel:setRedHallowsId( id )
    self.red_hallows_id = id
end

function HallowsModel:getRedHallowsId(  )
    return self.red_hallows_id
end

--==============================--
--desc:返回圣器数据
--time:2018-09-27 03:42:30
--@id:
--@return 
--==============================--
function HallowsModel:getHallowsById(id)
    return self.hallows_list[id]
end

--==============================--
--desc:当前总结束
--time:2018-09-28 02:13:35
--@return 
--==============================--
function HallowsModel:curTotalStep()
    local step = 0
    for k,v in pairs(self.hallows_list) do
        step = step + v.step
    end
    return step
end

--==============================--
--desc:获取圣器列表
--time:2018-09-28 02:35:43
--@return 
--==============================--
function HallowsModel:getHallowsList()
    local list = {}
    for k,v in pairs(self.hallows_list) do
        table_insert(list, v)
    end
    return list
end

--==============================--
--desc:圣器共鸣等级
--time:2018-09-28 01:59:13
--@return 
--==============================--
function HallowsModel:getResonateLev()
    return 0
    --return self.resonate_lev 
end


function HallowsModel:getRatio(type, attr_key)
    return self.attr_ratio_list[getNorKey(type, attr_key)]
end

--- 圣器任务列表
function HallowsModel:updateHallowsTask(list)
    if list == nil or next(list) == nil then return end
    if self.hallows_task_list == nil then
        self.hallows_task_list = {}
    end
    for i,v in ipairs(list) do
        self.hallows_task_list[v.id] = v
    end
    self:checkHallowsRedStatus()
    GlobalEvent:getInstance():Fire(HallowsEvent.UpdateHallowsTaskEvent)
end

--- 获取指定圣器的任务列表, 这个id是圣器的id
function HallowsModel:getHallowsTaskList(id)
    local task_list = {}
    local hallows_task_config = Config.HallowsData.data_task
    if self.hallows_task_list then
        for k,v in pairs(self.hallows_task_list) do
            local config = hallows_task_config[v.id]
            if config and config.hid == id then
                table_insert(task_list, v)
            end
        end
    end
    if next(task_list) then
        table_sort(task_list, function(a,b)
            return a.id < b.id
        end)
    end
    return task_list
end

--- 获取指定任务数据
function HallowsModel:getHallowsTaks(id)
    if self.hallows_task_list then
        return self.hallows_task_list[id]
    end
end

--- 获取当前待激活的圣器id
function HallowsModel:getCurActivityHallowsId()
    if self.hallows_list == nil or next(self.hallows_list) == nil then      -- 第一个圣器
        return 1
    end

    local next_id = 0
    for k,v in pairs(self.hallows_list) do
        if next_id < v.id then
            next_id = v.id
        end
    end
    return (next_id + 1)            -- 取出当前待激活的圣器的id
end

--- 当前待激活的神器是否有可领取的任务奖励
function HallowsModel:checkHallowsAwardTips()
    if self.hallows_task_list == nil or next(self.hallows_task_list) == nil then return false end
    local cur_hallows_id = self:getCurActivityHallowsId()
    local task_list = self:getHallowsTaskList(cur_hallows_id)
    if task_list == nil or next(task_list) == nil then return false end
    for i,v in ipairs(task_list) do
        if v.finish == 1 then
            return true
        end
    end
    return false
end

-- 获取当前是否已经激活所有神器
function HallowsModel:checkIsHaveAllHallows(  )
    local max_count = Config.HallowsData.data_base_length
    local cur_count = 0
    for k,v in pairs(self.hallows_list) do
        cur_count = cur_count + 1
    end
    return (cur_count>=max_count)
end

-- 设置是否打开过神器界面的标记
function HallowsModel:setOpenHallowsFlag( flag )
    self.open_flag = flag
end
-- 1 为打开过，2为没打开过
function HallowsModel:getHallowsOpenFlag(  )
    return self.open_flag
end

-- 根据神器id，从配置表数据中获取该神器最高属性数据
function HallowsModel:makeHighestHallowVo( hallows_id )
    if hallows_id then
        local hallows_vo = HallowsVo.New()
        local max_lv = Config.HallowsData.data_max_lev[hallows_id]
        local max_skill_lv = Config.HallowsData.data_skill_max_lev[hallows_id]
        local max_refine_lv = Config.HallowsRefineData.data_max_lev[hallows_id]
        local config_info = Config.HallowsData.data_info(getNorKey(hallows_id, max_lv))
        local config_skill = Config.HallowsData.data_skill_up(getNorKey(hallows_id, max_skill_lv))
        local attr_data = {}
        for k,v in pairs(config_info.attr) do
            local attr_str = v[1]
            local attr_temp = {}
            attr_temp.attr_id = Config.AttrData.data_key_to_id[attr_str]
            attr_temp.attr_val = v[2]
            table_insert(attr_data, attr_temp)
        end
        
        hallows_vo.id = hallows_id
        hallows_vo.step = max_lv
        hallows_vo.add_attr = attr_data
        hallows_vo.skill_bid = config_skill.skill_bid
        hallows_vo.skill_lev = max_skill_lv
        hallows_vo.refine_lev = max_refine_lv
        -- 看下是否被幻化了
        local vo = self:getHallowsById(hallows_id)
        if vo then
            hallows_vo.look_id = vo.look_id
        end

        return hallows_vo
    end
end

------------------------------@ 神器幻化相关
-- 设置幻化数据
function HallowsModel:setHallowsMagicData( data )
    self.hallows_magic_list = data or {}
    self:calculateHallowsMagicAttrs()
end

-- 获取幻化数据
function HallowsModel:getHallowsMagicData(  )
    return self.hallows_magic_list or {}
end

-- 是否有解锁幻化
function HallowsModel:checkIsHaveHallowsMagic(  )
    if not self.hallows_magic_list or next(self.hallows_magic_list) == nil then
        return false
    else
        return true
    end
end

-- 获取单个的幻化数据
function HallowsModel:getHallowsMagicDataById( id )
    local magic_data = {}
    for k,mData in pairs(self.hallows_magic_list) do
        if mData.id == id then
            magic_data = mData
            break
        end
    end
    return magic_data
end

-- 根据幻化id判断幻化是否已经解锁
function HallowsModel:checkHallowsMagicIsHave( id )
    local is_have = false
    for k,mData in pairs(self.hallows_magic_list) do
        if mData.id == id then
            is_have = true
            break
        end
    end
    return is_have
end

-- 根据幻化id获取幻化的状态
function HallowsModel:getHallowsMagicStatus( id )
    local magic_status = HallowsConst.Magic_status.Lock
    if self:checkHallowsMagicIsHave(id) then
        magic_status = HallowsConst.Magic_status.Have
    else
        local magic_cfg = Config.HallowsData.data_magic[id]
        if magic_cfg and magic_cfg.is_item ~= 2 then
            if magic_cfg.is_item == 0 then -- 任务解锁
                local task_list = self:getMagicTaskListById(id)
                for k,v in pairs(task_list) do
                    if v.finish == 0 then
                        magic_status = HallowsConst.Magic_status.Lock
                        break
                    else
                        magic_status = HallowsConst.Magic_status.CanHave
                    end
                end
            elseif magic_cfg.is_item == 1 and magic_cfg.loss[1] then -- 道具手动解锁
                local bid = magic_cfg.loss[1][1]
                local num = magic_cfg.loss[1][2]
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if have_num >= num then
                    magic_status = HallowsConst.Magic_status.CanHave
                end
            end
        else
            magic_status = HallowsConst.Magic_status.Lock
        end
    end
    return magic_status
end

-- 更新幻化数据
function HallowsModel:updateHallowsMagicData( data )
    local is_have = false
    for k,mData in pairs(self.hallows_magic_list) do
        if mData.id == data.id then
            for key,val in pairs(data) do
                mData[key] = val
            end
            is_have = true
            break
        end
    end
    if not is_have then
        table.insert(self.hallows_magic_list, data)
    end
    self:calculateHallowsMagicAttrs()
end

-- 删除幻化数据（幻化到期）
function HallowsModel:deleteHallowsMagicById( id )
    for k,mData in pairs(self.hallows_magic_list) do
        if mData.id == id then
            table.remove(self.hallows_magic_list, k)
            break
        end
    end
    self:calculateHallowsMagicAttrs()
end

-- 设置幻化任务数据
function HallowsModel:setHallowsMagicTaskData( data_list )
    data_list = data_list or {}
    self.magic_task_list = {}
    for k,tData in pairs(data_list) do
        local task_config = Config.HallowsData.data_magic_task[tData.id]
        if task_config then
            -- 以幻化id为标识存储
            if self.magic_task_list[task_config.hid] == nil then
                self.magic_task_list[task_config.hid] = {}
            end
            table.insert(self.magic_task_list[task_config.hid], tData)
        end 
    end
    self:checkMagicTaskRedStatus()
end

-- 更新幻化任务数据
function HallowsModel:updateHallowsMagicTaskData( data_list )
    data_list = data_list or {}
    for k,tData in pairs(data_list) do
        local task_config = Config.HallowsData.data_magic_task[tData.id]
        if task_config then
            if self.magic_task_list[task_config.hid] == nil then
                self.magic_task_list[task_config.hid] = {}
                table.insert(self.magic_task_list[task_config.hid], tData)
            else
                for _,oldData in pairs(self.magic_task_list[task_config.hid]) do
                    if oldData.id == tData.id then
                        for key,val in pairs(tData) do
                            oldData[key] = val
                        end
                        break
                    end
                end
            end
        end
    end
    self:checkMagicTaskRedStatus()
end

-- 根据幻化id检测是否显示红点
function HallowsModel:checkHallowsMagicIsShowRed( id )
    if self:checkHallowsMagicIsHave(id) then -- 已经获得
        return false
    end
    local is_show = false
    local magic_cfg = Config.HallowsData.data_magic[id]
    if magic_cfg then
        if magic_cfg.is_item == 0 then -- 任务解锁
            local task_list = self:getMagicTaskListById(id)
            for k,v in pairs(task_list) do
                if v.finish == 1 then
                    is_show = true
                    break
                end
            end
        elseif magic_cfg.is_item == 1 and magic_cfg.loss[1] then -- 道具手动解锁
            local bid = magic_cfg.loss[1][1]
            local num = magic_cfg.loss[1][2]
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
            if have_num >= num then
                is_show = true
            end
        end
    end
    return is_show
end

-- 检测幻化任务红点
function HallowsModel:checkMagicTaskRedStatus(  )
    local is_show_red = false
    local role_vo = RoleController:getInstance():getRoleVo()
    local open_cfg = Config.HallowsData.data_const["illusion_open"]
    if open_cfg and role_vo and open_cfg.val <= role_vo.lev then
        for id,task_list in pairs(self.magic_task_list) do
            for k,tData in pairs(task_list) do
                if tData.finish == 1 then
                    is_show_red = true
                    break
                end
            end
        end
    end
    self:updateHallowsRedStatus(HallowsConst.Red_Index.magic_task, is_show_red)    
end

-- 根据幻化id获取幻化任务列表
function HallowsModel:getMagicTaskListById( id )
    local task_list = {}
    local magic_task_config = Config.HallowsData.data_magic_task
    if self.magic_task_list then
        task_list = self.magic_task_list[id] or {}
    end
    if next(task_list) then
        table_sort(task_list, function(a,b)
            return a.id < b.id
        end)
    end
    return task_list
end

-- 根据幻化id获取特效资源
function HallowsModel:getHallowsEffectByMagicId( magic_id )
    local magic_cfg = Config.HallowsData.data_magic[magic_id]
    if magic_cfg then
        return magic_cfg.effect
    end
end

-- 计算幻化皮肤的属性加成
function HallowsModel:calculateHallowsMagicAttrs(  )
    self.magic_attrs = {}
    for k,mData in pairs(self.hallows_magic_list) do
        local magic_cfg = Config.HallowsData.data_magic[mData.id]
        if magic_cfg then
            for _,v in pairs(magic_cfg.attr) do
                local attr_key = v[1]
                local attr_val = v[2]
                if self.magic_attrs[attr_key] == nil then
                    self.magic_attrs[attr_key] = attr_val
                else
                    self.magic_attrs[attr_key] = self.magic_attrs[attr_key] + attr_val
                end
            end
        end
    end
end

-- 根据属性key获取幻化皮肤加成
function HallowsModel:getHallowsMagicAttrByKey( key )
    return self.magic_attrs[key] or 0
end

-- 神器精炼是否开启
function HallowsModel:getHallowsRefineIsOpen(  )
    local is_open = false
    local role_vo = RoleController:getInstance():getRoleVo()
    local open_lv_cfg = Config.HallowsRefineData.data_const["open_lev"]
    if open_lv_cfg and role_vo and role_vo.lev >= open_lv_cfg.val then
        is_open = true
    end
    return is_open
end

function HallowsModel:__delete()
end
