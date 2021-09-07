require("game/kuafu_1v1/kuafu1v1_view_count")
require("game/kuafu_1v1/kuafu1v1_view_main")
require("game/kuafu_1v1/kuafu1v1_view_rank")

KuaFu1v1View = KuaFu1v1View or BaseClass(BaseView)

function KuaFu1v1View:__init()
	self.ui_config = {"uis/views/kuafu1v1","KuaFu1v1"}
	self.play_audio = true
	self.hide = false
	self:SetMaskBg()
end

function KuaFu1v1View:__delete()
end

function KuaFu1v1View:LoadCallBack()
	self.main_panel = self:FindObj("MainPanel")
	self.main_view = KuaFu1v1ViewMain.New(self.main_panel)

	self.rank_panel = self:FindObj("RankPanel")
	self.rank_view = KuaFu1v1ViewRank.New(self.rank_panel)

	self.count_panel = self:FindObj("CountPanel")
	self.count_view = KuaFu1v1ViewCount.New(self.count_panel)

	self:ListenEvent("GoBack",
		BindTool.Bind(self.GoBack, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))

	KuaFu1v1Ctrl.Instance:SendGetCross1V1RankListReq()
	-- self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	-- ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function KuaFu1v1View:ReleaseCallBack()
	if self.main_view then
		self.main_view:DeleteMe()
		self.main_view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.count_view then
		self.count_view:DeleteMe()
		self.count_view = nil
	end
	-- if self.activity_call_back then
	-- 	ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
	-- 	self.activity_call_back = nil
	-- end
	self.main_panel = nil
	self.rank_panel = nil
	self.count_panel = nil
end

function KuaFu1v1View:OpenCallBack()
	-- if not self.hide then
		self:OpenMainView()
	-- else
		-- self:OpenCountView()
		-- self.hide = false
	-- end
	if self.main_view then
		self.main_view:Flush()
	end
end

function KuaFu1v1View:OpenAndFlush(param_t)
	if self.hide then
		self:Open()
	end
	self:Flush(param_t)
end

function KuaFu1v1View:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "match_result" then
			if self.count_panel.gameObject.activeSelf then
				self.count_view:Flush("match_result")
			end
		end
	end
	self.main_view:Flush()
	self.rank_view:Flush()
end

function KuaFu1v1View:CloseAllView()
	if self.main_panel then
		self.main_panel:SetActive(false)
	end
	if self.rank_panel then
		self.rank_panel:SetActive(false)
	end

	if self.count_panel then
		self.count_panel:SetActive(false)
	end
end

function KuaFu1v1View:OnClickClose()
	self:Close()
end

function KuaFu1v1View:OpenRankView()
	self:CloseAllView()
    KuaFu1v1Ctrl.Instance:SendGetCross1V1RankListReq()
	if self.rank_panel then
		self.rank_panel:SetActive(true)
		self.rank_view:Flush()
		self.rank_view:FlushModel(1)  --默认打开面板展示第一套
	end
end

function KuaFu1v1View:OpenCountView()
	self:CloseAllView()
	if self.count_panel then
		self.count_panel:SetActive(true)
		self.count_view:StartCountDown()
	end
end

function KuaFu1v1View:OpenMainView()
	self:CloseAllView()
	if self.main_panel then
		self.main_panel:SetActive(true)
		self.main_view:Flush()
	end
end

function KuaFu1v1View:RemoveCountDown()
	self.count_view:RemoveCountDown()
end

function KuaFu1v1View:GoBack()
	KuaFu1v1Ctrl.Instance:SendQuXiaoCrossMatch1V1Req()
	KuaFu1v1Ctrl.Instance.view:SendQuXiao()
	KuaFu1v1Ctrl.Instance.view:RemoveCountDown()
	-- self.hide = true
	-- self:CloseVisible()
end

function KuaFu1v1View:ActivityCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.KF_ONEVONE then
		if status == ACTIVITY_STATUS.CLOSE then
			self:Close()
			TipsCtrl.Instance:ShowReminding(Language.Kuafu1V1.MatchFailTxt2)
		end
	end
end

function KuaFu1v1View:SendQuXiao()
	self.main_panel:SetActive(true)
	self.rank_panel:SetActive(false)
	self.count_panel:SetActive(false)
end

function KuaFu1v1View:SendPiPen()
	self.main_panel:SetActive(false)
	self.rank_panel:SetActive(false)
	self.count_panel:SetActive(true)
end