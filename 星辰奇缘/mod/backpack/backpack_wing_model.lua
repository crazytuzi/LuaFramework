-- ----------------------------------
-- 翅膀子界面控制器
-- hosr
-- ----------------------------------
BackpackWingModel = BackpackWingModel or BaseClass(BaseModel)

function BackpackWingModel:__init(mainModel)
    self.mainModel = mainModel
    self.mgr = WingsManager.Instance

    self.wingPanel = nil
    self.gotWingData = false
    self.hasWing = false

    self.cur_selected_option = 1

    self.backpackItemListener = function()
        if self.wingPanel ~= nil and self.wingPanel.gameObject then
            self.wingPanel:ReloadPanel()
        end
    end

    self.wingsIdByGrade = {}
    for k,v in pairs(DataWing.data_base) do
        if self.wingsIdByGrade[v.grade] == nil then
            self.wingsIdByGrade[v.grade] = {}
        end
        table.insert(self.wingsIdByGrade[v.grade], v.wing_id)
    end
    for _,v in pairs(self.wingsIdByGrade) do
        table.sort(v)
    end
end

function BackpackWingModel:__delete()
    self:Close()
end

function BackpackWingModel:Close()
    if self.wingPanel ~= nil then
        self.wingPanel:DeleteMe()
        self.wingPanel = nil
    end
    if self.skillPanel ~= nil then
        self.skillPanel:DeleteMe()
        self.skillPanel = nil
    end

    if self.skillOptionConfirmPanel ~= nil then
        self.skillOptionConfirmPanel:DeleteMe()
        self.skillOptionConfirmPanel = nil
    end
end

function BackpackWingModel:Show()
    if self.mainModel.mainWindow.openArgs ~= nil then
        local index = self.mainModel.mainWindow.openArgs[2]
        self.mainModel.mainWindow.openArgs = nil
        self:ChangeSub(index)
    else
        self:ChangeSub(self.currentIndex)
    end

    -- if self.wingPanel == nil then
    --     self.wingPanel = BackpackWingPanel.New(self)
    --     self.wingPanel.parent = self.mainModel.mainWindow.gameObject
    -- end

    if self.wingPanel == nil then
        self.wingPanel = WingPanel.New(self.mainModel.mainWindow.gameObject)
    end
    self.wingPanel:Show()

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackItemListener)
end

function BackpackWingModel:Hiden()
    if self.wingPanel ~= nil then
        self.wingPanel:Hiden()
    end
end

function BackpackWingModel:OnHide()
    if self.wingPanel ~= nil then
        self.wingPanel:OnHide()
    end
end

function BackpackWingModel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackItemListener)
end

function BackpackWingModel:ChangeSub(index)
    self.lastIndex = index
end

function BackpackWingModel:GetData()
    self.temp_reset_id = WingsManager.Instance.temp_reset_id
    self.tmp_growth = WingsManager.Instance.tmp_growth
    self.tmp_grade = WingsManager.Instance.tmp_grade
    self.grade = WingsManager.Instance.grade
    self.wing_id = WingsManager.Instance.wing_id
    self.growth = WingsManager.Instance.growth
    self.enhance = WingsManager.Instance.enhance

    self.star = WingsManager.Instance.star
    if self.star == nil then self.star = 0 end
    self.skill_data = WingsManager.Instance.skill_data
    if self.skill_data == nil then self.skill_data = {} end
    self.tmp_skill_data = WingsManager.Instance.tmp_skill_data
    if self.tmp_skill_data == nil then self.tmp_skill_data = {} end

    self.gradeStarNum = {}

    for _,v in pairs(DataWing.data_upgrade) do
        if self.gradeStarNum[v.grade] == nil then self.gradeStarNum[v.grade] = 0 end
        self.gradeStarNum[v.grade] = self.gradeStarNum[v.grade] + 1
    end

    self.gotWingData = true

    -- if self.wingPanel ~= nil then
    --     self.wingPanel:ReloadPanel()
    -- end
end

function BackpackWingModel:OpenBook(args)
    if self.wingBook == nil then
        self.wingBook = WingsHandbookWindow.New(self)
    end
    self.wingBook:Open(args)
end

function BackpackWingModel:OpenWingSkillPanel(args)
    if self.skillPanel == nil then
        self.skillPanel = WingSkillPanel.New(self, self.mainModel.mainWindow.gameObject)
    end
    self.skillPanel:Show(args)
end

function BackpackWingModel:CloseWingSkillPanel()
    if self.skillPanel ~= nil then
        self.skillPanel:Hiden()
    end
end


--打开翅膀技能方案切换确认
function BackpackWingModel:OpenOptionConfirmPanel()
    if self.skillOptionConfirmPanel == nil then
        self.skillOptionConfirmPanel = WingOptionConfirmWindow.New(self)
        self.skillOptionConfirmPanel:Show()
    end
end

--关闭翅膀技能方案切换确认
function BackpackWingModel:CloseOptionConfirmPanel()
    if self.skillOptionConfirmPanel ~= nil then
        self.skillOptionConfirmPanel:DeleteMe()
        self.skillOptionConfirmPanel = nil
    end
    if self.skillOptionConfirmPanel == nil then
        -- print("===================self.skillOptionConfirmPanel is nil")
    else
        -- print("===================self.skillOptionConfirmPanel is not nil")
    end
end

function BackpackWingModel:GetAwakenSkill(grade)
    local data_get_lev_break_skill = DataWing.data_get_lev_break_skill[string.format("%s_%s", RoleManager.Instance.RoleData.classes, grade)]
    if data_get_lev_break_skill ~= nil then
        return data_get_lev_break_skill.skill_list[1]
    end
end