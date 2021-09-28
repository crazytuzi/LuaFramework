
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponPassiveSkill = i3k_class("wnd_hideWeaponPassiveSkill",ui.wnd_base)

local WIDGETS_ANQIJNT = "ui/widgets/anqijnt"
local WIDGETS_BAGUAQHT2 = "ui/widgets/baguaqht2"

function wnd_hideWeaponPassiveSkill:ctor()
	self._wid = nil  --暗器ID
	self._costTb = {} --技能升级消耗
end

function wnd_hideWeaponPassiveSkill:configure()
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(17315))
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets

	--技能图标
	self.skillUI = {}
	for i = 1, 3 do
		self.skillUI[i] = {
			skill_root 	= widgets["skillRoot" .. i],
			skill_btn	= widgets["skill"..i.."_btn"],
			up_arrow 	= widgets["up_arrow"..i],
			icon 		= widgets["icon"..i],
			label 		= widgets["label"..i],
			lock 		= widgets["lock"..i],  --暂时还没UI
		}
	end
end

--info wid是暗器id skillID是被动技能id
function wnd_hideWeaponPassiveSkill:refresh(info)
	self:initSkillPos()
	self:updateUI(info.wid, info.skillID)
end

function wnd_hideWeaponPassiveSkill:initSkillPos()
	--三个技能的位置
	local widgets = self._layout.vars
	self._posTable = {
		[1] = {radius = widgets.skillRoot1:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot1:getParent():convertToWorldSpace(widgets.skillRoot1:getPosition()))},
		[2] = {radius = widgets.skillRoot2:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot2:getParent():convertToWorldSpace(widgets.skillRoot2:getPosition()))},
		[3] = {radius = widgets.skillRoot3:getContentSize().width/2, pos = widgets.image:getParent():convertToNodeSpace(widgets.skillRoot3:getParent():convertToWorldSpace(widgets.skillRoot3:getPosition()))},
	}
end

function wnd_hideWeaponPassiveSkill:updateUI(wid, skillID)
	self._wid = wid

	local nowSkill = g_i3k_db.i3k_db_get_anqi_now_skill(self._wid)
	local sortSkill = g_i3k_db.i3k_db_sort_anqi_skill(nowSkill)

	self:updateSkillSlot(sortSkill)
	self:updateSkillScroll(sortSkill)
	self:showDefaultSkillInfo(sortSkill, skillID)
end

--已装备的被动技能库
function wnd_hideWeaponPassiveSkill:updateSkillSlot(sortSkill)
	local slot = g_i3k_game_context:GetSkillSlot(self._wid)
	local gradeCfg = g_i3k_db.i3k_db_get_one_anqi_skill_up_grade_cfg(self._wid)
	local slotCount = gradeCfg.slotCount

	local slotCfg = i3k_db_anqi_base[self._wid].gradeList

	local function getSkillData(skillID, skillLvl)
		for _, v in ipairs(sortSkill) do
			if v.skillID == skillID and v.skillLvl == skillLvl then
				return v
			end
		end
		return {}
	end

	for i, v in ipairs(self.skillUI) do
		local skillID = slot[i]
		local skillLvl = g_i3k_game_context:GetSkillLib(self._wid)[skillID]
		local skill = getSkillData(skillID, skillLvl)
		if skillID ~= 0 then
			v.up_arrow:setVisible(self:isShowUpArrow(skillID, skillLvl))
			v.skill_btn:onClick(self, function()
				self:showSkillInfo(skillID, skillLvl)
			end)
		end
		local isLock = not(slotCount >= i) -- 是否显示锁
		local grade = slotCfg[i]
		local gradeCfg2 = g_i3k_db.i3k_db_get_anqi_slot_cfg(grade)
		v.skill_root:setImage(g_i3k_db.i3k_db_get_icon_path(gradeCfg2.borderImage))
		local skillIconImg = skillID == 0 and gradeCfg2.cover or g_i3k_db.i3k_db_get_anqi_possitive_skill_icon(self._wid, skillID)
		v.icon:setVisible(not isLock)
		v.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillIconImg))
		local skillLevel = g_i3k_game_context:getHideWeaponSkillLevel(self._wid, skillID)
		v.label:setVisible(skillID ~= 0)
		v.label:setText(skillLevel.."级")
		v.lock:setVisible(isLock)
	end
end

--左侧被动技能库
function wnd_hideWeaponPassiveSkill:updateSkillScroll(sortSkill)
	self.ui.scroll:removeAllChildren()
	self.ui.scroll:stateToNoSlip()

	local allBars = self.ui.scroll:addChildWithCount(WIDGETS_ANQIJNT, 4, #sortSkill)
	for i, v in ipairs(allBars) do
		local skill = sortSkill[i]
		v.vars.btn:onTouchEvent(self, self.onSkillMove, {skill = skill, index = i})
		v.vars.desc:setText(skill.skillLvl .. "级")
		v.vars.lock:setVisible(false)
		v.vars.up_arrow:setVisible(self:isShowUpArrow(skill.skillID, skill.skillLvl))
		v.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skill.skillData.icon))
		v.vars.selectImg:hide()
		v.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(skill.skillData.cover))
	end
end

--是否显示可升级图标
function wnd_hideWeaponPassiveSkill:isShowUpArrow(skillID, skillLvl)
	local nextSkill = g_i3k_db.i3k_db_get_one_anqi_skill(self._wid, skillID, skillLvl + 1)
	if nextSkill then
		local isShow = true
		for _, v in ipairs(nextSkill.props) do
			if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
				isShow = false
			end
		end
		return isShow
	else
		return false
	end
end

function wnd_hideWeaponPassiveSkill:onSkillMove(sender, eventType, data)
	local mousePos = g_i3k_ui_mgr:GetMousePos()
	local pos = self.ui.image:getParent():convertToNodeSpace(mousePos)

	local skill = data.skill
	local index = data.index

	local skillIcon = skill.skillData.icon

	if eventType == ccui.TouchEventType.began then
		self:showSelectImg(index)
		self:showSkillInfo(skill.skillID, skill.skillLvl)

		self.ui.image:show()
		self.ui.image:setPosition(pos)
		self.ui.image:setImage(g_i3k_db.i3k_db_get_icon_path(skillIcon))
	elseif eventType == ccui.TouchEventType.moved then
		self.ui.image:setPosition(pos)
	else
		local disTable = {
			[1] = math.sqrt(math.pow(pos.x - self._posTable[1].pos.x, 2) + math.pow(pos.y - self._posTable[1].pos.y, 2)),
			[2] = math.sqrt(math.pow(pos.x - self._posTable[2].pos.x, 2) + math.pow(pos.y - self._posTable[2].pos.y, 2)),
			[3] = math.sqrt(math.pow(pos.x - self._posTable[3].pos.x, 2) + math.pow(pos.y - self._posTable[3].pos.y, 2)),
		}
		for i, v in ipairs(disTable) do
			if v <= self._posTable[i].radius then
				self:changeSkill(i, skill)
				break
			end
		end
		self.ui.image:hide()
	end
end

--默认选择一个技能
function wnd_hideWeaponPassiveSkill:showDefaultSkillInfo(sortSkill, skillID)
	if skillID ~= 0 then
		local skillLvl = g_i3k_game_context:GetSkillLib(self._wid)[skillID]
		for i, v in ipairs(sortSkill) do
			if v.skillID == skillID and v.skillLvl == skillLvl then
				self:showSelectImg(i)
				self:showSkillInfo(skillID, skillLvl)
				break
			end
		end
	else
		self:showSelectImg(1)
		self:showSkillInfo(sortSkill[1].skillID, sortSkill[1].skillLvl)
	end
end

function wnd_hideWeaponPassiveSkill:showSelectImg(index)
	for i, v in ipairs(self.ui.scroll:getAllChildren()) do
		v.vars.selectImg:setVisible(i == index)
	end
end

--点击选择一个技能
function wnd_hideWeaponPassiveSkill:showSkillInfo(skillID, skillLvl)
	local nextSkill = g_i3k_db.i3k_db_get_one_anqi_skill(self._wid, skillID, skillLvl + 1)
	local nowSkill = g_i3k_db.i3k_db_get_one_anqi_skill(self._wid, skillID, skillLvl)

	self.ui.skillNode:setVisible(nextSkill ~= nil)
	self.ui.maxNode:setVisible(nextSkill == nil)

	if nextSkill then
		self.ui.skill_desc_next:setText(nextSkill.desc)
		self.ui.skill_desc_now:setText(nowSkill.desc)
		self.ui.skill_name:setText(nowSkill.skillName)

		self._costTb = nextSkill.props --升级消耗道具
		self:updateCostItem()

		self.ui.up_btn:onClick(self, self.onUpSkillLvl, skillID)
	else
		self.ui.skill_desc_now2:setText(nowSkill.desc)
		self.ui.skill_name2:setText(nowSkill.skillName)

		self._layout.anis.max.play()
		self._layout.anis.xzh.play()
	end
end

function wnd_hideWeaponPassiveSkill:updateCostItem()
	self.ui.cost_scroll:removeAllChildren()

	local costTb = self._costTb
	for _, v in ipairs(costTb) do
		local ui = require(WIDGETS_BAGUAQHT2)()
		ui.vars.bt:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
		end)
		ui.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		local text = (math.abs(v.id) == g_BASE_ITEM_COIN or math.abs(v.id) == g_BASE_ITEM_DIAMOND) and v.count or canUseCount.."/"..v.count  -- 铜钱只显示数量
		ui.vars.name:setText(text)
		ui.vars.name:setTextColor(canUseCount < v.count and g_i3k_get_red_color() or g_i3k_get_green_color())
		ui.vars.suo:setVisible(v.id > 0)
		self.ui.cost_scroll:addItem(ui)
	end
end

--升级被动技能
function wnd_hideWeaponPassiveSkill:onUpSkillLvl(sender, skillID)
	for _, v in ipairs(self._costTb) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			g_i3k_ui_mgr:PopupTipMessage("升级所需道具不足")
			return
		end
	end
	i3k_sbean.hideweapon_pskill_levelup(self._wid, skillID, self._costTb)
end

--替换被动技能
--index是需要替换的技能位置
function wnd_hideWeaponPassiveSkill:changeSkill(slotIndex, skill)
	local gradeCfg = g_i3k_db.i3k_db_get_one_anqi_skill_up_grade_cfg(self._wid)
	local slotCount = gradeCfg.slotCount
	if slotIndex > slotCount then
		local needGrade = g_i3k_db.i3k_db_get_one_anqi_change_skill_need_grade(self._wid, slotIndex)
		local gradeName = g_i3k_db.i3k_db_get_anqi_grade_name(needGrade)
		g_i3k_ui_mgr:PopupTipMessage(string.format("暗器达到%s解锁该插槽", gradeName))
		return
	end

	local skillBaseCfg = g_i3k_db.i3k_db_get_one_anqi_skill_base_cfg(self._wid)
	local grade = skillBaseCfg.gradeList[slotIndex]
	if skill.skillData.grade > grade then
		g_i3k_ui_mgr:PopupTipMessage("技能品质高于插槽品质无法装备")
		return
	end

	local skillSlot = g_i3k_game_context:GetSkillSlot(self._wid)
	local oldSkillID = skillSlot[slotIndex]

	--替换相同位置的技能
	if oldSkillID == skill.skillID then
		return
	end

	--低品质替换高品质技能
	local oldIndex = 0
	for index, skillID in ipairs(skillSlot) do
		if skillID == skill.skillID then
			oldIndex = index
			break
		end
	end
	if oldIndex ~= 0 and oldSkillID ~= 0 then
		local oldGrade = skillBaseCfg.gradeList[oldIndex]
		local skillCfg = g_i3k_db.i3k_db_get_one_anqi_skill(self._wid, oldSkillID, 1)
		local newGrade = skillCfg.grade
		if newGrade > oldGrade then
			g_i3k_ui_mgr:PopupTipMessage("技能品质高于插槽品质无法装备")
			return
		end
	end

	i3k_sbean.hideweapon_pskill_select(self._wid, slotIndex, skill.skillID)
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponPassiveSkill.new()
	wnd:create(layout, ...)
	return wnd;
end
