--[[
    StartworkPopLayer.lua
    描述: 开工红包弹窗页面
    创建人: yanghongsheng
    创建时间: 2017.3.13
-- ]]

local StartworkPopLayer = class("StartworkPopLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 188))
end)

function StartworkPopLayer:ctor()
	-- 屏蔽点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化
    self:setUI()
end

function StartworkPopLayer:setUI()

    --背景
    local bgSprite = ui.newSprite("jc_19.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        text = TR("关闭"),
        normalImage = "c_28.png",
        position = cc.p(220, 300),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 前往按钮
    local goBtn = ui.newButton({
        text = TR("立即前往"),
        normalImage = "c_95.png",
        size = cc.size(125,51),
        position = cc.p(435, 300),
        clickAction = function()
            LayerManager.addLayer({
                name = "activity.ActivityMainLayer",
                data = {
                    moduleId = ModuleSub.eExtraActivity,
                    showSubModelId = ModuleSub.eStartworkReward
                }
            })
        end
    })
    self.mParentLayer:addChild(goBtn)
end

return StartworkPopLayer