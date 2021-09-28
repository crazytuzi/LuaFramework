require "Core.Module.LingYao.View.item.LingYaoHeChengTypeItem"



LingYaoHeChengLeftPanelCtr = class("LingYaoHeChengLeftPanelCtr");

function LingYaoHeChengLeftPanelCtr:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeChengLeftPanelCtr });
    return self
end

function LingYaoHeChengLeftPanelCtr:Init(gameObject, i)

    self.gameObject = gameObject;
    self.i = i;

    self.listPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "listPanel");

    self._item_phalanx = UIUtil.GetChildByName(self.listPanel, "LuaAsynPhalanx", "table");
    self._clsTable = UIUtil.GetChildByName(self.listPanel, "UITable", "table");


    local list = LingYaoDataManager.GetHeChengList(i);
    local t_num = table.getn(list);

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, LingYaoHeChengTypeItem);
    self.product_phalanx:Build(t_num, 1, list);

    local _items = self.product_phalanx._items;
    for j = 1, t_num do
        _items[j].itemLogic:SetIndex(self.i, self._clsTable);
    end

end



function LingYaoHeChengLeftPanelCtr:UpInfos(setTip)

    local _items = self.product_phalanx._items;
    local t_num = table.getn(_items);

    local res = false;
    for j = 1, t_num do
       local b =  _items[j].itemLogic:UpInfos(setTip);
       if b then
          res = true;
       end
    end
    return res;
end

function LingYaoHeChengLeftPanelCtr:UpShowListItem(v)

    local _items = self.product_phalanx._items;
    local t_num = table.getn(_items);

    for j = 1, t_num do
        _items[j].itemLogic:UpShowListItem(v);
    end

    -- self._clsTable:Reposition();
end



function LingYaoHeChengLeftPanelCtr:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LingYaoHeChengLeftPanelCtr:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function LingYaoHeChengLeftPanelCtr:Dispose()

    self.product_phalanx:Dispose()

    self.gameObject = nil;

     
    self.listPanel = nil;

    self._item_phalanx = nil;
    self._clsTable = nil;

    self.product_phalanx = nil;
   
end