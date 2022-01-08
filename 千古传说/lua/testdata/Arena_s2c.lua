local event = {}

event.playerEvent = {}
event.playerEvent.data = {}
event.playerEvent.data.playerList =
 {
{rank = 1 ,playerId =1 ,playerName = "葫芦娃1",playerLevel = 3,generalId = "3"},
{rank = 2 ,playerId =2 ,playerName = "葫芦娃2",playerLevel = 3,generalId = "3"},
{rank = 3 ,playerId =3 ,playerName = "葫芦娃3",playerLevel = 3,generalId = "3"},
{rank = 4 ,playerId =4 ,playerName = "葫芦娃4",playerLevel = 3,generalId = "3"},
{rank = 5 ,playerId =5 ,playerName = "葫芦娃5",playerLevel = 3,generalId = "3"},
{rank = 6 ,playerId =6 ,playerName = "葫芦娃6",playerLevel = 3,generalId = "3"},
{rank = 7 ,playerId =7 ,playerName = "葫芦娃7",playerLevel = 3,generalId = "3"},
{rank = 8 ,playerId =8 ,playerName = "葫芦娃8",playerLevel = 3,generalId = "3"},
{rank = 9 ,playerId =9 ,playerName = "葫芦娃9",playerLevel = 3,generalId = "3"},
{rank = 10 ,playerId =10 ,playerName = "葫芦娃10",playerLevel = 3,generalId = "3"},
{rank = 11 ,playerId =11 ,playerName = "葫芦娃11",playerLevel = 3,generalId = "3"},
}

event.rankEvent = {}
event.rankEvent.data = {}
event.rankEvent.data.rankList =
 {
{rank = 1 ,playerId =1 ,playerName = "葫芦娃1",playerLevel = 3,generalId = "3"},
{rank = 2 ,playerId =2 ,playerName = "葫芦娃2",playerLevel = 3,generalId = "3"},
-- {rank = 3 ,playerId =3 ,playerName = "葫芦娃3",playerLevel = 3,generalId = "3"},
-- {rank = 4 ,playerId =4 ,playerName = "葫芦娃4",playerLevel = 3,generalId = "3"},
-- {rank = 5 ,playerId =5 ,playerName = "葫芦娃5",playerLevel = 3,generalId = "3"},
-- {rank = 6 ,playerId =6 ,playerName = "葫芦娃6",playerLevel = 3,generalId = "3"},
-- {rank = 7 ,playerId =7 ,playerName = "葫芦娃7",playerLevel = 3,generalId = "3"},
-- {rank = 8 ,playerId =8 ,playerName = "葫芦娃8",playerLevel = 3,generalId = "3"},
-- {rank = 9 ,playerId =9 ,playerName = "葫芦娃9",playerLevel = 3,generalId = "3"},
-- {rank = 10 ,playerId =10 ,playerName = "葫芦娃10",playerLevel = 3,generalId = "3"},
-- {rank = 11 ,playerId =11 ,playerName = "葫芦娃11",playerLevel = 3,generalId = "3"},
}

event.rewardEvent = {}
event.rewardEvent.data = {}
event.rewardEvent.data.curRewardItems =
 {
{type = 4 ,number = 200 ,itemId = 3},
{type = 3 ,number = 200 ,itemId = 3},
}

event.rewardEvent.data.curCondition ="100名奖励"
event.rewardEvent.data.isCanReceive =true

event.rewardEvent.data.nextRewardItems =
 {
{type = 4 ,number = 300 ,itemId = 3},
{type = 3 ,number = 300 ,itemId = 3},
}

event.rewardEvent.data.nextCondition ="200名奖励"

return event
