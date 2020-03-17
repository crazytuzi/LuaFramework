--[[
物品推荐使用
lizhuangzhuang
2015年5月5日16:41:11
]]

_G.UIItemGuideUse = BaseUI:new("UIItemGuideUse");

UIItemGuideUse.list = {};
UIItemGuideUse.currId = nil;
UIItemGuideUse.currGetFunc = nil;
--不再提示
UIItemGuideUse.noTips = false;

function UIItemGuideUse:Create()
	if Version:IsLianYun() then
		self:AddSWF("itemGuideUseLianYun.swf",true,"bottomFloat");
	else
		self:AddSWF("itemGuideUse.swf",true,"bottomFloat");
	end
end

function UIItemGuideUse:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.item.rollOver    = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut     = function() self:OnItemRollOut(); end
	-- objSwf.nsNum.change = function() self:OnNSNumChange(); end
end

function UIItemGuideUse:NeverDeleteWhenHide()
	return true;
end

function UIItemGuideUse:IsTween()
	return true;
end

UIItemGuideUse.TweenScale = 50;
--打开效果
function UIItemGuideUse:TweenShowEff(callback)
	SoundManager:PlaySfx(2054);
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
function UIItemGuideUse:TweenHideEff(callback)
	local objSwf = self.objSwf;
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
	Tween:To( self.objSwf, 0.3, {_alpha = 0,_xscale=self.TweenScale,_yscale=self.TweenScale,_x=endX,_y=endY,ease=Back.easeInOut},
			{onComplete=callback});
end


function UIItemGuideUse:DoTweenShow()
	self:TweenShowEff(function()
		self:DoShow();
	end);
end

function UIItemGuideUse:DoTweenHide()
	self:TweenHideEff(function()
		self:DoHide();
	end);
end

function UIItemGuideUse:OnShow()
	self:ShowInfo();
	self:PlayEffects(true);
	self.objSwf.btnConfirm:showEffect(ResUtil:GetButtonEffect10());
end

function UIItemGuideUse:OnHide()
	self:PlayEffects(false);
	self.objSwf.btnConfirm:clearEffect();
	Tween:KillOf(self.objSwf);
end

function UIItemGuideUse:PlayEffects(play)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if play then
		-- objSwf.edgeEffect:playEffect(0);
	else
		-- objSwf.edgeEffect:stopEffect();
	end
end

function UIItemGuideUse:ShowInfo()
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then
		self:ShowNext();
		return;
	end
	local item = bagVO:GetItemById(self.currId);
	if not item then
		self:ShowNext();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.cbNoTip.selected = false;
	objSwf.nsNum.minimum = 1;
	objSwf.nsNum.maximum = item:GetCount();
	objSwf.nsNum.value = item:GetCount();
	local itemConfig = t_item[item:GetTid()];
	if itemConfig then
		objSwf.txtName.text = itemConfig.name;
		objSwf.txtName.textColor = TipsConsts:GetItemQualityColorVal( itemConfig.quality );
		objSwf.tfInfo.htmlText = string.format(StrConfig['bag49'],item:GetCount());
		--显示物品图标
		local slotVO = RewardSlotVO:new();
		slotVO.id = item:GetTid();
		slotVO.count = 0;
		objSwf.item:setData( slotVO:GetUIData() );
	else
		self:ShowNext();
	end
end

function UIItemGuideUse:CheckHasItem(id)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then
		return false;
	end
	local item = bagVO:GetItemById(id);
	if not item then
		return false;
	end
	return true;
end
-- function UIItemGuideUse:OnNSNumChange()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- if not self.currGetFunc then 
		-- objSwf.tfGet.htmlText = "";
		-- return; 
	-- end
	-- local num = objSwf.nsNum.value;
	-- local str = self.currGetFunc(num);
	-- objSwf.tfGet.htmlText = str;
-- end

function UIItemGuideUse:ShowNext()
	if #self.list <= 0 then
		self.currId = nil;
		self.currGetFunc = nil;
		self:DoHide();
		self.bShowState = false;
		return;
	end
	self:TweenHideEff(function()
		self.currId = nil;
		self.currGetFunc = nil;
		if #self.list > 0 then
			local vo = table.remove(self.list,1,1);
			self.currId = vo.id;
			self.currGetFunc = vo.getfunc;
			self:TweenShowEff();
			self:ShowInfo();
		else
			self:Hide();
		end
	end);
end

function UIItemGuideUse:OnBtnCloseClick()
	local objSwf = self.objSwf;
	if objSwf and objSwf.cbNoTip.selected then
		self.noTips = true;
	end
	self:ShowNext();
end

function UIItemGuideUse:OnBtnConfirmClick()
	local objSwf = self.objSwf;
	if objSwf and objSwf.cbNoTip.selected then
		self.noTips = true;
	end
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if bagVO then
		local item = bagVO:GetItemById(self.currId);
		if item then
			local num = objSwf.nsNum.value;
			num = num>item:GetCount() and item:GetCount() or num;
			BagController:UseItem(BagConsts.BagType_Bag,item:GetPos(),num);
		end
	end
	self:ShowNext();
end

function UIItemGuideUse:OnItemRollOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

function UIItemGuideUse:OnItemRollOut()
	TipsManager:Hide();
end

function UIItemGuideUse:OnBagUpdate(pos)
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	if item:GetId() ~= self.currId then return; end
	if item:GetCount() > objSwf.nsNum.maximum then
		objSwf.nsNum.maximum = item:GetCount();
		objSwf.tfInfo.htmlText = string.format(StrConfig['bag49'],item:GetCount());
		objSwf.nsNum.value = item:GetCount();
	elseif item:GetCount() < objSwf.nsNum.maximum then
		if objSwf.nsNum.value > item:GetCount() then
			objSwf.nsNum.value = item:GetCount();
		end
		objSwf.nsNum.maximum = item:GetCount();
		objSwf.tfInfo.htmlText = string.format(StrConfig['bag49'],item:GetCount());
	end
end

function UIItemGuideUse:OnBagRemove(id)
	if id == self.currId then
		self:ShowNext();
	end
end

function UIItemGuideUse:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:OnBagUpdate(body.pos);
	elseif name == NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:OnBagRemove(body.id);
	end
end

function UIItemGuideUse:ListNotificationInterests()
	return {NotifyConsts.BagUpdate,NotifyConsts.BagRemove};
end

--------------------------------------------------------
function UIItemGuideUse:Open(id,getfunc)
	if self.noTips then return; end
	if self.currId == id then return; end
	if not self:CheckHasItem(id) then return; end
	--
	for i,vo in ipairs(self.list) do
		if vo.id == id then
			return;
		end
	end
	if self.currId then
		local vo = {};
		vo.id = id;
		vo.getfunc = getfunc;
		table.push(self.list,vo);
	else
		self.currId = id;
		self.currGetFunc = getfunc;
		self:Show();
	end
end

--关闭所有
function UIItemGuideUse:CloseAll()
	self.list = {};
	self.currId = nil;
	self.currGetFunc = nil;
	self:Hide();
end

