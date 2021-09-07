-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

FaceModel = FaceModel or BaseClass(BaseModel)

function FaceModel:__init()
end

function FaceModel:__delete()
end

function FaceModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = FaceWindow.New(self)
    end
    self.mainWin:Open(args)
end

function FaceModel:OpenEffect(args)
    if self.effect == nil then
        self.effect = FaceGetEffectPanel.New(self)
    end
    self.effect:Show(args)
end

function FaceModel:CloseWindow()
end


