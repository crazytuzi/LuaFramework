--[[
确认购买二级window
wangshuai
]]

_G.UIConsignmentSureBuy = BaseUI:new("UIConsignmentSureBuy")

function UIConsignmentSureBuy:Create()
	self:AddSWF("consignmentSureBuyPanel.swf",true,"top")
end;

function UIConsignmentSureBuy:OnLoaded(objSwf)
	objSwf.closepanel.click = function()self:ClosePanel()end;
	objSwf.sure_btn.click = function()self:OnSureBuyClick()end;
	objSwf.cancel_btn.click = function()self:OnCancelBuyClick()end;

	-- objSwf.num_input.textChange = function() self:OnInputTextChange(objSwf.num_input.text) end;
	-- objSwf.num_input.restrict = "0-9"
	--objSwf.num_input.maxChars = 3

	objSwf.item_icon.rollOver = function() self:OnItemRollOver() end;
	objSwf.item_icon.rollOut  = function() TipsManager:Hide() end;

end;

function UIConsignmentSureBuy:OnShow()
	self:ShowData();
end;

function UIConsignmentSureBuy:OnHide()
	self.uid = 0;
end;

function UIConsignmentSureBuy:OnItemRollOver()
	local objSwf = self.objSwf;

	local uid = self.uid;	     
	local cfg = ConsignmentModel:getCertainBuitemInfo(uid)
	local cid = cfg.id;
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cid,1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = cfg.superList
	itemTipsVO.superVO.superNum = cfg.superNum
--trace(itemTipsVO.superVO)
	if itemTipsVO.superVO then
		itemTipsVO.superHoleList = {};
		for i=1,itemTipsVO.superVO.superNum do
			itemTipsVO.superHoleList[i] = 0
		end
	end
	itemTipsVO.extraLvl = cfg.attrAddLvl
	itemTipsVO.newSuperList = cfg.newSuperList
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIConsignmentSureBuy:OnInputTextChange(text)
	local objSwf = self.objSwf;
	local num = toint(text);
	if not num then return end;
	local data = ConsignmentModel:getCertainBuitemInfo(self.uid);
	local maxnum = data.num;
	if num > maxnum then 
		objSwf.num_input.text = maxnum
		num = maxnum
	end;
	local allPrice = num * data.price;
	objSwf.allprice.text = allPrice;
	objSwf.num_input.text = num;
	self.num = num;
end;
function UIConsignmentSureBuy:showText()
	local objSwf = self.objSwf;
	local data = ConsignmentModel:getCertainBuitemInfo(self.uid);
	local maxnum = data.num;
	objSwf.num_input.text = maxnum
	local allPrice = data.price;
	objSwf.allprice.text = allPrice;
	self.num = maxnum;
end;

function UIConsignmentSureBuy:SetData(uid)
	self.uid = uid;
	self:Show();
	if self:IsShow() then 
		self:Top();
		self:ShowData();
	end;
end;

function UIConsignmentSureBuy:ShowData()

	local objSwf = self.objSwf;
	local data = ConsignmentModel:getCertainBuitemInfo(self.uid);
	if not data then return end;
	local cfg = ConsignmentUtils:GetCurIdCfg(data.id)

	local nameColor = TipsConsts:GetItemQualityColor(cfg.quality)
	objSwf.itemName.htmlText = string.format(StrConfig["consignment001"],cfg.name)
	
	local price1 = math.floor(data.price/data.num);
	-- if price1<1 then
		-- objSwf.price.text = "<1"
	-- else
		-- objSwf.price.text = math.floor(data.price/data.num);
	-- end
	
	-- objSwf.money_load1.source = ResUtil:GetMoneyIconURL(12)
	objSwf.money_load2.source = ResUtil:GetMoneyIconURL(12)

	objSwf.allprice.text = "";
	objSwf.num_input.text = 1;
	-- self:OnInputTextChange(1)
	self:showText()


	local vo = ConsignmentUtils:GetBuyItemUIdata(data,true)
	objSwf.item_icon:setData(vo);
end;


function UIConsignmentSureBuy:OnSureBuyClick()
	local data = ConsignmentModel:getCertainBuitemInfo(self.uid);
	if not data then 
		FloatManager:AddNormal( StrConfig['consignment031']); 
		return end;
--	local price = data.price * self.num;
	local price = data.price;
	local moneyAll = ConsignmentUtils:GetMoneyTypeNum(12)
	if not price then price = 1 end;
	if not moneyAll then moneyAll = 0 end;
	if self.num <= 0 then 
		FloatManager:AddNormal( StrConfig['consignment023']); 
		return 
	end;
	if moneyAll < price then
		FloatManager:AddNormal( StrConfig['consignment010']); 
		return 
	end;
	ConsignmentController:ResqBuyItem(self.uid,self.num)
	self:Hide();
end;

function UIConsignmentSureBuy:OnCancelBuyClick()
	self:Hide();
end;

function UIConsignmentSureBuy:ClosePanel()

	self:Hide()
end;
function UIConsignmentSureBuy:GetPanelType()
	return 0;
end

function UIConsignmentSureBuy:ESCHide()
	return true;
end