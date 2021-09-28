require("game/lianhun/slaughter_devil/slaughter_devil_cell")
require("game/lianhun/slaughter_devil/slaughter_devil_content")
require("game/lianhun/slaughter_devil/slaughter_devil_tips_view")
require("game/lianhun/slaughter_devil.slaughter_devil_info_view")
require("game/lianhun/slaughter_devil/slaughter_devil_data")
SlaughterDevilCtrl = SlaughterDevilCtrl or BaseClass(BaseController)

function SlaughterDevilCtrl:__init()
	if SlaughterDevilCtrl.Instance ~= nil then
		print_error("[SlaughterDevilCtrl] Attemp to create a singleton twice !")
	end
	SlaughterDevilCtrl.Instance = self
	self.data = SlaughterDevilData.New()
	self.view = SlaughterDevilTipsView.New(ViewName.SlaughterDevilTipsView)
	self.fb_view = SlagughterDevilInfoView.New(ViewName.SlagughterDevilInfoView)
	self:RegisterAllProtocols()

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainuiComplete, self))
	self.item_data_callback = BindTool.Bind(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_callback)
end

function SlaughterDevilCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
	end
	if self.data then
		self.data:DeleteMe()
	end
	if self.fb_view then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_callback)
	SlaughterDevilCtrl.Instance = nil
end

function SlaughterDevilCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSTuituFbOperaReq)
	self:RegisterProtocol(SCTuituFbInfo, "OnSCTuituFbInfo")
	self:RegisterProtocol(SCTuituFbResultInfo, "OnSCTuituFbResultInfo")
	self:RegisterProtocol(SCTuituFbSingleInfo, "OnSCTuituFbSingleInfo")
	self:RegisterProtocol(SCTuituFbFetchResultInfo, "OnSCTuituFbFetchResultInfo")
	self:RegisterProtocol(SCTuituFbTitleInfo, "OnSCTuituFbTitleInfo")
end

-- 绑定事件bangding
function SlaughterDevilCtrl:OnMainuiComplete()
	self:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_ALL_INFO)
end

function SlaughterDevilCtrl:SetDataAndOpenTipsView(data)
	self.view:SetDataAndOpen(data)
end

function SlaughterDevilCtrl:SendTuituFbOperaReq(opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTuituFbOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

-- 推图总协议下来
function SlaughterDevilCtrl:OnSCTuituFbInfo(protocol)
	self.data:SetFbInfo(protocol)
	LianhunCtrl.Instance:FlushView()
	if self.fb_view:IsOpen() then
		self.fb_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SlaughterDevil)
end

-- 推图通关协议
function SlaughterDevilCtrl:OnSCTuituFbResultInfo(protocol)
	self.data:SetResultInfo(protocol)
end

-- -- 推图信息变动
function SlaughterDevilCtrl:OnSCTuituFbSingleInfo(protocol)
	self:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_ALL_INFO)
	-- self.data:SetSingleInfo(protocol)
	-- LianhunCtrl.Instance:FlushView()
	-- if self.fb_view:IsOpen() then
	-- 	self.fb_view:Flush()
	-- end
end

-- 领取奖励返回
function SlaughterDevilCtrl:OnSCTuituFbFetchResultInfo(protocol)
	self:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_ALL_INFO)
	if protocol.is_success == 1 and protocol.fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL then
		self.data:ShowStarReward(protocol)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_PUSH_FB_STAR_REWARD)
	end
end

function SlaughterDevilCtrl:SetFBSceneLogicInfo(protocol)
	self.data:SetFBSceneLogicInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.SlagughterDevilInfoView) then
		self.fb_view:Flush("star_info")
	end
end

function SlaughterDevilCtrl:SendEnterFb(chapter, level, is_success)
	if level > self.data:GetMaxLevel() then
		chapter = chapter + 1
		if chapter > self.data:GetMaxChapter() then
			FuBenCtrl.Instance:SendExitFBReq()
			return
		end
		level = 0
	end
	if is_success then
		FuBenCtrl.Instance:SendEnterNextFBReq()
	else
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 0, chapter, level)
	end
end

function SlaughterDevilCtrl:OnSCTuituFbTitleInfo(protocol)
	self.data:SetTitleData(protocol)
	LianhunCtrl.Instance:FlushView()
end

function SlaughterDevilCtrl:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local view_data = SlaughterDevilData.Instance:GetViewData()
	if view_data.card_id == item_id then
		LianhunCtrl.Instance:FlushView()
	end
end