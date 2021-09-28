CityContend = CityContend or BaseClass(BaseRender)

function CityContend:__init()
	self.rest_time = self:FindVariable("rest_time")
	self.model_display = self:FindObj("ModelDisplay")
	self:ListenEvent("ClickFight", BindTool.Bind(self.ClickFight, self))

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	for i = 1, 2 do
		self.item_cell_obj_list[i] = self:FindObj("ItemCell"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
	end
	self.chenghao = self:FindVariable("chenghao")
	self.winner_name = self:FindVariable("winner_name")
	self.has_winner = self:FindVariable("has_winner")
	self.winner_id = 0
end

function CityContend:__delete()
	self.rest_time = nil
	self.model_display = nil
	self.chenghao = nil
	self.winner_name = nil
	self.has_winner = nil

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	if self.role_info then
		GlobalEventSystem:UnBind(self.role_info)
		self.role_info = nil
	end

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function CityContend:OpenCallBack()
	self.main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.other_cfg = CityCombatData.Instance:GetOtherConfig()
	self.cz_fashion_yifu_id = self.other_cfg.cz_fashion_yifu_id
	self.yifu_item_data = ItemData.Instance:GetItemConfig(self.cz_fashion_yifu_id)
	self.gcz_chengzhu_reward, self.gcz_camp_reward = HefuActivityData.Instance:GetCityContendRewardInfo()

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_GONGCHENGZHAN)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self.item_cell_list[1]:SetData(self.gcz_chengzhu_reward)
	self.item_cell_list[2]:SetData(self.gcz_camp_reward)
	self.chenghao:SetAsset(ResPath.GetTitleIcon(self.other_cfg.cz_chenghao))
	self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.FlushTuanZhangModel, self))
	self:Flush()
end

function CityContend:CloseCallBack()
	if self.role_info then
	    GlobalEventSystem:UnBind(self.role_info)
	    self.role_info = nil
	end
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function CityContend:FlushTuanZhangModel(role_id, role_info)
	if self.winner_id ~= role_id then
		return
	end
	self.winner_name:SetValue(role_info.role_name)
	self:FlushModel(role_info)
	if self.winner_id ~= 0 then
		self.has_winner:SetValue(true)
	else
		self.has_winner:SetValue(false)
	end
end

function CityContend:FlushModel(role_info)
	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end

	local role_vo = {}
	if nil ~= role_info then
		role_vo.prof = role_info.prof
		role_vo.sex = role_info.sex
	else
		role_vo.prof = self.main_role_vo.prof
		role_vo.sex = self.main_role_vo.sex
	end
	role_vo.appearance = {}
	role_vo.appearance.fashion_wuqi = 1
	role_vo.appearance.fashion_body = self.yifu_item_data.param2
	self.model:SetModelResInfo(role_vo, true, true, true, true)
end

function CityContend:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min)
	self.rest_time:SetValue(str)
end

function CityContend:OnFlush()
	self.winner_id = HefuActivityData.Instance:GetCityContendWinnerInfo()
	if self.winner_id ~= 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(self.winner_id)
	end
	if self.winner_id ~= 0 then
		self.has_winner:SetValue(true)
	else
		self.has_winner:SetValue(false)
	end
end

function CityContend:ClickFight()
	HefuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:Open(ViewName.CityCombatView)
end