--[[
好友申请列表
lizhuangzhuang
2014年10月22日21:27:04
]]

_G.UIFriendApply = BaseUI:new("UIFriendApply");

UIFriendApply.pos = nil;
UIFriendApply.list = {};

function UIFriendApply:Create()
	self:AddSWF("friendApply.swf",true,"center");
end

function UIFriendApply:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnAddAll.click = function() self:OnBtnAddAllClick(); end
	objSwf.cbSelectAll.click = function() self:OnCBSelectAllClick(); end
	objSwf.list.itemSelectChange = function(e) self:OnItemSelectChange(e); end
end

function UIFriendApply:Open(pos)
	self.pos = pos;
	if self:IsShow() then
		self:SetPos();
		self:ShowList();
	else
		self:Show();
	end
end

function UIFriendApply:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:SetPos();
	objSwf.cbSelectAll.selected = false;
	self:ShowList();
end

function UIFriendApply:SetPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf._x = self.pos.x;
	objSwf._y = self.pos.y - 300;
end

function UIFriendApply:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local remindQueue = RemindModel:GetQueue(RemindConsts.Type_FriendApply);
	if not remindQueue then return; end
	self.list = {};
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(remindQueue.datalist) do
		local listVO = {};
		listVO.roleId = vo.roleId;
		listVO.name = vo.roleName;
		listVO.lvl = "LV"..vo.level;
		listVO.selected = true;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
	objSwf.cbSelectAll.selected = true;
end


--切换选择全部
function UIFriendApply:OnCBSelectAllClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local selectAll = objSwf.cbSelectAll.selected;
	objSwf.list.dataProvider:cleanUp();
	for i,listVO in ipairs(self.list) do
		listVO.selected = selectAll;
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
end

--item选中状态改变
function UIFriendApply:OnItemSelectChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local selected = e.renderer.checkBox.selected;
	local roleId = e.item.roleId;
	for i,listVO in ipairs(self.list) do
		if listVO.roleId == e.item.roleId then
			listVO.selected = selected;
			local uiItem = objSwf.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(UIData.encode(listVO));
			end
			objSwf.list.dataProvider[i-1] = UIData.encode(listVO);
		end
	end
	if not selected then
		if objSwf.cbSelectAll.selected then
			objSwf.cbSelectAll.selected = false;
		end
	end
end

--全部添加
function UIFriendApply:OnBtnAddAllClick()
	local approvelist = {};
	for i,listVO in ipairs(self.list) do
		local vo = {};
		vo.roleID = listVO.roleId;
		vo.agree = listVO.selected and 1 or 0;
		table.push(approvelist,vo);
	end
	FriendController:AddFriendApprove(approvelist);
	RemindController:ClearRemind(RemindConsts.Type_FriendApply);
	self:Hide();
end

--点击关闭,全部拒绝
function UIFriendApply:OnBtnCloseClick()
	local approvelist = {};
	for i,listVO in ipairs(self.list) do
		local vo = {};
		vo.roleID = listVO.roleId;
		vo.agree = 0;
		table.push(approvelist,vo);
	end
	FriendController:AddFriendApprove(approvelist);
	RemindController:ClearRemind(RemindConsts.Type_FriendApply);
	self:Hide();
end