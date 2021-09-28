--[[
    文件名：MarqueeMsgLayer
	描述：显示走马灯信息的Layer
	创建人：liaoyuangang
	创建时间：2016.3.30
-- ]]

local MarqueeMsgLayer = class("MarqueeMsgLayer", function()
    return display.newLayer()
end)

--
function MarqueeMsgLayer:ctor()
    self.mParentNode = ui.newStdLayer()
    self:addChild(self.mParentNode)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function MarqueeMsgLayer:initUI()
    -- 创建走马灯信息背景
    self.mBgSprite = ui.newSprite("c_149.png")
    self.mBgSprite:setAnchorPoint(cc.p(0, 0.5))
    self.mParentNode:addChild(self.mBgSprite)
    self.mBgSprite:setVisible(false)

    -- 背景的大小
    self.mBgSize = self.mBgSprite:getContentSize()
    -- 走马灯信息显示区域的大小
    self.mMsgSize = cc.size(470, self.mBgSize.height - 10)

    -- 走马灯信息的显示区域的剪裁控件
    local tempNode = ui.newScale9Sprite("c_149.png", self.mMsgSize)
    tempNode:setAnchorPoint(cc.p(0, 0))
    local clippNode = cc.ClippingNode:create(tempNode)
    clippNode:setPosition(45, 0)
    self.mBgSprite:addChild(clippNode)

    -- 创建显示走马灯信息的label
    self.mMsgLabel = ui.newLabel({
        text = "",
        size = 22,
        color = Enums.Color.eGold,
    })
    self.mMsgLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mMsgLabel:setPosition(0, self.mMsgSize.height / 2)
    clippNode:addChild(self.mMsgLabel)

    -- 创建奔跑的人物骨骼动画
    -- ui.newEffect({
    --     parent = self.mBgSprite,
    --     effectName = "effect_ui_adv",
    --     position = cc.p(0, 0),
    --     scale = 0.12,
    --     loop = true,
    --     endRelease = true,
    -- })
end

--
function MarqueeMsgLayer:onEnterTransitionFinish()
    local msgIsViewing = false
    Utility.schedule(self, function()
        if msgIsViewing then
            return
        end
        local tempStr = self:getMarqueeMsgStr()
        if not tempStr or tempStr == "" then
            self.mMsgLabel:setString("")
            self.mBgSprite:setVisible(false)
            return
        end
        msgIsViewing = true

        self.mMsgLabel:setString(tempStr)
        self.mMsgLabel:setPosition(0, self.mMsgSize.height / 2)
        local bgPosY = math.random(750, 920)
        self.mBgSprite:setPosition(640, bgPosY)
        self.mBgSprite:setVisible(true)

        -- 背景的action
        self.mBgSprite:runAction(cc.Sequence:create({
            cc.MoveBy:create(5, cc.p(-600, 0)),
            cc.CallFunc:create(function()
                local tempWidth = self.mMsgLabel:getContentSize().width
                local tempTime = tempWidth / 120
                local labelActionList = {
                    cc.MoveBy:create(tempTime, cc.p(-tempWidth, 0)),
                    cc.CallFunc:create(function()
                        self.mBgSprite:setVisible(false)
                        msgIsViewing = false
                    end),
                }
                self.mMsgLabel:runAction(cc.Sequence:create(labelActionList))
            end),
        }))
    end, 1.0)
end

function MarqueeMsgLayer:onExitTransitionStart()
    self.mBgSprite:stopAllActions()
    self.mMsgLabel:stopAllActions()
end

-- 获取滚动消息的字符串格式
--[[
-- 滚动消息的数据格式为：
    {
		TemplateName:模板名 (运营类型消息模板为: System)
		Weight: 权重
		AriseNum:显示次数
		StarTime: 开始显示时间
		EndTime: 结束显示时间
		Content :
		[
			{
				ResourceTypeSub : 0
				Count : 0
				Value : 赵敏
			}
			{
				ResourceTypeSub : 0
				Count : 0
				Value : 尖子生
			}
                   注: 游戏资源走马灯参数格式
                       ResourceTypeSub值唯一,
                       Count无效,
                       Value:(模型Id,数量|模型Id,数量..)以'|'分割
			{
				ResourceTypeSub : 1201
				Count : 0
				Value : 12012003,1|12012004,9
			}
		]
	}
 ]]
function MarqueeMsgLayer:getMarqueeMsgStr()
    local tempMsg = MarqueeObj:getMarqueeMessage(self:getParent())
    if type(tempMsg) ~= "table" then
        return tempMsg
    end

    if tempMsg.TemplateName == "System" then  -- 运营类型消息
        local ret
        if #tempMsg.Content > 0 then
            ret = tempMsg.Content[1].Value
        else
            ret = ""
        end
        return ret
    end

    local templateItem = MarqueeTemplateModel.items[tempMsg.TemplateName]
    local msgTemplate = templateItem and templateItem.templateText or ""
    if not msgTemplate or msgTemplate == "" then
        return ""
    end
    
    local msgVlaue = {}
    for i = 1, #tempMsg.Content do
        local resType = tempMsg.Content[i].ResourceTypeSub
        if not resType or resType == 0 then
            local tempValue = tempMsg.Content[i].Value
            table.insert(msgVlaue, tempValue)
        else
            if resType == ResourcetypeSub.eHero or Utility.isEquip(resType) or Utility.isTreasure(resType) or
                    Utility.isGoods(resType, true) or Utility.isIsTresureDebris(resType) then
                local itemList = string.splitBySep(tempMsg.Content[i].Value, "|")
                local strList = {}
                for index, item in pairs(itemList) do
                    local tempList = string.splitBySep(item, ",")
                    if #tempList == 2 then
                        local tempName = Utility.getGoodsName(resType, tonumber(tempList[1]))
                        local tempCount = tonumber(tempList[2])
                        if tempCount > 1 then
                            table.insert(strList, string.format("%sX%d", tempName, tempCount))
                        else
                            table.insert(strList, tempName)
                        end
                    end
                end
                local tempStr = (#strList > 0) and table.concat(strList, ", ") or ""
                table.insert(msgVlaue, tempStr)
            else
                local tempCount = tempMsg.Content[i].Count
                local tempName = ResourcetypeSubName[resType]
                table.insert(msgVlaue, string.format("%sX%d", tempName, tempCount))
            end
        end
    end
    return string.dynamicFormat(msgTemplate, msgVlaue)
end

return MarqueeMsgLayer

