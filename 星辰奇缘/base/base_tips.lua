-- -------------------------------------------
-- tips基类
-- hosr
-- -------------------------------------------
BaseTips = BaseTips or BaseClass(BaseView)

function BaseTips:__init()
    self.parent = nil
    self.name = "<Unknown Tips>"
    self.viewType = ViewType.Tips

    -- 窗口隐藏事件
    self.OnHideEvent = EventLib.New()

    self.loading = false
end

function BaseTips:__delete()
    self.openArgs = nil
    self.callback = nil
    self.OnHideEvent:DeleteMe()
    self.OnHideEvent = nil
    self.loading = false
end

-- 资源加载完毕事件
function BaseTips:OnResLoadCompleted()
    self.loading = false
    self:InitPanel()
    self:OnInitCompleted()
    self.gameObject:SetActive(true)
    if self.callback ~= nil then
        self.callback()
    end
    self:ClearMainAsset()
end

-- 子类重写
function BaseTips:UpdateInfo()
    -- 更新数据
end

function BaseTips:Show(callback)
    if self.loading then
        return
    end
    self.callback = callback
    if self.gameObject ~= nil then
        self.loading = false
        self.gameObject:SetActive(true)
        if self.callback ~= nil then
            self.callback()
        end
    else
        self.loading = true
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function BaseTips:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
        self.OnHideEvent:Fire()
    end
end
