--[[
打宝塔副本面板
2016-5-17
chenyujia
]]

_G.UIYaotaInfo = BaseUI:new("UIYaotaInfo");

UIYaotaInfo.openState = false

function UIYaotaInfo:Create()
	self:AddSWF("yaotaDupPanel.swf", true, "bottom");
end

function UIYaotaInfo:OnLoaded(objSwf)
	self.openState = false
	self:RegisterEventHandler(objSwf);
	self:init()
end

function UIYaotaInfo:init()
	local mapId = CPlayerMap:GetCurMapID();
	self.id = ActivityUtils:GetYaotaId(mapId)
end

function UIYaotaInfo:RegisterEventHandler(objSwf)
	local UI = objSwf.rewardPanel
	UI.btn_cost.click        = function() self:OnBtnCostClick() end
	UI.btn_enter.click       = function() self:OnEnterBtnClick() end
	UI.btn_quit.click        = function() self:OnQuitBtnClick() end
	objSwf.btn_state.click = function () 
		if self.openState then
			objSwf.btn_state.selected = true;
			objSwf.rewardPanel._visible =  false;
		else
			objSwf.btn_state.selected = false;
			objSwf.rewardPanel._visible = true;
		end
		self.openState = not self.openState;
	end

	-- RewardManager:RegisterListTips(objSwf.rewardPanel.rewardList);
	objSwf.rewardPanel.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardPanel.rewardList.itemRollOut = function () TipsManager:Hide(); end
	RewardManager:RegisterListTips(objSwf.rewardPanel.costList);
end

function UIYaotaInfo:OnShow()
	local ns = self.objSwf.rewardPanel.numericStepper
	ns.maximum = UIYaota:getMaxValue()
	ns.minimum = 1

	self:StartTimer()
	self:ShowBossInfo()
	self:ShowCostInfo()
end

function UIYaotaInfo:GetWidth()
	return 254
end

function UIYaotaInfo:GetHeight()
	return 480
end

function UIYaotaInfo:OnQuitBtnClick()
	ActivityController:QuitActivity(ActivityConsts.XianYuan)
end

function UIYaotaInfo:OnEnterBtnClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf = objSwf.rewardPanel
	local num = objSwf.numericStepper.value;
	if t_yaota[tonumber(num)].limit_lv > MainPlayerModel.humanDetailInfo.eaLevel then
		FloatManager:AddNormal(StrConfig['yaota1'])
		return
	end
	local params = {param1 = tonumber(num)}
	ActivityController:EnterActivity(ActivityConsts.XianYuan, params)
end

function UIYaotaInfo:OnBtnCostClick()
	if UIYaota:GetItemCount() >= 3 then
		FloatManager:AddNormal(StrConfig['yaota2'])
		return
	end
	BagController:UseItemByTid(BagConsts.BagType_Bag, 180500301, 1)
end

function UIYaotaInfo:ShowCostInfo()
	local objSwf = self.objSwf
	if not self.objSwf then return end
	objSwf = objSwf.rewardPanel
	objSwf.txt_use.text = StrConfig['yaota3'] .. UIYaota:GetItemCount() .. "/3"

	local count = BagModel:GetItemNumInBag(180500301)
	objSwf.btn_cost.disabled = count <= 0
	local rewardItemList = RewardManager:Parse("180500301,"..count)
	local uiList = objSwf.costList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardItemList) )
	uiList:invalidateData()
end

function UIYaotaInfo:ShowBossInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf = objSwf.rewardPanel
	local bossInfo = t_yaota[self.id]
	if not bossInfo then
		Error("error  yao  ta  bossinfo for  index :", nIndex)
		return
	end
	local monsterCfg = t_monster[bossInfo.monster_id]
	if not monsterCfg then
		Error("error yao ta monster is miss for monster_id :", bossInfo.monster_id)
		return
	end
	objSwf.txt_index.num = self.id
	objSwf.txt_monster.text = monsterCfg.level

	local rewardItemList = RewardManager:Parse(bossInfo.item)
	local uiList = objSwf.rewardList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardItemList) )
	uiList:invalidateData()

	objSwf.numericStepper._value = tonumber(bossInfo.id)
	objSwf.numericStepper:updateLabel()
end

function UIYaotaInfo:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:ShowLastTime();
	end, 1000, 0 );
	self:ShowLastTime();
end

--每秒刷新 直接刷新显示时间
function UIYaotaInfo:ShowLastTime()
	--- 这里直接刷新倒计时显示
	local objSwf = self.objSwf
	if not objSwf then return end

	local mapId = CPlayerMap:GetCurMapID();
	local id = ActivityUtils:GetYaotaId(mapId)
	if id ~= self.id then
		self.id = id
		self:ShowBossInfo()
	end

	local time = UIYaota:GetLastTime()
	if time < 0 then time = 0 self:OnQuitBtnClick() end
	
	objSwf.rewardPanel.txt_time.text = PublicUtil:GetShowTimeStr(time)
end

function UIYaotaInfo:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIYaotaInfo:HandleNotification(name,body)
	if name == NotifyConsts.BagItemUseNumChange then
		if body.id == 180500301 then
			self:ShowCostInfo()
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self.objSwf.rewardPanel.numericStepper.maximum = UIYaota:getMaxValue()
			-- self.objSwf.numericStepper:updateLabel()
		end
	else
		self:ShowCostInfo()
	end
end
function UIYaotaInfo:ListNotificationInterests()
	return {
		NotifyConsts.ActivityOnLineTime,
		NotifyConsts.BagItemUseNumChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.PlayerAttrChange,
	}
end