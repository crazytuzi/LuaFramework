--[[
	2016年11月11日
	(光棍节)
	
	地宫BOSS
]]

_G.UIPalaceBoss = BaseUI:new('UIPalaceBoss');

UIPalaceBoss.currId = nil;

UIPalaceBoss.scene = nil;
UIPalaceBoss.objAvatar = nil;--模型
UIPalaceBoss.sceneLoaded = false;


function UIPalaceBoss:Create()
	self:AddSWF('PalaceBossPanel.swf',true,nil);
end
function UIPalaceBoss:OnLoaded(objSwf)
	objSwf.bossList.change = function (e)
		self.currId = t_xianyuancave[objSwf.bossList.selectedIndex + 1].id
		self:DrawBoss();
		self:DrawReward();
		self:UpdateStateTxt();
		self:UpdateBtnState()
	end
	
	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
	
	objSwf.btn_goon.click = function () self:OnGoPointClick(); end
	

	objSwf.btnPagePre.click     = function() self:OnBtnPreClick(); end
	objSwf.btnPageNext.click    = function() self:OnBtnNextClick(); end

end

function UIPalaceBoss:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.bossList
	local numlist = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.btnPagePre.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.btnPageNext.disabled = selectedIndex == numlist - 1
end

function UIPalaceBoss:OnBtnPreClick()
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

function UIPalaceBoss:OnBtnNextClick()
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

function UIPalaceBoss:OnGoPointClick()
	local objSwf = self.objSwf;
	if not objSwf then return end

    local cfg=t_xianyuancave[self.currId];
    if not cfg then return end
	if toint(cfg.level) > MainPlayerModel.humanDetailInfo.eaLevel then
		FloatManager:AddNormal(string.format(StrConfig["PalaceBoss001"],cfg.level),objSwf.btn_goon);
        return 
    end
    UIXianYuanCave:OpenPanel(self.currId);
end

function UIPalaceBoss:OnShow()

	PersonalBossController:AskGetPalaceBossInfo()

	self:OnShowBossList();
	self:StartTimer()
end

function UIPalaceBoss:OnRedicBossState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:OnShowBossList();
end

function UIPalaceBoss:OnShowBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	objSwf.bossList.dataProvider:cleanUp();
	local list=PersonalBossModel:GetPalaceBossList()
	for i=1,#list do
	    local cfg=t_xianyuancave[i];
	    local vo={};
		vo.headUrl 	= ResUtil:GetFieldBossIcon(cfg.background)
		vo.id 		= cfg.id;
		if toint(cfg.level) > MainPlayerModel.humanDetailInfo.eaLevel then
			vo.lv       = string.format("<font color='#FF0000'>挑战等级：%s</font>", cfg.level)
		else
			vo.lv       = string.format("<font color='#ffffff'>挑战等级：%s</font>", cfg.level)
		end
		local info = PersonalBossModel:GetPalaceBossInfo(cfg.id)
		local alive = info and info.state~=1 or false;
		if alive then
			vo.timeStr = string.format("<font color='#1ec71e'>%s</font>", StrConfig['worldBoss006'])
		else
			vo.timeStr = string.format(StrConfig['worldBoss504'], PublicUtil:GetShowTimeStr(PersonalUtil:GetPalaceRefreshTime(cfg.id)))
		end
		objSwf.bossList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.bossList:invalidateData();
	
	self.currId = 1;
	
	self:DrawBoss();
	self:DrawReward();
	objSwf.bossList.selectedIndex = 0;
end

function UIPalaceBoss:StartTimer()
	if self.timerKey then return end;
	self.timerKey = TimerManager:RegisterTimer( function()
		self:OnTimer();
	end, 1000, 0 );
	self:UpdateStateTxt();
end

--每秒刷新
function UIPalaceBoss:OnTimer()
	self:UpdateStateTxt();
end

function UIPalaceBoss:UpdateStateTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_xianyuancave[self.currId];
	if not cfg then return; end
	local info = PersonalBossModel:GetPalaceBossInfo(self.currId);
	if not info then 
		objSwf.killIcon._visible = false
		objSwf.refreshIcon._visible = false
		return; 
	end
	local killed = info.state == 1;
	local txt, txtColor = self:GetStateTxtInfo(killed);
	if txt == "" then
		objSwf.killIcon._visible = false
		objSwf.refreshIcon._visible = true
	else
		objSwf.killIcon._visible = true
		objSwf.refreshIcon._visible = false
	end
end

function UIPalaceBoss:GetStateTxtInfo(killed)
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

function UIPalaceBoss:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end
end

function UIPalaceBoss:OnHide()
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

function UIPalaceBoss:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_xianyuancave[self.currId];
	if not cfg then return; end
	
	local randomList = RewardManager:Parse(cfg.monsterReward);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end

function UIPalaceBoss:DrawBoss()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	local cfg = t_xianyuancave[self.currId];
	if not cfg then return; end
	local bossId = cfg.bossID;
	
	local drawCfg = UIDrawPalaceBossConfig[bossId];

	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawPalaceBossConfig[bossId] = drawCfg;
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
	
	objSwf.nameLoader.source = ResUtil:GetFieldBossIcon(cfg.name)
	-- objSwf.levelNumLoader.num = t_monster[toint(cfg.bossId)].level
	-- objSwf.txtCondition.htmlText = t_monster[toint(cfg.bossId)].level .. "级"
end

UIPalaceBoss.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	Rotation = 0
};
function UIPalaceBoss:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIPalaceBoss:OnBtnTeleportOver()
	local tips = MapUtils:GetTeleportTips();
	tips = tips .."<br/>".. StrConfig["activityswyj036"];
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end
function UIPalaceBoss:ListNotificationInterests()
	return { NotifyConsts.PalaceBossUpdate }
end

function UIPalaceBoss:HandleNotification(name, body)
	if name == NotifyConsts.PalaceBossUpdate then
		self:OnShowBossList()
	end
end