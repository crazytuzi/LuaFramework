--[[
客户端点击日志
格式:url?uid=uid&sid=sid&platform=platform&cid=cid&type=type&param1=param1&param2=param2
lizhuangzhuang
2015年7月11日11:58:46
]]

_G.ClickLog = {};

--类型定义
ClickLog.T_Story_Enter = 1;			--剧情进入,param:剧情id
ClickLog.T_Story_Skip = 2;			--剧情跳过,param:剧情id
ClickLog.T_Stroy_Finish = 3;		--剧情完成,param:剧情id
ClickLog.T_Story_Step = 4;			--剧情步骤:param:剧情id,step
ClickLog.T_QuestPanel_Finish = 5;	--打开任务面板(完成任务),param:任务id [1]
ClickLog.T_QuestPanel_Accept = 6;	--打开任务面板(接任务),param:任务id   [1]
ClickLog.T_Quest_Equip = 7;			--穿装备任务,点击穿装备
ClickLog.T_Pack3_Start = 8;			--进主城包开始加载 [1]
ClickLog.T_Pack3_Finish = 9;		--进主城包加载结束 [1]
ClickLog.T_Pack4_Start = 10;		--第一个任务副本进打蛋副本开始加载 [1]
ClickLog.T_Pack4_Finish = 11;		--第一个任务副本进打蛋副本加载结束 [1]
ClickLog.T_Guide_Step = 12;			--引导脚本步骤,param:脚本名,step
ClickLog.T_Attack_Boss = 13;		--新手打第一个boss 新手村  神器守卫  --changer:houxudong date:2016/8/29 23:05
ClickLog.T_Attack_Egg = 14;			--第一个任务副本打洪荒之力 [1]
ClickLog.T_Quest_Except = 15;		--任务异常,param:任务id
ClickLog.T_PackXSC_Start = 16;		--进新手村包开始加载 [1]
ClickLog.T_PackXSC_Finish = 17;		--进新手村包加载结束 [1]
ClickLog.T_Stroy_Chapter = 18;		--播放任务章节,param:章节名
ClickLog.T_Stroy_Chapter_End = 19;  --播放任务章节结束:param:章节名
ClickLog.T_Welcome = 20;			--点击欢迎界面开始游戏,param:手动or自动 
ClickLog.T_AutoCreateSucc = 21;		--自动创建成功 [1]
ClickLog.T_QuestAdd = 22;			--客户端增加一个任务,param:任务id  接任务 [1]
ClickLog.T_QuestRemove = 23;		--客户端移除一个任务,param:任务id   [1]
ClickLog.T_ObtainReward = 24;		--目标奖励   [1]

ClickLog.reportUrl = nil;

ClickLog.sendAttackBoss = false;
ClickLog.sendAttackEgg = false;

function ClickLog:SetUrl(url)
	self.reportUrl = url;
	print("ClickLog:SetUrl(url):" .. url);

end

function ClickLog:SetCid(cid)
	if self.reportUrl and self.reportUrl~="" then
		cid = printguid(cid);
		print("ClickLog:SetCid(cid):" .. cid);
		self.reportUrl = self.reportUrl .. "&cid=" .. cid;
		print("ClickLog:SetCid(cid):" .. self.reportUrl);
	end
end

--发送日志
function ClickLog:Send(type,...)
	if not self.reportUrl then
		return;
	end
	local paramlist = {...};
	local paramurl = "";
	for i,param in ipairs(paramlist) do
		paramurl = paramurl .. "&param" ..i.. "=" ..param;
	end
	local url = self.reportUrl .. "&type=" .. type .. paramurl;
	_sys:httpReport(url);
	print("ClickLog:Send(type):" .. url);
end


