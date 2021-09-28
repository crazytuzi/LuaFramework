--[[
    SectPrestigeLayer.lua
    描述: 门派声望总览界面
    创建人: yanghongsheng
    创建时间: 2017.8.23
-- ]]

local SectPrestigeLayer = class("SectPrestigeLayer", function()
    return display.newLayer()
end)

function SectPrestigeLayer:ctor()
	-- 获取声望列表
	local prestigeData = SectObj:getSectCoinList()
	self.sectData = prestigeData.allSect
	self.curSectId = prestigeData.curSectId
	-- 框体大小
	self.boxSize = cc.size(560, 370)
	-- 列表项大小
	self.cellSize = cc.size(480, 120)
	-- 当前门派进度背景
	self.bBgSize = cc.size(485, 75)
	self.tBgSize = cc.size(470, 60)
	-- 列表背景
	self.listSize = cc.size(500, 260)

	self:initUI()
end

function SectPrestigeLayer:initUI()
	-- 创建进度条
	local function createProgressBar(texture, currValue, maxValue)
		-- 进度条
		local ProgressBar = require("common.ProgressBar"):create({
				bgImage = "xxzy_01.png",
				barImage = texture,
				currValue = currValue,
				maxValue = maxValue,
				needLabel = true,
				color = cc.c3b(0xF7, 0xF5, 0xF0),
				barType = ProgressBarType.eHorizontal,
			})
		local size = ProgressBar:getContentSize()
		
		return ProgressBar
	end
	-- 创建一项
	local function createListItem(sectID, sectCoin)
		local itemLayout = ccui.Layout:create()
		itemLayout:setContentSize(self.cellSize)

		-- 背景
		local itemBg = ui.newScale9Sprite("c_18.png", self.cellSize)
		itemBg:setPosition(self.cellSize.width*0.5, self.cellSize.height*0.45)
		itemLayout:addChild(itemBg)
		-- 门派图标
		local sectSprite = ui.newSprite(SectModel.items[sectID].headPic..".png")
		sectSprite:setScale(0.8)
		sectSprite:setPosition(self.cellSize.width*0.13, self.cellSize.height*0.5)
		itemBg:addChild(sectSprite)
		-- 进度条图
		local progressTexture = "xxzy_02.png"
		-- 当前图标
		if sectID == self.curSectId then
			local curSprite = ui.newSprite("mp_62.png")
			curSprite:setPosition(self.cellSize.width*0.23, self.cellSize.height*0.58)
			itemBg:addChild(curSprite)

			progressTexture = "mp_04.png"
		end
		-- 当前职阶
		local rankData = self:getCurRank(sectCoin)
		local rankLabel = ui.newLabel({
				text = TR("职位：%s", rankData.name),
				size = 22,
				color = cc.c3b(0x59, 0x28, 0x17),
			})
		rankLabel:setAnchorPoint(cc.p(0, 0.5))
		rankLabel:setPosition(self.cellSize.width*0.45, self.cellSize.height*0.25)
		itemBg:addChild(rankLabel)
		-- 进度条
		local nextID = rankData.ID - 1
		local maxValue = nextID > 0 and SectRankModel.items[nextID].needSectCoinMin or rankData.needSectCoinMin
		local progressBar = createProgressBar(progressTexture, sectCoin, maxValue)
		progressBar:setAnchorPoint(cc.p(1, 0.5))
		progressBar:setPosition(self.cellSize.width*0.95, self.cellSize.height*0.65)
		itemBg:addChild(progressBar)

		return itemLayout
	end
	-- 弹框函数
	local function DIYfunc(boxRoot, bgSprite, bgSize)
		-- 列表背景
		local listBg = ui.newScale9Sprite("c_17.png", self.listSize)
		listBg:setPosition(bgSize.width*0.5, bgSize.height*0.45)
		bgSprite:addChild(listBg)
		-- 列表
		local prestigeList = ccui.ListView:create()
	    prestigeList:setDirection(ccui.ScrollViewDir.vertical)
	    prestigeList:setBounceEnabled(true)
	    prestigeList:setContentSize(self.listSize)
	    prestigeList:setItemsMargin(5)
	    prestigeList:setGravity(ccui.ListViewGravity.centerHorizontal)
	    prestigeList:setAnchorPoint(cc.p(0.5, 0.5))
	    prestigeList:setPosition(self.listSize.width*0.5, self.listSize.height*0.5)
	    listBg:addChild(prestigeList)

	    -- 排序表
	    local tempList = {}
	    for key, value in pairs(self.sectData) do
	    	local item = {}
	    	item.sectID = key
	    	item.sectCoin = value
	    	table.insert(tempList, item)
	    end
	    table.sort(tempList, function(item1, item2)
	    	return item1.sectID == self.curSectId
	    end)

	    -- 填充列表
	    for _, value in pairs(tempList) do
	    	local item = createListItem(value.sectID, value.sectCoin)
	    	prestigeList:pushBackCustomItem(item)
	    end

		-- 规则按钮
		local ruleBtn = ui.newButton({
	    normalImage = "c_72.png",
	    clickAction = function()
	        local rule = {
	            [1] = TR("1.加入门派后，只能获得当前门派的声望，不同门派的声望不通用"),
	            [2] = TR("2.获得的声望可用于藏经阁购买功法、招式、绝学"),
	            [3] = TR("3.累计获得一定声望后，可以提升在该门派的称号"),
	            [4] = TR("4.退出门派后，之前的门派声望会保留"),
	        }
	        MsgBoxLayer.addRuleHintLayer(TR("规则"), rule)
	    end})
	    ruleBtn:setPosition(40, bgSize.height-35)
	    bgSprite:addChild(ruleBtn)
	end

	-- 创建对话框
    LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            notNeedBlack = true,
            bgSize = self.boxSize,
            title = TR("声望总览"),
            DIYUiCallback = DIYfunc,
            closeBtnInfo = {},
            btnInfos = {},
        },
        
    })
end

function SectPrestigeLayer:getCurRank(sectCoin)
	for i, v in ipairs(SectRankModel.items) do
		if sectCoin >= v.needSectCoinMin then
			return v
		end
	end
end

return SectPrestigeLayer