-- ----------------------------
-- 剧本处理
-- hosr
-- ----------------------------
PlotModel = PlotModel or BaseClass(BaseModel)

function PlotModel:__init(callback)
    self.callback = callback
    self.actionModel = DramaActionModel.New(function() self:EndPlot() end)
    self.transformer = DramaDataTransform.New()
    self.action_list = {}
end

function PlotModel:__delete()
    if self.actionModel ~= nil then
        self.actionModel:DeleteMe()
        self.actionModel = nil
    end
    if self.transformer ~= nil then
        self.transformer:DeleteMe()
        self.transformer = nil
    end
end

function PlotModel:BeginPlot(plotId)
    DramaManager.Instance.model:CanJump()
    local base = DataPlot.data_plot[plotId]
    -- BaseUtils.dump(base, "剧本数据")
    if base == nil then
        if self.callback ~= nil then
            self.callback()
        end
    else
        self.action_list = {}
        for i,data in ipairs(base.data) do
            local action = self.transformer:Format(data)
            action.id = i
            table.insert(self.action_list, action)
        end
        self.actionModel:BeginActions(self.action_list)
    end
end

function PlotModel:EndPlot()
    -- print("PlotModel:EndPlot")
    if self.callback ~= nil then
        self.callback()
    end
end

function PlotModel:JumpPlot()
    if self.actionModel ~= nil then
        self.actionModel:OnJump()
    end
    for _,dramaAction in ipairs(self.action_list) do
        if dramaAction.type == DramaEumn.ActionType.Plotunitdel then
            DramaVirtualUnit.Instance:RemoveUnit(dramaAction)
        end
    end
    self:EndPlot()
end