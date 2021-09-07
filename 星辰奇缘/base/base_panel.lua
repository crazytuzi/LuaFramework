-- 面板
-- Panel依附于window，由window控制其生命周期
BasePanel = BasePanel or BaseClass(BaseView)

function BasePanel:__init()
    -- 父对象，一般情况下是BaseWindow对象
    self.parent = nil
    self.name = "<Unknown Panel>"
    self.viewType = ViewType.Panel

    self.openArgs = nil

    -- 窗口隐藏事件
    self.OnHideEvent = EventLib.New()
    -- 窗口打开事件
    self.OnOpenEvent = EventLib.New()

    self.loading = false
end

function BasePanel:__delete()
    self.openArgs = nil
    if self.OnHideEvent ~= nil then
        self.OnHideEvent:DeleteMe()
        self.OnHideEvent = nil
    end
    if self.OnOpenEvent ~= nil then
        self.OnOpenEvent:DeleteMe()
        self.OnOpenEvent = nil
    end
end

function BasePanel:__OnInitCompleted()
    self.loading = false
    self:OnInitCompleted()
end

function BasePanel:Show(arge)
    if self.loading then
        return
    end
    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function BasePanel:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
        self.OnHideEvent:Fire()
    end
end
