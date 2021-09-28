--[[
	文件名: DlgGuessPopLayer
	描述: 弹出竞猜选择的对话框
	创建人: peiyaoqiang
	创建时间: 2017.11.2
-- ]]
local DlgGuessPopLayer = class("DlgGuessPopLayer",function()
	return display.newLayer()
end)

function DlgGuessPopLayer:ctor(params)
	-- 读取参数
    self.mPageInfo = params

    self.mTargetId = nil -- 下注目标id
    self.mBetNumId = 0 -- 下注档位id

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("选择竞猜玩家"),
        bgSize = cc.size(600, 560),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 初始化页面
    self:setUI()
end

function DlgGuessPopLayer:setUI()
    -- 背景图
    local tmpBgSprite = ui.newScale9Sprite("c_17.png", cc.size(self.mBgSize.width - 60, 380))
    tmpBgSprite:setPosition(self.mBgSize.width * 0.5, 300)
    self.mBgSprite:addChild(tmpBgSprite)

    -- 读取竞猜配置
    local betTypeId = self:getBetId(self.mPageInfo.currTurn)        -- 投注轮次ID
    local betConfig = PvpinterTopGamble.items[betTypeId]            -- 投注信息
    local betAmountList = {}
    for _,v in pairs(betConfig) do
        local tmpArray = string.split(v.betsAmount, ",")
        table.insert(betAmountList, {betType = v.betsType, betGold = tonumber(tmpArray[1]), betNum = tonumber(tmpArray[3])})
    end
    table.sort(betAmountList, function (a, b)
            return a.betNum < b.betNum
        end)
    
    -- 默认选中
    self.mBetNumId = betConfig[1].betsType

    -- 显示人物信息
    local guessCheckBox = {}
    local function addOnePlayer(playerItem, posX)
        local playerBgSprite = ui.newScale9Sprite("c_18.png", cc.size(200, 290))
        playerBgSprite:setPosition(posX, 335)
        self.mBgSprite:addChild(playerBgSprite)

        -- 头像
        local headerNode = require("common.CardNode").new({allowClick = false,})
        headerNode:setHero({ModelId = playerItem.HeadImageId, FashionModelID = playerItem.FashionModelId, IllusionModelId = playerItem.IllusionModelId}, {CardShowAttr.eBorder})
        headerNode:setPosition(100, 220)
        playerBgSprite:addChild(headerNode)

        -- 名字
        local nameLabel = ui.newLabel({
            text = playerItem.Name,
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = 100, 
            y = 155,
        })
        playerBgSprite:addChild(nameLabel)

        -- 战力
        local nameLabel = ui.newLabel({
            text = TR("战力:%s%s", Enums.Color.eNormalGreenH, Utility.numberFapWithUnit(playerItem.Fap)),
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = 100, 
            y = 125,
        })
        playerBgSprite:addChild(nameLabel)

        -- 区服
        local nameLabel = ui.newLabel({
            text = "[" .. playerItem.Zone .. "]",
            size = 20,
            color = cc.c3b(0x46, 0x22, 0x0d),
            x = 100, 
            y = 95,
        })
        playerBgSprite:addChild(nameLabel)

        -- 选择框
        local tmpCheckBox = ui.newCheckbox({
            normalImage = "c_60.png",
            selectImage = "c_61.png",
            isRevert = false,
            text = TR("支持"),
            textColor = cc.c3b(0x46, 0x22, 0x0d),
            callback = function(State)
                -- 设置单选效果
                for k,v in pairs(guessCheckBox) do
                    v:setCheckState(k == playerItem.PlayerId)
                end
                self.mTargetId = playerItem.PlayerId
            end
        })
        tmpCheckBox:setPosition(100, 55)
        playerBgSprite:addChild(tmpCheckBox)
        guessCheckBox[playerItem.PlayerId] = tmpCheckBox

        -- 赔率
        local oddsLabel = ui.newLabel({
            text = TR("赔率%s", betConfig[1].oddsDes),
            size = 20,
            color = Enums.Color.eNormalGreen,
        })
        oddsLabel:setPosition(cc.p(100, 20))
        playerBgSprite:addChild(oddsLabel)
    end
    addOnePlayer(self.mPageInfo.playerLeft, self.mBgSize.width * 0.24)
    addOnePlayer(self.mPageInfo.playerRight, self.mBgSize.width * 0.76)

    -- VS图片
    local vsSprite = ui.newSprite("zdjs_07.png")
    vsSprite:setPosition(self.mBgSize.width * 0.5, 330)
    self.mBgSprite:addChild(vsSprite)

    -- 选择背景
    local selectBgSprite = ui.newScale9Sprite("gd_10.png", cc.size(510, 58))
    selectBgSprite:setPosition(self.mBgSize.width * 0.5, 150)
    self.mBgSprite:addChild(selectBgSprite)

    -- 下注金币
    local dbLabel = ui.newLabel({
        text = TR("下注 {%s}:", Utility.getDaibiImage(betAmountList[1].betGold, 0)),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 50, 
        y = 29,
    })
    dbLabel:setAnchorPoint(cc.p(0, 0.5))
    selectBgSprite:addChild(dbLabel)
    
    -- 已选择的下注金额
    local btnSelect = ui.newButton({
        normalImage = "wlmz_21.png",
        clickAction = function()
            self:popSelectView(betAmountList)
        end
    })
    btnSelect:setPosition(255, 29)
    selectBgSprite:addChild(btnSelect)

    local selectLabel = ui.newLabel({
        text = Utility.numberWithUnit(betAmountList[1].betNum),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
        x = 240, 
        y = 29,
    })
    selectBgSprite:addChild(selectLabel)
    self.selectLabel = selectLabel

    -- 确认下注的按钮
    local okButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mBgSize.width * 0.5, 65),
        clickAction = function(pSender)
            if (self.mTargetId == nil) then
                ui.showFlashView(TR("请选择您要支持的玩家"))
                return
            end
            self.mPageInfo.callback(self.mTargetId, self.mBetNumId)
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(okButton)
end

function DlgGuessPopLayer:popSelectView(betAmountList)
    local dlgBgNode = cc.Node:create()
    dlgBgNode:setContentSize(cc.size(150, 150))
    dlgBgNode:setPosition(self.mBgSize.width * 0.5, 155)
    self.mBgSprite:addChild(dlgBgNode, 1)

    -- 添加按钮
    for i,v in ipairs(betAmountList) do
        local button = ui.newButton({
            normalImage = "ng_11.png",
            size = cc.size(140, 40),
            text = Utility.numberWithUnit(v.betNum),
            clickAction = function()
                self.mBetNumId = v.betType
                self.selectLabel:setString(Utility.numberWithUnit(v.betNum))
                dlgBgNode:removeFromParent()
            end
        })
        button:setPosition(0, i * 45)
        dlgBgNode:addChild(button)
    end

    -- 注册触摸关闭
    ui.registerSwallowTouch({
        node = dlgBgNode,
        allowTouch = true,
        endedEvent = function(touch, event)
            dlgBgNode:removeFromParent()
        end
        })
end

-- 辅助函数 转换下注ID
function DlgGuessPopLayer:getBetId(paramId)
    local tTable = {[1] = 16, [2] = 8, [3] = 4, [4] = 2, [5] = 1}
    return tTable[paramId]
end

return DlgGuessPopLayer
