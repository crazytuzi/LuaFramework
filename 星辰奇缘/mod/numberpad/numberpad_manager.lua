NumberpadManager = NumberpadManager or BaseClass(BaseManager)

function NumberpadManager:__init()
    if NumberpadManager.Instance ~= nil then
        return
    end
    NumberpadManager.Instance = self
    self.model = NumberpadModel.New()
end

function NumberpadManager:set_data(info)
    self.model:set_data(info)
    self.model:OpenWindow()
end

function NumberpadManager:OpenWindow()
    -- self.model:OpenWindow()
end

function NumberpadManager:GetResult()
    return self.model.result_show or 1
end

function NumberpadManager:Close()
    self.model:Close()
end
