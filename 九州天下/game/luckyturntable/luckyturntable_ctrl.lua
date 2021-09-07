require("game/luckyturntable/luckyturntable_data")
require("game/luckyturntable/luckyturntable_view")

LuckyTurntableCtrl= LuckyTurntableCtrl or BaseClass(BaseController)

function LuckyTurntableCtrl:__init()
	if LuckyTurntableCtrl.Instance then
		print_error("[LuckyTurntableCtrl]:Attempt to create singleton twice!")
	end
	LuckyTurntableCtrl.Instance = self
	self.view = LuckyTurntableView.New(ViewName.LuckyTurntableView)
	self.data = LuckyTurntableData.New()
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function LuckyTurntableCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

    if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
    
	LuckyTurntableCtrl.Instance = nil
end

function LuckyTurntableCtrl:GetView()
	return self.view
end

function LuckyTurntableCtrl:GetData()
	return self.data
end

function LuckyTurntableCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAOneYuanDrawInfo, "OnSCRAOneYuanDrawInfo")
end

function LuckyTurntableCtrl:OnSCRAOneYuanDrawInfo(protocol)
	self.data:SetLuckyTurntable(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LuckyTurntable)
end

function LuckyTurntableCtrl:MianUIOpenComlete()
	RemindManager.Instance:Fire(RemindName.LuckyTurntable)
end