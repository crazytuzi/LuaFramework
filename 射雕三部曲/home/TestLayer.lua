--[[
    文件名：HomeLayer.lua
    描述：首页Layer的显示
    创建人：liaoyuangang
    创建时间：2016.4.12
-- ]]

local TestLayer = class("TestLayer", function(params)
    return display.newLayer()
end)

--
function TestLayer:ctor()
    -- 页面控件的Parent
    self.mParentNode = ui.newStdLayer()
    self:addChild(self.mParentNode)

    --背景图
    self.mBgSprite = ui.newSprite("c_34.jpg")
    self.mBgSprite:setPosition(320, 568)
    self.mParentNode:addChild(self.mBgSprite)
    self.mBgSprite:setGray(true)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(580, 1050)
    self.mParentNode:addChild(self.mCloseBtn)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function TestLayer:initUI()
    local testBtnInfos = {
        {   -- 上帝模式
            normalImage = "c_28.png",
            text = TR("上帝模式"),
            clickAction = function()
                print("按下上帝模式按钮")
                LayerManager.addLayer({name = "home.GodLayer"})
            end,
        },
        {
            normalImage = "c_28.png",
            text = TR("清空道具"),
            clickAction = function()
                HttpClient:request({
                    moduleName = "Goods",
                    methodName = "CleanAllGoods",
                    callback = function(response)
                        if response and response.Status == 0 then
                            ui.showFlashView(TR("清空完毕"))
                        end
                    end
                })
            end,
        },
        {
            normalImage = "c_28.png",
            text = TR("测试按钮1"),
            clickAction = function()

                LayerManager.addLayer({
                    name = "hero.ImprintMainLayer",
                })
            end
        },
        {
            normalImage = "c_28.png",
            text = TR("测试按钮2"),
            clickAction = function()
                LayerManager.addLayer({
                    name = "jianghuKill.JianghuKillSelectForceLayer",
                })
            end
        },
    }

    local tempPosX, tempPosY = 320, 380
    for index, btnInfo in ipairs(testBtnInfos) do
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setPosition(tempPosX, tempPosY + (index - 1) * 100)
        self.mParentNode:addChild(tempBtn)
    end
end

function TestLayer:requestAddGameRecoure(resInfo)
    HttpClient:request({
        moduleName = "Player",
        methodName = "AddGameRecoure",
        svrMethodData = {resInfo},
        callbackNode = self,
        callback = function(response)
            if response and response.Status == 0 then
                ui.showFlashView(TR("添加成功"))
            end
        end
    })
end

return TestLayer
