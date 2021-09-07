require("game/buff_progress/buff_progress_view")
require("game/buff_progress/buff_progress_data")
BuffProgressCtrl = BuffProgressCtrl or BaseClass(BaseController)
function BuffProgressCtrl:__init()
	if BuffProgressCtrl.Instance ~= nil then
		print_error("[BuffProgressCtrl] attempt to create singleton twice!")
		return
	end
	BuffProgressCtrl.Instance = self

	self.view = BuffProgressView.New(ViewName.BuffProgressView)
	self.data = BuffProgressData.New()
end

function BuffProgressCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function BuffProgressCtrl:Flush(...)
	self.view:Flush(...)
	local buff_num = #self.data:GetBuffList()
	if buff_num <= 0 then
		self.view:Close()
	end
end