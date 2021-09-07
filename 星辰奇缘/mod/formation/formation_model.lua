FormationModel = FormationModel or BaseClass(BaseModel)

function FormationModel:__init()
    self.mainWindow = nil
end

function FormationModel:__delete()
end

function FormationModel:OpenMain(args)
    if self.mainWindow == nil then
        self.mainWindow = FormationMainWindow.New(self)
    end
    self.mainWindow:Open(args)
end

function FormationModel:CloseMain()
   WindowManager.Instance:CloseWindow(self.mainWindow)
end