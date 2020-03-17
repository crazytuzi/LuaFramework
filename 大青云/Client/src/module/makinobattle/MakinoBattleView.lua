--[[
	时间：   2016年10月19日 17:37:28
	开发者:  houxudong
	功能:    牧野之战, 邑外谓之郊, 郊外谓之牧, 牧外谓之, 野外谓之林
--]]

_G.UIMakinoBattleDungeon = BaseUI:new('UIMakinoBattleDungeon');
UIMakinoBattleDungeon.makinoBattleIndex   = 2002;   --副本id(客户端需和服务器保持一致)
UIMakinoBattleDungeon.makinoBattleTeamId  = 0;      --队伍的id
UIMakinoBattleDungeon.normalShowPanel = false;       --默认是显示排行榜
UIMakinoBattleDungeon.teamId = 0                    --队伍列表相应队伍id
function UIMakinoBattleDungeon:Create()
	self:AddSWF('makinoBattleDungeonPanel.swf',true,nil);
end

function UIMakinoBattleDungeon:OnLoaded(objSwf)
	-- 奖励模块
	objSwf.rewardList.itemRollOver            = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut             = function ()  TipsManager:Hide(); end
	-- 房间列表
	objSwf.teamListPanel.btn_createTeam.click = function () self:OnCreateRoomClick(); end         --创建房间
	objSwf.teamListPanel.btn_quickEnter.click = function () self:OnQuickEnterRoomClick(); end     --快速进入房间
	objSwf.teamListPanel.teamList.centerClick = function (e) self:OnEnterRoom(e.item.roomID); end --进入特定房间
	objSwf.teamListPanel.btn_update.click     = function () self:OnUpdateListTeam(); end          --刷新房间列表
	-- 房间信息
	objSwf.createTeamPanel.btn_world.click    = function () self:OnToShout(); end                 --世界呐喊
	objSwf.createTeamPanel.btn_state.click    = function () self:OnChangeState(); end             --进入游戏(准备or取消准备)
	objSwf.createTeamPanel.btn_quitTeam.click = function () self:OnQuitteam(); end                --退出组队
	objSwf.createTeamPanel.teamList.outClick  = function (e)self:OnKick(e.item.roleID) end        --踢人
	objSwf.createTeamPanel.btn_start.click    = function () self:OnAutoEnterDungeon() end;        --人满自动进人游戏
	-- 创建队伍
	objSwf.teamPanel.btn_closeTeam.click      = function () self:OnCloseEstPanel(); end           --关闭创建房间界面
	objSwf.teamPanel.btn_est.click            = function () self:OnEstTeam(); end                 --确认创建
	objSwf.teamPanel.btn_cancel.click         = function () self:OnCloseEstPanel(); end           --取消创建
	objSwf.teamPanel.tf3.text = UIStrConfig['makinoBattle1003'];
	objSwf.teamPanel.tf4.text = UIStrConfig['makinoBattle1004'];
	objSwf.teamPanel.tf5.text = UIStrConfig['makinoBattle1005'];
	objSwf.teamPanel.tf6.text = UIStrConfig['makinoBattle1006'];
	objSwf.teamPanel.tf7.text = UIStrConfig['makinoBattle1007'];
	-- 队伍密码  
	objSwf.passwordPanel.tf1.text = UIStrConfig['makinoBattle1004'];
	objSwf.passwordPanel.tf2.text = UIStrConfig['makinoBattle1006'];
	-- 阶段性奖励
	objSwf.btnPre.click                       = function( ) self:OnBtnPreClick();end    --前置按钮
	objSwf.btnNext.click                      = function( ) self:OnBtnNextClick();end   --后置按钮
	objSwf.RewardLists.change 		          = function()  self:OnRewardChange();end   --按钮状态发生变化
	objSwf.RewardLists.itemRollOver           = function(e) self:OnBtnRewardOver(e) end; 
	objSwf.RewardLists.itemRollOut            = function(e) TipsManager:Hide(); end;
	objSwf.RewardLists.itemClick              = function(e) self:OnGetReward(e) end;    --点击领奖
	-- 最强队伍&排行榜
	objSwf.btn_rank.click                     = function () self:OnShowRankPanel(); end --排行榜
	objSwf.btn_PackUp.click                   = function () self:OnPackUpPanel(); end --收起
	-- 规则信息
	objSwf.btnRule.rollOver                   = function() self:OnBtnRuleRollOver() end
	objSwf.btnRule.rollOut                    = function() self:OnBtnRuleRollOut() end

	objSwf.teamPanel._visible = false
	objSwf.passwordPanel._visible = false
	objSwf.teamListPanel._visible = true
	objSwf.createTeamPanel._visible = false

	--进入单人请求
	objSwf.btn_join.click = function () self:OnJoinClick(); end  
end

function UIMakinoBattleDungeon:OnShow( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.enterState = true
	self:InitRankList()
	self:ShowDungeonWorkOut()
	MakinoBattleController:ReqMakinoBattleDungeonData()                                         --请求牧野之战左侧界面数据
	-- 请求队伍信息走统一逻辑
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_makinoBattle);                -- 请求在线房间信息
end

function UIMakinoBattleDungeon:ShowDungeonWorkOut( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local imgUrl = ''
	local funcID = 0
	local name = ''
	for k,v in pairs(DungeonConsts.DungeonOpenFuncIdAnaImgUrl) do
		if v[1] == FuncConsts.muyeDungeon then
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
--------------------------------房间列表模块---------------------------------
--快速进入房间
function UIMakinoBattleDungeon:OnQuickEnterRoomClick( )
	TimeDungeonController:QuickTimeDungeonRoom(DungeonConsts.fubenType_makinoBattle);
end

--进入特定房间
function UIMakinoBattleDungeon:OnEnterRoom(teamID)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local objSwf = self.objSwf;
	if not objSwf then return end
	local enterNum,_ = MakinoBattleDungeonUtil:GetNowCanEnterNum();
	if enterNum < 1 then FloatManager:AddNormal( StrConfig["makinoBattle050"] ); return end
	local cfg = TimeDungeonModel:GetMakinoBattleTeamData(teamID); 
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

--刷新房间列表
--@为了防止玩家频繁请求服务器，这里添加5s时间间隔限制
UIMakinoBattleDungeon.updataState = true;
function UIMakinoBattleDungeon:OnUpdateListTeam()
	if not self.updataState then 
		FloatManager:AddNormal( StrConfig['makinoBattle7000'] )
		return 
	end
	FloatManager:AddNormal(string.format(StrConfig['makinoBattle7001']))
	local func = function( )      --回调函数,5秒后执行
		self.updataState = true
		TimerManager:UnRegisterTimer(self.timeKeyLimitUpdate);
		self.timeKeyLimitUpdate = nil;
	end
	self.timeKeyLimitUpdate = TimerManager:RegisterTimer(func,5000,1);
	TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_makinoBattle)  --请求在线房间信息
	self.updataState = false;
	return;
end

-- 创建房间(显示创建房间界面)
function UIMakinoBattleDungeon:OnCreateRoomClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local data = TimeDungeonModel:GetMakinobattleTeamData()
	if data.dungeonIndex then
		FloatManager:AddNormal( StrConfig['makinoBattle1020'] );
		return
	end
	local enterNum,totalNum = MakinoBattleDungeonUtil:GetNowCanEnterNum(); --今日剩余次数
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig['makinoBattle050'] );
		return
	end
	if objSwf.teamPanel._visible then return end;
	objSwf.teamPanel._visible = true;
	local name = MainPlayerModel.humanDetailInfo.eaName;
	objSwf.teamPanel.txt_name.htmlText = name;
	objSwf.teamPanel.txt_num.htmlText = string.format(StrConfig['makinoBattle1000'],enterNum,totalNum);

end

--------------------------------房间信息模块---------------------------------
--世界呐喊(10分钟喊一次)
function UIMakinoBattleDungeon:OnToShout( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.noticeTimeKey then
		FloatManager:AddNormal(StrConfig["makinoBattle8000"])
		return
	end
	self.noticeTimeKey = TimerManager:RegisterTimer(function()
		TimerManager:UnRegisterTimer(self.noticeTimeKey);
		self.noticeTimeKey= nil;
	end,600000);
	ChatController:OnSendCWWorldNotice(ChatConsts.WorldNoticeMakinoDungeon);
end

--进入游戏(准备or取消准备)
UIMakinoBattleDungeon.enterState = true;
function UIMakinoBattleDungeon:OnChangeState( )
	-- 非队长的处理
	local state = TimeDungeonModel:GetInTeamState();  --得到玩家在队伍中的状态

	-- 队长的处理(3秒提醒一下其他玩家准备开始游戏)
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then
		if  MakinoBattleDungeonUtil:GetNowCanEnterNum() < 1 then
			FloatManager:AddNormal( StrConfig["makinoBattle050"] );
			return
		end
		--[[
		if not self.enterState then FloatManager:AddNormal( StrConfig['makinoBattle7000'] )return end
		local func = function ()
			self.enterState = true;
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		self.timeKey = TimerManager:RegisterTimer(func,3000,1);
		--]]
		TimeDungeonController:OnSendEnterMakinoRoomStart();   
		-- self.enterState = false;
		return
	end
	if state then  --正在准备
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_makinoBattle,1);    --如果在准备状态  就取消
		return
	end
	local capData = TeamModel:GetCaptainInfo();  --获取队长信息
	if not capData then self:Hide(); return end
	local line = capData.line;                   --队长所在的线
	local myLine = CPlayerMap:GetCurLineID();    --自己所在的线
	if myLine == line and not state then         --如果在一条线并不准备，发送准备
		TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_makinoBattle,0);
		return
	end
	local func = function () 		             --如果不再一条线, 就切线并准备
		if myLine ~= line then
			MainPlayerController:ReqChangeLine(line);
		else
			TimeDungeonController:TimeDungeonRoomPrepare(DungeonConsts.fubenType_makinoBattle,0);
		end
	end
	self.preConfirmID = UIConfirm:Open(StrConfig['makinoBattle1101'],func);

end

-- 单人进入
function UIMakinoBattleDungeon:OnJoinClick( )
	local enterNum,dailyEnterNum = MakinoBattleDungeonUtil:GetNowCanEnterNum();      --今日剩余次数
	if enterNum < 1 then
		FloatManager:AddNormal( StrConfig["timeDungeon050"] );
		return
	end
	local func = function () 
		self:OnEnterDungeon();
	end
	self.oneConfirmID = UIConfirm:Open(string.format(StrConfig['timeDungeon010']),func);
end

function UIMakinoBattleDungeon:OnEnterDungeon()
	TimeDungeonController:AllZuiduiDungeonSignalEnter(DungeonConsts.fubenType_makinoBattle)
end

--退出房间
function UIMakinoBattleDungeon:OnQuitteam( )
	TimeDungeonController:QuitTimeDungeonRoom(DungeonConsts.fubenType_makinoBattle);
end

--踢人
function UIMakinoBattleDungeon:OnKick(roleID)
	TeamController:Kick(roleID)
end

-- 人满自动开始
function UIMakinoBattleDungeon:OnAutoEnterDungeon()
	TimeDungeonController:OnIsmaxPlayerAutuStartJustForMakinoBattle();
end

--------------------------------创建队伍界面模块-----------------------------
--关闭(取消)创建房间界面
function UIMakinoBattleDungeon:OnCloseEstPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:ClearPassAttTxt();
	objSwf.teamPanel._visible = false;
end

--清空数据
function UIMakinoBattleDungeon:ClearPassAttTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.teamPanel.txt_password.text = '';
	objSwf.teamPanel.txt_attLimit.text = '';
end

-- 确认创建队伍
function UIMakinoBattleDungeon:OnEstTeam(  )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local dungeonIndex = self.makinoBattleIndex  --副本类型
	local password;   --密码
	local txt1 = objSwf.teamPanel.txt_password.text;
	if txt1 == '' then
		password = '';
	else
		password = txt1;
	end
	local attLimit;  --战斗力限制
	local txt2 = objSwf.teamPanel.txt_attLimit.text;
	if txt2 == '' then
		attLimit = '0';
	else
		attLimit = txt2;
	end
	local dungeonType = DungeonConsts.fubenType_makinoBattle;
	TimeDungeonController:SendTimeDungeonRoomBuild(dungeonType,dungeonIndex,password,toint(attLimit));
	objSwf.teamPanel._visible = false;
	self:OnCloseEstPanel();
end
--------------------------------密码界面模块--------------------------------
-- 确定进入队伍 
function UIMakinoBattleDungeon:onBtnSure( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.teamId and self.teamId ~= 0 then
		TimeDungeonController:OnCenterTimeDungeonTeam(self.teamId,objSwf.passwordPanel.txt_password.text);
	end
	objSwf.passwordPanel._visible = false;
end

-- 确认取消
function UIMakinoBattleDungeon:onClosePassWordPanel( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel._visible = false;
end

-------------------------------每波奖励模块--------------------------------
-- 每波奖励
--@param: isShowNum表示物品上是否显示数字 true 显示 false 不显示
function UIMakinoBattleDungeon:ShowEvevyWashReward(isShowNum)
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rewardList.dataProvider:cleanUp()
	local data = MakinoBattleDungeonModel:GetMakinoDungeonData( )
	local bestWave = data.bestLayer       --历史最好成绩
	if not bestWave or bestWave == 0 then
		bestWave = 1;
	end
	local rewardCfg = t_muyewar[bestWave]
	if not rewardCfg then
		print("not find rewardCfg in t_muyewar ...",bestWave)
		return;
	end
	local reward = rewardCfg.reward;
	if not reward then
		print("not find reward in t_muyewar ...")
		return;
	end
	local rewardList = split(reward,'#')
	if not rewardList then
		return;
	end
	local rewardStr = '';
	for i,v in ipairs(rewardList) do
		local vo = split(rewardList[i],',')
		table.remove(vo,3)
		if isShowNum then                --物品上显示数量
			rewardStr = rewardStr .. ( i >= #rewardList and vo[1] .. ',' .. vo[2] or vo[1] .. ',' .. vo[2] .. '#'  )
		else
			rewardStr = rewardStr .. ( i >= #rewardList and vo[1] or vo[1] ..'#'  )
		end
	end
	local rewardItemList = RewardManager:Parse( rewardStr);
	objSwf.rewardList.dataProvider:push(unpack(rewardItemList))
	objSwf.rewardList:invalidateData()
end

-------------------------------额外奖励模块--------------------------------

-- 显示界面阶段性奖励
function UIMakinoBattleDungeon:ShowStageReward(bInit)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local rewardList = self:GetRewardList()
	objSwf.RewardLists.dataProvider:cleanUp()
	for _, vo in ipairs(rewardList) do
		objSwf.RewardLists.dataProvider:push(UIData.encode( vo ))
	end
	objSwf.RewardLists:invalidateData()
	-- 选中规则
	  --1.不可领取，每次打开界面默认选中第一个奖励
	  --2.有可领取奖励，买次打开界面默认选中第一个可以领取的奖励
	  --3.已领取奖励,每次打开界面默认选中已领取的最后一个奖励
	  local index = 0;  --默认选中第一个
	  local isHaveCanGetReward = false
	  for i,v in ipairs(rewardList) do
	  	if v.state == 1 then   --可以领取
	  		index = i - 1
	  		isHaveCanGetReward = true
	  		break;
	  	end
	  	if v.state == 2 then   --已经领取
	  		if not isHaveCanGetReward then
	  			index = i - 1;
	  		end
	  	end
	  end
	if bInit then
		if index >= 0 then
			objSwf.RewardLists.selectedIndex = index
		end
	end
	self:OnRewardChange()
	local index = 0;
	for i,v in ipairs(rewardList) do
		if v.state ~= 0 then
			index = index + i;
		end
	end
end

-- 获得奖励列表
function UIMakinoBattleDungeon:GetRewardList( )
	local rewardList = MakinoBattleDungeonModel:GetRewardDungeonData( )  --奖励列表
	-- print("收到服务器返回的奖励")
	-- trace(rewardList)
	if not rewardList  then return; end
	local list = {};
	for i,v in ipairs(rewardList) do
		local vo = {}
		vo.state = v.state;
		vo.num = v.index
		vo.rewardNum = v.index * 5
		vo.showEffects = false
		--vo.id = v.index;    -- 服务于奖励tips
		if v.state == 1 then      --可以领取
			vo.icon = ResUtil:GetBoxIcon(true)
			vo.showEffects = true
		elseif v.state == 0 then  --不能领取
			vo.icon = ResUtil:GetBoxIcon(false)
		elseif v.state == 2 then  --已领取
			vo.icon = ResUtil:GetBoxIcon(true)
		end
		table.push(list, vo)
	end
	return list
end

-- 前置按钮
function UIMakinoBattleDungeon:OnBtnPreClick( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local numReward = objSwf.RewardLists.dataProvider.length
	local list = objSwf.RewardLists;
	if list.scrollPosition > 0 then
		list.scrollPosition = list.scrollPosition - 1
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + list.rowCount - 1 )
	elseif list.selectedIndex > 0 then
		list.selectedIndex = list.selectedIndex - 1
	end
end

-- 后置按钮
function UIMakinoBattleDungeon:OnBtnNextClick( )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local numReward = objSwf.RewardLists.dataProvider.length
	local list = objSwf.RewardLists;
	if list.scrollPosition < numReward - list.rowCount then
		list.scrollPosition = list.scrollPosition + 1
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition )
	elseif list.selectedIndex < numReward - 1 then
		list.selectedIndex = list.selectedIndex + 1
	end
end

-- list发生变化
function UIMakinoBattleDungeon:OnRewardChange()
	self:UpdateBtnState()
	self:InitGiValue()
end

-- 更新进度条变化 
function UIMakinoBattleDungeon:InitGiValue( )
	-- 进度条
	
end

-- 更新按钮状态
function UIMakinoBattleDungeon:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.RewardLists
	local RewardNum = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnNext.disabled = selectedIndex == RewardNum - 1
	-- 进度条
	local rewardList = self:GetRewardList()
	local gi = objSwf.siGrowValue
	gi._visible = false
	gi:setProgress(selectedIndex , RewardNum )
end

function UIMakinoBattleDungeon:OnBtnRewardOver( e )
	local index = e.item.num * 5;    --e.item.id * 5;
	local cfg = t_muyewar[index]
	if not cfg then
		print("not find reward in t_muyewar.....")
		return;
	end
	local describe = cfg.describe;
	if describe == "" then
		print("not find describe in t_muyewar.....")
		return;
	end
	TipsManager:ShowBtnTips(describe,TipsConsts.Dir_RightDown);
end

-- 领取奖励
function UIMakinoBattleDungeon:OnGetReward( e )
	local index = e.item.num
	if not index then return end
	local rewardList = MakinoBattleDungeonModel:GetRewardDungeonData( )  --奖励列表
	if not rewardList  then 
		print("not find rewardList ......")
		return; 
	end
	local rewardCfg = rewardList[index];
	if not rewardCfg then
		print("not find corresponding data in rewardCfg ......")
		return;
	end
	if rewardCfg.state == 1 then --领奖状态为可领取
		-- print("-------点击领取奖励:",index)
		MakinoBattleController:ReqGetFirstReward(index)
	end
end

function UIMakinoBattleDungeon:OnBtnRuleRollOver( )
	TipsManager:ShowBtnTips( StrConfig['makinoBattle5000'], TipsConsts.Dir_RightDown )
end

function UIMakinoBattleDungeon:OnBtnRuleRollOut( )
	TipsManager:Hide()
end

function UIMakinoBattleDungeon:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel._visible = false;
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();      -- 清空队伍列表数据 
	objSwf.createTeamPanel.teamList.dataProvider:cleanUp();    -- 清空自己队伍数据
end

---------------------------------------------------------------------------
--显示副本界面数据(服务器返回后的刷新)
function UIMakinoBattleDungeon:OnShowData()
	-- 最强队伍
	self:BestTeam()
	-- 排行榜
	self:RankList()
	-- 波数信息
	self:InitWave()
	-- 首通奖励
	self:ShowStageReward(true)
	-- 产出预览
	self:ShowEvevyWashReward(false)
end

-- 最强队伍
function UIMakinoBattleDungeon:BestTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local dungeonData = MakinoBattleDungeonModel:GetMakinoDungeonData();             --得到界面数据信息
	objSwf.bestLayerTeam.text = dungeonData.bestTeamLayer;				             --最强队伍层数
	local bestTeamList = MakinoBattleDungeonModel:GetBeastTeamDungeonData();         --最强队伍成员数据
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

-- 初始化排行榜显示
function UIMakinoBattleDungeon:InitRankList( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.normalShowPanel = false
	objSwf.panel_rank._visible = false    --默认打开显示排行榜
	objSwf.btn_PackUp._visible = false
end
-- 显示排行榜
function UIMakinoBattleDungeon:OnShowRankPanel( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.normalShowPanel == false then
		objSwf.panel_rank._visible = true
	end
	self.normalShowPanel = true
	objSwf.btn_PackUp._visible = true
end

-- 收起排行榜
function UIMakinoBattleDungeon:OnPackUpPanel( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.normalShowPanel == true then
		objSwf.panel_rank._visible = false
	end
	self.normalShowPanel = false
	objSwf.btn_PackUp._visible = false
end

-- 排行榜
function UIMakinoBattleDungeon:RankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rankList = MakinoBattleDungeonModel:GetRankListDungeonData();   --获取排行榜数据 
	if not rankList then return end
	objSwf.panel_rank.listPlayer.dataProvider:cleanUp();
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

-- 波数信息&开启条件
function UIMakinoBattleDungeon:InitWave( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local dungeonData = MakinoBattleDungeonModel:GetMakinoDungeonData();             --得到界面数据信息
	objSwf.txt_myBestLayer.htmlText =  string.format(StrConfig['makinoBattle018'],dungeonData.bestLayer) --自己历史最好的成绩
	local enterNum,dailyEnterNum = MakinoBattleDungeonUtil:GetNowCanEnterNum();      --今日剩余次数
	objSwf.txt_enterNums.htmlText = string.format(StrConfig['makinoBattle002'],enterNum > 0 and '#00ff00' or '#ff0000',enterNum..'/'..dailyEnterNum);
	objSwf.txt_1.htmlText = string.format(StrConfig['makinoBattle4000'])
	local funcOpen,Openlv = DungeonUtils:CheckDungeonOpenFunc(123)  
	objSwf.txt_2.htmlText = string.format(StrConfig['makinoBattle4001'],Openlv)
end

--显示右侧队伍信息，包括玩家自己创建队伍和已有队伍列表
--@index 区别符号 ,1.代表其他队伍列表  2.代表自身队伍
function UIMakinoBattleDungeon:OnShowRightList(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local inTeam = TeamModel:IsInTeam();
	objSwf.passwordPanel._visible = false;
	local data = TimeDungeonModel:GetMakinobattleTeamData()   --得到牧野之战玩家自身队伍信息
		if index == 1 then --其他队伍列表
		objSwf.createTeamPanel.btn_start._visible = false;
		objSwf.teamListPanel._visible = true;
		objSwf.createTeamPanel._visible = false;
		objSwf.teamListPanel.btn_quickEnter.visible = true;
		objSwf.teamListPanel.btn_createTeam.visible = true;
		objSwf.teamListPanel.btn_update.visible = true;
		self:OnDrawAllTeam();
	end
	if index == 2 then   --自身队伍
		objSwf.createTeamPanel.btn_start._visible = true;
		objSwf.teamListPanel._visible = false;
		objSwf.createTeamPanel._visible = true;
		objSwf.teamListPanel.btn_update.visible = false;
		objSwf.teamListPanel.btn_quickEnter.visible = false;
		objSwf.teamListPanel.btn_createTeam.visible = false;
		self:OnDrawMyTeam();
	end
	self:OnChangePrepareState();
end

--绘制所有队伍list
function UIMakinoBattleDungeon:OnDrawAllTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local teamlist = {};
	--是否过滤加锁不加锁队伍
	if objSwf.teamListPanel.btn_change.selected then    
		teamlist = TimeDungeonModel:GetAllMakinoBattleOpenTeam();   --不加锁队伍
	else
		teamlist = TimeDungeonModel:GetAllMakinoBattleTeamData();   --所有的队伍
	end
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();
	-- 初始化队伍数据 
	for i , v in ipairs(teamlist) do
		local vo = {};
		vo.name = string.format(StrConfig['makinoBattle300'],v.capName);      --队伍名
		vo.teamInfo = string.format(StrConfig['makinoBattle301'],v.roomNum);  --人数
		vo.title = ""
		vo.att = string.format(StrConfig['makinoBattle303'],v.att);           --战力需求
		vo.lock = v.lock == 0;
		vo.showEffect = DungeonUtils:CheckShowEffect(v.roomNum,v.att,v.lock)
		vo.roomID = v.roomID;
		objSwf.teamListPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.teamListPanel.teamList:invalidateData();
end

-- 绘制自己队伍列表
function UIMakinoBattleDungeon:OnDrawMyTeam( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local myTeam = TimeDungeonModel:GetMakinoSelfTeamPlayerData(); 
	objSwf.createTeamPanel.teamList.dataProvider:cleanUp();
	for i , v in ipairs(myTeam) do
		local vo = {};
		vo.roleID = v.roleID;
		vo.myState = MainPlayerController:GetRoleID() == TeamModel:GetCaptainId();  --是否是队长
		vo.teamInfo = v.memName;
		vo.prepare = v.roomType;
		vo.level = v.level;
		vo.att = string.format(StrConfig['makinoBattle1022'],v.attLimit);           --战力
		vo.headUrl = ResUtil:GetHeadIcon(v.headID,false,true);
		vo.cap = v.cap;
		vo.line = v.line;
		vo.lineStr = string.format(StrConfig['makinoBattle1023'],vo.line);          --几线
		objSwf.createTeamPanel.teamList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.createTeamPanel.teamList:invalidateData();
	--初始化自己队伍的总数据
	self:OnDrawMyTeamData()  
end

--初始化自己队伍的总数据
function UIMakinoBattleDungeon:OnDrawMyTeamData( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local teamCfg = TimeDungeonModel:GetMakinoSelfTeamPlayerData();   --获取玩家自己的组队数据
	local attNum = 0;   --战斗力总数
	for i,v in ipairs(teamCfg) do
		attNum = attNum + v.attLimit;
	end
	objSwf.createTeamPanel.maxAtt.num = attNum;   -- 总战力
	objSwf.createTeamPanel.txt_playerNum.text = #teamCfg .. '/4';   --目前人数
	local campCfg = TeamModel:GetCaptainInfo();  --得到队长信息
	if not campCfg then return end
	local name = campCfg.roleName;
	objSwf.createTeamPanel.txt_name.htmlText = string.format(StrConfig['makinoBattle300'],name);
	local data = TimeDungeonModel:GetMakinobattleTeamData();            --获取牧野副本玩家自身队伍信息
	if data.lock == 0 then  --房间是否加锁 0.上锁 1.未上锁
		objSwf.createTeamPanel.lock._visible = true;
	else
		objSwf.createTeamPanel.lock._visible = false;
	end
	--区分队长还是队员，用来界面排版
	if TeamModel:GetCaptainId() ~= MainPlayerController:GetRoleID() then  --非队长
		objSwf.createTeamPanel.btn_start.visible = false;   --人满自动开始
		objSwf.createTeamPanel.btn_world.visible = false;	--呐喊按钮
	else
		objSwf.createTeamPanel.btn_start.visible = true;
		objSwf.createTeamPanel.btn_world.visible = true;	
	end
end

--(准备or未准备or开始战斗)按钮状态--包括队长和队员
function UIMakinoBattleDungeon:OnChangePrepareState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local state = TimeDungeonModel:GetInTeamState();
	if TeamModel:GetCaptainId() == MainPlayerController:GetRoleID() then --队长
		objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon202'];      --开始战斗
	else
		if state then  --队伍处于准备状态
			objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon201'];  --取消准备
		else
			objSwf.createTeamPanel.btn_state.label = StrConfig['timeDungeon200'];  --准备
		end
	end
end

--改变单个队员的信息
function UIMakinoBattleDungeon:OnChangePlayerItem(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local playerIndex = 1;
	local memberCfg = nil;
	for i , member in ipairs(TimeDungeonModel:GetMakinoSelfTeamPlayerData()) do
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
	vo.att = string.format(StrConfig['makinoBattle1022'],memberCfg.attLimit);
	vo.headUrl = ResUtil:GetHeadIcon(memberCfg.headID,false,true);
	vo.cap = memberCfg.cap;
	vo.line = memberCfg.line;
	vo.lineStr = string.format(StrConfig['makinoBattle1023'],memberCfg.line);
	objSwf.createTeamPanel['icon' .. playerIndex]:setData(UIData.encode(vo));
end

function UIMakinoBattleDungeon:IsShowLoading()
	return true;
end

-------------------------------监听消息列表------------------------------------
function UIMakinoBattleDungeon:ListNotificationInterests()
	return { 
		NotifyConsts.TimeDungeonTeamRooomData,
		NotifyConsts.TimeDungeonTeamMyRoom,
		NotifyConsts.TimeDungeonRoomPrepare,
		NotifyConsts.MemberChange,
		NotifyConsts.TeamMemberAdd,
		NotifyConsts.TeamMemberRemove,
		NotifyConsts.TeamQuit,
		NotifyConsts.MakinoBattleDungeonUpDate,
		NotifyConsts.MakinoBattleRewardStateChange,
	};
end

function UIMakinoBattleDungeon:HandleNotification(name,body)
	if name == NotifyConsts.TimeDungeonTeamRooomData then
		if body.dungeonType == DungeonConsts.fubenType_makinoBattle then   -- 返回所有房间信息
			print("successful get team list.....")
			self:OnShowRightList(1);
		end
	elseif name == NotifyConsts.TimeDungeonTeamMyRoom then		           --自己的房间信息
		if body.dungeonType == DungeonConsts.fubenType_makinoBattle then   
			print("receive new room message......")
			self:OnShowRightList(2);
		end
	elseif name == NotifyConsts.TimeDungeonRoomPrepare then                --点击准备状态的返回
			print("change prepare state......")
			self:OnChangePrepareState();  
	elseif name == NotifyConsts.MemberChange then                          --队员信息改变
		if TeamConsts.PataDungeonAttrs[ body.attrType ] then
			local data = TimeDungeonModel:GetMakinobattleTeamData()
			if data.dungeonIndex then
				print("team member message change..........")
				self:OnChangePlayerItem(body.index);      
				self:OnChangePrepareState();
			end
		end
	elseif name == NotifyConsts.TeamMemberAdd then                         --队伍成员增加                         
		local data = TimeDungeonModel:GetMakinobattleTeamData()
		if data.dungeonIndex then
			print("new people join in")
			self:OnDrawMyTeam();
		end
	elseif name == NotifyConsts.TeamMemberRemove then                      --队伍成员移除
		local data = TimeDungeonModel:GetMakinobattleTeamData()
		if data.dungeonIndex then
			self:OnDrawMyTeam();
		end
	elseif name == NotifyConsts.TeamQuit then                              --退出队伍
		print("level out team")
		TimeDungeonController:TimeDungeonRoom(DungeonConsts.fubenType_makinoBattle);
	elseif name == NotifyConsts.MakinoBattleDungeonUpDate then             --返回牧野之战副本界面所需要的数据
		self:OnShowData()     
	elseif name == NotifyConsts.MakinoBattleRewardStateChange then         --返回首次通过状态变化
		self:ShowStageReward(true)
	end
end