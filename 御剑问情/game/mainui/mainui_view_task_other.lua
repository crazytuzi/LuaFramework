MainUIViewTaskOther = MainUIViewTaskOther or BaseClass(BaseRender)

function MainUIViewTaskOther:__init()
	self.other_toggle = self:FindObj("OtherToggle")
	self.task_toggle = self:FindObj("TaskToggle")
	self.team_toggle = self:FindObj("TeamToggle")
	self.other_content = self:FindObj("OtherContent")
	self.show_other = self:FindVariable("ShowOther")
	self.show_team = self:FindVariable("ShowTeam")
	self.other_text = self:FindVariable("OtherText")
	self.other_view_change_event = GlobalEventSystem:Bind(MainUIEventType.OTHER_INFO_CHANGE, BindTool.Bind(self.OtherViewInfoChange, self))
end

function MainUIViewTaskOther:__delete()
	if self.other_view_change_event then
		GlobalEventSystem:UnBind(self.other_view_change_event)
		self.other_view_change_event = nil
	end
	if self.other_view then
		self.other_view:DeleteMe()
		self.other_view = nil
	end
end

local is_loading = false
-- param = {change_type=0关闭1打开2刷新, view=面板, title=标签名}
function MainUIViewTaskOther:OtherViewInfoChange(param)
	if not self.task_toggle.gameObject.activeInHierarchy
		or (self.param == nil or self.param.change_type == 0) and param.change_type == 2 then
		return
	end
	self.show_other:SetValue(true)
	self.show_team:SetValue(true)
	self.param = param
	if param.change_type == 0 then
		self.task_toggle.toggle.isOn = true
		if self.other_view then
			self.other_view:DeleteMe()
			self.other_view = nil
		end
		is_loading = false
	else
		if param.title then
			self.other_text:SetValue(param.title)
		end
	end
	if param.change_type ~= 0 and self.other_view == nil then
		self.other_toggle.toggle.isOn = true
	end
	self.show_other:SetValue(param.change_type ~= 0)
	self.show_team:SetValue(param.change_type == 0)
	if param.change_type ~= 0 then
		if param.change_type == 1 and self.other_view == nil then
			if not is_loading then
				is_loading = true
				local asset, bundle = param.view.AssetBundle()
				UtilU3d.PrefabLoad(asset, bundle, function(obj)
						obj.transform:SetParent(self.other_content.transform, false)
						obj = U3DObject(obj)
						self.other_view = param.view.New(obj, self)
						self.other_view:Flush()
						is_loading = false
						if not self.show_other:GetBoolean() then
							self.other_view:DeleteMe()
							self.other_view = nil
						end
					end)

			 end
		elseif self.other_view then
			self.other_view:Flush()
		end
	end
end

function MainUIViewTaskOther:ReFreshState()
	if self.param and (self.param.change_type ~= 0 or self.other_view ~= nil) then
		self:OtherViewInfoChange(self.param)
	end
end

function MainUIViewTaskOther:HasOtherPanel()
	if self.param and self.param.change_type ~= 0 then
		return true
	end
	return false
end

function MainUIViewTaskOther:OnFlush()

end