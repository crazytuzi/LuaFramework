--[[
    文件名：GuildModifyNameLayer.lua
    描述：  帮派更名
    创建人： chenzhong
    创建时间：2018.6.14
-- ]]

local GuildModifyNameLayer = class("GuildModifyNameLayer", function(params)
    return cc.LayerColor:create()
end)

-- 初始化
function GuildModifyNameLayer:ctor(params)
    -- 设置ui
    self:setUI()
end

function GuildModifyNameLayer:setUI()
    -- 设置背景大小
    local bgWidth = 515
    local bgHeight = 405

    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("修改帮派名字"),
        bgSize = cc.size(bgWidth, bgHeight),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    -- 文字描述
    local textSrc = ui.newLabel({
        text = TR("在下方输入你要修改的昵称"),
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    textSrc:setAnchorPoint(cc.p(0.5, 1.0))
    textSrc:setPosition(cc.p(bgWidth / 2, bgHeight - 75))
    self.mBgSprite:addChild(textSrc)

    -- 内容
    self:createContentBg()

     --不同编码下获取字符串长度
    local function asciilen(str)
        local barrier  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
        local size = #barrier
        local count, delta = 0, 0
        local c, i, j = 0, #str, 0

        while i > 0 do
            delta, j, c = 1, size, string.byte(str, -i)
            while barrier[j] do
                if c >= barrier[j] then i = i - j; break end
                j = j - 1
            end
            delta = j == 1 and 1 or 2
            count = count + delta
        end
        return count
    end

    -- 确认按钮
    local btnOk = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        color = cc.c3b(0xff, 0xff, 0xff),
        size = 22,
        position = cc.p(bgWidth /2 , bgHeight * 0.14),
        clickAction = function()
            if self.mNameEditBox:getText() ~= "" then
                if asciilen(self.mNameEditBox:getText()) <= 12 then
                    self:requestAlterPlayerName(self.mNameEditBox:getText())
                else
                    MsgBoxLayer.addOKLayer(TR("输入长度不得超过6个汉字或12个字符"),TR("提示"))
                end
            else
                ui.showFlashView({text = TR("请输入昵称"),})
            end
        end,
    })
    self.mBgSprite:addChild(btnOk)
end
-- 设置内容展示
function GuildModifyNameLayer:createContentBg()
    self.mContentBg = ui.newScale9Sprite("c_17.png", cc.size(466, 197))
    self.mContentBg:setPosition(cc.p(515 / 2, 190))
    self.mBgSprite:addChild(self.mContentBg)

    self.mNameEditBox = ui.newEditBox({
          image = "c_38.png",
          size  = cc.size(270, 40),
          fontColor = Enums.Color.eNormalGreen,
          placeHolder = TR("请输入新的昵称"),
          placeColor = Enums.Color.eNormalGreen,
        })
    self.mNameEditBox:setAnchorPoint(cc.p(0, 0.5))
    self.mNameEditBox:setPosition(cc.p(65, 157))
    self.mContentBg:addChild(self.mNameEditBox)

    -- 设置中部label
    self:setCenterLabel()
end

-- 设置中部label
function GuildModifyNameLayer:setCenterLabel()
    -- 消耗
    local castLabel1 = ui.newLabel({
        text  = TR("消耗:"),
        color = Enums.Color.eLightYellow,
    })
    castLabel1:setAnchorPoint(cc.p(0, 1))
    castLabel1:setPosition(80, 110)
    self.mContentBg:addChild(castLabel1)
    -- 图标
    local nameImage = GoodsModel.items[16050372].pic .. ".png"
    local modifySprite1 = ui.newSprite(nameImage)
    modifySprite1:setScale(0.6)
    modifySprite1:setAnchorPoint(cc.p(0, 1))
    modifySprite1:setPosition(150, 122)
    self.mContentBg:addChild(modifySprite1)
    -- 消耗
    local castNum1 = ui.newLabel({
        text = TR("X1"),
        color = Enums.Color.eNormalGreen,
    })
    castNum1:setAnchorPoint(cc.p(0, 1))
    castNum1:setPosition(205, 110)
    self.mContentBg:addChild(castNum1)

    local castLabel2 = ui.newLabel({
        text = TR("拥有:"),
        color = Enums.Color.eLightYellow,
    })
    castLabel2:setAnchorPoint(cc.p(0, 1))
    castLabel2:setPosition(80, 50)
    self.mContentBg:addChild(castLabel2)

    local modifySprite3 = ui.newSprite(nameImage)
    modifySprite3:setScale(0.6)
    modifySprite3:setAnchorPoint(cc.p(0, 1))
    modifySprite3:setPosition(150, 60)
    self.mContentBg:addChild(modifySprite3)
    local curGoodsCount = GoodsObj:getCountByModelId(16050372)
    local castNum2 = ui.newLabel({
        text = TR("X%s", curGoodsCount),
        color = (curGoodsCount > 0) and Enums.Color.eNormalGreen or Enums.Color.eRed,
    })
    castNum2:setAnchorPoint(cc.p(0, 1))
    castNum2:setPosition(205, 50)
    self.mContentBg:addChild(castNum2)
end

------[[------网络相关------]]-------
function GuildModifyNameLayer:requestAlterPlayerName(name)
    HttpClient:request({
        moduleName = "Guild",
        methodName = "AlterGuildName",
        svrMethodData = {name},
        callback = function(data)
            if data.Status == 0 then
                -- 修改缓存
                GuildObj:changeGuildName(name)
                ui.showFlashView({text = TR("更名成功"),})
                LayerManager.removeLayer(self)
            end
        end,
    })
end

return GuildModifyNameLayer
