--[[
    文件名: QuickExpMeetActionLayer.lua
	描述: 出现奇遇 奇遇执行的动作场景
	创建人: lichunsheng
	创建时间: 2017.07.11
--]]

local QuickExpMeetActionLayer = class("QuickExpMeetActionLayer", function()
    return display.newLayer()
end)

--[[
params:
	meetInfo : 奇遇
	targetPos : 目标位置
	callback: 回调
	parent: 父节点
--]]
function QuickExpMeetActionLayer:ctor(params)

	local meetInfo = params.meetInfo
	local targetPos = params.targetPos
    if not meetInfo or #meetInfo <= 0 then
        self:removeFromParent()
        params.callBack(params.parent)
        return
    end


	--创建总节点
	local node = cc.Node:create()
    self:addChild(node)
    node:setAnchorPoint(cc.p(0.5, 0.5))
    node:setLocalZOrder(Enums.ZOrderType.eNewbieGuide + 5)
    self:setLocalZOrder(6)
    params.parent.mParentLayer:addChild(self)

    --绘制图标
    local lines = math.ceil(#meetInfo / 4)
    self.mBgSize = cc.size(640, 120 * lines + 30)
    local startPosY = self.mBgSize.height - 60
    local tempPosX = self.mBgSize.width / 2
    for index, item in ipairs(meetInfo) do
        local currLine = math.ceil(index / 4)
        local tempIndex = index - (currLine - 1) * 4
        local currLineCount = math.min(#meetInfo - (currLine - 1) * 4, 4)
        local tempPosX = (tempPosX - (currLineCount - 1) * 60) + (tempIndex - 1) * 120
        local tempPosY = startPosY - (currLine - 1) * 120
        local icon = ui.newSprite(QuickexpMeetModel.items[meetInfo[index].TypeId].pic .. ".png")
        icon:setPosition(tempPosX, tempPosY + 150)
        icon:setTag(index)
        node:addChild(icon, Enums.ZOrderType.eNewbieGuide + 5)
    end
    node:setPosition(0, 500 - lines * 60)
    print("奇遇排数=", lines)

    --添加奇遇特效
    local findEfeect = ui.newEffect({
        parent = node,
        effectName = "effect_ui_faxianqiyu",
        position = cc.p(320, lines * 120 + 230),
        loop = false,
        endListener = function()
        end
    })

    --执行动画
    for index, item in ipairs(meetInfo) do
        local child = node:getChildByTag(index)
        --从小变大
        child:setScale(0.1)
        local scaleTo = cc.ScaleTo:create(0.4, 1.3)
       	scaleTo = cc.EaseBounceOut:create(scaleTo)
        --延迟
        local delay = cc.DelayTime:create(0.5)
        --移动
        local moveto = cc.MoveTo:create(0.5, cc.p(targetPos.x  - node:getPositionX(),
                                                targetPos.y - node:getPositionY()))
        local callback = cc.CallFunc:create(function()
            if index == #meetInfo then
                self:removeFromParent()
                params.callBack(params.parent)
            end
        end)
        child:runAction(cc.Sequence:create(scaleTo, delay, moveto, callback))
    end
end

return QuickExpMeetActionLayer
