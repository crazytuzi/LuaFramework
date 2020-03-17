--[[
流水副本 主面板
2015年6月24日15:33:30
haohu
]]

_G.UIWaterDungeon = BaseUI:new("UIWaterDungeon")

function UIWaterDungeon:Create()
	self:AddSWF( "waterDungeon.swf", true, "center" )
	-- self:AddChild( UIWaterDungeonRank, "rank" )
end

function UIWaterDungeon:OnLoaded( objSwf )
	self:Init( objSwf )
	--self:GetChild( "rank" ):SetContainer(objSwf.childPanel)
	objSwf.btnRank._visible = false
	objSwf.txtTimeRest._visible = false
	-- objSwf.costItem.disabled = true;
	-- objSwf.costItem._visible = false;
	-- objSwf.txtFight._visible = false
	objSwf.btnRank.click       = function() self:OnBtnRankClick() end
	objSwf.btnEnter.click      = function() self:OnBtnEnterClick() end
	-- objSwf.btnTest.click      = function() self:OnBtnTestClick() end
	objSwf.btnRule.rollOver    = function() self:OnBtnRuleRollOver() end
	objSwf.btnRule.rollOut     = function() self:OnBtnRuleRollOut() end
	objSwf.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut  = function() TipsManager:Hide(); end
	objSwf.expPanel._visible = false;
	objSwf.expPanel.btn_1.click = function () self:OnRewardClick(1); end
	objSwf.expPanel.btn_2.click = function () self:OnRewardClick(2); end

	objSwf.costItem.rollOver = function() self:OnCostrollOver(); end
	objSwf.costItem.rollOut = function() TipsManager:Hide(); end
	objSwf.btnEnter.labelID = ""
	objSwf.btnClose.click = function( ) self:OnBtnCloseClick() end
end

function UIWaterDungeon:Init( objSwf )
	objSwf.lblOpenTime.htmlText  = StrConfig['waterDungeon001']
	local openLevel = _G.t_funcOpen[FuncConsts.LiuShui].open_prama
	objSwf.lblCondition.htmlText = string.format( StrConfig['waterDungeon002'], openLevel )
end

function UIWaterDungeon:OnShow()
	WaterDungeonController:QueryWaterDungeonInfo()
	-- self:UpdateShow()
end

function UIWaterDungeon:InitLeftTimes( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local leftTime = WaterDungeonModel:GetLeftTime()
	local freeTimesCanUse =  WaterDungeonModel:GetDayFreeTime() or 0
	local dayPayTimesCanUse = WaterDungeonModel:GetDayPayTimeNew() or 0 
	local canEnterNum = freeTimesCanUse + dayPayTimesCanUse
	if leftTime > 0 and canEnterNum >0 then
		objSwf.txtleftTime.htmlText = string.format( StrConfig['waterDungeon503'], DungeonUtils:ParseTime(leftTime, false)) 
	elseif  leftTime <= 0 or canEnterNum <= 0 then
		objSwf.txtleftTime.htmlText = string.format( StrConfig['waterDungeon504']) 
	end
end

--//领取点击
function UIWaterDungeon:OnRewardClick(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_consts[94];
	if not cfg then return end
	local btnCfg = split(cfg.param,'#');
	local getNum = 0;
	local strType = '';
	local val = 0;
	
	if state == 1 then  --1.2倍领取
		getNum = tonumber(split(btnCfg[1],',')[1])
		strType = enAttrTypeName[tonumber(split(btnCfg[1],',')[2])];
		val = toint(split(btnCfg[1],',')[3])
		local func = function ()
			WaterDungeonController:SendWaterDungeonReward(2);
		end
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = UIConfirm:Open(string.format(StrConfig['waterDungeon410'],val,strType,getNum),func);
	elseif state == 2 then --1.5倍领取
		getNum = tonumber(split(btnCfg[2],',')[1])
		strType = enAttrTypeName[tonumber(split(btnCfg[2],',')[2])];
		val = toint(split(btnCfg[2],',')[3])
		local func = function ()
			WaterDungeonController:SendWaterDungeonReward(3);
		end
		UIConfirm:Close(self.confirmUID);
		self.confirmUID = UIConfirm:Open(string.format(StrConfig['waterDungeon410'],val,strType,getNum),func);
	else
		return;
	end
end

function UIWaterDungeon:OnHide()
	self:UnRegisterTimers()
	UIConfirm:Close(self.confirmUID);
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
end

function UIWaterDungeon:GetWidth()
	return 1146
end

function UIWaterDungeon:GetHeight()
	return 681
end

function UIWaterDungeon:IsTween()
	return true
end

function UIWaterDungeon:IsShowSound()
	return true
end

function UIWaterDungeon:UpdateShow()
	self:ShowBestExp()
	self:ShowBestWave()
	-- self:ShowFight()
	self:ShowTimeRest()
	self:ShowReward()
	self:UnRegisterTimers()
	self:UpdateDownTime()
end

--最佳经验
function UIWaterDungeon:ShowBestExp() 
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.expPanel._visible = false;
	objSwf.expPanel.txt_info.text = StrConfig['waterDungeon017'];
	-- objSwf.txtMaxExp.htmlText = string.format( StrConfig['waterDungeon016'] )
	objSwf.txt_jinggao.text = StrConfig['waterDungeon450'];
	local numStr = _G.getNumShow( WaterDungeonModel:GetBestExp(), true )
	-- objSwf.txtMaxExpNum.htmlText = string.format( StrConfig['waterDungeon018'], WaterDungeonModel:GetBestExp() )
	-- local numStr = _G.getNumShow( WaterDungeonModel:GetBestExp(), true )
	objSwf.txtMaxExpNum:drawStr( numStr )
end

--最佳波数
function UIWaterDungeon:ShowBestWave()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.txtWave.htmlText = string.format( StrConfig['waterDungeon004'], WaterDungeonModel:GetBestWave() )
end

--当前战斗力
function UIWaterDungeon:ShowFight()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local fight = MainPlayerModel.humanDetailInfo.eaFight
	-- if fight <0 then
	-- 	fight = 0
	-- end
	-- objSwf.txtFight.htmlText = string.format( StrConfig['waterDungeon015'],fight)
end

function UIWaterDungeon:OnCostrollOver( )
	if not self.itemId then return; end
	TipsManager:ShowItemTips(self.itemId);
end

UIWaterDungeon.itemId = nil;
function UIWaterDungeon:ShowTimeRest()
	local objSwf = self.objSwf
	if not objSwf then return end
	local textField = objSwf.txtTimeRest
	local enterTxt = objSwf.txtFight
	local costItemNeedVip = true                                    --消耗物品时需要vip
	local totalEnterNum = WaterDungeonConsts:GetDailyAllTime()      --总次数
	local dayFreeTimes = WaterDungeonConsts:GetDailyFreeTime()      --免费总次数
	local timePerDay = WaterDungeonConsts:GetDailyPayTimes()        --每日付费总次数

	local dayilyUseTimes =  WaterDungeonModel:GetTimeUsed() or 0      --每日已经使用次数
	local freeTimesCanUse =  WaterDungeonModel:GetDayFreeTime() or 0    --剩余免费次数
	local dayPayTimesCanUse = WaterDungeonModel:GetDayPayTimeNew() or 0 --剩余付费次数

	local canEnterNum = freeTimesCanUse + dayPayTimesCanUse
	local itemId, itemNum = WaterDungeonConsts:GetEnterItem()
	local itemCfg = t_item[itemId]
	self.itemId = itemId;
	local itemName = itemCfg and itemCfg.name or "missing"
	local isGodVip = VipController:IsDiamondVip()              --是不是钻石vip类型
	local vipgrade = VipController:GetVipLevel()               --vip等级
	local itemCondition,vipCondition = false,false
	for i=1,toint(timePerDay) do
		if i * itemNum <= BagModel:GetItemNumInBag( itemId ) then
			itemCondition = true	
		end
	end
	if costItemNeedVip then
		if isGodVip then
			vipCondition = true
		else
			vipCondition = false
		end
	end
	if freeTimesCanUse > 0 then
		objSwf.costItem._visible = false
	else
		objSwf.costItem._visible = true
	end
	local color = (canEnterNum > 0) and "#00FF00" or "#FF0000";
	local itemColor = (itemCondition == true) and "#00FF00" or "#FF0000";
	enterTxt.htmlText = string.format(StrConfig['waterDungeon010'], color, canEnterNum, totalEnterNum)
	objSwf.costItem.htmlLabel = string.format( "<font color='#ffffff'>成为钻石VIP后可消耗<font color='%s'><u>%s</u></font>进入</font>", itemColor, itemName)

end

UIWaterDungeon.CdTimekey = nil
function UIWaterDungeon:UpdateDownTime( )
	local objSwf  = self.objSwf;
	if not objSwf then return; end
	local itemId, itemNum = WaterDungeonConsts:GetEnterItem()
	local leftTime = WaterDungeonModel:GetLeftTime()                --获得剩余的CD时间
	local freeTimesCanUse =  WaterDungeonModel:GetDayFreeTime() or 0   
	local dayPayTimesCanUse = WaterDungeonModel:GetDayPayTimeNew() or 0 
	local canEnterNum = freeTimesCanUse + dayPayTimesCanUse
	if canEnterNum <= 0 then return end
	if leftTime <= 0 then return end
	-- if not itemId and not itemNum then
		self.CdTimekey = TimerManager:RegisterTimer(function()
			leftTime = leftTime - 1;
			local timess = DungeonUtils:ParseTime(leftTime, false);
			objSwf.txtleftTime.htmlText = string.format( StrConfig['waterDungeon503'], DungeonUtils:ParseTime(leftTime, false));
			if leftTime <= 0 then
				objSwf.txtleftTime.htmlText = string.format( StrConfig['waterDungeon504']);
				self:UnRegisterTimers()
				WaterDungeonModel:SetLeftTime(0)
				return;
			end
		end,1000,0);
	-- end
end

function UIWaterDungeon:UnRegisterTimers( )
	if self.CdTimekey then
		TimerManager:UnRegisterTimer(self.CdTimekey)
		self.CdTimekey = nil;
	end
end

--经验损失面板
function UIWaterDungeon:ShowLossExp()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local lossExp = WaterDungeonModel:GetLossExp();
	if not lossExp or lossExp < 1 then objSwf.expPanel._visible = false; return end
	-- objSwf.expPanel._visible = true;
	objSwf.expPanel._visible = false;
	objSwf.expPanel.numExp.num = lossExp;
end

function UIWaterDungeon:ShowReward()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local slotVO = RewardSlotVO:new()
	-- slotVO.id    = WaterDungeonConsts.uiExpItemId
	-- slotVO.count = 0
	-- slotVO.bind  = BagConsts.Bind_Bind
	-- objSwf.rewardItem:setData( slotVO:GetUIData() )

	--暂时屏蔽奖励这一块
	-- local rewardList = RewardManager:Parse(WaterDungeonConsts:GetReward( ));
	-- objSwf.rewardList.dataProvider:cleanUp();

	--[[
	objSwf.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardList:invalidateData();
	--]]
end

function UIWaterDungeon:OnBtnCloseClick()
	self:Hide()
end

function UIWaterDungeon:OnBtnRankClick()
	if UIWaterDungeonRank:IsShow() then
		UIWaterDungeonRank:Hide()
	else
		UIWaterDungeonRank:Show()
	end
end

function UIWaterDungeon:OnBtnEnterClick()
	-- 判断组队状态
	WaterDungeonController:EnterWaterDungeon()
end

-- function UIWaterDungeon:OnBtnTestClick()
-- 	UIWaterDungeonResult:Open( 5, 150000)
-- end

function UIWaterDungeon:OnBtnRuleRollOver()
	TipsManager:ShowBtnTips( StrConfig['waterDungeon006'], TipsConsts.Dir_RightDown )
end

function UIWaterDungeon:OnBtnRuleRollOut()
	TipsManager:Hide()
end

function UIWaterDungeon:OnRewardRollOver()
	TipsManager:ShowItemTips( WaterDungeonConsts:GetReward( ) )
end

function UIWaterDungeon:OnRewardRollOut()
	TipsManager:Hide()
end

function UIWaterDungeon:IsShowLoading()
	return true;
end

function UIWaterDungeon:GetPanelType()
	return 1;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIWaterDungeon:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.WaterDungeonBestWave,
		NotifyConsts.WaterDungeonBestExp,
		NotifyConsts.WaterDungeonTimeUsed,
		NotifyConsts.WaterDungeonLossExp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.RefreshWaterdata,
	}
end

--处理消息
function UIWaterDungeon:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaFight then
			-- self:ShowFight()
		end
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:ShowTimeRest()
	elseif name == NotifyConsts.WaterDungeonBestWave then 
		self:ShowBestWave(body)
	elseif name == NotifyConsts.WaterDungeonBestExp then
		self:ShowBestExp()
	elseif name == NotifyConsts.WaterDungeonTimeUsed then
		self:ShowTimeRest()
	elseif name == NotifyConsts.WaterDungeonLossExp then
		self:ShowLossExp()
	elseif name == NotifyConsts.RefreshWaterdata then
		self:InitLeftTimes()
		self:UpdateShow()
	end
end