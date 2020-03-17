_G.UIGMCmd = BaseUI:new("UIGMCmd");
UIGMCmd.sorts = nil;
UIGMCmd.items = nil;
UIGMCmd.currSort = nil;
UIGMCmd.currItem = nil;

function UIGMCmd:Create()
	self:AddSWF("gmCmd.swf",true,"center");
end

function UIGMCmd:OnLoaded(objSwf)
	objSwf.gmSortList.itemClick = function(e) self:OnSortListClick(e); end
	objSwf.gmItemList.itemClick = function(e) self:OnItemListClick(e); end
	objSwf.gmItemList.itemDoubleClick = function(e) self:OnItemListDoubleClick(e); end
end

function UIGMCmd:OnSortListClick(e)
	local sort = self.sorts[e.index+1];
	if not sort then
		return;
	end
	
	local swf = self.objSwf;
	
	swf.gmParam1.text = "param1";
	swf.gmParam2.text = "param2";
	swf.gmParam3.text = "param3";
	self.currSort = nil;
	self.currItem = nil;
	
	self.currSort = sort;
	self.items = {};
	swf.gmItemList.dataProvider:cleanUp();
	
	local items = _G.GmCmdList[sort.name];
	if not items then
		return;
	end
	
	for name,item in ipairs(items) do
		local vo = {};
		vo.name = name;
		vo.item = item;
		table.push(self.items,vo);
		swf.gmItemList.dataProvider:push(vo.item.desc);
	end
	swf.gmItemList:invalidateData();
	swf.gmItemList.selectedIndex = 0;
end

function UIGMCmd:OnItemListClick(e)
	local item = self.items[e.index+1];
	if not item then
		return;
	end
	
	local swf = self.objSwf;
	
	if self.currItem == nil or self.currItem.item.desc ~= item.item.desc then
		swf.gmParam1.text = "";
		swf.gmParam2.text = "";
		swf.gmParam3.text = "";
	
		if item.item.param1_default_value then
			swf.gmParam1.text = item.item.param1_default_value;
		end
		if item.item.param2_default_value then
			swf.gmParam2.text = item.item.param2_default_value;
		end
		if item.item.param3_default_value then
			swf.gmParam3.text = item.item.param3_default_value;
		end
	end
	
	self.currItem = item;
end

function UIGMCmd:OnItemListDoubleClick(e)
	local item = self.items[e.index+1];
	if not item then
		return;
	end
	self.currItem = item;
	
	local info = self.currItem.item.name;
	local param1 = self.objSwf.gmParam1.text;
	local param2 = self.objSwf.gmParam2.text;
	local param3 = self.objSwf.gmParam3.text;
	
	if param1 ~= "" then
		info = info..'/'..param1;
	end
	if param2 ~= "" then
		info = info..'/'..param2;
	end
	if param3 ~= "" then
		info = info..'/'..param3;
	end
	
	ChatController:SendChat(ChatConsts.Channel_World,info);
end

function UIGMCmd:UpdateGmList()
	local swf = self.objSwf;
	
	swf.gmParam1.text = "param1";
	swf.gmParam2.text = "param2";
	swf.gmParam3.text = "param3";
	self.currSort = nil;
	self.currItem = nil;
	self.sorts = {};
	self.items = {};
	
	swf.gmSortList.dataProvider:cleanUp();
	for name,sort in pairs(GmCmdList.gmsort) do
		local vo = {};
		vo.name = name;
		vo.sort = sort;
		table.push(self.sorts,vo);
		swf.gmSortList.dataProvider:push(vo.sort);
	end
	swf.gmSortList:invalidateData();
	swf.gmSortList.selectedIndex = 0;
	
	swf.gmItemList.dataProvider:cleanUp();
	swf.gmItemList:invalidateData();
end


function UIGMCmd:OnShow()
	self:UpdateGmList();
end

function UIGMCmd:OnHide()
end
