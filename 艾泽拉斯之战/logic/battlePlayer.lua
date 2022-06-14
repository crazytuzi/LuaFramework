
	SERVER_ACTION_TYPE =
	{
		INVALID		= -1,		
		ACTION		= 0,		--当前行动者，便于UI识别
		MOVE		= 1,		--移动
		ATTACK		= 2,		--攻击
		RETALIATE	= 3,		--反击
		LOCK		= 4,		--锁定
		DEAD		= 5,		--死亡
		SKILL		= 6,		--技能
		MAGIC		= 7,		--魔法
		BUFF		= 8,		--buff
		SUMMON		= 9,		--召唤
		DAMAGE		= 10,		--伤害
		CURE		= 11,		--治疗
		ATTRIBUTE   = 12,       --属性变化
		REVIVE      = 13,		--复活				
		MAGIC_OVER  = 14,
		BATTLE_OVER = 99,		--战斗结束
	}
	
	
  ACTION_TYPE = {
	INVLID = -SERVER_ACTION_TYPE.INVALID,	
	ACTIONUNITINDEX = SERVER_ACTION_TYPE.ACTION, -- 当前回合的行动军团id
	MOVE = SERVER_ACTION_TYPE.MOVE,
	ATTACK = SERVER_ACTION_TYPE.ATTACK,
	BEATBACK =  SERVER_ACTION_TYPE.RETALIATE, --反击
	LOCK = SERVER_ACTION_TYPE.LOCK,
	DEAD = SERVER_ACTION_TYPE.DEAD,	

----------------------------------------------
	SKILLDAMAGE = 4000,--群体伤害技能
	SKILLATTRIBUTE =5000,  --加属性
	SKILLADDBUFF =6000,  --buffer九 零 一 起 玩 ww w .9 0 1 7 5. com
-------------------------------------------------	
	SKILL		= SERVER_ACTION_TYPE.SKILL,		--技能
	MAGIC		= SERVER_ACTION_TYPE.MAGIC,		--魔法	
	SUMMON		= SERVER_ACTION_TYPE.SUMMON,	--召唤	
	
	ATTRIBUTE = SERVER_ACTION_TYPE.ATTRIBUTE,   --属性变化
	
	REVIVE     = SERVER_ACTION_TYPE.REVIVE,	    --复活	
	MAGIC_OVER =  SERVER_ACTION_TYPE.MAGIC_OVER, 	
	ENDFLAG    =  SERVER_ACTION_TYPE.BATTLE_OVER, --战斗结束
 
		
 	HANDLE_BUFF = 7000,	
	DELETE_BUFF = 8000,		
}


local  BATTLESTATE = {
	BS_BEGIN = 1,
	BS_BATTLE = 2,
	BS_END = 3,	
	BS_LEAVE = 4,	
	BS_BEFORE_DIALOGUE = 5,
	BS_AFTER_DIALOGUE = 6,	
}

actionSys = {}
actionSys.allAction = {}
actionSys._CLASS = {}
function actionSys.RegisterActClass(class,_type)
		actionSys._CLASS[_type]  = class
end	
function actionSys.getActionClass(_type)
		return actionSys._CLASS[_type]	
end	

function actionSys.createAction(action)

	local class = actionSys.getActionClass(action._type)
	if not class then
		print("createAction failed type:  "..action._type);
	end	
	local actInsatnce = class.new(action)		
	table.insert(actionSys.allAction,actInsatnce)
	actionSys.beginTime  = nil
	
	return actInsatnce
end
---指令表现完毕
actionSys.curAc = nil
function actionSys.Tick(t)
		if(actionSys.curAc)then
			local maybeTimeout = false
			actionSys.beginTime = actionSys.beginTime or  dataManager.getServerTime() 
			if(dataManager.getServerTime() - actionSys.beginTime  >=  2 * CHECK_LOCK_TIME)then
				maybeTimeout  = true
			end
				
			  local res = actionSys.curAc:Tick(t)
			  if(res == true)then
				---print("actionSys.curAc._action._type   over .."..actionSys.curAc._action._type)		
				
					if(battlePlayer.rePlayStatus == true) then 
						if(ACTION_TYPE.MAGIC_OVER == actionSys.curAc._action._type )then
							battlePlayer.magicOverNum =  battlePlayer.magicOverNum or 0
							battlePlayer.magicOverNum = battlePlayer.magicOverNum + 1
							if( battlePlayer.magicOverNum == 2)then
								eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_UNIT});
								battlePlayer.magicOverNum  = 0
							end		
						end
					end					
				actionSys.curAc = nil
			  end	
			
			if(maybeTimeout and  res == false )then
				res = true
				actionSys.curAc = nil
			end
			
			return res
		end	
			
	
		
		return true	
end		

function actionSys.Destroy()
	actionSys.curAc = nil	
end	
	
function actionSys.Play(action)
	local actInsatnce = actionSys.createAction(action)		
	actionSys.curAc = actInsatnce
	actionSys.curAc:play()	
	return 	actionSys.curAc 
end

local actionCmdClass = class("actionCmdClass")
function actionCmdClass:ctor()
	 _id = -1	
	 _type = ACTION_TYPE.INVLID
	 _param = nil	
	 round = -1
end	

local actionCmdBase = class("actionCmdBase")
function actionCmdBase:ctor(action)
	 self._action = action	
	 self._payer = sceneManager.battlePlayer()
end		

function actionCmdBase:enterStart()	
end
function actionCmdBase:enterProcess()
end	
function actionCmdBase:enterEnd()
end
function actionCmdBase:play()
	self:enterStart()	
end
function actionCmdBase:Tick(dt)
	return true
end
 

local actionCmd_MOVE = class("actionCmd_MOVE",actionCmdBase) -- 移动
function actionCmd_MOVE:ctor(action)
	actionCmd_MOVE.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_MOVE,ACTION_TYPE.MOVE)
function actionCmd_MOVE:enterStart()	
		 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._id]						
			self._payer.m_CurrentCrops.m_Targets = {}
			self._payer.m_CurrentCrops.m_TargetsDamage = {}	
			self._payer:_playMove(self._action)		
			self._payer:signGrid(self._payer.m_CurrentCrops.m_PosX,self._payer.m_CurrentCrops.m_PosY,"b")		
end		
function actionCmd_MOVE:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt) == true		
end
 

local actionCmd_ATTACK = class("actionCmd_ATTACK",actionCmdBase) --攻击
function actionCmd_ATTACK:ctor(action)
	actionCmd_ATTACK.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_ATTACK,ACTION_TYPE.ATTACK)

function actionCmd_ATTACK:enterStart()	
		 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._id]						
			self._payer.m_CurrentCrops.m_Targets = {}
			self._payer.m_CurrentCrops.m_TargetsDamage = {}	
			self._payer:_playAttack(self._action)	
			self._payer:signGrid(self._payer.m_CurrentCrops.m_PosX,self._payer.m_CurrentCrops.m_PosY,"b")		
end		
function actionCmd_ATTACK:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt) == true and ___targertHurtEnd(self._payer.m_CurrentCrops)	
end

local actionCmd_BEATBACK = class("actionCmd_BEATBACK",actionCmdBase)--反击
function actionCmd_BEATBACK:ctor(action)
	actionCmd_BEATBACK.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_BEATBACK,ACTION_TYPE.BEATBACK) 

function actionCmd_BEATBACK:enterStart()	
		 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._id]						
			self._payer.m_CurrentCrops.m_Targets = {}
			self._payer.m_CurrentCrops.m_TargetsDamage = {}	
			self._payer:_playAttackBack(self._action)	
			self._payer:signGrid(self._payer.m_CurrentCrops.m_PosX,self._payer.m_CurrentCrops.m_PosY,"b")			
end		
function actionCmd_BEATBACK:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt) == true and ___targertHurtEnd(self._payer.m_CurrentCrops)		
end	
local actionCmd_LOCK = class("actionCmd_LOCK",actionCmdBase) --LOCK
function actionCmd_LOCK:ctor(action)
	actionCmd_LOCK.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_LOCK,ACTION_TYPE.LOCK) 
function actionCmd_LOCK:enterStart()	
		 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._id]						
			self._payer.m_CurrentCrops.m_Targets = {}
			self._payer.m_CurrentCrops.m_TargetsDamage = {}	
			self._payer:_playLock(self._action)		
			self._payer:signGrid(self._payer.m_CurrentCrops.m_PosX,self._payer.m_CurrentCrops.m_PosY,"b")		
end		
function actionCmd_LOCK:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt) == true		
end
 
local actionCmd_DEAD = class("actionCmd_DEAD",actionCmdBase) --DEAD
function actionCmd_DEAD:ctor(action)
	actionCmd_DEAD.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_DEAD,ACTION_TYPE.DEAD)


function actionCmd_DEAD:enterStart()
		 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._id]						
			self._payer.m_CurrentCrops.m_Targets = {}
			self._payer.m_CurrentCrops.m_TargetsDamage = {}	
			self._payer:_playDead(self._action)		
end		
function actionCmd_DEAD:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt)	
end


local actionCmd_ACTIONUNITINDEX = class("actionCmd_ACTIONUNITINDEX",actionCmdBase) --ACTIONUNITINDEX
function actionCmd_ACTIONUNITINDEX:ctor(action)
	actionCmd_ACTIONUNITINDEX.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_ACTIONUNITINDEX,ACTION_TYPE.ACTIONUNITINDEX) 
 

function actionCmd_ACTIONUNITINDEX:enterStart()	
		sceneManager.battlePlayer().magicCasterRoundNum  = sceneManager.battlePlayer().ConstLastRoundNum - self._action.round					
		local uiupdate = false;
		
		if sceneManager.battlePlayer().magicOverFlag == true then
			-- 魔法回合结束，开始播放军团
			-- oppsite force
			sceneManager.battlePlayer().nextMagicRoundTurnForce = global.oppsiteForce(sceneManager.battlePlayer().nextMagicRoundTurnForce);
			
			sceneManager.battlePlayer().nextMagicRound = sceneManager.battlePlayer():getMagicRound();
			sceneManager.battlePlayer().magicOverFlag = false;
			
			uiupdate = sceneManager.battlePlayer():calcAllActionOrder(false);
		--else
			--uiupdate = sceneManager.battlePlayer():calcAllActionOrder(true);
		end
		
		uiupdate = sceneManager.battlePlayer():calcAllActionOrder(true);
		if self._action._id ~= sceneManager.battlePlayer().m_ActionOrder[1].index then
			print("actionCmd_ACTIONUNITINDEX:enterStart server action index"..self._action._id);
			print("actionCmd_ACTIONUNITINDEX:enterStart client action index"..sceneManager.battlePlayer().m_ActionOrder[1].index);
		end
		
		--if uiupdate then
			sceneManager.battlePlayer().m_UiOrderTranslationed = false;
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_UNIT_INFO})	
		--end
		
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_CASTERMAGIC_COUNTER})	
				
		sceneManager.battlePlayer().newRoundAction = true																	
end

local actionCmd_ENDFLAG = class("actionCmd_ENDFLAG",actionCmdBase) --ENDFLAG
function actionCmd_DEAD:ctor(action)
	actionCmd_ENDFLAG.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_ENDFLAG,ACTION_TYPE.ENDFLAG) 

function actionCmd_ENDFLAG:enterStart()	
	sceneManager.battlePlayer():endBattle();
end	

local actionCmd_MAGIC_OVER = class("actionCmd_MAGIC_OVER",actionCmdBase)
function actionCmd_MAGIC_OVER:ctor(action)
	actionCmd_MAGIC_OVER.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_MAGIC_OVER,ACTION_TYPE.MAGIC_OVER) 

function actionCmd_MAGIC_OVER:enterStart()
	
	-- 计算国王行动序列相关	
	if sceneManager.battlePlayer().nextMagicRoundTurnForce == self._action._param.force then	
		-- 轮到先手方释放
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_CASTERMAGIC_COUNTER, clear = true});
		
		
	else
		-- 先手方释放完
		-- 等待另一方释放魔法
		--sceneManager.battlePlayer().nextMagicRound = -1;
		sceneManager.battlePlayer().magicOverFlag = true;
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_CHANGE_KING_ICON});
	end
	
	local uiupdate = sceneManager.battlePlayer():calcAllActionOrder(false);
	
	if uiupdate then
		sceneManager.battlePlayer().m_UiOrderTranslationed = false;
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_UNIT_INFO})	
	end
		
	sceneManager.battlePlayer().turn_self_caster_magic  =  (battlePlayer.force	 == self._action._param.force)	
	
	if(battlePlayer.rePlayStatus == true)then
		if(sceneManager.battlePlayer().turn_self_caster_magic == true)then
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_SKILL, notFlip = (sceneManager.battlePlayer().m_RoundNum == 0) });	
		end	
	end
	
	-- 魔法飞出表现, 轮到自己方释放魔法
	if(sceneManager.battlePlayer().turn_self_caster_magic == true)then
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_FLY_MAGIC_OUT });	
	end
		
	if(sceneManager.battlePlayer().turn_self_caster_magic)then
		battlePlayer.selfMagicNum = battlePlayer.selfMagicNum or 0   
		battlePlayer.selfMagicNum = battlePlayer.selfMagicNum + 1 
		if(battlePlayer.selfMagicNum == 2)then
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_SKIP})
		end
	end
			
end	

 

local actionCmd_HANDLE_BUFF = class("actionCmd_HANDLE_BUFF",actionCmdBase) --HANDLE_BUFF
function actionCmd_HANDLE_BUFF:ctor(action)
	actionCmd_HANDLE_BUFF.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_HANDLE_BUFF,ACTION_TYPE.HANDLE_BUFF) 


function actionCmd_HANDLE_BUFF:enterStart()	
 	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._param.target]							
	self._payer:_handleBuffer(self._action)		
 
end
function actionCmd_HANDLE_BUFF:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt)	
end

local actionCmd_DELETE_BUFFF = class("actionCmd_DELETE_BUFFF",actionCmdBase) --DELETE_BUFF
function actionCmd_DELETE_BUFFF:ctor(action)
	actionCmd_DELETE_BUFFF.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_DELETE_BUFFF,ACTION_TYPE.DELETE_BUFF) 

function actionCmd_DELETE_BUFFF:enterStart()	
	self._payer.m_CurrentCrops = self._payer.m_AllCrops[self._action._param.target]							
	self._payer:_delBuffer(self._action)			
end

function actionCmd_DELETE_BUFFF:Tick(dt)
	return  self._payer.m_CurrentCrops:logic(dt)	
end

 
local actionCmd_SKILL = class("actionCmd_SKILL",actionCmdBase) --SKILL
function actionCmd_SKILL:ctor(action)
	actionCmd_SKILL.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_SKILL,ACTION_TYPE.SKILL) 


function actionCmd_SKILL:enterStart()	
	self._payer:_playSkill(self._action)	
end

function actionCmd_SKILL:Tick(dt)
		
	local res = (self._payer.m_CurrentCrops:logic(dt) == true)	
	return res	
end


local actionCmd_MAGIC = class("actionCmd_MAGIC",actionCmdBase) --MAGIC
function actionCmd_MAGIC:ctor(action)
	actionCmd_MAGIC.super.ctor(self,action)		
end	
actionSys.RegisterActClass(actionCmd_MAGIC,ACTION_TYPE.MAGIC) 

function actionCmd_MAGIC:enterStart()		
	
	--print("magic  ------------------------------------------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	
	self._payer:_playMagic(self._action)	
end
function actionCmd_MAGIC:Tick(dt)
	local 	res =  self._payer.casterKing:logic(dt) == true 
	if(res)then
		sceneManager.battlePlayer():playActionAnimate()
	end	
	return res
end


-- ATTRIBUTE
local actionCmd_ATTRIBUTE = class("actionCmd_ATTRIBUTE",actionCmdBase) -- ATTRIBUTE

function actionCmd_ATTRIBUTE:ctor(action)
	actionCmd_ATTRIBUTE.super.ctor(self,action)	
end	

actionSys.RegisterActClass(actionCmd_ATTRIBUTE,ACTION_TYPE.ATTRIBUTE) 

function actionCmd_ATTRIBUTE:enterStart()	
	self._payer:_AttributeChange(self._action)	
end



battlePlayer = class("battleField")

battlePlayer.ACTION_TIME_SPACE = 600
battlePlayer.ACTON_END_TIME = 0

battleKingSkillAi = {}
battleKingSkillAi.wait_time = 0
function  battleKingSkillAi.RandomSkill()
	if(sceneManager.battlePlayer().wait_action and 	sceneManager.battlePlayer().turn_self_caster_magic == true )then	
		--[[local canCastSkill = {}			
		for i,v in ipairs (playerEquipedMagicData) do				
				if(castMagic.checkSkillCanCaste(v.id))then
					 table.insert(canCastSkill,v.id)
				end							
		end
		--table.insert(canCastSkill,0)			
		castMagic.randomSkill( canCastSkill[math.random(1,#canCastSkill)])		
		]]--
		castMagic.autoKingSkill()
	end			
end
battleKingSkillAi.auto_time = 30*1000
battleKingSkillAi.casted = false

battleKingSkillAi.first_action = false
battleKingSkillAi.STATUS = 
{	
	Immediately = 1,
	TICK_TIME = 2
}
battleKingSkillAi.M_STATUS = battleKingSkillAi.STATUS.TICK_TIME

function  battleKingSkillAi.Tick(dt)
	
	if(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).countdown ==  false)then
		return 
	end
	if(sceneManager.battlePlayer().turn_self_caster_magic == false)then
		return
	end
	if(sceneManager.battlePlayer().wait_action )then					
			if(battleKingSkillAi.wait_time <= 0)then
					battleKingSkillAi.wait_time = 0
				if(battleKingSkillAi.casted == false)then
					battleKingSkillAi.casted = true
					battleKingSkillAi.RandomSkill()				
				end
			else
				battleKingSkillAi.wait_time = battleKingSkillAi.wait_time - dt/ sceneManager.battlePlayer():getSpeed()
			end											
	else
		battleKingSkillAi.casted = false		
		if(sceneManager.battlePlayer().AutoKingMagic == true)then
				battleKingSkillAi.M_STATUS = battleKingSkillAi.STATUS.Immediately
				battleKingSkillAi.wait_time = 2*1000
		else
				
			 battleKingSkillAi.M_STATUS = battleKingSkillAi.STATUS.TICK_TIME	
			 battleKingSkillAi.wait_time = battleKingSkillAi.auto_time 
		end		
 			
	end		



end
battlePlayer.guiderePlayStatus = false
battlePlayer.rePlayStatus = false
battlePlayer.allBattleStep ={}
battlePlayer.rePlayStep = nil
battlePlayer.replayBattleHandle = nil

battlePlayer.self_config = {}
battlePlayer.other_config = {}
battlePlayer.force = enum.FORCE.FORCE_INVALID

function battlePlayer:ctor()
	
	-- 清理释放魔法的数据
	castMagic.init();
	
	self.debuginfo = "";
	
	self.actionList = nil	
 
 	self.m_LastActionOrder = {}
	self.m_ActionOrder = {}  --ActionOrde
	
	self.m_maxRoundNum = dataConfig.configs.ConfigConfig[0].maxRounds or 200 --最大回合
	self.m_RoundNum = 0 	--当前回合。
	self.m_lastConflictForce = false --上次冲突是否是攻击方行动的
	self.m_bShowRoundNum = 12 --显示行动序列个数。
	self.m_bAttackWinner = false --是否攻击方胜利
	self.m_WaitingTime = 0 --等待时间
    self.m_actionEnd = false --  	
 	self.m_DeadUnitsIndex = nil;
 	-- 下一次国王魔法的剩余回合数, 变成0表示第一个该放魔法，变成-1表示第二个该放魔法
 	self.nextMagicRound = 0;
 	-- 下一次国王魔法回合开始时是进攻方，还是防守方
 	self.nextMagicRoundTurnForce = enum.FORCE.FORCE_ATTACK;
 	-- 需要一个标志，在收到后手magicover的时候，标记一下是后手开始放，设置flag为true
 	-- 在下一条action的时候检查如果是true的话，就表示魔法播放完了
 	self.magicOverFlag = false;
 	
	--battlePlayer.rePlayStatus = false
	self.unitInstanseInitOK = true;
	
	self.mergedRewardList = nil;
	self.skipBattleMagicSendBack = true
	battlePlayer.win = nil
	self.trunMagicNum = 0
end

function battlePlayer:release()
	battlePlayer.selfMagicNum = nil
	self.currentAction = nil;
	self.skipBattleMagicSendBack = true	
	self.unitInstanseInitOK = false;
	self.mergedRewardList = nil;
	self.nextMagicRound = 0;
	self.nextMagicRoundTurnForce = enum.FORCE.FORCE_ATTACK;
	self.trunMagicNum = 0
	-- 伤害字清除
	battleText.hitList = {};
		
	-- 战斗记录存文件
	battleRecord.endBattle();
	 
 	if self.casterKing then
 		self.casterKing:release();
		self.casterKing = nil;
 	end
	
	if self.targetNull then
		self.targetNull:release();
		self.targetNull = nil;
	end
	
	if(self.m_AllCrops ~= nil) then
		for _,v in pairs (self.m_AllCrops) do
			 if(v ~= nil)	then
					v:release()	
					v = nil			
			  end			
		end	
 
		self.m_AllCrops = nil		
	end
 
	self.wait_action = false
		
	self.actionList = nil	
	bufferSys.Destroy()
	actionSys.Destroy()
	battlePlayer.battleRc = nil

	if(battlePlayer.replayBattleHandle ~= nil)then
		scheduler.unscheduleGlobal(battlePlayer.replayBattleHandle)			
		battlePlayer.replayBattleHandle = nil	
	end	

	self.turn_self_caster_magic =   nil 
	self.AutoBattle = getClientVariable("AutoBattle",false)	
	self.AutoKingMagic = false 
	self.actionListPlayEnd = true
	self.selecMagic = nil
	battlePlayer.allHurtNum = nil
end

function battlePlayer:init()
	self:release()	
	self:setAutoBattle(battlePlayer.prepareAutoBattle or false)
	battlePlayer.win = nil
	self.m_Scale	 	  	=	self:getSpeed()
	--print("getClientVariable"..self.m_Scale )
	self.m_CurrentCrops = nil
	self.m_CurrentTime = 0
	self.m_RoundNum = 0				
	
	self.m_bAttackWinner = false
	self.m_lastConflictForce = false	
	self.m_AllCrops = {}	
	
	self.m_bPaused = false
	self.m_State  = nil
	self.m_UiOrderTranslationed = true
				
	function callBack(actor,endActor,skill,callbackindex,callbacknum, attUserData, attUserData2)
			print("callBack  skill "..skill.." callbackindex "..callbackindex.." callbacknum "..callbacknum.."attUserData"..attUserData);
		
		if not sceneManager.battlePlayer() or (sceneManager.battlePlayer() and sceneManager.battlePlayer():isEndBattle() ) then
			return;
		end
		
		--print(actor)
		if callbacknum == 0 then
			callbacknum = 1;
			callbackindex = 1;
		end

		if attackCallback.Handler[attUserData] then
			attackCallback.Handler[attUserData](actor, endActor, skill, callbackindex, callbacknum, attUserData2);			
		end
 		
	end		
	
	LORD.ActorManager:Instance():registerWoundCallBack(callBack)		
	
	
	
end

-- 进入战斗
function battlePlayer:runBattle(createdActors)
	--删除新手引导的拖动指引
	Guide.hideGuidHand()
	--
	dataManager.kingMagic:onBattleStart()
	 
	eventManager.dispatchEvent({name = global_event.BATTLE_UI_SHOW});
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_HIDE});
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE});
	self:createUnits(createdActors)
	self:parseData(sceneManager.battledata)	
	self:speedGame(tonumber(getClientVariable( "gameSpeed",SPEED_UP_GAME[1])))	
	 
	self.m_CurrentTime = 0
	self.m_lastConflictForce = false
	self.m_CurrentCrops = nil
	self.m_RoundNum = 0
	self.m_State = BATTLESTATE.BS_BEGIN	
 	
 	-- 备份星级，为了结束后比较是不是首通
 	if battlePrepareScene.isAdventureBattleType() and dataManager.playerData.stageInfo then
 		dataManager.playerData.stageInfo:backupStar();
 	end
end

-- 进入对话状态 
function battlePlayer:enterDialogue()
	if battlePrepareScene.isAdventureBattleType() and dataManager.playerData.stageInfo and dataManager.playerData.stageInfo:isShowDialogue() then
		self.m_State = BATTLESTATE.BS_BEFORE_DIALOGUE;
		eventManager.dispatchEvent({name = global_event.DIALOGUE_SHOW, 
			dialogueType = "adventureBefore", dialogueID = dataManager.playerData.stageInfo:getBeforeDialogueID() });
	else
		self:beginBattle();
	end
end

-- 对话结束
function battlePlayer:onEndDialogue()
	self:beginBattle();
end

-- 
function battlePlayer:onEndDialogueAfterBattle()
	eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_SHOW, stage = dataManager.playerData.stageInfo});	
	self.m_State =  BATTLESTATE.BS_END;
end

-- 恢复战斗
function battlePlayer:resumeBattle()

	self:parseData(sceneManager.battledata);
	
	if(battlePlayer.rePlayStatus == false )then
	
		if(self:getSkipBattle() ~= true)then
			eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_UNIT });
		end
	end
	castMagic.isSending = false;

end

function battlePlayer:setAllGridNormal()
	battlePrepareScene.setAllGridNormal();
end

function battlePlayer:signGrid( x,y,color )
	battlePrepareScene.signGrid(x, y, color) 
end

function battlePlayer:getCropsByIndex(index)

	if self.m_AllCrops then
		return self.m_AllCrops[index]
	else
		return nil;
	end
	
end	

function _isSkillOrMagicParamCare(Damage_source,skillOrmagic)
	if(skillOrmagic == true and  Damage_source == enum.SOURCE.SOURCE_SKILL)then
		return true
	end	
	if(skillOrmagic == false and Damage_source == enum.SOURCE.SOURCE_MAGIC)then
		return true
	end
	return false
end	

function _isBUFFParamCare(Damage_source)
	if(Damage_source == enum.SOURCE.SOURCE_BUFF)then	
		return true
	end
	return false
end	

function __makeINTERNAL_CONFLICTaram( _curAction ,_actiondata,index)
 
	local sourceGUID = _curAction.InternalConflict.sourceGUID 
	 
	local targets = {}
	local size = #	_actiondata	
	
	for i = index,size do						
		local v = _actiondata[i]									
		if(_curAction.m_round ~= v.m_round)then
			break
		end																			
		if (v.m_type == SERVER_ACTION_TYPE.DAMAGE ) then						
			local _skillId = v.damage.id  
			local damageSource =  v.damage.source 												
				if(sourceGUID == v.damage.sourceGUID)then					
					local _target = {}  				
					_target.casterId = v.m_caster
					_target.skillId = _skillId
					_target.id = v.damage.target 
					_target.damage = v.damage.value 
					_target.damageSource = damageSource
					_target.damageFlag = v.damage.damageFlag 
					table.insert( targets, { target = _target, server_action_type =  v.m_type} )
					v.handled = true
				end		
		end
	end
	return targets	
end				
				
function __makeSkillOrMagicParam( _curAction ,_actiondata,index,skillOrmagic) --
	local skillId = _curAction._param.skillid 
	local sourceGUID = _curAction._param.sourceGUID 
	local casterId = _curAction._id 
	local targets = {}
	local size = #	_actiondata	
	for i = index,size do						
		local v = _actiondata[i]									
		if(_curAction.round ~= v.m_round)then
			break
		end																			
		if (v.m_type == SERVER_ACTION_TYPE.DAMAGE and v.handled ~= true) then						
			local _skillId = v.damage.id  
			local damageSource =  v.damage.source 							
				--if(casterId == v.m_caster  and skillId  ==_skillId and _isSkillOrMagicParamCare(damageSource,skillOrmagic))then		
				
				if(sourceGUID == v.damage.sourceGUID)then		
			 	
					local _target = {}  
					_target.skillId = _skillId
					_target.id = v.damage.target 
					_target.damage = v.damage.value 
					_target.damageSource = damageSource
					_target.damageFlag = v.damage.damageFlag 
					_target.casterId = v.m_caster
					table.insert( targets, { target = _target, server_action_type =  v.m_type} )
					v.handled  = true
					--print("parse data _skillId ".._skillId);
					--dump(_target);
					 	 
					sceneManager.battlePlayer():calcDamage(_target.casterId, v.damage.value, damageSource == enum.SOURCE.SOURCE_MAGIC)
				end		
				
		--[[elseif (v.m_type == SERVER_ACTION_TYPE.ATTRIBUTE and v.handled ~= true ) then		
		 
			if(sourceGUID == v.attribute.sourceGUID)then				
					local tempaction = {}  			
					tempaction.round = v.m_round
					tempaction._id = v.attribute.id
				    tempaction._type = v.m_type
					tempaction._param = v.attribute;			
					table.insert( targets, { target = tempaction, server_action_type =  v.m_type} )
					v.handled  = true	
			end			
							]]--											
		elseif(v.m_type == SERVER_ACTION_TYPE.CURE and v.handled ~= true ) then
				local _skillId = v.cure.id 
				local damageSource =  v.cure.source 	
				--if(casterId == v.m_caster  and skillId  ==_skillId and _isSkillOrMagicParamCare(damageSource,skillOrmagic))then	
				if(sourceGUID == v.cure.sourceGUID)then				
					local _target = {}  
					_target.skillId = _skillId
					_target.id = v.cure.target 
					_target.cure = v.cure.value 
					_target.cureSource = damageSource
					_target.casterId = v.m_caster									
					table.insert( targets, { target = _target, server_action_type =  v.m_type} )
					v.handled  = true	
				end		
				
		elseif(v.m_type == SERVER_ACTION_TYPE.SUMMON and v.handled ~= true  ) then	
		
				local _skillId = v.summon.id 
				local summon_source =  v.summon.source 	
				if(sourceGUID == v.summon.sourceGUID)then		
				--if(casterId == v.m_caster  and skillId  ==_skillId and _isSkillOrMagicParamCare(summon_source,skillOrmagic))then						
					local _target = {}  
					_target.skillId = _skillId
					_target.m_targetID = v.summon.targetID 
					_target.m_targetIndex = v.summon.target 
					_target.m_count = v.summon.count
					_target.pos  = {x = v.summon.x, y = v.summon.y}
					_target.summon_Source = summon_source	
					_target.casterId = casterId				
					
					_target.shipAttack = v.summon.shipAttack;
					_target.shipDefence = v.summon.shipDefence;
					_target.shipCritical = v.summon.shipCritical;
					_target.shipResilience = v.summon.shipResilience;
						
					table.insert( targets, { target = _target, server_action_type =  v.m_type} )
					v.handled  = true							
				end							
		elseif(v.m_type == SERVER_ACTION_TYPE.REVIVE   and v.handled ~= true ) then					
				local _skillId = v.revive.id 
				local revive_source =  v.revive.source 	
				if(sourceGUID == v.revive.sourceGUID)then					
				--if(casterId == v.m_caster  and skillId  ==_skillId and _isSkillOrMagicParamCare(revive_source,skillOrmagic))then												
					local _target = {}  
					_target.skillId = _skillId					
					_target.revive_source = revive_source
					_target.target = v.revive.target					
					_target.hp = v.revive.hp	
					_target.casterId = casterId	
					_target.x = v.revive.x	
					_target.y = v.revive.y									
					table.insert( targets, { target = _target, server_action_type =  v.m_type} )
					v.handled  = true							
				end
				
		elseif(skillId == enum.SKILL_TABLE_ID.Repel and v.m_type == SERVER_ACTION_TYPE.MOVE and v.move.moveFlag == enum.MOVE_FLAG.MOVE_FLAG_REPEL and v.handled ~= true  ) then
			-- 合并击退的代码
			v.handled = true;
			
			local moveData = {};
			
			if(v.move.pointCount == 1)then				
				moveData = { moveFlag = v.move.moveFlag  ,pointNum = (v.move.pointCount), points = v.move.points};
			else
				table.remove(v.move.points,1) -- 第一个是自己的所在点 不需要
				v.move.pointCount = v.move.pointCount -1
				moveData = { moveFlag = v.move.moveFlag  ,pointNum = (v.move.pointCount), points = v.move.points};						
			end				
			
			local action = actionCmdClass.new();
			action.round = v.m_round;
			action._id = v.m_caster;
		
			moveData.skills = __makeMoveSkillParam(action, _actiondata, i+1);
			
			--dump(moveData);
			
			--print("parse data move ");
			
			-- 找到对应的target数据，加进去
			for key, value in pairs(targets) do
				if value.target.id == v.m_caster then
					value.repelData = moveData;
					break;
				end
			end
			
			--dump(targets);
			
		elseif(v.m_type == SERVER_ACTION_TYPE.BUFF  and v.handled ~= true  ) then			
				local 	operationCode =  v.buff.operationCode  
				local   targetId = v.buff.target  
				local	bufferId = 	v.buff.id  																	
					if operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_ADD then
						local _skillId = v.buff.skillID   		
						local buffSource =  v.buff.source 		
						if(sourceGUID == v.buff.sourceGUID)then														
						--if(casterId == v.m_caster  and skillId  ==_skillId and _isSkillOrMagicParamCare(buffSource,skillOrmagic) )then			
							local _target = {}  
							_target.skillId = _skillId
							_target.id = targetId 
							_target.bufferId = bufferId
							_target.bufferSource = buffSource 
							_target.layer = v.buff.layer
							_target.addRet = v.buff.addRet
							_target.casterId = v.buff.buffInnerCasterIndex;
							_target.cd = v.buff.cd;
							v.handled  = true											
							table.insert( targets, { target = _target, server_action_type =  v.m_type , bufferoperationCode = operationCode } )																				
						end																
					elseif operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_EFFECT then									
									 -- do nothing								
					elseif operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE then
							local _skillId = v.buff.skillID   								
							--if(casterId == v.m_caster  and skillId  ==_skillId )then	
							if(sourceGUID == v.buff.sourceGUID)then				
								local _target = {}  
								_target.skillId = _skillId
								_target.id = targetId 
								_target.bufferId = bufferId
								_target.buffInnerCasterIndex = v.buff.buffInnerCasterIndex;																				
								table.insert( targets, { target = _target, server_action_type =  v.m_type , bufferoperationCode = operationCode } )									
								v.handleBufferDel = true
								v.handled  = true	
							else
																												
							end
					elseif operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_CD then										
							local _skillId = v.buff.skillID   								
							--if(casterId == v.m_caster  and skillId  ==_skillId)then	
							if(sourceGUID == v.buff.sourceGUID)then									
								local _target = {}  
								_target.skillId = _skillId
								_target.id = targetId 
								_target.bufferId = bufferId		
								_target.cd = v.buff.cd
								_target.buffInnerCasterIndex = v.buff.buffInnerCasterIndex;
								v.handled  = true																				
								table.insert( targets, { target = _target, server_action_type =  v.m_type , bufferoperationCode = operationCode } )																				
							end										
					elseif operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_CHANGE_LAYER then									
							local _skillId = v.buff.skillID   								
							--if(casterId == v.m_caster  and skillId  ==_skillId)then
							if(sourceGUID == v.buff.sourceGUID)then					
								local _target = {}  
								_target.skillId = _skillId
								_target.id = targetId 
								_target.bufferId = bufferId		
								_target.layer = v.buff.layer		
								_target.hp = v.buff.hp 
								_target.buffInnerCasterIndex = v.buff.buffInnerCasterIndex;
								v.handled  = true												
								table.insert( targets, { target = _target, server_action_type =  v.m_type , bufferoperationCode = operationCode } )																				
							end																																																
					end															 												
		end		
																											
	end
	return targets	
end			
			
function __makeBUFFParam( curAction ,_actiondata,index)
		local  bufferId = curAction._param.bufferId 	
		local sourceGUID = curAction._param.sourceGUID 
		local target = curAction._param.target				
		local effectList = {}												
		local size = #	_actiondata	
			for i = index,size do						
				local v = _actiondata[i]												
				if(curAction.round ~= v.m_round)then
					break
				end																			
				if (v.m_type == SERVER_ACTION_TYPE.DAMAGE and v.handled ~= true  ) then						
					local _bufferId = 	v.damage.id  
					local damageSource =  v.damage.source 	
					local damageTarget = v.damage.target	
					if(sourceGUID == v.damage.sourceGUID)then								 						
					--if(target == damageTarget  and bufferId  ==_bufferId and _isBUFFParamCare(damageSource))then					
							local _effect = {}  
							_effect.bufferId = _bufferId
							_effect.id = damageTarget
							_effect.damage = v.damage.value 
							_effect.damageSource = damageSource
							_effect.damageFlag = v.damage.damageFlag 
							v.handled  = true 
							table.insert( effectList, { effect = _effect, server_action_type =  v .m_type} )	
							 
							sceneManager.battlePlayer():calcDamage(v.m_caster, v.damage.value, damageSource == enum.SOURCE.SOURCE_MAGIC)
					end									
				elseif(v .m_type == SERVER_ACTION_TYPE.CURE and v.handled ~= true ) then
					local _bufferId = v.cure.id  
					local cureeSource =  v.cure.source 	
					local cureTarget = v.cure.target	
					if(sourceGUID == v.cure.sourceGUID)then						
					--if(target == cureTarget  and bufferId  ==_bufferId and _isBUFFParamCare(damageSource))then				
								local _effect = {}  
								_effect.bufferId = _bufferId
								_effect.id = cureTarget
								_effect.cure = v.cure.value 
								_effect.cureSource = cureeSource	
								v.handled  = true 						
								table.insert( effectList, { effect = _effect, server_action_type =  v .m_type} )	
					end			
				end				
			end
			return effectList
end								
-- 解析战斗序列

function __makeMoveSkillParam(_curAction ,_actiondata,index)

	-- 计算割裂的效果，把后面所有的技能效果都收集起来
	local result = {};
	local size = #	_actiondata	
	for i = index,size do						
		local v = _actiondata[i]									
		
		if(_curAction.round ~= v.m_round)then
			break
		end
		
		-- 
		if (v.m_type == SERVER_ACTION_TYPE.SKILL and v.handled ~= true  ) then		
			--if(dataConfig.configs.skillConfig[v.skill.id].moment == enum.MOMENT.MOMENT_MOVE)then
			if( (v.skill.id == enum.SKILL_TABLE_ID.GeLie or v.skill.id == enum.SKILL_TABLE_ID.GeLie2)  and v.m_caster == _curAction._id )then 	----				['id'] = 50,		['name'] = '割裂',				
				local action =  actionCmdClass.new() 
				action.round = v.m_round
				action._id = v.m_caster				
				action._type = ACTION_TYPE.SKILL
			    action._param  = {skillid  = v.skill.id,sourceGUID = v.skill.sourceGUID}					
			    action._param.targets = __makeSkillOrMagicParam(action,_actiondata,i+1,true)					
				v.handled  = true 
				--return action._param.targets
				table.insert(result, action._param.targets);
				return result;
			end
		end
		
	end	 		
	return result;
end	
----------------------------------战斗回放-------------------
function battlePlayer:cacheBattleRecord(rc)
	battlePlayer.battleRc = battlePlayer.battleRc or {}
	table.insert(battlePlayer.battleRc,rc)
end

function battlePlayer:saveBattleRecord(rc)
	
	--[[
	local file = fio.open("battles", 1)	 
	local size = #battlePlayer.battleRc
	for i,v in ipairs (battlePlayer.battleRc) do
		local data = json.encode(v)				--print(data)
		fio.write(file, data)
		if(i ~= size) then
			fio.write(file, "&&")
		end
	end
	fio.close(file)		
	]]--
	battlePlayer.playbattleRc  = clone(battlePlayer.battleRc)
	
	
end	
function battlePlayer:loadAndRePlayBattleRecord()
	
	self:saveBattleRecord()	
	eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
	eventManager.dispatchEvent({name = global_event.RANKINGAWARD_HIDE})
	
	self.m_State = BATTLESTATE.BS_LEAVE
	self:release()
	--[[battlePlayer.allBattleStep ={}
	local file = fio.open("battles", 0)	 
	local fileStr = fio.readall(file)
	fio.close(file)		
	
	battlePlayer.allBattleStep = string.split(fileStr, "&&")
	battlePlayer.playbattleRc = {}	
	
	local step = #(battlePlayer.allBattleStep) 
	for i = 1 , step  do	
		local t = json.decode( battlePlayer.allBattleStep[i] )
		table.insert(battlePlayer.playbattleRc, t)		
	end
	]]--
	
	self:replayBattleRecord()
end
function tickPlay(dt)
		if(sceneManager.battlePlayer().wait_action == true)then
			battlePlayer.rePlayStep = battlePlayer.rePlayStep  + 1
			local step = #(battlePlayer.playbattleRc) 
			if(battlePlayer.rePlayStep <= step )then				
				--table.insert(sceneManager.battledata,battlePlayer.playbattleRc[ battlePlayer.rePlayStep])	
				sceneManager.battledata[1] = battlePlayer.playbattleRc[ battlePlayer.rePlayStep]						
				sceneManager.battlePlayer():parseData(sceneManager.battledata)
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_UNIT})
			else	
				if(battlePlayer.replayBattleHandle ~= nil)then
					scheduler.unscheduleGlobal(battlePlayer.replayBattleHandle)			
					battlePlayer.replayBattleHandle = nil	
				end		
			end	
		end						
end					
function battlePlayer:replayBattleRecord()	
	battlePlayer.rePlayStatus = true
	battlePlayer.guiderePlayStatus = false	
    battlePlayer.rePlayStep =   1		
	local battledata = battlePlayer.playbattleRc[ battlePlayer.rePlayStep]		
	--table.insert(sceneManager.battledata,battledata)
	sceneManager.battledata[1] = battledata
	game.EnterProcess( game.GAME_STATE_BATTLE)	
	if(battlePlayer.replayBattleHandle ~= nil)then		
		scheduler.unscheduleGlobal(battlePlayer.replayBattleHandle)
		battlePlayer.replayBattleHandle = nil			
	end		
	battlePlayer.replayBattleHandle = scheduler.scheduleGlobal(tickPlay,1)
	

end

function battlePlayer:currActionPlayEnd()
	return self.actionListPlayEnd == true
end	


function battlePlayer:calcDamage(casterId, damage,ismagic)
	
	
	print("casterId ..."..casterId)
	
	battlePlayer.allHurtNum[casterId] = battlePlayer.allHurtNum[casterId] or 0
	if(ismagic ~= true)then
		battlePlayer.allHurtNum[casterId]  = battlePlayer.allHurtNum[casterId] + damage
	end
	--[[
		local castCurrentCrops = self.m_AllCrops[casterId]	
		if( not  castCurrentCrops:isFriendlyForces() )	then
			---
		end
	]]--
end		
			
function battlePlayer:parseData(sceneManager_battledata)
	
	
	if(self:currActionPlayEnd() == false and self:getSkipBattle() == false)then	
		print("parseData  currActionPlayEnd")
		return 
	end		
	
	self.skipBattleMagicSendBack = nil
	
	--print("parseData"..table.nums(sceneManager_battledata) )
	self.actionListPlayEnd = false
	local actiondata = sceneManager_battledata[1];	
	self:cacheBattleRecord(clone(actiondata))	
	
	battlePlayer.allHurtNum = battlePlayer.allHurtNum or {} 
	
	 
	
	local ___acList = {}
	self.magicCasterRoundNum = 0
	self.ConstLastRoundNum = 0
	for i,v in ipairs(actiondata) do
		local action =  actionCmdClass.new() 
		action.round = v.m_round
		action._id = v.m_caster
		action._type = v.m_type
		if(i ==1 )then
			self.magicCasterRoundNum = action.round
		end
		self.ConstLastRoundNum =  action.round
		action._param = {}
		local insert = true
		if action._type == SERVER_ACTION_TYPE.MOVE then		
			
			if( v.handled ~= true)then
				 
				if(v.move.pointCount == 1)then				
					action._param = { moveFlag = v.move.moveFlag  ,pointNum = (v.move.pointCount), points = v.move.points}				
				else
					table.remove(v.move.points,1) -- 第一个是自己的所在点 不需要
					v.move.pointCount = v.move.pointCount -1
					action._param = { moveFlag = v.move.moveFlag  ,pointNum = (v.move.pointCount), points = v.move.points}							
				end				
				action._param.skills = __makeMoveSkillParam(action,actiondata,i+1)		
			else
				insert = false;
			end
			
		elseif action._type == SERVER_ACTION_TYPE.ATTACK then						
			action._param = {targetNum = 1, targets = { id = v.attack.target, hurt = { server_action_type = action._type ,target ={ damageFlag = v.attack.damageFlag,damage = v.attack.value}}}}
			self:calcDamage(action._id, v.attack.value)
	 
		elseif action._type == SERVER_ACTION_TYPE.RETALIATE	 then						
			action._param = {targetNum = 1, targets = {  id = v.retaliate.target,hurt ={server_action_type = action._type, target ={damageFlag = v.retaliate.damageFlag ,damage = v.retaliate.value}}}}
			 
			self:calcDamage(action._id, v.retaliate.value)
		elseif action._type == SERVER_ACTION_TYPE.LOCK then		
		elseif action._type == SERVER_ACTION_TYPE.DEAD then	
				action._param = { deadFlag =  v.dead.deadFlag}
		elseif action._type == SERVER_ACTION_TYPE.SKILL   then	--技能	
		
		  if( v.handled ~= true)then
			   action._type = ACTION_TYPE.SKILL
			   action._param  = {skillid  = v.skill.id,sourceGUID = v.skill.sourceGUID}					
			   action._param.targets = __makeSkillOrMagicParam(action,actiondata,i+1,true)		
			else
				insert = false
			end						
		elseif action._type == SERVER_ACTION_TYPE.MAGIC   then	--魔法											
			   action._type = ACTION_TYPE.MAGIC
			   action._param  = {skillid  = v.magic.id,sourceGUID = v.magic.sourceGUID ,posx = v.magic.posx,posy = v.magic.posy }					
			   action._param.targets = __makeSkillOrMagicParam(action,actiondata,i+1,false)
			   --dump(action._param.targets )
		elseif action._type == SERVER_ACTION_TYPE.BUFF	   then				
				local 	_operationCode =  v.buff.operationCode  
				local   _targetId = v.buff.target  
				local	_bufferId = 	v.buff.id				
			    if(_operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_EFFECT)then												
					action._type = ACTION_TYPE.HANDLE_BUFF
					action._param  = {target = _targetId,bufferId = _bufferId,bufferoperationCode = _operationCode ,
														server_action_type =  action._type, cd  = v.buff.cd, layer = v.buff.layer, sourceGUID = v.buff.sourceGUID}					
					action._param.effectList = __makeBUFFParam(action,actiondata,i+1)			
					--dump(action._param.effectList )					
			    elseif(v.buff.operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE)then								
				  	local 	_operationCode =  v.buff.operationCode  
				  	local   _targetId = v.buff.target  
				  	local	_bufferId = v.buff.id				
				  	local    skillId = v.buff.skillID									
			     	if( skillId == 0 and _operationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_DELETE   )then	
					 		v.handleBufferDel = true										
					 		action._type = ACTION_TYPE.DELETE_BUFF
					 		action._param  = { buffInnerCasterIndex = v.buff.buffInnerCasterIndex, target = _targetId, bufferId = _bufferId,bufferoperationCode = _operationCode ,server_action_type =  action._type}														
				   	elseif( v.handleBufferDel ~= true  )then  

					 		action._type = ACTION_TYPE.DELETE_BUFF
					 		action._param  = {buffInnerCasterIndex = v.buff.buffInnerCasterIndex, target = _targetId,bufferId = _bufferId,bufferoperationCode = _operationCode ,server_action_type =  action._type}										

				   end					
				else
					-- do nothing
				end							
		elseif action._type == SERVER_ACTION_TYPE.SUMMON then	--SUMMON				
			-- do nothing
		elseif action._type == SERVER_ACTION_TYPE.DAMAGE   then		
			-- do nothing
			 insert = false 
		elseif action._type == SERVER_ACTION_TYPE.CURE   then			
			-- do nothing		
			 insert = false
		elseif action._type == SERVER_ACTION_TYPE.BATTLE_OVER   then			
			-- do nothing	
			if( self:getSkipBattle() == true )then
				
				sceneManager.battlePlayer():endBattle(0);
			end
			 self.skipBattleMagicSendBack = false
		elseif action._type == SERVER_ACTION_TYPE.MAGIC_OVER   then		
			action._param = { force =  v.magicOver.force}																																									
		elseif (action._type == SERVER_ACTION_TYPE.ATTRIBUTE and v.handled ~= true) then		
			-- attr
			print("--------------------attr command----------------------------");
			action._type = ACTION_TYPE.ATTRIBUTE;
			action._param = v.attribute;		
			action.handled  = true		
		end			 
		if(insert == true)then
			table.insert(___acList,action)		
		end

	end
	self.magicCasterRoundNum = self.ConstLastRoundNum  - self.magicCasterRoundNum
	if(self.skipBattleMagicSendBack  == nil)then
		self.skipBattleMagicSendBack  = true
	end
		
	local function FindUnitDeadLastAction(deadIndex, actionList,id)
		  	local v = nil
			local round = nil
			for j = deadIndex -1, 1, -1 do	
				v = actionList[j]	
				local caster = v._id				
				if(round == nil)then
					round = v.round
				else
					if(round ~= v.round)then
						return false
					end
				end	
				---死亡之前是行动者
				if(id == caster )then
					
				--[[
					if(v._type ~= SERVER_ACTION_TYPE.MAGIC)then
						local dsource = nil
						if(v._param and v._param.targets)then
							for kk, vv   in pairs  (v._param.targets) do
								if(vv and  vv.id == id )then
									dsource = vv.damageSource 
								end					
							end
						end
						if(dsource ~= enum.SOURCE.SOURCE_MAGIC  )then
							return  true,j
						end
					end
				]]--
					if(v._type ~= SERVER_ACTION_TYPE.MAGIC )then
						return  true,j
					end
				end					
				--目标
			 	if( SERVER_ACTION_TYPE.ATTACK == v._type or v._type == SERVER_ACTION_TYPE.RETALIATE )then
						
						  
						if(v._param.targets.id == id)then																	
								return 	true,j	 	
						end	
	
				 		
				elseif( SERVER_ACTION_TYPE.SKILL == v._type or v._type == SERVER_ACTION_TYPE.MAGIC )then							
					local size = #v._param.targets					
					for i = size, 1, -1 do
						 local target = v._param.targets[i]													
							if(target.target.id == id )then
								return 	true,j	 	
							end																						
					end																	
				elseif( SERVER_ACTION_TYPE.BUFF == v._type )then					
					if(v._param.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_EFFECT)then							
							local size = #v._param.effectList					
							for i = size, 1, -1 do
								 local target = v._param.effectList[i]																
										if(target.target.id == id and   target.effect.damage > 0 )then									
												return 	true,j	 	
										end																										
							end													
					end							
				end							
			end	
		return false
	end
		
	local function signHurtToDead(deadIndex, actionList,id, deadFlag)
		   local v = nil		
		   local finRes = nil
		   local findIndex = nil
		   finRes , findIndex = FindUnitDeadLastAction(deadIndex, actionList,id)
	 
			for j = deadIndex -1, 1, -1 do	
				v = actionList[j]		
				
		  						
			 	if( SERVER_ACTION_TYPE.ATTACK == v._type or v._type == SERVER_ACTION_TYPE.RETALIATE )then
					 		
							  if(v._param.targets.id  == id and v._param.targets.hurt.target.damage > 0 )then							
									if(finRes == true and findIndex > j)then
										 return true
									else
										v._param.targets.hurt.target.hitToDead = true;
										v._param.targets.hurt.target.deadFlag = deadFlag;		
										return false --说明不需要单独的dead指令		
									end											
					          end
				 	 
				elseif( SERVER_ACTION_TYPE.SKILL == v._type or v._type == SERVER_ACTION_TYPE.MAGIC )then							
					local size = #v._param.targets					
					for i = size, 1, -1 do
						 local target = v._param.targets[i]							
						 if(target.server_action_type == SERVER_ACTION_TYPE.DAMAGE )then
								if(target.target.id == id and   target.target.damage > 0 )then						
									if(finRes == true and findIndex > j)then
										 return true
									else
										target.target.hitToDead = true
										target.target.deadFlag = deadFlag;	
										return false --说明不需要单独的dead指令		
									end			
								
								end		
						 end 																
					end	
																		
				elseif( SERVER_ACTION_TYPE.BUFF == v._type )then					
					if(v._param.bufferoperationCode == enum.BUFF_OPERATION_CODE.BUFF_OPERATION_CODE_EFFECT)then							
							local size = #v._param.effectList					
							for i = size, 1, -1 do
								 local target = v._param.effectList[i]								
								 if(target.server_action_type == SERVER_ACTION_TYPE.DAMAGE )then
										if(target.target.id == id and   target.effect.damage > 0 )then								
											if(finRes == true and findIndex > j)then
												 return true
											else
												target.effect.hitToDead = true
												target.effect.deadFlag = deadFlag			
												return false --说明不需要单独的dead指令		
											end		
											
										end									
								 end								
							end													
					end							
				end		
			 	
			end
			
			return true
	end		
	

	local _deadIndex = nil		
	local temT = {}
	 
	for i,v in ipairs (___acList) do	
		if(v._type == ACTION_TYPE.DEAD)then
			_deadIndex = i		
			if(true == signHurtToDead(_deadIndex,___acList,v._id, v._param.deadFlag))then
				v.addDeadAction = true
			end	
			table.insert(temT,v)
		end			
	end		
 
	
	--dump(___acList)
	self.actionList = {}
	--[[for k,vv in ipairs (___acList) do
		if(vv._type == ACTION_TYPE.MAGIC_OVER    )then	
			table.insert(self.actionList,vv)		
			break;
		end
	end	--]]
	--dump(self.actionList)
	
	for __,v in ipairs (___acList) do
		local vaild = false
		if(v._type == ACTION_TYPE.ACTIONUNITINDEX    )then		
			vaild = true
		elseif(v._type == ACTION_TYPE.MOVE    )then		
			vaild = true
		elseif(v._type == ACTION_TYPE.ATTACK    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.BEATBACK    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.LOCK 	)then	
			vaild = true
		elseif(v._type == ACTION_TYPE.DEAD    )then	
			vaild = ( v.addDeadAction == true)
		elseif(v._type == ACTION_TYPE.SKILL    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.MAGIC    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.SUMMON    )then	
			vaild = false
		elseif(v._type == ACTION_TYPE.ENDFLAG    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.MAGIC_OVER    )then				
			vaild = true				
		elseif(v._type == ACTION_TYPE.HANDLE_BUFF    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.DELETE_BUFF    )then	
			vaild = true
		elseif(v._type == ACTION_TYPE.ATTRIBUTE    )then	
			vaild = true								
		end			
		if(vaild == true)then		
			table.insert(self.actionList,v)
		end
	end		
		 
	 --dump(self.actionList)
 
 	self.wait_action = false
end
function battlePlayer:onCropsDead(deadCrops)
		 self:calcAllActionOrder(false)
		if deadCrops then
			self.m_DeadUnitsIndex = deadCrops.index;
		else
			self.m_DeadUnitsIndex = nil;
		end			
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_DELETE_DEAD_UNIT});		
end		

function battlePlayer:selfIsAttacker()
	return  battlePlayer.force == enum.FORCE.FORCE_ATTACK
end	
		
-- 创建参战兵团
function battlePlayer:createUnits(createdActors)
	
	
 	-- 填充己方
	local  otherforce =  enum.FORCE.FORCE_ATTACK

	if( battlePlayer.force == enum.FORCE.FORCE_ATTACK )then
		otherforce =  enum.FORCE.FORCE_GUARD
	end




	for k,v in ipairs(battlePlayer.self_config) do	
		local config =  cropData:getCropsGonfig(v.id);	
			print(" self ----- "..v.id.." index "..v.index)		

		local actor = nil;
		if createdActors then
			actor = createdActors[v.index + 1];
		end
		
		local crops = objectManager.CreateCropsUnit(config.resourceName, nil, nil, actor)
		

		crops:initCrops(v.id, v.x, v.y, v.soldierCount, battlePlayer.force, v.index);

		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK, v.shipAttr.attack);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE, v.shipAttr.defence);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL, v.shipAttr.critical);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE, v.shipAttr.resilience);
		
		self.m_AllCrops[crops.index]  = crops;
		--print("index "..k.." res "..config.resourceName);		
	end
		
	for k,v in ipairs(battlePlayer.other_config) do	
		local config =  cropData:getCropsGonfig(v.id);		
		print(" other ----- "..v.id.." index "..v.index)	
		
		local actor = nil;
		if createdActors then
			actor = createdActors[v.index + 1];
		end
			
		local crops = objectManager.CreateCropsUnit(config.resourceName, nil, nil, actor);
		crops:initCrops(v.id, v.x, v.y, v.soldierCount, otherforce, v.index);

		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK, v.shipAttr.attack);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE, v.shipAttr.defence);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL, v.shipAttr.critical);
		crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE, v.shipAttr.resilience);
						
		self.m_AllCrops[crops.index]  = crops;
		--print("index "..k.." res "..config.resourceName);
	end
	
	
	
 
	self.casterKing = objectManager.CreateKing("fashe.actor");
	self.casterKing:setIndex(kingClass.INDEX_CASTER_KING);
	self.casterKing:initKing();
	
	self.targetNull = objectManager.CreateKing("fashe.actor");
	self.targetNull:setIndex(kingClass.INDEX_TARGET_NULL);
	self.targetNull:initKing();
 
 	self.m_UiOrderTranslationed = false;					
	self:calcAllActionOrder(false);
 	--eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_UNIT_INFO});
 	
 	--刷新序列 和 魔法
 	eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_UNIT_SEQUNCE});
 	eventManager.dispatchEvent({name = global_event.BATTLE_UI_UPDATE_MAGICCD});
 	
 	self.unitInstanseInitOK = true;
end	
	
function battlePlayer:GetCropsByPosition(posX, posY)
	for i, v in pairs(self.m_AllCrops) do
		if v.m_PosX == posX and v.m_PosY == posY and v.m_bAlive then
			return v;
		end
	end
	
	return nil;
end

function battlePlayer:OnTick(dt)
	
	local color = LORD.Color(1,1,1,1);

	self:_logic(dt)
end

-- 根据状态展示
function battlePlayer:_logic(dt)
	
	if( self.m_State == BATTLESTATE.BS_BATTLE     and self:getSkipBattle() == true )then
		if(self.skipBattleMagicSendBack == true)then
			self.skipBattleMagicSendBack = nil
			table.remove(sceneManager.battledata,1)
			castMagic.autoKingSkill()
			self:_tickAllorOtherCrops(dt,true)		
		end
	end	
	
	
	if(self.m_bPaused )then
	   return
	end	
	
	-- 伤害字表现效果
	battleText.update(dt);
			
	if(self.m_State == BATTLESTATE.BS_BEGIN)then		
		if(self.playedSceneAnimated ~= true )then
				print("battlePlayer:_logic(dt)");
				local frequent = math.random();
				local radio = self:getCameraRadio();
				if frequent <= radio then
					battlePrepareScene.playStartAnimate();
				end
				self.playedSceneAnimated = true
		end
		 --self.m_WaitingTime =  self.m_WaitingTime - dt
		 --if(self.m_WaitingTime  < 0)then
		 --self.playedSceneAnimated = nil
			--self:beginBattle()
			--self:enterDialogue();
		 --end
		 
		 local isPlayingCamera = LORD.SceneManager:Instance():isPlayingCameraAnimate();
		 if not isPlayingCamera then
		 		self.playedSceneAnimated = nil;
				self:enterDialogue();
		 end
		
	end
	
	if self.m_State == BATTLESTATE.BS_BEFORE_DIALOGUE then
		-- 目前什么都不做
		
	end
	
	if(self.m_State == BATTLESTATE.BS_BATTLE)then	
			self:doBattle(dt)				
	end
				
	if(self.m_State == BATTLESTATE.BS_END)then	
		self:_tickAllorOtherCrops(dt,true)			
	end
		
	if(self.m_State == BATTLESTATE.BS_LEAVE)then	
			
	end			
end

function battlePlayer:beginBattle()
	
	self.m_CurrentTime = 0
	self.m_CurrentCrops = nil
	self.m_RoundNum = 0
	self.m_State = BATTLESTATE.BS_BATTLE

end

function battlePlayer:CancelBattle()
		
		-- 应该是等回包再处理
		self:QuitBattle()
		if(battlePlayer.rePlayStatus == false )then
			sendCancelBattle()
		end
end

function battlePlayer:onQuitBattle(again)
		
		local actorManager = LORD.ActorManager:Instance();
		actorManager:SetSpeedUp(1);
	
		sceneManager.battledata = {}
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
		eventManager.dispatchEvent({name = global_event.OUTCONFIRM_HIDE})
		eventManager.dispatchEvent({name = global_event.RANKINGAWARD_HIDE})
		eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})
		battlePlayer.prepareAutoBattle = nil
		self.m_State = BATTLESTATE.BS_LEAVE;
		self:release();
		battleprepareData.units = {};
		battleprepareData.sendUnits = {};
		
			
		battlePrepareScene.sceneDestroy();
		
		if battlePlayer.win == true and again ~= true and dataManager.playerData.stageInfo and dataManager.playerData.stageInfo:isShowAfterBattleDialogue() then
			eventManager.dispatchEvent({name = global_event.DIALOGUE_SHOW, 
				dialogueType = "adventureAfter", dialogueID = dataManager.playerData.stageInfo:getAfterDialogueID() });
			
			local flyStar = dataManager.playerData.stageInfo:getFlyStarCount();
			if flyStar > 0 then
				global.setFlag("advertureFlyStar", flyStar);
			end			
		end
		
		if dataManager.playerData.stageInfo then
			-- 恢复star
			dataManager.playerData.stageInfo:backupStar();
		end
end
function battlePlayer:QuitBattle()

	if LORD.SceneManager:Instance():isPlayingCameraAnimate() then
		LORD.SceneManager:Instance():stopCameraAnimations();
	end
	
	global.changeGameState(function()
		self:onQuitBattle();
		-- 根据不同的返回主基地类型, 要弹出不同的界面
 
		if( global.GlobalReplaySummaryInfo.isPrepareSceneAskBestBattleRecord )then
			battlePrepareScene.onEnter(battlePlayer.battleType,PLAN_CONFIG.currentPlanType);
		else
			game.EnterProcess( game.GAME_STATE_MAIN, {returnType = battlePlayer.battleType});	
		end			
		global.GlobalReplaySummaryInfo.isPrepareSceneAskBestBattleRecord = nil
		
	end);

end

function battlePlayer:AgainBattle()
		
		
	if battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		   battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then		
		
		local maxCanBattle = dataManager.playerData.stageInfo:getMaxCanBattleNum()
		local canBattleNum = (maxCanBattle - dataManager.playerData.stageInfo:getBattleNum())
		if(canBattleNum <= 0)then		
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.RESET_COPY, copyType = dataManager.playerData.stageInfo:getServerType(), copyID = dataManager.playerData.stageInfo:getAdventureID()});
			self:QuitBattle();
			return
		end
		
		if(dataManager.playerData:getVitality() < dataManager.playerData.stageInfo:getVigourCost() )then
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.VIGOR,-1,-1});
			self:QuitBattle();
			return
		end
		
		 
		sceneManager.battledata = {}
		eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})	
		sendBattle(battlePlayer.battleType, dataManager.playerData.stageInfo:getAdventureID(), 0);
		self.m_State = BATTLESTATE.BS_LEAVE;
		self:release();
	end	
	


end

function battlePlayer:isEndBattle()
	return self.m_State ==  BATTLESTATE.BS_END	or BATTLESTATE.BS_LEAVE == self.m_State 
end	


function battlePlayer:hideAlllCrops()
	
	if self.m_AllCrops then
		for _,v in pairs (self.m_AllCrops) do
			if(v)then
				v:hideCrops() 
			end		
		end	
	end
end	

		

function battlePlayer:endBattle(time )
	time = time or  2
	sceneManager.battledata = {}
	self.m_State =  BATTLESTATE.BS_END	
	--print(os.time().."---------------------解析完毕--判断出战斗已经结束--开始结束战斗")		
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLE_RECORD_REPLAY_END })
	if(	battlePlayer.rePlayStatus == true)then
	
		if(battlePlayer.guiderePlayStatus == true  )then
			sceneManager.battlePlayer():QuitBattle()
			return 
		end
		function onclickBattlePlayerReplay()
			global.changeGameState(function()
				sceneManager.battlePlayer():loadAndRePlayBattleRecord()
				local sceneInfo = dataConfig.configs.sceneConfig[battlePrepareScene.sceneID];
				if(sceneInfo)then
					engine.playBackgroundMusic(sceneInfo.music, true);
				end
			end);
			
		end
	
	
	eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = onclickBattlePlayerReplay
	 , callOnCancel = function() 
		sceneManager.battlePlayer():QuitBattle()
 
	end,text = "是否需要重播录像？" });	
 
		return  
	end
	
--[[
	local selfNum =0
	local enmyNum =	0
	
	for _,v in pairs (self.m_AllCrops) do
			if(v and v.m_bAlive)then		
				if(v:isFriendlyForces() == true)then
					selfNum = selfNum + 1
				else
					enmyNum = enmyNum + 1
				end					
			end		
	end
	
	local selfWin = false
	if(selfNum == 0)then
		selfWin = false
	elseif(enmyNum == 0)then 
		selfWin = true
	else
		selfWin = false
	end
	]]--
 
	function onendBattle()
		local selfWin = battlePlayer.win
		
		if(selfWin == nil)then
			return
		end
		if(battlePlayer.rePlayStatus == false)then
			if(self.mergedRewardList == nil)then
				return
			end
			
			if(battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
				if(not dataManager.hurtRankData:getServerResultOK())then
					return
				end	
			end
			
		end
		
		if(battlePlayer.delayWaitBattleResult)then
			scheduler.unscheduleGlobal(battlePlayer.delayWaitBattleResult)
			battlePlayer.delayWaitBattleResult = nil
		end
		
		
		if dataManager.playerData.stageInfo then
			--selfWin = dataManager.playerData.stageInfo:isWin()	
			for _,v in pairs (self.m_AllCrops) do
					if(v and v.m_bAlive and v.charmed == false and v:isFriendlyForces() == selfWin)then
						 v:enterStateWin()
					end		
			end	
		end

		local on_pve_endBattle = nil
		if battlePlayer.battleType ==  enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
			battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
				
		
			
			on_scheduler_endBattle = function() 
				self:hideAlllCrops()
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
				eventManager.dispatchEvent({name = global_event.CROPSINFOR_HIDE})
				eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})	
				if(selfWin == true)then
					eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_SHOW, stage = dataManager.playerData.stageInfo});		
				else
					eventManager.dispatchEvent({name = global_event.BATTLELOSE_SHOW, stage = dataManager.playerData.stageInfo});	
				end
			end
			print(os.time().."---------------------结束")		
			scheduler.performWithDelayGlobal(on_scheduler_endBattle, time)		
			
		elseif battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE then	
		
			on_scheduler_endBattle = function()
				self:hideAlllCrops()
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
				eventManager.dispatchEvent({name = global_event.CROPSINFOR_HIDE})
				eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})	
				if(selfWin == true)then
					eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_SHOW, stage = nil });
				else
					eventManager.dispatchEvent({name = global_event.BATTLELOSE_SHOW, stage = nil});	
				end												
				if(dataManager.pvpData:isOnlineOver())then	
					eventManager.dispatchEvent({name = global_event.PVPREWARD_SHOW})
				end	
			end	
				
				
			scheduler.performWithDelayGlobal(on_scheduler_endBattle, time)					
				
		elseif battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then
			on_scheduler_endBattle = function() 
				self:hideAlllCrops()
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
				eventManager.dispatchEvent({name = global_event.CROPSINFOR_HIDE})
				eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})	
				if(selfWin == true)then
					eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_SHOW, stage = nil });
				else
					eventManager.dispatchEvent({name = global_event.BATTLELOSE_SHOW, stage = nil});	
				end		
			end
			
			scheduler.performWithDelayGlobal(on_scheduler_endBattle, time)		
			
																	
		elseif battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then																	
			sceneManager.battlePlayer():QuitBattle();	
			eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})	
			eventManager.dispatchEvent({name = global_event.ACTIVITYDAMAGE_SHOW})
			if(battlePlayer.rePlayStatus == false )then
				eventManager.dispatchEvent({name = global_event.ACTIVITYDAMAGEAWARD_SHOW }) 
			end	
		
		elseif battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or
						battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
			
			sceneManager.battlePlayer():QuitBattle();
		
		elseif 	battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
		
			-- 弹出结算
			scheduler.performWithDelayGlobal( function()
			
				self:hideAlllCrops()
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
				eventManager.dispatchEvent({name = global_event.CROPSINFOR_HIDE})
				eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"});	
				eventManager.dispatchEvent({name = global_event.GUILDWARSCORE_SHOW, win = selfWin, isResult = true, });		

			end, time);
						
		else
		
			on_scheduler_endBattle = function() 
				self:hideAlllCrops()
				eventManager.dispatchEvent({name = global_event.BATTLE_UI_HIDE})
				eventManager.dispatchEvent({name = global_event.CROPSINFOR_HIDE})
				eventManager.dispatchEvent({name = global_event.LOADING_HIDE,userdate = "battlePlayer_SkipBattle"})	
				if(selfWin == true)then
					eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_SHOW, stage = nil });
				else
					eventManager.dispatchEvent({name = global_event.BATTLELOSE_SHOW, stage = nil});	
				end		
			end
			scheduler.performWithDelayGlobal(on_scheduler_endBattle, time)	
		end
			
	end	
	if(battlePlayer.delayWaitBattleResult)then
		scheduler.unscheduleGlobal(battlePlayer.delayWaitBattleResult)
		battlePlayer.delayWaitBattleResult = nil
	end
	battlePlayer.delayWaitBattleResult =  scheduler.scheduleGlobal(onendBattle, 0.1)

	
	
end

function battlePlayer:pauseGame(bpause)
	
	-- 镜头过程中不处理
	local isPlayingCamera = LORD.SceneManager:Instance():isPlayingCameraAnimate();
	if isPlayingCamera then
		return;
	end
	
	if(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).pause  == false)then
		return 
	end
 
	self.m_bPaused = bpause
	
	-- 检测指令的收到暂停的影响，恢复的时候需要清理一下
	if self.m_bPaused then
		actionSys.beginTime = nil;
	end
	 
	if self.m_AllCrops then
	   for _,v in pairs (self.m_AllCrops) do
			if(v and v:getActor())then
				 v:getActor():setActorPause(self.m_bPaused)
			end		
		end	
	end
  
	--print(self.m_bPaused )
end	

function battlePlayer:isPause(bpause)
	return self.m_bPaused
end

function battlePlayer:speedGame(scale)
	self.m_Scale = scale
	setClientVariable( "gameSpeed",	self.m_Scale );

	local actorManager = LORD.ActorManager:Instance()
	local speed = self:getSpeed()
	actorManager:SetSpeedUp(speed)
	if(speed == SPEED_UP_GAME[3])then
		LORD.SceneManager:Instance():enableCameraShake(false);	
	end
end

function battlePlayer:getAutoBattle( )
	return getClientVariable("AutoBattle",false) == "true"	
end
 

function battlePlayer:setAutoBattle( auto )
	self.AutoBattle = auto
	setClientVariable("AutoBattle",self.AutoBattle)	
	
	if(self.turn_self_caster_magic == true)then	
		if(self:getAutoBattle() == true)then
			castMagic.autoKingSkill()
		end
	end	
	
end

-- 获取当前速度的档位1,2,3,对应的摄像机概率参数
function battlePlayer:getCameraRadio()

	local t = SPEED_UP_GAME;	
	local speed = self:getSpeed();
	local index = table.keyOfItem(t,speed);
	
	local shiftRatio = 0.0;
	if index == 1 then
		shiftRatio = 1.0;
	elseif index == 2 then
		shiftRatio = 0.5;
	elseif index == 3 then
		shiftRatio = 0.0;
	end
	
	return shiftRatio;
end

function battlePlayer:getSpeed()
	return tonumber(getClientVariable( "gameSpeed", SPEED_UP_GAME[1]))

end	

function battlePlayer:getWorldPostion(logicX ,logicY)
	local ret =   LORD.Vector3(battlePrepareScene.centerPosition.x,battlePrepareScene.centerPosition.y,battlePrepareScene.centerPosition.z)
	ret.x =  ret.x + (logicX-battlePrepareScene.centerX)*battlePrepareScene.hexagonWidth
	ret.z = ret.z+ (logicY-battlePrepareScene.centerY)*0.75*battlePrepareScene.hexagonHeight
	if(math.abs(logicY - battlePrepareScene.centerY)%2 == 1)then	
	  ret.x = ret.x +  battlePrepareScene.hexagonWidth*0.5
	end

	return ret
end	

-- 获得要行动的军团
function battlePlayer:getActionCrops()
		 for i,v in ipairs (self.actionList) do			
				if(self.m_AllCrops[v._id])then				
					return self.m_AllCrops[v._id],i				
				end 									
		 end
		return nil
end	

-- 战斗展示

function battlePlayer:playOverACList()
	
		if(battlePlayer.rePlayStatus == true )then
			--return 
		end

		if(false == self.wait_action)then
				self.wait_action = true
				
				if(self.turn_self_caster_magic == true)then
					self.selecMagic  = nil
					self:playActionAnimate(true)
					print("auto ")print(self:getAutoBattle())
					if(self:getAutoBattle() == true)then
						castMagic.autoKingSkill()
					else
						eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_SKILL, notFlip = (self.m_RoundNum == 0) });	
						eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_SKILL_ROUND, show = true,self = true});	
					end
					self.trunMagicNum = 	self.trunMagicNum + 1
					eventManager.dispatchEvent( {name = global_event.GUIDE_ON_BATTLE_RECORD_TURN_SELF_MAGIC, arg1 = self.trunMagicNum } )
				else
					print("---------------------------等待对方施法")	
					eventManager.dispatchEvent({name = global_event.BATTLE_UI_SWITCH_TO_SKILL_ROUND,show = true,self = false});	
				end			
		end					
end	



function battlePlayer:doBattle(dt)
		
		-- 等待魔法表现的完成
		if self:getWaitMagicMovieFlag() then
			return;
		end
											
		--当前序列播放完毕（战斗还没完毕），等待后续指令。
		battleKingSkillAi.Tick(dt)
		if(self.wait_action)then
			self:_tickAllorOtherCrops(dt,true)
			return 
		end					
		
		-- 当前有还没执行完毕的action
		
		if(actionSys.Tick(dt) == false)then		
			self:_tickAllorOtherCrops(dt,self.m_CurrentCrops == nil)	
			return 
		end		

		if(self.newRoundAction)then -- 不是开始
			 battlePlayer.ACTON_END_TIME = battlePlayer.ACTON_END_TIME + dt
			if(battlePlayer.ACTON_END_TIME < battlePlayer.ACTION_TIME_SPACE )then		
				self:_tickAllorOtherCrops(dt,true)	
				return				
			end
		end

		self.newRoundAction = false			
		battlePlayer.ACTON_END_TIME = 0			
		self.m_CurrentCrops = nil	
		
		-- 去得第一条行动指令，没有就结束了
		local action = self.actionList[1]		
		if(action == nil)then			
			table.remove(sceneManager.battledata,1)
			local nums = table.nums(sceneManager.battledata)	
			print("del sceneManager.battledata  now num"..nums)	
			self.actionListPlayEnd = true
			if(nums ==0)then
				self:playOverACList()
				return
			else
				self:parseData(sceneManager.battledata)		
				return		
			end				
		end			
	
		--if(self.m_UiOrderTranslationed == false)then					
		--	self:_tickAllorOtherCrops(dt,true)				
		--	return 
		--end
		
		-- check
		--print("self.m_RoundNum "..self.m_RoundNum.." action.round "..action.round );
		
		--[[
		if battlePlayer.rePlayStatus == false then
			if action.round ~= self.m_RoundNum then
				--print("------------------------147");
				for k, v in pairs (self.m_AllCrops) do
					hpMonitor.checkUnit(action.round, v);
				end
			end
		end
		--]]
		
		-- 国王魔法的行动回合计算
		if action.round ~= self.m_RoundNum then
			self:onNextRoundBegin();
		end
		
		self.m_RoundNum = action.round			
		 print(string.format(" play RoundNum [%d] caster:[%d] action._type[%d] .........................",self.m_RoundNum, action._id, action._type))

		table.remove(self.actionList,1)
							
		if action._type == ACTION_TYPE.MAGIC then
			self.currentAction = action;
			self:setWaitMagicMovieFlag(true);
			eventManager.dispatchEvent( { name  = global_event.MAGICMOVIE_SHOW, force = action._id, magicid = action._param.skillid });
		else
			self.ac = actionSys.Play(action)
		end
										
end

function battlePlayer:goOnPlayAction()
	if self.currentAction then
		self.ac = actionSys.Play(self.currentAction)
		self.currentAction = nil;
	end
end

function battlePlayer:setWaitMagicMovieFlag(flag)
	self.waitMagicMovie = flag;
end

function battlePlayer:getWaitMagicMovieFlag()
	return self.waitMagicMovie;
end

-- 回合开始
function battlePlayer:onNextRoundBegin()
	--print("onNextRoundBegin self.nextMagicRound "..self.nextMagicRound);
	self.nextMagicRound = self.nextMagicRound - 1;
end

function battlePlayer:_tickAllorOtherCrops(dt,all)
	
	local current = self.m_CurrentCrops
	if(all)then
		current = nil
	end
	if(self.m_AllCrops)then
		for _,v in pairs (self.m_AllCrops) do
				if( v ~= current)then
					v:logic(dt)		
				end		
		end		
	end	
end




-----  没有参数
function battlePlayer:_playLock(action)
	self.m_CurrentCrops:enterStateLocked()
	-- 战斗记录
	battleRecord.pushLock(self.m_CurrentCrops);	
end	

--
function battlePlayer:_playMove(action)
	
	--dump(action);
		
	local t = {}

	for i = 1 ,action._param.pointNum do	
		table.insert(t,action._param.points[i] )			
	end		
	self.m_CurrentCrops:setMoveFlag(action._param.moveFlag)
	self.m_CurrentCrops:enterStateMoving(t,action._param.skills)	
	
	-- 战斗记录
	if action._param.pointNum >=1 then
		battleRecord.pushMoveRecord(self.m_CurrentCrops, 
																self.m_CurrentCrops.m_PosX, 
																self.m_CurrentCrops.m_PosY, 
																action._param.points[tonumber(action._param.pointNum)].x,
																action._param.points[tonumber(action._param.pointNum)].y);
	end
end

function battlePlayer:_playAttack(action)
 
	self.m_CurrentCrops:enterStateAttack(action._param.targets)		
	-- 战斗记录
	battleRecord.pushAttackRecord(self.m_CurrentCrops);
end

function battlePlayer:_playAttackBack(action)
	self.m_CurrentCrops:enterStateAttackBack(action._param.targets)
	-- 战斗记录
	battleRecord.pushRetaliate(self.m_CurrentCrops);	
end
 
function battlePlayer:_handleBuffer(action)
	self.m_CurrentCrops:enterHandlerBuffer( action )						
end

function battlePlayer:_delBuffer(action)
 	self.m_CurrentCrops:enterStateDelBuffer(action._param.bufferId, action._param.buffInnerCasterIndex);
end

function battlePlayer:createSUMMONcrops(action,force)	
		 local _param = action[1]
         local config =  cropData:getCropsGonfig(_param.m_targetID);			
		 local crops = objectManager.CreateCropsUnit(config.resourceName)	
		 crops:SetSummoned(true)	
		 
		 crops:initCrops(_param.m_targetID, _param.m_x, _param.m_y, _param.m_count, force , _param.m_targetIndex);	
 
		 crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK, _param.shipAttack);
		 crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE, _param.shipDefence);
		 crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL, _param.shipCritical);
		 crops:setShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE, _param.shipResilience);		
				
		 self.m_AllCrops[crops.index]  = crops;
		 return self.m_AllCrops[crops.index];
end


function battlePlayer:_playSkill(action)		
		self.m_CurrentCrops = self.m_AllCrops[action._id]
		
		-- 战斗记录
		local skillInfo = dataConfig.configs.skillConfig[action._param.skillid];
		if skillInfo and skillInfo.name then
			battleRecord.pushSkill(self.m_CurrentCrops, skillInfo.name);
		end
		
		self.m_CurrentCrops.m_Targets = {}
		self.m_CurrentCrops.m_TargetsDamage = {}					
		self.m_CurrentCrops:enterSkill(action)
end

function battlePlayer:_playMagic(action)
		self.casterKing.m_Targets = {}
		self.casterKing.m_TargetsDamage = {}			
		
		-- 战斗记录
		local magiceInfo = dataConfig.configs.magicConfig[action._param.skillid];
		if magiceInfo and magiceInfo.name then
			battleRecord.pushMagic(magiceInfo.name, action._id);
		end
		
		self.casterKing:enterSkill(action)	
end

function battlePlayer:_playSUMMON(action)
	if(action._param.summon_source == enum.SOURCE.SOURCE_MAGIC)then			
		self.casterKing:enterSkill(action)	
		
	elseif(action._param.summon_source == enum.SOURCE.SOURCE_SKILL)then	
		self.m_CurrentCrops = self.m_AllCrops[action._id]										
		self:signGrid(self.m_CurrentCrops.m_PosX,self.m_CurrentCrops.m_PosY,"b")	
		self.m_CurrentCrops:enterSkill(action)	 				
	end			
end

function battlePlayer:reviveTarget(_target)
	if(_target.revive_source ==  enum.SOURCE.SOURCE_MAGIC)then							
		self.casterKing:reviveTarget(_target)
	 else
		self.m_CurrentCrops = self.m_AllCrops[_target.casterId]							
		self.m_CurrentCrops:reviveTarget(_target)
	 end		
 
end	




function battlePlayer:SkipBattle(argu)
	self.skipBattle = argu
	if(self.skipBattle and self.skipBattleMagicSendBack == false)then
		sceneManager.battlePlayer():endBattle(0);
		 return 
	end
	if(self.skipBattle)then
		eventManager.dispatchEvent({name = global_event.LOADING_SHOW, userdate = "battlePlayer_SkipBattle"})	
		self:setAutoBattle(false)
		self:pauseGame(true);
	end	
end

function battlePlayer:getSkipBattle()
	return self.skipBattle or false
end

function battlePlayer:_playDead(action)
	self.m_CurrentCrops:enterStateDead(action._param.deadFlag)	
end

function battlePlayer:_AttributeChange(action)
	--print("battlePlayer:_AttributeChange target:"..action._param.target.." type "..action._param.attrType.." value "..action._param.attrValue);
	
	if(action._param.targetType == enum.ATTR_TARGET_TYPE.ATTR_TARGET_TYPE_UNIT) then
	
		local actionUnit = self.m_AllCrops[action._param.target];
		if actionUnit then
			actionUnit:setAttributeAll(action._param.typeIndex,action._param.attrType, action._param.attrValue);	
		end
	elseif(action._param.targetType == enum.ATTR_TARGET_TYPE.ATTR_TARGET_TYPE_KING) then
	 
		local king = nil   --    action._param.target == battlePlayer.force 
		local force = action._param.target
			king = dataManager.battleKing[force]
		 
		if(king)then		
			local value = action._param.attrValue 
			if(action._param.attrType == enum.KING_ATTR.KING_ATTR_MP )then -- 魔法值
				king:setMp(value)
			elseif(action._param.attrType == enum.KING_ATTR.KING_ATTR_INTELLIGENCE )then-- 智力   可以忽略客户端自己查表
				king:setIntelligence(value)
			elseif(action._param.attrType == enum.KING_ATTR.KING_ATTR_LEVEL )then -- 等级
				king:setLevel(value)
			elseif(action._param.attrType == enum.KING_ATTR.KING_ATTR_MAX_MP )then -- 魔法上限
				king:setMpMax(value)
			elseif(action._param.attrType == enum.KING_ATTR.KING_ATTR_COST_RATIO )then -- -- 魔法值消耗比
				king:setCasterMPRate(value)	
			end
			eventManager.dispatchEvent({name = global_event.BATTLE_KING_ATTR_SYNC,  force = force })	
		end		
	end
end

-- 根据当前的军团信息，计算出国王魔法需要的回合数
function battlePlayer:getMagicRound()
	-- 不包括召唤单位
	local unitCount = 0;
	for k,v in pairs(self.m_AllCrops) do
		if v.m_bAlive == true then
			unitCount = unitCount + 1;
		end
	end
	
	local round = 0;
	local tableRowMaxNum = table.nums(dataConfig.configs.magicRoundConfig);
	local magicRound = dataConfig.configs.magicRoundConfig[unitCount];
	if magicRound then
		round = magicRound.round;
	else
		round = dataConfig.configs.magicRoundConfig[tableRowMaxNum-1].round;
	end
	
	return round;
end

-- 计算行动序列self.m_ActionOrder
-- 这里所有的unit应该reset roundtime
-- deleteHead 表示是不是删掉第一个，目前的逻辑是当下一个行动开始的时候，删掉头上的这个
-- calcRound 计算的回合数
function battlePlayer:calcAllActionOrder(deleteHead, calcRound)
	
	calcRound = calcRound or 14
	--print("calcAllActionOrder deleteHead "..tostring(deleteHead));
	self.m_LastActionOrder = clone(self.m_ActionOrder);
	
	self.m_ActionOrder = nil;
	self.m_ActionOrder = {};
	
	self.m_TempUnits = nil;
	self.m_TempUnits = {};
	
	-- 生成一个临时的拷贝
	-- 因为需要计算多个回合的
	for i=0, table.nums(self.m_AllCrops)-1 do
		local v = self.m_AllCrops[i];
		--print("m_AllCrops i "..i.." index "..v.index.." speed "..v.m_ActionSpeed);
		self.m_TempUnits[i] = {
			['m_bAttacker'] = v:isAttacker(),
			['m_leftTime'] = v.m_leftTime,
			['m_bAlive'] = v.m_bAlive,
			['m_ActionSpeed'] = v.m_ActionSpeed,
			['m_roundTime'] = v.m_roundTime,
			['index'] = v.index,
			['m_PosX'] = v.m_PosX,
			['m_PosY'] = v.m_PosY,
		};
	end
	
	if #self.m_TempUnits == 0 then
		return;
	end
	
	--dump(self.m_TempUnits);
	local tempLastForce = self.m_lastConflictForce;
	
	-- 魔法回合
	local magicRound = self:getMagicRound();
	--nextMagicRoundTurnForce
	--nextMagicRound
	
	-- 计算一轮calcRound个显示的
	-- i 表示的是行动序列的索引
	-- 下次进攻方魔法的回合 由于序列从1开始，所以要加1
	local nextFirstMagicRound = self.nextMagicRound + 1;
	local nextSecondMagicRound = self.nextMagicRound + 2;
	local nextFirstMagicIsFriendly = self.nextMagicRoundTurnForce == battlePlayer.force;
	local nextSecondMagicIsFriendly = global.oppsiteForce(self.nextMagicRoundTurnForce) == battlePlayer.force;
	
	--print("nextFirstMagicRound "..nextFirstMagicRound);
	
	for i=1, calcRound do
		
		if i == nextFirstMagicRound then
			-- 先手方放魔法
			self.m_ActionOrder[i] = {};
			self.m_ActionOrder[i].isFriendlyForce = nextFirstMagicIsFriendly;
			self.m_ActionOrder[i].index = -1;

			-- 更新下一次魔法回合的数据
			nextFirstMagicRound = nextFirstMagicRound + magicRound + 1;
			nextFirstMagicIsFriendly = not nextFirstMagicIsFriendly;
		
		--[[
		elseif i == nextSecondMagicRound then
			-- 后手方放魔法
			self.m_ActionOrder[i] = {};
			self.m_ActionOrder[i].isFriendlyForce = nextSecondMagicIsFriendly;
			self.m_ActionOrder[i].index = -2;
			
			-- 更新下一次魔法回合的数据
			nextSecondMagicRound = nextSecondMagicRound + magicRound + 2;
			nextFirstMagicRound = nextFirstMagicRound + magicRound + 2;
			nextSecondMagicIsFriendly = not nextSecondMagicIsFriendly;
			nextFirstMagicIsFriendly = not nextFirstMagicIsFriendly;
		--]]
			
		else
			-- 计算军团的序列
			self.m_ActionOrder[i], self.m_lastConflictForce = battlePlayer._selectUnit(self.m_TempUnits, self.m_lastConflictForce);
			
			--print("selectunit  i "..i.." index "..self.m_ActionOrder[i].index);
			
			-- 把临时拷贝中的时间重新计算一下
			for k,v in pairs (self.m_TempUnits) do
				if( v ~= nil and v ~= self.m_ActionOrder[i]) then
					v.m_leftTime = v.m_leftTime-self.m_ActionOrder[i].m_leftTime;
				end
			end
			
			if i==1 and deleteHead then
				-- 原来的数据中只走了一个回合
				for k,v in pairs (self.m_AllCrops) do
					if( v ~= nil and v.index ~= self.m_ActionOrder[1].index and v.m_bAlive ) then
						v.m_leftTime = v.m_leftTime-self.m_ActionOrder[1].m_leftTime;
					end
				end
				
				self.m_AllCrops[self.m_ActionOrder[1].index]:resetRoundTime();
				
				-- 标志位被修改了，保存一份第一回合的修改
				tempLastForce = self.m_lastConflictForce;
				
			end
				
			self.m_ActionOrder[i].m_leftTime = self.m_ActionOrder[i].m_roundTime;			
		end			
	end
	
	-- 恢复到计算第一个时候的结果
	self.m_lastConflictForce = tempLastForce;
	
	--print("round ,"..self.m_RoundNum.."  m_lastConflictForce  "..tostring(self.m_lastConflictForce));
	if self.m_ActionOrder[1] and self.m_LastActionOrder[1] and self.m_LastActionOrder[1].index == self.m_ActionOrder[1].index then
		-- 不需要通知ui变化
		return false;
	else
		return true;
	end
	--dump(self.m_ActionOrder);
end

function battlePlayer._selectUnit(units, lastConflictForce)
	--找到alive中left time最小的元素
	local minTime		= 0x7FFFFFF;
	local minIndex	= -1;
	for i=0, table.nums(units)-1 do
		local v = units[i];
		if( v ~= nil and v.m_bAlive and v.m_leftTime < minTime)then
			minTime = v.m_leftTime;
			minIndex = i;
		end
	end	
	
	--dump(units);
	--print("minIndex  "..minIndex);
	--将alives中多个最小元素添加到minUnits中
	local minUnits = {};
	local index = 1;
	for i = minIndex, table.nums(units)-1 do
		local v = units[i];
		if( v ~= nil and v.m_bAlive and v.m_leftTime == minTime)then
			minUnits[index] = units[i];
			index = index + 1;
		end
	end
	
	--dump(minUnits);
	
	if ((#minUnits) == 0) then
		return nil, lastConflictForce;
	end
	
	if ((#minUnits) == 1) then
		lastConflictForce = false;
		return minUnits[1], lastConflictForce;
	end

	--下面，对于left time相同的单位，进行优先级比较
	local actorIndex = -1;
	local priority = -1;
	
	local actorIndexBackup = -1;
	local priorityBackup = -1;
	
	for i=1, #minUnits do
		if minUnits[i].m_bAttacker == (not lastConflictForce) then
			local tempPriority = battlePlayer._movePriority(minUnits[i]);
			if tempPriority > priority then
				priority = tempPriority;
				actorIndex = i;
			end
		else
			local tempPriorityBackup = battlePlayer._movePriority(minUnits[i]);
			if tempPriorityBackup > priorityBackup then
				priorityBackup = tempPriorityBackup;
				actorIndexBackup = i;
			end
		end
	end
	
	if actorIndex == -1 then
		actorIndex = actorIndexBackup;
	end
	
	if (#minUnits > 1) then--发生了冲突，要将lastConflict置反
		lastConflictForce = not lastConflictForce;
	end
	
	return minUnits[actorIndex], lastConflictForce;
end

mapMovePriorityOffence = {
	['0,0'] = 3,
	['0,1'] = 1,
	['0,2'] = 2,
	
	['1,0'] = 6,
	['1,1'] = 4,
	['1,2'] = 5,
	
	['2,0'] = 9,
	['2,1'] = 7,
	['2,2'] = 8,
	
	['3,0'] = 12,
	['3,1'] = 10,
	['3,2'] = 11,
	
	['4,0'] = 15,
	['4,1'] = 13,
	['4,2'] = 14,
	
	['5,0'] = 18,
	['5,1'] = 16,
	['5,2'] = 17,
	
	['6,0'] = 0,
	['6,1'] = 19,
	['6,2'] = 0,
}

mapMovePriorityDefence = {
	['0,0'] = 18,
	['0,1'] = 19,
	['0,2'] = 17,
	
	['1,0'] = 15,
	['1,1'] = 16,
	['1,2'] = 14,
	
	['2,0'] = 12,
	['2,1'] = 13,
	['2,2'] = 11,
	
	['3,0'] = 9,
	['3,1'] = 10,
	['3,2'] = 8,
	
	['4,0'] = 6,
	['4,1'] = 7,
	['4,2'] = 5,
	
	['5,0'] = 3,
	['5,1'] = 4,
	['5,2'] = 2,
	
	['6,0'] = 0,
	['6,1'] = 1,
	['6,2'] = 0,
}

-- 查表确定优先级
function battlePlayer._movePriority(unit)
	
	if unit.m_bAttacker then
		--print("_movePriority x "..unit.m_PosX.." y "..unit.m_PosY.." m "..mapMovePriorityOffence[unit.m_PosX..","..unit.m_PosY]);
		return mapMovePriorityOffence[unit.m_PosX..","..unit.m_PosY];
	else
		return mapMovePriorityDefence[unit.m_PosX..","..unit.m_PosY];
	end
end

function battlePlayer:playActionAnimate(magic)
	do
		return 
	end	

	local  CamAnim = "topToBack.camAnim"
	if(magic)then
		CamAnim = "backToTop.camAnim"
		if(self.firstMgic == nil)then
			self.firstMgic = true
			return 
		end
	end	
	
	if(self.preAnimate == CamAnim)	then
	 	return 
	end
	self.preAnimate = CamAnim
	local scene = 	sceneManager.scene 
	local ani = scene:importCameraAnimation(CamAnim)
	--local time = ani:getTotalTime()*1000	
	if(ani)then	
		ani:play()	 	
	end
end
