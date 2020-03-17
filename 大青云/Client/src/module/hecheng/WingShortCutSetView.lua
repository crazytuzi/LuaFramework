--[[
翅膀增加几率道具面板
zhangshuhui
2015年8月21日17:42:53
]]

_G.UIWingShortCutSet = BaseUI:new("UIWingShortCutSet");

UIWingShortCutSet.pos = 0;
UIWingShortCutSet.mc = nil;
--道具信息list
UIWingShortCutSet.wingrantitemList = {};

UIWingShortCutSet.currPanelY = 0;

function UIWingShortCutSet:Create()
	self:AddSWF("wingShortCutSetting.swf",true,"top");
end

function UIWingShortCutSet:OnLoaded(objSwf,name)
	RewardManager:RegisterListTips( objSwf.wingrantitemPanel.itemList );
	objSwf.wingrantitemPanel.itemList.itemClick = function(e) self:OnRantItemClick(e); end
end

function UIWingShortCutSet:OnResize()
	self:Hide();
end

--@param mc 点击目标格子mc
function UIWingShortCutSet:Open(mc, index)
	self.mc = mc;
	self.index = index;
	if self:IsShow() then
		self:SetUIPos();
	else
		self:Show();
	end
end

function UIWingShortCutSet:OnShow()
	self:ShowTitle();
	self:ShowList();
	self:SetUIPos();
end

function UIWingShortCutSet:OnHide()
	self.mc = nil;
end

function UIWingShortCutSet:SetUIPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local pos = nil;
	if self.mc then
		pos = UIManager:GetMcPos(self.mc);
		local width = self.mc.width or self.mc._width;
		pos.x = pos.x + width / 2;
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x - objSwf._width / 2;
	objSwf._y = pos.y - objSwf._height;
end

function UIWingShortCutSet:ShowTitle()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local title = StrConfig['hecheng22'];
	objSwf.wingrantitemPanel.labTitle.text = title;
end

function UIWingShortCutSet:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.wingrantitemList = {};
	local list = {};
	for i=HeChengConsts.WINGRANTBEGINID,HeChengConsts.WINGRANTENDID do
		list[i] = 0;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if bagVO then
		for i,item in pairs(bagVO.itemlist) do
			if item:GetShowType()==BagConsts.ShowType_Consum then
				if item:GetTid() >= HeChengConsts.WINGRANTBEGINID and item:GetTid() <= HeChengConsts.WINGRANTENDID then
					list[item:GetTid()] = list[item:GetTid()] + item:GetCount();
				end
			end
		end
	end
	for i=HeChengConsts.WINGRANTBEGINID,HeChengConsts.WINGRANTENDID do
		local selcount = HeChengModel:GetRantItemCount(i);
		local vo = RewardSlotVO:new();
		vo.id = i;
		vo.count = list[i] - selcount;
		vo.bind = BagConsts.Bind_None;
		vo.hasItem = true;
		table.push (self.wingrantitemList, vo:GetUIData());
	end
	
	--
	self.currPanelY = 20;
	self:ShowWingRantItemList();
	objSwf.bg._height = self.currPanelY + 40;
end

function UIWingShortCutSet:ShowWingRantItemList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.wingrantitemPanel;
	local rows = toint(#self.wingrantitemList/6,1);
	rows = rows<1 and 1 or rows;
	panel.itemList.bg._height = rows*40 + 10;
	panel._y = self.currPanelY;
	panel.itemList.dataProvider:cleanUp();
	for i, listVO in ipairs(self.wingrantitemList) do
		panel.itemList.dataProvider:push( listVO );
	end
	-- --不足6个补齐
	-- local lastRowNum = #self.wingrantitemList % 6;
	-- if lastRowNum>0 and lastRowNum<6 then
		-- for i=lastRowNum+1,6 do
			-- local vo = RewardSlotVO:new();
			-- vo.id = 0;
			-- vo.count = 0;
			-- vo.bind = BagConsts.Bind_None;
			-- vo.hasItem = false;
			-- panel.itemList.dataProvider:push( vo:GetUIData() );
		-- end
	-- end
	panel.itemList:invalidateData();
	self.currPanelY = self.currPanelY + rows*40 + 10;
end

function UIWingShortCutSet:OnRantItemClick(e)
	if e.item.count <= 0 then
		FloatManager:AddNormal( StrConfig['hecheng30'] );
		return;
	end
	
	local vo = {};
	vo.index = self.index;
	vo.cid = 0;
	vo.tid = e.item.id;
	HeChengModel:AddRantItem(vo);
	
	UIWingHeCheng:UpdateSucRateTool();
	UIWingHeCheng:UpdateSucRate();
	
	self:Hide();
end

function UIWingShortCutSet:OnRantItemRollOver(e)
	if not e.item.hasItem then return; end
	if e.item.tid > 0 then
		TipsManager:ShowItemTips(e.item.tid);
	end
end

function UIWingShortCutSet:OnRantItemRollOut(e)
	TipsManager:Hide();
end

function UIWingShortCutSet:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowList();
	end
end

function UIWingShortCutSet:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut,
			NotifyConsts.BagItemNumChange};
end