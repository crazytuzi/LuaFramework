--[[
 --
 -- add by vicky
 -- 2015.01.04 
 --
 --]] 

 require("game.guild.utility.GuildBottomBtnEvent")
 


local GuildBaseScene = class("GuildBaseScene", function()
    return display.newScene("GuildBaseScene")
end)

--contentCCBFile:中间内容的ccb文件
--广播下面的ccbi文件，如果没有为空


function GuildBaseScene:ctor(param) 
    -- local unTouchLayer = display.newColorLayer(ccc4(55,55,55,100))
    -- unTouchLayer:setTouchEnabled(true)
    -- self:addChild(unTouchLayer,1000000)

    --顶部框和底部框固定
    local BOTTOM_HEIGHT = 110 
    local TOP_HEIGHT    = 72 

    -- 是否显示帮派主界面 
    local _isOther = false 
    if param.isOther ~= nil then 
        _isOther = param.isOther 
    end 

    if _isOther == true then 
        TOP_HEIGHT = 152 
    end 


    local CENTER_HEIGHT = display.height - BOTTOM_HEIGHT - TOP_HEIGHT
    self.centerHeight = CENTER_HEIGHT

    self.getTopHeight = function(_)
        return TOP_HEIGHT
    end

    self.getBottomHeight = function(_)
        return BOTTOM_HEIGHT
    end

    self.getCenterHeight = function(_)
        return CENTER_HEIGHT
    end

    local _contentFile = param.contentFile
    local _subTopFile  = param.subTopFile
    local _bottomFile  = param.bottomFile
    local _bgImagePath = param.bgImage
    local _imageFromBottom = param.imageFromBottom
    local _adjustSize = param.adjustSize or CCSizeMake(0, 0)
    local _topFile = param.topFile 
    local _scaleMode = param.scaleMode or 0 

    -- 是否隐藏底部按钮 
    local _isHideBottom = false 
    if param.isHideBottom ~= nil then 
        _isHideBottom = param.isHideBottom 
    end 


    if _isHideBottom then 
        CENTER_HEIGHT = CENTER_HEIGHT + BOTTOM_HEIGHT 
        BOTTOM_HEIGHT = 0 
    end 

    game.runningScene = self

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("guild/guild_window_scene", proxy, self._rootnode)
    node:setContentSize(CCSizeMake(display.width, display.height))
    node:setPosition(display.cx, display.cy)
    self:addChild(node, 3) 

    -- 上部条 
    if _topFile then
        self._rootnode["topNode"]:removeSelf()

        local bottomNode = CCBuilderReaderLoad(_topFile, proxy, self._rootnode)
        bottomNode:setPosition(display.cx, display.height)
        self:addChild(bottomNode, 2)
    end

--  上部偏下的条
    local subTopNode
    if _subTopFile then
        subTopNode = CCBuilderReaderLoad(_subTopFile, proxy, self._rootnode)
        subTopNode:setPosition(display.cx, display.height - TOP_HEIGHT)
        self:addChild(subTopNode, 2)
    end

--  内容框
    local h = CENTER_HEIGHT
    if _contentFile then
        if subTopNode then
            h = h - subTopNode:getContentSize().height
        end
        local contentNode
        contentNode = CCBuilderReaderLoad(_contentFile, proxy, self._rootnode, self, CCSizeMake(display.width + _adjustSize.width, h + _adjustSize.height))
        self:addChild(contentNode, 1)
        contentNode:setPosition(display.width / 2, BOTTOM_HEIGHT)
    end

--  背景
    if _bgImagePath then

        local bg = display.newScale9Sprite(_bgImagePath)
        if _scaleMode == 0 then
            bg:setAnchorPoint(0.5, 0)
            if _imageFromBottom then
                local topH = 0
                if subTopNode then
                    topH = subTopNode:getContentSize().height
                end
                bg:setContentSize(CCSizeMake(display.width, display.height - TOP_HEIGHT - topH))
                bg:setPosition(display.width / 2, 0)
            else
                bg:setContentSize(CCSizeMake(display.width, h))
                bg:setPosition(display.width / 2, BOTTOM_HEIGHT)
            end

        else
            if display.width / bg:getContentSize().width > h / bg:getContentSize().height then
                bg:setScale(display.width / bg:getContentSize().width)
            else
                bg:setScale(h / bg:getContentSize().height)
            end 

            bg:setPosition(display.width / 2, BOTTOM_HEIGHT + h / 2)
        end

        if string.find(_bgImagePath, "common_bg.png") then

            local hw = display.newSprite("ui_common/common_huawen.png")
            hw:setPosition(display.width * 0.514, bg:getContentSize().height)
            hw:setAnchorPoint(ccp(0.5, 1))
            bg:addChild(hw)

            local bg2 = display.newScale9Sprite("ui_common/common_bg2.png")
            bg2:setContentSize(CCSizeMake(display.width + 40, bg:getContentSize().height + 12))
            bg2:setPosition(display.width / 2, bg:getContentSize().height / 2)
            bg:addChild(bg2)
        end
        self:addChild(bg, 0)
    end

--  是否替换下部的按钮
    if not _isHideBottom then 
        if _bottomFile then
            self._rootnode["bottomNode"]:removeSelf()

            local bottomNode = CCBuilderReaderLoad(_bottomFile, proxy, self._rootnode)
            bottomNode:setPosition(display.cx, 0)

            self:addChild(bottomNode, 2)
        else
    --      注册底部按钮事件
            printf("注册底部按钮事件")
        end
        GuildBottomBtnEvent.registerBottomEvent(self._rootnode)
    else
        self._rootnode["bottomNode"]:removeSelf() 
    end 

    self._rootnode["zhandouliLabel"]:setString(tostring(game.player:getBattlePoint()))

    if _isOther == false then 
        self._rootnode["goldLabel"]:setString(tostring(game.player:getGold()))
        self._rootnode["silverLabel"]:setString(tostring(game.player:getSilver()))
    end 

    if self._rootnode["chat_btn"] ~= nil then 
        if game.player:getAppOpenData().b_liaotian == APPOPEN_STATE.close then 
            self._rootnode["chat_btn"]:setVisible(false) 
        else
            self._rootnode["chat_btn"]:setVisible(true)  
        end  
    end 

    self.getCenterHeightWithSubTop = function()
        return h
    end

    -- 广播
    local broadcastBg = self._rootnode["broadcast_tag"]
    if broadcastBg ~= nil then
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

    if self._rootnode["nowTimeLabel"] then
        self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
        self._rootnode["nowTimeLabel"]:schedule(function()
            self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
        end, 60)
    end

    self:checkApplyNum() 

end


function GuildBaseScene:checkApplyNum()
    local notice = self._rootnode["apply_notice"] 
    if notice ~= nil then 
        if game.player:getGuildApplyNum() > 0 then 
            notice:setVisible(true) 
        else
            notice:setVisible(false)  
        end 
    end 
end 


function GuildBaseScene:regNotice() 
    RegNotice(self,
        function()
            local goldLbl = self._rootnode["goldLabel"]
            if goldLbl ~= nil and checkint(goldLbl:getString()) ~= game.player:getGold() then 
                goldLbl:runAction(transition.sequence({
                    CCScaleTo:create(0.2, 2),
                    CCCallFunc:create(function()
                        goldLbl:setString(tostring(game.player:getGold()))
                    end),
                    CCScaleTo:create(0.1, 1)
                }))
            end
        end,
        NoticeKey.CommonUpdate_Label_Gold)

    RegNotice(self,
        function()
            local silverLbl = self._rootnode["silverLabel"] 
            if silverLbl ~= nil and checkint(silverLbl:getString()) ~= game.player:getSilver() then 
                silverLbl:runAction(transition.sequence({
                    CCScaleTo:create(0.2, 1.1),
                    CCCallFunc:create(function()
                        silverLbl:setString(tostring(game.player:getSilver()))
                    end),
                    CCScaleTo:create(0.1, 1)
                }))
            end 
        end,
        NoticeKey.CommonUpdate_Label_Silver)

    RegNotice(self,
        function()
            local tiliLbl = self._rootnode["tili_Label"] 
            if tiliLbl ~= nil and checkint(tiliLbl:getString()) ~= game.player:getStrength() then 
                tiliLbl:runAction(transition.sequence({
                    CCScaleTo:create(0.2, 1.1),
                    CCCallFunc:create(function()
                        tiliLbl:setString(tostring(game.player:getStrength()))
                    end),
                    CCScaleTo:create(0.1, 1)
                }))
            end 
        end,
        NoticeKey.CommonUpdate_Label_Tili)

    RegNotice(self,
        function()
            local nailiLbl = self._rootnode["naili_Label"] 
            if nailiLbl ~= nil and checkint(nailiLbl:getString()) ~= game.player:getNaili() then 
                nailiLbl:runAction(transition.sequence({
                    CCScaleTo:create(0.2, 1.1),
                    CCCallFunc:create(function()
                        nailiLbl:setString(tostring(game.player:getNaili()))
                    end),
                    CCScaleTo:create(0.1, 1)
                }))
            end 
        end,
        NoticeKey.CommonUpdate_Label_Naili)


    RegNotice(self,
        function()
            self:setBottomBtnEnabled(false)
        end, 
        NoticeKey.LOCK_BOTTOM)

    RegNotice(self,
        function()
            self:setBottomBtnEnabled(true)
            printf("post UNLOCK_BOTTOM")
        end, 
        NoticeKey.UNLOCK_BOTTOM) 

    RegNotice(self, handler(self, GuildBaseScene.checkApplyNum), NoticeKey.CHECK_GUILD_APPLY_NUM) 

end


function GuildBaseScene:unregNotice() 
    UnRegNotice(self, NoticeKey.CommonUpdate_Label_Silver)
    UnRegNotice(self, NoticeKey.CommonUpdate_Label_Gold)

    UnRegNotice(self, NoticeKey.CommonUpdate_Label_Tili)
    UnRegNotice(self, NoticeKey.CommonUpdate_Label_Naili)

    UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
    UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM) 
    UnRegNotice(self, NoticeKey.CHECK_GUILD_APPLY_NUM) 
end


function GuildBaseScene:setBottomBtnEnabled(bEnabled) 
    GuildBottomBtnEvent.setTouchEnabled(bEnabled) 
end



return GuildBaseScene

