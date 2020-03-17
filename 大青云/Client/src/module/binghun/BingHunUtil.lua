--[[
BingHunUtil
zhangshuhui
2015年9月24日11:09:16
]]

_G.BingHunUtil = {};

function BingHunUtil:GetBingHunMax()
	local count = 0;
	for i = 1,100 do
		if t_binghun[i] then
			count = i;
		else
			break;
		end
	end
	return count;
end

function BingHunUtil:GetBingHunHeadIcon(strheadicon,prof)
	if strheadicon and strheadicon ~= "" then
		local list = split(strheadicon, "#")
		
		--只有一个
		if #list == 1 then
			return strheadicon;
		end
		
		for i = 1, #list do
			local sen = list[i]
			local senTable = split(sen, ",")
			
			if prof == tonumber(senTable[1]) then 
				return senTable[2];
			end
		end
	end
	
	return "";
end

--当前圣器是否已激活
function BingHunUtil:GetIsBingHunActive(id)
	local vo = BingHunModel:GetBingHunById(id);
	if vo and vo.time and vo.time ~= 0 then
		return true;
	end
	return false;
end