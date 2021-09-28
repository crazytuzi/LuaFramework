-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_show_flying_equip_tips = i3k_class("wnd_show_flying_equip_tips",ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipsfst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipsfst3"
local LAYER_ZBTIPST4 = "ui/widgets/zbtipsfst4"

function wnd_show_flying_equip_tips:ctor()
	self._id = nil
end

function wnd_show_flying_equip_tips:configure()
	local widgets = self._layout.vars

	self.equip_name = widgets.equip_name
	self.equip_bg = widgets.equip_bg
	self.equip_icon = widgets.equip_icon
	self.power_value = widgets.power_value
	self.level_label = widgets.level_label
	self.role_limit = widgets.role_limit
	self.is_free = widgets.is_free
	self.is_sale = widgets.is_sale
	self.part_limit = widgets.part_limit

	self.scroll = widgets.scroll
	self.get_label = widgets.get_label

	widgets.globel_btn:onClick(self, self.closeButton)
end

function wnd_show_flying_equip_tips:refresh(id)
	self._id = id
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local lvlReq = g_i3k_db.i3k_db_get_common_item_level_require(id)
	self.level_label:setVisible(lvlReq >= 1)
	local str = string.format("%s级", lvlReq)
	self.level_label:setText(str)
	if g_i3k_game_context:GetLevel() < lvlReq then
		self.level_label:setTextColor(g_i3k_game_context:GetRedColour())
	end
	self.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self.equip_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self.equip_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(id))

	self.part_limit:setText(i3k_db_equip_part[cfg.partID].partName)

	local classLimit = cfg.C_require

	local transfromLvl = g_i3k_game_context:GetTransformLvl()
	local roleName = TYPE_SERIES_NAME[cfg.roleType]

	if cfg.roleType == 0 then
		--roleName = string.format("<c=white>"..roleName.."</c>")
	elseif cfg.roleType ~= 0 and cfg.roleType ~= g_i3k_game_context:GetRoleType() then
		roleName = string.format("<c=red>"..roleName.."</c>")
	end
	if transfromLvl < classLimit then
		classLimit = "<c=red>"..classLimit.."转</c>"
	else
		classLimit = classLimit.."转"
	end
	if cfg.M_require == 1 then
		if cfg.M_require ~= bwtype then
			self.role_limit:setText(roleName.."   "..classLimit.."  ".."<c=red>正</c>")
		else
			self.role_limit:setText(roleName.."   "..classLimit.."  ".."正")
		end
	elseif cfg.M_require == 2 then
		if cfg.M_require ~= bwtype then
			self.role_limit:setText(roleName.."   "..classLimit.."  ".."<c=red>邪</c>")
		else
			self.role_limit:setText(roleName.."   "..classLimit.."  ".."邪")
		end
	elseif cfg.M_require == 0 then
		self.role_limit:setText(roleName.."   "..classLimit)
	end


	self.is_free:setText(id > 0 and string.format("已绑定") or string.format("非绑定"))
	self.is_free:setTextColor(g_i3k_get_cond_color(id < 0))
	if id > 0 then
		self.is_sale:hide()
	end
	self.is_sale:setText(cfg.canSale == 0 and string.format("不可交易") or string.format("可交易"))
	self.is_sale:setTextColor(g_i3k_get_cond_color(cfg.canSale ~= 0))

	local propertyData = g_i3k_db.i3k_db_get_equip_base_property(id)
	self:updateScroll(propertyData, id)
end

function wnd_show_flying_equip_tips:updateScroll(propertyData, equipID)
	self.scroll:removeAllChildren()
	local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(self._id)
	local width = self.scroll:getContentSize().width
	local height = self.scroll:getContentSize().height
	local scrollContainerSize = self.scroll:getContainerSize()

	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(string.format("基础属性"))
	self.scroll:addItem(des)

	for k, v in pairs(propertyData) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[v.id]
		local _desc = _t.desc
		_desc = _desc.." :"
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		des.vars.value:setText(i3k_get_prop_show(v.id, v.value))
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end

	local des2 = require(LAYER_ZBTIPST3)()
	des2.vars.desc:setText(string.format("附加属性"))
	self.scroll:addItem(des2)
	local count = 0
	local nCount = 0
	local ext_properties = cfg.ext_properties
	for _,e in ipairs(ext_properties) do
		if e.args ~= 0 then
			nCount = nCount + 1
			if e.maxVal == e.minVal then
				count = count + 1
			end
		end
	end
	if nCount == count and nCount ~= 0 then
		for _,e in ipairs(ext_properties) do
			if e.args ~= 0 then
				local des = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[e.args]
				local _desc = _t.desc
				_desc = _desc.." :"
				des.vars.desc:setText(_desc)
				des.vars.value:setText(i3k_get_prop_show(e.args, e.maxVal))
				self.scroll:addItem(des)
				table.insert(propertyData, {id = e.args, value = e.maxVal})
				-- local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, propertyData[k])
				-- if max then
				-- 	des.vars.max_img:show()
				-- end
			end
		end
		local sharpen = g_i3k_db.i3k_db_check_equip_can_sharpen(equipID)
		if not sharpen then
			local rank = g_i3k_db.i3k_db_get_common_item_rank(equipID)
			if rank >= g_RANK_VALUE_PURPLE then
				local sharpenWidget = require("ui/widgets/zbtipsfst4")()
				sharpenWidget.vars.desc:setText("<不可淬锋>")
				self.scroll:addItem(sharpenWidget)
			end
		end
	else
		local des3 = require(LAYER_ZBTIPST4)()
		self.scroll:addItem(des3)
	end
	self.power_value:setText(g_i3k_game_context:GetEquipBaseProperty(propertyData))
end

function wnd_show_flying_equip_tips:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ShowFlyingEquipTips)
end

function wnd_create(layout)
	local wnd = wnd_show_flying_equip_tips.new()
	wnd:create(layout)
	return wnd
end
