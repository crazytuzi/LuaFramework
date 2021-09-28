UITableList = class("UITableList");

--不固定长宽元素的列表控件.
--transform scrollView的transform 并且有一个叫Table的UITableGameObject

function UITableList:Init(transform, itemRes, itemCls)
	self._transform = transform;
	self._itemRes = itemRes;
	local tempName = string.split(itemRes, "/")
	self._itemName = tempName[table.getCount(tempName)]
	self._itemCls = itemCls;
	self:_Init();
	self:_InitReference();
	self:_InitListener();
end

function UITableList:_InitReference()
	
end

function UITableList:_InitListener()
	
end

function UITableList:_Init()
	self._scrollView = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView");
	--self._scrollPanel = UIUtil.GetChildByName(self._transform, "UIPanel", "scrollView");
	self._uiTable = UIUtil.GetChildByName(self._scrollView.transform, "UITable", "Table");
	self._trsUITable = self._uiTable.transform;
	UIUtil.RemoveAllChildren(self._trsUITable);
	
	self._items = {};
	UpdateBeat:Add(self.Update, self);
end

function UITableList:Dispose()
	self:_Dispose();
	self:_DisposeReference();
	self:_DisposeListener();
end

function UITableList:_Dispose()
	
	for i, v in ipairs(self._items) do
		self:_DelItem(i);
	end
	
	UpdateBeat:Remove(self.Update, self);
end

function UITableList:_DisposeReference()
	
end

function UITableList:_DisposeListener()
	
end

function UITableList:Update()
	if self.needAdjustSize then
		--[[        if self._transform.gameObject.activeInHierarchy then
            self:DoAdjustSize();
        else
            --如果gameObject不在激活状态. 则延迟更新uitable
            self.delayAdjustSize = true;
        end
        ]]
        self._uiTable.repositionNow = true;
        --self._uiTable:Reposition();

		self.delayAdjustSize = true;
		self.needAdjustSize = false;
		return;
	end
	
	--延迟更新uitable.
	if self.delayAdjustSize then
		if self._transform.gameObject.activeInHierarchy then
			self:DoAdjustSize();
			self.delayAdjustSize = false;
		end
	end
end

function UITableList:DoAdjustSize()
	--Warning("UITableList:DoAdjustSize");
	
	--self._scrollView:ResetPosition();
	self._scrollView:RestrictWithinBounds(true, false, true);
	if #self._items < 3 then
		self._scrollView:ResetPosition();
	end
end

function UITableList:ResetPosition()
	self._scrollView:ResetPosition();
end

function UITableList:Build(data)
	local num = # data;
	local cur = # self._items;
	
	if(cur > num) then
		for i = cur, num + 1, - 1 do
			self:_DelItem(i);
		end
	elseif(cur < num) then
		for i = cur + 1, num do
			self:_BuildItem(nil, i);
		end
	end
	
	for i, v in ipairs(self._items) do
		self:SetItemData(v, data[i], i);
	end
	
	--log(cur .." - ".. num)
	self.needAdjustSize = true;
	
--self._uiTable.repositionNow = true;
--self._scrollView:ResetPosition();
end

function UITableList:_DelItem(index)
	if(self._items[index].itemLogic) then
		self._items[index].itemLogic:Dispose();
	end
	
	if self._items[index].gameObject then
		self._items[index].gameObject.name = self._itemName
		Resourcer.Recycle(self._items[index].gameObject,false);
	end
	
	self._items[index] = nil;
end

function UITableList:_BuildItem(data, index)
	local itemGo = UIUtil.GetUIGameObject(self._itemRes);
	itemGo.name = itemGo.name .. "_" .. index;
	UIUtil.AddChild(self._trsUITable, itemGo.transform);
	local item = {};
	item.data = data;
	item.gameObject = itemGo;
	if self._itemCls then
		item.itemLogic = self._itemCls.New();
		item.itemLogic.index = index;
		item.itemLogic:Init(itemGo, data);
	end
	--table.insert(self._items, item);
	self._items[index] = item;
	return item;
end

function UITableList:SetItemData(item, data, index)
	item.itemLogic.index = index;
	item.itemLogic:UpdateItem(data);
end

function UITableList:GetItems()
	return self._items;
end