--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/9/18
    Time: 20:50
   ]]

_G.RemindFuncConditionUtil = {};

function RemindFuncConditionUtil:GetProp(id)
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	for k, v in pairs(t_funcremindcondition) do
		if v.index == id and myLevel >= v.min and myLevel <= v.max then
			return v.prop;
		end
	end
	return;
end

function RemindFuncConditionUtil:GetPropToInt(id)
	return toint(self:GetProp(id));
end

function RemindFuncConditionUtil:IsItemEnoughByItemID(id)
	local itemStr = self:GetProp(id);
	if not itemStr then return false; end
	local itemInfo = GetCommaTable(itemStr);
	local itemID = toint(itemInfo[1]);
	local itemCount = toint(itemInfo[2]);
	if BagModel:GetItemNumInBag(itemID) >= itemCount then
		return true;
	end
	return false;
end

function RemindFuncConditionUtil:IsPlayerInfoEnough(id)
	local attrStr = self:GetProp(id);
	if not attrStr then return false; end
	local attrInfo = GetCommaTable(attrStr);
	local attrID = toint(attrInfo[1]);
	local attrValue = toint(attrInfo[2]);
	if MainPlayerModel.humanDetailInfo[attrID] >= attrValue then
		return true;
	end
	return false;
end