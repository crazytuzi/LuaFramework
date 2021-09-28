require("game/activity_online/activity_online_view")
require("game/activity_online/activity_online_data")
ActivityOnLineCtrl = ActivityOnLineCtrl or BaseClass(BaseController)
function ActivityOnLineCtrl:__init()
	if nil ~= ActivityOnLineCtrl.Instance then
		return
	end

	ActivityOnLineCtrl.Instance = self

	self.view = ActivityOnLineView.New(ViewName.OnLineView)
	self.data = ActivityOnLineData.New()
	self:RegisterAllProtocols()
end

function ActivityOnLineCtrl:__delete()
	ActivityOnLineCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
end

function ActivityOnLineCtrl:RegisterAllProtocols()
	
end

--刷新通用方法，必须从此处刷新
function ActivityOnLineCtrl:FlushView(key)
	if self.view then
		self.view:Flush(key)
	end
end

function ActivityOnLineCtrl:SetActivityStatus(protocol)
	self.data:SetActivityStatus(protocol)

	local num = self.data:GetActivityOpenNum()

	if num > 0 then
		self:FlushView("toggle")
		MainUIView.Instance:SetOnLineIcon(true)
	else
		if self.view:IsOpen() then
			self.view:Close()
		end
		MainUIView.Instance:SetOnLineIcon(false)
	end

	RemindManager.Instance:Fire(ActivityOnLineData.RemindName_From_Id[protocol.activity_type])
end
