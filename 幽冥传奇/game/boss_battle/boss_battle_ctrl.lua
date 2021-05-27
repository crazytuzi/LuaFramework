require("scripts/game/boss_battle/boss_battle_award_preview")
require("scripts/game/boss_battle/boss_battle_injure_rank")
require("scripts/game/boss_battle/boss_battle_data")

BossBattleCtrl = BossBattleCtrl or BaseClass(BaseController)

function BossBattleCtrl:__init()
	if	BossBattleCtrl.Instance then
		ErrorLog("[BossBattleCtrl]:Attempt to create singleton twice!")
	end
	BossBattleCtrl.Instance = self

	self.data = BossBattleData.New()
	self.view = BossBattledRewardView.New(ViewName.BossBattlefieldRewardPreview)
	self.injure_rank = BossBattleInjureRankView.New(ViewName.BossBattleInjureRank)
	self:RegisterAllProtocols()
end

function BossBattleCtrl:__delete()
	-- self.view:DeleteMe()
	-- self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.injure_rank ~= nil then
		self.injure_rank:DeleteMe()
		self.injure_rank = nil
	end

	BossBattleCtrl.Instance = nil
end

function BossBattleCtrl:RegisterAllProtocols()
	
end