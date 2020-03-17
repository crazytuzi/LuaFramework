--[[
兵灵:进阶面板

]]

_G.UIBingLingLvlUp = BaseUI:new("UIBingLingLvlUp");

UIBingLingLvlUp.confirmUID = 0;
UIBingLingLvlUp.isShowClearConfirm = true;

function UIBingLingLvlUp:Create()
	self:AddSWF("lingzhenLevelUpPanel.swf", true, nil);
end

function UIBingLingLvlUp:OnLoaded( objSwf )
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

function UIBingLingLvlUp:OnDelete()
	self.objSwf = nil
end

function UIBingLingLvlUp:OnShow()
	self:UpdateShow();
	self:InitData();
end

function UIBingLingLvlUp:InitData()
	self.isShowClearConfirm = true;
end

function UIBingLingLvlUp:OnHide()
	-- if self.objUIDraw then
		-- self.objUIDraw:SetDraw(false);
	-- end
	BingLingController:SetAutoLevelUp(false);
	if self.confirmUID > 0 then
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = 0;
	end
end

--获取升阶按钮
function UIBingLingLvlUp:GetLvlUpBtn()
	if not self:IsShow() then return end
	return self.objSwf and self.objSwf.btnLvlUp;
end

function UIBingLingLvlUp:UpdateShow()	
	self:ShowBlessing(false);
	self:ShowConsume();
	self:SwitchAutoLvlUpState( BingLingController.isAutoLvlUp );
	self:ShowQingLingInfo();
end

local lastBlessing;
function UIBingLingLvlUp:ShowBlessing(showGain)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local binglingvo = BingLingUtils:GetBingLingVO(UIBingLing.currentid)
	if not binglingvo then
		return;
	end
	local blessing = binglingvo.progress;
	local level = binglingvo.id;
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local maxBlessing = cfg.maxVal;
	objSwf.proLoaderValue.num = blessing
	objSwf.proLoaderMax.num   = maxBlessing
	
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

function UIBingLingLvlUp:ShowConsume()
	self:ShowConsumeItem();
	self:ShowConsumeMoney();
	self:UpdateBtnEffect()
end

function UIBingLingLvlUp:ShowConsumeItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local binglingvo = BingLingUtils:GetBingLingVO(UIBingLing.currentid)
	if not binglingvo then
		return;
	end
	local blessing = binglingvo.progress;
	local level = binglingvo.id;
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local itemId = tonumber(cfg.levelItem[1]);
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "无道具";
	local labelItemColor = BagModel:GetItemNumInBag( itemId ) >= tonumber(cfg.levelItem[2]) and "#2f801f" or "#780000";
	objSwf.btnConsume.htmlLabel = string.format( StrConfig['magicWeapon012'], labelItemColor, itemName, tonumber(cfg.levelItem[2]) );
end

function UIBingLingLvlUp:ShowConsumeMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local binglingvo = BingLingUtils:GetBingLingVO(UIBingLing.currentid)
	if not binglingvo then
		return;
	end
	local blessing = binglingvo.progress;
	local level = binglingvo.id;
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local moneyConsume = cfg.money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local labelMoneyColor = moneyEnough and "#2f801f" or "#780000";
	objSwf.txtMoney.htmlLabel = string.format( "<u><font color='%s'>%s</font></u>", labelMoneyColor, moneyConsume );
	--objSwf.cbAutoBuy.selected = BingLingModel.autoBuy;
	objSwf.cbAutoBuy._visible = false;
end

function UIBingLingLvlUp:ShowLvlUpEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:OnHide();
	-- local pos = UIManager:PosLtoG( objSwf, 1160, 583 );
	-- UIEffectManager:PlayEffect( ResUtil:GetJinJieSuccess(), pos );
	-- SoundManager:PlaySfx(2030)
end

function UIBingLingLvlUp:ShowQingLingInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfcleardata.htmlText = "";
	local level = BingLingModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	if cfg.is_wishclear == true then
		objSwf.tfcleardata.htmlText = StrConfig["realm45"];
	end
end

function UIBingLingLvlUp:OnTipsAreaRollOver()
	local level = BingLingModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then return; end
	local blessing = BingLingModel:GetBlessing();
	local isWishclear = cfg.is_wishclear
	local tipStr = StrConfig["wuhun26"]
	if isWishclear then
		tipStr = StrConfig["wuhun27"]
	end

	TipsManager:ShowBtnTips( string.format(StrConfig["wuhun25"],blessing, tipStr));
end

function UIBingLingLvlUp:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UIBingLingLvlUp:OnBtnCloseClick()
	self:Hide();
end

UIBingLingLvlUp.lastSendTime = 0;
function UIBingLingLvlUp:OnBtnLvlUpClick()

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();
	
	if not BingLingController:CheckLevelUp(BingLingUtils:GetLevelByid(UIBingLing.currentid)) then
		return 
	end

	BingLingController:SetAutoLevelUp(false);
	local curlevel = BingLingUtils:GetLevelByid(UIBingLing.currentid);
	BingLingController:ReqBingLingLevelUp(curlevel);
end

function UIBingLingLvlUp:OnBtnAutoLvlUpClick()
	if not BingLingController:CheckLevelUp(BingLingUtils:GetLevelByid(UIBingLing.currentid)) then
		return 
	end
	
	BingLingController:SetAutoLevelUp(true);
	local curlevel = BingLingUtils:GetLevelByid(UIBingLing.currentid);
	BingLingController:ReqBingLingLevelUp(curlevel);
end

function UIBingLingLvlUp:OnBtnCancelAutoClick()
	BingLingController:SetAutoLevelUp(false);
end

function UIBingLingLvlUp:SwitchAutoLvlUpState(isAutoLvlUp)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.btnAutoLvlUp._visible = not isAutoLvlUp;
	objSwf.btnCancelAuto._visible = isAutoLvlUp;
	
	if isAutoLvlUp then
		UIBingLing:ShowIncrement()
	else
		UIBingLing:HideIncrement()
	end
end

function UIBingLingLvlUp:OnBtnConsumeRollOver(e)
	local binglingvo = BingLingUtils:GetBingLingVO(UIBingLing.currentid);
	if not binglingvo then
		return;
	end
	local level = binglingvo.id;
	local cfg = t_shenbingbingling[level];
	if not cfg then return; end
	local itemId = tonumber(cfg.levelItem[1]);
	TipsManager:ShowItemTips( itemId );
end

function UIBingLingLvlUp:OnBtnConsumeRollOut()
	TipsManager:Hide();
end

function UIBingLingLvlUp:OnCBAutoBuySelect(e)
	BingLingModel.autoBuy = e.selected;
end

function UIBingLingLvlUp:OnNameLoaded(e)
	local img = e.target.content;
	if not img then return end
	img._x = img._width * -1;
end

function UIBingLingLvlUp:OnNumValueLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.proLoaderValue._x = objSwf.posSign._x - objSwf.proLoaderValue.width
end

function UIBingLingLvlUp:OnNumMaxLoadComplete(e)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- objSwf.proLoaderMax._x = objSwf.posSign._x + objSwf.posSign._width - 10
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIBingLingLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.BingLingLevelUp,
		NotifyConsts.BingLingBlessing,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
	};
end

--处理消息
function UIBingLingLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.BingLingLevelUp then
		self:ShowLvlUpEffect();
	elseif name == NotifyConsts.BingLingBlessing then
		self:ShowBlessing(true);
		self:ShowConsume();
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

function UIBingLingLvlUp:UpdateBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end	
	local panelState = 2
	local lvlUpState = panelState == 2	
	
	local lvlUpConditionEnough = self:CheckMoney(UIBingLing.currentid) and self:CheckItem(UIBingLing.currentid)
	objSwf.btnLvlUpEff._visible = lvlUpState and lvlUpConditionEnough
	objSwf.btnAutoEff._visible  = lvlUpState and lvlUpConditionEnough
end

function UIBingLingLvlUp:CheckMoney(level)	
	local cfg = t_shenbingbingling[level];
	if not cfg then return false end
	if not cfg.money then
		return true;
	end
	local moneyConsume = cfg.money;
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local playerMoney = playerInfo.eaBindGold + playerInfo.eaUnBindGold;
	local moneyEnough = playerMoney >= moneyConsume;
	local bBuy = moneyEnough and true or false;
	return bBuy
end

function UIBingLingLvlUp:CheckItem(level)
	local cfg = t_shenbingbingling[level];
	if not cfg then return false end
	local itemid = tonumber(cfg.levelItem[1]);
	local NbNum = BagModel:GetItemNumInBag(itemid);
	if NbNum < tonumber(cfg.levelItem[2]) then
		FloatManager:AddNormal( StrConfig["qizhan5"], objSwf.activepanel.btnactive);
		return false;
	end
	return true;
end