GuildEvent = GuildEvent or {}

--更新公会列表，请求公会列表时候返回
GuildEvent.UpdateGuildList = "GuildEvent.UpdateGuildList"

--单个公会状态改变
GuildEvent.UpdateGuildItemEvent = "GuildEvent.UpdateGuildItemEvent"

--更新自己公会的基础信息
GuildEvent.UpdateMyInfoEvent = "GuildEvent.UpdateMyInfoEvent"

--更新自己公会成员列表
GuildEvent.UpdateMyMemberListEvent = "GuildEvent.UpdateMyMemberListEvent"

--更新自己公会单个成员的数据，主要是职位等
GuildEvent.UpdateMyMemberItemEvent = "GuildEvent.UpdateMyMemberItemEvent"

--更新副会长数量的事件，策划这个比较蛋疼的
GuildEvent.UpdateAssistantNumEvent = "GuildEvent.UpdateAssistantNumEvent"

--捐献次数更新
GuildEvent.UpdateDonateInfo = "GuildEvent.UpdateDonateInfo"

--更新申请列表
GuildEvent.UpdateApplyListInfo = "GuildEvent.UpdateApplyListInfo"

--公会更新红点事件
GuildEvent.UpdateGuildRedStatus = "GuildEvent.UpdateGuildRedStatus"

-- 更新捐献宝箱状态
GuildEvent.UpdateDonateBoxStatus = "GuildEvent.UpdateDonateBoxStatus"

--公会活跃基本信息
GuildEvent.UpdataGuildGoalBasicData = "GuildEvent.UpdataGuildGoalBasicData"
GuildEvent.UpdataGuildGoalTaskData = "GuildEvent.UpdataGuildGoalTaskData"
GuildEvent.UpdataGuildGoalSingleTaskData = "GuildEvent.UpdataGuildGoalSingleTaskData"

--更新公会日志列表
GuildEvent.UpdateGuildNoticeList = "GuildEvent.UpdateGuildNoticeList"

-- 更新公会活跃光环
GuildEvent.UpdateActiveIconEvent = "GuildEvent.UpdateActiveIconEvent"
