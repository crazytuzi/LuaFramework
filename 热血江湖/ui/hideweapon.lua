
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeapon = i3k_class("wnd_hideWeapon",ui.wnd_base)


local SELECT_BG = 706
local NORMAL_BG = 707

-- 右侧ui填充
local UP_GRADE = 1
local UP_STAR = 2
local UP_DESC = 3


local UI_RIGHT_CLUE = 1 -- 线索
local UI_RIGHT_DESC = 2 -- 介绍
local UI_RIGHT_GRADE = 3 -- 升品
local UI_RIGHT_LEVEL = 4 -- 升阶

local STATE_UNLOCK = 1 -- 未解锁
local STATE_LOCKED = 2 -- 已经解锁

local HUANHUA_ACTVTE_IMGID = 7399
local HUANHUA_LOCK_IMGID = 7398

function wnd_hideWeapon:ctor()
	self._anqiID = 0
	self._rightBtnIndex = UP_GRADE -- 右侧按钮的id
	self._allTap = {}
end


function wnd_hideWeapon:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.help_btn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17312))
	end)
	widgets.equipBtn:onClick(self, self.onEquipBtn)

	self._rightUIList =
	{
		[UP_GRADE] = { btn = widgets.upGradeBtn},
		[UP_STAR] = { btn = widgets.upStarBtn},
		[UP_DESC] = { btn = widgets.descBtn},
	}

	self._state =
	{
		[STATE_UNLOCK] = {tabNums = 2, sender = {self.onClueBtn, self.onDescBtn}, text = {"线索", "介绍",} },
		[STATE_LOCKED] = {tabNums = 3, sender = {self.onUpGradeBtn, self.onUpStarBtn, self.onDescBtn}, text = {"升品", "升级", "介绍"} },
	}
	self._senderIndex = {}

	self:initRightMainBtns()
	widgets.comment:onClick(self, self.onComment)
	widgets.recycleBtn:onClick(self, self.onRecycle)
	widgets.huanhuaBtn:onClick(self, self.onHuanhua)
end

function wnd_hideWeapon:onShow()
	local info = g_i3k_game_context:getHideWeaponInfo()
	if info.curWeapon and info.curWeapon ~= 0 then
	 	self._anqiID = info.curWeapon
	end
end

function wnd_hideWeapon:initRightMainBtns()
	local widgets = self._layout.vars
	widgets.upGradeBtn:stateToPressed()
	self._btns =
	{
		[1] = {btn = widgets.upGradeBtn, label = widgets.upGradeLabel, red = widgets.upGradeRed },
		[2] = {btn = widgets.upStarBtn, label = widgets.upStarLabel, red = widgets.upStarRed },
		[3] = {btn = widgets.descBtn, label = widgets.descLabel, red = widgets.descRed },
	}
	self:updateBtnSender()
end

function wnd_hideWeapon:updateBtnSender()
	for k, v in ipairs(self._btns) do
		v.btn:onClick(self, self.handleBtn, k)
	end
end

function wnd_hideWeapon:handleBtn(sender, index)
	local cfg = self._senderIndex[index]
	local btnFunc = self._state[cfg.state].sender[index]
	if not btnFunc then
		error(cfg.state .." "..index)
	end
	btnFunc(self, nil, index)
end


function wnd_hideWeapon:refresh()
	self:updateLeftScroll()
	self:updateAnqiIndex(self._anqiID)
end

function wnd_hideWeapon:updateAnqiIndex(index)
	self._anqiID = index
	local rightIndex = self:getRightBtnIndex()
	self:setRightBtnIndex(rightIndex) -- 初始化下右侧的标签刷新
	self:updateLeftScrollSelect(index)
	self:initUIByState(index)
	self:updateRightRed(index)
	self:initMainInfo()
	self._layout.vars.recycleBtn:setVisible(self:getIsMaxGrade(index))
	self:updateHuanhuaBtnState(index)
end

function wnd_hideWeapon:getAnqiID()
	return self._anqiID
end


-- 右侧页签，3个大按钮
function wnd_hideWeapon:setRightBtnIndex(id)
	self._rightBtnIndex = id
end
function wnd_hideWeapon:getRightBtnIndex()
	return self._rightBtnIndex
end


function wnd_hideWeapon:getState(id)
	local info = g_i3k_game_context:getHideWeaponInfo()
	return info.weapons[id] and STATE_LOCKED or STATE_UNLOCK -- 如果不为空，那么就解锁了
end

function wnd_hideWeapon:initUIByState(index)
	local state = self:getState(index)
	local stateCfg = self._state[state]
	for k, v in ipairs(self._btns) do
		if k <= stateCfg.tabNums then
			self._senderIndex[k] = {state = state}
			-- v.btn:onClick(self, stateCfg.sender[k], k)
			v.label:setText(stateCfg.text[k])
			v.btn:show()
		else
			v.btn:hide()
		end
	end
	local pageIndex = self:getRightBtnIndex()
	local func = stateCfg.sender[pageIndex]  -- 模拟按钮监听器

	func(self, nil, pageIndex)
end

-- 界面中间部分显示
function wnd_hideWeapon:initMainInfo()
	local index = self:getAnqiID()
	self:setSkillData(index)
	self:setEffectData(index)
	self:SetModule(index)
	self:setPower(g_i3k_game_context:getOneHideWeaponFightPower(index))
	local widgets = self._layout.vars

	local cfg = g_i3k_game_context:getHideWeaponInfo()
	widgets.typeLabel:setText(i3k_db_anqi_base[index].typeName)
	local weaponInfo = cfg.weapons[index]
	if cfg.curWeapon == index then
		widgets.equipBtn:disableWithChildren()
		widgets.equip_weapon_lable:setText("已装备")
		widgets.battle_bg:show()
	else
		if weaponInfo then
			widgets.equipBtn:enableWithChildren()
			widgets.equip_weapon_lable:setText("装备暗器")
			widgets.battle_bg:show()
		else
			widgets.equipBtn:disableWithChildren()
			widgets.equip_weapon_lable:setText("尚未解锁")
			widgets.battle_bg:hide()
			self:setlockModule()
		end
	end
end


function wnd_hideWeapon:setPower(value)
	local widgets = self._layout.vars
	widgets.battle_power:setText(value)
end

-- 主动技能
function wnd_hideWeapon:setSkillData(anqiID)
	local widgets = self._layout.vars
	local skillID = i3k_db_anqi_base[anqiID].skillID
	local skill_data = i3k_db_skills[skillID]
	widgets.skill4_bg:setImage()
	widgets.skill4_btn:onClick(self, self.onSkillBtn, skillID)
	widgets.up_arrow4:setVisible(g_i3k_game_context:CanHideWeaponUpASkill(anqiID))
	local isunLock = g_i3k_game_context:getHideWeaponByID(anqiID)
	widgets.skillLock4:setVisible((not isunLock )and true or false)
	local path = g_i3k_db.i3k_db_get_anqi_skin_skillId_by_skinID(anqiID, skillID)
	widgets.skillIcon4:setImage(path)
	local skillLevel = g_i3k_game_context:GetHideWeaponFinalActiveSkillLvl(anqiID)
	widgets.label4:setText(skillLevel.."级")
	widgets.label4:setVisible(isunLock and true or false)
end

-- 被动技能
function wnd_hideWeapon:setEffectData(list)
	local widgets = self._layout.vars
	local anqiID = self:getAnqiID()
	local slotCfg = i3k_db_anqi_base[anqiID].gradeList
	local skills = g_i3k_game_context:GetSkillSlot(anqiID)
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	local slotCount = 0
	if cfg then
		local cfgNow = i3k_db_anqi_grade[anqiID][cfg.rankValue]
		slotCount = cfgNow.slotCount
	end

	for i = 1, 3 do
		local isLock = not(slotCount >= i) -- 是否显示锁
		local info = {id = i, isLock = isLock, skillID = skills[i] }
		widgets["skill"..i.."_btn"]:onClick(self, self.onEffectBtn, info)
		local grade = slotCfg[i]
		local gradeCfg = g_i3k_db.i3k_db_get_anqi_slot_cfg(grade)
		local skillID = skills[i]
		local skill_data = i3k_db_skills[skillID]
		widgets["skill"..i.."_bg"]:setImage(g_i3k_db.i3k_db_get_icon_path(gradeCfg.borderImage))
		widgets["up_arrow"..i]:setVisible(g_i3k_game_context:CanHideWeaponUpPSkill(anqiID, i))
		widgets["skillLock"..i]:setVisible(isLock)
		local skillLevel = g_i3k_game_context:getHideWeaponSkillLevel(anqiID, skillID)
		widgets["label"..i]:setText(skillLevel.."级")
		widgets["label"..i]:setVisible(skillID ~= 0)
		local skillIconImg = skillID == 0 and gradeCfg.cover or g_i3k_db.i3k_db_get_anqi_possitive_skill_icon(anqiID, skillID)
		widgets["skillIcon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(skillIconImg)) -- TODO 设置被动技能图标
		widgets["skillIcon"..i]:setVisible(not isLock)
	end
end


function wnd_hideWeapon:SetModule(anqiID)
	local widgets = self._layout.vars
	local modelID = i3k_db_anqi_base[anqiID].modelID
	local curSkinID = g_i3k_game_context:GetAnqiCurSkin(anqiID)
	if curSkinID ~= 0 then
		local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkinID)
		modelID = skinCfg.skinModel
	end

	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	widgets.module:setSprite(path)
	widgets.module:setSprSize(uiscale)
	widgets.module:playAction("stand")
	widgets.modelBtn:onClick(self, self.onModelClick)
end

function wnd_hideWeapon:setUnlockModule()----解锁连续动作
	local widgets = self._layout.vars
	widgets.module:pushActionList("unlock",1)
	widgets.module:pushActionList("stand",-1)
	widgets.module:playActionList()--
end

function wnd_hideWeapon:setResponseModule()----装备/升阶/升星连续动作
	local widgets = self._layout.vars
	widgets.module:pushActionList("response",1)
	widgets.module:pushActionList("stand",-1)
	widgets.module:playActionList()
end

function wnd_hideWeapon:setlockModule()----动作
	local widgets = self._layout.vars
	widgets.module:playAction("lock")
end

function wnd_hideWeapon:onModelClick(sender)
	local widgets = self._layout.vars
	local anqiID = self:getAnqiID()
	local state = self:getState(anqiID)
	widgets.module:pushActionList("dianji",1)
	if state == STATE_LOCKED then
		widgets.module:pushActionList("stand",-1)
	else -- STATE_UNLOCK
		widgets.module:pushActionList("lock",-1)
	end
	widgets.module:playActionList()
end

--右侧面板动态添加节点
function wnd_hideWeapon:addNewNode(layer)
	local widgets = self._layout.vars
	local nodeWidth = widgets.new_root:getContentSize().width
	local nodeHeight = widgets.new_root:getContentSize().height
	local old_layer = widgets.new_root:getAddChild()
	if old_layer[1] then
		widgets.new_root:removeChild(old_layer[1])
	end
	if layer then
		widgets.new_root:addChild(layer)
		layer.rootVar:setContentSize(nodeWidth, nodeHeight)
	end
end

function wnd_hideWeapon:updateLeftScrollSelect(id)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	for k, v in ipairs(self._allTap) do
		if k == id then
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECT_BG))
		else
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_BG))
		end
	end
end

function wnd_hideWeapon:updateLeftScroll()
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	local allHideWeaponInfo = i3k_clone(i3k_db_anqi_base)
	local userHideWeaponInfo = g_i3k_game_context:getHideWeaponInfo()['weapons']
	scroll:removeAllChildren()
	for k, v in ipairs(allHideWeaponInfo) do
		v.isUnlock = userHideWeaponInfo[k] ~= nil
		v.id = k
		--未解锁暗器为0级
		v.level = userHideWeaponInfo[k] and userHideWeaponInfo[k].level or 0
	end
	--依据等级降序，同等级依据ID升序
	local sortHideWeapon = function (a, b)
		return a.level == b.level and a.id < b.id or a.level > b.level
	end
	table.sort(allHideWeaponInfo, sortHideWeapon)
	--未装备暗器时默认选中左侧栏中第一个
	if self._anqiID == 0 and #allHideWeaponInfo > 0 then
		self._anqiID = allHideWeaponInfo[1].id
	end
	for k, v in ipairs(allHideWeaponInfo) do
		local ui = require("ui/widgets/anqilbt")()
		local vars = ui.vars
		local path = g_i3k_db.i3k_db_get_anqi_skin_showId_by_skinID(v.id) or g_i3k_db.i3k_db_get_icon_path(v.icon)
		local gradeImg = g_i3k_db.i3k_db_get_anqi_img(v.id)
		vars.icon:setImage(path)
		vars.btn:onClick(self, self.onAnqiBtn, v.id)
		vars.name:setText(v.name)
		vars.qlvl:setText(v.level)
		vars.qlvl:setVisible(v.isUnlock)
		vars.qlvl_icon:setVisible(v.isUnlock)
		vars.desc:setVisible(false)
		vars.img:setImage(g_i3k_db.i3k_db_get_icon_path(gradeImg))
		vars.is_select:setVisible(g_i3k_game_context:getHideWeaponIsEquiped(v.id)) -- 是否装备
		local flag = g_i3k_game_context:CanHideWeaponBetter(v.id)
		vars.red_point:setVisible(g_i3k_game_context:CanHideWeaponBetter(v.id)) -- 红点
		self._allTap[v.id] = vars
		scroll:addItem(ui)
	end
end


----------------------
-- 此处的index为右侧按钮的索引id
function wnd_hideWeapon:updateRightUI(index)
	for k, v in ipairs(self._rightUIList) do
		if index == k then
			v.btn:stateToPressed()
		else
			v.btn:stateToNormal()
		end
	end
end

-- 线索
function wnd_hideWeapon:getClueLayer()
	local ui = require("ui/widgets/anqixiansuo")()
	local anqiID = self:getAnqiID()

	local itemID = i3k_db_anqi_base[anqiID].itemID
	local itemCount = i3k_db_anqi_base[anqiID].itemCount
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	local name = g_i3k_db.i3k_db_get_common_item_name(itemID)
	ui.vars.itemName:setText(name)
	ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	ui.vars.btn:onClick(self, self.onItemTips, itemID)
	ui.vars.count:setText(haveCount.."/"..itemCount)
	ui.vars.count:setTextColor(g_i3k_get_cond_color(haveCount >= itemCount))
	local args = {id = itemID, count = itemCount}
	ui.vars.doit:onClick(self, self.onHechengBtn, args)
	local get_way = g_i3k_db.i3k_db_get_common_item_source(itemID)
	ui.vars.getway:setText(get_way)

	return ui
end

function wnd_hideWeapon:setUpGradeScroll(scroll, list)
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		if v.from ~= 0 and v.to ~= 0 then
			local ui = require("ui/widgets/anqishengpint")()
			ui.vars.name:setText(v.name)
			ui.vars.from:setText(v.from)

			if v.to then
				ui.vars.to:setText(v.to)
			else
				ui.vars.arrow:hide()
				ui.vars.to:hide()
			end

			if v.nowLevelImg then
				ui.vars.from:hide()
				ui.vars.to:hide()
				ui.vars.img1:show()
				ui.vars.img2:show()
				ui.vars.img1:setImage(g_i3k_db.i3k_db_get_icon_path(v.nowLevelImg))
				if not v.nextLevelImg then
					ui.vars.img2:hide()
				else
					ui.vars.img2:setImage(g_i3k_db.i3k_db_get_icon_path(v.nextLevelImg))
				end
			else
				ui.vars.img1:hide()
				ui.vars.img2:hide()
			end
			ui.vars.btn:setVisible(v.showBtn)
			ui.vars.btn:onClick(self, self.onUpGradeTips, v.from)
			scroll:addItem(ui)
		end
	end
end

function wnd_hideWeapon:getUpGradeLayer(index)
	local ui = require("ui/widgets/anqishengpin")()
	local anqiID = self:getAnqiID()
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	local nextGradeCfg = i3k_db_anqi_grade[anqiID][cfg.rankValue + 1] -- 索引下一级的消耗
	if not nextGradeCfg then
		ui = require("ui/widgets/anqishengpinman")()
		return ui
	end
	local itemID = nextGradeCfg.itemID
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	local itemCount = nextGradeCfg.itemCount
	ui.vars.item_bg_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	ui.vars.item_btn:onClick(self, self.onItemTips, itemID)
	local name = g_i3k_db.i3k_db_get_common_item_name(itemID)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
	local name_colour = g_i3k_get_color_by_rank(item_rank)
	ui.vars.item_name:setText(name)
	ui.vars.item_name:setTextColor(name_colour)
	ui.vars.item_count:setText(haveCount.."/"..itemCount)
	ui.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= itemCount))

	-- 替代物品
	itemID = nextGradeCfg.itemID2
	haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	ui.vars.replaceItemBgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	ui.vars.replaceItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	ui.vars.replaceItem_btn:onClick(self, self.onItemTips, itemID)
	local name = g_i3k_db.i3k_db_get_common_item_name(itemID)
	local item_rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
	local name_colour = g_i3k_get_color_by_rank(item_rank)
	ui.vars.replaceItem_name:setText(name)
	ui.vars.replaceItem_name:setTextColor(name_colour)
	ui.vars.replaceItem_count:setText(haveCount.."/"..itemCount)
	ui.vars.replaceItem_count:setTextColor(g_i3k_get_cond_color(haveCount >= itemCount))

	local info =
	{
		itemID = nextGradeCfg.itemID,
		count = itemCount,
		itemBackup = nextGradeCfg.itemID2,
	}
	ui.vars.upstar_btn:onClick(self, self.onUpGrade, info)

	return ui
end

function wnd_hideWeapon:setUpStarScroll(scroll, list)
	scroll:removeAllChildren()

	for k, v in ipairs(list) do
		local ui = require("ui/widgets/anqishengjit")()
		local id = v.id
		ui.vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(id))
		if v.to then
			ui.vars.propertyValue:setText(i3k_get_prop_show(id, v.to))
		else
			ui.vars.propertyValue:hide()
		end
		ui.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
		ui.vars.valueMid:setText(i3k_get_prop_show(id, v.from))
		scroll:addItem(ui)
	end
end

function wnd_hideWeapon:setUpStarItems(ui, list)
	for i = 1, 3 do
		local itemID = list[i]
		local count = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
		ui.vars["itemBg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
		ui.vars["itemCount"..i]:setText(cfg.args1)
		ui.vars["count"..i]:setText(count)
		-- g_i3k_get_cond_color
		ui.vars["itemBtn"..i]:onClick(self, self.onUpLevelSingleItem, itemID)
	end
end

-- 升星，升级
function wnd_hideWeapon:getUpStarLayer()
	local ui = require("ui/widgets/anqishengji")()
	local anqiID = self:getAnqiID()
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	local info = g_i3k_db.i3k_db_get_anqi_up_star_info(anqiID, cfg.level)
	if not info then
		-- TODO 满级
	end
	ui.vars.level:setText("等级：")
	ui.vars.value:setText(cfg.level)
	local roleLevel = g_i3k_game_context:GetLevel()
	-- ui.vars.value:setTextColor(g_i3k_get_cond_color(roleLevel >= cfg.level))
	local colorText = roleLevel >= info.needLevel and "<c=green>" or "<c=red>"
	ui.vars.needLevel:setText("角色"..colorText..info.needLevel .."</c>级后可以升级")
	local curExp = cfg.exp
	ui.vars.exp_slider:setPercent(curExp / info.needExp * 100)
	ui.vars.exp_value:setText(curExp.."/"..info.needExp)
	ui.vars.desc:setText("无需装备即可给角色附加属性")
	local list = i3k_db_anqi_common.items
	self:setUpStarItems(ui, list)
	ui.vars.akey_btn:onClick(self, self.onOneKeyUseBtn) -- 一键使用

	return ui
end


function wnd_hideWeapon:getDescLayer(text)
	local ui = require("ui/widgets/anqijieshao")()
	ui.vars.desc:setText(text)
	return ui
end

-- 线索 -- 此处index为页签的id，123
function wnd_hideWeapon:onClueBtn(sender, index)
	local layer = self:getClueLayer()
	self:addNewNode(layer) -- 在添加完节点之后，才可以对滚动条进行设置
	self:updateRightUI(index)
end


function wnd_hideWeapon:refreshUpGrade()
	local index = self:getRightBtnIndex()
	local layer = self:getUpGradeLayer(index)
	self:addNewNode(layer) -- 在添加完节点之后，才可以对滚动条进行设置
	self:updateRightUI(index)

	local anqiID = self:getAnqiID()
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	local list = g_i3k_db.i3k_db_get_up_grade_list(anqiID, cfg.rankValue)
	self:setUpGradeScroll(layer.vars.scroll, list)
end

-- 升品 -- 此处index为页签的id，123
function wnd_hideWeapon:onUpGradeBtn(sender, index)
	self:setRightBtnIndex(index)
	self:refreshUpGrade()
end

function wnd_hideWeapon:refreshUpStarUI()
	local index = self:getRightBtnIndex()
	local layer = self:getUpStarLayer()
	self:addNewNode(layer) -- 在添加完节点之后，才可以对滚动条进行设置
	self:updateRightUI(index)

	local anqiID = self:getAnqiID()
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	local info = g_i3k_db.i3k_db_get_anqi_up_star_info(anqiID, cfg.level)
	self:setUpStarScroll(layer.vars.scroll, info.props)
end

-- 升星，升级 -- 此处index为页签的id，123
function wnd_hideWeapon:onUpStarBtn(sender, index)
	self:setRightBtnIndex(index)
	self:refreshUpStarUI()
end

-- 介绍 -- 此处index为页签的id，123
function wnd_hideWeapon:onDescBtn(sender, index)
	self:setRightBtnIndex(index)
	local anqiID = self:getAnqiID()
	local desc = i3k_db_anqi_base[anqiID].desc
	local layer = self:getDescLayer(desc)
	self:addNewNode(layer) -- 在添加完节点之后，才可以对滚动条进行设置
	self:updateRightUI(index)
end
----------------------
-- 主动技能
function wnd_hideWeapon:onSkillBtn(sender, skillID)
	local anqiID = self:getAnqiID()

	local isunLock = g_i3k_game_context:getHideWeaponByID(anqiID)

	local maxSkillLevel = #i3k_db_anqi_common.levelLimit
	local skillLvl = g_i3k_game_context:GetHideWeaponActiveSkillLvl(anqiID)

	local isMax = false
	if skillLvl >= maxSkillLevel then
		isMax = true
	end

	--未解锁和满级用一个ui
	if not isunLock or isMax then
		g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponActiveSkillLock)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponActiveSkillLock, anqiID, isMax)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponActiveSkill)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponActiveSkill, anqiID)
	end
end

-- 被动技能
function wnd_hideWeapon:onEffectBtn(sender, info)
	local id = info.id
	local skillID = info.skillID
	local isLock = info.isLock
	local anqiID = self:getAnqiID()
	if info.isLock then
		local needGrade = g_i3k_db.i3k_db_get_anqi_unlock_slot_need_grade(anqiID, id)
		local gradeName = g_i3k_db.i3k_db_get_anqi_grade_name(needGrade)
		g_i3k_ui_mgr:PopupTipMessage("暗器达到"..gradeName.."解锁该插槽")
		return
	end

	g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponPassiveSkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponPassiveSkill, {wid = anqiID, skillID = skillID})
end

-- 装备暗器
function wnd_hideWeapon:onEquipBtn(sender)
	local anqiID = self:getAnqiID()
	i3k_sbean.hideweapon_change(anqiID)
end

function wnd_hideWeapon:onAnqiBtn(sender, id)
	self:testCase()
	self:setRightBtnIndex(UP_GRADE)
	self:updateAnqiIndex(id)
end

-- 升星，升级一键使用 -- TODO 满级处理
function wnd_hideWeapon:onOneKeyUseBtn(sender)
	local list = i3k_db_anqi_common.items
	local totalCount = 0
	local anqiID = self:getAnqiID()
	local itemList = g_i3k_db.i3k_db_get_up_level_canUse_count_with_unlock(anqiID)
	local totalHaveCount = 0
	for k, v in pairs(itemList) do
		local haveCount = g_i3k_game_context:GetCommonItemCount(k)
		totalHaveCount = totalHaveCount + haveCount
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(k)
		totalCount = totalCount + v * cfg.args1
		i3k_log("onOneKeyUseBtn  id = "..k .. " count = ".. v.." exp = "..(v * cfg.args1))
	end

	if totalHaveCount == 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end

	if totalCount == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17320))-- 已经满足升级最大条件了，无法升级
		return
	end

	for k, v in pairs(itemList) do
		if v == 0 then
			itemList[k] = nil
		end
	end
	i3k_sbean.hideweapon_levelup(anqiID, itemList)
end

function wnd_hideWeapon:onUpLevelSingleItem(sender, itemID)
	local count = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	if count == 0 then
		g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
	else
		local anqiID = self:getAnqiID()
		local itemList = g_i3k_db.i3k_db_get_up_level_canUse_count_with_unlock(anqiID)
		local totalCount = 0
		for k, v in pairs(itemList) do
			local cfg = g_i3k_db.i3k_db_get_other_item_cfg(k)
			totalCount = totalCount + v * cfg.args1
		end
		if totalCount == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17320))
			return
		end
		local itemList
		local haveCount = g_i3k_game_context:GetCommonItemCount(itemID)
		if haveCount > 0 then
			itemList = { [itemID] = 1 }
		else
			itemList = { [-itemID] = 1 }
		end
		i3k_sbean.hideweapon_levelup(anqiID, itemList)
	end
end

function wnd_hideWeapon:onUpGradeTips(sender, msg)
	local anqiID = self:getAnqiID()
	local anqiName = i3k_db_anqi_base[anqiID].name
	g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(17314, anqiName, msg))
end

-- 升品
function wnd_hideWeapon:onUpGrade(sender, info)
	local item1 = info.itemID
	local item2 = info.itemBackup
	local count = info.count
	local haveCount1 = g_i3k_game_context:GetCommonItemCanUseCount(item1)
	local haveCount2 = g_i3k_game_context:GetCommonItemCanUseCount(item2)
	if haveCount1 + haveCount2 < count then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	-- local count1, count2 = g_i3k_db.i3k_db_get_anqi_consume_count(haveCount1, haveCount2, count)

	local items = g_i3k_db.i3k_db_get_anqi_consume_count_with_unlock(item1, item2, count)

	-- 道具满足条件
	local anqiID = self:getAnqiID()
	i3k_sbean.hideweapon_rankup(anqiID, items)
end

-- 合成
function wnd_hideWeapon:onHechengBtn(sender, args)
	local itemID = args.id
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	if args.count > haveCount then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	local anqiID = self:getAnqiID()
	i3k_sbean.hideweapon_make(anqiID, args)
end

function wnd_hideWeapon:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

-- 测试用例
function wnd_hideWeapon:testCase()

end

--更新界面右侧红点
function wnd_hideWeapon:updateRightRed(wid)
	local widgets = self._layout.vars
	local state = self:getState(wid)
	if state == STATE_UNLOCK then
		widgets.upGradeRed:setVisible(g_i3k_game_context:CanMakeHideWeapon(wid))
		widgets.upStarRed:setVisible(false)
		widgets.descRed:setVisible(false)
	end
	if state == STATE_LOCKED then
		widgets.upGradeRed:setVisible(g_i3k_game_context:CanHideWeaponUpRank(wid))
		widgets.upStarRed:setVisible(g_i3k_game_context:CanHideweaponUpLevel(wid))
		widgets.descRed:setVisible(false)
	end
end

function wnd_hideWeapon:getIsMaxGrade(anqiID)
	local cfg = g_i3k_game_context:getHideWeaponByID(anqiID)
	if cfg then
		local nextGradeCfg = i3k_db_anqi_grade[anqiID][cfg.rankValue + 1] -- 索引下一级的消耗
		if not nextGradeCfg then
			return true
		end
	end
	return false
end

--进入碎片回收界面
function wnd_hideWeapon:onRecycle(sender)
	local anqiID = self:getAnqiID()
	if self:getIsMaxGrade(anqiID) then
		local anqiCfg = i3k_db_anqi_base[anqiID]
		local itemID = anqiCfg.itemID
		i3k_sbean.openDebrisRecycle(itemID, g_DEBRIS_ANQI)
	else
		g_i3k_ui_mgr:PopupTipMessage("当前暗器未达到最大品质")
	end
end

function wnd_hideWeapon:updateHuanhuaBtnState(anqiID)
	local anqiCfg = i3k_db_anqi_base[anqiID]
	local widgets = self._layout.vars

	local isShow = anqiCfg.skinID[1] ~= 0 --不等于0表示显示化入口
	widgets.huanhuaBtn:setVisible(isShow)

	if isShow then
		local isActivate = g_i3k_game_context:GetAnqiSkinIsActivate(anqiID)
		local imgID = isActivate and HUANHUA_ACTVTE_IMGID or HUANHUA_LOCK_IMGID
		widgets.huanhuaBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
	end
end

--进入暗器幻化界面
function wnd_hideWeapon:onHuanhua(sender)
	local anqiID = self:getAnqiID()
	g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponHuanhua)
	g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponHuanhua, anqiID)
end

--进入暗器评论页面
function wnd_hideWeapon:onComment(sender)
	local anqiID = self:getAnqiID()
	i3k_sbean.socialmsg_pageinfoReq(3, anqiID, 1, 1, i3k_db_common.evaluation.showItemCount)
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeapon.new()
	wnd:create(layout, ...)
	return wnd;
end
