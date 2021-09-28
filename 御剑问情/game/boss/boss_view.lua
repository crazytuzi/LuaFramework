require("game/boss/world_boss_view")
require("game/boss/kf_boss_view")
require("game/boss/dabao_boss_view")
require("game/boss/miku_boss_view")
require("game/boss/boss_family_view")
require("game/boss/boss_active_view")
require("game/boss/secret_boss_view")
require("game/boss/xianjie_boss_view")
require("game/boss/baby_boss_view")
require("game/boss/drop_view")
require("game/boss/boss_data")

local NextReqTime = {
	[BOSS_ENTER_TYPE.TYPE_BOSS_WORLD] = 0,
	[BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY] = 0,
	[BOSS_ENTER_TYPE.TYPE_BOSS_MIKU] = 0,
	[BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE] = 0,
	[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE] = 0,
	[BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS] = 0,
	[BOSS_ENTER_TYPE.XIAN_JIE_BOSS] = 0,
}

local NEXT_TIME = 5

BossView = BossView or BaseClass(BaseView)

BossView.CACHE_LAYER_INDEX = -1
function BossView:__init()
	self.full_screen = true								-- 是否是全屏界面
	self.ui_config = {"uis/views/bossview_prefab","BossView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenBoss)
	end
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function BossView:ReleaseCallBack()
	if self.world_boss_view then
		self.world_boss_view:DeleteMe()
		self.world_boss_view = nil
	end

	if self.miku_boss_view then
		self.miku_boss_view:DeleteMe()
		self.miku_boss_view = nil
	end
	if self.active_boss_view then
		self.active_boss_view:DeleteMe()
		self.active_boss_view = nil
	end
	if self.vip_boss_view then
		self.vip_boss_view:DeleteMe()
		self.vip_boss_view = nil
	end
	if self.secret_boss_view then
		self.secret_boss_view:DeleteMe()
		self.secret_boss_view = nil
	end
	if self.xianjie_boss_view then
		self.xianjie_boss_view:DeleteMe()
		self.xianjie_boss_view = nil
	end

	if self.baby_boss_view then
		self.baby_boss_view:DeleteMe()
		self.baby_boss_view = nil
	end

	if self.drop_content_view then
		self.drop_content_view:DeleteMe()
		self.drop_content_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Boss)
	end

	-- 清理变量和对象
	self.nowpanelboss_num = nil
	self.gold = nil
	self.bind_gold = nil
	self.tab_world_boss = nil
	self.tab_miku_boss = nil
	self.tab_active_boss = nil
	self.tab_secret_boss = nil
	self.tab_baby_boss = nil
	self.show_miku_red_point = nil
	self.show_active_red_point = nil
	self.show_secret_red_point = nil
	self.fatigue_guide = nil
	self.xianjie_panel = nil
	self.show_xianjie_red_point = nil
	self.show_vip_red_point = nil
	self.show_baby_red_point = nil
	self.tab_xianjie_boss = nil
	self.world_boss_panel = nil
	self.active_boss_panel = nil
	self.vip_boss_panel = nil
	self.miku_boss_panel = nil
	self.secret_boss_panel = nil
	self.baby_panel = nil
	self.tab_vip_boss = nil
	self.drop_panel = nil
	self.tab_drop = nil
end

function BossView:LoadCallBack()
	self.world_boss_panel = self:FindObj("WorldBossPanel")
	self.active_boss_panel = self:FindObj("ActivePanel")
	self.vip_boss_panel = self:FindObj("VipPanel")
	self.miku_boss_panel = self:FindObj("MikuPanel")
	self.secret_boss_panel = self:FindObj("SecretPanel")
	self.xianjie_panel = self:FindObj("XianJiePanel")
	self.baby_panel = self:FindObj("BabyPanel")
	self.drop_panel = self:FindObj("DropPanel")

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")
	self.show_miku_red_point = self:FindVariable("show_miku_red_point")
	self.show_active_red_point = self:FindVariable("show_active_red_point")
	self.show_secret_red_point = self:FindVariable("show_secret_red_point")
	self.show_xianjie_red_point = self:FindVariable("show_xianjie_red_point")
	self.show_vip_red_point = self:FindVariable("show_vip_red_point")
	self.show_baby_red_point = self:FindVariable("show_baby_red_point")

	self.tab_world_boss = self:FindObj("TabWorldBoss")
	self.tab_miku_boss = self:FindObj("TabMiku")
	self.tab_vip_boss = self:FindObj("TabVip")
	self.tab_active_boss = self:FindObj("TabActive")
	self.tab_secret_boss = self:FindObj("TabSecret")
	self.tab_xianjie_boss = self:FindObj("TabXianJieBoss")
	self.tab_baby_boss = self:FindObj("TabBaby")
	self.tab_drop = self:FindObj("TabDrop")

	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))

	self:ListenEvent("OpenWorldBoss", BindTool.Bind(self.OpenWorldBoss, self))
	self:ListenEvent("OpenMiKuBoss", BindTool.Bind(self.OpenMiKuBoss, self))
	self:ListenEvent("OpenActiveBoss", BindTool.Bind(self.OpenActiveBoss, self))
	self:ListenEvent("OpenSecretBoss", BindTool.Bind(self.OpenSecretBoss, self))
	self:ListenEvent("OpenXianJieBoss", BindTool.Bind(self.OpenXianJieBoss, self))
	self:ListenEvent("OpenBabyBoss", BindTool.Bind(self.OpenBabyBoss, self))
	self:ListenEvent("OpenVipBoss", BindTool.Bind(self.OpenVipBoss, self))
	self:ListenEvent("OpenDrop", BindTool.Bind(self.OpenDrop, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Boss, BindTool.Bind(self.GetUiCallBack, self))
end

function BossView:HandleClose()
	self:Close()
end

function BossView:GetMiKuView()
	return self.miku_boss_view
end

function BossView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function BossView:ReqBossInfoByType(boss_type)
	if 0 == NextReqTime[boss_type] or NextReqTime[boss_type] < TimeCtrl.Instance:GetServerTime() then
		NextReqTime[boss_type] = TimeCtrl.Instance:GetServerTime() + NEXT_TIME
		if boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_WORLD then
			BossCtrl.Instance:SendGetWorldBossInfo(1)
		else
			BossCtrl.SendGetBossInfoReq(boss_type)
		end
	end
end

function BossView:OpenWorldBoss()
	-- self:ReqBossInfoByType(BOSS_ENTER_TYPE.TYPE_BOSS_WORLD)

	if self.show_index == TabIndex.world_boss then
		return
	end
	self:ShowIndex(TabIndex.world_boss)
end

function BossView:OpenMiKuBoss()
	self:ReqBossInfoByType(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)

	if self.show_index == TabIndex.miku_boss then
		return
	end
	self:ShowIndex(TabIndex.miku_boss)
end

function BossView:OpenDrop()
	if self.show_index ~= TabIndex.drop then
		--请求掉落日志
		BossCtrl.Instance:RequestDropLog()
	end

	self:ShowIndex(TabIndex.drop)
end

function BossView:OpenVipBoss()
	self:ReqBossInfoByType(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)

	if self.show_index == TabIndex.vip_boss then
		return
	end
	self:ShowIndex(TabIndex.vip_boss)
end

function BossView:OpenActiveBoss()
	self:ReqBossInfoByType(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)

	if self.show_index == TabIndex.active_boss then
		return
	end
	self:ShowIndex(TabIndex.active_boss)
end

function BossView:OpenSecretBoss()
	-- self:ReqBossInfoByType()

	if self.show_index == TabIndex.secret_boss then
		return
	end
	self:ShowIndex(TabIndex.secret_boss)
end

function BossView:OpenXianJieBoss()
	self:ReqBossInfoByType(BOSS_ENTER_TYPE.XIAN_JIE_BOSS)

	if self.show_index == TabIndex.xianjie_boss then
		return
	end
	self:ShowIndex(TabIndex.xianjie_boss)
end

function BossView:OpenBabyBoss()
	if self.show_index == TabIndex.baby_boss then
		return
	end
	self:ShowIndex(TabIndex.baby_boss)
end

function BossView:OnFlush(param_t)
	if param_t["index"] then
		BossView.CACHE_LAYER_INDEX = tonumber(param_t["index"].layer) or -1
	end
	for k,v in pairs(param_t) do
		if (k == "boss" or k == "boss_list") and self.show_index == TabIndex.world_boss then
			if self.world_boss_view then
				self.world_boss_view:FlushBossView()
			end
		elseif k == "active_boss" and self.show_index == TabIndex.active_boss then
			if self.active_boss_view then
				self.active_boss_view:FlushBossView()
			end
		elseif k == "vip_boss" and self.show_index == TabIndex.vip_boss then
			if self.vip_boss_view then
				self.vip_boss_view:FlushBossView()
			end
		elseif k == "miku_boss" and self.show_index == TabIndex.miku_boss then
			if self.miku_boss_view then
				self.miku_boss_view:FlushBossView()
			end
		elseif k == "secret_boss" and self.show_index == TabIndex.secret_boss then
			if self.secret_boss_view then
				self.secret_boss_view:FlushBossView()
			end
		elseif k == "xianjie_boss" and self.show_index == TabIndex.xianjie_boss then
			if self.xianjie_boss_view then
				self.xianjie_boss_view:FlushView()
			end
		elseif k == "xianjie_boss_init" and self.show_index == TabIndex.xianjie_boss then
			if self.xianjie_boss_view then
				self.xianjie_boss_view:InitView()
			end
		elseif k == "baby_boss" and self.show_index == TabIndex.baby_boss then
			if self.baby_boss_view then
				self.baby_boss_view:FlushBossView()
				self.baby_boss_view:FlushInfoList()
			end
		elseif k == "drop" and self.show_index == TabIndex.drop then
			if self.drop_content_view then
				self.drop_content_view:FlushView()
			end
		end
	end

	local boss_data = BossData.Instance
	self.show_miku_red_point:SetValue(boss_data:GetMiKuRedPoint())
	self.show_active_red_point:SetValue(boss_data:GetActiveRedPoint())
	self.show_secret_red_point:SetValue(boss_data:GetSecretRedPoint())
	self.show_vip_red_point:SetValue(boss_data:GetVipRedPoint())
	self.show_baby_red_point:SetValue(boss_data:GetBabyRedPoint())
end


function BossView:AsyncLoadView(index)
	if index == TabIndex.world_boss and not self.world_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "BossPanel",
			function(obj)
				obj.transform:SetParent(self.world_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.world_boss_view = WorldBossView.New(obj)
				self:Flush("boss")
			end)
	elseif index == TabIndex.active_boss and not self.active_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "ActivePanel",
			function(obj)
				obj.transform:SetParent(self.active_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.active_boss_view = BossActiveView.New(obj)
				self:Flush("active_boss")
			end)
	elseif index == TabIndex.vip_boss and not self.vip_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "FamilyPanel",
			function(obj)
				obj.transform:SetParent(self.vip_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.vip_boss_view = BossFamilyView.New(obj)
				self:Flush("vip_boss")
			end)
	elseif index == TabIndex.miku_boss and not self.miku_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "MikuPanel",
			function(obj)
				obj.transform:SetParent(self.miku_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.miku_boss_view = MikuBossView.New(obj)
				self:Flush("miku_boss")

				--引导用按钮
				self.fatigue_guide = self.miku_boss_view.fatigue_guide
			end)
	elseif index == TabIndex.secret_boss and not self.secret_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "SecretBossPanel",
			function(obj)
				obj.transform:SetParent(self.secret_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.secret_boss_view = SecretBossView.New(obj)
				self.secret_boss_view:InitView()
				self:Flush("secret_boss")
			end)
	elseif index == TabIndex.xianjie_boss and not self.xianjie_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "XianJiePanel",
			function(obj)
				obj.transform:SetParent(self.xianjie_panel.transform, false)
				obj = U3DObject(obj)
				self.xianjie_boss_view = XianJieBossView.New(obj)
				self:Flush("xianjie_boss_init")
			end)
	elseif index == TabIndex.baby_boss and not self.baby_boss_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "BabyPanel",
			function(obj)
				obj.transform:SetParent(self.baby_panel.transform, false)
				obj = U3DObject(obj)
				self.baby_boss_view = BabyBossView.New(obj)
				self:Flush("baby_boss")
			end)
	elseif index == TabIndex.drop and not self.drop_content_view then
		UtilU3d.PrefabLoad("uis/views/bossview_prefab", "DropPanel",
			function(obj)
				obj.transform:SetParent(self.drop_panel.transform, false)
				obj = U3DObject(obj)
				self.drop_content_view = DropContentView.New(obj)
				self:Flush("drop")
			end)
	end

	if index ~= TabIndex.world_boss and self.world_boss_view then
		self.world_boss_view:ChangeOpenState(false)
	end
end
function BossView:ShowIndexCallBack(index)
	self.show_index = index

	self:AsyncLoadView(index)
	if index == TabIndex.world_boss then
		if not self.tab_world_boss.toggle.isOn then
			self.tab_world_boss.toggle.isOn = true
		end
		self:Flush("boss")
	elseif index == TabIndex.miku_boss then
		if not self.tab_miku_boss.toggle.isOn then
			self.tab_miku_boss.toggle.isOn = true
		end
		self.watched = true
		self:Flush("miku_boss")
	elseif index == TabIndex.vip_boss then
		if not self.tab_vip_boss.toggle.isOn then
			self.tab_vip_boss.toggle.isOn = true
		end
		self.watched = true
		self:Flush("vip_boss")
	elseif index == TabIndex.active_boss then
		self:Flush("active_boss")
		if not self.tab_active_boss.toggle.isOn then
			self.tab_active_boss.toggle.isOn = true
		end
	elseif index == TabIndex.secret_boss then
		self:Flush("secret_boss")
		if not self.tab_secret_boss.toggle.isOn then
			self.tab_secret_boss.toggle.isOn = true
		end
	elseif index == TabIndex.xianjie_boss then
		self.tab_xianjie_boss.toggle.isOn = true
		self:Flush("xianjie_boss_init")
	elseif index == TabIndex.baby_boss then
		self.tab_baby_boss.toggle.isOn = true
		self:Flush("baby_boss")
	elseif index == TabIndex.drop then
		--请求掉落日志
		BossCtrl.Instance:RequestDropLog()

		self.tab_drop.toggle.isOn = true
		self:Flush("drop")

	else
		self:ShowIndex(TabIndex.world_boss)
	end
end

function BossView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.world_boss_view then
		self.world_boss_view:CloseBossView()
	end
	if self.miku_boss_view then
		self.miku_boss_view:CloseBossView()
	end
	if self.active_boss_view then
		self.active_boss_view:CloseBossView()
	end
	if self.vip_boss_view then
		self.vip_boss_view:CloseBossView()
	end
	if self.baby_boss_view then
		self.baby_boss_view:CloseBossView()
	end
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function BossView:OpenCallBack()
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:ShowOrHideTab()
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))

	--请求仙戒boss信息
	BossCtrl.Instance:RequestXianjieBossInfo()

	--请求宝宝boss信息
	BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_ROLE_INFO_REQ)   -- 请求宝宝boss人物信息
end

function BossView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_world_boss:SetActive(open_fun_data:CheckIsHide("world_boss"))
	self.tab_miku_boss:SetActive(open_fun_data:CheckIsHide("miku_boss"))
	self.tab_vip_boss:SetActive(open_fun_data:CheckIsHide("vip_boss"))
	self.tab_secret_boss:SetActive(open_fun_data:CheckIsHide("secret_boss"))
	self.tab_xianjie_boss:SetActive(open_fun_data:CheckIsHide("xianjie_boss"))
	self.tab_baby_boss:SetActive(open_fun_data:CheckIsHide("baby_boss"))
end

function BossView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(vo.gold))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(vo.bind_gold))
	end
end

function BossView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.miku_boss then
		self.tab_miku_boss.toggle.isOn = true
	end
end

function BossView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == TabIndex.miku_boss then
			if self.tab_miku_boss.gameObject.activeInHierarchy then
				if self.tab_miku_boss.toggle.isOn then
					return NextGuideStepFlag
				else
					local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.miku_boss)
					return self.tab_miku_boss, callback
				end
			end
		end
	elseif ui_name == GuideUIName.BossGuideFatigue then
		if self.fatigue_guide and self.fatigue_guide.gameObject.activeInHierarchy then
			return self.fatigue_guide
		end
	end
end