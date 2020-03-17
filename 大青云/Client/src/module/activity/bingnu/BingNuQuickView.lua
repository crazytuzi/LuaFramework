--[[
快速解救
zhangshuhui
2015年1月7日20:16:36
]]

_G.UIBingNuQuickView = BaseUI:new("UIBingNuQuickView");

UIBingNuQuickView.tartertMax = 12--冰奴总种类
UIBingNuQuickView.targerId = 0--解救目标类型
UIBingNuQuickView.targernum = 0--解救目标数量
UIBingNuQuickView.jiefengcount = 0--已经解救数量
UIBingNuQuickView.jiefengindex = 0--快速解救的index

function UIBingNuQuickView:Create()
	self:AddSWF("bingnuquickPanel.swf",true,nil);
end

function UIBingNuQuickView:OnLoaded(objSwf)
	--关闭
	objSwf.btnclose.click = function() self:OnBtnCancel()  end
	--快速解救
	objSwf.btnquick.click = function() self:OnBtnQuickclick()  end
	--解救目标下拉框
	objSwf.combtarget.change = function(e) self:OnCombTargetCick(e); end
	
	objSwf.ns.change = function(e) self:OnNsChange(e); end
end

function UIBingNuQuickView:OnShow()
	self:ShowQuickBingNuInfo();
end

-- 关闭
function UIBingNuQuickView:OnBtnCancel()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.combtarget.selectedIndex = 0;
	
	self:Hide();
end

-- 快速解救
function UIBingNuQuickView:OnBtnQuickclick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local bingmoneynum = self:GetConsumeNum();
	
	if self.targernum == 0 then
		return;
	end
	
	local count = 0;
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			count = activity.bingnucount;
		end
	end
	
	--已达上限
	if UIBingNuMainView.jiefengMax == count then
		FloatManager:AddSysNotice(2015001);--已达上限
	end
	
	--判断数量
	local jiejiucount = UIBingNuMainView.jiefengMax - count;
	if self.targernum > jiejiucount then
		return;
	end
	
	--绑元不够
	if BingNuUtils:GetHaveBindMoney(bingmoneynum) == false then
		FloatManager:AddNormal( StrConfig["bingnu005"], objSwf.btnquick);
		return;
	end
	
	--请求快速解救
	ActivityBingNu:ReqQuickJieFeng(self.targerId, self.targernum)
end

--解救目标下拉框
function UIBingNuQuickView:OnCombTargetCick(e)
	if self.targetList[e.index+1] then
		self.targerId = self.targetList[e.index+1];
		
		--更新消耗
		self:UpdateConsumeInfo();
	end
 end

function UIBingNuQuickView:OnNsChange(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = e.target;
	
	
	local count = 0;
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			count = activity.bingnucount;
		end
	end
	
	local jiejiucount = UIBingNuMainView.jiefengMax - count;
	
	if ns.value ~= 0 then
		if ns.value > jiejiucount then
			ns._value = jiejiucount;
			ns:updateLabel();
		end
	else
		if jiejiucount > 0 then
			ns._value = 1;
			ns:updateLabel();
		else
			ns._value = 0;
			ns:updateLabel();
		end
	end
	
	self.targernum = ns._value;
	--更新消耗
	self:UpdateConsumeInfo();
end
---------------------------------消息处理------------------------------------
function UIBingNuQuickView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.JieFengBingNuInfo then
		self:ShowQuickBingNuInfo()
	end
end

function UIBingNuQuickView:ListNotificationInterests()
	return {NotifyConsts.JieFengBingNuInfo};
end

--初始化数据
function UIBingNuQuickView:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--解救目标类型
	self.targetList = {};
	for i=UIBingNuMainView.tartertIdStart,UIBingNuMainView.tartertIdStart+self.tartertMax do
		table.push(self.targetList, i);
	end
	table.sort( self.targetList, function(A, B) return A < B; end );
	
	--解救冰奴数量
	self.jiefengcount = 0;
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			self.jiefengcount = activity.bingnucount;
		end
	end
	--解救目标数量列表
	self.numList = {};
	local count = UIBingNuMainView.jiefengMax - self.jiefengcount;
	for j=1,count do
		table.push(self.numList, j);
	end
	table.sort( self.numList, function(A, B) return A < B; end );
	
	--当前选择的冰奴index
	self.jiefengindex = objSwf.combtarget.selectedIndex;
end

--初始化UI
function UIBingNuQuickView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local ns = objSwf.ns;
	
	objSwf.combtarget.dataProvider:cleanUp();
	for i,vo in ipairs(self.targetList) do
		local colvo = t_collection[vo];
		if colvo then
			local str = "";
			if colvo.type >= 1 and colvo.type <= 3 then
				str = string.format(StrConfig["bingnu011"], colvo.name);
			elseif colvo.type >= 4 and colvo.type <= 6 then
				str = string.format(StrConfig["bingnu010"], colvo.name);
			elseif colvo.type >= 7 and colvo.type <= 9 then
				str = string.format(StrConfig["bingnu013"], colvo.name);
			elseif colvo.type >= 10 and colvo.type <= 12 then
				str = string.format(StrConfig["bingnu012"], colvo.name);
			end
			
			objSwf.combtarget.dataProvider:push(str);
		end
	end
	objSwf.combtarget.rowCount = self.tartertMax;
	objSwf.combtarget.selectedIndex = self.jiefengindex;
	self.targerId = self.targetList[self.jiefengindex+1];
	
	local count = UIBingNuMainView.jiefengMax - self.jiefengcount;
	if count > 0 then
		ns._value = 1;
	else
		ns._value = 0;
	end
	ns:updateLabel();
	self.targernum = ns._value;
end

--显示
function UIBingNuQuickView:ShowQuickBingNuInfo()
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	
	self:UpdateConsumeInfo();
end

--更新快速解救消耗
function UIBingNuQuickView:UpdateConsumeInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bingmoneynum = self:GetConsumeNum();
	
	--消耗绑元
	objSwf.tflijin.text = bingmoneynum;
	
	--预计获得
	objSwf.imgexp.visible = false;
	objSwf.imgyinliang.visible = false;
	objSwf.imgzhenqi.visible = false;
	objSwf.imglijin.visible = false;
	objSwf.imglijin.text = "";
	local vo = t_collection[self.targerId];
	if vo then
		if vo.type >= 1 and vo.type <= 3 then
			objSwf.imgexp.visible = true;
		elseif vo.type >= 4 and vo.type <= 6 then
			objSwf.imgyinliang.visible = true;
		elseif vo.type >= 7 and vo.type <= 9 then
			objSwf.imgzhenqi.visible = true;
		elseif vo.type >= 10 and vo.type <= 12 then
			objSwf.imglijin.visible = true;
		end
		objSwf.tfyuji.text = BingNuUtils:GetRewardInfo(vo.type) * self.targernum;
	end
end

--更新快速解救消耗
function UIBingNuQuickView:GetConsumeNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local num = self.objSwf.ns.value;
	
	local bingmoneynum = 0;
	local consumeinfo = t_consts[33];
	if consumeinfo then
		--大中小
		local costtype = t_collection[self.targerId].cost_type;
		bingmoneynum = consumeinfo["val"..(costtype + 1)] * num;
	end
	
	return bingmoneynum;
end