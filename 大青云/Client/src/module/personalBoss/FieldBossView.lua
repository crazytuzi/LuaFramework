--[[
	2015年11月24日00:53:12
	wangyanwei
	野外BOSS
]]

_G.UIFieldBoss = BaseUI:new('UIFieldBoss');

UIFieldBoss.currId = nil;

-- UIFieldBoss.curPage = 1;
-- UIFieldBoss.maxPage = 1;

UIFieldBoss.scene = nil;
UIFieldBoss.objAvatar = nil;--模型
UIFieldBoss.sceneLoaded = false;


function UIFieldBoss:Create()
	self:AddSWF('FieldBossPanel.swf',true,nil);
end

function UIFieldBoss:OnLoaded(objSwf)
	objSwf.bossList.change = function (e)
		self.currId = t_fieldboss[objSwf.bossList.selectedIndex + 1].id
		self:DrawBoss();
		self:DrawReward();
		self:UpdateStateTxt();
		self:UpdateBtnState()
	end
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_goon.click = function () self:OnGoPointClick(); end
	objSwf.btn_goon.rollOver = function() TipsManager:ShowBtnTips(StrConfig['worldBoss502']); end
	objSwf.btn_goon.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTeleport.rollOver = function() self:OnBtnTeleportOver(); end
	objSwf.btnTeleport.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTeleport.click = function() self:OnBtnTeleportClick(); end
	-- objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips("野外BOSS：详细规则请问策划!",TipsConsts.Dir_RightDown); end
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

function UIFieldBoss:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numlist - 1
end

function UIFieldBoss:OnBtnPreClick()
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

function UIFieldBoss:OnBtnNextClick()
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

function UIFieldBoss:OnGoPointClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_fieldboss[self.currId];
	if not cfg then return; end
	if cfg.position == '' then
		FloatManager:AddNormal(StrConfig['worldBoss503']);
		return
	end

	local position = t_position[cfg.position].pos
	local posCfg = split(position,'|');
	local posCfg = split(posCfg[1],',');
	if #posCfg < 1 then return end
	local func = function()
		local curline = CPlayerMap:GetCurLineID();
		if curline ~= 1 then
			MainPlayerController:ReqChangeLine(1);
		end
	end
	MainPlayerController:DoAutoRun(toint(posCfg[1]),_Vector3.new(toint(posCfg[2]),toint(posCfg[3]),0), func);
end

function UIFieldBoss:OnShow()
	PersonalBossController:AskGetFieldBossInfo()
	--
	self:OnShowBossList();
	self:StartTimer()
end

function UIFieldBoss:OnRedicBossState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:OnShowBossList();
end

function UIFieldBoss:OnShowBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.bossList.dataProvider:cleanUp();
	for index , cfg in ipairs(t_fieldboss) do
		local vo = {};
		vo.nameUrl 	= ResUtil:GetBossMapIcon(cfg.mapname)
		vo.headUrl 	= ResUtil:GetFieldBossIcon(cfg.icon)
		vo.id 		= cfg.id;
		local monsterCfg = t_monster[cfg.bossId]
		-- vo.lv       = monsterCfg.level
		if toint(monsterCfg.level) > MainPlayerModel.humanDetailInfo.eaLevel then
			-- vo.mapName = string.format("<font color='#FF0000'>%s</font>",cfg.mapname);
			vo.lv       = string.format("<font color='#FF0000'>LV.%s</font>", monsterCfg.level)
		else
			-- vo.mapName = string.format("<font color='#00FF00'>%s</font>",cfg.mapname);
			vo.lv       = string.format("<font color='#ffffff'>LV.%s</font>", monsterCfg.level)
		end
		local info = PersonalBossModel:GetFieldBossInfo(cfg.id)
		local alive = info and info.state~=1 or false;
		-- vo.killed = not alive
		if alive then
			vo.timeStr = string.format("<font color='#1ec71e'>%s</font>", StrConfig['worldBoss006'])
		else
			vo.timeStr = string.format(StrConfig['worldBoss504'], PublicUtil:GetShowTimeStr(PersonalUtil:GetFieldRefreshTime(cfg.id)))
		end
		objSwf.bossList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.bossList:invalidateData();
	
	self.currId = 1;
	
	self:DrawBoss();
	self:DrawReward();
	objSwf.bossList.selectedIndex = 0;
end

function UIFieldBoss:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 1000, 0 );
	self:UpdateStateTxt();
end

--每秒刷新
function UIFieldBoss:OnTimer()
	self:UpdateStateTxt();
end

function UIFieldBoss:UpdateStateTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_fieldboss[self.currId];
	if not cfg then return; end
	local info = PersonalBossModel:GetFieldBossInfo(self.currId);
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

function UIFieldBoss:GetStateTxtInfo(killed)
	local txt, txtColor
	if killed then
		local needTime = PersonalUtil:GetNextBirthLastTime(self.currId)
		local hour, min, sec = CTimeFormat:sec2format(needTime)
		local hourStr = hour > 0 and string.format( StrConfig['worldBoss002'], hour ) or ""
		local minStr = min > 0 and string.format( StrConfig['worldBoss003'], min ) or ""
		local secStr = sec >= 0 and string.format( StrConfig['worldBoss010'], sec ) or ""
		local timeStr = string.format( "%s%s%s", hourStr, minStr, secStr )
		txt = string.format( StrConfig['worldBoss004'], timeStr )
	else
		txt = "" --StrConfig['worldBoss006']
	end
	txtColor = 0x2fe00d
	return txt, txtColor
end

function UIFieldBoss:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIFieldBoss:OnHide()
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

function UIFieldBoss:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_fieldboss[self.currId];
	if not cfg then return; end
	
	local randomList = RewardManager:Parse(cfg.kill_reward);
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

function UIFieldBoss:DrawBoss()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	local cfg = t_fieldboss[self.currId];
	if not cfg then return; end
	local bossId = cfg.bossId;
	
	local drawCfg = UIDrawFieldBossConfig[bossId];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawFieldBossConfig[bossId] = drawCfg;
	end
	
	if not self.scene then
		self.scene = UISceneDraw:new("UIFieldBoss", objSwf.load_boss, _Vector2.new(1010, 620), false);
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
	
	objSwf.nameLoader.source = ResUtil:GetFieldBossIcon(cfg.name_pic_big)
	-- objSwf.levelNumLoader.num = t_monster[toint(cfg.bossId)].level
	-- objSwf.txtCondition.htmlText = t_monster[toint(cfg.bossId)].level .. "级"
end

UIFieldBoss.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	Rotation = 0
};
function UIFieldBoss:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIFieldBoss:OnBtnTeleportOver()
	local tips = MapUtils:GetTeleportTips();
	tips = tips .."<br/>".. StrConfig["activityswyj036"];
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function UIFieldBoss:OnBtnTeleportClick()
	local cfg = t_fieldboss[self.currId];
	if not cfg then return; end
	if cfg.position == '' then
		FloatManager:AddNormal("没有寻路点");
		return
	end

	local position = t_position[cfg.teleport_pos].pos
	local posCfg = split(position,'|');
	local posCfg = split(posCfg[1],',');
	if #posCfg < 1 then return end
	self.goFightAfterSceneChange = toint(posCfg[1]) ~= CPlayerMap:GetCurMapID()
	MapController:Teleport( MapConsts.Teleport_FieldBoss, nil, toint(posCfg[1]), toint(posCfg[2]), toint(posCfg[3]));
end

function UIFieldBoss:ListNotificationInterests()
	return { NotifyConsts.FieldBossUpdate }
end

function UIFieldBoss:HandleNotification(name, body)
	if name == NotifyConsts.FieldBossUpdate then
		self:OnShowBossList()
	end
end

function UIFieldBoss:OnTeleportDone()
	local func = function()
		local curline = CPlayerMap:GetCurLineID();
		if curline ~= 1 then
			MainPlayerController:ReqChangeLine(1);
		end
	end
	if self.goFightAfterSceneChange then
		MapController:AddSceneChangeCB(func)
	else
		func()
	end
end