--[[
跨服副本面板
liyuan
]]

_G.UIInterServiceDungeonView = BaseUI:new("UIInterServiceDungeonView");
UIInterServiceDungeonView.list = nil;

UIInterServiceDungeonView.ListLength = 5;
UIInterServiceDungeonView.ItemWidth = 207;
UIInterServiceDungeonView.TweenTime = 0.5;
function UIInterServiceDungeonView:Create()
	self:AddSWF("interServiceDungeon.swf", true, "center");
end

function UIInterServiceDungeonView:OnLoaded(objSwf)
	self:Init(objSwf);
	self:RegisterEventHandler(objSwf);
	
	objSwf.lab_openLevel.text = UIStrConfig['interServiceDungeon1']
	objSwf.lab_num.text = UIStrConfig['interServiceDungeon2']
	objSwf.lab_remaind.text = UIStrConfig['interServiceDungeon3']
	
	objSwf.teamPanel.btn_closeTeam.click = function () self:OnCloseEstPanel(); end
	objSwf.teamPanel.btn_cancel.click = function () self:OnCloseEstPanel(); end
	objSwf.teamPanel.lab_name.text = UIStrConfig['timeDungeon1001'];
	objSwf.teamPanel.lab_teamName.text = UIStrConfig['timeDungeon1002'];
	objSwf.teamPanel.lab_password.text = UIStrConfig['timeDungeon1003'];
	objSwf.teamPanel.lab_power.text = UIStrConfig['timeDungeon1004'];
	objSwf.teamPanel.tf2.text = UIStrConfig['timeDungeon1005'];
	objSwf.teamPanel.btn_close.click = function() end
	objSwf.teamPanel.btn_ok.click = function() end
	objSwf.teamPanel.btn_cancel.click = function() end 
	
	objSwf.teamListPanel.btn_create.click = function() end
	objSwf.teamListPanel.btn_quick.click = function() end
end

local startX;
function UIInterServiceDungeonView:Init(objSwf)
	startX = objSwf.listPanel._x;
end

function UIInterServiceDungeonView:RegisterEventHandler(objSwf)
	objSwf.btnClose.click       = function() self:OnBtnCloseClick(); end
	objSwf.btnPre.click         = function() self:OnBtnPreClick(); end
	objSwf.btnNext.click        = function() self:OnBtnNextClick(); end
	objSwf.listPanel.listBoss.change = function() self:OnBossChange(); end
	RewardManager:RegisterListTips( objSwf.rewardList );
end

function UIInterServiceDungeonView:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
		
	self.list = {};
	local list = objSwf.listPanel.listBoss;
	list.dataProvider:cleanUp();
	local dungeonList = self:GetInterDungeonListData()
	for bossId, vo in ipairs(dungeonList) do
		table.push(self.list, vo);
	end
	local uiDataList = self:GetListUIData()
	list.dataProvider:push( unpack(uiDataList) );
	list:invalidateData();
	self:ShowBoss(nil, false);
	self:UpdateBtnState();
end

-- 获取副本组
function UIInterServiceDungeonView:GetInterDungeonListData()
	local list = {};
	local srcList = DungeonModel.interDungeonList
	for dungeonId, dungeonVO in pairs( srcList ) do
		local cfgInfo  = dungeonVO:GetCfg()
		local vo = {};
		vo.dungeonId         = dungeonId;
		vo.restTimesDes      = dungeonVO:GetRestTimeDes();
		vo.name              = cfgInfo.name
		vo.nameImgURL        = dungeonVO:GetNameImgURL()
		vo.imgURL            = dungeonVO:GetBgURL()
		vo.kindTxt           = DungeonConsts:GetDungeonRewardTypeTxt( cfgInfo.reward_type );
		vo.needLevelTxt      = string.format( StrConfig['dungeon204'], cfgInfo.min_level );
		local myLevel = MainPlayerModel.humanDetailInfo.eaLevel
		vo.needLevelTxtColor = myLevel >= cfgInfo.min_level and 0x236017 or 0x780000;
		vo.typeTxt           = DungeonConsts:GetDungeonTypeTxt( cfgInfo.type );
		table.push( list, vo );
	end
	table.sort( list, function(A, B) return A.dungeonId < B.dungeonId end );
	return list;
end

function UIInterServiceDungeonView:OnBtnPreClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.listPanel;
	local list = panel.listBoss;
	local curPos = list.scrollPosition;
	if curPos > 0 then
		list.scrollPosition = curPos - 1;
		panel._x = startX - self.ItemWidth;
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + self.ListLength - 2 );
		Tween:To( panel, self.TweenTime, { _x = startX } );
	else
		list.selectedIndex = math.max( list.selectedIndex - 1, 1 );
	end
	self:UpdateBtnState();
end

function UIInterServiceDungeonView:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.listPanel;
	local list = panel.listBoss;
	local numBoss = list.dataProvider.length;
	local curPos = list.scrollPosition;
	if curPos < numBoss - self.ListLength then
		list.scrollPosition = curPos + 1;
		panel._x = startX + self.ItemWidth;
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition + 1 );
		Tween:To( panel, self.TweenTime, { _x = startX } );
	else
		list.selectedIndex = math.min( list.selectedIndex + 1, numBoss - 2 );
	end
	self:UpdateBtnState();
end

function UIInterServiceDungeonView:UpdateBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.listPanel.listBoss;
	local numBoss = list.dataProvider.length;
	local selectedIndex = list.selectedIndex;
	objSwf.btnPre.disabled = selectedIndex == 1;
	objSwf.btnNext.disabled = selectedIndex == numBoss - 2;
end

function UIInterServiceDungeonView:GetCurBossId()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.listPanel.listBoss;
	if list.selectedIndex == -1 then list.selectedIndex = 1; end
	local curListUIData = list.dataProvider[list.selectedIndex];
	local bossData = curListUIData and UIData.decode(curListUIData);
	FTrace(bossData,'跨服副本信息')
	if not bossData then
		Debug("no selected Dungeon");
		return;
	end
	local dungeonId = bossData and bossData.dungeonId;
	if dungeonId then
		self.dungeonId = dungeonId;
	end
	return self.dungeonId;
end

function UIInterServiceDungeonView:GetListUIData()
	local list = {};
	table.insert(list, "");
	for _, vo in ipairs(self.list) do
		local uiData = UIData.encode(vo);
		table.insert(list, uiData);
	end
	table.insert(list, "");
	return list;
end

function UIInterServiceDungeonView:OnBossChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:ShowBoss();
end

function UIInterServiceDungeonView:ShowBoss()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local dungeonId = self:GetCurBossId();
	if not dungeonId then return; end
	local dungeCfg = t_worlddungeons[dungeonId];
	if dungeCfg then
		objSwf.nameLoader.source = ResUtil:GetInterDungeonNameImg( dungeonId );
		objSwf.bgLoader.source = ResUtil:GetInterDungeonDesBg( dungeonId );
		objSwf.txt_level.text = 'lv.'..dungeCfg.min_level
		objSwf.txt_num.text = '4'
		objSwf.txt_remaind.text = '1'
		objSwf.teamListPanel.txt_teamName.text = dungeCfg.name
	end
	-- self:UpdateStateTxt();
	self:ShowRewards(dungeonId);
	self:OnDrawAllTeam()
	-- local bossInfo = ActivityWorldBoss:GetWorldBossInfo(bossId);
	-- objSwf.txtLastKill.text = bossInfo.lastKillRoleName;
	-- if UIWorldBossReward:IsShow() then
		-- UIWorldBossReward:UpdateShow();
	-- end	
end

function UIInterServiceDungeonView:ShowRewards(dungeonId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bossCfg = t_worlddungeons[dungeonId];
	if not bossCfg then return; end
	local rewardStr = bossCfg.reward;
	local rewardItemList = RewardManager:Parse( rewardStr );
	local uiList = objSwf.rewardList;
	uiList.dataProvider:cleanUp();
	uiList.dataProvider:push( unpack(rewardItemList) );
	uiList:invalidateData();
	
	rewardStr = bossCfg.first_rewards;
	rewardItemList = RewardManager:Parse( rewardStr );
	uiList = objSwf.firstRewardList;
	uiList.dataProvider:cleanUp();
	uiList.dataProvider:push( unpack(rewardItemList) );
	uiList:invalidateData();
	
end

--绘制所有队伍list
function UIInterServiceDungeonView:OnDrawAllTeam()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local teamlist = {};
	if objSwf.teamListPanel.btn_change.selected then
		teamlist = TimeDungeonModel:GetAllOpenTeam();
	else
		teamlist = TimeDungeonModel:GetAllTeamData();
	end
	objSwf.teamListPanel.teamList.dataProvider:cleanUp();
	-- for i , v in ipairs(teamlist) do
	for i = 1, 30 do
	local v  = {}
	v.roomNum = 1
	v.dungeonIndex = 1
	v.capName = 'wwwww'
	v.att = 111111
	v.lock = 1
	v.roomID = 11
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

-----------------------------------------------------------------------
function UIInterServiceDungeonView:IsTween()
	return true;
end

function UIInterServiceDungeonView:GetPanelType()
	return 1;
end

function UIInterServiceDungeonView:IsShowSound()
	return true;
end

function UIInterServiceDungeonView:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.teamPanel._visible = false
	
	
	
	objSwf.passwordPanel._visible = false

	self:UpdateShow();
end

function UIInterServiceDungeonView:OnHide()
	local objSwf = self.objSwf;
	objSwf.teamPanel._visible = false;
	objSwf.passwordPanel.txt_password.text = '';
	objSwf.passwordPanel._visible = false;
end

function UIInterServiceDungeonView:GetWidth()
	return 903;
end

function UIInterServiceDungeonView:GetHeight()
	return 632;
end

function UIInterServiceDungeonView:OnBtnCloseClick()
	self:Hide();
end

--监听消息列表
function UIInterServiceDungeonView:ListNotificationInterests()
	return { 
		NotifyConsts.WorldBossUpdate
	};
end

--处理消息
function UIInterServiceDungeonView:HandleNotification(name, body)
	if name == NotifyConsts.WorldBossUpdate then
		self:OnWorldBossUpdate();
	end
end

----------------------------创建房间---------------------------------
--关闭创建房间界面
function UIInterServiceDungeonView:OnCloseEstPanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:ClearPassAttTxt();
	objSwf.teamPanel._visible = false;
end

function UIInterServiceDungeonView:ClearPassAttTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.teamPanel.txt_password.text = '';
	objSwf.teamPanel.txt_teamName.text = '';
end

--创建房间
function UIInterServiceDungeonView:OnEstTeam()
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
	TimeDungeonController:SendTimeDungeonRoomBuild(dungeonIndex,password,toint(attLimit));
	objSwf.teamPanel._visible = false;
	self:OnCloseEstPanel();
end

--显示创建房间界面
function UIInterServiceDungeonView:OnShowRoomClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local open = self:OnGetIsOpenActivity();
	if not open then return end
	
	local data = TimeDungeonModel:GetSelfTeamData()
	if data.dungeonIndex then
		FloatManager:AddNormal( StrConfig['timeDungeon085'] );
		return
	end
	
	local cfg = TimeDungeonModel:OnGetRoleItemNum();
	if cfg[self.stateIndex] < t_monkeytime[self.stateIndex].key_num then
		FloatManager:AddNormal( StrConfig['timeDungeon053'] );
		return
	end
	
	if cfg[self.stateIndex] >= t_monkeytime[self.stateIndex].key_num then
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1005'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	else
		objSwf.teamPanel.btnitem.htmlLabel = string.format(StrConfig['timeDungeon1004'],string.format(string.format(StrConfig['timeDungeon1003'],UIStrConfig['timeDungeon' .. self.stateIndex + 3])))
	end
	if objSwf.teamPanel._visible then return end
	objSwf.teamPanel._visible = true;
	local name = MainPlayerModel.humanDetailInfo.eaName;
	objSwf.teamPanel.txt_name.htmlText = string.format(StrConfig['timeDungeon1001'],name);
	objSwf.teamPanel.txt_num.htmlText = string.format(StrConfig['timeDungeon1002'],TimeDungeonModel.enterNum);
	objSwf.teamPanel.scoreLoader.num = t_monkeytime[self.stateIndex].reward_radio;
	
	local color = TipsConsts:GetItemQualityColor(self.stateIndex - 1);
	objSwf.teamPanel.txt_title.htmlText = string.format(StrConfig['timeDungeon1006'],color,StrConfig['timeDungeon101' .. self.stateIndex]);
end