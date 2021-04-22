local QBuriedPoint = {}

local DungeonStartDictionary = 
{
	["wailing_caverns_2"] 			= 20641,
	["wailing_caverns_3"] 			= 20731,
	["wailing_caverns_4"] 			= 20801,
	["wailing_caverns_5"] 			= 21081,
	["wailing_caverns_6"] 			= 21111,
	["wailing_caverns_7"] 			= 21113,
	["wailing_caverns_8"] 			= 21115,
	["wailing_caverns_9"] 			= 21117,
	["wailing_caverns_10"] 			= 21261,
	["wailing_caverns_11"] 			= 21263,
	["wailing_caverns_12"] 			= 21265,
	["wailing_caverns_13"] 			= 21271,
	["wailing_caverns_14"] 			= 21273,
	["wailing_caverns_15"] 			= 21341,
	["wailing_caverns_16"] 			= 21343,
	["wailing_caverns_17"] 			= 21345,
	["wailing_caverns_18"] 			= 21347,
	["wailing_caverns_19"] 			= 21349,
	["wailing_caverns_20"] 			= 21351,
	["wailing_caverns_21"] 			= 21381,
	["wailing_caverns_22"] 			= 21383,
	["wailing_caverns_23"] 			= 21431,
	["wailing_caverns_24"] 			= 21433,
}

local DungeonWinDictionary =
{
	["wailing_caverns_1"]			= 20500,
	["wailing_caverns_2"]			= 20690,
	["wailing_caverns_3"] 			= 20760,
	["wailing_caverns_4"] 			= 20880,
	["wailing_caverns_5"] 			= 21100,
	["wailing_caverns_6"] 			= 21112,
	["wailing_caverns_7"] 			= 21114,
	["wailing_caverns_8"] 			= 21116,
	["wailing_caverns_9"] 			= 21118,
	["wailing_caverns_10"] 			= 21262,
	["wailing_caverns_11"] 			= 21264,
	["wailing_caverns_12"] 			= 21266,
	["wailing_caverns_13"] 			= 21272,
	["wailing_caverns_14"] 			= 21274,
	["wailing_caverns_15"] 			= 21342,
	["wailing_caverns_16"] 			= 21344,
	["wailing_caverns_17"] 			= 21346,
	["wailing_caverns_18"] 			= 21348,
	["wailing_caverns_19"] 			= 21350,
	["wailing_caverns_20"] 			= 21352,
	["wailing_caverns_21"] 			= 21382,
	["wailing_caverns_22"] 			= 21384,
	["wailing_caverns_23"] 			= 21432,
	["wailing_caverns_24"] 			= 21434,
}

local DungeonDialogDictionary = 
{
	["wailing_caverns_1"] = 
	{
		[1]							= 20390,
		[2]							= 20400,
		[3]							= 20440,
		[4]							= 20460,
		[5]							= 20480,
		[6]							= 20490,
	},
	["wailing_caverns_2"] = 
	{
		[1]							= 20650,
		[2]							= 20660,
	},
	["wailing_caverns_3"] = 
	{
		[1]							= 20741,
		[2]							= 20742,
	},
	["wailing_caverns_4"] = 
	{
		[1]							= 20860,
		[2]							= 20870,
		[3]							= 20871,
	},
	["wailing_caverns_5"] = 
	{
		[1]							= 21082,
		[2]							= 21083,
	}
	-- ["wailing_caverns_8"] = 
	-- {
	-- 	[1]							= 97,
	-- 	[2]							= 98,
	-- 	[3]							= 99,
	-- },
	-- ["wailing_caverns_9"] = 
	-- {
	-- 	[1]							= 103,
	-- 	[2]							= 104,
	-- 	[3]							= 105,
	-- 	[4]							= 107,
	-- },
	-- ["wailing_caverns_10"] = 
	-- {
	-- 	[1]							= 122,
	-- 	[2]							= 123,
	-- 	[3]							= 124,
	-- },
	-- ["wailing_caverns_12"] = 
	-- {
	-- 	[1]							= 131,
	-- 	[2]							= 132,
	-- 	[3]							= 133,
	-- 	[4]							= 134,
	-- 	[5]							= 135,
	-- 	[6]							= 136,
	-- },
	-- ["wailing_caverns_16"] = 
	-- {
	-- 	[1]							= 154,
	-- 	[2]							= 155,
	-- 	[3]							= 156,
	-- },
	-- ["wailing_caverns_20"] = 
	-- {
	-- 	[1]							= 168,
	-- 	[2]							= 169,
	-- 	[3]							= 170,
	-- },
	-- ["wailing_caverns_22"] = 
	-- {
	-- 	[1]							= 181,
	-- 	[2]							= 182,
	-- 	[3]							= 183,
	-- 	[4]							= 184,
	-- 	[5]							= 185,
	-- },
	-- ["wailing_caverns_24"] = 
	-- {
	-- 	[1]							= 197,
	-- 	[2]							= 198,
	-- 	[3]							= 199,
	-- },
}

local DungeonTutorialDictionary = 
{
	["wailing_caverns_1"] = 
	{
		[1]							= 20420,
		[2]							= 20450,
		[3]							= 20470,
	},
	["wailing_caverns_2"] = 
	{
		[1]							= 20670,
		[2]							= 20680,
	},
	["wailing_caverns_3"] = 
	{
		[1]							= 20740,
		[2]							= 20750,
	},
	["wailing_caverns_5"] = 
	{
		[1]							= 21090,
		-- [2]							= 82,
		-- [3]							= 83,
	},
	-- ["wailing_caverns_6"] = 
	-- {
	-- 	[1]							= 86,
	-- 	[2]							= 87,
	-- },
	-- ["wailing_caverns_7"] = 
	-- {
	-- 	[1]							= 93,
	-- 	[2]							= 94,
	-- },
	-- ["wailing_caverns_8"] = 
	-- {
	-- 	[1]							= 102,
	-- 	[2]							= 106,
	-- },
	-- ["wailing_caverns_10"] = 
	-- {
	-- 	[1]							= 125,
	-- 	[2]							= 126,
	-- },
	-- ["wailing_caverns_16"] = 
	-- {
	-- 	[1]							= 157,
	-- },
	-- ["wailing_caverns_18"] = 
	-- {
	-- 	[1]							= 162,
	-- },
	-- ["wailing_caverns_19"] = 
	-- {
	-- 	[1]							= 165,
	-- },
	-- ["wailing_caverns_21"] = 
	-- {
	-- 	[1]							= 178,
	-- },
	-- ["wailing_caverns_22"] = 
	-- {
	-- 	[1]							= 186,
	-- },
	-- ["wailing_caverns_23"] = 
	-- {
	-- 	[1]							= 194,
	-- },
}

function QBuriedPoint:getDungeonStartBuriedPointID(dungeon_id)
 	return DungeonStartDictionary[dungeon_id]
end

function QBuriedPoint:getDungeonWinBuriedPointID(dungeon_id)
	return DungeonWinDictionary[dungeon_id]
end

function QBuriedPoint:getDungeonDialogBuriedPointID(dungeon_id, index)
	local obj = DungeonDialogDictionary[dungeon_id]
	if obj then
		return obj[index]
	end
end

function QBuriedPoint:getDungeonTutorialBuriedPointID(dungeon_id, index)
	local obj = DungeonTutorialDictionary[dungeon_id]
	if obj then
		return obj[index]
	end
end

return QBuriedPoint