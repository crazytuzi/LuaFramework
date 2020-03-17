--[[
	新天神
]]

_G.UINewTianshenCompose = BaseUI:new('UINewTianshenCompose');

UINewTianshenCompose.selectList = {}
UINewTianshenCompose.nMaxCount = 10
function UINewTianshenCompose:Create()
	self:AddSWF("newTianshenCompose.swf", true, "center");
end

function UINewTianshenCompose:OnLoaded(objSwf)
	objSwf.closeBtn.click = function()
		self:Hide()
	end
	objSwf.blueBtn.click = function()
		objSwf.blueBtn.selected = true
		self.objSwf.txt_des.htmlText = StrConfig['newtianshen101']
		self.objSwf.txt_des1.htmlText = StrConfig['newtianshen21']
		self.selectList = {}
		self:ShowBagList()
		self:ShowSelectList()
		self:SetBtnPfx()
	end
	objSwf.ziBtn.click = function()
		objSwf.ziBtn.selected = true
		self.objSwf.txt_des.htmlText = StrConfig['newtianshen102']
		self.objSwf.txt_des1.htmlText = StrConfig['newtianshen20']
		self.selectList = {}
		self:ShowBagList()
		self:ShowSelectList()
		self:SetBtnPfx()
	end
	objSwf.composeBtn.click = function()
		self:AskCompose()
	end
	objSwf.aotoBtn.click = function()
		self:AotoInCard()
	end
	objSwf.list.itemClick = function(e)
		self:BagListClick(e)
	end
	objSwf.list1.itemClick = function(e)
		self:SelectListClick(e)
	end
	objSwf.blueBtn.htmlLabel = StrConfig['newtianshen13']
	objSwf.blueBtn.pfx:gotoAndStop(2)
	objSwf.ziBtn.htmlLabel = StrConfig['newtianshen14']
	objSwf.ziBtn.pfx:gotoAndStop(3)
	objSwf.list.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.list1.itemRollOver = function(e) self:OnBagEquipOver(e); end
	objSwf.list1.itemRollOut = function(e) TipsManager:Hide(); end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen207"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenCompose:OnShow()
	self.selectList = {}
	self.objSwf.blueBtn.selected = true
	self.objSwf.txt_des.htmlText = StrConfig['newtianshen101']
	self.objSwf.txt_des1.htmlText = StrConfig['newtianshen21']
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

--判断是否选中吞噬的天神
function UINewTianshenCompose:CheckIsSelectCard(id)
	return self.selectList[id]
end

function UINewTianshenCompose:OnBagEquipOver(e)
	if not e.item then return end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if item then
		TipsManager:ShowBagTips(BagConsts.BagType_Tianshen,item.pos);
	end
end

function UINewTianshenCompose:ShowBagList()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		if not self:CheckIsSelectCard(item:GetId()) and (not NewTianshenUtil:IsExpCard(item:GetTid())) then
			table.push(cardsList,UIData.encode(self:GetSlotVO(item,index)));
		end
	end
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list.dataProvider:push(unpack(cardsList));
	self.objSwf.list:invalidateData();
end

function UINewTianshenCompose:ShowSelectList()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		if self:CheckIsSelectCard(item:GetId()) then
			table.push(cardsList,UIData.encode(self:GetSlotVO(item,index)));
		end
	end
	if #cardsList < self.nMaxCount then
		for i = #cardsList + 1, self.nMaxCount do
			local vo = {}
			vo.hasItem = false
			table.push(cardsList,UIData.encode(vo));
		end
	end
	self.objSwf.list1.dataProvider:cleanUp();
	self.objSwf.list1.dataProvider:push(unpack(cardsList));
	self.objSwf.list1:invalidateData();
end

--获取格子VO
function UINewTianshenCompose:GetSlotVO(item,index)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index;
	vo.pos = item:GetPos();
	EquipUtil:GetDataToItemUIVO(vo,item);
	return vo;
end

--获取选中天神的数量
function UINewTianshenCompose:GetSelectNum()
	local num = 0
	for k, v in pairs(self.selectList) do
		num = num + 1
	end
	return num
end

function UINewTianshenCompose:BagListClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then
		return
	end
	local quality = NewTianshenUtil:GetQualityByZizhi(item:GetParam())
	if self.objSwf.blueBtn.selected and quality ~= 0 then
		FloatManager:AddNormal(StrConfig['newtianshen103'])
		return
	end
	if self.objSwf.ziBtn.selected and quality ~= 1 then
		FloatManager:AddNormal(StrConfig['newtianshen104'])
		return
	end
	if self:GetSelectNum() >= self.nMaxCount then
		--满了
		FloatManager:AddNormal(StrConfig['newtianshen105'])
		return
	end
	if not self:CheckIsSelectCard(item:GetId()) then
		self.selectList[item:GetId()] = 1
	end
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

function UINewTianshenCompose:SelectListClick(e)
	if not e.item then return end

	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local item = bag:GetItemByPos(e.item.pos);
	if not item then
		return
	end
	
	if not self:CheckIsSelectCard(item:GetId()) then
		return
	end
	self.selectList[item:GetId()] = nil
	self:ShowBagList()
	self:ShowSelectList()
	self:SetBtnPfx()
end

function UINewTianshenCompose:AskCompose()
	if self:GetSelectNum() < 10 then
		--必须要10个
		FloatManager:AddNormal(StrConfig['newtianshen106'])
		return
	end
	local complist = {}
	for k, v in pairs(self.selectList) do
		table.insert(complist, {id = k})
	end
	NewTianshenController:AskCompose(complist)
end

function UINewTianshenCompose:AotoInCard()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All);
	local cardsList = {}

	for index,item in pairs(cards) do
		if self:GetSelectNum() < self.nMaxCount then
			if not self:CheckIsSelectCard(item:GetId()) and (not NewTianshenUtil:IsExpCard(item:GetTid())) then
				local quality = NewTianshenUtil:GetQualityByZizhi(item:GetParam())
				if self.objSwf.blueBtn.selected and quality == 0 then
					self.selectList[item:GetId()] = 1
				elseif self.objSwf.ziBtn.selected and quality == 1 then
					self.selectList[item:GetId()] = 1
				end
			end
		end
	end
	self:ShowSelectList()
	self:ShowBagList()
	self:SetBtnPfx()
end

function UINewTianshenCompose:SetBtnPfx()
	local objSwf = self.objSwf
	if not objSwf then return end
	local bPfx = false
	if self.objSwf.blueBtn.selected then
		bPfx = NewTianshenUtil:IsHaveTenCardCanCompose(1)
	elseif self.objSwf.ziBtn.selected then
		bPfx = NewTianshenUtil:IsHaveTenCardCanCompose(2)
	end
	objSwf.aotoBtn.pfx._visible = bPfx and (self:GetSelectNum() ~= 10)
	objSwf.composeBtn.pfx._visible = self:GetSelectNum() == 10
end

function UINewTianshenCompose:ListNotificationInterests()
	return {NotifyConsts.tianShenComUpdata,NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,}
end

function UINewTianshenCompose:HandleNotification(name,body)
	if name == NotifyConsts.tianShenComUpdata then
		self.selectList = {}
		self:ShowBagList()
		self:ShowSelectList()
	else
		self:ShowBagList()
	end
	self:SetBtnPfx()
end

function UINewTianshenCompose:ESCHide()
	return true
end