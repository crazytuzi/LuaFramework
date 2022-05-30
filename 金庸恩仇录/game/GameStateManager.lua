require("game.GameConst")
require("game.UIManager")
local GameStateManager = {}

GameStateManager.currentState = GAME_STATE.STATE_LOGO

function GameStateManager:resetState(...)
	GameStateManager.currentState = GAME_STATE.STATE_LOGO
end

function GameStateManager:setState(state, msg)
	GameStateManager.currentState = GAME_STATE.STATE_NONE
	GameStateManager:ChangeState(state, msg)
end

function GameStateManager:ChangeState(nextState, msg)
	printf("nextState:" .. nextState)
	printf("currentState:" .. GameStateManager.currentState)
	if GameStateManager.currentState ~= nextState then
		--print("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"..nextState)
		do
			local lastState = GameStateManager.currentState
			GameStateManager.currentState = nextState
			if lastState == GAME_STATE.STATE_MAIN_MENU then
				--UIManager:getMainMenuLayer(msg):onExit()
			end
			local canShow = true
			CCDirector:sharedDirector():popToRootScene()
			local scene
			if nextState == GAME_STATE.STATE_MAIN_MENU then
				local showNote
				if msg ~= nil then
					showNote = msg.showNote
				end
				scene = UIManager:newScene("MainMenuScene")
				local layer = UIManager:getMainMenuLayer({showNote = showNote})
				scene:addChild(layer)
				display.replaceScene(scene)
				--local layer = UIManager:getMainMenuLayer(showNote)
				--if layer:getParent() ~= nil then
				--	layer:removeFromParentAndCleanup(false)
				--end
				--scene:addChild(layer)
				--layer:onEnter({showNote = showNote})
			elseif nextState == GAME_STATE.STATE_LOGO then
				display.replaceScene(require("app.scenes.LogoScene").new())
			elseif nextState == GAME_STATE.STATE_LOGIN then
				display.replaceScene(require("game.login.LoginScene").new())
			elseif nextState == GAME_STATE.STATE_VERSIONCHECK then
				game.player.m_logout = true
				game.player.m_orderList = nil
				--UIManager:releaseUI()
				display.replaceScene(require("app.scenes.VersionCheckScene").new())
			elseif nextState == GAME_STATE.STATE_ZHENRONG then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenRong_XiTong, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = UIManager:newScene("ZhenRongScene")
					game.runningScene = scene
					display.replaceScene(scene)
					local layer = UIManager:getHeroSettingLayer(msg)
					--layer:removeFromParentAndCleanup(false)
					scene:addChild(layer)
				end
			elseif nextState == GAME_STATE.STATE_FUBEN then
				scene = UIManager:newScene("BigMapLayer")
				game.runningScene = scene
				local layer = UIManager:getBigMapLayer(msg or {})
				scene:addChild(layer)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_LIANHUALU then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.LianJuaLu, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.SplitStove.SplitStoveScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_JINGYUAN then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenQi_XiTong, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					local spiritCtrl = require("game.Spirit.SpiritCtrl")
					spiritCtrl.enterSpiritScene(msg)
				end
			elseif nextState == GAME_STATE.STATE_XIAKE then
				scene = require("game.Hero.HeroList").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_MIJI then
				scene = require("game.Cheats.CheatsList").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_FRIENDS then
				scene = require("game.Friend.FriendScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_EQUIPMENT then
				scene = require("game.Equip.EquipV2.EquipListScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_JINGMAI then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JingMai, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.jingmai.JingmaiScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_HUODONG then
				scene = require("game.Huodong.HuodongScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_BEIBAO then
				local function reqBag(data1, data2, data3)
					scene = require("game.Bag.BagScene").new(msg)
					scene:initdata(data1, data2, data3)
					display.replaceScene(scene)
				end
				game.player:getBagReq(reqBag)
			elseif nextState == GAME_STATE.STATE_TIAOZHAN then
				local bHasOpen_hd, hdPrompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip())
				local bHasOpen_jy, jyPrompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip())
				if bHasOpen_jy == true or bHasOpen_hd == true then
					scene = require("game.Challenge.ChallengeScene").new(msg)
					display.replaceScene(scene)
				else
					show_tip_label(jyPrompt)
					canShow = false
				end
			elseif nextState == GAME_STATE.STATE_ARENA then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JingJiChang, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Arena.ArenaScene").new(msg)
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_HUASHAN_SHOP then
				scene = require("game.huashan.HuaShanExchangeScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_ARENA_BATTLE then
				scene = require("game.Arena.ArenaBattleScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_DUOBAO then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DuoBao, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Duobao.DuobaoScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_JINGYING_BATTLE then
				scene = require("game.Challenge.JingYingBattleScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_HUODONG_BATTLE then
				scene = require("game.Challenge.HuoDongBattleScene").new({fubenid = msg})
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_JINGCAI_HUODONG then
				if msg == nbActivityShowType.LimitHero then
					local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.LimitHero, game.player:getLevel(), game.player:getVip())
					if not bHasOpen then
						show_tip_label(prompt)
						canShow = false
					else
						canShow = true
					end
				end
				if canShow == true then
					ActStatusModel.sendRes({
					callback = function ()
						scene = require("game.nbactivity.ActivityScene").new(msg)
						display.replaceScene(scene)
					end
					})
				end
			elseif nextState == GAME_STATE.STATE_RANK_SCENE then
				scene = require("game.RankListScene.RankListScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_MAIL then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Mail, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Mail.MailScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_SETTING then
				scene = require("game.Setting.SettingScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_SUBMAP then
				scene = UIManager:newScene("SubMapLayer")
				game.runningScene = scene
				local layer = UIManager:getSubMapLayer(msg)
				scene:addChild(layer)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_NORMAL_BATTLE then
				local levelData = msg.levelData
				local grade = msg.grade
				scene = require("game.Battle.BattleScene_sy").new(levelData.id, grade, msg.star, msg.needPower, msg.isPassed)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_BATTLE_FISRT then
				local levelData = msg.levelData
				local grade = msg.grade
				scene = require("game.Battle.BattleScene_sy").new(levelData.id, grade, msg.star, msg.needPower, msg.isPassed)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_SHOP then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhaoMu_XiaKe, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					local layer = require("game.shop.ShopWindow").new(msg)
					if layer then
						for k, v in pairs(MAIN_MENU_SUBMENU) do
							if display.getRunningScene():getChildByTag(v) ~= nil then
								display.getRunningScene():removeChildByTag(v)
							end
						end
						display.replaceScene(layer)
					end
				end
			elseif nextState == GAME_STATE.STATE_JIANGHULU then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QunxiaLu, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.jianghu.JianghuScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_WORLD_BOSS_NORMAL then
				scene = require("game.Worldboss.WorldBossNormalScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_WORLD_BOSS then
				scene = require("game.Worldboss.WorldBossScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.DRAMA_SCENE then
				scene = require("game.Drama.DramaScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.DRAMA_BATTLE then
				local battleData = msg
				scene = require("game.Drama.DramaBattleScene").new(battleData)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_HUASHAN then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuashanLunjian, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.huashan.HuaShanScene").new(msg)
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_HANDBOOK then
				scene = require("game.HandBook.HandBook").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_HANDBOOK_CHEATS then
				scene = require("game.HandBook.HandBookCheats").new(msg)
				push_scene(scene)				
			elseif nextState == GAME_STATE.STATE_HANDBOOK_PET then
				scene = require("game.HandBook.HandBookPet").new(msg)
				push_scene(scene)
			elseif nextState == GAME_STATE.STATE_GUILD then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Guild, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					local function toGuildScene(...)
						local scene
						if game.player:getGuildMgr():getIsInUnion() == false then
							scene = require("game.guild.guildList.GuildListScene").new(true)
						else
							scene = require("game.guild.GuildMainScene").new(msg)
						end
						display.replaceScene(scene)
					end
					game.player:getGuildMgr():RequestInfo(toGuildScene)
				end
			elseif nextState == GAME_STATE.STATE_GUILD_GUILDLIST then
				local toGuildListScene = function ()
					local scene = require("game.guild.guildList.GuildListScene").new(false)
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestGuildList(toGuildListScene)
			elseif nextState == GAME_STATE.STATE_GUILD_MAINSCENE then
				local scene = require("game.guild.GuildMainScene").new()
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_GUILD_ALLMEMBER then
				local toGuildMemberScene = function (data)
					local scene = require("game.guild.guildMember.GuildMemberScene").new({showType = 1, data = data})
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestShowAllMember(toGuildMemberScene)
			elseif nextState == GAME_STATE.STATE_GUILD_VERIFY then
				local toGuildVerifyScene = function (data)
					local scene = require("game.guild.guildMember.GuildMemberScene").new({showType = 2, data = data})
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestShowApplyList(toGuildVerifyScene)
			elseif nextState == GAME_STATE.STATE_GUILD_DADIAN then
				local toGuildMainScene = function (data)
					local scene = require("game.guild.guildDadian.GuildDadianScene").new(data)
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestEnterMainBuilding(toGuildMainScene)
			elseif nextState == GAME_STATE.STATE_GUILD_DYNAMIC then
				local toGuildDynamicScene = function (data)
					local scene = require("game.guild.guildDynamic.GuildDynamicScene").new(data)
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestDynamicList(toGuildDynamicScene)
			elseif nextState == GAME_STATE.STATE_GUILD_QL_BOSS then
				local function toGuildBossScene(data)
					local scene = require("game.guild.guildQinglong.GuildQLBossScene").new({data = data, isFromGuildMainScene = msg})
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestBossState(toGuildBossScene)
			elseif nextState == GAME_STATE.STATE_GUILD_SHOP then
				do
					local showType = msg
					local function toScene(data)
						local scene = require("game.guild.guildShop.GuildShopScene").new({data = data, showType = showType})
						display.replaceScene(scene)
					end
					game.player:getGuildMgr():RequestShopList(showType, toScene)
				end
			elseif nextState == GAME_STATE.STATE_BIWU then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.BiWu, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Biwu.BiwuMainScene").new(msg)
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_BIWU_BATTLE then
				local scene = require("game.Biwu.BiwuBattleScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_CULIAN_MAIN then
				local CuLianMianView = require("game.Culian.CulianMainScene").new({
				_index = msg._index,
				_objId = msg._objId,
				_pos = msg._pos
				})
				display.replaceScene(CuLianMianView)
			elseif nextState == GAME_STATE.STATE_GUILD_FUBEN then
				local showType = msg
				local toScene = function (data)
					local scene = require("game.guild.guildFuben.GuildFubenScene").new({data = data})
					display.replaceScene(scene)
				end
				game.player:getGuildMgr():RequestFubenList(showType, toScene)
			elseif nextState == GAME_STATE.STATE_YABIAO_SCENE then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.YABIAO, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Yabiao.YabiaoMainScene").new()
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_YABIAO_BATTLE_SCENE then
				local scene = require("game.Yabiao.YabiaoBattleScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_FRIEND_PK then
				local scene = require("game.Friend.FriendBattleScene").new(msg)
				display.replaceScene(scene)
			elseif nextState == GAME_STATE.STATE_PET then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ChongWu, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Pet.PetList").new(msg)
					display.replaceScene(scene)
				end
			elseif nextState == GAME_STATE.STATE_KUAFU_MAIN then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.KuaFuZhan, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					local function kuafuState(state)
						if state > enumKuafuState.close then
							scene = require("game.kuafuzhan.KuafuScene").new(state, true)
							display.replaceScene(scene)
						else
							show_tip_label(common:getLanguageString("@KuafuNotOpenTip"))
						end
					end
					KuafuModel.kuafuStateInit(kuafuState)
				end
			elseif nextState == GAME_STATE.STATE_GUILD_BATTLE then
				local function getGuildBattleInfo()
					local scene = require("game.guild.guildBattle.GuildBattleScene").new(msg)
					display.replaceScene(scene)
				end
				GuildBattleModel.init()
				GuildBattleModel.cityInfoInit(getGuildBattleInfo)
			elseif nextState == GAME_STATE.STATE_CHUANGDANG then
				local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ChuangDang, game.player:getLevel(), game.player:getVip())
				if not bHasOpen then
					show_tip_label(prompt)
					canShow = false
				else
					scene = require("game.Huodong.ChuangDang.ChuangDangScene").new(msg)
					display.replaceScene(scene)
				end
			end
			if not canShow then
				GameStateManager.currentState = lastState
			end
			if scene then
				game.runningScene = scene
			end
		end
	elseif nextState == GAME_STATE.STATE_MAIN_MENU then
		for k, v in pairs(MAIN_MENU_SUBMENU) do
			if display.getRunningScene():getChildByTag(v) ~= nil then
				display.getRunningScene():removeChildByTag(v)
			end
		end
	end
end

return GameStateManager