
-- @Author: LaoY
-- @Date:   2018-11-06 16:03:19
--
HelpConfig = {}

-- <color=#ffffff>内容</color>

--[ColorUtil.ColorType.White]     = "444444",白色（页面用）
--[ColorUtil.ColorType.Purple]   = "a128e0",紫色（页面用）
--[ColorUtil.ColorType.Blue]     = "009cdd",蓝色（页面用）
--[ColorUtil.ColorType.Red]     = "eb0000",红色（页面用）
--[ColorUtil.ColorType.Pink]     = "df05e7",粉色（页面用）
--[ColorUtil.ColorType.Yellow]   = "ffcc00",黄色
--[ColorUtil.ColorType.Green]    = "248a00",浅绿色（页面用）
--[ColorUtil.ColorType.Orange]  = "df4600",橙色（页面用）
--[ColorUtil.ColorType.Apricot]  = "f0c78c",杏色
--[ColorUtil.ColorType.YellowWish] = "ffe27c",淡黄色
--[ColorUtil.ColorType.GreenDeep]  = "43f673",深绿色
--[ColorUtil.ColorType.WhiteYellow]  = "fef2b7",偏白黄色
--[ColorUtil.ColorType.YellowWish2]  = "FEEEA4",淡黄色
--[ColorUtil.ColorType.GrayWhite] = "c1b7aa",灰白色


--[[
0元礼包资源配置的规则：
    1：模型        {model,模型类型,资源id}
    2：贴图        {texture,string_1:贴图名字}     stirng_1:直接在"ui"文件夹下面的话：模块名字_image  例如：贵族ip_image
                                                           在"icon"文件夹里面的话：  iconasset/icon_模块名字 例如：iconasset/icon_贵族ip
]]--

HelpConfig.XX = [[
1.
2.
]]

HelpConfig.Equip = {}
HelpConfig.Equip.Suit = [[
1. Orange T5 1-star or better gears and Orange T7 1-star or better accessories can activate the Immortal Set;
2. Orange T5 2-star or better gears and Orange T7 2-star or better accessories can further activate the Oracle Set after activating the Immortal set;
3. A set of gears contains Weapon, Off hand, Helmet, Breastplate, Leggings, Gaunlets and Shoes. The set effect can be activated when all the gears are of the same tier;
4. Necklace, Left Ring and Right Ring form a set of accessories. Different accessories can also activate the set effect;
]]

HelpConfig.Equip.Combine = [[
1. Use %s to combine this gear (Left Ring, Right Ring and Necklace excluded);
2. Enhanced, inlaid and polished gears, gears in a set and equipped gears can't be combined;
3. The combination success rate is not guaranteed. The more gears put in, the higher success rate;
]]

HelpConfig.Equip.EquipCast = [[
<color=#197dca>Rules:</color>
1. The basic attributes and enhancement attributes of a gear can be further improved through forging. <color=#009512>The higher tier and enhancement level the gear has, the more attribute bonus</color>;
2. When replacing gears, if the gear quality can't be inherited, <color=#009512>all the consumed materials will be returned</color>;
3. By forging a basic gear or artifact to the same quality, you can get <color=#009512>great attribute bonus and the maximum benefit! </color>
4. Forging materials can be collected from the Forge Hut. You can get free chances everyday.
]]

HelpConfig.Equip.EquipRefine = [[
<color=#197dca>Rules: </color>
1.Each gear comes with 1 attribute and the rest of 3 attributes are unlocked by <color=#009512>bound diamond and diamond</color>. The 5th attribute needs to be unlocked by <color=#009512>VIP Player</color>
2. Using <color=#009512>Refinery Lock</color>: lock down an attribute to prevent it from being refined
3.You can recover up to <color=#009512>once</color> on the refined attributes. The recovery will cost you the amounts of <color=#009512>last time Refinery</color> <color=#009512>normal refinery gems</color>
4.<color=#009512>Special Refinery</color> will cost special refinery gems. When recovrting, <color=#009512>no</color> refinery gems will be used. Free attempts can't be used on special refinery.
5. Switching gears <color=#009512>won’t affect</color> refined attributes
]]

HelpConfig.Dungeon = {};
HelpConfig.Dungeon.worldBoss = [[
<color=#197dca>World Boss Info</color>
1. The World Boss may drop <color=#009512>super gears and appearance items</color> once being killed. The higher boss level, the better drops. 
2. There is a <color=#009512>limit to the number</color> of bosses killed each day (up to <color=#009512>3</color> World Bosses). After killing 3 bosses, you can't attack them any more. 
3. You can use <color=#009512>Fatigue Potions</color> to <color=#009512>increase</color> the number of bosses you can kill. 
4. The number of bosses killed each day will be reset at <color=#009512>00:00</color>. 
5. <color=#009512>Tip:</color> This is a Free Challenge Zone, you may be attacked by other players after entering this Zone, please be careful.
Tip: This is a <color=#009512>Free Challenge Zone</color>, you may <color=#009512>be attacked by other players</color> after entering this Zone, please be careful
]];

HelpConfig.Dungeon.worldBoss2 = [[
<color=#197dca>Non-fatigue World Boss Rules</color>
1. Killing bosses on this floor <color=#009512>doesn't cost World Boss Fatigue</color>. 
2. <color=#009512>The top 10 damage dealers</color> will get mailed rewards. 
3. The <color=#009512>team that deals the most damage (damage sum of team members)</color> will get the dropped rewards, so it's recommended to challenge in teams! 
3. Players <color=#009512>who are 100-level higher than the boss</color> won't get any rewards. 
4. This scene is in <color=#009512>Peace Mode</color>, players can't switch modes here, nor can they attack others.
]];

HelpConfig.Dungeon.homeBoss = [[
<color=#197dca>Rules:</color>
1. The number of Home Bosses killed each day won't be displayed. 
2. Different floors require <color=#009512>different VIP levels</color>.
3. As an VIP 1 or higher VIP player, if your <color=#009512>VIP level is insufficient</color>, you can <color=#009512>spend</color> bound diamonds/diamonds <color=#009512>to enter</color> higher floors. 
4. Killing bosses on <color=#009512>the first 3 floors of the Boss Home</color> will <color=#009512>cost Stamina</color>.
5. Once your Stamina runs out, you <color=#009512>won't be able to deal damage to the bosses on the first 3 floors</color>, <color=#009512>nor can you pick up their drops</color>. 6. Stamina refreshes at <color=#009512>0:00/08:00/16:00</color> every day.
7. <color=#009512>Tip:</color> This is a Free Challenge Zone, you may be attacked by other players after entering this Zone, please be careful.
8. Bosses on higher floors can drop <color=#009512>better Talismans</color> and rare items like <color=#009512>Stone of Divinity</color>, so hurry up to <color=#009512>increase your VIP level</color>!
Tip: This is a <color=#009512>Free Challenge Zone</color>, you may <color=#009512>be attacked by other players</color> after entering this Zone, please be careful
]];

HelpConfig.Dungeon.savageBoss = [[
<color=#197dca>Rules:</color>
1. After entering the Ancient Ruins, you will get 100 Rage. 
2. For <color=#009512>every minute</color> you spend in the game, you will lose <color=#009512>1</color> Rage. 
3. Killing Bosses and minions also <color=#009512>costs</color> a certain Rage. 
4. Once your rage is reduced to <color=#009512>0</color>, a <color=#009512>30s</color> countdown will start, at the end of which you will be <color=#009512>forced out of</color> the Ancient Ruins. 
Tip: This is a <color=#009512>Free Challenge Zone</color>, you may <color=#009512>be attacked by other players</color> after entering this Zone, please be careful
]];

HelpConfig.Dungeon.beastIsland = [[
<color=#197dca>(Server) Rules:</color>
1. Fantasy Island (Single Server) unlocks at Lv.<color=#009512>350</color>. Players at or higher than Lv.<color=#009512>350</color> can enter it. 
2. You can get Beast Gears by killing Fantasy Island Bosses and Fantasy Guards and collecting Souls. Bosses can drop Red Beast Gears at best, Fantasy Guards can drop Orange Beast Gears at best. Collecting Souls of Forest can get Orange Beast Gears at best, collecting Souls of Tide can get Red Beast Gears at best. 
3. Souls of Forest are basic souls spawned at fixed locations, you can collect up to <color=#009512>20</color> per day. Souls of Tide are advanced souls spawned randomly on the island, you can collect up to <color=#009512>2</color> per day. 
4. Killing the bosses will get Fantasy Island Fatigue, up to <color=#009512>3</color> Fatigue per day. 
5. Boss-killing Fatigue and Soul-collecting chances are reset at <color=#009512>00:00</color> every day. 
6. Boss-killing Fatigue and Soul-collecting chances are <color=#009512>shared</color> by Single-server and Cross-server Fantasy Islands. 
<color=#009512>Tip:</color> This is a Free Challenge Zone, you may be attacked by other players after entering this Zone, please be careful.
]];

HelpConfig.Dungeon.crossbeastIsland = [[
<color=#197dca>(Cross-Server) Rules:</color>
1. Fantasy Island (Single Server) unlocks at Lv.<color=#009512>370</color>. Players at or higher than Lv.<color=#009512>370</color> can enter it. 
2. You can get Beast Gears by killing Fantasy Island Bosses and Fantasy Guards and collecting Souls. Bosses can drop Red Beast Gears at best, Fantasy Guards can drop Orange Beast Gears at best. Collecting Souls of Forest can get Orange Beast Gears at best, collecting Souls of Light can get Red Beast Gears at best. 
3. Souls of Forest are basic souls spawned at fixed locations, you can collect up to <color=#009512>20</color> per day. Souls of Light are advanced souls spawned randomly on the island, you can collect up to <color=#009512>2</color> per day. 
4. Cross-server Fantasy Island offers better Boss Drops and Souls than the Single Server version. 
5. Killing the bosses will get Fantasy Island Fatigue, up to <color=#009512>3</color> Fatigue per day. 
6. Boss-killing Fatigue and Soul-collecting chances are reset at <color=#009512>00:00</color> every day. 
7. Boss-killing Fatigue and Soul-collecting chances are <color=#009512>shared</color> by Single-server and Cross-server Fantasy Islands. 
8. The Fantasy Island will be redistributed regularly with an advance mail notice, by then all connections will be cut off.
<color=#009512>Tip:</color> This is a Free Challenge Zone, you may be attacked by other players after entering this Zone, please be careful.
]];

HelpConfig.Dungeon.timeboss = [[
<color=#197dca>Rules:</color>
1. Cross-server Boss unlocks at <color=#197dca>Lv.200</color>. It contains <color=#197dca>4 floors</color> and each floor has <color=#197dca>4 rooms</color>. Higher floors offer better rewards. 
2. Each room contains 1 Boss, which will be <color=#197dca>reset at 14:00, 18:00 and 21:00</color> of every Tuesday, Thursday and Saturday. 
3. When the boss is killed, the <color=#197dca>top 10</color> damage dealers can get rare rewards, while other players can get <color=#197dca>participation rewards</color>. 
4. The <color=#197dca>top 3</color> damage dealers have double chance to get Orange 2 Gears, and <color=#197dca>players in their server</color> will get the <color=#197dca>privilege to open Treasure Chests</color>. 
5. There are 2 ways to open the treasure chest. Common way costs a <color=#197dca>Silver Key</color>, while Supreme way costs a <color=#197dca>Golden Key</color>. Keys can be purchased with bound diamonds / diamonds. 
6. Each chest can be opened 10 times, which will be <color=#197dca>calculated separately</color> for each player. The Supreme opening method grants double drops and may even drop <color=#197dca>high quality Hallow gears</color>. 
7. Each player can claim <color=#197dca>ranking rewards 4 times and participation rewards 4 times</color> per day, times of reward will be deducted as rewards being claimed. 
8. When a player has claimed the ranking rewards 4 times, <color=#197dca>the next time they will only get participation rewards</color>. 
9. Players with 0 Fatigue point <color=#197dca>can't attack the boss nor get rewards</color>. 
10. The first 2 bosses on the first floor of Cross-server Boss is open to <color=#197dca>the current server</color>, the last 2 bosses are <color=#197dca>open to the 2 servers next to each other</color>. The first 2 bosses on the 2nd floor are <color=#197dca>open to the 4 servers next to each other</color>, the rest of the bosses are <color=#197dca>open to the 8 servers next to each other</color>. 
11. Cross-server Boss is a cross-server event and may change according to cross-server plans. You may meet different players there.
]]
HelpConfig.Dungeon.timeboss_enter = [[
1. Cross-Server Boss may drop <color=#197dca>rare hallows</color>
2. <color=#197dca>Killing the boss will get rewards</color>, and <color=#197dca>the top 10</color> damage dealers will get great <color=#197dca>ranking rewards</color>. 
3. <color=#197dca>All players</color> that are in the same server with <color=#197dca>the top 3 damage dealers</color> can open <color=#197dca>treasure chests</color>.
]]

HelpConfig.Dungeon.exp = [[]];

HelpConfig.Dungeon.personalBoss = [[
<color=#197dca>Rules: </color>
1.<color=#009512>VIP4 and above player</color> can unlock <color=#009512>Exclusive Boss Challenge</color>
2.Entering by <color=#009512>consuming Exclusive Boss Ticket</color> or Diamond or Bound Diamond
3.Exclusive Boss will 100% drop <color=#009512>Mount Advance Pill, Elixir Chests and God Bane Set Chests</color>
4.It will have chance <color=#009512>super set stones and rare appearance items</color>
5. Exclusive Bosses can only be <color=#009512>challenged alone</color> for a limited times. <color=#009512>VIP 4-6 </color>enjoy <color=#009512>2</color> chances per day, while <color=#009512>VIP 7 or above</color> enjoy <color=#009512>3</color> chances per day
]]

HelpConfig.Dungeon.PetBoss = [[
<color=#3ec5fe>Rules:</color>
1. After entering the Monster Castle, you will get 100 Rage. 
2. For <color=#009512>every minute</color> you spend in the game, you will lose <color=#009512>1</color> Rage. 
3. Killing Bosses will <color=#009512>cost</color> a certain Rage. The higher boss quality, the more rage cost. 
4. The higher quality the boss has, the better the rewards will be. 
5. Killing 1 Boss will increase the quality of another 2 bosses on the same tier. For example, killing a low-tier boss will increase the quality of another 2 low-tier bosses. 
6. VIP 0 can enter the Monster Castle 1 time per day, while VIP <color=#009512>4</color> can enter <color=#009512>2</color> times, VIP <color=#009512>5</color> <color=#009512>3</color> times. 
7. Once your rage is reduced to <color=#009512>0</color>, a <color=#009512>30s</color> countdown will start, at the end of which you will be <color=#009512>forced out of</color> the Monster Castle. 
Tip: This is a <color=#009512>Free Challenge Zone</color>, you may <color=#009512>be attacked by other players</color> after entering this Zone, please be careful

]];

HelpConfig.SearchT = {}
HelpConfig.SearchT.search = [[
1. You will get some Blessing points for each draw. The more blessing points, the higher winning rate. Blessing points will be cleared after you win the rare prize;
2. You can spend items or diamonds to make a draw;
3. VIP 4 enjoys a blessing bonus on the first draw, while VIP 5 enjoys a blessing bonus for every draw which can greatly increase the chance of getting the rare prize.
]]

HelpConfig.SearchT.searchyy = [[
1. You will definitely get guaranteed rewards, with a chance to get the Prize for Today;
2. After drawing for a certain times, you can claim total draw rewards;
3. Total draw attempts will be reset every day, please claim rewards in time.
]]

HelpConfig.SearchT.smallR = [[
color=#197dca>Rules:</color>
1. Each draw will have chance to get Crand Prize
2. Each draw grants 1 blessing point, you will definitely win the Grand Prize with full blessing points
3. Different Target Grand Prizes have seperate blessing points
]]

HelpConfig.Faction = {}
--离线福利
HelpConfig.Faction.LiXianFuLi = [[Offline Farming time +<color=#44ec28>2 hours</color>.]]

--活宝福利
HelpConfig.Faction.HuoBaoFuLi = [[<color=#44ec28>5</color> drumsticks can be claimed per day, please give them to well-behaved guild members.]]
--职位福利
HelpConfig.Faction.CareerFuLi = [[Guild Camp, grants <color=#44ec28>5%</color> Defense and Attack bonus in Cross-server League]]
HelpConfig.Faction.listPanel = [[
<color=#197dca>Rules:</color>
1. Each guild can have up to <color=#009512>3 Guild Deputies</color> and <color=#009512>5 Elders</color>. 
2. Each guild can only have <color=#009512>1 guild sweetie</color>, who must be a <color=#009512>female character</color> and can claim <color=#009512>sweetie benefits</color> everyday.
3. The guild leader <color=#009512>can only transfer its leadership to the guild deputy</color>! To transfer leadership, please appoint a guild deputy first.
4. Completing guild quests can get <color=#009512>Guild Funds</color>. With enough guild funds, the <color=#009512>Guild Leader</color> can upgrade the guild.
]]

-- 魂卡寻宝
HelpConfig.MtT = {}
HelpConfig.MtT.search = [[
<color=#197dca>Rules:</color>
1. <color=#009512>Each treasure Hunt</color> grants 1-2 <color=#009512>Soul Card Shards</color> and 1 <color=#009512>random Soul Card</color>! 
2. Soul Card Shards can be exchanged for <color=#009512>Orange Soul Cards</color> or <color=#009512>Red Soul Cards</color> in the <color=#009512>Soul Card Shop! </color>
3. Hunting for 10 times at one go <color=#009512>will definitely get Orange or Red Soul Cards</color>. <color=#009512>30 hunts</color> guarantee <color=#009512>Red Soul Cards</color>! 
4. Each hunt costs 100 Hunting Energy which can <color=#009512>recover over time</color> or <color=#009512>be got from using items</color>. 
5. Hunting Energy recovers by 8 points per hour, <color=#009512>up to 400 points. </color>
6. Each Hunting Energy Rune grants 100 Hunting Energy. The rune can be obtained from <color=#009512>Events or the shop. </color>
7. The first Hunting Energy Pack bought every week enjoys a <color=#009512>40% discount. </color>
]]

--赠礼
HelpConfig.Friend = {}
HelpConfig.Friend.sendgift = [[
1. Sending gifts can increase you two's Intimacy and the receiver's Flower Points.
2. Intimacy can activate Intimacy Buffs when you two team up.
3. Flowers can be bought in the shop or on the Gifting Page.
]]

HelpConfig.Beast = {};
HelpConfig.Beast.strength = [[
<color=#3ec5fe>Rules:</color>
1. You can summon beasts to assist you in battles by acquiring <color=#009512>the required gear colors and types of the beasts<color=#009512>
2. <color=#009512>The basic number of assisting beasts</color> is fixed, you can use <color=#009512>Beast Expansion Cards</color> to get more assisting beasts
3. Beast Gears and Enhancing materials produced on the <color=#009512>Fantasy Island</color> can be used to enhance the beasts
4. Max Enhancing Level is decided by the color of the <color=#009512>Beast Gear</color>, the better color, the higher level cap.
]];

HelpConfig.Melee = {};
HelpConfig.Melee.dungeon1 = [[
1.<color=#76e153>All players</color> who <color=#76e153>participated in the Killing Brawl Guardian event</color> can earn points
2.<color=#76e153>The top 5 damage dealers</color> to the Brawl Guardian can get more points
3.Killing other players can grab up to <color=#76e153>50% point</color>
4.Every player has <color=#76e153>guaranteed points</color>, once their current points fall below this criteria, they <color=#76e153>won't lose points</color> any more once being killed
5.Players who have reached the <color=#76e153>point limit</color> <color=#76e153>won't get any more points</color>, nor can they <color=#76e153>reduce others' points</color> after killing them
6.Players will be ranked according to <color=#76e153>their points</color>. Players with the same points will be ranked according to their <color=#76e153>CP</color>
7.Every time the Brawl Guardian is refreshed, <color=#76e153>the current ranking</color> will be settled, rewards will be sent by <color=#76e153>mail</color>, and <color=#76e153>all players' points will be cleared</color>
8.<color=#76e153>Leaving the battlefield</color> in the middle will <color=#76e153>lose all points</color>
]];
HelpConfig.Melee.dungeon2 = [[
1.<color=#76e153>All players</color> who <color=#76e153>participated in the Killing Brawl Guardian event</color> can earn points
2.<color=#76e153>The top 5 damage dealers</color> to the Brawl Guardian can get more points
3.Killing other players can grab up to <color=#76e153>50% point</color>
4.Every player has <color=#76e153>guaranteed points</color>, once their current points fall below this criteria, they <color=#76e153>won't lose points</color> any more once being killed
5.Players who have reached the <color=#76e153>point limit</color> <color=#76e153>won't get any more points</color>, nor can they <color=#76e153>reduce others' points</color> after killing them
6.Players will be ranked according to <color=#76e153>their points</color>. Players with the same points will be ranked according to their <color=#76e153>CP</color>
7.Every time the Brawl Guardian is refreshed, <color=#76e153>the current ranking</color> will be settled, rewards will be sent by <color=#76e153>mail</color>, and <color=#76e153>all players' points will be cleared</color>
8.<color=#76e153>Leaving the battlefield</color> in the middle will <color=#76e153>lose all points</color>
]];


--福利
HelpConfig.Welfare = {}
---签到
HelpConfig.Welfare.Sign = [[
    <color=#3ec5fe>Rules:</color>
1. You can get 1 Check-in attempt every day you log in
2. Recheck attempts are granted for free. The higher VIP level, the more attempts
3. You need to reach a certain Daily Activity to do rechecks
]];
----祈福
--HelpConfig.Welfare.Grail = [[
--    <color=#3ec5fe>祈福说明：</color>
--1.祈福说明
--2.祈福说明说明
--3.祈福说明说明说明
--4.祈福说明说明说明
--5.祈福说明说明说明说明
--]];

--目前是从e_0到e_27
HelpConfig.Chat = {}
HelpConfig.Chat.CommonLG = [[
All team-up stages, Fighter's Path and Monster Siege, please bring me in!
I'm looking for the one to pass Romance stages, upgrade Love Locks and raise cute babies with me!
The gear is for sale on the Market right now, any interested query is welcome!
Guild power heads, please deal the Boss some serious damage, please!
Help! Our boss is being attacked by others! Please go stop it!
]]

HelpConfig.Candy = {}
HelpConfig.Candy.GameDescriton = [[
1. During the event, you can get EXP rewards per <color=#197dca>10s</color>
2. <color=#197dca>Sending gifts</color> to others can also get rewards
3. The player with the <color=#197dca>most popularity</color> can get an exclusive title
]]
HelpConfig.Candy.ShortCutLanguage = [[
Anyone want to exchange gifts? I will ask again later<quad name=emoji:23 size=35 width=1 />
All cool guys are sending gifts to me<quad name=emoji:2 size=35 width=1 />
I will punch you on the chest if you don't send me gifts<quad name=emoji:29 size=35 width=1 />
Any beautiful girls or handsome guys want to play together?<quad name=emoji:28 size=35 width=1 />
Anyone wants to send me a gift? ❤( > . - ))Sweet Heart<quad name=emoji:1 size=35 width=1 />
]]

--[[

--]]

HelpConfig.FactionBattle = {}
HelpConfig.FactionBattle.description = [[
 <color=#197dca>Matching Rules: </color>
 1. Start Time: <color=#009512>day 3</color>, <color=#009512>day 7</color> of new server and <color=#009512>every Sunday evening</color>;
 2. Guild Clash includes two matches. The first match starts at <color=#009512>21:00</color>; and the second starts at <color=#009512>21:25</color>. 
  3.There are 5 ratings: Divine, Holy, Heaven, Earth and Mortal;
 4.The <color=#009512>higher division rating</color> a guild has, the more <color=#009512>EXP</color> and <color=#009512>Contribution</color> it can earn;
 5.Each match has 2 rounds. In the first round, guilds of the <color=#009512>same division are matched up randomly</color>;in the second round, <color=#009512>winners will fight against each other while losers fight against each other to determine the final ranking</color>;
 6.The top guild in Divine division will be the <color=#009512>Dominating Guild</color> and get the control right over <color=#009512>Temple of Domination</color>
 7.After all matches are finished on Sunday night, <color=#009512>the top guild will advance to a higher division, while the last guild drops to a lower division</color>;
 8.Guilds in the Mortal division <color=#009512>will be reset every time before the event starts</color>;
 
 <color=#197dca>Rules: </color>
 1.<color=#009512>Players that enter a guild after day 3/7 and every Sunday 19:00</color> can't join the Guild War on that day
 2.5 Guilds will fight for the Guild Crystals on the scene，<color=#009512>collecting crystals can get points</color>;
 3.The more Banners collected, the more points earned, The guild that <color=#009512>earns 5000 points first</color> will be the winner;
 4.Killed players will revive <color=#009512>near the Home Crystal</color> or revive randomly. 
 5. The longer crystal occupation time, the more points.
]]
HelpConfig.FactionBattle.minimapTip = [[
 <color=#197dca>Matching Rules: </color>
 1. Start Time: <color=#009512>day 3</color>, <color=#009512>day 7</color> of new server and <color=#009512>every Sunday evening</color>;
 2. Guild Clash includes two matches. The first match starts at <color=#009512>21:00</color>; and the second starts at <color=#009512>21:25</color>. 
 3.There are 5 ratings: Divine, Holy, Heaven, Earth and Mortal;
 4.The <color=#009512>higher division rating</color> a guild has, the more <color=#009512>EXP</color> and <color=#009512>Contribution</color> it can earn;
 5.Each match has 2 rounds. In the first round, guilds of the <color=#009512>same division are matched up randomly</color>;in the second round, <color=#009512>winners will fight against each other while losers fight against each other to determine the final ranking</color>;
 6.The top guild in Divine division will be the <color=#009512>Dominating Guild</color> and get the control right over <color=#009512>Temple of Domination</color>
 7.After all matches are finished on Sunday night, <color=#009512>the top guild will advance to a higher division, while the last guild drops to a lower division</color>;
 8.Guilds in the Mortal division <color=#009512>will be reset every time before the event starts<color=#009512>;
 
 <color=#197dca>Rules: </color>
 1.<color=#009512>Players that enter a guild after day 3/7 and every Sunday 19:00</color> can't join the Guild War on that day
 2.5 Guilds will fight for the Guild Crystals on the scene，<color=#009512>collecting crystals can get points</color>;
 3.The more Banners collected, the more points earned, The guild that <color=#009512>earns 5000 points first</color> will be the winner;
 4.Killed players will revive <color=#009512>near the Home Crystal</color> or revive randomly. 
 5. The longer crystal occupation time, the more points.
]]

HelpConfig.GuildHouse = {}
HelpConfig.GuildHouse.tips = [[
<color=#197dca>Rules: </color>
1. Guild Ceremony starts on <color=#009512>20:30-20:50</color> everyday. 
2. The event contains 2 activities. The first 10 min is about <color=#009512>quiz answering</color>, the remaining time is about <color=#009512>killing the Guild Boss</color>.
<color=#197dca>Quiz: </color>
1. The Guild Quiz contains <color=#009512>20 questions</color>. Giving the right answers can get points. 
2.Giving the right answers can get points. The quicker the correct answer is given, <color=#009512>the more points earned</color>; giving wrong answers can <color=#009512>answer again</color>
3.The player with the most points will get a <color=#009512>Guild Boss Summon Card</color>
<color=#197dca>]Guild  Boss:</color>
1.It costs a Boss <color=#009512>Summon Card</color> to summon the Guild Boss
2.Different Summon Cards can summon <color=#009512>different levels</color> of bossesKilling the boss can get many <color=#009512>super gears and bound diamonds</color>
]]

HelpConfig.GuildHouse.EnterTips = [[
1. Event Time: <color=#009512>20:30-20:50</color>
2. The event contains 2 activities: <color=#009512>Guild Quiz and Guild Boss</color>
3.Player can get <color=#009512>Guild Boss Summon Card</color> from Guild Quiz
4. Killing the Guild Boss may get <color=#009512>super gears and many bound diamonds </color>
]]

HelpConfig.Pet = {}
HelpConfig.Pet.DecomposeTip = [[
1. Description missing
1. Description missing
1. Description missing
1. Description missing
1. Description missing
]]

HelpConfig.Pet.ComposeTip = [[
<color=#197dca>Rules:</color>
1. Pet combining requires <color=#009512>3 pets of the same quality</color>;
2.Pet combining may fail, but combining <color=#009512>Revelry Pets</color> will definitely succeed;
3. Pet combining can improve the <color=#009512>pet's quality</color> from low to high: Babe-Subadult-Adult/Mutant;
4. If the combination failed, <color=#009512>two of the pets will disappear, the pet in battle/assist will be kept; if no pet is in battle/assist, the pet with the highest rating will be kept</color>;
5、<color=#009512>3 entirely body</color> pets fuse and have <color=#009512>10%</color> to become <color=#009512>Variation</color>.
6、<color=#009512>Variation Pet</color> can increase huge CP!
]]

HelpConfig.Arena = {}
HelpConfig.Arena.panel = [[
<color=#197dca>Rules:</color>
Time: 
    All day. <color=#009512>The top 200</color> players in the server can participate Super Challenges
Details: 
    1. Players have <color=#009512>10 free</color> challenge chances, which will be reset at <color=#009512>24:00</color>
    2.Ranking Rewards will be issued at <color=#009512>22:00</color>
    3.Challenge chances can be bought, the higher <color=#009512>VIP Level</color>, they can <color=#009512>buy</color> more chances
]]
HelpConfig.Arena.rank = [[
<color=#197dca>Rules:</color>
Time: 
    All day. <color=#009512>The top 200</color> players in the server can participate Super Challenges
Details: 
    1. Players have <color=#009512>10 free</color> challenge chances, which will be reset at <color=#009512>24:00</color>
    2.Ranking Rewards will be issued at <color=#009512>22:00</color>
    3.Challenge chances can be bought, the higher <color=#009512>VIP Level</color>, they can <color=#009512>buy</color> more chances
]]
HelpConfig.Arena.bigGod = [[
<color=#197dca>Rules:</color>
Time: 
    All day. <color=#009512>The top 50</color> players in the server can participate Super Challenges
Details: 
    1. Players have <color=#009512>10 free</color> challenge chances, which will be reset at <color=#009512>24:00</color>
    2.Ranking Rewards will be issued at <color=#009512>22:00</color>
    3.Challenge chances can be bought, the higher <color=#009512>VIP Level</color>, they can <color=#009512>buy</color> more chances
]]

HelpConfig.FPacket = {}
HelpConfig.FPacket.HowToFetchFP = [[
<color=#197dca>Rules:</color>
1. Everyday on your first recharge, you can send a <color=#009512>red packet</color>
2. Red Packets dropped from Operation Events can also be sent out
3. The Red Packets have a <color=#009512>quantity limit</color>
4. Red Packet consumptions <color=#009512>won't be added to VIP EXP</color>
5. System and Operation Red Packets both have a <color=#009512>sending and claiming time limit</color>
]]

HelpConfig.GuildGuardDungeon = {}
HelpConfig.GuildGuardDungeon.HowToFuck = [[
<color=#197dca>Rules: </color>
1. The event starts at <color=#009512>20:30-21:00</color> on every Tuesday, Thursday and Saturday. 
2. Guild members at or above Lv.<color=#009512>130</color> can join the event and can't quit the guild during this period. 
3. The preparation time is 60s. There are 8 waves of attacks with a 60s interval. Clearing a wave earlier may shorten the interval. 
4. Upon killing a monster, <color=#009512>all players</color> on the scene will get <color=#009512>massive EXP</color>. The defense will be successful if the Lord of Light survives till the end of the event. 
5. After the event, all players will get <color=#009512>damage ranking rewards</color>. <color=#009512>The higher ranking, the more EXP reward</color>.
]]

HelpConfig.MAGIC_CARD = {}
HelpConfig.MAGIC_CARD.HowToFuck = [[
<color=#197dca>Rules: </color>
1. Players can get Soul Cards from <color=#009512>Magic Tower</color> or <color=#009512>Soul Card Hunt</color>
2. Low level Soul Cards can be dismantled into Magic Essence which is used for <color=#009512>Soul Card Upgrade</color>
3. Clearing more Magic Tower Floors can unlock more Soul Cards and <color=#009512>Soul Card Combination</color>
4. <color=#009512>Purple or better</color> Soul Cards can be <color=#009512>starred up</color>, which costs <color=#009512>identical Soul Cards</color> 
5. Solo-attribute Soul Cards can be upgraded to <color=#009512>3 stars</color>, <color=#009512>Combined Soul Cards</color> can be upgraded to <color=#009512>6 stars</color>
6. Orange and Red Combined Soul Cards can <color=#009512>inherit</color> the former card's attributes and get <color=#009512>super attributes</color> 
7. 0-star Soul Cards can be <color=#009512>combined</color>. The Soul Card will be dismantled into a 0-star Soul Card after the Star-up 
8. <color=#009512>Soul Card Star-up and Enhancement won't backfire</color>, players can star up and combine as needed
]]
HelpConfig.MARRY = {}
HelpConfig.MARRY.RING = [[
1. Upgrading costs Love Locks;
2. You will level up automatically when EXP is full;
3. Love Locks are obtained from Wedding Ceremonies and other events;
4. Getting married grants attribute bonuses;

]]
HelpConfig.MARRY.APPOINTMENT = [[
1. Completing a marriage of any grade can get 1 chance to hold a wedding ceremony;
2. The couple share 1 reservation chance and both sides can make the reservation;
3. The Ceremony can be reserved for a certain time of the day, and the time can't be changed;
4. Players can enter the wedding scene once the Wedding Ceremony starts and earn EXP rewards;
5. Collecting Wedding Cakes can get lost of Item rewards;
]]

HelpConfig.Daily = {}
HelpConfig.Daily.Findback = [[
1. You can retrieve <color=#009512>missed daily and event resources</color> through the retrieval function. 
2. You have two retrieval options: <color=#009512>with bound diamonds</color> or <color=#009512>with gold</color>. 
3. Retrieving with bound diamonds can get <color=#009512>all daily and event resources back</color>, while retrieving with gold can only get <color=#009512>50% back</color>. 
4. <color=#009512>Extra retrieval chances</color> are <color=#009512>determined by the purchase chances</color> of events. You can use diamonds when there are insufficient bound diamonds. 
5. Retrieval chances are reset at 00:00 every day.
]]

HelpConfig.Com1V1 = {}
HelpConfig.Com1V1.Help = [[
Require: <color=#009512>Lv.140</color>
Open Time: <color=#009512>21:00~21:30 on Monday, Wednesday and Friday</color>

Rules: 
1. You can fight 30 times per day, only the <color=#009512>first 10</color> fights grant rewards, the rest only grant points; You can have <color=#009512>10</color> cross-server fights per day, after that, you can spend 10 bound diamonds to fight again and get rewards as usual. 
2. You can earn points by winning and <color=#009512>your points determine your Grade</color>. Reaching a certain grade can get Grade Rewards. 
3. Each type of grade rewards can only be claimed <color=#009512>once</color>. 
4. In the <color=#009512>first two weeks</color> of a new server, the event is held within the server; after that it will enter the <color=#009512>cross-server season</color>, which ends after the last event held in the last week of a month. A new season will start from the first event of the next month. 
5. Each cross-server season has a grade ranking and an overall ranking. The top 32 players will get great rewards!
]]

HelpConfig.Warrior = {}
HelpConfig.Warrior.Help1 = [[
Open Time: 
<color=#009512>8:00 PM~8:20 PM on each Monday, Wednesday and Friday</color>
Rules: 
1. The Altar of Bravery has <color=#009512>7 stages</color>, you can enter the upper stage <color=#009512>after killing enough enemies</color> on the current stage
2. You may fall to the lower floor if you get killed on the <color=#009512>top floor (7th floor)</color> and choose to revive in the safe zone, Reviving on spot won't drop stages
3. Killing players or monsters in the Altar can get points. <color=#009512>The higher floor you are in, the more points you can get</color>
4.You can get great rewards on each floor of the altar andranking rewards are based on <color=#009512>your point ranking</color>
5.The top 3 players will get <color=#009512>time limited title rewards</color>
6.The altar opens for <color=#009512>20 min</color> after which it will close
7. If you quit in the middle and want to reenter, you will have to start from stage 1, but your points will be kept till the end of the event.
]]
HelpConfig.Warrior.Help2 = [[
Open Time: 
<color=#009512>8:00 PM~8:20 PM on each Monday, Wednesday and Friday</color>
Rules: 
1. The Altar of Bravery has <color=#009512>7 stages</color>, you can enter the upper stage <color=#009512>after killing enough enemies</color> on the current stage
2. You may fall to the lower floor if you get killed on the <color=#009512>top floor (7th floor)</color> and choose to revive in the safe zone, Reviving on spot won't drop stages
3. Killing players or monsters in the Altar can get points. <color=#009512>The higher floor you are in, the more points you can get</color>
4.You can get great rewards on each floor of the altar andranking rewards are based on <color=#009512>your point ranking</color>
5.The top 3 players will get <color=#009512>time limited title rewards</color>
6.The altar opens for <color=#009512>20 min</color> after which it will close
7. If you quit in the middle and want to reenter, you will have to start from stage 1, but your points will be kept till the end of the event.
]]

HelpConfig.Baby = {}
HelpConfig.Baby.Help = [[
<color=#3ec5fe>Rules:</color>
1. You can complete raising quests every day to get baby-raising items and use them to upgrade your babies;
2. Baby boys and baby girls <color=#009512>consume different baby-raising items</color>, they can level up once the progress is full;
3. The baby-raising function won't unlock until the baby's birth progress is full;
4. Daily first 3 baby sitting can get rewards.
]]

HelpConfig.Baby.Help2 = [[
Baby Birth Progress: 
1. You can get Baby Birth Progress by clearing the <color=#009512>Couple's Stage</color>, once the <color=#009512>progress is full</color>, you can start to raise a baby;2. You can also <color=#009512>buy a born baby in the shop</color>.
]]

HelpConfig.god = {}
HelpConfig.god.Help = [[
<color=#197dca>Info:</color>
1. Consume corresponding shards to light up
2. When all <color=#009512>8</color> positions are lit up in order, the deity can be activated
3. Activated deities can be <color=#009512>morphed</color>. A deity's skills are effective in battles 
4. Each deity has 2 skills. The Attribute Skill is <color=#009512>effective permanently</color>, while the Passive Skill <color=#009512>is only effective after the deity is morphed</color>
5. Surplus shards can be used to <color=#009512>reactivate the 8 positions</color> to <color=#009512>star up the deity</color>
]]
HelpConfig.god.Help2 = [[
<color=#197dca>Info:</color>
1. Consume corresponding shards to light up
2. When all <color=#009512>8</color> positions are lit up in order, the deity can be activated
3. Activated deities can be <color=#009512>morphed</color>. A deity's skills are effective in battles 
4. Each deity has 2 skills. The Attribute Skill is <color=#009512>effective permanently</color>, while the Passive Skill <color=#009512>is only effective after the deity is morphed</color>
5. Surplus shards can be used to <color=#009512>reactivate the 8 positions</color> to <color=#009512>star up the deity</color>
]]

HelpConfig.GodCelebration = {}
HelpConfig.GodCelebration.ActDesc = [[
<color=#197dca>Info:</color>
1. During the event, you can get deity points by challenging the <color=#009512>World Boss, Personal Boss, Boss Home, Ancient Ruins and Monster Castle</color>. 
2. Points can be used to exchange for rare rewards! 
3. Exchangeable rewards are limited in the event, first come first served!
]]
HelpConfig.GodCelebration.DungeDesc =[[
1. During the event, you will get <color=#009512>free challenge chances</color>, once used out, you can spend diamonds to continue to challenge. Challenge chances are limited and reset at 00:00 everyday. 
2. Clearing each floor can get fixed rewards, with a chance to get rare rewards. The higher floor, the better rewards. 
3. Clearing stages can get deity points, which can be used to exchange for rewards.
]]
HelpConfig.GodCelebration.ChildActDesc =[[
<color=#009512>Baby exchange instructions:</color>
1. During the event, kill the <color=#009512>World Boss, Boss Home, Ancient Ruins, and Monster Castle</color> to obtain items.
2. You can exchange rare rewards by consuming the items.
3. During the event period, the number of times the reward can be exchanged is limited.
]]

HelpConfig.casthouse = {}
HelpConfig.casthouse.Help = [[
<color=#009512>Info:</color>
1. You can build the Forge Hut to get lots of forging materials. 
2. You have <color=#009512>3 free dice throwing chances</color> per day, once used out, you need to spend diamonds or coupons to throw the dice. 
3. 1 coupon is worthy of <color=#009512>15 diamonds</color>. 
4. The higher VIP level, the more reset attempts.
]]

HelpConfig.stigmas = {}
HelpConfig.stigmas.Help = [[
You can arrange guards to resist monsters. A smart arrangement can greatly enhance your monster killing efficiency. Kill more monsters to get more rewards!
]]

HelpConfig.LimitTower = {}
HelpConfig.LimitTower.Help = [[
<color=#009512>Info: </color>
1. The first 9 floors are single-player stages that only allow one challenger
2. Floor 10 - 15 can be challenged by one player plus an assisting player, but the challenge results won't affect the progress of the assisting player
3. During the event, clearing all floors can get rare items
]]

HelpConfig.Fetival = {}
HelpConfig.Fetival.HanabiDesc = [[
<color=#009512>Info:</color>
1. Fireworks can be used to draw rewards
2. Fireworks can be bought with diamonds
3. It will have chance to get grand reward  
]]

HelpConfig.compete = {}
HelpConfig.compete.Help = [[
Sign-up Time: 
<color=#009512>New Server Day 1</color> and every <color=#009512>Saturday 00:00~ The next day 18：50</color>
Time: 
<color=#009512>New Server Day 2</color> and every <color=#009512>Sunday 19:00~ The next day 18：50</color>

Rules: 
1. The Diamond Ring consists of 4 phases: Sign-up Phase, Knockout Phase, Heaven&Earth Domination Phase, Off-season Phase. 
2. <color=#009512>Sign-up Phase:</color> Players meeting the requirements shown on the sign-up page can sign up. 
3. <color=#009512>Knockout Phase:</color> According to players' CP, the top 200 players will join the knockout matches and fight for 8 rounds. 
4. <color=#009512>Heaven&Earth Domination Phase:</color> The top 32 players on the point ranking will enter the Heaven&Earth Domination, with the top 16 enter the Heaven Division and the last 16 enter the Earth Division. 
5. <color=#009512>Off-season Phase:</color> It's a good time for players to improve their CP. 
6. The champion will get <color=#009512>abundant Diamond rewards</color>.
7. Players can bet on the winners of Heaven&Earth Domination matches to win Ring Tokens which can be used to exchange for rare titles and avatar frames. 
8. 10 min before the event starts, players can enter the preparation scene. 
9. Each player has 3 skills in the Ring Battle, they can buy temporary skills with diamonds to enhance their power.
]]

HelpConfig.siegewar = {}
HelpConfig.siegewar.Help = [[
<color=#009512>Rules</color>
1. <color=#009512>Depending on the opening days of the server</color>, the Siege War is divided into 4 phases: <color=#009512>1-server Phase, 2-server Phase, 4-server Phase and 8-server Phase</color>
2. After the <color=#009512>Cross-server Siege War - 2-server Phase</color> starts, your server will get 1 <color=#009512>Exclusive Bronze City</color>. You can follow the guide to plunder the <color=#009512>Silver City</color>, unspecified cities <color=#009512>can't be plundered. </color>
3. Killing the City Boss can get <color=#009512>points</color>. Your server will <color=#009512>occupy</color> the Silver City after earning <color=#009512>115 points</color>.
4. The server that occupied the Silver City can advance to the <color=#009512>Golden Capital</color>, killing the Boss there may get <color=#009512>rare Mecha Shards</color>.
5. Every time when it refreshes, players in the server that took the Silver City <color=#009512>will all</color> get <color=#009512>occupation rewards</color> which will be issued by mail. 
6. After earning <color=#009512>1500</color> medals in the week, you can spend diamonds to buy more medals and claim the final medal progress rewards. 
<color=#009512>Info:</color>
1. <color=#009512>The server that deals the most damage to the Boss</color> will get the Boss Ownership.
2. <color=#009512>Only the server with Boss Ownership</color> can claim the dropped items. Players who contributed to the killing of the boss can get participation rewards <color=#009512>which will be sent to their bags</color>. 
3. The Boss of the Bronze City is for your own server only, <color=#009512>other servers can't take it</color>.
4. Killing the boss will lose 1 Fatigue which <color=#009512>refreshes at 00:00 every day</color>.
]]
HelpConfig.siegewar.Tip1 = [[
1. After the event starts, your server will get a Bronze City. It's recommended to plunder the Silver City marked by the arrow first.
]]
HelpConfig.siegewar.Tip2 = [[
2. Go to the marked Silver City and kill the Boss there to earn points, the server with the most points will take the city.
]]
HelpConfig.siegewar.Tip3 = [[
3. The server that occupied the Silver City can advance to the Golden Capital, which may drop rare Mecha Shards.
]]
HelpConfig.siegewar.Tip4 = [[
4. Players of the server who contributed to the killing can all get Boss Ownership rewards. Call up friends to take the cities together!
]]

HelpConfig.nation = {}
HelpConfig.nation.CloundShopDesc = [[
<color=#009512>Rules:</color>
1.Event stars at 00:00 every day
2.Every time in Cross-server Shopping, you can get some random items and increase the purchase attempts of the item you buy.
3.Every big prize can be bought 5 times during 0:00-18:00. After 18:00 limit unlocks.
4.<color=#009512>Current shopping times=Max buyable times</color> rewards will be settled according to winning amount
5.<color=#009512>Current shopping times<Max buyable times</color>, rewards will be settled according to <color=#009512>[winning amount = current quantity * maximum winning quota/max buyable times]</color>; (Result draw (the calculation result is an integer);
6.If <color=#009512>【winning amount = current quantity * maximum winning quota/Max buyable times】result<1, there is a chance to trigger Guarantee mechanism</color>
7.【Buying quantity ≥ Max buyable times/maximum winning quota*0.75】trigger Guarantee mechanism and can get a big prize
8.Rewards will be settled at 21:00 everyday and issued by <color=#009512>mail</color>. Winning results can also be viewed in Shopping Records. 
9.The more purchase you made, the higher winning chance for the grand prize.
]]
HelpConfig.nation.CloundShopRecordDesc = [[
Reward Settlement Rules: 
1.Rewards will be settled when the time comes
2.<color=#009512>Current shopping times=Max buyable times</color> rewards will be settled according to winning amount
3.<color=#009512>Current shopping times<Max buyable times</color>, rewards will be settled according to <color=#009512>[winning amount = current quantity * maximum winning quota]</color>;
4.If <color=#009512>【winning amount = current quantity * maximum winning quota】result<1, winning results will also be settled 
5.【Buying quantity ≥ Max buyable times/maximum winning quota*0.75】trigger Guarantee mechanism and can get a big prize
6.Rewards will be settled at 21:00 everyday and issued by <color=#009512>mail</color>. Winning results can also be viewed in Shopping Records.
]]


HelpConfig.throne = {}
HelpConfig.throne.des = [[
1、During the event, you can enter <color=#009512>Faint Star</color> or <color=#009512>Bright Star</color>；
2、The server which deals the highest DMG to the boss can get<color=#009512> 30 points</color>；
3、In<color=#009512> Faint Star </color>or<color=#009512> Bright Star, </color>accumulate points to<color=#009512> 100 </color>and can unlocks <color=#009512>Pegasus</color>（<color=#009512>Pts of 2 zones won't be accumulated</color>）；
4、In one of the zones of<color=#009512> Faint Star </color>or<color=#009512> Bright Star</color>, this server reaches<color=#009512> 100 points</color>. The players of this server in two zones can transpot to<color=#009512>Pegasus</color>。
5、If you leave<color=#009512> the BOSS zone,</color> the DMG to the BOSS <color=#009512>will be cleared to 0</color>.
TIP:<color=#009512>Pegasus</color> contains many ultimate gears
]]


HelpConfig.richMan = {}
HelpConfig.richMan.des = [[
1、Event lasts for <color=#009512>10 days</color>.<color=#009512>It won't reset</color>current<color=#009512> progress</color>.
2、Dice source：Everyday<color=#009512> recharge</color> to <color=#009512>60,300,600 diamonds </color>and<color=#009512> can get 1 common dice</color>.<color=#009512>Recharge to 1200 diamonds</color> and can<color=#009512> get 1 Control Dice</color>
3、After throwing, can get the rewards from the check where the dice stops.
4、Event type：
<color=#009512>Stop on the box check</color>,<color=#009512> and can get the box</color>
<color=#009512>Stop on the dice check</color>,and <color=#009512>can get 1 common dice</color>
<color=#009512>Stop on the fallback check</color>,and <color=#009512>can go backwards 3 checks</color>
<color=#009512>Stay on the lucky check</color>,and <color=#009512>can draw once in the Lucky Pool</color>
5、<color=#009512>Every day can get 4 dices at most</color>
6、<color=#009512>The re-sign in dice is common dice</color>
]]


--[[
       tipInfo:             显示的文本
       is_show_two:         是否使用第二种样式的窗体（该窗体大小固定）
       width:               设置第一种样式的宽度
       ps:                  策划要的底部小提示（只适用于第二种样式）
--]]
function ShowHelpTip(tipInfo, is_show_two, width, ps)
    --local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    tipInfo = ChatColor.format_color(tipInfo)
    if is_show_two then
        local helpTip = lua_panelMgr:GetPanelOrCreate(HelpTipPanelTwo)
        helpTip:Open(tipInfo, ps)
    else
        local helpTip = lua_panelMgr:GetPanelOrCreate(HelpTipPanel)
        helpTip:Open(tipInfo, width)
    end
end