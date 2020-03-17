--[[
世界boss面板
2014年12月4日14:33:21
郝户
]]

_G.UIWorldBoss = BaseUI:new("UIWorldBoss");

--怪物id(仅用于获取boss刷新时间)
UIWorldBoss.monsterId = nil;
UIWorldBoss.timerKey = nil;

UIWorldBoss.goFightAfterSceneChange = false -- 换场景后是否寻路去打boss

UIWorldBoss.currId = nil

-- UIWorldBoss.curPage = 1;
-- UIWorldBoss.maxPage = 1;

function UIWorldBoss:Create()
	self:AddSWF("worldBossPanelEx.swf", true, nil);
	self:AddChild( UIWorldBossReward, "reward" );
end

function UIWorldBoss:OnLoaded(objSwf)
	self:GetChild("reward"):SetContainer( objSwf.childPanel );
	objSwf.bossList.change = function()
		local nValue = 0
		for k, v in pairs(ActivityWorldBoss.worldBossList) do
			if nValue == objSwf.bossList.selectedIndex then
				if self.currId ==k then
					return
				end
				self.currId = k
				break
			end
			nValue = nValue + 1
		end
		self:DrawBoss(true);
		self:DrawReward();
		self:UpdateStateTxt();
		self:UpdateBtnState()
	end
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	-- objSwf.btnRule.rollOver = function() return end
	-- objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	-- objSwf.desLoader.loaded     = function(e) self:OnDesLoaded(e); end
	-- objSwf.btnSkill.click       = function() self:OnBtnSkillClick(); end
	objSwf.btn_goon.click       = function() self:OnBtnFightClick(); end
	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end
	objSwf.btnTeleport.click    = function() self:OnBtnTeleportClick(); end
	objSwf.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver(); end
	objSwf.btnTeleport.rollOut  = function() self:OnBtnTeleportRollOut(); end
	local btnViewReward = objSwf.btnViewReward;
	btnViewReward.click    = function() self:OnBtnRewardClick(); end
	btnViewReward.rollOver = function() self:OnBtnRewardOver(); end
	btnViewReward.rollOut  = function() self:OnBtnRewardOut(); end

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



function UIWorldBoss:OnBtnPreClick()
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

function UIWorldBoss:OnBtnNextClick()
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

function UIWorldBoss:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numlist - 1
end

function UIWorldBoss:OnShow()
	self:OnShowBossList();
	self:StartTimer()
end

function UIWorldBoss:OnShowBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.bossList.dataProvider:cleanUp();
	for bossId , vo in pairs(ActivityWorldBoss.worldBossList) do
		local cfg = t_worldboss[bossId]
		if cfg then
			local opened     = cfg.open
			local monsterId  = cfg.monster
			local monsterCfg = t_monster[monsterId]
			local vo = {};
			vo.nameUrl 	= ResUtil:GetBossMapIcon(cfg.mapname_pic)
			vo.headUrl 	= ResUtil:GetWorldBossIcon( bossId, not opened )
			vo.id 		= bossId;
			-- vo.lv       = monsterCfg.level
			if MainPlayerModel.humanDetailInfo.eaLevel < monsterCfg.level then
				vo.lv       = string.format("<font color='#FF0000'>LV.%s</font>", monsterCfg.level)
				-- vo.mapName = string.format("<font color='#FF0000'>%s</font>", t_map[toint(cfg.map)].name)
			else
				vo.lv       = string.format("<font color='#ffffff'>LV.%s</font>", monsterCfg.level)
				-- vo.mapName = string.format("<font color='#1ec71e'>%s</font>", t_map[toint(cfg.map)].name)
			end

			local info = ActivityWorldBoss:GetWorldBossInfo(bossId);
			local alive = info and info.state~=1 or false;
			if alive then
				vo.timeStr = string.format("<font color='#00ff00'>%s</font>", StrConfig['worldBoss006'])
			else
				vo.timeStr = string.format(StrConfig['worldBoss504'], PublicUtil:GetShowTimeStr(WorldBossUtils:GetNextBirthTime(monsterId)))
			end
			-- vo.killed = not alive

			objSwf.bossList.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.bossList:invalidateData();
	
	self.currId = 1;
	
	self:DrawBoss(true);
	self:DrawReward();
	objSwf.bossList.selectedIndex = 0;
end

function UIWorldBoss:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 1000, 0 );
	self:UpdateStateTxt();
end

--每秒刷新
local lastTimeBossAliveState = true;
function UIWorldBoss:OnTimer()
	if not self.currId then return end
	local srcVO = ActivityWorldBoss:GetWorldBossInfo(self.currId);
	local bossAliveState = srcVO.state ~= 1;
	local aliveStateChanged = lastTimeBossAliveState ~= bossAliveState;
	if not bossAliveState or aliveStateChanged then
		lastTimeBossAliveState = bossAliveState;
		self:UpdateStateTxt( bossAliveState );
	end
end

function UIWorldBoss:UpdateStateTxt( bossAliveState )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local txt, txtColor
	local cfg = t_worldboss[self.currId]
	if not cfg then
		print( "cannot find worldboss config: " .. tostring(self.currId) )
		return
	end
	if cfg.open then
		if bossAliveState == nil then
			local srcVO = ActivityWorldBoss:GetWorldBossInfo(self.currId);
			bossAliveState = srcVO.state ~= 1;
		end
		txt, txtColor = self:GetStateTxtInfo( not bossAliveState );
	else
		txt, txtColor = StrConfig['worldBoss015'], 0xcc0000
	end
	-- objSwf.txtTime.text = txt;
	-- objSwf.txtTime.textColor = txtColor;
	if txt == "" then
		objSwf.killIcon._visible = false
		objSwf.refreshIcon._visible = true
	else
		objSwf.killIcon._visible = true
		objSwf.refreshIcon._visible = false
	end
end

function UIWorldBoss:GetStateTxtInfo(killed)
	local txt, txtColor
	if killed then
		local needTime = WorldBossUtils:GetNextBirthLastTime(t_worldboss[self.currId].monster)
		local hour, min, sec = CTimeFormat:sec2format(needTime)
		local hourStr = hour > 0 and string.format( StrConfig['worldBoss002'], hour ) or ""
		local minStr = min > 0 and string.format( StrConfig['worldBoss003'], min ) or ""
		local secStr = sec >= 0 and string.format( StrConfig['worldBoss010'], sec ) or ""
		local timeStr = string.format( "%s%s%s", hourStr, minStr, secStr )
		txt = string.format( StrConfig['worldBoss004'], timeStr )
	else
		txt = ""
	end
	txtColor = 0x2fe00d
	return txt, txtColor
end

function UIWorldBoss:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIWorldBoss:OnHide()
	self:StopTimer()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
		self.objUIDraw:SetUILoader(nil);
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil
	end
end

function UIWorldBoss:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_worldboss[self.currId];
	if not cfg then return; end
	
	local randomList = RewardManager:Parse( cfg.display_reward );
	-- self.maxPage = math.ceil(#randomList/5)

	-- objSwf.btnPre._visible = self.maxPage > 1
	-- objSwf.btnNext._visible = self.maxPage > 1
	-- local list = {}
	-- for i = 5*(self.curPage - 1) + 1, 5*(self.curPage - 1) + 5 do
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

--显示boss 3d 模型 -- scene
local viewPort -- _Vector2
function UIWorldBoss:Show3DBoss( bossId )
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = t_worldboss[bossId]
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1379, 732) end
		self.objUIDraw = UISceneDraw:new( "WorldBossUI", objSwf.bossLoader, viewPort )
	else 
		self.objUIDraw:SetUILoader(objSwf.bossLoader)
	end
	self.objUIDraw:SetScene( cfg.ui_sen )
	-- 模型旋转
	self.objUIDraw:SetDraw(true)
end

local viewPort -- _Vector2
function UIWorldBoss:DrawBoss(showSkill)
	local objSwf = self.objSwf;
	if not objSwf then return end 
	local cfg = t_worldboss[self.currId];
	if not cfg then return; end
	local bossId = cfg.monster;
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1010, 620) end
		self.objUIDraw = UISceneDraw:new( "WorldBossUI", objSwf.load_boss, viewPort )
	else
		self.objUIDraw:SetUILoader(objSwf.load_boss)
	end
	self.objUIDraw:SetScene( cfg.ui_sen, function()
		if showSkill then
			self:PlaySkill()
		end
	end )
	-- 模型旋转
	self.objUIDraw:SetDraw(true)

	objSwf.nameLoader.source = ResUtil:GetWorldBossNameUrl(self.currId);
	-- objSwf.desLoader.source = ResUtil:GetWorldBossDesUrl(self.currId);
	-- objSwf.levelNumLoader.num = t_monster[bossId].level

	local bossInfo = ActivityWorldBoss:GetWorldBossInfo(self.currId);
	local killerName = bossInfo.lastKillRoleName
	-- objSwf.txtLastKill.text = killerName ~= "" and killerName or StrConfig['worldBoss007']
	if UIWorldBossReward:IsShow() then
		UIWorldBossReward:UpdateShow();
	end
	-- 播放技能
	-- if showSkill then
	-- 	self:PlaySkill();
	-- end
	-- objSwf.txtCondition.htmlText = cfg.needLv .. "级"
end

function UIWorldBoss:WithRes()
	return { "worldBossRewardPanel.swf" };
end

function UIWorldBoss:OnFullShow()
	-- self:PlaySkill()
end

function UIWorldBoss:OnDesLoaded(e)
	local loader = e.target;
	local img = loader.content;
	img._x = -1 * img._width;
end


-- function UIWorldBoss:OnBtnSkillClick()
-- 	self:PlaySkill();
-- end

-- 播放技能 -- scene
function UIWorldBoss:PlaySkill()
	if not self.objUIDraw then return end
	local cfg = t_worldboss[self.currId]
	if not cfg then return end
	local aniName = cfg.anima_skill
	if aniName == nil or aniName == "" then return end
	local r = self.objUIDraw:NodeAnimation( cfg.ui_node, aniName );
end

function UIWorldBoss:OnBtnFightClick()
	self:GoToFight()
end

-- @ return position id
function UIWorldBoss:GetTeleportTerminal()
	local bossId = self.currId
	if not bossId then return end
	local cfg = t_worldboss[bossId]
	return cfg and cfg.teleport_pos
end

-- 直升
function UIWorldBoss:OnBtnTeleportClick()
	local bossId = self.currId
	if not bossId then return end
	local cfg = t_worldboss[bossId];
	if not cfg.open then
		FloatManager:AddNormal( StrConfig['worldBoss011'] )
		return
	end
	ActivityController:EnterActivity(bossId);
	--[[
	local currLine = CPlayerMap:GetCurLineID()          
	local bossLine = ActivityWorldBoss:GetBossLine(bossId)
	if currLine ~= bossLine then
		MainPlayerController:ReqChangeLine(bossLine)
		return
	end
	self:OnEnterWorldBoss(0)
	--]]
end

-- 小飞侠
function UIWorldBoss:OnEnterWorldBoss(result)
	if result ~= 0 then return end                      --传送失败
	--[[
	local posId = self:GetTeleportTerminal()            --传送坐标
	local point = QuestUtil:GetQuestPos(posId)          --获取任务坐标点
	local teleportType = MapConsts.Teleport_WorldBoss   --飞鞋类型
	local onfoot = function() self:GoToFight() end
	MapController:Teleport( teleportType, onfoot, point.mapId, point.x, point.y )
	self.goFightAfterSceneChange = point.mapId ~= CPlayerMap:GetCurMapID()
	--]]
end

function UIWorldBoss:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UIWorldBoss:OnBtnTeleportRollOut()
	TipsManager:Hide()
end

function UIWorldBoss:OnTeleportDone()
	if self.goFightAfterSceneChange then
		MapController:AddSceneChangeCB( function()
			self:GoToFight()
		end )
	else
		self:GoToFight()
	end
end

function UIWorldBoss:GoToFight()
	local bossId = self.currId;
	if not bossId then return; end
	if not MapUtils:CanTeleport() then
		FloatManager:AddCenter( StrConfig['worldBoss012'] );
		return;
	end
	local cfg = t_worldboss[bossId];
	if not cfg then
		Error( string.format( "cannot find config in t_worldboss.lua. id:%s", bossId ) );
		return;
	end
	if not cfg.open then
		FloatManager:AddNormal( StrConfig['worldBoss011'] );
		return;
	end
	self:AutoRunTo( cfg.position );
end

function UIWorldBoss:AutoRunTo( posId )
	local posVO = QuestUtil:GetQuestPos( posId ); --{x,y,mapId,range};
	MainPlayerController:DoAutoRun( posVO.mapId, _Vector3.new( posVO.x, posVO.y, 0 ) );
end

function UIWorldBoss:OnBtnRewardClick()
	local bossId = self.currId;
	if not bossId then return; end
	if UIWorldBossReward:IsShow() then
		UIWorldBossReward:Hide();
	else
		self:ShowChild("reward");
	end
end

function UIWorldBoss:OnBtnRewardOver()
	TipsManager:ShowBtnTips( StrConfig["worldBoss009"] )
end

function UIWorldBoss:OnBtnRewardOut()
	TipsManager:Hide()
end

function UIWorldBoss:ListNotificationInterests()
	return { NotifyConsts.WorldBossUpdate,NotifyConsts.SceneLineChanged }
end

function UIWorldBoss:HandleNotification(name, body)
	if name == NotifyConsts.WorldBossUpdate then
		self:OnShowBossList()
	elseif name == NotifyConsts.SceneLineChanged then
		self:OnEnterWorldBoss(body.ret)
	end
end