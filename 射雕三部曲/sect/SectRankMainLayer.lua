--[[
    SectRankMainLayer.lua
    描述: 门派排行榜
    创建人: yanghongsheng
    创建时间: 2017.8.31
-- ]]

--[[
    params:
        selectId    -- 选中门派id

]]

local SectRankMainLayer = class("SectRankMainLayer", function(params)
    return display.newLayer()
end)

function SectRankMainLayer:ctor(params)
    -- 初始化成员
    -- 选中门派id
    self.selectId = params.selectId or SectObj:getPlayerSectInfo().SectId

    -- 子页面的parent
    self.mSubLayerParent = cc.Node:create()
    self:addChild(self.mSubLayerParent)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 请求数据
    self:requestInfo()
end

-- 初始化界面
function SectRankMainLayer:initUI()
    local topPosY = 1136 - 110
    -- 列表背景
    local listBg = ui.newScale9Sprite("c_69.png", cc.size(620, 160))
    listBg:setPosition(320, topPosY)
    self.mParentLayer:addChild(listBg)
    -- 门派列表
    self.sectListView = ccui.ListView:create()
    self.sectListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.sectListView:setBounceEnabled(true)
    self.sectListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.sectListView:setContentSize(cc.size(580, 150))
    self.sectListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.sectListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.sectListView:setPosition(320, topPosY)
    self.mParentLayer:addChild(self.sectListView)

    self:refreshList()

    self:changePage(self.selectId)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
    self.closeBtn = closeBtn
end

-- 刷新列表
function SectRankMainLayer:refreshList()
    -- 创建一项
    local function createItem(data)
        local cellSize = cc.size(150, 150)
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)

        -- 点击按钮
        local tempBtn = ui.newButton({
            normalImage = data.headPic..".png",
            clickAction = function()
                if self.selectId == data.ID then
                    return
                end

                self:changePage(data.ID)
            end
        })
        tempBtn:setPosition(cellSize.width / 2, cellSize.height / 2 + 5)
        lvItem:addChild(tempBtn)

        return lvItem
    end
    -- 清空列表
    self.sectListView:removeAllChildren()
    -- 填充列表
    for _, v in ipairs(SectModel.items) do
        -- 判断该派声望排行是否存在
        if SectObj:getRankInfo(v.ID) then
            local item = createItem(v)
            self.sectListView:pushBackCustomItem(item)
        end
    end
end

-- 切换页面
function SectRankMainLayer:changePage(Id)
    -- 更新当前id
    self.selectId = Id

    -- 删除老页面
    if not tolua.isnull(self.mSubLayer) then
        self.mSubLayer:removeFromParent()
        self.mSubLayer = nil
    end
    -- 添加新界面
    self.mSubLayer = require("sect.SectRankSubLayer"):create({sectId = Id})
    self.mSubLayerParent:addChild(self.mSubLayer)
end


-----------------服务器相关-----------------
-- 请求初始信息
function SectRankMainLayer:requestInfo()
    SectObj:requestAllRankInfo(function ()
        self:initUI()
    end)
end

return SectRankMainLayer