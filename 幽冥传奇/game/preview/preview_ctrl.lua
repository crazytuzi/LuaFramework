require("scripts/game/preview/preview_data")
require("scripts/game/preview/preview_view")

--------------------------------------------------------
-- 物品预览
--------------------------------------------------------

PreviewCtrl = PreviewCtrl or BaseClass(BaseController)

function PreviewCtrl:__init()
	if	PreviewCtrl.Instance then
		ErrorLog("[PreviewCtrl]:Attempt to create singleton twice!")
	end
	PreviewCtrl.Instance = self

	self.data = PreviewData.New()
	self.view = PreviewView.New(ViewDef.Preview)
end

function PreviewCtrl:__delete()
	PreviewCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

