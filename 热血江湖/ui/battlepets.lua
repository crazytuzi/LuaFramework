module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battlePets = i3k_class("wnd_battlePets", ui.wnd_base)
local skill_grade = {151,152,153,154,155}
function wnd_battlePets:ctor()
	self._isMoveDown = false
end

function wnd_battlePets:configure()
    local widget=self._layout.vars
    --左侧佣兵信息
	local pets = {}
	pets.root = self._layout.vars.petsRoot
	local pets1 = {}
	pets1.root = widget.yb1
	pets1.btn = widget.petSkillBtn1
    pets1.btnRoot = widget.petSkill1
    pets1.skillHeadIcon = widget.skillHeadIcon1
	pets1.skillHeadIconBg = widget.skillHeadIconBg1
	pets1.bloodBar = widget.nursext
	pets1.spRoot = widget.petSp1
	pets1.spBar = widget.nurseSP
	pets1.icon = widget.nursetx
	pets1.iconBg = widget.iconBg1
	pets1.cool = widget.petTimer1

	-- pets1.levelLabel = widget.nurselevel
	-- pets1.nameLabel = widget.nurseName
	-- pets1.anis = self._layout.anis.c_nuqi
	pets[1] = pets1

	local pets2 = {}
	pets2.root = widget.yb2
	pets2.btn = widget.petSkillBtn2
    pets2.btnRoot = widget.petSkill2
    pets2.skillHeadIcon = widget.skillHeadIcon2
	pets2.skillHeadIconBg = widget.skillHeadIconBg2
	pets2.bloodBar = widget.nursext2
	pets2.spRoot = widget.petSp2
	pets2.spBar = widget.nurseSP2
	pets2.icon = widget.nursetx2
	pets2.iconBg = widget.iconBg2
	pets2.cool = widget.petTimer2
	-- pets2.levelLabel = widget.nurselevel2
	-- pets2.nameLabel = widget.nurseName2
	-- pets2.anis = self._layout.anis.c_nuqi2
	pets[2] = pets2

	local pets3 = {}
	pets3.root = widget.yb3
	pets3.btn = widget.petSkillBtn3
    pets3.btnRoot = widget.petSkill3
    pets3.skillHeadIcon = widget.skillHeadIcon3
	pets3.skillHeadIconBg = widget.skillHeadIconBg3
	pets3.bloodBar = widget.nursext3
	pets3.spRoot = widget.petSp3
	pets3.spBar = widget.nurseSP3
	pets3.icon = widget.nursetx3
	pets3.iconBg = widget.iconBg3
	pets3.cool = widget.petTimer3
	-- pets3.levelLabel = widget.nurselevel3
	-- pets3.nameLabel = widget.nurseName3
	-- pets3.anis = self._layout.anis.c_nuqi3
	pets[3] = pets3
    self._widgets = {}
	self._widgets.pets = pets
end

function wnd_battlePets:moveDownForInternalInjuryUI(isMoveDown)
	if isMoveDown and not self._isMoveDown then
		local petNode1 = self._layout.vars.yb1
		local petNode2 = self._layout.vars.yb2
		local petNode3 = self._layout.vars.yb3
		local yAbOffset = 10 --编辑器内设定值
		local yAbSizeY = 540
		local yfactor = yAbOffset / yAbSizeY
		local yRealOffset = petNode1:getParent():getContentSize().height * yfactor
		local tmpPos = petNode1:getPosition()
		petNode1:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		tmpPos = petNode2:getPosition()
		petNode2:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		tmpPos = petNode3:getPosition()
		petNode3:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		self._isMoveDown = true
	end
end
function wnd_battlePets:refresh()
    self:updateMercenaries(g_i3k_game_context:GetFightMercenaries())
end


function wnd_battlePets:updateMercenaries(fightPetIds)
	-- if g_i3k_game_context:GetWorldMapType() == g_TOURNAMENT then
	-- 	self._widgets.pets[1].root:hide()
	-- 	self._widgets.pets[3].root:hide()
	-- 	self._widgets.pets[3].btnRoot:hide()
	-- 	self._widgets.pets[1].btnRoot:hide()
	-- 	for _,v in ipairs(fightPetIds) do
	-- 		self:updateFightMercenaries(2, v, g_i3k_game_context:GetFightMercenaryInfo(v))
	-- 		break
	-- 	end
	-- else
		local index = 1
		for i,v in ipairs(fightPetIds) do
			self:updateFightMercenaries(index, v, g_i3k_game_context:GetFightMercenaryInfo(v))
			index = index + 1
		end
		while index<=3 do -- 控制显示的个数
			self:updateFightMercenaries(index)
			index = index + 1
		end
	-- end
    -- check show pets or not
    if (fightPetIds == nil) or (next(fightPetIds) == nil)  then
        g_i3k_ui_mgr:CloseUI(eUIID_BattlePets)
    end
	-- if g_i3k_game_context:GetWorldMapType() ~= g_TOURNAMENT then
	-- 	if g_i3k_ui_mgr:GetUI(eUIID_BattleTeam) then
	-- 		g_i3k_ui_mgr:CloseUI(eUIID_BattlePets)
	-- 	end
	-- end
end
--左侧佣兵信息
function wnd_battlePets:updateFightMercenaries(index, id, level, name, curHp, maxHp, curSp, maxSp, deadTime)
	local widgets = self._widgets.pets[index]
	if id then
		widgets.root:setTag(id)
		local logic = i3k_game_get_logic();
		local world = logic:GetWorld()
		local rank = i3k_db_mercenaries[id].rank
		widgets.root:show()
		local hpPercent = curHp/maxHp*100
		widgets.bloodBar:setPercent(hpPercent)
		widgets.icon:enable()
		local icon = g_i3k_db.i3k_db_get_pet_cfg(id).icon;
		if g_i3k_game_context:getPetWakenUse(id) then
			icon = i3k_db_mercenariea_waken_property[id].headIcon;
		end
		widgets.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(icon, false))
		widgets.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[rank]))
        widgets.skillHeadIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(icon))
		widgets.skillHeadIconBg:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[rank]))
		-- widgets.nameLabel:setText(name)
		-- widgets.nameLabel:setTextColor("FFFFFFFF")
		-- widgets.levelLabel:setText(level)
		-- widgets.levelLabel:setTextColor("FFE9E564")
        widgets.cool:hide()
		if hpPercent==0 then
			if g_i3k_db.i3k_db_get_pets_is_auto_revive() then
				local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
				local reviveTime = i3k_db_common.posUnlock.autoRevive
				local disTime = timeNow - deadTime
				i3k_log("deadTime = "..deadTime.."    reviveTime = "..reviveTime.."    disTime = "..disTime)
				if disTime<reviveTime then
					local timePercent = (reviveTime-disTime)/reviveTime
					local progressAction = widgets.cool:createProgressAction(reviveTime-disTime, 100*timePercent, 0)
					widgets.cool:show()
					widgets.cool:runAction(progressAction)
				end
			else
				widgets.icon:disable()
				-- widgets.levelLabel:setTextColor("FFC7E3DD")
				-- widgets.levelLabel:setText("死亡")
				-- widgets.nameLabel:setTextColor("FFD11B00")
			end
		else
			widgets.cool:hide()
		end
		local spPercent = curSp/maxSp*100
		widgets.spBar:setPercent(spPercent)
        widgets.btnRoot:hide()
		if spPercent==100 and hpPercent~=0 then
			-- widgets.anis.play()
			-- widgets.icon:onClick(self, self.petsSkill, id)
            widgets.btnRoot:show()
			local world = i3k_game_get_world()
			local hero = i3k_game_get_player_hero()
			if hero and not hero:IsInFightTime() and world._syncRpc then
				widgets.btnRoot:hide()
            end
            widgets.btn:onClick(self,self.petsSkill,id)
		else
			-- widgets.anis.stop()
			widgets.icon:setTouchEnabled(false)
		end

	else
		widgets.root:hide()
        widgets.btnRoot:hide()
	end
end

function wnd_battlePets:clearCoolAction()
    self._layout.vars.petTimer1:hide()
    self._layout.vars.petTimer2:hide()
    self._layout.vars.petTimer3:hide()
end

function wnd_battlePets:getPetsControl(id)
	for i,v in pairs(self._widgets.pets) do
		if v.root and v.root:getTag()==id then
			return v
		end
	end
end

function wnd_battlePets:petsSkill(sender, id)
	local widgets = self:getPetsControl(id)
	-- widgets.anis.stop()
	widgets.icon:setTouchEnabled(false)
	local logic = i3k_game_get_logic()
	local mercenary = i3k_game_get_mercenary_entity(id)
	if mercenary then
		if mercenary._behavior:Test(eEBStun) or mercenary._behavior:Test(eEBFear) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(607, i3k_db_mercenaries[id].name))
			return
		else
			mercenary:UltraSkill()
			widgets.spBar:setPercent(0)
		end
	end
end

function wnd_battlePets:syncPetsHp(mercenaryId, curHp, maxHp)
	local widgets = self:getPetsControl(mercenaryId)
	if widgets then
		local percent = curHp/maxHp*100
		widgets.bloodBar:setPercent(percent)
		if percent==0 then
			if g_i3k_db.i3k_db_get_pets_is_auto_revive() then
				local reviveTime = i3k_db_common.posUnlock.autoRevive
				local progressAction = widgets.cool:createProgressAction(reviveTime, 100, 0)
				widgets.cool:show()
				widgets.cool:runAction(progressAction)
			else
				widgets.icon:disable()
				-- widgets.levelLabel:setTextColor("FFC7E3DD")
				-- widgets.levelLabel:setText("死亡")
				-- widgets.nameLabel:setTextColor("FFD11B00")
			end
			-- widgets.anis.stop()
		else
			widgets.icon:enable()
			widgets.cool:hide()
			-- widgets.nameLabel:setTextColor("FFFFFFFF")
			-- widgets.levelLabel:setTextColor("FFE9E564")
		end
	end
end

function wnd_battlePets:syncPetsSp(mercenaryId, curSp, maxSp)
	local widgets = self:getPetsControl(mercenaryId)
	if widgets then
		local percent = curSp/maxSp*100
		widgets.spBar:setPercent(percent)
		local nowpersent = widgets.bloodBar:getPercent()
		if percent==100 and widgets.bloodBar:getPercent()~=0 then
			-- widgets.icon:onClick(self, self.petsSkill, mercenaryId)
			widgets.btnRoot:show()
			local mapType = g_i3k_game_context:GetWorldMapType()
			local hero = i3k_game_get_player_hero()
			if hero and not hero:IsInFightTime() and mapType == g_FIELD and g_i3k_game_context:GetPKMode() == 0 then
				widgets.btnRoot:hide()
            end
            widgets.btn:onClick(self,self.petsSkill,mercenaryId)
			-- widgets.anis.play()
		else
			widgets.icon:setTouchEnabled(false)
            widgets.btnRoot:hide()
			-- widgets.anis.stop()
		end
	end
end

function wnd_battlePets:onUpdate(dTime)
	for i,v in ipairs(self._widgets.pets) do
		if v.root:isVisible() and v.bloodBar:getPercent() ~= 0 and v.spBar:getPercent() == 100 then
			local mapType = g_i3k_game_context:GetWorldMapType()
			local hero = i3k_game_get_player_hero()
			if hero and not hero:IsInFightTime() and mapType == g_FIELD and g_i3k_game_context:GetPKMode() == 0 then
				v.btnRoot:hide()
			else
				v.btnRoot:show()
            end
		end
	end
	self:moveDownForInternalInjuryUI(g_i3k_game_context:GetLevel() >= i3k_db_wujue.inhurtLevel)
end
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_battlePets.new();
		wnd:create(layout);
	return wnd;
end
