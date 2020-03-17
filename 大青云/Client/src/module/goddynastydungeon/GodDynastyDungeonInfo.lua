--[[
	2016年10月45日, PM 0:46:25
	诛仙青云志信息面板
	houxudong
]]

_G.UIGodDynastyInfo = BaseUI:new('UIGodDynastyInfo');

function UIGodDynastyInfo:Create()
	self:AddSWF("goddynastyInfo.swf",true,"bottom");
end

function UIGodDynastyInfo:OnLoaded( objSwf )
	objSwf.minPanel.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.minPanel.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.minPanel.btn_out.click = function () self:OnOutGodDynastyClick(); end
	objSwf.minPanel.btnOpen.click = function () self:panelStateClick(); end   
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.minPanel.txt_4.text = UIStrConfig['babel154'];
	objSwf.minPanel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['goddynasity9'], TipsConsts.Dir_RightDown )
	 end
	objSwf.minPanel.btnRule.rollOut = function() TipsManager:Hide(); end
end

function UIGodDynastyInfo:OnShow()
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	self:InitLayer()
	self:InitTotalTime()
	self:ShowRewardList()
	self:SetUIState()
	self:startDownTime()
end

-- 显示当前的层数
function UIGodDynastyInfo:InitLayer( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local curLayer = GodDynastyDungeonModel.nowLayer or 0
	objSwf.minPanel.txt_curLayer.htmlText = string.format( StrConfig['goddynasity8'], curLayer )
end

-- 初始化总时间
function UIGodDynastyInfo:InitTotalTime()
	local objSwf = self.objSwf;
	local cfg = t_zhuxianzhen[GodDynastyDungeonModel.nowLayer];
	if not objSwf or not cfg then return end
	local times = cfg.maxTime;
	local hour,min,sec = self:OnBackNowLeaveTime(times);
	objSwf.minPanel.txt_timeNow.htmlText = hour .. ':' .. min .. ':' .. sec;
end

--显示本层奖励list

function UIGodDynastyInfo:ShowRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardAllList = GodDynastyDungeonModel:GetAllRewardInDungeon( )
	if rewardAllList == nil then 
		Debug("未拿到奖励数据")
		return 
	end 
	-- 处理重复id的堆集
	for k,v in pairs(rewardAllList) do
		for i=1,k-1 do
			if toint(rewardAllList[k].id) ~= 0 then
				if toint(rewardAllList[k].id) == toint(rewardAllList[i].id) then
					rewardAllList[k].num = rewardAllList[k].num + rewardAllList[i].num
					rewardAllList[i].id = 0
				end
			end
		end
	end
	local eliminateRewardList = {}   --过滤重复id后的堆集
	for i=1,#rewardAllList do
		if rewardAllList[i].id ~= 0 then
			local vo = {}
			vo.id = rewardAllList[i].id
			vo.num = rewardAllList[i].num
			table.push(eliminateRewardList,vo)
		end
	end
	local isShowNum = true  --是否显示数量
	local rewardStr = '';
	for i,v in ipairs(eliminateRewardList) do
		if isShowNum then                --物品上显示数量
			rewardStr = rewardStr .. ( i >= #eliminateRewardList and v.id .. ',' .. v.num or v.id .. ',' .. v.num .. '#'  )
		else
			rewardStr = rewardStr .. ( i >= #eliminateRewardList and v.id or v.id ..'#'  )
		end
	end
	objSwf.minPanel.rewardList.dataProvider:cleanUp();
	if rewardStr == '' then return end
	local rewardItemList = RewardManager:Parse(rewardStr);
	objSwf.minPanel.rewardList.dataProvider:push(unpack(rewardItemList));
	objSwf.minPanel.rewardList:invalidateData();
end

-- 设置界面的排版
function UIGodDynastyInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.minPanel._visible = true
	objSwf.btnCloseState._visible = false
end;

-- 副本到计时(刷怪10秒结束后进行倒计时)
function UIGodDynastyInfo:startDownTime( )
	local objSwf = self.objSwf;
	local cfg = t_zhuxianzhen[GodDynastyDungeonModel.nowLayer];
	if not objSwf or not cfg then return end
	self:OnCloseTimes()
	local times = cfg.maxTime;
	local func = function ()
		times = times - 1;
		if times >= 0 then
			local hour,min,sec = self:OnBackNowLeaveTime(times);
			objSwf.minPanel.txt_timeNow.htmlText = hour .. ':' .. min .. ':' .. sec;
		end
		if times <= 0 then 
			self:OnCloseTimes()
			times = 0;
			objSwf.minPanel.txt_timeNow.htmlText = '00:00:00';
			return;
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,0);
end

function UIGodDynastyInfo:OnCloseTimes( )
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

-- 时间格式转换
function UIGodDynastyInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

-- 展开
function UIGodDynastyInfo:OnBtnCloseClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = true;
	objSwf.btnCloseState._visible = false;
end

-- 合起
function UIGodDynastyInfo:panelStateClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.minPanel._visible = false;
	objSwf.btnCloseState._visible = true;
end

--退出诛仙阵
function UIGodDynastyInfo:OnOutGodDynastyClick()
	local func = function () 
		GodDynastyDungeonController:OnOutGodDynasty(0)
	end
	self.uiconfirmID = UIConfirm:Open(StrConfig['cave003'],func);
end

function UIGodDynastyInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIConfirm:Close(self.uiconfirmID);
end

function UIGodDynastyInfo:GetWidth()
	return 237
end

function UIGodDynastyInfo:GetHeight()
	return 380
end

