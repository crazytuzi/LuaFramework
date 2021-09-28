DCVirtualCurrency = { };

--[[直接充值接口，充值成功后回调时调用,新增接口，用于取代其它三个接口
	orderId:充值SDK生成的充值订单号，String类型
    iapId:礼包ID，String类型
	currencyAmount:充值金额 Int类型
	currencyType:充值货币类型，String类型
	paymentType:付费方式，String类型
]]
function DCVirtualCurrency.paymentSuccess(orderId, iapId, currencyAmount, currencyType, paymentType)
	if i3k_game_data_eye_valid() then
		DCLuaVirtualCurrency:paymentSuccess(orderId, iapId, currencyAmount, currencyType, paymentType);
	end
end

--[[直接充值接口，充值成功后回调时调用,新增接口，用于取代其它三个接口
    orderId:充值SDK生成的充值订单号，String类型
    iapId:礼包ID，String类型
    currencyAmount:充值金额 Int类型
    currencyType:充值货币类型，String类型
    paymentType:付费方式，String类型
    levelId:付费时所在关卡ID
]]
function DCVirtualCurrency.paymentSuccessInLevel(orderId, iapId, currencyAmount, currencyType, paymentType,levelId)
	if i3k_game_data_eye_valid() then
		DCLuaVirtualCurrency:paymentSuccessInLevel(orderId, iapId, currencyAmount, currencyType, paymentType, levelId);
	end
end

return DCVirtualCurrency;
