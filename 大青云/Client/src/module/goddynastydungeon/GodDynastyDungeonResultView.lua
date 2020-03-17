--[[
	2016年10月15日, PM 01:52:29
	houxudong
	诛仙阵结算面板
]]
_G.UIGodDynastyDungeonResultView = BaseUI:new('UIGodDynastyDungeonResultView');

function UIGodDynastyDungeonResultView:Create()
	self:AddSWF("UIGodDynastyDungeonResultView.swf",true,"center");
end

function UIGodDynastyDungeonResultView:OnLoaded(objSwf)
	objSwf.btn_1.click = function() self:BtnOneClick(); end
	objSwf.btn_2.click = function() self:BtnTwoClick(); end
	objSwf.txt_lose.htmlText = UIStrConfig['babel300'];
	objSwf.reward.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.reward.rewardList.itemRollOut = function () TipsManager:Hide(); end
end

UIGodDynastyDungeonResultView.resultState = nil;
function UIGodDynastyDungeonResultView:OnShow()
	self:TimeChangeHandler();
	self:InitbTn(0)
	if self.resultState == 0 then
		self:LoseHandler();
		self:InitbTn(1)
		return;
	end
	self:WinHandler();
end

function UIGodDynastyDungeonResultView:InitbTn( num)
	local objSwf = self.objSwf
	if not objSwf then return; end
	if num == 0 then
		objSwf.btn_1._visible = true;
		objSwf.btn_1.disabled = false;
		objSwf.btn_2._x = 404
	else
		objSwf.btn_1._visible = false;
		objSwf.btn_1.disabled = true;
		objSwf.btn_2._x = 328
	end
end
function UIGodDynastyDungeonResultView:BtnOneClick()
	if self.resultState == 1 then
		GodDynastyDungeonController:OnOutGodDynasty(0) --请求退出
	end
end

function UIGodDynastyDungeonResultView:BtnTwoClick()
	if self.resultState == 0 then
		GodDynastyDungeonController:OnOutGodDynasty(0) --请求退出
	else
		-- 当前已达到最高层数判断
		if GodDynastyDungeonModel.nowLayer >= #t_zhuxianzhen then 
			FloatManager:AddNormal( StrConfig["goddynasity1"] );
			return
		end
		GodDynastyDungeonController:OnOutGodDynasty(1)  --领奖继续
	end
end

--弹出面板计时
local nowTime = 5;
function UIGodDynastyDungeonResultView:TimeChangeHandler()
	local objSwf = self.objSwf;
	local func = function()
		local objSwf = self.objSwf;
		nowTime = nowTime - 1;
		if nowTime == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			nowTime = 5;
			if self.resultState == 0 then
				GodDynastyDungeonController:OnOutGodDynasty(0)  --退出
			else
				if GodDynastyDungeonModel.nowLayer >= #t_zhuxianzhen then
					GodDynastyDungeonController:OnOutGodDynasty(0)  --退出
					return;
				end
				GodDynastyDungeonController:OnOutGodDynasty(1)  --领奖继续
			end
			return;
		end
		if self.resultState == 1 then
			objSwf.txt_time.htmlText = string.format(StrConfig['babel001'],nowTime);   --自动领奖继续！
		else
			objSwf.txt_time.htmlText = string.format(StrConfig['babel012'],nowTime);   --自动退出！
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

--失败
function UIGodDynastyDungeonResultView:LoseHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_1.label = UIStrConfig['babel203'];  --再次挑战
	objSwf.btn_2.label = UIStrConfig['babel204'];  --退出
	objSwf.txt_lose._visible = true;
	objSwf.reward._visible = false;
	objSwf.win._visible = false;
	objSwf.lose._visible = true;
	objSwf.bgfail._visible = true;
	objSwf.bgWin._visible = false;
	objSwf.reward.rewardList.dataProvider:cleanUp();  --list清理掉
end	

--通关
function UIGodDynastyDungeonResultView:WinHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_1.label = UIStrConfig['babel201'];  --领奖退出
	objSwf.btn_2.label = UIStrConfig['babel202'];  --领奖继续
	objSwf.reward._visible = true;
	objSwf.win._visible = true;
	objSwf.lose._visible = false;
	objSwf.txt_lose._visible = false;
	objSwf.bgfail._visible = false;
	objSwf.bgWin._visible = true;
	self:OnShowIcon();
end

--绘制奖励list
function UIGodDynastyDungeonResultView:OnShowIcon()
	local objSwf = self.objSwf;
	local cfg = t_zhuxianzhen[GodDynastyDungeonModel.nowLayer];
	local rewardCfg;
	objSwf.reward.rewardList.dataProvider:cleanUp();
	if self.resultState == 1 then  --成功
		local rewardList = self.rewardList;
		if not rewardList then rewardList = {}; end
		local rewardStr = '';
		for i , v in ipairs(rewardList) do
			if v.id ~= 0 then
				rewardStr = rewardStr .. ( i >= #rewardList and v.id .. ',' .. v.num or v.id .. ',' .. v.num .. '#'  )
			end
		end
		rewardCfg = RewardManager:Parse( rewardStr );
	end
	objSwf.reward.rewardList.dataProvider:push(unpack(rewardCfg));
	objSwf.reward.rewardList:invalidateData();
end

UIGodDynastyDungeonResultView.rewardList = nil;
function UIGodDynastyDungeonResultView:OnOpen(state,rewardList)
	if UIGodDynastyDungeonResultView.timeKey then  --返回结果  先删掉计时器
		TimerManager:UnRegisterTimer(UIGodDynastyDungeonResultView.timeKey);
		UIGodDynastyDungeonResultView.timeKey = nil;
	end
	if state == 0 then                  --通关失败
		self.resultState = 0;           
	elseif state == 1 then              --通关成功(包含奖励)
		self.resultState = 1;
		self.rewardList = rewardList;
	end
	if UIGodDynastyInfo:IsShow() then
		UIGodDynastyInfo:Hide();
	end
	self:Show();
end

function UIGodDynastyDungeonResultView:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
		nowTime = 5;
	end
end