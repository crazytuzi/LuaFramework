-------------------------------------------------------
module(..., package.seeall)
local require = require;
--local ui = require("ui/base");
local ui = require("ui/chatBase")
local Timer = require("i3k_timer")

--[[
new battle 界面将原有的一个拆分为多个内容，当需要的时候添加，不需要的时候移除，来提升游戏的流畅度。
* battleBase 是战斗界面的主体内容，这里控制这技能和头像等级血条等内容，另外还有控制其它部分添加或删除的逻辑
* battleBossHp 显示boss或者玩家的血条
* battleDrug 药品相关
* battleEquip 任务的开采，提示新装备
* battleFight 副本界面321go动画
* battleFuben 副本界面的箭头和倒计时退出副本按钮
* battleNPChp 小怪血条
* battlePets 宠物（佣兵）相关
* battleProcessBar 开采的进度条
* battleRoom 遇到官邸boss
* battleShowExp 显示获得经验的动画
* battleTask 左侧的任务，包括任务逻辑
* battleTeam 队友信息
* battleTXAcceptTask 接受任务特效
* battleTXFinishTask 完成任务特效
* battleMiniMap 右上角小地图
* battleEntrance 小活动的入口
* battleOfflineExp 离线经验入口
* battleUnlockSkill 未解锁技能特效界面
]]
-------------------------------------------------------
local Record_timer = i3k_class("Record_timer", Timer.i3k_timer);
-------------------------------------------------------
wnd_battleBase = i3k_class("wnd_battleBase", ui.wnd_chatBase)

local skill_grade = {3542,3543,3544,3545,3546}
local f_pkImageTable = {643, 644, 645,2246, i3k_db_war_zone_map_cfg.severImgId}
local LAYER_RWLBT = "ui/widgets/rwlbt"
local LAYER_RWLBT2 = "ui/widgets/rwlbt2"
local LAYER_BUFF = "ui/widgets/bufft"
local BUFF_DRUG_ICON = 4371
local FIGHT_LINE_BUFF_DRUG_ICON = 4597
local CITY_LIGHT_ICON = 7395

-- 计时变量
local timeCounter = 0
local timeMinutesCounter = 1
local minuteCount = 0
local framesCounter = 0
local mSecondCounter = 0
local RideSpace = 1 --下马间隔
local Click_Time = 0
local l_touchTime = 1.5
local l_updateTime = 0.5
local l_openPreset_translvl = 1
local buffTimeCounter = 0
local vipPoolTimeFlag = 0 --记录时间
local vipPoolTimeCounter = 0

local combatLongTouchTime = 2 --拳师姿态长按时间
local combatTypeEffectPlay = false
---------------------------
function wnd_battleBase:ctor()
	self._useCommonSkillTouck_needValue = {}
	self._voiceToucePos = {}
	self.remTouchPos={}
	self._widgets = {}
	self._skillCoolAnis = {false, false, false, false}
	self._dodgeAnis = false
	self._uniqueAnis = false
	-- self._explist = {}
	self._herobuff = {}
	self._bufflist = {{},{},{},{}}
	self._cleanbuff = true
	self._selfbuffupdate_time = 0
	self._expcooldown = 0

	self.lastHp = 0
	self.curHp = 0
	self.maxHp = 0
	self.addTime = 0

	self._neijiaLastValue = 0
	self._neijiaCurValue = 0
	self._neijiaMaxValue = 0
	self.neijia_addTime = 0

	self._enableDodgeSkill = true;
	self._enableUniqueSkill = true;

	self._recordTime = 0 --记录时间
	self._curRoleLevel = 0

	self.touchSkillFlag = false
	self.touchSkillTime = 0

	--姿态
	self.touchCombatFlag = false
	self.touchCombatTime = 0		--长按切换平衡姿态时间
	self.combatTypeChangeSwitch = false
	self.combatCanChange = true
	self.combatCDTime = 0
	self._combatTypePoolTime = 0
	self.combatTypeTimeFlag = 0 --拳师姿态CD计时器
	self.firstShowBossDamage = true
	self._isSkillShow = true
	self.isReservePlay  = false
	self._isPromptlyMode = false
	self.lastChatType = global_world
	self._vipPoolTime = 0
	self._vipCoolTime = 0

	self._showLoginUICo = nil
	self._neishangCurValue = 0
	self._neishangMaxValue = 0
	self._neishangLastValue = 0
	self.neishang_addTime = 0
	self._isOpenInternalInjuryUI = false
end

local nowTime = 0
local tagTime = 0
local updateRoleHpFlag = false  -- 更新血条进度条标志位
local updateNeijiaFlag = false  -- 更新内甲值标志位
local updateNeishangFlag = false -- 更新内伤值标志位

function wnd_battleBase:configure()
	local widget=self._layout.vars
	self._IsShowTip=widget.IsShowTip
	self._IsShowText=widget.IsShowText
	--人物控件相关
	local role = {}
	role.bloodImage = widget.xt--血量图片
	role.headBtn = widget.touxiang--头像按钮
	role.headIcon = widget.tximage--头像图片
	role.headBg = widget.headBg --头像底图（正邪）
	role.levelLabel = widget.level--人物等级
	role.nameLabel = widget.name--人物名字
	role.bloodLabel = widget.xl--人物血量显示文本
	role.captainImage = widget.duizhang1--队长标志
	role.vipImage = widget.vipImage--人物vip等级
	role.pkBtn = widget.pkbtn--pk按钮
	role.pkbtnroot = widget.pkbtnroot--pk按钮
	role.pkImage = widget.pkImage--pk图片
	role.fproot = widget.fproot
	role.life = {
		[1] = widget.life1,
		[2] = widget.life2
	}
	role.lifeCount = 0
	for i,v in ipairs(role.life) do
		v:hide()
	end
	local fightsp1 = self._layout.vars.FightSP1
	local fightsp2 = self._layout.vars.FightSP2
	local fightsp3 = self._layout.vars.FightSP3
	local fightsp4 = self._layout.vars.FightSP4
	local fightsp5 = self._layout.vars.FightSP5
	local fightsp_bg1 = self._layout.vars.fightsp_bg1
	local fightsp_bg2 = self._layout.vars.fightsp_bg2
	local fightsp_bg3 = self._layout.vars.fightsp_bg3
	local fightsp_bg4 = self._layout.vars.fightsp_bg4
	local fightsp_bg5 = self._layout.vars.fightsp_bg5
	role.fightsp = {fightsp1,fightsp2,fightsp3,fightsp4,fightsp5}
	role.fightsp_bg = {fightsp_bg1,fightsp_bg2,fightsp_bg3,fightsp_bg4,fightsp_bg5}
	self._widgets.role = role
	--self._IsShowTip = widget.IsShowTip

	--左侧队友信息
	local team = {}
	team.root = self._layout.vars.teamRoot
	local team1 = {}
	team1.root = widget.teamRoot1
	team1.btn = widget.teamBtn1
	team1.blood = widget.teamBlood1
	team1.icon = widget.teamIcon1
	team1.captainImage = widget.teamCaptain
	team1.levelLabel = widget.teamLevel1
	team1.nameLabel = widget.teamName1
	team[1] = team1

	local team2 = {}
	team2.root = widget.teamRoot2
	team2.btn = widget.teamBtn2
	team2.blood = widget.teamBlood2
	team2.icon = widget.teamIcon2
	team2.levelLabel = widget.teamLevel2
	team2.nameLabel = widget.teamName2
	team[2] = team2

	local team3 = {}
	team3.root = widget.teamRoot3
	team3.btn = widget.teamBtn3
	team3.blood = widget.teamBlood3
	team3.icon = widget.teamIcon3
	team3.levelLabel = widget.teamLevel3
	team3.nameLabel = widget.teamName3
	team[3] = team3

	self._widgets.team = team
	-- 自动战斗
	self.autoFight = self._layout.vars.autoFight
	self.ridebtn = self._layout.vars.ridebtn
	self.kickBtn = self._layout.vars.kickBtn
	self.hugBtn = self._layout.vars.hugBtn
	self.kissBtn = self._layout.vars.kissBtn
	--幻形
	self.metamorphosis = self._layout.vars.metamorphosis


	--普通技能相关
	local commonSkill = {}
	local skill1 = {}
	skill1.rootBtn = widget.skill1
	skill1.gradeImage = widget.skill1k
	skill1.icon = widget.image1
	skill1.lockImage = widget.lock1
	skill1.cool = widget.timer1
	skill1.coolWord = widget.skill1Word
	skill1.anisImage = widget.cool1
	commonSkill[1] = skill1

	local skill2 = {}
	skill2.rootBtn = widget.skill2
	skill2.gradeImage = widget.skill2k
	skill2.icon = widget.image2
	skill2.lockImage = widget.lock2
	skill2.cool = widget.timer2
	skill2.coolWord = widget.skill2Word
	skill2.anisImage = widget.cool2
	commonSkill[2] = skill2

	local skill3 = {}
	skill3.rootBtn = widget.skill3
	skill3.gradeImage = widget.skill3k
	skill3.icon = widget.image3
	skill3.lockImage = widget.lock3
	skill3.cool = widget.timer3
	skill3.coolWord = widget.skill3Word
	skill3.anisImage = widget.cool3
	commonSkill[3] = skill3

	local skill4 = {}
	skill4.rootBtn = widget.skill4
	skill4.gradeImage = widget.skill4k
	skill4.icon = widget.image4
	skill4.lockImage = widget.lock4
	skill4.cool = widget.timer4
	skill4.coolWord = widget.skill4Word
	skill4.anisImage = widget.cool4
	commonSkill[4] = skill4

	for i,v in ipairs(commonSkill) do
		v.rootBtn:setTag(0)
		v.rootBtn:onTouchEvent(self,self.useCommonSkillTouck, i)
	end
	self._widgets.commonSkill = commonSkill

	--其他技能
	local skill = {}
	skill.attack = widget.attack
	skill.attackBg = widget.attackBg
	widget.attack:onClick(self, self.onAttackClick)
	widget.attack:onTouchEvent(self,self.onAttackTouch)
	--拳师姿态切换
	self.combatTypeBtn = widget.combatTypeBtn
	self.combatTypeBtn:onTouchEvent(self, self.onCombatTypeBtnTouch)

	local weapon = {}
	weapon.rootBtn = widget.weapon
	weapon.sp = widget.weaponSp
	weapon.icon = widget.weaponIcon
	weapon.word = widget.weaponWord
	weapon.specialIcon = widget.specialIcon
	skill.weapon = weapon
	weapon.rootBtn:setTouchEnabled(true)
	weapon.rootBtn:onTouchEvent(self, self.onStuntClick)

	local weaponBless = {} --武器祝福
	weaponBless.root = widget.weaponBlessRoot
	weaponBless.btn = widget.weaponBlessBtn
	weaponBless.sp = widget.weaponBlessProcess
	skill.weaponBless = weaponBless
	weaponBless.btn:setTouchEnabled(true)
	weaponBless.btn:onClick(self, self.onWeaponBlessClick)


	local dodge = {}
	dodge.rootBtn = widget.gundong
	-- dodge.icon = widget.dodgeIcon
	dodge.cool = widget.dodgeCool
	dodge.coolWord = widget.dodgeCoolWord
	-- dodge.anisImage = widget.dodgeAnisImg
	skill.dodge = dodge

	local uniqueSkills = {}
	uniqueSkills.rootBtn = widget.gundong2
	uniqueSkills.icon = widget.dodgeIcon2
	uniqueSkills.cool = widget.dodgeCool2
	uniqueSkills.coolWord = widget.dodgeCoolWord2
	uniqueSkills.anisImage = widget.dodgeAnisImg2
	uniqueSkills.gradeImage = widget.uniqueskillk
	skill.uniqueSkills = uniqueSkills

	local diy = {}
	diy.rootBtn = widget.DIYSkill
	diy.icon = widget.diyIcon
	diy.lockImage = widget.diyLock
	diy.cool = widget.diyCool
	diy.coolWord = widget.diyWord
	diy.gradeImage = widget.diyGrade
	diy.anisImage = widget.diyCoolImg
	skill.diySkill = diy

	-- 暗器技能
	local anqi = {}
	anqi.rootBtn = widget.anqiBtn
	anqi.rootBtn:onTouchEvent(self,self.onAnqitouch)
	anqi.icon = widget.anqiIcon
	anqi.lockImage = widget.anqiLock
	anqi.cool = widget.anqiCool
	anqi.coolWord = widget.anqiWord
	anqi.gradeImage = widget.anqiGrade
	anqi.anisImage = widget.anqiCoolImg
	skill.anqi = anqi
	--神兵变身主动技能
	local weaponManual = {}
	weaponManual.rootBtn = widget.weaponManual
	weaponManual.rootBtn:onClick(self, self.useWeaponMnualSkill)	
	weaponManual.icon = widget.weaponManualIcon
	weaponManual.lockImage = widget.weaponManualLock
	weaponManual.cool = widget.weaponManualCool
	weaponManual.coolWord = widget.weaponManualWord
	weaponManual.gradeImage = widget.weaponManualGrade
	weaponManual.anisImage = widget.weaponManualCoolImg
	skill.weaponManual = weaponManual

	--技能道具
	skill.skillItem = self._layout.vars.skillItem
	skill.skillItem:onClick(self, self.onSkillItem)
	self._widgets.skill = skill

	--[[self._fightStateSkill = {}
	for i,v in pairs(self._widgets.commonSkill) do
		table.insert(self._fightStateSkill, v)
	end
	table.insert(self._fightStateSkill, diy)
	table.insert(self._fightStateSkill, uniqueSkills)--]]

	--绑定监听器
	-- widget.team:onClick(self, self.toTeam)
	widget.touxiang:onClick(self, self.onTouXiangClick)
	widget.pkbtn:onClick(self, self.onPKbtnClick)
	widget.toChat:onClick(self, self.chatCB)
	widget.autoFight:onClick(self, self.onAutoFightClick)
	widget.ridebtn:onClick(self, self.onRideClick)
	widget.kickBtn:onClick(self, self.onKickClick)
	widget.hugBtn:onClick(self, self.onHugClick)
	widget.kissBtn:onClick(self, self.onKissBtn)
	widget.chatLog:onTouchEvent(self, self.OpenChatCB)
	widget.metamorphosis:onClick(self, self.onMetamorphosisBtn)

	self._layout.vars.buffInfo:setAlignMode(g_UIScrollList_HORZ_ALIGN_RIGHT)

	self.chatLog = widget.chatLog
	--语音入口
	self._chatState = global_world
	local voiceBtns = {widget.vworld, widget.vsect, widget.vbattle}
	local chat_state = {global_world, global_sect, global_battle}
	self.voiceStateImgs = {
		[global_world] = i3k_db_icons[2556].path,
		[global_sect] = i3k_db_icons[2557].path,
		[global_battle] = i3k_game_get_map_type() == g_PRINCESS_MARRY and i3k_db_icons[8853].path or  i3k_db_icons[8854].path,
	}
	--战场语音
	widget.moIcon:setVisible(i3k_game_get_map_type() == g_PRINCESS_MARRY)
	widget.zhanIcon:setVisible(i3k_game_get_map_type() ~= g_PRINCESS_MARRY)
	widget.toVoice:onTouchEvent(self, self.openChatVoiceCB)

	for i,v in ipairs(voiceBtns) do
		v:setTag(chat_state[i])
		v:onTouchEvent(self, self.toChatVoiceCB)
	end

	--buff相关界面
	local buff = {}
	buff.mybuff = self._layout.vars.buffbar1
	self._layout.vars.buffbar1:setTouchEnabled(false)
	self._layout.vars.hppoolbtn:onClick(self, self.onShowVipBloodTips)
	self._layout.vars.btnTest:onClick(self, self.onTestClick);

	--会武，势力战附加buff额外显示
	buff.aboveBuff = self._layout.vars.aboveBuffbar
	self._widgets.buff = buff

	--聊天小红点
	self.privateChatRed = widget.privateChatRed:show()
	self:onHideChatRedPoint()

	self.c_lizifei = self._layout.anis.c_lizifei
	self._layout.vars.mutiTouch:onMutiTouch(self, self.onSceneScale)
	self._layout.vars.tabBtn:onClick(self, self.onChangeTarget)

	--神兵魂语
	self.soulenergyCd = self._layout.vars.soulenergyCd
	self.soulenergyBg = self._layout.vars.soulenergyBg

	--帮派申请提示
	self.faction_tips_btn = self._layout.vars.faction_tips_btn
	self.faction_tips_btn:hide()
	self.faction_tips_btn:onClick(self,self.onFactionApply)
	self.faction_red = self._layout.vars.faction_red

	widget.reserveCueBtn:onClick(self, self.onMarryReserveCue)
	widget.endMission:onClick(self, self.onEndMission) --决战荒漠结束变身
	self:updateBtnSender()
end

-- 不要多次绑定按钮监听器
function wnd_battleBase:updateBtnSender()
	local widgets = self._widgets.skill.diySkill
	widgets.rootBtn:onTouchEvent(self,self.onDIYTouch)

	widgets = self._widgets.skill.uniqueSkills
	widgets.rootBtn:onTouchEvent(self,self.useUniqueSkillTouch)

	widgets = self._widgets.skill.dodge
	widgets.rootBtn:onClick(self, self.useDodgeSkill)

	self._IsShowTip:onClick(self,self.IsShowSkill)
end

function wnd_battleBase:refresh()
	g_i3k_game_context:SetRecoardDebug(false)
	local mapType = i3k_game_get_map_type()
	if mapType == g_PLAYER_LEAD then -- 新手关
		self:updataOfflineExpProgress(g_i3k_game_context:GetLevelExp())
		self:updataExpProgress(g_i3k_game_context:GetLevelExp())
		self:updateRoleProfile(g_i3k_game_context:GetRoleNameHeadIcon())
		self:updateRoleHeadBg(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId())
		self:updateRoleHp(g_i3k_game_context:GetRoleHp())
		self:updateRoleSp(g_i3k_game_context:GetRoleSp())
		self:updateRoleVipLevel(g_i3k_game_context:GetVipLevel())
		self:updateRoleLevel(g_i3k_game_context:GetLevel())
		self:updateTimeLabel()
		self:updateBattery()
		self:updateRoleBuff(g_i3k_game_context:GetRolebuff())
		self:updateRoomData()
		self:updateAllSkills()
		self:updateDrugIcon()
		self:checkShowTeam()
		-- 最后执行
		self:updatePlayerLead()
		self:updateInviteEntranceState(false)
		local level = i3k_db_new_player_guide_init[1].initRoleLevel
		self:setRoleLevel(level)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		self:updateRefreshUI()
		self:updataOfflineExpProgress(g_i3k_game_context:GetLevelExp())
		self:updataExpProgress(g_i3k_game_context:GetLevelExp())
		self:onUpdateBatterEquipShow()
		self:updateRoleProfile(g_i3k_game_context:GetBaseRoleNameHeadIcon())
		self:updateRoleHeadBg(g_i3k_game_context:GetTransformBWtype(), g_i3k_game_context:GetRoleHeadFrameId())
		self:updateRoleHp(g_i3k_game_context:GetRoleHp())
		self:updateRoleSp(g_i3k_game_context:GetRoleSp())
		self:updateRoleVipLevel(g_i3k_game_context:GetVipLevel())
		self:updateRoleLevel(g_i3k_game_context:GetLevel())
		self:updateWorldMapType(i3k_game_get_map_type())
		self:updateRoleBuff(g_i3k_game_context:GetRolebuff())
		self:updateTeamMemberProfiles(g_i3k_game_context:GetRoleId(), g_i3k_game_context:GetTeamLeader(), g_i3k_game_context:GetTeamOtherMembersProfile())
		self:updateRoomData()
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		self:updateAllSkills()
		self:updateRolePKMode(g_i3k_game_context:GetPKMode())--因为战斗状态以及PK模式影响技能是否显示，所以先加载技能再加载PK模式显示
		self:updateRoleAutoFight(g_i3k_game_context:IsAutoFight(),g_i3k_game_context:IsAutoFightShow())
		self:updateRoleRide(g_i3k_game_context:IsOnRide(),g_i3k_game_context:haveSteed())
		self:updateKickBtn()
		self:updateDrugIcon()
		self:updateOfflineExp()
		self:checkShowTeam()
		self:updateVipBloodPool()
		self:onRefreshChatLog()
		self:updateMercenaries(g_i3k_game_context:GetFightMercenaries())
		self:updateTournament()
		self:updateRoleLife()
		self:updateTimeLabel()
		self:updateBattery()
		self:updateBattleTreasure()
		----更新功能引导及功能开启------
		g_i3k_game_context:funcOpenCheck()
		self:updateBtnState()
		self:updatePetLifeBtn()
		self:updateSpyStoryBtn()
		self:updateOutCastBtn()
		self:addUnlockSkillsUIAtOtherMapType()
		self:updateEscortInfo()
		g_i3k_game_context:CheckOpenWoodMan()
		self:addBindEffect()
		self:updateShowExpUI()
		self:addPowerRepUI()
		if  mapType == g_FACTION_TEAM_DUNGEON then
			g_i3k_ui_mgr:OpenUI(eUIID_FactionTeamDungeonBtn)
		elseif mapType == g_ACTIVITY then
			g_i3k_ui_mgr:OpenUI(eUIID_KillCount)
			g_i3k_ui_mgr:RefreshUI(eUIID_KillCount, g_i3k_game_context:GetWorldMapID())
		end
		self:updateHugbtnState()
		self:updateNeijiaState()
		self:updateNeishangState()
		-- self:updateMapNameImg()
		self:updateRoleAboveBuff(g_i3k_game_context:GetRoleAboveBuff())
		self:updateSpringUI()
		self:updateHomeLandUI()
		self:updateDefenceWarUI()
		self:loadHeadFrameInfo(g_i3k_game_context:GetRoleHeadFrameId())
		self:updateHomeLandHouse()
		g_i3k_game_context:LuckyStarState()
		self:updatePetDungeon()
		self:updateDesertBattleDungeon()
		self:onUpdateDesertBetterEquipShow()
		self:updateMazeBattleUI()
		self:updateAtAnyMoment()
		self:updatePrincessMarryUI()
		self:updateMagicMachineUI()
		self:updateLongevityPavilionUI()
		self:updateGoldCoastUI()
		self:updateSuperOnHookUI()
		self:updateInviteEntranceState()
		self:updateCatchSpiritUI()
		self:updateSpyStoryDungeon()
		self:updateBiographyCareerUI()
	end
	self:showWolfWeapon()
	self:UpdateCombatBtnImg()
	local isMaskArmorInternalInjuryUI = false
	for i,v in ipairs(i3k_db_common.maskArmorInternalInjuryUI) do
		if g_i3k_game_context:GetWorldMapID() == v then
			isMaskArmorInternalInjuryUI = true
			break
		end
	end
	if not isMaskArmorInternalInjuryUI then
		local hero = i3k_game_get_player_hero()
		if g_i3k_game_context:GetLevel() >= i3k_db_wujue.inhurtLevel then
			self:openInhurtUI(true)
		elseif hero and hero._armor.id~=0 then
			self:showNeiJia(true)
		end
	end
end


-- 新手关引导相关UI显隐操作 mapType == g_PLAYER_LEAD
function wnd_battleBase:updatePlayerLead()
	local widget = self._layout.vars
	widget.chatView:hide() -- 聊天框
	widget.toChat:hide() -- 聊天按钮
	-- widget.__buffd:hide() -- 任务队伍房间  控件已经删掉了
	widget.tabBtn:hide() -- 切换目标
	widget.ridebtn:hide() -- 骑乘
	widget.autoFight:hide() -- 托管
	widget.weapon:hide() -- 神兵
	widget.skillItem:hide() -- 技能道具
	widget.gundong2:hide() -- 绝技
	widget.DIYSkill:hide() -- 自创武功
	widget.anqiBtn:hide()  -- 暗器技能
	widget.duizhang1:hide() --队长标识
	widget.pkbtnroot:hide() -- 和平按钮
	widget.weaponBlessRoot:hide() --武器祝福
	widget.lock1:hide()
	widget.lock2:hide()
	widget.lock3:hide()
	widget.lock4:hide()

	widget.gundong:show()  -- 轻功
	widget.attack:show()
	widget.attackBg:show()
	for i,v in ipairs(self._widgets.commonSkill) do
		v.rootBtn:show()
	end
	local baseStage = 0
	local stage = g_i3k_game_context:getPlayerLeadStage()
	local cfg = i3k_db_new_player_guide_lead[stage]

	if cfg then
		if cfg.showNormalAttack == 0 then
			widget.attack:hide()
			widget.attackBg:hide()
		end
		if cfg.showSkills == 0 then
			for i,v in ipairs(self._widgets.commonSkill) do
				v.rootBtn:hide()
			end
		end
		if cfg.showDogySkill == 0 then
			widget.gundong:hide()
		end
	end
	self:updatePlayerLeadStageUI(stage)
end

function wnd_battleBase:updatePlayerLeadStageUI(stage)
	g_i3k_ui_mgr:OpenUI(eUIID_PlayerLead)
	g_i3k_ui_mgr:RefreshUI(eUIID_PlayerLead, stage)
end

-- 帧事件 --------------------------------
function wnd_battleBase:onUpdate(dTime)
	self:onUpdateRoleHp(dTime)
	self:onUpdateNeiJiaValue(dTime)
	self:onUpdateNeiShangValue(dTime)
	self:onUpdatebuff(dTime)
	self:onUpdateWeapSkill(dTime)
	-- 计时
	timeCounter = timeCounter + dTime
	if timeCounter > 1 then
		self:onSecondTask(dTime)
		timeMinutesCounter = timeMinutesCounter + 1
		if timeMinutesCounter > 60 then
			self:onMinuteTask(dTime)
			timeMinutesCounter = 1
			minuteCount = minuteCount + 1
			if minuteCount >= 5 then
				local fps = g_i3k_game_handler:GetFPS()
				DCEvent.onEvent("fps", { [i3k_get_msdk().systemHardware] = math.modf(fps)})
				minuteCount = 1
			end
		end
		timeCounter = 0
	end

	mSecondCounter = mSecondCounter + dTime
	framesCounter = framesCounter + 1
	if mSecondCounter > 0.5 then
		mSecondCounter = 0
		self:onUpdateSkills(dTime)
		self:onUpdateDodge(dTime)
		self:onUpdateUniqueSkill(dTime)
		self:onUpdateDIYSkill(dTime)
		self:onUpdateMarryReserve() -- 到达预约婚礼时间提示
		self:onUpdateAnqikill(dTime)
		self:onUpdateEndMission(dTime)
		self:onUpdateWeaponManualkill(dTime)
	end
	self:onUpdateVipBloodPool(dTime)
	self:onUpdateCombatTypeCD(dTime)
end

-- 每秒执行(相对时间)
function wnd_battleBase:onSecondTask(dTime)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance,"UpdateState", dTime)
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance,"UpdateStatCallBack", dTime)
	self:updateRoleVipExperienceLevel(dTime)
	self:updateOnRideTime(dTime)
end

-- 每分钟执行（相对时间）
function wnd_battleBase:onMinuteTask(dTime)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance,"updateScheduleRedCallBack", dTime)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_game_context:RefreshSpecialCardProps()
	end, 1)
	self:updateTimeLabel(dTime)
end

-- battle UI manage functions --------------
function wnd_battleBase:onSelectRole(roleId, headIcon, name, level, curhp, maxhp, buffs, bwType, isMulHorse,sectID, gender, headBorder, buffDrugs, curInternalInjuryDamage, maxInternalInjuryDamage)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleHeroHp)
	if curInternalInjuryDamage and maxInternalInjuryDamage then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleHeroHp, "updateTargetRole",roleId, headIcon, name, level, curhp, maxhp, buffs, bwType, isMulHorse,sectID, gender, headBorder, buffDrugs, curInternalInjuryDamage, maxInternalInjuryDamage)
	else
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleHeroHp, "updateTargetRole",roleId, headIcon, name, level, curhp, maxhp, buffs, bwType, isMulHorse,sectID, gender, headBorder, buffDrugs)
	end
end

function wnd_battleBase:OnSelectMonster(monsterId, curhp, maxhp, buffs, curArmor, maxArmor, showName)
	local isBoss = g_i3k_db.i3k_db_get_monster_is_boss(monsterId)
	if g_i3k_ui_mgr:GetUI(eUIID_BattleBase) then -- check if battle
		if isBoss then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
			if g_i3k_game_context:GetWorldMapType() ~= g_SPIRIT_BOSS then
				g_i3k_ui_mgr:OpenUI(eUIID_BattleBossHp)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateTargetMonster", monsterId, curhp, maxhp, buffs, curArmor, maxArmor, showName)
			end
			--g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateBossBlood", monsterId, curhp, maxhp)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)

			g_i3k_ui_mgr:OpenUI(eUIID_BattleNPChp)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleNPChp, "updateTargetMonster", monsterId, curhp, maxhp, buffs, false, showName)
		end
	end
end

function wnd_battleBase:OnSelectNPC(npcId, name, curhp, maxhp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateTargetNPC", npcId, name, curhp, maxhp, g_i3k_game_context:getMainTaskIdAndVlaue())
end

function wnd_battleBase:OnSelectMercenary(mercenaryId, level, name, curhp, maxhp, buffs, awaken)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateTargetMercenary", mercenaryId, level, name, curhp, maxhp, buffs, nil, awaken)
end

function wnd_battleBase:OnSelectPet(petId, curhp, maxhp, buffs)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleNPChp, "updateTargetMonster", petId, curhp, maxhp, buffs, true)
end

function wnd_battleBase:OnSelectSummoned(summonedId, curhp, maxhp, buffs)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleNPChp, "updateTargetMonster", summonedId, curhp, maxhp, buffs, false, nil, true)
end

function wnd_battleBase:OnSelectEscortCar(Id, level, name, curhp, maxhp, buffs, isCar)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateTargetMercenary", Id, level, name, curhp, maxhp, buffs, isCar)
end

function wnd_battleBase:updateTargetNone()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleHeroHp)
	g_i3k_ui_mgr:CloseUI(eUIID_Wjxx) -- 点击地面关闭可能打开的角色操作栏
	g_i3k_ui_mgr:CloseUI(eUIID_KickMember)
	g_i3k_ui_mgr:CloseUI(eUIID_BattlePetRace) -- 宠物赛跑扔道具的ui
end

function wnd_battleBase:OnTargetInternalInjuryChanged(curInternalInjuryDamage, maxInternalInjuryDamage)
	if g_i3k_ui_mgr:GetUI(eUIID_BattleHeroHp) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleHeroHp, "updateInternalInjuryDamage", curInternalInjuryDamage, maxInternalInjuryDamage)
	end
end
function wnd_battleBase:OnTargetHpChanged(curhp, maxhp)
	if g_i3k_ui_mgr:GetUI(eUIID_BattleBossHp) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateTargetHp", curhp, maxhp)
	end
	if g_i3k_ui_mgr:GetUI(eUIID_BattleNPChp) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleNPChp, "updateTargetHp", curhp, maxhp)
	end
	if g_i3k_ui_mgr:GetUI(eUIID_BattleHeroHp) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleHeroHp, "updateTargetHp", curhp, maxhp)
	end
end

function wnd_battleBase:OnTargetBuffChanged(buffs)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBossHp, "updateSeletctBuff", buffs)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleHeroHp, "updateSeletctBuff", buffs)
end

function wnd_battleBase:OnFightMercenaryHpChanged(mercenarId, curhp, maxhp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePets, "syncPetsHp", mercenarId, curhp, maxhp)
end

function wnd_battleBase:OnFightMercenarySpChanged(mercenarId, cursp, maxsp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePets, "syncPetsSp", mercenarId, cursp, maxsp)
end

function wnd_battleBase:OnSuperModeChanged(superMode)
	self:updateRoleWeapon(g_i3k_game_context:GetSelectWeapon(), superMode)
	self:updatePKModeSkillUI()
end

function wnd_battleBase:OnMissionModeChanged(id, missionMode)
	self:UpdateHuanXingState(false)
	self:updateRoleMissionSkill(id, missionMode)
	self:updateRoleRide(g_i3k_game_context:IsOnRide(), g_i3k_game_context:haveSteed())
	self:updatePKModeSkillUI()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	self:UpdateTaskTips()
end

function wnd_battleBase:OnListenedCustomRoleHpChanged(roleId, curhp, maxhp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Battle4v4, "onHpChanged", roleId, curhp, maxhp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FightTeamSummary, "onHpChanged", roleId, curhp, maxhp)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FightTeamGuard, "onHpChanged", roleId, curhp, maxhp)
end

function wnd_battleBase:OnRideChanged()
	if not g_i3k_game_context:GetIsSpringWorld() then
		self:updateRoleRide(g_i3k_game_context:IsOnRide(), g_i3k_game_context:haveSteed())
	end
end

function wnd_battleBase:updateKickBtn()
	if not g_i3k_game_context:GetIsSpringWorld() then
		self.kickBtn:setVisible(g_i3k_game_context:IsOnRide() and g_i3k_game_context:IsLeaderMemberState())
	end
end

function wnd_battleBase:OnGuideDirChanged(dir)
	if not g_i3k_ui_mgr:GetUI(eUIID_BattleFuben) then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateSceneGuideDir", dir)
end

function wnd_battleBase:OnGuideVisibleChanged(visible)
	local fubenUI = g_i3k_ui_mgr:GetUI(eUIID_BattleFuben)
	if fubenUI then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateSceneGuideShow", visible)
	elseif visible then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
	end
end

function wnd_battleBase:OnMineStatusChanged(status)
	if status ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEquip, "updateMinePanel",status)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	end
end

function wnd_battleBase:updateMapNameImg()
	local data = g_i3k_game_context:getMapNameImgIDs()
	if not data or #data == 1 then
		return
	end
	local mId, value = g_i3k_game_context:getMainTaskIdAndVlaue()
	local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
	if main_task_cfg and main_task_cfg.type == g_TASK_GATE_POINT and main_task_cfg.arg1 == value then
		g_i3k_game_context:CheckSceneTriggerEffect(main_task_cfg, SCENE_EFFECT_CONDITION.doing)
		g_i3k_game_context:setMainTaskIdAndValue(mId,1)
	end

	if not g_i3k_game_context:getIsShowFirstLoginUI() then
		g_i3k_ui_mgr:OpenUI(eUIID_MapName)
		g_i3k_ui_mgr:RefreshUI(eUIID_MapName, data)
	end
end

-- 新手关结束之后，进入场景之前播放一个动画
function wnd_battleBase:playAnisAfterPlayerLead()
	if g_i3k_game_context:getLeavePlayerLeadPlayAnisFlag() then
		--TODO play anis
		local func = function()
			g_i3k_game_context:setLeavePlayerLeadPlayAnisFlag(false)
		end
		i3k_game_play_scene_ani(18, func)
	end
end

--------------------------------------------


function wnd_battleBase:updateEscortInfo()
	g_i3k_logic:OpenEscortHelpTips()
	g_i3k_logic:OpenEscortAction()
end


function wnd_battleBase:addBindEffect()
	local world = i3k_game_get_world()
	if world and world._cfg.id and i3k_db_field_map[world._cfg.id] then
		local modelId2d = i3k_db_field_map[world._cfg.id].modelId2d
		if modelId2d > 0 then
			if modelId2d == 1 then
				g_i3k_ui_mgr:CloseUI(eUIID_BindEffect)
				g_i3k_ui_mgr:CloseUI(eUIID_BindEffectMarry)
				g_i3k_ui_mgr:OpenUI(eUIID_BindEffect2D)
				return
			elseif modelId2d == 2 then
				g_i3k_ui_mgr:CloseUI(eUIID_BindEffect2D)
				g_i3k_ui_mgr:CloseUI(eUIID_BindEffect)
				g_i3k_ui_mgr:OpenUI(eUIID_BindEffectMarry)
				return
			end
		end

		local modelId = i3k_db_field_map[world._cfg.id].modelId
		if modelId and i3k_db_models[modelId] and modelId > 0 then
			g_i3k_ui_mgr:CloseUI(eUIID_BindEffect2D)
			g_i3k_ui_mgr:CloseUI(eUIID_BindEffectMarry)
			g_i3k_ui_mgr:OpenUI(eUIID_BindEffect)
			g_i3k_ui_mgr:RefreshUI(eUIID_BindEffect, modelId)
		end
	end
end

--修改为只返回一个值(old:第一个参数代表是否在和平模式，第二个参数表示是否战斗状态)
function wnd_battleBase:getFightStateUIIsShow()
	local mapType = i3k_game_get_map_type()
	local pkMode = g_i3k_game_context:GetPKMode()
	local hero = i3k_game_get_player_hero()
	local isInFightState = function ()
		return hero:IsInFightTime()
	end
	if hero then
		return  mapType==g_FIELD and  pkMode==0 and not isInFightState()
	end
end

function wnd_battleBase:updateAllSkills()
	self:updateRoleWeapon(g_i3k_game_context:GetSelectWeapon(), g_i3k_game_context:IsInSuperMode())
	self:updateRoleSkills(g_i3k_game_context:GetRoleSelectSkills(), g_i3k_game_context:GetRoleType())
	self:updateSoulEnergy(g_i3k_game_context:GetSoulEnergy());
	self:updateRoleWeaponEnergy(g_i3k_game_context:GetRoleWeaponErergy())
	self:updateRoleDIYSkill(g_i3k_game_context:GetCurrentDIYSkillId(), g_i3k_game_context:GetCurrentDIYSkillIconId(), g_i3k_game_context:GetCurrentSkillGradeId())
	self:updateRoleDodgeSkill(g_i3k_game_context:GetRoleType())
	self:updateRoleUniqueSkill(g_i3k_game_context:GetRoleType())
	self:updataRoleAnqiSkill(g_i3k_game_context:getEquipedHideWeaponSkill())
	self:updateRoleWeaponBless(g_i3k_game_context:GetActiveWeaponBlessID())
	self:updateRoleWeaponBlessEnergy(g_i3k_game_context:GetRoleWeaponBlessEnergy())
end

function wnd_battleBase:updatePetLifeBtn()
	local worldType = g_i3k_game_context:GetWorldMapType()
	if worldType == g_Life or worldType == g_Pet_Waken then
		if worldType == g_Life then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
			if g_i3k_game_context:GetLifeTaskRecorkPetID() ~= 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_ShenshiBattle)
				g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiBattle, g_i3k_game_context:GetLifeTaskRecorkPetID())
			end
		end
		self.ridebtn:hide()
		self.kickBtn:hide()
		self._widgets.skill.weapon.rootBtn:hide()
		self._widgets.skill.uniqueSkills.rootBtn:hide()
		self._widgets.skill.diySkill.rootBtn:hide()
		self._widgets.skill.anqi.rootBtn:hide()
		self._widgets.skill.dodge.rootBtn:hide()
		self._widgets.skill.skillItem:hide()
	end
end

function wnd_battleBase:updateSpyStoryBtn()
	local worldType = g_i3k_game_context:GetWorldMapType()
	if worldType == g_SPY_STORY then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SpyStoryTask)
	end
end
function wnd_battleBase:updateOutCastBtn()
	if i3k_game_get_map_type() == g_OUT_CAST  then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:OpenUI(eUIID_OutCastBattle)
		g_i3k_ui_mgr:RefreshUI(eUIID_OutCastBattle)
		self.ridebtn:hide()
		self.kickBtn:hide()
		self._widgets.skill.weapon.rootBtn:hide()
		self._widgets.skill.uniqueSkills.rootBtn:hide()
		self._widgets.skill.diySkill.rootBtn:hide()
		self._widgets.skill.anqi.rootBtn:hide()
		self._widgets.skill.dodge.rootBtn:hide()
		self._widgets.skill.skillItem:hide()
	end
end

function wnd_battleBase:updateSpringUI()
	if g_i3k_game_context:GetIsSpringWorld() then
		local vars = self._layout.vars;
		--温泉区域隐藏部分UI
		vars.weapon:setVisible(false)
		vars.attackBg:setVisible(false)
		vars.skillNodes:setVisible(false)
		vars.tabBtn:setVisible(false)
		vars.gundong:setVisible(false)
		vars.autoFight:setVisible(false)
		vars.ridebtn:setVisible(false)
		vars.combatTypeBtn:setVisible(false)

		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		--g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)

		g_i3k_ui_mgr:OpenUI(eUIID_SpringAct)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpringAct)

		g_i3k_ui_mgr:OpenUI(eUIID_SpringBuff)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpringBuff)
	end
end

function wnd_battleBase:updateHomeLandUI()
	if g_i3k_game_context:GetIsInHomeLandZone() then
		local vars = self._layout.vars;
		vars.weapon:setVisible(false)
		vars.attackBg:setVisible(false)
		vars.skillNodes:setVisible(false)
		vars.tabBtn:setVisible(false)
		vars.gundong:setVisible(false)
		vars.autoFight:setVisible(false)
		vars.combatTypeBtn:setVisible(false)
		--vars.ridebtn:setVisible(true)

		-- g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFuben)
		g_i3k_logic:OpenHomelandCustomersUI()
		if g_i3k_game_context:GetHomeLandFishStatus() and g_i3k_game_context:GetHomeLandCurEquipCanFish() then
			g_i3k_logic:OpenHomeLandFishUI()
		end
		if g_i3k_game_context:GetIsInFishArea() and not g_i3k_game_context:GetHomeLandFishStatus() then
			self:updateFishPrompt(true)
		end
	end
end

function wnd_battleBase:updateDefenceWarUI()
	local weight = self._layout.vars
	
	if i3k_game_get_map_type() == g_DEFENCE_WAR then
		weight.hppoolbtn:setVisible(false)
	end
	
	if g_i3k_game_context:defenceWarTransformState() then
		
		weight.autoFight:hide()
		weight.gundong:setVisible(false)
		weight.ridebtn:setVisible(false)
	end
end

function wnd_battleBase:updateFishState(value)
	self._layout.vars.about_touxiang:setVisible(value)
	self._layout.vars.hppoolbtn:setVisible(value)
end

function wnd_battleBase:updateBtnState()
	local dodgeCondition = g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.dodgeLvl
	local actionCondition = g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.actionLvl
	local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技
	local uniqueSkillsCondition = use_uniqueSkill > 0 --g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.uniqueSkillOpenLvl and
	local rootVisible = self._layout.vars.skillBtnUI:isVisible()
	local rootVisible2 = self._layout.vars.skillNodes:isVisible()
	local rootVisible3 = self._layout.vars.roleInfoUI:isVisible()
	local condition = not g_i3k_game_context:IsInMissionMode()
	--self._layout.vars.gundong:setVisible(dodgeCondition and rootVisible and rootVisible2 and condition)

	local isShow = not self:getFightStateUIIsShow() -- "not nil" is "true"
	self._layout.vars.gundong2:setVisible(uniqueSkillsCondition and rootVisible and rootVisible2 and condition and isShow)
end

function wnd_battleBase:updateBattleTreasure()
	local mapInfo = g_i3k_game_context:getTreasureMapInfo()
	local escortTaskId = g_i3k_game_context:GetFactionEscortTaskId()
	if escortTaskId==0 and (mapInfo and mapInfo.open~=0) and i3k_game_get_map_type()==g_FIELD and not g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTreasure)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTreasure)
	end
end

function wnd_battleBase:updateRefreshUI()
	self._layout.vars.pkbtnroot:setVisible(i3k_game_get_map_type() ~= g_ARENA_SOLO)
	self:showCombatTypebtn()
	if i3k_game_get_map_type() == g_ARENA_SOLO then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleRoom)
	elseif i3k_game_get_map_type() == g_Life or i3k_game_get_map_type() == g_OUT_CAST or i3k_game_get_map_type() == g_CATCH_SPIRIT or i3k_game_get_map_type() == g_BIOGIAPHY_CAREER then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	elseif i3k_game_get_map_type() == g_DOOR_XIULIAN then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	else
		g_i3k_logic:OpenBattleTaskUI()
		g_i3k_logic:OpenBattleMiniMap()
		g_i3k_ui_mgr:CloseUI(eUIID_ArenaSwallow)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_BattleNPChp)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleBossHp)
	self:UpdateTaskTips()
	self:UpdateFindWayTips()
	self:UpdateTripWizard()
end

function wnd_battleBase:showCombatTypebtn()
	local mapType = g_i3k_game_context:GetWorldMapType()
	if mapType == g_BIOGIAPHY_CAREER then
		self._layout.vars.combatTypeBtn:setVisible(g_i3k_game_context:getCurBiographyCareerId() == g_BASE_PROFESSION_QUANSHI)
	else
		if g_i3k_game_context:GetRoleType() == g_BASE_PROFESSION_QUANSHI then
			local hero = i3k_game_get_player_hero()
			local curMapType = i3k_game_get_map_type()
			local mapTypes = {
				[g_DESERT_BATTLE] = true,	--决战荒漠
				[g_CATCH_SPIRIT] = true,	--鬼岛驭灵
				[g_SPY_STORY] = true,		--密探风云
				[g_PET_ACTIVITY_DUNGEON] = true,		--宠物试炼副本
				[g_Life] = true,
				[g_Pet_Waken] = true,
			}
			local isHide = not (mapTypes[curMapType] or hero:IsInMissionMode())
			self._layout.vars.combatTypeBtn:setVisible(isHide)
		end
		--self._layout.vars.combatTypeBtn:setVisible(g_i3k_game_context:GetRoleType() == g_BASE_PROFESSION_QUANSHI)  --拳师姿态切换按钮
	end
end
function  wnd_battleBase:hideCombatTypeBtn( )
	self._layout.vars.combatTypeBtn:setVisible(false)
end
function wnd_battleBase:UpdateTaskTips()
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return
	end
	local hero = i3k_game_get_player_hero()
	if hero and hero._missionMode.type and (hero._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS or hero._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS ) then
		return
	end
	local mapType = i3k_game_get_map_type()
	local canNotShow = {
		[g_DEFEND_TOWER] = true,
		[g_DEFENCE_WAR] = true,
		[g_DESERT_BATTLE] = true,
		[g_DOOR_XIULIAN] = true,
		[g_SPY_STORY]	= true,
	}
	if not canNotShow[mapType]  then
		if g_i3k_game_context:IsInMissionMode() then
			g_i3k_ui_mgr:OpenUI(eUIID_TaskShapeshiftingTips)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_TaskShapeshiftingTips)
		end
	end
end

function wnd_battleBase:UpdateFindWayTips()
	if g_i3k_game_context:GetFindWayStatus() then
		g_i3k_game_context:openFindwayTipsUI()
	end
end

function wnd_battleBase:UpdateTripWizard()
	local mapType = i3k_game_get_map_type()
	if mapType ~= g_DESERT_BATTLE and mapType ~= g_PRINCESS_MARRY  and  mapType ~= g_SPY_STORY then
	local currPhoto = g_i3k_game_context:getCurrPhotos();
	if currPhoto and #currPhoto >= 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_TripWizardPhotoBtn)
		g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardPhotoBtn)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
		end
	else
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
	end
end

function wnd_battleBase:onShow()
	self:showNeiJia(false)
	self:setWeaponImg()
	self:checkFirstLogin()
	self:setVipBloodPoolTime()
	self:setCombatTypePoolTime()
end

function wnd_battleBase:setVipBloodPoolTime()
	self._vipPoolTime = i3k_game_get_time()
	self._vipCoolTime = g_i3k_game_context:GetVipBloodCD()
end
function wnd_battleBase:setCombatTypePoolTime()
	self._combatTypePoolTime = i3k_game_get_time()
	self:checkCombatTypeState()
end
function wnd_battleBase:checkCombatTypeState()
	if i3k_game_get_time() < g_i3k_game_context:GetCombatCoolEndTime() then
		self:openCombatCD()
	end
end

function wnd_battleBase:checkFirstLogin()
	if g_i3k_game_context:getDayFirstLogin() then
		local mapType = i3k_game_get_map_type()
		local roleLvl = g_i3k_game_context:GetLevel()
		if roleLvl > i3k_db_common.showFuliLevel and mapType == g_FIELD then
			g_i3k_logic:OpenDynamicActivityUI()  -- 打开福利界面

			-- 设置两个红点状态为true
			g_i3k_game_context:setDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_FIRST_PAY, true)
			g_i3k_game_context:setDayFirstLoginFuliRedPoint(DAY_FIRST_LOGIN_PURCHASE, true)
			g_i3k_game_context.isNeedShowCallback = true
		end

		if roleLvl == 1 then --玩家1级的时候展示宣传页面
			if mapType == g_FIELD then
				self._showLoginUICo = g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForNextFrame()

					--临时屏蔽宣传页
					--g_i3k_logic:OpenFirstLoginShow()
					--g_i3k_game_context:setDayFirstLogin(false)

					g_i3k_coroutine_mgr:StopCoroutine(self._showLoginUICo)
					self._showLoginUICo = nil
				end)
			end
		else
			g_i3k_logic:checkAndOpenActivityShowUI_dayLogin()
			g_i3k_game_context:setDayFirstLogin(false)
		end
		g_i3k_game_context:startChannelMigrationTips()
	end
end

function wnd_battleBase:onSceneScale(sender, eventType)
	if i3k_game_get_map_type() == g_SPIRIT_BOSS then --巨灵攻城副本不可以使用双指缩放
		return
	end

	if eventType==ccui.TouchEventType.began then
		distance = i3k_get_load_cfg():GetCameraInter();
	elseif eventType==ccui.TouchEventType.moved then
		local getScale = sender:getMutiTouchScaleRatio()
		if getScale < 1 then
			distance = distance + 0.02
			distance = distance>1 and 1 or distance
		elseif getScale>1 then
			distance = distance - 0.02
			distance = distance<0 and 0 or distance
		end
		g_i3k_game_context:setCameraDistance(distance)
	elseif eventType==ccui.TouchEventType.ended then
		distance = nil;
	end
end

function wnd_battleBase:onFactionApply(sender)
	local fun = (function()
			local data = i3k_sbean.sect_applications_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_applications_res.getName())
		end)
	local data = i3k_sbean.sect_sync_req.new()
	data.fun = fun
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
	self:updateFactionApplyTips(false)
end

function wnd_battleBase:updateFactionApplyTips(state)
	local mapType = i3k_game_get_map_type()
	if state and mapType == g_FIELD then
		self.faction_tips_btn:setVisible(state)
	else
		self.faction_tips_btn:setVisible(state)
	end
end

function wnd_battleBase:onChangeTarget(sender)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:ChangeEnemy()
	end
end

-----------------------------------------------
function wnd_battleBase:unlockSuccessed(index, skillId)
	local widgets = self._widgets.commonSkill[index]
	widgets.lockImage:hide()
	local coolAnis = "js"..index

	widgets.anisImage:show()
	self._layout.anis[coolAnis].play()

	local needValue = {index = index, skillId = skillId}
	widgets.rootBtn:setTag(skillId)
	--widgets.rootBtn:onClick(self, self.useCommonSkill, needValue)
	self._useCommonSkillTouck_needValue[index] = needValue
	widgets.rootBtn:onTouchEvent(self,self.useCommonSkillTouck, index)
end



function wnd_battleBase:onEnableDodgeSkill(value)
	self._enableDodgeSkill = value;
end

function wnd_battleBase:onEnableUniqueSkill(value)
	self._enableUniqueSkill = value;
end

function wnd_battleBase:checkShowTeam()
	if g_i3k_game_context:getOpenTaskState() ~= 1 then
		if i3k_game_get_map_type() ~= g_DEFEND_TOWER and i3k_game_get_map_type() ~= g_DOOR_XIULIAN then
			if g_i3k_game_context:GetWorldMapType() ~= g_DESERT_BATTLE and  g_i3k_game_context:GetWorldMapType() ~= g_SPY_STORY then --决战荒漠用新的
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTeam)-- 队伍和佣兵只能显示一种,队伍界面会自动检测自己界面是否存在。
			end
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
			
			g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)			
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTeam)
	end

	-- if not g_i3k_ui_mgr:GetUI(eUIID_BattleTeam) then
		g_i3k_ui_mgr:OpenUI(eUIID_BattlePets)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattlePets)
	-- end
end

function wnd_battleBase:showGundongBtn(bValue)
	self._layout.vars.gundong:setVisible(bValue)
end

function wnd_battleBase:updateRoleVipExperienceLevel(dTime)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if g_i3k_game_context:GetPracticalVipLevel() ~= 0 and  g_i3k_game_context:GetPracticalVipLevel() >= g_i3k_game_context:GetVipExperienceLevel() then
		g_i3k_game_context:SetVipExperienceLevel(0)
	else
		if g_i3k_game_context:GetVipExperienceLevel() ~= 0 then
			local allTime = g_i3k_game_context:GetVipExperienceEndTime()
			local nowTime = allTime - serverTime
			if nowTime <= 0 then
				g_i3k_game_context:SetVipExperienceLevel(0)
				g_i3k_game_context:SetVipLevel(g_i3k_game_context:GetPracticalVipLevel(), true)
			end
		end
	end
end

-----------------佣兵信息-----------------
function wnd_battleBase:setPetsViewVisible(isVisible)
	if isVisible then
		g_i3k_ui_mgr:OpenUI(eUIID_BattlePets)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattlePets)
		-- g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		local mapType = i3k_game_get_map_type()
		if mapType == g_FACTION_TEAM_DUNGEON or mapType == g_ANNUNCIATE then
			g_i3k_logic:OpenBattleTaskUI(true)
		elseif mapType == g_DEFEND_TOWER or mapType == g_DOOR_XIULIAN then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
			g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
			g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)
			g_i3k_ui_mgr:RefreshUI(eUIID_TaskBase)
		end
	else
		-- g_i3k_ui_mgr:CloseUI(eUIID_BattlePets)
		if i3k_game_get_map_type() ~= g_DEFEND_TOWER then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTeam)
		end
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleTeam)
end

function wnd_battleBase:updateMercenaries(fightPetIds)-- 随从
	g_i3k_ui_mgr:OpenUI(eUIID_BattlePets)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePets,"updateMercenaries",fightPetIds)
end

---------------------update functions --------------------
function wnd_battleBase:updataExpProgress(level, exp)
	local percent = 0
	if level+1 <= #i3k_db_exp then
		percent = exp / i3k_db_exp[level+1].value * 1000
	end
	if g_i3k_game_context:getRoleExpFull() then
		self._layout.vars.expbar:setImage(g_i3k_db.i3k_db_get_icon_path(8515))
	else
		self._layout.vars.expbar:setImage(g_i3k_db.i3k_db_get_icon_path(8514))
	end
	self._layout.vars.expbar:setPercent(math.floor(percent) / 10)
end

function wnd_battleBase:updataOfflineExpProgress(level, exp)
	local info = g_i3k_game_context:GetOfflineExpData()
	local dailyOfflineExp = info.dailyOfflineExp
	exp = exp + dailyOfflineExp
	local percent = 0
	if level+1 <= #i3k_db_exp then
		exp = exp > i3k_db_exp[level+1].value and i3k_db_exp[level+1].value or exp
		percent = exp / i3k_db_exp[level+1].value * 1000
	end
	self._layout.vars.expbarOffLine:setPercent(percent / 10)
end

---人物信息
function wnd_battleBase:updateRoleProfile(name, headIcon)
	self._widgets.role.headIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headIcon, false))--headIcon
	self._widgets.role.nameLabel:setText(name)--name
end

function wnd_battleBase:initFightSpBg(bwType)
	local iconId =
	{
		[0] = 3046,
		[1] = 3047,
		[2] = 3048
	}

	for i = 1, 5 do
		local widgetName = "fightsp_bg"..i
		self._layout.vars[widgetName]:setImage(g_i3k_db.i3k_db_get_icon_path(iconId[bwType]))
	end
end

function wnd_battleBase:updateRoleHeadBg(bwType, headBorder)
	self._widgets.role.headBg:setImage(g_i3k_get_head_bg_path(bwType, headBorder))
	self:initFightSpBg(bwType)
end

function wnd_battleBase:updateRoleHp(curHp,  maxHp)
	self._widgets.role.bloodLabel:setText(curHp.."/"..maxHp)
	local percent = curHp / maxHp
	percent = percent <= 1 and percent or 1
	self._widgets.role.bloodImage:setPercent(percent * 100)
	local filter = i3k_db_common.general.lowblood*maxHp/10000
	if filter > curHp and curHp ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleLowBlood)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleLowBlood,"UpdateShow",true)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleLowBlood)
	end
	self.lastHp = self.curHp
	self.curHp = curHp
	self.maxHp = maxHp
	-- 血条减少的动画
	updateRoleHpFlag = true
	local mapType = i3k_game_get_map_type()
	if curHp==0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattlePets,"clearCoolAction")
		if self._widgets.role.lifeCount > 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(589, i3k_db_tournament_base.baseData.deadTime))
		end
	end
end


function wnd_battleBase:onUpdateRoleHp(dTime)
	if updateRoleHpFlag then
		self.addTime = self.addTime + dTime * 1000
		local processTime = 400
		if self.addTime < processTime then -- mark as time
			local deltPercent = self.addTime / processTime
			local deltHp = self.lastHp - self.curHp
			local percent = (self.lastHp - deltHp * deltPercent) / self.maxHp * 100
			self._layout.vars.bloodBar:setPercent(percent)
		else
			self._layout.vars.bloodBar:setPercent(self.curHp / self.maxHp * 100)
			self.addTime = 0
			updateRoleHpFlag = false
		end
	end
end

function wnd_battleBase:updateSoulEnergy(curvalue, maxvalue)
	local world = i3k_game_get_world()
	if maxvalue > 0 and world._syncRpc and not g_i3k_game_context:IsInSuperMode() then
		local percent = curvalue/maxvalue*100
		self.soulenergyBg:show();
		self.soulenergyCd :setPercent(percent)
	else
		self.soulenergyBg:hide();
	end
end

function wnd_battleBase:updateRoleSp(curSp,maxSp)
	for k,v in pairs(self._widgets.role.fightsp_bg) do
		v:setVisible(k <= maxSp)
	end
	for i, v in pairs(self._widgets.role.fightsp) do
		v:setVisible(i <= curSp)
	end
end

function wnd_battleBase:updateNeishangState()
	local hero = i3k_game_get_player_hero()
	if hero then
		self:updateNeiShangValue(hero._internalInjuryState.value, hero._internalInjuryState.maxInjury)
	end
end
function wnd_battleBase:updateNeijiaState()
	local hero = i3k_game_get_player_hero()
	if hero and hero._armor.id~=0 then
		self:updateNeiJiaValue(g_i3k_game_context:GetRoleArmorValue())
	end
end

function wnd_battleBase:updateHugUI()
	if g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:OpenUI(eUIID_DoubleInteraction);
	else
		g_i3k_ui_mgr:CloseUI(eUIID_DoubleInteraction);
	end
end

-- defualt : false
function wnd_battleBase:showNeiJia(bValue)
	self._layout.vars.neijiaBar:setVisible(bValue)
	self._layout.vars.neijiaBarBottom:setVisible(bValue)
	local cfg = g_i3k_db.i3k_get_head_cfg_form_frameId(g_i3k_game_context:GetRoleHeadFrameId())
	local iconID = bValue and 2936 or 2935
	if cfg then
		iconID = bValue and cfg.bloodFrameUnderWear or cfg.bloodFrameNormal
	end
	self._layout.vars.zdtx:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
end

function wnd_battleBase:updateNeiShangValue(curValue, maxValue)
	self._neishangLastValue = self._neishangCurValue
	self._neishangCurValue = curValue
	self._neishangMaxValue = maxValue
	updateNeishangFlag = true
	if self._neishangCurValue > self._neishangLastValue then
		self._layout.vars.neishangBarBottom:setPercent(self._neishangLastValue / self._neishangMaxValue * 100)
	else
		self._layout.vars.neishangBarBottom:setPercent(self._neishangCurValue / self._neishangMaxValue * 100)
	end
end

function wnd_battleBase:updateNeiJiaValue(curValue, maxValue)
	--self:showNeiJia(true)
	self._neijiaLastValue = self._neijiaCurValue
	self._neijiaCurValue = curValue
	self._neijiaMaxValue = maxValue
	updateNeijiaFlag = true
	if self._neijiaCurValue < self._neijiaLastValue then
		self._layout.vars.neijiaBarBottom:setImage(g_i3k_db.i3k_db_get_icon_path(2892)) -- 减少的过程
		self._layout.vars.neijiaBarBottom:setPercent(self._neijiaLastValue / self._neijiaMaxValue * 100)
	else
		self._layout.vars.neijiaBarBottom:setImage(g_i3k_db.i3k_db_get_icon_path(2893)) -- 增加的过程
		self._layout.vars.neijiaBarBottom:setPercent(self._neijiaCurValue / self._neijiaMaxValue * 100)
	end
end
-- 内伤值变化动画
function wnd_battleBase:onUpdateNeiShangValue(dTime)
	if updateNeishangFlag then
		self.neishang_addTime = self.neishang_addTime + dTime * 1000
		local processTime = 400
		if self.neishang_addTime < processTime then
			local deltPercent = self.neishang_addTime / processTime
			local deltNeiShang = self._neishangLastValue - self._neishangCurValue
			local percent = (self._neishangLastValue - deltNeiShang * deltPercent) / self._neishangMaxValue * 100
			self._layout.vars.neishangBar:setPercent(percent)
		else
			self._layout.vars.neishangBar:setPercent(self._neishangCurValue / self._neishangMaxValue * 100)
			self._layout.vars.neishangBarBottom:setPercent(self._neishangCurValue / self._neishangMaxValue * 100)
			self.neishang_addTime = 0
			updateNeishangFlag = false
		end
	end
end

-- 内甲值变化动画
function wnd_battleBase:onUpdateNeiJiaValue(dTime)
	if updateNeijiaFlag then
		self.neijia_addTime = self.neijia_addTime + dTime * 1000
		local processTime = 400
		if self.neijia_addTime < processTime then
			local deltPercent = self.neijia_addTime / processTime
			local deltHp = self._neijiaLastValue - self._neijiaCurValue
			local percent = (self._neijiaLastValue - deltHp * deltPercent) / self._neijiaMaxValue * 100
			self._layout.vars.neijiaBar:setPercent(percent)
		else
			self._layout.vars.neijiaBar:setPercent(self._neijiaCurValue / self._neijiaMaxValue * 100)
			self._layout.vars.neijiaBarBottom:setPercent(self._neijiaCurValue / self._neijiaMaxValue * 100)
			self.neijia_addTime = 0
			updateNeijiaFlag = false
		end
	end
end

function wnd_battleBase:playNeijiaAnis()
	self._layout.anis.c_njmz.stop()
	self._layout.anis.c_njmz.play()
end

function wnd_battleBase:playNeijiaImgAnis(type, iValue)
	local imgs = g_i3k_game_context:getNeijiaImgIdByValue(type, iValue)
	local widgets = self._layout.vars
	for i = 1, 6 do
		local imgId = imgs[i]
		if imgId then
			widgets["neijiaN"..i]:show()
			widgets["neijiaN"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(imgId))
		else
			widgets["neijiaN"..i]:hide()
		end
	end
	self:playNeijiaAnis()
end


-- 内甲被虚弱
function wnd_battleBase:updateNeijiaWeek(iValue)
	self:playNeijiaImgAnis(NEIJIA_XURUO, iValue)
end
-- 内甲被损毁
function wnd_battleBase:updateNeijiaDamage(iValue)
	self:playNeijiaImgAnis(NEIJIA_SUNHUI, iValue)
end
-- 内甲被吸收
function wnd_battleBase:updateNeijiaGet(iValue)
	self:playNeijiaImgAnis(NEIJIA_XISHOU, iValue)
end

function wnd_battleBase:updateNeijiaFreeze(bValue)
	-- TODO if true then play anis else stop play anis end
	if bValue then

	else

	end
end

function wnd_battleBase:updateRoleVipLevel(vipLevel)
	local iconId = i3k_db_kungfu_vip[vipLevel].levelIconId
	self._widgets.role.vipImage:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end

function wnd_battleBase:updateRoleLevel(level)
	if self._curRoleLevel == 0 then
		self._curRoleLevel = level
	elseif self._curRoleLevel < level then
		self._curRoleLevel = level
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTXUpLevel)
	end

	self._widgets.role.levelLabel:setText(level)
	self._widgets.role.pkbtnroot:setVisible(level >= i3k_db_common.pk.pkOpenlvl)
	self._widgets.role.fproot:setVisible(level >= i3k_db_common.general.fightspOpenlvl)
	self._layout.vars.hppoolbtn:setVisible(level >= i3k_db_common.drug.boundToShowPoolLevel or ( level >= i3k_db_common.drug.drugshowlvl and g_i3k_game_context:GetVipBloodPool() > 0))
	if g_i3k_game_context:GetWorldMapType() ~= g_DESERT_BATTLE and g_i3k_game_context:GetWorldMapType() ~= g_SPY_STORY then
		self._layout.vars.hppoolbtn:hide()
	end
end
function wnd_battleBase:openInhurtUI(isOpen)
	if isOpen and not self._isOpenInternalInjuryUI then
		self._layout.vars.neishangBar:setVisible(true)
		self._layout.vars.neishangBarBottom:setVisible(true)
		local cfg = g_i3k_db.i3k_get_head_cfg_form_frameId(g_i3k_game_context:GetRoleHeadFrameId())
		local iconID = 7877
		if cfg then
			iconID = cfg.bloodFrameUnderWearNeishang
		end
		self._layout.vars.zdtx:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
		local neijiaBar = self._layout.vars.neijiaBar
		local neijiaBarBottom = self._layout.vars.neijiaBarBottom
		local fproot = self._layout.vars.fproot
		local yAbOffset = 10 --编辑器内设定值
		local yAbSizeY = 540
		local yfactor = yAbOffset / yAbSizeY
		local yRealOffset = self._layout.vars.neijiaBar:getParent():getContentSize().height * yfactor
		local tmpPos = neijiaBar:getPosition()
		neijiaBar:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		tmpPos = neijiaBarBottom:getPosition()
		neijiaBarBottom:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		tmpPos = fproot:getPosition()
		fproot:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		self._isOpenInternalInjuryUI = true
		local hero = i3k_game_get_player_hero()
		if hero._armor.id ~=0 then 
			self._layout.vars.neijiaBar:setVisible(true)
			self._layout.vars.neijiaBarBottom:setVisible(true)
		end
	end
end

function wnd_battleBase:updateTimeLabel(dTime)
	local time = os.date("%H:%M",i3k_game_get_systime())
	self._layout.vars.timeLabel:setText(time)
end

function wnd_battleBase:updateBattery()
	self._layout.vars.battery:setPercent(g_DEVICE_BATTERY)
end

function wnd_battleBase:setRoleLevel(level)
	self._widgets.role.levelLabel:setText(level)
end

function wnd_battleBase:updateWorldMapType(worldType)
	self:updateLeftUI(true)
	local condition = g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.battleMapID
	self._widgets.role.pkBtn:setVisible(worldType == g_FIELD or worldType == g_DEMON_HOLE or worldType == g_FACTION_WAR or worldType == g_FACTION_GARRISON or condition)
	local mapID = g_i3k_game_context:GetWorldMapID()
	if i3k_db_new_dungeon[mapID] and i3k_db_new_dungeon[mapID].maxPlayer==1 then
		self:updateLeftUI(false)
	end
	if worldType == g_FIELD then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEntrance)
		g_i3k_logic:OpenBattleTaskUI()
		g_i3k_logic:OpenBattleMiniMap()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEquip)
		g_i3k_game_context:IsRetrieveActExist()
	elseif worldType == g_TOURNAMENT then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		if i3k_get_is_tournament_weapon() then--神器乱战
			g_i3k_ui_mgr:CloseUI(eUIID_OnlineVoice)
			self._layout.vars.skillNodes:setVisible(false)
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTouramentWeapon)
		end
	elseif worldType == g_FORCE_WAR then --势力战
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMiniMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_ForceWarMiniMap)
		self:updateLeftUI(false)
	elseif worldType == g_FACTION_TEAM_DUNGEON then
		g_i3k_logic:OpenBattleTaskUI(true)
		g_i3k_logic:OpenBattleMiniMap()
	elseif worldType == g_DEMON_HOLE then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	elseif worldType == g_FACTION_WAR then -- 帮派战
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightMiniMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightMiniMap)
		self:updateLeftUI(false)
	elseif worldType == g_ANNUNCIATE then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_logic:OpenBattleTaskUI(true)
		g_i3k_logic:OpenBattleMiniMap()
	elseif worldType == g_DEFEND_TOWER  then
	    if g_i3k_game_context:IsInMissionMode() then
			self._IsShowTip:show()
			self._IsShowText:show()
	    end
	    -- self._IsShowTip:onClick(self,self.IsShowSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_BackDefense)
		g_i3k_ui_mgr:RefreshUI(eUIID_BackDefense)
		g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	elseif worldType == g_DOOR_XIULIAN then
		  if g_i3k_game_context:IsInMissionMode() then
			self._IsShowTip:show()
			self._IsShowText:show()
	    end
	    -- self._IsShowTip:onClick(self,self.IsShowSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_DefendSummary)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefendSummary)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	elseif worldType == g_FACTION_GARRISON then		
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEntrance)
		--g_i3k_logic:OpenGarrisonTeam()
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	elseif worldType == g_BUDO then
		if g_i3k_game_context:GetIsGuard() then
			g_i3k_ui_mgr:OpenUI(eUIID_FightTeamGuard)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamGuard)
			local widget = self._layout.vars
			widget.skillBtnUI:hide()
			widget.autoFight:hide()
			widget.ridebtn:hide()
		else
			g_i3k_ui_mgr:OpenUI(eUIID_FightTeamSummary)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamSummary)
			g_i3k_ui_mgr:OpenUI(eUIID_FightTeamPrompt)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamPrompt)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMiniMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_ForceWarMiniMap)
	elseif worldType == g_GLOBAL_PVE then
		if mapID == i3k_db_crossRealmPVE_cfg.peaceMapID then
			g_i3k_ui_mgr:OpenUI(eUIID_PvePeaceArea)
			g_i3k_ui_mgr:RefreshUI(eUIID_PvePeaceArea)
		elseif mapID == i3k_db_crossRealmPVE_cfg.battleMapID then
			g_i3k_ui_mgr:OpenUI(eUIID_PveBattleArea)
			g_i3k_ui_mgr:RefreshUI(eUIID_PveBattleArea)
		end
	elseif worldType == g_SPIRIT_BOSS then
		self:updateLeftUI(false)
		self:showGundongBtn(false)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_SpiritBossFight)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
	elseif worldType == g_GOLD_COAST then
		g_i3k_logic:OpenBattleMiniMap()
	elseif worldType == g_CATCH_SPIRIT then
		g_i3k_logic:OpenBattleMiniMap()
		self:updateLeftUI(false)
	elseif worldType == g_BIOGIAPHY_CAREER then
		g_i3k_logic:OpenBattleMiniMap()
		self:updateLeftUI(false)
	else
		if worldType == g_TOWER or worldType == g_Life or worldType == g_OUT_CAST or worldType == g_TAOIST or worldType == g_FACTION_DUNGEON or worldType == g_ACTIVITY or worldType == g_AT_ANY_MOMENT_DUNGEON or worldType == g_CATCH_SPIRIT then
			self:updateLeftUI(false)
		end

		if worldType ~= g_OUT_CAST then
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		end
		if worldType == g_HOME_LAND then
			-- g_i3k_logic:OpenHomelandCustomersUI()
		else
			g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
	end
	self.ridebtn:setVisible(g_i3k_game_context:haveSteed())

	-- if worldType ~= g_FIELD then
	-- 	local nativePos = self._layout.vars.autoFight:getPosition()
	-- 	local worldPos = self._layout.vars.skill1:getParent():convertToWorldSpace(self._layout.vars.skill1:getPosition())
	-- 	local needPos = self._layout.vars.autoFight:getParent():convertToNodeSpace(worldPos)
	-- 	worldPos.x = needPos.x
	-- 	worldPos.y = nativePos.y
	-- 	self._layout.vars.autoFight:setPosition(worldPos)
	-- end
	if worldType == g_ARENA_SOLO then
		self:updateLeftUI(false)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	end

	if worldType == g_FACTION_WAR then
		self:updateLeftUI(false)
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupScore)
	end

	if worldType == g_DEFENCE_WAR then
		self:updateLeftUI(false)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarBattle)
	end

	if worldType == g_ILLUSORY_DUNGEON then
		--打开boos属性面板
		g_i3k_ui_mgr:OpenUI(eUIID_BattleIllusory)
	end

	if worldType ~= g_FIELD then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFuben)
	end
	if worldType == g_DESERT_BATTLE then
		self._layout.vars.hppoolbtn:hide()
		self._layout.vars.fproot:hide()
		self:updateDesertBattleDungeon()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFubenDesert)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFubenDesert)
	end
	if worldType == g_DOOR_XIULIAN then
		g_i3k_ui_mgr:OpenUI(eUIID_DoorOfXiuLianFuBen)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DoorOfXiuLianFuBen, "InitBuffs")
		g_i3k_ui_mgr:RefreshUI(eUIID_DoorOfXiuLianFuBen)
	end
	if worldType == g_GOLD_COAST then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:OpenUI(eUIID_GlobalWorldMapTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_GlobalWorldMapTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	end
	if worldType ==  g_SPY_STORY then
		self._layout.vars.hppoolbtn:hide()
		self._layout.vars.fproot:hide()
		self:updateSpyStoryDungeon()
	end
	self:SetWeaponBlessBtnVisible(not i3k_db_common.blockWeaponBless[worldType])--设置武器祝福按钮的显示和隐藏
	self:RecordDebugVarsNameSetVisible(self.ridebtn)
end
function wnd_battleBase:IsShowSkill()
	g_i3k_ui_mgr:OpenUI(eUIID_IsShowSkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_IsShowSkill)
end


function wnd_battleBase:updateRolePKMode(mode)
	self._widgets.role.pkImage:setImage(g_i3k_db.i3k_db_get_icon_path(f_pkImageTable[mode+1]))
	self:updatePKModeSkillUI()
end

function wnd_battleBase:PlayShowSkill()
	self.isPlayingShowSkill = true
	self._layout.anis.c_chuxian.play(function ()
		self.isPlayingShowSkill = nil
		if self.hideSkillAfterShow then
			self:PlayHideSkill()
			self.hideSkillAfterShow = nil
		else
			self:addUnlockSkillsUI()
		end
	end)
	self:HuanXingSkillBtn()
end

function wnd_battleBase:PlayHideSkill()
	self.isPlayingHideSkill = true
	self._layout.anis.c_xiaoshi.play(function()
		self.isPlayingHideSkill = nil
		if self.showSkillAfterHide then
			self:PlayShowSkill()
			self.showSkillAfterHide = nil
		else
			self:hideXiaoshiSkillBtns()
		end
	end)
	self:HuanXingSkillBtn(true)
end

function wnd_battleBase:TryShowSkill()
	self:updateAllSkills()
	if not self._isSkillShow then
		self._isSkillShow = true
		if self.isPlayingHideSkill then
			self.showSkillAfterHide = true
		else
			self:PlayShowSkill()
		end
	end
end

function wnd_battleBase:TryHideSkill()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	if self._isSkillShow then
		self._isSkillShow = false
		if self.isPlayingShowSkill then
			self.hideSkillAfterShow = true
		else
			self:PlayHideSkill()
		end
	end
end

function wnd_battleBase:updatePKModeSkillUI()
	local mode = g_i3k_game_context:GetPKMode()
	local mapType = i3k_game_get_map_type()
	local hero = i3k_game_get_player_hero()
	if (mapType==g_FIELD or mapType == g_FACTION_GARRISON) and hero then
		self:updateRoleRide(g_i3k_game_context:IsOnRide(),g_i3k_game_context:haveSteed())
		if mode==0 and not g_i3k_game_context:IsInSuperMode() and not g_i3k_game_context:IsInMissionMode() then
			if hero:IsInFightTime() then
				self:TryShowSkill()
			else
				self:TryHideSkill()
			end
		else
			self:TryShowSkill()
			self:addUnlockSkillsUI() -- 除了和平模式外，在切换pk模式要添加未解锁技能的ui
		end
	end
end

function wnd_battleBase:hideXiaoshiSkillBtns()
    for _, v in ipairs(self._widgets.commonSkill) do
        v.rootBtn:hide()
    end
    self._widgets.skill.weapon.rootBtn:hide()
end

--显示幻形技能
function wnd_battleBase:HuanXingSkillBtn(isshow)
	local use =  g_i3k_game_context:GetMetamorphosisState()
	if use == 1 then 
		return self.metamorphosis:show()
	end
	if isshow then
		local curId = g_i3k_game_context:GetCurMetamorphosis()
		if curId and i3k_game_get_map_type() == g_FIELD and   curId ~= 0 and not g_i3k_game_context:GetIsSpringWorld() then
			local iconID = i3k_db_metamorphosis[curId].iconId
			self.metamorphosis:show()
			self._layout.vars.metamorphosisIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
		end
	else
		self.metamorphosis:hide()
	end
end
--刷新幻形技能状态
function wnd_battleBase:UpdateHuanXingState(isPressed)
	local curId = g_i3k_game_context:GetCurMetamorphosis()
	if isPressed then
		local iconID = i3k_db_metamorphosis[curId].iconId
		self._layout.vars.metamorphosisIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
		self.metamorphosis:stateToPressed()
		self.metamorphosis:show()
	else
		self.metamorphosis:stateToNormal()
		self.metamorphosis:hide()
	end
end
-- 技能道具
function wnd_battleBase:checkShowSkillItem()
	local items = g_i3k_game_context:getSkillItems()
    local worldType = i3k_game_get_map_type()
	if not next(items) or worldType == g_Life or worldType == g_DESERT_BATTLE or worldType == g_SPY_STORY or worldType == g_CATCH_SPIRIT or worldType == g_BIOGIAPHY_CAREER then
		self._widgets.skill.skillItem:hide()
	else
		self._widgets.skill.skillItem:show()
	end
end


function wnd_battleBase:addUnlockSkillsUI()
	-- 处于任务变身（神兵）状态，或者变身状态直接返回
    local world = i3k_game_get_world()
	if g_i3k_game_context:IsInMissionMode() or g_i3k_game_context:IsInSuperMode() or world._mapType == g_Life or world._mapType == g_DESERT_BATTLE or world._mapType == g_SPY_STORY or world._mapType == g_CATCH_SPIRIT or world._mapType == g_BIOGIAPHY_CAREER then
		return
	end
	if g_i3k_game_context:haveUnlockSkills()then
		if not g_i3k_ui_mgr:GetUI(eUIID_BattleUnlockSkill) then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleUnlockSkill)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleUnlockSkill)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	end
end

-- 在除了大地图中尝试添加解锁技能界面
function wnd_battleBase:addUnlockSkillsUIAtOtherMapType()
	local maptype = i3k_game_get_map_type()
	if maptype ~= g_FIELD and maptype ~= g_DESERT_BATTLE and maptype ~= g_SPY_STORY then
		local hero = i3k_game_get_player_hero()
		if g_i3k_game_context:haveUnlockSkills() and (not hero._inPetLife) then
			if not g_i3k_ui_mgr:GetUI(eUIID_BattleUnlockSkill) then
				g_i3k_ui_mgr:OpenUI(eUIID_BattleUnlockSkill)
			end
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleUnlockSkill)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		end
	end
end

function wnd_battleBase:updateTeamMemberProfiles(selfId, leaderId, profiles)
	self._widgets.role.captainImage:setVisible(selfId == leaderId)
	if g_i3k_game_context:getOpenTaskState() == 1 then
		return
	end
	if profiles and next(profiles) then
		if i3k_game_get_map_type() ~= g_DEFEND_TOWER
			and i3k_game_get_map_type() ~= g_DOOR_XIULIAN
			and g_i3k_game_context:GetWorldMapID() ~= i3k_db_spring.common.mapId
			and g_i3k_game_context:GetWorldMapType() ~= g_DESERT_BATTLE--决战荒漠用新的ui
			and g_i3k_game_context:GetWorldMapType() ~= g_SPY_STORY --密探不显示
			then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTeam)
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
			g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)	
			g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		-- g_i3k_ui_mgr:CloseUI(eUIID_BattlePets)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam,"updateTeamMemberProfiles",selfId, leaderId, profiles)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateMapInfo")
		if i3k_game_get_map_type() == g_ANNUNCIATE then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateAnnunciateInfo", true)
		end
	end
end

function wnd_battleBase:updateCoordInfo(coord)
	if coord then
		local mapId = g_i3k_game_context:GetWorldMapID()
		if i3k_db_dungeon_base[mapId] then
			local mapType = i3k_game_get_map_type()
		local maptable =
		{
			[g_ANNUNCIATE] = true,
			[g_PET_ACTIVITY_DUNGEON] = true,
			[g_DESERT_BATTLE] = true,
			[g_MAZE_BATTLE] = true,
			[g_PRINCESS_MARRY] = true,
			[g_MAGIC_MACHINE] = true,
				[g_LONGEVITY_PAVILION] = true,
				[g_CATCH_SPIRIT] = true,
				[g_SPY_STORY]		= true,
				[g_BIOGIAPHY_CAREER] = true,
		}
			if maptable[mapType] then
				local mapName 
				if mapType == g_MAZE_BATTLE then
					mapName = g_i3k_db.i3k_db_get_maze_cur_zone_name(g_i3k_game_context:getBattleMazeCurZoneId())
				else				
					mapName = i3k_db_dungeon_base[mapId].desc
				end
				local coord = "(" .. i3k_integer(coord.x)  .. "," .. i3k_integer(coord.z)..")"
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateCoordInfo", mapName, coord)
			else
				local line = g_i3k_game_context:GetCurrentLine()
				if mapType == g_GOLD_COAST then
					line = line % 10000 --战区地图分线特殊逻辑
				end
				local lineText = line ~= g_WORLD_KILL_LINE and string.format("(%s线)",line) or "(争夺)"
				if mapId == i3k_db_marry_rules.marryMapID then
					lineText = string.format("(%s)",i3k_get_string(i3k_db_marry_line[line].lineTipsId))
				end
				if mapType == g_DEMON_HOLE or mapType == g_FACTION_GARRISON or mapType == g_HOME_LAND or mapType == g_DEFENCE_WAR then
					lineText = ""
				end
				local mapName = i3k_db_dungeon_base[mapId].desc..lineText
				if mapType == g_GOLD_COAST then
					local desc = i3k_get_string(i3k_db_war_zone_map_fb[mapId].mapDesc)
					mapName = desc..lineText
				end
				local coord = "(" .. i3k_integer(coord.x)  .. "," .. i3k_integer(coord.z)..")"
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateCoordInfo", mapName, coord)
			end
		end
	end
end

function wnd_battleBase:updatePingInfo(ping)
	self._layout.vars.netStatusImg:setImage(g_i3k_game_context:getPingInfoImg(ping))
end

function wnd_battleBase:updatePingInfoDisableStatus()
	self._layout.vars.netStatusImg:setImage(g_i3k_db.i3k_db_get_icon_path(2552))
end

function wnd_battleBase:updateRoleSkills(skills, roleType)
	local hero = i3k_game_get_player_hero()
	local worldType = i3k_game_get_map_type()
	if hero then
		local defaultSkills = g_i3k_db.i3k_db_get_character_default_skills(roleType)
		local needLvl = g_i3k_db.i3k_db_get_skill_unlock_level(defaultSkills)
		local level = g_i3k_game_context:GetLevel()
		local condition = g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.dodgeLvl and worldType ~= g_SPIRIT_BOSS and worldType ~= g_LONGEVITY_PAVILION
		self._widgets.skill.dodge.rootBtn:setVisible(condition)
		local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技
		local uniqueSkillsCondition = use_uniqueSkill > 0 and worldType ~= g_DESERT_BATTLE and worldType ~= g_SPY_STORY and worldType ~= g_BIOGIAPHY_CAREER  --g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.uniqueSkillOpenLvl and
		self._widgets.skill.uniqueSkills.rootBtn:setVisible(uniqueSkillsCondition)
		self._widgets.skill.attack:setVisible(true)
		self._widgets.skill.attackBg:setVisible(true)
		self:checkShowSkillItem()
		self._layout.vars.endMission:hide()
		if hero._missionMode.valid and hero._missionMode.id ~= 0 then
			self._layout.vars.combatTypeBtn:hide()
			for k = 1,4 do
				self._widgets.commonSkill[k].rootBtn:setVisible(false)
			end
			self._widgets.skill.dodge.rootBtn:setVisible(false)
			self._widgets.skill.weapon.rootBtn:setVisible(false)
			self._widgets.skill.uniqueSkills.rootBtn:setVisible(false)
			self._widgets.skill.diySkill.rootBtn:setVisible(false)
			self._widgets.skill.anqi.rootBtn:setVisible(false)
			self._widgets.skill.skillItem:hide()
			local cfg = i3k_db_missionmode_cfg[hero._missionMode.id]
			local scfg = i3k_db_skills[cfg.attacks[1]];
			if hero._missionMode.type == g_TASK_TRANSFORM_STATE_PEOPLE then -- 变身邪教刺客等
				self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon),"")
				local skills = g_i3k_game_context:GetRoleMissionModeSkills()
				for k = 1,4 do
					if skills[k] and skills[k]._id ~= 0 then
						self._widgets.commonSkill[k].icon:setImage(g_i3k_db.i3k_db_get_icon_path(skills[k]._cfg.icon))
						self._widgets.commonSkill[k].rootBtn:setVisible(true)
						self._widgets.commonSkill[k].rootBtn:enableWithChildren()
						local needValue = {index = k, skillId = skills[k]._id, useCommonSkill = true}
						self._useCommonSkillTouck_needValue[k] = needValue
						-- self._widgets.commonSkill[k].rootBtn:onClick(self, self.useCommonSkill, needValue)
						self._widgets.commonSkill[k].lockImage:setVisible(false)
						self._widgets.commonSkill[k].gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
						self._widgets.commonSkill[k].cool:hide()
						self._widgets.commonSkill[k].rootBtn:setTag(skills[k]._id)
						self._widgets.commonSkill[k].anisImage:setOpacity(0)
					else
						self._widgets.commonSkill[k].rootBtn:setTag(0)
					end
				end
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_SUPER then -- 任务神兵变身
				local iconId = i3k_db_shen_bing[cfg.modelId].attackIcon
				self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(iconId),"")
				self._widgets.skill.dodge.rootBtn:setVisible(true)
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_ANIMAL then -- 任务骑马
				self._widgets.skill.attack:setVisible(false);
				self._widgets.skill.attackBg:setVisible(false);
				self._widgets.skill.skillItem:hide()
				self._layout.vars.autoFight:hide()
				g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_CARRY then -- 护送变身
				self._layout.vars.autoFight:hide()
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_SKULL then -- 决战荒漠复活变身
				-- self._layout.vars.autoFight:hide()
				self._widgets.skill.attackBg:hide()
				self._layout.vars.endMission:show()
				self._layout.vars.endMissionTime:show()
				self._widgets.skill.dodge.rootBtn:setVisible(false)
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_CAR then -- 工程车变身
				local weight = self._layout.vars
				weight.autoFight:hide()
				weight.gundong:setVisible(false)
				weight.ridebtn:setVisible(false)
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_METAMORPHOSIS or hero._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS then
				local widget = self._layout.vars
				self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon),"")
				local skills = g_i3k_game_context:GetRoleMissionModeSkills()
				for k = 1,4 do
					if skills[k] and skills[k]._id ~= 0 then
						self._widgets.commonSkill[k].icon:setImage(g_i3k_db.i3k_db_get_icon_path(skills[k]._cfg.icon))
						self._widgets.commonSkill[k].rootBtn:setVisible(true)
						self._widgets.commonSkill[k].rootBtn:enableWithChildren()
						local needValue = {index = k, skillId = skills[k]._id, useCommonSkill = true}
						self._useCommonSkillTouck_needValue[k] = needValue
						-- self._widgets.commonSkill[k].rootBtn:onClick(self, self.useCommonSkill, needValue)
						self._widgets.commonSkill[k].lockImage:setVisible(false)
						self._widgets.commonSkill[k].gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
						self._widgets.commonSkill[k].cool:hide()
						self._widgets.commonSkill[k].rootBtn:setTag(skills[k]._id)
						self._widgets.commonSkill[k].anisImage:setOpacity(0)
					else
						self._widgets.commonSkill[k].rootBtn:setTag(0)
					end
				end
				if hero._missionMode.type == g_TASK_TRANSFORM_STATE_CHESS then
					widget.gundong:show()
					self._widgets.skill.skillItem:show()
				else
					widget.ridebtn:hide() -- 骑乘
					widget.gundong:hide()  -- 轻功
					widget.tabBtn:hide() -- 切换目标
					widget.autoFight:hide() -- 托管
				self:UpdateHuanXingState(true)
				end
			elseif hero._missionMode.type == g_TASK_TRANSFORM_STATE_SPY then -- 密探风云变身
				-- self._layout.vars.autoFight:hide()
				self._widgets.skill.attackBg:hide()
				self._widgets.skill.dodge.rootBtn:setVisible(false)
			end
		elseif hero._inPetLife then
			local skills = g_i3k_game_context:GetPetLifeSkills()
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				end
				widgets.anisImage:setOpacity(0)
			end
		elseif hero._inSprog then -- 新手关引导
			local skills = g_i3k_game_context:GetSprogSkills()
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				end
				widgets.anisImage:setOpacity(0)
			end
		elseif hero._inDesertBattle then
			for k = 1, 4 do
				self._widgets.commonSkill[k].rootBtn:setVisible(false)
			end
			local skills = g_i3k_game_context:getDesertBattleSkills()
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				end
				widgets.anisImage:setOpacity(0)
			end
		elseif hero._inSpyStory then --密探风云
			for k = 1, 4 do
				self._widgets.commonSkill[k].rootBtn:setVisible(false)
			end
			local skills = g_i3k_game_context:getSpyStorySkills()
			if hero._cfg.attacks[1] then
				local scfg = i3k_db_skills[hero._cfg.attacks[1]];
				self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon),"")
			end
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				end
				widgets.anisImage:setOpacity(0)
			end
		elseif worldType == g_CATCH_SPIRIT then
			for k = 1, 4 do
				self._widgets.commonSkill[k].rootBtn:setVisible(false)
			end
			local skills = i3k_db_catch_spirit_skills[g_i3k_game_context:GetRoleType()].baseSkills
			self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_skill_icon_path(i3k_db_catch_spirit_base.dungeon.callSkillId), "")
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				end
				widgets.anisImage:setOpacity(0)
			end
		elseif hero._inBiographyCareer then
			for k = 1, 4 do
				self._widgets.commonSkill[k].rootBtn:setVisible(false)
			end
			local careerData = g_i3k_game_context:getBiographyCareerInfo()
			local careerId = g_i3k_game_context:getCurBiographyCareerId()
			local skills = careerData[careerId].equipSkills
			for i, v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v ~= 0 then
					widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[1]))
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v, useCommonSkill = true}
					self._useCommonSkillTouck_needValue[i] = needValue
				else
					widgets.lockImage:show()
					widgets.cool:hide()
					widgets.rootBtn:disableWithChildren()
					widgets.coolWord:hide()
				end
				widgets.anisImage:setOpacity(0)
			end
		else
			for i,v in ipairs(skills) do
				local widgets = self._widgets.commonSkill[i]
				widgets.rootBtn:setVisible(true);
				if v~=0 then
					local allSkill, useSkill = g_i3k_game_context:GetRoleSkills()
					for _,t in pairs(allSkill) do
						if v==t.id then
							widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[t.state+1]))
						end
					end
					widgets.rootBtn:setTag(v)
					widgets.rootBtn:enableWithChildren()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(v))
					widgets.lockImage:show()
					widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(1339))
					widgets.cool:hide()
					local needValue = {index = i, skillId = v}
					self._useCommonSkillTouck_needValue[i] = needValue
				else
					widgets.lockImage:show()
					widgets.cool:hide()
					widgets.rootBtn:setTag(0)
					widgets.coolWord:hide()
					widgets.icon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(defaultSkills[i]))
					if v==0 and level>=needLvl[i] then
						widgets.rootBtn:enableWithChildren()
						widgets.lockImage:setImage(g_i3k_db.i3k_db_get_icon_path(857))
						local needValue = {index = i, skillId = defaultSkills[i]}

						if i3k_game_get_map_type() ~= g_DESERT_BATTLE and i3k_game_get_map_type() ~= g_SPY_STORY and i3k_game_get_map_type() ~= g_BIOGIAPHY_CAREER then
						widgets.rootBtn:onClick(self, self.onSkillUnlock, needValue)
						end
					else
						widgets.rootBtn:disableWithChildren()
					end
				end
				widgets.anisImage:setOpacity(0)
			end
			self._layout.vars.autoFight:show()
			self._layout.vars.tabBtn:show() -- 切换目标
			self:HuanXingSkillBtn(not self._isSkillShow)
		end

		self:RecordDebugVarsNameSetVisible(self._layout.vars.autoFight)
	end
end

function wnd_battleBase:updateRoleWeapon(weaponId, superMode)
	local widgets = self._widgets.skill.weapon
	self:showWeaponMnualSkillUI(weaponId, superMode)
 	if weaponId~=0 then
		local hero = i3k_game_get_player_hero()
		if hero and not hero._missionMode.valid then
			widgets.rootBtn:show()
		end
		--local iconId = i3k_db_shen_bing[weaponId].battleIcon
		-- widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
	else
		widgets.rootBtn:hide()
	end
	if superMode then
		if i3k_db_shen_bing[weaponId] then
			local iconId = i3k_db_shen_bing[weaponId].attackIcon
			self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(iconId),"")
			self._layout.vars.combatTypeBtn:setVisible(false)
		end
		if not i3k_get_is_tournament_weapon() then
			self._layout.vars.skillNodes:hide()
		end
		self._widgets.skill.skillItem:hide()
		self.soulenergyBg:hide();
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	else
		self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(988),"")
		local hero = i3k_game_get_player_hero();
		if hero then
			local mapType = i3k_game_get_map_type()
			local mapty =
			{
				[g_Life] = i3k_db_mercenaries,
				[g_PET_ACTIVITY_DUNGEON] = i3k_db_mercenaries,
				[g_DESERT_BATTLE] = i3k_db_desert_generals,
			}
			local cfg = mapty[mapType] and mapty[mapType][hero._id] or g_i3k_db.i3k_db_get_general(hero._id)
			if mapType == g_SPY_STORY then
				cfg = i3k_db_spy_story_generals[hero._spyInfo.camp][hero._spyInfo.modelID]
			end
			if cfg and cfg.attacks[1] then
				local scfg = i3k_db_skills[cfg.attacks[1]];
				self._widgets.skill.attack:setImage(g_i3k_db.i3k_db_get_icon_path(scfg.icon),"")
			end
		end
		if not i3k_get_is_tournament_weapon() then
			self._layout.vars.skillNodes:show()
			self:showCombatTypebtn()
		end
		self:checkShowSkillItem()
		if hero and hero:IsInFightTime() and not self.isPlayingShowSkill and not self.isPlayingHideSkill then
			self:addUnlockSkillsUI()
		end
		local condition = g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.dodgeLvl and g_i3k_game_context:GetWorldMapType() ~= g_SPIRIT_BOSS and g_i3k_game_context:GetWorldMapType() ~= g_LONGEVITY_PAVILION
		self._layout.vars.gundong:setVisible(condition)
		local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技
		local uniqueSkillsCondition = use_uniqueSkill > 0 --g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.uniqueSkillOpenLvl and
		local isShow = not self:getFightStateUIIsShow()
		self._layout.vars.gundong2:setVisible(uniqueSkillsCondition and isShow)
	end
end

--更新武器祝福技能
function wnd_battleBase:updateRoleWeaponBless(skillID, blessMode)
	local worldType =  g_i3k_game_context:GetWorldMapType()
	local worldShow = not i3k_db_common.blockWeaponBless[worldType]
	local haveSkill = skillID and i3k_db_equip_temper_skill[skillID] and true or false
	local isInMission = g_i3k_game_context:IsInMissionMode() --是否在变身任务
	self:SetWeaponBlessBtnVisible(worldShow and haveSkill and not isInMission)
end
--设置武器祝福技能显隐
function wnd_battleBase:SetWeaponBlessBtnVisible(bValue)
	self._widgets.skill.weaponBless.root:setVisible(bValue)
end

function wnd_battleBase:updateRoleMissionSkill(id, missionMode)
	local worldType = i3k_game_get_map_type()
	self:updateRoleSkills(g_i3k_game_context:GetRoleSelectSkills(), g_i3k_game_context:GetRoleType())
	if worldType ~= g_DESERT_BATTLE and worldType ~= g_SPY_STORY then
	self:updateRoleWeaponBless(g_i3k_game_context:GetActiveWeaponBlessID())
	self:updateRoleWeaponBlessEnergy(g_i3k_game_context:GetRoleWeaponBlessEnergy())
	end
	if missionMode then
		local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
		self:onChangeStuntAnimation(animation,false)
	elseif worldType ~= g_DESERT_BATTLE and worldType ~= g_SPY_STORY then
		self:updateRoleWeapon(g_i3k_game_context:GetSelectWeapon(), g_i3k_game_context:IsInSuperMode())
		self:updateRoleWeaponEnergy(g_i3k_game_context:GetRoleWeaponErergy())
		self:updateSoulEnergy(g_i3k_game_context:GetSoulEnergy());
		self:updateRoleDIYSkill(g_i3k_game_context:GetCurrentDIYSkillId(), g_i3k_game_context:GetCurrentDIYSkillIconId(), g_i3k_game_context:GetCurrentSkillGradeId())
		self:updateRoleDodgeSkill(g_i3k_game_context:GetRoleType())
		self:updateRoleUniqueSkill(g_i3k_game_context:GetRoleType())
		self:updatePKModeSkillUI()
		self:updataRoleAnqiSkill(g_i3k_game_context:getEquipedHideWeaponSkill())
	end
end

function wnd_battleBase:updateRoleWeaponEnergy(curvalue, maxvalue)
	local widgets = self._widgets.skill.weapon
	local percent = curvalue/maxvalue*100
	widgets.sp:setPercent(percent)
	self:setWeaponParticle(percent)
	local animation = g_i3k_game_context:GetSelectWeaponMaxAnimation()
	if animation then
		self:onChangeStuntAnimation(animation, percent == 100)	
	end
end

local BLESS_STATE_NULL = 0
local BLESS_STATE_UP = 1
local BLESS_STATE_MAX = 2
local BLESS_STATE_DOWN = 3
function wnd_battleBase:updateRoleWeaponBlessEnergy(curValue, maxValue)
	local widgets = self._widgets.skill.weaponBless
	if not widgets.root:isVisible() then return end
	local percent = maxValue == 0 and 0 or curValue/maxValue*100
	widgets.sp:setPercent(percent)
	local hero = i3k_game_get_player_hero()
	local blessState = hero:GetWeaponBlessState()
	if blessState == BLESS_STATE_DOWN then
		self._layout.anis.c_cljn.play()
		widgets.root:enable()
		widgets.root:setImage(g_i3k_db.i3k_db_get_icon_path(7340))
	elseif blessState == BLESS_STATE_MAX then
		widgets.root:enable()
		widgets.root:setImage(g_i3k_db.i3k_db_get_icon_path(7341))
		self._layout.anis.c_cljn:stop()
		self._layout.anis.c_cljn.play()
	elseif blessState == BLESS_STATE_NULL then
		self._layout.anis.c_cljn:stop()
		widgets.root:disable()
		widgets.root:setImage(g_i3k_db.i3k_db_get_icon_path(7341))
	else
		widgets.root:disable()
		widgets.root:setImage(g_i3k_db.i3k_db_get_icon_path(7341))
	end
end

-- 设置神兵技能按钮的特效位置以及宽度大小
function wnd_battleBase:setWeaponParticle(percent)
	local isRising = g_i3k_game_context:getWeaponRisingStatus()
	local weaponRoot = self._layout.vars.weaponlizi
	local par1 = self._layout.vars.weaponPar1
	local par2 = self._layout.vars.weaponPar2
	local par3 = self._layout.vars.weaponPar3
	local par4 = self._layout.vars.weaponPar4
	if isRising then
		par1:show()
		par2:show()
		par3:hide()
		par4:hide()
	else
		par1:hide()
		par2:hide()
		par3:show()
		par4:show()
		par1 = par3
		par2 = par4
	end

	local Amounts1 = par1.ccNode_._nodeEff:getTotalParticles() -- 粒子个数
	local Amounts2 = par2.ccNode_._nodeEff:getTotalParticles()
	local pos1 = par1.ccNode_._nodeEff:getPosVar() -- 粒子显示的范围，高度宽度
	local pos2 = par2.ccNode_._nodeEff:getPosVar()

	local isPad = g_i3k_ui_mgr:JudgeIsPad()
	local radius = isPad and 34 or 45 --r.height / 2 - 9   --45  -- 半径
	local rootPos = weaponRoot:getPosition() -- x = 54, y = 54
	local deltY = (50 - percent) / 50 * radius
	local x = percent < 50 and 2 * radius * percent / 100 or 2 * radius *(1 - percent / 100)
	local lengthX = 2 * math.sqrt(x * (2 * radius - x))

	par1.ccNode_._nodeEff:setPosVar({x = lengthX/2, y = 1})
	par2.ccNode_._nodeEff:setPosVar({x = lengthX/2, y = 3})
	weaponRoot:setPosition(rootPos.x, radius -5 - deltY)
	weaponRoot:setVisible(percent > 2 and true or false)
	self:setWeaponImg()
	self:setWeaponAnis(percent)
end


-- 根据神兵能量的增加还是减少设置图片
function wnd_battleBase:setWeaponImg()
	local imgFront = self._layout.vars.weaponAngerImg
	local imgBack  = self._layout.vars.weaponSp
	local isRising = g_i3k_game_context:getWeaponRisingStatus()
	if isRising then
		imgFront:setImage(g_i3k_db.i3k_db_get_icon_path(3322))
		imgBack:setImage(g_i3k_db.i3k_db_get_icon_path(3320))
	else
		imgFront:setImage(g_i3k_db.i3k_db_get_icon_path(3323))
		imgBack:setImage(g_i3k_db.i3k_db_get_icon_path(3321))
	end
end


function wnd_battleBase:setWeaponAnis(percent)
	if not g_i3k_game_context:IsInSuperMode() then
		if percent == 100 then
			self._layout.anis.c_man.play()
			return
		end
	end
end

function wnd_battleBase:onChangeStuntAnimation(name,enable)
	if self._layout.anis[name] then
		if enable then
			self._layout.anis[name].play()
		else
			self._layout.anis[name].stop()
		end
	end
end

function wnd_battleBase:updateRoleDodgeSkill(roleType)
	local widgets = self._widgets.skill.dodge
	--local dodgeSkill = g_i3k_db.i3k_db_get_character_dodge_skill(roleType)
	widgets.coolWord:hide()
	widgets.cool:hide()
	if g_i3k_game_context:GetWorldMapType() == g_SPIRIT_BOSS then
		widgets.rootBtn:hide()
		-- widgets.rootBtn:onClick(self, self.useDodgeSkill)
	end
end

function wnd_battleBase:updateRoleUniqueSkill(roleType)
	local hero = i3k_game_get_player_hero()
	if hero and not hero._missionMode.valid then
		local widgets = self._widgets.skill.uniqueSkills
		local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技
		local _skill_data = i3k_db_skills[use_uniqueSkill]
		if _skill_data then
			widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
			widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[role_unique_skill[use_uniqueSkill].state+1]))
			widgets.anisImage:setOpacity(0)
			widgets.anisImage:show()
			widgets.coolWord:hide()
			widgets.cool:hide()
			-- widgets.rootBtn:onTouchEvent(self,self.useUniqueSkillTouch)
		end
	end
end

function wnd_battleBase:updateRoleDIYSkill(skillId, iconId, gradeId)
	local widgets = self._widgets.skill.diySkill
	widgets.cool:hide()
	widgets.coolWord:hide()
	widgets.anisImage:hide()
	widgets.lockImage:hide()
	if skillId~=0 then
		local hero = i3k_game_get_player_hero()
		if hero and not hero._missionMode.valid then
			widgets.rootBtn:show()
		end
		-- widgets.rootBtn:onTouchEvent(self,self.onDIYTouch)
	else
		widgets.rootBtn:hide()
	end
	if gradeId then
		widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[gradeId]))
	end
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end

function wnd_battleBase:onUpdateSkills(dTime)
	for i,v in pairs(self._widgets.commonSkill) do
		local skillId = v.rootBtn:getTag()
		if skillId~=0 then
			local canUse = g_i3k_game_context:GetSkillIsCanUse(skillId)
			if not canUse then
				local totalTime, hasCoolTime = g_i3k_game_context:GetRoleSkillCoolLeftTime(skillId)
				local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
				v.coolWord:setText(math.ceil(coolLeftTime))
				v.coolWord:show()
				v.cool:show()
				local percent = 100*coolLeftTime/(totalTime/1000)
				local progressAction = v.cool:createProgressAction(coolLeftTime, percent, 0)
				v.cool:runAction(progressAction)
				self._skillCoolAnis[i] = true
			else
				v.cool:hide()
				v.coolWord:hide()
				if self._skillCoolAnis[i] then
					local jnLabel = "jn"..i
					local jn = self._layout.anis[jnLabel]
					jn.play()
					self._skillCoolAnis[i] = false
				end
			end
		end
	end
end

function wnd_battleBase:onUpdateDodge(dTime)
	local widgets = self._widgets.skill.dodge
	local canUse = g_i3k_game_context:GetDodgeSkillIsCanUse()
	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:GetRoleDodgeSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
		widgets.coolWord:setText(math.ceil(coolLeftTime))
		widgets.coolWord:show()
		widgets.cool:show()
		local percent = 100*coolLeftTime/(totalTime/1000)
		local progressAction = widgets.cool:createProgressAction(coolLeftTime, percent, 0)
		widgets.cool:runAction(progressAction)
		self._dodgeAnis = true
	else
		widgets.cool:hide()
		widgets.coolWord:hide()
		if self._dodgeAnis then
			self._dodgeAnis = false
		end
	end
end

function wnd_battleBase:onUpdateUniqueSkill(dTime)
	local widgets = self._widgets.skill.uniqueSkills
	local canUse = g_i3k_game_context:GetUniqueSkillIsCanUse()
	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:GetRoleUniqueSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
		widgets.coolWord:setText(math.ceil(coolLeftTime))
		widgets.coolWord:show()
		widgets.cool:show()
		local percent = 100*coolLeftTime/(totalTime/1000)
		local progressAction = widgets.cool:createProgressAction(coolLeftTime, percent, 0)
		widgets.cool:runAction(progressAction)
		self._uniqueAnis = true
	else
		widgets.cool:hide()
		widgets.coolWord:hide()
		if self._uniqueAnis then
			widgets.anisImage:setOpacity(0)
			widgets.anisImage:show()
			self._layout.anis.jn7.play()
			self._uniqueAnis = false
		end
	end
end

function wnd_battleBase:onUpdateDIYSkill(dTime)
	local widgets = self._widgets.skill.diySkill
	local canUse = g_i3k_game_context:GetDIYSkillIsCanUse()
	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:GetRoleDIYSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime)/1000)
		widgets.coolWord:setText(math.ceil(coolLeftTime))
		widgets.coolWord:show()
		widgets.cool:show()
		local percent = 100*coolLeftTime/(totalTime/1000)
		local progressAction = widgets.cool:createProgressAction(coolLeftTime, percent, 0)
		widgets.cool:runAction(progressAction)
		self._diySkillAnis = true
	else
		if self._diySkillAnis then
			widgets.anisImage:setOpacity(0)
			widgets.anisImage:show()
			self._layout.anis.jn5.play()
			self._diySkillAnis = false
		end
		widgets.cool:hide()
		widgets.coolWord:hide()
	end
end

function wnd_battleBase:updateRoleAutoFight(auto,isshow)
	if auto then
		self.autoFight:stateToPressed()
	else
		self.autoFight:stateToNormal()
	end
	self.autoFight:setVisible(isshow);
end

function wnd_battleBase:updateRoleRide(isride,isshow)
	if not g_i3k_game_context:GetIsSpringWorld() then
		self.ridebtn:setVisible(isshow)
		if isride then
			self.ridebtn:stateToNormal()
		else
			self.ridebtn:stateToPressed()
		end
		self:RecordDebugVarsNameSetVisible(self.ridebtn)
	end
end

--聊天红点
function wnd_battleBase:onShowChatRedPoint(msgtype)
	local redPoint = self._layout.vars.chatRedPoint
	redPoint:show()
	if (msgtype == global_recent or msgtype == global_cross) then
		self.privateChatRed:show()
	end
end

function wnd_battleBase:onHideChatRedPoint()
	local redPoint = self._layout.vars.chatRedPoint
	if g_i3k_game_context:isEmpty() then
		redPoint:hide()
		self.privateChatRed:hide()
	else
		local msgs = g_i3k_game_context:GetChatMsg()
		if #msgs[global_recent + 1] == 0 then
			self.privateChatRed:hide()
		end
	end
end

--聊天显示内容
function wnd_battleBase:onRefreshChatLog()
	local chatScroll = self.chatLog
	chatScroll:removeAllChildren()
	local contentSize = chatScroll:getContentSize()
	chatScroll:setContainerSize(contentSize.width, contentSize.height)
	local chatData = g_i3k_game_context:GetChatData()--获取数据
	for i,v in chatData[2]:ipairs() do
		self:createBattleBaseChatItem(v)
	end
end

function wnd_battleBase:receiveNewMsg(message)
	self:createBattleBaseChatItem(message)
end

function wnd_battleBase:createBattleBaseChatItem(message)
	if self.chatLog:getChildrenCount() >=  g_Battle_Base_Chat_Count then
		self.chatLog:removeChildAtIndex(1)
	end
	self:createChatItem(message, self.chatLog)
	self.lastChatType = message.type
end

--荒漠快捷穿戴
function wnd_battleBase:onUpdateDesertBetterEquipShow()
	if g_i3k_game_context:GetNotEnterMapIdTips() then
		return
	end
	local worldType = i3k_game_get_map_type()
	if worldType == g_DESERT_BATTLE then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		local flag = g_i3k_game_context:GetDesertBetterEquipState()
		if flag then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleEquip, nil, nil, true)
		end
	end
end
function wnd_battleBase:onUpdateBatterEquipShow()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	if g_i3k_game_context:GetNotEnterMapIdTips() then
		return
	end
	local flag = g_i3k_game_context:GetBatterEquipStatus()
	local worldType = i3k_game_get_map_type()
	if flag and (worldType == g_FIELD or worldType == g_FACTION_GARRISON) then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEquip)
	end
	if not flag then
		self:onItemTipsShow()
	end
end

function wnd_battleBase:onItemTipsShow()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	local item = g_i3k_game_context:getNewItemCheckId()
	if item == nil then
		return
	end
	if g_i3k_game_context:GetNotEnterMapIdTips() then
		return
	end
	local flag = g_i3k_game_context:GetBatterEquipStatus()
	local worldType = i3k_game_get_map_type()
	if not flag and (worldType == g_FIELD or worldType == g_FORCE_WAR or worldType == g_FACTION_GARRISON or worldType == g_GLOBAL_PVE or worldType == g_PET_ACTIVITY_DUNGEON or worldType == g_HOME_LAND) then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleEquip)
	end
end


function wnd_battleBase:updateDrugIcon()
	local drugcount = g_i3k_game_context:GetAllDrugCount()
	local drugfilter = i3k_db_common.drug.druglimited
	local maptype = i3k_game_get_map_type()
	local level = g_i3k_game_context:GetLevel()
	local condition = maptype == g_FIELD or maptype == g_BASE_DUNGEON or maptype == g_ACTIVITY or maptype == g_TOWER or mapType == g_Life or mapType == g_OUT_CAST or mapType == g_AT_ANY_MOMENT_DUNGEON or mapType == g_CATCH_SPIRIT or mapType == g_BIOGIAPHY_CAREER
	local isVipBloodPoolEmpty = g_i3k_game_context:GetVipBloodPool() == 0;
	local t = drugcount <= drugfilter and level >= i3k_db_common.drug.drugshowlvl and condition and isVipBloodPoolEmpty
	--在每次进入battleBase时进行判断是否显示血量不足提示
	if t then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleDrug)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
	end
end

--未领取离线经验提示
function wnd_battleBase:updateOfflineExp()
	local info = g_i3k_game_context:GetOfflineExpData()
	local maptype = i3k_game_get_map_type()
	local pushMinTime = i3k_db_offline_exp.pushMinTime
	local condition = maptype == g_FIELD --or maptype == g_BASE_DUNGEON or maptype == g_ACTIVITY or maptype == g_TOWER
	-- 只有大地图显示
	local t = info.accTimeTotal ~= 0 and info.accTimeTotal > pushMinTime and condition
	if t and g_i3k_game_context:getIsHideOfflineExp() == 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleOfflineExp)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
	end
end

-- 根据状态等级，判断那些显示经验的UI需要常驻内存中
function wnd_battleBase:updateShowExpUI()
	local maptype = i3k_game_get_map_type()
	if mapType == g_FORCE_WAR then
		g_i3k_ui_mgr:OpenUI(eUIID_PVPShowKill)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_BattleShowExp)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleShowEquipPower)
		local lilianOpenLvl = i3k_db_experience_args.args.openLevel
		if g_i3k_game_context:GetLevel() >= lilianOpenLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_BattleShowExpCoin)
		end
		if g_i3k_game_context:GetLevel() >= i3k_db_swordsman_circle_cfg.openLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_SwordsmanExpProp)
		end
	end
end


function wnd_battleBase:addExpShow(iexp, oExp, dExp, wExp, cexp, sectZoneSpiritexp, globalWorldCardAdd, swornAdd)
	local dataList = {}
	dataList.iexp = iexp
	dataList.oExp = oExp
	dataList.dExp = dExp
	dataList.wExp = wExp
	dataList.cexp = cexp
	dataList.sectZoneSpiritexp = sectZoneSpiritexp
	dataList.gwcExp = globalWorldCardAdd
	dataList.swornAdd = swornAdd
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowExp, g_BATTLE_SHOW_EXP, dataList)
end

function wnd_battleBase:addPVPShowKill(kill,killermyself)
	-- g_i3k_ui_mgr:OpenUI(eUIID_PVPShowKill)
	g_i3k_ui_mgr:RefreshUI(eUIID_PVPShowKill, kill,killermyself)
end

function wnd_battleBase:addExpCoinShow(expCoin)
	-- g_i3k_ui_mgr:OpenUI(eUIID_BattleShowExpCoin)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowExpCoin, expCoin)
end

function wnd_battleBase:addPowerRepUI()
	local openLevel = g_i3k_db.i3k_db_power_rep_get_open_min_level()
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= openLevel then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleShowPowerRep)
	end
end

function wnd_battleBase:addPowerRepShow(power) -- InvokeUIFunction
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowPowerRep, power)
end

function wnd_battleBase:addEquipPower(power) -- InvokeUIFunction
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowEquipPower, power)
end

function wnd_battleBase:updateRoleBuff(buffs)
	self._herobuff = buffs
	self._cleanbuff = true;
end

function wnd_battleBase:updateRoleAboveBuff(aboveBuffs)
	local count = self._widgets.buff.aboveBuff:getAllChildren()
	if #aboveBuffs > #count then
		local children = self._widgets.buff.aboveBuff:addChildWithCount(LAYER_BUFF, 2, #aboveBuffs, true)
		for i, e in ipairs(aboveBuffs) do
			local widget = children[i].vars
			widget.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(e.iconID))
			widget.bt:onClick(self, self.onAboveBuffSelect, e)
		end
		self._widgets.buff.aboveBuff:stateToNoSlip()
		self._widgets.buff.aboveBuff:setVisible(#aboveBuffs > 0)
	end
end

function wnd_battleBase:onAboveBuffSelect(sender, cfg)
	g_i3k_ui_mgr:OpenUI(eUIID_AboveBuffTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_AboveBuffTips, cfg)
end

function wnd_battleBase:onUpdatebuff(dTime)
	local update = false
	for _, buff in pairs(self._herobuff) do
		update = true;
	end

	--卡片buff
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	if table.nums(cardInfo.card.inUse) > 0 then
		update = true;
	end
	if update or self._cleanbuff then
		self._selfbuffupdate_time = self._selfbuffupdate_time + dTime
		if self._selfbuffupdate_time > 0.1 then
			if self._cleanbuff then
				self:Clearbuff()
			end
			for id,lefttime in pairs(self._herobuff) do
				self._herobuff[id] = self._herobuff[id] - self._selfbuffupdate_time *1000
			end

			if self._cleanbuff then
				self:updateselfbuff()
				-- self:updatetargetbuff()
				self._cleanbuff = false
			end
			self._selfbuffupdate_time = 0;
		end
	end
	--帮派祝福buf
	if g_i3k_game_context:GetBlessingBuffState() and not g_i3k_game_context:blessingBuffOpenTime() then
		self:updateselfbuff()
		g_i3k_game_context:SetBlessingBuffState(false)
	end
end

function wnd_battleBase:Clearbuff()
	self._widgets.buff.mybuff:removeAllChildren()
end

function wnd_battleBase:updateselfbuff()
	local selfbuffcount = 0
	local selfdebuffcount = 0
	self._bufflist[1] = {}
	self._bufflist[2] = {}
	for id,lefttime in pairs(self._herobuff) do
		local cfg = i3k_db_buff[id]
		if cfg.type == 0 or cfg.type == 1 then
			if cfg.iconID ~= 0 and cfg.iconID ~= 1 then
				table.insert(self._bufflist[1], cfg)
				selfbuffcount = selfbuffcount + 1
			end
		elseif cfg.type == 2 then
			if cfg.iconID ~= 0 and cfg.iconID ~= 1 then
				table.insert(self._bufflist[2], cfg)
				selfdebuffcount = selfdebuffcount + 1
			end
		end
	end
	if selfbuffcount > 6 then
		selfbuffcount = 6
	end
	if selfdebuffcount > 6 then
		selfdebuffcount = 6
	end

	local children = self._widgets.buff.mybuff:addChildWithCount(LAYER_BUFF,6,12)

	--设置通用icon的方法 isDebuff为是否是负面buff start为需要设置buff的位置
	local function setBuffIcon(isDebuff, start)
		for i = start, 6 do
			local index = i - start + 1
			local count = isDebuff and i + 6 or i
			local buffCount = isDebuff and selfdebuffcount or selfbuffcount

			children[count].vars.bt:setTouchEnabled(false)
			children[count].vars.bt:hide()
			if index <= buffCount then
				children[count].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self._bufflist[isDebuff and 2 or 1][index].iconID))
				children[count].vars.bt:setTag(isDebuff and (index + 6) or index)
				children[count].vars.bt:onClick(self, self.onBuffSelect)
				children[count].vars.bt:show()
			end
		end
	end

	--设置buff药icon
	local function setBuffDrugIcon(start)
		children[start].vars.bt:setTouchEnabled(false)
		children[start].vars.bt:hide()
		children[start].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(BUFF_DRUG_ICON))
		children[start].vars.bt:onClick(self, self.onBuffDrugSelect, g_NORMAL_BUFF_DRUG)
		children[start].vars.bt:show()
	end

	--设置争夺线buff药icon
	local function setFightLineBuffIcon(start)
		children[start].vars.bt:setTouchEnabled(false)
		children[start].vars.bt:hide()
		children[start].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(FIGHT_LINE_BUFF_DRUG_ICON))
		if g_i3k_game_context:GetCurrentLine() ~= g_WORLD_KILL_LINE then
			children[start].vars.grade_icon:disableWithChildren()
		end
		children[start].vars.bt:onClick(self, self.onBuffDrugSelect, g_FIGHT_LINE_BUFF_DRUG)
		children[start].vars.bt:show()
	end

	--设置城主之光icon
	local function setCityLightBuffIcon(start)
		children[start].vars.bt:setTouchEnabled(false)
		children[start].vars.bt:hide()
		children[start].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(CITY_LIGHT_ICON))
		children[start].vars.bt:onClick(self, self.onDefenceWarExpSelect)
		children[start].vars.bt:show()
	end
	
	--设置帮派祝福icon
	local function setFactionBlessing(start)
		children[start].vars.bt:setTouchEnabled(false)
		children[start].vars.bt:hide()
		local icon = i3k_db_faction_spirit.spiritCfg.blessingIcon
		children[start].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		children[start].vars.bt:onClick(self, self.onFactionBlessing)
		children[start].vars.bt:show()
	end
	--设置卡片buff
	local function setWarZoneCardBuff(start, info)
		children[start].vars.bt:setTouchEnabled(false)
		children[start].vars.bt:hide()
		local cfg = i3k_db_war_zone_map_card[info.id]
 		local buff = i3k_db_buff[cfg.buffId]
		children[start].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(buff.iconID))
		if not info.isShow then
			children[start].vars.grade_icon:disable()
		end
		children[start].vars.bt:onClick(self, self.onBuffCardSelect, info)
		children[start].vars.bt:show()
	end
	local startIndex = 1
	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
	if table.nums(cardInfo.card.inUse) > 0 then
		local inUse = cardInfo.card.inUse
		for k,v in pairs(inUse) do
			local isShow =  i3k_db.i3k_db_get_war_zone_card_buff_is_show(k)
		 	setWarZoneCardBuff(startIndex, {id = k, isShow = isShow})
		 	startIndex = startIndex + 1
		 end 
	end
	if g_i3k_game_context:isOpenBlessingBuf() then
		setFactionBlessing(startIndex)
		startIndex = startIndex + 1
	end
		if g_i3k_game_context:isOpenCityLight() then
		setCityLightBuffIcon(startIndex)
		startIndex = startIndex + 1
	end
			if g_i3k_game_context:IsShowBuffDrugIcon(false) then
		setBuffDrugIcon(startIndex)
		startIndex = startIndex + 1
	end
				if g_i3k_game_context:IsShowFightLineBuff() then
		setFightLineBuffIcon(startIndex)
		startIndex = startIndex + 1
		setBuffIcon(false, startIndex)
				else
		setBuffIcon(false, startIndex)
				end
	-- if g_i3k_game_context:isOpenBlessingBuf() then
	-- 	setFactionBlessing(1)
	-- 	if g_i3k_game_context:isOpenCityLight() then
	-- 		setCityLightBuffIcon(2)
	-- 		if g_i3k_game_context:IsShowBuffDrugIcon(false) then
	-- 			setBuffDrugIcon(3)
	-- 			if g_i3k_game_context:IsShowFightLineBuff() then
	-- 				setFightLineBuffIcon(4)
	-- 				setBuffIcon(false, 5)
	-- 			else
	-- 				setBuffIcon(false, 4)
	-- 			end
	-- 		elseif g_i3k_game_context:IsShowFightLineBuff() then
	-- 			setFightLineBuffIcon(3)
	-- 			setBuffIcon(false, 4)
	-- 		else
	-- 			setBuffIcon(false, 3)
	-- 		end
	-- 	elseif g_i3k_game_context:IsShowBuffDrugIcon(false) then
	-- 		setBuffDrugIcon(2)
	-- 		if g_i3k_game_context:IsShowFightLineBuff() then
	-- 			setFightLineBuffIcon(3)
	-- 			setBuffIcon(false, 4)
	-- 		else
	-- 			setBuffIcon(false, 3)
	-- 		end
	-- 	elseif g_i3k_game_context:IsShowFightLineBuff() then
	-- 		setFightLineBuffIcon(2)
	-- 		setBuffIcon(false, 3)
	-- 	else
	-- 		setBuffIcon(false, 2)
	-- 	end
	-- elseif g_i3k_game_context:isOpenCityLight() then
	-- 	setCityLightBuffIcon(1)
	-- 	if g_i3k_game_context:IsShowBuffDrugIcon(false) then
	-- 		setBuffDrugIcon(2)
	-- 		if g_i3k_game_context:IsShowFightLineBuff() then
	-- 			setFightLineBuffIcon(3)
	-- 			setBuffIcon(false, 4)
	-- 		else
	-- 			setBuffIcon(false, 3)
	-- 		end
	-- 	elseif g_i3k_game_context:IsShowFightLineBuff() then
	-- 		setFightLineBuffIcon(2)
	-- 		setBuffIcon(false, 3)
	-- 	else
	-- 		setBuffIcon(false, 2)
	-- 	end
	-- elseif g_i3k_game_context:IsShowBuffDrugIcon(false) then
	-- 	setBuffDrugIcon(1)
	-- 	if g_i3k_game_context:IsShowFightLineBuff() then
	-- 		setFightLineBuffIcon(2)
	-- 		setBuffIcon(false, 3)
	-- 	else
	-- 		setBuffIcon(false, 2)
	-- 	end
	-- elseif g_i3k_game_context:IsShowFightLineBuff() then
	-- 	setFightLineBuffIcon(1)
	-- 	setBuffIcon(false, 2)
	
	-- else
	-- 	setBuffIcon(false, 1)
	-- end

	--设置debuff icon
	setBuffIcon(true, 1)
end

function wnd_battleBase:onBuffSelect(sender)
	local tagID = sender:getTag()
	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)
	local buffname;
	local bufflefttime = 0
	if tagID > 0 and tagID <= 6 then
		buffname = self._bufflist[1][tagID].note
	elseif tagID > 6 and tagID <= 12 then
		buffname = self._bufflist[2][tagID - 6].note
	elseif tagID > 12 and tagID <= 18 then
		buffname = self._bufflist[3][tagID - 12].note
	elseif tagID > 18 and tagID <= 24 then
		buffname = self._bufflist[4][tagID - 18].note
	end
	g_i3k_ui_mgr:OpenUI(eUIID_BuffTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuffTips, buffname, pos)
end

--设置战区卡片buff
function wnd_battleBase:onBuffCardSelect(sender, info)
 	local pos = sender:getPosition()
 	local cardInfo = g_i3k_game_context:GetWarZoneCardInfo()
 	local cfg = i3k_db_war_zone_map_card[info.id]
 	local buff = i3k_db_buff[cfg.buffId]
	pos = sender:getParent():convertToWorldSpace(pos)
	g_i3k_ui_mgr:CloseUI(eUIID_OtherBuffDrugTips)
	g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
	g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarExpTips)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionBlessingBufTips)
	g_i3k_ui_mgr:OpenUI(eUIID_TimeAndDescBuffTips)
	if not info.isShow then
		g_i3k_ui_mgr:RefreshUI(eUIID_TimeAndDescBuffTips, pos, buff.iconID, i3k_get_string(5769))
	else
		g_i3k_ui_mgr:RefreshUI(eUIID_TimeAndDescBuffTips, pos, buff.iconID, buff.note, cardInfo.card.inUse[info.id])
	end
end
function wnd_battleBase:onBuffDrugSelect(sender, buffType)
 	local isOther = false
 	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)

	g_i3k_ui_mgr:CloseUI(eUIID_TimeAndDescBuffTips)
	g_i3k_ui_mgr:CloseUI(eUIID_OtherBuffDrugTips)
	g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
	g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarExpTips)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionBlessingBufTips)
	g_i3k_ui_mgr:OpenUI(eUIID_BuffDrugTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuffDrugTips, isOther, pos, buffType)
end

--帮派祝福buf
function wnd_battleBase:onFactionBlessing(sender)
	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)

	if not g_i3k_ui_mgr:GetUI(eUIID_FactionBlessingBufTips) then
		g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
		g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarExpTips)
		g_i3k_ui_mgr:OpenUI(eUIID_FactionBlessingBufTips)
		g_i3k_ui_mgr:CloseUI(eUIID_TimeAndDescBuffTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionBlessingBufTips, pos)
	end
end
function wnd_battleBase:onDefenceWarExpSelect(sender)
	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)

	if not g_i3k_ui_mgr:GetUI(eUIID_DefenceWarExpTips) then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionBlessingBufTips)
		g_i3k_ui_mgr:CloseUI(eUIID_TimeAndDescBuffTips)
		g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
		g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarExpTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarExpTips, pos)
	end
end

function wnd_battleBase:updateVipBloodPool()
	local viphppool = g_i3k_game_context:GetVipBloodPool()
	local vipfilter = i3k_db_common.drug.vipfilter
	local maptype = i3k_game_get_map_type()
	local level = i3k_db_common.drug.boundToShowPoolLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	local barPercent = g_i3k_game_context:getVipBloodPercent(viphppool)
	self._layout.vars.bloodPoolImg:setImage(g_i3k_db.i3k_db_get_icon_path(1773))
	self._layout.vars.bloodPoolImg:setPercent(barPercent)
	self._layout.vars.hppoolbtn:setVisible( (roleLevel >= i3k_db_common.drug.boundToShowPoolLevel or viphppool > 0 ) and maptype ~= g_ARENA_SOLO )
	if maptype == g_FIELD then
		local mapId = g_i3k_game_context:GetWorldMapID()
		self._layout.vars.hppoolbtn:setVisible(i3k_db_field_map[mapId].showBloodPool == 1 and (roleLevel >= i3k_db_common.drug.boundToShowPoolLevel or viphppool > 0 ))
	end
	if maptype == g_DESERT_BATTLE then
		self._layout.vars.hppoolbtn:hide()
	end
	if maptype == g_SPY_STORY then
		self._layout.vars.hppoolbtn:hide()
	end
	if viphppool < vipfilter and viphppool ~= 0 then
		self._layout.anis.ss2.play(-1)--播放特效
	else
		self._layout.anis.ss2.stop()--停止特效
	end
	self:RecordDebugVarsNameSetVisible(self._layout.vars.hppoolbtn)
end
function wnd_battleBase:onUpdateCombatTypeCD(dTime)
	--准备部分
	local combatCD = g_i3k_db.i3k_db_get_CombatTypeCD()
	local endTime = g_i3k_game_context:GetCombatCoolEndTime()										--未来可点击时间
	local lastClickTime = endTime - combatCD
	local time = self._combatTypePoolTime ~= 0 and self._combatTypePoolTime or i3k_game_get_time() 	--回到当前开始计时时间
	local timer = time > lastClickTime and  time - lastClickTime or 0
	self._layout.vars.combatTypeCD:setVisible(not self.combatCanChange)
	if not self.combatCanChange and lastClickTime + timer + self.combatTypeTimeFlag < endTime then
		self.combatTypeTimeFlag = self.combatTypeTimeFlag + dTime 		--计时器累加时间
		local timeDiffer = timer + self.combatTypeTimeFlag
		local percent = (1 - timeDiffer / combatCD) * 100
		self._layout.vars.combatTypeCD:setPercent(percent)
	else 
		self.combatCanChange = true
		self.combatTypeTimeFlag = 0
		--特效播放
		if combatTypeEffectPlay then
			self._layout.anis.jnlqqs.play()
			combatTypeEffectPlay = false
		end
	end
end

function wnd_battleBase:onUpdateVipBloodPool(dTime)
	local lastUseHpPoolTime = g_i3k_game_context:GetUseHpPoolTime()
	local time = 0
	local vipCoolTime = 0
	if self._vipPoolTime ~= 0 then
		time = self._vipPoolTime
		vipCoolTime = self._vipCoolTime
	else
		time = i3k_game_get_time()
	end
	vipPoolTimeFlag = vipPoolTimeFlag + dTime;
	local timeDiffer = (time - lastUseHpPoolTime) + vipPoolTimeFlag
	local isShowCD = timeDiffer > 0 and timeDiffer < vipCoolTime
	self._layout.vars.bloodPoolCD:setVisible(isShowCD)
	if g_i3k_game_context:GetVipBloodPool() > 0 and i3k_game_get_map_type() ~= g_ARENA_SOLO and i3k_game_get_time() - lastUseHpPoolTime < vipCoolTime then
		vipPoolTimeCounter = vipPoolTimeCounter + dTime
		if vipPoolTimeCounter > 0.5 then
			vipPoolTimeCounter = 0
			local percent = (1 - timeDiffer / vipCoolTime) * 100
			local coolLeftTime = vipCoolTime - timeDiffer
			local progressAction = self._layout.vars.bloodPoolCD:createProgressAction(coolLeftTime, percent, 0)
			self._layout.vars.bloodPoolCD:runAction(progressAction)
		end
	else
		vipPoolTimeFlag = 0
	end
end

function wnd_battleBase:playVipBloodAnimation()
	self.c_lizifei.play()
end

-----------------监听器----------------------
function wnd_battleBase:onOpenRoom(sender)
	i3k_sbean.mroom_self()
end

function wnd_battleBase:onShowVipBloodTips(sender)
	local maptype = i3k_game_get_map_type()
	local fieldTypes = i3k_db_common.drug.poolShowMapID
	if fieldTypes[maptype] then
		if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3178))
		else
			g_i3k_logic:OpenBloodPoolUI()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1554))
	end
end

-- 头像按钮
function wnd_battleBase:onTouXiangClick(sender)
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD or mapType == g_FACTION_GARRISON or g_i3k_game_context:GetIsInHomeLandZone() then
		g_i3k_logic:OpenMainUI()
		DCEvent.onEvent("点击角色")
	elseif mapType == g_GOLD_COAST then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5750))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(262))
	end
	--if g_i3k_game_context:GetLevel() < i3k_db_server_limit.breakSealCfg.limitLevel then
	--	g_i3k_ui_mgr:PopupTipMessage("等级不足")
	--else
	 --   i3k_sbean.breakSeal_start()
	--end
end

-- 和平按钮
function wnd_battleBase:onPKbtnClick(sender)
	local worldType = i3k_game_get_map_type()
	if worldType == g_DEMON_HOLE or worldType == g_FACTION_WAR or worldType == g_MAZE_BATTLE then
		return
	end
	g_i3k_game_context:setUnlockSkillStatus(true)
	if worldType == g_FACTION_GARRISON then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16621))
	end
	local fieldPKType = i3k_game_get_field_map_pk_type()
	if fieldPKType then
		if fieldPKType == g_FIELD_SAFE_AREA then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(483))
			return;
		elseif fieldPKType == g_FIELD_KILL then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(485))
			return;
		end
	end
	if g_i3k_game_context:GetCurrentLine() == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(851))
		return
	end
	if worldType == g_GOLD_COAST then
		if g_i3k_game_context:getGoldCoastMapType() == g_GOLD_COAST_PEACE then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5605))
		else
			g_i3k_logic:OpenGoldCoastUI()
		end	
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_PKMode)
	g_i3k_ui_mgr:RefreshUI(eUIID_PKMode)
end

function wnd_battleBase:OpenChatUI(shouldTalk)
	local chatUI = g_i3k_ui_mgr:GetUI(eUIID_Chat)
	if chatUI then
		chatUI:reloadScroll()
		local rootVar = chatUI._layout.rootVar
		if rootVar then
			local width = rootVar:getContentSize().width
			local pos = rootVar:getPosition()
			local move = rootVar:createMoveTo(0.2, 0, pos.y)
			rootVar:runAction(move)
		end
	else
		local oldType = self.lastChatType
		if (shouldTalk and oldType == global_system) or oldType == global_recent or oldType == global_cross then
			oldType = global_world
		end
		g_i3k_logic:OpenChatUI(oldType)
	end
end

-- 聊天
function wnd_battleBase:chatCB(sender)
	self:OpenChatUI(true)
	-- g_i3k_game_context:enterPlayerLeadMap()
end

local Record_Start = false

function wnd_battleBase:checkSendVoice(deltaSec)
	-- g_i3k_ui_mgr:CloseUI(eUIID_Volume)
	-- self._layout.vars.vdeck:hide()
	-- if (deltaSec - 1) > 1 then
	-- 	g_i3k_game_handler:StopVoiceRecord(false)
	-- else
	-- 	g_i3k_game_handler:StopVoiceRecord(true)
	-- 	g_i3k_ui_mgr:PopupTipMessage("录音时间太短失败")
	-- end
	-- i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
end

function wnd_battleBase:openChatVoiceCB(sender, eventType)
	-- if not self:canSendMessage() then
	-- 	return
	-- end
	-- if eventType == ccui.TouchEventType.began then
	-- 	Click_Time = os.clock()
	-- 	Record_Start = false
	-- 	self._voiceToucePos = g_i3k_ui_mgr:GetMousePos()
	-- 	Record_timer.OnTest()
	-- elseif eventType == ccui.TouchEventType.ended then
	-- 	Record_timer.releaseTimer()
	-- 	local clock = os.clock()
	-- 	local delta = clock - Click_Time

	-- 	if delta > 0.001 and delta < 0.7 then
	-- 		local voice_deck = self._layout.vars.vdeck

	-- 		if voice_deck:isVisible() then
	-- 			voice_deck:hide()
	-- 		else
	-- 			voice_deck:show()
	-- 		end
	-- 	end

	-- 	if Record_Start then
	-- 		self:checkSendVoice(delta, clock)
	-- 	end
	-- elseif eventType == ccui.TouchEventType.canceled then
	-- 	Record_timer.releaseTimer()
	-- 	local currPos = g_i3k_ui_mgr:GetMousePos()
	-- 	local dist = currPos.y - self._voiceToucePos.y
	-- 	local height = self._layout.vars.toVoice:getSize().height*0.85

	-- 	g_i3k_ui_mgr:CloseUI(eUIID_Volume)
	-- 	self._layout.vars.vdeck:hide()
	-- 	if Record_Start then
	-- 		if dist > height then
	-- 			g_i3k_game_handler:StopVoiceRecord(true)
	-- 			g_i3k_ui_mgr:PopupTipMessage("取消录音成功")
	-- 			i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
	-- 		else
	-- 			local clock = os.clock()
	-- 			local delta = clock - Click_Time
	-- 			self:checkSendVoice(delta, clock)
	-- 		end
	-- 	end
	-- end
end

function wnd_battleBase:toChatVoiceCB(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self._layout.vars.vdeck:hide()
		local state = sender:getTag()
		if self._chatState ~= state then
			if state == global_sect then
				local sectId = g_i3k_game_context:GetSectId()
				if sectId <= 0 then
					local text = "您当前没有加入帮派，无法发言"
					g_i3k_ui_mgr:PopupTipMessage(text)
				else
					self._chatState = state
				end
			elseif state == global_battle then
				if not i3k_chat_state_BattleOrTeam() then
					local text = "您当前没有进入战场，无法发言"
					g_i3k_ui_mgr:PopupTipMessage(text)
				else
					self._chatState = state
				end
			elseif state == global_world then
				self._chatState = state
			end

			self._layout.vars.currChatImg:setImage(self.voiceStateImgs[self._chatState])
		end
	end
end

function wnd_battleBase:OpenChatCB(sender,eventType)
	local state = g_i3k_game_context:GetChatUIOpenState()
	if not state then
		local a,b = 1,2
		if eventType == ccui.TouchEventType.began then
			local pos_began = g_i3k_ui_mgr:GetMousePos()
			self.remTouchPos[a] = pos_began
		elseif eventType == ccui.TouchEventType.ended then
			local pos_end = g_i3k_ui_mgr:GetMousePos()
			table.insert(self.remTouchPos,pos_end)
			self.remTouchPos[b] = pos_end
		end
		local pos_began =  self.remTouchPos[a]
		local pos_end = self.remTouchPos[b]
		local scrollSize = self._layout.vars.chatLog:getSize().height
		if pos_began and pos_end then
			local distance = math.abs(pos_end.y - pos_began.y)
			if distance<= scrollSize/2 then
				self:OpenChatUI()
			end
			self.remTouchPos = {}
		end
	end
end

-- 普通攻击
function wnd_battleBase:onAttackClick(sender)
	local maptype = i3k_game_get_map_type()
	if maptype == g_CATCH_SPIRIT then
		local callback = function()
			g_i3k_game_context:checkCallSpirit()
		end
		local world = i3k_game_get_world()
		if world and world._syncRpc then
			g_i3k_game_context:UnRide(callback);
		else
			g_i3k_game_context:UnRideNotSyncRpc(callback)
		end
	else
	local hero = i3k_game_get_player_hero();
	if hero then
		if self:getFightStateUIIsShow() and not g_i3k_game_context:IsInMissionMode() and not g_i3k_game_context:IsInSuperMode() then
			hero:OnFightTime(0.01)
		elseif not hero:MaunalAttack(0) then
			if hero._AutoFight then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
				end
			end
		end
	end
end

function wnd_battleBase:changeRoleCombatType()
	if self.touchCombatFlag then
		if not self.combatCanChange then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1994))--"冷却中，无法切换姿态"
			self.touchCombatTime = 0
			return 
		end
		self.touchCombatTime = self.touchCombatTime + l_updateTime
		if self.touchCombatTime >= combatLongTouchTime then
			self.touchCombatFlag = false
			self:openCombatCD()
			local hero = i3k_game_get_player_hero()
			g_i3k_game_context:SetCombatType(g_BOXER_NORMAL)
			local time = i3k_game_get_time()
			local cd = g_i3k_db.i3k_db_get_CombatTypeCD()
			g_i3k_game_context:SetCombatCoolEndTime(time + cd)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1995, i3k_get_string(1996)))
			self:UpdateCombatBtnImg()
			i3k_sbean.sendChangeCombatType(hero:GetCombatType())
			self.touchCombatTime = 0
		end
	end
end
function wnd_battleBase:openCombatCD()
	self.combatCanChange = false --开启倒计时
	combatTypeEffectPlay = true
end
function wnd_battleBase:openPresetUI(typeNum,skillIndex)
	local maptype = i3k_game_get_map_type()
	if maptype == g_Life or maptype == g_PET_ACTIVITY_DUNGEON or maptype == g_CATCH_SPIRIT or maptype == g_BIOGIAPHY_CAREER then
		return
	end
	if self.touchSkillFlag and not g_i3k_game_context:isOnSprog() then
		self.touchSkillTime = self.touchSkillTime + l_updateTime
		if self.touchSkillTime >= l_touchTime then
			self.touchSkillFlag = false
			self.touchSkillTime = 0
			if g_i3k_game_context:GetTransformLvl() >= l_openPreset_translvl then
				if typeNum == g_PRESETTYPE_UNIQUE then
					local uniqueSkillsCfg = g_i3k_game_context:GetRoleUniqueSkills()
					local num = 0
					for _,_ in pairs(uniqueSkillsCfg) do
						num = num + 1
					end

					if num <= 1 then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(721)) --没有可以更换的绝技
						return
					end
				end
				local diySkillData = g_i3k_game_context:getDiySkillAndBorrowSkill()
				if not diySkillData then
					i3k_sbean.getDiySkillSync(nil, nil, g_SKILLPRE_DIY_FRESHTYPE_PRE,typeNum,skillIndex)
				else
					self:openSkillPreSet(typeNum,skillIndex)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(723,l_openPreset_translvl)) --%s转后开放技能快捷更换功能
			end
		end
	end
end

function wnd_battleBase:openSkillPreSet(typeNum,skillIndex)
	-- body
	if typeNum == g_PRESETTYPE_DIY then
		local diySkillData,borrowSkillData = g_i3k_game_context:getDiySkillAndBorrowSkill()
		if not borrowSkillData then
			if not diySkillData or #diySkillData <= 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(722)) --没有可以更换的自创武功
				return
			end
		else
			if not diySkillData or not next(diySkillData) then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(722)) --没有可以更换的自创武功
				return
			end
		end
	end

	g_i3k_ui_mgr:OpenUI(eUIID_SkillPreset)
	g_i3k_ui_mgr:RefreshUI(eUIID_SkillPreset, typeNum, skillIndex)
end

function wnd_battleBase:onAttackTouch(sender,eventType)
	-- body
	if eventType == ccui.TouchEventType.began then
		local maptype = i3k_game_get_map_type()
		if maptype == g_CATCH_SPIRIT then
			local callback = function()
				g_i3k_game_context:checkCallSpirit()
			end
			local world = i3k_game_get_world()
			if world and world._syncRpc then
				g_i3k_game_context:UnRide(callback);
			else
				g_i3k_game_context:UnRideNotSyncRpc(callback)
			end
		else
		self.touchSkillFlag = true
		local function upadate()
			--if self then
				--self:openPresetUI(g_PRESETTYPE_ATTACK)
				if i3k_game_get_map_type() ~= g_DESERT_BATTLE and i3k_game_get_map_type() ~= g_SPY_STORY then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openPresetUI",g_PRESETTYPE_ATTACK)
			end
			--end
		end
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
		end
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			local hero = i3k_game_get_player_hero();
			if hero then
				if self:getFightStateUIIsShow() and not g_i3k_game_context:IsInMissionMode() and not g_i3k_game_context:IsInSuperMode() then
					hero:OnFightTime(0.01)
				elseif not hero:MaunalAttack(0) then
					if hero._AutoFight then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
					end
				end
			end
			self.touchSkillFlag = false
			self.touchSkillTime = 0
		end
		self:releaseScheduler()
	end
end
--拳师姿态切换
function wnd_battleBase:onCombatTypeBtnTouch(sender, eventType)
	local hero = i3k_game_get_player_hero()
	if hero:IsOnHugMode() then
		return 
	end
	if i3k_game_get_map_type() == g_BIOGIAPHY_CAREER then
		local taskId = g_i3k_game_context:getBiographyTask()
		local careerId = g_i3k_game_context:getCurBiographyCareerId()
		if taskId > 0 and taskId < i3k_db_wzClassLand[careerId].changeStateTask then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18088))
		end
	else
		if g_i3k_game_context:GetTransformLvl() < 1 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1993))
		end
	end
	if eventType == ccui.TouchEventType.began then
		self.touchCombatFlag = true
		local function update()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "changeRoleCombatType")
		end
		self._scheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self:releaseScheduler()
		if self.touchCombatFlag then
			if not self.combatCanChange then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1994))
				self.touchCombatTime = 0
				return 
			end
			self:openCombatCD()
			local hero = i3k_game_get_player_hero()
			local cType = hero:GetCombatType()
			cType = cType == g_BOXER_DEFENCE and g_BOXER_ATTACK or cType + 1
			g_i3k_game_context:SetCombatType(cType)
			self:UpdateCombatBtnImg()
			local time = i3k_game_get_time()
			local cd = g_i3k_db.i3k_db_get_CombatTypeCD()
			g_i3k_game_context:SetCombatCoolEndTime(time + cd)
			if hero._combatType == g_BOXER_ATTACK then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1995, i3k_get_string(1997)))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1995, i3k_get_string(1998)))
			end
			i3k_sbean.sendChangeCombatType(hero:GetCombatType())
			self.touchCombatFlag = false
			self.touchCombatTime = 0
		end
	end
end
function wnd_battleBase:UpdateCombatBtnImg()
	local hero = i3k_game_get_player_hero()
	local combatType = hero:GetCombatType()
	local iconid = 9700							--平衡姿态
	if combatType == g_BOXER_ATTACK then 		--攻击姿态
		iconid = 9698
	elseif	combatType == g_BOXER_DEFENCE then  --防御姿态
		iconid = 9699
	end
	self.combatTypeBtn:setImage(g_i3k_db.i3k_db_get_icon_path(iconid))
end
function wnd_battleBase:CheckCombatTypeCD()
	local time = i3k_game_get_time()
	local endTime = g_i3k_game_context:GetCombatCoolEndTime()
	self.combatTypeChangeSwitch = endTime > time
end

function wnd_battleBase:releaseScheduler()
	-- body
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end

-- 解锁技能
function wnd_battleBase:onSkillUnlock(sender, needValue)
	local index = needValue.index
	local skillID = needValue.skillId
	g_i3k_game_context:CheakRoleSkillsUnlockAndUsed(skillID ,index)
end

function wnd_battleBase:useCommonSkill(sender, needValue)
	self:useSkill(needValue)
end

function wnd_battleBase:sendJoySkillTouchClick(index)
	local btn = self._widgets.commonSkill[index].rootBtn
	if not btn then
		return
	end
	if not btn:isVisible() then
		return
	end
	local skillId = btn:getTag()
	if skillId and type(skillId) == "number" and skillId > 0 then
		btn:sendTouchClick()
	end
end

function wnd_battleBase:useCommonSkillTouck(sender, eventType, i)

	local needValue = self._useCommonSkillTouck_needValue[i]
	if not needValue then
		return
	end

	if  needValue.useCommonSkill then
		if eventType == ccui.TouchEventType.ended then
		self:useCommonSkill(nil, needValue)
	end
	else
	if eventType == ccui.TouchEventType.began then
		self.touchSkillFlag = true
		local function upadate()
			--if self then
				--self:openPresetUI(g_PRESETTYPE_SKILL, needValue.index)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openPresetUI",g_PRESETTYPE_SKILL,needValue.index)
			--end
		end
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			self:useSkill(needValue)
			self.touchSkillFlag = false
			self.touchSkillTime = 0
		end
		self:releaseScheduler()
	end
end
end

function wnd_battleBase:useSkill(needValue)
	local index = needValue.index
	local hero = i3k_game_get_player_hero();
	if hero then
		if g_i3k_game_context:GetWorldMapType() == g_CATCH_SPIRIT then
			hero:UseGameInstanceSkill(needValue.skillId)
		else
		g_i3k_game_context:setUnlockSkillStatus(true)
		if not hero:MaunalAttack(index) then
			if hero._AutoFight then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
				end
			end
		end
	end
end

function wnd_battleBase:joyWeaponSkill()
	if self._widgets.skill.weapon.rootBtn:isVisible() then
		self:playWeaponSkill()
	end
end

function wnd_battleBase:playWeaponSkill()
	local widgets = self._widgets.skill.weapon
	local hero = i3k_game_get_player_hero()
	local world = i3k_game_get_world()
	if hero and world then
		local syncRpc = world._syncRpc; -- 是不是单机副本
		g_i3k_game_context:setUnlockSkillStatus(true)
		if not g_i3k_game_context:IsInSuperMode() then
			local isSpecial = self:isSpecialMode()
			if syncRpc  then
				if self:barPercentIsFull() or isSpecial then
					local func = function()
						if isSpecial then
							self._isPromptlyMode = false;
							i3k_sbean.motivate_weapon(promptlySuperMode)
						else
							i3k_sbean.motivate_weapon()
						end
					end
					g_i3k_game_context:UnRide(func, true)
				elseif self:openTongmingOrDongcha() then -- 地魔之眼
					if i3k_game_get_map_type() == g_FIELD then
				 		 g_i3k_ui_mgr:OpenUI(eUIID_ShenshiTongmin)
				 	else
				 		g_i3k_ui_mgr:PopupTipMessage("只能在大地图洞察或追仇")
				 	end
				end
			elseif self:barPercentIsFull() or isSpecial then
				local func = function()
					g_i3k_game_context:setPromptlyWead(true)
					self:stopWeaponFullAnis()
					hero:UpdateLastUseTime(g_i3k_game_context:GetTotalSuperTime());
					hero:SuperMode(true)
					widgets.sp:setPercent(0)
				end
				g_i3k_game_context:UnRideNotSyncRpc(func, true)
			end
		elseif self:openTongmingOrDongcha() then -- 地魔之眼
			if i3k_game_get_map_type() == g_FIELD then
		 		 g_i3k_ui_mgr:OpenUI(eUIID_ShenshiTongmin)
		 	else
		 		g_i3k_ui_mgr:PopupTipMessage("只能在大地图洞察或追仇")
		 	end
		end
	end
end

function wnd_battleBase:openSelectWeaponUI()
	self:releaseScheduler()
	if i3k_get_is_tournament_weapon() then--神器乱战
		return g_i3k_ui_mgr:PopupTipMessage("当前场景不可快速切换神兵")
	end
	if not g_i3k_game_context:haveShenbingCount() then
		return g_i3k_ui_mgr:PopupTipMessage("当前没有可切换的神兵")
	end
	self.touchSkillFlag = false
	g_i3k_ui_mgr:OpenUI(eUIID_selectWeapon)
	g_i3k_ui_mgr:RefreshUI(eUIID_selectWeapon)
end

-- 神兵
function wnd_battleBase:onStuntClick(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self.touchSkillFlag = true
		local function upadate()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openSelectWeaponUI")
		end
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			self:playWeaponSkill()
			self.touchSkillFlag = false
		end
		self:releaseScheduler()
	end
end

-- 武器祝福
function wnd_battleBase:onWeaponBlessClick(sender)
	local hero = i3k_game_get_player_hero()
	if hero then
		if hero:GetWeaponBlessState() == BLESS_STATE_MAX then
			self._layout.anis.c_cljnsf:stop()
			self._layout.anis.c_cljnsf.play()
			hero:ReleaseBlessSkill()
			hero:ShowInfo(hero, eEffectID_Dodge.style, i3k_get_string(17434))
		end
	end
end


function wnd_battleBase:isSpecialMode()
	local totalTime = g_i3k_game_context:GetTotalSuperTime()
	local hero = i3k_game_get_player_hero();
	if hero and not hero:IsDead() then
		if totalTime then
			if not self:barPercentIsFull() then
				if self._isPromptlyMode then
					return true;
				end
			end
		end
	end

	return false;
end

function wnd_battleBase:onUpdateWeapSkill(dTime)
	local totalTime = g_i3k_game_context:GetTotalSuperTime()
	if totalTime then
		local isCanSuper = g_i3k_game_context:isPromptlySuper();
		if isCanSuper and (not g_i3k_game_context:IsInSuperMode()) and (not self:barPercentIsFull()) then
			self._isPromptlyMode = true;
			self._widgets.skill.weapon.specialIcon:show();
		else
			self._isPromptlyMode = false;
			self._widgets.skill.weapon.specialIcon:hide();
		end
	else
		self._widgets.skill.weapon.specialIcon:hide();
	end
end

function wnd_battleBase:stopWeaponFullAnis()
	self._layout.anis.c_man.stop()
end

function wnd_battleBase:openTongmingOrDongcha()
	local info = i3k_db_shen_bing_unique_skill[g_i3k_game_context:GetSelectWeapon()] or {}
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(g_i3k_game_context:GetSelectWeapon())
	if isOpen and isOpen == 1 then
		for k,v in pairs(info) do
			if v.uniqueSkillType == 6 or v.uniqueSkillType == 7  then -- -- 开启洞察功能 开启追仇功能
				return true
			end
		end
	end
	return false
end

function wnd_battleBase:showWolfWeapon()
	local isShow = false
	local info = i3k_db_shen_bing_unique_skill[g_i3k_game_context:GetSelectWeapon()] or {}
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(g_i3k_game_context:GetSelectWeapon())
	if isOpen and isOpen == 1 then
		for k,v in pairs(info) do
			if v.uniqueSkillType == 16  then --是否有狼印特效
				isShow = true
				self:updateWolfWeapon()
			end
		end
	end
	self._layout.vars.wolfIcon:setVisible(isShow)
end

function wnd_battleBase:updateWolfWeapon()
	local wolfData = g_i3k_game_context:getWolfData()
	local percent = (wolfData.maxVal - wolfData.currVal) / wolfData.maxVal
	local index = 1
	for i = 1,5 do
		if percent >= (5-i)/5 then
			index = i
			break
		end
	end

	local iconId = 4360 + index
	if percent <= 0 then
		iconId = 4404
	end

	self._layout.vars.wolfIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end

function wnd_battleBase:barPercentIsFull()
	local curvalue , maxvalue = g_i3k_game_context:GetRoleWeaponErergy()
	local percent = curvalue/maxvalue*100
	if percent >= 100 then
		return true
	end
	return false
end

function wnd_battleBase:joyUseDodgeSkill( )
	if self._widgets.skill.dodge.rootBtn:isVisible() then
		self:useDodgeSkill()
	end
end

function wnd_battleBase:useDodgeSkill(sender)
	if self._enableDodgeSkill then
		local hero = i3k_game_get_player_hero();
		if g_i3k_game_context:IsAutoFight() then
			hero._autoUseDidge = true
			g_i3k_game_context:SetAutoFight(false)
		end
		if hero then
			if not hero:DodgeSkill() then
				if hero._AutoFight then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
				--else
					--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(121))
				end
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(120))
	end
end

function wnd_battleBase:useUniqueSkill()
	if self._enableUniqueSkill then
	local hero = i3k_game_get_player_hero();
		if hero then
			if not hero:UniqueSkill() then
				if hero._AutoFight then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
				--else
					--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(121))
				end
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(120))
	end
end

function wnd_battleBase:joyUseUniqueSkill()
	local _,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
	if not use_uniqueSkill or use_uniqueSkill <= 0 then
		return
	end
	local btn = self._widgets.skill.uniqueSkills.rootBtn
	if btn:isVisible() then
		self:useUniqueSkillTouch(btn, ccui.TouchEventType.began)
		self:useUniqueSkillTouch(btn, ccui.TouchEventType.ended)
	end
end

function wnd_battleBase:useUniqueSkillTouch(sender, eventType)
	-- body
	if eventType == ccui.TouchEventType.began then
		self.touchSkillFlag = true
		local function upadate()
			--if self then
				--self:openPresetUI(g_PRESETTYPE_UNIQUE)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openPresetUI",g_PRESETTYPE_UNIQUE)
			--end
		end
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			self:useUniqueSkill()
			self.touchSkillFlag = false
			self.touchSkillTime = 0
		end
		self:releaseScheduler()
	end
end

function wnd_battleBase:useDIYSkill()
	local hero = i3k_game_get_player_hero();
	if hero then
		if not hero:DIYSkill() then
			if hero._AutoFight then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
			--else
				--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(121))
			end
		end
	end
end

function wnd_battleBase:onDIYTouch(sender, eventType)
	-- body
	if eventType == ccui.TouchEventType.began then
		self.touchSkillFlag = true
		local function upadate()
			--if self then
				--self:openPresetUI(g_PRESETTYPE_DIY)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openPresetUI",g_PRESETTYPE_DIY)
			--end
		end
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			self:useDIYSkill()
			self.touchSkillFlag = false
			self.touchSkillTime = 0
		end
		self:releaseScheduler()
	end
end

--暗器技能
function wnd_battleBase:updataRoleAnqiSkill(skillinfo)
	local widgets = self._widgets.skill.anqi
	widgets.anisImage:hide()
	widgets.lockImage:hide()

	if skillinfo == nil then
		widgets.rootBtn:hide()
		return
	end

	local skillId = skillinfo.skillID
	local gradeId = skillinfo.level

	if skillId ~= 0 then
		local hero = i3k_game_get_player_hero()

		if hero and not hero._missionMode.valid then
			widgets.rootBtn:show()
		end
		-- widgets.rootBtn:onTouchEvent(self,self.onAnqitouch)
	else
		widgets.rootBtn:hide()
	end

	if gradeId then
		widgets.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[gradeId]))
	end

	if skillId then
		local anqiInfo = g_i3k_game_context:getHideWeaponInfo()
		local path = g_i3k_db.i3k_db_get_anqi_skin_skillId_by_skinID(anqiInfo.curWeapon, skillId)
		widgets.icon:setImage(path)
	end
end

function wnd_battleBase:onUpdateAnqikill()
	local widgets = self._widgets.skill.anqi
	local canUse = g_i3k_game_context:getAnqiSkillIsCanUse()

	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:getRoleAnqiSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime) / 1000)
		widgets.coolWord:setText(math.ceil(coolLeftTime))
		widgets.coolWord:show()
		widgets.cool:show()
		local percent = 100 * coolLeftTime /(totalTime / 1000)
		local progressAction = widgets.cool:createProgressAction(coolLeftTime, percent, 0)
		widgets.cool:runAction(progressAction)
		self._anqiSkillAnis = true
	else
		if self._anqiSkillAnis then
			widgets.anisImage:setOpacity(0)
			widgets.anisImage:show()
			self._layout.anis.jn5.play()
			self._anqiSkillAnis = false
		end

		widgets.cool:hide()
		widgets.coolWord:hide()
	end
end

function wnd_battleBase:useAnqiSkill()
	local hero = i3k_game_get_player_hero();

	if hero then
		local value = g_i3k_game_context:getAnqiSkillIsCanUse()

		if not value then
			return
		end

		if not hero:AnqiSkill() then
			if hero._AutoFight then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(114))
			end
		end
	end
end

function wnd_battleBase:openAnqiSelectUI()
	self:releaseScheduler()
	self.touchSkillFlag = false

	local anqiData = g_i3k_game_context:getHideWeaponSkills()

	if #anqiData == 1 then
		g_i3k_ui_mgr:PopupTipMessage("当前没有可切换的暗器")
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_AnqiSelect)
	g_i3k_ui_mgr:RefreshUI(eUIID_AnqiSelect)
end


function wnd_battleBase:onAnqitouch(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self.touchSkillFlag = true

		local function upadate()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "openAnqiSelectUI")
		end

		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(upadate, l_updateTime, false)
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		if self.touchSkillFlag then
			self:useAnqiSkill()
			self.touchSkillFlag = false
			self.touchSkillTime = 0
		end

		self:releaseScheduler()
	end
end
function wnd_battleBase:onUpdateWeaponManualkill()
	local widgets = self._widgets.skill.weaponManual
	local canUse = g_i3k_game_context:getWeaponManualSkillIsCanUse()
	if not canUse then
		local totalTime, hasCoolTime = g_i3k_game_context:getRoleWeaponManualSkillCoolLeftTime()
		local coolLeftTime = math.abs((totalTime - hasCoolTime) / 1000)
		widgets.coolWord:setText(math.ceil(coolLeftTime))
		widgets.coolWord:show()
		widgets.cool:show()
		local percent = 100 * coolLeftTime / (totalTime / 1000)
		local progressAction = widgets.cool:createProgressAction(coolLeftTime, percent, 0)
		widgets.cool:runAction(progressAction)
		self._WeaponManuaAnia = true
	else
		if self._WeaponManuaAnia then
			widgets.anisImage:setOpacity(0)
			widgets.anisImage:show()
			self._layout.anis.jnsb.play()
			widgets.cool:hide()
			widgets.coolWord:hide()
			self._WeaponManuaAnia = false
		end
	end
end
function wnd_battleBase:useWeaponMnualSkill()
	local hero = i3k_game_get_player_hero();
	if hero then
		local value = g_i3k_game_context:getWeaponManualSkillIsCanUse()
		if not value then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1611))
			return
		end
		if hero:useWeaponManualSkill() then
			local totalTime = g_i3k_game_context:getRoleWeaponManualSkillCoolLeftTime()		
			g_i3k_game_context:setWeaponSpecialCollTime(i3k_game_get_time() + math.ceil(totalTime / 1000))
		end
	end
end
function wnd_battleBase:showWeaponMnualSkillUI(weaponId, superMode)
	local weaponManual = self._widgets.skill.weaponManual
	local parms = g_i3k_db.i3k_db_get_weapon_isHava_manualSkill(weaponId)
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(weaponId)
	if superMode and parms and isOpen == 1 then
		weaponManual.lockImage:hide()
		weaponManual.gradeImage:setImage(g_i3k_db.i3k_db_get_icon_path(3546))
		local path = g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[parms[1]].icon)
		weaponManual.icon:setImage(path)
		weaponManual.rootBtn:show()
		weaponManual.anisImage:hide()
		local canUse = g_i3k_game_context:getWeaponManualSkillIsCanUse()
		if not canUse then
			weaponManual.coolWord:show()
			weaponManual.cool:show()
		else
			weaponManual.cool:hide()
			weaponManual.coolWord:hide()
		end		
	else
		weaponManual.rootBtn:hide()
	end	
end

-- 技能道具
function wnd_battleBase:onSkillItem(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BattleSkillItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleSkillItem)
end


function wnd_battleBase:onAutoFightClick(sender)
	local mapType = i3k_game_get_map_type()
	if mapType == g_DOOR_XIULIAN then
		if g_i3k_ui_mgr:GetUI(eUIID_ArenaSwallow) or g_i3k_ui_mgr:GetUI(eUIID_BattleReadFight) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(140))
			return
		end
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		local auto = not hero:IsAutoFight()
		g_i3k_game_context:SetAutoFight(auto)
		g_i3k_game_context:setUnlockSkillStatus(auto)
	end
end

function wnd_battleBase:updateOnRideTime(dTime)
	if i3k_game_get_time() - self._recordTime >  RideSpace then
		self._recordTime = 0
	end
end

function wnd_battleBase:onRideClick(sender)
	if self._recordTime ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage("操作过于频繁")
		return
	end
	local hero = i3k_game_get_player_hero()
	if hero:IsMulMemberState() then
		i3k_sbean.mulhorse_leave_requst()
		return
	end
	if g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17031))
		return
	end
	local ride = not hero:IsOnRide()
	local world = i3k_game_get_world()
	if world then
		if not world._syncRpc then
			if ride then
				if hero:CanRide() then
					hero:OnRideMode(ride)
				end
			else
				hero:OnRideMode(ride)
			end
		else
			hero:SetRide(ride)
		end
	end
	if not ride then
		self._recordTime = i3k_game_get_time()
	end
end

function wnd_battleBase:onKickClick(sender)
	local parent = sender:getParent()
	local pos = sender:getPosition()
	local width = sender:getContentSize().width
	pos = parent:convertToWorldSpace(cc.p(pos.x - width/2, pos.y))
	g_i3k_ui_mgr:OpenUI(eUIID_KickMember)
	g_i3k_ui_mgr:RefreshUI(eUIID_KickMember, pos)
end

function wnd_battleBase:onHugClick(sender)
	local isOnHug = g_i3k_game_context:IsOnHugMode()
	if isOnHug then
		self.hugBtn:stateToNormal()
	else
		self.hugBtn:stateToPressed()
	end
	if isOnHug then
		i3k_sbean.staywith_leave()
	else
		g_i3k_ui_mgr:PopupTipMessage("邀请其他人进行相依相偎")
	end
end

function wnd_battleBase:onKissBtn(sender)
	local isOnHug = g_i3k_game_context:IsOnHugMode()
	if isOnHug then
		self.kissBtn:stateToNormal()
	else
		self.kissBtn:stateToPressed()
	end
	if isOnHug then
		i3k_sbean.staywith_memeda()
	end
end

--使用幻形
function wnd_battleBase:onMetamorphosisBtn(sender)
	local isMetamorphosis = g_i3k_game_context:GetMetamorphosisState()
	if isMetamorphosis == 1 then
		i3k_sbean.metamorphosis_use(0)
	else
		local func = function()
			i3k_sbean.metamorphosis_use(1)
			end
		g_i3k_game_context:UnRide(func, true)
	end
end
function wnd_battleBase:updateHugbtnState()
	local isOnHug = g_i3k_game_context:IsOnHugMode()
	local isHomelandOverViewStatus= g_i3k_game_context:getHomelandOverViewStatus()
	if isHomelandOverViewStatus then isOnHug = false end
	self.hugBtn:setVisible(isOnHug);
	self.kissBtn:setVisible(isOnHug);
end

function wnd_battleBase:onTestClick(sender)
	g_i3k_ui_mgr:PopupTipMessage(g_i3k_game_handler:GetRenderState());
end

function wnd_battleBase:onTaskBtn()
	if i3k_game_get_map_type() == g_FIELD then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleBoss)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_logic:OpenBattleTaskUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(437))
	end
end

--世界boss输出数据
function wnd_battleBase:updateBossDamage(isShow)
	if isShow and self.firstShowBossDamage then
		self:onBossBtn()
		self.firstShowBossDamage = false
	end
	g_i3k_game_context:ShowBossDamageBtn(isShow)
end

function wnd_battleBase:onBossBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	g_i3k_ui_mgr:CloseUI(eUIID_SpiritSkill)	
	g_i3k_ui_mgr:CloseUI(eUIID_DemonHolesummary)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSummary)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonSpirit)

	g_i3k_ui_mgr:OpenUI(eUIID_BattleBoss)
	--g_i3k_ui_mgr:RefreshUI(eUIID_BattleBoss)
end

function wnd_battleBase:updateRoomData()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateRoomData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "updateRoomData")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBoss, "updateRoomData")
end
function wnd_battleBase:onOpenRoom(sender, roomType)
	if roomType==gRoom_Dungeon then
		i3k_sbean.mroom_self()
	else
		g_i3k_ui_mgr:OpenUI(eUIID_TournamentRoom)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "aboutMyRoom", g_i3k_game_context:getTournameRoomLeader(), g_i3k_game_context:getTournameMemberProfiles())
	end
end

function wnd_battleBase:updateTournament()
	local world = i3k_game_get_world()
	if world then
		local tType = g_i3k_db.i3k_db_get_tournament_type(world._cfg.id)
		if tType == g_TOURNAMENT_4V4 then--4v4场景
			g_i3k_ui_mgr:OpenUI(eUIID_Battle4v4)
		elseif tType == g_TOURNAMENT_2V2 then--2v2场景
			g_i3k_ui_mgr:OpenUI(eUIID_Battle2v2)
		elseif tType == g_TOURNAMENT_CHUHAN then --楚汉之争
			g_i3k_ui_mgr:OpenUI(eUIID_Battle4v4)
		end
	end
end

function wnd_battleBase:onRoleLifeChanged(count)
	self._widgets.role.lifeCount = self._widgets.role.lifeCount - 1
	self:updateRoleLife()
end

function wnd_battleBase:updateRoleLife(lifeCount)
	if lifeCount then
		self._widgets.role.lifeCount = lifeCount
	end
	local mapType = i3k_game_get_map_type()
	for i,v in ipairs(self._widgets.role.life) do
		v:setVisible(mapType==g_TOURNAMENT)
		local count = self._widgets.role.lifeCount
		v:setVisible(i<=count)
	end
end

--左侧任务、组队、房间的显隐
function wnd_battleBase:updateLeftUI(isShow)
	if isShow then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "showBuffdRoot")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "showBuffdRoot")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBoss, "showBuffdRoot")
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "hideBuffdRoot")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTeam, "hideBuffdRoot")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBoss, "hideBuffdRoot")
	end
end

function wnd_battleBase:playTaskFinishEffect()
	g_i3k_ui_mgr:OpenUI(eUIID_BattleTXFinishTask)
end
---------------------------------------------
Record_timer.timerId = -1
function Record_timer:Do(args)
	Record_timer.releaseTimer()
	if i3k_game_set_voice_state(g_VOICE_RECORDING_VOICE_MSG) then
		local startResult = g_i3k_game_handler:StartVoiceRecord()
		if startResult ~= false then --旧版本的引擎是nil，所以只能这么判断了
			Record_Start = true
			g_i3k_ui_mgr:OpenUI(eUIID_Volume)
			g_i3k_ui_mgr:RefreshUI(eUIID_Volume)
		else
			i3k_game_cancel_voice_state(g_VOICE_RECORDING_VOICE_MSG)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3058))
	end
end

function Record_timer.OnTest()
	local logic = i3k_game_get_logic()
	if logic then
		Record_timer.timerId = logic:RegisterTimer(Record_timer.new(700));
	end
end

function Record_timer.releaseTimer()
	local logic = i3k_game_get_logic();
	if logic and Record_timer.timerId > 0 then
		logic:UnregisterTimer(Record_timer.timerId);
		Record_timer.timerId = -1
	end
end
---------------------------------------------
--运营拍照用
function wnd_battleBase:onlyShowSkillItem()
	local widget = self._layout.vars
	widget.chatView:hide() -- 聊天框
	widget.toChat:hide() -- 聊天按钮
	widget.tabBtn:show() -- 切换目标
	widget.ridebtn:hide() -- 骑乘
	widget.autoFight:hide() -- 托管
	widget.weapon:hide() -- 神兵
	widget.skillItem:hide() -- 技能道具
	widget.gundong2:hide() -- 绝技
	widget.DIYSkill:hide() -- 自创武功
	widget.anqiBtn:hide()  -- 暗器技能
	widget.duizhang1:hide() --队长标识
	widget.pkbtnroot:hide() -- 和平按钮
	widget.weaponBlessRoot:hide() --武器祝福按钮
	widget.lock1:hide()
	widget.lock2:hide()
	widget.lock3:hide()
	widget.lock4:hide()
	widget.about_touxiang:hide()
	widget.hppoolbtn:hide()

	widget.gundong:show()  -- 轻功
	widget.attack:show()
	widget.attackBg:show()

	self:updateAllSkills()
end

function wnd_battleBase:RecordDebugVarsNameSetVisible(varName)
	local recordDebug = g_i3k_game_context:GetRecoardDebug()
	if recordDebug then
		varName:hide()
	end
end

function wnd_battleBase:onUpdateMarryReserve(dTime)
	if g_i3k_game_context:GetNowCanMarry() then
		if not self.isReservePlay then
			self._layout.anis.c_hl.play()
		end
		self.isReservePlay = true
	else
		self._layout.anis.c_hl.stop()
	end
end

-- InvokeUIFunction
function wnd_battleBase:updateFishPrompt(ani)
	if ani then
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandFishPrompt)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandFishPrompt)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandFishPrompt)
	end
end

function wnd_battleBase:onMarryReserveCue(sender)
	if g_i3k_game_context:GetNowCanMarry() then
		i3k_sbean.sync_marriage_bespeak()
	end
end

--负面状态显示
function wnd_battleBase:onUpdateDeBuffUI ()
	local hero = i3k_game_get_player_hero()
	if hero then
		local scroll = self._layout.vars.buffInfo
		--添加
		for buffId, buff in pairs(hero._buffs) do
			local buffConfig = buff._cfg

			local isNeedShow = buffConfig.specialIcon ~= 0
			local isHaveShow = false

			for _ ,v in ipairs(scroll:getAllChildren()) do
				if v.iconId == buffConfig.specialIcon then
					isHaveShow = true
				end
			end

			if isNeedShow and not isHaveShow then
				local _item = require("ui/widgets/bufft2")()
				_item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(buffConfig.specialIcon, false))
				_item.iconId = buffConfig.specialIcon
				scroll:addItem(_item)
			end
		end
		--移除
		local isNeedRemove = function  (iconId)
			for buffId, buff in pairs(hero._buffs) do
				if buff._cfg.specialIcon == iconId then
					return false
				end
			end
			return true
		end
		for k ,v in ipairs(scroll:getAllChildren()) do
			if isNeedRemove(v.iconId) then
				scroll:removeChild(v.root)
				table.remove(scroll.child, k)
				scroll:update()
			end
		end
	end
end

-- 根据边框id设置相关图片，头像底框，刀意图标，刀意底框
function wnd_battleBase:loadHeadFrameInfo(frameId)
	local cfg = g_i3k_db.i3k_get_head_cfg_form_frameId(frameId)
	if cfg then
		local headFrameIconID = cfg.headBgIcon
		self._layout.vars.headFrame:setImage(g_i3k_db.i3k_db_get_icon_path(headFrameIconID))
		for _, e in pairs(self._widgets.role.fightsp_bg) do
			e:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.powerFrame))
		end
		for _, e in pairs(self._widgets.role.fightsp) do
			e:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.powerIcon))
		end
	end
end

function wnd_battleBase:updateHomeLandHouse()
	if g_i3k_game_context:GetIsInHomeLandHouse() then
		local vars = self._layout.vars;
		vars.weapon:setVisible(false)
		vars.attackBg:setVisible(false)
		vars.skillNodes:setVisible(false)
		vars.tabBtn:setVisible(false)
		vars.gundong:setVisible(false)
		vars.autoFight:setVisible(false)
		vars.ridebtn:setVisible(false)
		vars.combatTypeBtn:setVisible(false)
		self._layout.vars.about_touxiang:hide()
		self._layout.vars.hppoolbtn:hide()
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
		g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
	end
end

function wnd_battleBase:setChatVisible(value)
	local widget = self._layout.vars	
	 -- 聊天框
	widget.chatView:setVisible(value)
	-- 聊天按钮
	widget.toChat:setVisible(value) 
end

function wnd_battleBase:updatePetDungeon()
	if i3k_game_get_map_type() == g_PET_ACTIVITY_DUNGEON then
		local info = g_i3k_game_context:getOnePetData(g_i3k_game_context:getPetDungeonID())
		
		if info then
			self._widgets.role.levelLabel:setText(info.level)
		end
		
		self.ridebtn:hide()
		self._widgets.skill.dodge.rootBtn:hide()
		self.kickBtn:hide()
		self._widgets.skill.uniqueSkills.rootBtn:hide()
		self._widgets.skill.diySkill.rootBtn:hide()
		self._widgets.skill.anqi.rootBtn:hide()
		self._widgets.skill.dodge.rootBtn:hide()
		self._widgets.skill.skillItem:hide()
		self._layout.vars.weapon:hide()
		self:SetWeaponBlessBtnVisible(false)
		self:updateLeftUI(false)		
		g_i3k_ui_mgr:OpenUI(eUIID_PetDungeonBattleBase)
		g_i3k_ui_mgr:RefreshUI(eUIID_PetDungeonBattleBase)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)	
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
	end
end

--更新荒漠副本
function wnd_battleBase:updateDesertBattleDungeon()
	if i3k_game_get_map_type() == g_DESERT_BATTLE then
		--TODO
		local widgets = self._layout.vars
		widgets.DIYSkill:hide()
		widgets.gundong2:hide()
		widgets.anqiBtn:hide()
		widgets.skillItem:hide()
		widgets.weaponBlessRoot:hide()
		widgets.weapon:hide()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	end
end
--决战荒漠观战UI刷新
function wnd_battleBase:updateDesertBattleWatchWar()
	if i3k_game_get_map_type() == g_DESERT_BATTLE then
		local widget = self._layout.vars
		widget.chatView:setVisible(false)
		widget.toChat:setVisible(false)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleFuben)		
		g_i3k_ui_mgr:CloseUI(eUIID_OnlineVoice)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleFubenDesert)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
	end
end
--更新密探风云副本
function wnd_battleBase:updateSpyStoryDungeon()
	if i3k_game_get_map_type() == g_SPY_STORY then
		--TODO
		local widgets = self._layout.vars
		widgets.DIYSkill:hide()
		widgets.gundong2:hide()
		widgets.anqiBtn:hide()
		widgets.skillItem:hide()
		widgets.weaponBlessRoot:hide()
		widgets.weapon:hide()
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	end
end
function wnd_battleBase:updateMazeBattleUI()
	if i3k_game_get_map_type() == g_MAZE_BATTLE then
		g_i3k_logic:OpneMazeBattleInfoUI()
		self._widgets.role.pkBtn:setVisible(true)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
	end
end
function wnd_battleBase:onEndMission(sender)
	local data = i3k_sbean.survive_quit_alter.new()
	i3k_game_send_str_cmd(data)
end
function wnd_battleBase:onUpdateEndMission(dTime)
	local missionMode, missionType = g_i3k_game_context:IsInMissionMode()
	if missionMode and missionType == g_TASK_TRANSFORM_STATE_SKULL then
		local endTime = g_i3k_game_context:GetMissionEndTime()
		local leftTime = endTime - i3k_game_get_time()
		if leftTime > 0 then
			self._layout.vars.endMissionTime:setText(leftTime.. "s")
		end
	end
end
function wnd_battleBase:updateAtAnyMoment()
	if i3k_game_get_map_type() == g_AT_ANY_MOMENT_DUNGEON then
		self._layout.vars.hppoolbtn:hide()
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFuben)
	end
end
function wnd_battleBase:updatePrincessMarryUI()
	if i3k_game_get_map_type() == g_PRINCESS_MARRY then
		g_i3k_logic:OpenPrincessMarry()
		self._widgets.role.pkBtn:setVisible(false)
		--self.ridebtn:setVisible(true)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryAddScore)
	end
end
function wnd_battleBase:updateLongevityPavilionUI()
	if i3k_game_get_map_type() == g_LONGEVITY_PAVILION then	
		self._widgets.role.pkBtn:setVisible(false)
		self:showGundongBtn(false)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
		--self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		g_i3k_logic:OpenLongevityPavilionUI()
		--g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		--self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())	
		end
	end

function wnd_battleBase:updateMagicMachineUI()
	if i3k_game_get_map_type() == g_MAGIC_MACHINE then	
		self._widgets.role.pkBtn:setVisible(false)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())
		g_i3k_logic:OpenMagicMachineUI()
		--g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		--self:updateCoordInfo(g_i3k_game_context:GetPlayerPos())	
	end
end
function wnd_battleBase:updateGoldCoastUI()
	if i3k_game_get_map_type() ==  g_GOLD_COAST then	
		self._widgets.role.pkBtn:setVisible(true)	
	end
end
function wnd_battleBase:addSwordsmanExp(exp)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwordsmanExpProp, exp)
end
function wnd_battleBase:updateSuperOnHookUI()
	if g_i3k_game_context:GetSuperOnHookValid() then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_SuperOnHook)
	end
end
function wnd_battleBase:updateCatchSpiritUI()
	if i3k_game_get_map_type() == g_CATCH_SPIRIT then
		local widgets = self._layout.vars
		widgets.DIYSkill:hide()
		widgets.gundong2:hide()
		widgets.anqiBtn:hide()
		widgets.skillItem:hide()
		widgets.weaponBlessRoot:hide()
		widgets.weapon:hide()
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEntrance)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleOfflineExp)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDrug)
		g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleUnlockSkill)
		g_i3k_ui_mgr:CloseUI(eUIID_TripWizardPhotoBtn)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritTask)
		g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritBag)
		g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritBag)
		self:updateCatchSpiritEffect()
	end
end
function wnd_battleBase:updateBiographyCareerUI()
	if i3k_game_get_map_type() == g_BIOGIAPHY_CAREER then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFuben)
		g_i3k_ui_mgr:OpenUI(eUIID_BiographyTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_BiographyTask)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleMiniMap)
		local widgets = self._layout.vars
		widgets.weaponBlessRoot:hide()
		self.ridebtn:hide()
		self.kickBtn:hide()
		self._widgets.skill.weapon.rootBtn:hide()
		self._widgets.skill.uniqueSkills.rootBtn:hide()
		self._widgets.skill.diySkill.rootBtn:hide()
		self._widgets.skill.anqi.rootBtn:hide()
		self._widgets.skill.dodge.rootBtn:show()
		self._widgets.skill.skillItem:hide()
	end
end
function wnd_battleBase:onHide()
	self:releaseScheduler()
	Record_timer.releaseTimer()
end

function wnd_battleBase:updateInviteEntranceState(force)
	local list = g_i3k_game_context:getInviteList()
	local mapType = i3k_game_get_map_type()
	if #list > 0 and force ~= false and (mapType == g_FIELD or mapType == g_FACTION_TEAM_DUNGEON or mapType == g_FACTION_GARRISON) then
		g_i3k_ui_mgr:OpenUI(eUIID_InviteEntrance)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_InviteEntrance)
	end
end
function wnd_battleBase:updateCatchSpiritEffect()
	local hero = i3k_game_get_player_hero()
	if hero and hero:GetAreaType() == g_CATCH_SPIRIT_AREA then
		self._layout.anis.c_pgdtx.play()
	else
		self._layout.anis.c_pgdtx.stop()
	end
end
function wnd_battleBase:spyStoryAreaTips()
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18671))
end
-----------------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleBase.new();
		wnd:create(layout);
	return wnd;
end
