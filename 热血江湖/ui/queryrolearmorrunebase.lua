
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_queryRoleArmorRuneBase = i3k_class("wnd_queryRoleArmorRuneBase",ui.wnd_base)

--顶部按钮图片配置
local EQUIP_BTN_TYPE 	= 1 --默认显示类型
local topBtn_NUM 		= 4 --顶部按钮总个数
local btnImageCfg = { 
						{ normal = 9152, pressed = 9151 }, --装备
						{ normal = 9150, pressed = 9149 }, --符文
						{ normal = 9148, pressed = 9147 }, --八卦
						{ normal = 9154, pressed = 9153 }, --飞升
					}
function wnd_queryRoleArmorRuneBase:ctor()
	self.Show_Equip = 1
	self.Show_Rune_Lang = 2
	self.Show_Bagua = 3
	self.Show_Feisheng 		= 4
	self._equip_root 		= nil
	self._feisheng_root 	= nil

	self._rune_root = nil
	self._rune_slot = {}
	self.equip_rune = {}
	self._currRuneSlot = 1
	self.langIndex = 0
	self.langName = 0
	self.soltGroupData = nil
	self.runeLangLvls = nil
	self.castIngots = nil  --符文铸锭属性
	self.openWhatBtn = nil
	self.lang_lab = nil
	self.lang_btn = nil
	self.star = nil

	--八卦部分
	self._bagua_root = nil
	self.equip_bagua = {}
	self.equipDiagrams = nil
	self.diagramPartStrength = nil
	self.diagramChangeSkill = nil
	self.topScroll = nil
	self._equipBtnList = {}
	self._equipShowType = 0
	self.rootlist = nil
	self.topBtnIndexList = {}
end

function wnd_queryRoleArmorRuneBase:configure()

end
function wnd_queryRoleArmorRuneBase:initEquipRoot(widgets)
	self.rootlist = { widgets.equip_root,  widgets.runeRoot, widgets.baguaRoot, widgets.feisheng_root}
end
--初始化顶部按钮
function wnd_queryRoleArmorRuneBase:initTopBtnState(widgets)
	self.topScroll = widgets.topTabScroll
	self.topScroll:removeAllChildren()
	self._equipBtnList = {}
	for i,v in ipairs(self.topBtnIndexList) do
		local item = require("ui/widgets/hyxxfyt")()
		item.vars.btn:setPressedImgs( g_i3k_db.i3k_db_get_icon_path(btnImageCfg[v].normal), 
								      g_i3k_db.i3k_db_get_icon_path(btnImageCfg[v].pressed))
		self._equipBtnList[v] = item
		self.topScroll:addItem(item)
	end
	self:initEquipBtnClick()
	self:setEquipBtnType(EQUIP_BTN_TYPE)
end
function wnd_queryRoleArmorRuneBase:initEquipBtnClick()
	--这里初始化时将各个界面全部隐藏
	for i,v in ipairs(self.rootlist) do
		self.rootlist[i]:hide()
	end
	for i,v in pairs(self._equipBtnList) do
		v.vars.btn:onClick(self, self.onEquipTypeChange, i)	
	end
end
function wnd_queryRoleArmorRuneBase:onEquipTypeChange(sender, showType)
	self:setEquipBtnType(showType)
end
--装备飞升按钮事件
function wnd_queryRoleArmorRuneBase:setEquipBtnType(showType)
	if self._equipShowType ~= showType then
		self._equipShowType = showType
		self:updateEquipBtnTypeChange(showType)
	end
end
function wnd_queryRoleArmorRuneBase:updateEquipBtnTypeChange(showType)
	for i, e in pairs(self._equipBtnList) do
		if showType == i then
			e.vars.btn:stateToPressed(true)
			self:setSomeNodeVisible(i == self.Show_Equip)
			self.rootlist[i]:show()
		else
			e.vars.btn:stateToNormal(true)
			self.rootlist[i]:hide()
		end
	end
	self:btnClickFunc(showType)
end

--八卦部分
function wnd_queryRoleArmorRuneBase:initBaguaBaseUI(widgets)
	self._bagua_root = widgets.baguaRoot
	for i = 1, 8 do
        local equip_btn = "bagua" .. i
        local equip_icon = "bagua_icon" .. i
        local grade_icon = "bagua_grade" .. i
        local is_select = "bagua_select" .. i
        local level_label = "bagua_level" .. i
        local red_tips = "bagua_tips" .. i
        local equip_blink = "equip_blink" .. i

        self.equip_bagua[i] = {
            equip_btn = widgets[equip_btn],
            equip_icon = widgets[equip_icon],
            grade_icon = widgets[grade_icon],
            is_select = widgets[is_select],
            level_label = widgets[level_label],
            red_tips = widgets[red_tips],
            equip_blink = widgets[equip_blink]
        }
    end
end

function wnd_queryRoleArmorRuneBase:initBaguaData(equipDiagrams, diagramPartStrength, diagramChangeSkill)
	self.equipDiagrams = equipDiagrams
	self.diagramPartStrength = diagramPartStrength
	self.diagramChangeSkill = diagramChangeSkill
end

function wnd_queryRoleArmorRuneBase:updateBaguaEquip()
	--更新八卦装备信息
    local data = self.equipDiagrams

    local suitTotal = {}
    for _, v in pairs(i3k_db_bagua_affix) do
        local suitID = v.args1
        suitTotal[suitID] = (suitTotal[suitID] or 0) + 1
    end

    local haveSuitCnt = {}
    for _, bagDiagram in pairs(data) do
        for _, v in ipairs(bagDiagram.additionProp) do
            local data = i3k_db_bagua_affix[v]
            if data.affixType == 3 then
                 local suitID = data.args1
                 haveSuitCnt[suitID] = (haveSuitCnt[suitID] or 0) + 1
            end
        end
    end

    for i, e in ipairs(self.equip_bagua) do
        e.is_select:hide()
        local equip = data[i] -- 八卦装备数据
        if equip then
            local rank = g_i3k_db.i3k_db_get_bagua_rank(equip.additionProp) --品质
            e.equip_btn:enable()
            e.equip_icon:show()
            e.equip_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(i).icon))
            e.grade_icon:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))

            local strengthLevel = self.diagramPartStrength[equip.part]
            local finalStrength = self:getBaGuaFinalStrength(equip.part)
            e.level_label:show()
            e.level_label:setText("+" .. finalStrength)
            e.level_label:setTextColor(finalStrength > strengthLevel.level and g_i3k_get_hl_green_color() or "FFFFFFFF")
            e.red_tips:hide()

            local suitID = 0
            for _, v in ipairs(equip.additionProp) do
                local data = i3k_db_bagua_affix[v]
                if data.affixType == 3 then
                     suitID = data.args1
                end
            end
            if suitID ~= 0 and haveSuitCnt[suitID] then
                e.equip_blink:setVisible(suitTotal[suitID] - haveSuitCnt[suitID] == 0)
            else
                e.equip_blink:hide()
            end

            e.equip_btn:onClick(self, self.onSelectBagua, {equip = equip})
        else
        	e.is_select:hide()
            e.equip_btn:disable()
            e.equip_icon:hide()
            e.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(5695)) --默认白色
            e.level_label:hide()
            e.red_tips:hide()
            e.equip_blink:hide()
        end
    end
end

function wnd_queryRoleArmorRuneBase:getBaGuaFinalStrength(part)
	local addStrength = {} 		--部位强化等级
	--获取基础强化信息
	for partId, strengthLevel in pairs(self.diagramPartStrength) do
		addStrength[partId] = strengthLevel.level
	end
	for _,bagDiagram in pairs(self.equipDiagrams) do
		g_i3k_game_context:updateBaguaAffixInfo(bagDiagram, {}, addStrength)
		--这里加入为空判断
		local part = bagDiagram.part
		local yilueData = self.diagramPartStrength[bagDiagram.part]
		if yilueData and yilueData.changeInfo then
			bagDiagram.yilue = yilueData.changeInfo
		end
	end
	g_i3k_game_context:updateBaguaSuitInfo(bagDiagram, {}, addStrength, self.equipDiagrams)

	--获取易略加成属性
	for i,yilueData in pairs(self.diagramPartStrength) do
		if self.equipDiagrams[i] then
			g_i3k_game_context:updateBaguaYilueInfo(i, yilueData.changeInfo, {}, addStrength ,self.diagramChangeSkill)
		end 
	end
	return addStrength[part]
end

function wnd_queryRoleArmorRuneBase:onSelectBagua(sender, data)
    local equip = data.equip
    for i = 1, #self.equip_bagua do
        self.equip_bagua[i].is_select:setVisible(i == equip.part)
    end
	local strenghData = {}
	for i,v in ipairs(self.diagramPartStrength) do
		table.insert(strenghData, v.level)
	end 
	local yilueData = self.diagramPartStrength[equip.part].changeInfo
	equip.yilue = yilueData
	equip.yilue.changeSkills = self.diagramChangeSkill
	g_i3k_ui_mgr:OpenUI(eUIID_BaguaTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BaguaTips, {equip = equip, isOut = true, equipDiagrams = self.equipDiagrams, diagramPartStrength = strenghData})
end
-------------------------end--------------------------

function wnd_queryRoleArmorRuneBase:initRuneBaseUI(widgets)
	self._rune_slot = {widgets.soltbtn1, widgets.soltbtn2, widgets.soltbtn3}
	self.lang_lab = widgets.lang_lab
	self.lang_btn = widgets.lang_btn
	self.star = widgets.star

	for i = 1 , #self._rune_slot do
		self._rune_slot[i]:onClick(self, self.changeRuneSlot, i)
	end
	for i = 1 , 6 do
		self.equip_rune[i] = {btn = widgets["rBtn"..i], icon = widgets["rIcon"..i]}
	end
	self._rune_root = widgets.runeRoot
	self.lang_btn:onClick(self, self.openRuneLang)
end


function wnd_queryRoleArmorRuneBase:initRuneData(soltGroupData, runeLangLvls, castIngots)
	self.soltGroupData = soltGroupData
	self.runeLangLvls = runeLangLvls
	self.castIngots = castIngots
end

function wnd_queryRoleArmorRuneBase:updateArmoRune()
	local runeSlot = self.soltGroupData[self._currRuneSlot].solts
	for i =1 ,#runeSlot do
		local node = self.equip_rune[i]
		local runeId = math.abs(runeSlot[i])
		if runeId ~= 0 then
			node.btn:enable()
			node.icon:show()
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(runeId,i3k_game_context:IsFemaleRole()))
			--local item_rank = g_i3k_db.i3k_db_get_common_item_rank(runeId)
			--node.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(runeId))
			node.btn:onClick(self, self.onRuneTips, runeId)
		else
			--node.grade_icon:setImage(g_i3k_get_icon_frame_path_by_rank(0))
			node.btn:disable()
			node.icon:hide()
		end
	end
	self._rune_slot[self._currRuneSlot]:stateToPressed(true)

	local rnId = g_i3k_db.i3k_db_get_rune_word(runeSlot)
	self.langIndex = rnId
	if rnId > 0 then
		local runeLvl = self.runeLangLvls[rnId] or 0
		local cfg = i3k_db_under_wear_rune_lang[rnId]
		self.langName = runeLvl == 0 and cfg.runeLangName or cfg.runeLangName.."·"..i3k_db_rune_lang_upgrade[rnId][runeLvl].lvlName
		self.lang_btn:show()
		self.lang_lab:setText(self.langName)
		self.star:hide()
		if self.castIngots[rnId] then
			self.star:show()
			self.star:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_under_wear_alone.zhuDingLvStarIcon[self.castIngots[rnId].level]))
		end
	else
		self.lang_btn:hide()
	end
end

function wnd_queryRoleArmorRuneBase:changeRuneSlot(sender, slotIndex)
	if self._currRuneSlot ~= slotIndex then
		self._rune_slot[self._currRuneSlot]:stateToNormal(true)
		self._currRuneSlot = slotIndex
		self:updateArmoRune()
	end
end

function wnd_queryRoleArmorRuneBase:resetRuneSlotState()
	for _,btn in ipairs(self._rune_slot) do
		btn:stateToNormal(true)
	end
end

function wnd_queryRoleArmorRuneBase:onRuneTips(sender, itemId)
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo, nil, nil,  itemId, 3)
end


function wnd_queryRoleArmorRuneBase:openRuneLang()
	local runeLvl = self.runeLangLvls[self.langIndex] or 0
	local zhuDingLvl = self.castIngots[self.langIndex] and self.castIngots[self.langIndex].level or 0
	g_i3k_ui_mgr:OpenUI(eUIID_Rune_lang_attr)
	g_i3k_ui_mgr:RefreshUI(eUIID_Rune_lang_attr, self.langIndex, runeLvl, self.langName, zhuDingLvl)
end

function wnd_queryRoleArmorRuneBase:setSomeNodeVisible()

end

function wnd_queryRoleArmorRuneBase:updateWearEquipsData()

end

function wnd_queryRoleArmorRuneBase:btnClickFunc(showWhat)
	if showWhat == self.Show_Equip then
		self:updateWearEquipsData()
	elseif showWhat == self.Show_Rune_Lang then
		self:checkRuneSlotVisible()
		self:updateArmoRune()
	elseif showWhat == self.Show_Bagua then
		self:updateBaguaEquip()
	end
end

function wnd_queryRoleArmorRuneBase:checkRuneSlotVisible()
	for i = 1 , #self._rune_slot do
		if self.soltGroupData[i].unlocked == 1 then
			self._rune_slot[i]:show()
		else
			self._rune_slot[i]:hide()
		end
	end
end

function wnd_queryRoleArmorRuneBase:selectArmorRune(soltGroupData, runeLangLvls, castIngots)
	self._currRuneSlot = 1
	self:resetRuneSlotState()
	self:initRuneData(soltGroupData, runeLangLvls, castIngots)
	self:checkRuneSlotVisible()
	self:updateArmoRune()
end

function wnd_queryRoleArmorRuneBase:createModule(Data)
	local playerData = Data.overview
	local data = {}
	for k,v in pairs(Data.wear.wearEquips) do
		data[k] = v.equip.id
	end
	self:changeModel(playerData.type, playerData.bwType, playerData.gender, Data.wear.face, Data.wear.hair, data, Data.wear.curFashions, Data.wear.showFashionTypes, Data.wear.wearParts, Data.wear.armor, Data.wear.weaponSoulShow, Data.wear.soaringDisplay)
end

function wnd_queryRoleArmorRuneBase:changeModel(id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, soaringDisplay)
	local cfg = i3k_db_fashion_dress[fashions[g_FashionType_Dress]]
	local modelTable = {}
	modelTable.node = self.hero_module
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = armor
	modelTable.weaponSoulShow = weaponSoulShow
	modelTable.isEffectFashion = cfg and cfg.withEffect == 1
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_queryRoleArmorRuneBase:playAction(Data)--如果是动态披风 会播放动作 模型会停止旋转
	local fashions = Data.wear.curFashions
	local curFashion = fashions[g_FashionType_Dress]
	local cfg = i3k_db_fashion_dress[curFashion]
	self.isEffectFashion = cfg and cfg.withEffect == 1 and Data.wear.soaringDisplay.skinDisplay == g_WEAR_FASHION_SHOW_TYPE
	if self.isEffectFashion then
		local showAct = cfg and cfg.showAction
		if showAct then
			for i, v in ipairs(showAct) do
			self.hero_module:pushActionList(v, i == #showAct and -1 or 1)
			end
			self.hero_module:playActionList()
		end
	end
end

--设置顶部按钮状态（装备，符文，八卦）
function wnd_queryRoleArmorRuneBase:updateTopBtnSate(Data)
	local isShowTab = Data.overview.level >= i3k_db_under_wear_alone.underWearRuneOpenLvl
	local isShowRune = isShowTab and Data.wear.armor.id ~= 0
	local isShowBagua = table.nums(Data.equipDiagrams) ~= 0
	local isShowFeisheng = g_i3k_game_context:isShowFeishengBtn(Data.wear.wearEquips)

	self.runeBtnBg:setVisible(isShowTab)
	table.insert(self.topBtnIndexList, self.Show_Equip)
	if isShowRune then
		table.insert(self.topBtnIndexList, self.Show_Rune_Lang)
	end
	table.insert(self.topBtnIndexList, self.Show_Bagua)
	if isShowFeisheng then
		table.insert(self.topBtnIndexList, self.Show_Feisheng)
	end
	self:initTopBtnState(self._layout.vars)
	if not isShowBagua then
		self._equipBtnList[self.Show_Bagua].vars.btn:onClick(self, function()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17125))
		end)
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_queryRoleArmorRuneBase.new()
	wnd:create(layout, ...)
	return wnd;
end

