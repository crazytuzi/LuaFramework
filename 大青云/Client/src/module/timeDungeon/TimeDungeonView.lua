--[[
	2015年1月30日, PM 04:41:33
	wangyanwei
]]

_G.UITimerDungeon = BaseUI:new('UITimerDungeon');

function UITimerDungeon:Create()
	self:AddSWF("timeDungeonPanel.swf",true,nil);  --"center"
end

function UITimerDungeon:OnLoaded(objSwf,name)
	
	objSwf.teamPanel.tf1.text = UIStrConfig['timeDungeon1001'];
	objSwf.teamPanel.tf2.text = UIStrConfig['timeDungeon1002'];
	objSwf.teamPanel.tf3.text = UIStrConfig['timeDungeon1003'];
	objSwf.teamPanel.tf4.text = UIStrConfig['timeDungeon1004'];
	objSwf.teamPanel.tf5.text = UIStrConfig['timeDungeon1005'];
	objSwf.teamPanel.tf6.text = UIStrConfig['timeDungeon1006'];
	objSwf.teamPanel.tf7.text = UIStrConfig['timeDungeon1007'];
	
	objSwf.passwordPanel.tf1.text = UIStrConfig['timeDungeon1004'];
	objSwf.passwordPanel.tf2.text = UIStrConfig['timeDungeon1006'];
	
	objSwf.teameInfoPanel.tf1.text = UIStrConfig['timeDungeon1001'];
	objSwf.teameInfoPanel.tf2.text = UIStrConfig['timeDungeon1002'];

	objSwf.teamListPanel._visible = false;
	objSwf.teameInfoPanel._visible = false;
	objSwf.teamPanel._visible = false;
	-- 屏蔽倍率等信息
	objSwf.teamPanel.exp1._visible = false
	objSwf.teamPanel.exp2._visible = false
	objSwf.teamPanel.scoreLoader._visible = false
	objSwf.teamPanel.tf1._visible = false
	objSwf.teamPanel.tf2._visible = false
	objSwf.teamPanel.btnitem._visible = false
	objSwf.passwordPanel._visible = false;
	objSwf.txt_time.text = t_monkeytime[1].opentime;
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig['timeDungeon0100'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	-- objSwf.txt_openTime.text = UIStrConfig['timeDungeon50'];
	-- objSwf.txt_openLevel.text = UIStrConfig['timeDungeon51'];
	-- objSwf.txt_downInfo.text = UIStrConfig['timeDungeon300'];
	objSwf.txt_level.htmlText = string.format(UIStrConfig['timeDungeon1'],t_funcOpen[20].open_prama);
	for i = 1 , 5 do
		objSwf['btnState_' .. i ].click = function () self:OnStateClick(i); end
		objSwf['btnState_' .. i ].rewardRollOver = function () TipsManager:ShowItemTips(t_monkeytime[i].key_id); end
		objSwf['btnState_' .. i ].rewardRollOut = function () TipsManager:Hide(); end
		-- 屏蔽门票功能
		objSwf['btnState_' .. i ].visible = false
		-- 屏蔽钥匙文本
		objSwf['txt_' .. i]._visible = false
		-- objSwf['btnState_' .. i ].htmlLabel = UIStrConfig['timeDungeon' .. 3+i];
	end
	objSwf.randomList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.randomList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.btn_join.click = function () self:OnJoinClick(); end  --进入单人请求
	-- objSwf.btn_join._visible = false
	-- objSwf.bg.hitTestDisable = true;
	
	--////////房间
	objSwf.teamListPanel.btn_team.click = function () self:OnShowRoomClick(); end
	objSwf.teamPanel.btn_closeTeam.click = function () self:OnCloseEstPanel(); end
	objSwf.teamPanel.btn_cancel.click = function () self:OnCloseEstPanel(); end
	
	objSwf.teamPanel.btn_est.click = function () self:OnEstTeam(); end 
	
	objSwf.teamListPanel.teamList.centerClick = function (e) self:OnCenterRoom(e.item.roomID); end
	objSwf.teamListPanel.btn_quick.click = function () self:QuickTeam(); end
	objSwf.teameInfoPanel.btn_quitTeam.click = function () TimeDungeonController:QuitTimeDungeonRoom(DungeonConsts.fubenType_lingguang); end
	objSwf.teameInfoPanel.btn_state.click = function () self:OnChangeState(); end
	objSwf.teameInfoPanel.teamList.outClick = function (e) TeamController:Kick(e.item.roleID) end
	
	objSwf.teameInfoPanel.btnitem.rollOver = function () TipsManager:ShowItemTips(t_monkeytime[self.stateIndex].key_id); end
	objSwf.teameInfoPanel.btnitem.rollOut = function () TipsManager:Hide(); end
	
	-- 屏蔽经验倍率，难度
	objSwf.teameInfoPanel.exp1._visible = false
	objSwf.teameInfoPanel.scoreLoader._visible = false
	objSwf.teameInfoPanel.icon._visible = false
	objSwf.teameInfoPanel.tf1._visible = false
	objSwf.teameInfoPanel.tf2._visible = false
	objSwf.teameInfoPanel.btnitem._visible = false
	
	objSwf.teamPanel.btnitem.rollOver = function () TipsManager:ShowItemTips(t_monkeytime[self.stateIndex].key_id); end
	objSwf.teamPanel.btnitem.rollOut = function () TipsManager:Hide(); end
	objSwf.teameInfoPanel.btn_limilt.disabled = true;
	-- objSwf.teameInfoPanel.btn_start.disabled = true;
	objSwf.teameInfoPanel.btn_start.click = function () 
		TimeDungeonController:OnIsmaxPlayerAutuStart();
	end;
	objSwf.teamListPanel.btn_change.click = function ()
		self:OnDrawAllTeam();
	end
	self:OnStateClick(1);   --默认选择第一个物品
	
	--刷新队伍信息
	objSwf.teamListPanel.btn_updata.click = function () self:teamUpData(); end
	--世界呐喊
	objSwf.teameInfoPanel.btn_world.click = function () self:OnToShout(); end
	
	--合成凭证
	objSwf.btn_pingzheng.click = function () FuncManager:OpenFunc(FuncConsts.HeCheng,false,180500002); end

	-- 屏蔽合成凭证
	objSwf.btn_pingzheng._visible = false
	objSwf.daojuBtn._visible = false
	objSwf.exp1._visible = false
	objSwf.exp2._visible = false
	objSwf.scoreLoader._visible = false

end

--发送呐喊
function UITimerDungeon:OnToShout()
	------------------CD  ....自己有
		
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.noticeTimeKey then
		FloatManager:AddNormal(StrConfig["timeDungeon086"])
		return
	end
	self.noticeTimeKey = TimerManager:RegisterTimer(function()
		TimerManager:UnRegisterTimer(self.noticeTimeKey);
		self.noticeTimeKey= nil;
	end,600000);
	ChatController:OnSendCWWorldNotice(ChatConsts.WorldNoticeTimeDungeon);
end

--请求准备状态
UITimerDungeon.enterState = true;
function UITimerDungeon:OnChangeState()
	local state = TimeDungeonModel:GetInTeamState();
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then
		if TimeDungeonModel:GetEnterNum() < 1 then
			FloatManager:AddNormal( StrConfig["timeDungeon050"] );
			return
		end
		-- local data = TimeDungeonModel:GetSelfTeamData();
		-- TimeDungeonController:OnEnterTimeDungeon(data.dungeonIndex);
		--[[
		if not self.enterState then FloatManager:AddNormal( StrConfig['timeDungeon017'] )return end
		local func = function ()
			self.enterState = true;
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		if self.timeKey then
			return
		end
		self.timeKey = TimerManager:RegisterTimer(func,3000,1);
		--]]
		TimeDungeonController:OnSendEnterRoomStart();
		-- self.enterState = false;
		return
	end
	if state then
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_lingguang,1);			--如果在准备状态  就取消
		return
	end
	local capData = TeamModel:GetCaptainInfo();
	if not capData then self:Hide(); return end
	local line = capData.line;
	local myLine = CPlayerMap:GetCurLineID();
	
	if myLine == line and not state then 
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_lingguang,0);			--如果在一条线并不准备  发送准备
		return
	end
	
	local func = function () 										--不再一条线  就切线并准备
		if myLine ~= line then
			MainPlayerController:ReqChangeLine(line);
		else
			TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_lingguang,0);
		end
	end
	self.preConfirmID = UIConfirm:Open(StrConfig['timeDungeon1101'],func);
end

--请求刷新
UITimerDungeon.updataState = true;
function UITimerDungeon:teamUpData()
	if not self.updataState then FloatManager:AddNormal( StrConfig['timeDungeon017'] )return end
	local func = function ()
		self.updataState = true;
		TimerManager:UnRegisterTimer(self.timeKey2);
		self.timeKey2 = nil;
	end
	if self.timeKey2 then
		return
	end
	self.timeKey2 = TimerManager:RegisterTimer(func,3000,1);
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_lingguang)
	self.updataState = false;
	return
end

--进入房间
function UITimerDungeon:OnCenterRoom(teamID)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local enterNum = TimeDungeonModel:GetEnterNum();
	if enterNum < 1 then FloatManager:AddNormal( StrConfig["timeDungeon050"] ); return end
	local cfg = TimeDungeonModel:GetTeamData(teamID);
	if not cfg then return end
	if cfg.lock == 1 then
		objSwf.passwordPanel._visible = false;
		TimeDungeonController:OnCenterTimeDungeonTeam(teamID,'');
		return
	end
	objSwf.passwordPanel._visible = false;  --屏蔽，组队副本改成单人副本 2016/12/5
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel.btn_sendPass.click = function () 
		TimeDungeonController:OnCenterTimeDungeonTeam(teamID,objSwf.passwordPanel.txt_password.text);
		objSwf.passwordPanel._visible = false;
	end
	objSwf.passwordPanel.btn_close.click = function ()
		objSwf.passwordPanel.txt_password.text = '';
		objSwf.passwordPanel._visible = false;
	end
	objSwf.passwordPanel.btn_cancel.click = function ()
		objSwf.passwordPanel.txt_password.text = '';
		objSwf.passwordPanel._visible = false;
	end
end

--快速加入
function UITimerDungeon:QuickTeam()
	if TimeDungeonModel:GetEnterNum() < 1 then
		FloatManager:AddNormal( StrConfig["timeDungeon050"] );
		return 
	end
	TimeDungeonController:QuickTimeDungeonRoom(DungeonConsts.fubenType_lingguang);
end

--创建房间
function UITimerDungeon:OnEstTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	--[[
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	if cfg[self.stateIndex] < t_monkeytime[self.stateIndex].key_num then
		FloatManager:AddNormal( StrConfig['timeDungeon053'] );
		return
	end
	--]]
	
	local dungeonIndex = self.stateIndex;
	local password;
	local txt1 = objSwf.teamPanel.txt_password.text;
	if txt1 == '' then
		password = '';
	else
		password = txt1;
	end
	local attLimit;
	local txt2 = objSwf.teamPanel.txt_attLimit.text;
	if txt2 == '' then
		attLimit = '0';
	else
		attLimit = txt2;
	end
	TimeDungeonController:SendTimeDungeonRoomBuild(DungeonConsts.fubenType_lingguang,dungeonIndex,password,toint(attLimit));
	objSwf.teamPanel._visible = false;
	self:OnCloseEstPanel();
end

--关闭创建房间界面
function UITimerDungeon:OnCloseEstPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:ClearPassAttTxt();
	objSwf.teamPanel._visible = false;
end

--显示创建房间界面
function UITimerDungeon:OnShowRoomClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local data = TimeDungeonModel:GetSelfTeamData()
	if data.dungeonIndex ~= nil then
		if data.dungeonIndex < 1 or data.dungeonIndex >5 then   --特殊处理，因为组队爬塔dungeonIndex非nil，而是副本的id
			FloatManager:AddNormal( StrConfig['timeDungeon085'] );
			return
		end
	end
	if TimeDungeonModel:GetEnterNum() < 1 then
		FloatManager:AddNormal( StrConfig['timeDungeon050'] );
		return
	end
	
	-- 取消物品限制
	
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	--[[
	if cfg[self.stateIndex] < t_monkeytime[self.stateIndex].key_num then
		FloatManager:AddNormal( StrConfig['timeDungeon053'] );
		return
	end
	--]]
	
	if cfg[self.stateIndex] >= t_monkeytime[self.stateIndex].key_num then
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1005'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	else
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1004'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	end
	if objSwf.teamPanel._visible then return end
	objSwf.teamPanel._visible = false;    --屏蔽，组队副本改成单人副本 2016/12/5
	local name = MainPlayerModel.humanDetailInfo.eaName;
	objSwf.teamPanel.txt_name.htmlText = name;
	objSwf.teamPanel.txt_num.htmlText = string.format(StrConfig['timeDungeon1002'],TimeDungeonModel:GetEnterNum(),TimeDungeonModel:GetTotalEnterNum());
	objSwf.teamPanel.scoreLoader.num = t_monkeytime[self.stateIndex].reward_radio;
	
	local color = TipsConsts:GetItemQualityColor(self.stateIndex - 1);
	objSwf.teamPanel.txt_title.htmlText = string.format(StrConfig['timeDungeon1006'],color,'天神战场');  --StrConfig['timeDungeon101' .. self.stateIndex]
end

function UITimerDungeon:OnShow()
	-- self:OnChangeAttTxt();
	
	-- 选中当前难度的道具
	local dungeonData = TimeDungeonModel:GetSelfTeamData();
	if not dungeonData.dungeonIndex then
		self:OnStateClick(1)
	else
		self:OnStateClick(dungeonData.dungeonIndex)
	end
	-- PlayerInfo:new();
	-- WriteLog(LogType.Normal,true,'-------------houxudong',MainPlayerModel.humanDetailInfo)
	-- trace(MainPlayerModel.humanDetailInfo)
	self:OnDrawKeyItem();--钥匙文本
	self:OnChangeItemTxt();
	TimeDungeonController:OnSendEnterNum();
	--self:OnChangeEnterNum();
	
	-- self:OnShowRightList();
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_lingguang);
	self:ShowDungeonWorkOut()
end

function UITimerDungeon:ShowDungeonWorkOut( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local imgUrl = ''
	local funcID = 0
	local name = ''
	for k,v in pairs(DungeonConsts.DungeonOpenFuncIdAnaImgUrl) do
		if v[1] == FuncConsts.teamExper then
			imgUrl = v[2]
			funcID = v[3]
			name   = v[4]
			break;
		end
	end
	local imgWorkOutBgURL = ResUtil:GetAllDungeonOutPutImg( imgUrl );
	if objSwf.outputLoader.source ~= imgWorkOutBgURL then
		objSwf.outputLoader.source = imgWorkOutBgURL
	end
	objSwf.toGet.click = function() 
		if not FuncManager:GetFuncIsOpen(funcID) then
			local cfg = t_funcOpen[funcID]
			if not cfg then
				Debug("not find cfgData in t_funcOpen:",funcID)
			return
			end
			FloatManager:AddNormal(string.format(StrConfig['shopExtra007'],cfg.open_level,cfg.name))
			return
		end
		FuncManager:OpenFunc(funcID,true)
	end
	objSwf.openOtherFunc.htmlText = string.format("查看");
	objSwf.toGet.htmlLabel = string.format("<font><u><font color='#00ff00'>我的%s</font></u></font>",name);
end

--钥匙文本
function UITimerDungeon:OnDrawKeyItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1, 5 do
		local vo = {};
		vo.id = t_monkeytime[i].key_id;
		vo.itemUrl = ResUtil:GetTimeDungeonSmallIcon(i)
		local rewardSlotVO = RewardSlotVO:new();
		rewardSlotVO.id = vo.id;
		rewardSlotVO.count = 0;
		rewardSlotVO.bind = false;
		objSwf['btnState_' .. i]:setData(UIData.encode(vo) .. '*' .. rewardSlotVO:GetUIData());
		objSwf['btnState_' .. i].visible = false
	end
end

--右侧面板显示隐藏
function UITimerDungeon:OnShowRightList(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	UIConfirm:Close(self.confirmid);
	for i = 1 , 5 do
		objSwf['btnState_' .. i ].disabled = false;
	end
	local inTeam = TeamModel:IsInTeam();
	objSwf.passwordPanel._visible = false;
	local data = TimeDungeonModel:GetSelfTeamData();
	-- print("状态.......",state)
	if state == 1 then
		objSwf.teameInfoPanel.btn_start.selected = false;
		objSwf.teamListPanel._visible = false;  --屏蔽，组队副本改成单人副本 2016/12/5
		objSwf.teameInfoPanel._visible = false;
		self:OnDrawAllTeam();
		local maxDungeonIndex = TimeDungeonModel:GetMaxTimeDungeon();
		-- print("最大副本难度.......",maxDungeonIndex)
		if not maxDungeonIndex then
			objSwf['btnState_' .. 1].selected = true;
			self.stateIndex = 1;
		else
			objSwf['btnState_' .. maxDungeonIndex].selected = true;
			self.stateIndex = maxDungeonIndex;
		end
		self:OnStateClick(self.stateIndex);
		return
	end
	objSwf.teamListPanel._visible = false;
	objSwf.teameInfoPanel._visible = false;  --屏蔽，组队副本改成单人副本 2016/12/5
	self:OnDrawMyTeam();
	self:OnChangePrepareState();
	self:OnSetMyTeamData();
	self:ClearPassAttTxt();
end

--自己队伍的xinxi
function UITimerDungeon:OnSetMyTeamData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local data = TimeDungeonModel:GetSelfTeamData();
	if objSwf.teameInfoPanel.icon.source == ResUtil:GetTimeDungeonTeamNDIcon(data.dungeonIndex) then
		return
	end
	objSwf.teameInfoPanel.icon.source = ResUtil:GetTimeDungeonTeamNDIcon(data.dungeonIndex)
end

--绘制自己队伍list
function UITimerDungeon:OnDrawMyTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myTeam = TimeDungeonModel:GetSelfTeamPlayerData();
	objSwf.teameInfoPanel.teamList.dataProvider:cleanUp();
	for i , v in ipairs(myTeam) do
		local vo = {};
		vo.roleID = v.roleID;
		-- vo.myID = MainPlayerController:GetRoleID();
		vo.myState = MainPlayerController:GetRoleID() == TeamModel:GetCaptainId();
		-- print(MainPlayerController:GetRoleID())
		-- print(TeamModel:GetCaptainId())
		-- print(vo.myState)
		-- debug.debug();
		vo.teamInfo = v.memName;
		vo.prepare = v.roomType;
		vo.level = v.level;
		vo.att = string.format(StrConfig['timeDungeon1022'],v.attLimit);
		vo.headUrl = ResUtil:GetHeadIcon(v.headID,false,true);
		vo.cap = v.cap;
		vo.line = v.line;
		vo.lineStr = string.format(StrConfig['timeDungeon1023'],vo.line);
		objSwf.teameInfoPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.teameInfoPanel.teamList:invalidateData();
	
	--人数文本   --物品消耗
	local data = TimeDungeonModel:GetSelfTeamData();
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	if cfg[data.dungeonIndex] >= t_monkeytime[data.dungeonIndex].key_num then
		objSwf.teameInfoPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1005'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. data.dungeonIndex + 3])))
	else
		objSwf.teameInfoPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1004'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. data.dungeonIndex + 3])))
	end
	
	self:OnDrawMyTeamData();
end

--改变单个队员的信息
function UITimerDungeon:OnChangePlayerItem(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerIndex = 1;
	
	local memberCfg = nil;--TimeDungeonModel:GetSelfTeamPlayerData()[index];
	for i , member in ipairs(TimeDungeonModel:GetSelfTeamPlayerData()) do
		if member.index == index then
			memberCfg = member;
			playerIndex = i;
		end
	end
	if not memberCfg then return end
	if not memberCfg or memberCfg == {} then 
		trace(TeamModel:GetMemberList()); 
		print('Error~~~~not player ：TeamIndex-----：' .. index); 
		return 
	end
	local vo = {};
	vo.teamInfo = memberCfg.memName;
	vo.roleID = memberCfg.roleID;
	vo.prepare = memberCfg.roomType;
	vo.myState = MainPlayerController:GetRoleID() == TeamModel:GetCaptainId();
	vo.level = memberCfg.level;
	vo.att = string.format(StrConfig['timeDungeon1022'],memberCfg.attLimit);
	vo.headUrl = ResUtil:GetHeadIcon(memberCfg.headID,false,true);
	vo.cap = memberCfg.cap;
	vo.line = memberCfg.line;
	vo.lineStr = string.format(StrConfig['timeDungeon1023'],memberCfg.line);
	objSwf.teameInfoPanel['icon' .. playerIndex]:setData(UIData.encode(vo));
	-- trace(vo);
end

--自己队伍的总信息
function UITimerDungeon:OnDrawMyTeamData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local teamCfg = TimeDungeonModel:GetSelfTeamPlayerData();
	local attNum = 0;
	for i , v in ipairs(teamCfg) do
		attNum = attNum + v.attLimit;
		-- objSwf.teameInfoPanel['vacancy' .. i]
	end
	for i = 1 , 4  do
		-- objSwf.teameInfoPanel['vacancy' .. i]._visible = i > #teamCfg;
	end
	objSwf.teameInfoPanel.maxAtt.num = attNum;   -- 总战力
	objSwf.teameInfoPanel.txt_playerNum.text = #teamCfg .. '/4';
	local campCfg = TeamModel:GetCaptainInfo();
	if not campCfg then return end
	local name = campCfg.roleName;
	objSwf.teameInfoPanel.txt_name.htmlText = string.format(StrConfig['timeDungeon1001'],name);
	
	local data = TimeDungeonModel:GetSelfTeamData();
	-- objSwf.teameInfoPanel.scoreLoader.num = t_monkeytime[data.dungeonIndex].reward_radio;
	objSwf.teameInfoPanel.scoreLoader.htmlText = t_monkeytime[data.dungeonIndex].reward_radio..'倍';
	objSwf.teameInfoPanel.btn_limilt.selected = data.lockAttNum ~= 0;
	if data.lock == 0 then
		objSwf.teameInfoPanel.lock._visible = true;
	else
		objSwf.teameInfoPanel.lock._visible = false;
	end
	if data.lockAttNum == 0 then
		objSwf.teameInfoPanel.tf_limit.text = UIStrConfig['timeDungeon1010'];
	else
		objSwf.teameInfoPanel.tf_limit.text = data.lockAttNum;
	end
	
	if TeamModel:GetCaptainId() ~= MainPlayerController:GetRoleID() then
		objSwf.teameInfoPanel.btn_start.disabled = true;
		objSwf.teameInfoPanel.btn_world.visible = false;	--呐喊按钮
		if data.autoStart == 0 then
			objSwf.teameInfoPanel.btn_start.icon_aotu._visible = true;
		else
			objSwf.teameInfoPanel.btn_start.icon_aotu._visible = false;
		end
	else
		objSwf.teameInfoPanel.btn_start.disabled = false;
		objSwf.teameInfoPanel.btn_world.visible = true;	--呐喊按钮
	end
end

--自己准备按钮状态
function UITimerDungeon:OnChangePrepareState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local state = TimeDungeonModel:GetInTeamState();
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then
		objSwf.teameInfoPanel.btn_state.label = StrConfig['timeDungeon202'];
	else
		if state then
			objSwf.teameInfoPanel.btn_state.label = StrConfig['timeDungeon201'];
		else
			objSwf.teameInfoPanel.btn_state.label = StrConfig['timeDungeon200'];
		end
	end
end

--绘制所有队伍list
function UITimerDungeon:OnDrawAllTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- TimeDungeonModel:SetAllTeamData({})
	
	local teamlist = {};
	if objSwf.teamListPanel.btn_change.selected then
		teamlist = TimeDungeonModel:GetAllOpenTeam();
	else
		teamlist = TimeDungeonModel:GetAllTeamData();
	end
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();
	for i , v in ipairs(teamlist) do
		local vo = {};
		vo.teamInfo = string.format(StrConfig['timeDungeon1017'],v.roomNum);
		vo.title = string.format(StrConfig['timeDungeon1018'],TipsConsts:GetItemQualityColor(v.dungeonIndex - 1),StrConfig['timeDungeon101' .. v.dungeonIndex]);
		vo.name = string.format(StrConfig['timeDungeon1001'],v.capName);
		vo.att = string.format(StrConfig['timeDungeon1016'],v.att);
		vo.lock = v.lock == 0;
		vo.roomID = v.roomID;
		objSwf.teamListPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.teamListPanel.teamList:invalidateData();
end

function UITimerDungeon:OnChangeEnterNum()
	local objSwf = self.objSwf;
	objSwf.txt_num.htmlText = string.format(StrConfig['timeDungeon002'],TimeDungeonModel:GetEnterNum() > 0 and "#00ff00" or "#ff0000" ,TimeDungeonModel:GetEnterNum(),TimeDungeonModel:GetTotalEnterNum( ));
end

--难度切换
UITimerDungeon.stateIndex = nil;
UITimerDungeon.oldIndex = nil;
function UITimerDungeon:OnStateClick(index)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self:OnChangeList(index);
	self:OnChangeAttTxt(index);
	-- if self.stateIndex ~= index then
		-- self.stateIndex = index;
	-- end
	objSwf['btnState_' .. index ].selected = true;
	if self.stateIndex == index then
		print(self.stateIndex,index)
		-- debug.debug();
		return
	end
	if self.stateIndex == self.oldIndex and self.oldIndex ~= nil then
		print(self.stateIndex,self.oldIndex)
		-- debug.debug();
		return
	end
	self.stateIndex = index;
	for i = 1 , 5 do
		if i == index then
			objSwf['btnState_' .. i ].htmlLabel = string.format(UIStrConfig['timeDungeon100'],UIStrConfig['timeDungeon' .. (3+i)]);
		else
			objSwf['btnState_' .. i ].htmlLabel = UIStrConfig['timeDungeon' .. (3+i)];
		end
	end
	local data = TimeDungeonModel:GetSelfTeamData()
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then
		local data = TimeDungeonModel:GetSelfTeamData()
		if not data.dungeonIndex then
			return
		end
		if data.dungeonIndex == index then
			return;
		end	
		local cfg = TimeDungeonModel:OnGetRoleItemNum();
		if cfg[self.stateIndex] < t_monkeytime[self.stateIndex].key_num then
			FloatManager:AddNormal( StrConfig['timeDungeon058'] );
			return
		end
		local func = function ()
			if not objSwf then return end
			TimeDungeonController:OnChangeRoomDiff(self.stateIndex);
			for i = 1 , 5 do
				objSwf['btnState_' .. i ].disabled = false;
			end
		end
		local cancel = function ()
			if not objSwf then return end
			for i = 1 , 5 do
				objSwf['btnState_' .. i ].disabled = false;
			end
		end
		self.confirmid = UIConfirm:Open(StrConfig['timeDungeon084'],func,cancel);
		for i = 1 , 5 do
			objSwf['btnState_' .. i ].disabled = true;
		end
	end
end

--切换list
function UITimerDungeon:OnChangeList(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_monkeytime[index];
	local rewardList = RewardManager:Parse(cfg.firstReward);
	objSwf.randomList.dataProvider:cleanUp();
	objSwf.randomList.dataProvider:push(unpack(rewardList));
	objSwf.randomList:invalidateData();
end

--进入副本请求
function UITimerDungeon:OnJoinClick()
	if TimeDungeonModel:GetEnterNum() < 1 then
		FloatManager:AddNormal( StrConfig["timeDungeon050"] );
		return
	end
	self:OnEnterDungeon()
	--[[
	if TeamModel:IsInTeam() then
		FloatManager:AddNormal( StrConfig['timeDungeon1019'] );
		return
	end
	local func = function () 
		self:OnEnterDungeon();
	end
	self.oneConfirmID = UIConfirm:Open(string.format(StrConfig['timeDungeon010']),func);
	--]]
end

--反复确认 
function UITimerDungeon:OnEnterDungeon()
	-- 单人进入副本
	TimeDungeonController:AllZuiduiDungeonSignalEnter(DungeonConsts.fubenType_lingguang)
end

--换算时间
function UITimerDungeon:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

--钥匙文本
function UITimerDungeon:OnChangeItemTxt()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	for i = 1 , 5 do
		if cfg[i] >= t_monkeytime[i].key_num then
			objSwf['txt_' .. i].htmlText = string.format(StrConfig['timeDungeon006'],cfg[i],t_monkeytime[i].key_num)
		else
			objSwf['txt_' .. i].htmlText = string.format(StrConfig['timeDungeon005'],cfg[i],t_monkeytime[i].key_num)
		end
	end
end

--推荐战斗力
function UITimerDungeon:OnChangeAttTxt(index)
	local objSwf = self.objSwf ;
	-- objSwf.txt_minAtt.num = t_monkeytime[self.stateIndex].min_att;
	objSwf.scoreLoader.num = t_monkeytime[index].reward_radio;
end

-- function UITimerDungeon:IsTween()
-- 	return true;
-- end

-- function UITimerDungeon:GetPanelType()
-- 	return 1;
-- end

function UITimerDungeon:IsShowSound()
	return true;
end

function UITimerDungeon:IsShowLoading()
	return true;
end

-- function UITimerDungeon:GetWidth()
-- 	return 910;
-- end

-- function UITimerDungeon:GetHeight()
-- 	return 600;
-- end

function UITimerDungeon:OnChangeData()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if not objSwf.teamPanel._visible then return end
	self:OnShowRoomClick();
end

function UITimerDungeon:OnHide()
	local objSwf = self.objSwf;
	objSwf.teamPanel._visible = false;
	self:ClearPassAttTxt();
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel._visible = false;
	self.oldIndex = nil;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIConfirm:Close(self.confirmid);
	UIConfirm:Close(self.oneConfirmID);
	UIConfirm:Close(self.preConfirmID);
	for i = 1 , 5 do
		objSwf['btnState_' .. i ].disabled = false;
	end
end

function UITimerDungeon:ClearPassAttTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.teamPanel.txt_password.text = '';
	objSwf.teamPanel.txt_attLimit.text = '';
end

--玩家换线
function UITimerDungeon:OnChangeLine()
	local data = TimeDungeonModel:GetSelfTeamData()
	if data.dungeonIndex then
		local capData = TeamModel:GetCaptainInfo();
		if not capData then self:Hide(); return end
		local line = capData.line;
		local myLine = CPlayerMap:GetCurLineID();
		if myLine == line then
			TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_lingguang,0);
		end
	end
end

function UITimerDungeon:OnKeyChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	if cfg[self.stateIndex] >= t_monkeytime[self.stateIndex].key_num then
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1005'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	else
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1004'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	end
end

function UITimerDungeon:HandleNotification(name,body)
	if name == NotifyConsts.BagItemNumChange then
		for i , v in pairs(t_monkeytime) do
			if v.key_id == body.id then
				self:OnChangeItemTxt();
				self:OnKeyChange();
				local data = TimeDungeonModel:GetSelfTeamData()
				if data.dungeonIndex then
					self:OnDrawMyTeam();
				end
				return 
			end
		end
	elseif name == NotifyConsts.TimerDungeonEnterNum then
		self:OnChangeEnterNum();
	elseif name == NotifyConsts.TimeDungeonTeamRooomData then	--所有房间信息
		self:OnShowRightList(1);
	elseif name == NotifyConsts.TimeDungeonTeamMyRoom then		--自己的房间信息
		self:OnShowRightList(2);
	elseif name == NotifyConsts.TimeDungeonRoomPrepare then		--点击准备的返回
		self:OnChangePrepareState();
	-- elseif name == NotifyConsts.QuitTimeDungeonRoom then		--退出房间返回
		-- TimeDungeonController:TimeDungeonRoom();
	elseif name == NotifyConsts.MemberChange then
		if TeamConsts.TimeDungeonAttrs[ body.attrType ] then
			local data = TimeDungeonModel:GetSelfTeamData()
			if data.dungeonIndex then
				self:OnChangePlayerItem(body.index);
				self:OnChangePrepareState();
			end
		end
	elseif name == NotifyConsts.TeamMemberAdd then
		local data = TimeDungeonModel:GetSelfTeamData()
		if data.dungeonIndex then
			self:OnDrawMyTeam();
		end
	elseif name == NotifyConsts.TeamMemberRemove then
		local data = TimeDungeonModel:GetSelfTeamData()
			if data.dungeonIndex then
				self:OnDrawMyTeam();
			end
	elseif name == NotifyConsts.TeamQuit then
		TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_lingguang);
	elseif name == NotifyConsts.SceneLineChanged then
		self:OnChangeLine();
	end
end

function UITimerDungeon:ListNotificationInterests()
	return {
		NotifyConsts.BagItemNumChange,
		NotifyConsts.TimerDungeonEnterNum,
		NotifyConsts.TimeDungeonTeamRooomData,  --所有房间信息
		NotifyConsts.TimeDungeonTeamMyRoom,		--自己的房间信息
		NotifyConsts.TimeDungeonRoomPrepare,	--点击准备的返回
		-- NotifyConsts.QuitTimeDungeonRoom,		--退出房间返回
		NotifyConsts.MemberChange,				--更新玩家信息
		NotifyConsts.TeamMemberAdd,				--添加一个队员
		NotifyConsts.TeamMemberRemove,			--移除队员
		NotifyConsts.TeamQuit,					--主玩家退出
		NotifyConsts.SceneLineChanged,			--玩家发生换线
		}
end