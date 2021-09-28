 --[[
 --
 -- @authors shan 
 -- @date    2014-05-13 15:17:12
 -- @version 
 --
 --]]

require("game.GameConst")

local GameStateManager = {}
GameStateManager.currentState = GAME_STATE.STATE_LOGO


function GameStateManager:resetState( ... )
    GameStateManager.currentState = GAME_STATE.STATE_LOGO
end


-- 强制设置，跳转到某个scene 
function GameStateManager:setState(state, msg) 
    GameStateManager.currentState = GAME_STATE.STATE_NONE 
    GameStateManager:ChangeState(state, msg) 
end 


function GameStateManager:ChangeState( nextState,msg)

	printf("nextState:" .. nextState)
	printf("currentState:" .. GameStateManager.currentState)
	if(GameStateManager.currentState ~= nextState) then
        local lastState = GameStateManager.currentState 
		GameStateManager.currentState = nextState

        local canShow = true 

--      清除push_scene里面的缓冲
        CCDirector:sharedDirector():popToRootScene()
        local scene
		if(nextState == GAME_STATE.STATE_MAIN_MENU) then
            local showNote = nil
            if(msg ~= nil) then
                showNote = msg.showNote
            end
			scene = require("game.scenes.MainMenuScene").new(showNote)
			display.replaceScene(scene)
        elseif(nextState == GAME_STATE.STATE_LOGO) then
            display.replaceScene(require("app.scenes.LogoScene").new())    
            
        elseif(nextState == GAME_STATE.STATE_LOGIN) then
            display.replaceScene(require("game.login.LoginScene").new()) 
        elseif(nextState == GAME_STATE.STATE_VERSIONCHECK) then
            display.replaceScene(require("app.scenes.VersionCheckScene").new()) 

		elseif(nextState == GAME_STATE.STATE_ZHENRONG) then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhenRong_XiTong, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
                canShow = false 
            else
    			scene = require("game.form.HeroSettingScene").new()
    			display.replaceScene(scene)
            end

		elseif(nextState == GAME_STATE.STATE_FUBEN) then
--            __G__TRACKBACK__("Hello")
            local bigMapID 
            local worldFunc 
            
            if msg ~= nil then
                bigMapID = msg.bigMapID
                subMapID = msg.subMapID
                worldFunc = msg.worldFunc
            end

            scene = require("game.Maps.BigMap").new(bigMapID,subMapID,worldFunc, true)

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
--            show_tip_label(data_error_error[2800001].prompt)
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

        elseif(nextState == GAME_STATE.STATE_HUODONG) then
            scene = require("game.Huodong.HuodongScene").new()
            display.replaceScene(scene)

		elseif(nextState == GAME_STATE.STATE_BEIBAO) then
            local function reqBag( data1, data2 )
                -- body            
                scene = require("game.Bag.BagScene").new(msg)
                scene:initdata(data1,data2)
                display.replaceScene(scene)
            end


            game.player:getBagReq(reqBag)

        elseif(nextState == GAME_STATE.STATE_TIAOZHAN) then 
            -- 默认精英副本的开启等级比活动副本的开启等级低
            local bHasOpen_hd, hdPrompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.HuoDong_FuBen, game.player:getLevel(), game.player:getVip()) 
            local bHasOpen_jy, jyPrompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JiYing_FuBen, game.player:getLevel(), game.player:getVip()) 

            if bHasOpen_jy == true or bHasOpen_hd == true then 
                scene = require("game.Challenge.ChallengeScene").new(msg) 
                display.replaceScene(scene) 
            else 
                show_tip_label(jyPrompt) 
                canShow = false 
            end 

        elseif(nextState == GAME_STATE.STATE_ARENA) then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.JingJiChang, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
                canShow = false 
            else
                scene = require("game.Arena.ArenaScene").new()
                display.replaceScene(scene)
            end
            
        elseif(nextState == GAME_STATE.STATE_HUASHAN_SHOP) then --华山商城
               scene = require("game.huashan.HuaShanExchangeScene").new()
               display.replaceScene(scene)           
        elseif (nextState == GAME_STATE.STATE_ARENA_BATTLE) then
            scene = require("game.Arena.ArenaBattleScene").new(msg)
            display.replaceScene(scene)

        elseif(nextState == GAME_STATE.STATE_DUOBAO) then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DuoBao, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
                canShow = false 
            else
                scene = require("game.Duobao.DuobaoScene").new()
                display.replaceScene(scene)
            end

        elseif (nextState == GAME_STATE.STATE_JINGYING_BATTLE) then
            scene = require("game.Challenge.JingYingBattleScene").new(msg)
            display.replaceScene(scene)

        elseif (nextState == GAME_STATE.STATE_HUODONG_BATTLE) then
            scene = require("game.Challenge.HuoDongBattleScene").new({
                fubenid = msg 
                })
            display.replaceScene(scene)

        elseif (nextState == GAME_STATE.STATE_JINGCAI_HUODONG) then
             --限时神将
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
                        callback = function()
                            scene = require("game.nbactivity.ActivityScene").new(msg)
                            display.replaceScene(scene)
                        end 
                        })
            end 

        elseif (nextState == GAME_STATE.STATE_RANK_SCENE) then
            --排行榜
                scene = require("game.RankListScene.RankListScene").new()
                display.replaceScene(scene)

        elseif (nextState == GAME_STATE.STATE_MAIL) then
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Mail, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then
                show_tip_label(prompt) 
                canShow = false 
            else
                scene = require("game.Mail.MailScene").new()
                display.replaceScene(scene)
            end

        elseif (nextState == GAME_STATE.STATE_SETTING) then
            scene = require("game.Setting.SettingScene").new()
            display.replaceScene(scene)
        elseif (nextState == GAME_STATE.STATE_SUBMAP) then
            scene = require("game.Maps.SubMap").new(msg)
            display.replaceScene(scene)
             
        elseif (nextState == GAME_STATE.STATE_NORMAL_BATTLE) then
            local levelData = msg.levelData
            local grade = msg.grade
            scene = require("game.Battle.BattleScene").new(levelData.id, grade, msg.star, msg.needPower,msg.isPassed)
            display.replaceScene(scene)

		elseif(nextState == GAME_STATE.STATE_SHOP) then
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhaoMu_XiaKe, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
                canShow = false 
            else
                local layer = require("game.shop.ShopWindow").new(msg)
                if layer then
                    for k,v in pairs(MAIN_MENU_SUBMENU) do
                        if(display.getRunningScene():getChildByTag(v) ~= nil) then
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
            scene = require("game.HandBook.HandBook").new()
            display.replaceScene(scene) 

        -- 帮派    
        elseif nextState == GAME_STATE.STATE_GUILD then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Guild, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
                canShow = false 
            else 
                local function toGuildScene( ... ) 
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

        -- 帮派列表 
        elseif nextState == GAME_STATE.STATE_GUILD_GUILDLIST then 
            local function toGuildListScene()
                local scene = require("game.guild.guildList.GuildListScene").new(false)  
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestGuildList(toGuildListScene) 

        -- 帮派主界面 
        elseif nextState == GAME_STATE.STATE_GUILD_MAINSCENE then 
            local scene = require("game.guild.GuildMainScene").new() 
            display.replaceScene(scene) 

        -- 帮派成员列表 
        elseif nextState == GAME_STATE.STATE_GUILD_ALLMEMBER then 
            local function toGuildMemberScene(data) 
                local scene = require("game.guild.guildMember.GuildMemberScene").new({
                    showType = 1, 
                    data = data 
                    })   
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestShowAllMember(toGuildMemberScene) 

        -- 审核列表 
        elseif nextState == GAME_STATE.STATE_GUILD_VERIFY then 
            local function toGuildVerifyScene(data) 
                local scene = require("game.guild.guildMember.GuildMemberScene").new({
                    showType = 2, 
                    data = data 
                    })   
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestShowApplyList(toGuildVerifyScene) 
        --比武
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
        -- 帮派大殿  
        elseif nextState == GAME_STATE.STATE_GUILD_DADIAN then 
            local function toGuildMainScene(data) 
                local scene = require("game.guild.guildDadian.GuildDadianScene").new(data) 
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestEnterMainBuilding(toGuildMainScene)

        -- 帮派动态 
        elseif nextState == GAME_STATE.STATE_GUILD_DYNAMIC then 
            local function toGuildDynamicScene(data) 
                local scene = require("game.guild.guildDynamic.GuildDynamicScene").new(data) 
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestDynamicList(toGuildDynamicScene) 

        -- 青龙堂boss 
        elseif nextState == GAME_STATE.STATE_GUILD_QL_BOSS then 
            local function toGuildBossScene(data) 
                local scene = require("game.guild.guildQinglong.GuildQLBossScene").new({
                    data = data, 
                    isFromGuildMainScene = msg 
                    }) 
                display.replaceScene(scene) 
            end 

            game.player:getGuildMgr():RequestBossState(toGuildBossScene) 

        -- 帮派商店 
        elseif nextState == GAME_STATE.STATE_GUILD_SHOP then 
            local showType = msg 
            local function toScene(data) 
                local scene = require("game.guild.guildShop.GuildShopScene").new({
                    data = data, 
                    showType = showType 
                    }) 
                display.replaceScene(scene) 
            end 
            
            game.player:getGuildMgr():RequestShopList(showType, toScene) 

        -- 帮派副本
        elseif nextState == GAME_STATE.STATE_GUILD_FUBEN then 
            local showType = msg 
            local function toScene(data)
                local scene = require("game.guild.guildFuben.GuildFubenScene").new({
                    data = data
                    }) 
                display.replaceScene(scene) 
            end
            
            game.player:getGuildMgr():RequestFubenList(showType, toScene) 

        elseif nextState == GAME_STATE.STATE_YABIAO_SCENE then
        	--测试押镖
            scene = require("game.Yabiao.YabiaoMainScene").new()   
            display.replaceScene(scene)
        elseif nextState == GAME_STATE.STATE_YABIAO_BATTLE_SCENE then
			local scene = require("game.Yabiao.YabiaoBattleScene").new(msg)   
            display.replaceScene(scene)
        end

        --[[============]]
        if not canShow then 
            GameStateManager.currentState = lastState
        end 

        if scene then
            game.runningScene = scene
        end
	else
		if(nextState == GAME_STATE.STATE_MAIN_MENU ) then
			
			for k,v in pairs(MAIN_MENU_SUBMENU) do				
				if(display.getRunningScene():getChildByTag(v) ~= nil) then
					display.getRunningScene():removeChildByTag(v)
				end
			end

		end
	end
end


return GameStateManager 