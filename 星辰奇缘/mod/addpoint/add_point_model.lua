-- ------------------------
-- 角色宠物加点控制
-- hosr
-- ------------------------
AddPointModel = AddPointModel or BaseClass(BaseModel)

function AddPointModel:__init()
    self.addPointView = nil
end

function AddPointModel:__delete()
    self:Close()
end

function AddPointModel:Close()
    if self.addPointView ~= nil then
        -- self.addPointView:DeleteMe()
        -- self.addPointView = nil
        WindowManager.Instance:CloseWindow(self.addPointView)
    end
end

function AddPointModel:Open(args)
    if self.addPointView == nil then
        self.addPointView = AddPoint.New(self)
    end
    self.addPointView:Open(args)
end
