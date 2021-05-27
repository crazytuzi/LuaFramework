local View = BaseClass(SubView)

View.AlreadyCanGetEquipNum = ItemData.ItemType.itHeroEquipMax - ItemData.ItemType.itHeroCuff	--战将已经能获取的装备数

function View:__init(view_def, data_model)
	self:SetModal(true)
	self.def_index = TabIndex.zhanjiang_zhanjiang

	self.texture_path_list[1] = "res/xui/zhanjiang.png"
	self.texture_path_list[2] = "res/xui/role.png"
	self.texture_path_list[3] = "res/xui/wing.png"

	self.config_tab = {
		{"zhanjiang_ui_cfg", 1, {TabIndex.zhanjiang_zhanjiang}},
	}

	self.data = data_model

	self.door = DoorModal.New()
	self.door:BindClickActBtnFunc(BindTool.Bind(self.OnActivateClicked, self))
end

function View:LoadCallBack()
	self.hero_model = nil
	self.cell_list = nil
	self.zhanjiang_attr_list = nil
	self.futi_attr_list = nil
	self.confirmDlg = nil
	
	self:CreateHeroModel()
	-- self:CreateEquipCells()
	self:CreateZhanjiangAttrList()
	self:CreateFutiAttrList()
	self:CreateConfirmDlg()
	self:CreateHeroEquip()

	self.skill_view = self:CreateSkillView()

	-- for i,v in ipairs(HeroConfig.soulRangCfg) do
	-- 	self["hunhuan_eff_" .. i] = RenderUnit.CreateEffect(v.modelid, self.node_t_list.layout_zhanjiang.node, 10, nil, nil, 145, 43)
	-- end

	self.stars_ui = UiInstanceMgr.Instance:CreateStarsUi({x = self.ph_list.ph_star.x, y = self.ph_list.ph_star.y, interval_x = 3,
		star_num = 10, parent = self.node_t_list.layout_zhanjiang.node, zorder = 10,})

	-- self.txt_get_material = RichTextUtil.CreateLinkText(Language.Zhanjiang.ObtainUpdateMaterial, 20, COLOR3B.GREEN)
	-- self.txt_get_material:setPosition(750, 170)
	-- self.node_t_list.layout_zhanjiang.node:addChild(self.txt_get_material, 100)

	if not self.data:IsActivatedSucc() then
		if not self.btn_activate then
			self.btn_activate = XUI.CreateButton(269, 356, 112, 115, false, ResPath.GetCommon("btn_activate"), nil, nil, true)
			self.btn_activate:setVisible(false)
			self.node_t_list.layout_zhanjiang.node:addChild(self.btn_activate, 100, 100)
			--激活按钮加特效
			-- local act_eff = RenderUnit.CreateEffect(900, self.btn_activate, 10, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			-- act_eff:setScale(1.2)
			XUI.AddClickEventListener(self.btn_activate, BindTool.Bind(self.OnActivateClicked, self), true)
		end
	end
	self:SetTextUiAttrs()

	self.node_t_list.img_flag_1.node:setVisible(false)
	-- self.node_t_list.img_flag_2.node:setVisible(false)

	XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_is_fight.node, BindTool.Bind(self.OnClickBtnFightCallBack, self))
	-- XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_help.node, BindTool.Bind(self.OnClickBtnHelpCallBack, self))
	XUI.AddClickEventListener(self.node_t_list.layout_zhanjiang.btn_begin_uplv.node, BindTool.Bind(self.OnClickBtnUpLvCallBack, self))
	XUI.AddRemingTip(self.node_t_list.layout_zhanjiang.btn_begin_uplv.node, function ()
		return self.data:GetCanUp()
	end)
	self.node_t_list.layout_zhanjiang.btn_begin_uplv.node.UpdateReimd()

	EventProxy.New(self.data, self):AddEventListener(self.data.DATA_CHANGE, BindTool.Bind(self.OnHeroInfoChange, self))
	EventProxy.New(self.data, self):AddEventListener(self.data.HERO_STATE_CHANGE, BindTool.Bind(self.OnHeroStateChange, self))
	EventProxy.New(self.data, self):AddEventListener(self.data.SKILL_CHANGE, BindTool.Bind(self.OnHeroSkillChange, self))
	EventProxy.New(self.data, self):AddEventListener(self.data.OPEAT_CALLBACK, BindTool.Bind(self.OnOperateSucces, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, function (vo)
		if vo.key == OBJ_ATTR.ACTOR_COIN or vo.key == OBJ_ATTR.ACTOR_BIND_COIN then
			self.node_t_list.layout_zhanjiang.btn_begin_uplv.node.UpdateReimd()
		end
	end)
end

--装备视图
local slot2type = {
	[1] = ItemData.ItemType.itHeroCuff,
	[2] = ItemData.ItemType.itHeroNecklace,
	[3] = ItemData.ItemType.itHeroDecorations,
	[4] = ItemData.ItemType.itHeroArmor,
}

local type2slot = {
	[ItemData.ItemType.itHeroCuff] = 1 ,
	[ItemData.ItemType.itHeroNecklace] = 2 ,
	[ItemData.ItemType.itHeroDecorations] = 3 ,
	[ItemData.ItemType.itHeroArmor] = 4 ,
}

function View:CreateHeroEquip()
	if self.eq_view then return end

	self.eq_view = {}
	self.node_t_list.layout_eq.node:setVisible(false)

	--内置数据
	local cell_list = {}

	local on_click_cell = function (slot) 
		local data_t = self.data:GetOwnedEquipList()
		local best_data = BagData.Instance:GetBestEqByType(slot2type[slot], data_t[slot])
		if nil == best_data then 
			if nil ~= data_t[slot] then
				TipCtrl.Instance:OpenItem(data_t[slot], EquipTip.FROM_HERO_EQUIP)
			else
				ViewManager:OpenViewByDef(ViewDef.MainGodEquipView.ReXueFuzhuang.ZhanChongShenHZuang)
				ViewManager.Instance:FlushViewByDef(ViewDef.MainGodEquipView, 0, "tabbar_change", {index =2, child_index =2})
			end
		else
			ZhanjiangCtrl.HeroPutOnEquipReq(best_data.series)
		end

	end

	local flush_eq_list = function ()
		local data_t = self.data:GetOwnedEquipList()	
		for i,v in ipairs(cell_list) do
			v:SetData(data_t[i])
			v:GetView():UpdateReimd()
			self.node_t_list["img_add_" .. i].node:setVisible(nil == (data_t[i] and next(data_t[i])))
		end
	end

	--外部调用
	self.eq_view.DeleteMe = function ()
		for i,v in ipairs(cell_list) do
			v:DeleteMe()
		end
	end

	self.eq_view.CheckShow = function ()
		if self.node_t_list.layout_eq.node:isVisible() then return end
		local is_show = ZhanjiangCtrl.GetPetEquipIsOpen()
		self.node_t_list.layout_eq.node:setVisible(is_show)
	end


	-- 监听数据变化
	EventProxy.New(self.data, self):AddEventListener(self.data.EQ_CHANGE, function ()
		flush_eq_list()
	end)

	-- 初始化
	self.eq_view.CheckShow()

	-- 创建UI
	for i = 1, 4 do
		local x, y = self.node_t_list.layout_eq["eq_cell_" .. i].node:getPosition()
		local cell = BaseCell.New()
		cell:SetPosition(x, y)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetCellBgVis(false)
		cell:SetCellBg()
		cell:SetIsShowTips(false)
		cell:SetClickCallBack(function ()
			on_click_cell(i)
		end)
		self.node_t_list.layout_eq.node:addChild(cell:GetView(), 103)
		cell_list[i] = cell

		XUI.AddRemingTip(cell:GetView(), function ()
			local data_t = self.data:GetOwnedEquipList()
			local best_data = BagData.Instance:GetBestEqByType(slot2type[i], data_t[i])
			return nil ~= best_data
		end)
	end

	-- 初始化显示
	flush_eq_list()
end

function View:OnOperateSucces(vo)
	if vo.opeat_type == "level_succes" then
		for i,v in ipairs(self.zhanjiang_attr_list:GetAllItems()) do
			v:ShowFlash()
		end
		for i,v in ipairs(self.futi_attr_list:GetAllItems()) do
			v:ShowFlash()
		end
		self:PlayShowEffect(1174, 270, 150)
	elseif vo.opeat_type == "activ_succes" then
		self:PlayShowEffect(901, 350, 300)
		self.door:OpenTheDoor()
	end
end

------------------------------
-- 激活

function View:FlushDoor()
	local show_door = false
	-- show_door = self.data.info_t.level and self.data.info_t.level > 0
	if nil == self.data.info_t.level then  --打开战宠面板，如果未激活再发一次激活协议过去
		ZhanjiangCtrl.HeroActivateReq(self.data:GetHeroType())
		show_door = true
	end
	self.door:SetVis(show_door, self.node_t_list.layout_zhanjiang.node)

	if show_door then
		self.door:GetView():setPosition(936 / 2, 650 / 2)
		self.door:CloseTheDoor()
	end
end

function View:OnHeroStateChange()
	local name = "icon_fight"
	local hero_state = self.data:GetHeroState()
	local is_activated = self.data:IsActivatedSucc()
	if hero_state == HERO_STATE.SHOW then
		name = "icon_relax"
	end

	self.node_t_list["btn_is_fight"].node:loadTexture(ResPath.GetZhangjiang(name))
	XUI.SetButtonEnabled(self.node_t_list.btn_is_fight.node, is_activated)
end

function View:OnHeroInfoChange()
	self:OnHeroStateChange()
	local is_activated = self.data:IsActivatedSucc()
	if self.btn_activate then
		self.btn_activate:setVisible(not is_activated)
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_is_fight.node, is_activated)
	XUI.SetButtonEnabled(self.node_t_list.btn_begin_uplv.node, is_activated)
	self:OnFlushView()

	self.eq_view.CheckShow()
end

function View:CreateSkillView()
	local view = {}

	local data_t = self.data:GetSkillList()
	for k = 1, 3 do
		local index = k
		XUI.AddClickEventListener(self.node_t_list["skill_" .. k].node, function ()
			if nil == data_t[index] then return end
			local item_id = data_t[index].item_id

			-- if data_t[k].is_not_active then
			-- 	ViewManager:OpenViewByDef(ViewDef.HunHuan)
			-- else
				local data_form = EquipTip.FROM_ZHANGCHONG
				if BagData.Instance:GetItemNumInBagById(item_id) >= 1 then
					data_form = EquipTip.FROM_BAG
				end
				TipCtrl.Instance:OpenItem(BagData.Instance:GetItem(item_id) or {item_id = item_id}, data_form)
			-- end
		end)

		local path = nil == data_t[k].icon_id and ResPath.GetZhangjiang("img_lock") or ResPath.GetZhangjiang(data_t[k].icon_id)
		self.node_t_list["skill_" .. index].node:loadTexture(path)
	end

	view.UpdateView = function ()
		local data_t = self.data:GetSkillList()
		for k = 1, 3 do
			local index = k
			self.node_t_list["skill_" .. index].node:setGrey(data_t[k] and data_t[k].is_not_active)
		end
	end

	return view
end

function View:OnHeroSkillChange()
	self.skill_view.UpdateView()
end

function View:ReleaseCallBack()
	if nil ~= self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
	if nil ~= self.zhanjiang_attr_list then
		self.zhanjiang_attr_list:DeleteMe()
		self.zhanjiang_attr_list = nil
	end
	if nil ~= self.futi_attr_list then
		self.futi_attr_list:DeleteMe()
		self.futi_attr_list = nil
	end
	if nil ~= self.confirmDlg then
		self.confirmDlg:DeleteMe()
		self.confirmDlg = nil
	end

	if nil ~= self.eq_view then
		self.eq_view:DeleteMe()
		self.eq_view = nil
	end

	self.zhu_up_add = nil
	self.fu_up_add = nil
	self.btn_activate = nil
	self.layout_wing_auto_hook = nil
	self.play_eff = nil
	self.btn_ronghun = nil
	self.stars_ui = nil
	-- self.data = nil

	self.door:Release()
end

function View:SetTextUiAttrs()
	-- self.node_t_list.lbl_zhanjiang_attr.node:setLocalZOrder(999)
	-- self.node_t_list.img_title_bg.node:setLocalZOrder(998)
	-- XUI.EnableOutline(self.node_t_list.lbl_zhanjiang_attr.node, c4b, size)
	XUI.RichTextSetCenter(self.node_t_list.rich_zhanjiang_consume.node)
end

function View:ShowIndexCallBack()
	self:Flush()
	self:FlushDoor()
end

function View:OnFlush(param_t)
	local is_activated = self.data:IsActivatedSucc()
	if self.btn_activate then
		self.btn_activate:setVisible(not is_activated)
	end
	XUI.SetButtonEnabled(self.node_t_list.btn_is_fight.node, is_activated)
	XUI.SetButtonEnabled(self.node_t_list.btn_begin_uplv.node, is_activated)
	self:OnFlushView()
	self:OnHeroSkillChange()
	self:OnHeroInfoChange()
end

function View:FlushBtnRemind()
	local remind_num = self.data:GetHeroRemindNum()
	self.node_t_list.img_flag_1.node:setVisible( remind_num > 0 )
	-- self.node_t_list.img_flag_2.node:setVisible( remind_num > 0 )
end

--战将信息刷新
function View:OnFlushView()
	-- local zhu_data, fu_data = self.data:GetHeroAttrData()		--战将主/附体属性
	-- if self.zhu_up_add then
	-- 	for k_1,v_1 in pairs(self.zhu_up_add) do
	-- 		for k_2, v_2 in pairs(zhu_data) do
	-- 			if v_1.type == v_2.type then
	-- 				v_2.add_value = v_1.value_str
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- if self.fu_up_add then
	-- 	for k_1,v_1 in pairs(self.fu_up_add) do
	-- 		for k_2,v_2 in pairs(fu_data) do
	-- 			if v_1.type == v_2.type then
	-- 				v_2.add_value = v_1.value_str
	-- 			end
	-- 		end
	-- 	end
	-- end

	self.zhanjiang_attr_list:SetDataList(self.data:GetHeroAttrStr())
	self.zhanjiang_attr_list:JumpToTop(true)

	self.node_t_list.layout_role_attr.node:setVisible(nil ~= next(self.data:GetRoleAttrStr()))
	self.futi_attr_list:SetDataList(self.data:GetRoleAttrStr())
	self.futi_attr_list:JumpToTop(true)

	-- local name = self.data:GetOtherInfoList().name
	-- self.node_t_list.lbl_zhanjiang_attr.node:setString(self.data:GetTitleAttrStr())
	self:ShowHeroModel()
	self:FlushConsumeView()
	-- self:FlushEquipCells()

	self.stars_ui:SetStarActNum(self.data:GetPart())
	self.node_t_list.img_jie.node:loadTexture(ResPath.GetZhangjiang("level_" .. self.data:GetJie()))
	-- self.stars_ui:GetView():setVisible(nil ~= equip_data)

	
end

--显示英雄形象
function View:ShowHeroModel()
	local model_data = self.data:GetHeroModelIdData()
	self.hero_model:SetMonsterVo(model_data)
	if not self.data:IsHaveHunHuan() and self.data:GetIsZhanChong() then
		self.hero_model:SetDirLeft()
	else
		self.hero_model:SetDirDown()
	end
end

function View:ClearNextLvAddData()
	self.zhu_up_add = nil
	self.fu_up_add = nil
	self:Flush(self:GetShowIndex(), "zhanjiang")
end

function View:FlushEquipCells()
	local owned_equip = self.data:GetOwnedEquipList()
	for k, v in pairs(self.cell_list) do
		v:SetData(owned_equip[k])
		v:SetRemind(nil ~= self.data:GetMaxEquipByType(v.equip_type), true)
	end
end

--自动 xxx -- 取消自动 切换
function View:FlushAutoXxxBtn()
	local text = nil
	text = Language.Zhanjiang.AutoUpgrade
	if self.is_auto_upgrade and self.data:IsUpHeroLvSucc() then 
		text = Language.Zhanjiang.CancelAuto 
	end
	self.node_t_list["btn_auto_uplv"].node:setTitleText(text)
end

function View:FlushConsumeView()
	self.node_t_list.layout_consum.node:setVisible(not self.data:IsMaxLevel())
	local text = GameMath.GetStringShowMoneynum2(self.data:GetHeroUpgradeConsum())
	self.node_t_list.lbl_consum.node:setString(text)
	self.node_t_list.rich_zhanjiang_consume.node:setVisible(self.data:IsMaxLevel())
	RichTextUtil.ParseRichText(self.node_t_list.rich_zhanjiang_consume.node,  Language.Common.AlreadyTopLv, 22)
end

-- 播放特效
function View:PlayShowEffect(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list["layout_zhanjiang"].node:addChild(self.play_eff, 2)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

--创建延迟请求定时器
function View:BuildReqSendTimer()
	if not self.send_req_timer then
		self.send_req_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnClickBtnUpLvCallBack, self), 0.25)
	end
end

--取消延迟定时器
function View:CancelReqSendTimer()
	if self.send_req_timer then
		GlobalTimerQuest:CancelQuest(self.send_req_timer)
		self.send_req_timer = nil
	end
end

function View:OnClickBtnFightCallBack()
	local hero_state = self.data:GetHeroState()
	self.data:SetHeroStateReq(hero_state == HERO_STATE.REST and HERO_STATE.SHOW or HERO_STATE.REST)
	if hero_state == HERO_STATE.SHOW then
		SettingCtrl.Instance:ChangeGuaJiSetting({[GUAJI_SETTING_TYPE.AUTO_CALL_HERO] = false})
	end
end

function View:OnClickBtnHelpCallBack()
	DescTip.Instance:SetContent(Language.Zhanjiang.DescContent, Language.Zhanjiang.TipTitle)
end

function View:OnClickBtnUpLvCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	self:CancelReqSendTimer()
	-- local vis = self.layout_wing_auto_hook.img_hook.node:isVisible()
	if self.data:GetHeroUpgradeConsum() <= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN) + RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN) then
		ZhanjiangCtrl.UpgradeHeroGradeReq(self.data:GetOtherInfoList().hero_id)
	else
		TipCtrl.Instance:OpenGetStuffTip(tagAwardItemIdDef[tagAwardType.qatBindMoney])
	end
end

function View:OnClickBtnAutoUpLvCallBack()
	if CrossServerCtrl.CrossServerPingbi() then return end

	self.is_auto_upgrade = not self.is_auto_upgrade
	if self.is_auto_upgrade then
		self:BuildReqSendTimer()
	end
end

function View:OnClickObtainMaterial()
	if CrossServerCtrl.CrossServerPingbi() then return end

	local id = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(80)
	local data = {
		{stuff_way = Language.Zhanjiang.WayTitles[1], go_to = id},
	}
	TipCtrl.Instance:OpenStuffTip(Language.Zhanjiang.AdvanceStuffGetWay, data)
end

function View:OnActivateClicked()
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= HeroConfig.actorLV then
		ZhanjiangCtrl.HeroActivateReq(self.data:GetHeroType())
	else
		SysMsgCtrl.Instance:FloatingTopRightText(string.format("等级达到%s级开启", HeroConfig.actorLV))
	end
end





function View:CreateHeroModel()
	self.hero_model = MonsterDisplay.New(self.node_t_list["layout_zhanjiang"].node, 20)
	self.hero_model:SetPosition(269, 160)
	self.hero_model:SetScale(1.2)
end

function View:CreateZhanjiangAttrList()
	self.zhanjiang_attr_list = ListView.New()
	local positionHelper = self.ph_list.ph_zhanjiang_attr_list
	self.zhanjiang_attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_attr_panel.node:addChild(self.zhanjiang_attr_list:GetView(), 100, 100)
	self.zhanjiang_attr_list:GetView():setAnchorPoint(0,0)
	self.zhanjiang_attr_list:SetItemsInterval(3)
	self.zhanjiang_attr_list:JumpToTop(true)
end

function View:CreateFutiAttrList()
	self.futi_attr_list = ListView.New()
	local positionHelper = self.ph_list.ph_zhanjiang_role_attr_list
	self.futi_attr_list:Create(positionHelper.x, positionHelper.y, positionHelper.w, positionHelper.h, nil, ZhanjiangAttrItem, nil, nil, self.ph_list.ph_zhanjiang_attr_item)
	self.node_t_list.layout_role_attr.node:addChild(self.futi_attr_list:GetView(), 100, 100)
	self.futi_attr_list:GetView():setAnchorPoint(0,0)
	self.futi_attr_list:SetItemsInterval(3)
	self.futi_attr_list:JumpToTop(true)
end

function View:CreateConfirmDlg()
	if not self.confirmDlg then
		self.confirmDlg = Alert.New()
		self.confirmDlg:SetShowCheckBox(false)
		self.confirmDlg:SetLableString(Language.Zhanjiang.ConfirmDlgContent)
		self.confirmDlg:SetOkFunc(function ()
			ZhanjiangCtrl.SetHeroStateReq(self.data:GetOtherInfoList().hero_id, HERO_STATE.SHOW)
		end)
	end
end






----------------------------------------------
--  战将属性itemrender

ZhanjiangAttrItem = ZhanjiangAttrItem or BaseClass(BaseRender)
function ZhanjiangAttrItem:__init()
end

function ZhanjiangAttrItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_attr_value.node)
	self.node_tree.lbl_attr_name.node:setColor(cc.c3b(0xf5, 0xf3, 0xdf))
end

function ZhanjiangAttrItem:OnFlush()
	if self.data == nil then return end
	if self.data.type == "fight_power" then
		self.node_tree.lbl_attr_name.node:setString(Language.Zhanjiang.FightPower)
	else
		self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	end 
	local add_value = ""
	if self.data.add_value then
		add_value = " {wordcolor;1eff00;↑" .. self.data.add_value .. "}"
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_attr_value.node, self.data.value_str .. add_value)
end

function ZhanjiangAttrItem:ShowFlash()
	if nil == self.select_effect then
		-- local size = self.node_tree.img9_bg.node:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(263, 13, 255, 27, ResPath.GetCommon("img9_292"), true)
		self.view:addChild(self.select_effect, 999)
		self.select_effect:setOpacity(0)
	end

	local fade_out = cc.FadeTo:create(0.2, 140)
	local fade_in = cc.FadeTo:create(0.3, 80)
	local fade_in2 = cc.FadeTo:create(0.2, 0)
	local action = cc.Sequence:create(fade_out, fade_in, fade_out, fade_in2)
	self.select_effect:runAction(action)
end

function ZhanjiangAttrItem:CreateSelectEffect()
end


return View