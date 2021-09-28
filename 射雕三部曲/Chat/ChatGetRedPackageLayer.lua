--[[
    ChatGetRedPackageLayer.lua
    描述: 聊天红包界面
    创建人: yanghongsheng
    创建时间: 2017.8.30
-- ]]

local ChatGetRedPackageLayer = class("ChatGetRedPackageLayer", function(params)
    return display.newLayer()
end)

--参数
--[[
    红包信息
--]]
function ChatGetRedPackageLayer:ctor(params)
    ui.registerSwallowTouch({node = self})
    
    self.mTotalInfo = params

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- self:getRedpurse()
	self:initUI()
end

function ChatGetRedPackageLayer:initUI()
	--黑色底层
	local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	bgLayer:setContentSize(640, 1136)
	self.mParentLayer:addChild(bgLayer)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(508, 835),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn, 10)

    self:createInfoView()

end

--创建展示信息
function ChatGetRedPackageLayer:createInfoView()

    --背景图
    local bgSprite = ui.newSprite("xn_22.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    local bgSize = bgSprite:getContentSize()

    --头像图片
    local titleSprite = CardNode.createCardNode({
        allowClick = false,
        })
    titleSprite:setHero(
            {
                ModelId = self.mTotalInfo.HeadImageId,
                FashionModelID = self.mTotalInfo.FashionModelId,
                PVPInterLv = self.mTotalInfo.DesignationId,
            },
            {CardShowAttr.eBorder, CardShowAttr.eName},
            self.mTotalInfo.PlayerName
            )
    titleSprite:setPosition(bgSize.width * 0.5 , bgSize.height * 0.99)
    bgSprite:addChild(titleSprite)

    --标题文字
    local str = GoodsModel.items[self.mTotalInfo.ModelId].name
    local titleLabel = ui.newLabel({
        text = str,
        size = 24,
        color = cc.c3b(0xf6, 0xe8, 0x7e),
        })
    titleLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.82)
    bgSprite:addChild(titleLabel)

    --领取信息
    local getInfoLabel = ui.createLabelWithBg({
            bgFilename = "bpz_31.png",
            -- bgSize = nil,       -- 背景图显示大小，默认为图片大小
            labelStr = TR("已领取 %s/%s", self.mTotalInfo.Num, self.mTotalInfo.TotalNum),
            -- fontSize = nil, 
            color = cc.c3b(0xfc, 0xd4, 0xa6), 
            outlineColor = Enums.Color.eOutlineColor,
            alignType = ui.TEXT_ALIGN_CENTER,
        })
    getInfoLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.67)
    bgSprite:addChild(getInfoLabel)

    --透明底板
    local underBgSprite = ui.newScale9Sprite("bsxy_10.png", cc.size(375, 340))
    underBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.32)
    bgSprite:addChild(underBgSprite)

    --奖励领取列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(cc.size(375, 330))
    listView:setItemsMargin(5)
    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(bgSize.width * 0.5, 25)
    bgSprite:addChild(listView)

    --排序把自己的领取信息排在等一个
    table.sort(self.mTotalInfo.PlayerList, function (a, b)
        local isSelfA = a.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId")
        local isSelfB = b.Id == PlayerAttrObj:getPlayerAttrByName("PlayerId")

        if isSelfA ~= isSelfB then
            return isSelfA
        end
    end)

    for i,v in ipairs(self.mTotalInfo.PlayerList) do
        listView:pushBackCustomItem(self:createOneCell(i))
    end
end

--创建一个条目
function ChatGetRedPackageLayer:createOneCell(index)
    local cellInfo = self.mTotalInfo.PlayerList[index]

    local layout = ccui.Layout:create()
    layout:setContentSize(370, 106)
    --背景
    local bgSprite = ui.newScale9Sprite("c_155.png", cc.size(370, 105))
    bgSprite:setPosition(185, 53)
    layout:addChild(bgSprite)

    --头像
    local headCard = CardNode.createCardNode({
        allowClick = false,
        })
    headCard:setHero(
            {
                ModelId = cellInfo.HeadImageId,
                FashionModelID = cellInfo.FashionModelId,
                PVPInterLv = cellInfo.DesignationId,
            },
            {CardShowAttr.eBorder}
            )
    headCard:setPosition(55, 53)
    layout:addChild(headCard)

    --名字
    local nameLabel = ui.newLabel({
        text = cellInfo.PlayerName,
        color = cc.c3b(0xfc, 0xf1, 0x89),
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    nameLabel:setAnchorPoint(0, 0.5)
    nameLabel:setPosition(105, 85)
    layout:addChild(nameLabel)

    --等级
    local lvLabel = ui.newLabel({
        text = TR("等级：%s", cellInfo.Lv),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eOutlineColor,
        size = 20,
        })
    lvLabel:setAnchorPoint(0, 0.5)
    lvLabel:setPosition(105, 55)
    layout:addChild(lvLabel)

    --vip等级
    local vipLv = tonumber(cellInfo.Vip)
    if vipLv > 0 then
        local vipNode = ui.createVipNode(vipLv)
        vipNode:setPosition(110, 25)
        layout:addChild(vipNode)
    end

    --奖励道具
    local rewardInfo = Utility.analysisStrResList(cellInfo.Reward)
    local rewardCard = CardNode.createCardNode({
            resourceTypeSub = rewardInfo[1].resourceTypeSub,
            modelId = rewardInfo[1].modelId,  -- 模型Id
            num = rewardInfo[1].num, -- 资源数量
            cardShowAttrs = {CardShowAttr.eName, CardShowAttr.eNum, CardShowAttr.eBorder},
        })
    rewardCard:setScale(0.8)
    rewardCard:setPosition(325, 65)
    layout:addChild(rewardCard)

    return layout
end

return ChatGetRedPackageLayer