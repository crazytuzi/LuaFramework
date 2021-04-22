-- 技能 暗器 鬼泣弹雨 飞弹
-- 技能ID 40530~40534
-- 具体的子弹
--[[
	暗器 鬼见愁
	ID:1528
	psf 2020-1-17
]]--

local function SetBullets(sp_x,sp_y,_flag)
	local _set_points = set_p
	local _bullet
	_bullet = {
		CLASS = "composite.QSBSequence",
		ARGS = {
			{
				CLASS = "action.QSBArgsIsUnderStatus",	
				OPTIONS = {is_attacker = true, status = "sszhuzhuqing_wuhun_jt"},--针对朱竹清小加强一波护盾
			},
			{
				CLASS = "composite.QSBSelector",
				ARGS = {
					{
						CLASS = "action.QSBStealedAbsorb",
						OPTIONS = {buff_id = "anqi_guijianchou_buff2_plus",percent = 0.06},
					},
					{
						CLASS = "action.QSBStealedAbsorb",
						OPTIONS = {buff_id = "anqi_guijianchou_buff2",percent = 0.06},
					},
				},
			},
			{
				CLASS = "action.QSBBullet",
				OPTIONS = {
					start_pos = {x = sp_x,y = sp_y}, is_bezier = true, length_threshold = 250 ,flag = _flag
				},
			},
		},
	}
	return _bullet
end

local anqi_guijianchou_trigger2 = 
{
	CLASS = "composite.QSBSequence",
	OPTIONS = {forward_mode = true},
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",	
			OPTIONS = {buff_id = "anqi_guijianchou_count"},
		},
		{
			CLASS = "action.QSBArgsSelectTarget",
			OPTIONS = {range = {max = 5}, cancel_if_not_found = true, change_all_node_target = true},
		},
		{
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
				failed_select = 5,
				{expression = "self:buff_num:anqi_guijianchou_count=1", select = 1},
				{expression = "self:buff_num:anqi_guijianchou_count=2", select = 2},
				{expression = "self:buff_num:anqi_guijianchou_count=3", select = 3},
				{expression = "self:buff_num:anqi_guijianchou_count=4", select = 4},
				{expression = "self:buff_num:anqi_guijianchou_count=5", select = 1},
				{expression = "self:buff_num:anqi_guijianchou_count=6", select = 2},
				{expression = "self:buff_num:anqi_guijianchou_count=7", select = 3},
				{expression = "self:buff_num:anqi_guijianchou_count=8", select = 4},
				{expression = "self:buff_num:anqi_guijianchou_count>8", select = 5},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
				SetBullets(10,118,3),
				SetBullets(0,100,4),
				SetBullets(10,122,3),
				SetBullets(0,103,4),
				{
					CLASS = "action.QSBRemoveBuff",	
					OPTIONS = {buff_id = "anqi_guijianchou_buff1"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_trigger2

