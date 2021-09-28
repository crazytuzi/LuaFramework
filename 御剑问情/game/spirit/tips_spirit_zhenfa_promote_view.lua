require("game/spirit/xianzhen_upgrade_view")
require("game/spirit/hunyu_upgrade_view")
TipsSpiritZhenFaPromoteView = TipsSpiritZhenFaPromoteView or BaseClass(BaseView)
local TAB_BAR = {
		XIANZHEN = 1,
		HUNYU = 2,
	}
function TipsSpiritZhenFaPromoteView:__init()
	self.ui_config = {"uis/views/tips/spiritzhenfatip_prefab","SpiritZhenfaPromoteTip"}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.data = nil
	self.play_audio = true
end

function TipsSpiritZhenFaPromoteView:LoadCallBack()	
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))
	--self:ListenEvent("ChooseSpirit",
	--	BindTool.Bind(self.,self))
	self.lingzhen_toggle = self:FindObj("lingzhen_toggle")
	self.hunyu_toggle = self:FindObj("hunshouyu_toggle")
	self.is_xianzhen_show_red_point = self:FindVariable("is_xianzhen_show_red_point")
	self.is_hunyu_show_red_point = self:FindVariable("is_hunyu_show_red_point")

	local xianzhen_upgrade_content = self:FindObj("xianzhenupgrade_content")

	UtilU3d.PrefabLoad("uis/views/tips/spiritzhenfatip_prefab", "LingZhenContent",
	function(obj)
		obj.transform:SetParent(xianzhen_upgrade_content.transform, false)
		obj = U3DObject(obj)
		self.xianzhen_upgrade_view = XianZhenUpGradeView.New(obj)
		self.xianzhen_upgrade_view:Flush()
	end)

	local hunyu_upgrade_content = self:FindObj("hunyuupgrade_content")

	UtilU3d.PrefabLoad("uis/views/tips/spiritzhenfatip_prefab", "HunShouYuContent",
	function(obj)
		obj.transform:SetParent(hunyu_upgrade_content.transform, false)
		obj = U3DObject(obj)
		self.hunyu_upgrade_view = HunYuUpGradeView.New(obj)
		self.hunyu_upgrade_view:Flush()
	end)

	self.lingzhen_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TAB_BAR.XIANZHEN))
	self.hunyu_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TAB_BAR.HUNYU))
end

function TipsSpiritZhenFaPromoteView:__delete()

end

function TipsSpiritZhenFaPromoteView:ReleaseCallBack()
	-- 清理变量
	-- self.lingzhen_toggle = nil
	-- self.hunyu_toggle = nil
	-- if self.xianzhen_upgrade_view then
	-- 	self.xianzhen_upgrade_view:DeleteMe()
	-- 	self.xianzhen_upgrade_view = nil
	-- end
	-- if self.hunyu_upgrade_view then
	-- 	self.hunyu_upgrade_view:DeleteMe()
	-- 	self.hunyu_upgrade_view = nil
	-- end
	self.lingzhen_toggle = nil
	self.hunyu_toggle = nil
	self.is_xianzhen_show_red_point = nil
	self.is_hunyu_show_red_point = nil
	if self.xianzhen_upgrade_view then
		self.xianzhen_upgrade_view:DeleteMe()
		self.xianzhen_upgrade_view = nil
	end
	if self.hunyu_upgrade_view then
		self.hunyu_upgrade_view:DeleteMe()
		self.hunyu_upgrade_view = nil
	end
end

function TipsSpiritZhenFaPromoteView:OnToggleChange(index, is_on)
	if is_on then
		self:ShowIndex(index)
	end
end

function TipsSpiritZhenFaPromoteView:OpenCallBack()

end

function TipsSpiritZhenFaPromoteView:CloseCallBack()
	
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end

end

function TipsSpiritZhenFaPromoteView:SetData(tab_index)

end

function TipsSpiritZhenFaPromoteView:ShowIndexCallBack(index)
	if index == TAB_BAR.XIANZHEN and not self.lingzhen_toggle.toggle.isOn then
		self.lingzhen_toggle.toggle.isOn = true
	elseif index == TAB_BAR.HUNYU and not self.hunyu_toggle.toggle.isOn then
	 	self.hunyu_toggle.toggle.isOn = true
	end
	self:Flush()
end

function TipsSpiritZhenFaPromoteView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritZhenFaPromoteView:OnFlush()
	if nil ~= self.xianzhen_upgrade_view then
		self.xianzhen_upgrade_view:Flush()
	end
	if nil ~= self.hunyu_upgrade_view then
		self.hunyu_upgrade_view:Flush()
	end
	self.is_xianzhen_show_red_point:SetValue(SpiritData.Instance:CanXianZhenUp())
	self.is_hunyu_show_red_point:SetValue(SpiritData.Instance:ShowAllHunyuRedPoint())
end