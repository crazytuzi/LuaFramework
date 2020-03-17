
--
-- Monster 系统总控制器，
-- 用于系统初始化，提供本系统对外接口
_G.classlist['MonsterController'] = 'MonsterController'
_G.MonsterController = setmetatable({}, {__index = IController})
MonsterController.name = "MonsterController"
MonsterController.objName = 'MonsterController'
MonsterController.talkTime = 0
MonsterController.monsterTalkTime = 20000
function MonsterController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_MonChangeBelong, self, self.OnChangeBelong)
	CPlayerControl:AddPickListen(self)
	self.updateDelay = 0
	self.bCanUse = true
	return true
end

function MonsterController:Update(interval)
	if not StoryController:IsStorying() then
		self.talkTime = self.talkTime + interval
		if self.talkTime > self.monsterTalkTime then		
			self.talkTime = 0
			local monster, talkId = MonsterModel:GetMonsterRadom()
			if monster then			
				monster:OnTalk(talkId)
			end
		end
	end

	
	return true
end

function MonsterController:Destroy()
	return true
end

function MonsterController:OnEnterGame()
	return true
end

function MonsterController:OnChangeSceneMap()
	MonsterController:DeleteAllMonster()
	return true
end

function MonsterController:OnLeaveSceneMap()
	MonsterController:DeleteAllMonster()
	return true
end

function MonsterController:OnPosChange(newPos)

end

-------------------鼠标事件-----------------------------------
function MonsterController:OnMouseWheel()
	
end

function MonsterController:OnBtnPick(button, type, node)
	self:OnMouseClick(node, button)
end

function MonsterController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function MonsterController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function MonsterController:OnMouseOut(node)
    if node == nil then
    	return
    end
	local cid = node.cid
	if not cid then
		return
	end
	local monster = MonsterController:GetMonster(cid)
	if not monster then
		return
	end
	self:MouseOutMonster(monster)
end

function MonsterController:OnMouseOver(node)
	if node == nil then 
		return
	end
	local cid = node.cid
	if not cid then
		return
	end
	local monster = MonsterController:GetMonster(cid)
	if not monster then
		return
	end
	self:MouseOverMonster(monster)
end

function MonsterController:OnMouseClick(node, button)
	if not node then
		return
	end
	local cid = node.cid
	if not cid then
		return
	end
	local monster = MonsterController:GetMonster(cid)
	if not monster then
		return
	end
	SkillController:ClickLockChar(cid)
	if MonsterController:MonsterIsAttack(cid) then
		AutoBattleController:DoNormalAttack(button)
	end
end
-------------------鼠标事件-----------------------------------
function MonsterController:AddMonster(monsterInfo)
	if not monsterInfo then 
		return
	end
	local cid = monsterInfo.charId
    if MonsterController:GetMonster(cid) ~= nil then
        Debug("monster add: ", cid)
        return
    end
	local monsterId = monsterInfo.configId 
	local x = monsterInfo.x
	local y = monsterInfo.y
	local faceto = monsterInfo.faceto
	local speed = monsterInfo.speed
	local belongType = monsterInfo.belongType
	local belongID = monsterInfo.belongID
	local monster = Monster:NewMonster(cid, monsterId, x, y, faceto, speed)
	if not monster then
		return
	end
	MonsterController:SetHPInfo(monster, monsterInfo.dwCurrHP, monsterInfo.dwMaxHP)
	MonsterController:ShowMonster(monster)
	MonsterModel:AddMonster(monster)
	MonsterController:SetState(monster, monsterInfo.ubit)
	if monsterInfo.born == 1 then
		monster:Born()
		monster:SetBornVisible()
	end
	monster:SetCamp(monsterInfo.camp)
	monster:SetBelongInfo(belongType, belongID)
	MonsterController:monsterIsDeadState(monster)
	local visible = QuestController:GetMonsterNeedShow(monsterId);
	monster:HideSelf(not visible);
	
	if visible and StoryController:IsStorying() then
		monster:ShowSelfByStory();
	end
end

function MonsterController:SetHPInfo(monster, currHP, maxHP)
	monster:SetCurrHP(currHP)
	monster:SetMaxHP(maxHP)
end
 
function MonsterController:SetState(monster, ubit)
	monster:SetState(ubit)
end

function MonsterController:DeleteMonster(cid)
	local monster = MonsterController:GetMonster(cid)
    if not monster then
		Debug("monster delete: ", cid)
        return
	end
	if monster:IsDead() and not monster.fadeTimePlan then
		monster:FadeOut()
	else
		MonsterController:DestroyMonster(cid)		
	end
end

function MonsterController:DestroyMonster(cid)
	local monster = MonsterModel:GetMonster(cid)
    if not monster then
        return
	end
	monster:ExitMap()
	monster = nil
end

function MonsterController:MoveTo(cid, x, y)
	local monster = MonsterModel:GetMonster(cid)
	if not monster then
		return 
	end
	local speed = monster:GetSpeed()
	monster:MoveTo(x, y, speed)
end

function MonsterController:StopMove(cid, x, y, faceto)
	local monster = MonsterModel:GetMonster(cid)
	if not monster then
		return 
	end
	monster:StopMove(x, y, faceto)
end

function MonsterController:MouseOverMonster(monster)
	monster:SetHighLight()
	monster:SetMouseOver(true)
	if MonsterController:MonsterIsAttack(monster.cid) then
		CCursorManager:AddStateOnChar("battle", monster.cid)
	end
end

function MonsterController:MouseOutMonster(monster)
	monster:DelHighLight()
	monster:SetMouseOver(false)
	if MonsterController:MonsterIsAttack(monster.cid) then
		CCursorManager:DelState("battle")
	end
    
end

function MonsterController:ShowMonster(monster)
	monster:Show()
end

function MonsterController:GetMonster(cid)
	return MonsterModel:GetMonster(cid)
end

function MonsterController:IsBoss(node)
	if not node then
		return
	end
	if not node.entity then
		return
	end
	local cid = node.entity.cid
	if not cid then
		return
	end
	local monster = MonsterController:GetMonster(cid)
	if monster and monster:IsBoss() then
		return true
	end
	return false
end

function MonsterController:monsterIsDeadState(monster)
	if not monster then
		return
	end
	if monster:IsDead() then
		monster:PlayDeadAction()
	end
end

function MonsterController:MonsterIsAttack(cid)
	local monster = MonsterController:GetMonster(cid)
    if not monster then
        return false
	end
	if not monster:CheckBelong() then
		return false
	end
	if monster:IsAtkCamp() then
		return true
	end
	return false
end

function MonsterController:ClearMonster()
	local monsterList = MonsterModel:GetMonsterList()
	if monsterList then
		for cid, monster in pairs(monsterList) do
			if monster:IsDead() then
				MonsterController:DestroyMonster(cid)
			end
		end
	end
end

function MonsterController:DeleteAllMonster()
	local monsterList = MonsterModel:GetMonsterList()
	if monsterList then
		for cid, monster in pairs(monsterList) do
			monster:ClearTimePlan()
		end
	end
	MonsterModel:DeleteAllMonster()
end


-----------------------------------------剧情怪--------------------------------------------

function MonsterController:AddStoryMonster(monsterInfo)
	if not monsterInfo then 
		return
	end
	
	local mid = monsterInfo.mid
    if MonsterModel:GetStoryMonster(mid) ~= nil then
        Debug("storymonster dup: ", mid)
        return
    end;
	local monsterId = monsterInfo.configId 
	local x = monsterInfo.x
	local y = monsterInfo.y
	local faceto = monsterInfo.dir
	local monster = Monster:NewMonster(mid, monsterId, x, y, faceto)
	if not monster then
		return
	end
	monster:SetIsStory(true)
	MonsterController:ShowMonster(monster)
	MonsterModel:AddStoryMonster(mid, monster)
end

function MonsterController:DeleteAllStoryMondter()
	for k,v in pairs(MonsterModel:GetStoryMonsterList()) do
		self:DeleteStoryMonster(k)
	end
	-- MonsterModel:DeleteAllStoryMonster()
end

function MonsterController:DeleteStoryMonster(mid)
	local monster = MonsterModel:GetStoryMonster(mid)
    if not monster then
        return
	end
	monster:ClearTimePlan()
	monster:ExitMap()
	MonsterModel:DeleteStoryMonster(mid)
	monster.avatar = nil
	monster = nil
end

function MonsterController:ReadFengyaoId()
	if not MonsterController.fengyaoTable then
		MonsterController.fengyaoTable = {}
	end
	for id, info in pairs(t_fengyao) do
		local monsters = split(info.monster_id,',');
		local t = tonumber(monsters[1])
		MonsterController.fengyaoTable[t] = true
	end
end

function MonsterController:IsFengyaoMonster(configId)
	if not MonsterController.fengyaoTable then
		MonsterController:ReadFengyaoId()
	end
	return MonsterController.fengyaoTable[configId]
end
-----------------------------------------------------------------

-------------------协议-------------------------
function MonsterController:OnChangeBelong(msg)
	local cid = msg.guid
	local belongType = msg.belongType
	local belongID = msg.belongID
	local monster = MonsterController:GetMonster(cid)
    if not monster then
        return
	end
	monster:SetBelongInfo(belongType, belongID)
end

-- 怪物死亡 
--CharController:OnCharDead(value)
function MonsterController:OnDead(msg)
	local charId = msg.deadid
	local skillId = msg.skillID
	local killerId = msg.killerID
	local effectType = msg.deadAction;
	local monster = MonsterController:GetMonster(charId)
	if not monster then
		Debug("monster dead: ", charId)
		return
	end
	monster:Dead(skillId, killerId,effectType)
	XiuweiPoolController:GetValMonsterDie(monster)
end