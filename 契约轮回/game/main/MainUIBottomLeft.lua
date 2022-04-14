-- 
-- @Author: LaoY
-- @Date:   2018-08-31 15:07:04
-- 
MainUIBottomLeft = MainUIBottomLeft or class("MainUIBottomLeft",BaseItem)
local MainUIBottomLeft = MainUIBottomLeft

function MainUIBottomLeft:ctor(parent_node,layer)
	self.abName = "main"
	self.assetName = "MainUIBottomLeft"
	self.layer = layer

	self.isHelpClick = true
	self.model = MainModel:GetInstance()
	MainUIBottomLeft.super.Load(self)
end

function MainUIBottomLeft:dctor()
	self:StopTime()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.exp_component)
	if self.event_id then
		RoleInfoModel:GetInstance():RemoveListener(self.event_id)
		self.event_id = nil
	end

	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	if self.role_update_list then
		for k,event_id in pairs(self.role_update_list) do
			self.role_data:RemoveListener(event_id)
		end
		self.role_update_list = nil
	end
	if self.schedule then
		GlobalSchedule:Stop(self.schedule)
		self.schedule = nil
	end
	
	self.isHelpClick = true
	self:DelExpEffect()
end

function MainUIBottomLeft:LoadCallBack()
	self.nodes = {
		"exp","text_time","img_exp_bg","exp/fill_area","img_battery_icon_charge","img_electricity",
		"text_pattern","img_pattern_bg","btn_mount","btn_dance","exp/fill_area/Fill/effect_con","btn_setting",
		"btn_group","btn_boss","btn_help","btn_help/helpTime",
	}
	self:GetChildren(self.nodes)
	self.exp_component = self.exp:GetComponent('Slider')
	self.text_time_component = self.text_time:GetComponent('Text')

	self.img_electricity_img = self.img_electricity:GetComponent('Image')

	self.img_pattern_bg_component = self.img_pattern_bg:GetComponent('Image')
	self.text_pattern_component = self.text_pattern:GetComponent('Text')
	self.helpTex = GetText(self.helpTime)
	self.help_btn_img = GetImage(self.btn_help)

	local bg_x = GetLocalPositionX(self.img_exp_bg)
	self.img_exp_bgwidth = GetSizeDeltaX(self.img_exp_bg)
	self.exp_width = GetSizeDeltaX(self.exp)
	self.fill_area_width = GetSizeDeltaX(self.fill_area)
	local bg_w = DesignResolutionWidth * g_standardScale_w / g_standardScale - (DesignResolutionWidth*0.5+bg_x)
	SetSizeDeltaX(self.img_exp_bg,bg_w)
	SetSizeDeltaX(self.exp,bg_w-2)
	SetSizeDeltaX(self.fill_area,bg_w-2)

	self.btn_mount_img = self.btn_mount:GetComponent('Image')
	local is_open = OpenTipModel:GetInstance():IsOpenSystem(130, 1)

	SetVisible(self.btn_mount, is_open)
	if self.is_need_setdata then
		self:SetData()
	end

	-- 10113
	-- self.ui_effect

	-- 
	SetVisible(self.btn_dance, false)
	SetVisible(self.btn_help, false)
	self.helpTex.text = ""
	local is_open1 = RoleInfoModel.GetInstance():GetMainRoleLevel() >= 80
	SetVisible(self.btn_group, is_open1)
	self:UpdateBossIcon()
	self:UpdateHelpIcon()
	self:AddEvent()
	
	self:checkAdaptUI()
end

function MainUIBottomLeft:checkAdaptUI()

	UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.btn_mount,-15)
	UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.btn_group,-15)
end

function MainUIBottomLeft:AddEvent()
	local function call_back(target,x,y)
		-- Notify.ShowText("111")
		lua_panelMgr:GetPanelOrCreate(PkModePanel):Open()
	end
	AddClickEvent(self.text_pattern.gameObject,call_back)

	local function call_back(target,x,y)
	    local main_role = SceneManager:GetInstance():GetMainRole()
	    if not main_role then
	    	return
	    end
        if not main_role:IsRiding() then
            --if AutoFightManager:GetInstance():GetAutoFightState() then
            --    Notify.ShowText("自动战斗状态不能骑乘");
            --    return;
            --end
            -- local is_can_mount = SceneConfigManager:GetInstance():GetSceneCanPlayMount()
            -- if not is_can_mount then
            --    	Notify.ShowText("本场景不可骑乘坐骑");
            -- 	return
            -- end
            -- local move_pos = main_role.move_pos
            -- local move_dir = main_role.move_dir
            -- if not main_role.move_state then
            -- 	move_pos = nil
            -- end
            -- local call_back
            -- if move_pos ~= nil then
            --     call_back = function()
            --         main_role:SetMovePosition(move_pos,move_dir)
            --     end
            -- end
            -- main_role:PlayMount(call_back,main_role.is_runing,move_pos)
		    --	SceneConfigManager:GetInstance():GetSceneCanPlayMount()

            main_role:OnClickPlayMount()

        else
            main_role:PlayDismount()
        end
	end
	AddClickEvent(self.btn_mount.gameObject,call_back)


	local function call_back(target,x,y)
		if TeamModel:GetInstance():GetTeamInfo() then
			lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open()
			return ;
		end
		lua_panelMgr:GetPanelOrCreate(TeamListPanel):Open()

	end
	AddClickEvent(self.btn_group.gameObject, call_back)

	local function call_back(target,x,y)
		OpenLink(999,1)
	end
	AddClickEvent(self.btn_setting.gameObject,call_back)

	self.global_event_list = self.global_event_list or {}

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(3,2)
	end
	AddClickEvent(self.btn_boss.gameObject, call_back)
	
	AddClickEvent(self.btn_help.gameObject, handler(self, self.HandleHelpClick))
	
	--切换场景开始
	local function call_back()
		if DungeonModel.GetInstance():IsDungeonScene() then
			SetVisible(self.btn_group.gameObject, false)
		else
			if  RoleInfoModel.GetInstance():GetMainRoleLevel() >= 80 then
				SetVisible(self.btn_group.gameObject, true)
             else
                SetVisible(self.btn_group.gameObject, false)
			end
			
		end
        self:UpdateBossIcon()
		self:UpdateHelpIcon()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)
	
	local function call_back()
		-- self:SetPkMode()

		-- local config = SceneConfigManager:GetInstance():GetDBSceneConfig()
		-- if config and self.role_data then
		-- 	self.role_data:ChangeData("pkmode",config.pkmode)
		-- end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

	local function call_back(bool)
		self:SetMountRes();
        --TODO
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(SceneEvent.ChangeMount, call_back)

	local function call_back()
		local is_open = OpenTipModel:GetInstance():IsOpenSystem(130, 1)
		SetVisible(self.btn_mount, is_open)

		local is_open1 = RoleInfoModel.GetInstance():GetMainRoleLevel() >= 80
		SetVisible(self.btn_group, is_open1)

	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.UpdateOpenFunction, call_back)

	self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	if not self.role_data then
		local function call_back()
			self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
			self:BindRoleUpdate()
			if not self.is_set_data then
				self:SetData()
			end
			RoleInfoModel:GetInstance():RemoveListener(self.event_id)
			self.event_id = nil
		end
		self.event_id = RoleInfoModel:GetInstance():AddListener(RoleInfoEvent.ReceiveRoleInfo,call_back)		
	else
		self:BindRoleUpdate()
		self:SetData()
	end

	local function step()
		self:SetTime()
		self:SetBatteryState()
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
	step()
end

function MainUIBottomLeft:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MainUIBottomLeft:PlayExpEffect()
	if not self.exp_effect then
		self.exp_effect = UIEffect(self.effect_con, 10113, false, self.layer)
	end
end

function MainUIBottomLeft:DelExpEffect()
	if self.exp_effect then
		self.exp_effect:destroy()
		self.exp_effect = nil
	end
end

function MainUIBottomLeft:SetMountRes()
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role:IsRiding() then
    	lua_resMgr:SetImageTexture(self,self.btn_mount_img,"main_image","btn_mount_1",true)
    else
    	lua_resMgr:SetImageTexture(self,self.btn_mount_img,"main_image","btn_mount_2",true)
    end
end

function MainUIBottomLeft:SetBatteryState()
	if self.last_update_tiem and Time.time - self.last_update_tiem <= 2 then
		return
	end
	self.last_update_tiem = Time.time
	local level,state = self:GetBatteryState()
	local str = string.format("img_battery_icon_%s",level)
	if self.cur_battery_res ~= str then
		self.cur_battery_res = str
		lua_resMgr:SetImageTexture(self,self.img_electricity_img,"main_image",str,true)
	end

	if self.cur_battery_state ~= state then
		self.cur_battery_state = state
		SetVisible(self.img_battery_icon_charge,self.cur_battery_state==2)
	end
end

function MainUIBottomLeft:GetBatteryState()
	local battery,state = PlatformManager:GetInstance():GetBatteryState()
	local level = 4
	if battery >= 75 then
		level = 4
	elseif battery >= 50 then
		level = 3
	elseif battery >= 25 then
		level = 2
	elseif battery >= 0 then
		level = 1
	end
	return level,state
end

function MainUIBottomLeft:BindRoleUpdate(data)
	self.role_update_list = self.role_update_list or {}
	local function call_back()
		self:SetExp()
	end
	self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("exp",call_back)
	local function call_back()
		self:SetPkMode()
	end
	self.role_update_list[#self.role_update_list+1] = self.role_data:BindData("pkmode",call_back)
end

function MainUIBottomLeft:SetTime()
	if not self.is_loaded then
		return
	end
	-- local time_date = os.date("*t")
	local time_date = TimeManager:GetInstance():ServerTimeDate()
	local str = string.format("%02d:%02d(UTC+%s)",time_date.hour,time_date.min,TimeManager.ServerTimeZoneIndex)
	self.text_time_component.text = str
end

function MainUIBottomLeft:SetExp()
	if not self.role_data or not self.is_loaded then
		return
	end
	local config = Config.db_role_level[self.role_data.level]
	if not config then
		logWarn("Non-existent db_role_level the level is ",self.role_data.level)
		return
	end
	self:PlayExpEffect()
	local value = self.role_data.exp/config.exp
	value = value > 1 and 1 or value
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.exp_component)
	local value_action = cc.ValueTo(0.1,value)
	value_action = cc.Sequence(value_action,cc.DelayTime(0.5),cc.CallFunc(function()
		self:DelExpEffect()
	end))
	cc.ActionManager:GetInstance():addAction(value_action,self.exp_component)
end

function MainUIBottomLeft:SetPkMode()
	if not self.role_data or not self.is_loaded then
		return
	end
	if self.cur_pkmode == self.role_data.pkmode then
		return
	end	
	if self.cur_pkmode then
		local config = SceneConfigManager.PkModeConfig[self.role_data.pkmode]
		if config then
			Notify.ShowText(config.tip)
		end
	end
	self.cur_pkmode = self.role_data.pkmode
	-- if not self.cur_pkmode then
	-- 	return
	-- end
	local pk_mode = self.cur_pkmode
	local config = SceneConfigManager.PkModeConfig[pk_mode]
	if not config then
		return
	end
	self.text_pattern_component.text = config.name
	local res = config.b_l_res
	if self.pkmode_res == res then
		return
	end
	self.pkmode_res = res
	local res_list = string.split(res,":")
	local abName = res_list[1]
	local assetName = res_list[2]
	lua_resMgr:SetImageTexture(self,self.img_pattern_bg_component,abName,assetName,true)

	GlobalEvent:Brocast(FightEvent.AccPKMode,self.role_data.pkmode)
end

function MainUIBottomLeft:SetData()
	if not self.is_loaded then
		self.is_need_setdata = true
		return
	end
	self.is_need_setdata = false
	self.is_set_data = true

	self:SetExp()
	self:SetPkMode()
end

function MainUIBottomLeft:UpdateBossIcon()
	local id = SceneManager:GetInstance():GetSceneId()
	local val = String2Table(Config.db_game["shop_boss_scene"].val)[1]
	local stype = Config.db_scene[id].stype
	local is_boss =  false
	for i = 1, #val do
		if val[i] == stype then
			is_boss = true
			break
		end
	end

	if is_boss then
		local pos = String2Table(Config.db_game["shop_boss"].val)[1]
		SetVisible(self.btn_boss.gameObject, true)
		SetLocalPosition(self.btn_boss.transform,  pos[1], pos[2])
	else
		SetVisible(self.btn_boss.gameObject, false)
	end
end

--请求支援
function MainUIBottomLeft:UpdateHelpIcon()
	local role  = RoleInfoModel.GetInstance():GetMainRoleData();
	if role.guild == "0" or role.guild == 0  then
		return
	end
	
	local id = SceneManager:GetInstance():GetSceneId()
	local val = String2Table(Config.db_game["support_boss"].val)[1]
	local stype = Config.db_scene[id].stype
	local is_boss =  false
	for i = 1, #val do
		if val[i] == stype then
			is_boss = true
			break
		end
	end
	
	if is_boss then
		local pos = String2Table(Config.db_game["support"].val)[1]
		SetVisible(self.btn_help.gameObject, true)
		SetLocalPosition(self.btn_help.transform,  pos[1], pos[2])
	else
		SetVisible(self.btn_help.gameObject, false)
	end
end

function MainUIBottomLeft:HandleHelpClick()
	if  not self.isHelpClick then
		Notify.ShowText("You asked for help too frequently, please try later")
		return
	end
	self.isHelpClick = false
	if self.schedule then
		GlobalSchedule:Stop(self.schedule)
		self.schedule = nil
	end
	self.HelpTime = 30
	ShaderManager:GetInstance():SetImageGray(self.help_btn_img)
	self:CountDown()
	self.schedule = GlobalSchedule.StartFun(handler(self,self.CountDown), 1, -1)
	DungeonCtrl:GetInstance():RequestSoSInfo()
end

function MainUIBottomLeft:CountDown()
	self.HelpTime = self.HelpTime - 1
	self.helpTex.text = self.HelpTime
	if self.HelpTime <= 0 then
		self.helpTex.text = ""
		self.isHelpClick = true
		ShaderManager:GetInstance():SetImageNormal(self.help_btn_img)
		if self.schedule then
			GlobalSchedule:Stop(self.schedule)
			self.schedule = nil
		end
	end
end