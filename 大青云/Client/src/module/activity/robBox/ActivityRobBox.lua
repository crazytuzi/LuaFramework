--[[
	2016年8月5日, AM 11:37:25
	主城抢宝箱活动
	houxudong
	功能可以理解为ActivityRobBoxController
]]
--@adder: houxudong date:2106/7/13 PM 16:21:50
--@reason: 注册活动分为两种注册模式
--@method1.一种活动类型对应一个活动id，采用RegisterActivity注册
--@method2.一种活动类型对应多个活动id，采用RegisterActivityClass注册

--目前抢宝箱 用的活动图标是财神降临，时间0:00:00 开启等级40级
_G.ActivityRobBox = BaseActivity:new(ActivityConsts.RobBox);
ActivityModel:RegisterActivity(ActivityRobBox);

ActivityRobBox.timerKey = nil;
ActivityRobBox.vecTarget = nil;
ActivityRobBox.ismovetocol = true; --移动去准备采集
function ActivityRobBox:GetType()
	return ActivityConsts.T_RobBox;
end

function ActivityRobBox:RegisterMsg()
end

-- 进入活动执行方法
function ActivityRobBox:OnEnter()
	UIActivity:Hide();
	UIRobBoxInfo:Show();
	BaseActivity:SetIsNoticeCloserd(false)   --设置在活动中不关闭提醒
end

--自动寻路最近的宝箱
function ActivityRobBox:collectNearestBox(k)
	-- print("-------自动寻路最近的宝箱---------")
	local tagertpos = {};  --目标点位置
	local pos1 = {};
	local player = MainPlayerController:GetPlayer();
	local pos = player:GetPos();
	-- print("玩家自己的位置:",pos.x,pos.y)
	pos1.x  = pos.x +10;
	pos1.y  = pos.y +5;

	tagertpos = pos1;

	local completeFuc = function()
	end

	self.ismovetocol = false;
	self.vecTarget = _Vector3.new(tagertpos.x,tagertpos.y,0);
	local mapId = MainPlayerController:GetMapId();
	-- MainPlayerController:DoAutoRun(mapId,self.vecTarget,completeFuc);

	local collectionList = CollectionModel:GetCollectionList();  --得到玩家视野中所有的宝箱
	local index = 0;
	for k,v in pairs(collectionList) do
		index = index + 1;
	end
	self:AutoBox()
end

--判断自动采集
function ActivityRobBox:AutoBox()
	local selfPos = MainPlayerController:GetPlayer():GetPos();
	--寻找最近该类型的宝箱
	local nearcollection = nil;   --最近宝箱
	local nearestdistance = 0;    --离最近宝箱的距离
	local collectionList = CollectionModel:GetCollectionList();  --得到场景中所有的宝箱
	if collectionList then
		for cid, collection in pairs(collectionList) do
			if collection then
				--是否是同种类型
				local posx,posy = collection:GetPos().x, collection:GetPos().y;              --获取采集物的坐标
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
	--遍历完后得到最近的宝箱和离最近宝箱的距离
	-- print("寻找最近的宝箱:",nearcollection)
	-- print("寻找最近的宝箱距离:",nearestdistance)
	if nearcollection then
		if nearcollection.isHide then return end   --对当前最近宝箱的状态进行处理
		ActivityRobBox.ismovetocol = true;
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
			local config_dis = config.distance  --采集距离
			CollectionController:RunToTargetCollection(nearcollection,config_dis/2, completeFuc)   --completeFuc 采集完毕后进行的操作
		end
	end
end

-- 退出活动执行方法
function ActivityRobBox:OnQuit()
	BaseActivity:SetIsNoticeCloserd(true)  --退出活动时关闭活动提醒
	UIRobBoxInfo:Hide()
end

function ActivityRobBox:GetEndLastTimeOverLoad( )
	return self:GetEndLastTime();
end

