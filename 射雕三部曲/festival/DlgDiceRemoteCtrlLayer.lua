--[[
    文件名: DlgDiceRemoteCtrlLayer.lua
    创建人: peiyaoqiang
    创建时间: 2017-09-24
    描述: 国庆活动——掷骰子——遥控骰子
--]]

local DlgDiceRemoteCtrlLayer = class("DlgDiceRemoteCtrlLayer", function()
    return display.newLayer()
end)

function DlgDiceRemoteCtrlLayer:ctor(params)
    -- 读取参数
    self.callback = params.callback

    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(540, 500),
        title = TR("遥控骰子"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 
    self:initUI()
end

-- 初始化页面控件
function DlgDiceRemoteCtrlLayer:initUI()
    -- 提示文字
    local infoLabel = ui.newLabel({
        text = TR("请选择您想要的点数:"),
        size = 24,
        color = cc.c3b(0xd1, 0x7b, 0x00),
    })
    infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
    infoLabel:setPosition(self.mBgSize.width * 0.5, 410)
    self.mBgSprite:addChild(infoLabel)

    -- 列表背景
    local listBgSize = cc.size(self.mBgSize.width - 80, 240)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(cc.p(0.5, 0))
    listBgSprite:setPosition(self.mBgSize.width * 0.5, 140)
    self.mBgSprite:addChild(listBgSprite)

    -- 骰子列表
    local diceItemList = {
        [1] = {img = "cdjh_1.png", num = 1, pos = cc.p(listBgSize.width * 0.2, listBgSize.height * 0.75)}, 
        [2] = {img = "cdjh_2.png", num = 2, pos = cc.p(listBgSize.width * 0.5, listBgSize.height * 0.75)}, 
        [3] = {img = "cdjh_3.png", num = 3, pos = cc.p(listBgSize.width * 0.8, listBgSize.height * 0.75)}, 
        [4] = {img = "cdjh_4.png", num = 4, pos = cc.p(listBgSize.width * 0.2, listBgSize.height * 0.25)}, 
        [5] = {img = "cdjh_5.png", num = 5, pos = cc.p(listBgSize.width * 0.5, listBgSize.height * 0.25)}, 
        [6] = {img = "cdjh_6.png", num = 6, pos = cc.p(listBgSize.width * 0.8, listBgSize.height * 0.25)}
    }
    local diceBtnList = {}
    local selectNum = 0
    local function selectOneNum(newNum)
        if (selectNum == newNum) then
            return
        end
        selectNum = newNum
        for _,v in ipairs(diceBtnList) do
            v.selectSprite:setVisible((v.num == newNum))
        end
    end
    for _,v in ipairs(diceItemList) do
        local button = ui.newButton({
            normalImage = v.img,
            position = v.pos,
            scale = 0.9,
            clickAction = function()
                selectOneNum(v.num)
            end
        })
        listBgSprite:addChild(button)

        -- 添加选中框
        local selectSprite = ui.newSprite("c_31.png")
        selectSprite:setPosition(v.pos)
        selectSprite:setVisible(false)
        listBgSprite:addChild(selectSprite)
        table.insert(diceBtnList, {num = v.num, selectSprite = selectSprite})
    end

    -- 骰子数量
    local ownCount = Utility.getOwnedGoodsCount(1605, 16050111)
    local countLabel = ui.newLabel({
        text = TR("当前拥有的遥控骰子数量: %s%d", Enums.Color.eNormalGreenH, ownCount),
        size = 22,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    countLabel:setAnchorPoint(cc.p(0.5, 0.5))
    countLabel:setPosition(self.mBgSize.width * 0.5, 110)
    self.mBgSprite:addChild(countLabel)

    -- 选择按钮
    local btnOk = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mBgSize.width * 0.5, 60),
        clickAction = function()
            if (ownCount == 0) then
                ui.showFlashView(TR("您暂时没有可用的遥控骰子"))
                return
            end
            if (selectNum == 0) then
                ui.showFlashView(TR("请先选择一个想要的点数"))
                return
            end

            -- 执行回调
            if (self.callback ~= nil) then
                self.callback(selectNum)
            end
            LayerManager.removeLayer(self)
        end
    })
    self.mBgSprite:addChild(btnOk)
end

return DlgDiceRemoteCtrlLayer