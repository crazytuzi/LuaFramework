--[[
物品使用脚本
lizhuangzhuang
2014年11月12日14:52:51
]]

_G.ItemScriptCfg = {};

function ItemScriptCfg:Add(script)
	if ItemScriptCfg[script.name] then
		print("Error:物品脚本重复！！！！",script.name);
		return;
	end
	ItemScriptCfg[script.name] = script;
end

_dofile (ClientConfigPath .. "config/itemScript/openfunc.lua")
_dofile (ClientConfigPath .. "config/itemScript/openui.lua")
_dofile (ClientConfigPath .. "config/itemScript/hornsend.lua")
_dofile (ClientConfigPath .. "config/itemScript/openjewellery.lua")
_dofile (ClientConfigPath .. "config/itemScript/openhecheng.lua")
_dofile (ClientConfigPath .. "config/itemScript/equipgroup.lua")
_dofile (ClientConfigPath .. "config/itemScript/openUpgradeStone.lua")
_dofile (ClientConfigPath .. "config/itemScript/openItemCardChange.lua")
_dofile (ClientConfigPath .. "config/itemScript/itemDailyPackage.lua")
_dofile (ClientConfigPath .. "config/itemScript/itemPackageItemCost.lua")
_dofile (ClientConfigPath .. "config/itemScript/unionupitem.lua")
_dofile (ClientConfigPath .. "config/itemScript/ItemMarryMyDate.lua")
_dofile (ClientConfigPath .. "config/itemScript/ItemMarryBeDate.lua")
_dofile (ClientConfigPath .. "config/itemScript/openmarry.lua")
_dofile (ClientConfigPath .. "config/itemScript/ItemMarryRingUse.lua")
_dofile (ClientConfigPath .. "config/itemScript/openHallows.lua")
_dofile (ClientConfigPath .. "config/itemScript/itemChangeRoleName.lua")

--[[
物品数量变化脚本
lizhuangzhuang
2015年5月5日11:07:47
]]

_G.ItemNumCScriptCfg = {};

function ItemNumCScriptCfg:Add(script)
	if ItemNumCScriptCfg[script.name] then
		print("Error:物品脚本重复！！！！",script.name);
		return;
	end
	ItemNumCScriptCfg[script.name] = script;
end

_dofile (ClientConfigPath .. "config/itemScript/strenbonechange.lua")
_dofile (ClientConfigPath .. "config/itemScript/itemguideuse.lua")
_dofile (ClientConfigPath .. "config/itemScript/itemstatguideuse.lua")
_dofile (ClientConfigPath .. "config/itemScript/pillchange.lua")
_dofile (ClientConfigPath .. "config/itemScript/gemdebrischange.lua")
_dofile (ClientConfigPath .. "config/itemScript/productnumchange.lua")
-- _dofile (ClientConfigPath .. "config/itemScript/jewellerychange.lua")
_dofile (ClientConfigPath .. "config/itemScript/mountchange.lua")
_dofile (ClientConfigPath .. "config/itemScript/realmchange.lua")
_dofile (ClientConfigPath .. "config/itemScript/linglidanchange.lua")
_dofile (ClientConfigPath .. "config/itemScript/linglidanchange1.lua")
_dofile (ClientConfigPath .. "config/itemScript/linglidanchange2.lua")
_dofile (ClientConfigPath .. "config/itemScript/openFirstChargePanel.lua")
_dofile (ClientConfigPath .. "config/itemScript/firstChargeItemChange.lua")
_dofile (ClientConfigPath .. "config/itemScript/shengmingquanchange.lua")
