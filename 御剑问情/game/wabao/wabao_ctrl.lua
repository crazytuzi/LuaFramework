require("game/wabao/wabao_data")
require("game/wabao/wabao_view")
WaBaoCtrl = WaBaoCtrl or BaseClass(BaseController)
function WaBaoCtrl:__init()
	if WaBaoCtrl.Instance then
		print_error("[WaBaoCtrl] Attemp to create a singleton twice !")
	end
	WaBaoCtrl.Instance = self
	self.data = WaBaoData.New()
	self.view = WaBaoView.New(ViewName.WaBao)
	self:RegisterAllProtocols()
	Runner.Instance:AddRunObj(self, 8)
	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function WaBaoCtrl:__delete()
	WaBaoCtrl.Instance = nil
	self.data:DeleteMe()
	self.view:DeleteMe()
	Runner.Instance:RemoveRunObj(self)
end

function WaBaoCtrl:Update(now_time, elapse_time)
	if self.check_time and self.check_time > now_time then
		return
	end
	self.check_time = now_time + 1
	local wabao_info = self.data:GetWaBaoInfo()
	if next(wabao_info)
		and wabao_info.baotu_count > 0
		and not self.view:IsOpen() then
		local x = wabao_info.baozang_pos_x
		local y = wabao_info.baozang_pos_y
		local wabao_scene_id = wabao_info.baozang_scene_id
		local role_scene_id = GameVoManager.Instance:GetMainRoleVo().scene_id
		if wabao_scene_id == role_scene_id and GuajiCtrl.CheckRange(x, y, 10) then
			if not TipsCtrl.Instance:GetWaBaoDigView():IsOpen() then
				TipsCtrl.Instance:ShowWaBaoDigView()
			end
		elseif TipsCtrl.Instance:GetWaBaoDigView():IsOpen() then
			TipsCtrl.Instance:GetWaBaoDigView():Close()
		end
	end
end

function WaBaoCtrl:GetView()
	return self.view
end

function WaBaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCWabaoInfo,"OnSCWabaoInfo")
end

function WaBaoCtrl:OnSCWabaoInfo(protocol)
	local flag = false
	local info = self.data:GetWaBaoInfo()
	if next(info) and protocol.baotu_count ~= info.baotu_count then
		flag = true
	end
	self.data:OnSCWabaoInfo(protocol)
	if flag == true then MainUICtrl.Instance:GetTaskView():DelaySortTask() end
	if self.data:GetWaBaoInfo().wabao_reward_type ~= 0 then
		if TipsCtrl.Instance:GetWaBaoDigView():IsOpen() then
			TipsCtrl.Instance:GetWaBaoDigView():Close()
		end
		if #protocol.wabao_reward_list > 3 then
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_WABAO_QUICKL)
		else
			TipsCtrl.Instance:ShowWaBaoView()
		end
	end
	if self.view:IsOpen() then
		self.view:Flush()
	end

	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if pos_cfg.baozang_scene_id and pos_cfg.baozang_scene_id ~= 0
		and WaBaoData.Instance:GetWaBaoFlag() and self.data:GetWaBaoInfo().wabao_reward_type == 0 then
		MoveCache.cant_fly = true
		GuajiCtrl.Instance:MoveToPos(pos_cfg.baozang_scene_id, pos_cfg.baozang_pos_x, pos_cfg.baozang_pos_y, 0, 0)
		WaBaoData.Instance:SetWaBaoFlag(false)
	end
end

function WaBaoCtrl.SendWabaoOperaReq(opera_type, is_killed)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWabaoOperaReq)
	protocol.opera_type = opera_type
	protocol.is_killed = is_killed
	protocol:EncodeAndSend()
end