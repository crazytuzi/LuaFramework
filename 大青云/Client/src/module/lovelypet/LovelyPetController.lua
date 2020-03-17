--[[
萌宠管理
zhangshuhui
2015年6月17日11:41:11
]]
_G.LovelyPetController = setmetatable({},{__index=IController})
LovelyPetController.name = "LovelyPetController";

LovelyPetController.isshowremind = false; --到期只弹一次

--萌宠说话计时
LovelyPetController.timerKey = nil;
LovelyPetController.chattime = 0;
LovelyPetController.fighttime = 0;--战斗单独拿出来处理
LovelyPetController.playerlaststate = -1; --玩家上一次状态

function LovelyPetController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_LovelyPetInfo,self,self.OnLovelyPetInfo);
	MsgManager:RegisterCallBack(MsgType.SC_ActiveLovelyPet,self,self.OnActiveLovelyPet);   --激活萌宠返回结果
	MsgManager:RegisterCallBack(MsgType.SC_LovelyPetTimeOver,self,self.OnLovelyPetTimeOver);
	MsgManager:RegisterCallBack(MsgType.SC_SendLovelyPet,self,self.OnSendLovelyPet);   --服务器返回:派出萌宠或者休息结果
	MsgManager:RegisterCallBack(MsgType.SC_RenewLovelyPet,self,self.OnRenewLovelyPet);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求激活萌宠
function LovelyPetController:ReqActiveLovelyPet(lovelypetid)
	local msg = ReqActiveLovelyPetMsg:new();
	msg.id = lovelypetid;
	MsgManager:Send(msg);
	
	-- print('=============请求激活萌宠')
	-- trace(msg)
end

-- 请求出战或者休息萌宠
function LovelyPetController:ReqSendLovelyPet(lovelypetid, state)
	local msg = ReqSendLovelyPetMsg:new();
	msg.id = lovelypetid;
	msg.state = state;
	MsgManager:Send(msg);
	
	print('=============请求出战或者休息萌宠')
	trace(msg)
end

-- 请求萌宠续费
function LovelyPetController:ReqRenewLovelyPet(lovelypetid, renewtype)
	local msg = ReqRenewLovelyPetMsg:new();
	msg.id = lovelypetid;
	msg.type = renewtype;
	MsgManager:Send(msg);
	
	-- print('=============请求萌宠续费')
	-- trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回萌宠信息
function LovelyPetController:OnLovelyPetInfo(msg)
	-- print('=======返回萌宠信息')
	-- trace(msg)
	
	local list = {};
	for i,listvo in ipairs(msg.list) do
		local vo = {};
		vo.id = listvo.id;
		vo.state = listvo.state;
		vo.time = listvo.time;
		if vo.time == 0 then
			vo.state = LovelyPetConsts.type_passtime;
		end
		vo.servertime = GetServerTime();
		table.push(list,vo);
		
		--设置出战的萌宠id
		if listvo.state == LovelyPetConsts.type_fight then
			LovelyPetModel:SetFightLovelyPetId(listvo.id);
		end
	end
	
	LovelyPetModel:SetLovelyPetListTime(GetServerTime());
	LovelyPetModel:SetLovelyPetList(list);
	
	if #list > 0 then
		self:StartTimer();
	end
	
	--续费提示
	local curid,curstate = LovelyPetUtil:GetCurLovelyPetState();
	if curstate == LovelyPetConsts.type_passtime then
		if self.isshowremind == false then
			self.isshowremind = true;
			RemindController:AddRemind(RemindConsts.Type_LovelyPet,1);
		end
	end
end

-- 返回萌宠激活结果
function LovelyPetController:OnActiveLovelyPet(msg)
	-- print('=======返回萌宠激活结果')
	-- trace(msg)
	
	if msg.result == 0 then
		local vo = {};
		vo.id = msg.id;
		vo.state = LovelyPetConsts.type_fight;
		vo.time = LovelyPetUtil:GetLovelyPetLimitTime(msg.id);
		vo.servertime = GetServerTime();
		
		LovelyPetModel:UpdateLovelyPet(vo);
	end
end

-- 返回到期了或者添加新的
function LovelyPetController:OnLovelyPetTimeOver(msg)
	-- print('=======返回到期了或者添加新的')
	-- trace(msg)
	
	--当前状态
	local curstate = LovelyPetUtil:GetLovelyPetState(msg.id);
	
	local vo = {};
	vo.id = msg.id;
	vo.time = msg.time;
	vo.servertime = GetServerTime();
	vo.state = curstate;
	if vo.time > 0 then
		--如果有其他萌宠是出战状态，则需要先休息
		-- for i,vo in ipairs (LovelyPetModel:GetLovelyPetList()) do
			-- if vo.state == LovelyPetConsts.type_fight then
				-- vo.state = LovelyPetConsts.type_rest;
				-- LovelyPetModel:UpdateLovelyPet(vo);
				-- break;
			-- end
		-- end
		if vo.state == LovelyPetConsts.type_passtime then
			vo.state = LovelyPetConsts.type_rest;
		end
	elseif vo.time == 0 then
		vo.state = LovelyPetConsts.type_passtime;
	end
	
	--之前是未激活，现在是战斗状态  模型显示
	if curstate == LovelyPetConsts.type_notactive and vo.time ~= 0 then
		UILovelyPetShowView:OpenPanel(vo.id);
	end
	
	--当前状态出战或者休息
	if vo.time ~= 0 and (curstate == LovelyPetConsts.type_rest or curstate == LovelyPetConsts.type_fight) then
		LovelyPetModel:UpdateLovelyPetTime(vo);
	elseif vo.time ~= 0 and curstate == LovelyPetConsts.type_passtime then
		LovelyPetModel:UpdateLovelyPetStateAndTime(vo);
	else
		LovelyPetModel:UpdateLovelyPet(vo);
	end
	
	if msg.time == 0 then
		UILovelyPetPassRenewView:Open(msg.id);
		RemindController:AddRemind(RemindConsts.Type_LovelyPet,1);
	else
		RemindController:AddRemind(RemindConsts.Type_LovelyPet,0);
	end
	
	if vo.time ~= 0 then
		self:StartTimer();
	end
end

-- 返回派出萌宠或者休息结果
function LovelyPetController:OnSendLovelyPet(msg)
	-- print('=======返回派出萌宠或者休息结果')
	-- trace(msg)
	-- print("-----服务器返回结果:",msg.result)
	
	if msg.result == 0 then
		--如果出战
		if msg.state == LovelyPetConsts.type_fight then
			--如果有其他萌宠是出战状态，则需要先休息
			for i,vo in ipairs (LovelyPetModel:GetLovelyPetList()) do
				if vo.state == LovelyPetConsts.type_fight then
					vo.state = LovelyPetConsts.type_rest;
					LovelyPetModel:UpdateLovelyPet(vo);
					break;
				end
			end
		end
		
		local vo = {};
		vo.id = msg.id;
		vo.state = msg.state;
		local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(msg.id);
		vo.time = lovelypettime;
		vo.servertime = servertime;
		
		LovelyPetModel:UpdateLovelyPet(vo);
	end
end

-- 返回萌宠续费结果
function LovelyPetController:OnRenewLovelyPet(msg)
	-- print('=======返回萌宠续费结果')
	-- trace(msg)
	
	if msg.result == 0 then
		FloatManager:AddNormal( StrConfig["lovelypet18"]);
		
		if UILovelyPetMainView:IsShow() == false then
			FuncManager:OpenFunc( FuncConsts.LovelyPet, true );
		end
	end
end

function LovelyPetController:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,100,0);
	
	local id, state = LovelyPetUtil:GetCurLovelyPetState();
	local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetConsts.player_fight);
	self.fighttime = Intervaltime;
end

--计时器
function LovelyPetController:OnTimer()
	--出战才计时
	local id, state = LovelyPetUtil:GetCurLovelyPetState();
	if state ~= LovelyPetConsts.type_fight then
		return;
	end
	
	LovelyPetController.chattime = LovelyPetController.chattime - 1;
	
	local selfPlayer = MainPlayerController:GetPlayer();
	
	--打坐状态
	if selfPlayer:IsSitState() == true then
		if LovelyPetController.playerlaststate == LovelyPetConsts.player_sit then
			if LovelyPetController.chattime <= 0 then
				local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetController.playerlaststate);
				UILovelyPetChat:Set(content, selfPlayer.pet);
				LovelyPetController.chattime = Intervaltime;
			end
		else
			LovelyPetController.playerlaststate = LovelyPetConsts.player_sit;
			local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetController.playerlaststate);
			LovelyPetController.chattime = Intervaltime;
		end
		
	--战斗状态
	elseif selfPlayer:IsSkillPlaying() == true then
		if LovelyPetController.playerlaststate == LovelyPetConsts.player_fight then
			LovelyPetController.fighttime = LovelyPetController.fighttime - 1;
			if LovelyPetController.fighttime <= 0 then
				local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetController.playerlaststate);
				UILovelyPetChat:Set(content, selfPlayer.pet);
				LovelyPetController.fighttime = Intervaltime;
			end
		else
			LovelyPetController.playerlaststate = LovelyPetConsts.player_fight;
		end
		
	--其他状态
	--elseif MainPlayerController:IsCanSit() == true then
	else
		if LovelyPetController.playerlaststate == LovelyPetConsts.player_rest then
			if LovelyPetController.chattime <= 0 then
				local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetController.playerlaststate);
				UILovelyPetChat:Set(content, selfPlayer.pet);
				LovelyPetController.chattime = Intervaltime;
			end
		else
			LovelyPetController.playerlaststate = LovelyPetConsts.player_rest;
			local content, Intervaltime = LovelyPetUtil:GetChatInfo(id, LovelyPetController.playerlaststate);
			LovelyPetController.chattime = Intervaltime;
		end
	end
	
end;