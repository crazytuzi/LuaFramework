RoleWingPage = RoleWingPage or BaseClass()

function RoleWingPage:__init()
	self.view = nil
	self.is_show_wing_bubble = true
	self.is_first_login = true
end	

function RoleWingPage:__delete()

	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
	end	

	self:RemoveEvent()
	self.view = nil
	self.effec = nil 

	ClientCommonButtonDic[CommonButtonType.ROLE_WING_UP_BTN] = nil
end	

--初始化页面接口
function RoleWingPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreatePageView()
	self:InitEvent()
	
end	

--初始化事件
function RoleWingPage:InitEvent()
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	-- XUI.AddClickEventListener(self.view.node_t_list.layout_gongming.node, BindTool.Bind(self.OpenUnionView, self), true)

	-- self.effec = RenderUnit.CreateEffect(10, self.view.node_t_list.layout_gongming.img9_open.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	-- self.effec:setScaleX(2.2)
	-- self.effec:setScaleY(0.8)
	-- self.effec:setPositionX(260)
	
	self.time_handler = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnTimeRun,self), 1)
	self:OnTimeRun()
end

-- function RoleWingPage:OpenUnionView()
-- 	self.is_first_login = false
-- 	self.effec:setVisible(self.is_first_login)
-- 	ViewManager.Instance:Open(ViewName.UnionProperty)
-- 	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "wing")
-- end

--移除事件
function RoleWingPage:RemoveEvent()

	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	
	if self.item_list_event then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		end	
		self.item_list_event = nil
	end

	if self.current_display then
		self.current_display:DeleteMe()
	end	

	if self.next_display then
		self.next_display:DeleteMe()
	end	

	-- if self.effect_display then
		-- self.effect_display:DeleteMe()
	--end

	if self.time_handler then
		GlobalTimerQuest:CancelQuest(self.time_handler)
		self.time_handler = nil
	end	

	if self.bubble then
		self.bubble:DeleteMe()
		self.bubble = nil
	end	
	if self.delay_flush_time then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil 
	end
	if self.play_effect then
		self.play_effect:setStop()
		self.play_effect = nil
	end
end

--更新视图界面
function RoleWingPage:UpdateData(data)
	self:FlushWingPage()
	local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
	self:SetAnimationByWingId(wingId)
end	

function RoleWingPage:FlushWingPage()
	self:Clear()
	self:UpdateViewByWingId()
	self:UpdateZhufubar()
	self:UpdateConsume()
	self:UpdateTempAttr()
	self:UpdateMaxLevel()
end


--创建一下动态的元素
function RoleWingPage:CreatePageView()
	self.current_display = ModelAnimate.New(ResPath.GetChibangBigAnimPath, self.view.node_t_list.current_model_container.node, GameMath.MDirDown)
	self.current_display:SetAnimPosition(0,0)
	self.current_display:SetFrameInterval(FrameTime.RoleStand)

	self.next_display = ModelAnimate.New(ResPath.GetChibangBigAnimPath, self.view.node_t_list.next_model_container.node, GameMath.MDirDown)
	self.next_display:SetAnimPosition(0,0)
	self.next_display:SetFrameInterval(FrameTime.RoleStand)

	self.check_box = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box:setVisible(false)
	self.view.node_t_list.checkBoxConsume.node:addChild(self.check_box, 19)
	XUI.AddClickEventListener(self.view.node_t_list.checkBoxConsume.node, BindTool.Bind(self.OnCheckBox, self))

	XUI.AddClickEventListener(self.view.node_t_list.beginBtn.node, BindTool.Bind(self.OnBegin, self))
	XUI.AddClickEventListener(self.view.node_t_list.autoBtn.node, BindTool.Bind(self.OnAuto, self))
	XUI.AddClickEventListener(self.view.node_t_list.helpBtn.node, BindTool.Bind(self.OnHelp, self))
	XUI.AddClickEventListener(self.view.node_t_list.tempAttrBtn.node,BindTool.Bind(self.OnTempAttr, self))

	self.bubble = ChatBubbleBoard.New()
	self.view.node_t_list.tempAttrBtn.node:addChild(self.bubble:GetRootNode())
	self.bubble:GetRootNode():setPosition(50,50)

	self.bubble:SetSayContent(Language.Wing.WingTempAttrDesc)
	self.bubble:SetVisible(false)

	-- self.effect_display = ModelAnimate.New(ResPath.GetChibangBigAnimPath, self.view.node_t_list.effect_model_container.node, GameMath.MDirDown)
	-- self.effect_display:SetAnimPosition(0,0)
	-- self.effect_display:SetFrameInterval(FrameTime.RoleStand)

	ClientCommonButtonDic[CommonButtonType.ROLE_WING_UP_BTN] = self.view.node_t_list.beginBtn.node
end	

function RoleWingPage:ItemDataListChangeCallback()
	self:UpdateConsume()
end

function RoleWingPage:OnBegin()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[1])
		self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.WHITE)
	end	

	if not self.auto_upgrade_event then
		local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
		if wingId > 0 then

			local cfg = WingData.Instance:GetWingCfgById(wingId)
			if #SwingEquipConfig.SwingEquipTable == wingId then
				local currenValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
				if currenValue == cfg.maxValue then
					return
				end	
			end	

			

			local flat = 0
			if self.check_box:isVisible() then
				flat = 1
			end	
			local consume = cfg.consume
			local item_id = consume.id
			local bagItemCount = ItemData.Instance:GetItemNumInBagById(item_id,nil)
			local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
			local needYb = (consume.count - bagItemCount) * consume.yb
			if bagItemCount >= consume.count then
				WingCtrl.Instance:SendWingUpGradeReq(0)
			elseif flat == 1 and money >= needYb then
				WingCtrl.Instance:SendWingUpGradeReq(1)
			else
				WingCtrl.Instance:SendWingUpGradeReq(flat)
			end	
			
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function RoleWingPage:OnAuto()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
		self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[1])
		self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.WHITE)
		return
	end	
	self:checkAuto()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	


function RoleWingPage:checkAuto()
	local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
	if wingId > 0 then

		local cfg = WingData.Instance:GetWingCfgById(wingId)

		if #SwingEquipConfig.SwingEquipTable == wingId then
			if self.auto_upgrade_event then
				GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
				self.auto_upgrade_event = nil
				self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[1])
				self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.WHITE)
			end	
			return
		end	

		self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[2])
		self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.RED)
		

		if self.auto_upgrade_event then
			GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
			self.auto_upgrade_event = nil
		end
		self.auto_upgrade_event = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.checkAuto,self), 0.6)

	    local flat = 0
		if self.check_box:isVisible() then
			flat = 1
		end	
		local consume = cfg.consume
		local item_id = consume.id
		local bagItemCount = ItemData.Instance:GetItemNumInBagById(item_id,nil)
		local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local needYb = (consume.count - bagItemCount) * consume.yb
		if bagItemCount >= consume.count then
			WingCtrl.Instance:SendWingUpGradeReq(0)
		elseif flat == 1 and money >= needYb then
			WingCtrl.Instance:SendWingUpGradeReq(1)
		else
			GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
			self.auto_upgrade_event = nil
			self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[1])
			self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.WHITE)
			WingCtrl.Instance:SendWingUpGradeReq(flat)
		end	
	end
	
end	

function RoleWingPage:OnHelp()
	DescTip.Instance:SetContent(Language.Wing.WingDetail, Language.Wing.WingTitle)
end	

function RoleWingPage:OnCheckBox()
	self.check_box:setVisible(not self.check_box:isVisible())
end	

function RoleWingPage:OnTempAttr()
	
	local currenValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
	local add_attrs_t = WingData.Instance:GetAttchAttrByZhufu(currenValue)
	if add_attrs_t then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		add_attrs_t = CommonDataManager.DelAttrByProf(prof,add_attrs_t)
		local title_attrs = RoleData.FormatRoleAttrStr(add_attrs_t, is_range)
		local result = ""
		for i = 1 , #title_attrs do
			result = result .. title_attrs[i].type_str .. ":" .. title_attrs[i].value_str .. "\n"
		end	
		DescTip.Instance:SetContent(result, Language.Wing.WingTempAttrTitle)
	end

	self.is_show_wing_bubble = false
	self.bubble:SetVisible(self.is_show_wing_bubble)
end	


function RoleWingPage:RoleDataChangeCallback(key, value,old_value)
	if key == OBJ_ATTR.ACTOR_SWING_ID then --阶数改变
		if old_value > 0 then
			self:UpdateUplevelAction(value)
		end
		self:FlushWingPage()
	elseif 	key == OBJ_ATTR.ACTOR_SWING_EXP then --祝福值改变
		self:FlushWingPage()
	end
end	

function RoleWingPage:UpdateUplevelAction(value)
	local pos = self.view.node_t_list.next_model_container.node:convertToWorldSpace(cc.p(0, 0))
	pos = self.view.node_t_list.layout_wing.node:convertToNodeSpace(pos)

	local cfg = WingData.Instance:GetWingCfgById(value)
	local anim_path, anim_name = ResPath.GetChibangBigAnimPath(cfg.appearance, SceneObjState.Stand, GameMath.DirDown)
	local img = RenderUnit.CreateAnimSprite(anim_path,anim_name)
	img:setPosition(pos.x, pos.y)
	self.view.node_t_list.layout_wing.node:addChild(img, 100)
	local cur_pos = self.view.node_t_list.current_model_container.node:convertToWorldSpace(cc.p(0, 0))
	cur_pos = self.view.node_t_list.layout_wing.node:convertToNodeSpace(cur_pos)
	local moveTo = cc.MoveTo:create(1, cc.p(cur_pos.x, cur_pos.y))
	local callback = cc.CallFunc:create(function()
		img:setVisible(false)
		self:SetPlayEffect(55, cur_pos.x,  cur_pos.y)
	end)
	local delay_time = cc.DelayTime:create(1)
	local wingcallback = cc.CallFunc:create(function()
		img:removeFromParent()
		self:SetAnimationByWingId(value)
	end)
	local action = cc.Sequence:create(moveTo, callback, delay_time,wingcallback)
	img:runAction(action)
end	

function RoleWingPage:SetPlayEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_wing.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)

end


function RoleWingPage:UpdateViewByWingId()
	local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
	if wingId > 0 then

		
		self.view.node_t_list["currentNameImg"].node:setLocalZOrder(999)
		self.view.node_t_list["nextNameImg"].node:setLocalZOrder(999)
		if wingId >= 10 then
			self.view.node_t_list["clear_remain_text"].node:setVisible(true)
		else
			self.view.node_t_list["clear_remain_text"].node:setVisible(false)
		end	

		self.view.node_t_list["cur_step_img"].node:loadTexture(ResPath.GetCommon("step_" .. wingId))

		local cfg = WingData.Instance:GetWingCfgById(wingId)
		--self.current_display:Show(cfg.appearance)

		local currenValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
		local attrs_t = WingData.Instance:GetAttrById(wingId)
		local add_attrs_t = WingData.Instance:GetAttchAttrByZhufu(currenValue)
		if add_attrs_t then
			attrs_t = CommonDataManager.AddAttr(attrs_t,add_attrs_t)
		end	

		self.bubble:SetVisible(self.is_show_wing_bubble and wingId == 1 and currenValue > 0)

		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		attrs_t = CommonDataManager.DelAttrByProf(prof,attrs_t)

		self.view.node_t_list["currentNameImg"].node:loadTexture(ResPath.GetWing("name_" .. cfg.appearance))
		


		local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
		local is_show = false
		for i = 1, 5 do
			is_show = title_attrs[i] and true or false
			self.view.node_t_list["attr_title" .. i].node:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
			self.view.node_t_list["cur_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
			self.view.node_t_list["layout_attr_bg_" .. i].node:setVisible(is_show)
		end
		
		local nextId = wingId + 1
		local nextCfg = WingData.Instance:GetWingCfgById(nextId)
		if nextCfg then
			self.view.node_t_list["nex_step_img"].node:loadTexture(ResPath.GetCommon("step_" .. nextId))
			self.view.node_t_list["nextNameImg"].node:loadTexture(ResPath.GetWing("name_" .. nextCfg.appearance))
			--self.next_display:Show(nextCfg.appearance)

			local attrs_t = WingData.Instance:GetAttrById(nextId)
			local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			attrs_t = CommonDataManager.DelAttrByProf(prof,attrs_t)
			local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
			for i = 1, 5 do
				self.view.node_t_list["nex_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
			end
		else
			nextCfg = WingData.Instance:GetWingCfgById(wingId)
			self.view.node_t_list["nex_step_img"].node:loadTexture(ResPath.GetCommon("step_" .. wingId))
			self.view.node_t_list["nextNameImg"].node:loadTexture(ResPath.GetWing("name_" .. nextCfg.appearance))
			--self.next_display:Show(nextCfg.appearance)

			local attrs_t = WingData.Instance:GetAttrById(wingId)
			local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			attrs_t = CommonDataManager.DelAttrByProf(prof,attrs_t)
			local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
			for i = 1, 5 do
				self.view.node_t_list["nex_attr" .. i].node:setString(title_attrs[i] and Language.Common.MaxGrade or "")
			end
		end
	end
end	

function RoleWingPage:SetAnimationByWingId(wingId)
	if wingId > 0 then
		local cur_cfg = WingData.Instance:GetWingCfgById(wingId)
		self.current_display:Show(cur_cfg.appearance)
		local nextCfg = WingData.Instance:GetWingCfgById(wingId + 1)
		if nextCfg ~= nil then
			self.next_display:Show(nextCfg.appearance)
		else
			nextCfg = WingData.Instance:GetWingCfgById(wingId)
			self.next_display:Show(nextCfg.appearance)
		end
	end
end

function RoleWingPage:UpdateMaxLevel()
	local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
	local nextId = wingId + 1
	local nextCfg = WingData.Instance:GetWingCfgById(nextId)
	if not nextCfg then
		self.view.node_t_list.componment1.node:setVisible(false)
		self.view.node_t_list.componment2.node:setVisible(false)
		self.view.node_t_list.maxLevelImg.node:setVisible(true)
	else	
		self.view.node_t_list.componment1.node:setVisible(true)
		self.view.node_t_list.componment2.node:setVisible(true)
		self.view.node_t_list.maxLevelImg.node:setVisible(false)
	end	
end	

function RoleWingPage:UpdateTempAttr()
	local currenValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
	local add_attrs_t = WingData.Instance:GetAttchAttrByZhufu(currenValue)
	if add_attrs_t then
		self.view.node_t_list.tempAttrBtn.node:setVisible(true)
	else	
		self.view.node_t_list.tempAttrBtn.node:setVisible(false)
	end	
end	

function RoleWingPage:UpdateConsume()
	local wingId = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID)
	if wingId > 0 then
		local cfg = WingData.Instance:GetWingCfgById(wingId)
		local consume = cfg.consume
		local item_id = consume.id
		local bagItemCount = ItemData.Instance:GetItemNumInBagById(item_id,nil)

		local format1 = "{wordcolor;ffff00;%s}{wordcolor;ff0000;/%s}"
		local format2 = "{wordcolor;ffff00;%s}{wordcolor;00ff00;/%s}"
		local result = ""

		if bagItemCount >= consume.count then
			result = string.format(format2,consume.count,bagItemCount)
		else	
			result = string.format(format1,consume.count,bagItemCount)
		end	
		RichTextUtil.ParseRichText(self.view.node_t_list["consumeText"].node, result, 22, COLOR3B.WHITE)
	end
end	

function RoleWingPage:UpdateZhufubar()
	local cfg = WingData.Instance:GetWingCfgById(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_ID))
	if cfg then
		local currenValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_EXP)
		self.view.node_t_list.progress_bar.node:setPercent(currenValue/cfg.maxValue * 100)
		self.view.node_t_list.zhufuText.node:setString(currenValue .. "/" .. cfg.maxValue)
	end
end	

function RoleWingPage:Clear()
	self.current_display:StopAllActions()--停止模型动画
	self.next_display:StopAllActions()--停止模型动画
	--self.effect_display:StopAllActions()
end	

function RoleWingPage:OnTimeRun()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local time = os.date("*t",server_time)
	local hour = time.hour
	local min = time.min
	local sec = time.sec

	local target_hour = 0
	local target_min = 0
	local target_sec = 0

	local src_time = 0
	local tar_time = 0

	local out_text = ""
	
	if hour >= 0 and hour < 6 then
		target_hour = 6
		target_min = 0
		target_sec = 0

		src_time = hour * 3600 + min * 60 + sec
		tar_time = target_hour * 3600 + target_min * 60 + target_sec
		local time_info = TimeUtil.Format2TableDHMS(tar_time - src_time)
		if time_info.hour > 0 then
			out_text = time_info.hour .. Language.Common.TimeList.h .. time_info.min .. Language.Common.TimeList.min
		else
			out_text = time_info.min .. Language.Common.TimeList.min .. time_info.s .. Language.Common.TimeList.s
		end	
	else
		target_hour = 24 + 6
		target_min = 0
		target_sec = 0

		src_time = hour * 3600 + min * 60 + sec
		tar_time = target_hour * 3600 + target_min * 60 + target_sec
		local time_info = TimeUtil.Format2TableDHMS(tar_time - src_time)
		out_text = time_info.hour .. Language.Common.TimeList.h .. time_info.min .. Language.Common.TimeList.min
	end	

	self.view.node_t_list["clear_remain_text"].node:setString("(" .. out_text .. Language.Role.WingZhufuClear .. ")")
end	

