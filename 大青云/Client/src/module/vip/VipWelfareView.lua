--[[
VIP 福利面板
2015-7-24 16:56:53
haohu
]]
--------------------------------------------------------------

_G.UIVipWelfare = BaseUI:new("UIVipWelfare")
UIVipWelfare.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};
UIVipWelfare.currentShowLevel = 1

function UIVipWelfare:Create()
	self:AddSWF("vipWelfarePanel.swf", true, nil)
end

function UIVipWelfare:OnLoaded( objSwf )
	-- RewardManager:RegisterListTips( objSwf.weekRewardList )
	--RewardManager:RegisterListTips( objSwf.levelRewardList )
	objSwf.btnAcceptWeekReward.click = function() 
		VipController.isShowWeekEffect = true
		self:OnBtnAcceptWeekRewardClick() 
	end
	objSwf.btnAcceptLevelReward.click = function() 
		VipController.isShowLvEffect = true
		self:OnBtnAcceptLevelRewardClick() 
	end

	objSwf.levelRewardList.itemRollOver = function(e) self:OnItemRewardOver(e) end;
	objSwf.levelRewardList.itemRollOut = function() TipsManager:Hide() end;
	-- objSwf.levelList.dataProvider:cleanUp()
	-- for level = 1, VipConsts:GetMaxVipLevel() do
		-- objSwf.levelList.dataProvider:push( level )
	-- end
	-- objSwf.levelList:invalidateData()
	-- objSwf.levelList.itemClick = function(e) self:OnLevelItemClick(e) end	
	self:UpdateLevelList()
	for level = 1, VipConsts:GetMaxVipLevel() do
		objSwf['btnTabLv'..level].click = function(e) self:ShowWelfare( level ) 
													  self:SetLvlReward(level)
		end
		objSwf['btnTabLv'..level].label = 'VIP'..level		
	end
	-- objSwf.btnTabLv13.visible = false
	
		
end
function UIVipWelfare:showPoint()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, VipConsts:GetMaxVipLevel() do
		if VipModel:GetLevelRewardState( i ) then
			objSwf['btnTabLv'..i].redPoint._visible = false	
		else
			objSwf['btnTabLv'..i].redPoint._visible = VipController:GetVipLevel() >= i	
		
		end
	end
end
function UIVipWelfare:UpdateLevelList()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- for level = 1, 13 do
		-- objSwf['btnTabLv'..level].visible = false
	-- end
	local vipLevel = VipController:GetVipLevel()--MainPlayerModel.humanDetailInfo.eaVIPLevel;
	for level = 1, vipLevel do
		objSwf['btnTabLv'..level].visible = true	
	end
	if vipLevel >= 12 then
		objSwf.btnTabLv13.visible = true
	end
	for i = 1, VipConsts:GetMaxVipLevel() do
		objSwf['effectTabLv'..i]._visible = false		
		if VipController:GetVipLevel() >= i and not VipModel:GetLevelRewardState( i ) then
			objSwf['effectTabLv'..i]._visible = true
		end
	end
	self:showPoint()
end

function UIVipWelfare:OnShow()
--[[
	local weekRewardAccepted = VipModel:GetWeekRewardState()
	local defaultLevel -- 打开默认显示的等级
	if not weekRewardAccepted then
		-- 周礼包未领取时，每次打开UI，默认为当前可领的VIP周礼包页签(即当前等级)。
		defaultLevel = VipController:GetVipLevel()
	else
		-- 周礼包已领取时，每次打开UI，默认为当前VIP等级的下一级(即当前等级+1)。
		defaultLevel = math.min( VipController:GetVipLevel() + 1, VipConsts:GetMaxVipLevel() )
	end--]]
	
	self.objSwf.mcYilingqu1.visible = false
	self.objSwf.mcYilingqu2.visible = false
	self:AutoShowDefaultLevel()
	
	--屏蔽周礼包
	self.objSwf.txtVipWeek._visible = false
	self.objSwf.item1._visible = false
	self.objSwf.mcYilingqu2._visible = false
	self.objSwf.btnAcceptWeekReward._visible = false
	self.objSwf.effectAcceptWeekReward._visible = false
	self.objSwf.txtVipLevel._visible = false
	
end

function UIVipWelfare:AutoShowDefaultLevel()	
	local curLevel = VipController:GetVipLevel()
	local defaultLevel = VipModel:GetMinLevelReward() -- 打开默认显示的等级，优先显示当前可领奖的最低等级的页签
	local weekRewardAccepted = VipModel:GetWeekRewardState()
	if defaultLevel == -1 or defaultLevel > curLevel then--当前等级及一下已领显示下一等级的
		if weekRewardAccepted == 0 then
			defaultLevel = curLevel
		else
			defaultLevel = math.min( curLevel + 1, VipConsts:GetMaxVipLevel() )
		end
	end
	defaultLevel = math.max( defaultLevel, 1 )
	self:ShowWelfare( defaultLevel )
	self:SetLvlReward( defaultLevel );
end

function UIVipWelfare:ShowWelfare( vipLevel )
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = _G.t_vip[ vipLevel ]
	if not cfg then return end
	self:UpdateLevelList()
	objSwf['btnTabLv'..vipLevel].selected = true
	-- 等级列表
	-- 周奖励
	-- objSwf.txtWeekReward.text = string.format( "成为VIP%s每周可享受超值大礼", vipLevel )
	-- objSwf.weekRewardList.dataProvider:cleanUp()
	-- objSwf.weekRewardList.dataProvider:push( unpack( RewardManager:Parse( cfg.vip_week_reward ) ) )
	-- objSwf.weekRewardList:invalidateData()
	
	local weekRewardAccepted = VipModel:GetWeekRewardState()
	if weekRewardAccepted == -1 or weekRewardAccepted == 1 or VipController:GetVipLevel() ~= vipLevel then
		objSwf.btnAcceptWeekReward.disabled = true
	else
		objSwf.btnAcceptWeekReward.disabled = false
	end
	
	objSwf.mcYilingqu1:gotoAndStop(objSwf.mcYilingqu1._totalframes);	
	-- objSwf.mcYilingqu2:gotoAndStop(objSwf.mcYilingqu1._totalframes);
	-- objSwf.btnAcceptWeekReward.visible = true
	-- objSwf.effectAcceptWeekReward._visible = weekRewardAccepted == 0 and VipController:GetVipLevel() == vipLevel
	-- objSwf.mcYilingqu2._visible = false
	if weekRewardAccepted == 1 and  VipController:GetVipLevel() == vipLevel then
		-- objSwf.mcYilingqu2._visible = true
		-- objSwf.btnAcceptWeekReward.visible = false
		-- objSwf.effectAcceptWeekReward._visible = false
		if VipController.isShowWeekEffect then
			-- objSwf.mcYilingqu2:gotoAndPlay(1)
		else
			-- objSwf.mcYilingqu2:gotoAndStop(objSwf.mcYilingqu2._totalframes);		
		end
		VipController.isShowWeekEffect = false
	end
	-- 等级奖励
	-- objSwf.txtLevelReward.text = string.format( "成为VIP%s马上可以领取超值大礼", vipLevel )
	--objSwf.levelRewardList.dataProvider:cleanUp()
	local dwProf = MainPlayerModel.humanDetailInfo.eaProf
	--objSwf.levelRewardList.dataProvider:push( unpack( RewardManager:Parse( cfg['vip_lv_reward'..dwProf] ) ) )
	--objSwf.levelRewardList:invalidateData()
	objSwf.btnAcceptLevelReward.disabled = VipModel:GetLevelRewardState( vipLevel ) or VipController:GetVipLevel() < vipLevel
	objSwf.btnAcceptLevelReward.visible = true
	objSwf.effectAcceptLevelReward._visible = VipController:GetVipLevel() >= vipLevel
	objSwf.mcYilingqu1._visible = false
	if VipModel:GetLevelRewardState( vipLevel ) then
		objSwf.mcYilingqu1._visible = true
		objSwf.btnAcceptLevelReward.visible = false
		objSwf.effectAcceptLevelReward._visible = false
		if VipController.isShowLvEffect then
			objSwf.mcYilingqu1:gotoAndPlay(1)
		else
			objSwf.mcYilingqu1:gotoAndStop(objSwf.mcYilingqu1._totalframes);		
		end
		VipController.isShowLvEffect = false
	end
	
	-- 特权展示
	-- objSwf.txtPowerDisplay.text = string.format( "成为VIP%s还将可以享受超级特权", vipLevel )
	-- objSwf.txtVipLevel.text = 'VIP'..vipLevel..'即可领取全部奖励'
	-- objSwf.txtVipWeek.text = 'VIP'..vipLevel..'周礼包'
	
	--vip信息
	objSwf.load_info.source = ResUtil:GetVipInfoUrl(cfg.vip_infourl);
	objSwf.loadLevel.source = ResUtil:GetVipInfoUrl(cfg.vip_name);
	objSwf.load_Name.source = ResUtil:GetVipInfoUrl(cfg.vip_rewardname);
	--奖励标题和vip等级对齐
	self.loadLevelx = objSwf.loadLevel._x
	objSwf.load_Name.loaded = function()
		objSwf.load_Name._x = self.loadLevelx + objSwf.loadLevel.content._width/2 - objSwf.load_Name.content._width / 2
	end
	
	self.currentShowLevel = vipLevel
	
	local vipModel = cfg.vipShowModel
	if vipLevel == 11 then
		local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
		local modelList = split(cfg.vipShowModel, "#")
		vipModel = modelList[prof]
	end
	UIVipWelfare:Show3DWeapon(vipModel)
end

function UIVipWelfare:OnItemRewardOver(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if not e.item then return end;
	TipsManager:ShowItemTips(e.item.id);
end;

function UIVipWelfare:SetLvlReward(vipLevel)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local cfg = _G.t_vip[ vipLevel ]
	if not cfg then return end
	local dwProf = MainPlayerModel.humanDetailInfo.eaProf
	local uidata = split(cfg['vip_lv_reward'..dwProf],'#') 
	local panledata = {};
	for i,info in ipairs(uidata) do 
		local cfgu = split(info,",");
		local id = toint(cfgu[1]);
		local num = toint(cfgu[2]);
		local vo = {};
		vo.hasItem = true;
		vo.id =  id;
		if t_equip[id] then 
			local itemcfg = t_equip[id];
			vo.iconUrl = BagUtil:GetItemIcon(id,false);
			vo.qualityUrl = ResUtil:GetSlotQuality(itemcfg.quality);
			vo.quality = itemcfg.quality;
			vo.strenLvl = itemcfg.star
			vo.super = 0;
			if vo.quality == BagConsts.Quality_Green2 then
				vo.super = 2;
			elseif vo.quality == BagConsts.Quality_Green3 then
				vo.super = 3;
			end
			vo.showBind = vo.bind ==BagConsts.Bind_GetBind or vo.bind ==BagConsts.Bind_Bind;
		elseif t_item[id] then
			local itemcfg = t_item[id]
			vo.qualityUrl = ResUtil:GetSlotQuality(itemcfg.quality);
			vo.quality = itemcfg.quality;
			vo.count = num
			vo.iconUrl = BagUtil:GetItemIcon(id);
		end;
		table.push(panledata,UIData.encode(vo))
	end;
	objSwf.levelRewardList.dataProvider:cleanUp();
	objSwf.levelRewardList.dataProvider:push(unpack(panledata));
	objSwf.levelRewardList:invalidateData();
end;


function UIVipWelfare:OnLevelItemClick(e)
	self:ShowWelfare( e.item )
	self:SetLvlReward( e.item );
end

function UIVipWelfare:OnBtnAcceptWeekRewardClick()
	local weekRewardAccepted = VipModel:GetWeekRewardState()
	if weekRewardAccepted == 1 or weekRewardAccepted == -1 then 
		FloatManager:AddNormal(StrConfig['vip126'])
		return 
	end
	local currentLevel = VipController:GetVipLevel()
	if self.currentShowLevel < currentLevel then
		FloatManager:AddNormal(StrConfig['vip127'])
		return
	end
	if self.currentShowLevel > currentLevel then
		FloatManager:AddNormal(StrConfig['vip128'])
		return
	end
	VipController:ReqAcceptVipWeekReward()
	
	local rewardList = RewardManager:Parse(t_vip[currentLevel]['vip_week_reward']);
	self:GoRewardfun(StrConfig['vip129'], rewardList)
end

function UIVipWelfare:OnBtnAcceptLevelRewardClick()
	local levelRewardAccepted = VipModel:GetLevelRewardState( self.currentShowLevel )
	if levelRewardAccepted then return end
	local currentLevel = VipController:GetVipLevel()
	if self.currentShowLevel > currentLevel then
		FloatManager:AddNormal(StrConfig['vip128'])
		return
	end
	VipController:ReqAcceptVipLevelReward( self.currentShowLevel )
	
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local rewardList = RewardManager:Parse(t_vip[self.currentShowLevel]['vip_lv_reward'..prof]);
	self:GoRewardfun(StrConfig['vip130'], rewardList)
end

function UIVipWelfare:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.VipLevelRewardState,
		NotifyConsts.VipWeekRewardState,
	}
end

function UIVipWelfare:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:ShowWelfare( self.currentShowLevel )
			self:SetLvlReward( self.currentShowLevel);
			self:showPoint()
		end
	elseif name == NotifyConsts.VipLevelRewardState or name == NotifyConsts.VipWeekRewardState then
		-- self:ShowWelfare( self.currentShowLevel )
		UIVipWelfare:AutoShowDefaultLevel()
		self:showPoint()
	end				
end

function UIVipWelfare:OnHide()
	local name = 'UIVipWelfare'
	local objUIDraw = UIDrawManager:GetUIDraw(name);
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

function UIVipWelfare:OnDelete()
	-- local name = 'UIVipWelfare'
	-- local objUIDraw = UIDrawManager:GetUIDraw(name);
	-- if objUIDraw then
		-- objUIDraw:SetUILoader(nil);
	-- end
end

function UIVipWelfare:Show3DWeapon(modelId)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local cfg = t_vip[ self.currentShowLevel ]
	if not cfg then return end
	
	local loader = objSwf.roleLoader
	local name      = 'UIVipWelfare'
	if not self.objUIDraw then
		self.objUIDraw = UISceneDraw:new( name, loader, _Vector2.new(1800, 1200), true);
	end
	
	self.objUIDraw:SetUILoader( loader )
	
	local src = cfg.model_sen;
	
	if #split(cfg.model_sen,'#') > 1 then
	
		local prof = MainPlayerModel.humanDetailInfo.eaProf;
		src = split(cfg.model_sen,'#')[prof];
		
	end
	
	self.objUIDraw:SetScene(src);
	
	self.objUIDraw:SetDraw(true);
end

function UIVipWelfare:GoRewardfun(title, rewardList)
	UIRewardGetPanel:Open(title,nil,rewardList)

end;

-- VIP等级奖励：
-- 显示达到VIP等级后可领取的奖励。
-- 玩家VIP等级不足时，按钮置灰，点击时，在按钮处提醒玩家“提升VIP等级后可领取”
-- 当玩家VIP等级达到后，按钮变亮可点。
-- 已经领取的VIP奖励，按钮处变成：已领取的戳。

-- VIP周礼包：
-- 达到对应的 VIP等级后，每周可额外领取一次奖励。
-- 奖励随VIP等级变动，只能领取当前等级的VIP周礼包。可领时，亮态，按钮文字为：领取。领取后，变成戳“下周一重置”
-- 低于当前等级的周礼包按钮，按钮显示为：您有更高级的礼包可领。
-- 高于当前等级的周礼包按钮，按钮置灰，文字为：未达成，点击后，在按钮处提示玩家“提升VIP等级后可领取”
