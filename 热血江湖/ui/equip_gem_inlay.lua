-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------
wnd_equip_gem_inlay = i3k_class("wnd_equip_gem_inlay", ui.wnd_profile)

local bless_rankImg = {5139, 5140, 5141, 5142, 10856, 10857, 10858, 10859, 10860, 10861}

local RowitemCount = 2 --scroll每行显示个数
local BST_WIDGET = "ui/widgets/bst"

function wnd_equip_gem_inlay:ctor()
	self._pos = 1 --装备部位
	self._slotType = 1 --宝石镶嵌类型
	
	self._jewelSlot = {}
	self._slotIconTable = {}
	self._blessIcon = {}
	self._slotImage = {}
	self._slotImageName = {}
	self._rightIncludeUI = {}
	self._slotRed = {}
	self._slotID = 0 --记录孔位
end

function wnd_equip_gem_inlay:configure()
	local widgets = self._layout.vars
	self:initRedPoint(widgets)
	
	self.role_lv = widgets.role_lv
	self.class_type = widgets.job
	self.battle_power = widgets.battle_power
	self.hero_module = widgets.hero_module
	self.class_icon = widgets.class_icon
	
	self:initWearEquipWidget(widgets)--初始化左侧穿着装备控件
	self:initRightSoltWidget(widgets)--初始化右侧插槽控件
	
	widgets.xq_bt:stateToPressed()
	widgets.sx_bt:stateToNormal()
	widgets.qh_bt:stateToNormal()
	widgets.cl_bt:stateToNormal()
	--跳转页面按钮
	widgets.qh_bt:onClick(self, self.onStrengClicked)
	widgets.sx_bt:onClick(self, self.onStarClicked)
	widgets.cl_bt:setVisible(g_i3k_db.i3k_db_get_equip_temper_show())
	if g_i3k_db.i3k_db_get_equip_temper_show() then
		widgets.cl_bt:onClick(self, self.onTemperClicked)
	end
	self.scroll = widgets.xqScroll
	self.noJewel = widgets.noJewel
	widgets.tipsText:setText(i3k_get_string(27))
	
	--飞升部分修改
	self:initEquipBtnState(widgets)
	--红点
	self.qhRedPoint = widgets.strengRedPoint
	self.starRedPoint = widgets.starRedPoint
	self.inlayRedPoint = widgets.inlayRedPoint
	self.temperRedPoint = widgets.temperRedPoint
	self.pveWord = widgets.pveWord
	widgets.check:onClick(self, self.checkBtn)
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_equip_gem_inlay:initWearEquipWidget(widgets)
	for i=1, eEquipNumber do
		local equip_btn = "equip"..i
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local is_select = "is_select"..i
		local level_label = "qh_level"..i
		local red_tips = "tips"..i
		self.wear_equip[i]  = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			level_label	= widgets[level_label],
			red_tips	= widgets[red_tips],
		}
	end
end

function wnd_equip_gem_inlay:updatePVE()
	local pve = g_i3k_db.i3k_db_get_streng_reward_info_for_type(3)
	local str = pve[3].count < i3k_db_common.equip.equipPropCount and "[<c=red>" or "[<c=green>"
	self.pveWord:setText(pve[3].desc.." 额外奖励属性"..str..pve[3].count.."/"..i3k_db_common.equip.equipPropCount.."</c>]")
end

function wnd_equip_gem_inlay:initRightSoltWidget(widgets)
	self._jewelSlot = {widgets.fangJewel, widgets.yuanJewel, widgets.sanJewel, widgets.lingJewel}--插槽btn
	for i=1, 4 do --插槽红点
		local slot = string.format("slot%sRed",i)
		local slotIcon = string.format("slot%sIcon", i)
		local blessIcon = string.format("bless"..i) 
		table.insert(self._slotRed, widgets[slot])
		table.insert(self._slotIconTable, widgets[slotIcon])
		table.insert(self._blessIcon, widgets[blessIcon])
	end
	self._slotImage = {widgets.fangImage, widgets.yuanImage, widgets.sanImage, widgets.lingImage}
	self._slotImageName = {widgets.fangImage:getImage(), widgets.yuanImage:getImage(), widgets.sanImage:getImage(), widgets.lingImage:getImage()}
	self._rightIncludeUI = {widgets.xqTipsUI, widgets.xiangqianUI, widgets.haveJewelUI}--是否可升级
end

function wnd_equip_gem_inlay:refresh()
	self:initShowType(g_i3k_game_context:GetWearEquips())
	--self:setTopBtnWidgets(self._layout.vars)
	self:updateWearEquipsData(g_i3k_game_context:GetRoleDetail())
	self:updateRedPoint()
	self:updatePVE()
end

function wnd_equip_gem_inlay:updateWearEquipsData(ctype, level, fightpower, wEquips)
	self:updateProfile(ctype, level, fightpower, wEquips)
	for i=1,eEquipNumber do
		if not g_i3k_game_context:checkEquipFacility(i, g_FACILITY_GEM_NESTING) then
			self.wear_equip[i].equip_btn:setVisible(false)
			self:showTopBtn(false)
		else
		local equip = wEquips[i].equip
		if equip then
			self.wear_equip[i].equip_btn:onClick(self, self.onEquipSlotClicked, i)
			self.wear_equip[i].level_label:hide()
			self:canSlotClicked()
		else
			self.wear_equip[i].equip_btn:enable()
			self.wear_equip[i].equip_btn:onClick(self, self.notwearingEquipTips, {partID = i})
			end
		end
	end
end


function wnd_equip_gem_inlay:canSlotClicked()
	for i, e in pairs(self._jewelSlot) do
		e:onClick(self, self.onSlotClicked, i)
	end
end

function wnd_equip_gem_inlay:setSlotBtnState(slotPos)
	for i, e in pairs(self._jewelSlot) do
		if i == slotPos then
			e:stateToPressed()
		else
			e:stateToNormal()
		end
	end
end

function wnd_equip_gem_inlay:updateSlotGemImage(partID)
	local slot = g_i3k_game_context:GetEquipSoltCfg(partID)
	local gemBlessInfo = g_i3k_game_context:GetEquipBlessInfo(partID)
	for i=1, 4 do --设置宝石类型图标
		local slotIcon = string.format("slot%sIcon",i)
		local imageType = i3k_db_equip_part[partID][slotIcon]
		self._jewelSlot[i]:setVisible(imageType ~= 0)
		if imageType ~= 0 then
			self._slotImage[i]:setImage(g_i3k_db.i3k_db_get_icon_path(imageType))
		end
	end
	for j=1,#slot do --设置已镶嵌宝石图标
		local isBless = gemBlessInfo[j] and gemBlessInfo[j] >= 1 or false
		self._slotIconTable[j]:setVisible(slot[j]~=0)
		self._blessIcon[j]:setVisible(isBless)
		if slot[j] ~= 0 then
			self._slotIconTable[j]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(slot[j],i3k_game_context:IsFemaleRole()))
			if isBless then
				self._blessIcon[j]:enableWithChildren()
				self._blessIcon[j]:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[gemBlessInfo[j]]))
			else
				self._blessIcon[j]:disableWithChildren()
			end
		else
			self._blessIcon[j]:setImage(g_i3k_db.i3k_db_get_icon_path(bless_rankImg[gemBlessInfo[j]]))
			self._blessIcon[j]:disableWithChildren()
		end
	end
end

function wnd_equip_gem_inlay:onEquipSlotClicked(sender, partID)
	self:updateFuncs(partID)
end
function wnd_equip_gem_inlay:updateFuncs(partID)
	self._pos = partID
	for i, e in pairs(self._jewelSlot) do
		e:stateToNormal()
	end
	self:updateSelectEquip(partID)
	self:initRightUI()
	self:updateSlotGemImage(partID)
	self:updateSlotRedPoint()
end

function wnd_equip_gem_inlay:notwearingEquipTips(sender, data)
	local str = g_i3k_db.i3k_db_get_equip_gain_resource_desc(data.partID)
	g_i3k_ui_mgr:ShowMessageBox1(str)
end

function wnd_equip_gem_inlay:updateSelectEquip(partID)
	for i=1, eEquipNumber do
		self.wear_equip[i].is_select:hide()
	end
	self.wear_equip[partID].is_select:show()
end

function wnd_equip_gem_inlay:onSlotClicked(sender, slotPos)
	local slotCfg = g_i3k_game_context:GetEquipSoltCfg(self._pos)
	if slotCfg[slotPos] ~= 0 then
		self:showCanUpLevelUI(slotPos)
	else
		self:showCanInlayUI(slotPos)
	end
end

--背包中可用于升级的宝石类型
function wnd_equip_gem_inlay:showCanInlayUI(slotPos)
	for i, e in pairs(self._rightIncludeUI) do
		e:setVisible(i==2)
	end
	self.scroll:removeAllChildren()
	self:setSlotBtnState(slotPos)
	local gemItems = self:getCanInlayGemInfo(slotPos)
	self.noJewel:setVisible(gemItems[1]==nil)
	if next(gemItems) then	
		local all_layer = self.scroll:addChildWithCount(BST_WIDGET, RowitemCount, #gemItems)
		for i, e in pairs(gemItems) do
			local widget = all_layer[i].vars
			widget.gemButton:onClick(self, self.onInlayGem, {pos = self._pos, seq = slotPos, gemId = e.id})
			self:updateScrollWidget(widget, e.id, e.count)
		end		
	end
end

function wnd_equip_gem_inlay:updateScrollWidget(widget, id, count)
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	widget.bsgrade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.jewelIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.jewelCount:setText(count)
	widget.jewelName:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widget.jewelName:setTextColor(name_colour)
	widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
	widget.jewelPro:setText(self:getGemPropertyDesc(id))
end 

function wnd_equip_gem_inlay:getCanInlayGemInfo(slotPos)
	local slotType = string.format("slot%sType", slotPos)
 	local gemType =  i3k_db_equip_part[self._pos][slotType]
	local bagSize, items = g_i3k_game_context:GetBagInfo()
	local canInlayGem = {}
	for i, e in pairs(items) do
		local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(e.id)
		if gemCfg then
			for _,v in ipairs(gemType) do
				if v == gemCfg.type then
					table.insert(canInlayGem, {sortid = g_i3k_db.i3k_db_get_bag_item_order(e.id), id = e.id, count = e.count})
				end
			end
		end
	end
	table.sort(canInlayGem, function (a,b) --对可镶嵌宝石进行排序
		return a.sortid < b.sortid
	end)
	return canInlayGem
end

function wnd_equip_gem_inlay:showCanUpLevelUI(slotPos)
	for i, e in pairs(self._rightIncludeUI) do
		e:setVisible(i==3)
	end
	self._slotID = slotPos
	local slotCfg = g_i3k_game_context:GetEquipSoltCfg(self._pos)
	local gemBlessInfo = g_i3k_game_context:GetEquipBlessInfo(self._pos)
	local widget = self._layout.vars
	self:setSlotBtnState(slotPos)
	local id = math.abs(slotCfg[slotPos])
	local isBless = gemBlessInfo[slotPos] and gemBlessInfo[slotPos] >= 1 or false
	local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(id)
	local blessCfg = g_i3k_db.i3k_db_get_diamond_bless_cfg(gemCfg.type)
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id))
	widget.haveJewelIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	widget.bsgrade2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.haveJewelLvl:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widget.haveJewelLvl:setTextColor(name_colour)
	widget.haveJewelProperty:setText(self:getGemPropertyDesc(id))
	local addPercent = 0
	if isBless then
		addPercent = blessCfg[gemBlessInfo[slotPos]]
	end
	local ratio = g_i3k_game_context:GetIncreaseRatioOfGemBlessOnEquip(self._pos) --装备锤炼技能 提升宝石属性 系数
	if isBless then
		widget.blessDesc:setVisible(true)
		widget.blessRed:setVisible(g_i3k_game_context:isCanBlessAble(self._pos, slotPos))
		widget.blessDesc:setText(self:getGemPropertyDesc(id, addPercent))
		widget.blessDesc2:setVisible(ratio ~= 0)
		widget.blessDesc2:setText(self:getGemPropertyDesc(id, nil, ratio))
	else
		widget.blessDesc:setVisible(ratio ~=0)
		widget.blessDesc:setText(self:getGemPropertyDesc(id, nil, ratio))
		widget.blessDesc2:setVisible(false)
	end

	local data = {pos = self._pos, seq = slotPos, gemId = id, blessLvl = gemBlessInfo[slotPos]}
	widget.updateButton:onClick(self, self.onGemUpLevel, data)  --宝石部位升级btn
	widget.maxLvl:setVisible(g_i3k_db.i3k_db_get_gem_item_cfg(data.gemId).updated_id == 0) --最大级别
	widget.demolition:onClick(self, self.onUnlay, data)--宝石部位拆除
	widget.blessBtn:setVisible(g_i3k_game_context:checkEquipFacility(self._pos, g_FACILITY_GEM_BLESSING))
	widget.blessBtn:onClick(self, self.onBlessBtn, data)--宝石祝福
	widget.maxBless:setVisible( data.blessLvl and data.blessLvl >= #i3k_db_equip_part[self._pos].blessing.itemCount ) -- 最大祝福
end

function wnd_equip_gem_inlay:updateBlessRed()
	if self._slotID ~= 0 then
		self._layout.vars.blessRed:setVisible(g_i3k_game_context:isCanBlessAble(self._pos, self._slotID))
	end
end

function wnd_equip_gem_inlay:onGemUpLevel(sender, data)
	if g_i3k_db.i3k_db_get_gem_item_cfg(data.gemId).updated_id ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_GemUpLevel)
		g_i3k_ui_mgr:RefreshUI(eUIID_GemUpLevel, data)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(251))
	end
end

function wnd_equip_gem_inlay:onInlayGem(sender, data)
	i3k_sbean.gem_inlay(data.pos, data.seq, data.gemId)
end

function wnd_equip_gem_inlay:onUnlay(sender, data)
	local isEnough =  g_i3k_game_context:IsBagEnough({[data.gemId] = 1})
	if isEnough then
		i3k_sbean.gem_unlay(data.pos, data.seq, data.gemId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end

function wnd_equip_gem_inlay:onBlessBtn(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_GemBless)
	g_i3k_ui_mgr:RefreshUI(eUIID_GemBless, data)
end

function wnd_equip_gem_inlay:getGemPropertyDesc(id, percent, temperPercent)
	local gemCfg = g_i3k_db.i3k_db_get_gem_item_cfg(id)
	if gemCfg then
		local effectDesc = i3k_db_prop_id[gemCfg.effect_id].desc
		if temperPercent then
			local str = g_i3k_make_color_string("(锤炼)", g_COLOR_VALUE_PURPLE)
			return string.format("%s +%s %s",effectDesc, math.floor(gemCfg.effect_value * temperPercent), str)
		end
		if percent then
			local str = g_i3k_make_color_string("(祝福)", g_COLOR_VALUE_PURPLE)
			return string.format("%s +%s %s",effectDesc, math.floor(gemCfg.effect_value * percent), str)
		else
			return string.format("%s +%s",effectDesc, math.floor(gemCfg.effect_value))
		end
	end
	return ""
end

--右侧初始状态
function wnd_equip_gem_inlay:initRightUI()
	for i, e in pairs(self._rightIncludeUI) do
		e:setVisible(i==1)
	end
end

function wnd_equip_gem_inlay:onStrengClicked(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Jewel)
	g_i3k_logic:OpenStrengEquipUI()
end

function wnd_equip_gem_inlay:onStarClicked(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Jewel)
	g_i3k_logic:OpenEquipStarUpUI()
end

function wnd_equip_gem_inlay:onTemperClicked(sender)
	if not g_i3k_db.i3k_db_get_equip_temper_open() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17410, i3k_db_equip_temper_base.openLevel))
		return
	end
	g_i3k_logic:OpenEquipTemperUI(eUIID_Jewel)
end

function wnd_equip_gem_inlay:updateRedPoint()
	self:updatePageRedPoint(i3k_game_context.isHaveInlayRedPoint)
	self:updatePartRedPoint()
end

function wnd_equip_gem_inlay:updatePartRedPoint()
	local wEquips = g_i3k_game_context:GetWearEquips()
	for i=1, eEquipNumber do
		self.wear_equip[i].red_tips:setVisible(g_i3k_game_context:isEquipCanInlay(i))
	end
	self:updateSlotRedPoint()
end

function wnd_equip_gem_inlay:updateSlotRedPoint()
	local wEquips = g_i3k_game_context:GetWearEquips()
	local slot = wEquips[self._pos].slot
	for j=1, 4 do
		if slot[j] then
			self._slotRed[j]:setVisible(g_i3k_game_context:isInlayAble(self._pos, j)) --孔位红点
		end
	end
end

function wnd_equip_gem_inlay:checkBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_StrengTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_StrengTips, 3)
end

function wnd_create(layout)
	local wnd = wnd_equip_gem_inlay.new()
		wnd:create(layout)
	return wnd
end
