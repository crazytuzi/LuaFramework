-- 技能 比比东大招
-- 技能ID 391
-- 根据状态释放不同攻击
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_hetiji = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {		
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBUncancellable",
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true, status = "bibidong_shihun",},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "composite.QSBParallel",
									ARGS = 
									{
										{
											CLASS = "action.QSBHitTarget",
										},
										{
											CLASS = "action.QSBTriggerSkill",
											OPTIONS = {skill_id = 200393,skill_level = -1,wait_finish = true},--噬魂
										},
									},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_dazhao_siwang"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_hetiji_siwang"},
								},
								--支配
								{
									CLASS = "action.QSBArgsConditionSelector",
									OPTIONS = {
										failed_select = 3,
										{expression = "self:has_buff:bibidong_beidong2_plus_buff=1", select = 1},
										{expression = "self:has_buff:bibidong_beidong2_buff=1", select = 2},
									}
								},
								{
									CLASS = "composite.QSBSelector",
									ARGS = {
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBRemoveBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_plus_siwang",teammate_and_self = true},
												},
												{
													CLASS = "action.QSBApplyBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_plus_shihun;y",highest_attack_teammate = true, prior_role="dps"},
												},
											},
										},
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBRemoveBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_siwang",teammate_and_self = true},
												},
												{
													CLASS = "action.QSBApplyBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_shihun;y", highest_attack_teammate = true, prior_role="dps"},
												},
											},
										},
									},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBTriggerSkill",
									OPTIONS = {skill_id = 200392,skill_level = -1,wait_finish = true},--死亡
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_dazhao_shihun"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "pf_bibidong01_hetiji_shihun"},
								},
								
								--支配
								{
									CLASS = "action.QSBArgsConditionSelector",
									OPTIONS = {
										failed_select = 3,
										{expression = "self:has_buff:bibidong_beidong2_plus_buff=1", select = 1},
										{expression = "self:has_buff:bibidong_beidong2_buff=1", select = 2},
									}
								},
								{
									CLASS = "composite.QSBSelector",
									ARGS = {
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBRemoveBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_plus_shihun",teammate_and_self = true},
												},
												{
													CLASS = "action.QSBApplyBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_plus_siwang;y",lowest_hp_teammate = true},
												},
											},
										},
										{
											CLASS = "composite.QSBParallel",
											ARGS = {
												{
													CLASS = "action.QSBRemoveBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_shihun",teammate_and_self = true},
												},
												{
													CLASS = "action.QSBApplyBuff",
													OPTIONS = {buff_id = "pf_bibidong01_beidong2_siwang;y",lowest_hp_teammate = true},
												},
											},
										},
									},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
					}
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}
return bibidong_hetiji

