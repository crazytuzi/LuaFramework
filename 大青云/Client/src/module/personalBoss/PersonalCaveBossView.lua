--[[
	2015年11月24日00:53:12
	wangyanwei
	地宫BOSS
]]

_G.UIPersonalCaveBoss = BaseUI:new('UIPersonalCaveBoss');

UIPersonalCaveBoss.currId = nil;

-- UIPersonalCaveBoss.curPage = 1;
-- UIPersonalCaveBoss.maxPage = 1;

UIPersonalCaveBoss.scene = nil;
UIPersonalCaveBoss.objAvatar = nil;--模型
UIPersonalCaveBoss.sceneLoaded = false;

function UIPersonalCaveBoss:Create()
	self:AddSWF('personalCavebossPanel.swf',true,nil);
end

function UIPersonalCaveBoss:OnLoaded(objSwf)
	objSwf.bossList.change = function ()
		self.currId = t_swyj[objSwf.bossList.selectedIndex + 1].id
		self:DrawBoss();
		self:DrawReward();
		self:UpdateStateTxt();
		self:UpdateBtnState()
	end
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	-- objSwf.icon_name.loaded = function () objSwf.icon_name._x = objSwf.btn_goon._x + objSwf.btn_goon._width/2 - objSwf.icon_name._width/2 end
	
	objSwf.btn_goon.click = function () self:OnGoPointClick(); end
	-- objSwf.btn_goon.rollOver = function() TipsManager:ShowBtnTips(StrConfig["activityswyj021"]); end
	-- objSwf.btn_goon.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTeleport.rollOver = function() self:OnBtnTeleportOver(); end
	objSwf.btnTeleport.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTeleport.click = function() self:OnBtnTeleportClick(); end
	-- objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig["activityswyj027"],TipsConsts.Dir_RightDown); end
	-- objSwf.btnRule.rollOut = function() TipsManager:Hide(); end

	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end

	-- objSwf.btnPre.click = function() 
	-- 	if self.curPage == 1 then return end
	-- 	self.curPage = self.curPage - 1
	-- 	self:DrawReward()
	-- end
	-- objSwf.btnNext.click = function()  
	-- 	if self.curPage == self.maxPage then return end
	-- 	self.curPage = self.curPage + 1
	-- 	self:DrawReward()
	-- end
end

function UIPersonalCaveBoss:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numlist - 1
end

function UIPersonalCaveBoss:OnBtnPreClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	if list.scrollPosition > 0 then
		list.scrollPosition = list.scrollPosition - 1
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + list.rowCount - 1 )
	elseif list.selectedIndex > 0 then
		list.selectedIndex = list.selectedIndex - 1
	end
end

function UIPersonalCaveBoss:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	if list.scrollPosition < numlist - list.rowCount then
		list.scrollPosition = list.scrollPosition + 1
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition )
	elseif list.selectedIndex < numlist - 1 then
		list.selectedIndex = list.selectedIndex + 1
	end
end

function UIPersonalCaveBoss:OnGoPointClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_swyj[self.currId];
	if not cfg then return; end
	local posVO = QuestUtil:GetQuestPos(cfg.finding); --{x,y,mapId,range};

	local completeFuc = function()
		NpcController:ShowDialog(20020008);
		UIBossBasic:Hide()
	end;

	MainPlayerController:DoAutoRun( posVO.mapId, _Vector3.new( posVO.x, posVO.y, 0 ), completeFuc);
end

function UIPersonalCaveBoss:OnShow()
	UnionDiGongController:ReqUnionDiGongInfo()
	--
	self:OnShowBossList();
	self:StartTimer()
end

function UIPersonalCaveBoss:OnRedicBossState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:OnShowBossList();
end

function UIPersonalCaveBoss:OnShowBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.bossList.dataProvider:cleanUp();
	for index , cfg in ipairs(t_swyj) do
		local vo = {};
		vo.nameUrl 	= ResUtil:GetBossMapIcon(cfg.mapname)
		vo.headUrl 	= ResUtil:GetBossMapIcon(cfg.bossIcon)
		vo.id 		= cfg.id;
		-- vo.lv 		= cfg.needLv
		
		if toint(cfg.needLv) > MainPlayerModel.humanDetailInfo.eaLevel then
			vo.lv       = string.format("<font color='#FF0000'>LV.%s</font>", cfg.needLv)
			-- vo.mapName = string.format("<font color='#FF0000'>%s</font>",cfg.info);
		else
			vo.lv       = string.format("<font color='#ffffff'>LV.%s</font>", cfg.needLv)
			-- vo.mapName = string.format("<font color='#00FF00'>%s</font>",cfg.info);
		end

		local info = UnionDiGongModel:getBossInfo(vo.id)
		local alive = info and info.state~=1 or false;
		-- vo.killed = not alive
		if alive then
			vo.timeStr = string.format("<font color='#1ec71e'>%s</font>", StrConfig['worldBoss006'])
		else
			vo.timeStr = string.format(StrConfig['worldBoss504'], PublicUtil:GetShowTimeStr(WorldBossUtils:GetUnionDiGongBossTime(cfg)))
		end
		objSwf.bossList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.bossList:invalidateData();
	
	self.currId = 1;
	
	self:DrawBoss();
	self:DrawReward();
	objSwf.bossList.selectedIndex = 0;
end

function UIPersonalCaveBoss:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 1000, 0 );
	self:UpdateStateTxt();
end

--每秒刷新
function UIPersonalCaveBoss:OnTimer()
	self:UpdateStateTxt();
end

function UIPersonalCaveBoss:UpdateStateTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end

	local info = UnionDiGongModel:getBossInfo(self.currId)
	if not info then 
		-- objSwf.txtLastKill.text = StrConfig['worldBoss007'];
		-- objSwf.txtTime.text = "";
		objSwf.killIcon._visible = false
		objSwf.refreshIcon._visible = false
		return; 
	end
	local killed = info.state == 1;
	local txt, txtColor = self:GetStateTxtInfo(killed);
	-- objSwf.txtTime.text = txt;
	-- objSwf.txtTime.textColor = txtColor;
	-- local killerName = info.lastKillRoleName
	-- objSwf.txtLastKill.text = killerName ~= "" and killerName or StrConfig['worldBoss007']
	if txt == "" then
		objSwf.killIcon._visible = false
		objSwf.refreshIcon._visible = true
	else
		objSwf.killIcon._visible = true
		objSwf.refreshIcon._visible = false
	end
end

function UIPersonalCaveBoss:GetStateTxtInfo(killed, cfg)
	cfg = cfg or t_swyj[self.currId];
	if not cfg then return "",""; end
	local txt, txtColor
	if killed then

		----todo 刷新时间
		local needTime = WorldBossUtils:GetNextBossBirthLastTime(cfg)
		local hour, min, sec = CTimeFormat:sec2format(needTime)
		local hourStr = hour > 0 and string.format( StrConfig['worldBoss002'], hour ) or ""
		local minStr = min > 0 and string.format( StrConfig['worldBoss003'], min ) or ""
		local secStr = sec >= 0 and string.format( StrConfig['worldBoss010'], sec ) or ""
		local timeStr = string.format( "%s%s%s", hourStr, minStr, secStr )
		txt = cfg and timeStr or string.format( StrConfig['worldBoss004'], timeStr )
	else
		txt = "" --StrConfig['worldBoss006']
	end
	txtColor = 0x2fe00d
	return txt, txtColor
end

function UIPersonalCaveBoss:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIPersonalCaveBoss:OnHide()
	self:StopTimer();
	
	if self.scene then 
		self.scene:SetDraw(false)
		self.scene:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.scene);
		self.scene = nil
	end
	
	self.sceneLoaded = false;
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UIPersonalCaveBoss:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_swyj[self.currId];
	if not cfg then return; end
	
	local randomList = RewardManager:Parse( cfg.dropReward );
	-- self.maxPage = math.ceil(#randomList/8)

	-- objSwf.btnPre._visible = self.maxPage > 1
	-- objSwf.btnNext._visible = self.maxPage > 1
	-- local list = {}
	-- for i = 8*(self.curPage - 1) + 1, 8*(self.curPage - 1) + 8 do
	-- 	if randomList[i] then
	-- 		table.push(list, randomList[i])
	-- 	else
	-- 		break
	-- 	end
	-- end
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end

function UIPersonalCaveBoss:DrawBoss()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	local cfg = t_swyj[self.currId];
	if not cfg then return; end
	local bossId = cfg.bossId;
	
	local drawCfg = UIDrawPersonalCaveBossConfig[bossId];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawPersonalCaveBossConfig[bossId] = drawCfg;
	end

	if not self.scene then
		self.scene = UISceneDraw:new("UIPersonalCaveBoss", objSwf.load_boss, _Vector2.new(1010, 620), false);
	end
	self.scene:SetUILoader(objSwf.load_boss);
	
	if self.sceneLoaded then
		if self.objAvatar then
			self.objAvatar:ExitMap();
			self.objAvatar = nil;
		end
		self.objAvatar = MonsterAvatar:NewMonsterAvatar(nil,bossId);
		self.objAvatar:InitAvatar();
		
		self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );
		local rotation = drawCfg.Rotation or 0;
		self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
		self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Monster);
	else
		self.scene:SetScene('v_panel_boss.sen', function()
			if self.objAvatar then
				self.objAvatar:ExitMap();
				self.objAvatar = nil;
			end
			self.objAvatar = MonsterAvatar:NewMonsterAvatar(nil,bossId);
			self.objAvatar:InitAvatar();
			
			self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
			self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );
			local rotation = drawCfg.Rotation or 0;
			self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
			self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Monster);
			self.sceneLoaded = true;
		end );
		self.scene:SetDraw( true );
	end
	
	local cfg = PersonalUtil:GetCaveBossIDCfg(bossId);
	if not cfg then return end
	objSwf.nameLoader.source = ResUtil:GetBossMapIcon(cfg.nameIcon)
	-- objSwf.levelNumLoader.num = t_monster[toint(cfg.bossId)].level
	-- objSwf.txtCondition.htmlText = cfg.needLv .. "级"
end

UIPersonalCaveBoss.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	Rotation = 0
};
function UIPersonalCaveBoss:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIPersonalCaveBoss:OnBtnTeleportOver()
	local tips = MapUtils:GetTeleportTips();
	tips = tips .."<br/>".. StrConfig["activityswyj036"];
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function UIPersonalCaveBoss:OnBtnTeleportClick()
	local cfg = t_swyj[self.currId];
	if not cfg then return; end

	local posVO = QuestUtil:GetQuestPos(cfg.flight)

	MapController:Teleport( MapConsts.Teleport_DailyQuest, nil, posVO.mapId, posVO.x, posVO.y);
end

function UIPersonalCaveBoss:ListNotificationInterests()
	return { NotifyConsts.UnionDiGongInfoUpdate }
end

function UIPersonalCaveBoss:HandleNotification(name, body)
	if name == NotifyConsts.UnionDiGongInfoUpdate then
		self:OnShowBossList()
	end
end