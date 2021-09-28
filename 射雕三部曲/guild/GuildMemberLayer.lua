--[[
    文件名: GuildMemberLayer
    描述: 帮派成员
    创建人: chenzhong
    创建时间: 2017.03.06
-- ]]

local GuildMemberLayer = class("GuildMemberLayer",function()
	return cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
end)

--每页数量
local itemNumsOnePage = 8

function GuildMemberLayer:ctor()
	-- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    --是否展开下拉
    self.isExpanded = false
    --展开下拉的index
    self.expandIndex = nil
    --当前listview已经加载的条数  用于分页
    self.nowAddItemNum = 0

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --初始化页面控件
    self:initUI()

    --获取成员信息
    self:requestGetGuildMembers()
end

--初始化UI
function GuildMemberLayer:initUI()
    --背景
    local backImageSprite = ui.newScale9Sprite("c_34.jpg", cc.size(640, 1136))
    backImageSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(backImageSprite)

	--关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1050),
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn)

    --在线成员
    local activePlayerBg = ui.newSprite("c_41.png")
    activePlayerBg:setPosition(120, 1040)
    self.mParentLayer:addChild(activePlayerBg)
    self.activePlayerLabel = ui.newLabel({
        text = TR("在线成员: %d/%d", 0, 0),
        size = 24,
        outlineColor = Enums.Color.eBlack,
        color = Enums.Color.eNormalWhite,
        x = 100,
        y = 1040,
    })
    self.mParentLayer:addChild(self.activePlayerLabel)

    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610, 840))
    listBg:setAnchorPoint(cc.p(0.5, 1))
    listBg:setPosition(320, 1005)
    self.mParentLayer:addChild(listBg)
    --成员列表
    self.playerListView = ccui.ListView:create()
    self.playerListView:setContentSize(cc.size(630, 820))
    self.playerListView:setAnchorPoint(cc.p(0.5,1))
    self.playerListView:setPosition(cc.p(320, 995))
    self.playerListView:setItemsMargin(10)
    self.playerListView:setDirection(ccui.ListViewDirection.vertical)
    self.playerListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.playerListView:setBounceEnabled(true)
    self.mParentLayer:addChild(self.playerListView)

    --listview添加监听
    self.playerListView:addScrollViewEventListener(function(sender, eventType)
        if eventType == 6 then  --BOUNCE_BOTTOM
            if self.nowAddItemNum >= #self.GuildMembersInfo then
                return
            end

            self:refreshListView()
        end
    end)

    --不是帮主就加上退出帮派按钮
    local myPostId = GuildObj:getPlayerGuildInfo().PostId
    if myPostId ~= 34001001 then
        --退出帮派按钮
        local tcBtn = ui.newButton({
            normalImage = "c_28.png",
            position = cc.p(320, 130),
            text = TR("退出帮派"),
            clickAction = function (sender)
        		MsgBoxLayer.addOKLayer(TR("每日第二次退出帮派后需要次日才能加入帮派,是否确定退出帮派?"),TR("提示"),
        			{{text = TR("确定"),clickAction = function(okLyaer)
        				self:requestExitGuild()
                        LayerManager.removeLayer(okLyaer)
        			end}},{}
        			)
            end
        })
        self.mParentLayer:addChild(tcBtn)
    end

    --顶部区域
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)
end

--刷新listView
function GuildMemberLayer:refreshListView()
    --更新列表  每次加载8条
    for i=1,itemNumsOnePage do
    	if self.nowAddItemNum >= #self.GuildMembersInfo then
    		break
    	end

    	self.nowAddItemNum = self.nowAddItemNum + 1
    	local data = self.GuildMembersInfo[self.nowAddItemNum]
    	self.playerListView:pushBackCustomItem(self:createPlayerCell(self.nowAddItemNum, data))
    end
end

--创建单个玩家信息
--[[
    params:
    table playerdata:
    {
        Id:玩家Id
        Name:玩家名称
        Lv:玩家等级
        Vip:玩家Vip等级
        HeadImageId:玩家头像
        IsActive:玩家是否在线
        OutTime:玩家离线时间
        FundTotal:玩家累积帮派资源
        BuildTime:建设间隔
        BuildType:上次建设建设类型
        PostId:权限Id
        IsFriend:是否是好友(1:是0:否)
    }
]]
function GuildMemberLayer:createPlayerCell(listIndex, playerdata)
	local cellSize = cc.size(592, 127)

    --添加背景
    local backImageSprite = ui.newScale9Sprite("c_18.png", cellSize)
    backImageSprite:setPosition(cellSize.width / 2, cellSize.height / 2)

    --容器
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)
    layout:addChild(backImageSprite)
    
    --头像
    local headerSpr = CardNode.createCardNode({
    	resourceTypeSub = ResourcetypeSub.eHero,
        modelId = playerdata.HeadImageId,
        fashionModelID = playerdata.FashionModelId,
        IllusionModelId = playerdata.IllusionModelId,
        pvpInterLv = playerdata.DesignationId,
        cardShowAttrs = {CardShowAttr.eBorder},
        onClickCallback = function ()

        end
        })
    headerSpr:setPosition(35 ,cellSize.height/2)
    headerSpr:setAnchorPoint(cc.p(0,0.5))
    layout:addChild(headerSpr)

    --名称
    local nameLabel = ui.newLabel({
        text = playerdata.Name,
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 22,
        x = 150,
        y = 90,
        anchorPoint = cc.p(0,0.5)
    })
    layout:addChild(nameLabel)

    --等级
    local lvLabel = ui.newLabel({
        text = TR("等级: #d17b00%s", playerdata.Lv),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = 150,
        y = 60,
        anchorPoint = cc.p(0,0.5),
    })
    layout:addChild(lvLabel)

    --战力
    local fapLabel = ui.newLabel({
        text = TR("战力: #d17b00%s", Utility.numberFapWithUnit(playerdata.FAP)),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = 300,
        y = 60,
        anchorPoint = cc.p(0,0.5),
    })
    layout:addChild(fapLabel)


    --vip等级
    local vipNode = ui.createVipNode(playerdata.Vip)
    vipNode:setPosition(300, 95)
    layout:addChild(vipNode)

    --职务
    local dutyLabel = ui.newLabel({
        text = TR("职位: #d17b00%s", GuildPostModel.items[playerdata.PostId].name),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = 150,
        y = 30,
        anchorPoint = cc.p(0,0.5),
        --font = _FONT_PANGWA,
    })
    layout:addChild(dutyLabel)

    --贡献
    local donateLabel = ui.newLabel({
        text = TR("贡献: #d17b00%d", playerdata.FundTotal),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 20,
        x = 300,
        y = 30,
        anchorPoint = cc.p(0,0.5),
        --font = _FONT_PANGWA,
    })
    layout:addChild(donateLabel)

    -- 当前建设的类型
    local buildTypePic = {[34004001] = "tb_135.png", [34004002] = "tb_136.png", [34004003] = "tb_137.png"}
    local currentType = playerdata.TodayBuildType or 0
    if buildTypePic[currentType] then
        local typeSprite = ui.newSprite(buildTypePic[currentType])
        typeSprite:setPosition(cc.p(320, cellSize.height / 2))
        typeSprite:setAnchorPoint(cc.p(0, 0.5))
        layout:addChild(typeSprite)
    end     

    --状态
    local str = ""
    local color = nil
    if playerdata.IsActive == true then
        local stateSprite = ui.newSprite("c_42.png")
        stateSprite:setPosition(520, 80)
        backImageSprite:addChild(stateSprite)
    else
        local tempStr = string.utf8sub(MqTime.toDownFormat(playerdata.OutTime), 1, -2)
        local stateValueLabel = ui.newLabel({
            text = TR("【离线%s】", tempStr),
            size = 20,
            x = 520,
            y = 80,
            color = Enums.Color.eRed,
            --font = _FONT_PANGWA,
        })
        backImageSprite:addChild(stateValueLabel)
    end

    --三角形初始旋转角度
    local initRotation = 0

    --操作按钮
    layout.sjxSpr = ui.newButton({
        normalImage = "c_43.png",
        position = cc.p(525, 40),
        clickAction = function (sender)
            -- 先删除并且纪录位置
            local scrollPos = self.playerListView:getInnerContainerPosition()
            if self.isExpanded then
                self.playerListView:removeItem(self.expandIndex + 1) --加上下拉框时  下拉框为下面一个
                if self.expandIndex ~= self.playerListView:getIndex(layout) then
                    self.playerListView:getItem(self.expandIndex).sjxSpr:setRotation(initRotation)
                end
            end

            local index = self.playerListView:getIndex(layout)

            if self.expandIndex == index then
                self.isExpanded = false
                self.expandIndex = nil
            else
                self.playerListView:insertCustomItem(self:createExpandCell(playerdata), index + 1)
                self.expandIndex = index
                self.isExpanded = true

                --如果在最后一个,滑动到底部
                if listIndex == table.nums(self.playerListView:getItems()) - 1 then
                    self.playerListView:jumpToBottom()
                end
                
            end
            
            -- -- 重新设置，需要延时才有效果
            Utility.performWithDelay(self, function()
                self.playerListView:setInnerContainerPosition(scrollPos)
            end,0.1)

            if layout.sjxSpr:getRotation() == initRotation then
                layout.sjxSpr:setRotation(initRotation + 180)
            else
                layout.sjxSpr:setRotation(initRotation)
            end
        end
    })
    layout:addChild(layout.sjxSpr)
    layout.sjxSpr:setRotation(initRotation)

    if playerdata.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
        layout.sjxSpr:setVisible(false)
    end

    return layout
end

--创建展开cell
--[[
    params:
    table playerdata:
    {
        Id:玩家Id
        Name:玩家名称
        Lv:玩家等级
        PostId:权限Id
    }
]]
function GuildMemberLayer:createExpandCell(playerdata)
    --容器
    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(620, 100))

    local backImageSprite = ui.newScale9Sprite("bp_22.png", cc.size(620, 100))
    backImageSprite:setPosition(cc.p(310, 60))
    layout:addChild(backImageSprite)

    --是否有踢出帮派权限
    local canKick = GuildObj:havePost(GuildAuth.eMemberOut)

    local btnData = {
    	[1] = {
    		text = TR("看阵容"),
    		isNeed = true,    --是否需要显示
    		clickAction = function ()
    			Utility.showPlayerTeam(playerdata.Id)
    		end
    	},
    	[2] = {
    		text = TR("加好友"),
    		isNeed = playerdata.IsFriend == false and not PlayerAttrObj:isPlayerSelf(playerdata.Id),
    		clickAction = function (sender)
                local btnInfos = {
                    {
                        text = TR("发送"),
                        clickAction = function(layerObj, btnObj)
                            -- 获取发送的内容
                            local message = self.mEditBox:getText()
                            self:requestFriendApply(playerdata.Id, message, layerObj)
                        end,
                    },
                    {
                        text = TR("关闭"),
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                        end,
                    },
                }

                local tempData = {
                    -- bgSize = cc.size(590, 588),
                    title = TR("好友请求"),
                    notNeedBlack = true,
                    msgText = "",
                    closeBtnInfo = {},
                    btnInfos = btnInfos,
                    DIYUiCallback = function(layer, layerBgSprite, layerBgSize)
                        -- 发送内容给xxx(名字)
                        local sendLabel = ui.newLabel({
                            text = TR("发送给%s的请求:", playerdata.Name),
                            color = cc.c3b(0x46, 0x22, 0x0d),
                        })
                        sendLabel:setAnchorPoint(cc.p(0, 1))
                        sendLabel:setPosition(40, layerBgSize.height - 70)
                        layerBgSprite:addChild(sendLabel)

                        -- 输入框
                        self.mEditBox = ui.newEditBox({
                            image = "c_17.png",
                            size = cc.size(500, 130),
                            fontSize = 30,
                            fontColor = Enums.Color.eNormalWhite,
                            multiLines = true,
                        })
                        self.mEditBox:setPlaceHolder(TR("请在这里输入内容"))
                        self.mEditBox:setPlaceholderFontSize(30)
                        self.mEditBox:setPosition(cc.p(286, 168))
                        layerBgSprite:addChild(self.mEditBox)
                    end,
                }
                LayerManager.addLayer({
                    name = "commonLayer.MsgBoxLayer",
                    data = tempData,
                    cleanUp = false,
                })
            end
    	},
    	[3] = {
    		text = TR("踢出"),
    		isKick = true,   -- 是否是剔除按钮，还要用做权限大小的判断
    		isNeed = canKick and not PlayerAttrObj:isPlayerSelf(playerdata.Id),
    		clickAction = function (sender)
            	MsgBoxLayer.addOKLayer(TR("是否确定踢出玩家%s?", playerdata.Name), TR("提示"),
        			{{text = TR("确定"),
                    clickAction = function(layobj,btnObj)
        				self:requestKickOutGuild(playerdata)
                        LayerManager.removeLayer(layobj)
        			end}},{})
            end
    	}
	}

	local btnNum = 3

	-- if PlayerAttrObj:isPlayerSelf(playerdata.Id) then
	-- 	btnNum = 1
	-- else
		if playerdata.IsFriend then
			btnNum = btnNum - 1
		end

		if not canKick then
			btnNum = btnNum - 1
		end
	-- end

	local posxI = 1 --用于计算位置的一个变量

	for i,v in ipairs(btnData) do
		if v.isNeed then
			-- local mid = (1 + btnNum) * 0.5
			-- local posx = 275 + (posxI - mid) * 180
            local posx = 530 - (btnNum - posxI) * 220
			posxI = posxI + 1

			local useBtn = ui.newButton({
				normalImage = "c_28.png",
				text = v.text,
				position = cc.p(posx, 50),
				clickAction = v.clickAction
			})
			backImageSprite:addChild(useBtn)

			--只能踢出职位小于自己的
			if v.isKick then
	            if GuildObj:getPlayerGuildInfo().PostId >= playerdata.PostId then
	                useBtn:setEnabled(false)
	            end
	        end
		end
	end

    return layout
end

-- =============================== 请求服务器数据相关函数 ===================

--获取成员信息
function GuildMemberLayer:requestGetGuildMembers()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GetGuildMembers",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            local value = response.Value

            self.GuildMembersInfo = value.GuildMembersInfo
            --先进行排序
			table.sort( self.GuildMembersInfo, function (a, b)
		        if a.IsActive and not b.IsActive then
		            return true
		        elseif not a.IsActive and b.IsActive then
		            return false
		        elseif a.PostId ~= b.PostId then
		            return a.PostId < b.PostId
		        elseif a.Vip ~= b.Vip then
		            return a.Vip > b.Vip
		        else
		            return a.FundTotal > b.FundTotal
		        end
		    end )

		 --    local testData = {
		 --    	Id = "xxxx",
   --          	Name = "测试",
   --          	Lv = 20,
   --          	Vip = 5,
   --          	HeadImageId = 12011302,
   --          	IsActive = false,
   --          	OutTime = 48,
   --          	FundTotal = 10,
   --          	PostId = 34001004,
   --          	IsFriend = 0,
			-- }

			-- for i=1,30 do
			-- 	table.insert(self.GuildMembersInfo, testData)
			-- end

			--计算在线人数
			self.activePlayer = 0
		    for k,v in pairs(self.GuildMembersInfo) do
		        if v.IsActive == true then
		            self.activePlayer = self.activePlayer + 1
		        end
		    end

		    --更新在线人数
		    self.activePlayerLabel:setString(TR("在线成员: %s%d/%d","#a8ff5b", self.activePlayer, #self.GuildMembersInfo))

            self:refreshListView()
        end,
    })
end

--退出帮派
function GuildMemberLayer:requestExitGuild()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "ExitGuild",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --转到游戏主页
            LayerManager.addLayer({
                name = "home.HomeLayer",
                isRootLayer = true,
                })

            --清除帮派缓存数据
            GuildObj:reset()
        end,
    })
end

--剔除成员
function GuildMemberLayer:requestKickOutGuild(playerdata)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "KickOutGuild",
        svrMethodData = {playerdata.Id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            
            --删除扩展框
            self.playerListView:removeItem(self.expandIndex + 1)
            --删除玩家
            self.playerListView:removeItem(self.expandIndex)
            --重置数据
            self.expandIndex = nil
            self.isExpanded = false
            --更新本页数据显示
            if playerdata.IsActive then
                self.activePlayerLabel:setString(TR("在线成员: %s%d/%d",Enums.Color.eNormalGreenH ,self.activePlayer - 1, GuildObj:getGuildInfo().MemberCount))
            else
                self.activePlayerLabel:setString(TR("在线成员: %s%d/%d",Enums.Color.eNormalGreenH, self.activePlayer, GuildObj:getGuildInfo().MemberCount))
            end
        end,
    })
end

function GuildMemberLayer:requestFriendApply(playerId, message, layer)
    HttpClient:request({
        moduleName = "FriendMessage",
        methodName = "FriendApply",
        svrMethodData = {playerId, message},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.showFlashView(TR("发送好友请求成功"))

            -- 离开该页面
            LayerManager.removeLayer(layer)
        end
    })
end

return GuildMemberLayer