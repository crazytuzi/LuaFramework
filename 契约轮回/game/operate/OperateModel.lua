--
-- @Author: LaoY
-- @Date:   2019-01-05 15:04:29
--
OperateModel = OperateModel or class("OperateModel", BaseModel)

function OperateModel:ctor()
    OperateModel.Instance = self

    self.act_no = 1.0
    -- 活动配置，请求php
    self.act_config = Config.db_yunying
    self.fest_config = Config.db_festival
    -- 活动奖励配置
    self.act_reward_config = {}
    for k, cf in pairs(Config.db_yunying_reward) do
        self.act_reward_config[cf.act_id] = self.act_reward_config[cf.act_id] or {}
        self.act_reward_config[cf.act_id][cf.id] = cf
    end
    for k, cf in pairs(Config.db_festival_reward) do
        self.act_reward_config[cf.act_id] = self.act_reward_config[cf.act_id] or {}
        self.act_reward_config[cf.act_id][cf.id] = cf
    end
    self.ingore_lv_act_type_list = { 781, 782, 783 }
    self:Reset()
end

function OperateModel:Reset()
    -- 活动开启信息列表
    self.act_list = {}
    -- 活动信息列表
    self.act_info_list = {}

    -- 活动红点列表
    self.act_red_dot = {}
    -- 活动对应的界面
    self.act_panel_list = {}
end

function OperateModel.GetInstance()
    if OperateModel.Instance == nil then
        OperateModel()
    end
    return OperateModel.Instance
end

function OperateModel:RequestConfig()
    local function call_back(cf_str)
        local str = cf_str
        str = string.gsub(str, "Config = Config or {}", "")
        str = string.gsub(str, "Config.db_yunying = ", "")
        local tab = LuaString2Table(str)
        if not table.isempty(tab) then
            self.act_config = tab
        end
    end
    HttpManager:GetInstance():ResponseGetText(AppConfig.YunYingUrl, call_back)
end

function OperateModel:SetConfig(cf)
    self.act_config = cf
end

function OperateModel:GetConfig(id)
    return self.act_config[id] or self.fest_config[id]
end

function OperateModel:AddRewardConfigList(list)
    local len = #list
    for i = 1, len do
        local cf = list[i]
        self:AddRewardConfig(cf.act_id, cf.id, cf)
    end
end

function OperateModel:AddRewardConfig(act_id, reward_id, config)
    self.act_reward_config[act_id] = self.act_reward_config[act_id] or {}
    self.act_reward_config[act_id][reward_id] = config
end

function OperateModel:GetRewardConfig(act_id, reward_id)
    if not self.act_reward_config[act_id] then
        return nil
    end
    if reward_id then
        return self.act_reward_config[act_id][reward_id]
    end
    return self.act_reward_config[act_id]
end

function OperateModel:AddActList(list)
    --logError("add act list-"..Table2String(list))
    local len = #list
    for i = 1, len do
        local data = list[i]
        self:AddAct(data)
    end
end

function OperateModel:AddAct(data)
    --logError("add act id-"..data.id)
    self.act_list[data.id] = data
    if not self.act_info_list[data.id] then
        OperateController:GetInstance():Request1700006(data.id)
    end
    if data.id == 175000 then
        OperateController:GetInstance():Request1700015(data.id)
    end
  
    self:UpdateIcon(data.id, data)
    
    if data.id == 100003 then
        self:UpdateIconReddot(data.id,true)
    end

    --显示寻宝活动 显示图标红点
    if Config.db_yunying[data.id] and Config.db_yunying[data.id].panel == "191@1" then
        self:UpdateIconReddot(data.id,true)
    end
end

function OperateModel:GetAct(id)
    return self.act_list[id]
end

function OperateModel:DelAct(id)
    if not self.act_list[id] then
        return
    end
    self.act_list[id] = nil
    self:UpdateIcon(id)
    self:UpdateIconReddot(id, nil)
end

function OperateModel:UpateAct(data)
    self.act_list[data.id] = data
    self:UpdateIcon(data.id)
end

function OperateModel:UpdateInfo(info)
    self.act_info_list[info.id] = info
end

function OperateModel:UpdateRewardInfo(data)
    local actId = data.act_id
    local awardId = data.id
    local info = self.act_info_list[actId]
    for i = 1, #self.act_info_list[actId].tasks do
        if self.act_info_list[actId].tasks[i].id == awardId then
            self.act_info_list[actId].tasks[i].state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
        end
    end
end

--[[
	@author LaoY
	@des	刷新右上角图标展示
	@param1 id 		必填；带参数表示只改变了一个，不需要全部刷新
--]]
function OperateModel:UpdateIcon(id, data)
    if LoginModel.IsIOSExamine then
        return
    end
    local key_str = self:GetActKey(id)
    if not key_str then
        return
    end
    local top_right_cf = IconConfig.TopRightConfig[key_str]
    local top_left_cf = IconConfig.TopLeftConfig[key_str]
    local icon_cf = top_right_cf or top_left_cf
    if not icon_cf then
        return
    end
    self.act_panel_list[key_str] = self.act_panel_list[key_str] or {}
    if not self.act_list[id] then
        local del_tab = {}
        local len = #self.act_panel_list[key_str]
        for i = 1, len do
            if id == self.act_panel_list[key_str][i] then
                del_tab[#del_tab + 1] = i
                break
            end
        end
        table.RemoveByIndexList(self.act_panel_list[key_str], del_tab)

        -- test
        -- Yzprint('--LaoY OperateModel.lua,line 168--',id)
        -- Yzdump(del_tab,"tab")
        -- Yzprint('--LaoY OperateModel.lua,line 169--')
        -- Yzdump(self.act_panel_list[key_str],"self.act_panel_list[key_str]")
        -- table.RemoveByIndexList(self.act_panel_list[key_str], del_tab)
        -- Yzprint('--LaoY OperateModel.lua,line 170--',data)
        -- Yzdump(self.act_panel_list[key_str],"self.act_panel_list[key_str]")
    else
        local is_contain_id = false
        for k, _id in pairs(self.act_panel_list[key_str]) do
            if id == _id then
                is_contain_id = true
                local right_cf = IconConfig.TopRightConfig[key_str]
                local right_cf = IconConfig.TopLeftConfig[key_str]
                local icon_cf = right_cf or right_cf
                if (not icon_cf) or icon_cf.is_always_update == false then
                    return
                end
            end
        end
        local list = self.act_panel_list[key_str]
        if not is_contain_id then
            table.insert(list, id)
        end
    end
    if key_str == "sevenDayActive" or key_str == "mergeSer" then
        local time_str, del_time, is_show_end = self:InitIconCDShow(key_str)
        GlobalEvent:Brocast(MainEvent.ChangeLeftIcon, key_str, true, nil, time_str, del_time, false, is_show_end, true, id)
        return
    end

    if icon_cf.is_mul then
        if not self.act_list[id] then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key_str, false, id)
        else
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key_str, true, id)
        end
    else
        if table.isempty(self.act_panel_list[key_str]) then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key_str, false)
        else
            local time_str, del_time, is_show_end = self:InitIconCDShow(key_str)
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key_str, true, nil, time_str, del_time, false, is_show_end, true, id)
        end
    end
end

function OperateModel:InitIconCDShow(key)
    local tbl = self.act_panel_list[key]
    if not tbl then
        return
    end
    local etime = 0
    local show_time = 0
    --是否显示已结束字样
    local is_show_end = false
    --有正在进行的活动
    local is_have_ongoing_act = false
    for i = 1, #tbl do
        local act_id = tbl[i]
        local data = self.act_list[act_id]
        if data then
            if data.act_etime and data.act_etime ~= 0 then
                --有效的结束时间
                if data.act_etime > os.time() then
                    is_have_ongoing_act = true
                    if data.act_etime > etime then
                        etime = data.act_etime
                    end
                end
            end
            local show_etime = data.show_etime
            if show_etime and show_etime ~= 0 then
                if show_etime > os.time() and show_etime > show_time then
                    show_time = show_etime
                end
            end
        end
    end
    --没有正在进行中的活动，有活动处于展示时间
    if (not is_have_ongoing_act) and show_time > 0 then
        is_show_end = true
    end
    --结束时间戳
    local time_str
    --删除时间戳
    local del_time
    --有正在进行中的活动
    if is_have_ongoing_act then
        time_str = etime
    elseif show_time > 0 then
        time_str = show_time
    end
    if show_time > 0 then
        del_time = show_time
    end
    return time_str, del_time, is_show_end
end

function OperateModel:UpdateIconReddot(id, param)

    if self.act_red_dot[id] == param then
        return
    end

    self.act_red_dot[id] = param
    -- 派发事件

    local key_str = self:GetActKey(id)
    if not key_str then
        return
    end
    -- 派发事件
    GlobalEvent:Brocast(OperateEvent.UPDATEREDDOT, key_str, id, param)

    -- 右上角图标事件
    local bo = self:GetReddotByKey(key_str, id)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, key_str, bo, id)
end

function OperateModel:GetActKey(id)
    local act_cf = self:GetConfig(id)
    if not act_cf then
        return nil
    end
    local link_cf = GetOpenByKey(act_cf.panel)
    if not link_cf then
        return nil
    end
    return link_cf.key_str
end

-- 获取单个活动的红点
function OperateModel:GetReddotById(id)
    return self.act_red_dot[id]
end

-- 获取图标的红点，部分图标对应的界面是多个活动组成，只要其中一个活动有红点，图标就要显示红点
-- 可能存在多个同一活动，出现多个相同图标 用id区别
function OperateModel:GetReddotByKey(key, id)
    -- 如果是同一个图标会出现多个的，判断单独活动即可
    if id and MainModel:GetInstance():TopRightIconIsMul(key) then
        return self:GetReddotById(id)
    else
        local list = self.act_panel_list[key]
        if table.isempty(list) then
            return false
        end
        for k, id in pairs(list) do
            local bo = self:GetReddotById(id)
            if bo then
                return bo
            end
        end
    end
    return false
end

function OperateModel:GetActInfo(id)
    return self.act_info_list[id]
end

function OperateModel:GetRewardInfo(act_id, rewa_id)
    local info = self.act_info_list[act_id]
    local result
    if info then
        local list = info.tasks
        for i = 1, #list do
            local info = list[i]
            if info.id == rewa_id then
                result = info
                break
            end
        end
    end
    return result
end

function OperateModel:IsActOpen(id)
    local key_str = self:GetActKey(id)
    if self.act_panel_list[key_str] then
        return true
    end
    return false
end

function OperateModel:IsActOpenByTime(id)
    if self.act_list[id] then
        local actInfo = self.act_list[id]
        if (os.time() > actInfo.act_stime and os.time() < actInfo.act_etime) or (os.time() > actInfo.show_stime and os.time() < actInfo.show_etime) then
            return true
        end
    end
    return false
end

function OperateModel:GetActIdByType(type)
    local actId = 0
    --dump(self.act_list)
    --  dump(self.act_info_list)
    -- for id, v in pairs(self.act_list) do
    --     local cfg = self.act_config[id]
    --     if  cfg then
    --         if cfg.type == type then
    --             if (os.time() > v.act_stime and os.time() < v.act_etime) or (os.time() > v.show_stime and os.time() < v.show_etime) then
    --                 actId = cfg.id
    --             end
    --         end
    --     end
    -- end

    local cur_time = os.time()
    for id, v in pairs(self.act_list) do
        local cfg = self.act_config[id] or self.fest_config[id]
        if cfg then
            if cfg.type == type then
                if (cur_time > v.act_stime and cur_time < v.act_etime) or (cur_time > v.show_stime and cur_time < v.show_etime) then
                    actId = cfg.id
                    break
                end
            end
        end
    end
    return actId
end

--%获取主题抽奖当前的活动id
function OperateModel:GetCurrentAct()
    for id, _ in pairs(self.act_list) do
        if Config.db_yunying[id] and Config.db_yunying[id].panel ~= "" then
            local arr = string.split(Config.db_yunying[id].panel, "@")
            if tonumber(arr[1]) == 875 then
                return id
            end
        end
    end
end

--获取小R活动的活动id列表
function OperateModel:GetSmallRActIds()
    local id_list = {}

    for id, _ in pairs(self.act_list) do
        if Config.db_yunying[id] and Config.db_yunying[id].panel ~= "" then
            if string.find(Config.db_yunying[id].panel, "876") then
                table.insert(id_list, id)
            end
        end
    end

    return id_list
end

--获取运营活动结束时间
function OperateModel:GetActEndTimeByActId(act_id)
    local info = self:GetAct(act_id)
    if not info then
        return
    end
    return info.act_etime
end

--获取运营活动展示结束时间
function OperateModel:GetActShowTimeByActId(act_id)
    local info = self:GetAct(act_id)
    if not info then
        return
    end
    return info.show_etime
end

function OperateModel:GetActStartTimeByActId(act_id)
    local info = self:GetAct(act_id)
    if not info then
        return
    end
    return info.act_stime
end

-- 通过类型得到 当前开启的 打包带走
function OperateModel:GetPackMallID()
    for id, _ in pairs(self.act_list) do
        local c = Config.db_yunying[id]
        if c and c.type == 720 then
            return id
        end
    end
end

--获取该图标第一个正在开启的活动配置 用图标Key值
function OperateModel:GetOpeningActCfByKey(key, id)
    local first_act_id
    if id then
        first_act_id = id
    else
        local panel_list = self.act_panel_list[key]
        if panel_list == nil or table.isempty(panel_list) then
            return
        end
        first_act_id = panel_list[1]
    end
    return self:GetConfig(first_act_id)
end

--获取节日活动图标资源
function OperateModel:GetIconNameByKey(key, id)
    local name = ""
    local cf = self:GetOpeningActCfByKey(key, id)
    if not cf then
        return name
    end
    local tbl = String2Table(cf.icon)
    return tbl[1]
end

--获取运营活动商店配置 id：奖励id
function OperateModel:GetShopCfByRewaId(rewa_id)
    local cf = Config.db_yunying_lottery_shop
    local result
    for i = 1, #cf do
        local data = cf[i]
        if data.id == rewa_id then
            result = data
            break
        end
    end
    return result
end

function OperateModel:CheckIsIgnoreLv(act_id)
    local cf = self:GetConfig(act_id)
    if not cf then
        return false
    end
    local id_type = cf.type
    local type_list = self.ingore_lv_act_type_list
    local is_ignore = false
    for i = 1, #type_list do
        if id_type == type_list then
            is_ignore = true
            break
        end
    end
    return is_ignore
end