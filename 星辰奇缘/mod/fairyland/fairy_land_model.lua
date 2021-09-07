FairyLandModel = FairyLandModel or BaseClass(BaseModel)

function FairyLandModel:__init()
    self.main_win = nil
    self.status = 0 --"0未开始，1通知，2开始"
    self.left_time = 0 --"剩余时间(秒)"
    self.cur_fairy_data = nil

    self.fairylandLuckDrawWindow = nil -- 彩虹魔盒

    self.type_names = {[79650]=TI18N("绿"), [79651] = TI18N("蓝"), [79652]= TI18N("红")}
    self.type_name_colors = {[79650]="#4acb5b", [79651] = "#3084eb", [79652]= "#f6ab81"}

    self.fairy_box_names = {TI18N("铜") , TI18N("银"), TI18N("金")}

    self.luckDrawStatus = 0
    self.luckDrawTimeout = 0
    self.luckDrawLogs = {}
    self.luckDrawTimes = nil
    self.luckDrawId = nil
    self.luckDrawPrizes = {}
end

function FairyLandModel:__delete()

end

------------------------------打开界面和关闭界面逻辑
--打开主界面
-- function FairyLandModel:InitMainUI()
--     if self.main_win == nil then
--         self.main_win = FairyLandboxWindow.New(self)
--         self.main_win:Open()
--     else
--         -- self.main_win:update_question_info(self.cur_question_data)
--     end
-- end

-- function FairyLandModel:CloseMainUI()
--     if self.main_win ~= nil then
--         WindowManager.Instance:CloseWindow(self.main_win)
--     end
--     if self.main_win == nil then
--         -- print("===================self.main_win is nil")
--     else
--         -- print("===================self.main_win is not nil")
--     end
-- end


--打开手札界面
function FairyLandModel:InitLetterUI()
    if self.main_win == nil then
        self.main_win = FairyLandLetterWindow.New(self)
        self.main_win:Open()
    end
end

function FairyLandModel:CloseLetterUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end


--打开幻境宝箱界面
function FairyLandModel:InitBoxUI()
    if self.main_win == nil then
        self.main_win = FairyLandboxWindow.New(self)
        self.main_win:Open()
    end
end

function FairyLandModel:CloseBoxUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开幻境钥匙界面
function FairyLandModel:InitKeyUI()
    if self.main_win == nil then
        self.main_win = FairyLandKeyWindow.New(self)
        self.main_win:Open()
    end
end

function FairyLandModel:CloseKeyUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开彩虹魔盒界面
function FairyLandModel:InitFairylandLuckDrawWindow()
    if self.fairylandLuckDrawWindow == nil then
        self.fairylandLuckDrawWindow = FairylandLuckDrawWindow.New(self)
        self.fairylandLuckDrawWindow:Open()
    end
end

function FairyLandModel:CloseFairylandLuckDrawWindow()
    if self.fairylandLuckDrawWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.fairylandLuckDrawWindow)
    end
end

-----------------------------界面更新

--------------------------------数据随机筛选
function FairyLandModel:get_box_list(box_id, num)
    local data_list = {}
    local total = 0
    for i=1,#DataFairy.data_base do
        local data = DataFairy.data_base[i]
        if self:FilterCfgData(data) then 
            if data.box_id == box_id then
                table.insert(data_list, data)
                total = total + data.show_odds
            end
        end
    end

    -- data_list
    local temp_list = {}
    for i=1,num do
        local rand_num = math.floor(Random.Range(1,  total))

        for j=1,#data_list do
            local temp_data = data_list[j]
            if temp_data.show_odds >= rand_num then
                table.remove(data_list, j)
                table.insert(temp_list, temp_data)
                total = total - temp_data.show_odds
                break
            else
                rand_num = rand_num - temp_data.show_odds
            end
        end
    end
    local result_list = {}
    for k, v in pairs(temp_list) do
        table.insert(result_list, BaseUtils.copytab(v))
    end

    if #result_list < num then
        --随机补足到num个
        local remain_num = num - #result_list
        for i=1,remain_num do
            table.insert(result_list, result_list[i])
        end
    end

    return result_list
end


--根据传入的钥匙类型，判断当前已有钥匙，返回对应钥匙名字
function FairyLandModel:get_key_name(_type)
    if self.cur_fairy_data == nil then
        return nil
    end

    if _type == 1 then
        --铜
        if self:get_key_num(1) > 0 then
            return TI18N("<color='#b49e64'>铜钥匙</color>")
        elseif self:get_key_num(2) > 0 then
            return TI18N("<color='#d0cace'>银钥匙</color>")
        elseif self:get_key_num(3) > 0 then
            return TI18N("<color='#e1cb41'>金钥匙</color>")
        end
        return TI18N("<color='#b49e64'>铜钥匙</color>")
    elseif _type == 2 then
        --银
        if self:get_key_num(2) > 0 then
            return TI18N("<color='#d0cace'>银钥匙</color>")
        elseif self:get_key_num(3) > 0 then
            return TI18N("<color='#e1cb41'>金钥匙</color>")
        end
        return TI18N("<color='#d0cace'>银钥匙</color>")
    elseif _type == 3 then
        --金
        if self:get_key_num(3) > 0 then
            return TI18N("<color='#e1cb41'>金钥匙</color>")
        end
        return TI18N("<color='#e1cb41'>金钥匙</color>")
    end
    return nil
end

--传入钥匙类型获取当前已有钥匙的数量
function FairyLandModel:get_key_num(_type)
    for i=1,#self.cur_fairy_data.keys do
        local key = self.cur_fairy_data.keys[i]
        if key.type == _type then
            return key.num
        end
    end
    return 0
end

--根据传入钥匙类型，获取当前可以开启该类型的钥匙数量
function FairyLandModel:get_can_open_key_num(_type)
    -- body
    for i=1,#self.cur_fairy_data.keys do
        local key = self.cur_fairy_data.keys[i]
        if key.type >= _type then
            return key.num
        end
    end
    return 0
end

--传入宝箱id获取宝箱配置数据
function FairyLandModel:get_cfg_data(id)
    for i=1,#DataFairy.data_base do
        local data = DataFairy.data_base[i]
        if data.box_id == id then
            return data
        end
    end
end

--检查 下玩家是否已经在幻境场景中
function FairyLandModel:check_player_in_fairy_land()
    local cur_map_id = SceneManager.Instance:CurrentMapId()
    for k,v in pairs(DataFairy.data_layer) do
        if v.id ~= 99 then
            if v.map == cur_map_id then
                return false
            end
        end
    end
    return true
end

--获取魔盒抽奖奖品
function FairyLandModel:get_reward()
    local roleData = RoleManager.Instance.RoleData
    local list = {}
    for key,value in pairs(DataRaffle.data_reward) do
        if BaseUtils.SelectionSex(roleData.sex, value.sex) and BaseUtils.SelectionClasses(roleData.classes, value.classes) and roleData.lev >= value.lev_min and roleData.lev <= value.lev_max
            and  roleData.lev_break_times >= value.break_times_min and roleData.lev_break_times <= value.break_times_max then
            table.insert(list, value)
        end
    end
    return list
end

function FairyLandModel:FilterCfgData(cfg_data)
    if cfg_data.sex == 2 or cfg_data.sex == RoleManager.Instance.RoleData.sex then 
        if cfg_data.classes == 0 or cfg_data.classes == RoleManager.Instance.RoleData.classes then 
            if (cfg_data.lev_min < RoleManager.Instance.RoleData.lev and cfg_data.lev_max > RoleManager.Instance.RoleData.lev) then 
                return true
            end
        end
    end
    return false
end