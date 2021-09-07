TipsSpiritSoulChangeView = TipsSpiritSoulChangeView or BaseClass(BaseView)

function TipsSpiritSoulChangeView:__init()
	self.ui_config = {"uis/views/tips/spiritsoultips", "SpiritSoulChangeTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true

	self.exchange_count = 0
	self.source_index_list = {}
	self.dest_index_list = {}
end

function TipsSpiritSoulChangeView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickYes", BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo", BindTool.Bind(self.OnClickNo, self))

	self.name_list = {}
	for i = 1, 8 do
		self.name_list[i] = {is_show = self:FindVariable("ShowName"..i), old_name = self:FindVariable("OldName"..i),
				new_name = self:FindVariable("NewName"..i)
		}
	end
end

function TipsSpiritSoulChangeView:__delete()
	self.ok_call_back = nil
end

function TipsSpiritSoulChangeView:ReleaseCallBack()
end

function TipsSpiritSoulChangeView:OpenCallBack()
	self.exchange_count = 0
	self.source_index_list = {}
	self.dest_index_list = {}
	self:Flush()
end

function TipsSpiritSoulChangeView:CloseCallBack()
end

function TipsSpiritSoulChangeView:OnClickYes()
	if self.ok_call_back then
		self.ok_call_back()
		self.ok_call_back = nil
	end
	SpiritCtrl.Instance:SendLieMingExchangeList(self.exchange_count, self.source_index_list, self.dest_index_list)
	self:Close()
end

function TipsSpiritSoulChangeView:OnClickClose()
	self:Close()
end

function TipsSpiritSoulChangeView:OnClickNo()
	self:Close()
end

function TipsSpiritSoulChangeView:SetCallBack(call_back)
	self.ok_call_back = call_back
end

function TipsSpiritSoulChangeView:SetData(change_list)
	self.change_list = change_list
end

function TipsSpiritSoulChangeView:OnFlush()
	if not self.change_list then
		return
	end

	local count = 1
	local empty_count = SpiritData.Instance:GetSlotSoulEmptyCount()
	local slot_list = SpiritData.Instance:GetSpiritSlotSoulInfo().slot_list
	local empty_show_count = 0
	local temp_type_list = SpiritData.Instance:GetSlotSoulTypeList()
	local empty_list= SpiritData.Instance:GetSlotSoulEmptyCountList()

	for k, v in pairs(self.change_list) do
		local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.info.id)
		if cfg then
			if 1 == v.change then
				local old_cfg = SpiritData.Instance:GetSpiritSoulCfg(slot_list[v.slot_index].id)
				local new_str = "<color="..SOUL_NAME_COLOR[cfg.hunshou_color]..">"..cfg.name.."</color>".."LV.1"
				self.name_list[count].new_name:SetValue(new_str)
				if old_cfg then
					local old_str = "<color="..SOUL_NAME_COLOR[old_cfg.hunshou_color]..">"..old_cfg.name.."</color>".."LV."..slot_list[v.slot_index].level
					self.name_list[count].old_name:SetValue(old_str)
				end
				count = count + 1
				self.exchange_count = self.exchange_count + 1
				table.insert(self.source_index_list, v.info.index)
				table.insert(self.dest_index_list, v.slot_index)
			else
				if empty_show_count < empty_count then
					local can_show =  true
					for i, j in pairs(temp_type_list) do
						if j == v.soul_type then
							can_show = false
						end
					end
					if can_show then
						local new_str = "<color="..SOUL_NAME_COLOR[cfg.hunshou_color]..">"..cfg.name.."</color>".."LV.1"
						self.name_list[count].new_name:SetValue(new_str)
						self.name_list[count].old_name:SetValue(Language.JingLing.NoDressSoul)

						self.exchange_count = self.exchange_count + 1

						table.insert(temp_type_list, v.soul_type)
						table.insert(self.source_index_list, v.info.index)
						table.insert(self.dest_index_list, empty_list[count])

						count = count + 1
						empty_show_count = empty_show_count + 1
					end
				end
			end
		end
	end

	for k, v in pairs(self.name_list) do
		v.is_show:SetValue(k < count)
	end
end