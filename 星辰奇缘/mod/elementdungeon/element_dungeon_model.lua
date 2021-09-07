-- 元素副本 model
-- ljh 20161215
ElementDungeonModel = ElementDungeonModel or BaseClass(BaseModel)

function ElementDungeonModel:__init()
    self.window = nil
end

function ElementDungeonModel:InitData()

end

function ElementDungeonModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ElementDungeonModel:OpenWindow(args)
    if self.window == nil then
        self.window = ElementDungeonWindow.New(self)
    end
    self.window:Open(args)
end

function ElementDungeonModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end