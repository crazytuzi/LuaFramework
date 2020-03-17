--[[
物品
参数格式:type,itemId,自由参数
自由参数定义：
	super=		卓越属性{id;val1;val2}
	wing=		是翅膀时{attrFlag}
lizhuangzhuang
2014年9月17日21:22:58
]]

_G.ItemChatParam = setmetatable({},{__index=ChatParam});

function ItemChatParam:GetType()
	return ChatConsts.ChatParam_Item;
end

function ItemChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local itemId = toint(params[1]);
	local cfg = t_item[itemId];
	if not cfg then return ""; end
	local str = "<font color='"..TipsConsts:GetItemQualityColor(cfg.quality).."'>["..cfg.name.."]</font>";
	if withLink then
		return self:GetLinkStr(str,paramStr);
	else
		return str;
	end
end

--编码
function ItemChatParam:EncodeItem(bagItem)
	local str = "";
	local tId = bagItem:GetTid();
	--
	if BagUtil:IsWing(tId) and EquipModel:GetWingAttrFlag(bagItem:GetId()) then
		str = str .. "wing=1";
	end
	--
	if BagUtil:IsRelic(tId) then
		str = str .. "relic=" .. bagItem:GetParam()
	end
	local superVO = EquipModel:GetItemSuperVO(bagItem:GetId());
	if not superVO then
		return self:Encode(tId,str);
	end
	--
	str = ",super=";
	str = str .. superVO.id ..";".. superVO.val1 ..";"..superVO.val2;
	return self:Encode(tId,str);
end

function ItemChatParam:DoLinkOver(paramStr)
	local params = self:Decode(paramStr);
	local itemId = toint(params[1]);
	local cfg = t_item[itemId];
	if not cfg then return; end
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(itemId,1);
	if not itemTipsVO then return; end
	--解析参数
	for i,s in ipairs(params) do
		if s:lead("super=") then
			local str = string.sub(s,7,#s);
			local superT = split(str,";");
			local vo = {};
			vo.id = toint(superT[1]);
			vo.val1 = toint(superT[2]);
			vo.val2 = toint(superT[3]);
			itemTipsVO.itemSuperVO = vo;
		elseif s:lead("relic=") then
			local str = string.sub(s,7,#s);
			itemTipsVO.param1 = toint(str);
		elseif s == "wing=1" then
			itemTipsVO.wingAttrFlag = true;
		end
	end
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightUp);
end