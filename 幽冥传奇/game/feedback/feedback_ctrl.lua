require("scripts/game/feedback/feedback_data")
require("scripts/game/feedback/feedback_view")

FeedbackCtrl = FeedbackCtrl or BaseClass(BaseController)

function FeedbackCtrl:__init()
	if FeedbackCtrl.Instance then
		ErrorLog("[FeedbackCtrl]:Attempt to create singleton twice!")
	end
	FeedbackCtrl.Instance = self
	self.view = FeedbackView.New(ViewName.Feedback)
	self.data = FeedbackData.New()
	self:RegisterAllProtocols()
end

function FeedbackCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	FeedbackCtrl.Instance = nil
end

function FeedbackCtrl:RegisterAllProtocols()

end