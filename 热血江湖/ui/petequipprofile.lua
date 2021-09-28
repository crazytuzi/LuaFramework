-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_petEquipProfile = i3k_class("wnd_petEquipProfile",ui.wnd_base)

--开放宠物装备部位数
local PET_EQUIP_PART_OPEN_CONT = #i3k_db_pet_equips_part

--开始点击事件和结束时间
local startTime
local endTime
--开始位置和结束位置
local startPos
local endPos
local dis --距离
local speed --速度 
local time --时间

function wnd_petEquipProfile:ctor()
	self.pet_equip = {}
	for i = 1, g_PET_EQUIP_PART_COUNT do
		self.pet_equip[i] = {
			equip_btn	= nil, --装备button
			equip_icon	= nil, --装备Icon
			grade_icon	= nil, --装备品级框
			is_select	= nil, --装备是否被选择
			level_label	= nil, --装备等级label
			red_tips	= nil  --装备红点
		}
	end
	
	self.pet_power		= nil --战力
	self.hero_module	= nil --模型
	self.revolve 		= nil --旋转模型的btn
	self.petScroll 		= nil --下方宠物列表
	self.equipPoint		= nil
	self.upLvlPoint 	= nil
	self.skillPoint 	= nil
	self.addIcon 		= nil
	self.powerValue 	= nil

	--默认分组
	self._choosePetGroup = g_i3k_game_context:GetPetEquipGroup()
	self._curPetID = 0
	self._isChange = false
	self._poptick = 0
	self._target = 0
	self._base = 0
end

function wnd_petEquipProfile:configure()

end

--升级，装备，卸下，更换调用此方法
function wnd_petEquipProfile:changeBattlePower(newBattlePower, oldBattlePower)
	self._target = newBattlePower
	self._base = oldBattlePower

	local fieldPetID = g_i3k_game_context:getFieldPetID()
	self._isChange = self._target ~= self._base
	self._poptick = 0
end

function wnd_petEquipProfile:onUpdate(dTime)--随从战力变化时动画
	if self._isChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self.pet_power:setText(text)
			self.addIcon:show()
			self.powerValue:show()
			if self._target >= self._base then
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				self.powerValue:setText("+"..self._target - self._base)
			else
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				self.powerValue:setText(self._target - self._base)
			end
			self.powerValue:setTextColor(g_i3k_get_cond_color(self._target >= self._base))
		elseif self._poptick >= 1 and self._poptick < 2 then
			self.pet_power:setText(self._target)
			self.addIcon:hide()
			self.powerValue:hide()
		elseif self._poptick > 2 then
			self.addIcon:hide()
			self.powerValue:hide()
			self._isChange = false
		end
	end
end

--设置装备信息
function wnd_petEquipProfile:updateProfile(group)
	local petEquips = g_i3k_game_context:GetPetEquipsData(group)
	for i, v in ipairs(self.pet_equip) do
		if i <= PET_EQUIP_PART_OPEN_CONT then
			local equipID = petEquips[i]
			if equipID then
				v.equip_btn:enable()
				v.equip_icon:show()
				v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
				v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
				v.equip_btn:onClick(self, self.onSelectEquip, {group = group, partID = i, equipID = equipID})
				v.level_label:hide()
			else
				v.equip_btn:disable()
				v.equip_icon:hide()
				v.grade_icon:setImage(g_i3k_get_pet_equip_icon_frame_path_by_pos(i))
				v.level_label:hide()
			end
		else
			v.equip_icon:setImage()--一张灰化的图
			v.grade_icon:setImage(g_i3k_get_pet_equip_icon_frame_path_by_pos(i))
			v.level_label:hide()
			v.equip_btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1537))
			end)
		end
		v.red_tips:hide()
		v.is_select:hide()
	end
end

function wnd_petEquipProfile:onSelectEquip(sender, data)
	for i, v in ipairs(self.pet_equip) do
		v.is_select:setVisible(i == data.partID)
	end
	--打开装备比较面板
end

--刷新下方宠物列表
function wnd_petEquipProfile:updatePetScroll(isFirst, isFight)
	local group = self:getChooseGroup()

	local selectIndex = 0
	local petID = 0

	local petCfgData = g_i3k_db.i3k_db_get_pet_cfg_data_by_group(group)
	self.petScroll:removeAllChildren()
	for i, v in ipairs(petCfgData) do
		local item = require("ui/widgets/xunyanglbt")()
		local id = v.id
		local iconID = v.icon

		if g_i3k_game_context:getPetWakenUse(id) then
			iconID = i3k_db_mercenariea_waken_property[id].headIcon
		end
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconID, true))
		item.vars.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(v.rank))
		item.vars.level:setText(g_i3k_game_context:getPetLevel(id))
		local isHave = g_i3k_game_context:IsHavePet(id)
		item.vars.levelIcon:setVisible(isHave)
		item.vars.selectBtn:SetIsableWithChildren(isHave)
		item.vars.icon:SetIsableWithChildren(isHave)
		item.vars.iconBg:SetIsableWithChildren(isHave)

		item.vars.selectBtn:onClick(self, function()
			self:selectPet(i, id)
		end)

		--默认选中的宠物
		if isHave and selectIndex == 0 then
			selectIndex = i
			petID = id
		end

		self.petScroll:addItem(item)
	end

	--正在野外出战的宠物
	if isFirst then
		local filedPetID = g_i3k_game_context:getFieldPetID()
		petID = filedPetID ~= 0 and filedPetID or petID
	end
	--正在试炼副本的宠物
	if isFight then
		local dungeonPetID = g_i3k_game_context:getPetDungeonID()
		petID = dungeonPetID ~= 0 and dungeonPetID or petID
	end
	for i, v in ipairs(petCfgData) do
		if v.id == petID then
			selectIndex = i
		end
	end

	self:selectPet(selectIndex, petID)
end

--选择宠物
function wnd_petEquipProfile:selectPet(index, petID)
	local group = self:getChooseGroup()
	local allPetLayer = self.petScroll:getAllChildren()
	--self.petScroll:jumpToChildWithIndex(index)

	self._curPetID = petID
	g_i3k_game_context:SetPetEquipPet(petID)

	for i, v in ipairs(allPetLayer) do
		v.vars.selectImg:setVisible(index == i)
	end
	self:setBattlePower(group, petID)
	self:setPetModle(petID)
end

--设置宠物战力
function wnd_petEquipProfile:setBattlePower(group, petID)
	--切换宠物停止战力变化
	self._isChange = false
	self.addIcon:hide()
	self.powerValue:hide()
	local power = g_i3k_game_context:getBattlePower(petID)
	self.pet_power:setText(power)
end

--设置宠物模型
function wnd_petEquipProfile:setPetModle(id)
	local ishave = g_i3k_game_context:IsHavePet(id)
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
	if ishave then
		local isUseAwaken = g_i3k_game_context:getPetWakenUse(id)
		if isUseAwaken then
			cfg = i3k_db_mercenariea_waken_property[id]
		end
	end
	if cfg and cfg.modelID then
		local path = i3k_db_models[cfg.modelID].path
		local uiscale = i3k_db_models[cfg.modelID].uiscale
		self.hero_module:setSprite(path)
		self.hero_module:setSprSize(uiscale)
		self.hero_module:setRotation(2)

		if isAwake then
			self.hero_module:pushActionList(i3k_db_mercenariea_waken_cfg.action, 1)
			self.hero_module:pushActionList("stand", -1)
			self.hero_module:playActionList()
		else
			self.hero_module:playAction("stand")
		end
	end
end

--得到分组
function wnd_petEquipProfile:getChooseGroup()
	return self._choosePetGroup
end

function wnd_petEquipProfile:onRotateBtn(sender, eventType)--isNotBreakCurAct 如果是true 就不打断当前动作
	if eventType == ccui.TouchEventType.began then
		self.rotate = self.hero_module:getRotation()
		self.hero_module:setRotation(self.rotate.y)
		startTime = i3k_game_get_time()
		startPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	else
		endPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
		endTime = i3k_game_get_time()
		self:getRotate()
		if eventType==ccui.TouchEventType.ended then
			self.index = 0
		end
	end
end

function wnd_petEquipProfile:getRotate()--是否屏蔽打断当前动作
	local btnPos = self.revolve:getPosition()
	local btnContentSize = self.revolve:getContentSize()
	local minPosX = btnPos.x - btnContentSize.width / 2
	local maxPosX = btnPos.x + btnContentSize.width / 2
	if endPos.x < minPosX then
		endPos.x = minPosX
	elseif endPos.x > maxPosX then
		endPos.x = maxPosX
	end
	dis = endPos.x - startPos.x
	time = endTime - startTime
	speed = dis / time
	local angel = self.rotate.y + math.rad(-dis)
	self.hero_module:setRotation(angel)
	self.index = self.index or 0
end

function wnd_petEquipProfile:updateTabRedPoint()
	self.equipPoint:setVisible(false)
	self.upLvlPoint:setVisible(g_i3k_game_context:UpdatePetEquipGroupPoint(self:getChooseGroup()))
	self.skillPoint:setVisible(g_i3k_game_context:UpdatePetSkillTabPoint())
	self.guardPoint:setVisible(g_i3k_db.i3k_db_pet_guard_main_red())
end

function wnd_create(layout)
	local wnd = wnd_petEquipProfile.new()
		wnd:create(layout)
	return wnd
end
