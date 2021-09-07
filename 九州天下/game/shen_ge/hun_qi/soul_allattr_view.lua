SoulAllAttrView = SoulAllAttrView or BaseClass(BaseView)
function SoulAllAttrView:__init()
	self.ui_config = {"uis/views/hunqiview", "SoulAllAttrView"}
	self.view_layer = UiLayer.Pop
	self.hunqi_index = 0
end

function SoulAllAttrView:__delete()

end

function SoulAllAttrView:ReleaseCallBack()
	self.capability = nil
	self.fangyu = nil
	self.gongji = nil
	self.hp = nil
	self.special_num = nil
end

function SoulAllAttrView:LoadCallBack()
	self.capability = self:FindVariable("Capability")
	self.fangyu = self:FindVariable("Fangyu")
	self.gongji = self:FindVariable("Gongji")
	self.hp = self:FindVariable("Hp")
	self.special_num = self:FindVariable("SpecialNum")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function SoulAllAttrView:CloseWindow()
	self:Close()
end

function SoulAllAttrView:OpenCallBack()
	local attr_list = HunQiData.Instance:GetAllElementAttrInfo(self.hunqi_index)
	if nil == attr_list then
		return
	end

	self.hp:SetValue(attr_list.max_hp)
	self.gongji:SetValue(attr_list.gong_ji)
	self.fangyu:SetValue(attr_list.fang_yu)
	local capability = CommonDataManager.GetCapability(attr_list)
	self.capability:SetValue(capability)
	local special_num = string.format("%.1f", attr_list.special/100)
	self.special_num:SetValue(special_num)
end

function SoulAllAttrView:SetHunQiIndex(hunqi_index)
	self.hunqi_index = hunqi_index
end