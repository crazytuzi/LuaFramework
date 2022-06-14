function SyncChallengeInfoHandler( greatMagics, challengeDamageDefence, challengeDamageResilience )
		 dataManager.kingMagic:setGreatMagic(greatMagics);
		 --dataManager.hurtRankData:SetCurrentStageIndex(challengeDamageIndex)
		 dataManager.hurtRankData:SetBossAtt(challengeDamageDefence,challengeDamageResilience)
end
