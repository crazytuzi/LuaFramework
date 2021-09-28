--[[
    文件名: DlgUpdateWayLayer.lua
    描述：玩家升级途径页面
    创建人：peiyaoqiang
    创建时间：2018.03.19
--]]

local DlgUpdateWayLayer = class("DlgUpdateWayLayer", function(params)
    return display.newLayer()
end)

-- 构造函数
--[[
-- 参数结构：
	{
		needToLv  		  需要升到的等级
	}
--]]
function DlgUpdateWayLayer:ctor(params)
    -- 创建背景
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("前往升级"),
        bgSize = cc.size(600, 480),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer, -1)
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()
    self.needToLv = params.needToLv or 0

    -- 初始化
    self:initUI()
end

-- 创建UI
function DlgUpdateWayLayer:initUI()
    local function addInfoLabel(pos, str)
        local label = ui.newLabel({
            text = str,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0.5, 1),
            x = pos.x,
            y = pos.y,
        })
        self.mBgSprite:addChild(label)
    end
    addInfoLabel(cc.p(300, 405), TR("您需要升到%s%s%s级后才能继续任务", Enums.Color.eNormalGreenH, self.needToLv, "#46220D"))
    addInfoLabel(cc.p(300, 370), TR("可以通过以下途径升级："))
    
    -- 分割线
    local listBgSize = cc.size(540, 305)
    local listBgSprite = ui.newScale9Sprite("c_17.png", listBgSize)
    listBgSprite:setAnchorPoint(0.5, 0)
    listBgSprite:setPosition(self.mBgSize.width * 0.5, 30)
    self.mBgSprite:addChild(listBgSprite)

    -- 创建列表
    local listViewSize = cc.size(listBgSize.width, listBgSize.height - 20)
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setContentSize(listViewSize)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setItemsMargin(5)
    listView:setAnchorPoint(cc.p(0.5, 0.5))
    listView:setPosition(listBgSize.width * 0.5, listBgSize.height * 0.5)
    listView:setScrollBarEnabled(false)
    listView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    listBgSprite:addChild(listView)

    -- 列表内容
    for _, moduleId in ipairs({ModuleSub.eBattleNormal, ModuleSub.eQuickExp}) do
        local layout = ccui.Layout:create()
        layout:setContentSize(listViewSize.width, 102)
        listView:pushBackCustomItem(layout)

        -- 背景
        local itemSize = cc.size(listBgSize.width - 10, 100)
        local itemBg = ui.newScale9Sprite("c_18.png", itemSize)
        itemBg:setPosition(listViewSize.width * 0.5, 51)
        layout:addChild(itemBg)

        -- 模块名字
        local moduleModel = ModuleSubModel.items[moduleId] or {}
        local label = ui.newLabel({
            text = moduleModel.name,
            color = cc.c3b(0x46, 0x22, 0x0d),
            anchorPoint = cc.p(0, 0.5),
            x = 28,
            y = itemSize.height * 0.5,
        })
        layout:addChild(label)

        -- 跳转按钮
        local button = ui.newButton({
        text = TR("前往"),
        normalImage = "c_28.png",
        position = cc.p(itemSize.width - 80, itemSize.height * 0.5),
        clickAction = function()
            LayerManager.showSubModule(moduleId)
        end
    })
    layout:addChild(button)
    end
end

return DlgUpdateWayLayer
