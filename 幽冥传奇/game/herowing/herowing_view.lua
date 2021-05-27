HeroWingView = HeroWingView or BaseClass(XuiBaseView)

function HeroWingView:__init()
	self.texture_path_list[1] = 'res/xui/god_arm.png'
	self.texture_path_list[2] = 'res/xui/wing.png'
	self.is_async_load = false
	self.is_modal = true	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"hero_wing_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	-- self.hero_wing_model = nil
	-- self.is_select = nil
	self.selec_index = 1
	self.title_img_path = ResPath.GetWing("hero_wing_title")
end

function HeroWingView:__delete()
	
end

function HeroWingView:ReleaseCallBack()
	-- if self.hero_wing_model then
	-- 	self.hero_wing_model:DeleteMe()
	-- 	self.hero_wing_model = nil
	-- end
	if self.big_herowing_effec then	
		self.big_herowing_effec:setStop()
		self.big_herowing_effec = nil
	end

	if self.hero_wing_show_list then
		self.hero_wing_show_list:DeleteMe()
		self.hero_wing_show_list = nil
	end
	if self.hero_attr_list then
		self.hero_attr_list:DeleteMe()
		self.hero_attr_list = nil
	end
	if self.role_attr_list then
		self.role_attr_list:DeleteMe()
		self.role_attr_list = nil
	end
	if self.confirmDlgVIP then
		self.confirmDlgVIP:DeleteMe()
		self.confirmDlgVIP = nil
	end

	if self.confirmDlgYB then
		self.confirmDlgYB:DeleteMe()
		self.confirmDlgYB = nil
	end

	if nil ~= self.alertWnd then
		self.alertWnd:DeleteMe()
  		self.alertWnd = nil
	end	
	self.selec_index = 1
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	ClientCommonButtonDic[CommonButtonType.ZHANSHEN_WING_WEAR_BTN] = nil
end

function HeroWingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- if nil == self.hero_wing_model then
		-- 	self.hero_wing_model = MonsterDisplay.New(self.node_t_list["layout_hero_wing"].node, 20)
		-- 	local ph = self.ph_list.ph_hero_wing_show_eff
		-- 	self.hero_wing_model:SetPosition(ph.x, ph.y)
		-- 	-- self.hero_wing_model:SetScale(1.2)
		-- end
		self:CreateConfirmDlgs()
		self:CreateViewElement()
		XUI.AddClickEventListener(self.node_t_list.layout_hero_wing.btn_light_pic.node, BindTool.Bind2(self.OnDressDischargeActivate, self), true)
		-- XUI.AddClickEventListener(self.node_t_list.layout_hero_wing.questBtn.node, BindTool.Bind2(self.OnHelp, self))
		self.timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.DelayClose, self), 10)
		self.node_t_list.layout_hero_wing.layout_desc.node:setVisible(false)
		local open_day = OtherData.Instance:GetOpenServerDays()
		local herowing_list = HeroWingData.Instance:GetHeroesInfoList()
		if open_day and open_day <= 3 and herowing_list[5].state ==2 then
			self.node_t_list.layout_hero_wing.layout_desc.node:setVisible(true)
			self.node_t_list.txt_desc_5.node:removeAllElements()
			RichTextUtil.ParseRichText(self.node_t_list.txt_desc_5.node, Language.Zhanjiang.HeroWingDesc,20, COLOR3B.LIGHT_BLUE)
		end

		ClientCommonButtonDic[CommonButtonType.ZHANSHEN_WING_WEAR_BTN] = self.node_t_list.layout_hero_wing.btn_light_pic.node
	end
end

function HeroWingView:OpenCallBack()	
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function HeroWingView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HeroWingView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HeroWingView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushHerowingList()
			self:FlushAttrList()
		elseif k == "just_flush_list" then
			self:FlushHerowingList()
			self:FlushAttrList()
		end
	end
end
function HeroWingView:FlushHerowingList()
	local herowing_list = HeroWingData.Instance:GetHeroesInfoList()
	self.hero_wing_show_list:SetDataList(herowing_list)
	self.hero_wing_show_list:SelectIndex(self.selec_index)
end
function HeroWingView:FlushAttrList()
	local hero_attr_str_t = HeroWingData.Instance:GetHeroWingAddAttrByLv(2,self.selec_index)
	local role_attr_str_t = HeroWingData.Instance:GetHeroWingAddAttrByLv(1,self.selec_index)
	self.hero_attr_list:SetDataList(hero_attr_str_t)
	self.role_attr_list:SetDataList(role_attr_str_t)
end	

function HeroWingView:CreateViewElement()
	if nil == self.hero_wing_show_list then
		local ph = self.ph_list.ph_hero_wing_show_list
		self.hero_wing_show_list = ListView.New()
		self.hero_wing_show_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroWingItemRender, nil, nil, self.ph_list.ph_show_hero_wing_item)
		self.node_t_list.layout_hero_wing.node:addChild(self.hero_wing_show_list:GetView(), 100)
		self.hero_wing_show_list:SetItemsInterval(5)
		self.hero_wing_show_list:SetJumpDirection(ListView.Top)
		self.hero_wing_show_list:SetIsUseStepCalc(false)
		self.hero_wing_show_list:SetSelectCallBack(BindTool.Bind(self.HeroWingSelectCallback, self))
		-- self.hero_wing_show_list:JumpToTop()
	end
	if nil == self.hero_attr_list then
		local ph = self.ph_list.ph_hero_attr_list
		self.hero_attr_list = ListView.New()
		self.hero_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroWingAttrRender, nil, nil, self.ph_list.ph_hero_attr_item)
		self.node_t_list.layout_hero_wing.node:addChild(self.hero_attr_list:GetView(), 100)
		self.hero_attr_list:SetItemsInterval(3)
		self.hero_attr_list:SetJumpDirection(ListView.Top)
	end
	if nil == self.role_attr_list then
		local ph = self.ph_list.ph_role_attr_list
		self.role_attr_list = ListView.New()
		self.role_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroWingAttrRender, nil, nil, self.ph_list.ph_role_attr_item)
		self.node_t_list.layout_hero_wing.node:addChild(self.role_attr_list:GetView(), 100)
		self.role_attr_list:SetItemsInterval(3)
		self.role_attr_list:SetJumpDirection(ListView.Top)
	end
	ph = self.ph_list.ph_hero_wing_show_eff
	if nil == self.big_herowing_effec then
		self.big_herowing_effec = RenderUnit.CreateEffect(effect_id, self.node_t_list.layout_hero_wing.node, 99, frame_interval, loops, ph.x, ph.y, callback_func)
	end
end


function HeroWingView:HeroWingSelectCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_index = index
	-- self.is_select = true
	local path = ResPath.GetWing("btn_stamp_" .. data.state)
	self.node_t_list.btn_light_pic_word.node:loadTexture(path)
	self:FlushAttrList()
	local effec_id = data.modelIcon
	if self.big_herowing_effec then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effec_id)
		self.big_herowing_effec:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
	self.node_t_list.rich_hero_desc.node:removeAllElements()
	RichTextUtil.ParseRichText(self.node_t_list.rich_hero_desc.node, Language.Zhanjiang.HeroWingDetail[index],18, COLOR3B.WHITE)
	if index == 5 and self.node_t_list.layout_hero_wing.layout_desc.node then
		self.node_t_list.layout_hero_wing.layout_desc.node:setVisible(false)
	end	
	-- self:ShowHeroModel(data)
end

function HeroWingView:CreateConfirmDlgs()
	if not self.confirmDlgVIP then
		self.confirmDlgVIP = Alert.New()
		self.confirmDlgVIP:SetShowCheckBox(false)
		self.confirmDlgVIP:SetOkString(Language.Zhanjiang.CheckBtnText)
		self.confirmDlgVIP:SetOkFunc(BindTool.Bind(self.ShowVIPView, self))
	end
	if not self.confirmDlgYB then
		self.confirmDlgYB = Alert.New()
		self.confirmDlgYB:SetShowCheckBox(false)
		self.confirmDlgYB:SetOkFunc(BindTool.Bind(self.ConfirmActivateClicked, self))
	end

	if self.alertWnd == nil then
		self.alertWnd = Alert.New()
		self.alertWnd:SetOkString(Language.Common.BtnRechargeText)
		self.alertWnd:SetOkFunc(BindTool.Bind(self.OnChargeRightNowHandler, self))
	end
end
--显示英雄形象
-- function HeroWingView:ShowHeroModel(data)
-- 	-- PrintTable(data)
-- 	self.hero_wing_model:SetMonsterVo(data)
-- end

-- function HeroWingView:OnHelp()
-- 	DescTip.Instance:SetContent(Language.Zhanjiang.HeroWingDetail, Language.Zhanjiang.HeroWingTitle)
-- end
function HeroWingView:ShowVIPView()
	self:Close()
	ViewManager.Instance:Open(ViewName.Vip, 1)
end
--穿戴-卸戴-激活
function HeroWingView:OnDressDischargeActivate()
	local selec_item = self.hero_wing_show_list:GetSelectItem()
	if not selec_item then return end
	local data = selec_item:GetData()
	if data.state == HERO_WING_STATE.ACTIVE then 		-- ------待激活-------
		-- print("激活", data.state)
		local need_remind, activate_type, activate_val, is_lack_money = HeroWingData.Instance:IsNeedActivateRemind(data)
		if need_remind then	-- 满足激活条件
			if activate_type and activate_val then
				-- 元宝激活提示弹窗
				if self.confirmDlgYB then
			-- 		if not is_lack_money then
					local content = string.format(Language.Zhanjiang.WarnDlgHeroWndContent[2], activate_val)
					self.confirmDlgYB:SetLableString(content)
					self.confirmDlgYB:Open()
			-- 		else
			-- 			if activate_type == HeroWingData.CondType[4] and self.alertWnd then
			-- 				local content = string.format(Language.Zhanjiang.NotAchieveCond, activate_val)
			-- 				self.alertWnd:SetLableString(content)
			-- 				self.alertWnd:Open()
			-- 			end
			-- 		end
				end
			else
				HeroWingCtrl.Instance:HeroActivateReq(data.idx)
			end
			return
		else 					-- 不满足激活条件
			if activate_type and activate_val then
				if activate_type == HeroWingData.CondType[2] then  -- VIP等级不够弹窗提示
					if self.confirmDlgVIP then
						local content = string.format(Language.Zhanjiang.WarnDlgHeroWndContent[1], activate_val)
						self.confirmDlgVIP:SetLableString(content)
						self.confirmDlgVIP:Open()
					end
				elseif activate_type == HeroWingData.CondType[4] then -- 元宝数量不够弹提示
					local my_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DRAW_GOLD_COUNT)
					if my_money > 0 then
						if self.alertWnd then
							local content = string.format(Language.Zhanjiang.NotAchieveCond, activate_val)
							self.alertWnd:SetLableString(content)
							self.alertWnd:Open()
						end
					else
						HeroWingCtrl.Instance:HeroActivateReq(data.idx)
					end	
				else
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Zhanjiang.NotActive))
				end
			else
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Zhanjiang.NotActive))
			end
		end
	elseif data.state == HERO_WING_STATE.DRESS then		-- -----卸戴------
		HeroWingCtrl.Instance:SetHeroStateReq(data.idx, HERO_WING_STATE.DISCHARGE)
		-- print("卸戴")
	else 											-- -------穿戴------
		--print("穿戴")
		HeroWingCtrl.Instance:SetHeroStateReq(data.idx, HERO_WING_STATE.DRESS)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--确定激活
function HeroWingView:ConfirmActivateClicked()
	local selec_item = self.hero_wing_show_list:GetSelectItem()
	if not selec_item then return end
	local data = selec_item:GetData()
	HeroWingCtrl.Instance:HeroActivateReq(data.idx)
end

--充值
function HeroWingView:OnChargeRightNowHandler()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end
function HeroWingView:DelayClose()
	if self.node_t_list.layout_hero_wing.layout_desc.node then
		self.node_t_list.layout_hero_wing.layout_desc.node:setVisible(false)
	end	
end

HeroWingItemRender = HeroWingItemRender or BaseClass(BaseRender)
function HeroWingItemRender:__init()
end

function HeroWingItemRender:__delete()
	self.effec1 = nil
	self.effec_id = nil
	self.select_effect = nil
	
end

function HeroWingItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local name = ResPath.GetWing("hero_wing_not_act_" .. self.index)
	self.node_tree.img_name.node:loadTexture(name)
	
end

function HeroWingItemRender:OnFlush()
	if not self.data then return end
	-- self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.txt_desc.node:setString(self.data.desc)
	local effec_id = self.data.modelIcon
	self:SetShowIconEffect(effec_id)
	if self.data.swingId ~= 5 then
		local bool = false
		local need_remind, activate_type, activate_val = HeroWingData.Instance:IsNeedActivateRemind(self.data)
		if self.data.state == HERO_WING_STATE.ACTIVE then
			if need_remind == false then
				bool = true
			else
				bool =false
			end
		elseif	self.data.state == HERO_WING_STATE.DRESS then
			bool =false
		else
			bool =false
		end
		self.node_tree.img_active.node:setVisible(need_remind == true)
		self.node_tree.txt_desc.node:setVisible(bool and self.data.swingId ~= 1)
		self.node_tree.img_name.node:setGrey(bool)
		self.node_tree.img_bg_1.node:setGrey(bool)
		self:MakeGray(bool)
	else	
		local login_day = OtherData.Instance:GetLoginDays()						-- 登陆天数
		if self.data.state == HERO_WING_STATE.ACTIVE then
			if login_day >= self.data.activateCond[1][1].loginDay then
				self.node_tree.img_active.node:setVisible(true)
				self.node_tree.txt_desc.node:setVisible(true)
				self.node_tree.img_name.node:setGrey(false)
				self.node_tree.img_bg_1.node:setGrey(false)
				self:MakeGray(false)
			else	
				self.node_tree.img_active.node:setVisible(false)
				self.node_tree.txt_desc.node:setVisible(true)
				self.node_tree.img_name.node:setGrey(true)
				self.node_tree.img_bg_1.node:setGrey(true)
				self:MakeGray(true)
			end		
		else	
			self.node_tree.img_active.node:setVisible(false)
			self.node_tree.txt_desc.node:setVisible(false)
			self.node_tree.img_name.node:setGrey(false)
			self.node_tree.img_bg_1.node:setGrey(false)
			self:MakeGray(false)
		end	
	end	
	self.node_tree.img_stamp.node:setVisible(self.data.state == HERO_WING_STATE.DRESS)

	-- self:SetFightImgVis(state_t.hero_id == self.data.heroId and state_t.state == HERO_WING_STATE.DRESS)
end


-- 选择状态改变
function HeroWingItemRender:OnSelectChange(is_select)
	local path_1 = ResPath.GetWing("hero_wing_act_" .. self.index)
	local path_2 = ResPath.GetWing("hero_wing_not_act_" .. self.index)
	local name = ""
	if is_select then
		-- local path_1 = ResPath.GetWing("hero_wing_act_" .. self.data.swingId)
		-- self.node_tree.img_name.node:loadTexture(path_1)
		name = path_1
	else	
		name = path_2
	end
	self.node_tree.img_name.node:loadTexture(name)
end

function HeroWingItemRender:SetShowIconEffect(effec_id)
	if self.effec1 == nil then
		local ph = self.ph_list.ph_img_icon
		self.effec1 = RenderUnit.CreateEffect(nil, self.view, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, ph.x, ph.y)
	end
	if effec_id and (self.effec_id == nil or self.effec_id ~= effec_id) then
		self.effec_id = effec_id
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.effec_id)
		self.effec1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.effec1:setScale(0.25)
	end
end

function HeroWingItemRender:CreateSelectEffect()
	local ph = self.ph_list.ph_selec_effec
	self.select_effect = XUI.CreateImageView(ph.x, ph.y, ResPath.GetGodArm("god_arm_img_3"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999)
end

-- function HeroWingItemRender:SetFightImgVis(vis)
-- 	self.node_tree.img_stamp.node:setVisible(vis)
-- end

HeroWingAttrRender = HeroWingAttrRender or BaseClass(BaseRender)
function HeroWingAttrRender:__init()

end

function HeroWingAttrRender:__delete()
	
end

function HeroWingAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	-- if self.cache_select and self.is_select then
 --    	self.cache_select = false
 --    	self:CreateSelectEffect()
 --    end
	-- self.node_tree.rich_attr_str.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function HeroWingAttrRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.txt_hero_attr_name.node:setString(self.data.type_str and self.data.type_str .. "：" or "")
	self.node_tree.txt_hero_attr_val.node:setString(self.data.value_str or "")
	
end

function HeroWingAttrRender:CreateSelectEffect()
end







