--[[
	2015年1月23日, PM 02:33:04
	wangyanwei
]]

_G.BabelController = setmetatable({},{__index=IController})

BabelController.name = 'BabelController';

function BabelController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackBabel,self,self.OnBackBabelInfo);  --返回通天塔信息
	MsgManager:RegisterCallBack(MsgType.SC_BackRankingListInfo,self,self.OnBackBabelRankListInfo);  --服务器通知：通天塔排行榜信息
	MsgManager:RegisterCallBack(MsgType.SC_BackBabelNowInfo,self,self.OnBackBabelNowInfo);  --服务器通知：进入通天塔
	MsgManager:RegisterCallBack(MsgType.SC_BackBabelResultInfo,self,self.OnBackBabelResultInfo);  --服务器通知：通关结果
	MsgManager:RegisterCallBack(MsgType.SC_BackBabelOut,self,self.OnBackBabelOut);  --服务器通知：退出通天塔
	MsgManager:RegisterCallBack(MsgType.SC_BackStoryEnd,self,self.OnBackStory);  --服务器通知：剧情播放完毕确认
	MsgManager:RegisterCallBack(MsgType.SC_BackBabelSweepsDate,self,self.OnBackBabelSweepsDate);  --扫荡斗破苍穹
end

--请求通天塔信息
function BabelController:OnGetBabelInfo(layer)
	local msg = ReqGetBabelInfoMsg:new();
	msg.layer = layer;
	MsgManager:Send(msg);
end

--刚进入游戏时请求通天塔信息
function BabelController:OnEnterGame()
	local msg = ReqGetBabelInfoMsg:new();
	msg.layer = 1;
	MsgManager:Send(msg);
end

--请求通天塔排行榜信息
function BabelController:OnGetBabelRankList()
	local msg = ReqGetRankingListMsg:new();
	MsgManager:Send(msg);
end

--请求进入通天塔
function BabelController:OnGetEnterBabel(index)
	local msg = ReqEnterIntoMsg:new();
	msg.layer = index;
	MsgManager:Send(msg);
end

BabelController.lastState = 0;
--请求退出通天塔
function BabelController:OnOutBabel(state)
	local msg = ReqOutBabelMsg:new();
	self.lastState = state;
	msg.state = state;
	MsgManager:Send(msg);
end

--侦听地图信息判断是否开启挂机
function BabelController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if mapCfg.type == 6 then
		AutoBattleController:SetAutoHang();
	end
end

--请求剧情播放完毕开始计时
function BabelController:OnSendStoryEnd()
	local msg = ReqsSendStoryEndMsg:new();
	msg.type = 1;
	MsgManager:Send(msg);
end

--请求扫荡
function BabelController:OnSendSweep(id)
	-- print("请求扫荡")
	local msg = ReqBabelSweepsMsg:new();
	msg.babelID = id;
	MsgManager:Send(msg);
end
--=================================以下是返回==================================--

function BabelController:OnBackBabelInfo(msg)
	local data = {};
	data.maxLayer = msg.maxLayer;		--当前挑战最高层
	data.layer = msg.layer;				--返回的是第几层
	data.maxTier = msg.maxTier;			--最佳通关人物的名字
	data.minTime = msg.minTime;			--最佳通关时间
	data.myTime = msg.myTime;			--我的时间
	data.num = msg.num;					--我剩余的次数
	data.daikyNum = msg.daikyNum;		--我剩余的每日总次数
	BabelModel:UpDataBabelInfo(data);
end

--返回通天塔排行榜
function BabelController:OnBackBabelRankListInfo(msg)
	local list = msg.list;
	BabelModel:BackRankData(list);
end

--返回当前进入通天塔的某一层
function BabelController:OnBackBabelNowInfo(msg)
	local result = msg.result;
	if result == -1 then
		FloatManager:AddNormal( StrConfig['babel10001'] );
		return
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['babel10002'] );
		return
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['babel10003'] );
		return
	elseif result == -4 then
		FloatManager:AddNormal( StrConfig['babel10004'] );
		return
	elseif result == -5 then
		FloatManager:AddNormal( StrConfig['babel10005'] );
		return
	elseif result == -6 then
		FloatManager:AddNormal( StrConfig['babel10006'] );
		return
	elseif result == -7 then
		FloatManager:AddNormal( StrConfig['babel10007'] );
		return
	elseif result == -8 then
		FloatManager:AddNormal( StrConfig['babel10008'] );
		return
	end
	if result ~= 0 then
		FloatManager:AddNormal( StrConfig['babel10009'] );
		return
	end
	BabelModel:OnBackLayer(msg);
	self.IsBabel = true;
end

--返回通关结果
function BabelController:OnBackBabelResultInfo(msg)
	self:OnPlayTimeDown(1000,msg)
end

function BabelController:OnPlayTimeDown(dealyTime,msg)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			if self.IsBabel then
				BabelModel:OnBackLayerResultInfo(msg);
				if msg.state == 0 then
					SoundManager:PlaySfx(2020);
				else
					SoundManager:PlaySfx(2019);
				end
			end
		end
		if num == 5 then
			UITimeTopSec:Open(2);  
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyTime)
	func()
end

--返回退出通天塔
function BabelController:OnBackBabelOut(msg)
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	BabelModel:OnOutBabelBack(msg);
	self.IsBabel = false;
end

--剧情播放完毕确认
function BabelController:OnBackStory(msg)
	if msg.type == 1 then
		BabelModel:OnEndStoryHandler();
	end
end

--确认是否在通天塔中
BabelController.IsBabel = false;
function BabelController:GetIsBabel()
	return self.IsBabel;
end

--服务器返回：返回扫荡
function BabelController:OnBackBabelSweepsDate(msg)
	local result = msg.result ;
	local rewardList = msg.rewardList ;
	local layerID = msg.layer ;
	
	if result == 0 then
		Notifier:sendNotification(NotifyConsts.BabelSweep,{list = rewardList,layerID = layerID});
	end
	if result == -1 then
		FloatManager:AddNormal( StrConfig['babel10001'] );
		return
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['babel10002'] );
		return
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['babel10003'] );
		return
	elseif result == -4 then
		FloatManager:AddNormal( StrConfig['babel10004'] );
		return
	elseif result == -5 then
		FloatManager:AddNormal( StrConfig['babel10005'] );
		return
	elseif result == -6 then
		FloatManager:AddNormal( StrConfig['babel10006'] );
		return
	elseif result == -7 then
		FloatManager:AddNormal( StrConfig['babel10007'] );
		return
	elseif result == -8 then
		FloatManager:AddNormal( StrConfig['babel10008'] );
		return
	end
	if result ~= 0 then
		FloatManager:AddNormal( StrConfig['babel10009'] );
		return
	end
end