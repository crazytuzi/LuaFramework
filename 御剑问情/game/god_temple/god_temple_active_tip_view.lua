GodTempleActiveTipView = GodTempleActiveTipView or BaseClass(BaseView)

function GodTempleActiveTipView:__init()
	self.ui_config = {"uis/views/godtemple_prefab", "GodTempleActiveTips"}
end

function GodTempleActiveTipView:__delete()
end

function GodTempleActiveTipView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	
	self:StopTimeQuest()

	self.power = nil
end

function GodTempleActiveTipView:LoadCallBack()
	self.model = RoleModel.New()
	self.model:SetDisplay(self:FindObj("display").ui3d_display)

	self.power = self:FindVariable("power")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function GodTempleActiveTipView:OnClick()
	self:Close()
	local today_layer = GodTemplePataData.Instance:GetTodayLayer()
	local next_layer_info = GodTemplePataData.Instance:GetLayerCfgInfo(today_layer + 1)
	if next_layer_info == nil then
		--已通关最高层数，退出副本
		FuBenCtrl.Instance:SendExitFBReq()
		return
	end

	Camera.Instance:SetCameraTransformByName("pata", 0.1)

	GlobalTimerQuest:AddDelayTimer(function ()
		Camera.Instance:Reset(0.1)
	end, 2)

	GlobalTimerQuest:AddDelayTimer(function ()
		FuBenCtrl.Instance:SendEnterNextFBReq()
	end, 2.5)
end

function GodTempleActiveTipView:StopTimeQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GodTempleActiveTipView:StartTimeQuest()
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self:OnClick()
	end, 5)
end

function GodTempleActiveTipView:OpenCallBack()
	self:Flush()
	-- self:StopTimeQuest()
	-- self:StartTimeQuest()
end

function GodTempleActiveTipView:CloseCallBack()
	self:StopTimeQuest()
end

function GodTempleActiveTipView:OnFlush()
	local shenqi_cfg_info = GodTempleShenQiData.Instance:GetShenQiCfgInfoByLevel()
	if shenqi_cfg_info == nil then
		return
	end

	local power = CommonDataManager.GetCapabilityCalculation(shenqi_cfg_info)
	self.power:SetValue(power)

	local bundle, asset = ResPath.GetGodTempleShenQiModel(shenqi_cfg_info.res_id)
	self.model:SetMainAsset(bundle, asset)
end