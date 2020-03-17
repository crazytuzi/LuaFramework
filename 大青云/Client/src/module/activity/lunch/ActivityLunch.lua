--[[
	2016年8月9日, AM 12:08:20
	大摆筵席活动
	houxudong
	功能可以理解为ActivityLunchController
]]
--@adder: houxudong date:2016/7/13 PM 16:21:50
--@reason: 注册活动分为两种注册模式
--@method1.一种活动类型对应一个活动id，采用RegisterActivity注册
--@method2.一种活动类型对应多个活动id，采用RegisterActivityClass注册

_G.ActivityLunch= BaseActivity:new(ActivityConsts.Lunch);
ActivityModel:RegisterActivityClass(ActivityConsts.T_Lunch,ActivityLunch);

--注册消息
function ActivityLunch:RegisterMsg()
	MsgManager:RegisterCallBack(MsgType.SC_ChooseMealTypeResult,self,self.ChooseMealTypeResult);  		--返回选择套餐结果
	MsgManager:RegisterCallBack(MsgType.SC_BanquetReward,self,self.BackRewardResult)             		--返回吃饭奖励
	MsgManager:RegisterCallBack(MsgType.SC_BanquetShortestChair,self,self.BanquetShortestChairResult)	--玩家离开桌子后返回最近的椅子坐标
end

function ActivityLunch:GetType()
	return ActivityConsts.T_Lunch;
end

function ActivityLunch:GetId()
	return ActivityConsts.Lunch;
end

ActivityLunch.nextPos ={
	x =0,
	y =0
};
ActivityLunch.timerKey = nil;
ActivityLunch.indexNum = 0;
ActivityLunch.nearX = 0;
ActivityLunch.nearY = 0;
-- 进入活动执行方法
function ActivityLunch:OnEnter()
	self.nextPos = MainPlayerController:GetPlayer():GetPos();
	self:KillXianJie();
	self:KillChiBang();
	UIActivity:Hide();
	UILunchInfo:Show();
	self:OnTimer();
	self:showAnnounce();
	self:KillPet();
	self.indexNum = 0
end

-- 切换完场景后执行
function ActivityLunch:OnSceneChange()
	self:KillTianShen();
end

--进入大摆筵席活动时干掉仙界 
function ActivityLunch:KillXianJie( )
	local player = MainPlayerController:GetPlayer();
	if player then
		player:KillXianJie()
	end
end

-- 进入大摆筵席活动时干掉天神
function ActivityLunch:KillTianShen( )
	local player = MainPlayerController:GetPlayer();
	if player then
		player:OnHideTianShen()
	end
end

--进入大摆筵席活动时干掉翅膀
function ActivityLunch:KillChiBang( )
	local player = MainPlayerController:GetPlayer();
	if player then
		player:KillChiBang()
	end
end

--退出大摆筵席活动时复活仙界
function ActivityLunch:ReBornXianJie( )
	local player = MainPlayerController:GetPlayer();
	if player then
		player:ReBornXianJie()
	end
end

--进入大摆筵席活动时复活翅膀
function ActivityLunch:ReBornChiBang( )
	local player = MainPlayerController:GetPlayer();
	if player then
		player:ReBornChiBang()
	end
end

--进入大摆筵席活动时干掉宠物
function ActivityLunch:KillPet( )
	local curPetId = LovelyPetModel:GetFightLovelyPetId()
	local state = LovelyPetUtil:GetLovelyPetState(curPetId);
	if state ~= LovelyPetConsts.type_fight then
		return;
	end
	LovelyPetController:ReqSendLovelyPet(curPetId, LovelyPetConsts.type_rest);
	local player = MainPlayerController:GetPlayer();
	if player then
		player:KillPet()
	end
end

--进入大摆筵席活动时复活宠物
function ActivityLunch:ReBornPet( )
	local curPetId = LovelyPetModel:GetFightLovelyPetId()
	local state = LovelyPetUtil:GetLovelyPetState(curPetId);
	if state ~= LovelyPetConsts.type_rest then
		return;
	end
	LovelyPetController:ReqSendLovelyPet(curPetId, LovelyPetConsts.type_fight);
end

--首次进入显示公告
function ActivityLunch:showAnnounce( )
	if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then
		UILunchAnnounce:Show();
	end
end

--开启时间监控
function ActivityLunch:OnTimer(  )
	local func = function() self:EatLunchOnLand() end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
	self.timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function ActivityLunch:EatLunchOnLand( )
	local curPetId = LovelyPetModel:GetFightLovelyPetId()
	local state = LovelyPetUtil:GetLovelyPetState(curPetId);
	local selfPlayer = MainPlayerController:GetPlayer()
	local pos = selfPlayer:GetPos();
	-- 玩家是否有移动或释放技能的判断
	-- if MainPlayerController:IsSkillPlaying() then;
	-- self:SendMove()
	-- end
	if MainPlayerController:IsEatOnland() or MainPlayerController:IsEatOnChair() or MainPlayerController:IsMoveState() then                         --运动
		self.indexNum = 0;
	else
		self.indexNum = self.indexNum + 1;    --静止
		if self.indexNum == 10 then
			if ActivityLunchModel:GetChooseState() == ActivityLunchConsts.NotChoose then   --未选择套餐
				if not MainPlayerController:IsEatOnland() then 
					self:SendEatOnLand()
				end
			else                                                                           --选择套餐(普通or豪华)
				if not MainPlayerController:IsEatOnChair() then                           
					self:AutoRun();
				end
			end
		end
	end
	-- UILunchInfo:ShowNum(self.indexNum)       --测试专用，后期删除
end

--自动寻路
function ActivityLunch:AutoRun( )
	local tagertpos = {};  --目标点位置
	local pos1 = {};
	local player = MainPlayerController:GetPlayer();
	local pos = player:GetPos();
	pos1.x  = self.nearX;
	pos1.y  = self.nearY;
	tagertpos = pos1;
	local completeFuc = function()
		--test code
		-- local selfPos = MainPlayerController:GetPlayer():GetPos();
		-- print("玩家自己的坐标位置:",selfPos.x,selfPos.y)
		self:AutoEatOnChair()
	end
	self.ismovetocol = false;
	-- print("目标点坐标位置:",pos1.x,pos1.y)
	self.vecTarget = _Vector3.new(tagertpos.x,tagertpos.y,0);
	local mapId = MainPlayerController:GetMapId();
	MainPlayerController:DoAutoRun(mapId,self.vecTarget,completeFuc);
end

--自动采集
function ActivityLunch:AutoEatOnChair()
	local selfPos = MainPlayerController:GetPlayer():GetPos();
	local nearcollection = nil;   
	local nearestdistance = 0;    
	local collectionList = CollectionModel:GetCollectionList(); 
	if collectionList then
		for cid, collection in pairs(collectionList) do
			if collection then
				local posx,posy = collection:GetPos().x, collection:GetPos().y;              --获取采集物的坐标
				-- print("玩家周围采集物坐标:",posx,posy)
				local distance = math.sqrt((posx - selfPos.x) ^ 2 + (posy - selfPos.y) ^ 2); --获得玩家到采集物之间的距离
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
	if nearcollection then
		if nearcollection.isHide then return end
		self.ismovetocol = true;
		local completeFuc = function()
			CollectionController:SendCollect(nearcollection)
		end
		if CollectionController:CheckOpenDialogDistance(nearcollection.configId) then
			CollectionController:SendCollect(nearcollection)
		else
			local pos = nearcollection:GetPos()
			local config = t_collection[nearcollection.configId]
			if not config then
				return false
			end
			local config_dis = config.distance  
			CollectionController:RunToTargetCollection(nearcollection,config_dis/2, CollectionController:SendCollect(nearcollection))   --completeFuc 采集完毕后进行的操作
		end
	end
end

-------------------------------	C TO S---------------------------------
--如果玩家不动10秒后执行原地吃饭动作
function ActivityLunch:SendEatOnLand( )
	local msg = ReqMealActionMsg:new();
	msg.actionType = ActivityLunchConsts.eatOnLand
	MsgManager:Send(msg);
end

--玩家走动时停止吃饭动作
function ActivityLunch:SendMove( )
	self.indexNum = 0
	local msg = ReqMealActionMsg:new();
	msg.actionType = ActivityLunchConsts.interruptAction
	MsgManager:Send(msg);
end

--选择套餐
function ActivityLunch:ChooseMealType(mealType)
	local msg = ReqChooseMealTypeMsg:new();
	msg.mealType = mealType
	MsgManager:Send(msg);
end

------------------------------- S TO C---------------------------------
--返回选择套餐结果
function ActivityLunch:ChooseMealTypeResult(msg)
	if msg.result == 0 then
		ActivityLunchModel:SetChooseState(msg.mealType)
		Notifier:sendNotification( NotifyConsts.ChooseLunchSuc);
		if UILunchAnnounce:IsShow() then
			UILunchAnnounce:Hide()
		end
	elseif msg.result == 1 then   --绑银不足
		ActivityLunchModel:SetChooseState(state)
		Notifier:sendNotification( NotifyConsts.ChooseLunchFailMoney);
	elseif msg.result == 2 then   --VIP等级不够
		ActivityLunchModel:SetChooseState(state)
		Notifier:sendNotification( NotifyConsts.ChooseLunchFailVip);
	end
end

--返回吃饭经验奖励
function ActivityLunch:BackRewardResult(msg)
	ActivityLunchModel:SetBackReward(msg.reward)
	Notifier:sendNotification( NotifyConsts.LunchBackExp);
end

--玩家离开桌子后返回最近的椅子坐标
function ActivityLunch:BanquetShortestChairResult(msg)
	-- print("收到服务器发来的椅子坐标信息")
	self.nearX = msg.x;
	self.nearY = msg.y;
end

--退出活动执行方法
function ActivityLunch:OnQuit()
	self:OnCloseTimer();
	UILunchInfo:Hide();
	self:ReBornXianJie();
	self:ReBornChiBang();
	self:ReBornPet();
	UILunchAnnounce:Hide()
	self.indexNum = 0;
	local player = MainPlayerController:GetPlayer()
	-- 如果玩家在桌边吃饭，取消吃饭动作
	if MainPlayerController:IsEatOnChair() then
		player:StopZhuoBianEat()
	end
	-- 如果玩家在地上吃饭，取消吃饭动作
	if MainPlayerController:IsEatOnland() then
		player:StopLandEat()
	end
end

function ActivityLunch:OnCloseTimer(  )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end
