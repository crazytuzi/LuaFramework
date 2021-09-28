
--[[
    文件名：TeambattleChooseTeamMateLayer.lua
    描述：   守卫襄阳邀请页面
    创建人：  wusonglin
    创建时间：2016.7.20
-- ]]

local TeambattleChooseTeamMateLayer = class("TeambattleChooseTeamMateLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

--[[
-- 参数 params 中各项为：
    {
        copyID:    配置id   必传参数
        callback:  回调函数 全服邀请
        callback2: 回调函数 自动匹配
    }
]]
function TeambattleChooseTeamMateLayer:ctor(params)
	-- 初始化数据
    self.mCopyID = params.copyID
    self.mTeamID = params.teamID or ""
    -- print("----awaj okkkl--", self.mCopyID)
    self.mCallback  = params.callback
    self.mCallback2 = params.callback2
    self.mModuleID = params.moduleName or 0

    -- 请求网络数据
    self:requestGetFriendsOrGuildMembers(self.mCopyID)
end

function TeambattleChooseTeamMateLayer:initUI()
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    --背景
    self.mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(590, 690))
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)

	-- 提示文字
	local titleLabel = ui.newLabel({
        size = 30,
		text = TR("邀请好友"),
        color = cc.c3b(0xff, 0xee, 0xdD),
        outlineColor = cc.c3b(0x3f, 0x27,0x1f),
        outlineSize = 1,
	})
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
	titleLabel:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 35))
	self.mBgSprite:addChild(titleLabel)

    -- 提示文字
    local intro = TR("邀请好友或帮派成员会有战力加成")
    if self.mModuleID == ModuleSub.eExpedition then 
        intro = TR("邀请普通玩家奖励+5%,邀请帮派成员或好友奖励+10%")
    end     
    local font = ui.newLabel({
        size = 22,
        text = intro,
        color = Enums.Color.eBlack,
    })
    font:setAnchorPoint(cc.p(0.5, 0.5))
    font:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height - 90))
    self.mBgSprite:addChild(font)

	-- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(self.mBgSprite:getContentSize().width - 40, self.mBgSprite:getContentSize().height - 30),
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mBgSprite:addChild(closeBtn)

    --创建滚动层背景
    self.mViewBg = ui.newScale9Sprite("c_38.png", cc.size(540, 485))
    self.mViewBg:setAnchorPoint(cc.p(0.5, 0.5))
    self.mViewBg:setPosition(cc.p(self.mBgSprite:getContentSize().width / 2, self.mBgSprite:getContentSize().height / 2 - 10))
    self.mBgSprite:addChild(self.mViewBg)
    --创建滚动层
    self:createListview()
end

-- 创建列表
function TeambattleChooseTeamMateLayer:createListview()
	-- 创建ListView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(540, 450))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setItemsMargin(10)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(270, 20)
    self.mViewBg:addChild(self.mListView)

    for i, v in ipairs(self.mChoooseList) do
        self.mListView:pushBackCustomItem(self:createHeadView(i, v))
    end

    -- 没有好友显示按钮
    if not next(self.mChoooseList) then
        local tempSprite = ui.createEmptyHint(TR("暂无在线好友和帮派成员"))
        tempSprite:setPosition(320,610)
        self.mParentLayer:addChild(tempSprite)
    end
    -- 全服邀请
    local oneKeyInvite = ui.newButton({
        text = self.mModuleID == ModuleSub.eExpedition and TR("组队邀请") or TR("全服邀请"),
        normalImage = "c_28.png",
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        position = cc.p(200, 60),
        clickAction = function()
            local callback = self.mCallback
            LayerManager.removeLayer(self)
            if callback then 
                callback()
            end 
        end
    })
    self.mBgSprite:addChild(oneKeyInvite)

    -- 自动匹配
    local fightForMatch = ui.newButton({
        text = self.mModuleID == ModuleSub.eExpedition and TR("一键匹配") or TR("自动匹配"),
        normalImage = "c_28.png",
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        position = cc.p(440, 60),
        clickAction = function()
            local callback = self.mCallback2
            LayerManager.removeLayer(self)
            if callback then 
                callback()
            end     
        end
    })
    self.mBgSprite:addChild(fightForMatch)
    -- 保存按钮，引导使用
    self.fightForMatch = fightForMatch
end

-- 创建cell
function TeambattleChooseTeamMateLayer:createHeadView(index, data)
	-- body
	local custom_item = ccui.Layout:create()
    local width = 520
    local height = 120
    custom_item:setContentSize(cc.size(width, height))

    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cc.size(width, height))
    cellSprite:setPosition(cc.p(270, height / 2))
    local cellSize = cellSprite:getContentSize()
    custom_item:addChild(cellSprite)

    -- 设置头像
    local header = CardNode.createCardNode({
        resourceTypeSub = ResourcetypeSub.eHero,
        modelId = data.HeadImageId,
        pvpInterLv = data.DesignationId,
        fashionModelID = data.FashionModelId,
        IllusionModelId = data.IllusionModelId,
        allowClick = false,
        cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eAddMark,
            CardShowAttr.eSynthetic,
        },
    })
    header:setAnchorPoint(cc.p(0, 0.5))
    header:setPosition(cc.p(30, 60))
    custom_item:addChild(header)

    -- 标签
    local imageName = data.type == 1 and "c_57.png" or "c_58.png"
    local titleBg = ui.newSprite(imageName)
    titleBg:setAnchorPoint(cc.p(0, 1))
    titleBg:setScale(0.75)
    titleBg:setPosition(cc.p(30, cellSize.height - 15))
    custom_item:addChild(titleBg)

    local titleFont = data.type == 1 and TR("好 友") or TR("帮 派")
    local font = ui.newLabel({
        text = titleFont,
        size = 20,
    })
    font:setPosition(cc.p(25, 50))
    titleBg:addChild(font)
    font:setRotation(-45)

    -- 名字
    local lvLabel = ui.newLabel({
        text  = string.format("%s", data.Name),
        size = 24,
        color = Enums.Color.eBlack,
    })
    lvLabel:setPosition(cc.p(140, 80))
    lvLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(lvLabel)

    -- 战斗力
    local fapLabel = ui.newLabel({
        text  = TR("战斗力: "),
        size = 22,
        color = Enums.Color.eBlack,
    })
    fapLabel:setPosition(cc.p(140, 50))
    fapLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fapLabel)

    local fightLabel = ui.newLabel({
        text  = TR("%s", Utility.numberFapWithUnit(data.FAP)),
        size = 22,
        color = cc.c3b(0xd1, 0x7b,0x00),
    })
    fightLabel:setPosition(cc.p(230, 50))
    fightLabel:setAnchorPoint(cc.p(0, 0.5))
    custom_item:addChild(fightLabel)

    -- 邀请btn
    local button = ui.newButton({
        normalImage = "c_28.png",
        text = TR("邀请"),
        fontSize = 24,
        anchorPoint = cc.p(0.5, 0.5),
        position = cc.p(460, 60),
        outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
        clickAction = function()
            self:requestInviteFriends(self.mCopyID, data.PlayerId)
        end,
    })
    custom_item:addChild(button)

    return custom_item
end

--[[-------------网络请求---------------------]]--
--  获取好友成员
-- 组队副本 和 据守襄阳获取好友列表方法名不一样
function TeambattleChooseTeamMateLayer:requestGetFriendsOrGuildMembers(id)
    local moduleName = self.mModuleID == ModuleSub.eExpedition and "ExpeditionNode" or "TeambattleInfo"
    local methodName = self.mModuleID == ModuleSub.eExpedition and "GetHelpMembers" or "GetFriendsOrGuildMembers"
	HttpClient:request({
        moduleName = moduleName,
        methodName = methodName,
        svrMethodData = {id},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value

            -- 处理网络数据
		    self.mChoooseList = {}
		    for _, v in ipairs(dataInfo.FriendPlayer) do
		        local item = clone(v)
		        item.type = 1
		        table.insert(self.mChoooseList, item)
		    end
		    for _, v in ipairs(dataInfo.GuildPlayer) do
		        local isExist = false
		        for _, vv in ipairs(self.mChoooseList) do
		            if v.PlayerId == vv.PlayerId then
		                isExist = true
		                break
		            end
		        end
		        if not isExist then
		            local item = clone(v)
		            item.type = 2
		            table.insert(self.mChoooseList, item)
		        end
		    end
		    table.sort(self.mChoooseList, function(a, b)
		        return a.FAP > b.FAP
		    end)

            -- 创建列表
            self:initUI()
            -- 执行新手引导
            self:executeGuide()
        end,
    })
end

-- 发送组队邀请
-- 组队副本 和 据守襄阳邀请好友方法名不一样（参数：据守襄阳是节点ID和玩家ID  组队副本是：队伍ID和玩家ID）
function TeambattleChooseTeamMateLayer:requestInviteFriends(id, playerId)
    local moduleName = self.mModuleID == ModuleSub.eExpedition and "ExpeditionNode" or "TeambattleInfo"
    local methodName = self.mModuleID == ModuleSub.eExpedition and "InviteFriends" or "InviteFriends"
    HttpClient:request({
        moduleName = moduleName,
        methodName = methodName,
        svrMethodData = {self.mModuleID == ModuleSub.eExpedition and self.mTeamID or id, playerId},
        callback = function(data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                return
            end
            local dataInfo = data.Value
            ui.showFlashView({
                text = TR("发送组队邀请成功"),
            })

        end,
    })
end

----[[---------------------新手引导---------------------]]--
-- 执行新手引导
function TeambattleChooseTeamMateLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 点击自动匹配
        [1190303] = {clickNode = self.fightForMatch},
    })
end

return TeambattleChooseTeamMateLayer
