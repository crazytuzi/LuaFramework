--[[
上架确认
wangshuai
]]

_G.UIConsignmentUpItem = BaseUI:new("UIConsignmentUpItem")

UIConsignmentUpItem.data = {}; -- item data;
UIConsignmentUpItem.upNum = 1;--上架数量
UIConsignmentUpItem.upGoldMoney = 0;--出售价值 金币
UIConsignmentUpItem.upYuanbMoney = 0;--出售价值  元宝
UIConsignmentUpItem.upMoneyType = 12 --出售货币类型
UIConsignmentUpItem.upTime = 4; -- 出售时限(出售时限改为恒定72小时，取消下拉菜单)
UIConsignmentUpItem.curitemUid = 0;


function UIConsignmentUpItem:Create()
	self:AddSWF("consignmentUpItemPanel.swf",true,"top")
end;

function UIConsignmentUpItem:OnLoaded(objSwf)
	objSwf.closePanel.click = function() self:Hide()end;

	objSwf.item_icon.rollOver = function() self:ItemRollOver()end;
	objSwf.item_icon.rollOut  = function() TipsManager:Hide()end;

	-- objSwf.timeDdlist.change= function (e) self:OnDlistChange(e);end;
	-- objSwf.timeDdlist.rowCount = 4;

	--objSwf.yuanbao_input.restrict = "0-9"
	objSwf.gold_input.restrict = "0-9"

	objSwf.gold_input.textChange = function() self:OnGoldInput(objSwf.gold_input.text)end;
	--objSwf.yuanbao_input.textChange = function() self:OnYuanbaoInput(objSwf.yuanbao_input.text)end;

	--objSwf.num.change = function(e) self:OnNsChange(e); end
	--objSwf.num.textField.textChange = function() self:NumTxtChang(objSwf.num.textField.text) end;

	objSwf.sure.click = function() self:OnSureClick() end;
	objSwf.cancel.click = function() self:OnCanCelClick()end;

	objSwf.gold.click = function()self:OnGoldClick()end;	
--	objSwf.yuanbao.click = function()self:OnYuanbaoClick()end;	
end;

function UIConsignmentUpItem:OnShow()
	self:UpdataItemInfo()
end;

function UIConsignmentUpItem:UpdataItemInfo()
	self:ShowUIInitData()
	--self:SetWH();
	self:OnSetData();
	-- self:ShowDdList();
end;

function UIConsignmentUpItem:OnHide()
	
end;
function UIConsignmentUpItem:GetPanelType()
	return 0;
end

function UIConsignmentUpItem:ESCHide()
	return true;
end
function UIConsignmentUpItem:SetAddbtn()
	local id = self.data.tid
	local cfg = t_equip[id];
	local objSwf = self.objSwf;
	if cfg then
		objSwf.num.nextBtn.disabled = true;
		objSwf.num.prevBtn.disabled = true;
		objSwf.num.input = false;
	else
		objSwf.num.nextBtn.disabled = false;
		objSwf.num.prevBtn.disabled = false;
		objSwf.num.input = true;
	end;
end;

function UIConsignmentUpItem:ShowUIInitData()
	local objSwf = self.objSwf;
	self.upMoneyType = 12;
	objSwf.gold.selected = true;
	self.upYuanbMoney = 0;
	self.upGoldMoney = 0
	objSwf.gold_input.text = 0;
	--objSwf.yuanbao_input.text = 0;
end;

function UIConsignmentUpItem:OnSureClick()
	local pos =	self.data.pos
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	self.item = bagVO:GetItemByPos(pos);
	--print(self.data.tid)
	local cfg = nil
	if t_equip[self.data.tid] then 
		cfg = t_equip[self.data.tid];
	elseif t_item[self.data.tid] then 
		cfg = t_item[self.data.tid];
	end;
	if not cfg then
		FloatManager:AddNormal( StrConfig['consignment999']); 
		return
	end;
	if not self.item then 
		FloatManager:AddNormal( StrConfig['consignment005']); 
		return; end

	if self.upMoneyType == enAttrType.eaUnBindMoney then 
		if self.upYuanbMoney == 0 then 
			-- local okfun = function () self:OkUpItem(); end;
			-- local nofun = function () end;
			-- UIConfirm:Open(StrConfig["consignment007"],okfun,nofun);
			FloatManager:AddNormal( StrConfig['consignment024']); 
			return 
		end;
		if self.upYuanbMoney < 2 then 
			FloatManager:AddNormal( StrConfig['consignment032']); 
			return 
		end;
	-- elseif self.upMoneyType == enAttrType.eaUnBindGold then 
		-- if self.upGoldMoney == 0 then 
			-- local okfun = function () self:OkUpItem(); end;
			-- local nofun = function () end;
			-- UIConfirm:Open(StrConfig["consignment007"],okfun,nofun);
			-- FloatManager:AddNormal( StrConfig['consignment024']); 
			-- return 
		-- end;
	end;
	
	self:OkUpItem();
end;

function UIConsignmentUpItem:OkUpItem()

	--print("上架 I D",self.item:GetId());
	--print("上架数量",self.upNum)
	--print("金币出售",self.upGoldMoney)
	--print("元宝出售",self.upYuanbMoney)
	--print("价格类型",self.upMoneyType)
	--print("出售时限",self.upTime)
	local objSwf = self.objSwf;
	self.upNum = objSwf.num.value
	-- print('-----------------self.upTime',self.upTime)
	if self.upMoneyType == enAttrType.eaUnBindMoney then 
		ConsignmentController:ResqItemInShelves(self.item:GetId(),self.upNum,self.upYuanbMoney,self.upTime)
	elseif self.upMoneyType == enAttrType.eaUnBindGold then 
		ConsignmentController:ResqItemInShelves(self.item:GetId(),self.upNum,self.upYuanbMoney,self.upTime)
	end;
	self:Hide();
end;

function UIConsignmentUpItem:OnCanCelClick()
	self:Hide();
end;

function UIConsignmentUpItem:OnGoldClick()
	self.upMoneyType = 12;
end;
function UIConsignmentUpItem:OnYuanbaoClick()
	self.upMoneyType = 12;
end;

function UIConsignmentUpItem:OnGoldInput(text)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = toint(text);
	if not num then 
		num = 0;
	end;

	if num > 100000 then 
		num = 99999
	end;
	objSwf.gold_input.text = num;
	-- self.upGoldMoney = num;
	self.upYuanbMoney = num;
end

function UIConsignmentUpItem:OnYuanbaoInput(text)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local num = toint(text);
	if not num then 
		num = 0;
	end;
	--objSwf.yuanbao_input.text = num;
	self.upYuanbMoney = num;
end

-- function UIConsignmentUpItem:OnNsChange(e)
-- 	local objSwf = self.objSwf
-- 	if not objSwf then return; end
-- 	local target = e.target;
-- 	local numVal = toint(target.value)
-- 	print(numVal,'--------哈哈哈哈')
-- 	objSwf.num.value = toint(target.value)
-- 	self.upNum = toint(target.value)

-- end;


function UIConsignmentUpItem:OnSetData()
	local objSwf = self.objSwf;
	self.data = ConsignmentModel:GetUpItemBagInfo()

	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bagVO:GetItemById(self.data.id)

	-- local voc = {};
	-- voc.hasItem = true;
	-- voc.pos = item:GetPos();
	-- voc.isBig = false;
	-- EquipUtil:GetDataToEquipUIVO(voc,item,voc.isBig);
	local uidata = UIData.encode(ConsignmentUtils:GetSlotVO(item,nil))
	objSwf.item_icon:setData(uidata);


	local cfg =  ConsignmentUtils:GetCurIdCfg(self.data.tid)
	local nameColor = TipsConsts:GetItemQualityColor(cfg.quality)
	objSwf.itemName.htmlText =  "<font color='"..nameColor.. "'>"..cfg.name.. "</font>";
	-- objSwf.ShuiShou.htmlText = string.format(StrConfig['consignment040']);

	objSwf.num.maximum = item.count
	objSwf.num.minimum = 1;
	objSwf.num.value = 1;
	self.upNum = 1;

	-- self.objSwf.timeDdlist.selectedIndex = self.upTime - 1;
	self.objSwf.gold.selected = true;


	self:SetAddbtn()


	local pos =	self.data.pos
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	self.curitemUid = item:GetId();
end;

function UIConsignmentUpItem:ItemRollOver()
	local pos =	self.data.pos
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end;


-- 显示 ddlist
function UIConsignmentUpItem:ShowDdList()
	local objSwf = self.objSwf;
	self.objSwf.timeDdlist.dataProvider:cleanUp();

	for i=1,ConsignmentConsts.UpItemTimeLenght do 
		local name = StrConfig["consignmentupitem"..i];
		self.objSwf.timeDdlist.dataProvider:push(name);
	end;

	self.objSwf.timeDdlist.selectedIndex = 0;
end;

function UIConsignmentUpItem:OnDlistChange(e)
	self.upTime = e.index + 1;
	-- print('--------------------UIConsignmentUpItem:OnDlistChange(e)',self.upTime)
end;


function UIConsignmentUpItem:SetWH()
	local objSwf = self.objSwf;
	local wWidth, wHeight = UIManager:GetWinSize();
	objSwf.mask._width  = wWidth;
	objSwf.mask._height = wHeight;
end;

function UIConsignmentUpItem:OnResize(wWidth, wHeight)
	-- if not self.bShowState then return; end
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- objSwf.mask._width = wWidth;
	-- objSwf.mask._height = wHeight;
end

function UIConsignmentUpItem:GetWidth()
	return 270;
end

function UIConsignmentUpItem:GetHeight()
	return 435;
end


-- notifaction
function UIConsignmentUpItem:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		}
end;
function UIConsignmentUpItem:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.BagRemove or NotifyConsts.BagUpdate == name then  
		self:IsHidePanel(body.id)
	end;
end;

function UIConsignmentUpItem:IsHidePanel(uid)
	--print(self.curitemUid)
	if self.curitemUid == uid then 
		self:Hide();
	end;
end;


