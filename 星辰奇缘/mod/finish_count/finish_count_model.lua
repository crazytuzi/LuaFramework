------------------
--结算系统统一逻辑
------------------
FinishCountModel = FinishCountModel or BaseClass(BaseModel)

function FinishCountModel:__init()
    self.box_win = nil
    self.reward_win = nil

    self.box_click_back_fun = nil

    self.reward_win_data = nil

    self.has_share_score = false
end

function FinishCountModel:__delete()

end

----打开关闭界面
function FinishCountModel:InitBoxWin()
    if self.box_win == nil then
        self.box_win = FinishCountBoxWindow.New(self)
    end
    self.box_win:Open()
end

function FinishCountModel:CloseBoxWin()
    if self.box_win ~= nil then
        WindowManager.Instance:CloseWindow(self.box_win)
    end
    if self.box_win == nil then
        -- print("===================self.box_win is nil")
    else
        -- print("===================self.box_win is not nil")
    end
end

function FinishCountModel:InitRewardWin()
    if self.reward_win == nil then
        self.reward_win = FinishCountRewardWindow.New(self)
    end
    self.reward_win:Open()
end

function FinishCountModel:CloseRewardWin()
    if self.reward_win ~= nil then
        WindowManager.Instance:CloseWindow(self.reward_win)
    end
    if self.reward_win == nil then
        -- print("===================self.reward_win is nil")
    else
        -- print("===================self.reward_win is not nil")
    end
end

function FinishCountModel:InitRewardWin_Common()
    if self.reward_win_common == nil then
        self.reward_win_common = CommonFinishCountRewardWindow.New(self)
    end
    self.reward_win_common:Open()
end

function FinishCountModel:CloseRewardWin_Common()
    if self.reward_win_common ~= nil then
        WindowManager.Instance:CloseWindow(self.reward_win_common)
    end
end

------------------界面更新逻辑
function FinishCountModel:UpdateBoxWinResult(index, data)
    if self.box_win ~= nil then
        self.box_win:OpenBox(index, data)
    end
end

--更新结算宝箱剩下的两个
function FinishCountModel:OpenOtherBox(index1, index2, data1, data2)
    if self.box_win ~= nil then
        self.box_win:OpenOtherBox(index1, index2, data1, data2)
    end
end
