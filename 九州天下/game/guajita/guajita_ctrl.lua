require("game/guajita/guajita_data")
-- require("game/guajita/guajita_view")
require("game/guajita/guajita_fb_info_view")
-- require("game/guajita/guajita_offline_info_view")

local CHECK_TIME_CD = 600		-- 检查剩余时间CD
local LESS_TIEM = 3600			-- 时间阈值

GuaJiTaCtrl = GuaJiTaCtrl or BaseClass(BaseController)

function GuaJiTaCtrl:__init()
	if GuaJiTaCtrl.Instance then
		return
	end

	GuaJiTaCtrl.Instance = self

	self.data = GuaJiTaData.New()
	-- self.view = GuaJiTaView.New(ViewName.RuneTowerView)
	self.fb_view = GuajiTaFbInfoView.New(ViewName.RuneTowerFbInfoView)
	-- self.offline_view = GuajiTaOfflineInfoView.New(ViewName.RuneTowerOfflineInfoView)

	self:RegisterAllProtocols()
	self.can_open_offline_view = false
	self.is_mainui_open = false
	-- self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function GuaJiTaCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	-- if self.view then
	-- 	self.view:DeleteMe()
	-- 	self.view = nil
	-- end

	if self.fb_view then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end

	-- if self.offline_view then
	-- 	self.offline_view:DeleteMe()
	-- 	self.offline_view = nil
	-- end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if GuaJiTaCtrl.Instance then
		GuaJiTaCtrl.Instance = nil
	end
end

function GuaJiTaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRuneTowerInfo, "OnRuneTowerInfo")
	self:RegisterProtocol(SCRuneTowerAutoReward, "OnRuneTowerAutoReward")
	-- self:RegisterProtocol(SCRuneTowerOfflineInfo, "OnRuneTowerOfflineInfo")

	self:RegisterProtocol(CSRuneTowerFetchTime)
	self:RegisterProtocol(CSRuneTowerAutoFb)
end

-- 符文塔信息
function GuaJiTaCtrl:OnRuneTowerInfo(protocol)
	self.data:SetRuneTowerInfo(protocol)
	-- if self.view:IsOpen() then
	-- 	self.view:Flush()
	-- end
	RuneCtrl.Instance:FlushTowerView()
	RemindManager.Instance:Fire(RemindName.RuneTower)
	RemindManager.Instance:Fire(RemindName.BeStrength)
end

function GuaJiTaCtrl:OnRuneTowerAutoReward(protocol)
	self.data:SetAutoRewardData(protocol)
	TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_GUAJITA_REWARD)
end

-- function GuaJiTaCtrl:MainuiOpen()
-- 	self.is_mainui_open = true
-- 	if self.can_open_offline_view then
-- 		-- self.offline_view:Open()
-- 	end

-- end

-- 领取离线时间
function GuaJiTaCtrl:SendGetRuneTowerFetchBuff()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneTowerFetchTime)
	send_protocol:EncodeAndSend()
end

-- 扫荡
function GuaJiTaCtrl:SendRuneTowerAuto()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneTowerAutoFb)
	send_protocol:EncodeAndSend()
end

function GuaJiTaCtrl:CheckOfflineCountDown()
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			if not OpenFunData.Instance:CheckIsHide("runetower") then
				return
			end
			local other_cfg = self.data:GetRuneOtherCfg()
			local rune_info = self.data:GetRuneTowerInfo()
			if rune_info.offline_time >= LESS_TIEM then
				return
			end

			local can_use = true
			if next(other_cfg) and next(rune_info) and other_cfg.offline_time_max <= rune_info.offline_time then
				can_use = false
			end

			local ok_callback = function()
				local callback = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
					local use_flag = can_use and 1 or 0
					if not can_use then
						TipsCtrl.Instance:ShowSystemMsg(Language.Rune.OfflineLimit)
					end
					MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, use_flag)
				end
				TipsCtrl.Instance:ShowCommonBuyView(callback, GUAJI_TA_TIME_CARD_ITEM_ID, nil, 1)
			end
			TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, true)
		end, CHECK_TIME_CD)
	end
end