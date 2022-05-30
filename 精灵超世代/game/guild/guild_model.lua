-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-30
-- --------------------------------------------------------------------
GuildModel = GuildModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort

function GuildModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildModel:config()
    self.guild_cache_list = {}      -- 缓存的当前服务器列表
    self.guild_apply_list = {}      -- 公会申请列表
    self.donate_sum = 0             -- 今天已经捐献的次数
    self.guild_member_list = {}     -- 成员列表
    self.guild_list = {}            -- 当前所有的公会列表
    self.guild_search_list = {}     -- 当前待查找的公会列表
    self.my_guild_assistant = {}    -- 当前副会长的数据
    self.guild_red_status_list = {} -- 公会红点的状态
    self.guild_donate_activity_list = {}    -- 捐献活跃宝箱清空
    self.guild_notice_list = {}     -- 公会日志列表
end

function GuildModel:updateGuildList(name, data_list)
    if name == "" then      -- 这个就是全部的公会列表
        self.guild_list = {}
        for i,v in ipairs(data_list) do
            local guild_vo = self.guild_cache_list[getNorKey(v.gid, v.gsrv_id)]
            if guild_vo == nil then
                guild_vo = GuildListVo.New()
                self.guild_cache_list[getNorKey(v.gid, v.gsrv_id)] = guild_vo
            end
            guild_vo:updateData(v)
            table_insert(self.guild_list, guild_vo)
        end
    else
        self.guild_search_list = {}
        for i, v in ipairs(data_list) do
            local guild_vo = self.guild_cache_list[getNorKey(v.gid, v.gsrv_id)]
            if guild_vo == nil then
                guild_vo = GuildListVo.New()
                self.guild_cache_list[getNorKey(v.gid, v.gsrv_id)] = guild_vo
            end
            guild_vo:updateData(v)
            table_insert(self.guild_search_list, guild_vo)
        end 
    end
    local type = GuildConst.list_type.total
    local guild_list = self.guild_list
    if name ~= "" then
        type = GuildConst.list_type.search
        guild_list = self.guild_search_list
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildList, type, guild_list) 
end

--==============================--
--desc:申请某个公会的返回
--time:2018-05-31 02:08:41
--@gid:
--@gsrv_id:
--@return 
--==============================--
function GuildModel:updateGuildApplyStatus(gid, gsrv_id, is_apply)
    local guild_list_vo = self.guild_cache_list[getNorKey(gid, gsrv_id)]
    if guild_list_vo ~= nil then
        guild_list_vo:setGuildAttribute("is_apply", is_apply)
    end
end

--==============================--
--desc:更新自己公会的基础信息
--time:2018-05-31 07:35:29
--@data:
--@return 
--==============================--
function GuildModel:updateMyGuildInfo(data)
    if self.my_guild_info == nil then
        self.my_guild_info = GuildMyInfoVo.New()
    end
    self.my_guild_info:updateData(data)
end

--==============================--
--desc:清空自己本地缓存的客户端数据
--time:2018-05-31 07:33:36
--@return 
--==============================--
function GuildModel:clearMyGuildInfo()
    self.my_guild_info = nil
    self.guild_red_status_list = {}
    self.my_guild_assistant = {}
    self.guild_member_list = {}
    self.guild_donate_activity_list = {}

    -- 这里需要做清楚红点操作
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild)
end

--==============================--
--desc:获取自己公会信息
--time:2018-05-31 07:47:49
--@return 
--==============================--
function GuildModel:getMyGuildInfo()
    return self.my_guild_info
end

--==============================--
--desc:更新成员列表，增删
--time:2018-05-31 09:04:50
--@data_list:
--@type:"0:更新 1:添加 2:删除" 
--@return 
--==============================--
function GuildModel:updateMyGuildMemberList(data_list,type)
    -- print("0:更新 1:添加 2:删除......",type)
    local role_vo = RoleController:getInstance():getRoleVo() 
    if role_vo == nil then return end 
    if type == 2 then       -- 删除
        for i,v in ipairs(data_list) do
            self.guild_member_list[getNorKey(v.rid, v.srv_id)] = nil

            if self.my_guild_assistant[getNorKey(v.rid, v.srv_id)] ~= nil then
                self.my_guild_assistant[getNorKey(v.rid, v.srv_id)] = nil
                -- 这里抛出时间更新副会长的数量吧
                if role_vo.position ~= GuildConst.post_type.member then
                    GlobalEvent:getInstance():Fire(GuildEvent.UpdateAssistantNumEvent)
                end
            end
        end 
    else
        local member_vo = nil
        for i,v in ipairs(data_list) do
            member_vo = self.guild_member_list[getNorKey(v.rid, v.srv_id)]
            -- 如果之前存在副会长，但是现在没有了的话，就移除掉
            if self.my_guild_assistant[getNorKey(v.rid, v.srv_id)] ~= nil then
                if v.post ~= GuildConst.post_type.assistant then
                    self.my_guild_assistant[getNorKey(v.rid, v.srv_id)] = nil
                    if role_vo.position ~= GuildConst.post_type.member then 
                        GlobalEvent:getInstance():Fire(GuildEvent.UpdateAssistantNumEvent) 
                    end
                end
            else
                if v.post == GuildConst.post_type.assistant then
                    self.my_guild_assistant[getNorKey(v.rid, v.srv_id)] = v 
                    if role_vo.position ~= GuildConst.post_type.member then 
                        GlobalEvent:getInstance():Fire(GuildEvent.UpdateAssistantNumEvent) 
                    end
                end
            end

            if member_vo == nil then
                member_vo = GuildMemberVo.New()
                self.guild_member_list[getNorKey(v.rid, v.srv_id)] = member_vo
            end
            if v.is_self == nil then
                v.is_self = RoleController:getInstance():checkIsSelf(v.srv_id, v.rid)       -- 当前是不是自己
            end
            v.role_post = role_vo.position                                              -- 自己的职位
            
            member_vo:updateData(v)
        end
    end
    -- 只有是增，删才处理这个事件 1:添加 2:删除
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateMyMemberListEvent, type)
end

--==============================--
--desc:自己职位变化的时候更改一下成员列表里面的自己职位数据
--time:2018-06-03 04:46:05
--@value:
--@return 
--==============================--
function GuildModel:updateMemberByPosition(value)
    if self.guild_member_list ~= nil then
        for k,v in pairs(self.guild_member_list) do
            v:setGuildAttribute("role_post", value)
        end
    end
end

--==============================--
--desc:获取当前副会长的总数
--time:2018-06-01 11:28:28
--@return 
--==============================--
function GuildModel:getAssistantSum()
    if self.my_guild_assistant == nil then 
        return 0 
    end
    local sum = 0
    for k,v in pairs(self.my_guild_assistant) do
        sum = sum + 1
    end
    return sum
end

--==============================--
--desc:获取成员列表
--time:2018-05-31 09:13:41
--@return 
--==============================--
function GuildModel:getGuildMemberList(show_type)
    local sort_keys = {}
    local member_list = {}
    local role_vo = RoleController:getInstance():getRoleVo()
    for k,v in pairs(self.guild_member_list) do
        local temp_status = false
        if show_type == GuildConst.show_type.all then
            temp_status = true
        elseif show_type == GuildConst.show_type.guild_war and v.day_war_time > 0 then --公会战有剩余挑战次数
            temp_status = true
        elseif show_type == GuildConst.show_type.guild_donate and v.day_donate == 0 then --无公会捐献
            temp_status = true
        elseif show_type == GuildConst.show_type.guild_voyage and v.day_dun_time > 0 then --有副本剩余购买次数
            temp_status = true
        end
        if temp_status then
            if show_type == GuildConst.show_type.all then
                table_insert(member_list, v)
            else
                if not role_vo:isSameRole(v.srv_id, v.rid) then -- 筛选列表不需要显示本身
                    table_insert(member_list, v)
                end
            end
        end
    end
    if show_type == GuildConst.show_type.all then
        sort_keys = {"online", "post_sort"}
    elseif show_type == GuildConst.show_type.guild_war then
        sort_keys = {"online", "post_sort", "day_war_time"}
    elseif show_type == GuildConst.show_type.guild_donate then
        sort_keys = {"online", "post_sort", "day_donate"}
    elseif show_type == GuildConst.show_type.guild_voyage then
        sort_keys = {"online", "post_sort", "day_dun_time"}
    end
    
    if #member_list > 1 and #sort_keys > 0 then
        local sort_func = SortTools.tableUpperSorter(sort_keys)
        table_sort(member_list, sort_func)
    end
    return member_list
end

--==============================--
--desc:更新玩家捐献情况
--time:2018-06-04 11:48:00
--@data_list:
--@return 
--==============================--
function GuildModel:updateDonateInfo(data_list)
    if data_list == nil then return end
    self.donate_sum = 0
    self.donate_list = {}
    for i,v in ipairs(data_list) do
        self.donate_list[v.type] = v.num
        self.donate_sum = self.donate_sum + v.num
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateDonateInfo)
    -- 设置红点
    self:updateGuildRedStatus(GuildConst.red_index.donate, (self.donate_sum <= 0))
end

--==============================--
--desc:这里表示捐献成功了
--time:2018-06-23 10:43:21
--@return 
--==============================--
function GuildModel:setGuildDonateStatus()
    self.donate_sum = self.donate_sum + 1
    self:updateGuildRedStatus(GuildConst.red_index.donate, false) 
end

--==============================--
--desc:判断某一个捐献状态
--time:2018-06-04 01:52:49
--@type:
--@return: 是否可以捐献，当前捐献次数
--==============================--
function GuildModel:checkDonateStatus(type)
    local num = 0
    if self.donate_list and self.donate_list[type] then
        num = self.donate_list[type]
    end
    return (self.donate_sum > 0), (num and num > 0)
end 

--==============================--
--desc:更新申请列表，
--time:2018-06-04 05:06:30
--@data_list:
--@return 
--==============================--
function GuildModel:updateGuildApplyList(data_list)
    self.guild_apply_list = {}
    for i,v in ipairs(data_list) do
        self.guild_apply_list[getNorKey(v.rid, v.srv_id)] = v
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateApplyListInfo)
    self:clearApplyRedStatus()
end

--==============================--
--desc:处理完成某个玩家申请请求之后，在总的申请列表中删除这个数据
--time:2018-06-04 05:08:22
--@rid:
--@srv_id:
--@return 
--==============================--
function GuildModel:deleteApplyInfo(rid, srv_id)
    if self.guild_apply_list[getNorKey(rid, srv_id)] ~= nil then
        self.guild_apply_list[getNorKey(rid, srv_id)] = nil
        GlobalEvent:getInstance():Fire(GuildEvent.UpdateApplyListInfo)
        self:clearApplyRedStatus()
    end
end

--==============================--
--desc:清楚公会申请红点状态
--time:2018-06-09 11:01:23
--@return 
--==============================--
function GuildModel:clearApplyRedStatus()
    if tableLen(self.guild_apply_list) == 0 then
        self:updateGuildRedStatus(GuildConst.red_index.apply, false)
    end 
end

--==============================--
--desc:获取当前申请列表，按照在线，战力以及vip等级从打到小排序
--time:2018-06-04 05:22:52
--@return 
--==============================--
function GuildModel:getGuildApplyList()
    local apply_list = {}
    for k,v in pairs(self.guild_apply_list) do
        table_insert(apply_list, v)
    end
    -- 做一个排序吧
    if #apply_list > 1 then
        local sort_func = SortTools.tableUpperSorter({"is_online", "power", "vip_lev"})
        table_sort(apply_list, sort_func) 
    end
    return apply_list
end

--==============================--
--desc:处理公会红点的状态
--time:2018-06-07 09:46:38
--@type:
--@status:
--@return 
--==============================--
function GuildModel:updateGuildRedStatus(type, status)
    local base_data = Config.FunctionData.data_base
    local bool = MainuiController:getInstance():checkIsOpenByActivate(base_data[6].activate)
    if bool == false then return end

    local _status = self.guild_red_status_list[type]
    if _status == status then return end

	self.guild_red_status_list[type] = status

    if type ~= GuildConst.red_index.notice and type ~= GuildConst.red_index.skill_2 and type ~= GuildConst.red_index.skill_3 and 
    type ~= GuildConst.red_index.skill_4 and type ~= GuildConst.red_index.skill_5 and 
    type ~= GuildConst.red_index.pvp_skill_2 and type ~= GuildConst.red_index.pvp_skill_3 and 
    type ~= GuildConst.red_index.pvp_skill_4 and type ~= GuildConst.red_index.pvp_skill_5 then --公会日志、技能不需要更新公会UI红点
        -- 更新场景红点状态
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid=type, status=status})
    end

    -- 事件用于同步更新公会主ui的红点
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, type, status)
end

--联盟活跃红点
function GuildModel:updataGuildActionRedStatus(data)
    self.goal_data = data
    local red = false
    local lev_data = Config.GuildQuestData.data_lev_data
    if data.lev < #lev_data and data.exp >= lev_data[data.lev].exp then
        red = true
    end
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = GuildConst.red_index.goal_action, status = red}) 

    self:updateGuildRedStatus(GuildConst.red_index.goal_action, red)
end

function GuildModel:getGoalRedStatus()
    if self.goal_data == nil or not next(self.goal_data) then return end
    local status = false
    local lev_data = Config.GuildQuestData.data_lev_data
    if self.goal_data.lev < #lev_data and self.goal_data.exp >= lev_data[self.goal_data.lev].exp then
        status = true
    end
    return status
end

-- 获取公会活跃等级
function GuildModel:getGuildActiveLev(  )
    if self.goal_data then
        return self.goal_data.lev or 0
    end
    return 0
end

--==============================--
--desc:判断某个类型的红点状态
--time:2018-06-07 10:34:01
--@type:
--@return 
--==============================--
function GuildModel:getRedStatus(type)
    return self.guild_red_status_list[type]
end

--==============================--
--desc:判断是否有捐献红点
--time:2018-07-16 09:24:22
--@return 
--==============================--
function GuildModel:getDonateRedStatus()
    local status = self:getRedStatus(GuildConst.red_index.donate)
    if status == true then 
        return status
    end
    status = self:getRedStatus(GuildConst.red_index.donate_activity)
    return status
end

--==============================--
--desc:捐献活跃宝箱情况
--time:2018-07-11 02:16:31
--@boxes:
--@donate_exp:
--@return 
--==============================--
function GuildModel:updateDonateBoxInfo(boxes, donate_exp)
    self.guild_donate_activity_list = {}
    self.guild_donate_activity = donate_exp     -- 当前公会捐献活跃度
    for i,v in ipairs(boxes) do
        self.guild_donate_activity_list[v.box_id] = true
    end
    self:checkDonateActivity()
end

--==============================--
--desc:设置某个捐献宝箱的状态
--time:2018-07-11 02:22:42
--@box_id:
--@return 
--==============================--
function GuildModel:setDonateBoxStatus(box_id)
    if self.guild_donate_activity_list == nil then
        self.guild_donate_activity_list = {}
    end
    self.guild_donate_activity_list[box_id] = true
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateDonateBoxStatus, box_id)
    self:checkDonateActivity()
end

--==============================--
--desc:别人捐献的时候更新当前捐献进度,可能同步会有红点提示
--time:2018-07-11 02:23:19
--@value:
--@return 
--==============================--
function GuildModel:updateDonateActivity(value)
    self.guild_donate_activity = value
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateDonateBoxStatus)
    self:checkDonateActivity()
end

--==============================--
--desc:监测是否有公会捐献活跃宝箱
--time:2018-07-16 09:16:54
--@return 
--==============================--
function GuildModel:checkDonateActivity()
    local activity = self.guild_donate_activity or 0
    local red_status = false
    for i, v in ipairs(Config.GuildData.data_donate_box) do
        if activity >= v.box_val and (not self.guild_donate_activity_list[i]) then
            red_status = true
            break
        end
    end 
    self:updateGuildRedStatus(GuildConst.red_index.donate_activity, red_status)
end

--==============================--
--desc:返回捐献活跃度的值
--time:2018-07-11 03:44:46
--@return 
--==============================--
function GuildModel:getDonateActivityValue()
    return self.guild_donate_activity or 0
end

--==============================--
--desc:获取捐献宝箱状态
--time:2018-07-11 03:45:14
--@id:
--@return 
--==============================--
function GuildModel:getDonateBoxStatus(id)
    return self.guild_donate_activity_list[id]
end

--==============================--
--desc:公会日志列表
--@return 
--==============================--
function GuildModel:initGuildNoticeList(data_list)
    if not data_list then return end

    self.guild_notice_list = {}
    for i,v in ipairs(data_list) do
        local key = TimeTool.getMD3(v.time) -- X月-X日
        if not self.guild_notice_list[key] then
            self.guild_notice_list[key] = {}
        end
        local notice_vo =  GuildNoticeVo.New()
        notice_vo:updateData(v)
        table_insert(self.guild_notice_list[key], notice_vo)
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildNoticeList)
end

function GuildModel:getGuildNoticeList(show_type)
    local show_type = show_type
    local list, temp_list = {}, {}
    local key_list = {}
    for day,item in pairs(self.guild_notice_list) do
        table_insert(key_list, TimeTool.getMixTime(day))
        for _,data in pairs(item) do
            if not list[day] then
                list[day] = {}
            end
            if show_type == GuildConst.show_type.all then
                table_insert(list[day], data)
            else
                if data.type == show_type then
                    table_insert(list[day], data)
                end
            end
        end
        if next(list[day]) == nil then
            list[day] = nil
        end
    end
    for _,v in pairs(list) do
        if #v > 1 then
            table.sort(v, SortTools.KeyUpperSorter("time"))
        end
    end
    table_sort(key_list, function(a, b)
        if tonumber(a) > tonumber(b) then 
            return true
        end
        return false
    end)
    for _,value in pairs(key_list) do
        local value = TimeTool.getSplitTime(value)
        if list[value] and next(list[value]) ~= nil then
            table_insert(temp_list, list[value])
        end
    end
    return temp_list
end

--==============================--
--desc:新增公会日志
--@return 
--==============================--
function GuildModel:addGuildNoticeItem(data_list)
    if not data_list or next(data_list) == nil then return end
    for i,v in ipairs(data_list) do
        local key = TimeTool.getMD3(v.time) -- X月-X日
        if not self.guild_notice_list[key] then
            self.guild_notice_list[key] = {}
        end
        local notice_vo =  GuildNoticeVo.New()
        notice_vo:updateData(v)
        table_insert(self.guild_notice_list[key], notice_vo)
    end
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildNoticeList)
end

function GuildModel:__delete()
end
