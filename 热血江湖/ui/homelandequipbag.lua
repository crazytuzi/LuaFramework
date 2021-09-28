-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/profile")

-------------------------------------------------------

wnd_homeLandEquipBag = i3k_class("wnd_homeLandEquipBag", ui.wnd_profile)

local WIDGET_YUGANT = "ui/widgets/yugant"
local QJ_WIDGETS = "ui/widgets/dj1"

local TYPE_ALL_EQUIPS		= 1 -- 全部
local TYPE_WEAPON_EQUIP		= 2 -- 武器
local TYPE_BAIT				= 3 -- 鱼饵

function wnd_homeLandEquipBag:ctor()
	self._filterType = 1 -- 全部，武器，鱼饵
end

function wnd_homeLandEquipBag:configure()
	local widgets = self._layout.vars
	self.hero_module = widgets.hero_module
	self.revolve = widgets.revolve
	widgets.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	self.wearEquipWidget = {}
	self:initWearEquipWidget(widgets)
	self.filterBtn = widgets.filterBtn
	self.gradeBtn = widgets.gradeBtn
	-- 筛选
	widgets.selectLab:setText(i3k_get_string(5110))
	widgets.filterBtn:onClick(self, function ()
		if widgets.levelRoot:isVisible() then
			widgets.levelRoot:setVisible(false)
		else
			widgets.levelRoot:setVisible(true)
			widgets.filterScroll:removeAllChildren();
			for i = 1, 3 do
				local _item = require(WIDGET_YUGANT)()
				_item.id = i
				_item.vars.label:setText(i3k_get_string(5109 + i))
				_item.vars.btn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)
					widgets.selectLab:setText(_item.vars.label:getText())
					self:updateEquipScroll(i)
				end)
				widgets.filterScroll:addItem(_item)
			end
		end
	end)
	widgets.homeLandEquip:stateToPressed()
	widgets.homeLandBuild:onClick(self, self.onHomeLandBulid)
	widgets.homeLandProp:onClick(self, self.onHomeLandProp)
	widgets.homeLandHistorys:onClick(self, self.onHomeLandHistorys)
	self.scroll = widgets.scroll
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function  wnd_homeLandEquipBag:initWearEquipWidget(widgets)
	for i=1, 2 do
		self.wearEquipWidget[i] = {
			equip_btn	= widgets["equip"..i],
			equip_icon	= widgets["equip_icon"..i],
			grade_icon	= widgets["grade_icon"..i],
		}
	end
end

function wnd_homeLandEquipBag:refresh()
	self:updateRecover()
	self:loadWearEquip()
	self:loadEquipScroll()
end

function wnd_homeLandEquipBag:loadWearEquip()
	local wearEquips = g_i3k_game_context:GetHomeLandCurEquip()
	for i, e in ipairs(self.wearEquipWidget) do
		local info = wearEquips[i]
		if info then
			e.equip_btn:enable()
			e.equip_icon:show()
			local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
			e.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipCfg.needItmeID, g_i3k_game_context:IsFemaleRole()))
			e.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipCfg.needItmeID))
			e.equip_btn:onClick(self, self.onEquipTips, {info = info, isWear = true})
		else
			e.equip_icon:hide()
			e.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(106))
			e.equip_btn:disable()
		end
	end
end

function wnd_homeLandEquipBag:loadEquipScroll()
	local equipInfo = g_i3k_game_context:GetHomeLandEquip()
	self.scroll:removeAllChildren()
	local items = self:itemSort(equipInfo)
	local all_layer = self.scroll:addChildWithCount(QJ_WIDGETS, 5, #items)
	for i, e in pairs(all_layer) do
		local info = items[i].info
		local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
		e.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipCfg.needItmeID, g_i3k_game_context:IsFemaleRole()))
		e.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipCfg.needItmeID))
		e.vars.item_count:setText(info.canUseTime) --可用次数
		e.vars.bt:onClick(self, self.onEquipTips, {info = info})
	end
end

function wnd_homeLandEquipBag:updateEquipScroll(filterType)
	if self._filterType ~= filterType then
		self._filterType = filterType
		self:loadEquipScroll()
	end
end

--物品排序
function wnd_homeLandEquipBag:itemSort(items)
	local tmp = {}
	for k, v in pairs(items) do
		local order = v.confId * 1000000 + v.canUseTime * 1000 + v.id
		local isAdd = false
		local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(v.confId)
		if self._filterType == TYPE_ALL_EQUIPS then
			isAdd = true
		elseif self._filterType == TYPE_WEAPON_EQUIP and equipCfg.equipType == g_HOMELAND_WEAPON_EQUIP then
			isAdd = true
		elseif self._filterType == TYPE_BAIT and equipCfg.equipType == g_HOMELAND_WEAPON_BAIT then
			isAdd = true
		end
		if isAdd then
			table.insert(tmp, {order = order, info = v})
		end		
	end

	table.sort(tmp, function (a,b)
		return a.order > b.order
	end)
	return tmp
end

function wnd_homeLandEquipBag:onEquipTips(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_HomeLandEquipTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandEquipTips, data.info, data.isWear)
end	

function wnd_homeLandEquipBag:onHomeLandBulid(sender)
	g_i3k_logic:openHomelandStructureUI(nil, eUIID_HomeLandEquipBag)
end

function wnd_homeLandEquipBag:onHomeLandProp(sender)
	i3k_sbean.homeland_sync(1)
end

function wnd_homeLandEquipBag:onHomeLandHistorys(sender)
	g_i3k_logic:OpenHomeLandEventUI(eUIID_HomeLandEquipBag)
end

function wnd_create(layout)
	local wnd = wnd_homeLandEquipBag.new()
	wnd:create(layout)
	return wnd
end
