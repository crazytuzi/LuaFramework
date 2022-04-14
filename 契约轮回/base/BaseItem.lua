--
-- Author: LaoY
-- Date: 2018-07-02 09:56:12
--
--AppConst.isLoadLocalRes = true
BaseItem = BaseItem or class("BaseItem", Node)

function BaseItem:ctor(parent_node, layer)
    self.parent_node = parent_node        -- 父节点
    self.layer = layer                    -- 层级
end

function BaseItem:dctor()
    -- lua_panelMgr:ClearItem(self)
end

function BaseItem:Load()
    local function load_call_back(obj)
        if obj then
            self:CreateItem(obj[0])
        end
    end
    if AppConst.isLoadLocalRes then
        local delay_local_call_back = function()
            lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back)
        end
        --延迟1秒容易出事
        GlobalSchedule.StartFunOnce(delay_local_call_back , 0.1)
    else
        lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back, nil, self.loadLevel or Constant.LoadResLevel.Best)
    end
    --

end

function BaseItem:__reset(parent_node, builtin_layer)
    BaseItem.super.__reset(self)
    parent_node = parent_node or self.parent_node
    if parent_node or not IsNil(parent_node) then
        self.parent_node = parent_node  -- 父节点
        if self.transform and not IsNil(self.transform) then
            self.transform:SetParent(self.parent_node)
        else
            if AppConfig.Debug then
                logError("transform is nil")
            end
        end
    end
end

function BaseItem:CreateItem(obj)
    -- 已经销毁或者加载失败
    if self.is_dctored or obj == nil or IsNil(obj) then
        logError("BaseItem CreateItem  28", self.abName, self.assetName)
        return
    end

    self.is_loaded = true

    self.gameObject = newObject(obj)
    self.transform = self.gameObject.transform
    self.transform_find = self.transform.Find

    -- 一定要先加入父节点
    self.transform:SetParent(self.parent_node)

    SetLocalScale(self.transform, 1, 1, 1)
    SetLocalPosition(self.transform, 0, 0, 0)
    SetLocalRotation(self.transform, 0, 0, 0)

    if self.transformName ~= nil then
        self.transform.name = self.transformName
    else
        self.transform.name = self.assetName
    end

    -- self:LoadCallBack()

    -- 如果加载节点报错，不至于影响后续操作
    local status, err = pcall(self.LoadCallBack, self)

    if self.isVisible ~= nil then
        self:SetVisible(self.isVisible)
    end
    if self.position ~= nil then
        self:SetPosition(self.position.x, self.position.y)
    end

    if self.sibling_index ~= nil then
        self:SetSiblingIndex(self.sibling_index)
    end

    if self.scale ~= nil then
        self:SetScale(self.scale)
    end

    if self.angle ~= nil then
        self:SetRotation(self.angle)
    end

    if self.order_index ~= nil then
        self:SetOrderIndex(self.order_index)
    end

    if not status then
        logError(self.__cname,err)
        -- self:Close()
    end
end

-- overwrite
function BaseItem:LoadCallBack()
    logWarn(string.format("%s 界面要重写 LoadCallBack方法", self.assetName))
end