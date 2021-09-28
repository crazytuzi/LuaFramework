--[[
	文件名：OtherMoreLayer.lua
	描述：查看他人的其他属性页面
	创建人: peiyaoqiang
	创建时间: 2017.05.28
--]]

local OtherMoreLayer = class("OtherMoreLayer", function()
	return display.newLayer()
end)

-- 初始化函数
--[[
	params: 参数列表
	{
		showIndex: 可选参数，进入阵容后直接显示的人物（1是主角，2~6是普通人物）
		formationObj: 其他玩家的阵容数据对象
        playerLv: 其它玩家的等级
	}
--]]
function OtherMoreLayer:ctor(params)
	-- 处理参数
	self.mShowIndex = params.showIndex or 1
	self.mFormationObj = params.formationObj
    self.mPlayerLv = params.playerLv

	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("其他属性"),
		bgSize = cc.size(632, 900),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存弹窗控件信息
	self.mBgSprite = bgLayer.mBgSprite
	self.mBgSize = bgLayer.mBgSprite:getContentSize()
	
	-- 初始化UI
	self:initUI()
	self:refreshList()
end

-- 初始化UI
function OtherMoreLayer:initUI()
	-- 头像背景
	local headerViewBg = ui.newScale9Sprite("c_38.png", cc.size(self.mBgSize.width - 60, 130))
	headerViewBg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 135)
	self.mBgSprite:addChild(headerViewBg)

	-- 头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
    	needPet = false,
    	needMate = false,
        showSlotId = self.mShowIndex,
        formationObj = self.mFormationObj,
        viewSize = cc.size(self.mBgSize.width - 80, 106),
        onClickItem = function(slotIndex)
        	if (not self.mFormationObj:slotIsEmpty(slotIndex)) then
	        	self.mShowIndex = slotIndex
	        	self:refreshList()
	        end
        end
    })
    self.mSmallHeadView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 83)
    self.mBgSprite:addChild(self.mSmallHeadView)

    -- 内容背景
    local listViewBgSize = cc.size(self.mBgSize.width - 60, 650)
	local listViewBg = ui.newScale9Sprite("c_38.png", listViewBgSize)
	listViewBg:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 540)
	self.mBgSprite:addChild(listViewBg)

	-- 内容列表
	local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setContentSize(cc.size(listViewBgSize.width - 20, listViewBgSize.height - 20))
    mListView:setItemsMargin(15)
    mListView:setAnchorPoint(cc.p(0.5, 0.5))
    mListView:setPosition(cc.p(listViewBgSize.width * 0.5, listViewBgSize.height * 0.5))
    listViewBg:addChild(mListView)
    self.mListView = mListView
end

-- 刷新属性列表
function OtherMoreLayer:refreshList()
	self.mListView:removeAllItems()

	-- 刷新头像列表
	if self.mSmallHeadView then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end

	-- 添加内功心法属性
	local zhenjueView = self:createZhenjueView()
	if (zhenjueView ~= nil) then
		self.mListView:pushBackCustomItem(zhenjueView)
	end

	-- 添加真元属性
	local zhenyuanView = self:createZhenyuanView()
	if (zhenyuanView ~= nil) then
		self.mListView:pushBackCustomItem(zhenyuanView)
	end

	-- 添加内力属性
	local neiliView = self:createNeiliView()
	if (neiliView ~= nil) then
		self.mListView:pushBackCustomItem(neiliView)
	end
end

-- 创建内功心法显示
function OtherMoreLayer:createZhenjueView()
	local bgSize = cc.size(552, 168)
	local lvItem = ccui.Layout:create()
    lvItem:setContentSize(bgSize)

    -- 显示背景
    local bgSprite = ui.newNodeBgWithTitle(lvItem, bgSize, TR("内功心法"))
    bgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)

    -- 显示内功列表
    local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowIndex)
    local zhenjueList = slotInfo and slotInfo.Zhenjue
    local haleWidth = bgSize.width * 0.5
    local xPosList = {haleWidth - 225, haleWidth - 135, haleWidth - 45, haleWidth + 45, haleWidth + 135, haleWidth + 225}
    for i=1,6 do
    	local zhenjueInfo = zhenjueList[i]
    	local isValid = zhenjueInfo and Utility.isEntityId(zhenjueInfo.Id)
    	local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eCircle,
	        allowClick = true, 
	        onClickCallback = function()
	        	if isValid then
		        	LayerManager.addLayer({
			            name = "zhenjue.ZhenjueInfoLayer",
			            data = {
			                zhenjueInfo = zhenjueInfo,
			            },
			            cleanUp = false
			        })
		        end
	        end,  
		})
		tempCard:setScale(0.9)
		tempCard:setPosition(xPosList[i], 75)
		if isValid then
			tempCard:setZhenjue(zhenjueInfo, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eZhenjueType, CardShowAttr.eStep})
            -- 洗炼进度百分比
            local retPercent = ZhenjueObj:calcPercent(zhenjueInfo.Id, zhenjueInfo, self.mPlayerLv)
            if (retPercent > 0) then
                local percentLabel = ui.newLabel({
                    text = string.format("%.1f%%", retPercent * 100),
                    color = cc.c3b(0xfd, 0xfa, 0xf1),
                    outlineColor = Enums.Color.eBlack,
                    size = 20,
                })
                local cardSize = tempCard:getContentSize()
                percentLabel:setPosition(cardSize.width / 2, 15)
                tempCard:addChild(percentLabel, CardShowAttr.ePercent)
            end
		else
			local typeId = self.mFormationObj:getZhenjueSlotType(i)
			local viewInfo = Utility.getZhenjueViewInfo(typeId)
			tempCard:setEmpty({}, "c_04.png", viewInfo.emptyImg)
		end
		bgSprite:addChild(tempCard)
    end
    
    return lvItem
end

-- 创建真元显示
function OtherMoreLayer:createZhenyuanView()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowIndex)
	local zhenyuanList = slotInfo and slotInfo.ZhenYuan
	if (zhenyuanList == nil) then
		return nil
	end

	-- 
	local bgSize = cc.size(552, 168)
	local lvItem = ccui.Layout:create()
    lvItem:setContentSize(bgSize)

    -- 显示背景
    local bgSprite = ui.newNodeBgWithTitle(lvItem, bgSize, TR("真元"))
    bgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)

    -- 显示内功列表
    local haleWidth = bgSize.width * 0.5
    local xPosList = {haleWidth - 225, haleWidth - 135, haleWidth - 45, haleWidth + 45, haleWidth + 135, haleWidth + 225}
    for i=1,6 do
    	local zhenyuanInfo = zhenyuanList[i]
    	local isValid = zhenyuanInfo and Utility.isEntityId(zhenyuanInfo.Id)
    	local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eCircle,
	        allowClick = true, 
	        onClickCallback = function()
	        	if isValid then
		        	LayerManager.addLayer({
			            name = "zhenyuan.ZhenyuanInfoLayer",
			            data = {
			                zhenyuanInfo = zhenyuanInfo,
			                onlyViewInfo = true,
			            },
			            cleanUp = false
			        })
		        end
	        end,  
		})
		tempCard:setScale(0.9)
		tempCard:setPosition(xPosList[i], 75)
		if isValid then
			tempCard:setZhenyuan(zhenyuanInfo, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel})
		else
			tempCard:setEmpty({}, "zy_12.png")
		end
		bgSprite:addChild(tempCard)
    end
    
    return lvItem
end

-- 创建内力显示
function OtherMoreLayer:createNeiliView()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowIndex)
	local NeiliInfoList = slotInfo.HeroNeiliInfo
	if (NeiliInfoList == nil) then
		return nil
	end
	
	local bgSize = cc.size(552, 168)
	local lvItem = ccui.Layout:create()
    lvItem:setContentSize(bgSize)

    -- 显示背景
    local bgSprite = ui.newNodeBgWithTitle(lvItem, bgSize, TR("内力"))
    bgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)

    -- 内力类型图
    local NeiliTypePic = {
    	"db_1140.png",
    	"db_1141.png",
    	"db_1142.png",
	}
	-- 内力坐标
	local NeiliPosList = {
		cc.p(15, 70),
		cc.p(200, 70),
		cc.p(395, 70),
	}

    for _, neiliModel in ipairs(NeiliTypeModel.items) do
    	local neiliInfo = NeiliInfoList[tostring(neiliModel.ID)] or {}
    	local floor = neiliInfo.Floor or 0
    	local lv = neiliInfo.Lv or 0

    	local parentSize = cc.size(150, 55)
    	local parentNode = cc.Node:create()
    	parentNode:setContentSize(parentSize)
    	parentNode:setAnchorPoint(cc.p(0, 0.5))
    	parentNode:setPosition(NeiliPosList[neiliModel.ID])
    	bgSprite:addChild(parentNode)

    	local widthCount = 0

    	-- 内力类型图
    	local typeSprite = ui.newSprite(NeiliTypePic[neiliModel.ID])
    	typeSprite:setAnchorPoint(cc.p(0, 0.5))
    	typeSprite:setPosition(widthCount, parentSize.height*0.5)
    	parentNode:addChild(typeSprite)
    	widthCount = widthCount + typeSprite:getContentSize().width

    	-- 重数
    	local floorNumLabel = ui.newNumberLabel({
    			text = floor == 10 and ":" or floor,
    			imgFile = "nl_23.png",
    			charCount = 11,
    		})
    	floorNumLabel:setAnchorPoint(cc.p(0, 0.5))
    	floorNumLabel:setPosition(widthCount, parentSize.height*0.5)
    	parentNode:addChild(floorNumLabel)
    	widthCount = widthCount + floorNumLabel:getContentSize().width

    	-- 阶数
    	local lvBg = ui.newSprite("nl_18.png")
    	lvBg:setAnchorPoint(cc.p(0, 0.5))
    	lvBg:setPosition(widthCount-5, parentSize.height*0.5)
    	parentNode:addChild(lvBg)
    	local lvNumLabel = ui.newNumberLabel({
    			text = lv == 10 and ":" or lv,
    			imgFile = "nl_23.png",
    			charCount = 11,
    		})
    	lvNumLabel:setPosition(lvBg:getContentSize().width*0.5, lvBg:getContentSize().height*0.5)
    	lvBg:addChild(lvNumLabel)
    end

    return lvItem
end

return OtherMoreLayer
