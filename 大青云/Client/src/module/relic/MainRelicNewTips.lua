--[[
翅膀新获得提示
]]

_G.UIMainRelicNewTips = BaseUI:new("UIMainRelicNewTips");

UIMainRelicNewTips.itemId = nil;--物品cid

UIMainRelicNewTips.autoCloseTimer = nil;

function UIMainRelicNewTips:Create()
	self:AddSWF("RelicNewTipsV.swf", true, "bottomFloat");
end

function UIMainRelicNewTips:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnOk.click = function() self:OnBtnOkClick(); end
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
end

function UIMainRelicNewTips:NeverDeleteWhenHide()
	return true;
end

function UIMainRelicNewTips:Open(itemId)
	self.itemId = itemId;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIMainRelicNewTips:OnShow()
	SoundManager:PlaySfx(2054);
	self:ShowInfo();
	self:PlayEffects(true);
	local time = 10;

	if self.autoCloseTimer then
		TimerManager:UnRegisterTimer(self.autoCloseTimer);
		self.autoCloseTimer = nil;
	end
	self.objSwf.tfInfo.htmlText = string.format(StrConfig["equipnewtip1"], time);
	self.autoCloseTimer = TimerManager:RegisterTimer(function(curtime)
		if curtime == time then
			self:OnBtnOkClick(true);
			if self.autoCloseTimer then
				TimerManager:UnRegisterTimer(self.autoCloseTimer);
				self.autoCloseTimer = nil;
			end
		else
			self.objSwf.tfInfo.htmlText = string.format(StrConfig["equipnewtip1"], time - curtime);
		end

	end,1000,time);

	self.objSwf.btnOk:showEffect(ResUtil:GetButtonEffect10());
end

function UIMainRelicNewTips:OnHide()
	if self.autoCloseTimer then
		TimerManager:UnRegisterTimer(self.autoCloseTimer);
		self.autoCloseTimer = nil;
	end
	self:PlayEffects(false);
	WingNewTipsManager:OnShowOneOver();
	self.objSwf.btnOk:clearEffect();
end

function UIMainRelicNewTips:IsTween()
	return true;
end

UIMainRelicNewTips.TweenScale = 50;
--打开效果
function UIMainRelicNewTips:TweenShowEff(callback)
	local objSwf = self.objSwf;
	local endX,endY = self:GetCfgPos();
	local startX = endX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local startY = endY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 50;
	objSwf._xscale = self.TweenScale;
	objSwf._yscale = self.TweenScale;
	--
	Tween:To( self.objSwf, 0.3, {_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end

--关闭效果
function UIMainRelicNewTips:TweenHideEff(callback)
	local objSwf = self.objSwf;
	if not objSwf then self:DoHide(); return; end
	local startX,startY = self:GetCfgPos();
	local endX = startX + self:GetWidth()/2 - self:GetWidth()*self.TweenScale/100/2;
	local endY = startY + self:GetHeight()/2 - self:GetHeight()*self.TweenScale/100/2;
	--
	objSwf._x = startX;
	objSwf._y = startY;
	objSwf._alpha = 100;
	objSwf._xscale = 100;
	objSwf._yscale = 100;
	--
	self.isTweenHide = true;
	Tween:To( self.objSwf, 0.3, {_alpha = 0,_xscale=self.TweenScale,_yscale=self.TweenScale,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=function()
				self.isTweenHide = false;
				callback();
			end});
end

function UIMainRelicNewTips:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIMainRelicNewTips:DoTweenHide()
	self:TweenHideEff(function()
		self:DoHide();
	end);
end

function UIMainRelicNewTips:PlayEffects(play)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if play then
	else
		objSwf.fightEffect:stopEffect();
	end
end

function UIMainRelicNewTips:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then self:Hide(); return; end
	local item = bagVO:GetItemById(self.itemId);
	if not item then self:Hide(); return; end
	local cfg = item:GetCfg();
	if not cfg then return; end
	local quality = cfg.quality;
	local name = cfg.name;
	--

	objSwf.tfName.htmlText = string.format( "<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(quality), name );
	local fight = UIMainRelicNewTips:OnGetAddFight(item);
	if fight <= 0 then
		objSwf.tfFight.htmlText = ""
		objSwf.tfFightStr.text = ""
		objSwf.fightEffect._visible = false
	else
		objSwf.tfFight.htmlText = fight
		objSwf.tfFightStr.text = StrConfig['equip131'];
		objSwf.fightEffect._visible = true
	end

	local slotVO = RewardSlotVO:new();
	slotVO.id = cfg.id;
	slotVO.count = 0;
	slotVO.bind = item:GetBindState();
	objSwf.item:setData(slotVO:GetUIData());
end

--比穿着装备高出的战斗力
function UIMainRelicNewTips:OnGetAddFight(item)
	return RelicUtil:GetRelicAddFightByEquip(item)
end

function UIMainRelicNewTips:OnItemRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemById(self.itemId);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,item:GetPos());
	if not itemTipsVO then return; end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_LeftUp);
end

function UIMainRelicNewTips:OnItemRollOut()
	TipsManager:Hide();
end

function UIMainRelicNewTips:OnBtnOkClick(isAuto)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if bagVO then
		local item = bagVO:GetItemById(self.itemId);
		if item then
			if isAuto and item:GetBindState()~= BagConsts.Bind_UseBind then
				BagController:EquipRelic(BagConsts.BagType_Bag,item:GetPos());
			else
				BagController:EquipRelic(BagConsts.BagType_Bag,item:GetPos());
			end
		end
	end
	self:Hide();
end

function UIMainRelicNewTips:OnBtnCloseClick()
	self:Hide();
end