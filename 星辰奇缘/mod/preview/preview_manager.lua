-- 模型预览
PreviewManager = PreviewManager or BaseClass(BaseManager)

function PreviewManager:__init()
    if PreviewManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PreviewManager.Instance = self;

    if IS_DEBUG then
        self.previewLogDic = {}
    end

    self.count = 0
    self.nextX = 100
    self.container = nil

    self:CreateContainer()
end

function PreviewManager:__delete()
end

function PreviewManager:NextX()
    self.nextX = self.nextX + 5
    return self.nextX
end

function PreviewManager:CreateContainer()
    self.container = GameObject("PreviewContainer")
    self.container.transform.position = Vector3(0, 0, 0)
    GameObject.DontDestroyOnLoad (self.container);
    Utils.ChangeLayersRecursively(self.container.transform, "ModelPreview")
end

function PreviewManager:CheckRelease()
    local tab = {}
    for k,v in pairs(self.previewLogDic) do
        if v ~= nil then
            if v.rawImage ~= nil and BaseUtils.isnull(v.rawImage) then
                Log.Error("模型预览没调用DeleteMe " .. v.tpose.name)
            end
            tab[k] = v
        end
    end

    self.previewLogDic = tab
end

function PreviewManager:GetCount()
    self.count = self.count + 1
    return self.count
end

function PreviewManager:Insert(composite)
    local id = self:GetCount()
    self.previewLogDic[id] = composite
    return id
end

function PreviewManager:Remove(id)
    self.previewLogDic[id] = nil
end


