--暂时系统界面合并到活动页面2017/9/18
AchieveView = AchieveView or BaseClass(XuiBaseView)

function AchieveView:__init()
	self:SetModal(true)
	self.def_index = 1
	self.texture_path_list[1] = 'res/xui/achieve.png'
	self.texture_path_list[2] = 'res/xui/compose.png'
	self.is_async_load = false	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"achieve_ui_cfg", 1, {0}},
		{"achieve_ui_cfg", 2, {TabIndex.achieve_achievement}},
		{"achieve_ui_cfg", 3, {TabIndex.achieve_medal}},
		{"common_ui_cfg", 2, {0}},
	}
	self.title_img_path = ResPath.GetAchieve("achieve_title")
	self.achieve_list = nil
	--self.shop_list = nil
	self.play_eff = nil
	self.remind_temp = {}
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindUpAchieveChange, self))

	self.current_btn_index = 1
	self.current_type = 1
	self.last_selec_min_num = 0
	self.tabbar = nil 
	self.btn_list = nil 
end

function AchieveView:__delete()
	
end

function AchieveView:ReleaseCallBack()
	if self.achieve_data_evt then
		GlobalEventSystem:UnBind(self.achieve_data_evt)
		self.achieve_data_evt = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.achieve_list then
		self.achieve_list:DeleteMe()
		self.achieve_list = nil
	end

	ClientCommonButtonDic[CommonButtonType.ACHIEVE_AWARD_LIST_VIEW] = nil

	if self.btn_list then
		self.btn_list:DeleteMe()
		self.btn_list = nil 
	end

	self.play_eff = nil
	self:MedalDelete()
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.Achieve)
end

function AchieveView:RemindUpAchieveChange(remind_name, num)
	if remind_name == RemindName.AchieveChuangQi then
		self:Flush({0},"changqi")
	elseif remind_name == RemindName.AchieveLoading then
		self:Flush({0},"loading")
	elseif remind_name == RemindName.AchieveGrowUp then
		self:Flush({0},"growup")
	elseif remind_name == RemindName.AchieveXYCM then
		self:Flush({0},"xycm")
	elseif remind_name == RemindName.AchieveCopter then
		self:Flush({0},"copter")
	elseif remind_name == RemindName.AchieveStrengthen then
		self:Flush({0},"strengthen")
	elseif remind_name == RemindName.AchieveJade then
		self:Flush({0},"jade")
	elseif remind_name == RemindName.AchieveGem then
		self:Flush({0},"gem")
	elseif remind_name == RemindName.AchieveWing then
		self:Flush({0},"wing")
	elseif remind_name == RemindName.AchieveAchievement then
		self:Flush({0},"achievementpoints")
	elseif remind_name == RemindName.AchieveMedal then
		self.remind_temp[TabIndex.achieve_medal] = num
		self:Flush({0}, "achievemedal")
	end
end

function AchieveView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.Achieve, self.tabbar)
		self:InitTabbar()
		if not self.achieve_data_evt then
			self.achieve_data_evt = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE, BindTool.Bind(self.UpdateData, self))
		end
	end
	if index == TabIndex.achieve_achievement then
		self:CreateBtn()
		self:CreateAchiveList()
	elseif index == TabIndex.achieve_medal then
		self:MedalInit()
	end	

end

function AchieveView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_common_bg.node, -15, -3,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.Achieve.TabGroup, false, ResPath.GetCommon("toggle_104_normal"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:SetSpaceInterval(20)
	end
end

function AchieveView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

function AchieveView:CreateBtn()
	if nil == self.btn_list then
		local ph = self.ph_list.ph_achievebtn_list
		self.btn_list = ListView.New()
		self.btn_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BtnRender, nil, nil, self.ph_list.ph_btn_item)
		self.btn_list:GetView():setAnchorPoint(0, 0)
		self.btn_list:SetItemsInterval(5)
		self.btn_list:SetMargin(2)
		self.btn_list:SetJumpDirection(ListView.Top)
		self.btn_list:SetDelayCreateCount(10)
		self.btn_list:SetSelectCallBack(BindTool.Bind1(self.SelectCallBack, self))
		self.node_t_list.layout_achivement.node:addChild(self.btn_list:GetView(), 100)

		local min_t = AchieveData.Instance:GetMinIndexT()
		if not min_t then return end
		local data = {}
		for k, v in ipairs(min_t) do
			if k < 8 then
				data[k] = {name = Language.Achieve.Name[k], type = k, min_num = v}
			end
		end

		local function sort_func()
			return function(a, b)
						if a.min_num ~= b.min_num then
							return a.min_num > b.min_num
						else
							return a.type < b.type
						end
					end
		end
		table.sort(data, sort_func())
		self.btn_list:SetDataList(data)
	end	
end

function AchieveView:SelectCallBack(item, btn_index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	-- print("index=========", btn_index)
	-- PrintTable(data)
	self.current_btn_index = btn_index
	self.current_type = data.type
	self:FlushAchieveList(data.type)
	self.achieve_list:SelectIndex(1)
	local min_t = AchieveData.Instance:GetMinIndexT()
	if not min_t then return end
	self.last_selec_min_num = min_t[self.current_type]	
end

function AchieveView:OpenCallBack()
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_btn_index = 1
end

function AchieveView:ShowIndexCallBack(index)	
	if index == TabIndex.achieve_achievement then
		self.btn_list:SelectIndex(1)
	end
	self.tabbar:SelectIndex(index)
	self:Flush(index)
	self:UpdateAchieveMedal()
end

function AchieveView:CloseCallBack()
	EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_btn_index = 1
	self.current_type = 1
	self.last_selec_min_num = 0
end

function AchieveView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			local achievement_points = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE) or 0
			self.node_t_list.txt_achieve_point.node:setString(achievement_points)
			if index == TabIndex.achieve_achievement then
				-- self:UpdateData()
				for i = 1, 7 do
					self:UpdateAchieveRemind(i)
				end
				self:FlushAchieveList(self.current_type)
				self:UpdateAchievement()
			elseif index == TabIndex.achieve_medal then
				self:UpdateAchieveMedal()
				self:MedalOnFlush(param_t, index)
				self:MedalChangeView()
			end	
		elseif k == "money" then
			self:FlushMoney()
		-- elseif k == "changqi" then
		-- 	self:UpdateAchieveRemind(1)
		-- elseif k == "loading" then
		-- 	self:UpdateAchieveRemind(2)
		-- elseif k == "growup" then
		-- 	self:UpdateAchieveRemind(3)
		-- elseif k == "xycm" then
		-- 	self:UpdateAchieveRemind(4)
		-- elseif k == "copter" then
		-- 	self:UpdateAchieveRemind(5)
		-- elseif k == "strengthen" then
		-- 	self:UpdateAchieveRemind(6)
		-- -- elseif k == "jade" then
		-- -- 	self:UpdateAchieveRemind(7)
		-- -- elseif k == "gem" then
		-- -- 	self:UpdateAchieveRemind(8)
		-- elseif k == "wing" then
		-- 	self:UpdateAchieveRemind(7)
		elseif k == "achievementpoints" then
			self:UpdateAchievement()
		elseif k == "achievemedal" then
			self:UpdateAchieveMedal()
		elseif k == "updatemedal" then
			self:UpdateMedal()
		end	
	end
end

function AchieveView:UpdateMedal()
	-- local level_tab = ComposeData.Instance:GetShenQiLevel()
	-- for k, v in pairs(level_tab) do
	-- 	if k == 8 then
	-- 		if v == 1 then
	-- 			self:SetShowPlayEff(901)
	-- 		else
	-- 			self:SetShowPlayEff(902)
	-- 		end
	-- 	end
	-- end
end

function AchieveView:UpdateData()
	local min_t = AchieveData.Instance:GetMinIndexT()
	if not min_t then return end
	if self.last_selec_min_num > 0 and min_t[self.current_type] <= 0 then
		local data = {}
		for k, v in ipairs(min_t) do
			if k < 8 then
				data[k] = {name = Language.Achieve.Name[k], type = k, min_num = v}
			end
		end

		local function sort_func()
			return function(a, b)
						if a.min_num ~= b.min_num then
							return a.min_num > b.min_num
						else
							return a.type < b.type
						end
					end
		end
		table.sort(data, sort_func())
		self.btn_list:SetDataList(data)
		self.btn_list:SelectIndex(1)
	end
end

function AchieveView:UpdateAchievement()
	local achieve_num = AchieveData.Instance:GetAchievementData()
	self.tabbar:SetRemindByIndex(TabIndex.achieve_achievement, achieve_num > 0)
end

function AchieveView:UpdateAchieveMedal()
	for k,v in pairs(self.remind_temp) do
		if k == TabIndex.achieve_medal then
			self.tabbar:SetRemindByIndex(TabIndex.achieve_medal, v > 0)
		end
	end
end

function AchieveView:UpdateAchieveRemind(index)
	if self.btn_list and self.btn_list:GetItemAt(index) then
		self.btn_list:GetItemAt(index):SetRemindFlag()
	end
	local sign_num = AchieveData.Instance:GetSignNum(index)
	if sign_num ~= nil and index ~= TabIndex.achieve_medal then
		if self.tabbar_list ~= nil then
			self.tabbar_list:SetRemindNumByIndex(index, sign_num)
		end
	end
end


--监听装备变化
function AchieveView:EquipmentDataChangeCallback(bool, change_item_id, change_item_index, change_reason)
	self:Flush({TabIndex.achieve_medal})
	self:Flush({TabIndex.achieve_medal}, "updatemedal")
end

--人物属性变化
function AchieveView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_BIND_GOLD or key == OBJ_ATTR.ACTOR_GOLD then
		self:Flush(TabIndex.achieve_medal, "money")
	elseif key == OBJ_ATTR.ACTOR_ACHIEVE_VALUE then
		self:Flush(TabIndex.achieve_medal, TabIndex.achieve_achievement)	
		if self:GetShowIndex() == TabIndex.achieve_medal then
			self:MedalOnFlush()
		end
		local achievement_points = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE) or 0
		self.node_t_list.txt_achieve_point.node:setString(achievement_points)
	end	
end

function AchieveView:MedalChangeView()
	
end

function AchieveView:FlushMoney()
	local bd_yuanbao = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))		--绑定元宝
	local yuanbao = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))				--元宝
	-- self.node_t_list.label_bind_xz_gold_num.node:setString(bd_yuanbao) 
	-- self.node_t_list.label__xz_gold_num.node:setString(yuanbao) 
end

--展示特效
function AchieveView:SetShowPlayEff(eff_id)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.root_node:addChild(self.play_eff, 99)
	end
	self.play_eff:setPosition(360, 390.5)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

--成就
function AchieveView:CreateAchiveList()
	if nil == self.achieve_list then
		local ph = self.ph_list.ph_achieve_list
		self.achieve_list = ListView.New()
		self.achieve_list:Create(ph.x, ph.y, ph.w, ph.h, nil, AchieveRender, nil, nil, self.ph_list.ph_achieve_item)
		self.achieve_list:GetView():setAnchorPoint(0, 0)
		self.achieve_list:SetItemsInterval(5)
		self.achieve_list:SetJumpDirection(ListView.Top)
		self.achieve_list:SetDelayCreateCount(10)
		self.achieve_list:SetMargin(3)
		self.node_t_list.layout_achivement.node:addChild(self.achieve_list:GetView(), 100)
		ClientCommonButtonDic[CommonButtonType.ACHIEVE_AWARD_LIST_VIEW] = self.achieve_list
	end
end

function AchieveView:FlushAchieveList(index)
	local data = AchieveData.Instance:GetAchieveListData(index)
	self.achieve_list:SetDataList(data)
end

function AchieveView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name) 
	end
	if node_name == NodeName.AchieveActbtn then
		return self.btn_activate, true
	end
end

AchieveRender = AchieveRender or BaseClass(BaseRender)
function AchieveRender:__init()
end

function AchieveRender:__delete()	
end

function AchieveRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_get.node, BindTool.Bind1(self.OnClickGetAwardsHandler, self))
end

function AchieveRender:OnClickGetAwardsHandler()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	AchieveCtrl.Instance:SendAchieveRewardReq(self.data.index_id)
end

function AchieveRender:OnFlush()
	if nil == self.data then return end
	local count = nil
	RichTextUtil.ParseRichText(self.node_tree.rich_achieve_name.node, self.data.name)
	--XUI.RichTextSetCenter(self.node_tree.rich_achieve_name.node)
	self.node_tree.txt_achieve_points.node:setString(self.data.award_1)
	self.node_tree.txt_money_count.node:setString(self.data.award_2)
	if self.data.finishs == 1 then
		self.already_complete = true
	else
		self.already_complete = false
	end	
	--完成时
	if self.already_complete then
		self.node_tree.txt_percent.node:setString(self.data.consume.."/"..self.data.consume)
		--self.node_tree.prog9_cj.node:setPercent(self.data.consume/self.data.consume*100)
		self.node_tree.btn_get.node:setVisible(true)
		self.node_tree.img_already_get.node:setVisible(false)
		self.node_tree.img_unsuccess.node:setVisible(false)
	else
		self.node_tree.btn_get.node:setVisible(false)
		self.node_tree.img_already_get.node:setVisible(false)
		self.node_tree.img_unsuccess.node:setVisible(true)
		local num_tab = AchieveData.Instance:GetAchieveFinishCount(self.data.event_id)
		count = num_tab and num_tab.count or 0
		self.node_tree.txt_percent.node:setString(count.."/"..self.data.consume)
		--self.node_tree.prog9_cj.node:setPercent(count/self.data.consume*100)
	end

	if self.data.rewards == 1 then
		self.node_tree.btn_get.node:setVisible(false)
		self.node_tree.img_already_get.node:setVisible(true)
		self.node_tree.img_unsuccess.node:setVisible(false)	
	end		
end

-- function AchieveRender:CreateSelectEffect()
-- 	local size =self.view:getContentSize()
-- 	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_173"), true)
-- 	if nil == self.select_effect then
-- 		ErrorLog("BaseRender:CreateSelectEffect fail")
-- 		return
-- 	end
-- 	self.view:addChild(self.select_effect, 999)
-- end

function AchieveRender:GetGuideView()
	if self.node_tree and self.node_tree.btn_get then
		return self.node_tree.btn_get.node
	end	
	return nil
end


BtnRender = BtnRender or BaseClass(BaseRender)
function BtnRender:__init()
end

function BtnRender:__delete()	
end

function BtnRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.remind_label.node:setVisible(false)

end

function BtnRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_name.node:setString(self.data.name)
	local remind_flag_vis = AchieveData.Instance:GetMinIndex(self.data.type) > 0
	local remind_cnt = AchieveData.Instance:GetSignNum(self.data.type)
	self.node_tree.remind_label.node:setVisible(remind_flag_vis)
	local text = remind_cnt > 0 and remind_cnt or ""
	self.node_tree.remind_num.node:setString(text)
	self.node_tree.icon_bg_1.node:loadTexture(ResPath.GetAchieve("icon_bg_".. self.data.type))
end

function BtnRender:SetRemindFlag()
	if not self.node_tree.remind_label then return end

	local remind_flag_vis = AchieveData.Instance:GetMinIndex(self.data.type) > 0
	local remind_cnt = AchieveData.Instance:GetSignNum(self.data.type)
	self.node_tree.remind_label.node:setVisible(remind_flag_vis)
	local text = remind_cnt > 0 and remind_cnt or ""
	self.node_tree.remind_num.node:setString(text)
end