local OpenDoorScene = class("OpenDoorScene",function() return cc.Scene:create() end)

function OpenDoorScene:ctor(roleid)
    __G_IS_OPENSCENE = true
    self.roleid = roleid
    local CommPath = "res/login/"--"res/createRole/opendoor/"  
    local bg = createSprite(self,"res/loading/1.jpg",cc.p(g_scrSize.width/2,g_scrSize.height/2),cc.p(0.5,0.5))
--if g_scrSize.width > 960 and g_scrSize.height > 640 then 
    --AudioEnginer.playMusic("sounds/openDoor.mp3")
    setLocalRecordByKey(2, "lastRoleID",roleid)
    local c_size = bg:getContentSize()
    local scale = g_scrSize.width/c_size.width
    if g_scrSize.height/c_size.height > scale then scale = g_scrSize.height/c_size.height end
    bg:setScale(scale)
   -- local door_str = {"a.jpg","b.jpg","c.jpg","d.jpg","e.jpg","f.jpg","g.jpg","h.jpg","i.jpg","j.jpg"}
    --local door = createSprite(bg,CommPath.."a.jpg",cc.p(400,300),cc.p(0.5,0.5))
    local logo = createSprite(self, CommPath.."7.png", cc.p(g_scrSize.width-200, g_scrSize.height/2+120), cc.p(0.5,0.5))
    logo:setOpacity(0)
    logo:setScale(0.01)
    logo:runAction(cc.Spawn:create(cc.FadeIn:create(0.5),
        cc.Sequence:create(cc.ScaleTo:create(0.2,1.6),cc.ScaleTo:create(0.2,scale),cc.CallFunc:create(function()
            --self:gotoGame(roleid) 
            end)
            )))
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames() 
    local hight = 20
    local loading_bg = createSprite(self, CommPath.."loadingbg.png", cc.p(g_scrCenter.x, 0), cc.p(0.5,0.0))
    local bg_size = loading_bg:getContentSize()
    local b_scale = g_scrSize.width/bg_size.width
    loading_bg:setScale(b_scale)
    local progress = cc.ProgressTimer:create(cc.Sprite:create(CommPath.."loadingpr.png"))  
    progress:setPosition(cc.p(0, bg_size.height/2+5))
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setAnchorPoint(cc.p(0.0,0.5))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setMidpoint(cc.p(0,1))
    progress:setPercentage(0)
    loading_bg:addChild(progress)
    if G_TIPS then
        local b_size = bg:getContentSize()
        --local tips_bg = createScale9Sprite(self,"res/layers/mine/4.png",cc.p(b_size.width/2,hight),cc.size(b_size.width+10,100))
       -- tips_bg:setOpacity(125)
        local tips = G_TIPS[math.random(1,#G_TIPS)]
        if tips then 
            createLabel(loading_bg,tips,cc.p(bg_size.width/2,hight),nil,22):setColor(cc.c3b(225, 137, 67))
        end
    end
    local runeffect = Effects:create(false)
    runeffect:playActionData("loading", 6, 0.6, -1)
    progress:addChild(runeffect, 2)
    runeffect:setPosition(cc.p(50,100))
    
    local backToLogin = function()
	    print("loading .. backToLogin")
	    userInfo.connStatus = RECONNECTFAILED
	    globalInit()
	    game.ToLoginScene()
    end

    local index = 10
    local setText = function() 
        if index < 72 then
            runeffect:setPosition(cc.p(-10+index*11,100))
            progress:setPercentage(index)
        elseif index == 72 then
           -- index = 0
            self:gotoGame(roleid)
        elseif index == 272 then
            local ret = MessageBox(game.getStrByKey("bad_heart_speed_tip"), game.getStrByKey("sure"), backToLogin)
            performWithDelay(ret, function() backToLogin() end, 6)
        end
        index = index + 2
    end
    schedule(self,setText,0.05)
 

    --print("roleid:"..roleid)
    --[[
    local gotoGame = function()
        local callback = function()
            local luaEventMgr = LuaEventManager:instance()
            local mbuff = luaEventMgr:getLuaEvent(2012)
            LuaSocket:getInstance():sendSocket(mbuff)
            globalInit()
            game.ToLoginScene()
        end
        MessageBox(game.getStrByKey("login_loginFailedAndRetToLogin"),nil,callback)  
    end
    ]]
    --performWithDelay(self,gotoGame,3)
	-- 1-game_id-游戏ID(只能传数字字符串),2-area_id-区号(只能传数字字符串),3-group_id-组号(只能传数字字符串),
	-- 4-pt_id-账号ID,5-mobile-手机号,6-user_id-角色名,
	-- 7-auth_type-认证方式,8-user_job-角色职业,9-user_level-角色等级,10-ext_key-扩展键值对
    local role_tab = {}
    if g_roleTable and #g_roleTable > 0 then
        for k,v in pairs(g_roleTable)do
            if v["RoleID"] == roleid then
                role_tab = v
                break
            end
        end
    end
    require "src/config/convertor"
	MdsAgent:setUserInfo("791000169", tostring(userInfo.serverId), "0", tostring(userInfo.userName), "", tostring(roleid), tostring(sdkGetArea()), Mconvertor:school(role_tab.School),tostring(role_tab.Level) , Mconvertor:sexName(role_tab.Sex), "")

    local msgids = {LOGIN_SC_GETROLELOCKSTATUS}
    require("src/MsgHandler").new(self,msgids)
end

function OpenDoorScene:gotoGame(roleid)

    ServerList.disconnect()
    require("src/layers/setting/SettingMsg")
    resetGameSeting()
    loadGameSettings(roleid)
    AudioEnginer.setIsNoPlayMusic(getGameSetById(GAME_SET_ID_CLOSE_MUSIC)==0)
    TextureCache:removeUnusedTextures()
    require("src/reLoadFiles")
    globalDataInit()
    require "src/RegComMsgHandler"
    __G_ON_CREATE_ROLE = nil
    __G_IS_OPENSCENE = nil
    sendLoadPlayerMsg(userInfo.userId,roleid,userInfo.serverId,userInfo.serversreal,userInfo.startTick,__getMapIDByRoleId(roleid),userInfo.sessionID,userInfo.userName)
    userInfo.currRoleStaticId = roleid;
    print("userInfo.currRoleStaticId = [" .. roleid .. "]");

    --g_dwon_manage = require("src/layers/download/DownloadManage").new()

    local platform = sdkGetPlatform()
    if platform == 1 then
        --print("Wechat")
        TersafeSDK:onTersafeWeChatLogin(sdkGetOpenId(), tostring(userInfo.userId), userInfo.serverId)
    elseif platform == 2 then
        --print("QQ")
        TersafeSDK:onTersafeQQLogin(sdkGetOpenId(), tostring(userInfo.userId), userInfo.serverId) 
    end

    --sdkShowNotice("2")
    LoginUtils.showNotice("2")
end

function OpenDoorScene:networkHander(luaBuffer,msgid)
    local switch = {
        [LOGIN_SC_GETROLELOCKSTATUS] = function()
            local retTable = g_msgHandlerInst:convertBufferToTable("LoginRoleLockStatusRet", luaBuffer)
            
            local strError = retTable.lockReason
            local time = retTable.lockDate
            
            local backCallBack = function()
                if g_roleTable and #g_roleTable > 0 then
                    if G_OLD_CREATE_ROLE then
                        game.goToScenes("src/login/CreateRoleFirst")
                    else
                        game.goToScenes("src/login/NewCreateRoleEndScene", getLocalRecordByKey(1, "lastRoleID"));
                    end
                else
                    if G_OLD_CREATE_ROLE then
                        game.goToScenes("src/login/CreateRole");
                    else
                        game.goToScenes("src/login/NewCreateRole");
                    end          
                end
            end

            local role_tab = {}
            if g_roleTable and #g_roleTable > 0 then
                for k,v in pairs(g_roleTable)do
                    if v["RoleID"] == self.roleid then
                        role_tab = v
                        break
                    end
                end
            end
            local str = string.format(game.getStrByKey("open_door_role_lock2"), "", role_tab.userName or "", strError)
            if time == -1 then
                str = str .. game.getStrByKey("open_door_role_lock4")
            elseif time > 0 then
                str = str .. game.getStrByKey("open_door_role_lock3") .. os.date("%Y-%m-%d %H:%M:%S", time)
            end

            MessageBox( str, game.getStrByKey("sure"), backCallBack)
        end,
    }
    if switch[msgid] then 
        switch[msgid]()
    end
end

return OpenDoorScene