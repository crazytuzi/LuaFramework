--斗罗SKILL 通用终极封锁触发技
--宗门武魂争霸
--id 51403
--通用
--[[
放陷阱
]]--
--创建人：庞圣峰
--创建时间：2019-1-24

local TRAP_COLUMN_NUM = 4
local TRAP_ROW_NUM = 4
local TRAP_WAIT_NUM = 0
local TRAP_COL_INTERVAL_TIME = 1
local TRAP_ROW_INTERVAL_TIME = 0.5
local MAX_X = 1100
local MIN_X = 150
local MAX_Y = 500
local MIN_Y = 200
local function CustomTrapPosTable(is_left,is_up,test)
	local custom_args = {}
	local col = 0
	local row = 0
	local r = 0
	local dx = (MIN_X - MAX_X)/TRAP_COLUMN_NUM/2
	local dy = (MAX_Y - MIN_Y)/TRAP_ROW_NUM/2
	local t = {delay_time = 0,pos = {x = 0 ,y = 0}}
	if is_left then
		t.pos["x"] = MIN_X
		dx = -dx
	else
		t.pos["x"] = MAX_X
	end
	if is_up then
		t.pos["y"] = MAX_Y
		dy = -dy 
	else
		t.pos["y"] = MIN_Y
	end
	while col <= TRAP_COLUMN_NUM do
		col = col + 1
		if col <= TRAP_WAIT_NUM then
			while r < TRAP_ROW_NUM do
				table.insert(custom_args,clone(t))
				t.delay_time = t.delay_time + TRAP_ROW_INTERVAL_TIME
				t.pos["y"] = t.pos["y"] + dy
				r = r + 1
			end
			r = 0
		else
			table.insert(custom_args,clone(t))
			t.pos["y"] = t.pos["y"] + dy
		end
		t.pos["x"] = t.pos["x"] + dx
		t.delay_time = t.delay_time + TRAP_COL_INTERVAL_TIME
	end
	--
	if test then
		for _,m in pairs(custom_args) do
			print("delay_time = "..m.delay_time.." , pos.x = "..m.pos["x"].." , pos.y = "..m.pos["y"])
		end
	end
	--
	return custom_args
end

local zmwh_boss_tongyong_fourth1_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
     	{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
					--上半场
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap1",
								args = CustomTrapPosTable(true,true)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap2",
								args = CustomTrapPosTable(true,true)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap1",
								args = CustomTrapPosTable(true,false)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap2",
								args = CustomTrapPosTable(true,false)
							},
						},
					--下半场
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap1",
								args = CustomTrapPosTable(false,true)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap2",
								args = CustomTrapPosTable(false,true)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap1",
								args = CustomTrapPosTable(false,false)
							},
						},
						{
							CLASS = "action.QSBTrap",  
							OPTIONS = 
							{ 
								trapId = "zmwh_boss_tongyong_fourth1_trap2",
								args = CustomTrapPosTable(false,false)
							},
						},
					},
				},
			},
		},
    },
}
return zmwh_boss_tongyong_fourth1_trigger