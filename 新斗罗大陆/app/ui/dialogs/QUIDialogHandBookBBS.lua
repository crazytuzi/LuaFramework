--
-- Kumo
-- 图鉴BBS
--

local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogHandBookBBS = class("QUIDialogHandBookBBS", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QMaskWords = import("...utils.QMaskWords")

local QUIWidgetHandBookBBSCell = import("..widgets.QUIWidgetHandBookBBSCell")
local QUIWidgetHandBookRankCell = import("..widgets.QUIWidgetHandBookRankCell")
local QUIWidgetHandBookRankMyRank = import("..widgets.QUIWidgetHandBookRankMyRank")


-- QUIDialogHandBookBBS.HOT_COMMENT_HEIGHT = 473
QUIDialogHandBookBBS.HOT_COMMENT_HEIGHT = 390
QUIDialogHandBookBBS.NORMAL_COMMENT_HEIGHT = 390
QUIDialogHandBookBBS.RANK_HEIGHT = 340
QUIDialogHandBookBBS.WIDTH = 690

QUIDialogHandBookBBS.HOT_COMMENT = "HOT_COMMENT"
QUIDialogHandBookBBS.NORMAL_COMMENT = "NORMAL_COMMENT"
QUIDialogHandBookBBS.RANK = "RANK"

function QUIDialogHandBookBBS:ctor(options)
    local ccbFile = "ccb/Dialog_HandBook_FloatBBS.ccbi"
    local callBack = {
        {ccbCallbackName = "onTriggerSend", callback = handler(self, self._onTriggerSend)},
        {ccbCallbackName = "onTriggerHotComment", callback = handler(self, self._onTriggerHotComment)},
        {ccbCallbackName = "onTriggerNormalComment", callback = handler(self, self._onTriggerNormalComment)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogHandBookBBS.super.ctor(self, ccbFile, callBack, options)

    self._actorId = options.actorId
    self._tab = options.tab or QUIDialogHandBookBBS.HOT_COMMENT
    self._commentIndex = 0 -- 评论对应的索引Id  等于0说明需要热评 等于其他就是页数索引
    self._isOpening = true

    q.setButtonEnableShadow(self._ccbOwner.btn_send)

    self:_init()
end

function QUIDialogHandBookBBS:_onBackTriggered()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogHandBookBBS:viewDidAppear()
    QUIDialogHandBookBBS.super.viewDidAppear(self)
end

function QUIDialogHandBookBBS:viewWillDisappear()
    QUIDialogHandBookBBS.super.viewWillDisappear(self)
end

function QUIDialogHandBookBBS:viewAnimationInHandler()
    QUIDialogHandBookBBS.super.viewAnimationInHandler(self)
    self:_selectTab()
end

function QUIDialogHandBookBBS:_init()
    self._data = {}
    self._myRankData = {}
    self:_addInputBox()
end

function QUIDialogHandBookBBS:_selectTab()
    self:getOptions().tab = self._tab
    self._data = {}
    self._myRankData = {}

    self:_updateUIView()
    self:_setButtonState()
    if self._listView then
        self._listView:clear()
        self._listView:unscheduleUpdate()
        self._listView = nil
    end

    if self._tab == QUIDialogHandBookBBS.HOT_COMMENT then
        self._commentIndex = 0
        remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
                self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
                -- QPrintTable(self._data)
                if not self._data or #self._data == 0 and self._isOpening then
                    self:_onTriggerNormalComment()
                else
                    self:_initListView()
                end
            end))
    elseif self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then
        self._commentIndex = 1
        remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
                self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
                self:_addListViewBtnData()
                -- QPrintTable(self._data)
                self:_initListView()
            end))
    elseif self._tab == QUIDialogHandBookBBS.RANK then
        remote.handBook:requestHandBookRank("HAND_BOOK_HERO_FORCE", remote.user.userId, self._actorId, self:safeHandler(function(data)
                self._data = data.rankings.top50 or {}
                self._myRankData = data.rankings.myself
                self:_initListView()
                self:_initMyRankInfo()
            end))
    end
end

function QUIDialogHandBookBBS:_addListViewBtnData()
    if self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT and self._data and #self._data > 0 then
        table.insert(self._data, {isBtnView = true})
    end
end

function QUIDialogHandBookBBS:_updateUIView()
    print("self._tab = ", self._tab)
    if self._tab == QUIDialogHandBookBBS.HOT_COMMENT then
        self._ccbOwner.s9s_bg:setPreferredSize(CCSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.HOT_COMMENT_HEIGHT + 6))
        self._ccbOwner.sheet_layout:setContentSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.HOT_COMMENT_HEIGHT)
        self._ccbOwner.node_input:setVisible(true)
        self._inputMsg:setEnabled(true)
        self._inputMsg:setVisible(true)
        self._ccbOwner.tf_tips:setString("目前还没有上榜热评，快去发表评论吧！")
    elseif self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then
        self._ccbOwner.s9s_bg:setPreferredSize(CCSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.NORMAL_COMMENT_HEIGHT + 6))
        self._ccbOwner.sheet_layout:setContentSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.NORMAL_COMMENT_HEIGHT)
        self._ccbOwner.node_input:setVisible(true)
        self._inputMsg:setEnabled(true)
        self._inputMsg:setVisible(true)
        self._ccbOwner.tf_tips:setString("目前还没有任何评论，快来发表评论吧！")
    elseif self._tab == QUIDialogHandBookBBS.RANK then
        self._ccbOwner.s9s_bg:setPreferredSize(CCSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.RANK_HEIGHT + 6))
        self._ccbOwner.sheet_layout:setContentSize(QUIDialogHandBookBBS.WIDTH, QUIDialogHandBookBBS.RANK_HEIGHT)
        self._ccbOwner.node_input:setVisible(false)
        self._inputMsg:setEnabled(false)
        self._inputMsg:setVisible(false)
        self._ccbOwner.tf_tips:setString("目前还没有任何排行信息")
    end
    self._ccbOwner.btn_buttom:setPositionY(self._ccbOwner.s9s_bg:getPositionY() - self._ccbOwner.s9s_bg:getContentSize().height)
    self._ccbOwner.node_myRank:removeAllChildren()
end

function QUIDialogHandBookBBS:_addInputBox()
    if not self._inputMsg then
        -- add input box
        self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
        self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
        self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self._onEdit), size = CCSize(self._inputWidth, self._inputHeight)})
        self._inputMsg:setFont(global.font_default, 26)
        self._inputMsg:setMaxLength(65)
        self._inputMsg:setPlaceHolder("点击输入（每天最多评论3条）")
        self._inputMsg:setPlaceholderFontColor(UNITY_COLOR.brown) 
        self._inputMsg:setFontName(global.font_name)
        self._ccbOwner.input:addChild(self._inputMsg)
    end
end

function QUIDialogHandBookBBS:_onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "ended" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "return" then
        -- 从输入框返回
    elseif event == "returnDone" then
        if device.platform == "ios" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    end
end

function QUIDialogHandBookBBS:_initListView()
    self._isOpening = false

    if not self._data or #self._data == 0 then
        self._ccbOwner.node_empty:setVisible(true)
    else
        self._ccbOwner.node_empty:setVisible(false)
    end
    local _scrollEndCallBack
    local _scrollBeginCallBack
    -- if self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then
    --     _scrollEndCallBack = function ( )
    --         self._commentIndex = self._commentIndex + 1
    --         remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
    --                 self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
    --                 self:_addListViewBtnData()
    --                 self:_initListView()
    --             end))
    --     end

    --     _scrollBeginCallBack = function ( ... )
    --         if self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT and self._commentIndex > 1 then
    --             self._commentIndex = self._commentIndex - 1
    --             if self._commentIndex < 1 then
    --                 self._commentIndex = 1
    --             end
    --             remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
    --                     self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
    --                     self:_addListViewBtnData()
    --                     self:_initListView()
    --                 end))
    --         end
    --     end
    -- end

    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()
                if not item then
                    if self._tab == QUIDialogHandBookBBS.RANK then
                        item = QUIWidgetHandBookRankCell.new()
                    else
                        item = QUIWidgetHandBookBBSCell.new()
                    end
                    isCacheNode = false
                end
                item:setInfo(itemData, index)
                info.item = item
                info.size = item:getContentSize()

                if self._tab == QUIDialogHandBookBBS.RANK then
                    list:registerBtnHandler(index, "btn_click", handler(self, self._clickRankHandler))
                else
                    list:registerBtnHandler(index, "btn_admire", handler(self, self._clickAdmireHandler))
                    list:registerBtnHandler(index, "btn_top", handler(self, self._topHandler), nil, true)
                    list:registerBtnHandler(index, "btn_refresh", handler(self, self._refreshHandler), nil, true)
                end
                
                return isCacheNode
            end,
            curOriginOffset = 0,
            spaceX = 10,
            spaceY = 2,
            isVertical = true,
            multiItems = 1,
            enableShadow = false,
            curOffset = 10,
            -- scrollEndCallBack = _scrollEndCallBack,
            -- scrollBeginCallBack = _scrollBeginCallBack,
            totalNumber = #self._data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:resetTouchRect()
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogHandBookBBS:_clickAdmireHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    -- QPrintTable(self._data[touchIndex])
    local selectActorId = self._data[touchIndex].actor_id
    local selectCommentId = self._data[touchIndex].comment_id
    local index = self._data[touchIndex].index
    self:_admireHeroByActorId(selectCommentId, index, selectActorId, touchIndex)
end

function QUIDialogHandBookBBS:_admireHeroByActorId(selectCommentId, index, selectActorId, touchIndex)
    -- 点赞
    remote.handBook:handBookAdmireRequest(selectCommentId, index, selectActorId, self:safeHandler(function(data)
            local item = self._listView:getItemByIndex(touchIndex)
            if item and item.refreshAdmireInfo then
                item:refreshAdmireInfo()
            end
        end))
end

function QUIDialogHandBookBBS:_topHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    -- local touchIndex = listView:getCurTouchIndex()
    -- self:_gotoTop()
    -- print(" _topHandler ", remote.handBook.isCommentRefreshing, self._commentIndex)
    if not remote.handBook.isCommentRefreshing and self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then
        self._commentIndex = 1
        remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
                self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
                self:_addListViewBtnData()
                self:_initListView()
            end))
    end
end

function QUIDialogHandBookBBS:_gotoTop()
    if self._listView and self._listView.startScrollToIndex then
        self._listView:startScrollToIndex(1, false, 100)
    end
end

function QUIDialogHandBookBBS:_refreshHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    -- local touchIndex = listView:getCurTouchIndex()
    -- print(" _refreshHandler ", remote.handBook.isCommentRefreshing, self._commentIndex)
    if not remote.handBook.isCommentRefreshing and self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then
        self._commentIndex = self._commentIndex + 1
        remote.handBook:handBookGetCommentRequest(self._actorId, self._commentIndex, self:safeHandler(function(data)
                self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
                self:_addListViewBtnData()
                self:_initListView()
            end))
    end
end

function QUIDialogHandBookBBS:_clickRankHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")

    local touchIndex = listView:getCurTouchIndex()
    local userData = self._data[touchIndex] or {}
    remote.handBook:requestHandBookRankHeroInfo(userData.userId, self._actorId, function(data)
        local heroInfo = data.handBookGetTargetUserHeroInfoResponse.targetHero
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroInfo", 
            options = {hero = {heroInfo.actorId}, pos = 1, fighter = {level = (userData.level or 1), ["heros"] = {heroInfo}} } })
    end)
end

function QUIDialogHandBookBBS:_initMyRankInfo()
    if self._tab ~= QUIDialogHandBookBBS.RANK then return end
    if not self._myRankData or not next(self._myRankData) then return end
    local widget = QUIWidgetHandBookRankMyRank.new()
    widget:setInfo(self._myRankData)
    self._ccbOwner.node_myRank:addChild(widget)
    self._ccbOwner.node_myRank:setVisible(true)
end

function QUIDialogHandBookBBS:_setButtonState()
    local isHotComment = self._tab == QUIDialogHandBookBBS.HOT_COMMENT
    local isNormalComment = self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT
    local isRank = self._tab == QUIDialogHandBookBBS.RANK

    self._ccbOwner.btn_hotComment:setHighlighted(isHotComment)
    self._ccbOwner.btn_hotComment:setEnabled(not isHotComment)

    self._ccbOwner.btn_normalComment:setHighlighted(isNormalComment)
    self._ccbOwner.btn_normalComment:setEnabled(not isNormalComment)

    self._ccbOwner.btn_rank:setHighlighted(isRank)
    self._ccbOwner.btn_rank:setEnabled(not isRank)
end

function QUIDialogHandBookBBS:_onTriggerSend()
    app.sound:playSound("common_small")
    local msg = self._inputMsg:getText()
    print(msg, string.len(msg))

    if msg == nil or msg == "" then
        app.tip:floatTip("不能发送空的评论")
        return
    end
    if string.len(msg) > 150 then
        app.tip:floatTip("发送评论内容过长")
        return
    end

    if QMaskWords:isFind(msg) then
        app.tip:floatTip("发送评论中包含敏感字符")
        return
    end

    local serverChatData = app:getServerChatData() -- app:getXMPPData() 
    if not serverChatData:messageValid(msg, CHANNEL_TYPE.GLOBAL_CHANNEL) then
        app.tip:floatTip("发送评论中包含非法字符")
        return
    end
    
    if (remote.user.handBookCommentCount or 0) >= 3 then
        app.tip:floatTip("发送评论次数已达今日上限")
        return
    end

    remote.handBook:handBookDoCommentRequest(self._actorId, msg, function()
            self._inputMsg:setText("")
            self._inputMsg:setPlaceHolder("")
            self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
            
            if self._tab == QUIDialogHandBookBBS.HOT_COMMENT then
                self:_onTriggerNormalComment()
            else
                self:_addListViewBtnData()
                self:_initListView()
            end
        end)
end

function QUIDialogHandBookBBS:_onTriggerHotComment()
    app.sound:playSound("common_small")
    if self._tab == QUIDialogHandBookBBS.HOT_COMMENT then return end
    self._tab = QUIDialogHandBookBBS.HOT_COMMENT

    self:_selectTab()
end

function QUIDialogHandBookBBS:_onTriggerNormalComment(e)
    if e then
        app.sound:playSound("common_small")
    end
    if self._tab == QUIDialogHandBookBBS.NORMAL_COMMENT then return end
    self._tab = QUIDialogHandBookBBS.NORMAL_COMMENT

    self:_selectTab()
end

function QUIDialogHandBookBBS:_onTriggerRank()
    app.sound:playSound("common_small")
    if self._tab == QUIDialogHandBookBBS.RANK then return end
    self._tab = QUIDialogHandBookBBS.RANK

    self:_selectTab()
end

function QUIDialogHandBookBBS:_onTriggerClose(e)
    if e then
        app.sound:playSound("common_small")
    end
    self:playEffectOut()
end

function QUIDialogHandBookBBS:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHandBookBBS:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogHandBookBBS