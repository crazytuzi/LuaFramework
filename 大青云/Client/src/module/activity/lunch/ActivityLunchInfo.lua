--[[
	2016年8月17日, AM 11:39:11
	houxudong
	大摆筵席面板
]]
_G.UILunchInfo = BaseUI:new('UILunchInfo');

function UILunchInfo:Create()
	self:AddSWF("lunchInfo.swf", true, "bottom");
end

function UILunchInfo:OnLoaded(objSwf)
	objSwf.smallPanel.txt_curCombo.text = UIStrConfig['lunchcombo'];
	objSwf.smallPanel.txt_Rewardjiate.text = UIStrConfig['lunchjiate'];
	objSwf.smallPanel.NormalTaocan.text = UIStrConfig['lunchNormal'];
	objSwf.smallPanel.VipTaocan.text = UIStrConfig['lunchVip'];
	objSwf.smallPanel.reward1.text = UIStrConfig['lunchReward1'];
	objSwf.smallPanel.reward2.text = UIStrConfig['lunchReward2'];   
	-- objSwf.smallPanel.normalExpend.text = UIStrConfig['lunchexpend'];  
	-- objSwf.smallPanel.vipExpend.text = UIStrConfig['lunchVipFree'];  
	-- objSwf.smallPanel.tips.text = UIStrConfig['lunchtips']; 
	objSwf.smallPanel.totalReward.text = UIStrConfig['lunchTotalReward'];
	objSwf.smallPanel.txt_levelTime.text = UIStrConfig['lunchLevelTime'];
	objSwf.btnCommon.click = function () self:ChooseNormaLunch(); end
	objSwf.btnVip.click = function () self:ChooseVipLunch(); end
	objSwf.btn_quit.click = function () self:QuitActivityLunch(); end
	objSwf.btnOpen.click = function() self:OnBtnOpenClick(e) end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick(e) end
end

function UILunchInfo:OnShow()
	self:InitInfo()
	self:InitCostType();
	self:UpdateData()
	self:UpdateReward()
	self:StartTimer()
end

UILunchInfo.costItemNum =0;
UILunchInfo.needVipLevel =0;
UILunchInfo.costItemName = ""
function UILunchInfo:InitCostType( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	-- 套餐一
	local cfg = t_lunch[2];
	if not cfg then return end
	local costType = t_lunch[2].cost_type
	local cost= t_lunch[2].cost
	if not costType or not cost then return; end
	if costType == 1 then    --消耗物品
		self.costItemName = enAttrTypeName[toint(split(cost,',')[1])]
		self.costItemNum = toint(split(cost,',')[2])
		objSwf.smallPanel.normalExpend.htmlText = string.format(StrConfig['lunchexpend'],self.costItemName..getNumShow(self.costItemNum))
	elseif costType == 2 then  --消耗vip
		self.needVipLevel = toint(t_lunch[2].cost)
		objSwf.smallPanel.normalExpend.htmlText = string.format(StrConfig['lunchVipFree'],self.needVipLevel)
	elseif costType == 3 then  --无消耗
	end
	-- 套餐二
	local cfg = t_lunch[3];
	if not cfg then return end
	local costType = t_lunch[3].cost_type
	local cost= t_lunch[3].cost
	if not costType or not cost then return; end
	if costType == 1 then    --消耗物品
		self.costItemName = enAttrTypeName[toint(split(cost,',')[1])]
		self.costItemNum = toint(split(cost,',')[2])
		objSwf.smallPanel.vipExpend.htmlText = string.format(StrConfig['lunchexpend'],self.costItemName..getNumShow(self.costItemNum))
	elseif costType == 2 then  --消耗vip
		self.needVipLevel = toint(t_lunch[3].cost)
		objSwf.smallPanel.vipExpend.htmlText = string.format(StrConfig['lunchVipFree'],self.needVipLevel)
	elseif costType == 3 then  --无消耗
	end
end

--更新数据
function UILunchInfo:UpdateData()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local playerLv = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_lunchexp[playerLv]
	if not cfg then return; end
	objSwf.smallPanel.exp_add.text = ""
	-- objSwf.smallPanel.exp_xiuwei.text = "" 
	local reward1 = split(cfg.reward_1,',')[2]
	local reward2 = split(cfg.reward_2,',')[2]
	local reward3 = split(cfg.reward_3,',')[2]
	-- objSwf.smallPanel.exp_xiuwei.htmlText =string.format(StrConfig['lunchaddExp2'],0)
	--处理玩家选择套餐状态
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		objSwf.smallPanel.txt_choose.text = UIStrConfig['lunchChooseState'];  
		objSwf.smallPanel.taocan._visible = false;
		objSwf.NormalChoose._visible = false;
		objSwf.VIPChoose._visible = false;
		objSwf.smallPanel.exp_add.htmlText = string.format(StrConfig['lunchaddExp21'],reward1)--    StrConfig['lunchaddExp2']..reward1;
	elseif ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NormalChoose then
		objSwf.smallPanel.txt_choose._visible = false;
		objSwf.smallPanel.taocan._visible = true;
		objSwf.smallPanel.taocan.text = UIStrConfig['lunchNormal'];
		objSwf.NormalChoose.text = StrConfig['lunchChoosed'];
		objSwf.NormalChoose._visible = true;
		objSwf.VIPChoose._visible = false;
		local str = string.format(StrConfig['lunchaddExp2'],getNumShow(reward2-reward1))
		objSwf.smallPanel.exp_add.htmlText = reward1..str;
	else
		objSwf.smallPanel.txt_choose._visible = false; 
		objSwf.smallPanel.taocan.text = UIStrConfig['lunchVip'];
		objSwf.VIPChoose.text = StrConfig['lunchChoosed'];
		objSwf.smallPanel.taocan._visible = true;
		objSwf.NormalChoose._visible = false;
		objSwf.VIPChoose._visible = true;
		local str = string.format(StrConfig['lunchaddExp2'],getNumShow(reward3-reward1))
		objSwf.smallPanel.exp_add.htmlText = reward1..str;
	end
end

function UILunchInfo:UpdateReward()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local ExpReward = ActivityLunchModel:GetBackReward()
	objSwf.smallPanel.totalExp.htmlText = string.format(getNumShow(ExpReward))
	-- objSwf.smallPanel.totalxiuwei.htmlText = string.format(getNumShow(0))

end
------------------------时间处理------------------------
UILunchInfo.timerKey = nil;
UILunchInfo.time = 0;
function UILunchInfo:StartTimer()
	local func = function() self:OnTimer() end
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	self.time = activity:GetEndLastTime(); 
	self.timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()  						 --首先调用一次初始值
end

function UILunchInfo:OnTimer()
	self.time = self.time - 1
	if self.time <= 0 then
		self:StopTimer()
		return
	end
	self:UpdateCountDown()
end

function UILunchInfo:UpdateCountDown()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.smallPanel
	if not panel then return end
	local textField = panel.levelTime
	textField.htmlText = ActivityLunchUtil:ParseTime( self.time )
end

function UILunchInfo:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey )
		self.timerKey = nil
		self:UpdateCountDown()
	end
end

--------------------------------------------------------

function UILunchInfo:InitInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.smallPanel._visible = true;
	objSwf.btnOpen._visible = true
	objSwf.btn_quit._visible = true
	objSwf.btnCommon._visible = true
	objSwf.btnVip._visible = true
	objSwf.NormalChoose._visible = true;
	objSwf.VIPChoose._visible = true;
	objSwf.btnCloseState._visible = false
end

function UILunchInfo:OnBtnOpenClick(e)
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.smallPanel._visible = false;
	objSwf.btnCommon._visible = false;
	objSwf.btnVip._visible = false;
	objSwf.btnOpen._visible = false;
	objSwf.btn_quit._visible = false;
	objSwf.NormalChoose._visible = false;
	objSwf.VIPChoose._visible = false;
	objSwf.btnCloseState._visible = true
end

function UILunchInfo:OnBtnCloseClick(e)
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.smallPanel._visible = true;
	objSwf.btnOpen._visible = true;
	objSwf.btn_quit._visible = true;
	objSwf.btnCommon._visible = true;
	objSwf.btnVip._visible = true;
	objSwf.NormalChoose._visible = true;
	objSwf.VIPChoose._visible = true;
	objSwf.btnCloseState._visible = false;
end

function UILunchInfo:GetWidth()
	return 256;
end

function UILunchInfo:GetHeight()
	return 565;
end

--选择普通套餐
function UILunchInfo:ChooseNormaLunch()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		-- 普通套餐的消耗
		local costType,itemOrPlayerInfo,id,costName,needNum,needVipLevel = ActivityLunchUtil:CheckMealCost(2)
		-- 豪华套餐的消耗
		local _,_,_,_,_,needVipLevels = ActivityLunchUtil:CheckMealCost(3)
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;            --vip等级
		print(costType,itemOrPlayerInfo,id,costName,needNum,needVipLevel,needVipLevels,vipLevel)
		local func = function ()
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then      --消耗物品(属性)
				local currHave = 0
				if itemOrPlayerInfo then    --消耗属性
					currHave = MainPlayerModel.humanDetailInfo[id]
				else                        --消耗道具
					currHave = BagModel:GetItemInBag(id)
				end
				if currHave < needNum then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailMoney"],costName))
				    return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.NormalChoose)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then   --消耗vip等级
				if vipLevel < needVipLevel then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailVips"]))
					return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.NormalChoose)
			end
		end
		local str = "";
		if vipLevel >= needVipLevels and needVipLevels ~= 0 then
			str =string.format( StrConfig['lunchVipTips'], getNumShow(needNum))
		else
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then
				str = string.format(StrConfig["lunchNormalTips"],costName)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then
				str = string.format(StrConfig["lunchHaohuaVipTips"])
			end
		end
		UIConfirm:Open(str,func);
	end
end

--选择VIP套餐
function UILunchInfo:ChooseVipLunch()
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		-- 豪华套餐的消耗
		local costType,itemOrPlayerInfo,id,costName,needNum,needVipLevel = ActivityLunchUtil:CheckMealCost(3)
		local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
		local func = function ()
			if costType == ActivityLunchConsts.ITEM_COST_TYPE then      --消耗物品(属性)
				local currHave = 0
				if itemOrPlayerInfo then    --消耗属性
					currHave = MainPlayerModel.humanDetailInfo[id]
				else                        --消耗道具
					currHave = BagModel:GetItemInBag(id)
				end
				if currHave < needNum then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailMoney"],costName))
				    return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.VIPChoose)
			elseif costType == ActivityLunchConsts.VIP_COST_TYPE then   --消耗vip等级
				if vipLevel < needVipLevel then
					FloatManager:AddNormal(string.format(StrConfig["lunchFailVips"]))
					return
				end
				ActivityLunch:ChooseMealType(ActivityLunchConsts.VIPChoose)
			end
		end
		local str = ''
		if costType == ActivityLunchConsts.ITEM_COST_TYPE then
			str = string.format(StrConfig["lunchhaohuaTips"],costName)
		elseif costType == ActivityLunchConsts.VIP_COST_TYPE then
			str = string.format(StrConfig["lunchHaohuaVipTips"])
		end
		UIConfirm:Open(str,func)
	end
end

function UILunchInfo:OnHide()
	self:StopTimer()
end

function UILunchInfo:QuitActivityLunch()
	local func = function ()
		local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
		if not activity then return; end
		if activity:GetType() ~= ActivityConsts.T_Lunch then return; end
		ActivityController:QuitActivity(activity:GetId());
	end
	UIConfirm:Open(UIStrConfig['lunch102'],func);
end

function UILunchInfo:HandleNotification(name, body)
	if name == NotifyConsts.ChooseLunchSuc then
		self:UpdateData();
	elseif name == NotifyConsts.ChooseLunchFailMoney then
		FloatManager:AddNormal(StrConfig["lunchFailMoney"])
	elseif name == NotifyConsts.ChooseLunchFailVip then
		FloatManager:AddNormal(StrConfig["lunchFailVip"])
	elseif name == NotifyConsts.LunchBackExp then
		self:UpdateReward();
	end
end

--监听消息列表
function UILunchInfo:ListNotificationInterests()
	return { 
		NotifyConsts.ChooseLunchSuc,
		NotifyConsts.ChooseLunchFailMoney,
		NotifyConsts.ChooseLunchFailVip,
		NotifyConsts.LunchBackExp,
	};
end


------------------测试专用，后期删除------------------
-- function UILunchInfo:ShowNum(num)
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return; end
-- 	if num then
-- 		objSwf.smallPanel.testNum.text = num;
-- 	end
-- end