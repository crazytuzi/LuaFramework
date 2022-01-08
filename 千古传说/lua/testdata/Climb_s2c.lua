local event = {}

event.mountainListEvent = {}
event.mountainListEvent.data = {}
event.mountainListEvent.data.mountainList =
 {
{id = 1 ,firstWinPlayerName = "葫芦娃1"},
{id = 2 ,firstWinPlayerName = "葫芦娃2"},
{id = 3 ,firstWinPlayerName = "葫芦娃3"},
{id = 4 ,firstWinPlayerName = "葫芦娃4"},
{id = 5 ,firstWinPlayerName = "葫芦娃5"},
{id = 6 ,firstWinPlayerName = "葫芦娃6"},
{id = 7 ,firstWinPlayerName = "葫芦娃7"},
{id = 8 ,firstWinPlayerName = "葫芦娃8"},
{id = 9 ,firstWinPlayerName = "葫芦娃9"},
{id = 10 ,firstWinPlayerName = "葫芦娃10"},
{id = 11 ,firstWinPlayerName = "葫芦娃11"},
}

event.challengeResultEvent = {}
event.challengeResultEvent.data = {}
event.challengeResultEvent.data.win = true

event.homeEvent = {}
event.homeEvent.data = {}
event.homeEvent.data.curId = 1
event.homeEvent.data.challengeCountOneDay = 6
event.homeEvent.data.challengeCountToDay = 2

event.rewardEvent = {}
event.rewardEvent.data = {}
event.rewardEvent.data.rewardItems =
 {
{type = 4 ,number = 200 ,itemId = 3},
{type = 3 ,number = 200 ,itemId = 3},
}
return event
