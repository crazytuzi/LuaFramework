-- 技能 暗器 佛怒唐莲
-- 技能ID 40414~40418
-- 清除控制. 没有标记上标记anqi_fonutanglian_buff;有标记就射子弹.
--[[
	暗器 佛怒唐莲
	ID:1525
	psf 2019-8-12
]]--

local anqi_fonutanglian_trigger1 = 
{
	 CLASS = "composite.QSBSequence",
	 ARGS = 
	 {
		{
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "action.QSBApplyBuff",	
					OPTIONS = {buff_id = "anqi_fonutanglian_buff_2"}
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "stun"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "stun_charge"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "silence"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "time_stop"},--时间静止效果不能解
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "freeze"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "fall"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "winding_of_cane"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "fear"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "sheep"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "sheep_1"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "sheep_2"},
				},
				{
					CLASS = "action.QSBRemoveBuffByStatus",
					OPTIONS = {status = "sheep_3"},
				},
			},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_time = 5.5},
		},
		{
			CLASS = "action.QSBBullet",	
			OPTIONS = {start_pos = {x = 150,y = 100}, check_target_by_skill = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_fonutanglian_trigger1

