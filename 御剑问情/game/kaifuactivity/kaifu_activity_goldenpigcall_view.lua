KaifuActivityGoldenPigCallView = KaifuActivityGoldenPigCallView or BaseClass(BaseRender)

function KaifuActivityGoldenPigCallView:__init()
    self.text_left_call_num = self:FindVariable("text_left_call_num")
	self.text_cur_gold_num = self:FindVariable("text_cur_gold_num")
	self.rest_time = self:FindVariable("rest_time")
	self.need_diamond_num = self:FindVariable("need_diamond_num")
	self.power = self:FindVariable("power")
	self.model_name = self:FindVariable("model_name")

	--self.show_pointred = self:FindVariable("show_pointred")


	self.call_award_list = {}
	self.join_award_list = {}
	self.text_call_num_list = {}
	self.text_button_list = {}
	self.show_pointred_list = {}
	self.next_timer = nil
    self:FlushNextTime()
	for i = 1, 3 do
		self["text_call_num" .. i] = self:FindVariable("text_call_num" .. i) 
        table.insert(self.text_call_num_list, self["text_call_num" .. i])

        self["text_button" .. i] = self:FindVariable("text_button" .. i)
        table.insert(self.text_button_list, self["text_button" .. i])

        self["show_pointred".. i] = self:FindVariable("show_pointred" .. i)
        table.insert(self.show_pointred_list, self["show_pointred" .. i])

		local call_award_item = ItemCell.New()
		call_award_item:SetInstanceParent(self:FindObj("call_award" .. i))
        call_award_item:SetData(nil)

		local join_award_item = ItemCell.New()
		join_award_item:SetInstanceParent(self:FindObj("join_award" .. i))
		join_award_item:SetData(nil)

		table.insert(self.call_award_list, call_award_item)
		table.insert(self.join_award_list, join_award_item)
		self:ListenEvent("BtnCallitem" .. i,BindTool.Bind(self.OnClickBtnCallItem, self, i))
	end
    
    self:ListenEvent("OpenHelp",BindTool.Bind1(self.OpenHelp, self))

    self.mount_display = self:FindObj("model")
	self.model_view = RoleModel.New("goldenpigcall_panel")
	self.model_view:SetDisplay(self.mount_display.ui3d_display)

	self.name_list = {
		[0] = "junior",
		[1] = "medium",
		[2] = "senior",
	}
end

function KaifuActivityGoldenPigCallView:__delete()
    for k, v in pairs(self.call_award_list) do
            v:DeleteMe()
    end

    for k, v in pairs(self.join_award_list) do
            v:DeleteMe()
    end

	self.text_left_call_num = nil
	self.text_cur_gold_num = nil
	self.mount_display = nil
	self.need_diamond_num = nil
	self.power = nil
	self.model_name = nil

	self.call_award_list = {}
	self.join_award_list = {}
	self.text_call_num_list = {}
	self.text_button_list = {}
	self.show_pointred_list = {}
	 
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	self.name_list = nil

end

function KaifuActivityGoldenPigCallView:OnFlush()
    local left_num_info = KaifuActivityData.Instance:GetGoldenPigCallInfo()
    self.text_left_call_num:SetValue(left_num_info.summon_credit or 0)
    self.text_cur_gold_num:SetValue(left_num_info.current_chongzhi or 0)

    --每种召唤需要的积分显示
	local basic_cfg = KaifuActivityData.Instance:GetGoldenPigBasisCfg()
	for i = 1, 3 do
		local call_name = self.name_list[i-1] .. "_summon_consume"
		self.text_call_num_list[i]:SetValue(basic_cfg[1][call_name]) 
	end
	self.need_diamond_num:SetValue(basic_cfg[1].gold_consume or 0)

  --召唤奖励和参与奖励图片显示
	local item_img_list = KaifuActivityData.Instance:GetCurCallCfg()
	if nil == item_img_list then return end
	for i, v in ipairs(item_img_list) do
		local call_table = v.summon_reward
		self.call_award_list[i]:SetData(call_table)
		self.call_award_list[i]:IsDestoryActivityEffect(false)
		self.call_award_list[i]:SetActivityEffect()
		local join_table = v.joiner_reward
		self.join_award_list[i]:SetData(join_table)
	end

	if self.next_timer == nil then

		self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
	end
	
	self:ChangeRoleModel(item_img_list[1])
	self.power:SetValue(item_img_list[1].power or 0)
	self.model_name:SetValue(item_img_list[1].model_name or 0) 

	 --Boss是否出现，出现显示前往击杀，未出现显示XX召唤  0不存在,1存在
    local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	for i = 1, 3 do
		self.text_button_list[i]:SetValue(Language.Activity.BossCallNameList[i])
		self.show_pointred_list[i]:SetValue(false)
	end
    if nil ~= boss_state_info then
	    for i, v in ipairs(boss_state_info) do
	    	if v == 1 then
	    		self.text_button_list[i]:SetValue(Language.Activity.GoFindBoss)
	    		local level = GameVoManager.Instance:GetMainRoleVo().level
	    		self.show_pointred_list[i]:SetValue(level >= 170)
	    	end
	    end
	end
 end

function KaifuActivityGoldenPigCallView:FlushNextTime()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_GOLDEN_PIG
	local left_time = ActivityData.Instance:GetActivityResidueTime(activity_type)
	local left_day = math.floor(left_time / 86400)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(left_time, 8)
	else
		time_str = TimeUtil.FormatSecond(left_time)
	end
	self.rest_time:SetValue(time_str)

 end

function KaifuActivityGoldenPigCallView:OnClickBtnCallItem(index)
	local boss_state_info = KaifuActivityData.Instance:GetGoldenPigCallBossInfo()
	if boss_state_info[index] == 1 then
		KaifuActivityCtrl.Instance:CloseKaiFuView()
	   	local golden_cfg = KaifuActivityData.Instance:GetGoldenCallPositionCfg(index - 1)		
		GuajiCtrl.Instance:FlyToScenePos(golden_cfg.scene_id, golden_cfg.pos_x, golden_cfg.pos_y, false, 0)
		return
	end

	
	local callindex = index - 1
	local left_num_info = KaifuActivityData.Instance:GetGoldenPigCallInfo()
	local left_call_num = left_num_info.summon_credit
	local basic_cfg = KaifuActivityData.Instance:GetGoldenPigBasisCfg()
	local need_call_num = basic_cfg[1][self.name_list[callindex] .. "_summon_consume"]
	if left_call_num < need_call_num then
		TipsCtrl.Instance:ShowLackJiFenView()
		return
	end

	KaifuActivityCtrl.Instance:SendGoldenPigCallInfoReq(GOLDEN_PIG_OPERATE_TYPE.GOLDEN_PIG_OPERATE_TYPE_SUMMON, callindex)
    return
end

function KaifuActivityGoldenPigCallView:OpenHelp()
	local tips_id = 198
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--模型显示
function  KaifuActivityGoldenPigCallView:ChangeRoleModel(cur_cfg)
	if nil == cur_cfg or nil == cur_cfg.path then
		return
	end
	local show_model = cur_cfg.show_model
	local bundle = cur_cfg.path
	local asset = cur_cfg.show_item
	
	if show_model == DISPLAY_TYPE.HALO then
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetHaloResid(asset)
	elseif show_model == DISPLAY_TYPE.XIAN_NV then
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetTrigger("show_idle_1")
	elseif show_model == DISPLAY_TYPE.MOUNT then
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetTrigger("rest")
	elseif show_model == DISPLAY_TYPE.WING then
		local main_role = Scene.Instance:GetMainRole()
		self.model_view:SetRoleResid(main_role:GetRoleResId())
		self.model_view:SetWingResid(asset)
	elseif show_model == DISPLAY_TYPE.WEAPON then
		self.model_view:SetMainAsset(bundle, asset)
	elseif show_model == DISPLAY_TYPE.GATHER then
		self.model_view:SetMainAsset(bundle, asset)
	elseif show_model == DISPLAY_TYPE.ZHIBAO then
		self.model_view:SetMainAsset(bundle, asset .. "_L")
	else
		local rotation = Vector3(0, 0, 0)
		self.model_view:SetMainAsset(bundle, asset)
		self.model_view:SetRotation(rotation)
	end

end