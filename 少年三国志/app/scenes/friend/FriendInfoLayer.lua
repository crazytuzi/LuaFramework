
local FriendInfoLayer = class("FriendInfoLayer", UFCCSModelLayer)
local FriendInfoConst = require("app.const.FriendInfoConst")

function FriendInfoLayer.create( info,func,killCallBack)
    local layer = FriendInfoLayer.new("ui_layout/friend_FriendInfoLayer.json",Colors.modelColor)
    layer:setKillCallBack(killCallBack)
    layer:updateView(info)
    if func then 
        layer:setCallBack(func)
    end
    return layer
end

function FriendInfoLayer.createByName(id, name, func,killCallBack)
    local layer = FriendInfoLayer.new("ui_layout/friend_FriendInfoLayer.json",Colors.modelColor)
    layer:setKillCallBack(killCallBack)
    G_HandlersManager.friendHandler:sendGetPlayerInfo(id,name)
    if func then 
        layer:setCallBack(func)
    end
    return layer
end

function FriendInfoLayer:setKillCallBack(callback)
    self._killCallBack = callback
end

function FriendInfoLayer:onLayerEnter( ... )
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_ADD, self._onFriendAdd, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_DELETE, self._onFriendDelete, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_KILL, self._onFriendKill, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_PLAYINFO, self._onFriendInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FRIENDS_MAIL, self._onFriendMail, self)  
end

function FriendInfoLayer:ctor()
    self.super.ctor(self)
    self:adapterWithScreen()

    self._vip = self:getImageViewByName("Image_vip")
    self._fightCapacity = self:getLabelByName("Label_zhanli")
    self._playerName = self:getLabelByName("Label_name")
    self._playerLevel = self:getLabelByName("Label_level")
    self._friend = self:getImageViewByName("Image_8")
    self._hero = self:getImageViewByName("ImageView_equipment_icon")
    self._board = self:getButtonByName("Button_border")

    self._hui1 = self:getLabelByName("Label_hui")
    self._hui2 = self:getLabelByName("Label_huiinfo")

    self._vip:setVisible(false)

    -- self._fightCapacity:createStroke(Colors.strokeBrown, 1)
    self._playerName:createStroke(Colors.strokeBrown, 1)
    -- self._playerLevel:createStroke(Colors.strokeBrown, 1)

    self._test = false
    self._runTest = false
    if G_PlatformProxy:getLoginServer().id == 9 then
        self._test = true
    end

    if self._test then
        self:gameInit()
    end

    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function(widget)
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    self:registerBtnClickEvent("Button_add",function(widget)
        self:_onAdd()
    end)
    self:registerBtnClickEvent("Button_hei",function(widget)
        self:_onHei()
    end)
    self:registerBtnClickEvent("Button_chat",function(widget)
        self:_onChat()
    end)
    self:registerBtnClickEvent("Button_mail",function(widget)
        self:_onMail()
    end)
    self:registerBtnClickEvent("Button_form",function(widget)
        self:_onForm()
    end)
    self:registerBtnClickEvent("Button_fight",function(widget)
        self._runTest = false
        self:_onFight()
    end)

end

function FriendInfoLayer:gameInit()
    self._totalTryTime = 1000
    self._sendCount = 0
    self._baseImg = self:getImageViewByName("Image_1")
    local rectheight = 540
    local height = (display.height - rectheight)/4+rectheight/2
    self._gameButton = Button:create()
    self._gameButton:loadTextureNormal("btn-big.png", UI_TEX_TYPE_PLIST)
    self._gameButton:setTouchEnabled(true)
    self._baseImg:addChild(self._gameButton)
    self._gameButton:setName("Button_play")
    self._gameButton:setPosition(ccp(0,height))
    self._gameButton:setTitleText("来一发吧")
    self._gameButton:setTitleFontSize(40)
    -- self._gameButton:setTitleColor(Colors.)
    -- self:getButtonByName("Button_play"):setVisible(false)
    self._fightState = false
    self:registerBtnClickEvent("Button_play",function(widget)
        self._runTest = true
        -- G_HandlersManager.friendHandler:sendKillFriend(self._info.id)
        self._sendCount = 0
        self._winCount = 0
        self._loseCount = 0
        self._labelRate:setVisible(false)
        -- self._timer = GlobalFunc.addTimer(0.02, handler(self, self._onTimer))
        self:_buttonClicked()
    end)

    self._labelWin =  GlobalFunc.createGameLabel("0", 80, Colors.darkColors.ATTRIBUTE, Colors.strokeBrown)
    self._labelLose =  GlobalFunc.createGameLabel("0", 80, Colors.darkColors.TIPS_01, Colors.strokeBrown)
    self._baseImg:addChild(self._labelWin)
    self._baseImg:addChild(self._labelLose)
    self._labelWin:setPosition(ccp(-200,height))
    self._labelLose:setPosition(ccp(200,height))

    self._labelRate =  GlobalFunc.createGameLabel("100.0%", 40, Colors.darkColors.ATTRIBUTE, Colors.strokeBrown)
    self._baseImg:addChild(self._labelRate)
    self._labelRate:setVisible(false)
    self._labelRate:setPosition(ccp(0,(height+rectheight/2)/2-20))
end

function FriendInfoLayer:_buttonClicked()
    if self._fightState then
        self._fightState = false
        self._gameButton:setTitleText("来一发吧")
        GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    else
        self._fightState = true
        self._gameButton:setTitleText("不想来了")
        self._timer = GlobalFunc.addTimer(0.02, handler(self, self._onTimer))
    end
end

function FriendInfoLayer:_onTimer( )
    if self._sendCount < self._totalTryTime then
        G_HandlersManager.friendHandler:sendKillFriend(self._info.id)
        G_WaitingLayer:setVisible(false)
        self._sendCount = self._sendCount + 1
    else
        -- GlobalFunc.removeTimer(self._timer)
        -- self._timer = nil
        self:_buttonClicked()
    end
end

function FriendInfoLayer:updateView(info )

    if info == nil then
        self:animationToClose()
        return
    end

    self._info = info
    
    self._isFriend = G_Me.friendData:isFriend(info.name)

    self._hui1:setText(G_lang:get("LANG_FRIEND_BANGHUI"))
    -- self._hui2:setText(G_lang:get("LANG_FRIEND_ZANWU"))
    if #info.guild_name > 0 then
        self._hui2:setText(info.guild_name)
    else
        self._hui2:setText(G_lang:get("LANG_FRIEND_ZANWU"))
    end

    local knightBaseInfo = knight_info.get(info.mainrole)
    -- local resId = knightBaseInfo["res_id"]

    local resId = G_Me.dressData:getDressedResidWithClidAndCltm(info.mainrole,info.dress_id,info.clid,info.cltm,info.clop)
    local heroPath = G_Path.getKnightIcon(resId)
    self._hero:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
    self._board:loadTextureNormal(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))
    self._board:loadTexturePressed(G_Path.getEquipColorImage(knightBaseInfo.quality,G_Goods.TYPE_KNIGHT))

    self._playerName:setColor(Colors.qualityColors[knightBaseInfo.quality])

    self._vip:setVisible(info.vip > 0)
    self._playerName:setText(info.name)
    self._fightCapacity:setText(info.fighting_capacity)
    self._playerLevel:setText(info.level..G_lang:get("LANG_FRIEND_LEVEL"))



    if self._isFriend then
        self._friend:loadTexture("ui/text/txt-middle-btn/shanchuhaoyou.png")
    else
        self._friend:loadTexture("ui/text/txt-middle-btn/tianjiahaoyou.png")
    end

    -- 称号相关显示更新
    local titleId = info.title_id
    local titleLabel = self:getLabelByName("Label_Title_Name")
    local titleBgBtn = self:getButtonByName("Button_Title")
    if titleId > 0 then
        require("app.cfg.title_info")
        local titleInfo = title_info.get(titleId)

        titleLabel:setVisible(true)
        titleLabel:setColor(Colors.getColor(titleInfo.quality))
        titleLabel:setText(titleInfo.name)
        titleLabel:createStroke(Colors.strokeBrown, 3)
        
        titleBgBtn:setVisible(true)
        titleBgBtn:loadTextureNormal(titleInfo.picture, UI_TEX_TYPE_LOCAL)  

        self:registerBtnClickEvent("Button_Title", function ( ... )
            local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(titleId)
            -- TODO:这样加会不会有问题？？？
            self:addChild(dialog)
        end)            
    else
        titleLabel:setVisible(false)
        titleBgBtn:setVisible(false)
    end

    --头像框
    local frameId = rawget(info,"fid") and info.fid or 0
    if frameId > 0 then
        require("app.cfg.frame_info")
        local frame = frame_info.get(frameId)
        if frame then
            self:getImageViewByName("ImageView_Frame"):setVisible(true)
            self:getImageViewByName("ImageView_Frame"):loadTexture(G_Path.getAvatarFrame(frame.res_id))
            G_GlobalFunc.addHeadIcon(self:getImageViewByName("ImageView_Frame"),frame.vip_level)
        else
            self:getImageViewByName("ImageView_Frame"):setVisible(false)
        end
    else
        self:getImageViewByName("ImageView_Frame"):setVisible(false)
    end

end

function FriendInfoLayer:onLayerLoad( )
        self.super:onLayerLoad()
end

function FriendInfoLayer:setCallBack( callback )
    self._callBack = callback
end

function FriendInfoLayer:_onAdd( )
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.ADDFRIEND)
        if res then
            self:animationToClose()
            return
        end
    end

    if not self._info then 
        return 
    end
    if self._isFriend then 
    MessageBoxEx.showYesNoMessage( G_lang:get("LANG_FRIEND_TISHI"),
     G_lang:get("LANG_FRIEND_ADD2",{name=self._info.name}), false, 
        function() 
            G_HandlersManager.friendHandler:sendDeleteFriend(self._info.id)
        end,
        function() end, 
        self )
    else
        G_HandlersManager.friendHandler:sendAddFriend(self._info.name)
    end
end

function FriendInfoLayer:_onHei( )
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.ADDBLACK)
        if res then
            self:animationToClose()
            return
        end
    end
    
    if not self._info then 
        return 
    end
    --已经在黑名单了就不要拉黑了
    if G_Me.friendData:isBlack(self._info.name) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_BLACK3",{name=self._info.name}))
        return
    end
    if not G_Me.friendData:canAddBlack() then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_BLACK4"))
        return
    end

    if self._isFriend then 
    MessageBoxEx.showYesNoMessage( nil,
     G_lang:get("LANG_FRIEND_BLACK2",{name=self._info.name}), false, 
        function() 
            G_HandlersManager.friendHandler:sendDeleteFriend(self._info.id)
            G_HandlersManager.friendHandler:sendAddBlack(self._info.name)
        end,
        function() end, 
        self )
    else
        MessageBoxEx.showYesNoMessage( nil,
         G_lang:get("LANG_FRIEND_BLACK1",{name=self._info.name}), false, 
            function() 
                -- G_HandlersManager.friendHandler:sendClearFriend(self._info.id)
                G_HandlersManager.friendHandler:sendAddBlack(self._info.name)
            end,
            function() end, 
            self )
    end
    
end

function FriendInfoLayer:_onChat( )
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.CHAT)
        if res then
            self:animationToClose()
            return
        end
    end
    if not self._info then 
        return 
    end
    if self._info.online ~= 0 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_LISILIAO"))
        return
    end
    if G_topLayer then 
        G_topLayer:chatToSomeone({self._info.name, self._info.mainrole})
    end
    self:animationToClose()

    -- uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new(nil, nil, "chat", 2, {self._info.name, self._info.mainrole}))
    -- self:close()
end

function FriendInfoLayer:_onMail( )
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.MAIL)
        if res then
            self:animationToClose()
            return
        end
    end
    
    if not self._info then 
        return 
    end
    local ChatInputPanel = require("app.scenes.friend.FriendMailInputLayer")
    ChatInputPanel.showInputLayer(self, "", 
        self._info.name, 
        self._info.mainrole, function ( text, send )
        if send then 
            G_HandlersManager.friendHandler:sendMail(text,self._info.id)
            -- self:close()
        end
    end)
    -- self:close()
end

function FriendInfoLayer:_onForm( )
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.FORM)
        if res then
            self:animationToClose()
            return
        end
    end
    if not self._info then 
        return 
    end
    G_HandlersManager.arenaHandler:sendCheckUserInfo(self._info.id)
end

function FriendInfoLayer:_onFight( )
    -- if self._info.online ~= 0 then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_PRESENT_LIQIECUO"))
    --     return
    -- end
    if self._callBack then 
        local res = self._callBack(FriendInfoConst.FIGHT)
        if res then
            self:animationToClose()
            return
        end
    end
    if not self._info then 
        return 
    end
    if G_SceneObserver:getSceneName() == "DailyPvpTeamScene" or G_SceneObserver:getSceneName() == "DailyPvpBattleScene" then
        G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_CANNOT_FIGHT"))
        return
    end
    G_HandlersManager.friendHandler:sendKillFriend(self._info.id)
end

function FriendInfoLayer:_onFriendAdd( data)
    if not self._info then 
        return 
    end
    if data.friend_type == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDSUCCESS",{name=self._info.name}))
    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_ADDBLACKSUCCESS",{name=self._info.name}))
    end
    self:animationToClose()
end

function FriendInfoLayer:_onFriendDelete( )
    self:animationToClose()
end

function FriendInfoLayer:_onGetUserInfo(data)
    local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
    uf_notifyLayer:getModelNode():addChild(layer)
    self:animationToClose()
end

function FriendInfoLayer:_onFriendKill( data)
    if data.ret == 1 then 
        if self._runTest then
            if self._fightState then
                if data.battle_report.is_win then
                    self._winCount = self._winCount + 1
                    self._labelWin:setText(self._winCount)
                else
                    self._loseCount = self._loseCount + 1
                    self._labelLose:setText(self._loseCount)
                end
                if self._winCount + self._loseCount >= self._totalTryTime then
                    local rate = self._winCount*100/(self._winCount+self._loseCount)
                    self._labelRate:setText( string.format("%.01f", rate).."%")
                    self._labelRate:setVisible(true)
                    self._labelRate:setScale(10.0)
                    local txtcolor = rate >= 50 and Colors.darkColors.ATTRIBUTE or Colors.darkColors.TIPS_01
                    self._labelRate:setColor(txtcolor)
                    self._labelRate:runAction(CCScaleTo:create(0.3,1))
                end
            end
            return
        end
         local killCallback = self._killCallBack
         local curSceneName = G_SceneObserver:getSceneName()
         local callback = function(result,func)
             local FightEnd = require("app.scenes.common.fightend.FightEnd")
             FightEnd.show(FightEnd.TYPE_FRIEND, data.battle_report.is_win,
                 {

                  },        
                 function() 
                     -- uf_sceneManager:popScene()
                    --  if func then
                    --     func()
                    -- else
                        -- uf_sceneManager:replaceScene(require("app.scenes.friend.FriendMainScene").new())
                        -- local packScene = G_GlobalFunc.createPackScene(self)
                        -- if packScene then 
                        --     uf_sceneManager:replaceScene(packScene)
                        -- else
                        --     GlobalFunc.popSceneWithDefault("app.scenes.friend.FriendMainScene")
                        -- end
                    -- end
                    if curSceneName ~= "FriendMainScene" then
                        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
                    else
                        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.friend.FriendMainScene").new())
                    end
                 end ,result
              )
         end
         local battle 
         local enemyData = 
            {
                id = self._info.mainrole,
                name = self._info.name,
                power = self._info.fighting_capacity
            }
         G_Loading:showLoading(function ( ... )
             --创建战斗场景
             battle = require("app.scenes.tower.TowerBattleScene").new(
                 {  data = data,
                    func = callback,
                    bg = G_Path.getDungeonBattleMap(31001),
                    func2 = killCallback
                 },

                 enemyData
             )
             -- uf_sceneManager:pushScene(battle)
             uf_sceneManager:replaceScene(battle)
         end, 
         function ( ... )
             --开始播放战斗
             battle:play()
         end)
         
     else
         -- MessageBoxEx.showOkMessage("error", G_NetMsgError.getMsg(data.ret))
     end  

     self:animationToClose()
end

function FriendInfoLayer:_onFriendInfo(data)
    if data.ret == 1 then 
        self:updateView(data.friend)
    else
        -- MessageBoxEx.showOkMessage("error", G_NetMsgError.getMsg(data.ret))
    end  
end

function FriendInfoLayer:_onFriendMail(data)
    if data.ret == 1 then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_FRIEND_MAILSEND"))
        self:animationToClose()
    end  
end


function FriendInfoLayer:onLayerUnload( )
    self.super:onLayerUnload()
end

function FriendInfoLayer:onLayerExit( )
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    if self._timer then
        GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

return FriendInfoLayer

