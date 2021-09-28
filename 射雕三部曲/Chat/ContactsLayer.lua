--[[
    文件名: ContactsLayer.lua
    描述: 聊天联系人页面
    创建人: liaoyuangang
    创建时间: 2017.6.12
-- ]]

local ContactsLayer = class("ContactsLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

-- 联系人页面页签枚举
local ContactsTag = {
	eFriend = ModuleSub.eFriend,  -- 好友列表
	eApply = ModuleSub.eEmailFriend, -- 好友申请列表
	eBlackList = Enums.ChatChanne.eBlackList, -- 黑名单列表
}

--[[
-- 参数 params中的各项为
    {
        forbidCleanUp = false, -- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
        selectCb = nil, -- 选中玩家的回调函数,参数为: (layerObj, selectPlayerId)
    }
]]
function ContactsLayer:ctor(params)
    params = params or {}
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
    self.mForbidCleanUp = params.forbidCleanUp
    -- 
    self.selectCb = params.selectCb

	-- 当前显示的tag
	self.mSelectTag = ContactsTag.eFriend

	-- 好友列表信息
	self.mFriendList = FriendObj:getFriendList() or {}
	-- 好友申请列表信息
	self.mApplyList = {}
	-- 黑名单列表信息
	self.mBlackList = EnemyObj:getEnemyList() or {}

    -- 背景图片的大小
    self.mBgSize = cc.size(635, 910)
    -- 列表的大小
    self.mListViewSize = cc.size(self.mBgSize.width - 50, self.mBgSize.height - 170)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    -- 初始化控件
    self:initUI()

    if self.mSelectTag == ContactsTag.eFriend then
        FriendObj:requestGetFriendList()
    elseif self.mSelectTag == ContactsTag.eApply then
        -- 获取好友申请数据
        self:requestGetFriendMessageByPage()
    end
    -- 刷新列表
    self:refreshListView()
end

-- 初始化页面控件
function ContactsLayer:initUI()
    -- 创建界面背景
    self.mBgSprite = ui.newScale9Sprite("mrjl_02.png", self.mBgSize)
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)
    -- title
    local bgSize = self.mBgSprite:getContentSize()
    local titleLabel = ui.newLabel({
        text = TR("联系人"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
    })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(bgSize.width*0.5, bgSize.height - 36)
    self.mBgSprite:addChild(titleLabel)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mCloseBtn:setPosition(self.mBgSize.width - 38, self.mBgSize.height - 35)
    self.mBgSprite:addChild(self.mCloseBtn)

    -- 列表空时的提示
    self.mEmptyHintNode, self.mHintLabel = ui.createEmptyHint(TR("没有信息"))
    self.mEmptyHintNode:setPosition(self.mBgSize.width / 2, self.mListViewSize.height / 2 + 10)
    self.mBgSprite:addChild(self.mEmptyHintNode, 10)

    -- 创建列表控件
    self:createListView()
    -- 创建tab切换控件
    self:createTabView()
end

-- 创建列表控件
function ContactsLayer:createListView()
    -- 列表背景
    local bgSize = cc.size(self.mListViewSize.width, self.mListViewSize.height+10)
    local listBg = ui.newScale9Sprite("c_17.png", bgSize)
    listBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.445)
    self.mBgSprite:addChild(listBg)
	-- 创建显示好友的listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setContentSize(self.mListViewSize)
    self.mListView:setBounceEnabled(true)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mBgSize.width / 2, 35)
    self.mBgSprite:addChild(self.mListView)

    Notification:registerAutoObserver(self.mListView, function()
        self.mFriendList = FriendObj:getFriendList()
        self:refreshListView()
    end, {EventsName.eFriendChanged})
end

-- 创建tab切换控件
function ContactsLayer:createTabView()
    -- 切换页签信息
	local tabBtnInfos = {
	    {
	        text = TR("好友列表"),
	        tag = ContactsTag.eFriend,
            fontSize = 24,
	    },
	    {
	        text = TR("好友申请"),
	        tag = ContactsTag.eApply,
            fontSize = 24,
	    },
	    {
	        text = TR("黑名单"),
	        tag = ContactsTag.eBlackList,
            fontSize = 24,
	    },
	}

    local tabView = ui.newTabLayer({
        btnInfos = tabBtnInfos,
        needLine = true,
        viewSize = cc.size(590, 80),
        space = 10,
        normalImage = "c_51.png",
        lightedImage = "c_50.png",
        normalTextColor = Enums.Color.eWhite,
        defaultSelectTag = self.mSelectTag,
        onSelectChange = function(selectBtnTag)
            if self.mSelectTag == selectBtnTag then
                return 
            end

            self.mSelectTag = selectBtnTag

            -- 
            if self.mSelectTag == ContactsTag.eFriend then
                FriendObj:requestGetFriendList()
            elseif self.mSelectTag == ContactsTag.eApply then
                -- 获取好友申请数据
                self:requestGetFriendMessageByPage()
            end

            -- 刷新列表
            self:refreshListView()
        end,
    })
    tabView:setAnchorPoint(cc.p(0.5, 0))
    tabView:setPosition(self.mBgSize.width / 2, self.mBgSize.height - 130)
    self.mBgSprite:addChild(tabView) 

    -- 添加小红点
    for tag, btnObj in pairs(tabView:getTabBtns()) do
        if tag == ContactsTag.eApply then
            local tempSize = btnObj:getContentSize()
            -- 
            local redDotSprite = ui.createBubble({})
            redDotSprite:setPosition(tempSize.width * 0.8, tempSize.height * 0.8)
            redDotSprite:setVisible(RedDotInfoObj:isValid(ContactsTag.eApply))
            btnObj:addChild(redDotSprite)

            -- 
            local eventsName = {EventsName.eRedDotPrefix .. tostring(ContactsTag.eApply)}
            Notification:registerAutoObserver(redDotSprite, function()
                local redDotData = RedDotInfoObj:isValid(ContactsTag.eApply)
                redDotSprite:setVisible(redDotData)
            end, eventsName)
        end
    end
end

-- 刷新列表信息
function ContactsLayer:refreshListView()
	self.mListView:removeAllItems()

    local isEmpty = true
    local hintText = TR("没有信息")
	if self.mSelectTag == ContactsTag.eFriend then
		for index, item in ipairs(self.mFriendList) do
            isEmpty = false
			self:refreshOneFriendItem(index)
		end
        hintText = TR("没有好友信息")
	elseif self.mSelectTag == ContactsTag.eApply then
		for index, item in ipairs(self.mApplyList) do
            isEmpty = false
			self:refreshOneApplyItem(index)
		end
        hintText = TR("暂时没有收到好友申请")
	elseif self.mSelectTag == ContactsTag.eBlackList then
		for index, item in ipairs(self.mBlackList) do
            isEmpty = false
			self:refreshOneBlackItem(index)
		end
        hintText = TR("没有黑名单信息")
	end

    self.mHintLabel:setString(hintText)
    self.mEmptyHintNode:setVisible(isEmpty)
end

-- 刷新一条好友信息
function ContactsLayer:refreshOneFriendItem(index)
	local cellData = self.mFriendList[index] 
	if not cellData then
		return 
	end

	-- 列表条目的大小
	local cellSize = cc.size(self.mListViewSize.width, 130)
	-- 获取或创建列表条目父对象
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 列表条目背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 头像
    local headCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
            if self.mForbidCleanUp then
                -- ui.showFlashView(TR("当前正在组队或战斗中，不能查看其他玩家阵容"))
                return 
            end

            -- Todo
        end
    })
    headCard:setHero({ModelId = cellData.HeadImageId, FashionModelID = cellData.FashionModelId, IllusionModelId = cellData.IllusionModelId, pvpInterLv = cellData.DesignationId}, {CardShowAttr.eBorder})
    headCard:setPosition(cc.p(70, cellSize.height / 2))
    lvItem:addChild(headCard)

    -- 结缘的标识
    if cellData.MarryPlayerId ==  PlayerAttrObj:getPlayerInfo().PlayerId then
        --添加玩家关系logo
        local tempSprite = ui.newSprite("c_42.png")
        tempSprite:setAnchorPoint(cc.p(0, 1))
        tempSprite:setPosition(0, 100)
        headCard:addChild(tempSprite)
    end

    -- 名字
    local nameLabel = ui.newLabel({
        text = TR("%s  %d级", cellData.Name, cellData.Lv),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 100)
    lvItem:addChild(nameLabel)

    --VIP等级
    local nameWidth = nameLabel:getContentSize().width
    local vipNode = ui.createVipNode(cellData.Vip)
    vipNode:setPosition(nameWidth + 140, 100)
    lvItem:addChild(vipNode)

    -- 战斗力
    local FAPStr = Utility.numberFapWithUnit(cellData.FAP)
    local FAPLabel = ui.newLabel({
        text = TR("战斗力:%s%s","#de6e00", FAPStr),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    FAPLabel:setAnchorPoint(cc.p(0, 0.5))
    FAPLabel:setPosition(130, 65)
    lvItem:addChild(FAPLabel)

    -- 离线时间
    if cellData.IsActive == true then
        local stateSprite = ui.newSprite("c_42.png")
        stateSprite:setPosition(280, 65)
        stateSprite:setAnchorPoint(cc.p(0, 0.5))
        lvItem:addChild(stateSprite)
    else
        local tempStr = string.utf8sub(MqTime.toDownFormat(cellData.OutTime), 1, -2)
        local stateValueLabel = ui.newLabel({
            text = TR("【离线%s】", tempStr),
            size = 20,
            x = 280,
            y = 65,
            color = Enums.Color.eRed,
        })
        stateValueLabel:setAnchorPoint(cc.p(0, 0.5))
        lvItem:addChild(stateValueLabel)
    end

    -- 添加私聊按钮
    local agreeBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("私聊"),
        fontSize = 24,
        clickAction = function()
            if self.selectCb then
                self.selectCb(self, cellData.PlayerId)
            else
                LayerManager.removeLayer(self)
                LayerManager.addLayer({
                    name = "Chat.ChatLayer",
                    data = {
                        chatChanne = Enums.ChatChanne.ePrivate,
                        privateId = cellData.PlayerId,
                    },
                    cleanUp = false
                })
            end
        end
    })
    agreeBtn:setPosition(cellSize.width - 80, cellSize.height / 2 + 25)
    lvItem:addChild(agreeBtn)

    -- 删除按钮
    local declineBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("删除"),
        fontSize = 24,
        clickAction = function()
            MsgBoxLayer.addOKCancelLayer(TR("是否确认删除好友?"), TR("删除联系人"),
                {
                    text = TR("确定"),
                    clickAction = function(layerObj)
                        FriendObj:requestDeleteFriend(cellData.PlayerId)
                        layerObj:removeFromParent()
                    end,
                },
                {
                    text = TR("取消"),
                }
            )
        end
    })
    declineBtn:setPosition(cellSize.width - 80, cellSize.height / 2 - 25)
    lvItem:addChild(declineBtn)
end

-- 刷新一条好友申请信息
function ContactsLayer:refreshOneApplyItem(index)
	local cellData = self.mApplyList[index] 
	if not cellData then
		return 
	end

	-- 列表条目的大小
	local cellSize = cc.size(self.mListViewSize.width, 130)
	-- 获取或创建列表条目父对象
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 列表条目背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 头像
    local headCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
            if self.mForbidCleanUp then
                -- ui.showFlashView(TR("当前正在组队或战斗中，不能查看其他玩家阵容"))
                return 
            end

            -- Todo
        end
    })
    headCard:setHero({ModelId = cellData.HeadImageId, FashionModelID = cellData.FashionModelId, IllusionModelId = cellData.IllusionModelId, pvpInterLv = cellData.DesignationId}, {CardShowAttr.eBorder})
    headCard:setPosition(cc.p(70, cellSize.height / 2))
    lvItem:addChild(headCard)

    -- 名字
    local nameLabel = ui.newLabel({
        text = TR("%s  %d级", cellData.SendPlayerName, cellData.SendPlayerLv),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 100)
    lvItem:addChild(nameLabel)

    -- 战斗力
    local FAPStr = Utility.numberFapWithUnit(cellData.SendPlayerFAP)
    local FAPLabel = ui.newLabel({
        text = TR("战斗力:%s%s","#de6e00", FAPStr),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    FAPLabel:setAnchorPoint(cc.p(0, 0.5))
    FAPLabel:setPosition(130, 70)
    lvItem:addChild(FAPLabel)

    -- 创建邮件内容
    local content = string.gsub(cellData.Content, "\n", "")
    if string.utf8len(content) > 30 then
        content = string.utf8sub(content, 1, 30) .. "..."
    end
    local tempLabel = ui.newLabel({
        text = content,  
        size = 20,
        color = cc.c3b(0x8e, 0x5f, 0x3a),
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        dimensions = cc.size(350, 0),
    })
    tempLabel:setAnchorPoint(cc.p(0, 0.5))
    tempLabel:setPosition(130, 35)
    lvItem:addChild(tempLabel)

    -- 同意按钮
    local agreeBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("同意"),
        fontSize = 24,
    	clickAction = function()
            self:isFull(cellData.SendPlayerId)
    	end
    })
    agreeBtn:setPosition(cellSize.width - 80, cellSize.height / 2 + 25)
    lvItem:addChild(agreeBtn)

    -- 拒绝按钮
    local declineBtn = ui.newButton({
    	normalImage = "c_28.png",
    	text = TR("拒绝"),
        fontSize = 24,
    	clickAction = function()
    		self:requestFriendApplyResponse(cellData.SendPlayerId, false)
    	end
    })
    declineBtn:setPosition(cellSize.width - 80, cellSize.height / 2 - 25)
    lvItem:addChild(declineBtn)
end

-- 刷新一条黑名单信息
function ContactsLayer:refreshOneBlackItem(index)
	local cellData = self.mBlackList[index] 
	if not cellData then
		return 
	end
    
    if not cellData.ExtendInfo then
        local playerInfo = ChatMng:getChatPlayerInfo(cellData.Id)
        cellData = playerInfo
    end
    local extendInfo = cellData.ExtendInfo

	-- 列表条目的大小
	local cellSize = cc.size(self.mListViewSize.width, 130)
	-- 获取或创建列表条目父对象
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 列表条目背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
    cellBgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 玩家头像
    local headCard = CardNode:create({
        allowClick = true,
        onClickCallback = function()
            if self.mForbidCleanUp then
                -- ui.showFlashView(TR("当前正在组队或战斗中，不能查看其他玩家阵容"))
                return 
            end

            -- Todo
        end
    })
    headCard:setHero({ModelId = extendInfo.HeadImageId, FashionModelID = cellData.FashionModelId, IllusionModelId = cellData.IllusionModelId, pvpInterLv = extendInfo.DesignationId}, {CardShowAttr.eBorder})
    headCard:setPosition(cc.p(70, cellSize.height / 2))
    lvItem:addChild(headCard)

    -- 名字
    local nameLabel = ui.newLabel({
        text = extendInfo.Name,
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(130, 100)
    lvItem:addChild(nameLabel)

    -- 战斗力
    local FAPLabel = ui.newLabel({ 
        text = TR("战斗力:%s%s", "#de6e00", Utility.numberFapWithUnit(extendInfo.Fap or extendInfo.FAP)),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    FAPLabel:setAnchorPoint(cc.p(0, 0.5))
    FAPLabel:setPosition(130, 65)
    lvItem:addChild(FAPLabel)

    -- 等级
    local lvLabel = ui.newLabel({
        text = TR("等级:%s%d", "#d17b00", extendInfo.Lv),
        size = 20,
        color = cc.c3b(0x46, 0x22, 0x0d)
    })
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    lvLabel:setPosition(130, 35)
    lvItem:addChild(lvLabel)

    -- 删除按钮
    local deleteBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("删除"),
        clickAction = function()
            EnemyObj:deleteEnemy(cellData.Id)

            self.mBlackList = EnemyObj:getEnemyList() or {}
            self:refreshListView()
        end
    })
    deleteBtn:setPosition(cellSize.width - 80, cellSize.height / 2)
    lvItem:addChild(deleteBtn)
end

function ContactsLayer:DeleteFriendPopUI()
    local function DIYNormalFunction(layer, layerBgSprite, layerSize)
            -- 重新设置提示内容的位置
        layer.mMsgLabel:setPosition(layerSize.width / 2, 230)
        local str = ""
         if self.friendList[#self.friendList] then
            if self.friendList[#self.friendList].IsActive == false then
                str = TR("你的好友数量已满\n是否直接删除离线时间最长的好友：%s",self.friendList[#self.friendList].Name)
            else
                str = TR("你的好友数量已满\n是否直接删除好友亲密度等级最低的好友：%s",self.friendList[#self.friendList].Name)
            end
        end
        local label = ui.newLabel({
            text = str,
            color = cc.c3b(0x46, 0x22, 0x0d),
            align = cc.TEXT_ALIGNMENT_CENTER,
            dimensions = cc.size(500, 0)
        })
        label:setPosition(cc.p(layerSize.width / 2,layerSize.height / 2 + 20))
        layerBgSprite:addChild(label)
        -- self:play(layerBgSprite)
    end
    local okBtn = {
        normalImage = "c_28.png",
        scale = 0.85,
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            FriendObj:requestDeleteFriend(self.friendList[#self.friendList].PlayerId)
            LayerManager.removeLayer(layerObj)           
        end
    }
    local cancelBtn = {
        normalImage = "c_28.png",
        scale = 0.85,
        text = TR("取消"),
        clickAction = function(layerObj, btnObj)  
            LayerManager.removeLayer(layerObj)      
        end
    }
     -- 创建窗口
    local tempData = {
        bgImage = "mrjl_02.png",
        bgSize = cc.size(557, 400),
        title = TR("提示"),
        msgText = "",
        btnInfos = {okBtn, cancelBtn},   
        closeBtnInfo = {
            normalImage = "c_29.png"
        },
        DIYUiCallback = DIYNormalFunction,
    }

    self.mPopLayer = LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        data = tempData,
        cleanUp = false,
    })
end

--=========================网络请求相关===========================

-- 获取好友邮件的数据请求
function ContactsLayer:requestGetFriendMessageByPage()
    HttpClient:request({
        moduleName = "FriendMessage", 
        methodName = "GetFriendMessageByPage", 
        svrMethodData = {0, 30}, 
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            self.mApplyList = {}
            for _, item in pairs(response.Value) do
                if item.Type == 1 then
                    table.insert(self.mApplyList, item)
                end
            end

            table.sort(self.mApplyList, function (a, b)
                return  a.SendTime > b.SendTime
            end)

            -- 当前正在好友申请页面，需要刷新好友申请列表
            if self.mSelectTag == ContactsTag.eApply then
                self:refreshListView()
            end
        end
    })
end

-- 网络数据处理
function ContactsLayer:requestFriendApplyResponse(palyerId, isAgree)
    HttpClient:request({
        moduleName = "Friend", 
        methodName = "FriendApplyResponse",
        svrMethodData = {palyerId, isAgree}, 
        callback = function(response)
            if response.Status == 0 then
                local hintStr = isAgree and TR("同意成为好友成功") or TR("已拒绝成为好友")
                ui.showFlashView(hintStr)

                -- 重新获取邮件信息
                self:requestGetFriendMessageByPage()
                -- 
                FriendObj:clearFriendList()
                FriendObj:requestGetFriendList()
            else
                local errorCode = response.Status
                if errorCode == -3013 or errorCode == -12 or errorCode == -3012 or errorCode == -3005 then
                    self:requestGetFriendMessageByPage()
                end
            end
        end
    })
end

function ContactsLayer:isGetMarry(playerID)
    if not Utility.isEntityId(playerID) then return false end
    if playerID == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        return true
    end
    return false
end

--判断好友是否已满
function ContactsLayer:isFull(PlayerId)  --是否全部判断
    FriendObj:requestGetFriendList(function(friendList)
        self.friendList = friendList
        table.sort(self.friendList, function(a, b) --在线 关系 好感度
            if self:isGetMarry(a.MarryPlayerId) and not self:isGetMarry(b.MarryPlayerId) then
                return true
            elseif not self:isGetMarry(a.MarryPlayerId) and self:isGetMarry(b.MarryPlayerId) then
                return false
            -- elseif not a.IsActive and not b.IsActive then
            --     return a.LeaveTime > b.LeaveTime
            end
        end)
        local currLv = PlayerAttrObj:getPlayerAttrByName("Lv")
        local friendCount = table.maxn(self.friendList)
        if friendCount >= PlayerLvRelation.items[currLv].friendMax then
            self:DeleteFriendPopUI()
        else
            self:requestFriendApplyResponse(PlayerId,true)
        end
    end)
end

return ContactsLayer