FeedbackData = FeedbackData or BaseClass()

function FeedbackData:__init()
	if FeedbackData.Instance then
		ErrorLog("[FeedbackData]:Attempt to create singleton twice!")
	end
	FeedbackData.Instance = self

end

function FeedbackData:__delete()
	FeedbackData.Instance = nil
end

function FeedbackData:IsShowFeedback()
	return not ClientHideFeedbackCfg[AgentAdapter:GetSpid()]
end