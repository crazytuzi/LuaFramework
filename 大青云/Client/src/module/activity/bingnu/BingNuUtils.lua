--[[
解封冰奴工具类
zhangshuhui
2015年1月7日20:16:36
]]

_G.BingNuUtils = {};

--得到奖励信息
function BingNuUtils:GetRewardInfo(type)
	local lvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local vo = t_product[lvl];
	if vo then
		return vo["product_"..type]
	end
	
	return 0;
end

--得到奖励信息
function BingNuUtils:GetHaveBindMoney(bingmoneynum)
	if ShopUtils:GetMoneyByType(enAttrType.eaUnBindMoney) < bingmoneynum then
		return false;
	end
	
	return true;
end