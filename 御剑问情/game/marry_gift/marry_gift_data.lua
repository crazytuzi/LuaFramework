MarryGiftData = MarryGiftData or BaseClass()

MarryGiftData.Has_Open = false
MarryGiftData.HAS_NEW_REMIND = false
MarryGiftData.HAS_REMIND = false
function MarryGiftData:__init()
	if MarryGiftData.Instance then
		print_error("[MarryGiftData] Attempt to create singleton twice!")
		return
	end
	MarryGiftData.Instance = self

	self.cur_purchased_seq = 0
	self.remind_info = {
		openserver_day = 0,
		buy_seq = 0,
		is_open_panel = 0,
	}
	self.timelimit_buy_cfg = ConfigManager.Instance:GetAutoConfig("qingyuanconfig_auto").timelimit_buy
	RemindManager.Instance:Register(RemindName.MarryGiftBack, BindTool.Bind(self.GetMarryGiftBackRemind, self))
	RemindManager.Instance:Register(RemindName.MarryGift, BindTool.Bind(self.GetMarryGiftRemind, self))
end

function MarryGiftData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MarryGiftBack)
	RemindManager.Instance:UnRegister(RemindName.MarryGift)
	MarryGiftData.Instance = nil
end

function MarryGiftData:SetCurPurchasedSeq(protocol)
	self.cur_purchased_seq = protocol.cur_purchased_seq
end

function MarryGiftData:CurPurchasedSeq()
	return self.cur_purchased_seq
end

function MarryGiftData:SetGiftRemindInfo(protocol)
	self.remind_info.openserver_day = protocol.openserver_day
	self.remind_info.buy_seq = protocol.buy_seq
	self.remind_info.is_open_panel = protocol.is_open_panel
	MarryGiftData.HAS_NEW_REMIND = true
end

function MarryGiftData:GetGiftRemindInfo()
	return self.remind_info
end

function MarryGiftData:GetMarryGiftSeqCfg(seq, openserver_day)
	local cfg = self:GetMarryGiftCfg(openserver_day)
	return cfg[seq]
end

function MarryGiftData:GetMarryGiftCfg(openserver_day)
	local open_day = openserver_day or TimeCtrl.Instance:GetCurOpenServerDay()
	local rand_t = {}
	local day = nil

	for k,v in ipairs(self.timelimit_buy_cfg) do
		if v and (nil == day or v.opengame_day == day) and open_day <= v.opengame_day then
			day = v.opengame_day
			rand_t[v.seq] =  v
		end
	end
	return rand_t
end

function MarryGiftData:GetMarryGiftBackRemind()
	return MarryGiftData.HAS_NEW_REMIND and 1 or 0
end

function MarryGiftData:GetMarryGiftRemind()
	if MarryGiftData.HAS_REMIND then
		return 0
	end
	if self:GetMarryGiftSeqCfg(self.cur_purchased_seq + 1) then
		return 1
	end
	return 0
end