Demo2Manager = Demo2Manager or BaseClass(BaseManager)

function Demo2Manager:__init()
    if Demo2Manager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    Demo2Manager.Instance = self
    self:InitHandler()
    
    -- model在此实例化，常驻
    self.model = Demo2Model.New()
end

function Demo2Manager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function Demo2Manager:InitHandler()
end

function Demo2Manager:TestLuaBehaviour()
end

function Demo2Manager:OpenWindow()
    self.model:OpenWindow()
end
