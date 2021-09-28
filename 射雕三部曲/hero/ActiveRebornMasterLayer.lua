--[[
    文件名：ActiveRebornMasterLayer.lua
    描述：转生大师激活页面(经脉共鸣激活)
    创建人: zouhuajie
    创建时间: 2017.09.11
--]]

local ActiveRebornMasterLayer = class("ActiveRebornMasterLayer", function()
    return display.newLayer()
end)

--[[
    params:
        {
            rebornLv: 当前激活的经脉共鸣等级
            callback: 弹窗结束回调
        }
]]
-- 构造函数
function ActiveRebornMasterLayer:ctor(params)
    dump(params, "ActiveRebornMasterLayer")
    self.mRebornLv = params and params.rebornLv or 0
    self.mEndCallback = params and params.callback or nil
    if self.mRebornLv == 0 then
        return
    end

    -- 播放音效
    MqAudio.playEffect("hetijihuo.mp3")

    -- 页面适配
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self:initUI()
end

-- 初始化页面
function ActiveRebornMasterLayer:initUI()
     -- 窗体
    local bgSprite = ui.newSprite("c_93.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    local bgSize = bgSprite:getContentSize()

    -- 显示标题
    local titleSprite = ui.newSprite("jm_59.png")
    titleSprite:setPosition(bgSize.width * 0.5, bgSize.height - 50)
    bgSprite:addChild(titleSprite)

    -- 显示激活信息
    local infoLabel = ui.newLabel({
        text = TR("6人经脉共鸣达到%s%s重", "#88DCFF", self.mRebornLv),
        size = 24,
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eOutlineColor,
    })
    infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
    infoLabel:setPosition(bgSize.width * 0.5, 105)
    bgSprite:addChild(infoLabel)

    -- 显示属性背景
    local attrBgSprite = ui.newSprite("zdjs_06.png")
    local attrBgSize = attrBgSprite:getContentSize()
    attrBgSprite:setPosition(320, 50)
    bgSprite:addChild(attrBgSprite)

    -- 显示加成信息
    local attrLabel = ui.newLabel({
        text = RebornLvActiveModel.items[self.mRebornLv].intro,
        size = 24,
        color = cc.c3b(0xa9, 0xff, 0x7f)
    })
    attrLabel:setPosition(attrBgSize.width / 2, attrBgSize.height / 2)
    attrBgSprite:addChild(attrLabel)

    bgSprite:runAction(cc.Sequence:create({
        cc.ScaleTo:create(0.2, 1),
        cc.DelayTime:create(1.5),
        cc.FadeOut:create(0.3),
        cc.CallFunc:create(function ()
            self:closeMyself()
        end)
    }))

    -- 注册触摸关闭事件
    ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
            self:closeMyself()
        end,
    })
end

-- 关闭当前页面
function ActiveRebornMasterLayer:closeMyself()
    if self.mEndCallback then
        self.mEndCallback()
    end
    LayerManager.removeLayer(self)
end

return ActiveRebornMasterLayer