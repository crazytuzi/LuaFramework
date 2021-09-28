local SocialNode = class("SocialNode", function() return cc.Node:create() end)
local RevengeDeclarationNode = class("RevengeDeclarationNode", function() return cc.Node:create() end)
local SocialViewLayer = class("SocialViewLayer", require("src/TabViewLayer"))

local FriendLayer = class("FriendLayer", require("src/TabViewLayer"))
local EnemyLayer = class("EnemyLayer", require("src/TabViewLayer"))

local dealTypeSend = 1
local dealTypeGet = 2

function SocialNode:ctor(chooseType)
    
    local msgids = {RELATION_SC_GETRELATIONDATA_RET, 
    RELATION_SC_REMOVERELATION_RET, 
    RELATION_SC_GETREALFIREND_RET,
    RELATION_SC_DEALGIFT_RET,
    RELATION_SC_CHANGEENEMYWORD_RET,
    RELATION_SC_GETENEMYWORD_RET}

	require("src/MsgHandler").new(self, msgids)
	--startTimerAction(self, 0.3, false, function() 
		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 1)
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
		--addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 2)
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 4})

		--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 5})
		--addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 2})
		--addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
		--addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)
	 --end)


    local bg, closeBtn = createBgSprite(self, game.getStrByKey("social_title_social"), nil, true)
    self.bg = bg
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_SOCIAL_CLOSE)

	-- local baseNode = cc.Node:create()
	-- self:addChild(baseNode)
	-- baseNode:setPosition(cc.p(0, 0))
	-- self.baseNode = baseNode

    --title
    --createLabel(baseNode, game.getStrByKey("chat_social"), cc.p(480, 608), cc.p(0.5, 0.5), 32, true, nil, nil, MColor.lable_yellow)

    --背景框
    --createSprite(bg, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))

    --tab背景
    --createScale9Sprite(bg, "res/common/bg/buttonBg4.png", cc.p(34, 40), cc.size(190, 502), cc.p(0, 0))
    local leftBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 40),
        cc.size(180,500),
        5
    )
    --view背景
    --createScale9Sprite(bg, "res/common/bg/bg60.png", cc.p(207, 326), cc.size(736, 424), cc.p(0, 0.5))
    --createSprite(bg, "res/common/bg/bg60.png", cc.p(574, 329), cc.p(0.5, 0.5))
    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(220, 40),
        cc.size(710,500),
        5
    )
    --名称 战斗力 等级 职业 状态等label
	CreateListTitle(bg, cc.p(223, 514), 702, 43, cc.p(0, 0.5))
    createLabel(bg, game.getStrByKey("show_flowers3"), cc.p(300, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(bg, game.getStrByKey("level"), cc.p(410, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(bg, game.getStrByKey("combat_power"), cc.p(535, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(bg, game.getStrByKey("school"), cc.p(660, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(bg, game.getStrByKey("state"), cc.p(770, 514), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)

    self.topBgQQ = CreateListTitle(bg, cc.p(223, 514), 702, 43, cc.p(0, 0.5))
    createLabel(self.topBgQQ, game.getStrByKey("qq_title_rank"), cc.p(45, self.topBgQQ:getContentSize().height/2), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(self.topBgQQ, game.getStrByKey("qq_title_info"), cc.p(210, self.topBgQQ:getContentSize().height/2), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(self.topBgQQ, game.getStrByKey("qq_title_fight"), cc.p(370, self.topBgQQ:getContentSize().height/2), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
    createLabel(self.topBgQQ, game.getStrByKey("qq_title_control"), cc.p(575, self.topBgQQ:getContentSize().height/2), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)

 --    --左侧tab按钮
 --    self.m_tab1 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 500), function(sender) self:setTab(sender, 1) end)
	-- createLabel(self.m_tab1, game.getStrByKey("friend"), getCenterPos(self.m_tab1), cc.p(0.5, 0.5), 24, true)

 --    self.m_tab2 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 428), function(sender) self:setTab(sender, 4) end)
	-- createLabel(self.m_tab2, game.getStrByKey("kind_list"), getCenterPos(self.m_tab2), cc.p(0.5, 0.5), 24, true)

 --    self.m_tab3 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 356), function(sender) self:setTab(sender, 5) end)
	-- createLabel(self.m_tab3, game.getStrByKey("near_list"), getCenterPos(self.m_tab3), cc.p(0.5, 0.5), 24, true)

	-- self.m_tab4 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 284), function(sender) self:setTab(sender, 2) end)
	-- createLabel(self.m_tab4, game.getStrByKey("enemy"), getCenterPos(self.m_tab2), cc.p(0.5, 0.5), 24, true)

 --    self.m_tab5 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 212), function(sender) self:setTab(sender, 3) end)
	-- createLabel(self.m_tab5, game.getStrByKey("black_list"), getCenterPos(self.m_tab3), cc.p(0.5, 0.5), 24, true)

 --    --屏蔽好友标签
 --    self.m_tab6 = createMenuItem(bg, "res/component/button/40.png", cc.p(122, 140), function(sender) self:setTab(sender, 6) end)
 --    self.m_tab6Str = createLabel(self.m_tab6, game.getStrByKey("social_qq_friend"), getCenterPos(self.m_tab3), cc.p(0.5, 0.5), 24, true)

    local textTab = {
        game.getStrByKey("friend"),
        game.getStrByKey("kind_list"),
        game.getStrByKey("near_list"),
        game.getStrByKey("enemy"),
        game.getStrByKey("black_list"),
        --game.getStrByKey("social_qq_friend"),
    }

    self.platform = sdkGetPlatform()

    if self.platform == 1 then
         --self.m_tab6Str:setString(game.getStrByKey("social_weixin_friend"))
         table.insert(textTab, game.getStrByKey("social_weixin_friend"))
    elseif self.platform == 2 then
         --self.m_tab6Str:setString(game.getStrByKey("social_qq_friend"))
         table.insert(textTab, game.getStrByKey("social_qq_friend"))
    end

        --默认选择好友
    local defaultIndex = 0
    if chooseType == 4 then
        defaultIndex = 1
    elseif chooseType == 5 then
        defaultIndex = 2
    elseif chooseType == 2 then
        defaultIndex = 3
    elseif chooseType == 3 then
        defaultIndex = 4
    elseif chooseType == 1 then
        defaultIndex = 5
    end

    local callback = function(idx)
        log("111111111111111111111111111111111 idx = "..idx)
        local relationType
        if idx == 1 then
            relationType = 1
        elseif idx == 2 then
            relationType = 4
        elseif idx == 3 then
            relationType = 5
        elseif idx == 4 then
            relationType = 2
        elseif idx == 5 then
            relationType = 3
        elseif idx == 6 then
            relationType = 6
        end
        self:setTab(relationType)
    end
    self.leftSelectNode = require("src/LeftSelectNode_ex").new(leftBg, textTab, cc.size(200, 465), cc.p(2, 30), callback, nil, nil, defaultIndex)

    --黑名单功能暂时没有
    --self.m_tab3:setVisible(false)

    self.parentBg = parentBg

    --数据
    self.data = {}
	self.data.friendData = {}
	self.data.enemyData = {}
    self.data.blackData = {}
    self.data.qqData = {}
    self.isShowSendMsg = true

    --view
    self.viewLayer = SocialViewLayer.new(self)	
	self.viewLayer:setPosition(cc.p(224, 121))
    bg:addChild(self.viewLayer)

    --选择的索引
    self.m_curSelDataIndex = 0

    --添加好友按钮
    local function addFriendBtnFunc()
		local layer = require("src/layers/friend/AddFriendLayer").new(self.bg, self)
		self:addChild(layer)
	end
	self.addFriendBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(670, 76), addFriendBtnFunc)
	G_TUTO_NODE:setTouchNode(self.addFriendBtn, TOUCH_SOCIAL_ADD_FIREND)
	createLabel(self.addFriendBtn, game.getStrByKey("add_friend"), getCenterPos(self.addFriendBtn), cc.p(0.5, 0.5), 22, true)

    --复仇宣言按钮
	local function revengeDeclarationBtnFunc()
		self.revengeDeclarationNode = RevengeDeclarationNode.new(self.data.revengeDeclaration)	
	    self:addChild(self.revengeDeclarationNode)
	    self.revengeDeclarationNode:setPosition(g_scrCenter)
        setLocalRecord("haveShowRevengeDeclarationBtnRedFlag",true)
        if self.revengeDeclarationBtnRedFlag then
            self.revengeDeclarationBtnRedFlag:setVisible(false)
        end
        if self.revengeDeclarationBtnRedFlagLeftTab then
            self.revengeDeclarationBtnRedFlagLeftTab:setVisible(false)
        end
    end
    --获取复仇宣言
    g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETENEMYWORD, "GetEnemyWordProtocol", {})
	self.revengeDeclarationBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(670, 76), revengeDeclarationBtnFunc)
	createLabel(self.revengeDeclarationBtn, game.getStrByKey("revenge_declaration"), getCenterPos(self.revengeDeclarationBtn), cc.p(0.5, 0.5), 22, true)
    local showFlag=getLocalRecord("haveShowRevengeDeclarationBtnRedFlag")
    if showFlag==nil or showFlag==false then
        self.revengeDeclarationBtnRedFlag = createSprite( self.revengeDeclarationBtn ,getSpriteFrame("mainui/flag/red.png") , cc.p( self.revengeDeclarationBtn:getContentSize().width - 5 , self.revengeDeclarationBtn:getContentSize().height - 10 ) , cc.p( 0.5 , 0.5 ) )
        local button = self.leftSelectNode:getTableView():cellAtIndex(3):getChildByTag(10)
        self.revengeDeclarationBtnRedFlagLeftTab = createSprite(button, getSpriteFrame("mainui/flag/red.png") , cc.p(button:getContentSize().width - 5 , button:getContentSize().height - 10 ) , cc.p( 0.5 , 0.5 ) )
    end
   
    --送花历史按钮
	local function flowerHistoryBtnFunc()
		local layer = require("src/layers/friend/FlowersLayer").new()
		self:addChild(layer)
	end
	self.flowerHistoryBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(860, 76), flowerHistoryBtnFunc)
	createLabel(self.flowerHistoryBtn, game.getStrByKey("flowers_record"), getCenterPos(self.flowerHistoryBtn), cc.p(0.5, 0.5), 22, true)

    --战斗日志按钮
	local function fightHistoryBtnFunc()
		local layer = require("src/layers/role/fightLog").new()
		self:addChild(layer)
	end
	self.fightHistoryBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(860, 76), fightHistoryBtnFunc)
	createLabel(self.fightHistoryBtn, game.getStrByKey("fight_log"), getCenterPos(self.fightHistoryBtn), cc.p(0.5, 0.5), 22, true)

    --更多操作按钮
	local function moreFunc()
        local record = nil
        if self.m_curTab == 1 then
            record = self.data.friendData[self.m_curSelDataIndex]
        elseif self.m_curTab == 2 then
            record = self.data.enemyData[self.m_curSelDataIndex]
        end

        if record == nil then
            return
        end

        self:showOperationPanel(record)		
	end
	-- self.moreBtn = createMenuItem(bg, "res/component/button/2.png", cc.p(860, 76), moreFunc)
	-- createLabel(self.moreBtn, game.getStrByKey("chat_moreOperation"), getCenterPos(self.moreBtn), cc.p(0.5, 0.5), 22, true)
  
    --删除按钮，黑名单用到
	local function deleteFunc()
		if self.m_curTab == 3 and self.m_curSelDataIndex and self.data.blackData[self.m_curSelDataIndex] ~= nil then
	        --g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_REMOVERELATION, "iic", G_ROLE_MAIN.obj_id, self.data.blackData[self.m_curSelDataIndex].roleId, 3)
			local t = {}
			t.targetSid = self.data.blackData[self.m_curSelDataIndex].roleId
			t.relationKind = 3
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_REMOVERELATION, "RemoveRelationProtocol", t)
			addNetLoading(RELATION_CS_REMOVERELATION, RELATION_SC_REMOVERELATION_RET)
	    end
        startTimerAction(self, 0.3, false, function() self.deleteBtn:setEnabled(false) end)
	end
	self.deleteBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(860, 76), deleteFunc)
	createLabel(self.deleteBtn, game.getStrByKey("delete_relation"), getCenterPos(self.deleteBtn), cc.p(0.5, 0.5), 22, true)

	--添加好友按钮，附近 熟人用到
	local function addFunc()
		if self.m_curTab == 4 and self.m_curSelDataIndex and self.data.kindData[self.m_curSelDataIndex] ~= nil then
			AddFriendsEx(self.data.kindData[self.m_curSelDataIndex].name)
			startTimerAction(self, 0.3, false, function() 
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
				end)
		elseif self.m_curTab == 5 and self.m_curSelDataIndex and self.data.nearData[self.m_curSelDataIndex] ~= nil then
			AddFriendsEx(self.data.nearData[self.m_curSelDataIndex].name)
			startTimerAction(self, 0.3, false, function() 
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
				end)
	    end
	end
	self.addBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(860, 76), addFunc)
	createLabel(self.addBtn, game.getStrByKey("add_friend"), getCenterPos(self.addBtn), cc.p(0.5, 0.5), 22, true)

    --一键领取
    local function getBtnFunc()
        local canTips = true
        for i,v in ipairs(self.data.qqData) do
            if v.canPickGift then
                local t = {}
                t.dealType = dealTypeGet
                t.roleSID = v.roleId
                g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_DEALGIFT, "DealgiftProtocol", t)
                v.canPickGift = false
                canTips = false
            end
        end
        if canTips then
            TIPS({ type = 1  , str = game.getStrByKey("social_get_gifts_tips") })
        end
        self.viewLayer:updateData(self.data.qqData, true)
    end
    self.getBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(480, 76), getBtnFunc)
    createLabel(self.getBtn, game.getStrByKey("social_qq_get_all"), getCenterPos(self.getBtn), cc.p(0.5, 0.5), 22, true)

    --一键赠送
    local function sendBtnFunc()
        local canTips = true
        for i,v in ipairs(self.data.qqData) do
            if v.canGift then
                local t = {}
                t.dealType = dealTypeSend
                t.roleSID = v.roleId
                g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_DEALGIFT, "DealgiftProtocol", t)
                v.canGift = false
                self.isShowSendMsg = false
                canTips = false
            end
        end
        if canTips then
            TIPS({ type = 1  , str = game.getStrByKey("social_send_gifts_tips") })
        end
        self.viewLayer:updateData(self.data.qqData, true)
    end
    self.sendBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(670, 76), sendBtnFunc)
    createLabel(self.sendBtn, game.getStrByKey("social_qq_send_all"), getCenterPos(self.sendBtn), cc.p(0.5, 0.5), 22, true)

    --邀请好友
    self.inviteBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(860, 76), INVITE_FIRENDS )
    createLabel(self.inviteBtn, game.getStrByKey("social_qq_invite"), getCenterPos(self.inviteBtn), cc.p(0.5, 0.5), 22, true)

    --击杀信息等
    self.killLabel = createLabel(bg, game.getStrByKey("social_kill_me"), cc.p(250, 90), cc.p(0, 0.5), 22, true)
    self.killLabel:setVisible(false)
    self.killmeLabel = createLabel(bg, game.getStrByKey("social_kill_by_me"), cc.p(250, 62), cc.p(0, 0.5), 22, true)
    self.killmeLabel:setVisible(false)

 --    --默认选择好友
 --    local choose = chooseIdx or 1
 --    local defaultBtn = self.m_tab1
 --    if choose == 4 then
 --    	defaultBtn = self.m_tab2
	-- elseif choose == 5 then
	-- 	defaultBtn = self.m_tab3
	-- elseif choose == 2 then
	-- 	defaultBtn = self.m_tab4
	-- elseif choose == 3 then
	-- 	defaultBtn = self.m_tab5
	-- elseif choose == 6 then
	-- 	defaultBtn = self.m_tab6
	-- end

    --self:setTab(chooseIdx or 1)
    callback(defaultIndex + 1)

    local function eventCallback(eventType)
        if eventType == "enter" then
        	G_TUTO_NODE:setShowNode(self, SHOW_SOCIAL)
        elseif eventType == "exit" then
        end
    end
    self:registerScriptHandler(eventCallback)

    --缓存好友列表信息
    self.canCacheFriendsInfo = false
end

function SocialNode:getSDKData()
    -- local t = {}
    -- t.openid={"wn1"}
    -- --table.insert(t, "wn10")
    -- g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETREALFIREND, "GetRealFirendProtocol", t)

    -- if self.friendsInfo and #self.friendsInfo > 0 then
    --     return
    -- end

    self.isMe = true

     --platform字段区分QQ还是微信，整型，1是微信，2是QQ，如下所示完成了好友信息的调用和回调
     self.platform = sdkGetPlatform()

     -- if self.platform == 1 then
     --     self.m_tab6Str:setString(game.getStrByKey("social_weixin_friend"))
     -- elseif self.platform == 2 then
     --     self.m_tab6Str:setString(game.getStrByKey("social_qq_friend"))
     -- end

     self.friendsInfo = {}

     local sendData = {}
     sendData.openid = {}
     self.onRelationFriendsInfoNotify = function(result, str)
         require("src/utf8")
         local ret = require("json").decode(str)
         if #ret > 0 then
             for i = 1, #ret do
                local record = {}
                 record.nickName = hexDecode(ret[i].nickName)
                 if not string.isValidUtf8(record.nickName) then
                    record.nickName = " "
                 end
               
                 record.pictureSmall = hexDecode(ret[i].pictureSmall)
                 record.pictureMiddle = hexDecode(ret[i].pictureMiddle)
                 record.pictureLarge = hexDecode(ret[i].pictureLarge)
                 record.city = hexDecode(ret[i].city)
                 record.gender = ret[i].gender
                 if self.isMe == true then
                    record.openId = sdkGetOpenId()
                 else
                    record.openId = ret[i].openId
                 end
                 
                 record.isMe = self.isMe
                 table.insert(self.friendsInfo, record)
                 table.insert(sendData.openid, record.openId)
             end

             if self.isMe == false then
                 g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETREALFIREND, "GetRealFirendProtocol", sendData)
             end
         end

        if self.isMe == true then
            self.isMe = false
            self:GetQueryInfo(false)
        end
     end

     self:GetQueryInfo(true)
end

function SocialNode:GetQueryInfo(isMyInfo)
    if isMyInfo then
        LoginUtils.queryMyInfo(self.onRelationFriendsInfoNotify)
    else
        LoginUtils.queryFriendsInfo(self.onRelationFriendsInfoNotify)
    end
end

function SocialNode:setTab(relationType)
    if self.m_curTab == relationType then
        return
    end
    dump(relationType)
    -- self.m_tab1:setTexture("res/component/button/40.png")
    -- self.m_tab2:setTexture("res/component/button/40.png")
    -- self.m_tab3:setTexture("res/component/button/40.png")
    -- self.m_tab4:setTexture("res/component/button/40.png")
    -- self.m_tab5:setTexture("res/component/button/40.png")
    -- self.m_tab6:setTexture("res/component/button/40.png")
    -- sender:setTexture("res/component/button/40_sel.png")

    -- if self.m_arrow == nil then
    --     self.m_arrow = createSprite(self.bg, "res/group/arrows/9.png", cc.p(0, 0), cc.p(0, 0.5))
    -- end

    -- self.m_arrow:setPosition(sender:getContentSize().width/2 + sender:getPositionX(), sender:getPositionY());

    --选择view
    self.m_curSelDataIndex = 0
    self.m_curTab = relationType
    if relationType == 1 then
        self.addFriendBtn:setVisible(true)
        self.fightHistoryBtn:setVisible(false)
        self.flowerHistoryBtn:setVisible(true)
        self.revengeDeclarationBtn:setVisible(false)
        --self.moreBtn:setVisible(true)
        self.deleteBtn:setVisible(false)
        self.addBtn:setVisible(false)
        self.addBtn:setEnabled(false)

        self.killLabel:setVisible(false)
        self.killmeLabel:setVisible(false)

        --self.moreBtn:setEnabled(false)

        self.getBtn:setVisible(false)
        self.sendBtn:setVisible(false)
        self.inviteBtn:setVisible(false)
        self.topBgQQ:setVisible(false)
         dump(relationType)
        self.viewLayer:updateData(self.data.friendData, false, relationType)
    elseif relationType == 4 then
        self.addFriendBtn:setVisible(false)
        self.fightHistoryBtn:setVisible(false)
        self.flowerHistoryBtn:setVisible(false)
        self.revengeDeclarationBtn:setVisible(false)
        --self.moreBtn:setVisible(false)
        self.deleteBtn:setVisible(false)
        self.deleteBtn:setEnabled(false)
        self.addBtn:setVisible(true)
        self.addBtn:setEnabled(false)

        self.killLabel:setVisible(false)
        self.killmeLabel:setVisible(false)

        self.getBtn:setVisible(false)
        self.sendBtn:setVisible(false)
        self.inviteBtn:setVisible(false)
        self.topBgQQ:setVisible(false)

        self.viewLayer:updateData(self.data.kindData, false, relationType)
    elseif relationType == 5 then
        self.addFriendBtn:setVisible(false)
        self.fightHistoryBtn:setVisible(false)
        self.flowerHistoryBtn:setVisible(false)
        self.revengeDeclarationBtn:setVisible(false)
        --self.moreBtn:setVisible(false)
        self.deleteBtn:setVisible(false)
        self.deleteBtn:setEnabled(false)
        self.addBtn:setVisible(true)
        self.addBtn:setEnabled(false)

        self.killLabel:setVisible(false)
        self.killmeLabel:setVisible(false)

        self.getBtn:setVisible(false)
        self.sendBtn:setVisible(false)
        self.inviteBtn:setVisible(false)
        self.topBgQQ:setVisible(false)

        self.viewLayer:updateData(self.data.nearData, false, relationType)
     elseif relationType == 2 then
        self.addFriendBtn:setVisible(false)
        self.fightHistoryBtn:setVisible(true)
        self.flowerHistoryBtn:setVisible(false)
        self.revengeDeclarationBtn:setVisible(true)
        --self.moreBtn:setVisible(true)
        self.deleteBtn:setVisible(false)
        self.addBtn:setVisible(false)
        self.addBtn:setEnabled(false)

        --self.moreBtn:setEnabled(false)

        --self.killmeLabel:setVisible(true)
        self.killmeLabel:setString(game.getStrByKey("social_kill_by_me"))
        --self.killLabel:setVisible(true)
        self.killLabel:setString(game.getStrByKey("social_kill_me"))    

        self.getBtn:setVisible(false)
        self.sendBtn:setVisible(false)
        self.inviteBtn:setVisible(false)
        self.topBgQQ:setVisible(false)     

        self.viewLayer:updateData(self.data.enemyData, false, relationType)
    elseif relationType == 3 then
        self.addFriendBtn:setVisible(false)
        self.fightHistoryBtn:setVisible(false)
        self.flowerHistoryBtn:setVisible(false)
        self.revengeDeclarationBtn:setVisible(false)
        --self.moreBtn:setVisible(false)
        self.deleteBtn:setVisible(true)
        self.deleteBtn:setEnabled(false)
        self.addBtn:setVisible(false)
        self.addBtn:setEnabled(false)

        self.killLabel:setVisible(false)
        self.killmeLabel:setVisible(false)

        self.getBtn:setVisible(false)
        self.sendBtn:setVisible(false)
        self.inviteBtn:setVisible(false)
        self.topBgQQ:setVisible(false)

        self.viewLayer:updateData(self.data.blackData, false, relationType)
    elseif relationType == 6 then
        self.addFriendBtn:setVisible(false)
        self.fightHistoryBtn:setVisible(false)
        self.flowerHistoryBtn:setVisible(false)
        self.revengeDeclarationBtn:setVisible(false)
        --self.moreBtn:setVisible(false)
        self.deleteBtn:setVisible(false)
        self.deleteBtn:setEnabled(false)
        self.addBtn:setVisible(false)
        self.addBtn:setEnabled(false)

        self.killLabel:setVisible(false)
        self.killmeLabel:setVisible(false)

        self.getBtn:setVisible(true)
        self.sendBtn:setVisible(true)
        self.inviteBtn:setVisible(true)
        self.topBgQQ:setVisible(true)

        self:getSDKData()

        self.viewLayer:updateData(self.data.qqData)
    end   
    -- AudioEnginer.playTouchPointEffect()
end

function SocialNode:reloadNetData()
	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 1)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})

	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 2)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 2})

	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})

	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 4})

	g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 5})
	addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)
end

function SocialNode:updateData(relationType)
    if self.m_curTab == relationType then
        if relationType == 1 then
            self.viewLayer:updateData(self.data.friendData, false, relationType)
        elseif relationType == 2 then
            self.viewLayer:updateData(self.data.enemyData, false, relationType)
        elseif relationType == 3 then
            self.viewLayer:updateData(self.data.blackData, false, relationType)
        elseif relationType == 4 then
            self.viewLayer:updateData(self.data.kindData, false, relationType)
        elseif relationType == 5 then
            self.viewLayer:updateData(self.data.nearData, false, relationType)
        elseif relationType == 6 then
            self.viewLayer:updateData(self.data.qqData, true, relationType)
        end
    end
end

function SocialNode:onSelDataIndex(index)
    self.m_curSelDataIndex = index

    if self.m_curTab == 3 then
        self.deleteBtn:setEnabled(true)
    elseif self.m_curTab == 4 or self.m_curTab == 5 then
    	self.addBtn:setEnabled(true)
    else
        --self.moreBtn:setEnabled(true)
            --更多操作按钮
        local function moreFunc()
            local record = nil
            if self.m_curTab == 1 then
                record = self.data.friendData[self.m_curSelDataIndex]
            elseif self.m_curTab == 2 then
                record = self.data.enemyData[self.m_curSelDataIndex]
            end

            if record == nil then
                return
            end

            self:showOperationPanel(record)     
        end
        moreFunc()
    end

    --更新击杀信息
    if self.m_curTab == 2 and self.data.enemyData[self.m_curSelDataIndex] ~= nil then
        local str = game.getStrByKey("social_kill_by_me")..self.data.enemyData[self.m_curSelDataIndex].killMe..game.getStrByKey("times")
        self.killmeLabel:setString(str)

        str = game.getStrByKey("social_kill_me")..self.data.enemyData[self.m_curSelDataIndex].killByMe..game.getStrByKey("times")
        self.killLabel:setString(str)
    end

    -- if index == nil then
    --     if self.m_curTab == 3 then
    --         self.deleteBtn:setEnabled(false)
    --     elseif self.m_curTab == 4 or self.m_curTab == 5 then
    --         self.addBtn:setEnabled(false)
    --     else
    --         self.moreBtn:setEnabled(false)
    --     end
    -- end
end

function SocialNode:showOperationPanel(record)
	local func = function(tag)
		local switch = {
			-- [1] = function() 
			-- 	PrivateChat(record.name)
			-- end,
			[1] = function() 
				LookupInfo(record.name)
			end,
			[2] = function() 
			  	InviteTeamUp(record.name)
			end,
			[3] = function() 
			  	local layer = require("src/layers/friend/SendFlowerLayer").new({[1]=record.roleId, [2]=record.name})
				Manimation:transit(
				{
					ref = G_MAINSCENE.base_node,
					node = layer,
					sp = g_scrCenter,
					ep = g_scrCenter,
					zOrder = 200,
					curve = "-",
					swallow = true,
				})
			end,
            [4] = function()
			  	local relation = 1
				if record.killMe then
					relation = 2
				end
			  	--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_REMOVERELATION, "iic", G_ROLE_MAIN.obj_id, record.roleId, relation)
			  	local t = {}
				t.targetSid = record.roleId
				t.relationKind = relation
				g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_REMOVERELATION, "RemoveRelationProtocol", t)
			  	addNetLoading(RELATION_CS_REMOVERELATION, RELATION_SC_REMOVERELATION_RET)
			  	-- if self.moreBtn then
			  	-- 	self.moreBtn:setEnabled(false)
			  	-- end
			end,
			[5] = function()
			  	--AddBlackList(record.name)
			  	local isInList = false
			  	if self.data.friendData then
				  	for k,v in pairs(self.data.friendData) do
				  		if v.name == record.name then
				  			isInList = true
				  			break
				  		end
				  	end
			  	end

			  	if isInList then
				  	local function yesFunc()
						--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,3,1,record.name)
						local t = {}
						t.relationKind = 3
						t.targetName = {record.name}
						g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
						self:reloadNetData()
					end
					MessageBoxYesNoEx(nil,game.getStrByKey("social_tip_for_add_black"),yesFunc,nil,nil,nil,true)
				else
					--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_ADDRELATION,"iccS",G_ROLE_MAIN.obj_id,3,1,record.name)
					local t = {}
					t.relationKind = 3
					t.targetName = {record.name}
					g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_ADDRELATION, "AddRelationProtocol", t)
					self:reloadNetData()
				end
			end,
            [6] = function() 
			  	--发送邀请入会协议
                g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_INVITE_JONE, "FactionInviteJoin", {opRoleName=record.name})
			end,
		}
		if switch[tag] then 
			switch[tag]() 
		end
		removeFromParent(self.operateLayer)
		self.operateLayer = nil
	end
	local menus = {
		--{game.getStrByKey("chat_personal"), 1, func},
		{game.getStrByKey("look_info"), 1, func},
		{game.getStrByKey("re_team"), 2, func},
		{game.getStrByKey("send_flower_text"), 3, func},
		{game.getStrByKey("delete_relation"), 4, func},
		{game.getStrByKey("add_blackList"), 5, func},
        {game.getStrByKey("faction_invite_member"), 6, func},
	}

	if G_CONTROL:isFuncOn( GAME_SWITCH_ID_FLOWER ) == false then
		table.remove(menus, 3)
	end

    if G_FACTION_INFO == nil or G_FACTION_INFO.job == nil or G_FACTION_INFO.job < 3 then
		table.remove(menus, 6)
	end

    self.operateLayer = require("src/OperationLayer").new(G_MAINSCENE, 1, menus,"res/component/button/2","res/common/scalable/7.png")
    --local pos = self.moreBtn:getParent():convertToWorldSpace(cc.p(self.moreBtn:getPosition()) )
    dump(self.operateLayer:getPosition())
    self.operateLayer:setPosition(cc.p(380, 0))
    dump(self.operateLayer:getPosition())
end

function SocialNode:networkHander(buff, msgid)
	local function addTab(tab, addTab)
		for i,v in ipairs(addTab) do
			table.insert(tab, #tab+1, v)
		end
	end
	local switch = {	
		[RELATION_SC_GETRELATIONDATA_RET] = function() 
			log("get RELATION_SC_GETRELATIONDATA_RET")
			local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", buff) 
			local relationType = t.relationKind
			log("relationType = "..relationType)
            dump(relationType)
			dump(t)
			if relationType == 1 then
				self.data.friendData = {}

				local onlineTab = {}
				local offLineTab = {}

				for i,v in ipairs(t.roleData) do
					local record = {}
					record.roleId = v.roleSid
					record.name = v.name
					record.lv = v.level
					record.sex = v.sex
					record.school = v.school
					record.fight = v.fightAbility
					record.online = v.isOnLine
					if record.online then
						table.insert(onlineTab, #onlineTab+1, record)
					else
						table.insert(offLineTab, #offLineTab+1, record)
					end
				end
				table.sort(onlineTab, function( a , b )  return a.lv > b.lv end )
				table.sort(offLineTab, function( a , b )  return a.lv > b.lv end )
				addTab(self.data.friendData, onlineTab)
				addTab(self.data.friendData, offLineTab)
				dump(self.data.friendData)
				self:updateData(relationType)
			elseif relationType == 2 then
				self.data.enemyData = {}
				
				local onlineTab = {}
				local offLineTab = {}

				for i,v in ipairs(t.roleData) do
					local record = {}
					record.roleId = v.roleSid
					record.name = v.name
					record.lv = v.level
					record.sex = v.sex
					record.school = v.school
					record.fight = v.fightAbility
					record.killByMe = v.killNum
					record.killMe = v.beKillNum
					record.online = v.isOnLine
					if record.online then
						table.insert(onlineTab, #onlineTab+1, record)
					else
						table.insert(offLineTab, #offLineTab+1, record)
					end
				end
				table.sort(onlineTab, function( a , b )  return a.lv > b.lv end )
				table.sort(offLineTab, function( a , b )  return a.lv > b.lv end )
				addTab(self.data.enemyData, onlineTab)
				addTab(self.data.enemyData, offLineTab)
				dump(self.data.enemyData)
				self:updateData(relationType)
			elseif relationType == 3 then
				self.data.blackData = {}
				
				local onlineTab = {}
				local offLineTab = {}

				for i,v in ipairs(t.roleData) do
					local record = {}
					record.roleId = v.roleSid
					record.name = v.name
					record.lv = v.level
					record.sex = v.sex
					record.school = v.school
					record.fight = v.fightAbility
					record.online = v.isOnLine
					if record.online then
						table.insert(onlineTab, #onlineTab+1, record)
					else
						table.insert(offLineTab, #offLineTab+1, record)
					end
				end
				table.sort(onlineTab, function( a , b )  return a.lv > b.lv end )
				table.sort(offLineTab, function( a , b )  return a.lv > b.lv end )
				addTab(self.data.blackData, onlineTab)
				addTab(self.data.blackData, offLineTab)
				dump(self.data.blackData)
				G_BLACK_INFO = {}
				for i,v in ipairs(self.data.blackData) do
					table.insert(G_BLACK_INFO, #G_BLACK_INFO+1, {name=v.name, roleId=v.roleId})
				end
				dump(G_BLACK_INFO)
				self:updateData(relationType)
			elseif relationType == 4 then
				self.data.kindData = {}
				
				local onlineTab = {}
				local offLineTab = {}

				for i,v in ipairs(t.roleData) do
					local record = {}
					record.roleId = v.roleSid
					record.name = v.name
					record.lv = v.level
					record.sex = v.sex
					record.school = v.school
					record.fight = v.fightAbility
					record.online = v.isOnLine
					if record.online then
						table.insert(onlineTab, #onlineTab+1, record)
					else
						table.insert(offLineTab, #offLineTab+1, record)
					end
				end
				table.sort(onlineTab, function( a , b )  return a.lv > b.lv end )
				table.sort(offLineTab, function( a , b )  return a.lv > b.lv end )
				addTab(self.data.kindData, onlineTab)
				addTab(self.data.kindData, offLineTab)
				dump(self.data.kindData)
				
				self:updateData(relationType)
			elseif relationType == 5 then
				self.data.nearData = {}
				
				local onlineTab = {}
				local offLineTab = {}

				for i,v in ipairs(t.roleData) do
					local record = {}
					record.roleId = v.roleSid
					record.name = v.name
					record.lv = v.level
					record.sex = v.sex
					record.school = v.school
					record.fight = v.fightAbility
					record.online = v.isOnLine
					if record.online then
						table.insert(onlineTab, #onlineTab+1, record)
					else
						table.insert(offLineTab, #offLineTab+1, record)
					end
				end
				table.sort(onlineTab, function( a , b )  return a.lv > b.lv end )
				table.sort(offLineTab, function( a , b )  return a.lv > b.lv end )
				addTab(self.data.nearData, onlineTab)
				addTab(self.data.nearData, offLineTab)
				dump(self.data.nearData)

				self:updateData(relationType)
			end
		end,	
		
		[RELATION_SC_REMOVERELATION_RET] = function() 
			--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 1)
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
			addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

			--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 2)
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 2})
			addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

			--g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA, "ic", G_ROLE_MAIN.obj_id, 3)
			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 3})
			addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 4})
			addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)

			g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 5})
			addNetLoading(RELATION_CS_GETRELATIONDATA, RELATION_SC_GETRELATIONDATA_RET)
		end,
        
        [RELATION_SC_GETREALFIREND_RET] = function() 
            cclog("yuexiaojun RELATION_SC_GETREALFIREND_RET ")
            log("get RELATION_SC_GETREALFIREND_RET")
            local t = g_msgHandlerInst:convertBufferToTable("GetRealFirendRetProtocol", buff)
            self.data.qqData = {}
            --local data = {}
            cclog("yuexiaojun RELATION_SC_GETREALFIREND_RET t.friendInfo= ", #t.friendInfo)
            for i,v in ipairs(t.friendInfo) do
                local record = {}
                record.roleId = v.roleSid
                record.name = v.name
                record.lv = v.level
                record.sex = v.sex
                record.school = v.school
                record.fight = v.fightAbility
                record.openId = v.openid
                record.canGift = v.canGift
                record.canPickGift = v.canPickGift
                record.startType = v.appStartType
                table.insert(self.data.qqData, record)
            end
            table.sort(self.data.qqData, function(a, b)  return a.fight > b.fight end)

            local function getPlayerSDKData(openId)
                --dump(openId)
                --dump(self.friendsInfo)
                for i,v in ipairs(self.friendsInfo) do
                    if v.openId == openId then
                        log("find 111111111111111111111111111111111")
                        return v
                    end
                end

                return nil
            end

            for i,v in ipairs(self.data.qqData) do
                v.sdkData = getPlayerSDKData(v.openId)
                dump(v.sdkData)
            end

            dump(self.data.qqData)

            self:updateData(6)
        end,

        [RELATION_SC_DEALGIFT_RET] = function() 
            log("get RELATION_SC_DEALGIFT_RET")
            cclog("yuexiaojun RELATION_SC_DEALGIFT_RET ")
            local t = g_msgHandlerInst:convertBufferToTable("DealgiftRetProtocol", buff)
            local dealType = t.dealType
            local roleSID = t.roleSID
            dump(dealType)
            if dealType == dealTypeSend then
                dump(roleSID)
                local openId
                for i,v in ipairs(self.data.qqData) do
                    if roleSID == v.roleId then
                        openId = v.openId
                        break
                    end
                end
                dump(openId)
                if openId and Device_target == cc.PLATFORM_OS_ANDROID then                  
                    cclog("yuexiaojun RELATION_SC_DEALGIFT_RET1 ")
                    dump(self.friendsInfo)
                    for i,v in ipairs(self.friendsInfo) do
                        dump(v)
                        if v.openId == openId and self.isShowSendMsg then
                            --log("success 111111111111111111111111")
                            local function yesFunc()
                                 local title = game.getStrByKey("friend_share_title")
                                 local desc = game.getStrByKey("friend_share_award_desc")
                                 local imageUrl = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
                                 local platform = sdkGetPlatform()
                                 if platform == 1 then   --微信后台分享
                                       --cclog("yuexiaojun sdkShareWeixinwithFriend ",openId, title, desc)
                                       sdkShareWeixinwithFriend(openId, title, desc, "", "messageExt", "MSG_heart_send", "extInfo")
                                 elseif platform == 2 then       
                                       --cclog("yuexiaojun sdkShareQQwithFriend ",openId, title, desc)
                                       local targetUrl_QQ = string.format("http://gamecenter.qq.com/gcjump?appid={1105148805}&pf=invite&from=androidqq&plat=qq&originuin=" .. sdkGetOpenId() .. "&ADTAG=gameobj.msg_heart")
                                       sdkShareQQwithFriend(1, openId, title, desc, targetUrl_QQ, imageUrl, "", "MSG_HEART_SEND")
                                 end
                            end
                            MessageBoxYesNo(nil, string.format(game.getStrByKey("social_send_succ_tip"), v.nickName), yesFunc, nil, nil, nil)
                            break
                        end
                    end
                end
            end
        end,
        [RELATION_SC_GETENEMYWORD_RET] = function() 
            local t = g_msgHandlerInst:convertBufferToTable("GetEnemyWordRetProtocol", buff) 
            self.data.revengeDeclaration=t.word
        end,
        [RELATION_SC_CHANGEENEMYWORD_RET]=function() 
            TIPS({type =1 ,str = game.getStrByKey("social_revenge_declaration_set_success")})
        end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

------------------------------------------------------------------------------------------------
function SocialViewLayer:ctor(mainLayer)
	self.mainLayer = mainLayer
	self.data = {}

    self.tip = createLabel(self, "", cc.p(704/2, 372/2), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.white)

	local tableView = self:createTableView(self, cc.size(704, 372), cc.p(0, 0), true, true)
end

function SocialViewLayer:updateData(data, isQQData, relationType)
	self.data = data
    self.isQQData = isQQData
    if relationType then
        self.tipStr = game.getStrByKey("social_tip_"..relationType)
    else
        self.tipStr = ""
    end

	self:updateUI()
end

function SocialViewLayer:updateUI()
	self:getTableView():reloadData()

    self.tip:setVisible(false)
    if self.data == nil or #self.data == 0 then
        if self.tipStr then
            self.tip:setString(self.tipStr)
            self.tip:setVisible(true)
        end
    end
end

function SocialViewLayer:clearSelected()
	if self.selectIndex then
		local selectCell = self:getTableView():cellAtIndex(self.selectIndex)
		if selectCell then
			local flagSpr = selectCell:getChildByTag(10)
			if flagSpr then
				removeFromParent(flagSpr)
			end

            local lab = selectCell:getChildByTag(11)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(12)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(13)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
            lab = selectCell:getChildByTag(14)
            if lab ~= nil then lab:setColor(cc.c3b(187, 141, 107)) end
		end
	end
	self.selectIndex = nil
end

function SocialViewLayer:tableCellTouched(table, cell)
    if self.isQQData then
        return
    end

	local index = cell:getIdx()

	if self.selectIdx == index then
		return 
	else
		self:clearSelected()

		local flagSpr = createSprite(cell, "res/common/bg/titleBg4-1.png", cc.p(0, 35), cc.p(0, 0.5))
        flagSpr:setScale(1.44, 1.4)
		flagSpr:setTag(10)

        local lab = cell:getChildByTag(11)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(12)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(13)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
        lab = cell:getChildByTag(14)
        if lab ~= nil then lab:setColor(MColor.lable_yellow) end
	end

	self.selectIndex = index
    self.mainLayer:onSelDataIndex(index+1)
end

function SocialViewLayer:cellSizeForTable(table, idx)
    if self.isQQData then
        return 105, 490
    end 
    return 70, 490
end

function SocialViewLayer:tableCellAtIndex(table, idx)
	local record = self.data[idx+1]

	local cell = table:dequeueCell()

	local function getSchoolStr(school, sex)
		local sexStrTab = 
		{
			game.getStrByKey("man"),
			game.getStrByKey("female"),
		}
		local schoolStrTab = 
		{
			game.getStrByKey("zhanshi"),
			game.getStrByKey("fashi"),
			game.getStrByKey("daoshi"),
		}
        --dump(school)
        --dump(sex)
		return sexStrTab[sex]..schoolStrTab[school]
	end

	local function getOnlineStr(isOnline)
		if isOnline == true then
			return game.getStrByKey("online")
		else
			return game.getStrByKey("offline")
		end
	end

	local function getOnlineColor(isOnline)
		if isOnline == true then
			return MColor.green
		else
			return cc.c3b(187, 141, 107)
		end
	end

    local function createCellContentEx(cell)
        local posY = 50
        local cellBg = createSprite(cell, "res/common/table/cell21.png", cc.p(0, 0), cc.p(0, 0))
        cellBg:setScale(1, 1.45)

        if idx == 0 then
            createSprite(cell, "res/ranking/no_1.png", cc.p(48, 50), cc.p(0.5, 0.5))
        elseif idx == 1 then
            createSprite(cell, "res/ranking/no_2.png", cc.p(48, 50), cc.p(0.5, 0.5))
        elseif idx == 2 then
            createSprite(cell, "res/ranking/no_3.png", cc.p(48, 50), cc.p(0.5, 0.5))
        else
            createLabel(cell, idx+1, cc.p(48, 50), cc.p(0.5, 0.5), 30, false, nil, nil, MColor.white)
        end

        createSprite(cell, "res/common/bg/itemBg.png", cc.p(130, 50), cc.p(0.5, 0.5))
        dump(record.sdkData)
        if record.sdkData and record.sdkData.pictureSmall then
            local head = HttpSprite:create("res/layers/friend/default.png", record.sdkData.pictureSmall)
            if head then
                head:setAnchorPoint(cc.p(0.5, 0.5))
                head:setPosition(cc.p(130, 50))
                head:setScale(1.75)
                cell:addChild(head)
            end
        end

        --添加QQvip信息
       -- if LoginUtils.isQQLogin() or isWindows() then
        if isWindows() then--暂时关闭qq登录等
            if game.getVipLevel(record.openId) == 1 then
                createSprite(cell,"res/layers/qqMember/vip.png",cc.p(150,25),cc.p(0.5,0.5))
            elseif game.getVipLevel(record.openId) == 2 then
                createSprite(cell,"res/layers/qqMember/svip.png",cc.p(150,25),cc.p(0.5,0.5))
            end
        end

        require("src/utf8")
        local qqStartOff = 0
        if record.sdkData and record.sdkData.nickName then
            local name = record.sdkData.nickName
            local newName = name
            if string.len(name) > 20 then
                local strOrigin = string.utf8sub(name,1,10)
                newName = string.format(strOrigin .. "...")
            end
            local lab = createLabel(cell, newName, cc.p(190, 60), cc.p(0, 0), 20, false, nil, nil, MColor.yellow)
            qqStartOff = lab:getContentSize().width
        end

        --if (not LoginUtils.isReviewServer() or isWindows()) then 
        if isWindows() then  --暂时关闭qq登录等         
            if record.startType == 2 then
                createTouchItem(cell,"res/layers/qqMember/qqstart.png",cc.p(250 + qqStartOff, 73),nil)
            elseif record.startType == 1 then 
                createTouchItem(cell,"res/layers/qqMember/wxstart.png",cc.p(250 + qqStartOff, 73),nil)
            else
                if LoginUtils.isQQLogin() then
                    local btn = createTouchItem(cell,"res/layers/qqMember/qqstart.png",cc.p(250 + qqStartOff, 73),nil)
                    btn:addColorGray()
                else
                    local btn = createTouchItem(cell,"res/layers/qqMember/wxstart.png",cc.p(250 + qqStartOff, 73),nil)
                    btn:addColorGray()
                end
            end
        end

        createLabel(cell, getSchoolStr(record.school, record.sex), cc.p(190, 35), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
        createLabel(cell, record.lv..game.getStrByKey("faction_player_level"), cc.p(260, 35), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
        createLabel(cell, record.name, cc.p(190, 10), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
        createLabel(cell, game.getStrByKey("combat_power").."：", cc.p(340, 35), cc.p(0, 0), 20, false, nil, nil, MColor.lable_yellow)
        createLabel(cell, record.fight, cc.p(340, 10), cc.p(0, 0), 20, false, nil, nil, MColor.white)

        if record.sdkData and record.sdkData.isMe then
            return
        end

        local getBtn
        local function getBtnFunc()
            local t = {}
            t.dealType = dealTypeGet
            t.roleSID = record.roleId
            --dump(t.roleSID)
            g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_DEALGIFT, "DealgiftProtocol", t)

            startTimerAction(self, 0.3, false, function() getBtn:setEnabled(false) record.canPickGift=false end)
        end
        getBtn = createMenuItem(cell, "res/component/button/48.png", cc.p(525, posY), getBtnFunc)
        createLabel(getBtn, game.getStrByKey("social_qq_get"), getCenterPos(getBtn), cc.p(0.5, 0.5), 20, true)

        local sendBtn
        local function sendBtnFunc()
            local t = {}
            t.dealType = dealTypeSend
            t.roleSID = record.roleId
            --dump(t.roleSID)
            g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_DEALGIFT, "DealgiftProtocol", t)

            startTimerAction(self, 0.3, false, function() sendBtn:setEnabled(false) record.canGift=false end)
        end
        sendBtn = createMenuItem(cell, "res/component/button/48.png", cc.p(635, posY), sendBtnFunc)
        createLabel(sendBtn, game.getStrByKey("social_qq_send"), getCenterPos(sendBtn), cc.p(0.5, 0.5), 20, true)

        if record.canGift then
            sendBtn:setEnabled(true)
        else
            sendBtn:setEnabled(false)
        end

        if record.canPickGift then
            getBtn:setEnabled(true)
        else
            getBtn:setEnabled(false)
        end
    end

	local function createCellContent(cell)
        if self.isQQData then
            createCellContentEx(cell)
            return
        end

		local posY = 35
		createSprite(cell, "res/common/table/cell21.png", cc.p(0, 0), cc.p(0, 0))
		createLabel(cell, record.name, cc.p(75, posY), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),11)
		createLabel(cell, record.lv..game.getStrByKey("faction_player_level"), cc.p(160, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),13)
        createLabel(cell, tostring(record.fight), cc.p(310, posY), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),12)
		createLabel(cell, getSchoolStr(record.school, record.sex), cc.p(400, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),14)
		createLabel(cell, getOnlineStr(record.online), cc.p(525, posY), cc.p(0, 0.5), 22, true, nil, nil, getOnlineColor(record.online))
		if idx == self.selectIdx then
			local flagSpr = createSprite(cell, "res/common/bg/titleBg4-1.png", cc.p(0, 25), cc.p(0, 0.5))
			flagSpr:setTag(10)
		end

		local function privateFunc()
			PrivateChat(record.name)
		end
		if self.mainLayer and self.mainLayer.m_curTab ~= 3 then
			local privateBtn = createTouchItem(cell, "res/component/button/48.png", cc.p(645, posY), privateFunc)
			createLabel(privateBtn, game.getStrByKey("private_chat"), getCenterPos(privateBtn), cc.p(0.5, 0.5), 22, true)
		end
	end

	if nil == cell then
		cell = cc.TableViewCell:new() 
		createCellContent(cell)
    else
    	cell:removeAllChildren()
    	createCellContent(cell)
    end

    return cell
end

function SocialViewLayer:numberOfCellsInTableView(table)
    if self.data then
        return #self.data
    else
	   return 0
    end
end

--复仇宣言输入框
------------------------------------------------------------------------------------------------
function RevengeDeclarationNode:ctor(str)
	self.declarationStr = str or game.getStrByKey("social_revenge_declaration_input_tips")

	local function setDeclaration(str)
		if self.richText then
			removeFromParent(self.richText)
			self.richText = nil
		end

		self.richText = require("src/RichText").new(self.bg, cc.p(self.bg:getContentSize().width/2, 175), cc.size(300, 100), cc.p(0.5, 0.5), 25, 20, MColor.lable_yellow)
	 	self.richText:addText(str)
	 	self.richText:format()
	end

	local editBoxHandler = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用
        	setDeclaration("")
        	self.editBox:setText(self.declarationStr)
        elseif strEventName == "ended" then --编辑框完成时调用
        elseif strEventName == "return" then --编辑框return时调用
     		local str = self.editBox:getText()
     		str = checkShield(str)
     		dump(str)
	    	if str and string.utf8len(str) > 15 then
				TIPS({type =1 ,str = game.getStrByKey("social_revenge_declaration_input_num_error")})
                self.declarationStr=string.utf8sub(str,1,15)
            elseif str == "" then
                self.declarationStr=game.getStrByKey("social_revenge_declaration_input_tips")
            else
				self.declarationStr = str
	    	end	
            setDeclaration(self.declarationStr)
			self.editBox:setText("")
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        end
	end
	
	local bg = createSprite(self, "res/common/bg/bg31.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg
    createScale9Sprite( self.bg , "res/common/bg/inputBg9.png",cc.p(bg:getContentSize().width/2, 175), cc.size(320 , 100 ) , cc.p( 0.5 , 0.5 ) )
    
	createLabel(bg, game.getStrByKey("social_revenge_declaration_title"), cc.p(bg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 22, true)
	createLabel(bg, game.getStrByKey("social_revenge_declaration_tip"),cc.p(bg:getContentSize().width/2, 93), cc.p(0.5, 0), 18, true, nil, nil, MColor.red)

	local editBox = createEditBox(bg, nil, cc.p(bg:getContentSize().width/2, 175), cc.size(300, 110), MColor.lable_yellow, 20)
	self.editBox = editBox
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	--editBox:setPlaceHolder(game.getStrByKey("social_revenge_declaration_input_tips"))
	editBox:setPlaceholderFontSize(20)
	editBox:registerScriptEditBoxHandler(editBoxHandler)
	
	
	local function closeFunc()
		removeFromParent(self)
	end
	local cancelBtn =createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2-100, 45), closeFunc)
    createLabel(cancelBtn, game.getStrByKey("cancel"), getCenterPos(cancelBtn), cc.p(0.5, 0.5), 22, true)
	local function sureFunc()
		--dump(self.declarationStr)
		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_SET_WORD, "iS", G_ROLE_MAIN.obj_id, self.teachStr)
		local t = {}
		t.word = self.declarationStr
		g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_CHANGEENEMYWORD, "ChangeEnemyWordProtocol", t)

		--g_msgHandlerInst:sendNetDataByFmtExEx(MASTER_CS_GET_WORD, "ii", G_ROLE_MAIN.obj_id, 0)
		
		--获取复仇宣言
        g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETENEMYWORD, "GetEnemyWordProtocol", {})
		--addNetLoading(MASTER_CS_GET_WORD, MASTER_SC_GET_WORD_RET)

		removeFromParent(self)
	end
	local sureBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2+100, 45), sureFunc)
	createLabel(sureBtn, game.getStrByKey("sure"), getCenterPos(sureBtn), cc.p(0.5, 0.5), 22, true)

	setDeclaration(self.declarationStr)

	registerOutsideCloseFunc(bg, closeFunc, true)
end
------------------------------------------------------------------------------------------------
return SocialNode