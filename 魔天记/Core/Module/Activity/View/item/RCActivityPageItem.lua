require "Core.Module.Common.UIItem"

require "Core.Module.Activity.View.item.RCActivityItem"

RCActivityPageItem = class("RCActivityPageItem", UIItem);

function RCActivityPageItem:New()
    self = { };
    setmetatable(self, { __index = RCActivityPageItem });
    return self
end

 
function RCActivityPageItem:UpdateItem(data)
    self.data = data
end

function RCActivityPageItem:Init(gameObject, data)
    self.gameObject = gameObject

    self.items = { };

    for i = 1, 8 do
        local gobj = UIUtil.GetChildByName(self.gameObject, "Transform", "item" .. i);
        self.items[i] = RCActivityItem:New();
        self.items[i]:Init(gobj);
    end

end

function RCActivityPageItem:SetActive(v)
    self.gameObject:SetActive(v);
end


function RCActivityPageItem:SetSelect(activity_id)

    local b = false;
    for i = 1, 8 do
        local tb = self.items[i]:SetSelect(activity_id);
        if tb then
            b = true;
        end
    end
    return b

end

function RCActivityPageItem:SetData(d, has_nPoint)
    self.list = d;

    if self.list ~= nil then
        local pag_num = table.getn(self.list);

        for i = 1, 8 do
            self.items[i]:SetData(self.list[i], has_nPoint);
        end
        self:SetActive(true);
    else
        self:SetActive(false);
    end
end

function RCActivityPageItem:_Dispose()
    for i = 1, 8 do
        self.items[i]:Dispose();
        self.items[i] = nil;
    end
    self.gameObject = nil;

    self.items = nil;

end