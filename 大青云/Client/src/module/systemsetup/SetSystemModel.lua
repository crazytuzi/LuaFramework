--[[
	2015年1月15日, PM 04:30:49
	系统设置数据
	wangyanwei
]]

_G.SetSystemModel = Module:new();

---------------==<<<<<<<<接到服务器传过来的设置>>>>>>>>>>==------------------
SetSystemModel.oldSetVal = 0;
SetSystemModel.SetModel = nil;  --显示设置
function SetSystemModel:UpDataSetModel(val)
	self.oldSetVal = val;
	local obj = {};
	obj.showPlayerNum = nil;
--	if bit.band(val,SetSystemConsts.MUSICOPEN) == SetSystemConsts.MUSICOPEN then obj.musicIsOpen = true; else obj.musicIsOpen = false; end  		--音乐效果
--	if bit.band(val,SetSystemConsts.MUSICBGOPEN) == SetSystemConsts.MUSICBGOPEN then obj.musicBGIsOpen = true; else obj.musicBGIsOpen = false; end  --背景音乐效果
--	if bit.band(val,SetSystemConsts.TEAMISOPEN) == SetSystemConsts.TEAMISOPEN then obj.teamIsOpen = true; else obj.teamIsOpen = false; end  		--是否组队
--	if bit.band(val,SetSystemConsts.DEALISOPEN) == SetSystemConsts.DEALISOPEN then obj.dealIsOpen = true; else obj.dealIsOpen = false; end  		--是否交易
	if bit.band(val,SetSystemConsts.FRIENDISOPEN) == SetSystemConsts.FRIENDISOPEN then obj.friendIsOpen = true; else obj.friendIsOpen = false; end  --是否开启好友
	if bit.band(val,SetSystemConsts.UNIONISOPEN) == SetSystemConsts.UNIONISOPEN then obj.unionIsOpen = true; else obj.unionIsOpen = false; end  	--开启工会
	if bit.band(val,SetSystemConsts.UNSHOWNUMZERO) == SetSystemConsts.UNSHOWNUMZERO then obj.showPlayerNum = 0; self.oldSetVal = self.oldSetVal - SetSystemConsts.UNSHOWNUMZERO; end  								--全部隐藏
	if bit.band(val,SetSystemConsts.UNSHOWNUMTEN) == SetSystemConsts.UNSHOWNUMTEN then obj.showPlayerNum = 1; self.oldSetVal = self.oldSetVal - SetSystemConsts.UNSHOWNUMTEN; end  									--显示十个
	if bit.band(val,SetSystemConsts.UNSHOWNUMTWENTY) == SetSystemConsts.UNSHOWNUMTWENTY then obj.showPlayerNum = 2;  self.oldSetVal = self.oldSetVal - SetSystemConsts.UNSHOWNUMTWENTY; end								--显示二十个
	if bit.band(val,SetSystemConsts.UNSHOWNUMTHIRTY) == SetSystemConsts.UNSHOWNUMTHIRTY then obj.showPlayerNum = 3; self.oldSetVal = self.oldSetVal - SetSystemConsts.UNSHOWNUMTHIRTY; end								--显示三十个
	if bit.band(val,SetSystemConsts.UNSHOWNUMALL) == SetSystemConsts.UNSHOWNUMALL then obj.showPlayerNum = 4; self.oldSetVal = self.oldSetVal - SetSystemConsts.UNSHOWNUMALL; end									--显示全部
	if bit.band(val,SetSystemConsts.UNSHOWNUMNAME) == SetSystemConsts.UNSHOWNUMNAME then obj.unAllPlayerShowName = true; else obj.unAllPlayerShowName = false; end									--显示名字
	if bit.band(val,SetSystemConsts.ISSHOWSKILL) == SetSystemConsts.ISSHOWSKILL then obj.isShowSkill = true; else obj.isShowSkill = false; end		--屏蔽他人技能特效
	if bit.band(val,SetSystemConsts.ISOPENFLASH) == SetSystemConsts.ISOPENFLASH then obj.isOpenFlash = true; else obj.isOpenFlash = false; end		--屏蔽低血量闪屏特效
	if bit.band(val,SetSystemConsts.ISSHOWCOMMONMONSTER) == SetSystemConsts.ISSHOWCOMMONMONSTER then obj.isShowCommonMonster = true; else obj.isShowCommonMonster = false; end--屏蔽普通怪物造型
--	if bit.band(val,SetSystemConsts.ROLEAUTOPOINTSET) == SetSystemConsts.ROLEAUTOPOINTSET then obj.roleAutoPointSet = true; else obj.roleAutoPointSet = false; end--人物属性点自动分配
	if bit.band(val,SetSystemConsts.TEAMINVITE) == SetSystemConsts.TEAMINVITE then obj.teamInviteOpen = true; else obj.teamInviteOpen = false; end--是否接受组队邀请
	if bit.band(val,SetSystemConsts.TEAMAPPLAY) == SetSystemConsts.TEAMAPPLAY then obj.teamApplayOpen = true; else obj.teamApplayOpen = false; end--是否接受入队申请
	if bit.band(val,SetSystemConsts.ISSHOWTITLE) == SetSystemConsts.ISSHOWTITLE then obj.isShowTitle = true; else obj.isShowTitle = false; end--是否显示他人称号
	
	if bit.band(val,SetSystemConsts.HIGHDEFINITION) == SetSystemConsts.HIGHDEFINITION then obj.highDefinition = true; else obj.highDefinition = false; end  --是否开启了高光
	if bit.band(val,SetSystemConsts.FLOWRIGHT) == SetSystemConsts.FLOWRIGHT then obj.flowRight = true; else obj.flowRight = false; end  --是否开启了泛光
	
	--画面配置
	if bit.band(val,SetSystemConsts.DRAWLOW) == SetSystemConsts.DRAWLOW then obj.drawLevel = DisplayQuality.lowQuality; self.oldSetVal = self.oldSetVal - SetSystemConsts.DRAWLOW; end  --低配
	if bit.band(val,SetSystemConsts.DRAWMID) == SetSystemConsts.DRAWMID then obj.flowRight = false; obj.showPlayerNum = 2; obj.drawLevel = DisplayQuality.midQuality; self.oldSetVal = self.oldSetVal - SetSystemConsts.DRAWMID; end  --推荐
	if bit.band(val,SetSystemConsts.DRAWHIGH) == SetSystemConsts.DRAWHIGH then obj.drawLevel = DisplayQuality.highQuality; self.oldSetVal = self.oldSetVal - SetSystemConsts.DRAWHIGH; end  --高配
	if not obj.drawLevel then
		obj.drawLevel = DisplayQuality.midQuality
		obj.showPlayerNum = 2;
		obj.flowRight = false;
	end
	--多倍视角
--	if bit.band(val,SetSystemConsts.DOUBLEOVERLOOKS) == SetSystemConsts.DOUBLEOVERLOOKS then obj.doubleLooks = true; else obj.doubleLooks = false; end  --低配
	
	self.SetModel = SetSystemVO:new(obj);
	self:OpenFunc();
	self:sendNotification(NotifyConsts.SetSystemShowChange);
end

--储存当前设置字符
SetSystemModel.KeyStr = '';
--设置快捷键
SetSystemModel.setModelFuncKey = {};--功能
SetSystemModel.copyModelFuncKey = {};
SetSystemModel.setSkillKey = {};--技能
SetSystemModel.copySkillKey = {};
SetSystemModel.setDrugKey = {};--药品
SetSystemModel.copyDrugKey = {};
SetSystemModel.SetSkillInit = deepcopy(SkillConsts.KeyMap);      ---技能键默认的按键
function SetSystemModel:UpDataFuncKey(str)
	self.KeyStr = str;

	local strCfg = split(str,'#');
	if #strCfg ~= 3 then
		self:ModelErrorHandler();
		return
	end
	
	local cfg1 = split(strCfg[2],',');
	if #cfg1 ~= #SetSystemConsts.SkillKeyMap then
		self:ModelErrorHandler();
		return
	end
	
	local cfg2 = split(strCfg[3],',');
	if #cfg2 ~= #SetSystemConsts.DrugKeyMap then
		self:ModelErrorHandler();
		return 
	end
	
	local cfg = split(strCfg[1],',');
	for i = 1 , #cfg do									--功能数据
		local funcCfg = split(cfg[i],':');
		local num = tonumber(funcCfg[1]);
		self.setModelFuncKey[num] = {};
		self.setModelFuncKey[num].str = funcCfg[2];
		self.setModelFuncKey[num].id = num;
	end
	local oldSkillKey = deepcopy(self.setSkillKey);		--保存前的数据
	local cfg1 = split(strCfg[2],',');
	for i = 1 , #cfg1 do
		local skillCfg = split(cfg1[i],':');
		local num = tonumber(skillCfg[1]);
		self.setSkillKey[num] = {};
		self.setSkillKey[num].str = skillCfg[2];
		self.setSkillKey[num].id = num;
	end
	local oldDrugKey = deepcopy(self.setDrugKey);	--保存前的数据
	for i = 1 , #cfg2 do
		local drugCfg = split(cfg2[i],':');
		local num = tonumber(drugCfg[1]);
		self.setDrugKey[num] = {};
		self.setDrugKey[num].str = drugCfg[2];
		self.setDrugKey[num].id = num;
	end
	local skillHasChange = false;
	for i , v in ipairs(self.setSkillKey) do
		if not oldSkillKey[i] then 
			skillHasChange = true;
			break
		end
		if v.str ~= oldSkillKey[i].str then
			skillHasChange = true;
			break
		end
	end
	for i , v in ipairs(self.setDrugKey) do
		if not oldDrugKey[i] then 
			skillHasChange = true;
			break
		end
		if v.str ~= oldDrugKey[i].str then
			skillHasChange = true;
			break
		end
	end
	self:SetFuncKeyHandler();
	
	--//改变界面下方技能栏技能字符串
	if skillHasChange then
		self:sendNotification(NotifyConsts.SkillShortCutRefresh);
		self:sendNotification(NotifyConsts.ItemShortCutRefresh);
	end
end

--重构执行方法
function SetSystemModel:ModelErrorHandler()
	print('Error！！！！！！！！！！！！！重构！！！！！！！！！！！！')
	self.setModelFuncKey = {};
	self.setSkillKey = {};
	self.setDrugKey = {};
	self.KeyStr = '';
	self:SetFuncInitKey();
end

--给功能附快捷键
function SetSystemModel:SetFuncKeyHandler()
	self.copyModelFuncKey = deepcopy(self.setModelFuncKey);
	self.copySkillKey = deepcopy(self.setSkillKey);
	self.copyDrugKey = deepcopy(self.setDrugKey);
	for i = 1 , #SetSystemConsts.KeyFuncID do
		local cfg = self.setModelFuncKey[SetSystemConsts.KeyFuncID[i]];
		local cfgFunc = FuncManager:GetFunc(cfg.id); --获取功能
		cfgFunc:SetFuncKey(-1);
		for j , k in pairs(SetSystemConsts.KeyConsts) do
			if cfg.str == '' then
				cfgFunc:SetFuncKey(-1);
			end
			if cfg.str == k then
				cfgFunc:SetFuncKey(j);
			end
		end
	end
	--  以上是功能
	self:sendNotification(NotifyConsts.SetSystemFuncChange);
	--  以下是技能
	for i = 1 , #self.setSkillKey do
		for j , k in pairs(SetSystemConsts.KeyConsts) do
			if self.setSkillKey[i].str == '' then
				SkillConsts.KeyMap[SetSystemConsts.SkillKeyMap[i]].keyCode = nil;
			end
			if self.setSkillKey[i].str == k then
				SkillConsts.KeyMap[SetSystemConsts.SkillKeyMap[i]].keyCode = j;
			end
		end
	end
	for i = 1 , #self.setDrugKey do
		for j , k in pairs(SetSystemConsts.KeyConsts) do
			if self.setDrugKey[i].str == '' then
				SkillConsts.ShortCutItemKey = nil;
			end
			if self.setDrugKey[i].str == k then
				SkillConsts.ShortCutItemKey = j;
			end
		end
	end
	self:sendNotification(NotifyConsts.SetSystemSkillChange);
end

--设置里面是否已经有了这个按键  
--@param keyStr 传过来要修改的键str
function SetSystemModel:GetIsFuncKey(keyStr)
	local cfg = self:GetFuncKey();
	for i , v in pairs(cfg) do
		if keyStr == v.str then
			return	true;
		end
	end
	local cfg2 = self:GetSkillKey();
	for j , k in pairs(cfg2) do
		if keyStr == k.str then
			return  true;
		end
	end
	local cfg3 = self:GetDrugKey();
	for i , k in pairs(cfg3) do
		if keyStr == k.str then
			return  true;
		end
	end
	return false;
end

--清掉冲突的字符
function SetSystemModel:OnClearKeyStr(str)
	local cfg1 = self:GetFuncKey();
	local cfg2 = self:GetSkillKey();
	local cfg3 = self:GetDrugKey();
	for i , k in pairs(cfg1) do
		if k.str == str then
			self.copyModelFuncKey[i].str = '';
			return;
		end
	end
	for i , k in pairs(cfg2) do
		if k.str == str then
			self.copySkillKey[i].str = '';
			return;
		end
	end
	for i , k in pairs(cfg3) do
		if k.str == str then
			self.copyDrugKey[i].str = '';
		end
	end
end

--取STR值   用于交互
function SetSystemModel:GetFuncKeyStr()
	local str = '';
	local cfg1 = SetSystemModel:GetFuncKey();
	local cfg2 = SetSystemModel:GetSkillKey();
	local cfg3 = self:GetDrugKey();
	for i , v in ipairs(SetSystemConsts.KeyFuncID) do
		if i == #SetSystemConsts.KeyFuncID then
			str = str .. cfg1[v].id .. ':' .. cfg1[v].str .. '#';
		else
			str = str .. cfg1[v].id .. ':' .. cfg1[v].str .. ',';
		end
	end
	for i , v in ipairs(SetSystemConsts.SkillKeyMap) do
		if i == #SetSystemConsts.SkillKeyMap then
			str = str .. cfg2[i].id .. ':' .. cfg2[i].str .. '#';
		else
			str = str .. cfg2[i].id .. ':' .. cfg2[i].str .. ',';
		end
	end
	for i , v in ipairs(SetSystemConsts.DrugKeyMap) do
		if i == #SetSystemConsts.DrugKeyMap then
			str = str .. cfg3[i].id .. ':' .. cfg3[i].str;
		else
			str = str .. cfg3[i].id .. ':' .. cfg3[i].str .. ',';
		end
	end
	return str
end

--得到功能设置的按键
function SetSystemModel:GetFuncKey()
	return self.copyModelFuncKey;
end

--得到技能设置的按键
function SetSystemModel:GetSkillKey()
	return self.copySkillKey;
end

--得到药品设置的按键
function SetSystemModel:GetDrugKey()
	return self.copyDrugKey;
end

--恢复默认
function SetSystemModel:SetFuncInitKey()
	--将所有功能按键恢复默认
	for i , v in ipairs(SetSystemConsts.KeyFuncID) do
		local cfgFunc = FuncManager:GetFunc(v); --获取功能
		cfgFunc:SetFuncKey(-1);
	end
	local str = '';
	for i , v in ipairs(SetSystemConsts.KeyFuncID) do
		local cfgFunc = FuncManager:GetFunc(v); --获取功能
		cfgFunc:SetFuncKey(nil);
		local key = cfgFunc:GetFuncKey();
		if i == #SetSystemConsts.KeyFuncID then 
			str = str .. v .. ':' .. SetSystemConsts.KeyConsts[key] .. '#';
		else
			str = str .. v .. ':' .. SetSystemConsts.KeyConsts[key] .. ',';
		end
	end
	--将所有技能按键恢复默认
	for i , v in ipairs(SetSystemConsts.SkillKeyMap) do
		for j , k in pairs(self.SetSkillInit) do
			
			if v == j then
				SkillConsts.KeyMap[v].keyCode = k.keyCode;
				if v == SetSystemConsts.SkillKeyMap[#SetSystemConsts.SkillKeyMap] then
					str = str .. i .. ':' .. SetSystemConsts.KeyConsts[k.keyCode] .. '#';
				else

					str = str .. i .. ':' .. SetSystemConsts.KeyConsts[k.keyCode] .. ',';
				end
			end
		end
	end
	
	--药品按键
	for i , v in ipairs(SetSystemConsts.DrugKeyMap) do
		if i == #SetSystemConsts.DrugKeyMap then
			str = str .. i .. ':' .. SetSystemConsts.KeyConsts[v];
		else
			str = str .. i .. ':' .. SetSystemConsts.KeyConsts[v] .. ',';
		end
	end

	self:UpDataFuncKey(str);
	--将显示设置恢复默认
	self:UpDataSetModel(SetSystemConsts.ININTSHOWMODEL);
end

function SetSystemModel:GetMusicIsOpen()
	local cfg = self.SetModel;
	if not cfg then return true; end
	if cfg and cfg:GetMusicIsOpen() then   ---背景音乐
		return true
	else
		return false
	end
end


--开启功能
function SetSystemModel:OpenFunc()
	local cfg = self.SetModel;
	SetSystemController:SetHdMode(cfg:GetHighDefinition())
--	SetSystemController:SetGlowFactor(cfg:GetFlowRight())

	--画面设置
	SetSystemController:SetDisplayQuality(cfg:GetDrawLevel())
	
	if SetSystemModel:LoadAudioMute() == 0 then   ---背景音乐
		SetSystemController:CloseBackSoundVolume();
	else
		SetSystemController:OpenBackSoundVolume();
	end
	if SetSystemModel:LoadAudioMute() == 0 then  ---特效音乐
		SetSystemController:CloseMusicVolume();
	else
		SetSystemController:OpenMusicVolume();
	end
	local num = cfg:GetUnShowNum(); --显示人数
	if num == 0 then
		SetSystemController:HideAllPlayer();
	elseif num == 1 then
		SetSystemController:Show10Player();
	elseif num == 2 then
		SetSystemController:Show20Player();
	elseif num == 3 then
		SetSystemController:Show30Player();
	elseif num == 4 then
		SetSystemController:ShowAllPlayer();
	end

	if cfg:GetUnAllPlayerShowName() then
		SetSystemController:HideAllPlayerShowName()
	end

	if cfg:GetIsShowSkill() then
		SetSystemController:HidePlayerPfx();
	else
		SetSystemController:ShowPlayerPfx();
	end
	if cfg:GetIsOpenFlash() then
		UIBeatenAnimation:OnSetIsShow(true);
	else
		UIBeatenAnimation:OnSetIsShow(false);
	end
	if cfg:GetIsShowCommonMonster() then
		SetSystemController:HideAllMonster();
	else
		SetSystemController:ShowAllMonster();
	end
	if cfg:GetIsDoubleLooks() then
		SetSystemController:OpenHighView();
	else
		SetSystemController:CloseHighView();
	end

	--音量设置
	self:SetAllVolume(self:LoadAudioValue(), self:LoadSoundEffectValue());
end

function SetSystemModel:SetAllVolume(audioVol, soundEffectVol)
	SoundManager:SetBackSoundVolume(audioVol);
	SoundManager:SetBackSoundStoryVolume(audioVol);
	SoundManager:SetMusicVolume(soundEffectVol);
end

--返回是否可交易 true 不可
function SetSystemModel:GetIsDeal()
	local cfg = self.SetModel;
	if not cfg then return true; end
	if cfg:GetDealIsOpen() then
		return true;
	end
	return false;
end
--返回是否可组队 true 不可
function SetSystemModel:GetIsTeam()
	local cfg = self.SetModel;
	if not cfg then return true; end
	if cfg:GetTeamIsOpen() then
		return true;
	end
	return false;
end
--返回是否可添加好友 true 不可
function SetSystemModel:GetIsFriend()
	local cfg = self.SetModel;
	if not cfg then return true; end
	if cfg:GetFriendIsOpen() then
		return true;
	end
	return false;
end
--返回是否可帮派邀请 true 不可
function SetSystemModel:GetIsUnion()
	local cfg = self.SetModel;
	if not cfg then return true; end
	if cfg:GetUnionIsOpen() then
		return true;
	end
	return false;
end

--获取以储存的设置信息
function SetSystemModel:GetSetSysModel()
	return self.oldSetVal,self.KeyStr;
end

--是否显示他人称号
function SetSystemModel:GetIsShowTitle()
	local cfg = self.SetModel;
	if not cfg then return true; end
	return cfg:GerIsShowTitle();
end

function SetSystemModel:LoadAudioMute()
	local roleCfg = ConfigManager:GetRoleCfg();
	if not roleCfg.audioMute then
		roleCfg.audioMute = self:LoadDefaultAudioMute();
		ConfigManager:Save();
	end
	return roleCfg.audioMute;
end

function SetSystemModel:LoadAudioValue()
	local roleCfg = ConfigManager:GetRoleCfg();
	if not roleCfg.audioValue then
		roleCfg.audioValue = self:LoadDefaultAudioValue();
		ConfigManager:Save();
	end
	return roleCfg.audioValue;
end
function SetSystemModel:LoadSoundEffectValue()
	local roleCfg = ConfigManager:GetRoleCfg();
	if not roleCfg.soundEffectValue then
		roleCfg.soundEffectValue = self:LoadDefaultSoundEffectValue();
		ConfigManager:Save();
	end
	return roleCfg.soundEffectValue;
end

function SetSystemModel:SaveAudioMute(value)
	local roleCfg = ConfigManager:GetRoleCfg();
	roleCfg.audioMute = value;
	ConfigManager:Save();
end

function SetSystemModel:SaveAudioValue(value)
	local roleCfg = ConfigManager:GetRoleCfg();
	roleCfg.audioValue = value;
	ConfigManager:Save();
end

function SetSystemModel:SaveSoundEffectValue(value)
	local roleCfg = ConfigManager:GetRoleCfg();
	roleCfg.soundEffectValue = value;
	ConfigManager:Save();
end

function SetSystemModel:LoadDefaultAudioMute()
	return 1;
end
function SetSystemModel:LoadDefaultAudioValue()
	return 30;
end
function SetSystemModel:LoadDefaultSoundEffectValue()
	return 30;
end

function SetSystemModel:GetIsShowPlayerTianShen()
	local roleCfg = ConfigManager:GetRoleCfg();
	if not roleCfg.isShowPlayerTianShen then
		roleCfg.isShowPlayerTianShen = 1;
		ConfigManager:Save();
	end
	if roleCfg.isShowPlayerTianShen == 1 then
		return true;
	else
		return false;
	end
end

function SetSystemModel:SaveIsShowPlayerTianShen(value)
	local i = 0;
	if value then
		i = 1;
	else
		i = 0;
	end
	local roleCfg = ConfigManager:GetRoleCfg();
	roleCfg.isShowPlayerTianShen = i;
	ConfigManager:Save();
end

function SetSystemModel:GetIsShowPlayerMagicWeapon()
	local roleCfg = ConfigManager:GetRoleCfg();
	if not roleCfg.isShowPlayerMagicWeapon then
		roleCfg.isShowPlayerMagicWeapon = 1;
		ConfigManager:Save();
	end
	if roleCfg.isShowPlayerMagicWeapon == 1 then
		return true;
	else
		return false;
	end
end

function SetSystemModel:SaveIsShowPlayerMagicWeapon(value)
	local i = 0;
	if value then
		i = 1;
	else
		i = 0;
	end
	local roleCfg = ConfigManager:GetRoleCfg();
	roleCfg.isShowPlayerMagicWeapon = i;
	ConfigManager:Save();
end