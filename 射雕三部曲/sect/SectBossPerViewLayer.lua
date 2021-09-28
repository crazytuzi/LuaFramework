--[[
    SectBossPerViewLayer.lua
    描述: 门派boss预览页面
    创建人: lengjiazhi
    创建时间: 2017.11.24
-- ]]

local SectBossPerViewLayer = class("SectBossPerViewLayer", function()
    return display.newLayer()
end)

function SectBossPerViewLayer:ctor()
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
	self:requestGetBossInfo()
end

function SectBossPerViewLayer:initUI()

	local blackBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	blackBg:setContentSize(640, 1136)
	blackBg:setPosition(0, 0)
	self.mParentLayer:addChild(blackBg)

	local bgSprite = ui.newScale9Sprite("sy_25.png",cc.size(500, 350))
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	self.mBgSprite = bgSprite

	local titleSprite = ui.newSprite("mjrq_28.png")
	titleSprite:setPosition(320, 720)
	self.mParentLayer:addChild(titleSprite)

	-- 注册屏蔽下层页面事件
    ui.registerSwallowTouch({
        node = blackBg,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
        	if not ui.touchInNode(touch, self.mBgSprite) then
            	LayerManager.removeLayer(self)
            end
        end,
    })

end

--根据状态创建ui
function SectBossPerViewLayer:changeState()
	local curTime = Player:getCurrentTime()
	if curTime < self.mWorldBossStartTime then
		self:perviewUI()
	elseif curTime >= self.mWorldBossStartTime and curTime <  self.mWorldBossEndTime then
		if self.mIfHaveDeath then
			self:BossEndUI()
		else
			self:fightUI()
		end
	elseif curTime >= self.mWorldBossEndTime then
		self:BossEndUI()
	end
end
--预览的UI
function SectBossPerViewLayer:perviewUI()
	local bossInfo = WorldbossModel.items[self.mWorldBossModelID]
	local tipLabel = ui.newLabel({
		text = TR("%s 将在中午12点抵达门派！", bossInfo.name),
		size = 24,
		color = cc.c3b(0x46, 0x22, 0x0d),
		})
	tipLabel:setPosition(320, 650)
	self.mParentLayer:addChild(tipLabel)

	local tipSprite = ui.newSprite(bossInfo.touchPic..".png")
	tipSprite:setPosition(320, 560)
	tipSprite:setScale(1.3)
	self.mParentLayer:addChild(tipSprite)

    -- 设置规则按钮
    local ruleBtn = ui.newButton({
    	text = TR("查看规则"),
        normalImage = "c_28.png",
        position = cc.p(220, 460),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.魔教入侵玩法每天中午12点开启，达到48级的玩家即可参与。"),
                [2] = TR("2.魔教会随机出现在八大门派的探索地图中，请前往寻找并击退。"),
                [3] = TR("3.出击时，三角标记越靠近中心光点区域，伤害加成越高。"),
                [4] = TR("4.魔教被击退后或逃跑后，将通过领奖中心发放个人和帮派伤害的排行奖励。"),
                [5] = TR("5.魔教被击退后，会掉落稀有物品，所有玩家都可在拍卖行竞拍这些物品。"),
                [6] = TR("6.拍卖行将在魔教被击退后的5分钟内开启。"),
                [7] = TR("7.如果魔教在12:30之前未被击退则会逃跑，不会掉落稀有物品。"),
            })
        end})
    self.mParentLayer:addChild(ruleBtn)

	local dropBtn = ui.newButton({
		text = TR("掉落预览"),
		normalImage = "c_28.png",
		clickAction = function()
			self:showRewardLayer(self.mWorldBossModelID)
		end
		})
	dropBtn:setPosition(420, 460)
	self.mParentLayer:addChild(dropBtn)
end

--boss出现的ui
function SectBossPerViewLayer:fightUI()
	local bossInfo = WorldbossModel.items[self.mWorldBossModelID]
	local tipLabel = ui.newLabel({
		text = TR("%s 已出现，请前往击退！", bossInfo.name),
		size = 24,
		color = cc.c3b(0x46, 0x22, 0x0d),
		})
	tipLabel:setPosition(320, 650)
	self.mParentLayer:addChild(tipLabel)

	local tipSprite = ui.newSprite(bossInfo.touchPic..".png")
	tipSprite:setPosition(320, 560)
	tipSprite:setScale(1.3)
	self.mParentLayer:addChild(tipSprite)

	local goBtn = ui.newButton({
		text = TR("前往击杀"),
		normalImage = "c_28.png",
		clickAction = function()
			if not ModuleInfoObj:moduleIsOpen(ModuleSub.eSect, true) then
                return false
            end
            SectObj:getSectInfo(function(response)
                if response.IsJoinIn then
                    LayerManager.addLayer({
                        name = "sect.SectBigMapLayer",
                        data = {}
                    })
                else
                    LayerManager.addLayer({
                        name = "sect.SectSelectLayer",
                        data = {}
                    })
                end
            end)
		end
		})
	goBtn:setPosition(320, 460)
	self.mParentLayer:addChild(goBtn)
end

--boss结束的ui
function SectBossPerViewLayer:BossEndUI()
	local bossInfo = WorldbossModel.items[self.mWorldBossModelID]
	local tipLabel = ui.newLabel({
		text = TR("%s 已被击退，拍卖行已开启！", bossInfo.name),
		size = 24,
		color = cc.c3b(0x46, 0x22, 0x0d),
		})
	tipLabel:setPosition(320, 630)
	self.mParentLayer:addChild(tipLabel)

	if not self.mIfHaveDeath then
		tipLabel:setPosition(320, 650)
		tipLabel:setString(TR("%s 已逃走，未能开启拍卖行！", bossInfo.name))

		local tipLabel2 = ui.newLabel({
			text = TR("少侠请明天再来！"),
			size = 24,
			color = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabel2:setPosition(320, 610)
		self.mParentLayer:addChild(tipLabel2)
	end

	--排行
	local rankRewardBtn = ui.newButton({
		normalImage = "tb_16.png",
		clickAction = function ()
			LayerManager.addLayer({
                    name = "sect.SectBossRankLayer",
                    cleanUp = false,
                })
		end
		})
	rankRewardBtn:setPosition(220, 510)
	self.mParentLayer:addChild(rankRewardBtn)

	--排行
	local rankRewardBtn = ui.newButton({
		normalImage = "tb_127.png",
		clickAction = function ()
			 MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.魔教入侵玩法每天中午12点开启，达到48级的玩家即可参与。"),
                [2] = TR("2.魔教会随机出现在八大门派的探索地图中，请前往寻找并击退。"),
                [3] = TR("3.出击时，三角标记越靠近中心光点区域，伤害加成越高。"),
                [4] = TR("4.魔教被击退后或逃跑后，将通过领奖中心发放个人和帮派伤害的排行奖励。"),
                [5] = TR("5.魔教被击退后，会掉落稀有物品，所有玩家都可在拍卖行竞拍这些物品。"),
                [6] = TR("6.拍卖行将在魔教被击退后的5分钟内开启。"),
                [7] = TR("7.如果魔教在12:30之前未被击退则会逃跑，不会掉落稀有物品。"),
            })
		end
		})
	rankRewardBtn:setPosition(420, 510)
	self.mParentLayer:addChild(rankRewardBtn)
end

function SectBossPerViewLayer:showRewardLayer(bossId)
    local function msgDiyFunction(layer, layerBgSprite, layerSize)
        local bossInfo = WorldbossModel.items[bossId]
        -- 显示提示语
        local noticeLabel = ui.newLabel({
            text = TR("击杀 #D17B00%s%s 有几率掉落以下物品\n掉落物品要通过拍卖行竞拍获得", bossInfo.name, Enums.Color.eNormalWhiteH),
            size = 26,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(469, 74),
            align = cc.TEXT_ALIGNMENT_CENTER,
            x = 302,
            y = 473,
        })
        layerBgSprite:addChild(noticeLabel)

        -- 黑色背景框
        local blackSize = cc.size(524, 324)
        local blackBg = ui.newScale9Sprite("c_38.png", blackSize)
        blackBg:setAnchorPoint(0.5, 0)
        blackBg:setPosition(layerSize.width/2, 100)
        layerBgSprite:addChild(blackBg)

        -- 计算掉落的内容
        local dropList = {}
        local shopGroup = AuctionShop.items[bossInfo.killedMeetRewardId]
        for _,v in ipairs(shopGroup) do
            table.insert(dropList, Utility.analysisStrResList(v.auctionGoods)[1])
        end
        -- dump(dropList, "dropList")
        table.sort( dropList, function (a, b)
            local qA = Utility.getQualityByModelId(a.modelId, a.resourceTypeSub)
            local qB = Utility.getQualityByModelId(b.modelId, b.resourceTypeSub)
            if qA ~= qB then
                return qA > qB
            end
            return a.modelId < b.modelId
        end )
        -- 创建滑动框
        local totalHeight = 142 * math.ceil(#dropList / 4)
        local worldView = ccui.ScrollView:create()
        worldView:setContentSize(cc.size(497, 299))
        worldView:setPosition(cc.p(12, 12))
        worldView:setDirection(ccui.ScrollViewDir.vertical)
        worldView:setInnerContainerSize(cc.size(497, totalHeight))
        blackBg:addChild(worldView)

        -- 显示掉落内容
        for i,v in ipairs(dropList) do
            local tempCard = CardNode.createCardNode({
                resourceTypeSub = v.resourceTypeSub,
                modelId = v.modelId,
                num = v.num,
                cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
            })
            tempCard:setPosition(cc.p(((i - 1) % 4) * 125 + 63, totalHeight - math.floor((i - 1) / 4) * 142 - 60))
            worldView:addChild(tempCard)
        end
    end
    MsgBoxLayer.addDIYLayer({
        bgSize=cc.size(605, 597), 
        title=TR("掉落预览"), 
        closeBtnInfo={}, 
        DIYUiCallback = msgDiyFunction, 
        notNeedBlack=true
    })
end

--================================网络请求===============================
function SectBossPerViewLayer:requestGetBossInfo()
	HttpClient:request({
        moduleName = "WorldBossInfo",
        methodName = "GetWorldBossPreviewInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            dump(response)
            self.mIfHaveDeath = response.Value.IfHaveDeath
            self.mWorldBossStartTime = response.Value.WorldBossStartTime
            self.mWorldBossModelID = response.Value.WorldBossModelID
            self.mWorldBossEndTime = response.Value.WorldBossEndTime
            self:changeState()
        end
    })
end
return SectBossPerViewLayer