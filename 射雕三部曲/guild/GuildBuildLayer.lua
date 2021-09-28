--[[
    文件名: GuildBuildLayer
    描述: 帮派 建设
    创建人: chenzhong
    创建时间: 2016.06.06
-- ]]

local GuildBuildLayer = class("GuildBuildLayer",function()
	return display.newLayer()
end)

function GuildBuildLayer:ctor()
	-- 建筑模型Id列表
	self.mBuildModelIds = table.keys(GuildBuildtypeModel.items)
	table.sort(self.mBuildModelIds, function(Id1, Id2)
		return Id1 < Id2
	end)

	-- 建筑信息列表的大小
	self.mListSize = cc.size(640, 420)
	-- 列表条目的大小
	self.mCellSize = cc.size(600, 120)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    --初始化页面控件
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
        	Notification:postNotification(EventsName.eGuildHomeAll)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
    self.mParentLayer:addChild(self.mCloseBtn)
end

--初始化页面控件
function GuildBuildLayer:initUI()
	-- 创建背景
    self.mBgSprite = ui.newSprite("c_34.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)

	-- 创建页面上部的控件
	self:createBaseUI()

	-- 创建建设列表
	self:createListView()
end

-- 创建页面基础控件
function GuildBuildLayer:createBaseUI()
	--建设日志
	local buildLogBtn = ui.newButton({
		normalImage = "tb_174.png",
		position = cc.p(570, 780),
		clickAction = function (sender)
			LayerManager.addLayer({
                name = "guild.GuildBuildLogLayer",
                cleanUp = false,
                zOrder = Enums.ZOrderType.ePopLayer
            })
		end
	})
	self.mParentLayer:addChild(buildLogBtn, 1)

    -- 创建人物
    local meinv = ui.newSprite("bp_17.jpg")
    self.mParentLayer:addChild(meinv)
    meinv:setPosition(cc.p(320, 931))

    -- 下方列表背景
    local listBack = ui.newScale9Sprite("c_19.png", cc.size(640, 738))
    listBack:setAnchorPoint(cc.p(0.5, 1))
    listBack:setPosition(cc.p(320, 738))
    self.mParentLayer:addChild(listBack)

    -- 商品列表背景
    local listBg = ui.newScale9Sprite("c_17.png", cc.size(610,454))
    listBg:setPosition(320, 400)
    self.mParentLayer:addChild(listBg)

	-- 文字描述
    local decLabel = ui.newLabel({
        text = TR("帮派建设可以增加个人贡献哦"),
        outlineColor = cc.c3b(0x28, 0x28, 0x29),
        outlineSize = 2,
        valign = ui.VERTICAL_TEXT_ALIGNMENT_TOP,
        size = 24,
        dimensions = cc.size(300, 0),
        anchorPoint = cc.p(0, 1)
    })
    decLabel:setPosition(20, 836)
    self.mParentLayer:addChild(decLabel)

    local sp = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    sp:setPosition(cc.p(450, 675))
    self.mParentLayer:addChild(sp)

	--帮派资金
	local foundLabel = ui.newLabel({
		text = "",
		align = cc.TEXT_ALIGNMENT_RIGHT,
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	foundLabel:setAnchorPoint(cc.p(0, 0.5))
	foundLabel:setPosition(35, 675)
	self.mParentLayer:addChild(foundLabel)

    local haveContrBack = ui.newScale9Sprite("c_24.png", cc.size(120, 35))
    haveContrBack:setPosition(cc.p(205, 675))
    self.mParentLayer:addChild(haveContrBack)

	--个人贡献
	local contributionLabel = ui.newLabel({
		text = "",
		align = cc.TEXT_ALIGNMENT_RIGHT,
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	contributionLabel:setAnchorPoint(cc.p(0, 0.5))
	contributionLabel:setPosition(280, 675)
	self.mParentLayer:addChild(contributionLabel)

	-- 今日建设次数
	local buildTotalLabel = ui.newLabel({
        text = "",
        size = 24,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 2
    })
    buildTotalLabel:setPosition(320, 135)
	self.mParentLayer:addChild(buildTotalLabel)

    -- 充值按钮
    local rechargeButton = ui.newButton({
        normalImage = "tb_21.png",
        position = cc.p(570, 675),
        clickAction = function ()
            LayerManager.showSubModule(ModuleSub.eCharge)
        end
    })
    self.mParentLayer:addChild(rechargeButton)
    rechargeButton:setVisible(ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eCharge) and ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eCharge, true))

	-- 监听帮派信息变化
	local function dealGuildInfoChange(tempNode)
		-- 帮派信息
        local guildInfo = GuildObj:getGuildInfo()
	    -- 每日建设最大次数,跟最大人数一样
		local totalTime = GuildLvRelation.items[guildInfo.Lv].memberNumMax+(guildInfo.ExtendCount or 0)

		-- 帮派资金
		foundLabel:setString(TR("帮派资金: {%s}#FA8005 %s", "db_1134.png", tostring(guildInfo.GuildFund)))

		-- 个人贡献
		contributionLabel:setString(TR("个人贡献:{%s}#FA8005 %s", "db_1113.png", tostring(PlayerAttrObj:getPlayerAttrByName("Contribution"))))

		-- 今日建设次数
		buildTotalLabel:setString(TR("今日建设总次数: #a7e737%d/%d", guildInfo.GuildBuildCount, totalTime))
    end
	Notification:registerAutoObserver(buildTotalLabel, dealGuildInfoChange, EventsName.eGuildHomeAll)
	dealGuildInfoChange(buildTotalLabel)
end

-- 创建建设列表
function GuildBuildLayer:createListView()
	-- 列表控件
    self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(self.mListSize)
    self.mListView:setAnchorPoint(cc.p(0.5,1))
    self.mListView:setPosition(cc.p(320, 610))
    self.mListView:setItemsMargin(20)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setBounceEnabled(true)
    self.mParentLayer:addChild(self.mListView)

    -- 刷新帮派建设信息列表
    self:refreshListView()
end

-- 刷新帮派建设信息列表
function GuildBuildLayer:refreshListView()
	for index, item in ipairs(self.mBuildModelIds) do
		local lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListItem(index)
	end
end

-- 刷新帮派建设信息列表中的一个条目
function GuildBuildLayer:refreshListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    local cellSize = self.mCellSize
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    local buildLogList = {"bp_23.png", "bp_25.png", "bp_24.png"}
    -- 建筑标记图片名
    local logoImg = buildLogList[math.max(1, math.min(index, #buildLogList))]
    -- 建筑的模型信息
    local buildModel = GuildBuildtypeModel.items[self.mBuildModelIds[index]] 

    -- 条目背景
    local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
    bgSprite:setPosition(cellSize.width / 2, cellSize.height / 2)
    lvItem:addChild(bgSprite)

	--头像图片
	local iconImageRes = {"tb_135.png", "tb_136.png", "tb_137.png"}
	local iconImage = ui.newSprite(iconImageRes[index])
	iconImage:setPosition(cc.p(85, 55))
	lvItem:addChild(iconImage)

	--标签
	local logoSprite = ui.newSprite(logoImg)
	logoSprite:setPosition(cc.p(35, 88))
	lvItem:addChild(logoSprite)

	local outputInfoList = {
		TR("帮派资金: #258711+%d", buildModel.outputGuildFund),
		TR("个人贡献: #258711+%d", buildModel.outputContribution)
	}
	--额外获得
	if buildModel.outputResource ~= "" then
		local tempList = Utility.analysisStrResList(buildModel.outputResource)
		local tempStrList = {}
		for _, item in ipairs(tempList) do
			local tempName = Utility.getGoodsName(item.resourceTypeSub, item.modelId)
			table.insert(outputInfoList, string.format("%s:#258711 *%d", tempName, item.num))
		end
	end
	local spaceY = 30
	local startPosY = (cellSize.height + #outputInfoList * spaceY) / 2 - spaceY / 2
	for infoIndex, info in pairs(outputInfoList) do
		local tempLabel = ui.newLabel({
	        text = info,
	        size = 20,
			anchorPoint = cc.p(0, 0.5),
			color = cc.c3b(0x46, 0x22, 0x0d),
	    })
	    tempLabel:setPosition(160, startPosY - (infoIndex - 1) * spaceY)
		lvItem:addChild(tempLabel)
	end

	--消耗资源
	local needList = Utility.analysisStrResList(buildModel.useResource)
	local needSprite = ui.createDaibiView({
		resourceTypeSub = needList[1].resourceTypeSub,
		number = needList[1].num,
		fontColor = cc.c3b(0xd1, 0x7b, 0x00),
	})
	needSprite:setPosition(cc.p(520 , 85))
    lvItem:addChild(needSprite)

    --建设按钮
    local tempBtn = ui.newButton({
		normalImage = "c_28.png",
		position = cc.p(520, 35),
		text = TR("建设"),
		clickAction = function(sender)
			if not Utility.isResourceEnough(needList[1].resourceTypeSub, needList[1].num) then
				return
			end

			--请求网络接口
			self:requestGuildBuild(buildModel.ID)
		end
	})
	lvItem:addChild(tempBtn)

	-- 监听帮派信息变化
	local function dealGuildInfoChange(tempNode)
		-- 帮派信息
        local guildInfo = GuildObj:getGuildInfo()
	    -- 玩家帮派信息
	    local playerBulidInfo = GuildObj:getPlayerGuildInfo()
	    -- 每日建设最大次数,跟最大人数一样
		local totalTime = GuildLvRelation.items[guildInfo.Lv].memberNumMax+(guildInfo.ExtendCount or 0)
		local isBulidFull = totalTime <= guildInfo.GuildBuildCount

		-- 设置按钮的状态
		tempBtn:setEnabled(playerBulidInfo.IfCanBuildTime and not isBulidFull)
		tempBtn:setTitleText(isBulidFull and TR("已建满") or (not playerBulidInfo.IfCanBuildTime) and TR("已建设") or TR("建设"))
    end
	Notification:registerAutoObserver(tempBtn, dealGuildInfoChange, EventsName.eGuildHomeAll)
	dealGuildInfoChange(tempBtn)
end

-- =============================== 请求服务器数据相关函数 ===================

-- buildId  建设等级的id
function GuildBuildLayer:requestGuildBuild(buildId)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "GuildBuild",
        svrMethodData = {buildId},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 更新小红点
            GuildObj:updatePlayerGuildInfo({IfCanBuildTime = false})

			-- 显示获得的领奖
            local tempModel = GuildBuildtypeModel.items[buildId]
			local text = TR("帮派资金+%d, 个人贡献+%d", tempModel.outputGuildFund, tempModel.outputContribution)
			if tempModel.outputResource ~= "" then
				local tempList = Utility.analysisStrResList(tempModel.outputResource)
				for _, item in pairs(tempList) do
					local tempStr = Utility.getGoodsName(item.resourceTypeSub, item.modelId)
					tempStr = string.format("%s+%d", tempStr, item.num)
					text = text .. ", " .. tempStr
				end
			end
			ui.showFlashView(text)
        end,
    })
end

return GuildBuildLayer