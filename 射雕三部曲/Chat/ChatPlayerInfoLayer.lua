--[[
	filename:ChatPlayerInfoLayer.lua
	desc:点击聊天里的任务会进入玩家信息页面
	author:yanghongsheng
	date:2017年07月20日
--]]

local ChatPlayerInfoLayer = class("ChatPlayerInfoLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--构造函数
--[[
	table params:
	{
		playerId = "", 玩家Id
        forbidCleanUp = false, -- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
        selectCb = nil, -- 选中玩家的回调函数,参数为: (layerObj, selectPlayerId)
        isStudy = nil, 是否显示切磋功能
	}
	return:
--]]
function ChatPlayerInfoLayer:ctor(params)
	params = params or {}

	-- 当前选中玩家的PlayerId
    self.mSelectPlayerId = params.playerId
    self.mIsStudy = params.isStudy or false
    -- 只有首页显示切磋功能
    if LayerManager.getTopCleanLayerName() ~= "home.HomeLayer" then
    	self.mIsStudy = false
    end

	self.mBgSize = cc.size(580, 370)

	-- 是否禁止该页面跳转到其他页面时LayerManager.addLayer函数的cleanUp参数为true, 默认为false
    self.mForbidCleanUp = params.forbidCleanUp
    -- 
    self.selectCb = params.selectCb

    --玩家id
    self.mPlayerId = params.playerId

    -- 屏蔽下层触摸
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
	self:initUI()
end

function ChatPlayerInfoLayer:initUI()
	-- 创建界面背景
    self.mBgSprite = ui.newScale9Sprite("mrjl_02.png", self.mBgSize)
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)
    -- 标题
    local bgSize = self.mBgSprite:getContentSize()
    local titleLabel = ui.newLabel({
        text = TR("玩家信息"),
        size = Enums.Fontsize.eTitleDefault,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x42, 0x2d, 0x25),
    })
    titleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    titleLabel:setPosition(bgSize.width*0.5, bgSize.height - 36)
    self.mBgSprite:addChild(titleLabel)
    -- 创建人物信息
	FriendObj:requestGetPlayerInfoById(self.mPlayerId, function(playerInfo)
		-- dump(playerInfo, "HelloWorld")
		self:createPlayerBaseInfo(playerInfo.Value)
	end)
	-- 加为好友
	local addFriendBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("加为好友"),
			clickAction = function ()
				local isFriend = FriendObj:playerIsFriend(self.mSelectPlayerId)
				if not isFriend then
					FriendObj:requestFriendApply(self.mSelectPlayerId)
				else
					ui.showFlashView({text = TR("已经是好友了")})
				end
			end
		})
	addFriendBtn:setPosition(self.mIsStudy and bgSize.width*0.45 or bgSize.width*0.35, bgSize.height*0.35)
	self.mBgSprite:addChild(addFriendBtn)
	-- 屏蔽发言
	local shieldBtn = ui.newButton({
			normalImage = "c_33.png",
			text = TR("屏蔽发言"),
			clickAction = function ()
				local isEnemy = EnemyObj:isEnemyPlayer(self.mSelectPlayerId)
				if isEnemy then
					ui.showFlashView(TR("该玩家已在屏蔽列表中"))
					return
				end

				local playerInfo = ChatMng:getChatPlayerInfo(self.mSelectPlayerId)
				if playerInfo then
					EnemyObj:addEnemy(playerInfo)
				else
					ui.showFlashView(TR("不能屏蔽没有聊天记录的玩家"))
				end
			end
		})
	shieldBtn:setPosition(self.mIsStudy and bgSize.width*0.8 or bgSize.width*0.7, bgSize.height*0.35)
	self.mBgSprite:addChild(shieldBtn)
	-- 私聊
	local chatBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("私聊"),
			clickAction = function ()
				if self.selectCb then
	                self.selectCb(self, self.mSelectPlayerId)
	            else
	                LayerManager.removeLayer(self)
	                LayerManager.addLayer({
	                    name = "Chat.ChatLayer",
	                    data = {
	                        chatChanne = Enums.ChatChanne.ePrivate,
	                        privateId = self.mSelectPlayerId,
	                    },
	                    cleanUp = false
	                })
	            end
			end
		})
	chatBtn:setPosition(self.mIsStudy and bgSize.width*0.45 or bgSize.width*0.35, bgSize.height*0.18)
	self.mBgSprite:addChild(chatBtn)
	-- 阵容
	local teamBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("阵容"),
			clickAction = function ()
                if self.mForbidCleanUp then
                    ui.showFlashView(TR("当前正在组队或战斗中，不能查看其他玩家阵容"))
                    return 
                end
				Utility.showPlayerTeam(self.mSelectPlayerId, false)
			end
		})
	teamBtn:setPosition(self.mIsStudy and bgSize.width*0.8 or bgSize.width*0.7, bgSize.height*0.18)
	self.mBgSprite:addChild(teamBtn)

	-- 切磋按钮
	if self.mIsStudy then
		local studyBtn = ui.newButton({
				normalImage = "tb_303.png",
				clickAction = function ()
					-- 开放等级
					local openLv = 20
					if PlayerAttrObj:getPlayerAttrByName("Lv") < openLv then
						ui.showFlashView(TR("%d级开启切磋功能", openLv))
						return
					end

					-- 已在战斗中
					if LayerManager.getTopCleanLayerName() == "ComBattle.BattleLayer" then
						ui.showFlashView(TR("已在战斗中"))
						return
					end

					self:requestFight()
				end
			})
		studyBtn:setPosition(bgSize.width*0.2, bgSize.height*0.27)
		self.mBgSprite:addChild(studyBtn)
	end

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mCloseBtn:setPosition(self.mBgSize.width - 38, self.mBgSize.height - 35)
    self.mBgSprite:addChild(self.mCloseBtn)
end

function ChatPlayerInfoLayer:createPlayerBaseInfo(playerInfo)
	-- 人物名片背景
    local itemSize = cc.size(526, 130)
	local itemBg = ui.newScale9Sprite("c_65.png", itemSize)
	itemBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.6)
	self.mBgSprite:addChild(itemBg)
	-- 创建玩家头像
    local headType = math.floor(playerInfo.HeadImageId / 10000)-- 幻化或者hero的modelId是一个字段
	local headCard = CardNode.createCardNode({
		resourceTypeSub = Utility.isIllusion(headType) and ResourcetypeSub.eIllusion or ResourcetypeSub.eHero,
		modelId = playerInfo.HeadImageId,
        fashionModelID = playerInfo.FashionModelId,
		pvpInterLv = playerInfo.DesignationId,
		cardShowAttrs = {CardShowAttr.eBorder},
		allowClick = false,
	})
	headCard:setPosition(itemSize.width*0.11, itemSize.height*0.5)
	itemBg:addChild(headCard)
	-- 玩家姓名
	local playerName = ui.newLabel({
			text = playerInfo.Name,
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 24,
		})
	playerName:setAnchorPoint(cc.p(0, 0))
	playerName:setPosition(itemSize.width*0.22, itemSize.height*0.55)
	itemBg:addChild(playerName)
	-- 等级
	local playerLv = ui.newLabel({
		text = TR("等级: %s%d", "#d17b00", playerInfo.Lv),
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 24,
	})
	playerLv:setAnchorPoint(cc.p(0, 0))
	playerLv:setPosition(itemSize.width*0.22, itemSize.height*0.2)
	itemBg:addChild(playerLv)
	-- 战力
	local FAPStr = Utility.numberFapWithUnit(playerInfo.FAP)
	local playerFap = ui.newLabel({
		text = TR("战斗力: %s%s", "#20781b", FAPStr),
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 24,
	})
	playerFap:setAnchorPoint(cc.p(0, 0))
	playerFap:setPosition(itemSize.width*0.55, itemSize.height*0.55)
	itemBg:addChild(playerFap)
	-- 帮派
	local strGuildName = TR("未加入任何帮派")
	if (playerInfo.GuildName ~= nil) and (playerInfo.GuildName ~= "") then
		strGuildName = playerInfo.GuildName
	end
	local playerGuild = ui.newLabel({
		text = TR("帮派: %s%s", "#d17b00", strGuildName),
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 24,
	})
	playerGuild:setAnchorPoint(cc.p(0, 0))
	playerGuild:setPosition(itemSize.width*0.55, itemSize.height*0.2)
	itemBg:addChild(playerGuild)
end

--------------------------------网络相关------------------------------------
-- 请求切磋
function ChatPlayerInfoLayer:requestFight()
	HttpClient:request({
    	moduleName = "PVP",
    	methodName = "Study",
    	svrMethodData = {self.mSelectPlayerId},
    	callback = function(response)
    		if not response or response.Status ~= 0 then
                return
            end
	        -- 进入战斗页面
            local value = response.Value
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(Enums.ClientModuld.eStudy)
            -- 玩家信息
            local targetPlayerInfo = ChatMng:getChatPlayerInfo(self.mSelectPlayerId).ExtendInfo
            -- 调用战斗页面
            LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    callback = function(retData)
                        PvpResult.showPvpResultLayer(
                            Enums.ClientModuld.eStudy,
                            value,
                            PlayerAttrObj:getPlayerInfo(),
                            {
				        		PlayerName = targetPlayerInfo.Name,
				        		FAP = targetPlayerInfo.Fap,
				        		HeadImageId = targetPlayerInfo.HeadImageId,
					        }
                        )

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
    	end
	})
end

return ChatPlayerInfoLayer








