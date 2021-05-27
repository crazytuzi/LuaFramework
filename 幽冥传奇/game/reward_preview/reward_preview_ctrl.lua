require("scripts/game/reward_preview/reward_preview_data")
require("scripts/game/reward_preview/reward_preview_view")

--------------------------------------------------------
-- 物品预览
--------------------------------------------------------

RewardPreviewCtrl = RewardPreviewCtrl or BaseClass(BaseController)

function RewardPreviewCtrl:__init()
	if	RewardPreviewCtrl.Instance then
		ErrorLog("[RewardPreviewCtrl]:Attempt to create singleton twice!")
	end
	RewardPreviewCtrl.Instance = self

	self.data = RewardPreviewData.New()
	self.view = RewardPreviewView.New(ViewDef.RewardPreview)
end

function RewardPreviewCtrl:__delete()
	RewardPreviewCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

