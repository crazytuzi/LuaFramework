--[[
UI:物品类Tips
lizhuangzhuang
2014年7月24日21:24:50
]]

_G.UITipsTool = BaseUI:new("UITipsTool");

UITipsTool.tipsInfo = nil;
UITipsTool.tipsDir = nil;
UITipsTool.target = nil;
UITipsTool.compareTipsInfo = nil;--对比信息

function UITipsTool:Create()
	self:AddSWF("tipsTool.swf",true,"float");
end

function UITipsTool:OnLoaded(objSwf)
	objSwf.panel.tipsQualityLoader.loaded = function() self:OnTipsQualityLoaded(objSwf.panel.tipsQualityLoader); end
	objSwf.comparePanel.tipsQualityLoader.loaded = function() self:OnTipsQualityLoaded(objSwf.comparePanel.tipsQualityLoader); end
	objSwf.hitTestDisable = true	
end

function UITipsTool:NeverDeleteWhenHide()
	return true;
end

function UITipsTool:IsTween()
	return false;
end

function UITipsTool:OnShow()
	if not self.tipsInfo then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--显示Tips
	local panel = objSwf.panel;
	self:SetPanelInfo(panel,self.tipsInfo);
	self.width = self.tipsInfo.width;
	self.height = panel.bg._height + 34;
	--显示对比信息
	local comparePanel = objSwf.comparePanel;
	if self.compareTipsInfo then
		comparePanel._visible = true;
		--changer：houxudong date:2016/8/15 15:49:25
		--reason:调整比较面板的位置
		comparePanel._x = self.tipsInfo.width - 33;   
		self:SetPanelInfo(comparePanel,self.compareTipsInfo);
		self.width = self.width + self.compareTipsInfo.width;
		if comparePanel.bg._height > self.height then
			self.height = comparePanel.bg._height;
		end
	else
		comparePanel._visible = false;
	end
	--
	local tipsX,tipsY = TipsUtils:GetTipsPos(self.width,self.height,self.tipsDir);
	objSwf._x = tipsX;
	objSwf._y = tipsY;
	--
	local tipsInfo = self.tipsInfo;
	local compareTipsInfo = self.compareTipsInfo;
	self:DrawModel(panel,tipsInfo);
	if compareTipsInfo then
		self:DrawModel(comparePanel,compareTipsInfo);
	end
end

function UITipsTool:OnHide()
	if self.tipsInfo and self.tipsInfo.modelDraw then
		local modelDraw = self.tipsInfo.modelDraw
		self.tipsInfo.modelDraw = nil
		self.tipsInfo = nil
		modelDraw:Exit();
	end
	if self.compareTipsInfo and self.compareTipsInfo.modelDraw then
		local modelDraw = self.compareTipsInfo.modelDraw
		self.compareTipsInfo.modelDraw = nil
		self.compareTipsInfo = nil;
		modelDraw:Exit();
	end
end

function UITipsTool:OnTipsQualityLoaded(uiLoader)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsQualityEffect = uiLoader.content.effect;
	if tipsQualityEffect then
		tipsQualityEffect._x = 0;
		tipsQualityEffect._y = 48;
		tipsQualityEffect:playEffect(0);
	end
end

function UITipsTool:DrawModel(panel,tipsInfo)
	if tipsInfo.modelDraw then
		tipsInfo.modelDraw:Enter(panel.modelloader,unpack(tipsInfo.modelDrawArgs));
		self.loaderPosy = panel.modelloader._y
		if tipsInfo.showType == TipsConsts.Type_NewTianshen then
			panel.modelloader._y = self.loaderPosy - 90
		else
			panel.modelloader._y = self.loaderPosy
		end
	end
end

--设置面板信息
--changer：houxudong date:2016/8/15 15:53:25
--reason:调整比较面板的位置
function UITipsTool:SetPanelInfo(panel,tipsInfo)
	panel.effectBg.liuguang._visible = false
	panel.effectBg.liuguangMc._visible = false
	panel.effectBg.bg._visible = false
	panel.NameIconBg._visible = false
	
	panel.tfTips._width = tipsInfo.width - 50;
	panel.tfTips.htmlText = tipsInfo.tipsStr;
	panel.tfTips._height = panel.tfTips.textHeight + 17;
	panel.bg._height = panel.tfTips.textHeight + 23; 
	panel.bg._width = tipsInfo.width -30.3 ;
	-- panel.titleBg._width = tipsInfo.width -30 ;
	panel.titleBg._visible = false ;
	--品质框加载处理
	local qualityLoader = panel.icon.qualityLoader;
	if not qualityLoader.loaded then
		qualityLoader.loaded = function()
			local effect = qualityLoader.content.slotQuality;
			if effect then
				effect._x = 28;
				effect._y = 28.3;
				-- effect:playEffect(0);
			end
		end
	end
	
	if tipsInfo.showIcon then
		panel.icon._visible = true;
		panel.icon.loader:load(tipsInfo.iconUrl);
		panel.icon.mcEquip._visible =  tipsInfo.showEquiped			--tipsInfo.showEquiped;  --干掉他、、、、

		--标识
		if tipsInfo.showBiao and tipsInfo.showBiao ~= "" then
			panel.icon.mcBiao.source = tipsInfo.showBiao
			panel.icon.mcBiao._visible = true;
			if panel.bg._width < 320 then 
				panel.icon.mcBiao._x = 180;
				panel.icon.mcBiao._y = 49;
			else
				panel.icon.mcBiao._x = 266;
				panel.icon.mcBiao._y = 88;
			end;
		else
			panel.icon.mcBiao._visible = false;
		end
		--图标等阶
		if tipsInfo.iconLevelUrl and tipsInfo.iconLevelUrl ~= "" then
			if panel.icon.levelLoader.source ~= tipsInfo.iconLevelUrl then
				panel.icon.levelLoader.source = tipsInfo.iconLevelUrl;
			end
		else
			panel.icon.levelLoader:unload();
			panel.icon.levelLoader.source = nil;
		end
		
		if tipsInfo.showEquiped then
			-- if panel.bg._height > 428 then
			-- 	panel.icon.mcEquip._y = 148;  --135
			-- else
			-- 	panel.icon.mcEquip._y = panel.bg._height-320;  --170
			-- end
			local iconY = panel.icon.qualityK._y
			if SmithingModel:GetMaxStarCount(tipsInfo.modelDrawArgs[1]) == 0 then
				panel.icon.mcEquip._y = iconY + 101
			else
				panel.icon.mcEquip._y = iconY + 145
			end
		else
			panel.icon.mcEquip._y = 48;
		end
		panel.icon._x = tipsInfo.iconPos.x;
		panel.icon._y = tipsInfo.iconPos.y+24;
		
		-- print('=========================panel.bg._width',panel.bg._width)
		if panel.bg._width>390 and  panel.bg._width<391 then--装备tips的背景特效
			panel.effectBg.liuguang._visible = true
			panel.effectBg.liuguangMc._visible = true
			panel.effectBg.bg._visible = true
			if tipsInfo.quality == 3 then--品质3的装备有名字背景
				panel.NameIconBg._visible = true
			end
		end
		
		local lv = split(t_consts[321].param,",")
		local lvEffect = tonumber(lv[1])
		
		if tipsInfo.quality < lvEffect then--品质6,7，的装备在tips左右两侧增加流光特效
			panel.effectBg.liuguang._visible = false
		end
		if tipsInfo.quality < 5 then--品质为5,6,7，的装备背景图上增加特效底图显示，暂时没有装备品质为4
			panel.effectBg.liuguangMc._visible = false
			panel.effectBg.bg._visible = false
		end
		
		if tipsInfo.qualityUrl ~= "" then
			if qualityLoader.source ~= tipsInfo.qualityUrl then
				qualityLoader.source = tipsInfo.qualityUrl;
			end
		else
			qualityLoader:unload();
			qualityLoader.source = nil;
		end

		if tipsInfo.quality >= 0 then
			panel.icon.qualityBg._visible = true;
			panel.icon.qualityBg:gotoAndStop(tipsInfo.quality+1);
			panel.icon.qualityK._visible = true;
			panel.icon.qualityK:gotoAndStop(tipsInfo.quality+1);
		else
			panel.icon.qualityBg._visible = false;
			panel.icon.qualityBg:stop();
			panel.icon.qualityK._visible = false;
			panel.icon.qualityK:stop();
		end
		if tipsInfo.superStar > 0 then
			panel.icon.mcSuper._visible = true;
			panel.icon.mcSuper:gotoAndStop(tipsInfo.superStar);
		else
			panel.icon.mcSuper._visible = false;
		end
	else
		panel.icon._visible = false;
	end
	if tipsInfo.showType == TipsConsts.Type_NewTianshen and tipsInfo.quality > 2 then
		--天神卡显示流光
		panel.effectBg.liuguang._visible = true
		panel.effectBg.liuguangMc._visible = true
		panel.effectBg.bg._visible = true
	end
	--tips 特效底纹
	local tipsEffectUrl = tipsInfo.tipsEffectUrl;
	if tipsEffectUrl and tipsEffectUrl ~= "" then
		if panel.tipsQualityLoader.source ~= tipsEffectUrl then
			panel.tipsQualityLoader.source = tipsEffectUrl;
		end
	else
		panel.tipsQualityLoader:unload();
		panel.tipsQualityLoader.source = nil;
	end
	if tipsInfo.relicIcon then
		if panel.relicloader.source ~= tipsInfo.relicIcon then
			panel.relicloader.source = tipsInfo.relicIcon
		end
		panel.relicloader._visible = true
	else
		panel.relicloader._visible = false
	end
end

function UITipsTool:Update()
	if not self.bShowState then return; end
	if self.tipsInfo and self.tipsInfo.modelDraw then
		self.tipsInfo.modelDraw:Update();
	end
	if self.compareTipsInfo and self.compareTipsInfo.modelDraw then
		self.compareTipsInfo.modelDraw:Update();
	end
end

function UITipsTool:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local tipsX,tipsY = TipsUtils:GetTipsPos(self.width,self.height,self.tipsDir);
		objSwf._x = tipsX;
		objSwf._y = tipsY;
	elseif name == NotifyConsts.StageClick then
		if isDebug then
			if _sys:isKeyDown(_System.KeyShift) then
				if self.tipsInfo and self.tipsInfo.debugInfo then
					UIChat:AddSend(self.tipsInfo.debugInfo);
				end
				return
			end
		end
		if self.tipsInfo and self.tipsInfo.itemID then
			local itemID = self.tipsInfo.itemID
			if itemID == 92 then
				--试炼积分
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Babel)
			elseif itemID == 51 then
				--荣誉 51
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Honor)
			elseif itemID == 81 then
				-- 帮贡 81
				UIShopCarryOn:OpenShopByType(ShopConsts.T_Guild)
			elseif itemID == 13 then
				--绑元
				-- UIShoppingMall:Show()
				UIShoppingMall:OpenPanel(3)
			elseif itemID == 12 then
				--元宝
				-- UIShoppingMall:Show()
				UIShoppingMall:OpenPanel(2)
			elseif itemID > 999 then
				if not UIShoppingMall:IsShow() then
					UIQuickBuyConfirm:Open(nil,itemID)
				end
			end
		end
	end
end

function UITipsTool:ListNotificationInterests()
	return {NotifyConsts.StageMove,NotifyConsts.StageClick};
end

--显示Tips
--@param tipsInfo	tips信息
function UITipsTool:ShowTips(tipsInfo,tipsDir,compareTipsInfo)
	if not tipsInfo then
		return;
	end
	--
	self:OnHide();
	self.tipsInfo = tipsInfo;  ---tips信息
	self.tipsDir = tipsDir;
	self.compareTipsInfo = compareTipsInfo;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end