require "Core.Module.Common.UIItem"

require "Core.Module.LingYao.View.item.LingYaoHeProItem"


LingYaoHeChengTypeItem = class("LingYaoHeChengTypeItem", UIItem);

LingYaoHeChengTypeItem.currSelected = { };

function LingYaoHeChengTypeItem:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeChengTypeItem });
    return self
end
 

function LingYaoHeChengTypeItem:UpdateItem(data)
    self.data = data
end

function LingYaoHeChengTypeItem:Init(gameObject, data)

    self.gameObject = gameObject;



    self.txtTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtTitle");
    self.canComTipTicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "canComTipTicon");


    self.yp_phalanx = UIUtil.GetChildByName(self.gameObject, "Transform", "yp_phalanx");
    self._item_phalanx = UIUtil.GetChildByName(self.gameObject, "LuaAsynPhalanx", "yp_phalanx");

    self:SetData(data)

    self:HideItems();

    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);

end


function LingYaoHeChengTypeItem:SetIndex(v, _clsTable)
    self.index = v;
    self._clsTable = _clsTable;

    local _items = self.product_phalanx._items;
    local t_num = table.getn(_items);

    for j = 1, t_num do
        _items[j].itemLogic:SetIndex(self.index);
    end


end

function LingYaoHeChengTypeItem:UpShowListItem(v)

    local _items = self.product_phalanx._items;
    local t_num = table.getn(_items);
    local index = 1;

    for j = 1, t_num do
        local fv = _items[j].itemLogic:UpShowListItem(v);

        if fv then
            local gtf = _items[j].itemLogic.gameObject.transform;
            local pos = self.posList[index];

            Util.SetLocalPos(gtf, pos.x, pos.y, 0)

            --            gtf.localPosition = Vector3.New(pos.x, pos.y, 0);


            index = index + 1;
        end

    end

    self._clsTable:Reposition();

end

function LingYaoHeChengTypeItem:_OnClickHandler()

    if LingYaoHeChengTypeItem.currSelected[self.index] == self then

        if self.itemShow then
            self:HideItems()
        else
            self:ShowItems()
        end

    else

        if LingYaoHeChengTypeItem.currSelected[self.index] ~= nil then
            LingYaoHeChengTypeItem.currSelected[self.index]:HideItems()
        end

        LingYaoHeChengTypeItem.currSelected[self.index] = self;
        LingYaoHeChengTypeItem.currSelected[self.index]:ShowItems()

    end

end


function LingYaoHeChengTypeItem:ShowItems()

    self.itemShow = true;
    self.yp_phalanx.gameObject:SetActive(true);
    self._clsTable:Reposition();
end

function LingYaoHeChengTypeItem:HideItems()

    self.itemShow = false;
    self.yp_phalanx.gameObject:SetActive(false);

    if self._clsTable ~= nil then
        self._clsTable:Reposition();
    end

end


function LingYaoHeChengTypeItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end




function LingYaoHeChengTypeItem:SetData(data)

    self.data = data;

    self.txtTitle.text = self.data.name;


    local type = self.data.type;
    local kind = self.data.kind;



    local itemList = LingYaoDataManager.GetProductsList(type, kind);
    local t_num = table.getn(itemList);

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, LingYaoHeProItem);
    self.product_phalanx:Build(t_num, 1, itemList);

    -------------------------------------------------------------------
    local items = self.product_phalanx._items;
    local t_num = table.getn(items);

    self.posList = { };


    for i = 1, t_num do
        local gtf = items[i].itemLogic.gameObject.transform;
        self.posList[i] = { x = gtf.localPosition.x, y = gtf.localPosition.y };
    end

    ---------------------------------------------------


    self:UpInfos(true);
end


function LingYaoHeChengTypeItem:UpInfos(setTip)

    local items = self.product_phalanx._items;
    local t_num = table.getn(items);

    local canShowComTip = false;

    for i = 1, t_num do
        items[i].itemLogic:UpInfo();
        local canComp = items[i].itemLogic.canCompos;
        if canComp then
            canShowComTip = true;
        end
    end

    if setTip then
        if canShowComTip then
            self.canComTipTicon.gameObject:SetActive(true);
        else
            self.canComTipTicon.gameObject:SetActive(false);
        end
    end

    return canShowComTip;
end


function LingYaoHeChengTypeItem:_Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil;

    self.product_phalanx:Dispose()
    self.product_phalanx = nil;

    self.gameObject = nil;


    self.txtTitle = nil;
    self.canComTipTicon = nil;


    self.yp_phalanx = nil;
    self._item_phalanx = nil;


end