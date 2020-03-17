--[[
	2015年10月20日22:11:31
	wangyanwei
	福神降临
]]

_G.UIMascotComeInfo = BaseUI:new('UIMascotComeInfo');

function UIMascotComeInfo:Create()
	self:AddSWF('mascotCome.swf',true,'bottom');
end

function UIMascotComeInfo:OnLoaded(objSwf)
	-- objSwf.smallPanel.txt_title.text = UIStrConfig['mascotCome1'];
	objSwf.btn_state.click = function () self:ChangeSmallPanelState(); end
	objSwf.smallPanel.btn_quit.click = function () self:OnBtnExitClick() end
	objSwf.smallPanel.txt_boss._visible = false;
	objSwf.smallPanel.btnAuto.click = function() self:OnBtnAutoClick() end
end

UIMascotComeInfo.isKillBoss = false;		--BOss是否被击杀
function UIMascotComeInfo:OnShow()
	self:MonsterUpDate();
	self:ShowDungeonType();
	self:SetUIState();
	self.isAutoBattle = false;  --默认开始为非挂机状态
end

-- 点击退出
function UIMascotComeInfo:OnBtnExitClick()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetType() ~= ActivityConsts.T_MascotCome then return; end
	ActivityController:QuitActivity(activity:GetId());
	ActivityMascotCome.currentChooseMascotComeActivityID = 0;
end


--改变挂机按钮文本
function UIMascotComeInfo:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.state = state;
	if state then
		AutoBattleController:OpenAutoBattle()   --自动战斗
		objSwf.smallPanel.btnAuto.labelID = 'waterDungeon012'
	else
		objSwf.smallPanel.btnAuto.labelID = 'waterDungeon009'
	end
end

function UIMascotComeInfo:OnBtnAutoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.isAutoBattle = not self.isAutoBattle
	if self.state ~= true then
		AutoBattleController:OpenAutoBattle();
		-- objSwf.panel.btnAuto.labelID = 'waterDungeon012'
	else
		AutoBattleController:CloseAutoHang()
		-- objSwf.panel.btnAuto.labelID = 'waterDungeon009'
	end
end

function UIMascotComeInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.smallPanel._visible = true
	objSwf.smallPanel.hitTestDisable = false;
	objSwf.btn_state.selected = false;
end;

function UIMascotComeInfo:ChangeSmallPanelState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_state.selected = objSwf.smallPanel.visible;
	objSwf.smallPanel.visible = not objSwf.smallPanel.visible;
end

function UIMascotComeInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.smallPanel.visible = true;
	objSwf.smallPanel.txt_boss._visible = false;
	self.isKillBoss = false;
	self.state = false
end

function UIMascotComeInfo:GetWidth()
	return 256;
end

function UIMascotComeInfo:GetHeight()
	return 331;
end

--副本内怪物数量发生变化
function UIMascotComeInfo:MonsterUpDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- if level<100 then
		-- local num1 = level/10;
		-- level = (num1+1)*10;
	-- else
		-- local num1 = level/100;
		-- local num2 = level%10;
		-- local num3 = num2/10;
		-- local num4 = (num3+1)*10;
		-- level = num1*100+num4;
	-- end
	-- WriteLog(LogType.Normal,true,'--------------UIMascotComeInfo:MonsterUpDate() ',level);
	
	local snatchdoorCfg = t_snatchdoor[level];
	if not snatchdoorCfg then print('not level ~!!!!!!!!!!',level) return end
	local wave = ActivityMascotCome:GetWaveNum();
	if wave <= 0 then print('not wave ~!!!!!!!!!!',wave) return end								--当前波数
	local dungeonType = self.monsterType ;
	if dungeonType <= 0 then print('not dungeonType ~!!!!!!!!!!',dungeonType) return end
	
	snatchdoorCfg = snatchdoorCfg['number' .. self.monsterType];
	if not snatchdoorCfg then print('not snatchdoorCfg number monsterType~!!!!!!!!!!',self.monsterType) return end
	
	local monsterCfg = split(snatchdoorCfg,'#')[wave];
	
	if not monsterCfg then print('not wave ' ,wave ) return end
	
	monsterCfg = split(monsterCfg,',');
	local monsterID = monsterCfg[1];
	
	local monsterTable = t_monster[toint(monsterID)];
	if not monsterTable then print('not monsterTable',monsterTable) return end
	
	local maxMonsterNum = monsterCfg[2];						--本波总数量
	
	local killMonsterNum = ActivityMascotCome:GetMonsterNum();	--已击杀数量
	
	if wave >= #(split(snatchdoorCfg,'#')) then
		if self.isKillBoss then
			killMonsterNum = killMonsterNum - 1;
		end
	end
	
	local monsterName = monsterTable.name;						--怪物名称
	
	local constsCfg = t_consts[120];							--常量
	if not constsCfg then print('not consts') return end
	
	objSwf.smallPanel.txt_wave.htmlText = string.format(StrConfig['mascotCome001'],wave,#(split(snatchdoorCfg,'#')));
	
	objSwf.smallPanel.txt_monster.htmlText = string.format(StrConfig['mascotCome002'],monsterName,killMonsterNum .. '/' .. maxMonsterNum);
	
	if wave >= #(split(snatchdoorCfg,'#')) then
		objSwf.smallPanel.txt_boss._visible = true;
	else
		return 
	end
	-- if level<100 then
		-- local num1 = level/10;
		-- level = (num1+1)*10;
	-- else
		-- local num1 = level/100;
		-- local num2 = level%10;
		-- local num3 = num2/10;
		-- local num4 = (num3+1)*10;
		-- level = num1*100+num4;
	-- end
	
	-- WriteLog(LogType.Normal,true,'---------------------UIMascotComeInfo:MonsterUpDate()',level)
	
	local bossCfg = split(t_snatchdoor[level].boss,',');
	local bossID = bossCfg[1];
	local bossCfg = t_monster[toint(bossID)];
	objSwf.smallPanel.txt_boss.text = bossCfg.name;
end

--副本类型确定  确定副本内怪物的类型
UIMascotComeInfo.monsterType = 0;	
function UIMascotComeInfo:ShowDungeonType()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local dungeonType = ActivityMascotCome:GetDungeonType();
	if dungeonType == 0 then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- if level<100 then
		-- local num1 = level/10;
		-- level = (num1+1)*10;
	-- else
		-- local num1 = level/100;
		-- local num2 = level%10;
		-- local num3 = num2/10;
		-- local num4 = (num3+1)*10;
		-- level = num1*100+num4;
	-- end
	local snatchdoorCfg = t_snatchdoor[level];
	if not snatchdoorCfg then return end
	self.monsterType = dungeonType;
	
	snatchdoorCfg = snatchdoorCfg['number' .. self.monsterType];
	if not snatchdoorCfg then return end
	
	local monsterCfg = split(snatchdoorCfg,'#')[1];
	
	if not monsterCfg then return end
	
	monsterCfg = split(monsterCfg,',');
	local monsterID = monsterCfg[1];
	
	local monsterTable = t_monster[toint(monsterID)];
	if not monsterTable then return end
	
	local maxMonsterNum = monsterCfg[2];						--本波总数量
	
	local killMonsterNum = 0;	--已击杀数量
	
	local monsterName = monsterTable.name;						--怪物名称
	
	local constsCfg = t_consts[120];							--常量
	if not constsCfg then return end
	
	objSwf.smallPanel.txt_wave.htmlText = string.format(StrConfig['mascotCome001'],1,#(split(snatchdoorCfg,'#')));
	objSwf.smallPanel.txt_monster.htmlText = string.format(StrConfig['mascotCome002'],monsterName,0 .. '/' .. maxMonsterNum);
end

--计时退出
function UIMascotComeInfo:OnTimeChange(timeNum)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if timeNum <= 0 then
		objSwf.smallPanel.txt_time.htmlText = string.format(StrConfig['mascotCome003'],'00:00');
		return
	end
	local hour,min,sec = CTimeFormat:sec2format(timeNum);
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	objSwf.smallPanel.txt_time.htmlText = string.format(StrConfig['mascotCome003'],min .. ':' .. sec);
end

--是否击杀了BOSS   将不计入击杀数量的范围
function UIMascotComeInfo:OnKillBoss(id)
	local dungeonType = self.monsterType;
	if dungeonType == 0 then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- if level<100 then
		-- local num1 = level/10;
		-- level = (num1+1)*10;
	-- else
		-- local num1 = level/100;
		-- local num2 = level%10;
		-- local num3 = num2/10;
		-- local num4 = (num3+1)*10;
		-- level = num1*100+num4;
	-- end
	local snatchdoorCfg = t_snatchdoor[level];
	if not snatchdoorCfg then return end
	
	local bossCfg = split(snatchdoorCfg.boss,',');
	local bossID = bossCfg[1];
	
	-- print(bossID,id,'=================')
	if id == toint(bossID) then
		-- debug.debug();
		self.isKillBoss = true;
	end
end

function UIMascotComeInfo:HandleNotification(name,body)
	if name == NotifyConsts.MascotComeUpDate then
		self:MonsterUpDate();
	elseif name == NotifyConsts.MascotComeType then
		self:ShowDungeonType();
	elseif name == NotifyConsts.MascotComeTime then
		self:OnTimeChange(body.timeNum);
	elseif name == NotifyConsts.MascotComeKillID then
		self:OnKillBoss(body.monsterID)
	elseif name == NotifyConsts.AutoHangStateChange then
		self:OnChangeAutoText(body.state);
	end
end
function UIMascotComeInfo:ListNotificationInterests()
	return {
		NotifyConsts.MascotComeUpDate,
		NotifyConsts.MascotComeType,
		NotifyConsts.MascotComeTime,
		NotifyConsts.MascotComeKillID,
		NotifyConsts.AutoHangStateChange,
	}
end