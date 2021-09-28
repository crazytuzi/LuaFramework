--[[
    文件名：OverallRankMainLayer
    描述：跨服总榜页面
    创建人：yuanhuangjing
    修改人：chenqiang
    创建时间：2016.4.27
-- ]]

local OverallRankMainLayer = class("OverallRankMainLayer",function ()
	return display.newLayer()
end)

local RankType = {
	zhanli = ModuleSub.eFapBoard,
	dengji = ModuleSub.eLvBoard,
	-- zhuzai = ModuleSub.ePVPInter,
}

local tabType = {
	RankType.zhanli,
	RankType.dengji,
	-- RankType.zhuzai
}

local childLayerZorder = 1
local parentLayerZorder = childLayerZorder + 1
local bottomSpriteZorder = parentLayerZorder + 1

--主界面初始化
--[[
    params: 参数列表
    {
        rankType: 可选参数，选中排行榜类型
    }
--]]
function OverallRankMainLayer:ctor(params)
	--变量
    self.mRankType = -1
	self.mChildLayer = nil             --子页面
	self.mCellButtons = {}             --顶部按钮列表
    
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer, parentLayerZorder)

    -- 初始化UI
	self:initUI()

    -- 创建对应活动页面
    local ttype = params.rankType
    self:setRankLayer(ttype)
end

--初始化UI
function OverallRankMainLayer:initUI()
    --创建顶部资源栏和底部导航栏
    local bottomSprite = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eSTA, 
            ResourcetypeSub.eDiamond, 
            ResourcetypeSub.eGold
        }
    })
    self:addChild(bottomSprite, bottomSpriteZorder)

    self:initTopUI()
    self:initMiddleUI()
end

--创建顶部背景栏
function OverallRankMainLayer:initTopUI()
    --创建顶部背景
    local topSprite = ui.newScale9Sprite("c_69.png", cc.size(588, 137))
    topSprite:setPosition(320, 1136 - 45)
    topSprite:setAnchorPoint(cc.p(0.5, 1))
    self.mTopSprite = topSprite
    self.mTopSize = topSprite:getContentSize()
    self.mParentLayer:addChild(topSprite, 2)
    --创建listView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setContentSize(cc.size(self.mTopSize.width - 90, self.mTopSize.height))
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(self.mTopSize.width * 0.5, self.mTopSize.height * 0.5)
    self.mListView:setItemsMargin(10)
    self.mTopSprite:addChild(self.mListView)

    for i = 1, #tabType  do
        self.mListView:pushBackCustomItem(self:createCellView(i))
    end
end

--创建中部规则按钮
function OverallRankMainLayer:initMiddleUI()
	--规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        textColor = Enums.Color.eYellow,
        position = cc.p(50, 926),
        clickAction = function ()
            print("规则")
            MsgBoxLayer.addRuleHintLayer(TR("规则"),{
                TR("1.排行榜分为等级榜、战力榜"),
                TR("2.等级榜、战力榜排名规则：选取本服排名前十名的玩家，然后根据临近自己服务器id序号的其他4组服务器，综合这5组服务器玩家进行排名"),
                TR("3.等级榜、战力榜每日零点刷新排名信息"),
            })
        end
    })
    self.mParentLayer:addChild(ruleBtn)

    -- 退出按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        --anchorPoint = cc.p(0.5, 0),
        clickAction = function()
            LayerManager.removeLayer(self)
        end     
    })
    closeBtn:setPosition(594, 926)
    self.mParentLayer:addChild(closeBtn)
end

function OverallRankMainLayer:createCellView(index)
    local rankType = tabType[index]
    local width = 110
    local height = self.mTopSize.height

    local custom_item = ccui.Layout:create()
    custom_item:setContentSize(cc.size(width, height))

    --按钮上显示的图片
    local normalImage, disabledImage, titleImage = nil
    if rankType == RankType.zhanli then
        normalImage = "gd_22.png"
        disabledImage = "gd_22.png"
    elseif rankType == RankType.dengji then
        normalImage = "gd_23.png"
        disabledImage = "gd_23.png"
    elseif rankType == RankType.zhuzai then
        normalImage = "phb_01.png"
        disabledImage = "phb_02.png"
    end

    --创建点击按钮
    local cellButton = ui.newButton({
        normalImage = normalImage,
        disabledImage = disabledImage,
        position = cc.p(width * 0.5, height * 0.5),
        clickAction = function()
            --模块是否开启
            if not ModuleInfoObj:moduleIsOpenInServer(rankType) or not ModuleInfoObj:modulePlayerIsOpen(rankType, true) then
                return
            end
            
            self:setRankLayer(rankType)
        end
    })
    cellButton.type = rankType
    table.insert(self.mCellButtons, cellButton)
    custom_item:addChild(cellButton)
    local tempSize = cellButton:getContentSize()

    local selectSprite = ui.newSprite("c_116.png")
    selectSprite:setPosition(tempSize.width * 0.5, tempSize.height * 0.5 + 8)
    cellButton:addChild(selectSprite, -1)
    selectSprite:setVisible(false)
    cellButton.selectSprite = selectSprite

    -- 有模块Id的按钮需要添加小红点的逻辑
    if rankType then
        if rankType == RankType.zhuzai then
            -- 超脱榜
        else
            local moduleId = rankType
            local function dealRedDotVisible(redDotSprite)
                local redDotData = RedDotInfoObj:isValid(moduleId)
                redDotSprite:setVisible(redDotData)
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(moduleId), parent = cellButton})
        end
    end

    return custom_item
end

--[[
函数：设置排行的三个界面
参数：页面类型
--]]
function OverallRankMainLayer:setRankLayer(rankType)
    if rankType ==nil then
        rankType = RankType.zhanli
    end
    if self.mRankType == rankType then
        for _, button in pairs(self.mCellButtons) do
            if button.type == self.mRankType then
                button:setEnabled(false)
            end
        end
        return
    end

    self.mRankType = rankType
  
    for _, button in pairs(self.mCellButtons) do
        button:setEnabled(button.type ~= self.mRankType)
        button.selectSprite:setVisible(button.type == self.mRankType)
    end
    if self.mChildLayer then
        self.mChildLayer:removeFromParent()
    end
   
    if self.mRankType == RankType.zhanli  then
        self.mChildLayer = require("pvpinter.OverallRankFapLayer").new(self)
        self:addChild(self.mChildLayer, childLayerZorder)
    elseif self.mRankType == RankType.dengji then
        self.mChildLayer = require("pvpinter.OverallRankLvLayer").new(self)
        self:addChild(self.mChildLayer, childLayerZorder)
    elseif self.mRankType == RankType.zhuzai then
        self.mChildLayer = require("pvpinter.OverallRankZZLayer").new(self)
        self:addChild(self.mChildLayer, childLayerZorder)
    end

end

-- 获取恢复数据
function OverallRankMainLayer:getRestoreData()
    local retData = {
        rankType = self.mRankType,
    }

    return retData
end

return OverallRankMainLayer