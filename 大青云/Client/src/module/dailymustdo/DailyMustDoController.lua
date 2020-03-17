--[[
DailyMustDoController管理
zhangshuhui
2015年3月18日14:50:00
]]
_G.DailyMustDoController = setmetatable({},{__index=IController})
DailyMustDoController.name = "DailyMustDoController";

function DailyMustDoController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_DailyMustDo,self,self.OnGetDailyMustDoListResult);
	MsgManager:RegisterCallBack(MsgType.SC_FinishMustDo,self,self.OnFinishDailyMustDoResult);
	MsgManager:RegisterCallBack(MsgType.SC_FinishAllMustDo,self,self.OnFinishAllDailyMustDoResult);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求今日必做列表
function DailyMustDoController:ReqGetDailyMustDoList()
	local msg = ReqDailyMustDoMsg:new()
	MsgManager:Send(msg)
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	DailyMustDoModel:SetReqLevel(playerinfo.eaLevel);
	
	--print('======================请求今日必做列表')
	--trace(msg)
end

-- 请求完成或者追回资源
function DailyMustDoController:ReqFinishDailyMustDo(id, type, consumetype)
	local msg = ReqFinishMustDoMsg:new()
	msg.id = id;
	msg.type = type;
	msg.consumetype = consumetype;
	MsgManager:Send(msg)
	
	--print('======================请求完成或者追回资源')
	--trace(msg)
end

-- 请求一键完成或者追回资源
function DailyMustDoController:ReqFinishAllDailyMustDo(type, consumetype)
	local msg = ReqFinishAllMustDoMsg:new()
	msg.type = type;
	msg.consumetype = consumetype;
	MsgManager:Send(msg)
	
	--print('======================请求一键完成或者追回资源')
	--trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回今日必做列表
function DailyMustDoController:OnGetDailyMustDoListResult(msg)
--	print('======================返回今日必做列表')
--	trace(msg)
	
	--活动信息
	for i,vo in pairs(msg.list) do
		if vo then
			DailyMustDoModel:AddDailyVo(vo);
		end
	end
	
	--刷新面板
	UIYaota:ShowCostInfo()
	UIYaotaInfo:ShowCostInfo()
	self:sendNotification(NotifyConsts.JinRiBiZuoList);
end

-- 返回完成或者追回资源
function DailyMustDoController:OnFinishDailyMustDoResult(msg)
	--print('======================返回完成或者追回资源')
	--trace(msg)
	
	if msg.result == 0 then
		local vo = {};
		if msg.type == DailyMustDoConsts.typetoday then
			vo.id = msg.id;
			vo.todaynum = 0;
		elseif msg.type == DailyMustDoConsts.typeyesterday then
			vo.id = msg.id;
			vo.runnum = 0;
		end
		
--		DailyMustDoModel:UpdateDailyVo(vo);
	end
	
end

-- 返回一键完成或者追回资源
function DailyMustDoController:OnFinishAllDailyMustDoResult(msg)
	--print('======================返回一键完成或者追回资源')
	--trace(msg)
	
	if msg.result == 0 then
		if msg.type == DailyMustDoConsts.typetoday then
--			DailyMustDoModel:ClearTodayDaily();
		elseif msg.type == DailyMustDoConsts.typeyesterday then
--			DailyMustDoModel:ClearRunDaily();
		end
	end
end