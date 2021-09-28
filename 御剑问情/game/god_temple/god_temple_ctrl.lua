require("game/god_temple/god_temple_view")
require("game/god_temple/god_temple_data")
require("game/god_temple/god_temple_rank_view")
require("game/god_temple/god_temple_active_tip_view")
require("game/god_temple/god_temple_info_view")

GodTempleCtrl = GodTempleCtrl or BaseClass(BaseController)

function GodTempleCtrl:__init()
	if GodTempleCtrl.Instance ~= nil then
		ErrorLog("[GodTempleCtrl] attempt to create singleton twice!")
		return
	end

	GodTempleCtrl.Instance = self

	self.data = GodTempleData.New()
	self.view = GodTempleView.New(ViewName.GodTempleView)
	self.active_tip_view = GodTempleActiveTipView.New(ViewName.GodTempleActiveTipView)
	self.rank_view = GodTempleRankView.New(ViewName.GodTempleRankView)
	self.info_view = GodTempleInfoView.New(ViewName.GodTempleInfoView)
end

function GodTempleCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.active_tip_view ~= nil then
		self.active_tip_view:DeleteMe()
		self.active_tip_view = nil
	end

	if self.rank_view ~= nil then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.info_view ~= nil then
		self.info_view:DeleteMe()
		self.info_view = nil
	end
	
	GodTempleCtrl.Instance = nil
end