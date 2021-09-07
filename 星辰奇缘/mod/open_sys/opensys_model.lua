OpensysModel = OpensysModel or BaseClass(BaseModel)

function OpensysModel:__init()
    self.opensysPanel = nil
end

function OpensysModel:Show(args)
    if self.opensysPanel == nil then
        -- self.opensysPanel = OpensysPanel.New(self, function() self:ShowEnd() end)
        self.opensysPanel = OpensysPanelNew.New(self, function() self:ShowEnd() end)
    end
    self.opensysPanel:Show(args)
end

function OpensysModel:ShowEnd()
    if self.opensysPanel ~= nil then
        self.opensysPanel:DeleteMe()
        self.opensysPanel = nil
    end
end