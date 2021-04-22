local QBuyCountBase = class("QBuyCountBase")

function QBuyCountBase:ctor(options)
	-- body
end

function QBuyCountBase:refreshInfo()
	-- body
end

--标题
function QBuyCountBase:getTitle()
	return "次数购买"
end

--下面的描述
function QBuyCountBase:getDesc()
	return "用少量钻石购买一次次数"
end

--描述后面的次数
function QBuyCountBase:getCountDesc()
	return "(今日可购买次数0/0)"
end

--消耗
function QBuyCountBase:getConsumeNum()
	return 0
end

--返回描述
function QBuyCountBase:getReciveNum()
	return "次数 X 1"
end

--图标路径
function QBuyCountBase:getIconPath()
	return nil
end

--是否还能购买
function QBuyCountBase:checkCanBuy()
	return true
end

--是否到VIP最大购买次数
function QBuyCountBase:checkVipCanGrade()
	return true
end

--刷新提示
function QBuyCountBase:getRefreshDesc()
	return "每日可购买次数在凌晨"..remote.user.c_systemRefreshTime.."点刷新" 
end

--弹出VIP框
function QBuyCountBase:alertVipBuy()
	-- body
end

--请求购买
function QBuyCountBase:requestBuy()
	-- body
end

return QBuyCountBase