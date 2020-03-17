--[[
帮派副本view
2015年1月8日14:34:38
haohu
]]

_G.UIUnionDungeon = BaseUI:new("UIUnionDungeon");

function UIUnionDungeon:Create()
	self:AddSWF("unionDungeonPanel.swf", true, nil);
end

function UIUnionDungeon:OnLoaded(objSwf)
	local list = objSwf.list;
	objSwf.list.itemBtnEnterClick   = function(e) self:OnBtnEnterClick(e); end
	objSwf.list.itemBtnRuleRollOver = function(e) self:OnBtnRuleRollOver(e); end
	objSwf.list.itemBtnRuleRollOut  = function(e) self:OnBtnRuleRollOut(e); end
	objSwf.list.itemRewardRollOver  = function(e) self:OnRewardRollOver(e); end
	objSwf.list.itemRewardRollOut   = function(e) self:OnRewardRollOut(e); end
	
	objSwf.btnPre.click  = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
end

function UIUnionDungeon:OnShow()
	self:UpdateShow();
end

function UIUnionDungeon:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- 帮派副本列表
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local dungeonListUIData = self:GetDungeonListUIData();
	list.dataProvider:push( unpack(dungeonListUIData) );
	list:invalidateData();
	-- 左右导航按钮状态
	self:CheckNavigateBtnState();
end

function UIUnionDungeon:GetDungeonListUIData()
	local list = {};
	local vo;
	local unionLevel = UnionModel:GetMyUnionLevel();
	local dungeonList = UnionDungeonModel:GetDungeonList();
	for id, dungeonVO in ipairs( dungeonList ) do
		vo = {};
		vo.id = id;
		local needLevel = dungeonVO.guildlv;
		vo.opened = unionLevel >= needLevel;
		if isDebug then
			vo.opened = true;
		end
		vo.needLevel       = needLevel
		vo.desTxt          = string.format( "<font color='#e9dbc4'>%s</font>", dungeonVO.des );
		vo.nameURL         = ResUtil:GetUnionDungeonNameImg( id );
		vo.bgURL           = ResUtil:GetUnionDungeonBgImg( id );
		vo.enterLabel      = StrConfig['union401'];
		vo.ruleLabel       = StrConfig['union402'];
		vo.rewardTitle     = StrConfig['union406'];
		local majorStr     = UIData.encode(vo);
		local allRewardStr = self:ConvertRewardStr( dungeonVO.reward );
		local rewardList   = RewardManager:Parse( allRewardStr );
		local rewardStr    = table.concat(rewardList, "*");
		local finalStr     = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list;
end

-- 将配表中配的奖励字符串中的数量转为0（以达到界面中奖励不显示数量目的）
function UIUnionDungeon:ConvertRewardStr( str )
	local tab = {};
	local itemStrTab = split(str, "#");
	for _, itemStr in pairs(itemStrTab) do
		local itemTab = split(itemStr, ",");
		itemTab[2] = 0;
		local newItemStr = table.concat( itemTab, "," );
		table.push( tab, newItemStr);
	end
	return table.concat( tab, "#" );
end

-- 切换到点击的帮派副本子页面
function UIUnionDungeon:OnBtnEnterClick(e)
	local unionDungeonVO = e.item;
	local id = unionDungeonVO and unionDungeonVO.id;
	self:ShowDungeon(id);
	local renderer = e.renderer
	if not renderer then return end
	renderer:setState("up")
end

-- 显示规则
function UIUnionDungeon:OnBtnRuleRollOver(e)
	local unionDungeonVO = e.item;
	local id = unionDungeonVO and unionDungeonVO.id;
	local ruleStr = UnionDungeonConsts.RuleMap[id];
	if ruleStr then
		TipsManager:ShowBtnTips( ruleStr, TipsConsts.Dir_RightDown )
	end
end

-- 隐藏规则
function UIUnionDungeon:OnBtnRuleRollOut(e)
	TipsManager:Hide();
end

-- 悬浮奖励
function UIUnionDungeon:OnRewardRollOver(e)
	local slotVO = RewardSlotVO:new();
	slotVO.id = e.item.id;
	slotVO.count = e.item.count;
	slotVO.bind = e.item.bind;
	local tipsInfo = slotVO:GetTipsInfo();
	TipsManager:ShowTips( tipsInfo.tipsType, tipsInfo.info, tipsInfo.tipsShowType, TipsConsts.Dir_RightDown);
end

-- 划出奖励
function UIUnionDungeon:OnRewardRollOut(e)
	TipsManager:Hide();
end

function UIUnionDungeon:OnBtnPreClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos - 1;
	self:CheckNavigateBtnState();
end

function UIUnionDungeon:OnBtnNextClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	local curPos = list.scrollPosition;
	list.scrollPosition = curPos + 1;
	self:CheckNavigateBtnState();
end

function UIUnionDungeon:CheckNavigateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	objSwf.btnPre.disabled = list.scrollPosition == 0;
	local numUnionDungeon = list.dataProvider.length;
	local numOnePage = UnionDungeonConsts.NumDungeonsOnePage;
	objSwf.btnNext.disabled = list.scrollPosition == numUnionDungeon - numOnePage;
end

--@param id 帮派副本(t_guildActivity)id
function UIUnionDungeon:ShowDungeon(id)
	if UnionDungeonConsts.WarActi == UnionDungeonConsts.UnionDungeonMap[id] then 
		UnionWarController:GOGOGOEnterWar()
		return 
	end;
	if UnionDungeonConsts.CityWarActi == UnionDungeonConsts.UnionDungeonMap[id] then 
		UnionCityWarController:GOGOGOCityWar()
		return 
	end;

	local parentUI = self.parent;
	if not parentUI then return; end
	local panelName = UnionDungeonConsts.UnionDungeonMap[id];
	if not panelName then return; end
	parentUI:ShowChild(panelName);
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIUnionDungeon:ListNotificationInterests()
	return {
		NotifyConsts.UnionDungeonListUpdate,
	};
end

--处理消息
function UIUnionDungeon:HandleNotification(name, body)
	if name == NotifyConsts.UnionDungeonListUpdate then
		self:OnDungeonListUpdate();
	end
end

function UIUnionDungeon:OnDungeonListUpdate()
	if self:IsShow() then
		self:UpdateShow();
	end
end