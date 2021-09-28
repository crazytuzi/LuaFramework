require("game/yewaiguaji/yewai_guaji_view")
require("game/yewaiguaji/yewai_guaji_data")
require("game/guaji/guaji_ctrl")
require("game/guaji/guaji_data")
YewaiGuajiCtrl = YewaiGuajiCtrl or BaseClass(BaseController)

function YewaiGuajiCtrl:__init()
	if nil ~= YewaiGuajiCtrl.Instance then
		print_error("[YewaiGuajiCtrl] Attemp to create a singleton twice !")
		return
	end
	YewaiGuajiCtrl.Instance = self
	self.yewai_guaji_ctrl_view = YewaiGuajiView.New(ViewName.YewaiGuajiView)
	self.yewai_guaji_ctrl_data = YewaiGuajiData.New()

	self.activity_callback = BindTool.Bind(self.OnActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_callback)
	self:RegisterAllProtocols()
end

function YewaiGuajiCtrl:__delete()
	if self.yewai_guaji_ctrl_view ~= nil then
		self.yewai_guaji_ctrl_view:DeleteMe()
		self.yewai_guaji_ctrl_view = nil
	end
	if self.yewai_guaji_ctrl_data ~= nil then
		self.yewai_guaji_ctrl_data:DeleteMe()
		self.yewai_guaji_ctrl_data = nil
	end

	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_callback)
	self.activity_callback = nil

	YewaiGuajiCtrl.Instance = nil
end

function YewaiGuajiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGuajiBossCount, "OnGuajiBossCount")
	self:RegisterProtocol(CSGetGuajiBossCount)
	self:RegisterProtocol(SCGuajiBossRefresh, "OnGuajiBossRefresh")
end

--请求挂机场景中BOSS状态
function YewaiGuajiCtrl:SendGuajiBossCountReq(scene_id_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetGuajiBossCount)
	send_protocol.scene_id_list = scene_id_list or {}
	send_protocol:EncodeAndSend()
end

--挂机场景中有多少个BOSS处于已刷新状态
function YewaiGuajiCtrl:OnGuajiBossCount(protocol)
	self.yewai_guaji_ctrl_data:SetSceneBossInfo(protocol)
	if self.yewai_guaji_ctrl_view:IsOpen() then
		self.yewai_guaji_ctrl_view:SetSceneBossCount()
	end
end

function YewaiGuajiCtrl:GoGuaji(scene_id, x, y)
	GuajiCtrl.Instance:StopGuaji()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
	self.yewai_guaji_ctrl_view:CloseView()
	MainUICtrl.Instance:IsShowMonsterButton(true)
	MainUICtrl.Instance:IsShowMonsterKillTip()
end

function YewaiGuajiCtrl:SetCurHasKillBossCount(value)
	if value then
		local old_data = self.yewai_guaji_ctrl_data:GetCurHasKillBossCount()
		if value ~= old_data then
			self.yewai_guaji_ctrl_data:SetCurHasKillBossCount(value)
		end
		
	end
end

--挂机场景中有多少个BOSS处于已刷新状态
function YewaiGuajiCtrl:OnGuajiBossRefresh(protocol)
	local scene_id = protocol.scene_id
	local boss_id = protocol.boss_id
	local pos_x, pos_y = self.yewai_guaji_ctrl_data:GetBossPosition(scene_id, boss_id)
	if nil ~= pos_x and nil ~= pos_y then
		local function callback()
			self.yewai_guaji_ctrl_data:SetGuaJiSceneId(scene_id)
			KuafuGuildBattleCtrl.Instance:CSReqMonsterGeneraterList(scene_id)
			self:GoGuaji(scene_id, pos_x, pos_y)
			-- GuajiCtrl.Instance:FlyToScenePos(scene_id, pos_x, pos_y, 0)
		end
--		BossCtrl.Instance:SetOtherBossTips(protocol.boss_id, callback, "GuaJiBossView", BOSS_ENTER_TYPE.GUA_JI_BOSS)
	end
end

function YewaiGuajiCtrl:OnActivityChangeCallBack(activity_type, status, next_time, open_type)
	if activity_type ~= ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI then
		return
	end
	if status == ACTIVITY_STATUS.STANDY then

	end
	if status == ACTIVITY_STATUS.OPEN then
		local scene_id = Scene.Instance:GetSceneId()
		if YewaiGuajiData.Instance:IsGuaJiScene(scene_id) then
			FuBenCtrl.Instance:GetFuBenIconView():Open()
			FuBenCtrl.Instance:GetFuBenIconView():Flush()
			GlobalEventSystem:Fire(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW, false)
		end
	end

	if status == ACTIVITY_STATUS.CLOSE then
		local scene_id = Scene.Instance:GetSceneId()
		if YewaiGuajiData.Instance:IsGuaJiScene(scene_id) then
			FuBenCtrl.Instance:GetFuBenIconView():Close()
			MainUICtrl.Instance:SetViewState(true)
			GlobalEventSystem:Fire(SceneEventType.SHOW_MAINUI_RIGHT_UP_VIEW, true)
		end
	end

	self.yewai_guaji_ctrl_data:SetTripleExpFlag(status)
	self.yewai_guaji_ctrl_view:Flush()
end