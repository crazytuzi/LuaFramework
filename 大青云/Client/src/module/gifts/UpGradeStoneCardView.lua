--[[
	2015年10月19日14:50:26
	wangyanwei
	升阶石卡片
]]

_G.UIUpGradeStoneCard = BaseUI:new('UIUpGradeStoneCard');

function UIUpGradeStoneCard:Create()
	self:AddSWF('upgradeStoneCardPanel.swf',true,'center')
end

function UIUpGradeStoneCard:OnLoaded(objSwf)
	objSwf.item.rollOver = function(e) TipsManager:ShowItemTips(e.target.data.id); end
	objSwf.item.rollOut = function(e) TipsManager:Hide(); end
	objSwf.btn_getReward.click = function () self:OnRewardClick(); end
	objSwf.btn_close.click = function () self:Hide(); end
	-- for i = 1 , 3 do
		-- objSwf['btnRadio_' .. i].click = function () self.selectType = i; end
	-- end
	objSwf.list.itemClick = function (e) self.selectType = e.item.id; end
end

function UIUpGradeStoneCard:OnRewardClick()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.pos);
	if not item then FloatManager:AddNormal( StrConfig['stone111'] );return end
	-- print(item:GetId(),self.selectType);
	
	GiftsController:SendOpenItemCard(item:GetId(),self.selectType);
end

UIUpGradeStoneCard.cardID = 0;
UIUpGradeStoneCard.itemID = 0;
UIUpGradeStoneCard.pos = 0;
UIUpGradeStoneCard.bagType = 0;
function UIUpGradeStoneCard:Open(bagType,itemID,cardID,pos)
	if not cardID then return end
	self.cardID = cardID;
	self.itemID = itemID;
	self.pos = pos;
	self.bagType = bagType;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIUpGradeStoneCard:OnShow()
	self:InitRadioDate();
	self:OnShowItemDate();
	self:ShowRadioTxt();
end

function UIUpGradeStoneCard:OnShowItemDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local item = t_item[self.itemID];
	if not item then print('not itemID' .. self.itemID)return end
	local rewardSlotVO = RewardSlotVO:new();
	rewardSlotVO.id = item.id;
	objSwf.item:setData(rewardSlotVO:GetUIData());
	objSwf.txt_name.text = item.name;
end

function UIUpGradeStoneCard:ShowRadioTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local itemCardCfg = t_itemcard[self.cardID];
	if not itemCardCfg then print('not t_itemcard id' .. self.cardID)return end
	
	local count = 0;
	local tcost = itemCardCfg.cost;
	local titem = itemCardCfg.item;
	local bag = BagModel:GetBag(self.bagType);
	if bag then
		local item = bag:GetItemByPos(self.pos);
		if item then
			count = item:GetUseCnt() + 1;
		end
	end
	for i=2,count do
		local icost = itemCardCfg['cost'..i];
		local iitem = itemCardCfg['item'..i];
		if not icost or icost == '' then
			break;
		end
		tcost = icost;
		titem = iitem;
	end
	
	local costCfg = split(tcost,'#');
	local itemNumCfg = split(titem,'#');	--获得的物品 ps有可能是多个  #分割类型  *分割同一类型多个物品
	objSwf.list.dataProvider:cleanUp();
	for i , moneyStr in ipairs(costCfg) do
	
		local vo = {};
		vo.id = i;
		
		local moneyCfg = split(moneyStr , ',');
		if toint(moneyCfg[1]) == 0 then
			local itemNameStr = ''; 
			local itemNumStr = ''; 
			local itemGetCfg = split(itemNumCfg[i],'*');
			for index , itemDate in ipairs(itemGetCfg) do
				local itemCfg = split(itemDate,',');
				local item = t_item[toint(itemCfg[1])] or t_equip[toint(itemCfg[1])];
				if not item then print('not cardItem ' , itemCfg[1])return end
				itemNameStr = index >= #itemGetCfg and itemNameStr .. item.name or itemNameStr .. item.name .. '/';
				itemNumStr = index >= #itemGetCfg and itemNumStr .. 'X' ..itemCfg[2] or itemNumStr .. 'X' .. itemCfg[2] .. '/';
			end
			vo.txt = string.format(StrConfig['stone101'],itemNameStr,itemNumStr);
		else
			local moneyTypeStr = enAttrTypeName[toint(moneyCfg[1])];			--消耗物品的名称;
			local itemNameStr = ''; 									--获得道具的str
			local itemNumStr = ''; 										--获得道具数量的str
			local itemGetCfg = split(itemNumCfg[i],'*');
			for index , itemDate in ipairs(itemGetCfg) do
				local itemCfg = split(itemDate,',');
				local item = t_item[toint(itemCfg[1])] or t_equip[toint(itemCfg[1])];
				if not item then print('not cardItem ' , itemCfg[1])return end
				itemNameStr = index >= #itemGetCfg and itemNameStr .. item.name or itemNameStr .. item.name .. '/';
				itemNumStr = index >= #itemGetCfg and itemNumStr .. 'X' ..itemCfg[2] or itemNumStr .. 'X' .. itemCfg[2] .. '/';
			end
			vo.txt = string.format(StrConfig['stone102'], moneyCfg[2] .. moneyTypeStr , itemNameStr , itemNumStr );
		end
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end
	objSwf.list:invalidateData();
end

function UIUpGradeStoneCard:OnHide()
	self.data = nil;
end

UIUpGradeStoneCard.selectType = 1;
function UIUpGradeStoneCard:InitRadioDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.list.selectedIndex = 0;
	self.selectType = 1;
end
