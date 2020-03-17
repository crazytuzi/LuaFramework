--[[
全服红包管理
zhangshuhui
2015年10月7日18:52:20
]]
_G.RedPacketController = setmetatable({},{__index=IController})
RedPacketController.name = "RedPacketController";

function RedPacketController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_SendRedPacket,self,self.OnSendRedPacket);
	MsgManager:RegisterCallBack(MsgType.WC_RedPacketInfoNotify,self,self.OnRedPacketInfoNotify);
	MsgManager:RegisterCallBack(MsgType.WC_GetRedPacketRank,self,self.OnRedPacketRank);
	MsgManager:RegisterCallBack(MsgType.WC_GetRedPacket,self,self.OnGetRedPacketMsg);
	MsgManager:RegisterCallBack(MsgType.SC_RedPacketHaveInfo,self,self.OnRedPacketHaveInfoMsg);
end

---------------------------以下为客户端发送消息-----------------------------
-- 发送礼包
function RedPacketController:ReqSendRedPacket(type,allNum,allPart,numType)
	local msg = ReqSendRedPacketMsg:new()
	msg.type = type or 0;
	msg.allNum = allNum or 0;
	msg.allPart = allPart or 0;
	msg.numType = numType or 0;
	MsgManager:Send(msg)
	
	-- print('======================发送礼包')
	-- trace(msg)
end


-- 请求红包奖励排行榜
function RedPacketController:ReqGetRedPacketRank(id)
	local msg = ReqGetRedPacketRankMsg:new()
	msg.id = id;
	MsgManager:Send(msg)
	
	-- print('======================请求红包奖励排行榜')
	-- trace(msg)
end

-- 请求获取礼包
function RedPacketController:ReqGetRedPacket(id)
	local msg = ReqGetRedPacketMsg:new()
	msg.id = id;
	MsgManager:Send(msg)
	
	-- print('======================请求获取礼包')
	-- trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
--发红包剩余次数
function RedPacketController:OnRedPacketHaveInfoMsg(msg)
	-- print('======================发红包剩余次数')
	-- trace(msg)
	RedPacketModel:SetCurNum(msg.num)
end
--发送红包结果
function RedPacketController:OnSendRedPacket(msg)
	-- print('======================发送红包结果')
	-- trace(msg)
	if msg.result == 0 then
		RedPacketModel:SetCurNum(msg.num)
		FloatManager:AddNormal( StrConfig["redpacket7"] )
	end
end

--全服红包通知
function RedPacketController:OnRedPacketInfoNotify(msg)
	--[[
	QuestController:TestTrace('======================全服红包通知')
	QuestController:TestTrace(msg)
	--]]
	local hongbaoModel, hongbaoRemindUI
	if msg.type == 1 then -- 新婚红包
		hongbaoModel = RedPacketMarryModel
		hongbaoRemindUI = UIRedPacketRemindMarry
	else  -- vip全服红包
		hongbaoModel = RedPacketModel
		hongbaoRemindUI = UIRedPacketRemindView
	end
	--
	local vo = {};
	hongbaoModel:SetredpacketNum(hongbaoModel:GetredpacketNum() + 1);
	
	local list = hongbaoModel:GetRedPacketList();
	local redvo = {};
	redvo.id = msg.id;
	redvo.roleName = msg.roleName;
	redvo.num = msg.num;
	if msg.num == -1 then
		redvo.num = 1;
	end
	table.push(list, redvo);
	hongbaoModel:SetRedPacket(list);
	if GameController.loginState then
		return;
	end
	hongbaoRemindUI:Show();
end

-- 全服红包排行榜
function RedPacketController:OnRedPacketRank(msg)
	--[[
	QuestController:TestTrace('======================全服红包排行榜')
	QuestController:TestTrace(msg)
	--]]
	local hongbaoModel, hongbaoUI
	if msg.type == 1 then -- 新婚红包
		hongbaoModel = RedPacketMarryModel
		hongbaoUI = UIRedPacketMarry
	else  -- vip全服红包
		hongbaoModel = RedPacketModel
		hongbaoUI = UIRedPacketView
	end

	local isZore = false;
	--红包列表
	local redpacketlist = hongbaoModel:GetRedPacketList();
	for v,listvo in ipairs(redpacketlist) do
		if listvo.id == msg.id then
			redpacketlist[v].num = msg.num;
			if msg.num == 0 then
				isZore = true;
			elseif msg.num == -1 then
				redpacketlist[v].num = 1;
			end
			break;
		end
	end
	
	--红包信息
	local list = {};
	for i,vo in pairs(msg.list) do
		if vo then
			table.push(list, vo);
		end
	end
	table.sort( list, function(A,B) return B.num < A.num end )
	hongbaoModel:SetCurId(msg.id);
	hongbaoModel:SetCurtId(msg.tid);
	hongbaoModel:SetPacketRankList(list);
	hongbaoModel:SetSenderName(msg.senderName);
	hongbaoModel:SetRewardNum(0);
	hongbaoUI:Show();
	if isZore == true then
		hongbaoModel:DeleteCurRedPacket(msg.id);
	end
	self:sendNotification(NotifyConsts.RedPacketListUpdata);
end

--获取红包结果
function RedPacketController:OnGetRedPacketMsg(msg)
	-- print('======================获取红包结果')
	-- trace(msg)
	local hongbaoModel, hongbaoRemindUI
	local hbType = self:CheckHBType(msg.id)
	if hbType == 1 then -- 新婚红包
		hongbaoModel = RedPacketMarryModel
		hongbaoRemindUI = UIRedPacketRemindMarry
	else  -- vip全服红包
		hongbaoModel = RedPacketModel
		hongbaoRemindUI = UIRedPacketRemindView
	end

	
	if msg.result == 0 then
		local list = hongbaoModel:GetPacketRankList();
		local playerinfo = MainPlayerModel.humanDetailInfo;
		local vo = {};
		vo.roleName = playerinfo.eaName;
		vo.num = msg.num;
		table.push(list, vo);
		table.sort( list, function(A,B) return B.num < A.num end );
		hongbaoModel:SetPacketRankList(list);
		hongbaoModel:UpdateCurRedPacket(msg.id);
		hongbaoModel:SetRewardNum(msg.num)
		hongbaoModel:DeleteCurRedPacket(msg.id);
		--self:sendNotification(NotifyConsts.HuoYueDuListRefresh,{Id=msg.id});
		
		if #hongbaoModel:GetRedPacketList() <= 0 then
			hongbaoRemindUI:Hide();
		end
	else
		--红包列表
		local redpacketlist = hongbaoModel:GetRedPacketList();
		for v,listvo in ipairs(redpacketlist) do
			if listvo.id == hongbaoModel:GetCurId() then
				redpacketlist[v].num = 0;
				self:sendNotification(NotifyConsts.RedPacketUpdata);
				hongbaoModel:DeleteCurRedPacket(msg.id);
				break;
			end
		end
	end
end

function RedPacketController:CheckHBType( id )
	local redpacketlist = RedPacketMarryModel:GetRedPacketList()
	for v,listvo in ipairs(redpacketlist) do
		if listvo.id == id then
			return 1 -- 新婚红包
		end
	end
	return 0
end