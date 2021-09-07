-- -------------------------------
-- 单独播放剧本控制
-- hosr
-- -------------------------------
PlotModelSingle = PlotModelSingle or BaseClass(PlotModel)

function PlotModelSingle:__init(callback)
    self.callback = callback
    self.actionModel = DramaActionModel.New(function() self:EndPlot() end)
    self.transformer = DramaDataTransform.New()
    self.action_list = {}
end

function PlotModelSingle:__delete()
    if self.actionModel ~= nil then
        self.actionModel:DeleteMe()
        self.actionModel = nil
    end
    if self.transformer ~= nil then
        self.transformer:DeleteMe()
        self.transformer = nil
    end
    self.callback = nil
    self.action_list = nil
end

function PlotModelSingle:BeginPlot(plotId)
    local base = DataPlot.data_plot[plotId]
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

function PlotModelSingle:EndPlot()
    if self.callback ~= nil then
        self.callback()
        self.callback = nil
    end
end
