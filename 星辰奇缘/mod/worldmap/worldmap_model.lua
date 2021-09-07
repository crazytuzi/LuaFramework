WorldMapModel = WorldMapModel or BaseClass(BaseModel)

function WorldMapModel:__init()
    self.window = nil
end

function WorldMapModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function WorldMapModel:OpenWindow(args)
    if SceneManager.Instance.sceneModel.sceneView.textureid == nil then
        return
    end

    if self.window == nil then
        self.window = WorldMapView.New(self)
        self.window:Open(args)
    end
end

function WorldMapModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function WorldMapModel:FixedUpdate()
    if self.window ~= nil then
        self.window:FixedUpdate()
    end
end