--[[
境界管理
zhangshuhui
2015年4月1日18:31:00
]]
_G.RealmController = setmetatable({},{__index=IController})
RealmController.name = "RealmController";

function RealmController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_RealmInfo,self,self.OnRealmInfoMsg);
	MsgManager:RegisterCallBack(MsgType.SC_RealmFloodResult,self,self.OnRealmFloodResult);
	MsgManager:RegisterCallBack(MsgType.SC_RealmBreakResult,self,self.OnRealmBreakResult);
	MsgManager:RegisterCallBack(MsgType.SC_GetRealmMax,self,self.OnGetRealmMaxResult);
	MsgManager:RegisterCallBack(MsgType.SC_StrenthenChong,self,self.OnStrenthenChongResult);
	MsgManager:RegisterCallBack(MsgType.SC_StrenthenBreakResult,self,self.OnStrenthenBreakResult);
	MsgManager:RegisterCallBack(MsgType.SC_ChangeRealmModel,self,self.OnChangeRealmModelResult);
end

function RealmController:BeforeLineChange()
	self:SetAutoLevelUp(false);
end

function RealmController:BeforeEnterCross()
	self:SetAutoLevelUp(false);
end


---------------------------以下为客户端发送消息-----------------------------
-- 请求灌注
function RealmController:ReqRealmFlood(floodnum,type)
	local msg = ReqRealmFloodMsg:new();
	msg.floodnum = floodnum;
	msg.type = type;
	MsgManager:Send(msg);
	
	-- print('===================请求灌注')
	-- trace(msg)
end

--角色面板手动升级之升级境界
function RealmController:RoleToRealmFlood()
	--满阶
	if RealmModel:GetRealmOrder() >= RealmConsts.ordermax then
		FloatManager:AddNormal( string.format(StrConfig['realm27']) );
		return;
	end

	--满星
	if RealmUtil:GetIsFullProgress() == true then
		FloatManager:AddNormal( string.format(StrConfig['realm28']) );
		return;
	end
	
	--经验不足
	if RealmUtil:GetIsHaveExp(RealmModel:GetRealmOrder()) == false then
		FloatManager:AddNormal( string.format(StrConfig['realm18']) );
		return;
	end
	
	self:ReqRealmFlood();
end

-- 请求突破
function RealmController:ReqGoBreak()
	--自动购买
	if RealmModel.autoBuy == true then
		--元宝不足
		if RealmUtil:GetIsJinJieByMoney(RealmModel:GetRealmOrder()) == false then
			self:SetAutoLevelUp(false);
			FloatManager:AddNormal( StrConfig["realm42"]);
			return;
		end
	else
		--道具不足
		if RealmUtil:GetIsHaveToolTuPo(RealmModel:GetRealmOrder()) == false then
			self:SetAutoLevelUp(false);
			FloatManager:AddNormal( StrConfig["realm42"]);
			return;
		end
	end
	
	--银两不足
	if RealmUtil:GetIsHaveMoneyTuPo(RealmModel:GetRealmOrder()) == false then
		self:SetAutoLevelUp(false);
		FloatManager:AddNormal( StrConfig["realm43"]);
		return;
	end
	
	local autoBuy = RealmModel.autoBuy
	local msg = ReqGoBreakMsg:new();
	msg.autobuy = autoBuy and 0 or 1; -- 0:自动购买 1:不自动购买
	MsgManager:Send(msg);
	
	-- print('===================请求突破')
	-- trace(msg)
end

-- 请求联手渡劫
function RealmController:ReqJoinlyBreak(type)
	
end

-- 请求退出突破
function RealmController:ReqBackBreak()
	
end

-- 请求前往境界巩固
function RealmController:ReqGoStrenthen(id)
	
end

-- 请求境界巩固
function RealmController:ReqStrenthenReal(id)
	
end

-- 请求获得世界最高等阶
function RealmController:ReqGetRealmMax()
	local msg = ReqGetRealmMaxMsg:new();
	MsgManager:Send(msg);
	
	-- print('===================请求获得世界最高等阶')
	-- trace(msg)
end

-- 请求巩固境界
function RealmController:ReqStrenthenChong(Id,num)
	local msg = ReqStrenthenChongMsg:new();
	msg.chongId = Id;
	msg.num = num;
	MsgManager:Send(msg);
	
	print('==========请求巩固境界')
	trace(msg)
end

-- 请求突破境界
function RealmController:ReqStrenthenBreak(Id)
	local msg = ReqStrenthenBreakMsg:new();
	msg.chongId = Id;
	MsgManager:Send(msg);
	
	print('==========请求突破境界')
	trace(msg)
end

--请求切换境界
function RealmController:ReqChangeRealmModel(Id)
	local msg = ReqChangeRealmModelMsg:new();
	msg.id = Id;
	MsgManager:Send(msg);
	
	-- print('==========请求切换境界')
	-- trace(msg)
end
---------------------------以下为处理服务器返回消息-----------------------------
-- 返回信息
function RealmController:OnRealmInfoMsg(msg)
	-- print('===================境界信息')
	-- trace(msg)
	-- WriteLog(LogType.Normal,true,'-------------houxudong',msg.RealmOrder)
	if RealmModel:GetRealmOrder() and RealmModel:GetRealmOrder() > 0 and RealmModel:GetRealmOrder() < msg.RealmOrder then
		FuncManager:OpenFunc( FuncConsts.Realm );
	end
	
	RealmModel:SetRealmOrder(msg.RealmOrder);
	RealmModel:SetRealmStar(0);
	RealmModel:SetRealmProgress(msg.feedToalNum);
	RealmModel:SetFreeNum(1000);
	
	RealmModel:SetChongId(msg.chongId);
	RealmModel:SetChongProgress(msg.chongprogress);
	RealmModel:SetSelectId(msg.selectId);
	RealmModel:SetPillNum(msg.pillNum);
	ZiZhiModel:SetZZNum(5, msg.zizhiNum)
	if msg.chongId == 0 then
		RealmModel:SetChongId(101);
	else
		if msg.chongId % 100 == 0 then
			RealmModel:SetChongId(msg.chongId + 1);
		end
	end
	
	local list = {};
	local cfg = t_jingjie[RealmModel:GetRealmOrder()];
	if cfg then
		for _, type in pairs( RealmConsts.Attrs ) do
			if cfg[type] > 0 then
				local vo = {};
				vo.type = AttrParseUtil.AttMap[type];
				vo.val = 0;
				table.push(list,vo);
			end
		end
	end
	-- UILog:print_table(msg.realmattrlist)
	local attrlist = {};
	for i,voattr in pairs(msg.realmattrlist) do
		local vo = {};
		vo.type = voattr.type;
		vo.val = voattr.value;
		table.push(attrlist,vo);
	end
	attrlist = RealmUtil:AddUpAttrIsNil(attrlist,list);
	RealmModel:SetAttrList(attrlist);
	
	RealmModel:SetBreakProgress(msg.blessing);
end

-- 返回灌注结果
function RealmController:OnRealmFloodResult(msg)
	-- print('===================返回灌注结果')
	-- trace(msg)
	
	if msg.result == 0 then
		RealmModel:SetFreeNum(0);
		RealmModel:SetFlootInfo(msg.realmOrder, msg.feedToalNum);
		
		--属性变化
		local list = {};
		for i,voattr in pairs(msg.attrlist) do
			local vo = {};
			vo.type = voattr.type;
			vo.val = voattr.value;
			table.push(list,vo);
		end
		RealmModel:UpdateAttrList(list);
	elseif msg.result == 1 then
	elseif msg.result == 2 then
	elseif msg.result == 3 then
	elseif msg.result == 4 then
	end
end

-- 返回进阶结果
function RealmController:OnRealmBreakResult(msg)
	-- print('===================返回进阶结果',msg.result)
	-- trace(msg)
	
	if msg.result == 0 then
		VipModel:SetIsChange(VipConsts.TYPE_REALM,true);
		RealmModel:SetRealmStar(0);
		RealmModel:SetBreakProgress( msg.blessing, true );
	else
		self:SetAutoLevelUp(false);
	end
end

-- 返回获得世界最高等阶结果
function RealmController:OnGetRealmMaxResult(msg)
	-- print('===================返回获得世界最高等阶结果')
	-- trace(msg)
	
	RealmModel:SetOrderMaxInGame(msg.order)
end

RealmController.isAutoLvlUp = false;
local timerKey;
function RealmController:SetAutoLevelUp(auto)
	if self.isAutoLvlUp == auto then return end
	if auto then
		if timerKey ~= nil then return end;
		timerKey = TimerManager:RegisterTimer( function()
			self:ReqGoBreak();
		end, 300, 0 );-- 自动升阶时间间隔300毫秒
	else
		if timerKey then
			TimerManager:UnRegisterTimer(timerKey);
			timerKey = nil;
		end
	end
	self.isAutoLvlUp = auto;
	UIRealmMainView:SwitchAutoLvlUpState(auto);
end

-- 返回巩固结果
function RealmController:OnStrenthenChongResult(msg)
	print('============返回巩固结果')
	trace(msg)
	
	if msg.result == 0 then
		RealmModel:SetChongId(msg.chongId);
		RealmModel:SetChongProgress(msg.progress);
	end
end
--返回境界重突破结果
function RealmController:OnStrenthenBreakResult(msg)
	print('============返回境界重突破结果')
	trace(msg)
	
	if msg.result == 0 then
		RealmModel:SetChongId(msg.chongId);
		if msg.chongId % 100 == 1 then
			RealmModel:SetSelectId((toint(msg.chongId / 100) - 1) * 100 + RealmConsts.xingmax);
		else
			RealmModel:SetSelectId(msg.chongId - 1);
		end
		RealmModel:SetChongProgress(msg.progress);
		
		self:sendNotification( NotifyConsts.StrenthenUpdate,{isTuPo = true} );
	end
end
--返回切换境界结果
function RealmController:OnChangeRealmModelResult(msg)
	print('============返回境界重突破结果')
	trace(msg)
	
	if msg.result == 0 then
		RealmModel:SetSelectId(msg.id);
	end
end