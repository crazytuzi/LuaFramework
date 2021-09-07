SlotUpLevelView = SlotUpLevelView or BaseClass(BaseView)
local CONV_RATE = {
	"gongji_conv_rate",
	"fangyu_conv_rate",
	"hp_conv_rate",
}
function SlotUpLevelView:__init(instance)
	self.ui_config = {"uis/views/famousgeneralview", "SlotUpLevelView"}
	self:SetMaskBg(true)
	self.slot_seq = 0
	--self.flag = false
end

function SlotUpLevelView:ReleaseCallBack()
	if self.item_cell then 
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.call_back then 
		ItemData.Instance:UnNotifyDataChangeCallBack(self.call_back)
		self.call_back = nil
	end
	-- if self.upgrade_timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	-- 	self.upgrade_timer_quest = nil
	-- end
	self.slot_seq = 0
	self.title = nil
	self.slot_name = nil
	self.bless_text = nil
	self.solt_level = nil
	self.bless_progress = nil
	self.item_num = nil
	self.can_up = nil
	self.cur_desc = nil
	self.next_desc = nil
	self.cur_cap= nil
	self.next_cap = nil
	self.progress_bg = nil
	self.top = nil
end

function SlotUpLevelView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("UpLevel", BindTool.Bind(self.OnClickUpLevel, self))
	self.title = self:FindVariable("Title")
	self.slot_name = self:FindVariable("SoltName")
	self.bless_text = self:FindVariable("BlessText")
	self.solt_level = self:FindVariable("SoltLevel")
	self.bless_progress = self:FindVariable("BlessProgress")
	self.item_num = self:FindVariable("ItemNum")
	self.can_up = self:FindVariable("CanUp")
	self.cur_desc = self:FindVariable("CurDesc")
	self.next_desc = self:FindVariable("NextDesc")
	self.cur_cap = self:FindVariable("CurCap")
	self.next_cap = self:FindVariable("NextCap")
	--self.stop_up_level = self:FindVariable("StopUpLevel")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.progress_bg = self:FindObj("ProgressBG")
	self.top = self:FindObj("Top")
	if self.call_back == nil then
		self.call_back = BindTool.Bind(self.ItemChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.call_back)
	end
end

function SlotUpLevelView:CloseCallBack()
	--self.stop_up_level:SetValue(false)
	--self.flag = false
end

function SlotUpLevelView:SetSlotSeq(slot_seq)
	self.slot_seq = slot_seq
end

function SlotUpLevelView:OpenCallBack()
	local slot_name = FamousGeneralData.Instance:GetSlotName(self.slot_seq)
	self.title:SetValue(string.format(Language.FamousGeneral.SoltUpTitle, slot_name))
	self.slot_name:SetValue(slot_name)
	self:Flush()
end

function SlotUpLevelView:OnFlush(param_t)
	local lang_name = Language.FamousGeneral
	local slot_info = FamousGeneralData.Instance:GetSingleSlotInfo(self.slot_seq)
	if not slot_info or not next(slot_info) then return end

	local slot_cfg = FamousGeneralData.Instance:GetSlotLevelCfg(slot_info.level, self.slot_seq)
	if not slot_cfg or not next(slot_cfg) then return end

	local next_cfg = FamousGeneralData.Instance:GetSlotLevelCfg(slot_info.level + 1, self.slot_seq)

	local rate_num, rate_key = self:CheckShowConvRate(slot_cfg)

	local cur_str = string.format(lang_name.DescContent, lang_name.RateName[4], slot_cfg.wash_attr_add_percent)
	local cur_cap = string.format(lang_name.AttrDesc[self.slot_seq], slot_cfg[lang_name.AttrName[self.slot_seq]])
	local next_cap = lang_name.MaxLevel
	local next_str = lang_name.MaxLevel
	if next_cfg then
		next_str = string.format(lang_name.DescContent, lang_name.RateName[4], next_cfg.wash_attr_add_percent)
		next_cap = string.format(lang_name.AttrDesc[self.slot_seq], next_cfg[lang_name.AttrName[self.slot_seq]])
	end
	if rate_num ~= #CONV_RATE then
		cur_str = string.format(lang_name.DescContent, lang_name.RateName[4], slot_cfg.wash_attr_add_percent)
		if next_cfg then
			next_str = string.format(lang_name.DescContent, lang_name.RateName[4], next_cfg.wash_attr_add_percent)
		end
	end

	self.cur_desc:SetValue(cur_str)
	self.next_desc:SetValue(next_str)
	self.cur_cap:SetValue(cur_cap)
	self.next_cap:SetValue(next_cap)
	self.bless_text:SetValue(slot_info.level_val .. "/" .. slot_cfg.need_val)
	self.solt_level:SetValue("Lv." .. slot_info.level)	
	self.bless_progress:SetValue(slot_info.level_val/slot_cfg.need_val)	
	self.item_cell:SetData({item_id = slot_cfg.item_id})
	local own_item = ItemData.Instance:GetItemNumInBagById(slot_cfg.item_id)
	self.item_num:SetValue(own_item .. "/" .. slot_cfg.item_num)
	self.can_up:SetValue(own_item >= slot_cfg.item_num)
end

function SlotUpLevelView:SetPercentNum(cur_str)
	if cur_str > 1 then
		return cur_str 
	else
		return cur_str * 100 .. "%" 
	end
end

function SlotUpLevelView:OnClickUpLevel()
	-- if self.flag then 
	-- 	self:StopOnClickUpLevel()
	-- 	return
	-- end
	--self.stop_up_level:SetValue(true)
	--self.flag = true
	self:UpData()
end

--连续升级
function SlotUpLevelView:UpData( )
	-- if nil ~= self.upgrade_timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	-- 	self.upgrade_timer_quest = nil
	-- end
	--local function send()
		FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_SLOT_LEVEL_UP, self.slot_seq, 1)
	--end
	--if self.flag then
		--self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(send, self), 0.3)
	--end	
end

-- function SlotUpLevelView:StopOnClickUpLevel()
-- 	self.stop_up_level:SetValue(false)
-- 	self.flag = false
-- end

function SlotUpLevelView:CheckShowConvRate(single_cfg)
	if not single_cfg or not next(single_cfg) then return end
	local num = 0
	local cur_rate = 1
	for k,v in pairs(CONV_RATE) do
		if single_cfg[v] > 0 then
			num = num + 1
			cur_rate = k
		end
	end
	return num, cur_rate
end

function SlotUpLevelView:ItemChange()
	self:Flush()
end