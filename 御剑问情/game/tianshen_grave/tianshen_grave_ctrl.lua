require("game/tianshen_grave/tianshen_grave_info_view")
require("game/tianshen_grave/tianshen_grave_data")
TianShenGraveCtrl = TianShenGraveCtrl or BaseClass(BaseController)

function TianShenGraveCtrl:__init()
	if TianShenGraveCtrl.Instance ~= nil then
		print_error("[TianShenGraveCtrl] Attemp to create a singleton twice !")
	end
	self.view = TianshenGraveInfoView.New()
	self.data = TianShenGraveData.New()
	self:RegisterAllProtocols()

	TianShenGraveCtrl.Instance = self
	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainuiComplete, self))
end

function TianShenGraveCtrl:__delete()
	self:CancelShuiJingBuffCountDown()
	TianShenGraveCtrl.Instance = nil
end

function TianShenGraveCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossShuijingGatherInfo, "CrossShuijingGatherInfo")
	self:RegisterProtocol(SCCrossShuijingUserInfo, "CrossShuijingUserInfo")

end

function TianShenGraveCtrl:CrossShuijingGatherInfo(protocol)
	self.data:SetData(protocol)
	self.view:Flush()
	if self.view:IsOpen() then
	
	end
end

function TianShenGraveCtrl:CrossShuijingUserInfo(protocol)
	self.data:SetUserData(protocol)
	self:StartShuiJingBuffCountDown(protocol.wudi_gather_buff_end_timestamp)
	local main_role = Scene.Instance:GetMainRole()
	main_role:ChangeTianShenGraveWuDiGather()
	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	-- if fuben_icon_view:IsOpen() then
		fuben_icon_view:SetTianshenBuffBubblesText()
	-- end
	self.view:Flush()
end

function TianShenGraveCtrl:OpenInfoView()
	self.view:Open()
end

function TianShenGraveCtrl:CloseInfoView()
	self.view:Close()
end

function TianShenGraveCtrl.OnShuijingBuyBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossShuijingBuyBuff)
	protocol:EncodeAndSend()
end

function TianShenGraveCtrl:StartShuiJingBuffCountDown(complete_time)
	self:CancelShuiJingBuffCountDown()
	local time = complete_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then return end
	self.shuijing_buff_count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.ShuiJingBuffCountDown, self))
end

function TianShenGraveCtrl:ShuiJingBuffCountDown(elapse_time, total_time)
	if Scene.Instance:GetSceneType() ~= SceneType.CrossShuijing then
		self:CancelShuiJingBuffCountDown()
	end
	if elapse_time >= total_time then
		self:CancelShuiJingBuffCountDown()
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeTianShenGraveWuDiGather(0)
	end
end

function TianShenGraveCtrl:CancelShuiJingBuffCountDown()
	if self.shuijing_buff_count_down then
		CountDown.Instance:RemoveCountDown(self.shuijing_buff_count_down)
		self.shuijing_buff_count_down = nil
	end
end