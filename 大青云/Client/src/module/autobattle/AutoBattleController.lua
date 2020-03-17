--自动战斗controller
_G.classlist['AutoBattleController'] = 'AutoBattleController'
_G.AutoBattleController = setmetatable({}, { __index = IController });
AutoBattleController.objName = 'AutoBattleController'
AutoBattleController.name = "AutoBattleController";


AutoBattleController.lastSkillId = 0
AutoBattleController.autoCastSkillState = false
AutoBattleController.currTarget = 0
AutoBattleController.isAutoHang = false
AutoBattleController.CDList = {}
AutoBattleController.hpTime = 0
--AutoBattleController.mpTime = 0
AutoBattleController.lastPickTime = 0
AutoBattleController.lastUseSkillTime = 0
AutoBattleController.lastUseRollSkillTime = 0
AutoBattleController.HangPos = nil
AutoBattleController.skillIndex = 1
AutoBattleController.attackList = {}
AutoBattleController.autoReviveTime = 0
AutoBattleController.AutoBuyItemTime = 0
AutoBattleController.normalAttackTime = 0
AutoBattleController.targetCid = nil
AutoBattleController.autoHidePfxTime = 20 * 60 * 1000
AutoBattleController.isAutoHidePfx = false
AutoBattleController.startHangTime = 0
AutoBattleController.closeTime = 0
AutoBattleController.castMagicFailTime = 0
AutoBattleController.isAutoHangInDeadState = false
AutoBattleController.posInDeadState = nil
AutoBattleController.autoSendHangStateTime = 0
AutoBattleController.firstSendHangState = false

function AutoBattleController:Create()
end

function AutoBattleController:Update(dwInterval)
	AutoBattleController:AutoSendHangState()
	AutoBattleController:AutoHang()
	AutoBattleController:AutoNormalAttack()
	AutoBattleController:CheckHidePfx()
end

function AutoBattleController:OnEnterGame()
end

function AutoBattleController:OnChangeSceneMap()
end

function AutoBattleController:OnSceneFocusOut()
end

-- 每次登陆收到服务器技能列表时
function AutoBattleController:OnSkillListResult()
	self:SetAutoBattle();
end

-- 增加技能时
function AutoBattleController:OnSkillAddResult(skillId)
	AutoBattleModel:AddSkill(skillId);
end

-- 删除技能时
function AutoBattleController:OnSkillRemoveResult(skillId)
	AutoBattleModel:RemoveSkill(skillId);
end

-- 升级新技能时
function AutoBattleController:OnSkillLvlUpResult(skillId, oldSkillId)
	AutoBattleModel:SkillLvlUp(skillId, oldSkillId);
end

function AutoBattleController:SaveAutoBattleSetting()
	--save config
	local autoBattleSetting = {};
	for k, v in pairs(AutoBattleModel) do
		if type(v) ~= "function" then
			autoBattleSetting[k] = v;
		end
	end
	local cfg = ConfigManager:GetRoleCfg();
	cfg.autoBattleSetting = autoBattleSetting;
	ConfigManager:Save();
end

function AutoBattleController:SetAutoBattle()
	if not self:LoadAutoBattleSetting() then
		self:UseDefaultSetting();
	end
end

function AutoBattleController:LoadAutoBattleSetting()
	local autoBattleSetting = ConfigManager:GetRoleCfg("autoBattleSetting");
	if autoBattleSetting then
		AutoBattleModel:UseCfg(autoBattleSetting);
		return true;
	end
	return false;
end

function AutoBattleController:UseDefaultSetting()
	AutoBattleModel:UseDefault();
end

function AutoBattleController:AutoNormalAttack()
	if SkillController.CurrSkillTargetPos then
		return
	end
	local lastSkillId = self.lastSkillId
	local skillConfig = t_skill[lastSkillId]
	if not skillConfig then
		return false
	end
	if not skillConfig.b_normal_att then
		self.lastSkillId = 0
		return
	end
	if not AutoBattleController.autoCastSkillState then
		return
	end
	if not self:IsSameClickChar() then
		return
	end
	if GetCurTime() - AutoBattleController.normalAttackTime < 400 then
		return
	end
	
	if MainPlayerController:InTransforming() then
		self:PickInTransformSkill(1);
		return;
	end
	
	local skillId = MainPlayerController:GetNormalAttackSkillId()
	if AutoBattleController:IsCanUseSkill(skillId) then
		SkillController:PlayCastSkill(skillId)
		AutoBattleController.normalAttackTime = GetCurTime()
	end
end

function AutoBattleController:SetAutoCastSkillState(autoCastSkillState)
	self.autoCastSkillState = autoCastSkillState
end

function AutoBattleController:IsSameClickChar()
	return (AutoBattleController.currTarget == SkillController.targetCid)
end

function AutoBattleController:DoNormalAttack(mouesID)
	local skillId = MainPlayerController:GetNormalSkillIdByMoues(mouesID)
	SkillController:PlayCastSkill(skillId, false, true)
end

function AutoBattleController:AutoClickLockChar()
	AutoBattleController:AutoCancelLockChar()
	local char, charType = SkillController:GetCurrTarget()
	if not char then
		local attackTarget = AutoBattleController:GetAutoNormalAttackTarget()
		if attackTarget then
			SkillController:ClickLockChar(attackTarget:GetCid())
		end
	end
end

function AutoBattleController:AutoCancelLockChar()
	local char, charType = SkillController:GetCurrTarget()
	if char then
		local cid = char:GetCid()
		if not AutoBattleController:CanAttack(cid) then
			SkillController:ClearTarget()
		end
		local pos = nil
		local range = nil
		if AutoBattleController:GetAutoHang() then
			pos = AutoBattleController.HangPos
			range = AutoBattleModel.findMonsterRange
		else
			pos = MainPlayerController:GetPlayer():GetPos()
			range = 100
		end
		local size = 0
		local targetPos = char:GetPos()
		if charType == enEntType.eEntType_Monster then
			size = char:GetBoxWidth()
		end
		if GetDistanceTwoPoint(targetPos, pos) > range + size then
			SkillController:ClearTarget()
		end
	end
end

function AutoBattleController:GetAutoNormalAttackTarget()
	local attackTarget
	local pos = nil
	local range = nil
	if AutoBattleController:GetAutoHang() then
		pos = AutoBattleController.HangPos
		range = AutoBattleModel.findMonsterRange
	end
	local attackList = AutoBattleController:GetAttackPlayerByRange(pos, range)
	if next(attackList) then
		attackTarget = attackList[1]
	else
		attackList = AutoBattleController:GetAttackMonsterByRange(pos, range)
		if next(attackList) then
			attackTarget = attackList[1]
		end
	end
	return attackTarget
end


function AutoBattleController:CloseAutoHang()
	if AutoBattleController.isAutoHang then
		AutoBattleController:SetAutoHang();
	end
end

function AutoBattleController:SetAutoHang()
	if StoryController:IsStorying() then
		return
	end

	if not MainPlayerController:GetPlayer() then
		return
	end

	if not self.isAutoHang then
		local ret = AutoBattleController:IsCanAutoHang()
		if ret == false then
			return
		end
	end

	self.isAutoHang = not self.isAutoHang
	if MainPlayerController:GetPlayer():IsDead() then
		self.isAutoHang = false
	end
	if self.isAutoHang then --打开自动挂机
		--打断寻路
		SetLoadTaskState(true);
		MainPlayerController:StopMove()
		local pos = MainPlayerController:GetPlayer():GetPos()
		AutoBattleController.HangPos = { x = pos.x, y = pos.y, z = pos.z }
		AutoBattleController.attackList = {}
		AutoBattleController.skillIndex = 1
		--如果正在打坐，取消
		if SitModel:GetSitState() ~= SitConsts.NoneSit then
			SitController:ReqCancelSit()
		end
		AutoBattleController.startHangTime = GetCurTime()
		AutoBattleController.isAutoHangInDeadState = false
		SkillController.CurrSkillTargetPos = nil
		AutoBattleController.CDList = {}
		AutoBattleController.autoSendHangStateTime = GetCurTime() - 4 * 60 * 1000
		AutoBattleController.autoGCTime = GetCurTime()
	else --关闭自动挂机
		SetLoadTaskState(false);
		AutoBattleController:PickUpItem(1000)
		TimerManager:RegisterTimer(function()
			AutoBattleController:PickUpItem(1000)
		end, 300, 5)
		AutoBattleController.closeTime = GetCurTime() + 1000
		RemindController:AddRemind(RemindConsts.Type_HANG, 1)
		AutoBattleController.startHangTime = 0
		AutoBattleController:SendHangState(0)
		AutoBattleController.HangPos = nil
		AutoBattleController.attackList = {}
	end
	Notifier:sendNotification(NotifyConsts.AutoHangStateChange, { state = self.isAutoHang })
	--UI挂机状态显示切换
	UIAutoBattle:SwitchHang(self.isAutoHang)

	if self.isAutoHang then
		QuestGuideManager:OnAutoBattle();
	else
		QuestGuideManager:OnAutoBattleEnd();
	end
end

function AutoBattleController:OpenAutoBattle()
	if not self.isAutoHang then
		AutoBattleController:SetAutoHang()
	end
end

function AutoBattleController:GetAutoHang()
	return self.isAutoHang
end

function AutoBattleController:SetSkillCD(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	if skillConfig.oper_type == SKILL_OPER_TYPE.COMBO and SkillController.comboing then
		return
	end
	AutoBattleController.CDList[skillId] = GetCurTime() + skillConfig.cd
end

function AutoBattleController:CheckSkillCD(skillId)
	if AutoBattleController.CDList[skillId] and AutoBattleController.CDList[skillId] > GetCurTime() then
		return false
	end
	return true
end

function AutoBattleController:GetCanUseSkill()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	local skill_list1 = AutoBattleModel.normalSkillList
	local skill_list2 = AutoBattleModel.specialSkillList
	if not skill_list1 and not skill_list2 then
		return
	end
	local normalskillId = MainPlayerController:GetNormalAttackSkillId()
	local rollSkillId = MainPlayerController:GetRollSkillId()
	local result = {}
	if skill_list2 then
		for _, skillVo in pairs(skill_list2) do
			if skillVo.selected == true then
				local skillId = skillVo.skillId
				if skillId ~= rollSkillId then
					if AutoBattleController:IsCanUseSkill(skillId) then
						table.insert(result, skillId)
					end
				end
			end
		end
	end
	if skill_list1 then
		for index, skillVo in pairs(skill_list1) do
			if skillVo.selected == true then
				local skillId = skillVo.skillId
				if skillId ~= normalskillId then
					if AutoBattleController:IsCanUseSkill(skillId) then
						table.insert(result, skillId)
					end
				end
			end
		end
	end
	if #result > 1 then
		table.sort(result, function(skillone, skilltwo)
			local priorityone = AutoBattleController:GetSkillPriority(skillone)
			local prioritytwo = AutoBattleController:GetSkillPriority(skilltwo)
			return priorityone > prioritytwo
		end)
	end
	
	if result[1] then
		return result[1]
	end
end

function AutoBattleController:AutoHang()
	if CPlayerMap.changeLineState == true then
		return
	end
	if MainPlayerController.isEnter == false then
		return
	end
	AutoBattleController:AutoRecover1()
	AutoBattleController:AutoRecover()
	if not InterServicePvpController:IsInPvp1() then
		AutoBattleController:AutoReviveOnDead()
	end
	if not self.isAutoHang then
		return
	end
	AutoBattleController:AutoRunHangPos()
	AutoBattleController:AutoStopMove()
	AutoBattleController:AutoClickLockChar()
	AutoBattleController:AutoUseSkill()
	AutoBattleController:AutoPickUp()
	AutoBattleController:AutoInterruptCast()
	AutoBattleController:AutoRunToTarget()
	AutoBattleController:AutoGC()
end

function AutoBattleController:AutoGC()
	if not AutoBattleController.autoGCTime then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.autoGCTime >= 30 * 1000 then
		LuaGC()
		AutoBattleController.autoGCTime = nowTime
	end
end

--自动使用技能(只针对有目标的情况)
function AutoBattleController:AutoUseSkill()
	if GetCurTime() - AutoBattleController.lastUseSkillTime < 100 then
		return
	end
	local char = SkillController:GetCurrTarget()
	if not char then
		return
	end
	if SkillController:IsStiff() then
		return
	end
	if not AutoBattleController:CheckCastState() then
		return
	end
	if SkillController.CurrSkillTargetPos then --当前有技能作用
		return
	end
	
	if MainPlayerController:InTransforming() then
		self:PickInTransformSkill();
		return;
	end
	
	AutoBattleController:AutoUseRollSkill()
	local skillId = AutoBattleController:GetCanUseSkill()
	if not skillId then
		skillId = MainPlayerController:GetNormalAttackSkillId() --获取普通攻击（注：没有左右键技能）
	end
	local result = SkillController:PlayCastSkill(skillId) --对技能释放的尝试
end

function AutoBattleController:ChangeWhenTransform()
	if not self.isAutoHang then
		return;
	end
	
	local last = AutoBattleController.lastUseSkillTime;
	AutoBattleController.lastUseSkillTime = 0;
	self:AutoUseSkill();
	if AutoBattleController.lastUseSkillTime == 0 then
		AutoBattleController.lastUseSkillTime = last;
	end
end

function AutoBattleController:AutoUseRollSkill()
	if SkillController:GetCurrTarget() then
		local targetPos = SkillController:GetCurrTarget():GetPos()
		local pos = MainPlayerController:GetPlayer():GetPos()
		if GetDistanceTwoPoint(targetPos, pos) > 50 then
			local skillId = AutoBattleController:GetJumpSkill()
			if not (skillId and AutoBattleController:IsCanUseSkill(skillId)) then
				return false
			end
			local ret = SkillController:PlayCastSkill(skillId)
			return ret
		end
	end
	return false
end

function AutoBattleController:AutoRecover()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if selfPlayer:IsDead() then
		return
	end
	if not AutoBattleModel.takeHpDrugInterval then
		return
	end
	--if not AutoBattleModel.takeMpDrugInterval then
	--	return
	--end
	local takeHpDrugInterval = AutoBattleModel.takeHpDrugInterval
	--local takeMpDrugInterval = AutoBattleModel.takeMpDrugInterval
	local takeDrugHp = AutoBattleModel.takeDrugHp
	--local takeDrugMp = AutoBattleModel.takeDrugMp
	if takeHpDrugInterval <= 1 then
		takeHpDrugInterval = 10
	end
	--if takeMpDrugInterval < 1 then
	--	takeMpDrugInterval = 10
	--end
	local playerCurrLevel = selfPlayer:GetPlayerInfoByType(enAttrType.eaLevel)
	if not playerCurrLevel then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.hpTime > takeHpDrugInterval * 1000 then
		local hp = selfPlayer:GetPlayerInfoByType(enAttrType.eaHp)
		local maxHp = selfPlayer:GetPlayerInfoByType(enAttrType.eaMaxHp)
		if maxHp and hp < takeDrugHp * maxHp and maxHp > 0 then
			local haveHpItem = false
			local hpList = nil
			if AutoBattleModel.takeHpDrugSequence == 1 then --小剂量优先
			hpList = AutoDefine.hp_list1
			else
				hpList = AutoDefine.hp_list2
			end
			for _, itemId in ipairs(hpList) do
				local item = BagModel:GetItemInBag(itemId)
				local level = t_item[itemId].level
				if item and playerCurrLevel >= level then
					if BagModel:GetItemCD(itemId) == 0 then
						BagController:UseItem(BagConsts.BagType_Bag, item:GetPos(), 1)
						AutoBattleController.hpTime = nowTime + 500
					end
					haveHpItem = true
					break
				end
			end
			if not haveHpItem then
				--自动购买药品
				AutoBattleController:AutoBuyItem(1)
			end
		end
	end
	--[[
	if nowTime - AutoBattleController.mpTime > takeMpDrugInterval * 1000 then
		local mp = selfPlayer:GetPlayerInfoByType(enAttrType.eaMp)
		local maxMp = selfPlayer:GetPlayerInfoByType(enAttrType.eaMaxMp)
		if maxMp and mp < takeDrugMp * maxMp and maxMp > 0 then
			local haveMpItem = false
			local mpList = nil
			if AutoBattleModel.takeMpDrugSequence == 1 then --小剂量优先
				mpList = AutoDefine.mp_list1
			else
				mpList = AutoDefine.mp_list2
			end
			for index, itemId in ipairs(mpList) do
				local item = BagModel:GetItemInBag(itemId)
				local level = t_item[itemId].level
				if item and playerCurrLevel >= level then
					if BagModel:GetItemCD(itemId) == 0 then
						BagController:UseItem(BagConsts.BagType_Bag, item:GetPos(), 1)
						AutoBattleController.mpTime = nowTime
					end
					haveMpItem = true
					break
				end
			end
			if not haveMpItem then
				--自动购买药品
				AutoBattleController:AutoBuyItem(2)
			end
		end
	end
	]] --
end

function AutoBattleController:AutoRecover1()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if selfPlayer:IsDead() then
		return
	end
	if SkillModel.shortCutItem == 0 then
		return
	end
	if MainPlayerController.isInterServer then
		return
	end
	local canuse = BagUtil:GetItemCanUse(SkillModel.shortCutItem)
	if canuse < 0 then
		return
	end


	local hp = selfPlayer:GetPlayerInfoByType(enAttrType.eaHp)
	local maxHp = selfPlayer:GetPlayerInfoByType(enAttrType.eaMaxHp)
	if maxHp
			and hp
			and maxHp > 0
			and hp < 0.3 * maxHp then
		UIMainSkill:OnSCItemClick()
	end
end


function AutoBattleController:AutoBuyItem(itemType)
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if not AutoBattleModel.autoBuyDrug then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.AutoBuyItemTime < 10000 then
		return
	end
	local playerCurrLevel = selfPlayer:GetPlayerInfoByType(enAttrType.eaLevel)
	local buyItemId
	local shopItemList
	if itemType == 1 then
		shopItemList = Shop_Item_List_1
		-- elseif itemType == 2 then
		-- 	shopItemList = Shop_Item_List_2
	end
	for i = #shopItemList, 1, -1 do
		local itemId = shopItemList[i]
		local level = t_item[itemId].level
		if playerCurrLevel >= level then
			buyItemId = itemId
			break
		end
	end
	AutoBattleController:BuyItem(buyItemId)
	AutoBattleController.AutoBuyItemTime = nowTime
end

function AutoBattleController:BuyItem(buyItemId)
	local ret = false
	if buyItemId then
		for id, shopItem in pairs(t_shop) do
			if buyItemId == shopItem.itemId then
				local itemCfg = t_item[buyItemId]
				if itemCfg then
					local num = itemCfg.repeats
					if ShopUtils:CheckCanBuy(id, num) then
						ShopController:ReqBuyItem(id, num)
						ret = true
					end
				end
				break
			end
		end
	end
	return ret
end

function AutoBattleController:AutoPickUp()
	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.lastPickTime < 3000 then
		return
	end
	if not self.isAutoHang then
		return
	end
	AutoBattleController:PickUpItem()
	AutoBattleController.lastPickTime = nowTime
end

function AutoBattleController:PickUpItem(pickRadius)
	if not AutoBattleModel.autoPickEquip
			and not AutoBattleModel.autoPickMoney
			and not AutoBattleModel.autoPickDrug
			and not AutoBattleModel.autoPickMaterial then
		return
	end

	if not pickRadius then
		pickRadius = 100
	end

	local pickList = {}
	local pos = MainPlayerController:GetPlayer():GetPos()
	-- local posX = pos.x
	-- local posY = pos.y
	local selfCid = MainPlayerController:GetRoleID()
	for cid, item in pairs(MainPlayerModel.allDropItem) do
		if not item.isSim then --如果是模拟掉落的物品，则不执行这个
			if item.dwRoleId == selfCid or item.dwRoleId == "0_0" then
				local itemPos = item:GetPos()
				local itemId = item:GetItemId()
				if GetDistanceTwoPoint(itemPos, pos) <= pickRadius then
					local canPick = AutoBattleController:CheckItemCanPick(itemId)
					if canPick then
						table.insert(pickList, { id = cid })
					end
				end
			end
		end
	end
	if #pickList >= 1 then
		DropItemController:SendPickUpItem(pickList)
	end
end

function AutoBattleController:CheckItemCanPick(itemConfigId)
	if not BagModel:CheckCanPutItem(itemConfigId, 1) then
		return false
	end
	local canPick = false
	if t_equip[itemConfigId] then
		if AutoBattleModel.autoPickEquip then
			if AutoBattleModel.autoPickEquipProf == -1
					or (AutoBattleModel.autoPickEquipProf == t_equip[itemConfigId].vocation
					or t_equip[itemConfigId].vocation == 0) then
				if AutoBattleModel.autoPickEquipLvl == -1 or t_equip[itemConfigId].level > AutoBattleModel.autoPickEquipLvl then
					if AutoBattleModel.autoPickEquipQuality == -1 or t_equip[itemConfigId].quality >= AutoBattleModel.autoPickEquipQuality then
						canPick = true
					end
				end
			end
		end
	elseif t_item[itemConfigId] then
		if AutoBattleModel.autoPickMoney
				and (itemConfigId == 7
				or itemConfigId == 10
				or itemConfigId == 11
				or itemConfigId == 12
				or itemConfigId == 13
				or itemConfigId == 14
				or itemConfigId == 51
				or itemConfigId == 54
				or itemConfigId == 55
				or itemConfigId == 59
				or itemConfigId == 60
				or itemConfigId == 61
				or itemConfigId == 62
				or itemConfigId == 101
				or itemConfigId == 102
				or t_item[itemConfigId].sub == 2
				or t_item[itemConfigId].sub == 15) then
			canPick = true
		end
		if AutoBattleModel.autoPickDrug
				and (t_item[itemConfigId].sub == 1
				or t_item[itemConfigId].sub == 3
				or t_item[itemConfigId].sub == 4
				or t_item[itemConfigId].sub == 20) then
			canPick = true
		end
		if AutoBattleModel.autoPickMaterial
				and (t_item[itemConfigId].sub == 5
				or t_item[itemConfigId].sub == 6
				or t_item[itemConfigId].sub == 7
				or t_item[itemConfigId].sub == 8
				or t_item[itemConfigId].sub == 9
				or t_item[itemConfigId].sub == 10
				or t_item[itemConfigId].sub == 11
				or t_item[itemConfigId].sub == 12
				or t_item[itemConfigId].sub == 13
				or t_item[itemConfigId].sub == 14
				or t_item[itemConfigId].sub == 16
				or t_item[itemConfigId].sub == 17
				or t_item[itemConfigId].sub == 18
				or t_item[itemConfigId].sub == 19
				or t_item[itemConfigId].sub == 21
				or t_item[itemConfigId].sub == 22
				or t_item[itemConfigId].sub == 23
				or t_item[itemConfigId].sub == 24
				or t_item[itemConfigId].sub == 25
				or t_item[itemConfigId].sub == 28
				or t_item[itemConfigId].sub == 32
				or t_item[itemConfigId].sub == 33) then
			canPick = true
		end
	end
	return canPick
end

function AutoBattleController:AutoInterruptCast()
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer.stateMachine
			and selfPlayer.stateMachine.currState
			and selfPlayer.stateMachine.currState.name == "prep" then
		local skillId = SkillController.CurrPrepSkillId
		if not skillId then
			return
		end
		local skillConfig = t_skill[skillId]
		if not skillConfig then
			return
		end
		if selfPlayer.stateMachine.currState.prepTime - GetCurTime() <= skillConfig.prep_time / 2 then
			SkillController:TryInterruptCast()
		end
	end
end

--打断自动施法
function AutoBattleController:InterruptAutoBattle()
	AutoBattleController:InterruptAutoCast()
	if AutoBattleController:GetAutoHang() then
		AutoBattleController:SetAutoHang()
	end
end

function AutoBattleController:InterruptAutoCast()
	AutoBattleController:SetAutoCastSkillState(false)
	SkillController:CancelAutoCastSkill()

	-- smart,打断采集
	if ActivityZhanChang.isAtZhanchangAct then
		ZhChFlagController:CloseTimer()
	end;
	if UnionDiGongModel:GetIsAtUnionActivity() then
		DiGongFlagController:CloseTimer()
	end;
	if UnionDiGongModel:GetIsGoGetFlag() then
		UnionDiGongModel:SetIsGoGetFlag(false);
	end;
end

--引导技能时跑向怪
function AutoBattleController:AutoRunToTarget()
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer.stateMachine
			and selfPlayer.stateMachine.currState
			and selfPlayer.stateMachine.currState.name == "chan" then
		local targetChar, charType = SkillController:GetCurrTarget()
		local targetCid = SkillController.targetCid
		if targetChar and targetCid ~= AutoBattleController.targetCid then
			local targetPos = targetChar:GetPos()
			local selfPos = MainPlayerController:GetPlayer():GetPos()
			local selfDis = GetDistanceTwoPoint(targetPos, selfPos)
			local size = 0
			if charType == enEntType.eEntType_Monster then
				size = targetChar:GetBoxWidth()
			else
				size = 10
			end
			selfDis = selfDis - size
			if selfDis < 0 then
				return
			end
			local pos = SkillController:GetRollPos(selfDis, targetPos)
			if not pos then
				return
			end
			local ret = CPlayerControl:AutoRun(pos, { func = function() end })
			if ret == false then
				return
			end
			AutoBattleController.targetCid = targetCid
		end
	end
end

function AutoBattleController:IsCanAutoHang()
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer.stateMachine
			and selfPlayer.stateMachine.currState
			and (selfPlayer.stateMachine.currState.name == "prep" or selfPlayer.stateMachine.currState.name == "combo") then
		return false
	end
	return true
end

function AutoBattleController:AutoBattleUnderAttack()
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if selfPlayer:IsMoveState() then
		return
	end

	if selfPlayer:IsDead() then
		return
	end

	if CPlayerMap.teleportState == true then
		return
	end

	if CPlayerMap.bChangeMaping then
		return
	end

	if CPlayerMap.changeLineState == true then
		return
	end

	if CPlayerMap.changePosState then
		return
	end

	if AutoBattleController:GetAutoHang() then
		return
	end

	if not AutoBattleModel.autoHang then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - MainPlayerController.laseOpTime < 10000 then
		return
	end
	table.insert(AutoBattleController.attackList, nowTime)
	for index = #AutoBattleController.attackList, 1, -1 do
		local attackTime = AutoBattleController.attackList[index]
		if nowTime - attackTime > 10000 then
			table.remove(AutoBattleController.attackList, index)
		end
	end
	if #AutoBattleController.attackList >= 10 then
		AutoBattleController:OpenAutoBattle()
	end
end

function AutoBattleController:AutoReviveOnDead()
	if not AutoBattleModel.autoReviveSitu then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.autoReviveTime < 5200 then
		return
	end
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	if selfPlayer:IsDead() then
		AutoBattleController.autoReviveTime = nowTime
		UIRevive:OnBtnReviveSituClick()
	end
end

function AutoBattleController:CanCastOnAutoBattle(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return false
	end
	local skillType = skillConfig.oper_type
	if skillConfig.oper_type == SKILL_OPER_TYPE.CHAN then
		local selfPlayer = MainPlayerController:GetPlayer()
		local pos = selfPlayer:GetPos()
		if AutoBattleController:CheckNearAttackChar(pos, 40) then
			return true
		end
		--   elseif skillConfig.oper_type == SKILL_OPER_TYPE.LINGZHEN then
		--   	local selfPlayer = MainPlayerController:GetPlayer()
		-- local pos = selfPlayer:GetPos()
		--   	if AutoBattleController:CheckNearAttackChar(pos, 80) then
		--   		return true
		--   	end
	else
		local ret = AutoBattleController:CheckNearDamageTarget(skillId)
		if ret then
			return true
		end
	end
	return false
end

function AutoBattleController:IsCanUseSkill(skillId)
	if not AutoBattleController:CheckSkillCD(skillId) then
		return false
	end
	local ret = SkillController:IsCanUseSkill(skillId)
	if ret ~= 0 and ret ~= 6 then
		return false
	end
	if not AutoBattleController:IsCanUseJump(skillId) then
		return false
	end
	if not AutoBattleController:CanCastOnAutoBattle(skillId) then
		return false
	end
	return true
end

function AutoBattleController:IsCanUseJump(skillId)
	local jumpSkillId = AutoBattleController:GetJumpSkill()
	if skillId ~= jumpSkillId then
		return true
	end
	if not SkillController:GetCurrTarget() then
		return false
	end
	local targetPos = SkillController:GetCurrTarget():GetPos()
	local pos = MainPlayerController:GetPlayer():GetPos()
	if GetDistanceTwoPoint(targetPos, pos) < 30 then
		return false
	else
		return true
	end
end

function AutoBattleController:GetJumpSkill()
	local profID = MainPlayerController:GetProfID()
	if not profID then
		return
	end
	local skill_list1 = AutoBattleModel.normalSkillList
	for _, skillVo in pairs(skill_list1) do
		if skillVo.selected == true then
			local skillId = skillVo.skillId
			local skillConfig = t_skill[skillId]
			if skillConfig and skillConfig.group_id and tostring(skillConfig.group_id) == profID .. "0002" then
				return skillId
			end
		end
	end
end

function AutoBattleController:CheckNearDamageTarget(skillId)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return false
	end

	local targetChar = SkillController:GetCurrTarget()
	if not targetChar then
		return false
	end
	local targetPos = targetChar:GetPos()
	local selfPlayer = MainPlayerController:GetPlayer()
	local selfPos = selfPlayer:GetPos()

	local hasEType1 = false;
	local hasEType2 = false;
	local effectId = 0
	for i = 1, 3 do
		--因为自动挂机的时候以前只判断e_type_ = 1的时候，这个技能才可以在挂机中使用。现在把2的情况也加进去
		--1为在 作用目标身上上的特效
		--2为在 作用目标地范围的特效
		--yanghongbin/guyingnan   2016-8-2
		if skillConfig["e_type_" .. i] == 1 then
			hasEType1 = true
		end
		if skillConfig["e_type_" .. i] == 2 then
			hasEType2 = true
		end
		if hasEType1 or hasEType2 then
			effectId = skillConfig["effect_" .. i]
			break
		end
	end
	--指向型技能 range为1
	if hasEType2 then
		return true;
	end
	if effectId == 0 then
		return false
end

	local skillEffect = t_effect[effectId]
	if (not skillEffect) and hasEType1 then
		return false
end
	local range = skillEffect.range
	local distance = skillEffect.distance
	local angle = skillEffect.angle
	local attackList = {}

	if range == 1 then
		return true
	elseif range == 2 then
		local pos = nil
		if skillConfig.oper_type == SKILL_OPER_TYPE.COMBO then
			if not SkillController.comboing then
				pos = targetPos
			else
				pos = SkillController.comboPos
			end
			if not pos then
				return false
			end
		else
			pos = targetPos
		end
		attackList = AutoBattleController:GetNearAttackCharByRange(targetPos, distance)
	elseif range == 3 then
		attackList = AutoBattleController:CheckNearAttackCharBySector(distance, angle / 2)
	elseif range == 4 then
		attackList = AutoBattleController:CheckNearAttackCharByRectangle(distance, angle / 2)
	elseif range == 5 then
		attackList = AutoBattleController:GetNearAttackCharByRange(selfPos, distance)
	end
	if next(attackList) then
		return true
	end
	return false
end

function AutoBattleController:CheckNearAttackCharBySector(distance, theta)
	local pos = MainPlayerController:GetPlayer():GetPos()
	local targetPos = SkillController:GetCurrTarget():GetPos()
	local dir = GetDirTwoPoint(pos, targetPos)
	theta = theta * math.pi / 180
	local result = {}
	for cid, monster in pairs(MonsterModel:GetMonsterList()) do
		if AutoBattleController:CanAttack(cid) then
			local monsterPos = monster:GetPos()
			local monsterDir = GetDirTwoPoint(pos, monsterPos)
			if GetDistanceTwoPoint(pos, monsterPos) <= distance then
				if AutoBattleController:CheckDir(dir, monsterDir, theta) then
					table.insert(result, monster)
				end
			end
		end
	end

	for cid, player in pairs(CPlayerMap:GetAllPlayer()) do
		if AutoBattleController:CanAttack(cid) then
			local playerPos = player:GetPos()
			local playerDir = GetDirTwoPoint(pos, playerPos)
			if GetDistanceTwoPoint(pos, playerPos) <= distance then
				if AutoBattleController:CheckDir(dir, playerDir, theta) then
					table.insert(result, player)
				end
			end
		end
	end

	return result
end

-- dir1 是否在dir正负theta 之间
function AutoBattleController:CheckDir(dir, dir1, theta)
	local maxDir = dir + theta
	if maxDir > 2 * math.pi then
		maxDir = maxDir - 2 * math.pi
	end
	local minDir = dir - theta
	if minDir < 0 then
		minDir = 2 * math.pi + minDir
	end
	local ret = false
	if minDir > maxDir then
		if dir1 <= 2 * math.pi and dir1 >= minDir then
			ret = true
		end
		if dir1 >= 0 and dir1 <= maxDir then
			ret = true
		end
	else
		if dir1 >= minDir and dir1 <= maxDir then
			ret = true
		end
	end
	return ret
end

function AutoBattleController:CheckNearAttackCharByRectangle(distance, angle)
	local pos = MainPlayerController:GetPlayer():GetPos()
	local targetPos = SkillController:GetCurrTarget():GetPos()
	local dir = GetDirTwoPoint(pos, targetPos)
	dir = dir + math.pi
	if dir > 2 * math.pi then
		dir = dir - 2 * math.pi
	end
	local dir1 = dir + math.pi / 2
	local dir2 = dir - math.pi / 2
	if dir1 > 2 * math.pi then
		dir1 = dir1 - 2 * math.pi
	end
	if dir2 < 0 then
		dir2 = 2 * math.pi + dir2
	end
	local result = {}
	local pos1 = {}
	local pos2 = {}
	local pos3 = {}
	local pos4 = {}
	local sinDir1 = math.sin(dir1)
	local cosDir1 = math.cos(dir1)
	local sinDir2 = math.sin(dir2)
	local cosDir2 = math.cos(dir2)
	local sinDir = math.sin(dir)
	local cosDir = math.cos(dir)
	for cid, monster in pairs(MonsterModel:GetMonsterList()) do
		if AutoBattleController:CanAttack(cid) then
			local monsterPos = monster:GetPos()
			local size = monster:GetBoxWidth()
			local tempAngle = angle + size
			local tempDistance = distance + size
			pos1.x = pos.x - tempAngle * sinDir1
			pos1.y = pos.y + tempAngle * cosDir1
			pos2.x = pos.x - tempAngle * sinDir2
			pos2.y = pos.y + tempAngle * cosDir2
			pos3.x = pos2.x - tempDistance * sinDir
			pos3.y = pos2.y + tempDistance * cosDir
			pos4.x = pos1.x - tempDistance * sinDir
			pos4.y = pos1.y + tempDistance * cosDir
			if AutoBattleController:isContain(pos1, pos2, pos3, pos4, monsterPos) then
				table.insert(result, monster)
			end
		end
	end
	for cid, player in pairs(CPlayerMap:GetAllPlayer()) do
		if AutoBattleController:CanAttack(cid) then
			local playerPos = player:GetPos()
			local tempAngle = angle
			local tempDistance = distance
			pos1.x = pos.x - tempAngle * sinDir1
			pos1.y = pos.y + tempAngle * cosDir1
			pos2.x = pos.x - tempAngle * sinDir2
			pos2.y = pos.y + tempAngle * cosDir2
			pos3.x = pos2.x - tempDistance * sinDir
			pos3.y = pos2.y + tempDistance * cosDir
			pos4.x = pos1.x - tempDistance * sinDir
			pos4.y = pos1.y + tempDistance * cosDir
			if AutoBattleController:isContain(pos1, pos2, pos3, pos4, playerPos) then
				table.insert(result, player)
			end
		end
	end

	return result
end

function AutoBattleController:isContain(p1, p2, p3, p4, p)
	if (AutoBattleController:Multiply(p, p1, p2) * AutoBattleController:Multiply(p, p4, p3) <= 0
			and AutoBattleController:Multiply(p, p4, p1) * AutoBattleController:Multiply(p, p3, p2) <= 0) then
		return true
	end
	return false
end

function AutoBattleController:Multiply(p1, p2, p)
	return ((p1.x - p.x) * (p2.y - p.y) - (p2.x - p.x) * (p1.y - p.y))
end

function AutoBattleController:CheckCastState()
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer:IsDead() == true then
		return false
	end
	if selfPlayer:IsPunish() == false then
		return false
	end
	if selfPlayer:IsChanState() == true then
		return false
	end
	if selfPlayer:IsPrepState() == true then
		return false
	end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then
		return false
	end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_CASTING) == 1 then
		return false
	end
	return true
end

--挂机时自动隐藏特效
function AutoBattleController:CheckHidePfx()
	do return end
	if AutoBattleController.isAutoHidePfx == true and AutoBattleController.startHangTime ~= 0 then
		return
	end

	if AutoBattleController.isAutoHidePfx == false and AutoBattleController.startHangTime == 0 then
		return
	end

	if AutoBattleController.isAutoHidePfx == false and AutoBattleController.startHangTime ~= 0
			and GetCurTime() - AutoBattleController.startHangTime >= AutoBattleController.autoHidePfxTime then
		AutoBattleController.isAutoHidePfx = true
		RemindController:AddRemind(RemindConsts.Type_HANG)
	end

	if AutoBattleController.isAutoHidePfx == true and AutoBattleController.startHangTime == 0 then
		AutoBattleController.isAutoHidePfx = false
	end
end

--点击UI后
function AutoBattleController:ShowPfx()
	AutoBattleController.isAutoHidePfx = false
	AutoBattleController.startHangTime = GetCurTime()
end

--自动切换到善恶模式
function AutoBattleController:AutoChangePkState()
	AutoBattleController.oldState = MainRolePKModel:GetPKIndex()
	MainMenuController:OnSendPkState(5)
end

function AutoBattleController:TabClickChar()
	local range = 100
	local pos = MainPlayerController:GetPlayer():GetPos()
	local attackTarget
	local attackList = AutoBattleController:GetAttackPlayerByRange(pos, range)
	if next(attackList) then
		if #attackList == 1 and attackList[1]:GetCid() == SkillController.targetCid then
			attackList = AutoBattleController:GetAttackMonsterByRange(pos, range)
		end
	else
		attackList = AutoBattleController:GetAttackMonsterByRange(pos, range)
	end
	if next(attackList) then
		attackTarget = attackList[math.random(1, #attackList)]
	end
	if not attackTarget then
		return
	end
	local cid = attackTarget:GetCid()
	SkillController:ClickLockChar(cid)
end

function AutoBattleController:GetAttackMonsterByRange(pos, range)
	local result = {}
	if not range then
		range = 100
	end
	local selfPos = MainPlayerController:GetPlayer():GetPos()
	if not pos then
		pos = selfPos
	end

	for cid, monster in pairs(MonsterModel:GetMonsterList()) do
		if AutoBattleController:CanAttack(cid) then
			local monsterPos = monster:GetPos()
			local size = monster:GetBoxWidth()
			if GetDistanceTwoPoint(pos, monsterPos) <= range + size then
				table.insert(result, monster)
			end
		end
	end
	local selfPosX, selfPosY = selfPos.x, selfPos.y
	local sortfunc = function(objFirst, objSecond)
		local firstPos = objFirst:GetPos()
		local secondPos = objSecond:GetPos()
		local posFirstX, posFirstY = firstPos.x, firstPos.y
		local posSecondX, posSecondY = secondPos.x, secondPos.y
		local disFirst = (posFirstX - selfPosX) ^ 2 + (posFirstY - selfPosY) ^ 2
		local disSecond = (posSecondX - selfPosX) ^ 2 + (posSecondY - selfPosY) ^ 2
		return disFirst < disSecond
	end

	table.sort(result, sortfunc)
	return result
end

function AutoBattleController:GetAttackPlayerByRange(pos, range)
	local result = {}
	if not range then
		range = 100
	end
	if not pos then
		pos = MainPlayerController:GetPlayer():GetPos()
	end
	local selfCid = MainPlayerController:GetRoleID()
	for cid, player in pairs(CPlayerMap:GetAllPlayer()) do
		if cid ~= selfCid and AutoBattleController:CanAttack(cid) then
			local playerPos = player:GetPos()
			if GetDistanceTwoPoint(pos, playerPos) <= range then
				table.insert(result, player)
			end
		end
	end
	local selfPos = MainPlayerController:GetPlayer():GetPos()
	local selfPosX, selfPosY = selfPos.x, selfPos.y
	local sortfunc = function(objFirst, objSecond)
		local posFirstX, posFirstY = objFirst:GetPos().x, objFirst:GetPos().y
		local posSecondX, posSecondY = objSecond:GetPos().x, objSecond:GetPos().y
		local disFirst = (posFirstX - selfPosX) ^ 2 + (posFirstY - selfPosY) ^ 2
		local disSecond = (posSecondX - selfPosX) ^ 2 + (posSecondY - selfPosY) ^ 2
		return disFirst < disSecond
	end

	table.sort(result, sortfunc)
	return result
end

function AutoBattleController:CanAttack(cid)
	local char, charType = CharController:GetCharByCid(cid)
	if not char then
		return false
	end
	if charType ~= enEntType.eEntType_Monster and charType ~= enEntType.eEntType_Player then
		return false
	end
	if char:IsDead() then
		return false
	end
	if char:GetStateInfoByType(PlayerState.UNIT_BIT_GOD) == 1 then
		return false
	end
	if charType == enEntType.eEntType_Player
			and MainPlayerController:PlayerIsAttack(cid) ~= 0 then
		return false
	elseif charType == enEntType.eEntType_Monster
			and MonsterController:MonsterIsAttack(cid) == false then
		return false
	end

	if charType == enEntType.eEntType_Monster
			and char:IsFengyao()
			and AutoBattleModel.noActiveAttackBoss then
		return false
	end

	local pos = char:GetPos()
	if not AreaPathFinder:CheckPoint(pos.x, pos.y) then
		return false
	end

	return true
end

function AutoBattleController:CheckNearAttackChar(pos, range)
	local list = AutoBattleController:GetNearAttackCharByRange(pos, range)
	if #list > 0 then
		return true
	end
	return false
end

function AutoBattleController:GetNearAttackCharByRange(pos, range)
	local attackList = AutoBattleController:GetAttackPlayerByRange(pos, range)
	local attackList1 = AutoBattleController:GetAttackMonsterByRange(pos, range)
	for _, char in pairs(attackList1) do
		table.insert(attackList, char)
	end
	return attackList
end

function AutoBattleController:AutoStopMove()
	local pos = AutoBattleController.HangPos
	local range = AutoBattleModel.findMonsterRange
	local selfPos = MainPlayerController:GetPlayer():GetPos()
	if SkillController.CurrSkillTargetPos == nil then
		if GetDistanceTwoPoint(pos, selfPos) > range then
			if MainPlayerController:IsMoveState() then
				MainPlayerController:StopMove()
			end
			AutoBattleController:RunHangPos()
		end
	end
end

function AutoBattleController:RunHangPos()
	local pos = AutoBattleController.HangPos
	local ret = CPlayerControl:AutoRun(pos, {
		func = function()
			SkillController.CurrSkillTargetPos = nil
		end
	})
	if ret == true then
		SkillController.CurrSkillTargetPos = pos
	else
		SkillController.CurrSkillTargetPos = nil
	end
end

function AutoBattleController:AutoRunHangPos()
	local selfPos = MainPlayerController:GetPlayer():GetPos()
	local pos = AutoBattleController.HangPos
	local dis = GetDistanceTwoPoint(pos, selfPos)
	if GetCurTime() - AutoBattleController.lastUseSkillTime > 8000
			and not MainPlayerController:IsMoveState() then
		SkillController.CurrSkillTargetPos = nil
		if dis > 5 then
			-- AutoBattleController:RunHangPos()
		end
	end
end

function AutoBattleController:WhenCastMagicFail(skillId)
	local nowTime = GetCurTime()
	local profID = MainPlayerController:GetProfID()
	local skillProf = string.sub(tostring(skillId), 1, 1)
	if profID ~= skillProf then
		return
	end
	if nowTime - AutoBattleController.castMagicFailTime < 1000 then
		if AutoBattleController:GetAutoHang() then
			SkillController:ClearTarget()
			AutoBattleController:RunHangPos()
		end
	end
	AutoBattleController.castMagicFailTime = nowTime
end

function AutoBattleController:GetSkillPriority(skillId)
	local priority = 0
	local skillConfig = t_skill[skillId]
	if skillConfig then
		local mapId = CPlayerMap:GetCurMapID()
		if skillConfig.showtype == SkillConsts.ShowType_WuHun
				and mapId == 10340003 then
			priority = skillConfig.priority + 1000
		else
			priority = skillConfig.priority
		end
	end
	return priority
end

function AutoBattleController:MainPlayerDead()
	if AutoBattleController:GetAutoHang()
			and AutoBattleModel.autoReviveSitu then
		AutoBattleController.isAutoHangInDeadState = true
		AutoBattleController.posInDeadState =
		{
			x = AutoBattleController.HangPos.x,
			y = AutoBattleController.HangPos.y
		}
	end
end

function AutoBattleController:MainPlayerRevive()
	if AutoBattleController.isAutoHangInDeadState then
		local pos = AutoBattleController.posInDeadState
		CPlayerControl:AutoRun(pos, {
			func = function()
				AutoBattleController:OpenAutoBattle()
			end
		})
		AutoBattleController.posInDeadState = nil
		AutoBattleController.isAutoHangInDeadState = false
	end
end

function AutoBattleController:AutoSendHangState()
	if not AutoBattleController:GetAutoHang() then
		return
	end

	if not CPlayerMap:IsFieldMap() then
		return
	end

	if MainRolePKModel:GetPKIndex() ~= 0 then
		return
	end

	local hour = GetCurrHour()
	if hour < 23 and hour >= 11 then
		return
	end

	local needSend = false
	if not AutoBattleController.firstSendHangState then
		if hour == 23 then
			local minute = GetCurrMinute()
			if minute < 5 then
				AutoBattleController.firstSendHangState = true
				needSend = true
			end
		end
	end

	local nowTime = GetCurTime()
	if nowTime - AutoBattleController.autoSendHangStateTime > 5 * 60 * 1000 then
		needSend = true
	end

	if needSend then
		AutoBattleController:SendHangState(1)
		AutoBattleController.autoSendHangStateTime = nowTime
	end
end

function AutoBattleController:ResetAutoSendHangStateTime()
	AutoBattleController.autoSendHangStateTime = GetCurTime()
end

function AutoBattleController:SetLastUseSkillTime(skillId)
	AutoBattleController:SetSkillCD(skillId)
	AutoBattleController.lastUseSkillTime = GetCurTime()
end

-------------------------------------------
function AutoBattleController:SendHangState(hangState)
	local msg = ReqHangStateMsg:new()
	msg.hangState = hangState
	MsgManager:Send(msg)
end

function AutoBattleController:PickInTransformSkill(pos)
	local skillId,skills = SkillModel:GetTransformHangSkills(pos);
	SkillController:PlayCastSkill(skillId);
end	