--[[
        文件名：PreLoadLayer.lua
        描述：配置文件和图片资源预加载文件
        创建人：liaoyuangang
        创建时间：2016.4.11
-- ]]

local PreLoadLayer = class("PreLoadLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
    {
        endCallback = nil, -- 预加载完成后的回调函数
    }
]]
function PreLoadLayer:ctor(params)
    self.endCallback = params.endCallback
    self.mPreLoadConfig = {}
    self.mPreLoadImg = {}

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initData()
    self:initUI()
    self:startPreLoad()
end

-- 初始化需要预加载的数据
function PreLoadLayer:initData()
    -- 整理需要预加载的lua文件
    local tempList = require("Config.RequireAllConfig") -- 所有的配置文件
    for index = 1, #tempList do
        table.insert(self.mPreLoadConfig, tempList[index])
    end
    table.insert(self.mPreLoadConfig, "common.ConfigFunc")
    table.insert(self.mPreLoadConfig, "data.Notification")
    table.insert(self.mPreLoadConfig, "Guide.GuideInit")
    table.insert(self.mPreLoadConfig, "ComBattle.BattleInit")

    -- 其他需要预加载的lua文件
    -- Todo

    -- 整理需要预加载的图片资源
    -- Todo
end

-- 创建页面控件
function PreLoadLayer:initUI()
    -- 添加游戏忠告
    local tempList = {
        TR("抵制不良游戏，拒绝盗版游戏。"),
        TR("注意自我保护，谨防受骗上当。"),
        TR("适度游戏益脑，沉迷游戏伤身。"),
        TR("合理安排时间，享受健康生活。")
    }
    local startPosY = 270
    for index, item in pairs(tempList) do
        local tempLabel = ui.newLabel({
            text = item,
            size = 23,
            align = cc.TEXT_ALIGNMENT_CENTER,
            outlineColor = cc.c3b(0x32, 0x32, 0x32),
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(320, startPosY - (index - 1) * 32)
        self.mParentLayer:addChild(tempLabel)
    end

    -- 提示语
    local tempLabel = ui.newLabel({
        text = TR("正在加载资源，这个过程不产生任何流量哦。"),
        size = 24,
        align = ui.TEXT_ALIGN_CENTER,
        outlineColor = cc.c3b(0x32, 0x32, 0x32),
    })
    tempLabel:setPosition(320, 120)
    self.mParentLayer:addChild(tempLabel)

    -- 进度条
    self.mProgressBar = require("common.ProgressBar").new({
        bgImage = "zr_14.png",
        barImage = "zr_15.png",
        currValue = 0,
        maxValue=  100,
        barType = ProgressBarType.eHorizontal,
        color = Enums.Color.eWhite,
        needLabel = true,
    })
    self.mProgressBar:setPosition(cc.p(320, 90))
    self.mParentLayer:addChild(self.mProgressBar)
end

-- 开始预加载
function PreLoadLayer:startPreLoad()
    -- 先加载配置文件
    local total = #self.mPreLoadConfig + #self.mPreLoadImg
    local progIndex = 0
    local isBusy = false

    Utility.schedule(self.mParentLayer, function(sender)
        if isBusy then
            return
        end
        if progIndex > total then
            LocalData:setPreLoadStatus(true)

            if self.endCallback then
                self.endCallback()
            end
            self:removeFromParent()
            return
        end
        isBusy = true

        local num = progIndex / total * 100
        self.mProgressBar:setCurrValue(num)
        for index = 1, 2 do
            progIndex = progIndex + 1
            if progIndex <= #self.mPreLoadConfig then
                require(self.mPreLoadConfig[progIndex])  -- 预加载配置文件
            else
                local tempProg = progIndex - #self.mPreLoadConfig
                if tempProg <= #self.mPreLoadImg then
                    local textureCache = cc.Director:getInstance():getTextureCache()
                    local tempFile = self.mPreLoadImg[tempProg]
                    local alphoFormat = display.TEXTURES_PIXEL_FORMAT[tempFile]
                    if alphoFormat then
                        cc.Texture2D:setDefaultAlphaPixelFormat(alphoFormat)
                    elseif string.lower(tempFile):match("[^%s+]%.jpg") then
                        alphoFormat = cc.TEXTURE2_D_PIXEL_FORMAT_RG_B888
                        cc.Texture2D:setDefaultAlphaPixelFormat(alphoFormat)
                    end
                    if textureCache:reloadTexture(self.mPreLoadImg[tempProg]) then
                        local texture = textureCache:getTextureForKey(self.mPreLoadImg[tempProg])
                        if texture then
                            texture:retain()
                        end
                    end
                    if alphoFormat then
                        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
                    end
                else
                    break
                end
            end
        end
        isBusy = false
    end, 0.01)
end

return PreLoadLayer
