require "Core.Module.LingYao.View.item.LingYaoSetItem"


LingYaoSetPanelCtr = class("LingYaoSetPanelCtr");

function LingYaoSetPanelCtr:New()
    self = { };
    setmetatable(self, { __index = LingYaoSetPanelCtr });
    return self
end

function LingYaoSetPanelCtr:Init(gameObject, lingyaoData, i)

    self.gameObject = gameObject;
    self.lingyaoData = lingyaoData;


    self.listPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    local list = self.lingyaoData.list;
    local t_num = table.getn(list);

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, LingYaoSetItem);
    self.product_phalanx:Build(t_num, 1, list);

   self.list = list;

end



function LingYaoSetPanelCtr:UpInfos()

    local items = self.product_phalanx._items;
    local t_num = table.getn(items);
    for i = 1, t_num do
        local obj = items[i].itemLogic;
        obj:UpInfos()
    end

end


function LingYaoSetPanelCtr:GetKind()

  return self.list[1].kind;

end



function LingYaoSetPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LingYaoSetPanelCtr:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function LingYaoSetPanelCtr:Dispose()

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
    end


    self.gameObject = nil;

end