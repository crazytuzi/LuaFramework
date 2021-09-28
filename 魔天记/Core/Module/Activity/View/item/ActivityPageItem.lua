require "Core.Module.Common.UIItem"

require "Core.Module.Activity.View.item.ActivityFBItem"

ActivityPageItem = class("ActivityPageItem", UIItem);

function ActivityPageItem:New()
    self = { };
    setmetatable(self, { __index = ActivityPageItem });
    return self
end

 
function ActivityPageItem:UpdateItem(data)
    self.data = data
end

function ActivityPageItem:Init(gameObject, data)
    self.gameObject = gameObject

    self.items = { };

    for i = 1, 6 do
        local gobj = UIUtil.GetChildByName(self.gameObject, "Transform", "item" .. i);
        self.items[i] = ActivityFBItem:New();
        self.items[i]:Init(gobj);
    end

end

function ActivityPageItem:SetSelect(activity_id)

    for i = 1, 6 do

        self.items[i]:SetSelect(activity_id);
    end

end

function ActivityPageItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ActivityPageItem:SetData(d)

    self.list = d;

    if self.list ~= nil then
        local pag_num = table.getn(self.list);
        for i = 1, 6 do
            self.items[i]:SetData(self.list[i]);
        end

        self:SetActive(true);

    else
        self:SetActive(false);
    end



end

function ActivityPageItem:_Dispose()


    for i = 1, 6 do
        self.items[i]:Dispose();
        self.items[i] = nil;
    end

    self.gameObject = nil;
    self.items = nil;


end