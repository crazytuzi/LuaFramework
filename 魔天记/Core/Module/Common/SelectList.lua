
require "Core.Module.Common.SelectListPage";

SelectList = class("SelectList");
local insert = table.insert

function SelectList:Init(transform)
    self._transform = transform;
    self:_Init();
end

function SelectList:_Init()
    self._items = { };
    self.setItemSel = true;

    self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView");
    self._grid = UIUtil.GetChildByName(self._scrollView.transform, "UIGrid", "grid");
    self._gridCoc = UIUtil.GetChildByName(self._scrollView.transform, "UICenterOnChild", "grid");
    self._gridTr = self._grid.transform;
    
    self.onCoc = function() self:OnCenterOfChild(); end;
    self._gridCoc.onCenter = self.onCoc;

    UIUtil.RemoveAllChildren(self._grid.transform);

    self._btnLeft = UIUtil.GetChildByName(self._transform, "UIButton", "btnLeft");
    self._btnRight = UIUtil.GetChildByName(self._transform, "UIButton", "btnRight");

    self._pagesGrid = UIUtil.GetChildByName(self._transform, "UIGrid", "pages")
    self._pagesGridTr = self._pagesGrid.transform;

    if self._pagesGrid then
        UIUtil.RemoveAllChildren(self._pagesGridTr);
    end

    self._onClickBtnLeft = function(go) self:_OnClickBtnLeft() end
    UIUtil.GetComponent(self._btnLeft, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnLeft);
    self._onClickBtnRight = function(go) self:_OnClickBtnRight() end
    UIUtil.GetComponent(self._btnRight, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRight);

    self.onListSpringEnd = function() self:OnListSpringEnd() end

end

function SelectList:SetItemAutoSelect(v)
    self.setItemSel = v;
end

function SelectList:OnCenterOfChild()

    if self._gridCoc.centeredObject == nil then
        return;
    end
	
    if self._panelSpring == nil then
        self._panelSpring = UIUtil.GetComponent(self._scrollView.transform, "SpringPanel");
    end
    
    local tmp = string.split(self._gridCoc.centeredObject.name, "_");
    local index = tonumber(tmp[3]);

    if self._selIndex ~= index then
        self._selIndex = index;

        if self.setItemSel then
            for i,v in ipairs(self._items) do
                if v.itemLogic then
                    v.itemLogic:SetSelect(i == index);
                end
            end
        end
    end

    if self._pagesGrid then
        for i,v in ipairs(self._pageItems) do
            v:SetSelect(i == self._selIndex);
        end
    end

    if self.chgFunc then
        local d = self._items[index].data;
        self.chgFunc(d);
    end
end

function SelectList:SetItemClass(res, cls)
    self._itemRes = res;
    self._itemCls = cls;
end

function SelectList:SetOnItemChg(func)
    self.chgFunc = func;
end

function SelectList:Build(data)
    if self._pagesGrid then
        self._pageItems = { };
        UIUtil.RemoveAllChildren(self._pagesGridTr);
    end
    --self._items = { };
    self.data = data;
    local max = #data;
    local count = table.getn(self._items);

    if (count > max) then
        for i = max, count, -1 do
            self:_DelItem(i);
        end
    elseif (count < max) then
        for i = math.max(count, 1), max do
            self:_BuildItem(data[i], i);
        end
    end
    for i = 1, count do
        SelectList:SetItemData(self._items[i], data[i], i);
    end
end

function SelectList:Refresh()
    for i = 1, table.getn(self._items) do
        SelectList:SetItemData(self._items[i], self.data[i], i);
    end
end

function SelectList:_DelItem(index)
    if (self._items[index].itemLogic) then
        self._items[index].itemLogic:Dispose();
    end
    Resourcer.Recycle(self._items[index].gameObject);
    self._items[index] = nil;
end

function SelectList:_BuildItem(data, index)
    
    local itemGo = UIUtil.GetUIGameObject(self._itemRes);
    itemGo.name = itemGo.name  .. "_" .. index;
    UIUtil.AddChild(self._gridTr, itemGo.transform);
    local item = { };
    item.data = data;
    item.gameObject = itemGo;
    if self._itemCls then
        item.itemLogic = self._itemCls:New()
        item.itemLogic.index = index;
        item.itemLogic:Init(itemGo, data);
    end
    insert(self._items, item);

    if self._pagesGrid then
        local pageGo = UIUtil.GetUIGameObject(ResID.UI_PAGEITEM);
        UIUtil.AddChild(self._pagesGridTr, pageGo.transform);
        local pageItem = SelectListPage.New();
        pageItem:Init(pageGo.transform); 
        insert(self._pageItems, pageItem);
    end

    return item;
end

function SelectList:SetItemData(item, data, index)
    if (index ~= nil) then
        item.itemLogic.index = index + 1
    end
    item.itemLogic:UpdateItem(data);
end 


function SelectList:_OnClickBtnLeft()
    --[[
    if self._selIndex > 1 then
        self:StartListSpring(160);
    end
    ]]
    if self._panelSpring then
        local pos = self._panelSpring.target;
        if pos.x < -81 then
            pos.x = pos.x + 160;
            self:StartListSpring(pos);
        end
    end
end

function SelectList:_OnClickBtnRight()
    --[[]
    if self._selIndex < table.getn(self._items) then
        self:StartListSpring(-160);
    end
    ]]
    if self._panelSpring then
    local pos = self._panelSpring.target;
        if pos.x > -1199 then
            pos.x = pos.x - 160;
            self:StartListSpring(pos);
        end
    end
end

function SelectList:StartListSpring(pos)
    if self._panelSpring then
        self._panelSpring.strength = 16;
        self._panelSpring.target = pos;
        self._panelSpring.onFinished = self.onListSpringEnd;
        self._panelSpring.enabled = true;
    end
end

function SelectList:OnListSpringEnd()

    self._panelSpring.strength = 8;
    self._panelSpring.onFinished = nil;
    self._gridCoc:Recenter();
end

function SelectList:Dispose()
    
    for k, v in pairs(self._items) do
        if (v.itemLogic) then
            v.itemLogic:Dispose()
        end
        if (v.gameObject) then
            Resourcer.Recycle(v.gameObject,false)
            v.gameObject = nil
        end
        self._items[k] = nil
    end

    self.onCoc = nil;

    UIUtil.GetComponent(self._btnLeft, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnLeft = nil;
    UIUtil.GetComponent(self._btnRight, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRight = nil;
end



