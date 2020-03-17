--[[
装备穿戴确认
lizhuangzhuang
2015年9月24日12:01:21
]]

_G.UIBagEquipConfirm = BaseUI:new("UIBagEquipConfirm");

UIBagEquipConfirm.waitList = {};
UIBagEquipConfirm.currVO = nil;
--1分钟不操作取消
UIBagEquipConfirm.timerKey = nil;

function UIBagEquipConfirm:Create()
	self:AddSWF("equipConfirm.swf",true,"top");
end

function UIBagEquipConfirm:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.tfContent.autoSize = "center";
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
	objSwf.btnConfirm.label = StrConfig["confirmName2"];
	objSwf.btnCancel.label = StrConfig["confirmName3"];
end


function UIBagEquipConfirm:ESCHide()
	return true;
end

function UIBagEquipConfirm:OnESC()
	self:OnBtnCloseClick();
end

function UIBagEquipConfirm:Open(bag,pos,itemUid,confirmFunc)
	if self.currVO then
		if self.currVO.itemUid == itemUid then
			return;
		end
		if #self.waitList > 0 then
			for i,vo in ipairs(self.waitList) do
				if vo.itemUid == itemUid then
					return;
				end
			end
		end
	end
	local vo = {};
	vo.bag = bag;
	vo.pos = pos;
	vo.itemUid = itemUid;
	vo.confirmFunc = confirmFunc;
	if self.currVO then
		table.push(self.waitList,vo);
	else
		self.currVO = vo;
		self:Show();
	end
end

function UIBagEquipConfirm:CloseAll()
	if not self:IsShow() then return; end
	self.currVO = nil;
	self.waitList = {};
	self:Hide();
end

function UIBagEquipConfirm:ShowNext()
	self.currVO = nil;
	if #self.waitList > 0 then
		self.currVO = table.remove(self.waitList,1,1);
		self:ShowInfo();
	else
		self:Hide();
	end
end

function UIBagEquipConfirm:OnShow()
	self:ShowInfo();
	SoundManager:PlaySfx(2045);
end

function UIBagEquipConfirm:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIBagEquipConfirm:ShowInfo()
	self:Top();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfContent.htmlText = StrConfig["bag48"];
	--
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:OnBtnCloseClick();
		self.timerKey = nil;
	end,60000,1);
	--
	if not self.currVO then return; end
	local bagVO = BagModel:GetBag(self.currVO.bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currVO.pos);
	if not item then return; end
	local vo = self:GetSlotVO(item);
	objSwf.item:setData(UIData.encode(vo));
	objSwf.tfName.text = item:GetCfg().name;
	objSwf.tfName.textColor = TipsConsts:GetItemQualityColorVal(item:GetCfg().quality);
end

function UIBagEquipConfirm:GetSlotVO(item)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = false;
	EquipUtil:GetDataToEquipUIVO(vo,item,vo.isBig);
	return vo;
end

function UIBagEquipConfirm:OnItemRollOver()
	if not self.currVO then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currVO.bag,self.currVO.pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIBagEquipConfirm:OnItemRollOut()
	TipsManager:Hide();
end

function UIBagEquipConfirm:OnBtnCloseClick()
	self:ShowNext();
end

function UIBagEquipConfirm:OnBtnCancelClick()
	self:ShowNext();
end

function UIBagEquipConfirm:OnBtnConfirmClick()
	if self.currVO and self.currVO.confirmFunc then
		self.currVO.confirmFunc();
	end
	self:ShowNext();
end