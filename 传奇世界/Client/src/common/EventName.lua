--Author:		bishaoqing
--DateTime:		2016-04-25 19:26:32
--Region:		EventName
EventName = {}

local EventNameDef = 
{
	"ReplaceCompare",				--装备对比切换对比属性\详细属性
	"RefreshGridData",				--装备tip刷新
	"UpdateTeam",					--远古宝藏队伍刷新
	"UpdateBlackMarket",			--黑市刷新
	"OnLimitReturn",				--黑市买前获取限制数返回

	"OnChatCallRet",				--多人守卫喊话
	"UpdateMultiPanel",				--刷新多人守卫界面
	"GetFriendsRet",				--好友界面刷新
	"OperateRet",					--操作返回
	"UpdateMyTeam",					--我的队伍刷新
	"CloseChat",					--关闭聊天窗
	"TeamChallengeRet",				--多人守卫组队挑战返回
	"ChangeTeamNode",				--多人守卫队员刷新


	--team
	"OnCreateTeamRet",				--创建队伍返回
	"AllReady", 					--成员准备就绪
	"MultiError",					--多人守卫出错
}

local function InitEventName()
	for _, v in pairs(EventNameDef) do
		if EventName[v] then
			error("redefine 'EventName':",v)
			return
		end
		EventName[v] = v
	end
end

InitEventName()

return EventName
