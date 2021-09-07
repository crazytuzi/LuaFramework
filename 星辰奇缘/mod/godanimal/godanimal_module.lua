-- @author zgs
GodAnimalModel = GodAnimalModel or BaseClass(BaseModel)

function GodAnimalModel:__init()
    self.gaWin = nil
    self.godAnimalChangeWindow = nil
end

function GodAnimalModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
    if self.godAnimalChangeWindow then
        self.godAnimalChangeWindow = nil
    end
end

function GodAnimalModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = GodAnimalWindow.New(self)
    end
    self.gaWin:Open(args)
end

function GodAnimalModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end

function GodAnimalModel:OpenChangeWindow(args)
    if self.godAnimalChangeWindow == nil then
        self.godAnimalChangeWindow = GodAnimalChangeWindow.New(self)
    end
    self.godAnimalChangeWindow:Open(args)
end

function GodAnimalModel:CloseChangeMain()
    WindowManager.Instance:CloseWindow(self.godAnimalChangeWindow, true)
end