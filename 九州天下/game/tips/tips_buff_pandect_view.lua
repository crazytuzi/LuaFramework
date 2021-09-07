TipsBuffPandectView = TipsBuffPandectView or BaseClass(BaseView)

FIGHT_EFFECT_JI_NENG  = 3103  --有功能 但不要显示的技能
FIGHT_EFFECT_CHOU_DI  = 3100  --仇敌
FIGHT_EFFECT_PO_JIA   = 3101  --破甲
function TipsBuffPandectView:__init()
	self.ui_config = {"uis/views/tips/bufftips", "BuffPandectTip"}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.data_list = {}
	self.play_audio = true
end

function TipsBuffPandectView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.list_view.scroll_rect.normalizedPosition = Vector2(0, 1)
	self.view_open_event = GlobalEventSystem:Bind(OtherEventType.VIEW_OPEN, BindTool.Bind(self.HasViewOpen, self))
	self.menu_toggle_change = GlobalEventSystem:Bind(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, BindTool.Bind(self.PortraitToggleChange, self))
end

function TipsBuffPandectView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.data_list = {}
end

function TipsBuffPandectView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.data_list = {}

	-- 清理变量和对象
	self.list_view = nil
	if self.view_open_event then
		GlobalEventSystem:UnBind(self.view_open_event)
		self.view_open_event = nil
	end
	if self.menu_toggle_change then
		GlobalEventSystem:UnBind(self.menu_toggle_change)
		self.menu_toggle_change = nil
	end
end

function TipsBuffPandectView:HasViewOpen(view)
	if view.view_name and view.view_name ~= "" and view.view_name ~= ViewName.BuffPandectTips
	and view.view_layer == UiLayer.Normal then
		self:Close()
	end
end

function TipsBuffPandectView:PortraitToggleChange(state, from_move)
	if from_move then
		self:Close()
	end
end

function TipsBuffPandectView:GetNumberOfCells()
	return #FightData.Instance:GetMainRoleShowEffect()
end

function TipsBuffPandectView:RefreshMountCell(cell, data_index)
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = TipBuffCell.New(cell)
		self.cell_list[cell] = item_cell
	end
	local main_role_all_effect_list = FightData.Instance:GetMainRoleShowEffect()
	item_cell:SetData(main_role_all_effect_list[data_index + 1])
end

function TipsBuffPandectView:OnClickClose()
	self:Close()
end

function TipsBuffPandectView:OpenCallBack()
	if self.buff_effect_change == nil then
		self.buff_effect_change = GlobalEventSystem:Bind(
		ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind(self.OnFightEffectChange, self))

	end
	self:Flush()
end

function TipsBuffPandectView:CloseCallBack()
	if self.buff_effect_change ~= nil then
		GlobalEventSystem:UnBind(self.buff_effect_change)
		self.buff_effect_change = nil
	end
end

function TipsBuffPandectView:OnFightEffectChange(is_main_role)
	if is_main_role then
		self:Flush()
	end
end

function TipsBuffPandectView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function TipsBuffPandectView:PauseTimer()
	if self.cell_list ~= nil then
		for k,v in pairs(self.cell_list) do
			if v ~= nil then
				if v.data ~= nil and v.data.info and v.data.info.client_effect_type then
					local cfg = FightData.Instance:GetBuffDescCfgByType(v.data.info.client_effect_type)
					if cfg ~= nil and cfg.dead_pause == 1 then
						v:PauseUpdateTimer()
					end
				end
			end
		end
	end
end


TipBuffCell = TipBuffCell or BaseClass(BaseCell)
local BEAUTY_SHIXIE = 6 	--美人噬血技能
function TipBuffCell:__init(instance)
	self.buff_name = self:FindVariable("BuffName")
	self.buff_img = self:FindVariable("BuffImg")
	self.buff_time = self:FindVariable("BuffTime")
	self.buff_dec = self:FindVariable("BuffDec")
	self.begin_time = 0
end

function TipBuffCell:__delete()
	GlobalTimerQuest:CancelQuest(self.buff_timer)
end

function TipBuffCell:OnFlush()
	if not self.data then return end
	--策划说要写死 不要显示
	if self.data.info.client_effect_type == FIGHT_EFFECT_JI_NENG or self.data.info.client_effect_type == FIGHT_EFFECT_CHOU_DI or  self.data.info.client_effect_type == FIGHT_EFFECT_PO_JIA  then return end
	local dec, name = FightData.Instance:GetEffectDesc(self.data)
	if self.data.type == 2 then
		local beauty_skill = BeautyData.Instance:GetBeautySkill(self.data.info.effect_type)
		dec = beauty_skill.buff_explain
		name = beauty_skill.name
		if self.data.info.effect_type == BEAUTY_SHIXIE then
			dec = string.format(dec, self.data.info.param1)
		end
	end
	self.buff_name:SetValue(name)
	self.buff_dec:SetValue(dec)
	self.buff_time:SetValue("")
	GlobalTimerQuest:CancelQuest(self.buff_timer)
	self.begin_time = Status.NowTime
	self.buff_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateBuffTime, self), 1)
	self:UpdateBuffTime()
	-- self.buff_img:SetAsset(ResPath.GetBuffSmallIcon(self.data.info.client_effect_type))
end

function TipBuffCell:UpdateBuffTime()
	if nil == self.data then return end
	if self.data.info.cd_time <= 0 or self.data.info.cd_time >= 10 * 24 * 3600 then   --超过10天不显示时间，方便服务端处理
		return
	end

	local cd_time = self.data.info.cd_time - (Status.NowTime - self.begin_time)
	self.buff_time:SetValue(string.format("(%s)", TipBuffCell.FormatSecond(cd_time)))

	if cd_time <= 0 then
		if self.data ~= nil and self.data.info ~= nil and self.data.info.client_effect_type ~= nil then
			FightData.Instance:SetBuffPause(self.data.info.client_effect_type, 0)
		end		
	end
	-- self.buff_time:SetValue(Language.Common.ShengYuShiJian .. TipBuffCell.FormatSecond(cd_time))
end

function TipBuffCell.FormatSecond(time)
	local s = ""
	if time > 0 then
		local hour = math.floor(time / 3600)
		local minute = math.floor((time / 60) % 60)
		local second = math.floor(time % 60)
		if hour > 0 then
			s = string.format("%02d:%02d:%02d", hour, minute, second)
		else
			s = string.format("%02d:%02d", minute, second)
		end
	else
		s = "00:00"
	end

	return s
end

function TipBuffCell:PauseUpdateTimer()
	if self.buff_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.buff_timer)
		if self.data ~= nil and self.data.info ~= nil and self.data.info.client_effect_type ~= nil then
			FightData.Instance:SetBuffPause(self.data.info.client_effect_type, Status.NowTime)
		end
	end
end