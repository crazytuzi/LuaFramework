-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_qigong = i3k_class("wnd_biography_qigong", ui.wnd_base)


local LAYER_LEVEL_DESC = {"一层", "二层", "三层", "四层"}
local xinfa_layer = {135,133,130,131,132,134}

function wnd_biography_qigong:ctor()
	self._allQigong = {} --list
	self._qigongLevel = 1
	self._curCareer = 1
	self._equipQigong = {} --set
	self._curIndex = 1
end

function wnd_biography_qigong:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.skill_btn:onClick(self, self.onBiographySkill)
	self._layout.vars.help_btn:onClick(self, self.onShowHelp)
end

function wnd_biography_qigong:refresh()
	self._curCareer = g_i3k_game_context:getCurBiographyCareerId()
	local allQigong = g_i3k_game_context:getBiographyCareerQigong()
	self._allQigong = allQigong[self._curCareer]
	self._equipQigong = g_i3k_game_context:getBiographyCareerEquipQigong()
	self._layout.vars.skill_btn:stateToNormal()
	self._layout.vars.xinfa_btn:stateToPressed()
	self._qigongLevel = i3k_db_wzClassLand[self._curCareer].xinfaLevel
	self:updateQigongScroll()
	self:updateQigongInfo()
	self._layout.vars.desc1:setText(string.format("已装备%s/%s", table.nums(self._equipQigong or {}), i3k_db_common.spiritBook.zhiyeCount))
end

function wnd_biography_qigong:updateQigongScroll()
	self._layout.vars.scroll1:removeAllChildren()
	if self._allQigong then
		for k, v in ipairs(self._allQigong) do
			local node = require("ui/widgets/xflbt")()
			if self._curIndex == k then
				node.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
			else
				node.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(707))
			end
			local item_id = i3k_db_xinfa[v].itemID
			node.vars.bg_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item_id))
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item_id, g_i3k_game_context:IsFemaleRole()))
			node.vars.name:setText(i3k_db_xinfa[v].name)
			node.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item_id)))
			if self._equipQigong[v] then
				node.vars.btn_icon2:show()
			else
				node.vars.btn_icon2:hide()
			end
			node.vars.red_point:hide()
			local layer = i3k_db_xinfa_data[v][self._qigongLevel].layer
			local desc = layer == 0 and "元始" or LAYER_LEVEL_DESC[layer]
			node.vars.layer_lvl:setText(desc)
			node.vars.icon_desc:setVisible(false)
			if layer == i3k_db_xinfa[v].maxLayer then
				node.vars.layer_lvl:setText("圆满")
			end
			node.vars.select1_btn:onClick(self, self.onSelectQigong, k)
			node.vars.select2_btn:onClick(self, self.onChangeQigong, k)
			self._layout.vars.scroll1:addItem(node)
		end
	end
end

function wnd_biography_qigong:onSelectQigong(sender, index)
	if self._curIndex ~= index then
		self._curIndex = index
		local children = self._layout.vars.scroll1:getAllChildren()
		for k, v in ipairs(children) do
			if self._curIndex == k then
				v.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
			else
				v.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(707))
			end
		end
		self:updateQigongInfo()
	end
end

function wnd_biography_qigong:onChangeQigong(sender, index)
	if self._equipQigong[self._allQigong[index]] then
		i3k_sbean.biography_class_spirit_uninstall(self._allQigong[index])
	else
		if table.nums(self._equipQigong) >= i3k_db_common.spiritBook.zhiyeCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(692, i3k_db_common.spiritBook.zhiyeCount))
		else
			i3k_sbean.biography_class_spirit_install(self._allQigong[index])
		end
	end
end

function wnd_biography_qigong:updateQigongInfo()
	if self._allQigong then
		for i = 1, 28 do
			self._layout.vars["stave"..i]:setText(i3k_db_xinfa[self._allQigong[self._curIndex]].desc[i])
			if i <= self._qigongLevel then
				self._layout.vars["stave"..i]:setTextColor("ffe2ec92")
			else
				self._layout.vars["stave"..i]:setTextColor("ffffffff")
			end
		end
		
		local hero = i3k_game_get_player_hero()
		local layerCount = 0
		for k, v in ipairs(self._allQigong) do
			layerCount = layerCount + i3k_db_xinfa_data[v][self._qigongLevel].layer
		end
		self._layout.vars.xinfa1_s:setText("气功伤害：")
		self._layout.vars.xinfa1_value:setText(hero:GetPropertyValue(ePropID_atkC))
		self._layout.vars.xinfa2_s:setText("气功防御：")
		self._layout.vars.xinfa2_value:setText(hero:GetPropertyValue(ePropID_defC))
		self._layout.vars.xinfa3_s:setText("气功总层级：")
		self._layout.vars.xinfa3_value:setText(layerCount)
		self._layout.vars.xinfa4_s:setText("气功精通：")
		self._layout.vars.xinfa4_value:setText(hero:GetPropertyValue(ePropID_masterC))
		
		self._layout.vars.max:hide()
		self._layout.anis.c_dakai.stop()
		local layer = i3k_db_xinfa_data[self._allQigong[self._curIndex]][self._qigongLevel].layer
		if layer == 0 then
			self._layout.vars.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[2]))
		elseif i3k_db_xinfa_data[self._allQigong[self._curIndex]][self._qigongLevel + 1] then
			self._layout.vars.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[layer + 2]))
		else
			self._layout.vars.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[6]))
			self._layout.vars.max:show()
			self._layout.anis.c_dakai.play()
		end
		for k = 1, 4 do
			self._layout.anis["c_wg"..k].stop()
		end
		self._layout.anis["c_wg"..layer].play()
		
		local props = {}
		local arrayProps = {}
		for k, v in pairs(i3k_db_xinfa_data[self._allQigong[self._curIndex]]) do
			if k <= self._qigongLevel then
				for i = 1, 2 do
					if v["attribute"..i] ~= 0 then
						if not props[v["attribute"..i]] then
							props[v["attribute"..i]] = 0
						end
						props[v["attribute"..i]] = props[v["attribute"..i]] + v["value"..i]
					end
				end
			end
		end
		for k, v in pairs(props) do
			table.insert(arrayProps, {id = k, value = v})
		end
		for k = 1, 6 do
			if arrayProps[k] then
				self._layout.vars["abt"..k]:show()
				self._layout.vars["value"..k]:show()
				self._layout.vars["abt"..k]:setText(i3k_db_prop_id[arrayProps[k].id].desc..":")
				self._layout.vars["value"..k]:setText(arrayProps[k].value)
			else
				self._layout.vars["abt"..k]:hide()
				self._layout.vars["value"..k]:hide()
			end
		end
		
		local layer = i3k_db_xinfa_data[self._allQigong[self._curIndex]][self._qigongLevel].layer
		self._layout.vars.effect_desc:setText(i3k_db_xinfa[self._allQigong[self._curIndex]].effectDesc[layer + 1])
	end
end

function wnd_biography_qigong:changeQigongSuccess()
	self._equipQigong = g_i3k_game_context:getBiographyCareerEquipQigong()
	local children = self._layout.vars.scroll1:getAllChildren()
	for k, v in ipairs(self._allQigong) do
		if self._equipQigong[v] then
			children[k].vars.btn_icon2:show()
		else
			children[k].vars.btn_icon2:hide()
		end
	end
	self._layout.vars.desc1:setText(string.format("已装备%s/%s", table.nums(self._equipQigong or {}), i3k_db_common.spiritBook.zhiyeCount))
end

function wnd_biography_qigong:onBiographySkill(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BiographySkills)
	g_i3k_ui_mgr:RefreshUI(eUIID_BiographySkills)
	g_i3k_ui_mgr:CloseUI(eUIID_BiographyQigong)
end

function wnd_biography_qigong:onShowHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18533))
end

function wnd_create(layout)
	local wnd = wnd_biography_qigong.new()
	wnd:create(layout)
	return wnd
end
