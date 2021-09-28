local LoadingScene = class("LoadingScene",function() return cc.Layer:create() end)
--local last_time = 0
--LoadingScene.changeTime = 0
function LoadingScene:ctor(luaBuffer,params)
    local BaseMapScene = require("src/base/BaseMapScene")
    --local now_time = os.time()
    if G_ROLE_MAIN then
        --G_ROLE_MAIN:standed()
        G_ROLE_MAIN:RemoveCharText();
        G_ROLE_MAIN:removeRideAction()
        G_ROLE_MAIN:retain()
        G_ROLE_MAIN:onRetain()
    end 
    AudioEnginer.stopAllEffects()
    --__G_cacheTip__ = nil
    local mapInfo = getConfigItemByKey("MapInfo","q_map_id",params[3])
    local mapName = "res/map/block/"..mapInfo.q_mapresid..".tmx"
    if mapInfo.q_newmap then
        mapName = "res/mapnew/"..mapInfo.q_mapresid..".tmx"
    end
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames() 
    TextureCache:removeUnusedTextures()
    local is_firstin = not G_MAINSCENE
    local need_add_loading = true
    if G_MAINSCENE and G_MAINSCENE.map_layer then
        if (G_MAINSCENE.mapId == G_SHAWAR_DATA.mapId or G_MAINSCENE.mapId == G_SHAWAR_DATA.mapId1) 
            and (params[3] == G_SHAWAR_DATA.mapId or params[3] == G_SHAWAR_DATA.mapId1) then
            need_add_loading = false
        end

        G_MAINSCENE.map_layer:removeRockerCb()
        if game.getAutoStatus() == AUTO_ATTACK then
            game.setAutoStatus(0)
        else
            local detailMapNode = require("src/layers/map/DetailMapNode"):getDetailMapInfo()
            if detailMapNode.map_id == G_MAINSCENE.mapId then
                detailMapNode.curmap_tarpos = nil
                detailMapNode.map_id = nil
                detailMapNode.target_pos = nil
                if game.getAutoStatus() ~= AUTO_PATH_MAP or game.getAutoStatus() ~= AUTO_PATH then 
                    game.setAutoStatus(0)
                end
            end
        end
        G_MAINSCENE:playHangupEffect(2)
        --if MapView.resetBloodNode then MapView:resetBloodNode() end
        if G_MAINSCENE.map_layer.skill_item_Node then
            G_MAINSCENE.map_layer.skill_item_Node:stopAllActions()
        end
        G_MAINSCENE.map_layer:resetTouchTag()
        local reset_mainscene = false
        if mapInfo.xianzhi and tonumber(mapInfo.xianzhi) == 1 and (not mapInfo.Is_BOSS) then
        --if params[3] == 6004 or params[3] == 20001 or tonumber(mapInfo.q_map_zones) == 1  then
            reset_mainscene = true
        else
            --if G_MAINSCENE.map_layer:isHideMode()  then
            local old_map_info = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId)
            if old_map_info.xianzhi and tonumber(old_map_info.xianzhi) == 1 and (not old_map_info.Is_BOSS) then
                reset_mainscene = true
            else
                __RemoveTargetTab("a44")
            end
        end
        -- 清空
        G_MAINSCENE.map_layer.m_friendsData = {};
        if G_MAINSCENE.map_layer.item_Node then
            G_MAINSCENE.map_layer.safe_node = nil
            removeFromParent(G_MAINSCENE.map_layer.item_Node)
            G_MAINSCENE.map_layer.item_Node = nil
        end
        removeFromParent(G_MAINSCENE.map_layer)
        G_MAINSCENE.map_layer = nil
        if reset_mainscene then
            G_MAINSCENE = nil
            -- if Device_target == cc.PLATFORM_OS_ANDROID then
            --     local className = "org/cocos2dx/lua/AppActivity"
            --     local methodName = "HideKeyboard"
            --     local sig = "()V"
            --     local ok, ret = callStaticMethod(className, methodName, {}, sig)
            -- end
        end
    end

    if G_MAINSCENE then
        --cc.SpriteFrameCache:getInstance():removeSpriteFramesEx() 
        G_MAINSCENE:addChild(self,9999)
        if need_add_loading then self:addBgLayer(params[3]) end
        local goTo = function()
            G_MAINSCENE:createMapLayer(mapName,params[3],cc.p(params[4],params[5]),tonumber(mapInfo.q_map_zones) == 1)
            G_MAINSCENE:onEnterMapScene(luaBuffer,params)    
        end
        goTo()
        --performWithDelay(getRunScene(),goTo,0.00)
        return
        --cc.TextureCache:getInstance():removeUnusedTextures()
    end

    if is_firstin then
        require("src/base/BaseMapNetNode").first_login = true
        BaseMapScene:reInit()
        BaseMapScene.skill_cds[7000] = 300
    elseif G_MAINSCENE then
        G_MAINSCENE.mapId = nil 
        if G_MAINSCENE.skill_node and G_MAINSCENE.skill_node.getPageIndex  then
            G_SKILL_PAGE = G_MAINSCENE.skill_node:getPageIndex()
        end         
    end 

    if luaBuffer and params then
        --cc.SpriteFrameCache:getInstance():removeSpriteFrames() 
        params[4] = params[4] or 31
        params[5] = params[5] or 24
        local changeScene = function() 
            __TASK = nil
            G_MAINSCENE = nil
            clearTextAry()
            local scene = BaseMapScene.new(luaBuffer,params)
            if G_MAINSCENE then
                if not is_firstin then
                    Director:replaceScene(scene)
                    G_MAINSCENE:addChild(self,9999)
                else
                    --Director:replaceScene(scene)
                    Director:replaceScene(cc.TransitionFade:create(0.0,scene))
                end
            else 
                G_MAINSCENE = nil
                userInfo.connStatus = RECONNECTFAILED
                globalInit()
                TIPS( { type = 1 , str = "^c(green)进入地图异常，请重新登录^" } )
                local func = function()
                    game.ToLoginScene()
                end
                performWithDelay(getRunScene(),func,1.0)
                return
            end
            G_MAINSCENE:createMapLayer(mapName,params[3],cc.p(params[4],params[5]),tonumber(mapInfo.q_map_zones) == 1)
            G_MAINSCENE:onEnterMapScene(luaBuffer,params,true)
        end
        --[[  
        if now_time - LoadingScene.changeTime <= 1 then
            print("change map too busy")
            if G_MAINSCENE.map_layer then
                removeFromParent(G_MAINSCENE.map_layer)
                G_MAINSCENE.map_layer = nil
            end
            createSprite(getRunScene(),CommPath.."logo.jpg",cc.p(s.width/2,s.height/2),nil,9999)
            performWithDelay(getRunScene(),changeScene,0.5)
        else
            changeScene()
        end
        LoadingScene.changeTime = now_time
        ]]
        changeScene()
        if (not is_firstin) and need_add_loading then
            self:addBgLayer(params[3])
        end
    end
end


function LoadingScene:addBgLayer(map_id)
    local hight = 20
    local loading_str = "res/loading/1.jpg"
    local futil = cc.FileUtils:getInstance()
    local bCurFilePopupNotify = false
    if isWindows() then
        bCurFilePopupNotify = futil:isPopupNotify()
        futil:setPopupNotify(false)
    end
    local c_effect = nil
    local load_effect = nil
    local temp_loading_str = "res/loading/"..map_id..".jpg"
    if futil:isFileExist(temp_loading_str) and (not getLocalRecord("loading"..map_id)) then
        loading_str = temp_loading_str
        load_effect = true
    end
    if isWindows() then
        futil:setPopupNotify(bCurFilePopupNotify)
    end
    local bg = createSprite(self,loading_str,cc.p(g_scrSize.width/2,g_scrSize.height/2),cc.p(0.5,0.5))
    local b_size = bg:getContentSize()
    local scale = g_scrSize.width/b_size.width
    if g_scrSize.height/b_size.height > scale then scale = g_scrSize.height/b_size.height end
    bg:setScale(scale)
    local loading_bg = createSprite(self, "res/login/loadingbg.png", cc.p(g_scrCenter.x, 0), cc.p(0.5,0.0))
    local bg_size = loading_bg:getContentSize()
    local b_scale = g_scrSize.width/bg_size.width
    loading_bg:setScale(b_scale)
    local progress = cc.ProgressTimer:create(cc.Sprite:create("res/login/loadingpr.png"))  
    progress:setPosition(cc.p(0, bg_size.height/2+5))
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setAnchorPoint(cc.p(0.0,0.5))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0,1))
    progress:setPercentage(0)
    loading_bg:addChild(progress)
    if G_TIPS then
        --local tips_bg = createScale9Sprite(self,"res/layers/mine/4.png",cc.p(b_size.width/2,hight),cc.size(b_size.width+10,100))
        --tips_bg:setOpacity(125)
        local tips = G_TIPS[math.random(1,#G_TIPS)]
        if tips then 
            createLabel(loading_bg,tips,cc.p(bg_size.width/2,hight),nil,22):setColor(cc.c3b(225, 137, 67))
        end
    end
    local runeffect = Effects:create(false)
    runeffect:playActionData("loading", 6, 0.6, -1)
    progress:addChild(runeffect, 2)
    runeffect:setPosition(cc.p(50,100))
    self:setCascadeOpacityEnabled(true)
    local index = 10
    local setText = function() 
        if index < 72 then
            runeffect:setPosition(cc.p(-10+index*11,100))
            progress:setPercentage(index)
        elseif index >= 72 then
            self:stopAllActions()
            self:runAction(cc.Sequence:create(
                cc.FadeOut:create(0.3)
                , cc.RemoveSelf:create()
            ))
        end
        index = index + 8
    end
    local endFunc = function()
        --setLocalRecordByKey(3,"loading"..map_id,true)
        setLocalRecord("loading"..map_id,true)
    end
    if load_effect then
        loading_bg:setVisible(false)
        self:setOpacity(128)
        self:runAction(cc.Sequence:create(cc.FadeTo:create(1,255),cc.DelayTime:create(1),cc.FadeOut:create(2),cc.CallFunc:create(endFunc),cc.RemoveSelf:create()))
    else
         schedule(self,setText,0.01)
    end
   
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
            self:stopAllActions()
            if load_effect then
                endFunc()
            elseif loading_bg then
                loading_bg:setVisible(false)
            end
            self:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.RemoveSelf:create()))
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self)
    --SwallowTouches(self)
end
--[[
function LoadingScene:gotoMapScene(scene)
    local cb = function()
        scene:onEnterMapScene
        Director:replaceScene(cc.TransitionFade:create(0.2,scene))
    end
    performWithDelay(self, cb, 0.0)
end
]]
return LoadingScene