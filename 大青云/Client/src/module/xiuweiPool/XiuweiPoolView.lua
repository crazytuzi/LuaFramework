--[[
修为池
]]
_G.UIXiuweiPool = BaseUI:new("UIXiuweiPool")

UIXiuweiPool.isDanyao = false;

function UIXiuweiPool:Create()
	self:AddSWF("xiuweiPoolPanel.swf",true,'center')
end;

function UIXiuweiPool:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide() end;

	objSwf.toDanyao.click = function() self:OnDanyaoClick()end;
	objSwf.btnLianzhi.click = function() self:OnLianzhiClick()end;
	objSwf.btnLianzhi.rollOver = function() self:LianzhiTips()end;
	objSwf.btnLianzhi.rollOut = function() TipsManager:Hide() end;

	objSwf.getWaytipx.rollOver = function() self:ShowWayTips() end;
	objSwf.getWaytipx.rollOut = function() TipsManager:Hide() end;

	objSwf.ruleTips.rollOver = function() self:RuleTips() end;
	objSwf.ruleTips.rollOut = function() TipsManager:Hide() end;
	
	objSwf.tips.rollOver = function() self:XiuweiTips() end;
	objSwf.tips.rollOut = function() TipsManager:Hide() end;
end;

function UIXiuweiPool:OnShow()
	-- XiuweiPoolController:RepXiuweiInfo()
	self:UpdataUI();
end;
--获取途径的悬浮tips
function UIXiuweiPool:ShowWayTips()
	 TipsManager:ShowBtnTips(StrConfig['xiuweiPool10'],TipsConsts.Dir_RightDown);
end;
-- 修为情况
function UIXiuweiPool:XiuweiTips()
	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	local accumulate = XiuweiPoolModel:getAccumulate()
	local max_accumulate = cfg.max_accumulate
	local str = string.format(StrConfig['xiuweiPool20'],accumulate,max_accumulate)
	 TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
end;
-- 规则说明
function UIXiuweiPool:RuleTips()
	 TipsManager:ShowBtnTips(StrConfig['xiuweiPool11'],TipsConsts.Dir_RightDown);
end;
-- 炼制按钮的悬浮tips
function UIXiuweiPool:LianzhiTips()
	 TipsManager:ShowBtnTips(StrConfig['xiuweiPool09'],TipsConsts.Dir_RightDown);
end;
-- 修为球的悬浮tips
-- function UIXiuweiPool:RuleTips()
	 -- TipsManager:ShowBtnTips(StrConfig['xiuweiPool11'],TipsConsts.Dir_RightDown);
-- end;
function UIXiuweiPool:OnDanyaoClick()
	if not UIRole:IsShow() then
		self.isDanyao = true
		UIRole:Show();
	else
		UIRole:Hide();
		self.isDanyao = true
		UIRole:Show();
	end
end

--------飞图标
function UIXiuweiPool:PlyIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local itemid = XiuweiPoolModel:GetRefineItemid()

	local startPos = UIManager:PosLtoG(objSwf.flyLoad,0,0);
	local rewardList = RewardManager:ParseToVO(toint(itemid));
	RewardManager:FlyIcon(rewardList,startPos,6,true,60);
end;

function UIXiuweiPool:UpdataUI()
	--修为池
	self:SetXiuweiChiVal();
	--属性
	self:SetInfo();
end;

function UIXiuweiPool:OnHide()
end;

function UIXiuweiPool:OnLianzhiClick()
	-- 当前魂力值不足
	-- local cfg = t_xiuwei[1];
	-- if not cfg then 
		-- return 
	-- end;
	-- local decrease = cfg.decrease
	-- local xiuwei = XiuweiPoolModel:GetXiuwei()
  	-- if decrease > xiuwei then 
		-- FloatManager:AddNormal(StrConfig["xiuweiPool03"])
  		-- return 
  	-- end;
	 
	-- 今日炼制次数已达上限
	-- local refine_times = XiuweiPoolModel:GetRefineTimes()
	-- local times = cfg.times
	-- if refine_times >= times then 
		-- FloatManager:AddNormal(StrConfig["xiuweiPool04"])
  		-- return 
  	-- end;
	-- 背包已满
	
	--炼制丹药
	XiuweiPoolController:ReqDanYaoInfo()

end;

function UIXiuweiPool:SetInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	objSwf.getWaytipx.htmlLabel = string.format(StrConfig['xiuweiPool06']);
	objSwf.toDanyao.htmlLabel = string.format(StrConfig['xiuweiPool07']);
	
	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	
	local accumulate = XiuweiPoolModel:getAccumulate()
	local max_accumulate = cfg.max_accumulate
	local max_current = cfg.max_current
	local canGet = max_accumulate -accumulate
	objSwf.xiuweiVal_txt.htmlText =  string.format(StrConfig['xiuweiPool15'],canGet,max_accumulate)
	
	local refine_times = XiuweiPoolModel:GetRefineTimes()
	local times = cfg.times
	-- objSwf.getCount_txt.htmlText =  string.format(StrConfig['xiuweiPool01'],refine_times,times)
	
	local decrease = cfg.decrease
	local xiuwei = XiuweiPoolModel:GetXiuwei()
	if decrease<xiuwei then
		objSwf.getDesc_txt.htmlText =  string.format(StrConfig['xiuweiPool18'],decrease)  -------消耗的绿色
	else
		objSwf.getDesc_txt.htmlText =  string.format(StrConfig['xiuweiPool19'],decrease)
	end
	objSwf.getXiuwei_txt.htmlText =  string.format(StrConfig['xiuweiPool17'],xiuwei,max_current)
	objSwf.getXiuwei_txt1.htmlText =  string.format(StrConfig['xiuweiPool16'])
	-- WriteLog(LogType.Normal,true,'---------------------accumulate,xiuwei',accumulate,xiuwei)
end;

function UIXiuweiPool:SetXiuweiChiVal()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;

	local maxVal = cfg.max_current;
	local curVal = XiuweiPoolModel:GetXiuwei();

	objSwf.xiuweiChi_pro.maximum = toint(maxVal)
  	objSwf.xiuweiChi_pro.value = toint(curVal);
end;

------ 消息处理 ---- 
function UIXiuweiPool:ListNotificationInterests()
	return {
		NotifyConsts.XiuweiPoolUpdate,
		}
end;
function UIXiuweiPool:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.XiuweiPoolUpdate then 
		self:UpdataUI();
	end;
end;


-- 面板缓动
function UIXiuweiPool:IsTween()
	return true;
end;

--面板类型
function UIXiuweiPool:GetPanelType()
	return 1;
end

