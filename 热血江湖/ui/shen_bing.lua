-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
require("i3k_usercfg");
require("i3k_ui_mgr");

local shenbing_moduleTb = nil
-------------------------------------------------------
wnd_shen_bing = i3k_class("wnd_shen_bing", ui.wnd_base)

local LAYER_SBLBT = "ui/widgets/sblbt"

local JIESHAO = "ui/widgets/shenbingjieshao"
local SHENBINGMAX = "ui/widgets/shenbingqianghuaman"
local SHENGJI = "ui/widgets/shenbingshengji"
local SHENGXING = "ui/widgets/shenbingshengxing"
local JUEXING = "ui/widgets/shenbingjuexing"
local XIANSUO = "ui/widgets/shenbingxiansuo"---
local YUANBAOSHENGJI ="ui/widgets/yuanbaoshengji2"
local TIANFU = "ui/widgets/shenbingtianfu"
local TISHI = "ui/layers/sbts"

local star_icon = {3055,3056,3057,3058,3059,3060,3061,3062,3063,3064}

local SHENBING_ATTACK = 1015
local SHENBING_DEFENSE = 1016
local CRIT = 1006
local TOUGHNESS = 1007
local HP = 1001

local MANXING = 365


local MANXINGJIACHENG = 366
local MANJI = 367
local MANJIJIACHENG = 368

local onSelection_Icon = 706
local attained_Icon = 707
local unAttained_Icon = 708



function wnd_shen_bing:ctor()
	self._shenbing = {}
	--local id = nil
	local id = g_i3k_game_context:GetSelectWeapon()
	self._id = id ~= 0 and id or 1
	self.weaponValue = {}
	self.property_root = {}
	self.skill_btn = {}
	self.skill_bg = {}
	self.up_arrow = {}
	self.item_widget = {}
	self.Root = {}
	self.co = nil
	--self._shenbingget = {}
	--self._shenbingnoget = {}

	self._canUse = true
	self.widgets = nil
	shenbing_moduleTb = {[1] = {callback = wnd_shen_bing.setUnlockModule},[2] = {callback = wnd_shen_bing.setResponseModule},[3] = {callback = wnd_shen_bing.setlockModule}
	}

	self.isShenBingStar = false
	self.isShenBingUp   = true
	self.isShenBingAwake = false
end

function wnd_shen_bing:configure()
	local widgets = self._layout.vars
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self.shenbing_module = widgets.shenbing_module
	self.xinasuo_label = widgets.xinasuo_label
	self.desc_label = widgets.desc_label
	widgets.help_btn:onClick(self, self.onHelp)

	for i=1, 4 do
		local value = string.format("weapon%s_value",i)
		table.insert(self.weaponValue, widgets[value])
	end

	self.red_point1 = widgets.red_point2--下
	self.red_point2 = widgets.red_point1

	self.scroll1 = widgets.scroll1
	self.equip_weapon_lable = widgets.equip_weapon_lable
	self.equip_weapon_btn = widgets.equip_weapon_btn

	self.awake_btn = widgets.awake_btn
	self.desc_btn = widgets.desc_btn
	self.xiansuo_btn = widgets.xiansuo_btn
	self.shenbing_desc = widgets.shenbing_desc
	self.property_btn = widgets.property_btn
	self.shenbing_getway = widgets.shenbing_getway
	self.tianfu_label = widgets.tianfu_label
	for i=1,3 do
		local property_label = string.format("property_label%s",i)
		table.insert(self.property_root, widgets[property_label])
	end
	self.c_sj = self._layout.anis.c_sbsj
	self.c_sbsx = self._layout.anis.c_sbsx
	self.c_xm = self._layout.anis.c_xm

	for i=1,4 do
		local temp_skill = "skill"..i.."_btn"
		local temp_skill_bg = "skill"..i.."_bg"
		local up_arrow = "up_arrow"..i
		table.insert(self.skill_btn, widgets[temp_skill])
		table.insert(self.skill_bg, widgets[temp_skill_bg])
		table.insert(self.up_arrow, widgets[up_arrow])
	end

	self.battle_bg = widgets.battle_bg--------
	self.battle_power = widgets.battle_power
	self.new_root = widgets.new_root
	-----------------------------------------
	self.talent_btn = widgets.talent_btn
	self.talent_point = widgets.talent_point
	----------------------------------------
	self.unique_skill_btn = widgets.unique_skill_btn
	self.unique_skill_icon = widgets.unique_skill_icon
	widgets.commentBtn:onClick(self, self.openCommentUI)
	widgets.recycle_btn:onClick(self, self.onRecycle)                 --碎片回收入口
	self.awake_btn:onClick(self, self.onAwakeBtnClick)
	self:initQiling()
end

function wnd_shen_bing:initQiling()
	local weaponID = self._id
	local widgets = self._layout.vars
	widgets.qilingBtn:onClick(self, self.onQilingBtn)
	local reqLevel = i3k_db_qiling_cfg.showLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	widgets.qilingBtn:setVisible(roleLevel >= reqLevel)
	local imgID = self:getQilingImageID(weaponID)
	widgets.qilingIcon:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
end

function wnd_shen_bing:getQilingImageID(weaponID)
	local qilingIconList = {4589, 4590, 4594,5320,6975}
	local info = g_i3k_game_context:getQilingData()
	if not next(info) then
		return 4588 -- 未装备
	end
	for k, v in ipairs(info) do
		if weaponID == v.equipWeaponId then
			return qilingIconList[k]
		end
	end
	return 4588 -- 未装备
end

function wnd_shen_bing:updateUpLevelAnimation(data)--神兵升星和神兵神兵升阶的时候播放的动画
	for k,v in ipairs(self.property_root) do
		local tmp_str = string.format("%s+%s",data.newData[k].name,(data.newData[k].value - data.oldData[k].value))
		v:setText(tmp_str)
	end
	self.c_sj.play()
end

function wnd_shen_bing:updateStarLevelAnimation()
	self.c_sbsx.play()
end

function wnd_shen_bing:addNewNode(layer)
	g_i3k_coroutine_mgr:StopCoroutine(self.co)
	local nodeWidth = self.new_root:getContentSize().width
	local nodeHeight = self.new_root:getContentSize().height
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth,nodeHeight)
end

function wnd_shen_bing:refresh(id)

	self:SetShenbingData(g_i3k_game_context:GetShenbingData())
	self:SetTotalAttribute()
	self:updateIsUse()
	self:SetShenBingUpSkillData(g_i3k_game_context:GetShenbingData())
	if id then
		self:onSelectBtnHave(nil, id)
	end
end

function wnd_shen_bing:isCanSummon(id)--是否能够集齐
	local allShenbing = g_i3k_game_context:GetShenbingData()
	if not allShenbing[id] then
		self.red_point2:setVisible(g_i3k_game_context:isEnougSummonWeapon(id))---如果未解锁时有足够的碎片，就显示红点线索
		self.red_point1:hide()
		return g_i3k_game_context:isEnougSummonWeapon(id)
	end
end

function wnd_shen_bing:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(15))
end

function wnd_shen_bing:SetTotalAttribute()
	local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
	local value3 = 0
	for k,v in pairs(allShenbing) do
		value3 = value3 + i3k_db_shen_bing_upstar[k][v.slvl].grade
	end
	local hero = i3k_game_get_player_hero()
	self.weaponValue[1]:setText(hero:GetPropertyValue(ePropID_atkW))
	self.weaponValue[2]:setText(hero:GetPropertyValue(ePropID_defW))
	self.weaponValue[3]:setText(value3)
	self.weaponValue[4]:setText(hero:GetPropertyValue(ePropID_masterW))
end

function wnd_shen_bing:SetModule(id, tagId )----模型id

	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.shenbing_module:setSprite(path)
	self.shenbing_module:setSprSize(uiscale)


	shenbing_moduleTb[tagId].callback(self, id)
end

function wnd_shen_bing:setUnlockModule(id)----解锁连续动作

	self.shenbing_module:pushActionList("unlock",1)
	self.shenbing_module:pushActionList("stand",-1)
	self.shenbing_module:playActionList()--
end

function wnd_shen_bing:setResponseModule(id)----装备/升阶/升星连续动作

	self.shenbing_module:pushActionList("response",1)
	self.shenbing_module:pushActionList("stand",-1)
	self.shenbing_module:playActionList()


end

function wnd_shen_bing:setlockModule(id)----动作
	--local tagId = g_i3k_game_context:GetShenBingState(id)
	--if tagId == self._id then
		self.shenbing_module:playAction("lock")
	--end

end

function wnd_shen_bing:SetShenbingData(allShenbing ,useShenbing, isTrue)
	self:SetShenbingDataInfo(allShenbing ,useShenbing, isTrue)
	self:updateRightUI(allShenbing, self._id ,useShenbing)
	local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
	local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
	self:SetModule(weaponModuleID, g_i3k_game_context:GetShenBingState(self._id))---
end

function wnd_shen_bing:SetShenbingDataInfo(allShenbing ,useShenbing, isTrue)
	self.scroll1:removeAllChildren()
	self._shenbing = {}

	local shenbinguTb = {}
	self.shenbinguTb = shenbinguTb

	local index = 0
	local count = 0
	for i, e in ipairs(i3k_db_shen_bing) do
		local id = e.id
		local _layer = require(LAYER_SBLBT)()
		if e.canUse then
			if allShenbing[id] then--解锁
				index = allShenbing[id].qlvl * 1000 + allShenbing[id].slvl * 100 + 100 - id
			else
				index = 100 - id
			end
			table.insert(shenbinguTb, {sortid = index,id = id , layer = _layer} )
		else
			_layer.vars.sb_root:hide()
		end

	end
	table.sort(shenbinguTb,function (a,b)
		local have_a = allShenbing[a.id]
		local have_b = allShenbing[b.id]
		local enough_a = g_i3k_game_context:isEnougSummonWeapon(a.id)
		local enough_b = g_i3k_game_context:isEnougSummonWeapon(b.id)
		local active_a = not have_a and enough_a
		local active_b = not have_b and enough_b
		if active_a == active_b then
				return a.sortid > b.sortid
		else
			return active_a
		end
			end)
	for i,v in ipairs(shenbinguTb) do
		local widget = v.layer.vars
		local isAwake = g_i3k_game_context:IsShenBingAwake(v.id)
		local awakeCfg = i3k_db_shen_bing_awake[v.id]
		local icon = isAwake and awakeCfg.awakeWeaponIcon or i3k_db_shen_bing[v.id].icon
		local iconBg = isAwake and awakeCfg.awakeBackground
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		if isAwake then
			widget.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(iconBg))
		end
		widget.name:setText(i3k_db_shen_bing[v.id].name)
		self._shenbing[i] = {
			id = v.id,
			is_show = widget.is_show,
			is_select_icon = widget.is_select,
			qlvl = widget.qlvl,---等级
			slvl_icon = widget.slvl,--星星
			red_point = widget.red_point,
			xinfaBg = widget.xinfaBg,
			widget = widget
		}
		g_i3k_game_context:SetShenbingState(id,g_WEAPON_STATE_LOCK)

		if allShenbing[v.id] then--解锁
			--table.insert(self._shenbingget, {id = v.id ,xinfaBg = widget.xinfaBg} )
			self:updateShenbingLvl(v.id, allShenbing[v.id].qlvl, allShenbing[v.id].slvl)
			widget.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(attained_Icon))
			widget.desc:hide()--线索描述
			widget.select1_btn:onClick(self, self.onSelectBtnHave, v.id)--点击左侧
			local talentRedPoint = false
			if g_i3k_game_context then
				if g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.shenbingtianfuOpenLvl and g_i3k_game_context:IsShenBingCanInput(v.id) and not g_i3k_game_context:GetShenbingTalentRedPointRecord(v.id) then
					talentRedPoint = true
				end
			end

			if g_i3k_game_context:isEnoughUpWeaponlvl(v.id) or g_i3k_game_context:isEnoughUpWeaponStar(v.id) or talentRedPoint or g_i3k_game_context:GetShenBingUniqueRedPointState(v.id) or g_i3k_game_context:GetWeaponAwakeRed(v.id) then
				widget.red_point:show()
			else
				widget.red_point:hide()
			end
		else
			--table.insert(self._shenbingnoget, {id = v.id ,xinfaBg = widget.xinfaBg} )
			local isShowRed = self:isCanSummon(v.id)
			widget.red_point:setVisible(isShowRed)
			if isShowRed and not self._firstCanActive then
				self._firstCanActive = v.id
				self._id = v.id
			end
			widget.qlvl_icon1:hide()
			widget.qlvl:hide()
			widget.slvl:hide()
			widget.desc:setText(isShowRed and "线索已获得" or "尚未获得线索")
			widget.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(unAttained_Icon))
			widget.select1_btn:onClick(self, self.onShenbingNohave,{id= v.id,tag = i})


		end
		if i == 1 and not self._id then
			self._id = v.id
		end
		widget.is_show:setVisible(self._id==v.id)
		if self._id==v.id then
			widget.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(onSelection_Icon))
		end

		self.scroll1:addItem(v.layer, true)
	end
	--if isTrue then
		for k,v in ipairs(shenbinguTb) do
			if self._id==v.id then
				self.scroll1:jumpToChildWithIndex(k)
				break
			end
		end
	--end
	self:talenRedPointState(self._id)
	self:SetUniqueSkillBtnState()
	self.unique_skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[self._id].entranceIcon))
	local isOpen,mastery,form = g_i3k_game_context:GetShenBingUniqueSkillData(self._id)
	mastery = mastery or 0
	local cfg = i3k_db_shen_bing[self._id]
	if mastery >= cfg.proficinecyMax and isOpen == 0 then
		self.c_xm.play()
	else
		self.c_xm.stop()
	end
	self:SetUniqueSkillBtnImg(self._id)
end

function wnd_shen_bing:updateRightUI(allShenbing , id,useShenbing)
	if self._id == useShenbing then
		self.equip_weapon_lable:setText("装备中")
		self.equip_weapon_btn:disableWithChildren()--disable()
	else
		self.equip_weapon_lable:setText("装备神兵")
		self.equip_weapon_btn:enableWithChildren()--enable()
	end
	if self._id == id then
		if allShenbing[id] then
			--self:SetShenbingUplvlData(id)
			self:onUpStarBtn(self.xiansuo_btn)
			self.xiansuo_btn:stateToPressed()
			self.xiansuo_btn:onClick(self, self.onUpStarBtn)
			self.xinasuo_label:setText("升星")
			self.tianfu_label:setText("天赋")
			self.desc_label:setText("升阶")
			self.awake_btn:setVisible(g_i3k_db.i3k_db_get_weapon_awake_is_show(id))--觉醒按钮显示
		
			self.desc_btn:stateToNormal()
			self.desc_btn:onClick(self, self.onUplvlBtn )

			self.talent_btn:setVisible(true)
			self.talent_btn:stateToNormal()
			self.talent_btn:onClick(self, self.onTalentBtn)

			self.awake_btn:stateToNormal()
			if g_i3k_game_context:GetLevel() < i3k_db_common.functionHide.shenbingshengjiHideLvl  then
				self.desc_btn:hide()
			else
				self.desc_btn:show()
			end
			if g_i3k_game_context:GetLevel() < i3k_db_common.functionHide.shenbingtianfuHideLvl  then
				self.talent_btn:hide()
			else
				self.talent_btn:show()
			end

		else
			self:SetOneXiansuoData()
			self.xiansuo_btn:stateToPressed()
			self.xiansuo_btn:onClick(self, self.onXiansuoBtn)
			self.xinasuo_label:setText("线索")
			--self.desc_label:setText("介绍")
			self.tianfu_label:setText("介绍")
			self.talent_btn:stateToNormal()
			self.talent_btn:show()
			self.talent_btn:onClick(self, self.onDescBtn)
			self.desc_btn:hide()
			self.awake_btn:hide()
		end
	end

end

function wnd_shen_bing:SetOneXiansuoData()
	local _layer = require(XIANSUO)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	self.xiansuo_btn:stateToPressed()
	self.talent_btn:stateToNormal()
	local itemid = i3k_db_shen_bing[self._id].itemid
	local itemCount = i3k_db_shen_bing[self._id].itemCount

	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	widgets.shenbing_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	widgets.shenbing_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	widgets.shenbing_btn:onClick(self, self.onItemInfo, itemid)
	widgets.shenbing_getway:setText(g_i3k_db.i3k_db_get_common_item_source(itemid))

	if haveCount >= itemCount then
		widgets.hecheng_btn2:enableWithChildren()--enable()------合成
		widgets.hecheng_btn2:onClick(self, self.onHechengBtn)
	else
		widgets.hecheng_btn2:disableWithChildren()--disable()
	end
	widgets.shenbing_count:setText(haveCount.."/"..itemCount)--(itemCount.."/"..haveCount)
	widgets.shenbing_count:setTextColor(g_i3k_get_cond_color(itemCount<=haveCount))
	widgets.shenbing_bg_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.equip_weapon_btn:hide()--隐藏中间按钮
	for i=1,4 do
		self.skill_btn[i]:hide()
		self.skill_bg[i]:hide()
		self.up_arrow[i]:hide()
	end
	self._layout.vars.recycle_btn:hide()
	self.property_btn:hide()
	self.battle_power:hide()
	self.battle_bg:hide()
	self:isCanSummon(self._id)
end

function wnd_shen_bing:SetShenbingUplvlData()
	if not g_i3k_game_context:IsHaveShenbing(self._id) then
		return
	end
	local _layer = require(SHENGJI)()
	self.widgets = _layer
	self:addNewNode(_layer)
	self.isShenBingUp = true
	self:updateShenbingUplvlDataItem()

end

function wnd_shen_bing:updateShenbingUplvlDataItem()-----------
	if not g_i3k_game_context:IsHaveShenbing(self._id) then
		return
	end
	if not self.isShenBingUp then
		return
	end
	-- self.xiansuo_btn:stateToPressed()
	-- self.xinasuo_label:setText("升阶")
	-- self.desc_label:setText("升星")
	-- self.desc_btn:stateToNormal()
	local id = self._id
	local level = g_i3k_game_context:GetShenBingQlvl(id)
	self.widgets.vars.level:setText("阶位")
	self.widgets.vars.value:setText(level)
	local exp = g_i3k_game_context:GetShenbingExp(id)
	local maxLevel = #i3k_db_shen_bing_uplvl[id]
	local needLevel = level == maxLevel and i3k_db_shen_bing_uplvl[id][level].needLevel or i3k_db_shen_bing_uplvl[id][level+1].needLevel
	if level == maxLevel then
		self:onSetShenbingMaxUpLvlData()
	else
		local need_level = g_i3k_make_color_string(string.format("%s级",needLevel), g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= needLevel))
		local str = string.format("角色达到%s可升阶",need_level)
		self.widgets.vars.needLevel:setText(str)
	end
	local need_exp = level == maxLevel and i3k_db_shen_bing_uplvl[id][level].exp or i3k_db_shen_bing_uplvl[id][level+1].exp
	local need_item = i3k_db_shen_bing_uplvl[id][level].itemid
	self.widgets.vars.exp_value:setText(exp.."/"..need_exp)
	self.widgets.vars.exp_slider:setPercent(exp/need_exp * 100)
	for i=1,6 do
		local temp_bg = "item"..i.."_bg"
		local temp_icon = "item"..i.."_icon"
		local temp_btn = "item"..i.."_btn"
		local temp_count = "item"..i.."_count"
		local tempcountBg = "count"..i.."Root"
		local tmpValue = "item"..i.."_value"
		self.widgets.vars[temp_bg]:setVisible(need_item[i]~=nil)
		self.widgets.vars[temp_count]:setVisible(need_item[i]~=nil)
		self.widgets.vars[tempcountBg]:setVisible(need_item[i]~=nil)
		if need_item[i] then
			local itemCount = g_i3k_game_context:GetCommonItemCount(need_item[i])
			local itemid = itemCount > 0 and need_item[i] or -need_item[i]
			--local itemid = need_item[i]
			local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
			local value = tmp_cfg.args1
			self.widgets.vars[temp_bg]:show()
			self.widgets.vars[temp_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			self.widgets.vars[temp_icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			self.widgets.vars[temp_count]:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemid))
			self.widgets.vars[tmpValue]:setText(value)

			self.widgets.vars[temp_btn]:onTouchEvent(self,self.onUseItem, {itemid = itemid,item = self.widgets})--长按按钮
		end
	end
	self.widgets.vars.akey_btn:onClick(self, self.onAkeyUse)
	self.widgets.vars.diamondup_btn:onClick(self, self.onDiamondUpTolvl)

end

function wnd_shen_bing:updateShenbingLvl(id, level, starlvl)----
	for k, v in pairs(self._shenbing) do
		if v.id == id then
			v.qlvl:setText(level)
			local index = starlvl + 1
			v.slvl_icon:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[index]))----改变星星
		end
	end
end

function wnd_shen_bing:onPropertyBtn(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_ShenBingPropertyTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingPropertyTips, self:getPropertyData())

	else
		if eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
			g_i3k_ui_mgr:CloseUI(eUIID_ShenBingPropertyTips)
		end
	end
end

function wnd_shen_bing:getPropertyData()
	local level = g_i3k_game_context:GetShenBingQlvl(self._id)
	local starlvl =  g_i3k_game_context:GetShenbingStarLvl(self._id)
	local grade = i3k_db_shen_bing_upstar[self._id][starlvl].grade
	local attack = 0
	local defense = 0
	local crit = 0
	local tou = 0
	local hp = 0
	for i=1,4 do
		local temp_attribute = "attribute"..i
		local temp_value = "value"..i
		local attribute = i3k_db_shen_bing_uplvl[self._id][level][temp_attribute]
		local value = i3k_db_shen_bing_uplvl[self._id][level][temp_value]
		local atr_star = i3k_db_shen_bing_upstar[self._id][starlvl][temp_attribute]
		local val_star = i3k_db_shen_bing_upstar[self._id][starlvl][temp_value]
		if attribute == SHENBING_ATTACK then
			attack = attack + value
		elseif attribute == SHENBING_DEFENSE then
			defense = defense + value
		elseif attribute == CRIT then
			crit = crit + value
		elseif attribute == TOUGHNESS then
			tou = tou + value
		elseif attribute == HP then
			hp = hp + value
		end
		if atr_star == SHENBING_ATTACK then
			attack = attack + val_star
		elseif atr_star == SHENBING_DEFENSE then
			defense = defense + val_star
		elseif atr_star == CRIT then
			crit = crit + val_star
		elseif atr_star == TOUGHNESS then
			tou = tou + val_star
		elseif atr_star == HP then
			hp = hp + value
		end
	end
	return {grade = grade, attack = attack, defense = defense, crit = crit, tou = tou, hp = hp}
end

function wnd_shen_bing:updateShenBingPower()
	if not g_i3k_game_context:IsHaveShenbing(self._id) then
		return
	end
	local data = self:getPropertyData()
	local prop_table = {
		[1001] = data.hp,
		[1015] = data.attack,
		[1016] = data.defense,
		[1006] = data.crit,
		[1007] = data.tou
	}
	local power = g_i3k_db.i3k_db_get_battle_power(prop_table)
	local falsePower = g_i3k_game_context:GetWeaponAddFightPower(self._id)
	local str = string.format("%s",power + falsePower)
	self.battle_power:setText(str)
	self:initQiling()
end

function wnd_shen_bing:setShenbingUpStarData()
	if not g_i3k_game_context:IsHaveShenbing(self._id) then
		return
	end
	-------------------------------------------------
	local _lvl = g_i3k_game_context:GetShenbingStarLvl(self._id)
	if not i3k_db_shen_bing_upstar[self._id][_lvl + 1] then          --判断当前神兵星级
		return
	end
	------------------------------------------------
	if not self.isShenBingStar then           --如果不处于神兵升星界面  直接返回
		return
	end
	------------------------------------------------
	local _layer = require(SHENGXING)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local starlvl =  g_i3k_game_context:GetShenbingStarLvl(self._id)
	widgets.upstar_btn:onClick(self, self.onShengxingBtn)
	self:updateShenbingLvl(self._id, g_i3k_game_context:GetShenBingQlvl(self._id), starlvl)
	local itemid = i3k_db_shen_bing_upstar[self._id][starlvl+1].itemid
	local needItemCount = i3k_db_shen_bing_upstar[self._id][starlvl+1].itemCount
	local itemGrade = g_i3k_db.i3k_db_get_common_item_rank(itemid)
	local haveItemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	widgets.item_bg_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	widgets.item_btn:onClick(self, self.onItemInfo, itemid)
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(itemGrade))
	widgets.item_count:setText(haveItemCount.."/"..needItemCount)--(needItemCount.."/"..haveItemCount)
	widgets.item_count:setTextColor(g_i3k_get_cond_color(needItemCount <= haveItemCount))

	local replaceItem = i3k_db_shen_bing_upstar[self._id][starlvl+1].replaceItem
	local replaceGrade = g_i3k_db.i3k_db_get_common_item_rank(replaceItem)
	local raplceCount = g_i3k_game_context:GetCommonItemCanUseCount(replaceItem)
	widgets.replaceItemBgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(replaceItem))
	widgets.replaceItem_btn:onClick(self, self.onItemInfo, replaceItem)
	widgets.replaceItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(replaceItem,i3k_game_context:IsFemaleRole()))
	widgets.replaceItem_name:setText(g_i3k_db.i3k_db_get_common_item_name(replaceItem))
	widgets.replaceItem_name:setTextColor(g_i3k_get_color_by_rank(replaceGrade))
	widgets.replaceItem_count:setText(raplceCount)
	widgets.replaceItem_count:setTextColor(g_i3k_get_cond_color(raplceCount>0))

	local attribute1id = i3k_db_shen_bing_upstar[self._id][starlvl].attribute1
	local attribute1Vlaue = i3k_db_shen_bing_upstar[self._id][starlvl].value1
	local attribute1VlaueN = i3k_db_shen_bing_upstar[self._id][starlvl+1].value1
	local attribute1Name = i3k_db_prop_id[attribute1id].desc
	local attribute1Colour = i3k_db_prop_id[attribute1id].textColor
	local value1Colour = i3k_db_prop_id[attribute1id].valuColor
	local attribute2id = i3k_db_shen_bing_upstar[self._id][starlvl].attribute2
	local attribute2Vlaue = i3k_db_shen_bing_upstar[self._id][starlvl].value2
	local attribute2VlaueN = i3k_db_shen_bing_upstar[self._id][starlvl+1].value2
	local attribute2Name = i3k_db_prop_id[attribute2id].desc
	local attribute2Colour = i3k_db_prop_id[attribute2id].textColor
	local value2Colour = i3k_db_prop_id[attribute2id].valuColor

	widgets.attribute1:setText(attribute1Name)
	--widgets.attribute1:setTextColor(attribute1Colour)
	widgets.value1:setText(attribute1Vlaue)
	--widgets.value1:setTextColor(value1Colour)
	widgets.nextValue1:setText(attribute1VlaueN)
	--widgets.nextValue1:setTextColor(value1Colour)

	widgets.attribute2:setText(attribute2Name)
	--widgets.attribute2:setTextColor(attribute2Colour)
	widgets.value2:setText(attribute2Vlaue)
	--widgets.value2:setTextColor(value2Colour)
	widgets.nextValue2:setText(attribute2VlaueN)
	--widgets.nextValue2:setTextColor(value2Colour)

	-- for i=1,4 do                                ----------------------------删掉了
	-- 	local temp = "skill"..i.."lvl"
	-- 	local now_lvl = i3k_db_shen_bing_upstar[self._id][starlvl][temp]
	-- 	local next_lvl = i3k_db_shen_bing_upstar[self._id][starlvl+1][temp]
	-- 	if now_lvl < next_lvl then
	-- 		local temp_skill = "skill"..i.."ID"
	-- 		local skillID = i3k_db_shen_bing[self._id][temp_skill]
	-- 		local tempskillName = i3k_db_skills[skillID].name
	-- 		tempskillName = "武功等级"
	-- 		widgets.skillName:setText(tempskillName)
	-- 		widgets.skillValue:setText(now_lvl.."级")
	-- 		widgets.skillNextValue:setText(next_lvl.."级")
	-- 		break
	-- 	end
	-- end
	self.battle_power:show()
	self:updateShenBingPower()
	local nowGrade = i3k_db_shen_bing_upstar[self._id][starlvl].grade
	local nextGrade = i3k_db_shen_bing_upstar[self._id][starlvl + 1].grade
	widgets.gradeRoot:setVisible(nowGrade < nextGrade)
	if nowGrade < nextGrade then
		widgets.gradeName:setText("神兵品级")
		widgets.gradeValue:setText(nowGrade)
		widgets.gradeNextValue:setText(nextGrade)
	end
	self:SetTotalAttribute()
	self:updateRightRedPoint(self._id)
end

function wnd_shen_bing:onSetShenbingMaxUpLvlData()
	local _layer = require(SHENBINGMAX)()
	local widgets = _layer.vars
	self:addNewNode(_layer)

	local lvl =  g_i3k_game_context:GetShenBingQlvl(self._id)
	self:updateShenbingLvl(self._id, lvl, g_i3k_game_context:GetShenbingStarLvl(self._id))
	local c_dd = self._layout.anis.c_dd
	c_dd.play()

	widgets.maxLvl:setImage(g_i3k_db.i3k_db_get_icon_path(MANJI))
	widgets.maxLvl_Decs:setImage(g_i3k_db.i3k_db_get_icon_path(MANJIJIACHENG))
	local attribute1 = i3k_db_shen_bing_uplvl[self._id][lvl].attribute1
	local attribute2 = i3k_db_shen_bing_uplvl[self._id][lvl].attribute2
	local attribute3 = i3k_db_shen_bing_uplvl[self._id][lvl].attribute3
	local attribute4 = i3k_db_shen_bing_uplvl[self._id][lvl].attribute4
	local value1 = i3k_db_shen_bing_uplvl[self._id][lvl].value1
	local value2 = i3k_db_shen_bing_uplvl[self._id][lvl].value2
	local value3 = i3k_db_shen_bing_uplvl[self._id][lvl].value3
	local value4 = i3k_db_shen_bing_uplvl[self._id][lvl].value4

	local attribute1Name = i3k_db_prop_id[attribute1].desc
	local attribute1Colour = i3k_db_prop_id[attribute1].textColor
	local value1Colour = i3k_db_prop_id[attribute1].valuColor
	local attribute2Name = i3k_db_prop_id[attribute2].desc
	local attribute2Colour = i3k_db_prop_id[attribute2].textColor
	local value2Colour = i3k_db_prop_id[attribute2].valuColor
	local attribute3Name = i3k_db_prop_id[attribute3].desc
	local attribute3Colour = i3k_db_prop_id[attribute3].textColor
	local value3Colour = i3k_db_prop_id[attribute3].valuColor
	local attribute4Name = i3k_db_prop_id[attribute4].desc
	local attribute4Colour = i3k_db_prop_id[attribute4].textColor
	local value4Colour = i3k_db_prop_id[attribute4].valuColor
	for i=3,7 do
		local temp1 = "attribute"..i
		local temp2 = "value"..i
		local attribute = widgets[temp1]
		local value = widgets[temp2]
		if i == 3 then
			attribute:setText(attribute1Name)
			-- attribute:setTextColor(attribute1Colour)
			value:setText(value1)
			-- value:setTextColor(value1Colour)
		elseif i == 4 then
			attribute:setText(attribute2Name)
			-- attribute:setTextColor(attribute2Colour)
			value:setText(value2)
			-- value:setTextColor(value2Colour)
		elseif i == 5 then
			attribute:setText(attribute3Name)
			-- attribute:setTextColor(attribute3Colour)
			value:setText(value3)
			-- value:setTextColor(value3Colour)
		elseif i == 6 then
			attribute:show()
			attribute:setText(attribute4Name)
			-- attribute:setTextColor(attribute4Colour)
			value:show()
			value:setText(value4)
			-- value:setTextColor(value4Colour)
		else
			attribute:hide()
			value:hide()
		end
	end
	self:SetTotalAttribute()
	self:updateShenBingPower()
end

function wnd_shen_bing:onSetShenbingMaxStarData()
	local _layer = require(SHENBINGMAX)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local starlvl =  g_i3k_game_context:GetShenbingStarLvl(self._id)
	self:updateShenbingLvl(self._id, g_i3k_game_context:GetShenBingQlvl(self._id), starlvl)
	local c_dd = self._layout.anis.c_dd
	c_dd.play()

	widgets.maxLvl:setImage(g_i3k_db.i3k_db_get_icon_path(MANXING))
	widgets.maxLvl_Decs:setImage(g_i3k_db.i3k_db_get_icon_path(MANXINGJIACHENG))

	local attribute1 = i3k_db_shen_bing_upstar[self._id][starlvl].attribute1
	local attribute2 = i3k_db_shen_bing_upstar[self._id][starlvl].attribute2
	local value1 = i3k_db_shen_bing_upstar[self._id][starlvl].value1
	local value2 = i3k_db_shen_bing_upstar[self._id][starlvl].value2
	local attribute1Name = i3k_db_prop_id[attribute1].desc

	local attribute2Name = i3k_db_prop_id[attribute2].desc
	local grade = i3k_db_shen_bing_upstar[self._id][starlvl].grade
	for i=3,7 do
		local temp1 = "attribute"..i
		local temp2 = "value"..i
		local attribute = widgets[temp1]
		local value = widgets[temp2]
		if i == 3 then
			attribute:setText(attribute1Name)
			value:setText(value1)
		elseif i == 4 then
			attribute:setText(attribute2Name)
			value:setText(value2)
		elseif i == 5 then
			attribute:setText("神兵品级")
			value:setText(grade)
		else
			attribute:hide()
			value:hide()
		end
	end
	self:SetTotalAttribute()
	self:updateShenBingPower()
end

function wnd_shen_bing:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_shen_bing:onUseShenbingBtn(sender)
	local hero = i3k_game_get_player_hero()
	if hero._superMode.valid then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(129))
		return
	end
	i3k_sbean.goto_weapon_select(self._id, i3k_db_shen_bing[self._id].showModuleID)--装备协议
end

function wnd_shen_bing:onHechengBtn(sender)
	i3k_sbean.goto_weapon_make(self._id,i3k_db_shen_bing[self._id].showModuleID)

end

function wnd_shen_bing:setCanUse(canUse)
	self._canUse = canUse
end

function wnd_shen_bing:onUseItem(sender, eventType, data)
	if eventType==ccui.TouchEventType.began then
		local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)
		local needLevel = i3k_db_shen_bing_uplvl[self._id][lvl+1].needLevel
		local now_exp = g_i3k_game_context:GetShenbingExp(self._id)
		local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(data.itemid)
		local exp = tmp_cfg.args1

		local need_exp = i3k_db_shen_bing_uplvl[self._id][lvl+1].exp
		if needLevel > g_i3k_game_context:GetLevel() and now_exp + exp >=  need_exp then
			g_i3k_ui_mgr:PopupTipMessage("您不满足升阶条件")
			return
		end
		local temp = {[data.itemid] = 1}
		local final_exp = 0
		local up_lvl = lvl
		if now_exp + exp >= need_exp then
			final_exp = now_exp + exp - need_exp
			up_lvl = up_lvl + 1
		else
			final_exp = now_exp + exp
		end
		local compare_lvl = {isUpLvl= false,before_lvl=0}
		if up_lvl ~= lvl then
			compare_lvl.isUpLvl = true
			compare_lvl.before_lvl = lvl
		end
		i3k_sbean.goto_weapon_levelup(self._id, temp, up_lvl, final_exp, compare_lvl, true)--升阶协议
		if g_i3k_game_context:GetCommonItemCanUseCount(data.itemid) <= 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(data.itemid)
		end
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
				if g_i3k_game_context:GetCommonItemCanUseCount(data.itemid) <= 0 then
					g_i3k_ui_mgr:PopupTipMessage("经验石不足，无法升阶")
					return false
				end
				local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)
				local needLevel = i3k_db_shen_bing_uplvl[self._id][lvl+1].needLevel
				local now_exp = g_i3k_game_context:GetShenbingExp(self._id)
				local tmp_cfg = g_i3k_db.i3k_db_get_common_item_cfg(data.itemid)
				local exp = tmp_cfg.args1

				local need_exp = i3k_db_shen_bing_uplvl[self._id][lvl+1].exp
				if needLevel > g_i3k_game_context:GetLevel() and now_exp + exp >=  need_exp then
					g_i3k_ui_mgr:PopupTipMessage("您不满足升阶条件")
					return
				end
				local temp = {[data.itemid] = 1}
				local final_exp = 0
				local up_lvl = lvl
				if now_exp + exp >= need_exp then
					final_exp = now_exp + exp - need_exp
					up_lvl = up_lvl + 1
				else
					final_exp = now_exp + exp
				end
				local compare_lvl = {isUpLvl= false,before_lvl=0}
				if up_lvl ~= lvl then
					compare_lvl.isUpLvl = true
					compare_lvl.before_lvl = lvl
				end
				i3k_sbean.goto_weapon_levelup(self._id, temp, up_lvl, final_exp, compare_lvl,true)--升阶协议
			end
		end)

	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end

end

function wnd_shen_bing:onAkeyUse(sender)    --一键使用
	if g_i3k_game_context:isEnoughUpWeaponlvl(self._id) then
		i3k_sbean.goto_weapon_levelup(self._id, g_i3k_game_context:isEnoughUpWeaponlvl(self._id))   --升阶协议
		local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
		local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
		self:SetModule(weaponModuleID, g_i3k_game_context:GetShenBingState(self._id))
	else
		g_i3k_ui_mgr:PopupTipMessage("您不满足升阶条件")
	end
end
function wnd_shen_bing:onDiamondUpTolvl(sender)
	self.isShenBingUp = false

	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)      --神兵的等级--加元宝判断
	if i3k_db_shen_bing_uplvl[self._id][lvl+1].needLevel > g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(330))
		return
	end
	self:onDiamondUp()
end
function wnd_shen_bing:onDiamondUp(sender)  --元宝升阶
	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)      --神兵的等级--加元宝判断
	local _layer = require(YUANBAOSHENGJI)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local x
	self.maxUp=1
	local maxLevel = #i3k_db_shen_bing_uplvl[self._id]
	for x=1,maxLevel do
		if i3k_db_shen_bing_uplvl[self._id][x].needLevel>g_i3k_game_context:GetLevel() then
			self.maxUp = x-1
			break
		end
	end
	local need_level = g_i3k_make_color_string(string.format("%s阶",self.maxUp), g_i3k_get_cond_color(true))
	local str = string.format("神兵可以升到%s",need_level)
	widgets.tipValue:setText(str)

	local nowdiamond = g_i3k_game_context:GetDiamondCanUse(true)
	self.diamond_count1 = i3k_db_shen_bing_uplvl[self._id][lvl + 1].diamond

	if nowdiamond < self.diamond_count1 then
		widgets.das:setText("消耗[<c=red>"..self.diamond_count1.."</c>]元宝，直接提升1阶")
		widgets.uplvl1:disableWithChildren()
	else
		widgets.das:setText("消耗[<c=green>"..self.diamond_count1.."</c>]元宝，直接提升1阶")
		widgets.uplvl1:enableWithChildren()
		widgets.uplvl1:onClick(self, self.onShengjiBtn1)
	end
	local nowlvl
	self.count = 0
	self.diamond_count5 =0
	self.count = self.maxUp - lvl >= 5 and 5 or self.maxUp - lvl
	local lvnow
	for lvnow = lvl+1, lvl+self.count do
		self.diamond_count5 = self.diamond_count5 + i3k_db_shen_bing_uplvl[self._id][lvnow].diamond
	end
	if nowdiamond < self.diamond_count5 then
		widgets.das2:setText("消耗[<c=red>"..self.diamond_count5.."</c>]元宝，直接提升" .. self.count .."阶")
		widgets.upname:setText("升" .. self.count .. "阶")
		widgets.uplvl5:disableWithChildren()
	else
		widgets.das2:setText("消耗[<c=green>"..self.diamond_count5.."</c>]元宝，直接提升" .. self.count .."阶")
		widgets.upname:setText("升" .. self.count .. "阶")
		widgets.uplvl5:enableWithChildren()
		widgets.uplvl5:onClick(self, self.onShengjiBtn5)
	end
	self.diamond_countm =0

	local lv
	for lv = lvl, self.maxUp-1 do
		self.diamond_countm = self.diamond_countm + i3k_db_shen_bing_uplvl[self._id][lv+1].diamond
	end
	if nowdiamond < self.diamond_countm then
		widgets.das3:setText("消耗[<c=red>"..self.diamond_countm.."</c>]元宝，升至最大阶别")
		widgets.uplvlm:disableWithChildren()
	else
		widgets.das3:setText("消耗[<c=green>"..self.diamond_countm.."</c>]元宝，升至最大阶别")
		widgets.uplvlm:enableWithChildren()
		widgets.uplvlm:onClick(self, self.onShengjiBtnm)
	end
	widgets.back_btn:onClick(self, self.backUI)
	local exp = g_i3k_game_context:GetShenbingExp(self._id)
	local level = g_i3k_game_context:GetShenBingQlvl(self._id)
	local maxLevel = #i3k_db_shen_bing_uplvl[self._id]
	local needLevel = level == maxLevel and i3k_db_shen_bing_uplvl[self._id][level].needLevel or i3k_db_shen_bing_uplvl[self._id][level+1].needLevel
	local need_exp = level == maxLevel and i3k_db_shen_bing_uplvl[self._id][level].exp or i3k_db_shen_bing_uplvl[self._id][level+1].exp
	widgets.level:setText("阶位")
	widgets.value:setText(level)

	widgets.exp_value:setText(exp.."/"..need_exp)
	widgets.exp_slider:setPercent(exp/need_exp * 100)
end

function wnd_shen_bing:backUI()
	self.isShenBingUp = true
	self:SetShenbingUplvlData(self._id)
end

function wnd_shen_bing:onShengjiBtn1(sender)
	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)--神兵的等级
	if i3k_db_shen_bing_uplvl[self._id][lvl+1].needLevel > g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage("您的等级不够")
		return
	else
		i3k_sbean.goto_weapon_buylevel(self._id, lvl+1, i3k_db_shen_bing[self._id].showModuleID)--买等级
		--g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingPropertyTips, self:getPropertyData())
		if lvl+1 == self.maxUp then
			g_i3k_ui_mgr:PopupTipMessage("恭喜您升到最大级别")
		else
			g_i3k_ui_mgr:PopupTipMessage("恭喜您成功提升1阶")
		end
	end
end

function wnd_shen_bing:onShengjiBtn5(sender)
	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)--神兵的等级
	local lvlnow = lvl + self.count - 1 --提升的等级
	if i3k_db_shen_bing_uplvl[self._id][lvlnow].needLevel>g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage("您的等级不够")
		return
	else
		i3k_sbean.goto_weapon_buylevel(self._id, lvl+self.count, i3k_db_shen_bing[self._id].showModuleID)--买等级
		if lvlnow + 1 == self.maxUp then
			g_i3k_ui_mgr:PopupTipMessage("恭喜您升到最大级别")
		else
			g_i3k_ui_mgr:PopupTipMessage("恭喜您成功提升" .. self.count .."阶")
		end
	end
end

function wnd_shen_bing:onShengjiBtnm(sender)
	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)--神兵的等级
	if i3k_db_shen_bing_uplvl[self._id][lvl].needLevel > g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage("您的等级不够")
		return
	else
		local lvevl = self.maxUp - lvl
		i3k_sbean.goto_weapon_buylevel(self._id, lvl+lvevl, i3k_db_shen_bing[self._id].showModuleID)--买等级
		g_i3k_ui_mgr:PopupTipMessage("恭喜您成功提升至最大阶位")
		self.isShenBingUp = true
	end
end

function wnd_shen_bing:onShengxingBtn(sender)
	local lvl = g_i3k_game_context:GetShenbingStarLvl(self._id)
	local cost_item_id = i3k_db_shen_bing_upstar[self._id][lvl+1].itemid
	local replace_item_id = i3k_db_shen_bing_upstar[self._id][lvl+1].replaceItem
	local cost_item_count = i3k_db_shen_bing_upstar[self._id][lvl+1].itemCount
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(cost_item_id)
	local replce_itemCount = g_i3k_game_context:GetCommonItemCanUseCount(replace_item_id)
	local altCount = haveCount >= cost_item_count and 0 or cost_item_count - haveCount
	local need_item = haveCount >= cost_item_count and cost_item_count or haveCount
	local useShenbing = g_i3k_game_context:GetShenbingData()
	if cost_item_count > haveCount + replce_itemCount then
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法升星")
	else
		local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
		local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
		i3k_sbean.goto_weapon_starup(self._id, lvl+1, need_item, altCount, weaponModuleID, useShenbing)-------升星协议
	end
end
function wnd_shen_bing:refreshShenbinBuyLevel()
	local old_layer = self.new_root:getAddChild()
	if old_layer[1].vars.back_btn then
		self:onDiamondUp()
	end
end
function wnd_shen_bing:onSelectBtnHave(sender, ID)
	self.isShenBingUp = true
	self.isShenBingStar = false
	self.isShenBingAwake = false
	local widget = nil
	local tag = 0
	for k, v in ipairs(self.shenbinguTb) do
		if v.id == ID then
			widget = v.layer.vars
			tag = k
			break
		end
	end
	local idNow = self._id
	self._id = self._shenbing[tag].id
	self.unique_skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[self._id].entranceIcon))
	self:updateSelectMark(tag)
	self.xiansuo_btn:stateToPressed()
	self.xiansuo_btn:onClick(self, self.onUpStarBtn)
	self.desc_btn:stateToNormal()
	self.desc_btn:onClick(self,self.onUplvlBtn)
	self.talent_btn:stateToNormal()
	self.talent_btn:onClick(self, self.onTalentBtn)
	--self:SetShenbingUplvlData(self._id)
	self:onUpStarBtn(self.xiansuo_btn)
	self.xinasuo_label:setText("升星")
	self.desc_label:setText("升阶")
	self.tianfu_label:setText("天赋")
	self.awake_btn:setVisible(g_i3k_db.i3k_db_get_weapon_awake_is_show(self._id))--觉醒按钮显示
	g_i3k_game_context:SetShenbingState(self._id ,g_WEAPON_STATE_UNLOCK)
	if idNow ~= self._shenbing[tag].id then
		local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
		local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
		self:SetModule(weaponModuleID, g_i3k_game_context:GetShenBingState(self._id))
	end
	if self._id == g_i3k_game_context:GetSelectWeapon() then
		self.equip_weapon_lable:setText("装备中")
		self.equip_weapon_btn:disableWithChildren()--disable()
	else
		self.equip_weapon_lable:setText("装备神兵")
		self.equip_weapon_btn:enableWithChildren()--enable()
	end
	self:SetShenBingUpSkillData(g_i3k_game_context:GetShenbingData())
	self:talenRedPointState(self._id)
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionHide.shenbingshengjiHideLvl  then
		self.desc_btn:hide()
	else
		self.desc_btn:show()
	end
	if g_i3k_game_context:GetLevel() < i3k_db_common.functionHide.shenbingtianfuHideLvl  then
		self.talent_btn:hide()
	else
		self.talent_btn:show()
	end
	local isOpen,mastery,form = g_i3k_game_context:GetShenBingUniqueSkillData(self._id)
	local cfg = i3k_db_shen_bing[self._id]
	mastery = mastery or 0
	if mastery >= cfg.proficinecyMax and isOpen == 0 then
		self.c_xm.play()
	else
		self.c_xm.stop()
	end
	self:SetUniqueSkillBtnImg(self._id)
	self:initQiling()
end

function wnd_shen_bing:onShenbingNohave(sender, needValue)
	self.isShenBingUp = true
	self.isShenBingStar = false
	self.isShenBingAwake = false
	self.c_xm.stop()
	local idNow = self._id
	self._id = self._shenbing[needValue.tag].id
	self.unique_skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[self._id].entranceIcon))
	self:isCanSummon(self._id)
	self:updateSelectMark(needValue.tag)
	--self:updateShowSelect(needValue.tag)
	--[[
	for k,v in pairs(self._shenbingnoget) do
		if v.id == needValue.id then

			self._shenbing[needValue.tag].xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(onSelection_Icon))

			for k,v in pairs(self._shenbingget) do
				v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(attained_Icon))
			end

		else

		  v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(unAttained_Icon))
		end

	end
	--]]
	self:SetOneXiansuoData()
	self.xiansuo_btn:stateToPressed()
	self.xiansuo_btn:onClick(self, self.onXiansuoBtn)
	self.talent_btn:stateToNormal()
	self.talent_btn:onClick(self, self.onDescBtn)
	self.xinasuo_label:setText("线索")
	self.tianfu_label:setText("介绍")
	self.talent_point:hide()
	self.red_point1:hide()
	self.awake_btn:hide()
	self.equip_weapon_lable:setText("装备神兵")
	self.equip_weapon_btn:enableWithChildren()--enable()
	if idNow ~= self._shenbing[needValue.tag].id then
		local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
		local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
		self:SetModule(weaponModuleID, g_i3k_game_context:GetShenBingState(self._id))
	end
	self.talent_btn:show()
	self.desc_btn:hide()
	self:SetUniqueSkillBtnImg(self._id)
	self:initQiling()
end

function wnd_shen_bing:updateShowSelect(tag)
	for k,v in pairs(self._shenbing) do
		v.is_show:setVisible(k==tag)
		----
		if k == tag then
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(onSelection_Icon))
		end
	end

end
function wnd_shen_bing:updateSelectMarkHide()
	for k,v in ipairs(self._shenbing) do
		local id = v.id
		v.is_show:hide()
		if g_i3k_game_context:IsHaveShenbing(id) then
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(attained_Icon))
		else
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(unAttained_Icon))
		end
	end
end

function wnd_shen_bing:updateSelectMark(tag)
	self:updateSelectMarkHide(tag)
	self:updateShowSelect(tag)
end

function wnd_shen_bing:onXiansuoBtn(sender)
	self.xiansuo_btn:stateToPressed()
	self.talent_btn:stateToNormal()
	self:SetOneXiansuoData()
end

function wnd_shen_bing:onDescBtn(sender)
	local _layer = require(JIESHAO)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	self.xiansuo_btn:stateToNormal()
	self.xiansuo_btn:onClick(self, self.SetOneXiansuoData)
	self.talent_btn:stateToPressed()
	self.awake_btn:stateToNormal()
	widgets.shenbing_desc:setText(i3k_db_shen_bing[self._id].desc)
end

function wnd_shen_bing:onUplvlBtn(sender)

	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionHide.shenbingshengjiHideLvl and g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.shenbingshengjiOpenLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(803,i3k_db_common.functionOpen.shenbingshengjiOpenLvl))
		return
	end
	self.isShenBingStar = false
	self.isShenBingUp   = true
	self.isShenBingAwake = false
	local lvl = g_i3k_game_context:GetShenBingQlvl(self._id)
	self.desc_btn:stateToPressed()
	self.xiansuo_btn:stateToNormal()
	self.talent_btn:stateToNormal()
	self.awake_btn:stateToNormal()
	if not i3k_db_shen_bing_uplvl[self._id][lvl+1] then
		self:onSetShenbingMaxUpLvlData()
	else
		self:SetShenbingUplvlData(self._id)
	end
	self:updateRightRedPoint(self._id)
	self:updateLeftRedPoint(self._id)
	self:SetShenBingUpSkillData(g_i3k_game_context:GetShenbingData())
end

function wnd_shen_bing:onUpStarBtn(sender)
	self.isShenBingStar = true
	self.isShenBingUp   = false
	self.isShenBingAwake = false
	local id = self._id
	self.battle_bg:show()
	self.battle_power:show()
	self.equip_weapon_btn:show()--显示中间按钮
	--self.equip_weapon_btn:enable()
	self.equip_weapon_btn:onClick(self, self.onUseShenbingBtn)
	for i=1,4 do
		local temp_res = "skill"..i.."ID"
		local skill = i3k_db_shen_bing[id][temp_res]
		local iconid = i3k_db_skills[skill].icon
		self.skill_btn[i]:show()
		self.skill_btn[i]:setImage(g_i3k_db.i3k_db_get_icon_path(iconid),g_i3k_db.i3k_db_get_icon_path(iconid))
		self.skill_btn[i]:setTag(i)
		self.skill_btn[i].skill = skill
		self.skill_btn[i]:onClick(self, self.onSkillBtn)
		--self.skill_btn[i]:onClick(self,self.onSkillBtn)
		self.skill_bg[i]:show()
	end
	self._layout.vars.recycle_btn:show()
	self.property_btn:show()
	self.property_btn:enable()
	self.property_btn:onTouchEvent(self, self.onPropertyBtn)

	-------------------------------------------------

	-------------------------------------------------
	self:updateShenBingPower()
	self:updateShenbingLvl(id, level, g_i3k_game_context:GetShenbingStarLvl(id))
	self:SetTotalAttribute()
	self:updateRightRedPoint(id)
	self:updateLeftRedPoint(id)
	self.desc_btn:stateToNormal()
	self.xiansuo_btn:stateToPressed()
	self.talent_btn:stateToNormal()
	self.awake_btn:stateToNormal()
	local lvl = g_i3k_game_context:GetShenbingStarLvl(self._id)
	if i3k_db_shen_bing_upstar[self._id][lvl + 1] then
		self:setShenbingUpStarData()
	else
		self:onSetShenbingMaxStarData()
	end

end

function wnd_shen_bing:updateRightRedPoint(id)
	local id = id or self._id
	self.red_point1:setVisible(g_i3k_game_context:isEnoughUpWeaponStar(id))--碎片满足就显示下
	if g_i3k_game_context:isEnoughUpWeaponlvl(id) then
		self.red_point2:show()
	else
		self.red_point2:hide()
	end
	self:UpdateAwakeRedPoint()--觉醒红点
end

function wnd_shen_bing:updateLeftRedPoint(id)
	local id = id or self._id
	for i, e in ipairs(self._shenbing) do
		local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
		local talentRedPoint = false
		if g_i3k_game_context then
			if g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.shenbingtianfuOpenLvl and g_i3k_game_context:IsShenBingCanInput(id) and not g_i3k_game_context:GetShenbingTalentRedPointRecord(id) then
				talentRedPoint = true
			end
		end

		if allShenbing[id] and id == e.id then
			if g_i3k_game_context:isEnoughUpWeaponlvl(id) or g_i3k_game_context:isEnoughUpWeaponStar(id) or talentRedPoint or g_i3k_game_context:GetShenBingUniqueRedPointState(id) or g_i3k_game_context:GetWeaponAwakeRed(id) then
				e.red_point:show()
			else
				e.red_point:hide()
			end
		end
	end
end

function wnd_shen_bing:updateIsUse()
	local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
	for k,v in pairs(self._shenbing) do
		v.is_select_icon:setVisible(v.id==useShenbing)
	end

end

function wnd_shen_bing:SetShenBingUpSkillData(IsHaveShenbing)
	if not next(IsHaveShenbing) then
		return
	end

	local upSkillData = g_i3k_game_context:GetShenBingUpSkillData()

	local shenbingId = self._id

	local allShenbing = g_i3k_game_context:GetShenbingData()
	if not allShenbing[self._id] then
		return
	end

	for i=1,4 do
		local shenbing_lvl = g_i3k_game_context:GetShenBingQlvl(shenbingId)
		local skill_lvl_now = upSkillData[shenbingId][i]
		if skill_lvl_now ~= #i3k_db_shen_bing_upskill[shenbingId][i] then
			local skill_lvl_next = skill_lvl_now + 1
			local id1 = i3k_db_shen_bing_upskill[shenbingId][i][skill_lvl_next].use_id1
			local count1 = i3k_db_shen_bing_upskill[shenbingId][i][skill_lvl_next].use_count1
			local bag_count1 = g_i3k_game_context:GetCommonItemCanUseCount(id1)
			local id2 = i3k_db_shen_bing_upskill[shenbingId][i][skill_lvl_next].use_id2
			local count2 = i3k_db_shen_bing_upskill[shenbingId][i][skill_lvl_next].use_count2
			local bag_count2 = g_i3k_game_context:GetCommonItemCanUseCount(id2)
			local upSkill_lvl = i3k_db_shen_bing_upskill[shenbingId][i][skill_lvl_next].upSkill_lvl
			if shenbing_lvl >= upSkill_lvl then
				if bag_count1 >= count1 then
					if id2 ~= 0 then
						if bag_count2 >= count2 then
							self.up_arrow[i]:show()
						else
							self.up_arrow[i]:hide()
						end
					else
						self.up_arrow[i]:show()
					end
				else
					self.up_arrow[i]:hide()
				end
			else
				self.up_arrow[i]:hide()
			end
		else
			self.up_arrow[i]:hide()
		end
	end
end

function wnd_shen_bing:onSkillBtn(sender)
	local upSkillData = g_i3k_game_context:GetShenBingUpSkillData()
	local tag = sender:getTag()
	local skillId = self.skill_btn[tag].skill

	if upSkillData[self._id][tag] == #i3k_db_shen_bing_upskill[self._id][tag] then
		g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_UpSkillMax)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_UpSkillMax,"refresh",self._id,tag,#i3k_db_shen_bing_upskill[self._id][tag],skillId)
	else
		if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.shenbingshengjiOpenLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongSkillTips)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuicongSkillTips,"refresh",skillId,nil,tag,i3k_get_string(812,i3k_db_common.functionOpen.shenbingshengjiOpenLvl))
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_UpSkill)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_UpSkill,"refresh",self._id,skillId,tag)
		end
	end
end


function wnd_shen_bing:onTalentBtn(sender)

	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionHide.shenbingtianfuHideLvl and g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.shenbingtianfuOpenLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(804,i3k_db_common.functionOpen.shenbingtianfuOpenLvl))
		return
	end

	self.isShenBingStar = false
	self.isShenBingUp   = false
	self.isShenBingAwake = false
	self.talent_btn:stateToPressed()
	self.xiansuo_btn:stateToNormal()
	self.desc_btn:stateToNormal()
	self.awake_btn:stateToNormal()
	g_i3k_game_context:SetShenbingTalentRedPointRecord(self._id,true)
	self.talent_point:hide()
	--self:refreshTalentLefrRedPoint(self._shenbing[self._id].widget)
	self:updateLeftRedPoint(self._id)
	self:updateRightRedPoint(self._id)
	self:setShenbingTalentData()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateWeaponNotice")
end

function wnd_shen_bing:stopAnimation()
	self.c_xm.stop()
end

function wnd_shen_bing:setShenbingTalentData()
	if not g_i3k_game_context:IsHaveShenbing(self._id) then
		return
	end

	local _layer = require(TIANFU)()
	local widgets = _layer.vars
	self:addNewNode(_layer)

	widgets.add_point_btn:onClick(self, self.onAddTalentPoint)

	local shenbing_surplus_talent_point = g_i3k_game_context:GetShenBingCanUseTalentPoint(self._id)
	widgets.surplus_talent_point:setText(tostring(shenbing_surplus_talent_point))

	local shenbing_talent_data = g_i3k_game_context:GetShenBingTalentData()

	local allPoint = g_i3k_game_context:GetShenBingAllTalentPoint(self._id)

	if allPoint > 0 then
		widgets.reset_btn:show()
		widgets.reset_btn:onClick(self, self.onResetBtn)
	else
		widgets.reset_btn:hide()
	end

	self.talentTbl = {}
	for i=1,5 do
		local talent_bg = string.format("item_bg_icon%s",i)
		local talent_icon = string.format("item_icon%s",i)
		local talent_btn = string.format("item_btn%s",i)
		local talent_name = string.format("item_name%s",i)
		local talent_count = string.format("item_count%s",i)
		local _talentTbl = {
		talent_bg = widgets[talent_bg],
		talent_icon = widgets[talent_icon],
		talent_btn = widgets[talent_btn],
		talent_name = widgets[talent_name],
		talent_count = widgets[talent_count]
	}
		table.insert(self.talentTbl , i , _talentTbl)
	end
	for i=1,5 do
		local havePoint = shenbing_talent_data[self._id][i]
		local maxPoint = i3k_db_shen_bing_talent[self._id][i].talentMaxPoint
		local NeedInputPoint = i3k_db_shen_bing_talent[self._id][i].NeedInputPoint
		self.talentTbl[i].talent_name:setText(i3k_db_shen_bing_talent[self._id][i].talentName)
		self.talentTbl[i].talent_count:setText(havePoint.."/"..maxPoint)
		self.talentTbl[i].talent_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_talent[self._id][i].talentIconId))
		--self.talentTbl[i].talent_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(i3k_db_shen_bing_talent[self._id][i].talentIconId))
		self.talentTbl[i].talent_btn:onClick(self,self.onTalentInfo,{shenbingId = self._id,talentIndex = i})
		if NeedInputPoint <= allPoint then
			self.talentTbl[i].talent_count:setTextColor(g_i3k_get_green_color())
		else
			self.talentTbl[i].talent_count:setTextColor(g_i3k_get_red_color())
		end
	end
	local haveBuyPoint = g_i3k_game_context:GetHaveBuyShenBingTalentPoint(self._id)
	if haveBuyPoint +  i3k_db_shen_bing_talent_init.init_talentPoint_counts[1] == #i3k_db_shen_bing_talent_buy[self._id] then
		widgets.add_point_btn:hide()
	else
		widgets.add_point_btn:show()
		widgets.add_point_btn:onClick(self,self.onAddTalentPoint)
	end
end

function wnd_shen_bing:onTalentInfo(sender,refreshData)
	local shenbingId = refreshData.shenbingId
	local talentIndex = refreshData.talentIndex
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_Talent_Info)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_Talent_Info,shenbingId,talentIndex)
end

function wnd_shen_bing:onResetBtn()
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_Talent_Reset)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_Talent_Reset,self._id)
end

function wnd_shen_bing:onAddTalentPoint()
	local haveBuyPoint = g_i3k_game_context:GetHaveBuyShenBingTalentPoint(self._id)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_Talent_Buy)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_Talent_Buy,self._id,haveBuyPoint)
end

function wnd_shen_bing:talenRedPointState(shenbingId)
	local canUsePoint = g_i3k_game_context:GetShenBingCanUseTalentPoint(shenbingId)
	local state =  g_i3k_game_context:GetShenbingTalentRedPointRecord(shenbingId)
	if canUsePoint > 0 and not state and g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.shenbingtianfuOpenLvl then
		self.talent_point:show()
	else
		self.talent_point:hide()
	end
end

function wnd_shen_bing:refreshTalentLefrRedPoint(widget)
	local id = self._id
	local talentRedPoint = false
	if g_i3k_game_context then
		if g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.shenbingtianfuOpenLvl and g_i3k_game_context:IsShenBingCanInput(id) and not g_i3k_game_context:GetShenbingTalentRedPointRecord(id) then
			talentRedPoint = true
		end
	end

	if g_i3k_game_context:isEnoughUpWeaponlvl(id) or g_i3k_game_context:isEnoughUpWeaponStar(id) or talentRedPoint then
		widget.red_point:show()
	else
		widget.red_point:hide()
	end
end


--------------------------
--神兵绝技
function wnd_shen_bing:openUiqueSkillUI(sender)
	local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
	if i3k_db_shen_bing[self._id].isOpenUniqueSkill == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_UniqueSkill)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UniqueSkill,self._id)
	else
		g_i3k_ui_mgr:PopupTipMessage("【"..i3k_db_shen_bing[self._id].uniqueSkillName.."】系统即将开放，敬请期待")
	end
end

function wnd_shen_bing:SetUniqueSkillBtnState()
	self.unique_skill_btn:onClick(self,self.openUiqueSkillUI)
end

--为已激活特技的按钮更换底图
function wnd_shen_bing:SetUniqueSkillBtnImg(id)
	local isOpen = g_i3k_game_context:GetShenBingUniqueSkillData(id)
	local iconID = (isOpen and isOpen ~= 0) and 7257 or 7256
	self.unique_skill_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(iconID))
end

function wnd_shen_bing:SetUpAndStar()
	self.isShenBingStar = false
	self.isShenBingUp   = false
	self.isShenBingAwake = false
	self.equip_weapon_lable:setText("装备中")
	self.equip_weapon_btn:disableWithChildren()--disable()
end

function wnd_shen_bing:openCommentUI()
	if g_i3k_game_context:GetLevel() < i3k_db_common.evaluation.openLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15405, i3k_db_common.evaluation.openLvl))
	end
	i3k_sbean.socialmsg_pageinfoReq(2, self._id, 1, 1, i3k_db_common.evaluation.showItemCount)
end

--进入碎片回收界面
function wnd_shen_bing:onRecycle(sender)
	if g_i3k_game_context:GetShenBingAllTalentPoint(self._id) and g_i3k_game_context:isMaxWeaponStar(self._id) then
		local upstar_cfg = i3k_db_shen_bing_upstar[self._id]
		local itemId = upstar_cfg[1].itemid
		i3k_sbean.openDebrisRecycle(itemId, g_DEBRIS_SHENBIN)
	else
	    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16135))
	end
end

function wnd_shen_bing:onQilingBtn(sender)
	g_i3k_logic:openQilingUI(self._id)
end


-------------神兵觉醒-------------
function wnd_shen_bing:onAwakeBtnClick(sender)--神兵觉醒页签 
	g_i3k_logic:OpenShenBingAwakeUI(self._id)
end

function wnd_shen_bing:RefreshAwakeUI(id)
	self.isShenBingAwake = true
	self.isShenBingStar = false
	self.isShenBingUp = false
	self.awake_btn:stateToPressed()
	self.desc_btn:stateToNormal()
	self.xiansuo_btn:stateToNormal()
	self.talent_btn:stateToNormal()
	local layer = require(JUEXING)()
	local widget = layer.vars
	self.awake_widget = widget
	self.awakeFlag = widget.flag
	self:addNewNode(layer)
	local isAwake = g_i3k_game_context:IsShenBingAwake(id)
	widget.awakeRoot:setVisible(not isAwake)
	widget.descRoot:setVisible(isAwake)
	self:SetAwakeModule(widget.module, id)
	self:updateRightRedPoint(id)
	if not isAwake then
		local cfg = i3k_db_shen_bing_awake[self._id]
		widget.item_quality:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.needItemID))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemID,i3k_game_context:IsFemaleRole()))
		widget.name:setText(g_i3k_db.i3k_db_get_common_item_name(cfg.needItemID))
		widget.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(cfg.needItemID)))
		widget.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemID) .."/".. (cfg.needItemCount))
		widget.count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemID) >= cfg.needItemCount))
		widget.conditionDes:setText(i3k_get_string(5355, g_i3k_game_context:GetShenBingQlvl(self._id), (cfg.needLvl)))
		widget.conditionDes:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetShenBingQlvl(self._id) >= cfg.needLvl))
		widget.item_btn:onClick(self,function()
			g_i3k_ui_mgr:ShowCommonItemInfo(cfg.needItemID)
		end)
		widget.awake_btn:onClick(self,function()
			local cfg = i3k_db_shen_bing_awake[id]
			if g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemID) >= cfg.needItemCount then
				if g_i3k_game_context:GetShenBingQlvl(self._id) >= cfg.needLvl then
					i3k_sbean.weapon_awake(id)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5354))
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5343))
			end
		end)
		widget.browse_btn:onClick(self,function()
			g_i3k_ui_mgr:OpenUI(eUIID_ShenBingBingHun)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingBingHun, id, true)
		end)
	else
		widget.flag:setVisible(g_i3k_game_context:GetShenBingForm(self._id) == g_WEAPON_FORM_AWAKE)
		widget.red:setVisible(self._layout.vars.awake_red:isVisible())
		widget.binghun_btn:onClick(self, self.onBingHunBtnClick)
		widget.shenyao_btn:onClick(self, self.onShenYaoBtnClick)
		widget.useAwakeBtn:onClick(self, self.onUseAwakeBtnClick)
	end
	self:updateLeftRedPoint(self._id)
	self:updateRightRedPoint(self._id)
end

function wnd_shen_bing:UpdateAwakeConsume()
	if self.isShenBingAwake then--只有在这个界面的时候才刷新
		local cfg = i3k_db_shen_bing_awake[self._id]
		local count = g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemID)
		self.awake_widget.count:setText(count .."/".. (cfg.needItemCount))
		self.awake_widget.count:setTextColor(g_i3k_get_cond_color(count >= cfg.needItemCount))
	end
end

function wnd_shen_bing:SetAwakeModule(moduleUI, id)
	local cfg = i3k_db_shen_bing_awake[id]
	local isFemale = g_i3k_game_context:IsFemaleRole()
	local modleID = isFemale and cfg.awakeModleFemale or cfg.awakeModleMale
	ui_set_hero_model(moduleUI, modleID)
	moduleUI:pushActionList(i3k_db_shen_bing_others.awakeShowAction, -1)
	moduleUI:playActionList()
end

function wnd_shen_bing:UpdateAwakeRedPoint()
	local widgets = self._layout.vars
	local awake_btn = widgets.awake_btn
	local awake_red = widgets.awake_red
	if awake_btn:isVisible() then
		awake_red:setVisible(g_i3k_game_context:GetWeaponAwakeRed(self._id))
	end
end

function wnd_shen_bing:onBingHunBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBingBingHun)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingBingHun, self._id, false)
end

function wnd_shen_bing:onShenYaoBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBingShenYao)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingShenYao, self._id)
end

function wnd_shen_bing:onUseAwakeBtnClick(sender)
	if g_i3k_game_context:GetShenBingForm(self._id) == g_WEAPON_FORM_AWAKE then
		i3k_sbean.weapon_setform(self._id, g_WEAPON_FORM_NORMAL)
	else
		i3k_sbean.weapon_setform(self._id, g_WEAPON_FORM_AWAKE)
	end
end
function wnd_shen_bing:onShenBingAwakeSuccess(weaponID) --神兵觉醒成功回调
	self:RefreshAwakeUI(weaponID) --刷新觉醒界面
	for i,v in ipairs(self.shenbinguTb) do --更新觉醒后的图片
		local widget = v.layer.vars
		local isAwake = g_i3k_game_context:IsShenBingAwake(v.id)
		local awakeCfg = i3k_db_shen_bing_awake[v.id]
		local icon = isAwake and awakeCfg.awakeWeaponIcon or i3k_db_shen_bing[v.id].icon
		local iconBg = isAwake and awakeCfg.awakeBackground or 0
		widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		widget.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(iconBg))
	end
end

function wnd_shen_bing:onChangeShenBingForm() --神兵形态切换
	if self.awakeFlag and self.isShenBingAwake then
		self.awakeFlag:setVisible(g_i3k_game_context:GetShenBingForm(self._id) == g_WEAPON_FORM_AWAKE)
		local weaponForm = g_i3k_game_context:GetShenBingForm(self._id)
		local weaponModuleID = weaponForm == g_WEAPON_FORM_AWAKE and i3k_db_shen_bing_awake[self._id].awakeWeaponModle or i3k_db_shen_bing[self._id].showModuleID
		self:SetModule(weaponModuleID, g_i3k_game_context:GetShenBingState(self._id))---
	end
end
function wnd_shen_bing:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self.co)
end
-----------------------------------
function wnd_create(layout)
	local wnd = wnd_shen_bing.new()
	wnd:create(layout)
	return wnd
end
