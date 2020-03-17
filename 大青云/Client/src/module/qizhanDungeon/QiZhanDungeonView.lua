--[[
	2015年11月13日23:54:55
	2016年6月29日 14:48:11
	wangyanwei&houxudong
	骑战副本
	爬塔副本
]]

_G.UIQiZhanDungeon = BaseUI:new('UIQiZhanDungeon');

UIQiZhanDungeon.numlayer = 1;   -- 默认是1层
UIQiZhanDungeon.original_x = 0 ;    -- 层的初始位置 
function UIQiZhanDungeon:Create()
	self:AddSWF('qizhanDungeonPanel.swf',true,nil);
end

function UIQiZhanDungeon:OnLoaded(objSwf)
	objSwf.teamPanel.tf3.text = UIStrConfig['timeDungeon1003'];
	objSwf.teamPanel.tf4.text = UIStrConfig['timeDungeon1004'];
	objSwf.teamPanel.tf5.text = UIStrConfig['timeDungeon1005'];
	objSwf.teamPanel.tf6.text = UIStrConfig['timeDungeon1006'];
	objSwf.teamPanel.tf7.text = UIStrConfig['timeDungeon1007'];

	objSwf.passwordPanel.tf1.text = UIStrConfig['timeDungeon1004'];
	objSwf.passwordPanel.tf2.text = UIStrConfig['timeDungeon1006'];


	objSwf.txt_1.htmlText = StrConfig['qizhanDungeon001'];
	local cfg = t_funcOpen[FuncConsts.QiZhanDungeon];
	if cfg then
		objSwf.txt_2.htmlText = string.format(StrConfig['qizhanDungeon002'],cfg.open_level);
	end
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_rank.click = function () self:OnShowRankPanel(); end      --排行榜
	objSwf.btn_update.click = function () self:OnUpdateListTeam(); end   --刷新队伍列表
	
	objSwf.createTeamPanel.btn_world.click = function () self:OnToShout(); end  --世界呐喊

	objSwf.btnPre.click = function () self:OnBtnPreTeam(); end
	objSwf.btnNext.click = function () self:OnBtnNextTeam(); end  
	objSwf.btn_quickEnter.click = function () self:OnEnterQiZhanDungeonClick(); end
	objSwf.btn_info.rollOver = function () TipsManager:ShowBtnTips(StrConfig['qizhanDungeon050'],TipsConsts.Dir_RightDown); end
	objSwf.btn_info.rollOut = function () TipsManager:Hide(); end
	objSwf.createTeamPanel.btn_quitTeam.click = function () TimeDungeonController:QuitTimeDungeonRoom(DungeonConsts.fubenType_pata); end   --退出组队
	objSwf.createTeamPanel.teamList.outClick = function (e) TeamController:Kick(e.item.roleID) end  --踢人

	
	objSwf.teamPanel._visible = false;
	objSwf.passwordPanel._visible = false;

	objSwf.createTeamPanel.btn_start.click = function () 
		TimeDungeonController:OnIsmaxPlayerAutuStartJustForPata();
	end;

	objSwf.createTeamPanel.btn_state.click = function () self:OnChangeState(); end
	-- 创建房间
	objSwf.btn_createTeam.click = function () self:OnShowRoomClick(); end
	objSwf.teamPanel.btn_closeTeam.click = function () self:OnCloseEstPanel(); end
	objSwf.teamPanel.btn_cancel.click = function () self:OnCloseEstPanel(); end
	objSwf.teamPanel.btn_est.click = function () self:OnEstTeam(); end 
	objSwf.teamListPanel.teamList.centerClick = function (e) self:OnCenterRoom(e.item.roomID); end
	self.original_x = objSwf.cengIcon._x;
	-- 屏蔽层数和关卡特点 2016/12/5
	objSwf.btnPre._visible = false
	objSwf.di._visible = false
	objSwf.numFight._visible = false
	objSwf.cengIcon._visible = false
	objSwf.btnNext._visible = false
	objSwf.tedian._visible = false
	objSwf.tfDetail._visible = false
	--进入单人请求
	objSwf.btn_join.click = function () self:OnJoinClick(); end  
end

function UIQiZhanDungeon:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.createTeamPanel._visible = false;                                -- 特殊处理
	objSwf.panel_rank._visible = false                                       -- 默认打开时显示排行榜
	QiZhanDungeonController:SendQiZhanDungeonData();                        -- 请求爬塔数据
	
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_pata);    -- 请求在线房间信息
	self:ShowBestTeam()    --最强队伍
	self:ShowRankList()	   --排行榜
	self:InitIconPos(objSwf)
	self:ShowDungeonWorkOut()
end

function UIQiZhanDungeon:ShowDungeonWorkOut( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local imgUrl = ''
	local funcID = 0
	local name = ''
	for k,v in pairs(DungeonConsts.DungeonOpenFuncIdAnaImgUrl) do
		if v[1] == FuncConsts.teamDungeon then
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

function UIQiZhanDungeon:InitSpeicalPos(objSwf)
	if self.numlayer then
		if self.numlayer >= 20 then
			objSwf.cengIcon._x = self.original_x + 10;
		end
	end
end

function UIQiZhanDungeon:InitIconPos(objSwf)
	 objSwf.cengIcon._x = self.original_x;
end

UIQiZhanDungeon.IsChange = false

function UIQiZhanDungeon:SetLeftPosition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.numlayer < 10 then
		objSwf.cengIcon._x = self.original_x;
	end
end

function UIQiZhanDungeon:SetRightPosition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.numlayer >= 11 then
		self.IsChange = false;
	end
	if self.numlayer == 10 then
		objSwf.cengIcon._x = self.original_x + 10;
	end
end

function UIQiZhanDungeon:ShowNextLayer( )
	self.numlayer = QiZhanDungeonModel:GetNextLayerNum();
end
--发送呐喊
function UIQiZhanDungeon:OnToShout()	
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
	ChatController:OnSendCWWorldNotice(ChatConsts.WorldNoticePataDungeon);
end

--显示创建房间界面
function UIQiZhanDungeon:OnShowRoomClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local data = TimeDungeonModel:GetPataSelfTeamData()
	if data.dungeonIndex then
		FloatManager:AddNormal( StrConfig['timeDungeon085'] );
		return
	end
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); --今日剩余次数
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['timeDungeon050'] );
		return
	end
	if objSwf.teamPanel._visible then return end   --如果打开将打开返回
	objSwf.teamPanel._visible = true;
	local name = MainPlayerModel.humanDetailInfo.eaName;
	objSwf.teamPanel.txt_name.htmlText = name;
	-- local enterNums = TimeDungeonModel:GetEnterNum()
	local enterNums = QiZhanDungeonUtil:GetNowEnterNum();
	local cfg = t_consts[148];
	if cfg then
		objSwf.teamPanel.txt_num.htmlText = string.format(StrConfig['timeDungeon1002'],enterNums,cfg.val1);
	end
end

--创建房间
UIQiZhanDungeon.stateIndex = 1001;
function UIQiZhanDungeon:OnEstTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
		
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
	local dungeonType = DungeonConsts.fubenType_pata;
	TimeDungeonController:SendTimeDungeonRoomBuild(dungeonType,dungeonIndex,password,toint(attLimit));
	objSwf.teamPanel._visible = false;
	self:OnCloseEstPanel();
end

--请求准备状态
UIQiZhanDungeon.enterState = true;
function UIQiZhanDungeon:OnChangeState()
	local state = TimeDungeonModel:GetInTeamState();
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then  --队长
		if  QiZhanDungeonUtil:GetNowEnterNum() < 1 then
			FloatManager:AddNormal( StrConfig["timeDungeon050"] );
			return
		end
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
		TimeDungeonController:OnSendEnterPataRoomStart();   
		-- self.enterState = false;
		return
	end
	if state then
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_pata,1);			--如果在准备状态  就取消
		return
	end

	local capData = TeamModel:GetCaptainInfo();  --获取队长信息
	if not capData then self:Hide(); return end
	local line = capData.line;
	local myLine = CPlayerMap:GetCurLineID();

	if myLine == line and not state then 
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_pata,0);			--如果在一条线并不准备  发送准备
		return
	end
	
	local func = function () 										--不再一条线  就切线并准备
		if myLine ~= line then
			MainPlayerController:ReqChangeLine(line);
		else
			TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_pata,0);
		end
	end
	self.preConfirmID = UIConfirm:Open(StrConfig['timeDungeon1101'],func);


end

--关闭创建房间界面
function UIQiZhanDungeon:OnCloseEstPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:ClearPassAttTxt();
	objSwf.teamPanel._visible = false;
end

--清空数据
function UIQiZhanDungeon:ClearPassAttTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.teamPanel.txt_password.text = '';
	objSwf.teamPanel.txt_attLimit.text = '';
end

--进入游戏
function UIQiZhanDungeon:OnCenterRoom(teamID)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local enterNum = TimeDungeonModel:GetPataEnterNum();
	if enterNum < 1 then FloatManager:AddNormal( StrConfig["timeDungeon050"] ); return end
	local cfg = TimeDungeonModel:GetPataTeamData(teamID);
	if not cfg then return end
	if cfg.lock == 1 then  --不上锁
		objSwf.passwordPanel._visible = false;
		TimeDungeonController:OnCenterTimeDungeonTeam(teamID,'');
		return
	end
	objSwf.passwordPanel._visible = true;
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

--刷新队伍列表
--@为了防止玩家频繁请求服务器，这里添加3s时间间隔限制
UIQiZhanDungeon.updataState = true;
function UIQiZhanDungeon:OnUpdateListTeam( )
	if not self.updataState then 
		FloatManager:AddNormal( StrConfig['qizhanDungeon7005'] )
		return 
	end
	FloatManager:AddNormal( StrConfig['qizhanDungeon7006'] )
	local func = function( )  --回调函数,3秒后执行
		self.updataState = true
		TimerManager:UnRegisterTimer(self.timeKeyLimitUpdate);
		self.timeKeyLimitUpdate = nil;
	end
	if self.timeKeyLimitUpdate then
		return;
	end
	self.timeKeyLimitUpdate = TimerManager:RegisterTimer(func,3000,1);
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_pata)  --请求在线房间信息
	self.updataState = false;
	return;
end

--单人进入副本请求
function UIQiZhanDungeon:OnJoinClick()
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); --今日剩余次数
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig["timeDungeon050"] );
		return
	end
	local func = function () 
		self:OnEnterDungeon();
	end
	self.oneConfirmID = UIConfirm:Open(string.format(StrConfig['timeDungeon010']),func);
end

function UIQiZhanDungeon:OnEnterDungeon()
	TimeDungeonController:AllZuiduiDungeonSignalEnter(DungeonConsts.fubenType_pata)
end

-- 快速进入
function UIQiZhanDungeon:OnEnterQiZhanDungeonClick()
	TimeDungeonController:QuickTimeDungeonRoom(DungeonConsts.fubenType_pata);
	
	--[[
	local objSwf = self.objSwf;
	if not objSwf then return end
	if QiZhanDungeonController:GetInQiZhanDungeonState() then
		FloatManager:AddNormal( StrConfig['qizhanDungeon1003'] );
		return
	end
	
	local cfg = t_funcOpen[FuncConsts.QiZhanDungeon];
	if not cfg then return end
	
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum();
	if not enterNum then return end
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	
	if level < cfg.open_level then
		FloatManager:AddNormal( StrConfig['qizhanDungeon1001'] );
		return
	end
	
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['qizhanDungeon1002'] );
		return
	end
	QiZhanDungeonController:SendEnterQiZhanDungeon();	--请求进入
	--]]
end

--上一层副本
function UIQiZhanDungeon:OnBtnPreTeam( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.numlayer <= QiZhanDungeonConsts.minLayer then
		return;
	else
		self.numlayer = self.numlayer - 1;
	end
	UIQiZhanDungeon:SetFight(false)
	self:ShowDetail(self.numlayer)
	self:SetLeftPosition()
end

--下一层副本
function UIQiZhanDungeon:OnBtnNextTeam( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.numlayer >= QiZhanDungeonUtil:GetListCount() then
		return;
	else
		self.numlayer = self.numlayer + 1;
	end
	UIQiZhanDungeon:SetFight(false)
	self:ShowDetail(self.numlayer)
	self:SetRightPosition()
end

--显示战斗力
--@param 是否滚动显示
function UIQiZhanDungeon:SetFight(withScroll)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if withScroll then
		-- objSwf.numFight:scrollToNum(self.numlayer,5)   --@parm2 代表滚动所需时间
		objSwf.numFight.num = self.numlayer;
		self:InitSpeicalPos(objSwf)
		return;
	end
	objSwf.numFight.num = self.numlayer;
	self:ShowReward()
end

-- 显示层数详情
function UIQiZhanDungeon:ShowDetail( index )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local cfg = t_ridedungeon[index]
	if not cfg then return; end
	local detail = cfg.description;
	objSwf.tfDetail.text = detail
end

--音效
function UIQiZhanDungeon:IsShowSound()
	return true;
end

function UIQiZhanDungeon:IsShowLoading()
	return true;
end

-- 显示奖励
function UIQiZhanDungeon:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_ridereward[self.numlayer];
	if not cfg then return end
	local randomList = RewardManager:Parse( cfg.reward );
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));  -- unpack 数据格式的转换 往AS传的数据
	objSwf.rewardList:invalidateData();
end

function UIQiZhanDungeon:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_rank._visible = false;
	objSwf.teamPanel._visible = false;
	self:ClearPassAttTxt();
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel._visible = false;
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();      --清空自己队伍数据
	objSwf.createTeamPanel.teamList.dataProvider:cleanUp();    --清空队伍列表数据

end

-- 显示排行榜
function UIQiZhanDungeon:OnShowRankPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.panel_rank._visible = not objSwf.panel_rank._visible;
end

--显示副本数据
function UIQiZhanDungeon:OnShowData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local dungeonData = QiZhanDungeonModel:GetQiZhanDungeonData();
	objSwf.bestLayerTeam.text = dungeonData.bestTeamLayer;													--最强队伍层数
	local enterNum = QiZhanDungeonUtil:GetNowEnterNum(); --今日剩余次数
	-- print("今日剩余次数:",enterNum)
	if enterNum then
		local cfg = t_consts[148];
		if cfg then
			objSwf.txt_enterNum.htmlText = string.format(StrConfig['qizhanDungeon005'],enterNum > 0 and '#00ff00' or '#ff0000',enterNum .. '/' .. cfg.val1);
		end
	end
	--我的最高层数
	objSwf.txt_myLayer.htmlText = string.format(StrConfig['qizhanDungeon006'],dungeonData.bestLayer)
	self:ShowBestTeam();
	self:ShowRankList();
	self:ShowNextLayer();
	self:SetFight(true)
	self:ShowDetail(self.numlayer)
	self:ShowReward();
end

--最强队伍列表数据
function UIQiZhanDungeon:ShowBestTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bestTeamList = QiZhanDungeonModel:GetQiZhanDungeonBestTeamData();  --最强队伍成员数据
	if not bestTeamList then return; end
	
	for i = 1 , 4 do
		if bestTeamList[i] then
			objSwf['txt_team' .. i]._visible = true;
			objSwf['txt_team' .. i].text = bestTeamList[i].name;
		else
			objSwf['txt_team' .. i]._visible = false;
		end
	end
end

--排行榜数据
function UIQiZhanDungeon:ShowRankList()

	local objSwf = self.objSwf;
	if not objSwf then return end
	local rankList = QiZhanDungeonModel:GetQiZhanDungeonRankData();   --获取排行榜数据 
	if not rankList then return end
	objSwf.panel_rank.listPlayer.dataProvider:cleanUp();
	-- just need rank and name
	for i = 2 , 10 do
		if rankList[i] then
			local vo = {};
			vo.rank = i;
			vo.playerName = rankList[i].name;
			objSwf.panel_rank.listPlayer.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.panel_rank.listPlayer:invalidateData();
end


--绘制自己的队伍list
function UIQiZhanDungeon:OnDrawMyTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myTeam = TimeDungeonModel:GetPataSelfTeamPlayerData(); 
	objSwf.createTeamPanel.teamList.dataProvider:cleanUp();
	for i , v in ipairs(myTeam) do
		local vo = {};
		vo.roleID = v.roleID;
		vo.myState = MainPlayerController:GetRoleID() == TeamModel:GetCaptainId();
		vo.teamInfo = v.memName;
		vo.prepare = v.roomType;
		vo.level = v.level;
		vo.att = string.format(StrConfig['timeDungeon1022'],v.attLimit); --战力
		vo.headUrl = ResUtil:GetHeadIcon(v.headID,false,true);
		vo.cap = v.cap;
		vo.line = v.line;
		vo.lineStr = string.format(StrConfig['timeDungeon1023'],vo.line);  --几线
		objSwf.createTeamPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.createTeamPanel.teamList:invalidateData();
	self:OnDrawMyTeamData();
end

--自己队伍的总信息
function UIQiZhanDungeon:OnDrawMyTeamData()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local teamCfg = TimeDungeonModel:GetPataSelfTeamPlayerData();   --获取玩家自己的组队配置数据
	local attNum = 0;   --战斗力总数
	for i,v in ipairs(teamCfg) do
		attNum = attNum + v.attLimit;
	end
	objSwf.createTeamPanel.maxAtt.num = attNum;   -- 总战力
	objSwf.createTeamPanel.txt_playerNum.text = #teamCfg .. '/4';   --目前人数
	local campCfg = TeamModel:GetCaptainInfo();  --得到队长信息
	if not campCfg then return end
	local name = campCfg.roleName;
	objSwf.createTeamPanel.txt_name.htmlText = string.format(StrConfig['timeDungeon1001'],name);

	local data = TimeDungeonModel:GetPataSelfTeamData();            --获取爬塔玩家自身队伍信息
	if data.lock == 0 then  --房间是否加锁
		objSwf.createTeamPanel.lock._visible = true;
	else
		objSwf.createTeamPanel.lock._visible = false;
	end
	--[[
	if data.lockAttNum == 0 then   --战斗力限制数
		objSwf.createTeamPanel.tf_limit.text = UIStrConfig['timeDungeon1010'];
	else
		objSwf.createTeamPanel.tf_limit.text = data.lockAttNum;
	end
	--]]
	--区分队长还是队员，用来界面排版
	if TeamModel:GetCaptainId() ~= MainPlayerController:GetRoleID() then
		objSwf.createTeamPanel.btn_start.visible = false;
		objSwf.createTeamPanel.btn_world.visible = false;	--呐喊按钮
	else
		objSwf.createTeamPanel.btn_start.visible = true;
		objSwf.createTeamPanel.btn_world.visible = true;	--呐喊按钮
	end
end

--自己准备按钮状态--包括队长和队员
function UIQiZhanDungeon:OnChangePrepareState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local state = TimeDungeonModel:GetInTeamState();
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then
		objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon202'];      --开始战斗
	else
		if state then
			objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon201'];  --取消准备
		else
			objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon200'];  --准备
		end
	end
end

--绘制所有队伍list
function UIQiZhanDungeon:OnDrawAllTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local teamlist = {};
	--是否过滤加锁不加锁队伍
	if objSwf.teamListPanel.btn_change.selected then    
		teamlist = TimeDungeonModel:GetAllPataOpenTeam();   --不加锁队伍
	else
		teamlist = TimeDungeonModel:GetAllPataTeamData();   --所有的队伍
	end
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();
	for i , v in ipairs(teamlist) do
		local vo = {};
		vo.name = string.format(StrConfig['timeDungeon1001'],v.capName);      --队伍名
		vo.teamInfo = string.format(StrConfig['timeDungeon1017'],v.roomNum);  --人数
		vo.title = string.format(StrConfig['timeDungeon1018'],TipsConsts:GetItemQualityColor(v.dungeonIndex - 1),StrConfig['timeDungeon101' .. v.dungeonIndex]);
		vo.att = string.format(StrConfig['timeDungeon1016'],v.att);           --战力需求
		--平均战力  待定
		vo.lock = v.lock == 0;
		vo.roomID = v.roomID;
		vo.showEffect = DungeonUtils:CheckShowEffect(v.roomNum,v.att,v.lock)
		objSwf.teamListPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.teamListPanel.teamList:invalidateData();
end

--改变单个队员的信息
function UIQiZhanDungeon:OnChangePlayerItem(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerIndex = 1;

	local memberCfg = nil;
	for i , member in ipairs(TimeDungeonModel:GetPataSelfTeamPlayerData()) do
		if member.index == index then
			memberCfg = member;
			playerIndex = i;
		end
	end
	if not memberCfg then return end
	if not memberCfg or memberCfg == {} then 
		trace(TeamModel:GetMemberList());     --输出队员列表
		print('Error not player ：TeamIndex-----：' .. index); 
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
	objSwf.createTeamPanel['icon' .. playerIndex]:setData(UIData.encode(vo));
end

--显示右侧队伍信息，包括玩家自己创建队伍和已有队伍列表
--@index 区别符号 ,用来区分玩家自身队伍(2)和已有队伍列表(1)
function UIQiZhanDungeon:OnShowRightList(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local inTeam = TeamModel:IsInTeam();
	objSwf.passwordPanel._visible = false;
	local data = TimeDungeonModel:GetPataSelfTeamData();
	if index == 1 then    --其他队伍列表
		objSwf.createTeamPanel.btn_start._visible = false;
		objSwf.teamListPanel._visible = true;
		objSwf.createTeamPanel._visible = false;
		objSwf.btn_quickEnter.visible = true;
		objSwf.btn_createTeam.visible = true;
		objSwf.btn_update.visible = true;
		self:OnDrawAllTeam();
	end
	if index == 2 then   --自身队伍
		objSwf.createTeamPanel.btn_start._visible = true;
		objSwf.teamListPanel._visible = false;
		objSwf.createTeamPanel._visible = true;
		objSwf.btn_update.visible = false;
		objSwf.btn_quickEnter.visible = false;
		objSwf.btn_createTeam.visible = false;
		self:OnDrawMyTeam();
	end
	self:OnChangePrepareState();
end
-------------------------------监听消息列表------------------------------------
function UIQiZhanDungeon:ListNotificationInterests()
	return { 
		NotifyConsts.QiZhanDungeonUpDate,
		NotifyConsts.TimeDungeonTeamRooomData,
		NotifyConsts.TimeDungeonTeamMyRoom,
		NotifyConsts.TimeDungeonRoomPrepare,
		NotifyConsts.MemberChange,
		NotifyConsts.TeamMemberAdd,
		NotifyConsts.TeamMemberRemove,
		NotifyConsts.TeamQuit,
	};
end

function UIQiZhanDungeon:HandleNotification(name,body)
	if name == NotifyConsts.TimeDungeonTeamRooomData then
		if body.dungeonType == DungeonConsts.fubenType_pata then   -- 返回所有房间信息
			print("successful get team list.....")
			self:OnShowRightList(1);
		end
	elseif name == NotifyConsts.TimeDungeonTeamMyRoom then		   --自己的房间信息
		if body.dungeonType == DungeonConsts.fubenType_pata then   
			print("receive new room message......")
			self:OnShowRightList(2);
		end
	elseif name == NotifyConsts.TimeDungeonRoomPrepare then        --点击准备状态的返回
			print("收到准备状态改变的服务器消息")
			self:OnChangePrepareState();                           --这条消息的目的只是改变按钮的状态
	elseif name == NotifyConsts.MemberChange then                  --队员信息改变
		if TeamConsts.PataDungeonAttrs[ body.attrType ] then
			local data = TimeDungeonModel:GetPataSelfTeamData()
			if data.dungeonIndex then
				print("team member message change..........")
				self:OnChangePlayerItem(body.index);      
				self:OnChangePrepareState();
			end
		end
	elseif name == NotifyConsts.TeamMemberAdd then
		local data = TimeDungeonModel:GetPataSelfTeamData()
		-- if data.dungeonIndex then
			print("new people join in")
			self:OnDrawMyTeam();
		-- end
	elseif name == NotifyConsts.TeamMemberRemove then
		local data = TimeDungeonModel:GetPataSelfTeamData()
		if data.dungeonIndex then
			self:OnDrawMyTeam();
		end
	elseif name == NotifyConsts.TeamQuit then                       --退出队伍
		print("level out team")
		TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_pata);
	elseif name == NotifyConsts.QiZhanDungeonUpDate then
		self:OnShowData();                                           --波数信息刷新
	end
end