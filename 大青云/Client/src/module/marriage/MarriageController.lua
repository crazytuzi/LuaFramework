--[[
	结婚controller
	wangshuai
]]

_G.MarriagController = setmetatable({},{__index=IController})
MarriagController.name = "MarriagController";

function MarriagController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_ProposalRes,self,self.OnProposalMsg); 
	MsgManager:RegisterCallBack(MsgType.WC_BeProposaled,self,self.OnBeProposaledMsg); 
	MsgManager:RegisterCallBack(MsgType.WC_ApplyMarryData,self,self.OnMarryTimeData); 
	MsgManager:RegisterCallBack(MsgType.WC_ApplyMarry,self,self.OnMarryTimeSet); 
	MsgManager:RegisterCallBack(MsgType.SC_MarryType,self,self.OnMarryTypeSet); 
	MsgManager:RegisterCallBack(MsgType.SC_MarryTimeStart,self,self.OnMarryTimeStart); 
	MsgManager:RegisterCallBack(MsgType.SC_EnterMarryChurch,self,self.OnEnterMarrySence); 
	MsgManager:RegisterCallBack(MsgType.WC_LookMarryRedPackets,self,self.OnLookMoneyBag); 
	MsgManager:RegisterCallBack(MsgType.SC_Marry,self,self.OnMarry); 
	MsgManager:RegisterCallBack(MsgType.SC_MarryCardList,self,self.OnMarryCardList); 
	MsgManager:RegisterCallBack(MsgType.WC_MarryCardRemind,self,self.OnMarryCardRemind); 
	MsgManager:RegisterCallBack(MsgType.SC_MarryCardUse,self,self.OnMarryUseCard); 
	MsgManager:RegisterCallBack(MsgType.SC_ClaerMarry,self,self.OnMarryClaer); 
	MsgManager:RegisterCallBack(MsgType.SC_MarryMainPanelInfo,self,self.OnMarryPanelInfo); 
	MsgManager:RegisterCallBack(MsgType.WC_MarryTimeRemand,self,self.OnMarryTimeRemind); 
--	MsgManager:RegisterCallBack(MsgType.SC_RingInfo,self,self.OnRingInfo); 
	MsgManager:RegisterCallBack(MsgType.WC_FlyToMate,self,self.OnLayToMate); 
	MsgManager:RegisterCallBack(MsgType.SC_Divorce,self,self.OnDivorce); 
	MsgManager:RegisterCallBack(MsgType.WC_ProposaledSure,self,self.OnProposaledSure)
	MsgManager:RegisterCallBack(MsgType.SC_MarryOpen,self,self.OnMarryOpen)
	MsgManager:RegisterCallBack(MsgType.SC_GiveRedPacket,self,self.OnGiveRedResult)
	MsgManager:RegisterCallBack(MsgType.SC_MarryCardUseMyData,self,self.MarryCardUseData)
	MsgManager:RegisterCallBack(MsgType.SC_MarryingState,self,self.OnMarryState)
	MsgManager:RegisterCallBack(MsgType.SC_MarryTravelRes,self,self.OnMarryTravelRes)
	MsgManager:RegisterCallBack(MsgType.WC_MarryInvite,self,self.OnMarryInvite)
	MsgManager:RegisterCallBack(MsgType.SC_SendMarryBox,self,self.OnSendMarryBoxRes)
	MsgManager:RegisterCallBack(MsgType.SC_OutMarryCopy,self,self.OnOutMarryCopy)
	MsgManager:RegisterCallBack(MsgType.SC_DivorceXieYi,self,self.OnDivorceXieyi)
	MsgManager:RegisterCallBack(MsgType.SC_MarryEatStart,self,self.OnEatStart)
	MsgManager:RegisterCallBack(MsgType.SC_MarryRingStren,self,self.OnMarryRingStren)


end;

--婚戒强化
function MarriagController:OnMarryRingStren(msg)
	--print("强化范湖")
	--trace(msg)
	if msg.result == 0 then 
		MarriageModel:SetMarryRingStren(msg.lvl,msg.newVal)
		if UIMarryRingStren:IsShow() then 
			UIMarryRingStren:OnShow();
		end;
		if UIMarryRingStren:IsShow() then 
			UIMarryRingStren:PlayerFpx();
		end;
		if UIMarryMain:IsShow() then 
			UIMarryMain:SetRingStar();
		end;
	end;
end;

--婚宴开始
function MarriagController:OnEatStart(msg)
	--msg.time 
	if UIMarryCopy:IsShow() then 
		UIMarryCopy:SetEatOpen(msg.time)
	end;
end;

--双方协议离婚
MarriagController.tishiPanel = nil;
function MarriagController:OnDivorceXieyi(msg)
	local func = function()
		MarriagController:ReqDivorceXieYi(1)
		MarriagController.tishiPanel = nil
	end;
	local nofunc = function()
		MarriagController:ReqDivorceXieYi(2)
		MarriagController.tishiPanel = nil
	end;
	self.tishiPanel = UIConfirm:Open(StrConfig["marriage203"],func,nofunc)
end;

function MarriagController:OnOutMarryCopy(msg)
	if msg.result == 0 then 
		MainMenuController:UnhideRightTop();
		if UIMarrySayIdo:IsShow() then 
			UIMarrySayIdo:Hide();
		end;
		if UIMarryCopy:IsShow() then 
			UIMarryCopy:Hide();
		end;
	end;
end;

function MarriagController:OnMarryInvite(msg)
	--trace(msg)
	--print(debug.--traceback())
	--print("-----------------------------")
	if msg.result == 0 then 
		-- 成功
		FloatManager:AddNormal( StrConfig["marriage080"])
	elseif msg.result == -1 then 
		--无资格
		FloatManager:AddNormal( StrConfig["marriage081"])
	elseif msg.result == -2 then 
		--队长
		FloatManager:AddNormal( StrConfig["marriage076"])	--队长操作
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig["marriage095"])	--队长操作
	end;
end;


function MarriagController:OnEnterGame()
	MarriagController:ReqMarryMainPanelInfo()
end;

function MarriagController:OnLeaveSceneMap()
	local mapId = CPlayerMap:GetCurMapID();
	local cfg = t_map[mapId];
	if not cfg then return; end
	if cfg.type == 25 then
		UIMarrySayIdo:Hide();
	end
end

--自己的结婚状态
function MarriagController:OnMarryState(msg)
	--F--Trace(msg, '自己的结婚状态')
	-- --trace(msg)
	MarriageModel:SetMarryState(msg.marryState,msg.marryTime,msg.marryType,msg.marrySchedule,msg.marryDinner)
--	--debug.debug();
	if UIMarryMain:IsShow() then 
		UIMarryMain:UpdataShow()
	end;
end;

--自己使用红包前的data
function MarriagController:MarryCardUseData(msg)
	--trace(msg)
	--print("自己使用红包前的data")
	-- debug.debug()
	if msg.result == 0 or msg.result == 1 then 
		MarriageModel:SetCardUseMyData(msg.naroleName,msg.time)
		-- if not UIMarryCardMyData:IsShow() then 
		-- 	UIMarryCardMyData:Show()
		-- end;
	elseif msg.result == -1 then--不在结婚状态
		FloatManager:AddNormal(StrConfig["marriage067"]);
	elseif msg.result == -2 then--数量不足
		FloatManager:AddNormal(StrConfig["marriage068"]);
	end
end;

--给新人红包返回
function MarriagController:OnGiveRedResult(msg)
	--trace(msg)
	--print("_-------------------------")
	if msg.result == 0 then 
		--成功
		if MarryGiveFive:IsShow() then 
			MarryGiveFive:Hide();
		end;

		FloatManager:AddNormal( StrConfig['marriage035']);
	elseif msg.result == -1 then 
		--金额0
		FloatManager:AddNormal( StrConfig['marriage036']);
	end;
end;

--队员收到，队长开启婚礼仪式的通知
function MarriagController:OnMarryOpen(msg)
	--trace(msg)
	--print("队长开启婚礼仪式。。。。")
	if msg.result == 0 then 
		MarriageModel:SetOpenMarry(msg.roleID)
		if not UIMarrySayIdo:IsShow() then 
			UIMarrySayIdo:Show();
		end;
	elseif msg.result == -1 then--不符合队伍条件
		FloatManager:AddNormal(StrConfig["marriage064"]);
	elseif msg.result == -2 then--不在结婚状态
		FloatManager:AddNormal(StrConfig["marriage067"]);
	elseif msg.result == -3 then--配偶不在线
		FloatManager:AddNormal(StrConfig["marriage070"]);
	elseif msg.result == -4 then--与配偶不在同一地图
		FloatManager:AddNormal(StrConfig["marriage066"]);
	elseif msg.result == -5 then--队长
		FloatManager:AddNormal(StrConfig["marriage076"]);
	end;
end;

--双方收到结婚成功信息
function MarriagController:OnProposaledSure(msg)
	MarriageModel:SetProposaledData(msg.ringId,msg.naProf,msg.nvProf)
	if not UIMarryReserverOk:IsShow() then 
		UIMarryReserverOk:Show();
	end;
end;

--离婚
function MarriagController:OnDivorce(msg)
	--trace(msg)
	--debug.debug();
	--print("离婚返回")
	if msg.result == 0 then 
		--成功
		FloatManager:AddNormal( StrConfig['marriage033']);
		if UIDivorceOne:IsShow() then 
			UIDivorceOne:Hide();
		end;
		if UIDivorceTwo:IsShow() then
			UIDivorceTwo:Hide();
		end;
	elseif msg.result == -1 then
		--失败
		FloatManager:AddNormal( StrConfig['marriage034']);
	elseif msg.result == -2 then 
		FloatManager:AddNormal( StrConfig['marriage040']);
	elseif msg.result == -3 then 
		FloatManager:AddNormal( StrConfig['marriage041']);
	elseif msg.result == -4 then--没有配偶
		FloatManager:AddNormal(StrConfig["marriage069"]);
	elseif msg.result == -5 then--配偶不在线
		FloatManager:AddNormal(StrConfig["marriage070"]);
	elseif msg.result == -6 then--队长操作
		FloatManager:AddNormal(StrConfig["marriage076"]);
	elseif msg.result == -7 then--预约结婚时间内,禁止离婚
		FloatManager:AddNormal(StrConfig["marriage221"]);
	elseif msg.result == -8 then--双方不在同一线路
		FloatManager:AddNormal(StrConfig["marriage055"]);
	end;
end;

-- --设置玩家背包戒指信息
-- function MarriagController:OnRingInfo(msg)
-- 	for i,info in ipairs(msg.list) do 
-- 		MarriageModel:SetMyBagRingInfo(	info.itemId,
-- 										info.state)
-- 	end;
-- end;

--收到玩家婚礼提醒邀请
function MarriagController:OnMarryTimeRemind(msg)
	MarriageModel:SetMarryRemind(msg.naroleName,msg.nvroleName,msg.naprof,msg.nvprof)
	local curmapId = CPlayerMap:GetCurMapID()
	if curmapId == MarriageConsts.MarryMap then
		return;
	end
	--提醒界面
	if not UIMarryRemind:IsShow() then 
		UIMarryRemind:Show();
	end;
end;

--强制清理婚礼状态
function MarriagController:OnMarryClaer(msg)

end;

--婚礼界面信息
function MarriagController:OnMarryPanelInfo(msg)
	print('收到婚礼界面消息')
	-- trace(msg)
	MarriageModel:SetMyMarryPanelInfo(msg.beRoleName,msg.beUnionName,msg.beProf,msg.lvl,msg.fight,msg.time,msg.MaxDay,msg.intimate,msg.cid,msg.marryType,msg.ringLvl,msg.newVal)
	if UIMarryMain:IsShow() then 
		UIMarryMain:UpdataShow()
	end;
end;

--返回玩家使用请柬结果
function MarriagController:OnMarryUseCard(msg)
	--trace(msg)
	--print("--------------------------")
	if msg.result == 0 then
		--成功
		FloatManager:AddNormal( StrConfig['marriage037']);
		if UIMarryCardMyData:IsShow() then 
			UIMarryCardMyData:Hide();
		end;
	elseif msg.result == -1 then 
		--您还没有订婚，请柬不可使用！
		FloatManager:AddNormal( StrConfig['marriage097']);
	elseif msg.result == -2 then 
		--不在结婚状态，不可使用请柬
		--FloatManager:AddNormal( StrConfig['marriage097']);
	elseif msg.result == -3 then 
		--不可以向您的结婚对象发送请柬
		FloatManager:AddNormal( StrConfig['marriage098']);
	end
end;

--玩家收到请柬，提醒
function MarriagController:OnMarryCardRemind(msg)
	if msg.naroleName ~= "" then 
		--弹窗提醒
	end;
end;

--玩家上线，推背包内所有请柬列表
function MarriagController:OnMarryCardList(msg)
	--print("收到上线推请柬列表")
	----trace(msg)
	for i,info in ipairs(msg.list) do 
		MarriageModel:SetMyMarryCardData(	info.itemId,
											info.state,
											info.naroleName,
											info.nvroleName,
											info.naroleprof,
											info.nvroleprof,
											info.time)
	end;
end;

--返回即时消息，愿意否
function MarriagController:OnMarry(msg)
	--trace(msg,'---------------，当前结果')
	if msg.result == 1 then 
		--成功
		MarryUtils:PlayeMarryMv(msg.marryType, msg.naprof, msg.nvprof)
	elseif msg.result == -1 then--配偶不在线
		FloatManager:AddNormal(StrConfig["marriage063"]);
	elseif msg.result == -2 then--不满足组队条件
		FloatManager:AddNormal(StrConfig["marriage064"]);
	elseif msg.result == -3 then--不在结婚时间
		FloatManager:AddNormal(StrConfig["marriage065"]);
	elseif msg.result == -4 then--不在同一地图
		FloatManager:AddNormal(StrConfig["marriage066"]);
	elseif msg.result == -5 then--队长操作
		FloatManager:AddNormal(StrConfig["marriage076"]);
	end
end;

--返回礼包详情
function MarriagController:OnLookMoneyBag(msg)
	MarriageModel:SetMarryRedMoney(msg.datalist)
	--print(MarryGiveBeFive:IsShow(),'---------------------')
	if MarryGiveBeFive:IsShow() then 
		MarryGiveBeFive:OnUpdataShow()
	end;
end;

--请求进入礼堂
MarriagController.isChangeLineLitang = false;
function MarriagController:OnEnterMarrySence(msg)
	--F--Trace(msg, '进入礼堂')
	--trace(msg)
	--print('-----------------------------')
	-- debug.debug();
	if msg.result == 0 then
		-- 成功
		if msg.lineID >= 0 then 
			local curLine = CPlayerMap:GetCurLineID();
			if curLine == msg.lineID then 
				self:ReqEnterMarryChurchOK();
			else
				self.isChangeLineLitang = true;
				MainPlayerController:ReqChangeLine(msg.lineID);
			end;
		else
			self:ReqEnterMarryChurchOK();
		end;
	elseif msg.result == -1 then --时间未到
		FloatManager:AddNormal( StrConfig['marriage099']);
	elseif msg.result == -2 then --时间过期
		FloatManager:AddNormal( StrConfig['marriage101']);
	elseif msg.result == -3 then --无资格参加婚礼
		FloatManager:AddNormal( StrConfig['marriage102']);
	elseif msg.result == -4 then 
	elseif msg.result == -5 then --没有巡游
		FloatManager:AddNormal( StrConfig['marriage103']);
	elseif msg.result == -6 then --婚礼被玩家取消
		FloatManager:AddNormal( StrConfig['marriage104']);
	elseif msg.result == -7 then --已在副本中
		FloatManager:AddNormal( StrConfig['marriage108']);
	elseif msg.result == -8 then --已在副本中
		FloatManager:AddNormal( StrConfig['marriage223']);
	end;
end;

function MarriagController:ReqEnterMarryChurchOK()
	--print("进入婚礼礼堂，换线成功")
	local msg = ReqEnterMarryChurchOKMsg:new();
	MsgManager:Send(msg);
	if not UIMarryCopy:IsShow() then 
		UIMarryCopy:Show();
	end;
	MainMenuController:HideRightTop();
end;

--新人婚礼时间到，通知双方
function MarriagController:OnMarryTimeStart(msg)
	--UIConfirm:Open( StrConfig['marriage039']);
	local mapId = MarriageConsts.MarryMap
	 local curmapId = CPlayerMap:GetCurMapID()
	 if mapId == curmapId then
	 	--同一场景，不提示
	 	return 
	 end;
	if not UIMarryRemindV:IsShow() then 
		UIMarryRemindV:Show();
	end;
end;

--发送求婚结果
function MarriagController:OnProposalMsg(msg)
	if msg.result == 0  then
		--发送成功,
		FloatManager:AddNormal( StrConfig['marriage027']);
		if UIMarryProposal:IsShow() then 
			UIMarryProposal:Hide();
		end;
	elseif msg.result == -1 then
		--道具不足
		FloatManager:AddNormal( StrConfig['marriage028']);
	elseif msg.result == -2 then 
		--对方不在线
		FloatManager:AddNormal( StrConfig['marriage029']);
	elseif msg.result == -3 then 
		--不可同性
		FloatManager:AddNormal( StrConfig['marriage030']);
	elseif msg.result == -4 then 
		--已有结婚or订婚状态
		FloatManager:AddNormal( StrConfig['marriage031']);
	elseif msg.result == -5 then 
		--等级不足
		FloatManager:AddNormal( StrConfig['marriage032']);
	elseif msg.result == -6 then---6对方已在结婚或求婚状态
		FloatManager:AddNormal( StrConfig["marriage052"]);
	elseif msg.result == -7 then---7对方已经与你是婚姻状态
		FloatManager:AddNormal( StrConfig['marriage053'])
	elseif msg.result == -8 then --对方等级不足
		FloatManager:AddNormal( StrConfig['marriage096'])
	elseif msg.result == -9 then --不在同1地图
		FloatManager:AddNormal( StrConfig['marriage212'])
	end;
	--trace(msg)
	--print("返回的求婚发送结果")
end;

--收到求婚
function MarriagController:OnBeProposaledMsg(msg)
	--trace(msg)
	--print("收到求婚了....")
	--debug.debug();
	MarriageModel:SetBeProposaled(msg.name,msg.desc,msg.ringId)
	-- if ui:IsShow() then  ui:updata end;
	UIMarryBeProposal:UpdataShow()
end;

--返回婚礼预约列表
function MarriagController:OnMarryTimeData(msg)
	--trace(msg)
	--print('收到返回时间')
	MarriageModel:SetMarryTime(msg.time,msg.TimeList)
	if UIMarryTimeSelect:IsShow() then 
		UIMarryTimeSelect:UpdataTimeList()
	end;
end;


---婚礼时间确认设置
function MarriagController:OnMarryTimeSet(msg)
	--trace(msg)
	--print("婚礼时间设定成功")
	if msg.result == 0 then 
		--设置成功
		FloatManager:AddNormal( StrConfig['marriage025']);
		local timeData = CTimeFormat:todate(MarriageModel:GetMyMarryTime() or 0, false);
		UIConfirm:Open( string.format(StrConfig['marriage047'],timeData));
		if UIMarryTimeSelect:IsShow() then 
			UIMarryTimeSelect:Hide();
		end;

	elseif msg.result == -1 then 
		--时间不可选择
		FloatManager:AddNormal( StrConfig['marriage026']);
	elseif msg.result == -2 then---2配偶不在
		FloatManager:AddNormal( StrConfig["marriage055"]);
	elseif msg.result == -3 then---3需要与组成2人队伍
		FloatManager:AddNormal( StrConfig["marriage054"])
	elseif msg.result == -4 then
		FloatManager:AddNormal( StrConfig["marriage072"])	--选择时间已过
	elseif msg.result == -5 then 
		FloatManager:AddNormal( StrConfig["marriage076"])	--队长操作
	elseif msg.result == -6 then 
		FloatManager:AddNormal( StrConfig["marriage211"])	--队长操作
	elseif msg.result == -7 then 
		FloatManager:AddNormal( StrConfig["marriage222"])	--没有选择模式
	end
end;

--婚礼类型确认
function MarriagController:OnMarryTypeSet(msg)
	if msg.result == 0 then 
		FloatManager:AddNormal( StrConfig['marriage022']);
		if not UIMarryTimeSelect:IsShow() then 
			UIMarryTimeSelect:Show();
		end;
		


	elseif msg.result == -1 then 
		--钱不够
		FloatManager:AddNormal( StrConfig['marriage023']);
	elseif msg.result == -2 then 
		--非组队
		FloatManager:AddNormal( StrConfig['marriage024']);
	elseif msg.result == -3 then--对方不在线
		FloatManager:AddNormal( StrConfig['marriage058'])
	elseif msg.result == -4 then--已选择结婚类型
		FloatManager:AddNormal( StrConfig["marriage060"]);
	elseif msg.result == -5 then--双方不在同一地图内
		FloatManager:AddNormal( StrConfig["marriage061"]);
	elseif msg.result == -6 then--没有资格
		FloatManager:AddNormal( StrConfig["marriage062"]);
	elseif msg.result == -7 then--队长操作
		FloatManager:AddNormal( StrConfig["marriage076"])	--队长操作
	elseif msg.result == -8 then--夫妻组队
		FloatManager:AddNormal( StrConfig["marriage224"])	--队长操作
	end
end;

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--开启婚礼仪式
function MarriagController:ReqMarryOpen()
	local msg = ReqMarryOpenMsg:new();
	MsgManager:Send(msg)
	--print("队长请求开启婚礼仪式")
end;

--发送求婚信息
function MarriagController:ReqProposal(roleID,loveText,ringId)
	local msg = ReqProposalMsg:new();
	msg.roleID = roleID;
	msg.desc = loveText;
	msg.ringId = ringId;
	MsgManager:Send(msg)
	--print("发送求婚信息")
	--trace(msg)
end;
--接受到求婚，返回被求婚的结果，
function MarriagController:ReqBeProposal(roleName,result,ringId)
	local msg = ReqBeProposaledChooseMsg:new()
	msg.name = roleName;
	msg.result = result;
	msg.ringId = ringId;
	MsgManager:Send(msg)
	--print("接受到求婚，返回被求婚的结果，")
	--trace(msg)
end;

--请求预约婚礼时间
function MarriagController:ReqApplyMarryData(time)
	local msg = ReqAookyNarryDataMsg:new()
	msg.time = time;
	MsgManager:Send(msg)
	--print("请求预约婚礼时间")
	--trace(msg)

--[[ 	--测试
	local list = {};
	for i=1,6 do
		local vo = {}
		vo.TimeID = i
		vo.naName = "";--math.random(2) % 2 == 0 and "哎呦啊0" or "傻逼呵呵"
		vo.nvName = "";--math.random(2) % 2 == 0 and "蹦擦擦" or "丫逗比"
		table.push(list,vo)
	end;	
	local voc = {};
	voc.time = time--GetServerTime();
	voc.TimeList = list;
	MarriagController:OnMarryTimeData(voc) ]]
end;

--确定设置婚礼时间
function MarriagController:ReqApplyMarry(toke,time,timeid)
	local msg = ReqApplyMarryMsg:new()
	msg.toke = toke;
	msg.time =  time;
	msg.timeIndex = timeid;
	-- msg.marryType = self.marryType;
	MsgManager:Send(msg)
	--print("确定设置婚礼时间")
	--trace(msg)
end;

--婚礼类型选择
-- MarriagController.marryType = 0;
function MarriagController:ReqMarryType(id)
	local msg = ReqMarryTypeMsg:new();
	msg.marryType = id;
	MsgManager:Send(msg)
	-- self.marryType = id;
	--print("婚礼类型选择")
	--trace(msg)
end;

--请求婚礼迅游
function MarriagController:ReqMarryTravel()
	local msg = ReqMarryTravelMsg:new();
	MsgManager:Send(msg)
	--print("请求婚礼迅游")
	--trace(msg)
end;

-- 赠送新人，红包
function MarriagController:ReqGiveRedPacket(type,num,blessing)
	local msg = ReqGiveRedPacketMsg:new()
	msg.type = type;
	msg.num = num;
	blessing = string.gsub(blessing,"\r",function()
		return "";
	end);
	msg.desc = blessing;
	MsgManager:Send(msg)
	--print("赠送新人，红包")
	--trace(msg)
end;

--收到邀请进入礼堂
function MarriagController:ReqEnterMarryChurch()
	local mapId = CPlayerMap:GetCurMapID();
	local cfg = t_map[mapId];
	if not cfg then return; end
	if cfg.type~=1 and cfg.type~=2 then
		FloatManager:AddNormal(StrConfig['marriage086']);
		return;
	end
	local msg = ReqEnterMarryChurchMsg:new();
	MsgManager:Send(msg)	
	--print("收到邀请进入礼堂")
	--trace(msg)
end;	

--邀请收到请柬的玩家进入，act
function MarriagController:ReqMarryInvite()
	local msg = ReqMarryInviteMsg:new();
	MsgManager:Send(msg)
	--print("邀请收到请柬的玩家进入，act")
	--trace(msg)
end;

--新人查看收到的红包
function MarriagController:ReqLookMarryRedPackets()
	local msg = ReqLookMarryRedPacketsMsg:new();
	MsgManager:Send(msg)
	--print("新人查看收到的红包")
	--trace(msg)
end;

--任何人，请求退出婚礼副本
function MarriagController:ReqOutMarryCopy()
	local msg = ReqOutMarryCopyMsg:new();
	MsgManager:Send(msg)
	--print("任何人，请求退出婚礼副本")
	--trace(msg)
	MainMenuController:UnhideRightTop();
end;

--双方确定，同意结婚
function MarriagController:ReqMarry(YesOrNot)
	local msg = ReqMarryMsg:new()
	msg.result = YesOrNot;
	MsgManager:Send(msg)
	--print("发送消息")
	--trace(msg)
end

--请求，结婚mv播放完毕
function MarriagController:ReqMarryMovEnd()
	local msg = ReqMarryMovEndMsg:new()
	MsgManager:Send(msg)
	--print("请求，结婚mv播放完毕")
	--trace(msg)
end;

--请求进入指定婚礼副本
function MarriagController:ReqMarryActEnterMsg(cid)
	local msg = ReqMarryActEnterMsg:new()
	msg.cid = cid ;
	MsgManager:Send(msg)
	--print("请求进入指定婚礼副本")
	--trace(msg)
end;

--请求使用自己的空请柬
function MarriagController:ReqMarryCardUse(list,cid)
	local msg = ReqMarryCardUseMsg:new()
	msg.rolelist = list;
	msg.cid = cid;
	MsgManager:Send(msg)
	--print("请求使用自己的空请柬")
	--trace(msg)
end;

--请求离婚
function MarriagController:ReqDivorce(type)
	local msg = ReqDivorceMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
	--print("请求离婚")
	--trace(msg)
end;

--请求查看结婚面板
function MarriagController:ReqMarryMainPanelInfo()
	local msg = ReqMarryMainPanelInfoMsg:new()
	MsgManager:Send(msg)
	--print("请求查看结婚面板")
	--trace(msg)
end;

--结婚请求发送宝箱
function MarriagController:ReqSendMarryBox()
	local msg = ReqSendMarryBoxMsg:new()
	MsgManager:Send(msg)
	--print("结婚请求发送宝箱")
	--trace(msg)
end;

--结婚后，使用戒指
function MarriagController:ReqMarryRingChang(ringId,cid)
	local msg = ReqMarryRingChangMsg:new()
	msg.id = ringId 
	msg.cid = cid
	MsgManager:Send(msg)
	--trace(msg)
	--print("结婚使用戒指")
end;

--双方协议离婚
function MarriagController:ReqDivorceXieYi(type)
	local msg = ReqDivorceXieYiMsg:new();
	msg.type = type;
	MsgManager:Send(msg)
end;


------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--婚戒强化
function MarriagController:ReqMarryRingStren()
	local msg = ReqMarryRingStrenMsg:new();
	MsgManager:Send(msg)
	--print("秦秋强化")
end;
--------------------配偶传送
--请求传送的配偶身边,求换线id
function MarriagController:ReqFlyToMate()
	local msg = ReqFlyToMateMsg:new()
	MsgManager:Send(msg)
	--print("请求传送的配偶身边,求换线id")
	--trace(msg)
end;

--请求传送，，客户端已切换同线
function MarriagController:ReqFlyToMateOk()
	local msg = ReqFlyToMateOkMsg:new();
	MsgManager:Send(msg)
	--print("请求传送，，客户端已切换同线")
	--trace(msg)
end;


--换线
MarriagController.isChangeLine = false;
function MarriagController:OnLayToMate(msg)
	--trace(msg)
	if msg.lineId > 0 then
		local curLine = CPlayerMap:GetCurLineID();
		if curLine == msg.lineId then 
			self:ReqFlyToMateOk();
		else
			self.isChangeLine = true;
			MainPlayerController:ReqChangeLine(msg.lineId);
		end
	elseif msg.lineId == -1 then--配偶不在线
		FloatManager:AddNormal( StrConfig["marriage213"]);
	elseif msg.lineId == -2 then--自己不在野外或者主城
		FloatManager:AddNormal( StrConfig["marriage056"]);
	elseif msg.lineId == -3 then--目标不在野外或者主城
		FloatManager:AddNormal( StrConfig["marriage057"]);
	elseif msg.lineId == -4 then --cd
		FloatManager:AddNormal( StrConfig["marriage215"]);
	end
end;

-- 换线成功
function MarriagController:OnLineChange()
	if self.isChangeLine == true then
		-- 进入活动
		self:ReqFlyToMateOk();
		self.isChangeLine = false;
	end;
	if self.isChangeLineLitang == true then 
		self:ReqEnterMarryChurchOK();
		self.isChangeLineLitang = false;
	end;
	
end;

--换线失败
function MarriagController:OnLineChangeFail()
	self.isChangeLine = false;
	self.isChangeLineLitang = false;
end

-- 巡游返回结果
function MarriagController:OnMarryTravelRes(msg)
	
	if msg.result == 0 then 
		--可以巡游开始
		if UIMarryNpcBox:IsShow() then 
			UIMarryNpcBox:Hide();
		end;
		
		--trace(msg)
		--print(debug.--traceback(),'哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈')
	elseif msg.result == -1 then 	
		FloatManager:AddNormal( StrConfig["marriage064"])	--与配偶组队，才可操作
	elseif msg.result == 2 then
		--迅游完成。显示npc
	elseif msg.result == -3 then 
		--队长
		FloatManager:AddNormal( StrConfig["marriage076"])	--队长操作
	elseif msg.result == -4 then 
		FloatManager:AddNormal( StrConfig["marriage107"])	--巡游时间未到
	elseif msg.result == -5 then 
		FloatManager:AddNormal( StrConfig["marriage216"])	--巡游时间未到
	elseif msg.result == -6 then 
		FloatManager:AddNormal( StrConfig["marriage225"])	--不在同场景or同线
	end;
end

-- 发送结婚宝箱返回结果
function MarriagController:OnSendMarryBoxRes(msg)
	--print('===================发送结婚宝箱返回结果')
	--trace(msg)
	if msg.result == 0 then
		UIMarrySendMoneyView:ReSetData();
	elseif msg.result == -1 then 
		FloatManager:AddNormal(StrConfig["marriage207"])
	elseif msg.result == -2 then 
		FloatManager:AddNormal(StrConfig["marriage206"])
	end
end