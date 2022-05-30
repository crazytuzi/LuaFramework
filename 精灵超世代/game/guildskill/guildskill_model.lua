-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-19
-- --------------------------------------------------------------------
GuildskillModel = GuildskillModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort

function GuildskillModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildskillModel:config()
    self.career_skill_list = {}
    self.skill_wait_upgrade_list = {}
    self.skill_upgrade_cost_list = {}                 -- 当前待升级的技能消耗相关，以及需求的公会等级
    self.skill_red_status_list   = {}                 -- 职业技能红点状态
    self.pvp_skill_red_status_list   = {}                 -- 职业技能红点状态

    --pvp的职业信息
    self.pvp_career_skill_list = nil   

    self.had_send_mainui = false
    self.had_close_mainui = false
end

function GuildskillModel:clearGuildCareerSkill()
    self.career_skill_list = {}
    self.skill_wait_upgrade_list = {}
    self.skill_upgrade_cost_list = {}
    self.skill_red_status_list   = {}
    self.pvp_skill_red_status_list   = {}
end

function GuildskillModel:initGuildCareerSkill(data)
    if data == nil or data.group_id == nil then return end
    local config = Config.GuildSkillData.data_info_group[data.group_id]
    if config == nil then
        print("公会技能配置数据有问题，技能组id为：", data.group_id)
    else
        local object = {}
        object.career = data.career                 -- 当前职业
        object.group_id = data.group_id             -- 当前激活的技能组
        object.group_ids = data.group_ids           -- 已经激活的技能组
        object.skill_ids = {}                       -- 当前技能组的技能状态

        --是否有技能升级过
        if #data.group_ids > 0 or #data.skill_ids > 0 then
            object.had_skill_up = true
        else
            object.had_skill_up = false    
        end

        local dic_skill_ids = {}
        for i,v in ipairs(data.skill_ids) do
            dic_skill_ids[v.skill_id] = true
        end

        for i,v in ipairs(config) do
            local data = {}
            data.id = v.id
            data.index = v.seq
            if dic_skill_ids[v.id] then
                data.status = GuildskillConst.status.activity
            else
                data.status = GuildskillConst.status.un_activity
            end
            table_insert(object.skill_ids, data)
        end

        -- 对技能顺序做一个排序吧，主要是担心策划配置不是按照正常顺序来
        if next(object.skill_ids) then
            table_sort(object.skill_ids, function(a,b) 
                return a.index < b.index
            end)
        end
        self.career_skill_list[data.career] = object
        GlobalEvent:getInstance():Fire(GuildskillEvent.UpdateGuildSkillEvent, data.career)
    end
end

--初始化pvp技能信息
function GuildskillModel:initPvpCareerSkillInfo(data)
    if not data then return end
    self.dic_pvp_power_career = nil
    if self.pvp_career_skill_list == nil then
        self.pvp_career_skill_list = {}
    end

    for i,v in ipairs(data) do
        if v.career then
            self.pvp_career_skill_list[v.career] = v
            table_sort(v.attr_formation, SortTools.KeyLowerSorter("id"))
        end
    end    
    self:checkGuildPvpSkillRedStatus()
end

function GuildskillModel:getPvpskillInfoByCareer(career)
    if self.pvp_career_skill_list then
        return self.pvp_career_skill_list[career]
    end
end

function GuildskillModel:getPvpskillInfo()
    return self.pvp_career_skill_list 
end

function GuildskillModel:setPvpFisrtReset(is_first)
    self.is_pvp_first = is_first
end
--是否首次
function GuildskillModel:isPvpFisrtReset()
    return (self.is_pvp_first == true)
end

--获取每个career的战力加成
function GuildskillModel:getPvpPowerByCareerlist(list)
    if self.dic_pvp_power_career == nil then
        self.dic_pvp_power_career = {}
    end
    local total_power = 0
    for i,career in ipairs(list) do
        if self.dic_pvp_power_career[career] == nil then
            local pvp_career_data = self:getPvpskillInfoByCareer(career)
            if pvp_career_data  then
                local career_power = 0
                for _,v in ipairs(pvp_career_data.attr_formation) do
                    local key = getNorKey(v.id, v.lev)
                    local config =  Config.GuildSkillData.data_pvp_attr_info(key)
                    if config then
                        career_power = career_power + config.power
                    end
                end

                local key = getNorKey(career, pvp_career_data.skill_lev)
                local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
                if pvp_skill_config then
                    career_power = career_power + pvp_skill_config.power
                end
                self.dic_pvp_power_career[career] = career_power
            end
        end
        local power = self.dic_pvp_power_career[career] or 0
        total_power = total_power + power
    end
    return total_power
end

--重置某个职业信息
function GuildskillModel:resetCareerSkillInfo(career)
    -- body
    local object = self.career_skill_list[career]
    if object then
        object.group_id = math.floor(object.group_id/1000) * 1000 + 1
        object.group_ids = {}
        local config = Config.GuildSkillData.data_info_group[object.group_id]
        object.skill_ids = {}
        for i,v in ipairs(config) do
            local data = {}
            data.id = v.id
            data.index = v.seq
            data.status = GuildskillConst.status.un_activity
            table_insert(object.skill_ids, data)
        end
        object.had_skill_up = false

        GlobalEvent:getInstance():Fire(GuildskillEvent.ResetGuildSkillEvent, career)
    end 
end

--==============================--
--desc:获取指定职业的技能信息
--time:2018-06-20 11:00:23
--@career:
--@return 
--==============================--
function GuildskillModel:getCareerSkillInfo(career)
    return self.career_skill_list[career]
end

--获取各职业的公会技能等级
function GuildskillModel:getCareerSkillLevel(career)
    if self.career_skill_list and self.career_skill_list[career] then
        local skill_ids = self.career_skill_list[career].skill_ids
        local count = #self.career_skill_list[career].group_ids * 6
        for i,v in ipairs(skill_ids) do
            if v.status == GuildskillConst.status.activity then
                count = count + 1
            end
        end
        return count
    end
    return -1
end

--获取各职业的公会pvp技能和属性等级
function GuildskillModel:getCareerPvpSkillLevel(career)
    if self.pvp_career_skill_list and self.pvp_career_skill_list[career] then
        local attr_lev = 0
        local pvp_career_skill_data = self.pvp_career_skill_list[career]
        for i,v in ipairs(pvp_career_skill_data.attr_formation) do
            attr_lev = attr_lev + v.lev
        end
        local skill_lev = pvp_career_skill_data.skill_lev or 0
        return attr_lev, skill_lev
    end
    return -1
end

--==============================--
--desc:激活指定职业的技能信息
--time:2018-06-20 10:58:30
--@career:
--@skill_id:
--@return 
--==============================--
function GuildskillModel:updateGuildCareerSkill(career, skill_id)
    if career == nil or skill_id == nil then return end
    local object = self.career_skill_list[career]
    if object and object.skill_ids then
        for i, item in ipairs(object.skill_ids) do
            if item.id == skill_id then
                item.status = GuildskillConst.status.activity
                break
            end
        end
        object.had_skill_up = true
        -- 升级之后，这边做一次保存当前待升级的技能id
        local red_skill_id = 0
        for k,v in ipairs(object.skill_ids) do
            if v.status == GuildskillConst.status.un_activity then
                red_skill_id = v.id
                break
            end
        end
        self:updateGuildSkillStatus(career, red_skill_id)

        GlobalEvent:getInstance():Fire(GuildskillEvent.UpdateSkillStatusEvent, career, skill_id)
    end
end

--==============================--
--desc:升级指定职业的技能组，这个时候默认该技能组技能都未激活
--time:2018-06-20 10:57:38
--@career:
--@group_id:
--@return 
--==============================--
function GuildskillModel:upgradeGuildCareerSkill(career, group_id)
    if career == nil or group_id == nil then return end

    local object = self.career_skill_list[career]
    if object == nil then
        object = {}
        object.group_ids = {}
        self.career_skill_list[career] = object
    end

    if object.group_ids then
        table_insert(object.group_ids, {group_id=object.group_id})               -- 把当前的技能组插入到已激活的技能组列表中
    end
    object.career = career

    if object.group_id ~= group_id then
        object.group_id = group_id
        object.skill_ids = {}

        local config = Config.GuildSkillData.data_info_group[group_id] 
        if config == nil then 
            print("更新技能组出错，配置数据有问题，技能组id为：", group_id)
            return
        end
        object.had_skill_up = true
        for i,v in ipairs(config) do
            table_insert(object.skill_ids, {id = v.id, index = v.seq, status = GuildskillConst.status.un_activity})
        end
        
        if next(object.skill_ids) then
            table_sort(object.skill_ids, function(a,b) 
                return a.index < b.index
            end)
        end
    end

    -- 升级之后，这边做一次保存当前待升级的技能id
    local skill_id = 0
    for k,v in ipairs(object.skill_ids) do
        if v.status == GuildskillConst.status.un_activity then
            skill_id = v.id
            break
        end
    end
    self:updateGuildSkillStatus(career, skill_id)

    GlobalEvent:getInstance():Fire(GuildskillEvent.UpdateSkilUpgradeEvent, career, group_id)
end

--==============================--
--desc:获取当前技能组上线
--time:2018-06-21 11:57:24
--@career:
--@return 
--==============================--
function GuildskillModel:getCareerGroupMax(career)
    career = career or GuildskillConst.index.physics
    if self.career_group_max == nil then
        self.career_group_max = {}
    end
    if self.career_group_max[career] == nil then
        local config = Config.GuildSkillData.data_career_list[career] 
        if config then
            self.career_group_max[career] = #config 
        else
            self.career_group_max[career] = 0
        end
    end
    return self.career_group_max[career]
end

--==============================--
--desc:公会技能的初始化红点状态
--time:2018-06-23 12:03:54
--@data:
--@return 
--==============================--
function GuildskillModel:initGuildSkillStatus(data)
    if data and data.outline then
        self.skill_wait_upgrade_list = {}
        for i,v in ipairs(data.outline) do
            self.skill_wait_upgrade_list[v.career] = v.skill_id
        end
    end
    self:checkGuildSkillRedStatus()
end

--==============================--
--desc:更新当前技能
--time:2018-06-23 02:02:53
--@career:
--@skill_id:
--@return 
--==============================--
function GuildskillModel:updateGuildSkillStatus(career, skill_id)
    if self.skill_wait_upgrade_list == nil then
        self.skill_wait_upgrade_list = {}
    end
    self.skill_wait_upgrade_list[career] = skill_id
    self:checkGuildSkillRedStatus()
end

--==============================--
--desc:公会技能红点的算法更新
--time:2018-08-07 12:06:12
--@return 
--==============================--
function GuildskillModel:checkGuildSkillRedStatus()
    if self.skill_wait_upgrade_list == nil or next(self.skill_wait_upgrade_list) == nil then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    local backpack_model = BackpackController:getInstance():getModel()
    local max_lv_cfg = Config.GuildSkillData.data_const["max_lv"] -- 公会技能最大等级
    local max_lv = 40
    if max_lv_cfg then
        max_lv = max_lv_cfg.val
    end
    local red_list = {}
    for k, skill_id in pairs(self.skill_wait_upgrade_list) do
        local config = Config.GuildSkillData.data_info(skill_id)
        if config then
            red_list[k] = true
            if config.lev >= max_lv then
                red_list[k] = false
            elseif config.guild_lev > role_vo.guild_lev then
                red_list[k] = false
            else
                for i,v in ipairs(config.loss or {}) do
                    if v[1] and v[2] then
                        local bid = v[1]
                        local num = v[2]
                        local assert = Config.ItemData.data_assets_id2label[bid]
                        if assert then
                            if num > role_vo[assert] then
                                red_list[k] = false
                                break
                            end
                        else
                            local sum = backpack_model:getBackPackItemNumByBid(bid)
                            if num > sum then
                                red_list[k] = false
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    for k,v in pairs(red_list) do
        local id = self:getCareerKey(k)
        self:updateGuildRedStatus(id, v)
    end
end

function GuildskillModel:checkGuildPvpSkillRedStatus()
    if self.pvp_career_skill_list and next(self.pvp_career_skill_list) ~= nil then
        for k,pvp_career_skill_data in pairs(self.pvp_career_skill_list) do
            local total_status = false
            for i,v in ipairs(pvp_career_skill_data.attr_formation) do
                local key = getNorKey(v.id, v.lev)
                local config =  Config.GuildSkillData.data_pvp_attr_info(key)
                local status = true
                if config and next(config.loss) ~= nil then
                    for _,cost in ipairs(config.loss) do
                        local bid = cost[1]
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                        if have_num < cost[2] then
                            status = false
                        end
                    end
                else
                    --没有消耗 就木有红点了
                    status = false
                end
                if not total_status then
                    total_status = status
                end
                
            end
            if not total_status then
                total_status = self:checkGuildPvpOnlySkillRedpoit(pvp_career_skill_data.career, pvp_career_skill_data.skill_lev, pvp_career_skill_data.attr_formation)
            end
            local id = self:getPvpCareerKey(k)
            self:updateGuildPvpRedStatus(id, total_status)
        end   
    end
end

function GuildskillModel:checkGuildPvpOnlySkillRedpoit(career, skill_lev, attr_formation)
    if not career then return end
    if not skill_lev then return end
    if not attr_formation then return end

    local key = getNorKey(career, skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key) 
    if pvp_skill_config then
        for i,v in ipairs(attr_formation) do
            if v.lev < pvp_skill_config.need_lev then
                return false
            end
        end

        if next(pvp_skill_config.loss) ~= nil then
            for _,cost in ipairs(pvp_skill_config.loss) do
                local bid = cost[1]
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                if have_num < cost[2] then
                    return false
                end
            end
        else
            --没有消耗 就木有红点了
            return false
        end
        return true
    end
    return false
end

--==============================--
--desc:设置一个唯一id吧, 跟 guildconst.skill_2 ,3 ,4 ,5对应
--time:2018-08-07 06:00:23
--@career:
--@return 
--==============================--
function GuildskillModel:getCareerKey(career)
    career = career  or GuildskillConst.index.physics
    if career == GuildskillConst.index.magic then 
        return GuildConst.red_index.skill_2
    elseif career == GuildskillConst.index.physics then
        return GuildConst.red_index.skill_3
    elseif career == GuildskillConst.index.defence then
        return GuildConst.red_index.skill_4
    elseif career == GuildskillConst.index.assist then
        return GuildConst.red_index.skill_5
    else
        return GuildConst.red_index.skill_3
    end
end

--==============================--
--desc:设置一个唯一id吧, 跟 guildconst.skill_2 ,3 ,4 ,5对应
--time:2018-08-07 06:00:23
--@career:
--@return 
--==============================--
function GuildskillModel:getPvpCareerKey(career)
    career = career  or GuildskillConst.index.physics
    if career == GuildskillConst.index.magic then 
        return GuildConst.red_index.pvp_skill_2
    elseif career == GuildskillConst.index.physics then
        return GuildConst.red_index.pvp_skill_3
    elseif career == GuildskillConst.index.defence then
        return GuildConst.red_index.pvp_skill_4
    elseif career == GuildskillConst.index.assist then
        return GuildConst.red_index.pvp_skill_5
    else
        return GuildConst.red_index.pvp_skill_3
    end
end



--更新公会pvp技能红点
function GuildskillModel:updateGuildPvpRedStatus(bid, status)
    local base_data = Config.FunctionData.data_base
    local bool = MainuiController:getInstance():checkIsOpenByActivate(base_data[6].activate)
    if bool == false then return end

    local _status = self.pvp_skill_red_status_list[bid]
    if _status == status then return end

    self.pvp_skill_red_status_list[bid] = status
    
    -- 更新场景红点状态,只在登录的时候提示一次
    if self.had_send_mainui == false then
        self.had_send_mainui = true
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = bid, status = status}) 
    end

    -- 事件用于同步更新公会主ui的红点
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, bid, status)
end 
--==============================--
--desc:清楚主界面上面的红点
--time:2019-01-04 05:01:21
--@return 
--==============================--
function GuildskillModel:clearGuildSkillIconRed()
    if self.had_close_mainui == true then return end
    self.had_close_mainui = true

    local is_red = false
    for k,v in pairs(self.skill_red_status_list) do
        if v == true then
            is_red = true
            break
        end
    end
    if not is_red  then
        for k,v in pairs(self.pvp_skill_red_status_list) do
            if v == true then
                is_red = true
                break
            end
        end
    end

    if is_red == true then
        local data = {
            {bid = GuildConst.red_index.skill_2, status = false},{bid = GuildConst.red_index.skill_3, status = false},
            {bid = GuildConst.red_index.skill_4, status = false},{bid = GuildConst.red_index.skill_5, status = false},
            {bid = GuildConst.red_index.pvp_skill_2, status = false},{bid = GuildConst.red_index.pvp_skill_3, status = false},
            {bid = GuildConst.red_index.pvp_skill_4, status = false},{bid = GuildConst.red_index.pvp_skill_5, status = false}
        }
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, data) 
    end
end

--==============================--
--desc:更新公会技能红点
--time:2018-07-16 09:41:38
--@bid:
--@status:
--@return 
--==============================--
function GuildskillModel:updateGuildRedStatus(bid, status)
    local base_data = Config.FunctionData.data_base
    local bool = MainuiController:getInstance():checkIsOpenByActivate(base_data[6].activate)
    if bool == false then return end

    local _status = self.skill_red_status_list[bid]
    if _status == status then return end

	self.skill_red_status_list[bid] = status
	
	-- 更新场景红点状态,只在登录的时候提示一次
    if self.had_send_mainui == false then
        self.had_send_mainui = true
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = bid, status = status}) 
    end

	-- 事件用于同步更新公会主ui的红点
	GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, bid, status)
end 

function GuildskillModel:getRedStatus(career)
    local id = self:getCareerKey(career)
    local pvp_id = self:getPvpCareerKey(career)
    return self.skill_red_status_list[id] or self.pvp_skill_red_status_list[pvp_id]
end

function GuildskillModel:getRedTotalStatus()
    for k, _status in pairs(self.skill_red_status_list) do
        if _status == true then
            return true
        end
    end
    for k, _status in pairs(self.pvp_skill_red_status_list) do
        if _status == true then
            return true
        end
    end
    return false
end

function GuildskillModel:__delete()
end
