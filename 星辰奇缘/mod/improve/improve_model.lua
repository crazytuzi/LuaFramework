ImproveModel = ImproveModel or BaseClass(BaseModel)


function ImproveModel:__init()
    self.improveWin = nil
    self.improveMgr = ImproveManager.Instance
end

function ImproveModel:__delete()
    if self.improveWin then
        self.improveWin = nil
    end
end

function ImproveModel:OpenMyWindow()
    -- if #self.improveMgr.lastList == 0 then
    --     return
    -- end
    if self.improveWin == nil then
        self.improveWin = ImproveWindow.New(self)
    end
    self.improveWin:Open()
end

function ImproveModel:CloseWin()
    if self.improveWin ~= nil then
        WindowManager.Instance:CloseWindow(self.improveWin)
    end
    self.improveWin = nil
end