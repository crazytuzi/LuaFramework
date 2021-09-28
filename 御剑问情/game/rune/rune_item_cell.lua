RuneItemCell = RuneItemCell or BaseClass(BaseRender)

function RuneItemCell:__init()
	self.icon_res = self:FindVariable("IconRes")
	self:ListenEvent("Click", BindTool.Bind(self.ClickItem, self))
end

function RuneItemCell:__delete()

end

function RuneItemCell:SetListenEvent(callback)
	self:ClearEvent("Click")
	self:ListenEvent("Click", callback)
end

function RuneItemCell:ClickItem()
	print_error("ClickItem+++++++++++++++")
end

function RuneItemCell:SetToggleEnable(enable)
	self.root_node.toggle.enabled = enabled
end

function RuneItemCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data
end