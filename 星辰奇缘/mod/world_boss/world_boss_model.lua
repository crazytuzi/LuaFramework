WorldBossModel = WorldBossModel or BaseClass(BaseModel)

function WorldBossModel:__init()

    self.boss_rank_id = 0

    self.world_boss_data = nil
    self.main_win = nil
    self.rank_win = nil
    self.current_rank_list = nil
end

function WorldBossModel:__delete()

end

-----------------------各种界面打开更新逻辑
--打开守护主面板
function WorldBossModel:OpenWorldBossUI()
    if self.main_win == nil then
        self.main_win = WorldBossMainWindow.New(self)
    end
    self.main_win:Open()
end

--关闭守护主面板
function WorldBossModel:CloseWorldBossUI()
    WindowManager.Instance:CloseWindow(self.main_win)
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开守护招募成功面板
function WorldBossModel:OpenWorldBossRankUI()
    if self.rank_win == nil then
        self.rank_win = WorldBossKillRankWindow.New(self)
        self.rank_win:Open()
    end
end

--关闭守护招募成功面板
function WorldBossModel:CloseWorldBossRankUI()
     WindowManager.Instance:CloseWindow(self.rank_win)
    if self.rank_win == nil then
        -- print("===================self.rank_win is nil")
    else
        -- print("===================self.rank_win is not nil")
    end
end


----------------------各种面板更新
function WorldBossModel:update_view()
    if self.main_win ~= nil then
        self.main_win:update_view()
    end
end

--更新排行榜
function WorldBossModel:update_rank_view(kill_ranks, _type)
    self.current_rank_list = kill_ranks
    if self.rank_win ~= nil then
        self.rank_win:update_view(kill_ranks,_type)
    end
end