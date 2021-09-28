CombineServerBossLogic = CombineServerBossLogic or BaseClass(BaseFbLogic)

function CombineServerBossLogic:__init()
	-- -- 监听系统事件
	-- self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,
	-- 	BindTool.Bind(self.OnGuajiTypeChange, self))
end

function CombineServerBossLogic:__delete()

end

function CombineServerBossLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	if ViewManager.Instance:IsOpen(ViewName.KaifuActivityView) then
		ViewManager.Instance:Close(ViewName.KaifuActivityView)
	end

	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_INFO_REQ)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_RANK_REQ)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_BOSS, CSA_BOSS_OPERA_TYPE.CSA_BOSS_OPERA_TYPE_ROLE_INFO_REQ)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.CombineServerBossView)
end

function CombineServerBossLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.CombineServerBossView)
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:SetViewState(true)
end

function CombineServerBossLogic:OnGuajiTypeChange(guaji_type)
	if nil ~= ShengDiFuBenAutoGatherEvent.func and guaji_type == GuajiType.Auto then
		ShengDiFuBenAutoGatherEvent.func()
	end
end