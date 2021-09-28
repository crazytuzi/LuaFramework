require "Core.Module.Common.UIItem"

ProductItems = UIItem:New()

-- 通用道具显示容器, 无滚动
-- parent显示父节点,data配置道具格式:id_数量(100_1),...
-- w,h单个道具占用宽/高, c 多少行/列
function ProductItems:Init(parent, data, w, h, c)
    self._parent = parent.transform
    self.data = data
    self._w, self._h, self._c = w or 2, h or 2, c or 1
    self:_Init()
end
function ProductItems:_Init()
    self._items = {}
    self._itemGos = {}
    self:UpdateItem(self.data)
end

function ProductItems:UpdateItem(data)
    self.data = data
    for i,v in pairs(self._items) do 
        v:UpdateItem(nil)
        v:SetVisible(false)
    end
    if data then
        local mf = math.floor
        for i,v in ipairs(data) do 
            local item = string.split(v, "_")
            local d = ProductInfo:New()
            d:Init({spId = tonumber(item[1]), am = tonumber(item[2])})
            local itemUI = self._items[i]
            if not itemUI then
                itemUI = self:_CreateItem(d, i, ((i - 1) % self._c) * self._w
                    , mf((i - 1) / self._c) * -self._h)
            else
                itemUI:UpdateItem(d);
            end
            itemUI:SetVisible(false)
            itemUI:SetVisible(true)
        end
    end
end
function ProductItems:_CreateItem(data, i, x, y)
    local itemGo = UIUtil.GetUIGameObject(ResID.UI_PropsItem)
    UIUtil.AddChild(self._parent, itemGo.transform, x, y, 0)
    local itemUI = PropsItem:New()
    itemUI:Init(itemGo, data);
    itemUI:AddBoxCollider()
    self._items[i] = itemUI;
    self._itemGos[i] = itemGo;
    return itemUI
end

function ProductItems:_Dispose()
    for i,v in ipairs(self._items) do 
        v:Dispose() 
        Resourcer.Recycle(self._itemGos[i], false);
    end
    self._itemGos = nil
    self._items = nil
    self._parent = nil
end
