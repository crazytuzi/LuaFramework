--[[
宝甲:进阶面板
2015年4月28日17:12:38
zhangshuhui
]]

_G.UIBaoJiaLvlUp = BaseUI:new("UIBaoJiaLvlUp");

function UIBaoJiaLvlUp:Create()
	self:AddSWF("baoJiaLevelUpPanel.swf", true, nil);
end

function UIBaoJiaLvlUp:OnLoaded( objSwf )
	objSwf.txtConsume.text       = StrConfig['baojia010'];
	objSwf.txtMoneyName.text     = StrConfig['baojia011'];
	objSwf.btnConsume.autoSize   = true;
	objSwf.txtMoney.autoSize     = "left";
	objSwf.txtConsume.autoSize   = "left";
	objSwf.txtMoneyName.autoSize = "left";
	objSwf.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.tipsArea.rollOut  = function() self:OnTipsAreaRollOut(); end

	objSwf.loader.hitTestDisable = true;
	objSwf.btnClose.click         = function() self:OnBtnCloseClick(); end
	objSwf.btnLvlUp.click         = function() self:OnBtnLvlUpClick(); end
	objSwf.btnAutoLvlUp.click     = function() self:OnBtnAutoLvlUpClick(); end
	objSwf.btnCancelAuto.click    = function() self:OnBtnCancelAutoClick(); end
	objSwf.btnConsume.rollOver    = function(e) self:OnBtnConsumeRollOver(e); end
	objSwf.btnConsume.rollOut     = function() self:OnBtnConsumeRollOut(); end
	objSwf.cbAutoBuy.select       = function(e) self:OnCBAutoBuySelect(e) end
	objSwf.proLoader.loadComplete = function() self:OnNumLoadComplete(); end
end

function UIBaoJiaLvlUp:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIBaoJiaLvlUp:OnShow()
	self:UpdateShow();
end

function UIBaoJiaLvlUp:GetWidth()
	return 332;
end

function UIBaoJiaLvlUp:GetHeight()
	return 625;
end

function UIBaoJiaLvlUp:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	BaoJiaController:SetAutoLevelUp(false);
end

function UIBaoJiaLvlUp:UpdateShow()
	self:ShowBaoJia();
	self:ShowBlessing(false);
	self:ShowConsume();
	self:SwitchAutoLvlUpState( BaoJiaController.isAutoLvlUp );
end

function UIBaoJiaLvlUp:ShowBaoJia()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local level = BaoJiaModel:GetLevel() + 1;
	local cfg = t_baojia[level];
	if not cfg then return; end
	objSwf.nameLoader.source = ResUtil:GetBaoJiaNameImg(level);
	local lvlStr = tostring(level);
	if level == 10 then lvlStr = "a" end;
	objSwf.lvlLoader:drawStr( lvlStr );
	self:Show3DBaoJia();
end

local viewPort;
function UIBaoJiaLvlUp:Show3DBaoJia()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currentShowLevel = BaoJiaModel:GetLevel() + 1;
	local cfg = t_baojia[currentShowLevel];
	if not cfg then
		Error("Cannot find config of baojia level:"..level);
		return;
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(620, 860); end
		self.objUIDraw = UISceneDraw:new( "BaoJiaLvlUpUI", objSwf.loader, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.loader );
	local sen = cfg.ui_up_sen;
	if sen and sen ~= "" then
		self.objUIDraw:SetScene( cfg.ui_up_sen );
		self.objUIDraw:SetDraw( true );
	end
end

local lastBlessing;
function UIBaoJiaLvlUp:ShowBlessing(showGain)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local blessing = BaoJiaModel:GetBlessing();
	local level = BaoJiaModel:GetLevel();
	local cfg = t_baojia[level];
	if not cfg then return; end
	local maxBlessing = cfg.wish_max;
	local proStr = string.format( "%sp%s", blessing, maxBlessing );
	objSwf.proLoader:drawStr( proStr );
	objSwf.siBlessing.maximum = maxBlessing;
	objSwf.siBlessing.value = blessing;
	if showGain then
		if lastBlessing then
			local blessingGain = blessing - lastBlessing;
			if blessingGain > 0 then
				FloatManager:AddNormal( string.format(StrConfig['wuhun38'], blessingGain ), objSwf.tipsArea );
			end
		end
	end
	lastBlessing = blessing;
end

function UIBaoJiaLvlUp:ShowConsume()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	local level = BaoJiaModel:GetLevel();
	local cfg = t_baojia[level];
	if not cfg then return; end
	local itemConsume = cfg.proce_consume;
	local itemId = itemConsume[1];
	local itemNum = itemConsume[2];
	local itemCfg = t_item[itemId];
	local itemName = itemCfg and itemCfg.name or "something baojia";
	objSwf.btnConsume.data = {itemId = itemId, count = itemNum};
	local labelColor = BagModel:GetItemNumInBag( itemId ) >= itemNum and "#2f801f" or "#780000";
	objSwf.btnConsume.htmlLabel = string.format( StrConfig['baojia012'], labelColor, itemName, itemNum );
	objSwf.txtMoney.htmlText = string.format( "<u><font color='#2f801f'>%s</font></u>", cfg.proce_money );
	objSwf.cbAutoBuy.selected = BaoJiaModel.autoBuy;
end

function UIBaoJiaLvlUp:ShowLvlUpEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:Hide();
	local winW,winH = UIManager:GetWinSize();
	local pos = {};
	pos.x = winW/2;
	pos.y = winH/2;
	--UIEffectManager:PlayEffect(ResUtil:GetJinJieSuccess(),pos);
end

function UIBaoJiaLvlUp:OnTipsAreaRollOver()
	local blessing = BaoJiaModel:GetBlessing();
	TipsManager:ShowBtnTips( string.format( StrConfig["baojia024"], blessing ) );
end

function UIBaoJiaLvlUp:OnTipsAreaRollOut()
	TipsManager:Hide();
end

function UIBaoJiaLvlUp:OnBtnCloseClick()
	self:Hide();
end

function UIBaoJiaLvlUp:OnBtnLvlUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local level = BaoJiaModel:GetLevel();
	local cfg = t_baojia[level];
	if not cfg then return; end
	local itemConsume = cfg.proce_consume;
	local itemId = itemConsume[1];
	local itemNum = itemConsume[2];
	
	if BaoJiaModel.autoBuy == 0 then
		if BagModel:GetItemNumInBag( itemId ) < itemNum then
			FloatManager:AddNormal( StrConfig["baojia022"], objSwf.btnLvlUp);
			return;
		end
	else
		local buymax = MallUtils:GetMoneyShopMaxNum(itemId);
		if BagModel:GetItemNumInBag( itemId ) + buymax < itemNum then
			FloatManager:AddNormal( StrConfig["baojia022"], objSwf.btnLvlUp);
			return;
		end
	end
	
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaBindGold + playerinfo.eaUnBindGold < cfg.proce_money then
		FloatManager:AddNormal( StrConfig["baojia021"], objSwf.btnLvlUp);
		return;
	end
	
	BaoJiaController:ReqBaoJiaLevelUp();
end

function UIBaoJiaLvlUp:OnBtnAutoLvlUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local level = BaoJiaModel:GetLevel();
	local cfg = t_baojia[level];
	if not cfg then return; end
	local itemConsume = cfg.proce_consume;
	local itemId = itemConsume[1];
	local itemNum = itemConsume[2];
	
	if BaoJiaModel.autoBuy == 0 then
		if BagModel:GetItemNumInBag( itemId ) < itemNum then
			FloatManager:AddNormal( StrConfig["baojia022"], objSwf.btnAutoLvlUp);
			return;
		end
	else
		local buymax = MallUtils:GetMoneyShopMaxNum(itemId);
		if BagModel:GetItemNumInBag( itemId ) + buymax < itemNum then
			FloatManager:AddNormal( StrConfig["baojia022"], objSwf.btnAutoLvlUp);
			return;
		end
	end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if playerinfo.eaBindGold + playerinfo.eaUnBindGold < cfg.proce_money then
		FloatManager:AddNormal( StrConfig["baojia021"], objSwf.btnAutoLvlUp);
		return;
	end
	
	BaoJiaController:SetAutoLevelUp(true);
	BaoJiaController:ReqBaoJiaLevelUp();
end

function UIBaoJiaLvlUp:OnBtnCancelAutoClick()
	BaoJiaController:SetAutoLevelUp(false);
end

function UIBaoJiaLvlUp:SwitchAutoLvlUpState(isAutoLvlUp)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btnAutoLvlUp._visible = not isAutoLvlUp;
	objSwf.btnCancelAuto._visible = isAutoLvlUp;
end

function UIBaoJiaLvlUp:OnBtnConsumeRollOver(e)
	local itemInfo = e.target.data;
	local itemId = itemInfo.itemId;
	if not itemId then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips( itemId, count );
end

function UIBaoJiaLvlUp:OnBtnConsumeRollOut()
	TipsManager:Hide();
end

function UIBaoJiaLvlUp:OnCBAutoBuySelect(e)
	BaoJiaModel.autoBuy = e.selected;
end

function UIBaoJiaLvlUp:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local numLoader = objSwf.proLoader;
	local bg = objSwf.posSign;
	numLoader._x = bg._x - numLoader._width * 0.5;
	numLoader._y = bg._y - numLoader._height * 0.5;
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIBaoJiaLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.BaoJiaUpdate,
		NotifyConsts.BaoJiaLevelUp,
		NotifyConsts.BaoJiaBlessing,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIBaoJiaLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.BaoJiaLevelUp then
		self:ShowLvlUpEffect();
	elseif name == NotifyConsts.BaoJiaUpdate then
		-- self:UpdateShow();
	elseif name == NotifyConsts.BaoJiaBlessing then
		self:ShowBlessing(true);
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:ShowConsume();
		end
	end
end