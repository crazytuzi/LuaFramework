
local fnTrowItem = function (nItemId)
	RemoteServer.InDifferBattleRequestInst("TrowItem", nItemId)
end

local fnUseItem = function (nItemId)
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	RemoteServer.InDifferBattleRequestInst("UseItem", nItemId)
end

local tbItem = Item:GetClass("IndifferAddBuff"); 
function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "丢弃",  szSecondName = "使用"};
    tbUseSetting.fnFirst = function ()
    	fnTrowItem(nItemId) 
    end
    tbUseSetting.fnSecond = function ()
       fnUseItem(nItemId)
    end;
    return tbUseSetting;        
end

function tbItem:OnUse(it)
	local nBuffId = KItem.GetItemExtParam(it.dwTemplateId, 1)
	local nBuffLevel = KItem.GetItemExtParam(it.dwTemplateId, 2)
	local nBuffTime = KItem.GetItemExtParam(it.dwTemplateId, 3)
	me.AddSkillState(nBuffId, nBuffLevel, 0, nBuffTime * Env.GAME_FPS)
	return 1;	
end


local tbItem = Item:GetClass("IndifferCanTrow"); 

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "丢弃"};
    tbUseSetting.fnFirst = function ()
    	fnTrowItem(nItemId) 
    end
    return tbUseSetting;        
end


local tbItem = Item:GetClass("IndifferUseItem"); 

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "丢弃", szSecondName = "使用"};
    tbUseSetting.fnFirst = function ()
    	fnTrowItem(nItemId) 
    end
    tbUseSetting.fnSecond = function ()
       fnUseItem(nItemId)
    end;
    return tbUseSetting;        
end

function tbItem:OnUse(it)
	InDifferBattle:OnUseIndifferItem(me, it.dwTemplateId)
	return 1;	
end