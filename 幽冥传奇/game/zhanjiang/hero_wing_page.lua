--英雄光翼页面
HeroWingInfoPage = HeroWingInfoPage or BaseClass()

function HeroWingInfoPage:__init()
	self.view = nil
	self.page = nil
	self.is_show_wing_bubble = true
	self.is_show_skill_bubble = true		
end	

function HeroWingInfoPage:__delete()
	self:RemoveEvent()
	self.page = nil
	self.view = nil
	if self.big_herowing_effec then	
		self.big_herowing_effec:setStop()
		self.big_herowing_effec = nil
	end
	if self.big_herowing_effec_next then	
		self.big_herowing_effec_next:setStop()
		self.big_herowing_effec_next = nil
	end
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
	end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil
	end
	if self.bubble then
		self.bubble:DeleteMe()
		self.bubble = nil
	end

	if self.bubbleskill then
		self.bubbleskill:DeleteMe()
		self.bubbleskill = nil
	end	

end	

--初始化页面接口
function HeroWingInfoPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.layout_wing

	
	self:InitEvent()
end

--初始化事件
function HeroWingInfoPage:InitEvent()
	XUI.AddClickEventListener(self.page.componment2.beginBtn.node,BindTool.Bind(self.OnBegin,self),true)
	XUI.AddClickEventListener(self.page.componment2.autoBtn.node,BindTool.Bind(self.OnAuto,self),true)
	local ph = self.view.ph_list.current_model_container
	if nil == self.big_herowing_effec then
		self.big_herowing_effec = RenderUnit.CreateEffect(effect_id, self.page.node, 99, frame_interval, loops, ph.x, ph.y, callback_func)
	end
	ph = self.view.ph_list.next_model_container
	if nil == self.big_herowing_effec_next then
		self.big_herowing_effec_next = RenderUnit.CreateEffect(effect_id, self.page.componment1.node, 99, frame_interval, loops, ph.x, ph.y, callback_func)
	end
	self.check_box = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box:setVisible(false)
	self.view.node_t_list.checkBoxConsume.node:addChild(self.check_box, 19)
	XUI.AddClickEventListener(self.view.node_t_list.checkBoxConsume.node, BindTool.Bind(self.OnCheckBox, self))

	self.time_handler = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnTimeRun,self), 1)
	self:OnTimeRun()

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	XUI.AddClickEventListener(self.view.node_t_list.tempAttrBtn.node,BindTool.Bind(self.OnTempAttr, self))

	self.bubble = ChatBubbleBoard.New()
	self.view.node_t_list.tempAttrBtn.node:addChild(self.bubble:GetRootNode())
	self.bubble:GetRootNode():setPosition(50,50)

	self.bubble:SetSayContent(Language.Wing.WingTempAttrDesc)
	self.bubble:SetVisible(false)

	self.bubbleskill = ChatBubbleBoard.New()
	self.view.node_t_list.layout_skill.node:addChild(self.bubbleskill:GetRootNode())
	self.bubbleskill:GetRootNode():setPosition(50,50)
	XUI.AddClickEventListener(self.view.node_t_list.layout_skill.node,BindTool.Bind(self.OnTempSkill, self))
	self.bubbleskill:SetSayContent(Language.Wing.WingTempAttrDesc)
	self.bubbleskill:SetVisible(false)

end

--移除事件
function HeroWingInfoPage:RemoveEvent()
	if self.time_handler then
		GlobalTimerQuest:CancelQuest(self.time_handler)
		self.time_handler = nil
	end	
end

function HeroWingInfoPage:RoleDataChangeCallback(key, value)
	self:UpdateData()
end

function HeroWingInfoPage:OnCheckBox()
	self.check_box:setVisible(not self.check_box:isVisible())
end	

function HeroWingInfoPage:OnTempSkill()
	self.is_show_skill_bubble = false
	self.bubbleskill:SetVisible(self.is_show_skill_bubble)
	local wing_cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingLevel)
	if wing_cfg  then
		if self.now_DeletType  and self.next_DeletType then
			local str =string.format(Language.Zhanjiang.HeroWingTip,wing_cfg.temp_value,self.now_DeletType.value_str,wing_cfg.temp_value+1,self.next_DeletType.value_str) 
			DescTip.Instance:SetContent(str,Language.Zhanjiang.HeroWingTipTitle)			
		end
	end
end

function HeroWingInfoPage:OnTempAttr()	
	local wing_vua = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingValue)
	local add_attrs_t
	if wing_vua then
		add_attrs_t = WingData.Instance:GetHeroAttchAttrByZhufu(wing_vua.temp_value)
	end
	if add_attrs_t then
		local prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		add_attrs_t = CommonDataManager.DelAttrByProf(prof,add_attrs_t)
		local title_attrs = RoleData.FormatRoleAttrStr(add_attrs_t, is_range,nil,prof)
		local result = ""
		for i = 1 , #title_attrs do
			result = result .. title_attrs[i].type_str .. ":" .. title_attrs[i].value_str .. "\n"
		end	
		DescTip.Instance:SetContent(result, Language.Wing.WingTempAttrTitle)
	end
	self.is_show_wing_bubble = false
	self.bubble:SetVisible(self.is_show_wing_bubble)
end	


--更新视图界面
function HeroWingInfoPage:UpdateData(data)
	local wing_cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingLevel)
	local wing_vua = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingValue)
	if wing_cfg and wing_vua then
		self:UpdateAttr(wing_cfg.temp_value,wing_vua.temp_value)
	end
	local herowing_list = HeroWingData.Instance:GetHeroesInfoList()
	local index = 1
	for i,v in ipairs(herowing_list) do
		if v.state == HERO_WING_STATE.DRESS then
			index =  i
		end
	end
	local wingData  = herowing_list[index]
	if wingData then
		local effec_id = wingData.modelIcon
		if self.big_herowing_effec and self.big_herowing_effec_next and effec_id then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effec_id)
			self.big_herowing_effec:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.big_herowing_effec_next:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
	end
end


function HeroWingInfoPage:OnTimeRun()
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

function HeroWingInfoPage:UpdateAttr(level,value)	
	local wing_Level_next = ZhanjiangData.Instance:getHeroGoldWingType(level+1)
	local wing_Level_now = ZhanjiangData.Instance:getHeroGoldWingType(level)
	if wing_Level_now then
		self.view.node_t_list["cur_step_img"].node:loadTexture(ResPath.GetCommon("step_" ..wing_Level_now.id))
		local attrs_t = WingData.Instance:GetHeroAttrById(wing_Level_now.id)
		local add_attrs_t = WingData.Instance:GetHeroAttchAttrByZhufu(value)
		if add_attrs_t then
			attrs_t = CommonDataManager.AddAttr(attrs_t,add_attrs_t)
		end

		self.bubble:SetVisible(self.is_show_wing_bubble and wing_Level_now.id == 1 and value > 0)

		local prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		attrs_t = CommonDataManager.DelAttrByProf(prof,attrs_t)
		local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range,nil,prof)
		local index = 1
		for i,v in ipairs(title_attrs) do
			if v.type ==GAME_ATTRIBUTE_TYPE.AHeroAttackActorMaxHpPower then
				index = i
				break
			end
		end
		if title_attrs and title_attrs[index] then
			self.now_DeletType = title_attrs[index]
			table.remove(title_attrs,index)
		end
		local is_show = false
		for i = 1, 5 do
			is_show = title_attrs[i] and true or false
			self.view.node_t_list["attr_title" .. i].node:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
			self.view.node_t_list["cur_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
			self.view.node_t_list["layout_attr_bg_" .. i].node:setVisible(is_show)
		end
		local consume = wing_Level_now.consume
		local bagItemCount = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
		local format1 = "{wordcolor;ff0000;%s}{wordcolor;ffff00;/%s}"
		local format2 = "{wordcolor;ffff00;%s}{wordcolor;00ff00;/%s}"
		local result = ""
		if bagItemCount >= consume.count then
			result = string.format(format2,bagItemCount,consume.count)
		else	
			result = string.format(format1,bagItemCount,consume.count)
		end	
		RichTextUtil.ParseRichText(self.view.node_t_list["consumeText"].node, result, 22, COLOR3B.WHITE)
	end

	if wing_Level_next then

		self.view.node_t_list.progress_bar.node:setPercent(value/wing_Level_next.maxValue * 100)
		self.view.node_t_list.zhufuText.node:setString(value .. "/" .. wing_Level_next.maxValue)
		if wing_Level_next.id >= HeroSwingEquipConfig.clearLevel then
			self.view.node_t_list["clear_remain_text"].node:setVisible(true)
		else
			self.view.node_t_list["clear_remain_text"].node:setVisible(false)
		end
		self.view.node_t_list["nex_step_img"].node:loadTexture(ResPath.GetCommon("step_" ..wing_Level_next.id))	
		self.page.componment1.node:setVisible(true)

		local attrs_t = WingData.Instance:GetHeroAttrById(wing_Level_next.id)
		local prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		attrs_t = CommonDataManager.DelAttrByProf(prof,attrs_t)
		local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range,nil,prof)
		local index = 1
		for i,v in ipairs(title_attrs) do
			if v.type ==GAME_ATTRIBUTE_TYPE.AHeroAttackActorMaxHpPower then
				index = i
				break
			end
		end
		if title_attrs and title_attrs[index] then
			self.next_DeletType = title_attrs[index]
			table.remove(title_attrs,index)
		end
		for i = 1, 5 do
			self.view.node_t_list["nex_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
		end
	else
		self.page.componment1.node:setVisible(false)
		self.view.node_t_list["clear_remain_text"].node:setVisible(false)
		self.view.node_t_list.progress_bar.node:setPercent(100)
		self.view.node_t_list.zhufuText.node:setString(0)
		for i = 1, 5 do
			self.view.node_t_list["nex_attr" .. i].node:setString(Language.Common.MaxGrade or "" )
		end	
	end
	self.view.node_t_list["maxLevelImg"].node:setVisible(not wing_Level_next)
end	

function HeroWingInfoPage:OnBegin()
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
		local wing_cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingLevel)
		
		if wing_cfg then


			local cfg = ZhanjiangData.Instance:getHeroGoldWingType(wing_cfg.temp_value)
			if #HeroSwingEquipConfig.SwingEquipTable == cfg.id then
				return
			end	
			local flat = 0
			if self.check_box:isVisible() then
				flat = 1
			end	
			local consume = cfg.consume
			local bagItemCount = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
			local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
			local needYb = (consume.count - bagItemCount) * consume.yb
			if bagItemCount >= consume.count then
				WingCtrl.Instance:SendHeroWingUpGradeReq(0)
			elseif flat == 1 and money >= needYb then
				WingCtrl.Instance:SendHeroWingUpGradeReq(1)
			else
				WingCtrl.Instance:SendHeroWingUpGradeReq(flat)
			end	
			
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end


function HeroWingInfoPage:OnAuto()
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


function HeroWingInfoPage:checkAuto()
	local wing_cfg = ZhanjiangData.Instance:getHeroGold(ZhanjiangData.TempType.WingLevel)
	if wing_cfg  then

		local cfg = ZhanjiangData.Instance:getHeroGoldWingType(wing_cfg.temp_value)
		if  #HeroSwingEquipConfig.SwingEquipTable == cfg.id then
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
		local bagItemCount = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
		local money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local needYb = consume.yb
		if bagItemCount >= consume.count then
			WingCtrl.Instance:SendHeroWingUpGradeReq(0)
		elseif flat == 1 and money >= needYb then
			WingCtrl.Instance:SendHeroWingUpGradeReq(1)
		else
			GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
			self.auto_upgrade_event = nil
			self.view.node_t_list.autoBtn.node:setTitleText(Language.Wing.UpLevelBtnTxt[1])
			self.view.node_t_list.autoBtn.node:setTitleColor(COLOR3B.WHITE)
			WingCtrl.Instance:SendHeroWingUpGradeReq(flat)
		end	
	end
	
end
