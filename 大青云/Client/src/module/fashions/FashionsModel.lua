--[[FashionsModel
时装数据
zhangshuhui
2015年1月22日16:57:20
]]

_G.FashionsModel = Module:new();

--武器
FashionsModel.fashionsArms = 0;
--衣服
FashionsModel.fashionsDress = 0;
--头
FashionsModel.fashionsHead = 0;
--限时时装列表
FashionsModel.fashionslimitlist = {};
--永久时装列表
FashionsModel.fashionsforeverlist = {};

--是否获取了时装列表,第一次获取后要按时间排序
FashionsModel.isgetlist = false;

--剩余时间定时器key
FashionsModel.lastTimerKey = nil;

--设置时装武器
function FashionsModel:SetFashionsArms(Arms)
	local oldId = FashionsModel.fashionsArms;
	FashionsModel.fashionsArms = Arms;
	
	self:sendNotification(NotifyConsts.FashionsDressInfo,{pos=1, tid=Arms, oldId=oldId});
end
--设置时装衣服
function FashionsModel:SetFashionsDress(Dress)
	local oldId = FashionsModel.fashionsDress;
	FashionsModel.fashionsDress = Dress;
	
	self:sendNotification(NotifyConsts.FashionsDressInfo,{pos=2, tid=Dress, oldId=oldId});
end
--设置时装头
function FashionsModel:SetFashionsHead(Head)
	local oldId = FashionsModel.fashionsHead;
	FashionsModel.fashionsHead = Head;
	
	self:sendNotification(NotifyConsts.FashionsDressInfo,{pos=3, tid=Head, oldId=oldId});
end

--添加限时时装
function FashionsModel:Updatefashionslimit(vo)
	for i,cfg in pairs(self.fashionslimitlist) do
		if vo.tid == cfg.tid then
			self.fashionslimitlist[i] = vo;
			return;
		end
	end
	table.insert(self.fashionslimitlist ,vo);
	
	self:sendNotification(NotifyConsts.FashionsDressAdd,{tid=vo.tid, time=vo.time});
	
	--需要启动限时倒计时
	self:StartLastTimer();
end

--添加永久时装
function FashionsModel:Updatefashionsforever(vo)
	for i,cfg in pairs(self.fashionsforeverlist) do
		if vo.tid == cfg.tid then
			self.fashionsforeverlist[i] = vo;
			return;
		end
	end
	table.insert(self.fashionsforeverlist ,vo);
	
	self:sendNotification(NotifyConsts.FashionsDressAdd,{tid=vo.tid, time=vo.time});
end

function FashionsModel:StartLastTimer()
	if not self.lastTimerKey then
		self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 1000, 0 );
	end
end

--倒计时自动
function FashionsModel.DecreaseTimeLast()
	local ishavelimit = false;
	for i,cfg in pairs(FashionsModel.fashionslimitlist) do
		if cfg and cfg.time > 0 then
			FashionsModel.fashionslimitlist[i].time = FashionsModel.fashionslimitlist[i].time - 1;
			ishavelimit = true;
		end
	end
	
	if ishavelimit == false then
		TimerManager:UnRegisterTimer(FashionsModel.lastTimerKey);
		FashionsModel.lastTimerKey = nil;
	end
end