ScrollPageList = class("ScrollPageList");
local insert = table.insert

function ScrollPageList:Init(transform)
    self._transform = transform;
    self:_Init();
    self:_InitReference();
	self:_InitListener();
end

function ScrollPageList:_Init()
	self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView");
    self._grid = UIUtil.GetChildByName(self._scrollView.transform, "UIGrid", "grid");
    self._gridCoc = UIUtil.GetChildByName(self._scrollView.transform, "UICenterOnChild", "grid");
    self._gridTr = self._grid.transform;
    
    self.onCoc = function() self:OnCenterOfChild(); end;
    self._gridCoc.onCenter = self.onCoc;

    UIUtil.RemoveAllChildren(self._grid.transform);

    self._pagesGrid = UIUtil.GetChildByName(self._transform, "UIGrid", "pages")
    self._pagesGridTr = self._pagesGrid.transform;

    if self._pagesGrid then
        UIUtil.RemoveAllChildren(self._pagesGridTr);
    end

    self._items = {};
    self._pageItems = {};
end

function ScrollPageList:_InitReference()
    
end

function ScrollPageList:_InitListener()
    
end

function ScrollPageList:Dispose()
    self:_Dispose();
    self:_DisposeReference();
    self:_DisposeListener();
end

function ScrollPageList:_Dispose()
    for i, v in ipairs(self._items) do
        self:_DelItem(i);
    end

    self:ClearPage();
    if self._gridCoc and self._gridCoc.onCenter then
        self._gridCoc.onCenter:Destroy();
    end
    self.onCoc = nil;
end

function ScrollPageList:_DisposeReference()
    
end

function ScrollPageList:_DisposeListener()
    
end

function ScrollPageList:SetItemClass(res, cls)
    self._itemRes = res;
    self._itemCls = cls;
end

function ScrollPageList:SetOnItemChg(func)
    self.chgFunc = func;
end

function ScrollPageList:ClearPage()
    if self._pagesGrid then
        for i, v in ipairs(self._pageItems) do
            v:Dispose();
        end
        UIUtil.RemoveAllChildren(self._pagesGridTr);
        self._pageItems = {};
    end
end

function ScrollPageList:Build(data, x, y)
    local perPage = x * y;
    local num = #data;
    local max = num / perPage;
    if num > 0 and num < perPage then
        max = 1;
    end

    local count = table.getn(self._items);
    if (count > max) then
        for i = max, count, -1 do
            self:_DelItem(i);
        end
    elseif (count < max) then
        for i = math.max(count, 1), max do
            self:_BuildItem(nil, i);
        end
    end

    for i,v in ipairs(self._items) do
        local tmp = {};
        local k = perPage * (i - 1) + 1;
        for n = k, k + perPage - 1 do 
            if data[n] then
                insert(tmp, data[n]);
            end
        end 
        self:SetItemData(v, tmp, i);
    end

    UIUtil.RestGrid(self._grid.gameObject);

    if self._pagesGrid then
        UIUtil.RestGrid(self._pagesGrid.gameObject);
    end
    
    self:SetSelectIdx(1);
end

function ScrollPageList:Refresh()
    for i = 1, table.getn(self._items) do
        self:SetItemData(self._items[i], data[i], i);
    end
end

function ScrollPageList:_DelItem(index)
    if (self._items[index].itemLogic) then
        self._items[index].itemLogic:Dispose();
    end

    if self._items[index].gameObject then
        Resourcer.Recycle(self._items[index].gameObject);
    end

    self._items[index] = nil;

    if self._pagesGrid then
        for i,v in ipairs(self._pageItems) do
            if (i == index) then
                v:Dispose();
                if v.gameObject then
                    Resourcer.Recycle(v.gameObject);
                end
            end
        end
        table.remove(self._pageItems, index);
    end
end

function ScrollPageList:_BuildItem(data, index)
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

function ScrollPageList:SetItemData(item, data, index)
    item.itemLogic.index = index;
    item.itemLogic:UpdateItem(data);
end 

function ScrollPageList:OnCenterOfChild()
    if self._gridCoc.centeredObject then
        local tmp = string.split(self._gridCoc.centeredObject.name, "_");
        local index = tonumber(tmp[3]);
        self:SetSelectIdx(index);
    end
end

function ScrollPageList:SetSelectIdx(index)
    if self._selIndex ~= index then
        self._selIndex = index;

        if self._pagesGrid then
            for i,v in ipairs(self._pageItems) do
                v:SetSelect(i == index);
            end
        end

        if self.chgFunc then
            local d = self._items[index].data;
            self.chgFunc(d);
        end
    end
end
