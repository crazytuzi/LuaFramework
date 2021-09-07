GuildCheckDonateView = GuildCheckDonateView or BaseClass(BaseView)

function GuildCheckDonateView:__init()
	self.ui_config =  {"uis/views/guildview", "GuildCheckDonateView"}
	self:SetMaskBg(true)
	self.full_screen = false
end

function GuildCheckDonateView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:CheckDonateInfo()
end

function GuildCheckDonateView:ReleaseCallBack()
	if self.donate_list then
		for k,v in pairs(self.donate_list) do
			v:DeleteMe()
		end
		self.donate_list = {}
	end

	self.donate_scroller = nil
end

function GuildCheckDonateView:OnClickClose()
	self:Close()
end

-- 等级投资
function GuildCheckDonateView:CheckDonateInfo()
	self.donate_list = {}
	self.donate_scroller = self:FindObj("Scroller")
	local delegate = self.donate_scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #GuildData.Instance:GetGuildEventList()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1
		local target_cell = self.donate_list[cell]
		if nil == target_cell then
			self.donate_list[cell] = DonateInfoListCell.New(cell.gameObject)
			target_cell = self.donate_list[cell]
		end
		local data = GuildData.Instance:GetGuildEventList()
		local cell_data = data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end


---------------------------------------------------------------
--

DonateInfoListCell = DonateInfoListCell or BaseClass(BaseCell)

function DonateInfoListCell:__init()
	self.name = self:FindVariable("Name")
	self.time = self:FindVariable("Time")
	self.reward_des = self:FindVariable("RewardDes")
	self.cold_type = self:FindVariable("ColdType")
end

function DonateInfoListCell:__delete()

	
end


function DonateInfoListCell:OnFlush()
	if nil == self.data then return end

	self.name:SetValue(self.data.event_owner)
	self.cold_type:SetValue(Language.Guild.DonateType[self.data.param0])
	self.reward_des:SetValue(string.format(Language.Guild.RewardDonateDesc, self.data.param1))

    local t_time = TimeUtil.Timediff(TimeCtrl.Instance:GetServerTime(), self.data.event_time)
    local donate_time = self:LastDonateTime(t_time)
	self.time:SetValue(donate_time)
end

-- 通过相差的时间，返回合适的时间
function DonateInfoListCell:LastDonateTime(t_time)
    local last_time = ""
    if t_time.year > 0 then
        last_time = string.format(Language.Common.BeforeXXYear, t_time.year)
        return last_time
    elseif t_time.year < 0 then
        last_time = Language.Common.JustMoment
        return last_time
    end
    if t_time.month ~= 0 then
        string.format(Language.Common.BeforeXXMonth, t_time.month)
        return last_time
    end
    if t_time.day ~= 0 then
        last_time = string.format(Language.Common.BeforeXXDay, t_time.day)
        return last_time
    end
    if t_time.hour ~= 0 then
        last_time = string.format(Language.Common.BeforeXXHour, t_time.hour)
        return last_time
    end
    if t_time.min ~= 0 then
        last_time = string.format(Language.Common.BeforeXXMinute, t_time.min)
        return last_time
    end
    if t_time.sec ~= 0 then
	    last_time = string.format(Language.Common.BeforeXXSecond, t_time.sec)
    else
    	last_time = Language.Common.JustMoment
    end
    return last_time
end