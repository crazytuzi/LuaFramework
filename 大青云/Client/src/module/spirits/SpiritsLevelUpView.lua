--[[武魂界面主面板
liyuan
2014年9月28日10:35:06
]]

_G.UILevelUpSpirits = {}

-- UILevelUpSpirits.needItemId = -1
UILevelUpSpirits.lastBlessing = nil
UILevelUpSpirits.confirmUID = 0;
UILevelUpSpirits.isShowClearConfirm = true;
UILevelUpSpirits.isaotuup = false;--是否是自动进阶
function UILevelUpSpirits:OnLoaded(objSwf)
	self.objSwf = objSwf
	objSwf.btnStart.click = function() self:OnBtnStartClick() end
	objSwf.btnAuto.click = function() self:OnBtnAutoClick() end
	objSwf.labXiaohao.text = StrConfig["wuhun16"]
	objSwf.labyinliang.text = StrConfig["wuhun17"]
	objSwf.btnXiaohao.rollOver = function(e) self:OnJinjieItemOver(e); end
	objSwf.btnXiaohao.rollOut = function(e) self:OnJinjieItemOut(e); end
	objSwf.btnXiaohao.autoSize = true
	--objSwf.btnXiaohao.click = function() self:OnBtnXiaohaoClick(e) end
	objSwf.checkBoxAuto.select = function() SpiritsModel.isAutoBuy = objSwf.checkBoxAuto.selected end
	objSwf.lableYuanBao.rollOver = function() 
										TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown);
										end
	objSwf.lableYuanBao.rollOut = function() TipsManager:Hide(); end
	objSwf.lableYuanBao.autoSize = true
	
	objSwf.proLoader.loadComplete = function() self:OnNumLoadComplete(); end
	
	objSwf.siBlessing.tweenComplete  = function() self:OnSiBlessingTweenComplete() end -- 祝福值进度条缓动完成
	objSwf.tipsArea.rollOver = function() self:OnTipsAreaRollOver(); end
	objSwf.tipsArea.rollOut  = function() self:OnTipsAreaRollOut(); end	 
end

function UILevelUpSpirits:OnNumLoadComplete()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if not self:GetShowState() then return end
	local numLoader = objSwf.proLoader;
	local bg = objSwf.posSign;
	numLoader._x = bg._x - numLoader._width * 0.5;
	numLoader._y = bg._y - numLoader._height * 0.5;
end

function UILevelUpSpirits:OnShow(name)
	local objSwf = self.objSwf
	if not objSwf then 
		FPrint('找不到灵兽进阶UI')
		return 
	end
	objSwf._visible = true
	self:InitData()	
	SpiritsModel.isAutoLevelUp = false
	UIzhanshou:HideUPArrow()
	objSwf.btnAuto.label = UIStrConfig['wuhun16']
	self.isShowClearConfirm = true;
	self.isaotuup = false;
end

function UILevelUpSpirits:OnHide()
	SpiritsModel.isAutoLevelUp = false
	UIzhanshou:HideUPArrow()
	self.lastBlessing = nil
	local objSwf = self.objSwf;
	if not objSwf then 
		FPrint('找不到灵兽进阶UI')
		return 
	end
	objSwf._visible = false
	objSwf.btnAuto.label = UIStrConfig['wuhun16']
	if self.confirmUID > 0 then
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = 0;
	end
end

UILevelUpSpirits.lastSendTime = 0;

function UILevelUpSpirits:OnBtnStartClick()
	local objSwf = self.objSwf 
	if not objSwf then return end
	if not self:GetShowState() then return end

	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();

	SpiritsModel.isAutoLevelUp = false
	UIzhanshou:HideUPArrow()
	objSwf.btnAuto.label = UIStrConfig['wuhun16']
	self.isaotuup = false;
	self:OnLevelUP(objSwf.btnStart)
end

function UILevelUpSpirits:OnLevelUP(btnStart)
	local objSwf = self.objSwf 
	if not objSwf then return end
	if not self:GetShowState() then return end
	local wid = SpiritsModel:getWuhuVO().wuhunId
	local btn = btnStart or objSwf.btnAuto
	if not objSwf.checkBoxAuto.selected then
		if not self:CheckMoney(wid) then
			FloatManager:AddNormal(StrConfig['wuhun37'],objSwf.nsFeedNum)--金钱不足，无法进阶
			objSwf.btnAuto.label = UIStrConfig['wuhun16']
			SpiritsModel.isAutoLevelUp = false
			UIzhanshou:HideUPArrow()
			return
		end
		
		if self:CheckItem(wid) > 0 then
			FloatManager:AddNormal( StrConfig["wuhun34"], btn);
			-- UIShopQuickBuy:Open( t_wuhun[wid].proce_consume[1],UILevelUpSpirits, objSwf.childPanel, self:CheckItem(wid))
			objSwf.btnAuto.label = UIStrConfig['wuhun16']
			SpiritsModel.isAutoLevelUp = false
			UIzhanshou:HideUPArrow()
			return
		end
		
	end
	
	if not self:CheckMoney(wid) then
		FloatManager:AddNormal(StrConfig['wuhun37'],objSwf.nsFeedNum)--金钱不足，无法进阶
		objSwf.btnAuto.label = UIStrConfig['wuhun16']
		SpiritsModel.isAutoLevelUp = false
		UIzhanshou:HideUPArrow()
		return
	end
	
	--清空二次确认提示
	if self.isShowClearConfirm == true then
		local wuhunCfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
		if not wuhunCfg then return end
		if wuhunCfg then
			local isWishclear = wuhunCfg.is_wishclear
			if isWishclear then
				local confirmFunc = function()
					if self.isaotuup == true then
						SpiritsModel.isAutoLevelUp = true
						UIzhanshou:ShowUPArrow()
						objSwf.btnAuto.label = UIStrConfig['wuhun18']
					end
					SpiritsController:LevelUpWuhun(SpiritsModel:getWuhuVO().wuhunId, objSwf.checkBoxAuto.selected)
					self.isShowClearConfirm = false;
				end
				local nofun = function ()
					objSwf.btnAuto.label = UIStrConfig['wuhun16']
					SpiritsModel.isAutoLevelUp = false
					UIzhanshou:HideUPArrow()
				end
				if self.isaotuup == true then
					SpiritsModel.isAutoLevelUp = false
					UIzhanshou:HideUPArrow()
					objSwf.btnAuto.label = UIStrConfig['wuhun16']
				end
				self.confirmUID = UIConfirm:Open( StrConfig["realm48"], confirmFunc, nofun );
				return;
			end
		end
	end
	SpiritsController:LevelUpWuhun(SpiritsModel:getWuhuVO().wuhunId, objSwf.checkBoxAuto.selected)
end

function UILevelUpSpirits:OnBtnXiaohaoClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local wid = SpiritsModel:getWuhuVO().wuhunId
	-- UIShopQuickBuy:Open( t_wuhun[wid].proce_consume[1],UILevelUpSpirits, objSwf.childPanel, self:CheckItem(wid))
end

function UILevelUpSpirits:OnBtnAutoClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local wid = SpiritsModel:getWuhuVO().wuhunId
	if SpiritsModel.isAutoLevelUp == true then
		objSwf.btnAuto.label = UIStrConfig['wuhun16']
		SpiritsModel.isAutoLevelUp = false
		UIzhanshou:HideUPArrow()
		return
	end
	
	if not self:CheckMoney(wid) then
		FloatManager:AddNormal(StrConfig['wuhun37'],objSwf.nsFeedNum)--金钱不足，无法进阶
		objSwf.btnAuto.label = UIStrConfig['wuhun16']
		SpiritsModel.isAutoLevelUp = false
		UIzhanshou:HideUPArrow()
		return
	end
	
	SpiritsModel.isAutoLevelUp = true
	UIzhanshou:ShowUPArrow()
	objSwf.btnAuto.label = UIStrConfig['wuhun18']
	self.isaotuup = true;
	self:OnLevelUP(objSwf.btnAuto)
end

function UILevelUpSpirits:OnTipsAreaRollOver()
	if not self:GetShowState() then return end
	local wuhunCfg = t_wuhun[SpiritsModel:getWuhuVO().wuhunId]
	if not wuhunCfg then return end
	local isWishclear = wuhunCfg.is_wishclear
	local tipStr = StrConfig["wuhun26"]
	local zhufuzhi = SpiritsModel:getWuhuVO().wuhunWish
	
	if isWishclear then
		tipStr = StrConfig["wuhun27"]
	end

	TipsManager:ShowBtnTips( string.format(StrConfig["wuhun25"],zhufuzhi, tipStr));
end

function UILevelUpSpirits:OnTipsAreaRollOut()
	TipsManager:Hide();
end

--进阶消耗道具鼠标移上
function UILevelUpSpirits:OnJinjieItemOver(e)
	local itemInfo = e.target.data;
	if not itemInfo then return end
	local itemId = itemInfo.itemId;
	if not itemId or itemId == 0 then return; end
	local count = itemInfo.count;
	TipsManager:ShowItemTips( itemId, count );
end

--进阶消耗道具鼠标移出
function UILevelUpSpirits:OnJinjieItemOut(e)
	TipsManager:Hide();
end

---------------------------------ui逻辑------------------------------------

function UILevelUpSpirits:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self:GetShowState() then return end
	local blessing = SpiritsModel:getWuhuVO().wuhunWish
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	if not cfg then return; end
	local maxBlessing = cfg.wish_max;
	-- objSwf.proLoaderValue.num = blessing
	-- objSwf.proLoaderMax.num   = maxBlessing
	objSwf.proLoader:drawStr( tostring(blessing) );
	if self.lastBlessing then
		local blessingGain = blessing - self.lastBlessing;
		if blessingGain > 0 then
			FloatManager:AddNormal( string.format(StrConfig['wuhun38'], blessingGain ), objSwf.tipsArea );
		end
		objSwf.siBlessing:tweenProgress( blessing, maxBlessing, 0 );
	else
		objSwf.siBlessing:setProgress( blessing, maxBlessing );
	end
	
	self.lastBlessing = blessing;
	self:UpdateItemAndMoney()
	self:UpdateBtnEffect()
	self:ShowQingLingInfo();
end

-- function UILevelUpSpirits:CheckItem(wuhunId)
-- 	local cfg = t_wuhun[wuhunId]
-- 	local itemId = cfg.proce_consume[1]
-- 	local needItemNum = cfg.proce_consume[2]
	
-- 	if itemId and itemId ~= 0 then
-- 		local itemNum = BagModel:GetItemNumInBag(itemId)
-- 		if itemNum < needItemNum then
-- 			return needItemNum - itemNum
-- 		end
-- 	end
	
-- 	return 0
-- end

function UILevelUpSpirits:CheckItem(wuhunId)
	local itemId, needItemNum, isEnough = self:GetConsumeItem(wuhunId)
	if itemId and itemId ~= 0 then
		local itemNum = BagModel:GetItemNumInBag(itemId)
		if itemNum < needItemNum then
			return needItemNum - itemNum
		end
	end
	
	return 0
end

function UILevelUpSpirits:CheckMoney(wuhunId)
	local cfg = t_wuhun[wuhunId]
	local myMoney = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	if not cfg or cfg.proce_money > myMoney then
		return false
	end
	
	return true
end

-- function UILevelUpSpirits:UpdateItemAndMoney()
-- 	local objSwf = self.objSwf
-- 	if not objSwf then return end
-- 	if not self:GetShowState() then return end
-- 	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	
-- 	local cfg = t_wuhun[wuhunId]
-- 	self.needItemId = cfg.proce_consume[1]
-- 	local needItemNum = cfg.proce_consume[2]
-- 	local needMoney = cfg.proce_money
	
-- 	local colorStr = '#2FE00D'
-- 	if self.needItemId ~= 0 then
-- 		local itemCfg = t_item[tonumber(self.needItemId)]
		
-- 		local itemNum = BagModel:GetItemNumInBag(self.needItemId)
-- 		-- SpiritsUtil:Print(self.needItemId..':'..itemNum)
		
-- 		if itemNum < needItemNum then
-- 			colorStr = '#780000'
-- 		end
-- 		objSwf.btnXiaohao.txtXiaohao.htmlText = string.format(StrConfig["wuhun18"],colorStr,itemCfg.name,needItemNum);
-- 	else 
-- 		objSwf.btnXiaohao.txtXiaohao.text = ""
-- 	end
	
-- 	local myMoney = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
-- 	colorStr = '#2FE00D'
-- 	if needMoney > myMoney then
-- 		colorStr = '#780000'
-- 	end
	
-- 	objSwf.lableYuanBao.yuanBaoNum.htmlText = string.format(StrConfig["wuhun19"],colorStr,cfg.proce_money);
-- end

function UILevelUpSpirits:UpdateItemAndMoney()
	self:ShowConsumeMoney()
	self:ShowConsumeItem()
end

function UILevelUpSpirits:ShowConsumeMoney()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	if not cfg then return end
	local needMoney = cfg.proce_money
	local myMoney = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
	local colorStr = needMoney > myMoney and '#FF0000' or '#00FF00'	
	objSwf.lableYuanBao.htmlLabel = string.format(StrConfig["wuhun19"],colorStr,needMoney);
end

function UILevelUpSpirits:ShowConsumeItem()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local itemId, itemNum, isEnough = self:GetConsumeItem(wuhunId)
	if not itemId then return end
	if itemId ~= 0 then
		local itemCfg = t_item[itemId]
		local itemName = itemCfg and itemCfg.name or "something magic";
		local labelItemColor = isEnough and "#00FF00" or "#FF0000";
		objSwf.btnXiaohao.htmlLabel = string.format( StrConfig["wuhun18"], labelItemColor, itemName, itemNum );
	else 
		objSwf.btnXiaohao.htmlLabel = ""
	end
	objSwf.btnXiaohao.data = {itemId = itemId, count = itemNum};
end

function UILevelUpSpirits:GetConsumeItem(wuhunId)
	local cfg = t_wuhun[wuhunId]
	if not cfg then return end
	local itemConsume1 = cfg.proce_consume
	local itemConsume2 = cfg.proce_consume2
	local itemConsume3 = cfg.proce_consume3
	local hasEnoughItem = function( item, num )
		return BagModel:GetItemNumInBag( item ) >= num
	end
	local itemId, itemNum, isEnough
	if hasEnoughItem( itemConsume1[1], itemConsume1[2] ) then
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = true
	elseif hasEnoughItem( itemConsume2[1], itemConsume2[2] ) then
		itemId = itemConsume2[1]
		itemNum = itemConsume2[2]
		isEnough = true
	elseif hasEnoughItem( itemConsume3[1], itemConsume3[2] ) then
		itemId = itemConsume3[1]
		itemNum = itemConsume3[2]
		isEnough = true
	else
		itemId = itemConsume1[1]
		itemNum = itemConsume1[2]
		isEnough = false
	end
	return itemId, itemNum, isEnough
end

function UILevelUpSpirits:ShowQingLingInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.tfcleardata.htmlText = "";
	
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	local cfg = t_wuhun[wuhunId]
	if cfg.is_wishclear == true then
		objSwf.tfcleardata.htmlText = StrConfig["realm45"];
	end
end

--处理消息
function UILevelUpSpirits:HandleNotification(name, body)
	local objSwf = self.objSwf
	if not objSwf then return; end
	if not self:GetShowState() then return end
	if name == NotifyConsts.WuhunLevelUpUpdate then
		self:InitData() 
		if body.isSucc then 
			self:OnHide()
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold or body.type == enAttrType.eaLevel then
			self:ShowConsumeMoney()
			self:UpdateBtnEffect()
		end
	elseif name == NotifyConsts.BagItemNumChange then
		-- if self.needItemId == body.id then
			self:ShowConsumeItem()
			self:UpdateBtnEffect()
		-- end
	elseif name == NotifyConsts.WuhunLevelUpFail then
		local objSwf = self.objSwf 
		if not objSwf then return end
		
		objSwf.btnAuto.label = UIStrConfig['wuhun16']
	elseif name == NotifyConsts.PlayerModelChange then
		-- self:InitData()
	end
end

function UILevelUpSpirits:OnDelete()
	self.objSwf = nil
end

function UILevelUpSpirits:UpdateBtnEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local panelState = 2
	local lvlUpState = panelState == 2
	
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	
	local lvlUpConditionEnough = self:CheckMoney(wuhunId) and self:CheckItem(wuhunId) <= 0
	objSwf.btnLvlUpEff._visible = lvlUpState and lvlUpConditionEnough
	objSwf.btnAutoEff._visible  = lvlUpState and lvlUpConditionEnough
end

function UILevelUpSpirits:OnSiBlessingTweenComplete()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self:GetShowState() then return end
	local panelState = 2
	local lvlUpState = panelState == 2
	if lvlUpState then
		-- objSwf.shineEffect2:playEffect(1)
	end
end

function UILevelUpSpirits:GetShowState()
	return self.objSwf._visible
end







