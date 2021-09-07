HonorModel = HonorModel or BaseClass(BaseModel)

function HonorModel:__init()
    self.mine_honor_list = nil
    self.main_win = nil
    self.newHonorView = nil
    self.current_data = nil
    self.current_honor_id = nil
    self.current_honor_data_list = nil
    self.newHonorCache = {}
end

function HonorModel:__delete()

end


------窗口打开关闭逻辑
--打开称号预览界面
function HonorModel:InitMainUI()
    if self.main_win == nil then
        self.main_win = HonorPreviewWindow.New(self)
    end
    self.main_win:Show()
end

function HonorModel:CloseMainUI()
    if self.main_win ~= nil then
        -- WindowManager.Instance:CloseWindow(self.main_win)
        self.main_win:DeleteMe()
        self.main_win = nil
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end


function HonorModel:CloseGetWin()
    if self.getWin ~= nil then
        self.getWin:DeleteMe()
        self.getWin = nil
    end
end

function HonorModel:OpenGetWindow(args)
     if self.getWin == nil then
        self.getWin = ItemsaveGetWindow.New(self)
    end
    self.getWin:Show(args)
end
function HonorModel:OpenNewHonorWindow(args)
    if self.newHonorView == nil then
        self.newHonorView = NewHonorView.New(self)
    end
    self.newHonorView:Show(args)
end

function HonorModel:CloseNewHonorWindow()
    if self.newHonorView ~= nil then
        -- WindowManager.Instance:CloseWindow(self.newHonorView)
        self.newHonorView:DeleteMe()
        self.newHonorView = nil
    end
end

--获取当前称号
function HonorModel:get_current_honor()
    if self.mine_honor_list == nil then
        return nil
    end

    for i=1,#self.mine_honor_list do
        local data = self.mine_honor_list[i]
        if data.id == self.current_honor_id then
            return data
        end
    end
    return nil
end

--传入称号id，检查下我有没有这个称号
function HonorModel:check_has_honor(id)
    if self.mine_honor_list == nil then
        return false
    end

    for i=1,#self.mine_honor_list do
        local data = self.mine_honor_list[i]
        if data.id == id then
            return true
        end
    end
    return false
end

--传入称号id，检查下我有没有这个前缀称号
function HonorModel:check_has_pre_honor(id)
    if self.pre_honor_id_list == nil then
        return false
    end

    for i=1,#self.pre_honor_id_list do
        local data = self.pre_honor_id_list[i]
        if data.pre_id == id then
            return true
        end
    end
    return false
end



--获得新称号，弹出获得新称号面板
function HonorModel:GetNewHonor(id,type)

    if self.newHonorView == nil then
        self:OpenNewHonorWindow({id,type})
    else
        if type == InfoHonorEumn.Status.ForWard then
            table.insert(self.newHonorCache, id)
        end
    end
end