--[[
骑战:进阶面板

]]

_G.UIQiZhanLvlUp = BaseUI:new("UIQiZhanLvlUp");

UIQiZhanLvlUp.confirmUID = 0;
UIQiZhanLvlUp.isShowClearConfirm = true;

function UIQiZhanLvlUp:Create()
	self:AddSWF("lingzhenLevelUpPanel.swf", true, nil);
end

function UIQiZhanLvlUp:OnLoaded( objSwf )
	self.objSwf = objSwf
	objSwf.txtConsume.text       = StrConfig['magicWeapon010'];
	objSwf.txtMoneyName.text     = StrConfig['magicWeapon011'];
	objSwf.btnConsume.autoSize   = true;
	objSwf.txtMoney.autoSize     = "left";
	objSwf.txtConsume.autoSize   = "left";
	objSwf.txtMoneyName.autoSize = "left";
	objSwf.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.tipsArea.rollOut  = function() self:OnTipsAreaRollOut(); end

	-- objSwf.loader.hitTestDisable = true;
	-- objSwf.btnClose.click              = function() self:OnBtnCloseClick(); end
	objSwf.btnLvlUp.click              = function() self:OnBtnLvlUpClick(); end
	objSwf.btnAutoLvlUp.click          = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.btnCancelAuto.click         = function() self:OnBtnCancelAutoClick(); end
	objSwf.btnConsume.rollOver         = function(e) self:OnBtnConsumeRollOver(e); end
	objSwf.btnConsume.rollOut          = function() self:OnBtnConsumeRollOut(); end
	objSwf.cbAutoBuy.select            = function(e) self:OnCBAutoBuySelect(e) end
	-- objSwf.nameLoader.loaded           = function(e) self:OnNameLoaded(e); end
	objSwf.proLoaderValue.loadComplete = function(e) self:OnNumValueLoadComplete(e); end
	-- objSwf.proLoaderMax.loadComplete   = function(e) self:OnNumMaxLoadComplete(e); end
end

function UIQiZhanLvlUp:OnDelete()
	self.objSwf = nil
end

function UIQiZhanLvlUp:OnShow()
	self:UpdateShow();
	self:InitData();
end

function UIQiZhanLvlUp:InitData()
	self.isShowClearConfirm = true;
end

function UIQiZhanLvlUp:OnHide()
	-- if self.objUIDraw then
		-- self.objUIDraw:SetDraw(false);
	-- end
	QiZhanController:SetAutoLevelUp(false);
	if self.confirmUID > 0 then
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = 0;
	end
end

--获取升阶按钮
function UIQiZhanLvlUp:GetLvlUpBtn()
	if not self:IsShow() then return end
	return self.objSwf and self.objSwf.btnLvlUp;
end

function UIQiZhanLvlUp:UpdateShow()	
	self:ShowBlessing(false);
	self:ShowConsume();
	self:SwitchAutoLvlUpState( QiZhanController.isAutoLvlUp );
	self:ShowQingLingInfo();
end

local lastBlessing;
function UIQiZhanLvlUp:ShowBlessing(showGain)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local blessing = QiZhanModel:GetBlessing();
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local maxBlessing = cfg.wish_max;
	objSwf.proLoaderValue.num = blessing
	-- objSwf.proLoaderMax.num   = maxBlessing
	
	-- objSwf.siBlessing.maximum = maxBlessing;
	-- objSwf.siBlessing.value   = blessing;
	-- if noTween then
		-- objSwf.siBlessing:setProgress( blessing, maxBlessing );
	-- else
		-- objSwf.siBlessing:tweenProgress( blessing, maxBlessing, 0 );
	-- end
	
	if showGain then
		if lastBlessing and (blessing - lastBlessing > 0) then
			local blessingGain = blessing - lastBlessing;
			if blessingGain > 0 then
				FloatManager:AddNormal( string.format(StrConfig['wuhun38'], blessingGain ), objSwf.tipsArea );
			end
			objSwf.siBlessing:tweenProgress( blessing, maxBlessing, 0 );
		else
			objSwf.siBlessing:setProgress( blessing, maxBlessing );
		end
	else
		objSwf.siBlessing:setProgress( blessing, maxBlessing );
	end
	lastBlessing = blessing;
end

function UIQiZhanLvlUp:ShowConsume()
	self:ShowConsumeItem();
	self:ShowConsumeMoney();
	self:UpdateBtnEffect()
end

function UIQiZhanLvlUp:ShowConsumeItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local itemId, itemNum, isEnough = QiZhanUtils:GetConsumeItem(level);
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "无道具";
	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#2f801f" or "#780000";
	objSwf.btnConsume.htmlLabel = string.format( StrConfig['magicWeapon012'], labelItemColor, itemName, itemNum );
end

function UIQiZhanLvlUp:ShowConsumeMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local moneyConsume = cfg.proce_money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local labelMoneyColor = moneyEnough and "#2f801f" or "#780000";
	objSwf.txtMoney.htmlLabel = string.format( "<u><font color='%s'>%s</font></u>", labelMoneyColor, moneyConsume );
	--objSwf.cbAutoBuy.selected = QiZhanModel.autoBuy;
	objSwf.cbAutoBuy._visible = false;
end

function UIQiZhanLvlUp:ShowLvlUpEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:OnHide();
	-- local pos = UIManager:PosLtoG( objSwf, 1160, 583 );
	-- UIEffectManager:PlayEffect( ResUtil:GetJinJieSuccess(), pos );
	-- SoundManager:PlaySfx(2030)
end

function UIQiZhanLvlUp:ShowQingLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfcleardata.htmlText = "";
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	if cfg.is_wishclear == true then
		objSwf.tfcleardata.htmlText = StrConfig["realm45"];
	end
end

function UIQiZhanLvlUp:OnTipsAreaRollOver()
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local blessing = QiZhanModel:GetBlessing();
	local isWishclear = cfg.is_wishclear
	local tipStr = StrConfig["wuhun26"]
	if isWishclear then
		tipStr = StrConfig["wuhun27"]
	end

	TipsManager:ShowBtnTips( string.format(StrConfig["wuhun25"],blessing, tipStr));
end

function UIQiZhanLvlUp:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UIQiZhanLvlUp:OnBtnCloseClick()
	self:Hide();
end

UIQiZhanLvlUp.lastSendTime = 0;
function UIQiZhanLvlUp:OnBtnLvlUpClick()

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();
	
	if not QiZhanController:CheckLevelUp() then
		return 
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local cfg = t_ridewar[QiZhanModel:GetLevel()];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					QiZhanController:SetAutoLevelUp(false);
					QiZhanController:ReqQiZhanLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end

	QiZhanController:SetAutoLevelUp(false);
	QiZhanController:ReqQiZhanLevelUp();
end

function UIQiZhanLvlUp:OnBtnAutoLvlUpClick()
	if not QiZhanController:CheckLevelUp() then
		return 
	end
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local cfg = t_ridewar[QiZhanModel:GetLevel()];
		if cfg then
			local isWishclear = cfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					QiZhanController:SetAutoLevelUp(true);
					QiZhanController:ReqQiZhanLevelUp();
					self.isShowClearConfirm = false;
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc );
				return;
			end
		end
	end
	
	QiZhanController:SetAutoLevelUp(true);
	QiZhanController:ReqQiZhanLevelUp();
end

function UIQiZhanLvlUp:OnBtnCancelAutoClick()
	QiZhanController:SetAutoLevelUp(false);
end

function UIQiZhanLvlUp:SwitchAutoLvlUpState(isAutoLvlUp)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.btnAutoLvlUp._visible = not isAutoLvlUp;
	objSwf.btnCancelAuto._visible = isAutoLvlUp;
	
	if isAutoLvlUp then
		UIQiZhan:ShowIncrement()
	else
		UIQiZhan:HideIncrement()
	end
end

function UIQiZhanLvlUp:OnBtnConsumeRollOver(e)
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local itemId, itemNum, isEnough = QiZhanUtils:GetConsumeItem(level);
	if not itemId then return; end
	TipsManager:ShowItemTips( itemId );
end

function UIQiZhanLvlUp:OnBtnConsumeRollOut()
	TipsManager:Hide();
end

function UIQiZhanLvlUp:OnCBAutoBuySelect(e)
	QiZhanModel.autoBuy = e.selected;
end

function UIQiZhanLvlUp:OnNameLoaded(e)
	local img = e.target.content;
	if not img then return end
	img._x = img._width * -1;
end

function UIQiZhanLvlUp:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderValue._x = objSwf.posSign._x - objSwf.proLoaderValue.width /2
end

function UIQiZhanLvlUp:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.proLoaderMax._x = objSwf.posSign._x + objSwf.posSign._width - 10
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIQiZhanLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.QiZhanLevelUp,
		NotifyConsts.QiZhanBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
	};
end

--处理消息
function UIQiZhanLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.QiZhanLevelUp then
		self:ShowLvlUpEffect();
	elseif name == NotifyConsts.QiZhanBlessing then
		self:ShowBlessing(true);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaBindGold or body.type == enAttrType.eaUnBindGold then
			self:ShowConsumeMoney();
			self:UpdateBtnEffect()
		end
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:ShowConsumeItem();
			self:UpdateBtnEffect()
		end
	end
end

function UIQiZhanLvlUp:UpdateBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end	
	local panelState = 2
	local lvlUpState = panelState == 2	
	
	local lvlUpConditionEnough = self:CheckMoney() and self:CheckItem()
	objSwf.btnLvlUpEff._visible = lvlUpState and lvlUpConditionEnough
	objSwf.btnAutoEff._visible  = lvlUpState and lvlUpConditionEnough
end

function UIQiZhanLvlUp:CheckMoney()	
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return false end
	local moneyConsume = cfg.proce_money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	if playerMoney >= moneyConsume then
		return true
	else
		return false
	end
end

function UIQiZhanLvlUp:CheckItem()
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return false end
	local itemConsume = cfg.proce_consume;
	local itemId = itemConsume[1];
	local itemNum = itemConsume[2];
	
	if BagModel:GetItemNumInBag( itemId ) >= itemNum then
		return true
	else
		return false
	end
end