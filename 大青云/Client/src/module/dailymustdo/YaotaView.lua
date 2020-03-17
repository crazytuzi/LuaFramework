--[[
打宝塔面板
2016-5-17
chenyujia
]]

_G.UIYaota = BaseUI:new("UIYaota");

UIYaota.timerKey = nil;

UIYaota.showList = nil;

UIYaota.showIndex = nil;

UIYaota.nLastTime = 0;

UIYaota.nCount = 0;

UIYaota.nStartTime = 0;

function UIYaota:Create()
	self:AddSWF("yaotaPanel.swf", true, "center");
end

function UIYaota:OnLoaded(objSwf)
	self:RegisterEventHandler(objSwf);
end

function UIYaota:RegisterEventHandler(objSwf)
	objSwf.btn_close.click       = function() self:Hide() end
	objSwf.btn_cost.click        = function() self:OnBtnCostClick() end
	objSwf.bossList.change 		 = function() self:OnBossChange() end
	objSwf.btn_enter.click       = function() self:OnEnterBtnClick() end
	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end
	-- objSwf.numericStepper.change = function(e) self:OnNsChange(e); end

	-- RewardManager:RegisterListTips(objSwf.rewardList);
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end

	objSwf.txt_diaoluo.htmlText = StrConfig['yaota7']

	objSwf.tfNeedItem.rollOver = function(e) TipsManager:ShowItemTips(180500301); end
	objSwf.tfNeedItem.rollOut = function(e) TipsManager:Hide() end
	
	objSwf.btnRule.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["yaota8"],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function(e) TipsManager:Hide(); end
	-- RewardManager:RegisterListTips(objSwf.costList);
end

--- 这里在初始化的时候可以直接处理显示列表 以及初次应该显示的索引
function UIYaota:init()
	self.showList = {}
	self.showIndex = #t_yaota
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local table_insert = table.insert
	for i, v in ipairs(t_yaota) do
		table_insert(self.showList, 1, v)
		if v.limit_lv <= myLevel then
			self.showIndex = #t_yaota - i + 1
		end
	end
end

function UIYaota:OnBtnPreClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numBoss = list.dataProvider.length
	self.lastFumoOldLV = -2;
	if list.scrollPosition > 0 then
		list.scrollPosition = list.scrollPosition - 1
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + list.rowCount - 1 )
	elseif list.selectedIndex > 0 then
		list.selectedIndex = list.selectedIndex - 1
	end
end

function UIYaota:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.bossList
	local numBoss = list.dataProvider.length
	self.lastFumoOldLV = -2;
	if list.scrollPosition < numBoss - list.rowCount then
		list.scrollPosition = list.scrollPosition + 1
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition )
	elseif list.selectedIndex < numBoss - 1 then
		list.selectedIndex = list.selectedIndex + 1
	end
end

function UIYaota:OnShow()
	--- 在这里直接把层数控件最小值与最大值写死
	local objSwf = self.objSwf
	if not objSwf then return end
	self:init()
	local ns = objSwf.numericStepper
	ns.maximum = UIYaota:getMaxValue()
	ns.minimum = 1

	self:ShowBossList(true)
	self:StartTimer()
	self:ShowBossInfo()
	self:ShowCostInfo()
	self:DrawBoss()
	ActivityController:SendActivityOnLineTime(ActivityConsts.XianYuan);
end

function UIYaota:ShowCostInfo()
	local objSwf = self.objSwf
	if not self.objSwf then return end

	objSwf.txt_use.text = StrConfig['yaota3'] ..self:GetItemCount() .. "/3"
	local count = BagModel:GetItemNumInBag(180500301)
	objSwf.btn_cost.disabled = count <= 0
	local color = count < 1 and "#FF0000" or "#00FF00";
	objSwf.tfNeedItem.htmlLabel = string.format( "<font color = '%s'>%s</font>", color, t_item[180500301].name);
end

function UIYaota:OnBtnCostClick()
	if self:GetItemCount() >= 3 then
		FloatManager:AddNormal(StrConfig['yaota2'])
		return
	end
	BagController:UseItemByTid(BagConsts.BagType_Bag, 180500301, 1)
end

function UIYaota:ShowBossList(bInit)
	local objSwf = self.objSwf
	if not objSwf then return end
	local uiList = objSwf.bossList
	uiList.dataProvider:cleanUp()
	local showList = self:GetShowList()
	for _, vo in ipairs(showList) do
		uiList.dataProvider:push(UIData.encode( vo ))
	end
	uiList:invalidateData()
	if bInit then
		uiList.selectedIndex = self.showIndex - 1
	end
end

-- 获取显示列表
function UIYaota:GetShowList()
	local list = {}
	for k, v in pairs(self.showList) do
		local vo = {}
		local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
		if myLevel < v.limit_lv then
			vo.levelStr = string.format( StrConfig["yaota4"], '#ffbf00', v.limit_lv)
		else
			vo.levelStr = ""
		end
		vo.num = string.format(StrConfig["yaota6"], v.id)
		vo.icon = ResUtil:GetMonsterIconName(t_model[t_monster[v.monster_id].modelId].icon)
		table.push(list, vo)
	end
	return list
end

function UIYaota:getMaxValue()
	local nValue = 0
	for k, v in pairs(self.showList) do
		if v.limit_lv <= MainPlayerModel.humanDetailInfo.eaLevel then
			nValue = nValue + 1
		end
	end
	return nValue
end

function UIYaota:GetCurIndex()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- 当前boss的索引
	local listIndex = objSwf.bossList.selectedIndex

	self.showIndex = listIndex + 1
	return self.showIndex
end

function UIYaota:OnBossChange()
	self:ShowBossInfo()
	self:UpdateBtnState()
	self:PlayAnimal()
end

function UIYaota:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numBoss = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numBoss - 1
end

function UIYaota:ShowBossInfo()
	local objSwf = self.objSwf
	if not objSwf then return end

	local nIndex = self:GetCurIndex()
	local bossInfo = self.showList[nIndex]
	if not bossInfo then
		Error("error  yao  ta  bossinfo for  index :", nIndex)
		return
	end
	local monsterCfg = t_monster[bossInfo.monster_id]
	if not monsterCfg then
		Error("error yao ta monster is miss for monster_id :", bossInfo.monster_id)
		return
	end
	local modelCfg = t_model[monsterCfg.modelId]
	-- objSwf.icon_head.source = ResUtil:GetMonsterIconName(modelCfg.icon)
	objSwf.txt_ceng.text = bossInfo.id
	-- objSwf.txt_condition.text = bossInfo.limit_lv .. "级可进入"
	-- objSwf.txt_Title.num = bossInfo.id
	objSwf.txt_mosterlevel.text = monsterCfg.level .. "级"

	local rewardItemList = RewardManager:Parse(bossInfo.item)
	local uiList = objSwf.rewardList
	uiList.dataProvider:cleanUp()
	uiList.dataProvider:push( unpack(rewardItemList) )
	uiList:invalidateData()
	local itemList = {};
	itemList[1] = objSwf.icon1;
	itemList[2] = objSwf.icon2;
	itemList[3] = objSwf.icon3;
	itemList[4] = objSwf.icon4;
	UIDisplayUtil:HCenterLayout(#rewardItemList, itemList, 58, 933, 330);
	itemList = nil;

	objSwf.numericStepper._value = tonumber(bossInfo.id)
	objSwf.numericStepper:updateLabel()
end

function UIYaota:OnEnterBtnClick()
	local objSwf = self.objSwf
	if not objSwf then return end

	local num = objSwf.numericStepper.value;
	if t_yaota[tonumber(num)].limit_lv > MainPlayerModel.humanDetailInfo.eaLevel then
		FloatManager:AddNormal(StrConfig['yaota1'])
		return
	end
	local params = {param1 = tonumber(num)}
	ActivityController:EnterActivity(ActivityConsts.XianYuan, params)
end

function UIYaota:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:ShowLastTime();
	end, 1000, 0 );
	self:ShowLastTime();
end

function UIYaota:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
end

--每秒刷新 直接刷新显示时间
function UIYaota:ShowLastTime()
	--- 这里直接刷新倒计时显示
	local objSwf = self.objSwf
	if not objSwf then return end
	local time = self:GetLastTime()
	if time < 0 then time = 0 end
	
	objSwf.txt_time.text = PublicUtil:GetShowTimeStr(time)
end

function UIYaota:SaveInfo(time, nCount)
	self.nLastTime = time
	if self.nStartTime ~= 0 then
		self.nStartTime = GetServerTime()
	end
	-- self.nCount = nCount
end

function UIYaota:StartTime()
	self.nStartTime = GetServerTime()
end

function UIYaota:StopTime()
	self.nStartTime = 0
end

function UIYaota:GetLastTime()
	if self.nStartTime == 0 then
		return self.nLastTime
	else
		return self.nLastTime - (GetServerTime() - self.nStartTime)
	end
end

function UIYaota:GetItemCount()
	return BagModel:GetDailyUseNum(180500301)
end

function UIYaota:IsTween()
	return true;
end

--面板类型
function UIYaota:GetPanelType()
	return 1;
end

function UIYaota:DrawBoss()
	local objSwf = self.objSwf
	if not objSwf then return end

	self.objUIDraw = UISceneDraw:new( "UIYaota", objSwf.icon_sce, _Vector2.new(1030, 570) )
	self.objUIDraw:SetScene("v_ui_yaota.sen")
	self.objUIDraw:SetDraw(true)
end

function UIYaota:PlayAnimal()
	if not self.objUIDraw then return end
	-- self.objUIDraw:NodeAnimation("v_ui_jianmian_01", "v_ui_jianmian_01.san")
	if not self.objUIDraw.objScene then return end
	local nodes = self.objUIDraw.objScene:getNodes();
	local node = nil
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find("v_ui_jianmian_01") then
			node = v;
			break;
		end
	end
	if not node then return; end
	local anima = node.mesh.skeleton:getAnima("v_ui_jianmian_01.san");
	if not anima then
		anima = node.mesh.skeleton:addAnima("v_ui_jianmian_01.san");
	end
	anima:play();
end

function UIYaota:IsShowSound()
	return true
end


function UIYaota:HandleNotification(name,body)
	if name == NotifyConsts.ActivityOnLineTime then
		self:ShowCostInfo()
	elseif name == NotifyConsts.BagItemUseNumChange then
		if body.id == 180500301 then
			self:ShowCostInfo()
		end
	else
		self:ShowCostInfo()
	end
end
function UIYaota:ListNotificationInterests()
	return {
		NotifyConsts.ActivityOnLineTime,
		NotifyConsts.BagItemUseNumChange,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	}
end

--面板中详细信息为隐藏面板，不计算到总宽度内
function UIYaota:GetWidth()
	return 1146;
end

function UIYaota:GetHeight()
	return 687;
end