--[[
活动解封冰奴
zhangshuhui
2015年1月7日20:16:36
]]

_G.UIBingNuMainView = BaseUI:new("UIBingNuMainView");

--解封冰奴上限
UIBingNuMainView.jiefengMax = 30;
--第一个冰奴Id
UIBingNuMainView.tartertIdStart = 513;

UIBingNuMainView.timerKey = nil;
UIBingNuMainView.bingnuindex = 0;
UIBingNuMainView.vecTarget = nil;
UIBingNuMainView.ismovetocol = true; --移动去准备采集
function UIBingNuMainView:Create()
	self:AddSWF("bingnuMainPanel.swf",true,"center");
	
	self:AddChild(UIBingNuQuickView, "BingNuQuick");
end

function UIBingNuMainView:OnLoaded(objSwf)
	self:GetChild("BingNuQuick"):SetContainer(objSwf.smallpanel.childPanel);
	objSwf.btn_state.click = function () self:OnBtn_StateClick(); end
	objSwf.btn_statesmall.click = function () self:OnBtn_StateSmallClick(); end
	objSwf.smallpanel.btnexit.click = function() self:OnBtnExitClick() end
	objSwf.smallpanel.btnquick.click = function() self:OnBtnQuickClick() end
	
	objSwf.smallpanel.labledaozei.click = function() self:OnbtnBingNuClick(1); end
	objSwf.smallpanel.lablexiushi.click = function() self:OnbtnBingNuClick(2); end
	objSwf.smallpanel.lableshangjia.click = function() self:OnbtnBingNuClick(3); end
	objSwf.smallpanel.lableyishou.click = function() self:OnbtnBingNuClick(4); end
	
	objSwf.smallpanel.labledaozei.rollOver = function() self:OnbtnBingNuTipRollOver(1); end
	objSwf.smallpanel.labledaozei.rollOut = function() self:OnbtnHideTipRollOver(); end
	objSwf.smallpanel.lablexiushi.rollOver = function() self:OnbtnBingNuTipRollOver(2); end
	objSwf.smallpanel.lablexiushi.rollOut = function() self:OnbtnHideTipRollOver(); end
	objSwf.smallpanel.lableshangjia.rollOver = function() self:OnbtnBingNuTipRollOver(3); end
	objSwf.smallpanel.lableshangjia.rollOut = function() self:OnbtnHideTipRollOver(); end
	objSwf.smallpanel.lableyishou.rollOver = function() self:OnbtnBingNuTipRollOver(4); end
	objSwf.smallpanel.lableyishou.rollOut = function() self:OnbtnHideTipRollOver(); end
	objSwf.smallpanel.btnquick._visible = false
	objSwf.smallpanel.lableyishou._visible = false
	objSwf.smallpanel.tfzhenqi._visible = false
end

function UIBingNuMainView:WithRes()
	local withResList = {};
	table.push(withResList,"bingnuquickPanel.swf");
	return withResList;
end

function UIBingNuMainView:GetWidth()
	return 220;
end

function UIBingNuMainView:OnShow()
	--初始化数据
	self:InitData();
	self:InitUI();
	
	self:ShowBingNuInfo();
	
	self:StartTimer();
end

function UIBingNuMainView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.btn_state.visible = true;
	objSwf.btn_statesmall.visible = false;
end

function UIBingNuMainView:OnHide()
	self:DelTimerKey();
end

-- 点击退出
function UIBingNuMainView:OnBtnExitClick()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_BingNu then return; end
	ActivityController:QuitActivity(activity:GetId());
end

function UIBingNuMainView:OnBtn_StateClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.smallpanel._visible = not objSwf.smallpanel._visible
	objSwf.btn_state.visible = false;
	objSwf.btn_statesmall.visible = true;
end
function UIBingNuMainView:OnBtn_StateSmallClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.smallpanel._visible = not objSwf.smallpanel._visible
	objSwf.btn_statesmall.visible = false;
	objSwf.btn_state.visible = true;
end

-- 快速解救
function UIBingNuMainView:OnBtnQuickClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if VipController:GetQuickCollection() == false then
		FloatManager:AddNormal( StrConfig["bingnu018"], objSwf.smallpanel.btnquick);
		return;
	end
	local child = self:GetChild("BingNuQuick");
	if not child then
		return;
	end
	self:ShowChild("BingNuQuick");
end

function UIBingNuMainView:OnbtnBingNuClick(k)
	self:JieJiuNearestBingNu(k);
end

--自动寻路最近的冰奴
function UIBingNuMainView:JieJiuNearestBingNu(k)
	local t = split(t_consts[36].param,"#");
	local pos1 = {};
	local pos2 = {};
	if t[1] then
		local posTable = split(t[1],",");
		pos1.x = tonumber(posTable[1]);
		pos1.y = tonumber(posTable[2]);
	end
	if t[2] then
		local posTable = split(t[2],",");
		pos2.x = tonumber(posTable[1]);
		pos2.y = tonumber(posTable[2]);
	end
	
	local tagertpos = {};
	local player = MainPlayerController:GetPlayer();
	local pos = player:GetPos();
	if math.sqrt((pos1.x - pos.x)^2 + (pos1.y - pos.y)^2) <= math.sqrt((pos2.x - pos.x)^2 + (pos2.y - pos.y)^2) then
		tagertpos = pos2;
	else
		tagertpos = pos1;
	end
		
	local completeFuc = function()
	end
		
	if k == 1 then
		self.bingnuindex = self.tartertIdStart
	elseif k == 2 then
		self.bingnuindex = self.tartertIdStart + 3
	elseif k == 3 then
		self.bingnuindex = self.tartertIdStart + 6
	elseif k == 4 then
		self.bingnuindex = self.tartertIdStart + 9
	end
	self.ismovetocol = false;
	self.vecTarget = _Vector3.new(tagertpos.x,tagertpos.y,0);
	local mapId = MainPlayerController:GetMapId();
	MainPlayerController:DoAutoRun(mapId,self.vecTarget,completeFuc);
end

function UIBingNuMainView:OnbtnBingNuTipRollOver(k)
	local collectionId = 0;
	local smallId = 0;
	if k == 1 then
		local colvo = t_collection[self.tartertIdStart];
		if colvo then
			smallId = self.tartertIdStart;
			collectionId = colvo.id;
		end
	elseif k == 2 then
		local colvo = t_collection[self.tartertIdStart + 3];
		if colvo then
			smallId = self.tartertIdStart + 3;
			collectionId = colvo.id;
		end
	elseif k == 3 then
		local colvo = t_collection[self.tartertIdStart + 6];
		if colvo then
			smallId = self.tartertIdStart + 6;
			collectionId = colvo.id;
		end
	elseif k == 4 then
		local colvo = t_collection[self.tartertIdStart + 9];
		if colvo then
			smallId = self.tartertIdStart + 9;
			collectionId = colvo.id;
		end
	end
	
	UIBingNuTipView:Open(collectionId, smallId)
end

function UIBingNuMainView:OnbtnHideTipRollOver()
	UIBingNuTipView:Hide();
end

---------------------------------消息处理------------------------------------
function UIBingNuMainView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.JieFengBingNuInfo then
		self:UpdateJieFengInfo(body);
	end
end

function UIBingNuMainView:ListNotificationInterests()
	return {NotifyConsts.JieFengBingNuInfo};
end

--显示
function UIBingNuMainView:ShowBingNuInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.smallpanel.labledaozei.htmlLabel = StrConfig['bingnu001'];
	objSwf.smallpanel.lablexiushi.htmlLabel = StrConfig['bingnu002'];
	objSwf.smallpanel.lableshangjia.htmlLabel = StrConfig['bingnu003'];
	objSwf.smallpanel.lableyishou.htmlLabel = StrConfig['bingnu004'];
	
	--解封冰奴奖励
	objSwf.smallpanel.tfyinliang.text = "0";
	objSwf.smallpanel.tfzhenqi.text = "0";
	objSwf.smallpanel.tflijin.text = "0";
	objSwf.smallpanel.tfexp.text = "0";
	
	--解封冰奴奖励
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			
			--解封数量
			objSwf.smallpanel.tfbingfengcount.text = activity.bingnucount.."/"..self.jiefengMax;
			
			for j,vo in pairs(activity.totalrewardlist) do
				if j == enAttrType.eaBindGold then
					objSwf.smallpanel.tfyinliang.text = vo;
				elseif j == enAttrType.eaZhenQi then
					objSwf.smallpanel.tfzhenqi.text = vo;
				elseif j == enAttrType.eaBindMoney then
					objSwf.smallpanel.tflijin.text = vo;
				elseif j == enAttrType.eaExp then
					objSwf.smallpanel.tfexp.text = vo;
				end
			end
		end
	end
	
	--倒计时
	self:ShowTimeInfo();
end

--更新倒计时
function UIBingNuMainView:ShowTimeInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			activity.sourceTime = activity.sourceTime -1;
			local t,s,m  = ActivityBingNu:GetTime(activity.sourceTime)
			objSwf.smallpanel.tfdaojishi.text = "00:"..s..":"..m;
		end
	end
end

--更新倒计时
function UIBingNuMainView:UpdateTimeInfo(s,m)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not s then
		objSwf.smallpanel.tfdaojishi.text = "00:00:00";
		return;
	end
	
	objSwf.smallpanel.tfdaojishi.text = "00:"..s..":"..m;
end

--初始化数据
function UIBingNuMainView:InitData()
	self.bingnuindex = 0;
	self.vecTarget = nil;
	self.ismovetocol = true;
end

--更新我的解救信息
function UIBingNuMainView:UpdateJieFengInfo(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--解封数量
	objSwf.smallpanel.tfbingfengcount.text = body.count.."/"..self.jiefengMax;
	
	--解封冰奴奖励
	local list = ActivityModel:GetActivityByType(ActivityBingNu:GetType());
	for i,activity in ipairs(list) do
		if activity:GetBingNuId() == ActivityController:GetCurrId() then
			for j,vo in pairs(activity.totalrewardlist) do
				if j == enAttrType.eaBindGold then
					objSwf.smallpanel.tfyinliang.text = vo;
				elseif j == enAttrType.eaZhenQi then
					objSwf.smallpanel.tfzhenqi.text = vo;
				elseif j == enAttrType.eaBindMoney then
					objSwf.smallpanel.tflijin.text = vo;
				elseif j == enAttrType.eaExp then
					objSwf.smallpanel.tfexp.text = vo;
				end
			end
		end
	end
end

function UIBingNuMainView:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,50,0);
end

function UIBingNuMainView:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UIBingNuMainView:OnTimer()
	-- 找到采集物
	if UIBingNuMainView.ismovetocol == true then
		return;
	end
	
	if MainPlayerController.autoRunInfo and MainPlayerController.autoRunInfo.vecTarget then
		if MainPlayerController.autoRunInfo.vecTarget.x == UIBingNuMainView.vecTarget.x and
		   MainPlayerController.autoRunInfo.vecTarget.y == UIBingNuMainView.vecTarget.y then
			UIBingNuMainView:AutoBingNu();
		end
	end
end;

--判断自动采集
function UIBingNuMainView:AutoBingNu()
	local selfPos = MainPlayerController:GetPlayer():GetPos();
	--寻找最近该类型的冰奴
	local nearcollection = nil;
	local nearestdistance = 0;
	local collectionList = CollectionModel:GetCollectionList();
	if collectionList then
		for cid, collection in pairs(collectionList) do
			if collection then
				--是否是同种类型
				if collection.configId >= self.bingnuindex and collection.configId < self.bingnuindex + 3 then
					local posx,posy = collection:GetPos().x, collection:GetPos().y;
					local distance = math.sqrt((posx - selfPos.x) ^ 2 + (posy - selfPos.y) ^ 2);
					if nearestdistance == 0 then
						nearestdistance = distance;
						nearcollection = collection;
					else
						if nearestdistance > distance then
							nearestdistance = distance;
							nearcollection = collection;
						end
					end
				end
			end
		end
	end
	
	if nearcollection then
		if nearcollection.isHide then return end
		self.ismovetocol = true;
		
		local completeFuc = function()
			CollectionController:SendCollect(nearcollection)
		end
		if CollectionController:CheckOpenDialogDistance(nearcollection.configId) then
			completeFuc()
		else
			local pos = nearcollection:GetPos()
			local config = t_collection[nearcollection.configId]
			if not config then
				return false
			end
			local config_dis = config.distance
			CollectionController:RunToTargetCollection(nearcollection,config_dis/2, completeFuc)
		end
	end
end