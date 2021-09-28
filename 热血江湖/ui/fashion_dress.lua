-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_fashion_dress = i3k_class("wnd_fashion_dress", ui.wnd_profile)

local FASHION_WIDGET = "ui/widgets/shizhuangt"
local STORAGE_WIDGET = "ui/widgets/shizhuangt2"
local RowitemCount = 4
local NO_HAVE = "ffffffff"
local IS_HAVE = "ff966856"
local fashionType1 = 1;
local fashionType2 = 2;
local fashionType3 = 3;  --衣橱
local metamorphosisType = 4 --幻形

local BG_NORMAL = 4027  	--普通时装底板
local BG_SPINNING = 4028  	--精纺时装底板

local STORAGE_OPEN_LVL = i3k_db_fashion_base_info.wardrobe_open_lvl  --衣橱和精纺功能开启等级
local STORAGE_MAX_NUM = #i3k_db_fashion_wardrobe  					 --衣橱最大分栏数

function wnd_fashion_dress:ctor()
	self.showType = 2 --1:装备，2：形象，3：衣橱

	self._select_icon = nil;
	self._isShow = false;
	self._isShowWeapon = false;
	self._isMetamorphosis = false --是否是幻形
	self.showingFashionId = g_i3k_game_context:GetCurFashion();--当前展示的时装id(武器不算)
end

function wnd_fashion_dress:configure()
	local widgets = self._layout.vars
	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self, self.addCoinBtn)

	self.scroll = widgets.scroll

	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.hero_module.isEffectFashion = true
	self.class_icon = widgets.class_icon
	self.red_point = widgets.red_point
	self.sz_redPoint = widgets.sz_redPoint
	self.showText = widgets.showText
	self.showText1 = widgets.showText1
	self.logoimage = widgets.LogoImage
	self.logoimage:setVisible(false)
	self:initWearEquipWidget(widgets)

	widgets.fashion_btn:stateToPressed()
	widgets.bag_btn:stateToNormal()

	widgets.bag_btn:onClick(self, self.onBagBtn)
	widgets.warehouse_btn:onClick(self, self.onWarehouseBtn)
	widgets.role_btn:onClick(self, self.onRoleBtn)
	widgets.store_btn:onClick(self, self.onStoreBtn)
	self.store_btn = widgets.store_btn
	self.fashionTypeButton = {widgets.weapon_btn, widgets.image_btn, widgets.storage_btn, widgets.huanXing_btn}
	self.recover_btn = widgets.recover_btn
	widgets.recover_btn:onClick(self, self.onRecoverBtn)
	widgets.liulan_btn:onClick(self,self.onShowBtn)

	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn, true) --旋转模型

	self.desc_1 = widgets.desc_1
	self.desc_2 = widgets.desc_2

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self:initEffectEvent()
	self._layout.vars.chooseTypeBtn1:onClick(self, self.onChangeWeaponShowBtn)
	self._layout.vars.chooseTypeBtn2:onClick(self, self.onChangeSkinShowBtn)
end

function wnd_fashion_dress:onShow()
	self:setDynamicEffect(self.showingFashionId)
	self:onShowBtn(self)
end


--初始化穿着装备控件
function wnd_fashion_dress:initWearEquipWidget(widgets)
	for i=1, 3 do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local repair_icon = "repair"..i
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i

		self.wear_equip[i] = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			repair_icon	= widgets[repair_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end

function wnd_fashion_dress:refresh(showType)
	if showType then
		self.showType = showType
	end

	if g_i3k_game_context:GetLevel() < STORAGE_OPEN_LVL then
		self.fashionTypeButton[fashionType3]:setVisible(false)
	end

	for i, e in ipairs(self.fashionTypeButton) do
		e:onClick(self, self.onShowTypeChanged, i)
		if i == self.showType then
			e:stateToPressed(true)
		else
			e:stateToNormal(true)
		end
	end
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updateIsShowFashion()
	self:refreshLeftItems()
	self:updateScroll()
	g_i3k_game_context:LeadCheck()
end

function wnd_fashion_dress:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_fashion_dress:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_fashion_dress:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_fashion_dress:GetIsShow(fashionType)
	local items = g_i3k_db.i3k_db_get_fashion_from_type(fashionType)
	local fashionItem = self:sortFashion(items)
	for i, e in pairs(fashionItem) do
		if g_i3k_db.i3k_db_get_fashion_is_wear(e.id) or g_i3k_db.i3k_db_get_flying_is_wear() then
			if fashionType ~= fashionType1 then
				self._isShow = true
				break
			else
				self._isShowWeapon = true
				break
			end
		end
	end
end





function wnd_fashion_dress:updateIsShowFashion()
	self:IsShowFashion()
	self:setChangeWeaponShow()
end

function wnd_fashion_dress:updateScroll()
	if self.showType == fashionType3 then
		self:updateStorageScroll()
	elseif self.showType == metamorphosisType then
		self:updateMetamorphosisScroll()
	else
		self:updateFashionScroll()
	end
end

--刷新衣橱
function wnd_fashion_dress:updateStorageScroll()
	self.scroll:removeAllChildren()
	local items = g_i3k_game_context:GetAllFashionInStorage()
	local fashionItems = self:sortStorage(items)
	local all_layer = self.scroll:addChildWithCount(STORAGE_WIDGET, 1, STORAGE_MAX_NUM)
	for i, v in ipairs(all_layer) do
		local widget = all_layer[i].vars
		local fashionId = fashionItems[i] and fashionItems[i].id
		local prop = fashionItems[i] and fashionItems[i].prop
		self:updatStorageCell(widget, i, fashionId, prop)
	end

	self.store_btn:setVisible(false)
	self.recover_btn:setVisible(false)
	self.desc_1:setVisible(true)
	self.desc_1:setText(i3k_get_string(15539))
	self.desc_2:setText(i3k_get_string(15540))
end

--对衣橱的时装按战力和id从小到大排序
function wnd_fashion_dress:sortStorage(items)
	local tmp = {}
	for _, n in ipairs(items) do
		local id = n.id
		local prop = g_i3k_game_context:GetPropertyByFashionId(id)  --vector
		local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
		local power = g_i3k_db.i3k_db_get_battle_power(propertyTb, true)
		local order = power * 1000 + id
		table.insert(tmp, {id = id, prop = prop, order = order})
	end

	table.sort(tmp, function (a,b)
		return a.order < b.order
	end)
	return tmp
end

function wnd_fashion_dress:updatStorageCell(widget, index, fashionId, prop)
	if fashionId then
		local itemId = i3k_db_fashion_dress[fashionId].needItemId
		local propertyTb = g_i3k_game_context:ConvertVectorToMap(prop)
		local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
		widget.fightPower:setText(power)

		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
		widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
		widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))

		local i = 1
		for k, v in ipairs(prop) do
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			_desc = _desc.." :"
			widget["key_"..i]:setText(_desc)
			widget["key_"..i]:setVisible(true)
			widget["value_"..i]:setText(i3k_get_prop_show(v.id, v.value))
			i = i + 1
		end

		widget.out_btn:onClick(self, self.onTakeOutBtn, fashionId)
		widget.item_root:setVisible(true)
		widget.empty_root:setVisible(false)
		widget.suo_root:setVisible(false)
	else
		local charm = g_i3k_game_context:GetCharm()  --魅力值or守护值
		local roleLvl = g_i3k_game_context:GetLevel()  --角色等级
		local charmTypeStr = g_i3k_game_context:IsFemaleRole() and "魅力值" or "守护值"

		local needCharm = i3k_db_fashion_wardrobe[index] and i3k_db_fashion_wardrobe[index].needCharm or 0
		local needLvl = i3k_db_fashion_wardrobe[index] and i3k_db_fashion_wardrobe[index].needLvl or 0

		if charm >= needCharm or roleLvl >= needLvl then
			local tempStr = i3k_get_string(15542)
			widget.empty_desc:setText(tempStr)
			widget.empty_root:setVisible(true)
			widget.suo_root:setVisible(false)
		else
			local tempStr = i3k_get_string(15543, charmTypeStr, needCharm, charm, needLvl, roleLvl)
			widget.suo_desc:setText(tempStr)
			widget.empty_root:setVisible(false)
			widget.suo_root:setVisible(true)
		end
		widget.item_root:setVisible(false)
	end
end

--从衣橱取出该时装
function wnd_fashion_dress:onTakeOutBtn(sender, fashionId)
	i3k_sbean.fashion_getwardrobe(fashionId)
end

--刷新时装形象和武器
function wnd_fashion_dress:updateFashionScroll()
	self.scroll:removeAllChildren()
	local items = g_i3k_db.i3k_db_get_fashion_from_type(self.showType)
	local fashionItem = self:sortFashion(items)
	local all_layer = self.scroll:addChildWithCount(FASHION_WIDGET, RowitemCount, #fashionItem)
	for i, e in pairs(fashionItem) do
		local widget = all_layer[i].vars
		self:updatCell(widget, e.needItemId, e.id, e.getPathway, e.sex)
	end
	self.sz_redPoint:setVisible(g_i3k_game_context:getFashionRedPoint())
	self:refreshLeftFashionItems()
	self.store_btn:setVisible(true)
	self.recover_btn:setVisible(true)
	self.desc_1:setVisible(false)
end
--刷新左侧时装装备
function wnd_fashion_dress:refreshLeftFashionItems()
	for i=1, 2 do
		local items = g_i3k_db.i3k_db_get_fashion_from_type(i)
		local fashionItem = self:sortFashion(items)
		for _, e in pairs(fashionItem) do
			if g_i3k_db.i3k_db_get_fashion_is_wear(e.id) then
				self:onShowLeftFashion(i, e.id)
			end
		end
	end
end

function wnd_fashion_dress:sortFashion(sort_items)
	local tmp = {}
	local springFasionId = i3k_db_spring.common.fationId
	for i, e in pairs(sort_items) do
		if springFasionId and e.id ~= springFasionId then
			local order = 0
			local isHave = g_i3k_db.i3k_db_get_fashion_is_have(e.id)
			local isWear = g_i3k_db.i3k_db_get_fashion_is_wear(e.id)
			local isStorage = g_i3k_game_context:GetFashionInStorage(e.id)
			local isSex = g_i3k_db.i3k_db_get_fashion_by_sex(e.id)
			if isWear then
				order = e.sortid + 4500
			elseif isStorage and isSex then
				order = e.sortid + 4000
			elseif isStorage and not isSex then
				order = e.sortid + 3500
			elseif isHave and isSex then
				order = e.sortid + 3000
			elseif isHave and not isSex then
				order = e.sortid + 2500
			elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) > 0 and isSex then
				order = e.sortid + 2000
			elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) > 0 and not isSex then
				order = e.sortid + 1500
			elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) <= 0 and isSex then
				order = e.sortid + 1000
			elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) <= 0 and not isSex then
				order = e.sortid
			end
			table.insert(tmp, {id = e.id, needItemId = e.needItemId, getPathway = e.getPathway, sex = e.sex, order = order})
		end
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

function wnd_fashion_dress:updatCell(widget, itemId, fashionId, getPathway, sex)
	widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	local isHave = g_i3k_db.i3k_db_get_fashion_is_have(fashionId)
	local isWear = g_i3k_db.i3k_db_get_fashion_is_wear(fashionId)
	local desc, color = self:getFashionStateDesc(fashionId)
	local isSpinning = g_i3k_game_context:GetFashionIsSpinning(fashionId)
	local isStorage = g_i3k_game_context:GetFashionInStorage(fashionId)
	widget.state:setText(desc)
	widget.state:setTextColor(color)
	local isShow = false
	if isHave and not isWear then
		isShow = true
	elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(itemId) <= 0 then
		isShow = true
	end
	widget.state:setVisible(isShow)
	widget.activation:setVisible(isWear)
	widget.have_spinning:setVisible(isStorage)  --衣柜标签
	widget.no_have:setVisible(not isHave and not isWear and g_i3k_game_context:GetCommonItemCanUseCount(itemId) > 0)
	widget.lizi:setVisible(not isHave and not isWear and g_i3k_game_context:GetCommonItemCanUseCount(itemId) > 0)
	--是否精纺
	if isSpinning then
		widget.item_root:setImage(g_i3k_db.i3k_db_get_icon_path(BG_SPINNING))
	else
		widget.item_root:setImage(g_i3k_db.i3k_db_get_icon_path(BG_NORMAL))
	end

	if not isHave then
		widget.item_root:disableWithChildren()
	end
	widget.is_select:hide()
	widget.id = fashionId
	local tmp = {id = itemId, fashionId = fashionId, is_select = widget.is_select, getPathway = getPathway, sex = sex}
	widget.item_btn:onClick(self, self.onFashionTips, tmp)
end

function wnd_fashion_dress:getFashionStateDesc(fashionId)
	local isHave = g_i3k_db.i3k_db_get_fashion_is_have(fashionId)
	local desc
	if not isHave then
		return	string.format("未启动"), g_i3k_get_white_color()
	elseif g_i3k_db.i3k_db_get_fashion_is_wear(fashionId) then
		return	string.format("使用中"), IS_HAVE
	elseif isHave then
		return	string.format("已拥有"), g_i3k_get_white_color()
	end
end

function wnd_fashion_dress:onRecoverBtn(sender)
	self:updateRecover()
end

function wnd_fashion_dress:showSelect(id)
	local all_child = self.scroll:getAllChildren()
	for i, e in pairs(all_child) do
		e.vars.is_select:hide()
	end
end

function wnd_fashion_dress:updateshowSelect(id)
	local all_child = self.scroll:getAllChildren()
	for i, e in pairs(all_child) do
		if e.id  == id then
			e.vars.is_select:show()
			break
		end
	end
end

function wnd_fashion_dress:onFashionTips(sender, args)
	self:showSelect()
	self:updateshowSelect(args.fashionId)
	g_i3k_game_context:SetTestFashionData(args.fashionId)
	self.hero_module.isEffectFashion = self.showType == 2 and true or false--形象界面
	if g_i3k_db.i3k_db_get_fashion_by_sex(args.fashionId) then
		ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FashionDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_FashionDressTips, args.id, true, args.getPathway, nil, args.sex, true, true)
	local  logoid = i3k_db_fashion_dress[args.fashionId].LoGoID
	if logoid == 0 then
		self.logoimage:setVisible(false)
	else
		self.logoimage:setVisible(true)
		self.logoimage:setImage(logoid)
	end
	if self.showType == 2 then			--如果是在形象界面 刷新 在武器界面不刷新
		self.showingFashionId = args.fashionId
		self:setDynamicEffect(args.fashionId)
		self:onShowBtn(self)--播放
	end
	self._isMetamorphosis = false
end

function wnd_fashion_dress:onShowTypeChanged(sender, tag)
	self:setFashionShowType(tag)
end

function wnd_fashion_dress:setFashionShowType(showType)
	if self.showType ~= showType then
		self.showType = showType
		for i, e in ipairs(self.fashionTypeButton) do
			e:stateToNormal(true)
		end
		self.fashionTypeButton[showType]:stateToPressed(true)
		self:updateScroll()
		self.scroll:jumpToListPercent(0)
	end
end

function wnd_fashion_dress:updateWearEquipsData(ctype, level, fightpower, wEquips)
	local level_str = string.format("%s级",level)
	self.role_lv:setText(level_str)
	self.class_type:setText(ctype)
	local gcfg = g_i3k_db.i3k_db_get_general(g_i3k_game_context:GetRoleType())
	self.class_icon:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
	self.battle_power:setText(fightpower)
	for i=1,3 do
		self.wear_equip[i].repair_icon:hide()
		self.wear_equip[i].equip_btn:disable()--装备栏不可点击
		self.wear_equip[i].red_tips:hide()
		self.wear_equip[i].level_label:hide()
	end
	self:updateRecover()
	g_i3k_game_context:SetTestFashionData(g_i3k_game_context:GetCurFashion())--初始化时假设试穿当前穿的时装
	self.red_point:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2())
end

function wnd_fashion_dress:onShowLeftFashion(index, fashionID)
	self.wear_equip[index].equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_fashion_dress[fashionID].needItemId,i3k_game_context:IsFemaleRole()))
	self.wear_equip[index].grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_fashion_dress[fashionID].needItemId))
end

function wnd_fashion_dress:onIsShowBtn(sender, skinType)
	if self._isMetamorphosis then
		ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
		self._isMetamorphosis = false
		return
	end
	local isChange = self:isChangeWear(skinType)
	local curId = g_i3k_game_context:GetCurFashion()
	self:setDynamicEffect(isChange and 0 or curId)
		self._layout.vars.liulan_btn:onClick(self,self.onShowBtn)
	if isChange then

		i3k_sbean.fashion_setshow(skinType == 1 and g_WEAR_NORMAL_SHOW_TYPE or skinType)
	else
		self.skinShowState = false
		self._layout.vars.showTypeBg2:hide()
	end
end

function wnd_fashion_dress:isChangeWear(skinType)
	local showFlag = g_i3k_game_context:getCurWearShowType()
	if showFlag == g_WEAR_NORMAL_SHOW_TYPE and skinType == 1 then
		return false
	end
	if showFlag == g_WEAR_FASHION_SHOW_TYPE and skinType == 2 then
		return false
	end
	if showFlag == g_WEAR_FLYING_SHOW_TYPE and skinType == 3 then
		return false
	end
	return true
end

function wnd_fashion_dress:onStoreBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
	g_i3k_logic:OpenVipStoreUI(3)
end

function wnd_fashion_dress:onRoleTitleBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
	g_i3k_logic:OpenRoleTitleUI()
end

function wnd_fashion_dress:onRoleBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
	g_i3k_logic:OpenRoleLyUI2()
end

function wnd_fashion_dress:onBagBtn()
	g_i3k_ui_mgr:CloseUI(eUIID_FashionDress)
	g_i3k_logic:OpenBagUI()
end

function wnd_fashion_dress:onWarehouseBtn(sender)
	g_i3k_logic:OpenWarehouseUI(eUIID_FashionDress)
end

function wnd_fashion_dress:onHide()
	g_i3k_game_context:ResetTestFashionData()
end


------------------幻形--------------------
--刷新左侧装备栏
function wnd_fashion_dress:refreshLeftItems()
	self:refreshLeftFashionItems()
	self:refreshLeftMetamorphosisItems()
end


--刷新幻形
function wnd_fashion_dress:updateMetamorphosisScroll()
	self.scroll:removeAllChildren()
	local items = i3k_db_metamorphosis
	local metamorphosisItem = self:sortMetamorphosis(items)
	local all_layer = self.scroll:addChildWithCount(FASHION_WIDGET, RowitemCount, #metamorphosisItem)
	self.sz_redPoint:setVisible( g_i3k_game_context:getMetamorphosisRedPoint())
	for i, e in pairs(metamorphosisItem) do
		local widget = all_layer[i].vars
		self:updatMetamorphosisCell(widget, e.needItemId, e.id)
	end
	self:refreshLeftMetamorphosisItems()
	
end

--刷新幻形
function wnd_fashion_dress:refreshLeftMetamorphosisItems()
	local items = i3k_db_metamorphosis
	local metamorphosisItem = self:sortMetamorphosis(items)
	for _, e in pairs(metamorphosisItem) do
		if g_i3k_db.i3k_db_get_metamorphosis_is_wear(e.id) then
			self:onShowLeftMetamorphosis(e.id)
		end
	end
end

--幻形装备栏
function wnd_fashion_dress:onShowLeftMetamorphosis(id)
	self.wear_equip[3].equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_metamorphosis[id].needItemId,i3k_game_context:IsFemaleRole()))
	self.wear_equip[3].grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_metamorphosis[id].needItemId))
end

--幻形排序
function wnd_fashion_dress:sortMetamorphosis(sort_items)
	local tmp = {}
	for i, e in pairs(sort_items) do
		local order = 0
		local isHave = g_i3k_db.i3k_db_get_metamorphosis_is_have(e.id)
		local isWear = g_i3k_db.i3k_db_get_metamorphosis_is_wear(e.id)
		if isWear then
			order = e.sortid + 3000
		elseif isHave then
			order = e.sortid + 2500
		elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) > 0 then
			order = e.sortid + 2000
		elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) > 0  then
			order = e.sortid + 1500
		elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) <= 0  then
			order = e.sortid + 1000
		elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(e.needItemId) <= 0 then
			order = e.sortid
		end
		table.insert(tmp, {id = e.id, needItemId = e.needItemId, order = order})
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

--幻形格子刷新
function wnd_fashion_dress:updatMetamorphosisCell(widget, itemId, metamorphosisId)
	widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	widget.item_name:setText(i3k_db_metamorphosis[metamorphosisId].name)
	widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	local isHave = g_i3k_db.i3k_db_get_metamorphosis_is_have(metamorphosisId)
	local isWear = g_i3k_db.i3k_db_get_metamorphosis_is_wear(metamorphosisId)
	local desc, color = self:getMetamorphosisStateDesc(metamorphosisId)
	widget.state:setText(desc)
	widget.state:setTextColor(color)
	local isShow = false
	if isHave and not isWear then
		isShow = true
	elseif not isHave and g_i3k_game_context:GetCommonItemCanUseCount(itemId) <= 0 then
		isShow = true
	end
	widget.state:setVisible(isShow)
	widget.activation:setVisible(isWear)
	widget.have_spinning:setVisible(false)  --衣柜标签
	widget.no_have:setVisible(not isHave and not isWear and g_i3k_game_context:GetCommonItemCanUseCount(itemId) > 0)
	widget.lizi:setVisible(not isHave and not isWear and g_i3k_game_context:GetCommonItemCanUseCount(itemId) > 0)

	if not isHave then
		widget.item_root:disableWithChildren()
	end
	widget.is_select:hide()
	widget.id = metamorphosisId
	local tmp = {id = itemId, metamorphosisId = metamorphosisId, is_select = widget.is_select}
	widget.item_btn:onClick(self, self.onMetamorphosisTips, tmp)
end

--幻形状态字
function wnd_fashion_dress:getMetamorphosisStateDesc(metamorphosisID)
	local isHave = g_i3k_db.i3k_db_get_metamorphosis_is_have(metamorphosisID)
	local desc
	if not isHave then
		return	string.format("未启动"), g_i3k_get_white_color()
	elseif g_i3k_db.i3k_db_get_metamorphosis_is_wear(metamorphosisID) then
		return	string.format("使用中"), IS_HAVE
	elseif isHave then
		return	string.format("已拥有"), g_i3k_get_white_color()
	end
end

--幻形选中
function wnd_fashion_dress:onMetamorphosisTips(sender, args)
	self:showSelect()
	self:updateshowSelect(args.metamorphosisId)
	local changeID = i3k_db_metamorphosis[args.metamorphosisId].changeID
	local modelID = i3k_db_missionmode_cfg[changeID].modelId
	if modelID then
		ui_set_hero_model(self.hero_module, modelID)
	end
	g_i3k_ui_mgr:OpenUI(eUIID_MetamorphosisDressTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_MetamorphosisDressTips, args.id)
	self.logoimage:setVisible(false)
	self._isMetamorphosis = true
end

-----------------------幻形end--------------------

--飞升装备显示设置相关
function wnd_fashion_dress:IsShowFashion()
	self._layout.vars.showTypeBg2:hide()
	self._layout.vars.chooseTypeBtn2:disableWithChildren()
	self:GetIsShow(fashionType2);
	if self._isShow then
		self._layout.vars.chooseTypeBtn2:enableWithChildren()
	end
	self.showingFashionId = g_i3k_game_context:GetCurFashion()
	self.hero_module.isEffectFashion = true
	if g_i3k_game_context:GetIsShwoFashion() then
		self:setDynamicEffect(self.showingFashionId)
		if self.showType == 2 then --只有在形象界面才播放动画
			self:onShowBtn(self)--显示时装的时候若果是特效的要播放动作
		end
	end
	local showType = g_i3k_game_context:getCurWearShowType()
	if showType == g_WEAR_FASHION_SHOW_TYPE then
		self._layout.vars.showTypeText2:setText(i3k_get_string(1702))
	elseif showType == g_WEAR_NORMAL_SHOW_TYPE then
		self._layout.vars.showTypeText2:setText(i3k_get_string(1701))
	else
		self._layout.vars.showTypeText2:setText(i3k_get_string(1803))
	end
end

function wnd_fashion_dress:onChangeSkinShowBtn(sender)
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1817))
	end
	self.weaponShowState = false
	self._layout.vars.showTypeBg1:hide()
	if self.skinShowState then
		self.skinShowState = false
		self._layout.vars.showTypeBg2:hide()
	else
		self.skinShowState = true
		self._layout.vars.showTypeBg2:show()
		self:setSkinShowTypeScroll()
	end
end

function wnd_fashion_dress:onChangeWeaponShowBtn(sender)
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1817))
	end
	self.skinShowState = false
	self._layout.vars.showTypeBg2:hide()
	if self.weaponShowState then
		self.weaponShowState = false
		self._layout.vars.showTypeBg1:hide()
	else
		self.weaponShowState = true
		self._layout.vars.showTypeBg1:show()
		self:setWeaponShowTypeScroll()
	end
end

function wnd_fashion_dress:setSkinShowTypeScroll()
	local showType = g_i3k_game_context:getCurWearShowType()
	if showType == g_WEAR_FASHION_SHOW_TYPE then
		self._layout.vars.showTypeText2:setText(i3k_get_string(1702))
	elseif showType == g_WEAR_NORMAL_SHOW_TYPE then
		self._layout.vars.showTypeText2:setText(i3k_get_string(1701))
	else
		self._layout.vars.showTypeText2:setText(i3k_get_string(1803))
	end
	self._layout.vars.showTypeScroll2:removeAllChildren()
	if self.skinShowState then
		local buttonCount = 3
		for k = 1, buttonCount do
			local needAdd = false
			local text = ""
			local level_sixth = 6
			local fashionData = g_i3k_game_context:GetWearFashionData()
			if k == 1 then
				needAdd = true
				text = i3k_get_string(1701)
			elseif k == 2 and fashionData[g_FashionType_Dress] then
				if self._isShow then
					needAdd = true
					text = i3k_get_string(1702)
				end
			elseif k == 3 and g_i3k_game_context:isFinishFlyingTask(level_sixth) then
				needAdd = true
				text = i3k_get_string(1803)
			end
			if needAdd then
				local node = require("ui/widgets/bgsxt")()
				node.vars.levelLabel:setText(text)
				node.vars.levelBtn:onClick(self, self.onIsShowBtn, k)
				self._layout.vars.showTypeScroll2:addItem(node)
			end
		end
	end
end

function wnd_fashion_dress:onChangeSkinShowHandler()
	self.skinShowState = false
	self:IsShowFashion()
	self:updateRecover()
end

function wnd_create(layout)
	local wnd = wnd_fashion_dress.new()
	wnd:create(layout)
	return wnd
end
