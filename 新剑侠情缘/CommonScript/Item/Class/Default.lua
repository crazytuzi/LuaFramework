
-- Item默认模板（普通道具，通用功能脚本）

local tbDefault = Item:GetClass("default");

function tbDefault:OnItemInit()
	-- 啥都不做
end

function tbDefault:OnInit()
	-- 啥都不做
end

function tbDefault:OnCreate()
	-- 啥都不做
end

function tbDefault:CheckUsable()
	return	1;						-- 可用
end

--function tbDefault:OnUse()			-- 不会默认就有这个回调了
--	print("tbDefault:OnUse")
--	return	0;
--end

-- 客户端回调
function tbDefault:OnClientUse(pItem)
	return 0;
end

function tbDefault:GetTitle(pItem)
	return pItem.szName;
end

function tbDefault:GetPrefixTip()
	return ""
end

function tbDefault:GetTip(nState)			-- 获取普通道具Tip
	return	"";
end

function tbDefault:GetTipByTemplate(nTemplateId, nFaction)
	return	"";
end

function tbDefault:CheckCanSell(pItem)
	return true;
end
