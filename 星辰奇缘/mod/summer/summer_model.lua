--2016/7/14
--zzl
SummerModel = SummerModel or BaseClass(BaseModel)

function SummerModel:__init()
    self.main_win = nil

    self.fruit_help_win = nil

    self.fruit_to_help_win = nil

    self.summer_login_data = nil

    --主界面的tab选项卡的手写配置
    self.tab_data_list = {
        --btn_str:按钮的名字， iconW:按钮宽度，iconH：按钮高度, iconName:按钮资源名称, sortIndex:排序为
        [1] = {id = 1, btn_str = TI18N("水果种植"), iconW = 23, iconH = 32, iconName = "FruitPlantIcon3", sortIndex = 3, endTime = 1470931199}
        ,[2] = {id = 2, btn_str = TI18N("清凉一夏"), iconW = 22, iconH = 30, iconName = "FruitPlantIcon1", sortIndex = 1, endTime = 1470931199}
        ,[3] = {id = 3, btn_str = TI18N("暑期登录"), iconW = 32, iconH = 32, iconName = "FruitPlantIcon5", sortIndex = 2, endTime = 0}
        ,[4] = {id = 4, btn_str = TI18N("捉迷藏"), iconW = 22, iconH = 30, iconName = "FruitPlantIcon4", sortIndex = 4, endTime = 1470931199}
    }



    self.fruit_plant_data = nil

    self.listener = function() self:SceneLoad() end
    -- EventMgr.Instance:AddListener(event_name.scene_load, self.listener)

    self.timerIdShare = 0
    self.timeShareCount = 0
end

function SummerModel:startTimeShareCal()
    -- if self.timerIdShare ~= 0 then
    --     LuaTimer.Delete(self.timerIdShare)
    -- end
    self.timeShareCount = 10
    self.timerIdShare = LuaTimer.Add(0, 1000, function()
        if self.timeShareCount > 0 then
            self.timeShareCount = self.timeShareCount - 1
        else
            self.timeShareCount = 1
            LuaTimer.Delete(self.timerIdShare)
            self.timerIdShare = 0
        end
    end)
end


function SummerModel:__delete()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.listener)
end

----------------------------界面打开关闭逻辑
--打开主界面
function SummerModel:InitMainUI(args)
    if self.main_win == nil then
        self.main_win = SummerMainWindow.New(self)
    end
    self.main_win:Open(args)
end

function SummerModel:CloseMainUI()
    if self.main_win ~= nil then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end



--打开好友求助界面
function SummerModel:InitFruitHelpUI()
    if self.fruit_help_win == nil then
        self.fruit_help_win = SummerFruitPlantHelpWindow.New(self)
    end
    self.fruit_help_win:Open()
end

function SummerModel:CloseFruitHelpUI()
    if self.fruit_help_win ~= nil then
        WindowManager.Instance:CloseWindow(self.fruit_help_win)
    end
    if self.fruit_help_win == nil then
        -- print("===================self.fruit_help_win is nil")
    else
        -- print("===================self.fruit_help_win is not nil")
    end
end


--打开好友求助界面
function SummerModel:InitFruitToHelpUI(help_data)
    local rid = help_data.rid
    if rid == 0 then
        rid = help_data.id
    end
    if RoleManager.Instance.RoleData.id == rid and RoleManager.Instance.RoleData.platform == help_data.platform and RoleManager.Instance.RoleData.zone_id == help_data.zone_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("这是你自己的求助信息"))
        return
    end


    self.to_help_data = help_data
    if self.fruit_to_help_win == nil then
        self.fruit_to_help_win = SummerFruitToHelpWindow.New(self)
    end
    self.fruit_to_help_win:Open()
end

function SummerModel:CloseFruitToHelpUI()
    self.to_help_data = nil
    if self.fruit_to_help_win ~= nil then
        WindowManager.Instance:CloseWindow(self.fruit_to_help_win)
        self.fruit_to_help_win = nil
    end
    if self.fruit_to_help_win == nil then
        -- print("===================self.fruit_to_help_win is nil")
    else
        -- print("===================self.fruit_to_help_win is not nil")
    end
end

function SummerModel:ShowSeekChildrenDetailPanel(bo,data)
    if self.seekchildrenDetailPanel == nil then
        self.seekchildrenDetailPanel = SeekChildrensDetailDescPanel.New(self)
    end
    if bo == true then
        self.seekchildrenDetailPanel:Show(data)
    else
        self.seekchildrenDetailPanel:Hiden()
    end
end

function SummerModel:SceneLoad()
    -- self:NpcState()
end

function SummerModel:isFinish(id)
    if SummerManager.Instance.childrensGroupData ~= nil and SummerManager.Instance.childrensGroupData.list ~= nil then
        for i,v in ipairs(SummerManager.Instance.childrensGroupData.list) do
            if v.id == id then
                return true
            end
        end
    end
    return false
end
-- 更新小屁孩头上的状态标识
-- 没做的 -- 任务可接的叹号
-- 做完的 -- 活动称号
function SummerModel:NpcState()
    -- 功能自己处理状态变化
    local isFinish = false
    local hasQuest = false
    local baseid = 0
    local tempNpc = nil
    local tempData = nil
    for uniqueid,npcView in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if string.find(uniqueid, "_32") ~= nil then
            npcView.data.honorType = 0
            npcView:change_honor()
            tempNpc = npcView
            baseid = tempNpc.data.baseid
        end
    end
    for uniqueid,data in pairs(SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List) do
        if string.find(uniqueid, "_32") ~= nil then
            data.honorType = 0
            tempData = data
            baseid = tempData.baseid
        end
    end

    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.seekChild)
    if questData ~= nil then
        local childData = DataCampHideSeek.data_child_task[questData.id]
        if childData ~= nil then
            if childData.unit_id == baseid then
                hasQuest = true
            end
        end
    end

    isFinish = self:isFinish(baseid) or hasQuest

    if tempNpc ~= nil then
        if isFinish then
            tempNpc.data.honorType = 0
        else
            tempNpc.data.honorType = 1
        end
        tempNpc:change_honor()
    elseif tempData ~= nil then
        if isFinish then
            tempData.honorType = 0
        else
            tempData.honorType = 1
        end
    end
end

--检查下是否所有都已经领取
function SummerModel:CheckHasGetAll()
    if self.summer_login_data == nil then
        return true
    end
    local data = self.summer_login_data
    local buy_keys = {}
    for i=1,#data.buys do
        local b_data = data.buys[i]
        buy_keys[b_data.id] = b_data
    end

    local key_days = {}
    for i=1,#data.days do
        key_days[data.days[i].day] = data.days[i]
    end

    local temp_list = DataCampLogin.data_base
    for k, v in pairs(temp_list) do
        if key_days[v.day] == nil then
            --还没领取
            return false
        end
    end

    --都已经领取了，看下有没有能买的
    for k, v in pairs(temp_list) do
        for i=1,#v.buys do
            local b_data = v.buys[i]
            if b_data[1] <= RoleManager.Instance.RoleData.lev and b_data[2] >= RoleManager.Instance.RoleData.lev then
                if buy_keys[b_data[3]] ~= nil then
                    if buy_keys[b_data[3]].time + DataCampLogin.data_buy[b_data[3]].cd > BaseUtils.BASE_TIME then
                        return false
                    end
                end
            end
        end
    end
    return true
end