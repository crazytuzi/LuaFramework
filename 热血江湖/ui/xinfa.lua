-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_xinfa = i3k_class("wnd_xinfa", ui.wnd_base)

local LAYER_XFLBT = "ui/widgets/xflbt"
local LAYER_XFJMT = "ui/widgets/xfjmt"

local notHaveXinfaIcon = 708
local selectXinfaIcon = 706
local haveXinfaIcon = 707
local noHaveColor = "FF909090"--ff639f94
local selectXinfaColor = "ffb2ff6d"
local haveXinfaColor = "FFFFFF00"--ff92fbe8

local xinfa_layer = {135,133,130,131,132,134}

--诗句文字颜色
local FINISH = 'ffe2ec92'--ffcaff58
local UN_FINISH = 'ffffffff'--ff57b2ad

local XINFA_ENERGY = 33
local ZHIYE_COUNT	=	g_i3k_db.i3k_db_get_professional_xinfa_count()
local JIANGHU_COUNT	=	i3k_db_common.spiritBook.jianghuCount
local PEIBIE_COUNT	=	i3k_db_common.spiritBook.peibieCount

local l_spiritsPre_transLvl = 1
local l_spiritsPre_onNum = 1

function wnd_xinfa:ctor()
	self._id = 0
	ZHIYE_COUNT	=	g_i3k_db.i3k_db_get_professional_xinfa_count()
	--初始化控件
	self.stave = {}
	self.animation = {}
	self.red_point = {}
	self.effect = {}
	self.abt = {}
	self.value = {}
	self.xinfaDesc = {}
	self.xinfaValue = {}
	self.type_btn = {}
	self.staveBg = {}
	self.xiaohao = {}
end

function wnd_xinfa:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.help_btn:onClick(self, self.onHelp)
	widgets.skill_btn:onClick(self, self.onSkillBtn)
	widgets.wujue:onClick(self, self.onWujueBtn)
	widgets.wujue:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_wujue.showLevel)

	self.up_btn = widgets.up_btn
	self.up_btn:onClick(self, self.onUp)--研读心法已获得

	self.scroll = widgets.scroll1
	self.zy_btn = widgets.zy_btn
	self.jh_btn = widgets.jh_btn
	self.pb_btn = widgets.pb_btn
	self.type_btn = {self.zy_btn, self.jh_btn, self.pb_btn, self.pb_btn}
	self.zy_btn:stateToPressed(true)
	widgets.xinfa_btn:stateToPressed()
	self:updatePeibieBtn()
	local anis = self._layout.anis
	for i=1,4 do
		local wg = string.format("c_wg%s", i)
		table.insert(self.animation, anis[wg])
		local effect = string.format("effect%s", i)
		table.insert(self.effect, widgets[effect])
		local xinfa_s = string.format("xinfa%s_s", i)
		local xinfa_value = string.format("xinfa%s_value", i)
		table.insert(self.xinfaDesc, widgets[xinfa_s])
		table.insert(self.xinfaValue, widgets[xinfa_value])
	end
	for i=1,28 do
		local stave = string.format("stave%s",i)
		table.insert(self.stave, widgets[stave])
	end
	for i=1,5 do
		local rp = string.format("red_point%s",i)
		table.insert(self.red_point, widgets[rp])
	end
	for i=1,6 do
		local abt = string.format("abt%s",i)
		table.insert(self.abt, widgets[abt])
		local value = string.format("value%s",i)
		table.insert(self.value, widgets[value])
	end
	for i=2, 4 do
		local stave_bg = string.format("stave_bg%s",i)
		table.insert(self.staveBg, widgets[stave_bg])
	end

	self.desc1 = widgets.desc1
	self.red_point4 = widgets.red_point4
	self.up_btn_label = widgets.up_btn_label
	self.jmRedPoint = widgets.jmRedPoint
	self.jmRedPoint2 = widgets.jmRedPoint2
	self.level_icon = widgets.level_icon
	self.effect_desc = widgets.effect_desc
	self.effect_desc2 = widgets.effect_desc2
	self.item1Name = widgets.item1Name
	self.item2Name = widgets.item2Name
	self.item1_btn = widgets.item1_btn
	self.item2_btn = widgets.item2_btn
	self.item1_icon = widgets.item1_icon
	self.item2_icon = widgets.item2_icon
	self.item1_BgIcon = widgets.item1_BgIcon
	self.item2_BgIcon = widgets.item2_BgIcon
	self.item1Count = widgets.item1Count
	self.item2Count = widgets.item2Count
	self.item_lables = widgets.item_lables
	self.is_have = widgets.is_have
	self.no_have = widgets.no_have
	self.up_btn2 = widgets.up_btn2
	self.xinfa_name = widgets.xinfa_name
	self.xinfa_icon = widgets.xinfa_icon
	self.item_btn = widgets.item_btn
	self.get_way = widgets.get_way
	self.upgrade_btn = widgets.upgrade_btn
	self.hintLabel = widgets.hintLabel
	self.spiritsPre_btn = widgets.spirits_pre
	self.spiritsPre_btn:onClick(self,self.onSpiritsPreClick)
	self.meridian_btn = widgets.meridian_btn;
	self.meridian_btn:onClick(self,self.onMeridianBtn)
end

function wnd_xinfa:refresh()
	local xinfa = g_i3k_game_context:GetXinfa()---new
	self._info = xinfa._zhiye
	self:setHintLabelText()
	self:SetZhiye(true)
	self:updateAnimation(self._id,xinfa._zhiye)--改
	self:SetTotalAttribute(xinfa._zhiye)
	self:upDataRedPoint()
	--self:showUniqueSkillLabel()
	self:spiritsPerBtnFormat()
	self:meridianBtnFormat()
end

function wnd_xinfa:onShow()
end
---绝技标签显隐
function wnd_xinfa:showUniqueSkillLabel()
	self.jueji_btn = self._layout.vars.jueji_btn
	self._heroLevel = g_i3k_game_context:GetLevel()
	local need_lvl = i3k_db_common.functionHide.HideUniqueSkillLabel
	if self._heroLevel < need_lvl then
		self.jueji_btn:hide()
	else
		self.jueji_btn:show()
	end
end

--判断有没有派别心法没有则隐藏该按钮
function wnd_xinfa:updatePeibieBtn()
	local zyID, transfromLvl, BWtype = self:getNeedRoleInfo()
	local pbXinfa = transfromLvl == 0 and i3k_db_generals[zyID].pbXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].pbXinfa
	local zyXinfa = transfromLvl == 0 and i3k_db_generals[zyID].zyXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].zyXinfa
	local jhXinfa = transfromLvl == 0 and i3k_db_generals[zyID].jhXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].jhXinfa
	-- self.pb_btn:setVisible(next(pbXinfa)~=nil and pbXinfa[1]~=0)
	-- self.pb_btn:onTouchEvent(self, self.onPaibie)
	-- self.zy_btn:setVisible(next(zyXinfa)~=nil and zyXinfa[1]~=0)
	-- self.zy_btn:onClick(self, self.onZhiye)
	-- self.jh_btn:setVisible(next(jhXinfa)~=nil and jhXinfa[1]~=0)
	-- self.jh_btn:onClick(self, self.onJianghu)
	self.zy_btn:setVisible(false)
	self.jh_btn:setVisible(false)
	self.pb_btn:setVisible(false)
end

--技能预设按钮
function wnd_xinfa:spiritsPerBtnFormat()
		local use_xinfa_detail = {}
		local use_xinfa = g_i3k_game_context:GetUseXinfa()
		for _,v in pairs(use_xinfa) do
			for _,j in ipairs(v) do
				table.insert(use_xinfa_detail,j)
			end
		end
	if g_i3k_game_context:GetTransformLvl() < l_spiritsPre_transLvl or #use_xinfa_detail < l_spiritsPre_onNum then
		self.spiritsPre_btn :hide()
	else
		self.spiritsPre_btn:show()
	end
end

function wnd_xinfa:SetTotalAttribute(info)--gai
	local hero = i3k_game_get_player_hero()
	--local xinfa = g_i3k_game_context:GetXinfa()
	local value3 = 0


	for k,v in pairs(info) do--new
		value3 = value3 + i3k_db_xinfa_data[k][v].layer
	end
	self.xinfaDesc[1]:setText("气功伤害：")
	self.xinfaValue[1]:setText(hero:GetPropertyValue(ePropID_atkC))
	self.xinfaDesc[2]:setText("气功防御：")
	self.xinfaValue[2]:setText(hero:GetPropertyValue(ePropID_defC))
	self.xinfaDesc[3]:setText("气功总层级：")
	self.xinfaValue[3]:setText(value3)
	self.xinfaDesc[4]:setText("气功精通：")
	self.xinfaValue[4]:setText(hero:GetPropertyValue(ePropID_masterC))
end

function wnd_xinfa:getNeedRoleInfo()
	return g_i3k_game_context:GetRoleType(), g_i3k_game_context:GetTransformLvl(), g_i3k_game_context:GetTransformBWtype()
end

function wnd_xinfa:SetZhiye(isStretch)
	self.up_btn_label:setText("学习气功")
	local zyID, transfromLvl, BWtype = self:getNeedRoleInfo()
	local zyXinfa = transfromLvl == 0 and i3k_db_generals[zyID].zyXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].zyXinfa
	local xinfa = g_i3k_game_context:GetXinfa()
	local useXinfa = g_i3k_game_context:GetUseXinfa()
	local use_data = useXinfa._zhiye
	local desc = string.format("已装备：%s/%s",#use_data,ZHIYE_COUNT)
	self.desc1:setText(desc)
	self:SetScrollData(zyXinfa, xinfa._zhiye, use_data, isStretch)
end

function wnd_xinfa:SetJianghu(isStretch)
	local zyID, transfromLvl, BWtype = self:getNeedRoleInfo()
	local jhXinfa = transfromLvl == 0 and i3k_db_generals[zyID].jhXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].jhXinfa
	local xinfa = g_i3k_game_context:GetXinfa()
	local useXinfa = g_i3k_game_context:GetUseXinfa()
	local use_data = useXinfa._jianghua
	local desc = string.format("已装备：%s/%s",#use_data,JIANGHU_COUNT)
	self.desc1:setText(desc)
	self:SetScrollData(jhXinfa, xinfa._jianghua, use_data, isStretch)
end

function wnd_xinfa:SetPaibie(isStretch)
	local zyID, transfromLvl, BWtype = self:getNeedRoleInfo()
	local pbXinfa = transfromLvl == 0 and i3k_db_generals[zyID].pbXinfa or i3k_db_zhuanzhi[zyID][transfromLvl][BWtype].pbXinfa
	local xinfa = g_i3k_game_context:GetXinfa()
	local useXinfa = g_i3k_game_context:GetUseXinfa()
	local use_data = useXinfa._paibie
	local desc = string.format("已装备：%s/%s",#use_data,PEIBIE_COUNT)
	self.desc1:setText(desc)
	self:SetScrollData(pbXinfa, xinfa._paibie, use_data, isStretch)
end

function wnd_xinfa:setHintLabelText()
	local dialogueCfg = i3k_db_dialogue[999998]
	local id = math.floor(math.random(1, #dialogueCfg))
	local time = 0
	local index = time+id
	local txt = dialogueCfg[index].txt
	self.hintLabel:setText(txt)
	function update(dTime)
		if index >= #dialogueCfg then
			time = 0
			id   = 0
		end
		time = time +1
		index =time+id
		self.hintLabel:setText(txt)
	end
	if not self._scheduler then
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 5, false)
	end
end

function wnd_xinfa:SetScrollData(data, zy_data, use_data, isStretch)
	self.scroll:removeAllChildren()
	if isStretch then
		self.scroll:setContainerSize(0, 0)
	end

	if next(data) then
		for k,v in ipairs(data) do
			if k == 1 and self._id == 0 then
				self._id = v
			end
			local _layer = require(LAYER_XFLBT)()
			self:updateScollWidget(data, zy_data, use_data, v, _layer.vars)
			self.scroll:addItem(_layer)
		end
		self:SetData(self._id, zy_data)---改
	else
		self:SetData(nil)
	end

	self:SetTotalAttribute(zy_data)
	self:upDataRedPoint()
end

local LAYER_LEVEL_DESC = {"一层", "二层", "三层", "四层"}
-- 未习得，元始，一，二，三，圆满
local LAYER_LEVEL_DESCS = {135,133,130,131,132,134}
function wnd_xinfa:updateScollWidget(data, zy_data, use_data, v, widgets)
	widgets.select2_btn:setVisible(zy_data[v]~=nil)--显示勾选装备
	widgets.btn_icon1:setVisible(zy_data[v]~=nil)
	local item_id = i3k_db_xinfa[v].itemID
	if not zy_data[v] then
		widgets.red_point:setVisible(g_i3k_game_context:GetCommonItemCanUseCount(item_id)~=0)
		widgets.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(notHaveXinfaIcon))
		--//add by jxw 需要修改的地方 无需设置图标
		--widgets.bg_grade:disable()
		--widgets.icon:disable()
		widgets.layer_lvl:setVisible(true)
		widgets.icon_desc:setVisible(false)

		--widgets.name:setTextColor(noHaveColor)
		widgets.layer_lvl:setText("尚未获得")
		widgets.layer_lvl:setTextColor(noHaveColor) --灰色
		widgets.icon_desc:setImage(g_i3k_db.i3k_db_get_icon_path(LAYER_LEVEL_DESCS[1]))

	else
		widgets.select2_btn:onClick(self, self.onUseXinfa, {id = v, useXinfa = use_data,info = zy_data})--勾选装备  改
		widgets.red_point:setVisible(g_i3k_game_context:isXinfaEnoughUpLvl(v, zy_data[v]))
		widgets.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(haveXinfaIcon))
		--widgets.name:setTextColor(haveXinfaColor)

		local lvl, layerLvl = self:getXinFaLevelAndLayer(v, zy_data)---改
		widgets.icon_desc:setVisible(false)
		widgets.layer_lvl:setVisible(true)
		local desc = layerLvl == 0 and "元始" or LAYER_LEVEL_DESC[layerLvl]
		widgets.layer_lvl:setText(desc)
		widgets.icon_desc:setImage(g_i3k_db.i3k_db_get_icon_path(LAYER_LEVEL_DESCS[layerLvl+2]))
		if layerLvl == i3k_db_xinfa[v].maxLayer then
			widgets.layer_lvl:setText("圆满")
			widgets.icon_desc:setImage(g_i3k_db.i3k_db_get_icon_path(LAYER_LEVEL_DESCS[6]))
		end

		--widgets.layer_lvl:setTextColor(haveXinfaColor)
	end
	widgets.bg_grade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item_id))
	--//add by jxw 需要修改的地方  列表中，无论气功是否解锁，气功图标与气功文字颜色，均根据气功对应的解锁道具的品质决定
	widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item_id,i3k_game_context:IsFemaleRole()))
	widgets.name:setText(i3k_db_xinfa[v].name)
	widgets.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item_id)))

	widgets.select1_btn:onClick(self, self.onSelect, {widgets = widgets, id = v, allXinfa = data,info = zy_data})--加一个参数
	widgets.is_show:setVisible(self._id == v)
	widgets.btn_icon2:hide()
	for i, e in ipairs(use_data) do
		if e == v then
			widgets.btn_icon2:setVisible(e==v)
			break
		end
	end
	if self._id == v then
		widgets.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(selectXinfaIcon))
		--widgets.name:setTextColor(selectXinfaColor)
		--widgets.layer_lvl:setTextColor(selectXinfaColor)
	end
end

function wnd_xinfa:hideSelect(allXinfa, haveXinfa)
	local all_child = self.scroll:getAllChildren()
	for i, e in ipairs(all_child) do
		e.vars.is_show:hide()
		e.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(notHaveXinfaIcon))
	end
	for i, e in ipairs(allXinfa) do
		local xinfaBg = all_child[i].vars.xinfaBg
		local name = all_child[i].vars.name
		local layerLvl = all_child[i].vars.layer_lvl
		--name:setTextColor(noHaveColor)
		xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(notHaveXinfaIcon))
		--layerLvl:setTextColor(noHaveColor)
		if haveXinfa[e] then
			xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(haveXinfaIcon))
			--name:setTextColor(haveXinfaColor)
			--layerLvl:setTextColor(haveXinfaColor)
		end
	end
end

function wnd_xinfa:onSelect(sender, data)
	self._info = data.info---
	if self._id == data.id then
		return
	end
	local widgets = data.widgets
	local id = data.id


	self._xinfaPercent = self._layout.vars.scroll1:getListPercent()---
	--i3k_log("--onSelect-------",self._xinfaPercent)----
	self:hideSelect(data.allXinfa,data.info)-- haveXinfa
	widgets.is_show:show()
	widgets.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(selectXinfaIcon))
	--widgets.name:setTextColor(selectXinfaColor)
	--widgets.layer_lvl:setTextColor(selectXinfaColor)
	self._id = id
	self:updateAnimation(self._id,data.info)--haveXinfa
	self:SetData(self._id,data.info,self._xinfaPercent)---改  haveXinfa
end

function wnd_xinfa:onUseXinfa(sender, data)
	local id = data.id
	local widgets = data.widgets
	local useXinfa = data.useXinfa
	self._id = id
	self:updateAnimation(self._id,data.info)
	local xinfaType = i3k_db_xinfa[id].type
	local isUse = false
	for i, e in ipairs(useXinfa) do
		if id == e then
			isUse = true
			break
		end
	end
	self._xinfaPercent = self._layout.vars.scroll1:getListPercent()---
	--i3k_log("--onUseXinfa-------",self._xinfaPercent)----
	if isUse then
		i3k_sbean.goto_spirit_uninstall(id,self._xinfaPercent)--卸载
	else
		if xinfaType == g_ZHIYE_XINFA then
			if #useXinfa < ZHIYE_COUNT then
				i3k_sbean.goto_spirit_install(id,self._xinfaPercent)
			else
				local str = i3k_get_string(692,ZHIYE_COUNT)
				g_i3k_ui_mgr:PopupTipMessage(str)
			end
		elseif xinfaType == g_JIANGHU_XINFA then
			if #useXinfa < JIANGHU_COUNT then
				i3k_sbean.goto_spirit_install(id,self._xinfaPercent)
			else
				local str = string.format("江湖气功只能装备%s个", JIANGHU_COUNT)
				g_i3k_ui_mgr:PopupTipMessage(str)
			end
		elseif xinfaType == g_PEIBIE_XINFA then
			if #useXinfa < PEIBIE_COUNT then
				i3k_sbean.goto_spirit_install(id,self._xinfaPercent)
			else
				local str = string.format("派别气功只能装备%s个", PEIBIE_COUNT)
				g_i3k_ui_mgr:PopupTipMessage(str)
			end
		end
	end
end

function wnd_xinfa:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(8))
end

function wnd_xinfa:onUp(sender)

	--local xinfa = g_i3k_game_context:GetXinfa()
	local lv = 0
	local tmp = 0


	self._xinfaPercent = self._layout.vars.scroll1:getListPercent()---新增
	--i3k_log("--onUp-------",self._xinfaPercent)----
	if self._info[self._id] then ---
		lv = self._info[self._id]
		tmp = lv
		lv = lv + 1
	end

	local id = self._id
	if i3k_db_xinfa_data[self._id][lv] then
		if lv == 0 then
			local needItem = i3k_db_xinfa[self._id].itemID
			local count = g_i3k_game_context:GetCommonItemCanUseCount(needItem)

			if count  == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(11))
				return
			end
			i3k_sbean.goto_spirit_learn(self._id, lv,self._xinfaPercent)-- 心法学习
		else
			if g_i3k_game_context:isXinfaEnoughUpLvl(self._id, tmp) then
				i3k_sbean.goto_spirit_levelup(self._id, lv,self._xinfaPercent)---- 心法研读
			else
				local str = string.format("所需材料不足")
				g_i3k_ui_mgr:PopupTipMessage(str)
			end
		end
		--i3k_log("--onUp-------",count,needItem,self._id,lv)----
	end
end

function wnd_xinfa:onSpiritsPreClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritsSet)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritsSet,1)
end

--诗句的动画
function wnd_xinfa:playStaveEffect(lvl)
	local widgets = self._layout.vars
	local pos = self.stave[lvl]:getPosition()
	local worldPos = widgets.bao:getParent():convertToNodeSpace(self.stave[lvl]:getParent():convertToWorldSpace(pos))

	widgets.bao:setPosition(worldPos)
	self._layout.anis.c_bd.play()
end
--得到心法描述
function wnd_xinfa:upDateLine(id, lvl, isPlay)
	local desc = i3k_db_xinfa[id].desc
	for i, e in ipairs(self.staveBg) do
		e:hide()
	end
	self.staveBg[#desc/7-1]:show()
	for i=1, #self.stave do
		local color = i <= lvl  and FINISH or UN_FINISH
		self.stave[i]:setTextColor(color)
		self.stave[i]:setVisible(desc[i]~=nil)
		if desc[i] then
			self.stave[i]:setText(desc[i])
		end
	end
end
--刷新播放武功动画
function wnd_xinfa:updateAnimation(id,info)--改多了一个参数
	local lvl, layer_lvl = self:getXinFaLevelAndLayer(id,info)--改多了一个参数
	for i, e in pairs(self.animation) do
		e.stop()
	end
	if layer_lvl == 0 then
		self.animation[1].play()
	else
		self.animation[layer_lvl].play()
	end
end

function wnd_xinfa:btnToNormal()
	for i, e in pairs(self.type_btn) do
		e:stateToNormal(true)
	end
end

function wnd_xinfa:onZhiye(sender)
	self._id = 0
	self._info = g_i3k_game_context:GetXinfa()._zhiye
	self:SetZhiye(true)
	self:btnToNormal()
	self.zy_btn:stateToPressed(true)
end
---江湖心法
function wnd_xinfa:onJianghu(sender)
	self._id = 0
	self._info =  g_i3k_game_context:GetXinfa()._jianghua--
	self:SetJianghu(true)
	self:btnToNormal()
	self.jh_btn:stateToPressed(true)
end

function wnd_xinfa:onPaibie(sender)
	self._id = 0
	self._info = g_i3k_game_context:GetXinfa()._paibie
	self:SetPaibie(true)
	self:btnToNormal()
	self.pb_btn:stateToPressed(true)
end
--获取对应心法的等级和层级
function wnd_xinfa:getXinFaLevelAndLayer(id,info)

	local lv = 0
	if next(info) ~= nil then
		if info[id] then
			lv = info[id]
		end
	end
	return lv, i3k_db_xinfa_data[id][lv].layer
end

function wnd_xinfa:SetData(id,info,percent)---改
	--i3k_log("--SetData = -------",id,self._xinfaPercent,percent)----
	self._id = id
	if not id or not i3k_db_xinfa_data[id] then
		for i, e in pairs(self.effect) do
			e:hide()
		end
		for i, e in pairs(self.abt) do
			e:hide()
		end
		for i, e in pairs(self.value) do
			e:hide()
		end
		self.effect_desc:hide()
		self.item1Name:hide()
		self.item2Name:hide()
		self.item1_icon:hide()
		self.item2_icon:hide()
		self.item1Count:hide()
		self.item2Count:hide()
		self.item1_BgIcon:hide()
		self.item2_BgIcon:hide()
		return
	end


	local lvl
	local is_ok = false
	local now_layer
	local typeXinfa = i3k_db_xinfa[id].type

	local lv, layerLevel = self:getXinFaLevelAndLayer(self._id,info)---改
	self:upDateLine(self._id, lv, false)
	local condition = (typeXinfa == 1 and not info[id]) or (typeXinfa == 2 and not info[id]) or (typeXinfa == 3 and not info[id])
	--i3k_log("----SetData---------",id,info[id],condition)----
	self.no_have:setVisible(condition)--未获得心法时的界面
	if condition then---未获得时
		for i=1,#self.effect do
			self.effect[i]:hide()
		end
		self.is_have:hide()
		self._info = info
		self.up_btn2:onClick(self, self.onUp)---未获得时学习心法 多一个参数
		local itemid = i3k_db_xinfa[id].itemID
		self.xinfa_name:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(itemid)~=0))
		self.get_way:setText(g_i3k_db.i3k_db_get_common_item_source(itemid))
		local tmp_str = string.format("%s ×1",g_i3k_db.i3k_db_get_common_item_name(itemid))
		self.xinfa_name:setText(tmp_str)
		self.item_btn:onClick(self, self.onItemTips, itemid)
		self.xinfa_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		self.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[1]))
		self.up_btn_label:setText("学习气功")
		self.effect_desc2:setText(i3k_db_xinfa[id].effectDesc[1])
		self._layout.vars.max:hide()
	else
		self.is_have:show()---显示获得心法的界面
		is_ok = true


		local _t = i3k_db_xinfa_data[id]---new
		local lv1 = info[id]
		local _data
		if _t[lv1] then
			_data = _t[lv1]
			lvl = lv1
		end
		self.upgrade_btn:setText("研读气功")
		if _data then

			now_layer = _data.layer


			self:setItemAttribute(_t,lvl,_data)----改
			self.effect[1]:show()
			self.effect[1]:setText("【研习效果】")
		end

		local xiaohao = _t[lvl + 1]
		self._layout.vars.max:setVisible(not xiaohao)
		self.item_lables:setVisible(xiaohao~=nil)
		self.item1Name:setVisible(xiaohao~=nil)
		self.item2Name:setVisible(xiaohao~=nil)
		self.item1_icon:setVisible(xiaohao~=nil)
		self.item2_icon:setVisible(xiaohao~=nil)
		self.item1Count:setVisible(xiaohao~=nil)
		self.item2Count:setVisible(xiaohao~=nil)
		self.up_btn:setVisible(xiaohao~=nil)--获得时学习心法
		self.xiaohao = xiaohao
		if xiaohao then
			local item1ID = XINFA_ENERGY
			local item2ID = xiaohao.item2ID
			self.item1Name:setText(g_i3k_db.i3k_db_get_common_item_name(item1ID))
			self.item2Name:setText(g_i3k_db.i3k_db_get_common_item_name(item2ID))
			self.item1Name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item1ID)))
			self.item2Name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item2ID)))
			self.item1_btn:onClick(self, self.onItemTips, item1ID)
			self.item2_btn:onClick(self, self.onItemTips, item2ID)
			self.item1_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item1ID,i3k_game_context:IsFemaleRole()))
			self.item1_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item1ID))
			self.item2_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item2ID,i3k_game_context:IsFemaleRole()))
			self.item2_BgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item2ID))

			self:setItemScrollData()
		else
			for i, e in pairs(self.effect) do
				e:hide()
			end
		end

		self:setItemXiaohaoAttributes(_t,lvl)
		if now_layer then

			self.effect_desc:setText(i3k_db_xinfa[id].effectDesc[now_layer+1])
		end

		--新增
		if percent and percent>0 then
			self._layout.vars.scroll1:jumpToListPercent(percent)

		else
			self._layout.vars.scroll1:jumpToListPercent(0)
		end
	end
	self:SetTotalAttribute(g_i3k_game_context:GetXinfa()._zhiye);
end

function wnd_xinfa:setItemScrollData()
 	if not self.xiaohao or not next(self.xiaohao) then
		return
	end
	local item1ID = XINFA_ENERGY
	local Count1 = self.xiaohao.item1Count
	local item2ID = self.xiaohao.item2ID
	local Count2 = self.xiaohao.item2Count
	if not Count1 or not item2ID or not Count2  then
		return
	end
	local item1_num = g_i3k_game_context:GetCommonItemCanUseCount(item1ID)
	local item2_num = g_i3k_game_context:GetCommonItemCanUseCount(item2ID)
	self.item1Count:setText(item1_num.."/"..Count1)
	self.item2Count:setText(item2_num.."/"..Count2)
	self.item1Count:setTextColor(g_i3k_get_cond_color(Count1 <= item1_num))
	self.item2Count:setTextColor(g_i3k_get_cond_color(Count2 <= item2_num))
end

function wnd_xinfa:setItemAttribute(_t,lvl,_data)
	local layer = _data.layer

	local __error_default = {attribute1=0,value1=0,attribute2=0,value2=0}
	local attribute1 = (_t[lvl+1] or __error_default).attribute1--_data.attribute1
	local value1 = (_t[lvl+1] or __error_default).value1 -- _data.value1
	local attribute2 = (_t[lvl+1] or __error_default).attribute2--_data.attribute2
	local value2 = (_t[lvl+1] or __error_default).value2 --_data.value2
	if layer == 0 then
		self.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[2]))
	else
		if _t[lvl + 1] then
			self.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[layer +2]))
		else
			self.level_icon:setImage(g_i3k_db.i3k_db_get_icon_path(xinfa_layer[6]))
		end
	end

	if attribute1 ~= 0 then
		local desc1 = i3k_db_prop_id[attribute1].desc
		self.effect[2]:show()
		self.effect[2]:setText(desc1.."+"..value1)
		if attribute2 ~= 0 then
			local desc2 = i3k_db_prop_id[attribute2].desc
			self.effect[3]:show()
			self.effect[3]:setText(desc2.."+"..value2)
			self.effect[4]:setText("气功效果提升")
			self.effect[4]:setVisible(lvl ~= 0 and (lvl+1)%7 == 0 )
		else
			self.effect[3]:setText("气功效果提升")
			self.effect[3]:setVisible(lvl ~= 0 and (lvl+1)%7 == 0)
			self.effect[4]:show()
		end
	elseif attribute2 ~= 0 then
		local desc2 = i3k_db_prop_id[attribute2].desc
		self.effect[2]:show()
		self.effect[2]:setText(desc2.."+"..value2)
		self.effect[3]:setText("气功效果提升")
		self.effect[4]:hide()
		self.effect[3]:setVisible(lvl ~= 0 and (lvl+1)%7 == 0)
	else
		for i, e in pairs(self.effect) do
			e:hide()
		end
	end

end
--研习消耗物品的属性
function wnd_xinfa:setItemXiaohaoAttributes(_t,lvl)
	local _temp = {}
	local _tmp_sort = {}
	if _t[0].attribute1 ~= 0 then
		local is_ok = false
		for k,v in pairs(_tmp_sort) do
			if v.attribute == _t[0].attribute1 then
				v.value = v.value + _t[0].value1
				is_ok = true
			end
		end
		if not is_ok then
			local index = #_tmp_sort + 1
			_tmp_sort[index] = {}
			_tmp_sort[index].attribute =  _t[0].attribute1
			_tmp_sort[index].value = _t[0].value1
		end

	end
	if _t[0].attribute2 ~= 0 then
		local is_ok = false
		for k,v in ipairs(_tmp_sort) do
			if v.attribute == _t[0].attribute2 then
				v.value = v.value + _t[0].value2
				is_ok = true
			end
		end
		if not is_ok  then
			local index = #_tmp_sort + 1
			_tmp_sort[index] = {}
			_tmp_sort[index].attribute =  _t[0].attribute2
			_tmp_sort[index].value = _t[0].value2
		end
	end

	for k,v in ipairs(_t) do
		if k > lvl then
			break
		end
		local is_ok1 = false
		local is_ok2 = false
		if v.attribute1 ~= 0 then
			for a,b in  ipairs(_tmp_sort) do
				if b.attribute == v.attribute1 then
					b.value = b.value + v.value1
					is_ok1 = true
				end
			end
			if not is_ok1 then
				local index = #_tmp_sort + 1
				_tmp_sort[index] = {}
				_tmp_sort[index].attribute = v.attribute1
				_tmp_sort[index].value = v.value1
			end

		end
		if v.attribute2 ~= 0 then
			for a,b in  ipairs(_tmp_sort) do
				if b.attribute == v.attribute2 then
					b.value = b.value + v.value2
					is_ok2 = true
				end
			end
			if not  is_ok2 then
				local index = #_tmp_sort + 1
				_tmp_sort[index] = {}
				_tmp_sort[index].attribute = v.attribute2
				_tmp_sort[index].value = v.value2
			end
		end
	end
	for i=1,#self.abt do
		self.abt[i]:hide()
	end

	for i=1,#self.value do
		self.value[i]:hide()
	end
	local count = 0
	for k,v in ipairs(_tmp_sort) do
		count  = count +1
		local desc = i3k_db_prop_id[v.attribute].desc
		desc = desc.."："
		self.abt[count]:show()
		self.abt[count]:setText(desc)
		self.value[count]:show()
		self.value[count]:setText(v.value)
	end
end
function wnd_xinfa:onItemTips(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

---武功标签
function wnd_xinfa:onSkillBtn(sender)
	self:onCloseUI()
	g_i3k_logic:OpenSkillLyUI()
end

function wnd_xinfa:meridianBtnFormat()
	local limitLvl = i3k_db_meridians.common.limitLvl
	if g_i3k_game_context:GetLevel() < limitLvl then
		self.meridian_btn:hide()
	else
		self.meridian_btn:show()
	end
end

function wnd_xinfa:onMeridianBtn(sender)
	g_i3k_logic:OpenMeridian(eUIID_XinFa)
end






function wnd_xinfa:upDataRedPoint()
	for i=1, 3 do
		self.red_point[i]:setVisible(g_i3k_game_context:isCanLearnXinfa(i))
	end
	self.red_point[4]:setVisible(g_i3k_game_context:isShowSkillRedPoint())
	self.red_point[5]:setVisible(g_i3k_game_context:isShowXinfaRedPoint())
	self.jmRedPoint:setVisible(g_i3k_game_context:GetIsMeridianRed())
	self.jmRedPoint2:setVisible(g_i3k_game_context:isShowWujueRedPoint())
end


function wnd_xinfa:releaseSchedule()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end

function wnd_xinfa:onHide()
	self:releaseSchedule()
end

function wnd_xinfa:onCloseUI()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
	g_i3k_ui_mgr:CloseUI(eUIID_XinFa)

end

function wnd_xinfa:onWujueBtn(sender)
	g_i3k_logic:OpenWujueUI()
end
function wnd_create(layout)
	local wnd = wnd_xinfa.new()
	wnd:create(layout)
	return wnd
end
