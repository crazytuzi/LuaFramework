-- 开服每日累计主题充值
OpenSerDailyAddChargePage = OpenSerDailyAddChargePage or BaseClass()

function OpenSerDailyAddChargePage:__init()
	
	
end	

function OpenSerDailyAddChargePage:__delete()
	self:RemoveEvent()
	if self.charge_list_view ~= nil then
		self.charge_list_view:DeleteMe()
		self.charge_list_view = nil 
	end
end	

--初始化页面接口
function OpenSerDailyAddChargePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	-- self.rich_des = self.view.node_t_list.rich_daily_charge_theme_des.node
	self:CreateList()
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_daily_theme_link.node, Language.OpenServiceAcitivity.RechargeTips, 22, color, x, y, w, h, ignored_link, {under_line = true})
	self:InitEvent()
end	
--初始化事件
function OpenSerDailyAddChargePage:InitEvent()
	self.view.node_t_list.btn_charge_daily.node:addClickEventListener(BindTool.Bind(self.OpenView, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self), 1)
end

--移除事件
function OpenSerDailyAddChargePage:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

local end_time = 24 * 3600
function OpenSerDailyAddChargePage:FlushTime()
	local now_time = ActivityData.GetNowShortTime()
	local rest_time = end_time - now_time
	local time_str = TimeUtil.FormatSecond2Str(rest_time, 1, true)
	time_str = Language.Common.RemainTime.."：".. time_str
	self.view.node_t_list.txt_daily_charge_rest_time.node:setString(time_str)
end

function OpenSerDailyAddChargePage:CreateList()
	if self.charge_list_view == nil then
		local ph = self.view.ph_list.ph_item_list_daily
		self.charge_list_view = ListView.New()
		self.charge_list_view:Create(ph.x, ph.y, ph.w, ph.h, direction, OpenDailyAddChargeAwardItem, nil, false, self.view.ph_list.ph_list_item_daily)
		self.charge_list_view:SetItemsInterval(3)
		self.charge_list_view:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_daily_charge.node:addChild(self.charge_list_view:GetView(), 100)
	end
end

--更新视图界面
function OpenSerDailyAddChargePage:UpdateData(data)
	self:FlushTime()
	local data = OpenServiceAcitivityData.Instance:GetDailyChargeRewardData()
	self.charge_list_view:SetDataList(data)
	local charge_money = OpenServiceAcitivityData.Instance:GetDailyChargeMoney()
	local txt = string.format(Language.OpenServiceAcitivity.ChargeMoney, charge_money)
	self.view.node_t_list.txt_my_charge_daily.node:setString(txt)
	local day = OtherData.Instance:GetOpenServerDays()
	local path = ResPath.GetOpenServerActivities("daily_charge_theme_1")
	local config = OpenServiceAcitivityData.GetServerCfg(OPEN_SERVER_CFGS_NAME[3]) or {}
	if day > 0 and day <= #config then
		path = ResPath.GetOpenServerActivities("daily_charge_theme_" .. day)
	end
	self.view.node_t_list.img_daily_charge_theme.node:loadTexture(path)
	-- txt = OpenServiceAcitivityData.Instance:GetDailyChargeDes()
	-- RichTextUtil.ParseRichText(self.rich_des, txt, 22, COLOR3B.YEELOW)
end

function OpenSerDailyAddChargePage:OpenView()
	ViewManager.Instance:Open(ViewName.ChargePlatForm)
end

