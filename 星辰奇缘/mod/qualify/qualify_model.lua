QualifyModel = QualifyModel or BaseClass(BaseModel)

function QualifyModel:__init()
    self.qualifying_activitys = nil
    --请求段位排行榜返回
    self.rank_max_indexs = nil
    --请求可参与次数
    self.count_list = nil

    --战斗结果
    self.qualifying_result = nil

    --请求段位信息
    self.mine_qualify_data = nil

    self.match_state_data = nil

    --匹配成功
    self.match_data = nil

    self.match_timer_id = 0
    self.total_time = 0

    self.activity_time = 0

    self.activity_state = 0

    --当前匹配状态
    self.sign_type = 0

    self.qualifying_type = {
        type_1 = 1
    }

    self.rank_type = {
        friend = 1, --好友
        all = 2 --总榜
    }

    self.max_qualify_lev = 30

    self.max_match_time = 8

    self.season_time = 0 --赛季结束时间戳

    self.open_lock_data = nil

    self.main_win = nil
    self.match_win = nil
    self.finish_win = nil

    self.my_best_win = nil
    self.open_lock_win = nil
end

function QualifyModel:__delete()

end

---------------------------------------------打开面板逻辑
--打开段位赛主面板
function QualifyModel:OpenQualifyMainUI()
    if self.main_win == nil then
        self.main_win = QualifyMainWindow.New(self)
    end
    self.main_win:Open()
end

--关闭主面板
function QualifyModel:CloseQualifyMainUI()
    WindowManager.Instance:CloseWindow(self.main_win)
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开段位赛匹配面板
function QualifyModel:OpenQualifyMatchUI()
    if self.match_win == nil then
        self.match_win = QualifyMatchWindow.New(self)
    end
    self.match_win:Open()
end

--关闭匹配面板
function QualifyModel:CloseQualifyMatchUI()
    WindowManager.Instance:CloseWindow(self.match_win)
    if self.match_win == nil then
        -- print("===================self.match_win is nil")
    else
        -- print("===================self.match_win is not nil")
    end
end

--打开段位赛结算面板
function QualifyModel:OpenQualifyFinishUI()
    if self.finish_win == nil then
        self.finish_win = QualifyFinishWindow.New(self)
    end
    self.finish_win:Open()
end

--关闭结算面板
function QualifyModel:CloseQualifyFinishUI()
    WindowManager.Instance:CloseWindow(self.finish_win)
    if self.finish_win == nil then
        -- print("===================self.finish_win is nil")
    else
        -- print("===================self.finish_win is not nil")
    end
end


--隐藏结算面板
function QualifyModel:HideQualifyFinishUI()
    if self.finish_win ~= nil then
        self.finish_win:Hide()
    end
end

--打开我的最高段位
function QualifyModel:OpenQualifyMyBestUI()
    if self.my_best_win == nil then
        self.my_best_win = QualifyMyBestWindow.New(self)
    end
    self.my_best_win:Show()
end

--关闭我的最高段位
function QualifyModel:CloseQualifyMyBestUI()
    WindowManager.Instance:CloseWindow(self.my_best_win)
    if self.my_best_win == nil then
        -- print("===================self.my_best_win is nil")
    else
        -- print("===================self.my_best_win is not nil")
    end
end


--打开解锁段位界面
function QualifyModel:OpenQualifyOpenLockUI()
    if self.open_lock_win == nil then
        self.open_lock_win = QualifyOpenLockWindow.New(self)
    end
    self.open_lock_win:Show()
end

--关闭解锁段位界面
function QualifyModel:CloseQualifyOpenLockUI()
    WindowManager.Instance:CloseWindow(self.open_lock_win)
    if self.open_lock_win == nil then
        -- print("===================self.open_lock_win is nil")
    else
        -- print("===================self.open_lock_win is not nil")
    end
end


---------------------------------------------各种面板更新
--更新匹配界面
function QualifyModel:update_match_win_socket_back()
    if self.match_win ~= nil then
        self:stop_match_timer()
        self.match_win:update_socket_back()
    else
        -- self:stop_match_timer()
        -- self:OpenQualifyMatchUI()
    end
end

--更新段位赛主界面
function QualifyModel:update_main_win_info()
    if self.main_win ~= nil then
        self.main_win:update_qualify_info()
    end
end

--主面板更新段位赛排行榜
function QualifyModel:update_rank_items(data)
    if self.main_win ~= nil then
        self.main_win:update_rank_items(data)
    end
end

--更新五胜和首胜状态
function QualifyModel:update_fine_and_first_reward()
    if self.main_win ~= nil then
        self.main_win:update_fine_and_first_reward()
    end
end

--主面板更新活动信息
function QualifyModel:update_activitys()
    if self.main_win ~= nil then
        self.main_win:update_activitys()
    end
end

--更新按钮红点
function QualifyModel:update_reward_btn_point()
    if self.main_win ~= nil then
        self.main_win:update_reward_btn_point()
    end
end

---------------------------------------------检查逻辑
--检查是否有奖励没领取
function QualifyModel:check_has_reward()
    local cfg_data = DataSystem.data_daily_icon[103]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if self.match_state_data ~= nil then
        if (self.match_state_data.win_flag ~= 1 and self.match_state_data.win >= 1) or (self.match_state_data.win_five_flag ~= 1 and self.match_state_data.win > 5) then
            return true
        end
    end
    return false
end

---------------------------------------------匹配过程中的计时器
--开始匹配计时
function QualifyModel:start_match_timer()
    if self.match_timer_id ~= 0 then
        --已经在计时中
        return
    end
    self.match_timer_id = LuaTimer.Add(0, 1000, function()
        self.total_time = self.total_time + 1
        if self.match_win ~= nil then
            self.match_win:match_timer_tick()
        end
        -- if 人物面板不为空 then

        -- end
    end)
end

--结束匹配计时
function QualifyModel:stop_match_timer()
    if self.match_timer_id ~= 0 then
        LuaTimer.Delete(self.match_timer_id)
        self.match_timer_id = 0
        self.total_time = 0
    end
end


---------------------------------------------各种get/set
--配置数据逻辑
--根据段位分获取配置数据
function QualifyModel:get_cfg_data_by_point(point)
    for i=0, DataQualifying.data_qualify_data_list_length do
        local data = DataQualifying.data_qualify_data_list[i]
        if data.point > point then
            return DataQualifying.data_qualify_data_list[i-1]
        end
    end
    return nil
end

--根据类型获取可参与次数
function QualifyModel:get_can_time_by_type(_type)
    if self.count_list == nil or #self.count_list == 0 then
        return 0
    end

    for i=1,#self.count_list do
        local dat = self.count_list[i]
        if dat.type == _type then
            return dat.num
        end
    end
end

--获取段位赛参加
function QualifyModel:get_has_take_part()
    if QualifyManager.Instance.model.match_state_data ~= nil then
        local list = QualifyManager.Instance.model.match_state_data.count_list
        for i=1,#list do
            local data = list[i]
            if data.type == 1 then
                return data.num
            end
        end
    end
    return 0
end