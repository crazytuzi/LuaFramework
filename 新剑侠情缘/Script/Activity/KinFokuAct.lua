
local tbAct      = Activity:GetUiSetting("FokuBattle")
tbAct.nShowLevel = 20
tbAct.szTitle    = "龙门之争"
tbAct.szUiName   = "Normal"
tbAct.szContent  = [[
[FFFE0D]龙门之争活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%s~%s[-]
[FFFE0D]参与等级：[-]20级
    龙门之争是一个与其他服务器同水平的家族热血对战的活动。活动期间每天[FFFE0D]19:55[-]开始报名，[FFFE0D]20:00[-]活动正式开始。
[FFFE0D]精英赛场[-]
    [FFFE0D]精英赛场[-]需要家族成员组队由队长申请，[FFFE0D]家族领袖/族长/副族长/指挥[-]同意后方可进入准备场等待匹配，[FFFE0D]精英赛场[-]最多同时进入[FFFE0D]3支[-]队伍。[FFFE0D]精英赛场[-]中玩家采集并持有地图中刷新的[FFFE0D]天龙珠[-]可为己方提供积分，处于越靠近地图的中心位置获得的积分越高，玩家死亡会掉落[FFFE0D]天龙珠[-]。当己方积分达到[FFFE0D]10000[-]时积分将停止增长，进入[FFFE0D]20秒[-]的倒计时阶段，此阶段内己方持有[FFFE0D]天龙珠[-]的家族成员不被击杀即可取得胜利，被击杀会减少对应积分且打断倒计时阶段。玩家还可以占领地图中的[FFFE0D]旗帜复活点[-]，占领后死亡可立即复活在离死亡地点最近的[FFFE0D]旗帜复活点[-]且减少[FFFE0D]天龙珠[-]的丢失数量，否则会在大营复活且丢失所有的[FFFE0D]天龙珠[-]。
[FFFE0D]普通赛场[-]
    [FFFE0D]普通赛场[-]允许任何家族成员进入。[FFFE0D]普通赛场[-]中玩家需收集[FFFE0D]天龙珠[-]，当己方天龙珠的总数量达到[FFFE0D]8[-]时将会消耗掉所有的[FFFE0D]天龙珠[-]并为[FFFE0D]精英赛场[-]中的本家族成员每人从[FFFE0D]不溃、复苏、潜行、疾行、无敌[-]中随机提供一个技能。
    活动结束时会按照家族的胜负情况及得分情况发放奖励一起开启家族拍卖。
    大侠们快为了家族荣誉，夺取龙门秘宝————[FFFE0D]天龙珠[-]吧！
]]
tbAct.FnCustomData = function (szKey, tbData)
    local szStart = Lib:TimeDesc7(tbData.nStartTime)
    local szEnd   = Lib:TimeDesc7(tbData.nEndTime)
    return {string.format(tbAct.szContent, szStart, szEnd, Activity.NewYearQAAct.nBeAnswerAwardTimes)}
end