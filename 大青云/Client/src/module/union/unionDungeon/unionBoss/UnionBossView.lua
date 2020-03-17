--[[
  activity unionBoss
  wangshuai
]]

_G.UIUnionBoss = BaseUI:new("UIUnionBoss")

UIUnionBoss.curId = 1;

UIUnionBoss.curActivityid = 4;

UIUnionBoss.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(837,781)
								  };
								  

function UIUnionBoss:Create()
	self:AddSWF("UnionBossPanel.swf",true,nil)
end

function UIUnionBoss:OnLoaded(objSwf)
	objSwf.enter_btn.click = function()self:EnterActivity()end;
	objSwf.left_btn.click = function() self:LastId()end;
	objSwf.right_btn.click = function()self:NextId()end;

	RewardManager:RegisterListTips(objSwf.rewardlist);
end;

function UIUnionBoss:OnShow()
	self:InitInfo();
	self:SetEnterBtnState();
	self:ShowInfo()

end;

function UIUnionBoss:OnHide()
	if self.objUIDraw then 
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end;
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
end;

function UIUnionBoss:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIUnionBoss:SetEnterBtnState()
	local objSwf = self.objSwf;
	local state = UnionbossModel:GetOpenState();
	local isleader = UnionModel:IsLeader() -- 是否帮主
	local isDutySubLeader = UnionModel:IsDutySubLeader() --是否副帮主
	if state == 0 then --未开启
		if isleader or isDutySubLeader then 
			objSwf.enter_btn.label = StrConfig["unionBoss003"];
			objSwf.enter_btn.disabled = false;
		else
			objSwf.enter_btn.label = StrConfig["unionBoss004"]
			objSwf.enter_btn.disabled = true;
		end;
		objSwf.left_btn.disabled = false;
		objSwf.right_btn.disabled =  false;
	elseif state == 1 then  -- 已开启过
		objSwf.enter_btn.label = StrConfig["unionBoss005"]
		objSwf.enter_btn.disabled = true;
		objSwf.left_btn.disabled = false;
		objSwf.right_btn.disabled =  false;
	elseif state == 2 then  -- ing
		objSwf.enter_btn.label = StrConfig["unionBoss006"]
		objSwf.enter_btn.disabled = false;
		objSwf.left_btn.disabled = true;
		objSwf.right_btn.disabled =  true;
		self.curId = UnionbossModel:GetIngActId()
		--print(self.curId,"-00-0--0-0-0-0-0-00000000000")
	end;
end;

function UIUnionBoss:InitInfo()
	local myUnionLvl = UnionModel:GetMyUnionLevel();
	for i,info in ipairs(t_guildBoss) do
		if info.openlvl == myUnionLvl then 
			self.curId = info.id;
			break;
		end;
	end;
	--self.curId = 1;
end;

function UIUnionBoss:EnterActivity()
	local serverTime = GetLocalTime();
	local cfg = t_guildActivity[4]
	local vo = {};
	vo.startTime = CTimeFormat:daystr2sec(cfg.openTime);
	vo.endTime = vo.startTime + cfg.duration*60;
	local endtime = (serverTime - GetDayTime()); -- 今天0点 
	local JieshuTime = endtime + vo.endTime
	if GetDayTime() > vo.endTime or GetDayTime() < vo.startTime then 
		FloatManager:AddNormal(StrConfig["unionBoss019"]);
		return 
	end;
	
	local state = UnionbossModel:GetOpenState();
	if state == 2 then 
		if UnionbossModel:GetActState() then 
			FloatManager:AddNormal(StrConfig["unionBoss016"]);
			return
		end;
		if TeamModel:IsInTeam() then 
			FloatManager:AddNormal(StrConfig["unionBoss017"]);
			return 
		end;
		UnionBossController:EnterUnionBoss()
		return 
	end;

	if UIUnionBoss:OpenActivityJudge() == false then 
		return;
	end;
	
	local okfun = function () self:NextFun(); end;
	UIConfirm:Open(StrConfig["unionBoss015"],okfun)
end;

function UIUnionBoss:NextFun()
	local state = UnionbossModel:GetOpenState();
	local isleader = UnionModel:IsLeader() -- 是否帮主
	local isDutySubLeader = UnionModel:IsDutySubLeader() --是否副帮主
	--trace(stete)
	if state == 0 then 
		if isleader or isDutySubLeader then 
			if self:OpenActivityJudge() then 
				--print("这个")
				UnionBossController:OpenUnionBoss(self.curId)
			end;
		end;
	end;
end;

--是否够开启条件
function UIUnionBoss:OpenActivityJudge()
	local cfg = self:GetCfg();
	local myUnionMoney = UnionModel:GetMyUnionMoney();
	if myUnionMoney < cfg.consume then 
		FloatManager:AddNormal(StrConfig["unionBoss007"]);
		return false;
	end;
	local myUnionLvl = UnionModel:GetMyUnionLevel();
	if myUnionLvl < cfg.openlvl then 
		FloatManager:AddNormal(StrConfig["unionBoss008"]);
		return false;
	end;
	return true;
end;

function UIUnionBoss:LastId()
	self.curId = self.curId - 1;
	self:ShowInfo()
end;

function UIUnionBoss:NextId()
	self.curId = self.curId + 1;
	self:ShowInfo()
end;

function UIUnionBoss:GetCfg()
	local cfg = t_guildBoss[self.curId];
	if not cfg then 
		self.curId = 1;
		cfg = t_guildBoss[self.curId];
		if not cfg then 
			print("Error:cur cfg t_guildBoss id ",self.curId)
			return;
		end;
	end;
	return cfg;
end;

function UIUnionBoss:ShowInfo()
	local cfg = self:GetCfg();
	--print("cur cfg id ------",cfg.bossid)
	self:DrawMonster(cfg.bossid)
	self:SetUiInfo(cfg.bossid)
	self:SetUiRewardInfo()
end;

function UIUnionBoss:SetUiRewardInfo()
	local objSwf = self.objSwf
	--local cfg = self:GetCfg();
	----trace(cfg)
	local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfgid = roleLvl * 100 + self.curId;
	local cfg = t_guildBosslevel[cfgid]
	-- WriteLog(LogType.Normal,true,'-------------帮派boss:',cfgid,self.curId,roleLvl)
	local list = AttrParseUtil:ParseAttrToMap(cfg.rewardall)
	local uilist = {};
	for i,info in pairs(list) do 
		local reward =  RewardSlotVO:new();
		reward.id = toint(i);
		reward.count = toint(info);
		table.push(uilist,reward:GetUIData())
	end;

	objSwf.rewardlist.dataProvider:cleanUp();
	objSwf.rewardlist.dataProvider:push(unpack(uilist));
	objSwf.rewardlist:invalidateData();
end;

function UIUnionBoss:SetUiInfo(bossid)
	local objSwf = self.objSwf;
	local monsterCfg = t_monster[bossid];
	if not monsterCfg then 
		print("ERROR: cur monsterid is error",bossid)
		return 
	end;
	objSwf.BossName_txt.htmlText = monsterCfg.name; 

	objSwf.bosslvl_txt.htmlText = string.format(StrConfig["unionBoss014"],monsterCfg.level) ; 

	local actiCfg = t_guildActivity[self.curActivityid];
	local str = ""
	local startTime = CTimeFormat:daystr2sec(actiCfg.openTime);
	local startHour,startMin = CTimeFormat:sec2format(startTime);
	local endHour,endMin = CTimeFormat:sec2format(startTime+ actiCfg.duration * 60);
	str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
	str = str .. " ";
	objSwf.openTime_txt.htmlText = str;


	local bossCfg = self:GetCfg()
	local lvlstr = string.format(StrConfig["unionBoss001"],bossCfg.openlvl) 
	--local moneystr = string.format(StrConfig["unionBoss002"],bossCfg.consume)
	local unionLvl = UnionModel:GetMyUnionLevel()
	if unionLvl >= bossCfg.openlvl then 
		objSwf.openlvl_txt._visible = false;
	else
		objSwf.openlvl_txt._visible = true;
	end;
	objSwf.openlvl_txt.htmlText = lvlstr;
	local moneyU = UnionModel:GetMyUnionMoney()
	local str = ""
	if bossCfg.consume >  moneyU then 
		str = string.format(StrConfig['unionBoss018'],"#FF0000",bossCfg.consume)
	else
		str = string.format(StrConfig['unionBoss018'],"#00FF00",bossCfg.consume)
	end;
	objSwf.unionmoney_txt.htmlText = str;
end;	

function UIUnionBoss:DrawMonster(monsterid)
	local objSwf = self.objSwf;
	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,monsterid)
	monsterAvater:InitAvatar();
	local drawcfg = UIDrawUnionbossConfig[monsterid]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
	end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("UnionBossMonster",monsterAvater, objSwf.boss_load,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIShihunMonster");
	else 
		self.objUIDraw:SetUILoader(objSwf.boss_load);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	self.objUIDraw:SetDraw(true);
end;

-- 创建配置文件
function UIUnionBoss:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	return cfg;
end