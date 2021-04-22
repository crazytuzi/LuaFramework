local QSBAction = import(".QSBAction")
local QSBReviveMograine = class("QSBReviveMograine", QSBAction)

local QBaseEffectView
if not IsServerSide then
	QBaseEffectView = import("...views.QBaseEffectView")
end
local QUIWidgetBattleTutorialDialogue
if not IsServerSide then
	QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
end

-- 这个技能只用来复活莫格莱尼，走向莫格莱尼，复活莫格莱尼，取消群体睡眠的过程 (不包含群体睡眠的释放)
-- 注意，莫格莱尼的尸体不消失在QBattleManager处理
function QSBReviveMograine:ctor(director, attacker, target, skill, options)
	QSBReviveMograine.super.ctor(self, director, attacker, target, skill, options)
	-- 睡眠buff
	self._startBuff = self._options.startBuff
	-- 复活后上的buff
	self._endBuff = self._options.endBuff
	-- 复活时的施法者的施法动作
	self._startAnimation = self._options.startAnimation
	-- 复活后的被复活者的起身动作
	self._endAnimation = self._options.endAnimation
	-- 复活的时间
	self._reviveTime = self._options.reviveTime
	-- 开始攻击的时间
	self._attackTime = self._options.attackTime
	-- 是否改变血量
	self._isChangeHp = self._options.isChangeHp
	-- 改变血量的基数
	self._coef = self._options.coef
	-- 复活角色ActorID
	self._reviveActorID = self._options.reviveActorID
end

function QSBReviveMograine:_execute(dt)
	local actor = self._attacker
	if self._set ~= true then
		local mates = app.battle:getEnemies()
		local mograine = nil
		for _, mate in ipairs(mates) do
            -- TOFIX-CHARACTER
            -- 要复活的怪的actor ID
			if mate:isDead() and mate:getActorID() == self._reviveActorID then
				mograine = mate
				self._mograine = mograine
				break
			end
		end

		if mograine == nil then
			if not app.battle:isInRebelFight() then
				-- 自己找中文替换    GetLuaLocalization("QSBReviveMograine_wordKey_1")
				assert(false, GetLuaLocalization("QSBReviveMograine_wordKey_1"))
			end

			local heros = app.battle:getHeroes()
			if nil ~= self._startBuff then
				for _, hero in ipairs(heros) do
					hero:removeBuffByID(self._startBuff)
					if hero:getHunterPet() then
						hero:getHunterPet():removeBuffByID(self._startBuff)
					end
				end
			end

			self:finished()
			return
		end
		self._prevTarget = actor:getTarget()
		actor:setTarget(mograine)
		actor:setManualMode(actor.STAY)
		app.grid:moveActorToTarget(actor, mograine, false, false)
		self._mograine:setIsReviving(true)
		self._set = true
	else
		local dist = q.distOf2Points(app.grid:_toScreenPos(actor.gridPos), actor:getPosition())
		if self._revived ~= true and dist < 24 and not actor:isWalking() then
			if not IsServerSide and nil ~= self._startAnimation and self._startAnimation ~= "" then
			    app.battle:performWithDelay(function()
			    --     self._dialogueRight = QUIWidgetBattleTutorialDialogue.new({isLeftSide = false, text = GetLuaLocalization("QSBReviveMograine_wordKey_2"), name = GetLuaLocalization("QSBReviveMograine_wordKey_3")})
			    --     -- 对话头像
			    --     self._dialogueRight:setActorImage("ui/maien.png")
			    --     app.scene:addChild(self._dialogueRight)
			    --     app.scene:hideHeroStatusViews()
			    --     -- 对话时的音效
			    --     app.sound:playSound("HighInquisitorWhitemaneRes01");

			        local enemyView = app.scene:getActorViewFromModel(actor)
			        enemyView._animationQueue = {self._startAnimation, ANIMATION.STAND}
			        enemyView:_changeAnimation()
			    end, 0.0, self._attacker)
			end

			-- if not IsServerSide then
			--     app.battle:performWithDelay(function()
			--         local enemy = self._mograine
		 --            local 	 = app.scene:getActorViewFromModel(enemy)
		 --            -- 播放的特效
		 --            local frontEffect, backEffect = QBaseEffectView.createEffectByID("monster_born_3", actorView)
		 --            if frontEffect then
		 --                actorView:getSkeletonActor():attachNodeToBone(DUMMY.BODY, frontEffect, false)
		 --                frontEffect:playAnimation(EFFECT_ANIMATION, false)
		 --                frontEffect:playSoundEffect(false)
		 --                frontEffect:afterAnimationComplete(function()
		 --                    actorView:getSkeletonActor():detachNodeToBone(frontEffect)
		 --                end)
		 --            end
		 --            local frontEffect, backEffect = QBaseEffectView.createEffectByID("monster_born_3_1", actorView)
		 --            if frontEffect then
		 --                actorView:getSkeletonActor():attachNodeToBone(DUMMY.BODY, frontEffect, false)
		 --                frontEffect:playAnimation(EFFECT_ANIMATION, false)
		 --                frontEffect:playSoundEffect(false)
		 --                frontEffect:afterAnimationComplete(function()
		 --                    actorView:getSkeletonActor():detachNodeToBone(frontEffect)
		 --                end)
		 --            end
		 --            local frontEffect, backEffect = QBaseEffectView.createEffectByID("monster_born_3_2", actorView)
		 --            if backEffect then
		 --                actorView:getSkeletonActor():attachNodeToBone(DUMMY.BODY, backEffect, true)
		 --                backEffect:playAnimation(EFFECT_ANIMATION, false)
		 --                backEffect:playSoundEffect(false)
		 --                backEffect:afterAnimationComplete(function()
		 --                    actorView:getSkeletonActor():detachNodeToBone(backEffect)
		 --                end)
		 --            end
			--         self._dialogueRight:removeFromParent()
			--         app.scene:showHeroStatusViews()
			--     end, 2.0, self._attacker)
			-- end

		    app.battle:performWithDelay(function()
		    	if not IsServerSide then
			        -- self._dialogueRight = QUIWidgetBattleTutorialDialogue.new({isLeftSide = false, text = GetLuaLocalization("QSBReviveMograine_wordKey_4"), name = GetLuaLocalization("QSBReviveMograine_wordKey_5")})
			        -- self._dialogueRight:setActorImage("ui/gelaini.png")
			        -- app.scene:addChild(self._dialogueRight)
			        -- app.scene:hideHeroStatusViews()
			        -- app.sound:playSound("ScarletCommanderMograineAtRest01")
			    end
                if self._attacker:isDead() then
                    return
                end
                
	        	local enemy = self._mograine
		        local position = enemy:getPosition()
		        enemy:resetStateForBattle(true)
		        enemy:setActorPosition(position)
		        enemy:setTarget(nil)

		        local value = enemy:getMaxHp()
		        if self._isChangeHp then
                    local coef = self._coef + enemy:getReviveCount() - 1
		        	value = value / coef
                end
		        --[[enemy._hpValidate:set(value)
		        enemy._hp = value
		        enemy._hpBeforeLastChange = enemy:getMaxHp()]]
                enemy:setHp(value)
		        enemy:setManualMode(actor.STAY)

		        -- 莫格莱尼的AI重置
		        app.battle:reloadActorAi(enemy)
   		        self._mograine:setIsReviving(false)

		        if not IsServerSide and nil ~= self._endAnimation and self._endAnimation ~= "" then
			        local enemyView = app.scene:getActorViewFromModel(enemy)
			        enemyView._animationQueue = {self._endAnimation, ANIMATION.STAND}
			        enemyView:_changeAnimation()
			    end

				actor:setTarget(self._prevTarget)
		    end, self._reviveTime, self._attacker)

		    app.battle:performWithDelay(function()
                if self._attacker:isDead() then
                    return
                end
	        	local enemy = self._mograine

				actor:setManualMode(actor.AUTO)
		        enemy:setManualMode(actor.AUTO)

		        if nil ~= self._startBuff then
					local heros = app.battle:getHeroes()
					for _, hero in ipairs(heros) do
						hero:removeBuffByID(self._startBuff)
						if hero:getHunterPet() then
							hero:getHunterPet():removeBuffByID(self._startBuff)
						end
					end
				end

				-- 给吕布上一个buff
				if nil ~= self._endBuff then
					enemy:applyBuff(self._endBuff, enemy)
				end

				-- if not IsServerSide then
			 --        self._dialogueRight:removeFromParent()
			 --        app.scene:showHeroStatusViews()
			 --    end		        
		        self:finished()
		    end, self._attackTime, self._attacker)

	        self._revived = true
    	end
	end
end

function QSBReviveMograine:_onCancel()
	if nil == self._startBuff then
		return
	end

	local heros = app.battle:getHeroes()
	for _, hero in ipairs(heros) do
		hero:removeBuffByID("shuimian_debuff")
	end
end

return QSBReviveMograine
