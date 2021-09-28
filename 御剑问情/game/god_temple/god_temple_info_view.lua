GodTempleInfoView = GodTempleInfoView or BaseClass(BaseView)

function GodTempleInfoView:__init()
	self.ui_config = {"uis/views/godtemple_prefab", "GodTempleFBInFoView"}
	self.view_layer = UiLayer.MainUILow

	self.item_data = {}
	self.item_cells = {}
	self.temp_level = nil
	self.temp_change_level = nil
	self.active_close = false
end

function GodTempleInfoView:__delete()
end

function GodTempleInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.fuben_info_change ~= nil then
		GlobalEventSystem:UnBind(self.fuben_info_change)
		self.fuben_info_change = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.fb_name = nil
	self.monster_name = nil
	self.special_reward_level = nil
	self.fight_power = nil
	self.show_panel = nil
	self.tong_guan_des = nil
	self.power_color = nil
	self.shenqi_power = nil
end

function GodTempleInfoView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.monster_name = self:FindVariable("Require1")
	self.special_reward_level = self:FindVariable("SpecailRewardLevel") 	--下一个特殊奖励层数
	self.fight_power = self:FindVariable("FightPower")
	self.tong_guan_des = self:FindVariable("TongGuanDes")
	self.power_color = self:FindVariable("PowerColor")
	self.shenqi_power = self:FindVariable("ShenQiPower")

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self.show_panel = self:FindVariable("ShowPanel")
end

function GodTempleInfoView:OpenCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.fuben_info_change = GlobalEventSystem:Bind(FuBenEventType.FUBEN_INFO_CHANGE,
		BindTool.Bind(self.FuBenInfoChange, self))

	self:Flush()
end

function GodTempleInfoView:CloseCallBack()
	if self.fuben_info_change ~= nil then
		GlobalEventSystem:UnBind(self.fuben_info_change)
		self.fuben_info_change = nil
	end

	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function GodTempleInfoView:FuBenInfoChange(scene_type)
	if scene_type == SceneType.GodTemple then
		local fuben_info = FuBenData.Instance:GetFBSceneLogicInfo()
		if fuben_info.is_finish == 1 and fuben_info.is_pass == 0 then
			--失败了，弹出失败面板
			ViewManager.Instance:Open(ViewName.FBFailFinishView)
		elseif fuben_info.is_pass == 1 then
			--成功了，判断能否继续下一关
			local shenqi_is_level_up = GodTempleShenQiData.Instance:IsLevelUp()
			if shenqi_is_level_up then
				--神器升级
				ViewManager.Instance:Open(ViewName.GodTempleActiveTipView)
				return
			end

			local today_layer = GodTemplePataData.Instance:GetTodayLayer()
			local next_layer_info = GodTemplePataData.Instance:GetLayerCfgInfo(today_layer + 1)
			if next_layer_info == nil then
				--已通关最高层数，弹出胜利界面，退出副本
				local call_back = function ()
					ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish")
				end
				TimeScaleService.StartTimeScale(call_back)
			else
				--未通过最高层数，弹出是否继续下一关的界面
				local function ok_func()
					Camera.Instance:SetCameraTransformByName("pata", 0.1)

					GlobalTimerQuest:AddDelayTimer(function ()
						Camera.Instance:Reset(0.1)
					end, 2)

					GlobalTimerQuest:AddDelayTimer(function ()
						FuBenCtrl.Instance:SendEnterNextFBReq()
					end, 2.5)
				end
				local function canel_func()
					FuBenCtrl.Instance:SendExitFBReq()
				end
				TipsCtrl.Instance:TipsPaTaView(canel_func, ok_func, next_layer_info.capability)
			end
		else
			self:Flush()
		end
	end
end

function GodTempleInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function GodTempleInfoView:FlushView()
	local layer_info = GodTemplePataData.Instance:GetLayerCfgInfo()
	if layer_info == nil then
		return
	end

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local color = TEXT_COLOR.GREEN
	if main_vo.capability < layer_info.capability then
		color = TEXT_COLOR.RED
	end
	self.power_color:SetValue(color)
	self.fight_power:SetValue(layer_info.capability)

	self.fb_name:SetValue(layer_info.level)

	local monster_cfg = BossData.Instance:GetMonsterInfo(layer_info.boss_id)
	if monster_cfg then
		self.monster_name:SetValue(monster_cfg.name)
	end

	--设置特殊奖励激活条件
	local active_info = GodTemplePataData.Instance:GetNextActiveShenQiLayerInfoByLayer()
	if active_info then
		self.special_reward_level:SetValue(active_info.level)
	end

	--设置奖励（如果已经通关过则显示每日奖励，没有则显示首次奖励）
	local pass_layer = GodTemplePataData.Instance:GetPassLayer()
	local today_layer = GodTemplePataData.Instance:GetTodayLayer()
	local reward_list = {}
	local tong_guan_des = Language.FB.NormalReward
	if pass_layer > today_layer then
		--显示每日奖励
		reward_list = layer_info.show_reward
	else
		--显示首通奖励
		reward_list = layer_info.first_reward
		tong_guan_des = Language.FB.FirstReward
	end
	for k, v in ipairs(self.item_cells) do
		if reward_list[k - 1] then
			v:SetParentActive(true)
			v:SetData(reward_list[k - 1])
		else
			v:SetParentActive(false)
		end
	end

	self.tong_guan_des:SetValue(tong_guan_des)

	local shenqi_level = GodTempleShenQiData.Instance:GetShenQiLevel()
	local shenqi_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel(shenqi_level + 1)
	if shenqi_info then
		self.shenqi_power:SetValue(CommonDataManager.GetCapabilityCalculation(shenqi_info))
	end
end

function GodTempleInfoView:OnFlush()
	self:FlushView()
end