ForceImproveModel = ForceImproveModel or BaseClass(BaseModel)

function ForceImproveModel:__init()
    self.typeList = {
        [1] = {name = TI18N("装备评分"), subList = {}, icon = "AttrIcon48", myScore = 0, serverTop = 0},
        [2] = {name = TI18N("宝石评分"), subList = {}, icon = "AttrIcon49", myScore = 0, serverTop = 0},
        [3] = {name = TI18N("翅膀评分"), subList = {}, icon = "AttrIcon69", myScore = 0, serverTop = 0},
        [4] = {name = TI18N("冒险评分"), subList = {}, icon = "AttrIcon61", myScore = 0, serverTop = 0},
        [5] = {name = TI18N("坐骑评分"), subList = {}, icon = "AttrIcon67", myScore = 0, serverTop = 0},
        [6] = {name = TI18N("守护评分"), subList = {}, icon = "AttrIcon31", myScore = 0, serverTop = 0},
        [7] = {name = TI18N("宝物评分"), subList = {}, icon = "AttrIcon31", myScore = 0, serverTop = 0},
        [99] = {name = TI18N("其他评分"), subList = {}, icon = "AttrIcon70", myScore = 0, serverTop = 0}
    }

    self:SetData()

    self.firstTimeOpenForceImproveWindow = true
end

function ForceImproveModel:__delete()
end

function ForceImproveModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = ForceImproveWindow.New(self)
    end
    self.mainWin:Open(args)
end

function ForceImproveModel:CloseWindow()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.force_improve)
end

function ForceImproveModel:OpenForceImproveRecommendWindow(args)
    if self.forceImproveRecommendWindow == nil then
        self.forceImproveRecommendWindow = ForceImproveRecommendWindow.New(self)
    end
    self.forceImproveRecommendWindow:Open(args)
end

function ForceImproveModel:CloseForceImproveRecommendWindow()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.force_improve_recommend)
end

function ForceImproveModel:SetData()
    self.subTypeList = {}
    for k,v in pairs(DataFcUpdate.data_base) do
        table.insert(self.typeList[v.type].subList, v)
        self.subTypeList[v.id] = {}
    end

    self.classList = {}
    for k,v in pairs(self.typeList) do
        table.sort(v.subList, function(a, b) return a.id < b.id end)
        table.insert(self.classList, v)
        v.id = k
    end
    table.sort(self.classList, function(a,b) return a.id < b.id end)
end

-- 获取我等级段的推荐战力数据
function ForceImproveModel:GetMyRecommendData(id)
    local roleData = RoleManager.Instance.RoleData
    for _,value in ipairs(DataFcUpdate.data_recommend) do
        if value.id == id and value.lev_low <= roleData.lev and value.lev_high >= roleData.lev and value.break_times_min <= roleData.lev_break_times and value.break_times_max >= roleData.lev_break_times then
            return value
        end
    end
end

-- 按照与推荐战力的差值从大到小排序
function ForceImproveModel:SortRecommendData()
    local list = {}
    for key1, data_base in pairs(DataFcUpdate.data_base) do
        local data_recommend = self:GetMyRecommendData(data_base.id)
        if data_recommend ~= nil and self.subTypeList[data_base.id].myScore ~= nil then   
            data_recommend = BaseUtils.copytab(data_recommend)
            data_recommend.sortVal = data_recommend.val - self.subTypeList[data_base.id].myScore
            table.insert(list, data_recommend)
        end
    end

    local function sortfun(a,b)
        return a.sortVal > b.sortVal
    end

    table.sort(list, sortfun)
    return list
end

-- 获取我当前的推荐战力
function ForceImproveModel:GetRecommendFC()
    local fc = 0
    for key1, data_base in pairs(DataFcUpdate.data_base) do
        local data_recommend = self:GetMyRecommendData(data_base.id)
        if data_recommend ~= nil then   
            fc = fc + data_recommend.val
        end
    end
    return fc
end

-- 按照与推荐战力的比例从大到小排序
function ForceImproveModel:SortDetailData(subList)
    local list = {}
    for key1, subData in pairs(subList) do
        local recommendData = self:GetMyRecommendData(subData.id)
        if recommendData ~= nil then
            local myScore = self.subTypeList[subData.id].myScore
            local serverTop = self.subTypeList[subData.id].serverTop
            
            recommendData = BaseUtils.copytab(recommendData)
            recommendData.lev = subData.lev
            recommendData.name = subData.name
            recommendData.icon = subData.icon
            recommendData.link = subData.link

            local showBestScore = myScore >= recommendData.val
            if showBestScore then
                recommendData.sortVal = myScore / serverTop
            else
                recommendData.sortVal = myScore / recommendData.val 
            end
            table.insert(list, recommendData)
        end
    end

    local function sortfun(a,b)
        return a.sortVal < b.sortVal
    end

    table.sort(list, sortfun)
    return list
end

function ForceImproveModel:CheckCanUpgrade(checkItem)
    if self.fcLevel == nil then
        return false
    end
    
    local roleData = RoleManager.Instance.RoleData
    local next_data_reward = DataFcUpdate.data_reward[string.format("%s_%s", self.fcLevel+1, roleData.classes)]
    if next_data_reward == nil then
        return false
    else
        if checkItem and #next_data_reward.loss > 0 then
            local num = BackpackManager.Instance:GetItemCount(next_data_reward.loss[1][1])
            local need = next_data_reward.loss[1][2]
            if roleData.fc >= next_data_reward.score and  num >= need then
                return true
            else
                return false
            end
        else
            if roleData.fc >= next_data_reward.score then
                return true
            else
                return false
            end
        end
    end
end