--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-17
-- Time: 下午3:04
-- To change this template use File | Settings | File Templates.
--

BottomBtnEvent = {}

BottomBtnEvent.canTouchEnabled = true 


function BottomBtnEvent.setTouchEnabled(bEnabled)
    BottomBtnEvent.canTouchEnabled = bEnabled 
end




function BottomBtnEvent.registerBottomEvent(btnMaps)

    local function onTouchBtn(tag)
        -- if  ResMgr.isBottomEnabled == false then
        --     return
        -- end

        if BottomBtnEvent.canTouchEnabled ~= nil and BottomBtnEvent.canTouchEnabled == true then 

            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
            
            local nextState = 0
            if(tag == 1) then
                nextState = GAME_STATE.STATE_MAIN_MENU
            elseif(tag == 2) then
                RequestHelper.formation.list({
                m = "fmt",
                a = "list",
                pos = "0",
                param      = {},
                callback = function(data)

                    game.player.m_formation = data
                    -- dump(game.player.m_formation["2"])
                    nextState = GAME_STATE.STATE_ZHENRONG
                    GameStateManager:ChangeState(nextState, msg)
                end
            })
                -- nextState = GAME_STATE.STATE_ZHENRONG
            elseif(tag == 3) then
                nextState = GAME_STATE.STATE_FUBEN

            elseif(tag == 4) then
                nextState = GAME_STATE.STATE_HUODONG
            elseif(tag == 5) then
                nextState = GAME_STATE.STATE_BEIBAO
            elseif(tag == 6) then
                nextState = GAME_STATE.STATE_SHOP
            end

            -- 高亮选择中的底部按钮
            -- 重复点击，保持高亮，不切换状态
            local items = {"mainSceneBtn", "formSettingBtn", "battleBtn", "activityBtn", "bagBtn", "shopBtn"}
            for k,v in pairs(G_BOTTOM_BTN) do
                if(GameStateManager.currentState == v and GameStateManager.currentState > 2) then            
                    btnMaps[items[k]]:selected()
                    break
                end
            end

            if(tag ~= 2) then
                if nextState ==   GAME_STATE.STATE_FUBEN then

                    local bigMapID = nil
                    if PageMemoModel.bigMapID ~= 0 then
                        bigMapID = PageMemoModel.bigMapID
                    end
                    local msg = {}
                    -- 请求大地图数据
                    RequestHelper.getLevelList({
                        id = bigMapID,
                        callback = function(data)
                            -- dump(data) 
                            game.player.bigmapData = data
                            msg.bigMapID = game.player.bigmapData["1"]
                            msg.subMapID = game.player.bigmapData["2"]
                            GameStateManager:ChangeState(nextState, msg)
                        end
                    })
                else             
                    GameStateManager:ChangeState(nextState)
                end
            end
        end 
    end


    if btnMaps["mainSceneBtn"] then
        btnMaps["mainSceneBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end

    if btnMaps["formSettingBtn"] then
        btnMaps["formSettingBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end

    if btnMaps["battleBtn"] then
        btnMaps["battleBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end

    if btnMaps["activityBtn"] then
        btnMaps["activityBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end

    if btnMaps["bagBtn"] then
        btnMaps["bagBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end

    if btnMaps["shopBtn"] then
        btnMaps["shopBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTouchBtn)
    end
end

return BottomBtnEvent

