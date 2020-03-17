--[[
    Created by IntelliJ IDEA.
    User: Hongbin Yang
    Date: 2016/7/2
    Time: 11:12
   ]]



_G.UIPerfusionSubPanelView = BaseSlotPanel:new("UIPerfusionSubPanelView")

UIPerfusionSubPanelView.SlotTotalNum = 4;
UIPerfusionSubPanelView.currentType = 0;
UIPerfusionSubPanelView.currentLevel = 0;
UIPerfusionSubPanelView.currentProgress = 0;
UIPerfusionSubPanelView.sendTime = 0;
UIPerfusionSubPanelView.grayURLList = {};
UIPerfusionSubPanelView.itemDataList = {};
UIPerfusionSubPanelView.selectedTid = -1;
function UIPerfusionSubPanelView:Create()
	self:AddSWF("stovePerfusionSubPanel.swf", true, nil);
end

function UIPerfusionSubPanelView:OnLoaded(objSwf)
	objSwf.btnPerfusionSingle.click = function() self:OnBtnPerfusionSingleClick(); end
	objSwf.btnPerfusionSingle.rollOver = function() StovePanelView:OnStartProgressRollOver() end
	objSwf.btnPerfusionSingle.rollOut = function() StovePanelView:OnStartProgressRollOut() end


	objSwf.btnPerfusionAuto.click = function() self:OnBtnPerfusionAutoClick(); end
	objSwf.btnPerfusionAuto.rollOver = function() StovePanelView:OnStartProgressRollOver() end
	objSwf.btnPerfusionAuto.rollOut = function() StovePanelView:OnStartProgressRollOut() end


end

function UIPerfusionSubPanelView:OnShow()
	self.currentType = self.args[1];
	self.currentLevel = self.args[2];
	self.currentProgress = self.args[3];
	for i = 1, self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(self.objSwf["item" .. i]), i);
	end
	self:SetDragEnabled(false);
	self:UpdateView();
end

function UIPerfusionSubPanelView:UpdateView()
	self:UpdateItemSlots(self.currentType, self.currentLevel);
end

function UIPerfusionSubPanelView:UpdateItemSlots(type, level)
	local needItemIDList = StoveUtil:GetStoveNeedItemList(type, level);
	for k, v in pairs(self.grayURLList) do
		ImgUtil:DeleteGrayImg(v);
	end
	self.grayURLList = {};
	self.objSwf.list.dataProvider:cleanUp();

	self.itemDataList = {};
	for i = 1, 4 do
		local itemID = toint(needItemIDList[i]);
		local slotVO = BagSlotVO:new();
		if itemID then
			local itemCount = BagModel:GetItemNumInBag(itemID);
			local hasItem = itemCount > 0;
			if hasItem then
				slotVO.count = itemCount;
			end
			slotVO.opened = true;
			slotVO.hasItem = true;
			slotVO.tid = itemID;
			if not hasItem then
				local grayURL = ImgUtil:GetGrayImgUrl(BagUtil:GetItemIcon(itemID));
				slotVO.customIconUrl = grayURL;
				table.insert(self.grayURLList, grayURL);
			end
			slotVO.bindState = false;
		else
			slotVO.opened = true;
			slotVO.hasItem = false;
		end
		table.push(self.itemDataList, slotVO);
	end

	for i, item in pairs(self.itemDataList) do
		self.objSwf.list.dataProvider:push(item:GetUIData());
	end

	self.objSwf.list:invalidateData();
	--隐藏第四个显示 jianghaoran 2016-8-11
	self.objSwf.list:getRendererAt(3)._visible = false;
	--检查下选择的还有没有
	if self.selectedTid ~= -1 and BagModel:GetItemNumInBag(self.selectedTid) <= 0 then
		self.selectedTid = -1;
	end

	if self.selectedTid == -1 then
		self:SelectedFirstOne();
	else
		self:SelectedItemByTid(self.selectedTid);
	end

end

function UIPerfusionSubPanelView:SelectedFirstOne()
	for i = 1, 4 do
		if BagModel:GetItemNumInBag(self.itemDataList[i].tid) > 0 then
			self:SelectedItem(i);
			break;
		end
	end
end
--选择一个道具 根据tid
function UIPerfusionSubPanelView:SelectedItemByTid(tid)
	for k, v in pairs(self.itemDataList) do
		if v.tid == tid then
			self:SelectedItem(k);
			break;
		end
	end
end


--选择一个道具 index从1开始
function UIPerfusionSubPanelView:SelectedItem(index)
	index = toint(index);
	for i = 1, 4 do
		local item = self.objSwf.list:getRendererAt(i - 1);
		if i == index then
			item.choose = true;
			self.selectedTid = self.itemDataList[i].tid;
		else
			item.choose = false;
		end
	end
end

--点击Item
function UIPerfusionSubPanelView:OnItemClick(item)
	if not item then
		return;
	end
	local data = item:GetData();
	if toint(data.count) <= 0 then return; end;
	self:SelectedItemByTid(data.tid);
end

function UIPerfusionSubPanelView:OnItemRollOver(item)
	if not item then
		return;
	end
	local data = item:GetData();
	if not data.hasItem then return; end;
	TipsManager:ShowItemTips(data.tid);
end

function UIPerfusionSubPanelView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIPerfusionSubPanelView:GetQuickBuyItemID()
	return StoveUtil:GetStoveQuickBuyItemID(self.currentType, self.currentLevel);
end

function UIPerfusionSubPanelView:OnBtnPerfusionSingleClick()
	--点击延迟
	local curTime = GetCurTime() / 1000;
	if curTime - self.sendTime < 0.6 then return; end
	self.sendTime = curTime;

	TipsManager:Hide();

	local tid = self.selectedTid;
	if tid == -1 then
		FloatManager:AddNormal(StrConfig["stove1000"]);
		UIQuickBuyConfirm:Open(self,self:GetQuickBuyItemID());
		return;
	end

	local playerinfo = MainPlayerModel.humanDetailInfo;
	local costStr = StoveUtil:GetStoveCostItem(self.currentType, self.currentLevel);
	if costStr[1] and costStr[2] then
		local costItemList = costStr;
		local costItemID = tonumber(costItemList[1]);
		local costItemCount = tonumber(costItemList[2]);
		local name = "";
		local hasCount = 0;
		if isPlayerAttr(costItemID) then
			name = enAttrTypeName[costItemID];
			hasCount = playerinfo[costItemID];
		else
			name = t_item[costItemID].name;
			hasCount = BagModel:GetItemNumInBag(costItemID);
		end
		if hasCount < costItemCount then
			FloatManager:AddNormal(name .. "不足, 需要" .. costItemCount);
			return;
		end
	end

	--处理灌注
	StoveController:RequestHuDunProgress(StoveUtil:GetStoveTid(self.currentType, self.currentLevel), tid);
end

function UIPerfusionSubPanelView:OnBtnPerfusionAutoClick()
	--点击延迟
	local curTime = GetCurTime() / 1000;
	if curTime - self.sendTime < 0.6 then return; end
	self.sendTime = curTime;

	--计算一键需要的银两
	local needItemIDList = StoveUtil:GetStoveNeedItemList(self.currentType, self.currentLevel);
	local list = {};
	if needItemIDList == "" then return; end
	for needItemK, needItemValue in pairs(needItemIDList) do
		local itemID = toint(needItemValue);
		local itemCount = BagModel:GetItemNumInBag(itemID);
		if itemCount > 0 then
			local itemVO = {};
			itemVO.tid = tonumber(needItemValue);
			itemVO.count = itemCount;
			itemVO.addExp = t_stoveitem[itemVO.tid].value;
			table.push(list, itemVO);
		end
	end
	if #list <= 0 then
		FloatManager:AddNormal(StrConfig["stove1000"]);
		UIQuickBuyConfirm:Open(self,self:GetQuickBuyItemID());
		return;
	end

	local maxExp = StoveUtil:GetStovePlan(self.currentType, self.currentLevel);
	local currentExp = self.currentProgress;
	local needExp = maxExp - currentExp;
	local needItemCount = 0;
	for i = 1, #list do
		if needExp <= 0 then
			break;
		end
		local itemVO = list[i];
		local count = math.ceil(needExp / itemVO.addExp);
		if count <= itemVO.count then
			needItemCount = needItemCount + count;
		else
			needItemCount = needItemCount + itemVO.count;
		end
		needExp = needExp - (needItemCount * itemVO.addExp);
	end
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local costStr = StoveUtil:GetStoveCostItem(self.currentType, self.currentLevel);
	if costStr[1] and costStr[2] then
		local costItemList = costStr;
		local costItemID = tonumber(costItemList[1]);
		local costItemCount = tonumber(costItemList[2]);
		local needMoney = needItemCount * costItemCount;
		local name = "";
		local hasCount = 0;
		if isPlayerAttr(costItemID) then
			name = enAttrTypeName[costItemID];
			hasCount = playerinfo[costItemID];
		else
			name = t_item[costItemID].name;
			hasCount = BagModel:GetItemNumInBag(costItemID);
			hasCount = BagModel:GetItemNumInBag(costItemID);
		end
		if hasCount < needMoney then
			FloatManager:AddNormal(name .. "不足, 需要" .. needMoney);
			return;
		end
	end
	--一键灌注
	StoveController:RequestHuDunAutoUp(StoveUtil:GetStoveTid(self.currentType, self.currentLevel));
end

function UIPerfusionSubPanelView:OnUseItemResponse()
	if not self:IsShow() then return end
	UIPerfusionSubPanelView:UpdateItemSlots(self.currentType, self.currentLevel);
end

function UIPerfusionSubPanelView:ShowPerfusionBtn(value)
	if not self.objSwf then return; end
	self.objSwf.btnPerfusionSingle._visible = value;
	self.objSwf.btnPerfusionAuto._visible = value;
	self.objSwf.txtTitle._visible = value;
	self.objSwf.item1._visible = value;
	self.objSwf.item2._visible = value;
	self.objSwf.item3._visible = value;
end

function UIPerfusionSubPanelView:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.BagItemNumChange then
		self:OnUseItemResponse();
	end
end

function UIPerfusionSubPanelView:ListNotificationInterests()
	return { NotifyConsts.BagItemNumChange }
end

function UIPerfusionSubPanelView:OnHide()
	self:RemoveAllSlotItem();
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list:invalidateData();
	self.sendTime = 0;
	for k, v in pairs(self.grayURLList) do
		ImgUtil:DeleteGrayImg(v);
	end
	self.grayURLList = {};
	self.selectedTid = -1;
end

function UIPerfusionSubPanelView:IsTween()
	return false;
end

function UIPerfusionSubPanelView:GetPanelType()
	return 0;
end
