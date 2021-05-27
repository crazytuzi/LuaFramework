
local LUCKYROLLAWARDINDEX = 30
local GETLUCKYROLLAWARDING = 33
local DROPNAME = "LuckyRollAward"
LuckyRollAwardItemConfig=
{
{
		item_id = 1572,
		needDelete = true,
		needMinBagGrid = 1,
		drop = 1,
    		interfaceName = Lang.ScriptTips.x00091,
		onlyDoRoll = true,
		dropName =
    		{
      			"data/config/item/scriptItemConfig/LuckyRollAwardItemDrops/drops1.lua",
   		},
   	 dropInclude =
    	{
     	   {
--#include "data/config/item/scriptItemConfig/LuckyRollAwardItemDrops/drops1.lua",
      	   },
       },
},
}