-- 视图组件基类，BasePanel和BaseWindow继承该类
BaseView = BaseView or BaseClass()

function BaseView:__init()
    -- MemoryCheckTable[self] = Time.time
    self.name = "<Unknown View>"
    self.viewType = ViewType.BaseView
    -- 根节点
    self.gameObject = nil
    self.assetWrapper = nil
    self.resList = {}
    self.resAutoCheck = false
end

function BaseView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper= nil
    end
end

-- 资源加载完毕事件
function BaseView:OnResLoadCompleted()
    self:InitPanel()
    self:__OnInitCompleted()
end

-- 窗口初始化(需要重写)
function BaseView:InitPanel()
end

function BaseView:__OnInitCompleted()
    self:OnInitCompleted()
end
-- 窗口初始化完成(需要重写)
function BaseView:OnInitCompleted()
end

-- 资源加载
function BaseView:LoadAssetBundleBatch()
    if self.assetWrapper ~= nil then
        local errorInfo = "BaseView<" .. self.name .. ">assetWrapper不可以重复使用"
        for key, _ in pairs(self.resList) do
            errorInfo = errorInfo .. " /r/n" .. key
        end
        Log.Error(errorInfo)
    end
    self.assetWrapper = AssetBatchWrapper.New()
    local callback = function()
        self:OnResLoadCompleted()
    end
    if self.resAutoCheck then
        self.assetWrapper:LoadAssetBundle(PrefabdepManager.Instance:AppendDep(self.resList), callback)
    else
        self.assetWrapper:LoadAssetBundle(self.resList, callback)
    end
end

-- 获取prefab
function BaseView:GetPrefab(file)
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetMainAsset(file)
    else
        return nil
    end
end

-- 资源unload
-- unload AssetType.Main类型
function BaseView:ClearMainAsset()
    if self.assetWrapper ~= nil then
        self.assetWrapper:ClearMainAsset()
    end
end
-- unload AssetType.Dep类型
-- 一般情况下是窗口关闭并注销的时候关闭
function BaseView:ClearDepAsset()
    if self.assetWrapper ~= nil then
        self.assetWrapper:ClearDepAsset()
    end
end
-- unload所有资源
-- 与上面两个方法不可以重复调用
function BaseView:AssetClearAll()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper= nil
    end
end
