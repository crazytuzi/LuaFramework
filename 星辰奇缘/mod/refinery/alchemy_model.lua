AlchemyModel = AlchemyModel or BaseClass(BaseModel)

function AlchemyModel:__init()
    self.main_win = nil
    self.good_win = nil
    self.confirm_win = nil

    self.confirm_data = nil

end

function AlchemyModel:__delete()

end

------------------------------打开界面和关闭界面逻辑
--打开主界面
function AlchemyModel:InitMainUI()
    if self.main_win == nil then
        self.main_win = AlchemyMainWindow.New(self)
    end
    self.main_win:Open()
end

function AlchemyModel:CloseMainUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--炼化道具
function AlchemyModel:InitLianhuUI()
    if self.good_win == nil then
        self.good_win = AlchemyItemWindow.New(self)
        self.good_win:Show()
    end
    if self.main_win ~= nil then
        self:CloseMainUI()
    end
end

function AlchemyModel:CloseLianhuUI()
    if self.good_win ~= nil then
        self.good_win:DeleteMe()
        self.good_win = nil
    end

    self:InitMainUI()

    if self.good_win == nil then
        -- print("===================self.good_win is nil")
    else
        -- print("===================self.good_win is not nil")
    end
end

function AlchemyModel:CloseLianhuUI_Normal()
    if self.good_win ~= nil then
        self.good_win:DeleteMe()
        self.good_win = nil
    end

    if self.good_win == nil then
        -- print("===================self.good_win is nil")
    else
        -- print("===================self.good_win is not nil")
    end
end

--打开炼化确认
function AlchemyModel:InitLianhuaConfirmUI()
    if self.confirm_win == nil then
        self.confirm_win = AlchemyConfirmWindow.New(self)
        self.confirm_win:Show()
    end
end

--关闭炼化确认界面
function AlchemyModel:CloseLianhuaConfirmUI()
    self.confirm_win:DeleteMe()
    self.confirm_win = nil
    if self.confirm_win == nil then
        -- print("===================self.confirm_win is nil")
    else
        -- print("===================self.confirm_win is not nil")
    end
end


--------------------------------------------界面内容更新
function AlchemyModel:UpdateMainInfo()
    if self.main_win ~= nil then
        self.main_win:update_info()
    end
end



--------------------------------------------各种数值判断
--判断是否有空格
function AlchemyModel:CheckHasEmptyPos()
    local state = false
    for i=1,#self.data_list do
        local dat = self.data_list[i]
        if dat.volume - #dat.products > 0 then
            state = true --有空格
        end
    end
    return state
end

function AlchemyModel:CheckValueEnough()
    local need = 0
    local has = RoleManager.Instance.RoleData.alchemy
    for i=1,#self.data_list do
        local dat = self.data_list[i]
        local cfg_data = DataAlchemy.data_base[dat.id]
        need = need + (dat.volume - #dat.products)*cfg_data.cost[1][2]
    end
    if has < need then
        return false
    else
        return true
    end
end

--检查下是否有足够的能力足够去放最小的那个
function AlchemyModel:CheckRedPointState()
    local has = RoleManager.Instance.RoleData.alchemy
    --BaseUtils.dump(self.data_list,"self.data_list")
    if self.data_list ~= nil then
        for i=1,#self.data_list do
            local dat = self.data_list[i]
            if dat.item_id ~= 90013 then
                for j=1,#dat.products do
                    local d = dat.products[j]
                    local left_time = d.time + dat.need_time - BaseUtils.BASE_TIME
                    if left_time <= 0 then
                        return true
                    end
                end
            else
                if not SkillManager.Instance.model:check_prac_skill_fullexp() then
                    for j=1,#dat.products do
                        local d = dat.products[j]
                        local left_time = d.time + dat.need_time - BaseUtils.BASE_TIME
                        if left_time <= 0 then
                            return true
                        end
                    end
                end
            end
            -- if dat.volume > #dat.products then
            --     local cfg_data = DataAlchemy.data_base[dat.id]
            --     if cfg_data.cost[1][2] <= has then
            --         return true
            --     end
            -- end
        end
    end

    return false
end


