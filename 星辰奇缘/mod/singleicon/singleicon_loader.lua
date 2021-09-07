-- 图标icon单独加载
SingleIconLoader = SingleIconLoader or BaseClass()

function SingleIconLoader:__init(gameObject)
    self.gameObject = gameObject
    self.image = gameObject:GetComponent(Image)
    self.callback = function(icon) self:OnCallback(icon) end
    self.hasDestory = false
    self.isLoading = false
    self.isUsed = false
    self.setnativesize = false
    self.iconType = nil
    self.iconId = nil
    self.loadedCallback = nil
end

function SingleIconLoader:__delete()
    -- if not BaseUtils.isnull(self.image) then
    --     self.image.sprite = nil
    -- end
    self:OnRelease()
end

-- LuaOnDestroy.cs 脚本回调
-- 防止不规范操作下，由于未调用DeleteMe导致资源无法释放的问题
function SingleIconLoader:OnDestroy()
    self:OnRelease()
end

function SingleIconLoader:OnCallback(icon)
    self.isLoading = false
    if not BaseUtils.is_null(self.gameObject) then
        if LuaOnDestory then
            self.bridge = self.gameObject:GetComponent(LuaOnDestory)
            if self.bridge == nil then
                self.bridge = self.gameObject:AddComponent(LuaOnDestory)
                self.bridge:SetDestoryCall(function() self:OnDestroy() end)
            end
        end
        self.image.sprite = icon
        if self.setnativesize then
            self.image:SetNativeSize()
        end
        self.image.color = self.color

        if self.loadedCallback ~= nil then
            self.loadedCallback()
            self.loadedCallback = nil
        end
    else
        -- 这里是一个保底的操作，以防加载完之前gameobject不在了，然后又没正常进行delete
        self:DecreaseReferenceCount()
    end
end

function SingleIconLoader:SetSprite(iconType, iconId, SetNativeSize)
    if self.isLoading then
        self.loadedCallback = function() self:SetSprite(iconType, iconId, SetNativeSize) end
        return
    end

    if iconId ~= 0 and self.iconId == iconId then
        if not BaseUtils.is_null(self.gameObject) then
            self.image.color = self.color
        end
        return
    end

    -- 释放掉上次的资源
    self.image = nil
    if self.iconId ~= nil and self.iconId ~= 0 then
        self:DecreaseReferenceCount()
    end

    if SetNativeSize ~= nil then
        self.setnativesize = SetNativeSize
    end

    self.image = self.gameObject:GetComponent(Image)
    self.color = Color(self.image.color.r, self.image.color.g, self.image.color.b, self.image.color.a)
    self.image.color = Color(self.color.r, self.color.g, self.color.b, 0)
    self.iconType = iconType
    self.iconId = iconId
    self.isLoading = true
    self.isUsed = true
    SingleIconManager.Instance:GetSprite(self.iconType, self.iconId, self.callback)
end

function SingleIconLoader:OnRelease()
    if self.hasDestory then
        -- 删了又删会导致引用数不对
        return
    end

    self.hasDestory = true
    self.bridge = nil
    self.image = nil
    self.callback = nil
    self.gameObject = nil

    -- 没被使用过的话是不存在要释放的资源
    if not self.isLoading and self.isUsed then
        self:DecreaseReferenceCount()
    end
end

function SingleIconLoader:DecreaseReferenceCount()
    if self.iconType ~= nil and self.iconId ~= nil then
        SingleIconManager.Instance:DecreaseReferenceCount(self.iconType, self.iconId)
    end
    self.iconType = nil
    self.iconId = nil
end

-- 外部使用时会遇到一种情况
-- 本来是使用道具图标，某些逻辑下会使用其他图标
-- 这里提供外部用的，释放上一次引用的接口
function SingleIconLoader:SetOtherSprite(sprite)
    if self.isLoading then
        return
    end

    self.image = nil
    if self.iconType ~= nil and self.iconId ~= nil then
        self:DecreaseReferenceCount()
    end
    self.image = self.gameObject:GetComponent(Image)
    self.image.sprite = sprite

    if self.color ~= nil then
        self.image.color = self.color
    end
end

-- 外部设置图标的颜色值，这里做一个接口，处理未加载完时的值缓存
function SingleIconLoader:SetIconColor(color)
    if self.isLoading then
        self.color = color
    else
        if self.image ~= nil then
            self.image.color = color
        end
    end
end