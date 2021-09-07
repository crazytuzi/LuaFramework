-- ---------------
-- 剧情动作基类
-- ---------------
BaseDramaPanel = BaseDramaPanel or BaseClass(BaseView)

function BaseDramaPanel:__init()
    self.name = "<Unknown DramaPanel>"
    self.viewType = ViewType.Panel
    self.parent = nil
    self.openArgs = nil
    self.isMulti = false
end

function BaseDramaPanel:__delete()
end

-- 子类重写,作为初始化或显示后的处理回调
function BaseDramaPanel:OnInitCompleted()
end

function BaseDramaPanel:Show(args)
    self.openArgs = args
    if self.gameObject ~= nil then
        self:OnInitCompleted()
        self.gameObject:SetActive(true)
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function BaseDramaPanel:Hiden()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function BaseDramaPanel:OnJump()
end