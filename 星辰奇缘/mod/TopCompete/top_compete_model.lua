TopCompeteModel = TopCompeteModel or BaseClass(BaseModel)

function TopCompeteModel:__init()
    self.top_compete_win = nil
    self.top_compete_box_win = nil
    self.top_compete_status_data = nil
    self.top_compete_finish_data = nil
end


function TopCompeteModel:__delete()
    self:CloseMainFinishUI()
end


---打开结算界面
function TopCompeteModel:InitFinishUI()
    if self.top_compete_win == nil then
        self.top_compete_win = TopCompeteFinishWindow.New(self)
        self.top_compete_win:Open()
    end
end

--关闭结算界面
function TopCompeteModel:CloseFinishUI()
    WindowManager.Instance:CloseWindow(self.top_compete_win, true)
    if self.top_compete_win == nil then
        -- print("===================self.top_compete_win is nil")
    else
        -- print("===================self.top_compete_win is not nil")
    end
end

---打开box界面
function TopCompeteModel:InitBoxUI()
    if self.top_compete_box_win == nil then
        self.top_compete_box_win = TopCompeteboxWindow.New(self)
        self.top_compete_box_win:Open()
    end
end

--关闭box界面
function TopCompeteModel:CloseBoxUI()
    WindowManager.Instance:CloseWindow(self.top_compete_box_win, true)
    if self.top_compete_box_win == nil then
        -- print("===================self.top_compete_box_win is nil")
    else
        -- print("===================self.top_compete_box_win is not nil")
    end
end

--------------------------界面更新
--更新结算界面
function TopCompeteModel:UpdateFinishUI()
    if self.top_compete_win ~= nil then
        self.top_compete_win:update_info()
    end
end

