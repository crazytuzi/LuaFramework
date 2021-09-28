FlowerRemindView = FlowerRemindView or BaseClass(BaseView)

function FlowerRemindView:__init()
	self.ui_config = {"uis/views/flowerremindview_prefab","FlowerRemindView"}
	self.full_screen = false
	self.view_layer = UiLayer.MainUIHigh
end

function FlowerRemindView:LoadCallBack()
	self:ListenEvent("OnClickCloseEffect",BindTool.Bind(self.OnClickCloseEffect,self))
end

function FlowerRemindView:OnClickCloseEffect()
	-- SettingData.Instance:SetSettingData(SETTING_TYPE.FLOWER_EFFECT,true,true)
	FlowersCtrl.Instance:StopEffect()
	self:Close()
end