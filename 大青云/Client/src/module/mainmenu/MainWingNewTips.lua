--[[
翅膀新获得提示
]]

_G.UIMainWingNewTips = BaseUI:new("UIMainWingNewTips");

UIMainWingNewTips.itemId = nil;--物品cid

UIMainWingNewTips.autoCloseTimer = nil;

function UIMainWingNewTips:Create()
	self:AddSWF("wingNewTipsV.swf", true, "bottomFloat");
end

function UIMainWingNewTips:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnOk.click = function() self:OnBtnOkClick(); end
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
	objSwf.numFight._visible = false;
end

function UIMainWingNewTips:NeverDeleteWhenHide()
	return true;
end

function UIMainWingNewTips:Open(itemId)
	self.itemId = itemId;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIMainWingNewTips:OnShow()
	SoundManager:PlaySfx(2054);
	self:ShowInfo();
	self:PlayEffects(true);
	local time = 0;
	if MainPlayerModel.humanDetailInfo.eaLevel < QuestConsts.AutoLevel then
		time = 5;
	else
		time = 30;
	end
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

function UIMainWingNewTips:OnHide()
	if self.autoCloseTimer then
		TimerManager:UnRegisterTimer(self.autoCloseTimer);
		self.autoCloseTimer = nil;
	end
	self:PlayEffects(false);
	WingNewTipsManager:OnShowOneOver();
	self.objSwf.btnOk:clearEffect();
end

function UIMainWingNewTips:IsTween()
	return true;
end

UIMainWingNewTips.TweenScale = 50;
--打开效果
function UIMainWingNewTips:TweenShowEff(callback)
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
function UIMainWingNewTips:TweenHideEff(callback)
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

function UIMainWingNewTips:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIMainWingNewTips:DoTweenHide()
	self:TweenHideEff(function()
		self:DoHide();
	end);
end

function UIMainWingNewTips:PlayEffects(play)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if play then
	else
		objSwf.fightEffect:stopEffect();
	end
end

function UIMainWingNewTips:ShowInfo()
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
	local newSuperNum = 0;
	local newSuperVO = EquipModel:GetNewSuperVO(item:GetId());
	if newSuperVO then
		for i,vo in ipairs(newSuperVO.newSuperList) do
			if vo.id > 0 then
				newSuperNum = newSuperNum + 1;
			end
		end
	end
	-- if newSuperNum > 0 then
		-- name = "卓越的 " .. name;
	-- end
	
	-- local superVO = EquipModel:GetSuperVO(item:GetId());
	-- if superVO then
		-- local superNum = 0;
		-- for i,vo in ipairs(superVO.superList) do
			-- if vo.id > 0 then
				-- superNum = superNum + 1;
			-- end
		-- end
		-- if superNum == 5 then
			-- name = name .. "·超越";
		-- elseif superNum == 6 then
			-- name = name .. "·无双";
		-- elseif superNum == 7 then
			-- name = name .. "·逆天";
		-- end
	-- end
	objSwf.tfName.htmlText = string.format( "<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(quality), name );
	objSwf.tfFight.htmlText = UIMainWingNewTips:OnGetAddFight(item);
	objSwf.tfFightStr.text = StrConfig['equip131'];
	--objSwf.tfInfo._visible = false;
	-- if newSuperNum > 0 then
		-- objSwf.tfInfo.htmlText = string.format("%s条卓越属性",newSuperNum);
	-- else
		-- objSwf.tfInfo.htmlText = "";
	-- end
	local slotVO = RewardSlotVO:new();
	slotVO.id = cfg.id;
	slotVO.count = 0;
	slotVO.bind = item:GetBindState();
	objSwf.item:setData(slotVO:GetUIData());
	--
	-- local hasEquipItem = BagUtil:GetCompareEquip(BagConsts.BagType_Bag,item:GetPos());
	-- if hasEquipItem then
		-- objSwf.numFight.num = item:GetFight() - hasEquipItem:GetFight();
	-- else
		-- objSwf.numFight.num = item:GetFight();
	-- end
	
	
end

--比穿着装备高出的战斗力
function UIMainWingNewTips:OnGetAddFight(item)
	local fightNum = BagUtil:CheckBetterWingFightNum(item:GetBagType(),item:GetPos(),item:GetTid());
	return fightNum;
end

function UIMainWingNewTips:OnItemRollOver()
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

function UIMainWingNewTips:OnItemRollOut()
	TipsManager:Hide();
end

function UIMainWingNewTips:OnBtnOkClick(isAuto)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if bagVO then
		local item = bagVO:GetItemById(self.itemId);
		if item then
			if isAuto and item:GetBindState()~= BagConsts.Bind_UseBind then
				BagController:EquipWing(BagConsts.BagType_Bag,item:GetPos());
			else
				BagController:EquipWing(BagConsts.BagType_Bag,item:GetPos());
			end
		end
	end
	self:Hide();
end

function UIMainWingNewTips:OnBtnCloseClick()
	self:Hide();
end