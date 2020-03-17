--[[
	成就主面板
	2015年5月21日, PM 02:16:49
	wangyanwei
]]

_G.UIAchievement = BaseUI:new('UIAchievement');

UIAchievement.SelecConsts = {
	StateAchievement_Open = 1,
	StateAchievement_End = 2,
}


UIAchievement.oldData = {};
function UIAchievement:Create()
	self:AddSWF('achievementPanel.swf',true,'center');
end

function UIAchievement:OnLoaded(objSwf)
	
	objSwf.list.handlerRewardClick = function (e) self:GetRewardClick(e.item.id); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
	objSwf.btn_getPointReward.click = function () self:GetRewardPointClick(); end
	objSwf.btn_close.click = function () self:Hide(); end
	
	objSwf.rewardpointList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardpointList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.endicon._visible = false;
	
	objSwf.effect_point.complete = function () objSwf.effect_point:playEffect(1); end
	
	objSwf.AchievementTitleList.itemClick = function (e) self.titleSelectIndex = e.index + 1; self:OnDrawRightList(); end
	objSwf.AchievementTitleList.selectedIndex = 0;
	objSwf.allNum.loadComplete = function ()
		objSwf.allNum._x = 15 + (190 / 2 - objSwf.allNum._width / 2);
	end
	
	objSwf.btn_all.click = function () self:OnAllAchievement(); end
	objSwf.maskBtn.visible = false;
end

--一键领取
function UIAchievement:OnAllAchievement()
	for i , v in ipairs(t_achievementstage) do
		local list = AchievementModel:OnGetAchievementTypeData(i);
		if not list then break end
		for j , k in pairs(list) do
			if k.state == 1 then
				AchievementController:OnGetAchievementReward(k.id);
			end
		end
	end
	
end

--切换标签
function UIAchievement:OnTabClick(tabName)
	if tabName == self.SelecConsts.StateAchievement_Open then
		self:OnShowChievementList();
	elseif tabName == self.SelecConsts.StateAchievement_End then
		self:OnChangeEndAchievement();
	end
end

UIAchievement.ShowItemNumConsts = 7;  --UI上显示成就列表item的选项个数
function UIAchievement:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:GetNextPage();
	self:OnDrawTitleList();		---绘制成就title
	self:OnDrawRightList();
	self:OnShowPointIndex();
end

UIAchievement.titleIndex = 0;
function UIAchievement:GetNextPage()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.args or #self.args < 1 then 
		local index = AchievementModel:OnGetIsOpenRewardIndex();
		UIAchievement.titleSelectIndex = index;
		self.titleSelectIndex = index;
		objSwf.AchievementTitleList.selectedIndex = index - 1;
		self.titleIndex = index - 1;
	else
		local page = toint(self.args[1] / self.IDNumConsts);
		objSwf.AchievementTitleList.selectedIndex = page - 1;
		self.titleSelectIndex = page;
		self.titleIndex = page - 1;
	end
end

function UIAchievement:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.AchievementTitleList.selectedIndex = 0;
	if self.timeKey then 
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.maskBtn.visible = false;
	self.maskState = false;
end

UIAchievement.IDNumConsts = 100000;
UIAchievement.titleSelectIndex = 1;  --选中的成就类型
function UIAchievement:OnDrawTitleList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local titleList = {};
	local index = 1;
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	for i , achievement in pairs(t_achievement) do
		if not titleList[index] then
			local achievementCfg = t_achievement[self.IDNumConsts * index + 1];
			if not achievementCfg then break end
			if playerLevel >= achievementCfg.level then
				titleList[index] = {};
				titleList[index].titleStr = achievementCfg.header;
				titleList[index].id = index;
				titleList[index].reward = AchievementModel:GetIndexIsReward(index); 
				index = index + 1;
			end
		end
	end
	objSwf.AchievementTitleList.dataProvider:cleanUp();
	for i , achievementTitle in ipairs(titleList) do
		local achievementVO = {};
		achievementVO.reward = achievementTitle.reward;
		achievementVO.titleStr = achievementTitle.titleStr;
		achievementVO.id = achievementTitle.id;
		objSwf.AchievementTitleList.dataProvider:push(UIData.encode(achievementVO));
	end
	objSwf.AchievementTitleList:invalidateData();
	objSwf.AchievementTitleList:scrollToIndex(self.titleIndex);
end

--右侧list
function UIAchievement:OnDrawRightList()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.list:scrollToIndex(0);
	objSwf.list.dataProvider:cleanUp();
	local allData = self:AllPanelData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
end

--领奖点击
function UIAchievement:GetRewardClick(id)
	if not t_achievement[id] then
		return
	end
	local achievement = AchievementModel:GetAchievenment(id);
	if achievement.state == 1 then
		AchievementController:OnGetAchievementReward(id);
		self:ShieldPanel();
	end
	if achievement.state == 0 then
		local achievementCfg = t_achievement[id];
		local funcIdCfg = split(achievementCfg.funid,',');
		if #funcIdCfg > 1 then
			FuncManager:OpenFunc(toint(funcIdCfg[1]),true,toint(funcIdCfg[2]));
		else
			FuncManager:OpenFunc(toint(funcIdCfg[1]));
		end
		self:Hide();
	end
end

function UIAchievement:ShieldPanel()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.maskBtn.visible = true;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.maskState = true;
	self.timeKey = TimerManager:RegisterTimer(function ()
		self.maskState = false;
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
		objSwf.maskBtn.visible = false;
	end,1000,1);
end

--点数领奖
function UIAchievement:GetRewardPointClick()
	local myPonit = AchievementModel:GetAchievenmentAllPoint();
	local cfgIndex = AchievementModel:GetPointIndex();
	local cfg = t_achievementstage[cfgIndex];
	if not cfg then return end
	local layerPoint = cfg.point;
	if myPonit >= layerPoint then
		AchievementController:OnGetAchievementPonitReward(cfgIndex)
	end
end

--点数阶段
function UIAchievement:OnShowPointIndex()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local PointIndex = AchievementModel:GetPointIndex();
	
	local allAchievementPoint = AchievementModel:GetAchievenmentAllPoint();
	
	local achievementStageCfg = t_achievementstage[PointIndex];
	if not achievementStageCfg then	achievementStageCfg = t_achievementstage[PointIndex - 1]; end
	objSwf.processBarMoney.maximum = achievementStageCfg.point;
	objSwf.processBarMoney.value = allAchievementPoint;
	objSwf.allNum.num = allAchievementPoint;
	objSwf.txt_allPoint.text = allAchievementPoint .. '/' .. achievementStageCfg.point;
	
	objSwf.icon_title.text = achievementStageCfg.name;
	--点数奖励
	self:OnShowPointReward();
	--已完成总数
	self:OnShowCompleteAchievement();
	--领奖按钮
	objSwf.endicon._visible = false;
	if PointIndex > #t_achievementstage then
		objSwf.btn_getPointReward.disabled = true;
		objSwf.btn_getPointReward.visible = false;
		objSwf.endicon._visible = true;
		objSwf.effect_point:stopEffect();
	else
		if allAchievementPoint >= achievementStageCfg.point then
			objSwf.btn_getPointReward.label = StrConfig['Achievement001'];
			objSwf.btn_getPointReward.disabled = false;
			objSwf.effect_point:playEffect(1);
		else
			objSwf.btn_getPointReward.label = StrConfig['Achievement002'];
			objSwf.btn_getPointReward.disabled = true;
			objSwf.effect_point:stopEffect();
		end
	end
end

--已完成总数
function UIAchievement:OnShowCompleteAchievement()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local num = AchievementModel:GetEndAchievement();
	objSwf.txt_allAchievement.htmlText = string.format(StrConfig['Achievement010'],num);
end

--点数奖励
function UIAchievement:OnShowPointReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local index = AchievementModel:GetPointIndex();
	if AchievementModel:GetPointIndex() > #t_achievementstage then 
		index = #t_achievementstage;
	end
	local cfg = t_achievementstage[index];
	if not cfg then return end
	local rewardList = RewardManager:Parse(cfg.reward);
	objSwf.rewardpointList.dataProvider:cleanUp();
	objSwf.rewardpointList.dataProvider:push(unpack(rewardList));
	objSwf.rewardpointList:invalidateData();
end

--当前UI上要显示的数据
UIAchievement.achievementData = nil;
function UIAchievement:OnShowChievementList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.achievementData = AchievementModel:GetAchievenmentListData();
	table.sort(self.achievementData,function(A,B)
		return A:GetAchievementId() < B:GetAchievementId() 
	end);
	objSwf.list.dataProvider:cleanUp();
	local allData = self:AllPanelData();
	objSwf.list.dataProvider:push( unpack(allData) );
	objSwf.list:invalidateData();
	
	--点数文本
	self:OnShowPointIndex();
	
	objSwf.list:scrollToIndex(0);
end

--所有数据
function UIAchievement:AllPanelData()
	--将可领奖的放在上面  拆分，排序，重组
	local group = self.titleSelectIndex;
	print(group,'!!!')
	local achievementObj = AchievementModel:OnGetAchievementTypeData(group)
	-- trace(achievementObj); 
	local newVo1 = {};
	local newVo2 = {};
	local newVo3 = {};
	
	local general = false;
	local data1 = achievementObj[1];
	if t_achievement[data1.id].general == 1 then
		general = true;
	end	
	
	local maxValue = 0;
	if general then
		for i , v in ipairs(achievementObj) do
			if v.value > maxValue then
				maxValue = v.value;
			end
		end
	end
	
	for i , v in ipairs(achievementObj) do
		if v.state == 1 then
			table.push(newVo1,v);
		elseif v.state == 0 then
			table.push(newVo2,v);
		else
			table.push(newVo3,v);
		end
	end
	table.sort(newVo1,function(A,B) 
		return A.id < B.id;
	end)
	table.sort(newVo2,function(A,B) 
		return A.id < B.id;
	end)
	table.sort(newVo3,function(A,B) 
		return A.id < B.id;
	end)
	local cfg = {};
	for i , v in ipairs(newVo1) do
		table.push(cfg,v);
	end
	for i , v in ipairs(newVo2) do
		table.push(cfg,v);
	end
	for i , v in ipairs(newVo3) do
		table.push(cfg,v);
	end
	self.oldData = cfg;
	local list = {}
	local vo;
	for i , v in ipairs(cfg) do
		local cfg = t_achievement[v.id];
		vo = {};
		vo.indexID = i;
		vo.id = v.id;
		vo.funcId = t_achievement[v.id].funid;
		vo.point = cfg.point;
		vo.btnState = v.state;
		if btnState ~= 1 then
			vo.btnLabel = StrConfig['Achievement200']
		else
			vo.btnLabel = StrConfig['Achievement201']
		end
		if v.state == 2 then
			vo.value = cfg.val;
		elseif v.state == 0 then
			vo.value = v.value;
		else
			vo.value = cfg.val;
		end
		vo.maxValue = t_achievement[v.id].val;
		if cfg.show_type == 1 then
			vo.txtStr = string.format(t_achievement[vo.id].txt,vo.value,vo.maxValue)
		else
			vo.txtStr = t_achievement[vo.id].txt;
		end
		local majorStr = UIData.encode(vo);
		local rewardList = RewardManager:Parse( t_achievement[v.id].reward );
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list
end

function UIAchievement:IsTween()
	return true;
end

function UIAchievement:GetPanelType()
	return 1;
end

function UIAchievement:IsShowSound()
	return true;
end

function UIAchievement:IsShowLoading()
	return true;
end

UIAchievement.maskState = false;
local oldID;
function UIAchievement:OnPlayEffect(id)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if id == oldID then return end
	oldID = id;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local itemIndex;
	for i , achievement in ipairs(self.oldData) do
		if achievement.id == id then
			itemIndex = i;
			break
		end
	end
	if not itemIndex then return end
	local item = objSwf.list:getRendererAt(itemIndex - 1);
	if not item then return end
	local effectMC = objSwf[item._name .. '_effect'];
	if not effectMC then return end
	effectMC:playEffect(1);
	effectMC.complete = function ()
		objSwf.maskBtn.visible = false;
		self.maskState = false;
		self:DrawData(id)
	end
end

function UIAchievement:DrawData(id)
	self:OnShow();
	-- self:OnDrawRightList();
	-- self.titleSelectIndex = toint(id / self.IDNumConsts);
	-- self.objSwf.AchievementTitleList.selectedIndex = self.titleSelectIndex - 1;
	-- self:OnShowPointIndex();
	-- self:OnDrawTitleList();
end

function UIAchievement:HandleNotification(name,body)
	if name == NotifyConsts.AchievementUpData then
		if not body or not body.id then
			return
		end
		
		if not self.maskState then self:DrawData(body.id); return end
		self:OnPlayEffect(body.id);
	elseif name == NotifyConsts.AchievementPointUpData then
		self:OnShowPointIndex();
	end
end

function UIAchievement:ListNotificationInterests()
	return {
		NotifyConsts.AchievementUpData,NotifyConsts.AchievementPointUpData
	}
end

function UIAchievement:GetWidth()
	return 938
end

function UIAchievement:GetHeight()
	return 680
end