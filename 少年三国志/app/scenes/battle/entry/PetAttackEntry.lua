require "app.cfg.play_info"
require "app.cfg.skill_info"

local Entry 			= require("app.scenes.battle.entry.Entry")
local ActionEntry 		= require "app.scenes.battle.entry.ActionEntry"
local PetSkillNameEntry = require("app.scenes.battle.entry.PetSkillNameEntry")
local BattleFieldConst 	= require("app.scenes.battle.BattleFieldConst")
local SoundManager 		= require("app.sound.SoundManager")

local PetAttackEntry = class("PetAttackEntry", require("app.scenes.battle.entry.AttackEntry"))

function PetAttackEntry:initEntry()
	PetAttackEntry.super.super.initEntry(self)

	local attack 		= self._data		-- attack data
	local knights		= self._objects		-- knights
	local battleField	= self._battleField	-- battle layer
	local skill_id		= rawget(attack, "skill_id")
	self._playInfo		= play_info.get(10, skill_id)
	self._isPetAttack	= true

	-- 哪一方的宠物在攻击
	local pet = battleField:getPets()[attack.identity]
	self._pet = pet

	-- 施放技能
	if skill_id then
		local skillInfo = skill_info.get(attack.skill_id)
		local skillType = skillInfo.skill_type

		-- 如果是大招，添加一个黑底层
		if skillType == BattleFieldConst.SKILL_PET_ACTIVE then
			self._blackLayer = CCLayerColor:create(ccc4(0,0,0,255*0.7), display.width, display.height + 30)
			self._battleField:addToPetAttackNode(self._blackLayer, -99999)
		end

		-- 战宠虚影移至武将上层,如果是大招，把受击者也移到上层
		self:addEntryToQueue(nil, function()
										pet:moveToLayer(battleField:getPetAttackNode())
										if skillType == BattleFieldConst.SKILL_PET_ACTIVE then
											self:moveVictimsToLayer(attack.skill_victims, battleField:getPetAttackNode())
										end
										return true
								  end,
							 nil, pet)

		-- 虚影移出
		local checkAttackBegin = nil
		self:addEntryToQueue(nil, function() 
										checkAttackBegin = checkAttackBegin or pet:playOut(nil, skillType)
										return checkAttackBegin()
								  end,
						     nil, pet)

		-- 战宠实体开始攻击，区分普通攻击和大招
		local checkAttackFinish = nil
		local attackHandler = handler(self, self.onAttackerEvent)
		if skillType == BattleFieldConst.SKILL_PET_NORMAL then
			self:addEntryToQueue(nil, function()
											if not checkAttackFinish then
												checkAttackFinish = pet:playAttack(attackHandler) 
											end
											return checkAttackFinish()
								      end,
							 	 nil, pet)
		else
			local entrySet = Entry.new()

			-- 大招技能
			entrySet:addEntryToNewQueue(nil, function()
												if not checkAttackFinish then
														checkAttackFinish = pet:playCont(attackHandler)
												end
												return checkAttackFinish()
								  		 end)

			-- 技能文字
			local tweenJsonName = "battle/tween/tween_pet_skillname.json"
			local skillNameEntry = PetSkillNameEntry.new(tweenJsonName, attack, nil, battleField)
			entrySet:addEntryToNewQueue(skillNameEntry, skillNameEntry.updateEntry)

			self:addEntryToQueue(entrySet, entrySet.updateEntry, nil, pet)
		end

		-- 如果是大招，去掉黑底，并将受击者移回下层
		if skillType == BattleFieldConst.SKILL_PET_ACTIVE then
			self:addOnceEntryToQueue(nil, function() 
												self._blackLayer:removeFromParent()
												self._blackLayer = nil
												self:moveVictimsToLayer(attack.skill_victims, battleField:getCardNode())
												return true
										  end,
								     nil, pet)

		end

		-- 战宠虚影移回下层出现
		self:addOnceEntryToQueue(nil, function() 
											pet:moveToLayer(battleField:getPetShadowNode())
											pet:playAppear()
											return true
									  end, 
							     nil, pet)
	end
end

function PetAttackEntry:moveVictimsToLayer(victims, newLayer)
	local knights = self._objects
	for i = 1, #victims do
		local victim = victims[i]
		local knight = knights[victim.identity][tostring(victim.position + 1)]
		if knight then
			local order = knight:getZOrder()
			knight:retain()
			knight:removeFromParent()
			newLayer:addChild(knight, order)
			knight:release()
		end
	end
end

function PetAttackEntry:onAttackerEvent(event, target, frameIndex)
	self.super.onAttackerEvent(self, event, target, frameIndex)

	-- 战宠乌龟的大招是纯加Buff，并且是在hit事件时播放buff而不是技能结束时，因此这里特殊处理一下
	if string.match(event, "hit") then
		local attack 		= self._data		-- attack data
		local knights		= self._objects		-- knights
		local battleField	= self._battleField	-- battle layer

		local buffEntry = Entry.new()
		local hitActions = {}
    	for i=1, #attack.buff_victims do
        	local victim = attack.buff_victims[i]
        	if victim.identity == attack.identity then
        		-- buff效果
            	local knight = knights[victim.identity][tostring(victim.position+1)]
            	buffEntry:addOnceEntryToQueue(nil, function()
                	knight:addBuff(victim)
                	return true
            	end, nil, knight)

            	-- 受击动作
            	-- PS：在同一个武将上可能有连着N个Buff效果，但是受击动作只播一次
            	if not hitActions[knight] then
            		local hitActionID = "battle/action/"..self._playInfo.defend_action_id..".json"
            		local hitEntry = ActionEntry.new(hitActionID, knight, battleField)
            		hitEntry:addEntryToNewQueue(nil, function()
            											local hitSound = skill_info.get(attack.skill_id).hit_sound
            												if hitSound and hitSound ~= "0" then
            													SoundManager:playSound(hitSound)
            												end
            											return true
            									 	 end)
            		self:addEntryToQueue(hitEntry, hitEntry.updateEntry, nil, knight)
            		hitActions[knight] = hitEntry
            	end
        	end
    	end

    	self:addEntryToQueue(buffEntry, buffEntry.updateEntry)
	end
end

function PetAttackEntry:destroyEntry()
	PetAttackEntry.super.destroyEntry(self)

	-- 如果大招黑幕还在，移除之，并把受击者移回下层
	if self._blackLayer then
		self._blackLayer:removeFromParent()
		self._blackLayer = nil
		self:moveVictimsToLayer(self._data.skill_victims, self._battleField:getCardNode())
	end

	-- 强制结束宠物攻击动作
	self._pet:stopAttack()
end

return PetAttackEntry