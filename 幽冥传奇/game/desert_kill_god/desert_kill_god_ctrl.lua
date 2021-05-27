require("scripts/game/desert_kill_god/desert_kill_god_data")
require("scripts/game/desert_kill_god/desert_kill_god_award_preview")


-- 盟重杀神
DesertKillGodCtrl = DesertKillGodCtrl or BaseClass(BaseController)

function DesertKillGodCtrl:__init()
	if	DesertKillGodCtrl.Instance then
		ErrorLog("[DesertKillGodCtrl]:Attempt to create singleton twice!")
	end
	DesertKillGodCtrl.Instance = self

	self.data = DesertKillGodData.New()
	self.award_preview = DesertKillGodAwardPreview.New(ViewName.DesertKillGodAwardPreview)
	self:RegisterAllProtocols()
end

function DesertKillGodCtrl:__delete()
	self.award_preview:DeleteMe()
	self.award_preview = nil

	self.data:DeleteMe()
	self.data = nil


	DesertKillGodCtrl.Instance = nil
end

function DesertKillGodCtrl:RegisterAllProtocols()
	
end