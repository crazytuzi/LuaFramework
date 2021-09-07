-- ----------------------------------
-- 星辰宝典子界面控制器
-- hosr
-- ----------------------------------
BibleBrewModel = BibleBrewModel or BaseClass(BaseModel)

function BibleBrewModel:__init(mainModel)
    self.mainModel = mainModel

    self.leftTypeList = {
        [1] = {name = TI18N("提升主角"), icon = "brew1"}
        , [2] = {name = TI18N("提升宠物"), icon = "brew2"}
        , [3] = {name = TI18N("提升守护"), icon = "brew3"}
        , [4] = {name = TI18N("我要银币"), icon = "Assets90000"}
        , [5] = {name = TI18N("我要金币"), icon = "Assets90003"}
        , [6] = {name = TI18N("我要积分"), icon = "Assets90012"}
    }

    self.warm_tips_time_gap =600
    self.warm_tips_type = 1
    self.warm_tips_panel = nil
    self.warm_tips_lev = 40

    self.type = 1

    self.dataTypeList = nil
    self.dataList = nil
    self.subDataList = nil

    self.is_warm_tips = true
end

function BibleBrewModel:loadData()
    self.dataTypeList = nil
    self.dataTypeList = {}
    self.dataList = nil
    self.dataList = {}
    for k,v in pairs(DataBrew.data_brew) do
        if v.type == self.type and RoleManager.Instance.RoleData.lev >= v.lev then
            table.insert(self.dataTypeList,v)
            if v.group_id == 0 then
                table.insert(self.dataList,v)
            end
        end
    end
    table.sort(self.dataList,BibleBrewModel.SortFun)
end

function BibleBrewModel.SortFun(a,b)
    return a.id < b.id
end

function BibleBrewModel:loadSubData(group_id)
    self.subDataList = nil
    self.subDataList = {}
    for k,v in pairs(self.dataTypeList) do
        if v.group_id == group_id then
            table.insert(self.subDataList,v)
        end
    end
    table.sort(self.subDataList,self.SortFun)
end

function BibleBrewModel:__delete()
end


--打开公会建筑加速面板面板
function BibleBrewModel:InitWarmTipsUI()
    if self.warm_tips_panel == nil then
        self.warm_tips_panel = BibleBrewWarmTipsPanel.New(self)
        self.warm_tips_panel:Show()
    end
end

--关闭公会自荐列表面板
function BibleBrewModel:CloseWarmTipsUI()
    if self.warm_tips_panel ~= nil then
        self.warm_tips_panel:DeleteMe()
        self.warm_tips_panel = nil
    end
    if self.warm_tips_panel == nil then
        -- print("===================self.warm_tips_panel is nil")
    else
        -- print("===================self.warm_tips_panel is not nil")
    end
end


--获取每日运势
function BibleBrewModel:Get_Warm_Tips_List()
    local ok_list = {}
    for i=1,#DataBibleBrewWarm.data_base do
        if DataBibleBrewWarm.data_base[i].is_show == 1 then
            if self:check_data(i) or i >= 100 then
                table.insert(ok_list, DataBibleBrewWarm.data_base[i])
            end
        end
    end

    return ok_list
end


--检查逻辑
function BibleBrewModel:check_data(i)
    if i == 1 then
        return self:check_day(1006, 30)
    elseif i == 2 then
        return self:check_dungeon(3000, 35)
    elseif i == 3 then
        return self:check_day(1011, 30)
    elseif i == 4 then
        return self:check_day(1002, 28)
    elseif i == 5 then
        return self:check_day(1004, 40)
    elseif i == 6 then
        if RoleManager.Instance.RoleData.lev <= 10 then
            return GuildManager.Instance.model:check_has_join_guild()
        end
    elseif i == 7 then
        if GuildManager.Instance.model:check_has_join_guild() then
            return self:check_day(1013, 30)
        end
    elseif i == 8 then
        return self:check_day(1014, 25)
    elseif i == 9 then
        return self:check_day(1001, 15)
    elseif i == 10 then
        return self:check_day(1009, 32)
    end
    return false
end


--检查某个日常活动是否还没参加过
function BibleBrewModel:check_day(id, lev)
    if RoleManager.Instance.RoleData.lev >= lev then
        for i=1,#AgendaManager.Instance.day_list do
            local d = AgendaManager.Instance.day_list[i]
            if d.id == id then
                if d.engaged == 0 then
                    return true
                end
                break
            end
        end
    end
    return false
end

--检查某个副本活动是否还没参加过
function BibleBrewModel:check_dungeon(id, lev)
    if RoleManager.Instance.RoleData.lev >= lev then
        for i=1,#AgendaManager.Instance.dungeon_list do
            local d = AgendaManager.Instance.dungeon_list[i]
            if d.id == id then
                if d.engaged == 0 then
                    return true
                end
                break
            end
        end
    end
    return false
end
