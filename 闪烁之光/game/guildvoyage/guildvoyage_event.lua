GuildvoyageEvent = GuildvoyageEvent or {}

-- 初始化远航订单列表
GuildvoyageEvent.UpdateGuildvoyageOrderListEvent = "GuildvoyageEvent.UpdateGuildvoyageOrderListEvent"


-- 添加或者移除掉伙伴在订单中的状态
GuildvoyageEvent.AddToOrderPartnerListEvent = "GuildvoyageEvent.AddToOrderPartnerListEvent"


-- 更新订单状态,这个现在在领取订单和秒掉订单时候触发,需要删掉当前的订单的航线
GuildvoyageEvent.UpdateGuildvoyageOrderStatus = "GuildvoyageEvent.UpdateGuildvoyageOrderStatus"

-- 更新互助列表
GuildvoyageEvent.UpdateGuildVoyageInteractionEvent = "GuildvoyageEvent.UpdateGuildVoyageInteractionEvent"

-- 删除一个互助对象
GuildvoyageEvent.RemoveGuildVoyageInteractionEvent = "GuildvoyageEvent.RemoveGuildVoyageInteractionEvent"

-- g更新最近的一条订单信息
GuildvoyageEvent.UpdateNearLogInfoEvent = "GuildvoyageEvent.UpdateNearLogInfoEvent"

-- 刷新护送日志列表
GuildvoyageEvent.UpdateLogListEvent = "GuildvoyageEvent.UpdateLogListEvent"

-- 更新护送次数
GuildvoyageEvent.UpdateDailyEscortTimes = "GuildvoyageEvent.UpdateDailyEscortTimes"