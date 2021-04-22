-- @Author: liaoxianbo
-- @Date:   2019-11-22 14:38:52
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-19 18:02:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCollegeTrainBBS = class("QUIDialogCollegeTrainBBS", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")
local QMaskWords = import("...utils.QMaskWords")

-- local QUIWidgetHandBookBBSCell = import("..widgets.QUIWidgetHandBookBBSCell")

local QUIWidgetCollegeTrainBBSCell = import("..widgets.QUIWidgetCollegeTrainBBSCell")

QUIDialogCollegeTrainBBS.HOT_COMMENT_HEIGHT = 390
QUIDialogCollegeTrainBBS.NORMAL_COMMENT_HEIGHT = 390
QUIDialogCollegeTrainBBS.WIDTH = 690

QUIDialogCollegeTrainBBS.HOT_COMMENT = "HOT_COMMENT"
QUIDialogCollegeTrainBBS.NORMAL_COMMENT = "NORMAL_COMMENT"

function QUIDialogCollegeTrainBBS:ctor(options)
	local ccbFile = "ccb/Dialog_CollegeTrain_PingLun.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerSend", callback = handler(self, self._onTriggerSend)},
        {ccbCallbackName = "onTriggerHotComment", callback = handler(self, self._onTriggerHotComment)},
        {ccbCallbackName = "onTriggerNormalComment", callback = handler(self, self._onTriggerNormalComment)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogCollegeTrainBBS.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	-- cc.GameObject.extend(self)
	-- self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._chapterId = options.chapterId
    print("self._chapterId = ",self._chapterId)
    self._tab = options.tab or QUIDialogCollegeTrainBBS.HOT_COMMENT
    self._commentIndex = 0 -- 评论对应的索引Id  等于0说明需要热评 等于其他就是页数索引
    self._isOpening = true

    q.setButtonEnableShadow(self._ccbOwner.btn_send)

    self:_init()
end

function QUIDialogCollegeTrainBBS:viewDidAppear()
	QUIDialogCollegeTrainBBS.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogCollegeTrainBBS:viewWillDisappear()
  	QUIDialogCollegeTrainBBS.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogCollegeTrainBBS:viewAnimationInHandler()
    QUIDialogCollegeTrainBBS.super.viewAnimationInHandler(self)
    self:_selectTab()
end

function QUIDialogCollegeTrainBBS:_init( )
    self._data = {}
    self._myRankData = {}
    self:_addInputBox()
end

function QUIDialogCollegeTrainBBS:_addInputBox()
    -- if not self._inputMsg then
    --     -- add input box
    --     self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
    --     self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
    --     self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self._onEdit), size = CCSize(542, 44)})
    --     self._inputMsg:setFont(global.font_default, 22)
    --     self._inputMsg:setMaxLength(65)
    --     self._inputMsg:setPlaceHolder("点击输入")
    --     self._inputMsg:setPlaceholderFontColor(COLORS.k) 
    --     self._inputMsg:setFontName(global.font_name)
    --     self._ccbOwner.input:addChild(self._inputMsg)
    -- end

    if not self._inputMsg then
        -- add input box
        self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
        self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
        self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self._onEdit), size = CCSize(self._inputWidth, self._inputHeight)})
        self._inputMsg:setFont(global.font_default, 26)
        self._inputMsg:setMaxLength(65)
        self._inputMsg:setPlaceHolder("点击输入（每天最多评论3条）")
        self._inputMsg:setPlaceholderFontColor(ccc3(200, 200, 200)) 
        self._inputMsg:setFontName(global.font_name)
        self._ccbOwner.input:addChild(self._inputMsg)
    end
end

function QUIDialogCollegeTrainBBS:_onEdit(event, editbox)
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

function QUIDialogCollegeTrainBBS:_initListView()
    self._isOpening = false
    if not self._data or #self._data == 0 then
        self._ccbOwner.node_empty:setVisible(true)
    else
        self._ccbOwner.node_empty:setVisible(false)
    end

    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetCollegeTrainBBSCell.new()
                    isCacheNode = false
                end
                item:setInfo(itemData, index)
                info.item = item
                info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_admire", handler(self, self._clickAdmireHandler))
                list:registerBtnHandler(index, "btn_top", handler(self, self._topHandler), nil, true)
                list:registerBtnHandler(index, "btn_refresh", handler(self, self._refreshHandler), nil, true)
                
                return isCacheNode
            end,
            curOriginOffset = 0,
            spaceX = 10,
            spaceY = 10,
            isVertical = true,
            multiItems = 1,
            enableShadow = false,
            curOffset = 10,
            totalNumber = #self._data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:resetTouchRect()
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogCollegeTrainBBS:_clickAdmireHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    -- QPrintTable(self._data[touchIndex])
    local selectCommentId = self._data[touchIndex].commentId
    local index = self._data[touchIndex].index
    self:_admireHeroByActorId(selectCommentId, index, self._chapterId, touchIndex)
end

function QUIDialogCollegeTrainBBS:_admireHeroByActorId(selectCommentId, index, chapterId, touchIndex)
    -- 点赞
    remote.collegetrain:collegeTrainAdmire(selectCommentId, index, chapterId, self:safeHandler(function(data)
            local item = self._listView:getItemByIndex(touchIndex)
            if item and item.refreshAdmireInfo then
            	local info = {}
            	if data and data.collegeTrainInfoResponse then
            		local commentInfo = data.collegeTrainInfoResponse.commentInfo or {}
            		for _,v in pairs(commentInfo) do
            			if v.index == index then
                            self._data[touchIndex] = v
            				break
            			end
            		end
            	end
                item:refreshAdmireInfo(self._data[touchIndex])
            end
        end))
end

function QUIDialogCollegeTrainBBS:_topHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")

    if self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT then
    	self._commentIndex = 1
	    remote.collegetrain:getCollegeTrainCommentInfo(self._chapterId,self._commentIndex,function( data)
	    	if self:safeCheck() then
	        	if data and data.collegeTrainInfoResponse then
	        		self._data = data.collegeTrainInfoResponse.commentInfo or {}
	        	end
		        self:_addListViewBtnData()
		        self:_initListView()
		    end
	    end)
   	end
end

function QUIDialogCollegeTrainBBS:_gotoTop()
    if self._listView and self._listView.startScrollToIndex then
        self._listView:startScrollToIndex(1, false, 100)
    end
end

function QUIDialogCollegeTrainBBS:_refreshHandler( x, y, touchNode, listView )
    app.sound:playSound("common_others")
    if self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT then
    	self._commentIndex = self._commentIndex+1
	    remote.collegetrain:getCollegeTrainCommentInfo(self._chapterId,self._commentIndex,function( data)
	    	if self:safeCheck() then
	        	if data and data.collegeTrainInfoResponse then
	        		self._data = data.collegeTrainInfoResponse.commentInfo or {}
	        	end
		        self:_addListViewBtnData()
		        self:_initListView()
		    end
	    end)
   	end
end

function QUIDialogCollegeTrainBBS:_selectTab(  )
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

    if self._tab == QUIDialogCollegeTrainBBS.HOT_COMMENT then
        self._commentIndex = 0
        remote.collegetrain:getCollegeTrainCommentInfo(self._chapterId,self._commentIndex,function( data)
        	if self:safeCheck() then
	        	if data and data.collegeTrainInfoResponse then
	        		self._data = data.collegeTrainInfoResponse.commentInfo or {}
	        	end
		        if not self._data or #self._data == 0 and self._isOpening then
		            self:_onTriggerNormalComment()
		        else
		            self:_initListView()
		        end
	        end
        end)
    elseif self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT then
    	self._commentIndex = 1
        remote.collegetrain:getCollegeTrainCommentInfo(self._chapterId,self._commentIndex,function( data)
        	if self:safeCheck() then
	        	if data and data.collegeTrainInfoResponse then
	        		self._data = data.collegeTrainInfoResponse.commentInfo or {}
	        	end
		        self:_addListViewBtnData()
		        self:_initListView()
		    end
        end)    	
        

    end

end

function QUIDialogCollegeTrainBBS:_addListViewBtnData()
    if self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT and self._data and #self._data > 0 then
        table.insert(self._data, {isBtnView = true})
    end
end

function QUIDialogCollegeTrainBBS:_updateUIView()
    print("self._tab = ", self._tab)
    if self._tab == QUIDialogCollegeTrainBBS.HOT_COMMENT then

        self._ccbOwner.node_input:setVisible(true)
        self._inputMsg:setEnabled(true)
        self._inputMsg:setVisible(true)
        self._ccbOwner.tf_tips:setString("目前还没有上榜热评，快去发表评论吧！")
    elseif self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT then
        self._ccbOwner.node_input:setVisible(true)
        self._inputMsg:setEnabled(true)
        self._inputMsg:setVisible(true)
        self._ccbOwner.tf_tips:setString("目前还没有任何评论，快来发表评论吧！")
    end

    self._ccbOwner.node_myRank:removeAllChildren()
end

function QUIDialogCollegeTrainBBS:_setButtonState()
    local isHotComment = self._tab == QUIDialogCollegeTrainBBS.HOT_COMMENT
    local isNormalComment = self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT

    self._ccbOwner.btn_hotComment:setHighlighted(isHotComment)
    self._ccbOwner.btn_hotComment:setEnabled(not isHotComment)

    self._ccbOwner.btn_normalComment:setHighlighted(isNormalComment)
    self._ccbOwner.btn_normalComment:setEnabled(not isNormalComment)

end


function QUIDialogCollegeTrainBBS:_onTriggerSend()
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
  
    remote.collegetrain:collegeTrainComment(self._chapterId, msg, function(data)
	    	if self:safeCheck() then
	            self._inputMsg:setText("")
	            self._inputMsg:setPlaceHolder("")

	            -- self._data = remote.handBook:getCommentInfoArrByActorIDAndIndex(self._actorId, self._commentIndex)
	            if data.collegeTrainInfoResponse then
	            	self._data = data.collegeTrainInfoResponse.commentInfo or {}
	           	end
	            if self._tab == QUIDialogCollegeTrainBBS.HOT_COMMENT then
	                self:_onTriggerNormalComment()
	            else
	                self:_addListViewBtnData()
	                self:_initListView()
	            end
	        end   
        end)
end

function QUIDialogCollegeTrainBBS:_onTriggerHotComment()
    app.sound:playSound("common_small")
    if self._tab == QUIDialogCollegeTrainBBS.HOT_COMMENT then return end
    self._tab = QUIDialogCollegeTrainBBS.HOT_COMMENT

    self:_selectTab()
end

function QUIDialogCollegeTrainBBS:_onTriggerNormalComment(e)
    if e then
        app.sound:playSound("common_small")
    end
    if self._tab == QUIDialogCollegeTrainBBS.NORMAL_COMMENT then return end
    self._tab = QUIDialogCollegeTrainBBS.NORMAL_COMMENT

    self:_selectTab()
end

function QUIDialogCollegeTrainBBS:_onTriggerRank()
    app.sound:playSound("common_small")
    if self._tab == QUIDialogCollegeTrainBBS.RANK then return end
    self._tab = QUIDialogCollegeTrainBBS.RANK

    self:_selectTab()
end

function QUIDialogCollegeTrainBBS:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCollegeTrainBBS:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCollegeTrainBBS
