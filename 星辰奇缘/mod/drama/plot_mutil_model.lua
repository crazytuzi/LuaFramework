-- ---------------------
-- 剧情动作同时播放
-- hosr
-- ---------------------
PlotMutilModel = PlotMutilModel or BaseClass(PlotModel)

function PlotMutilModel:__init(callback)
    self.callback = callback
    self.actionModel = MutilActionModel.New(function() self:EndPlot() end)
    self.transformer = DramaDataTransform.New()
    self.action_list = {}
end

function PlotMutilModel:__delete()
    if self.actionModel ~= nil then
        self.actionModel:DeleteMe()
        self.actionModel = nil
    end
    if self.transformer ~= nil then
        self.transformer:DeleteMe()
        self.transformer = nil
    end
end

function PlotMutilModel:BeginPlot(plotId)
    local base = DataPlot.data_plot[plotId]
    if base ~= nil then
        self.action_list = {}
        for i,data in ipairs(base.data) do
            local action = self.transformer:Format(data)
            action.id = i
            table.insert(self.action_list, action)
        end
        self.actionModel:BeginActions(self.action_list)
    end
end

function PlotMutilModel:CustomBeginPlot(actionlist)
    self.actionModel:BeginActions(actionlist)
end

function PlotMutilModel:EndPlot()
    -- print("PlotMutilModel:EndPlot")
end

function PlotMutilModel:JumpPlot()
    if self.actionModel ~= nil then
        self.actionModel:OnJump()
    end
    for _,dramaAction in ipairs(self.action_list) do
        if dramaAction.type == DramaEumn.ActionType.Plotunitdel then
            -- 删除批量同步创建的单位
            DramaVirtualUnit.Instance:RemoveUnit(dramaAction)
        end
    end
end