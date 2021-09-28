--[[
    文件名：GuildBookOverViewLayer.lua
    描述：帮派秘籍学习总揽界面
    创建人：yanghongsheng
    创建时间：2018.1.27
-- ]]

local GuildBookOverViewLayer = class("GuildBookOverViewLayer", function(params)
    return display.newLayer()
end)

function GuildBookOverViewLayer:ctor(params)
	-- 秘籍解锁信息
	self.mCheatsInfo = {}
	-- 秘籍服务器信息
	self.mBookInfo = {}
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eGuildGongfuCoin,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)

    -- 初始化
    self:initUI()

    self:requestInfo()
end

--[[
	整理数据
		self.mCheatsInfo = {	-- 已开放所有秘籍信息
			bookID = 1,
			name = "越女剑法",
			needGuildCoin = 0,
			needGuildLv = 5,
			pic = "bomjn_101",
			smallPic = "bomjn_101s",
			isOpen = 1,
			fashionNeedLearnNum = 31,
			fahionBookModelID = 108,

			state = 0,			-- 秘籍状态（0:未解锁 1:解锁但未达到领悟绝学 2:达到领悟绝学进度 3:学完绝学）
			progress = 0,		-- 秘籍学习进度
		}

]]
function GuildBookOverViewLayer:initData()
	self.mCheatsInfo = {}

	-- 解锁秘籍列表
	local unlockList = {}
	local unlockBookStrList = string.splitBySep(GuildObj:getGuildBookInfo().GuildBook or "", ",")
	for _, unlockBookId in pairs(unlockBookStrList) do
		unlockList[tonumber(unlockBookId)] = true
	end

	for _, cheatsInfo in pairs(GuildLibraryModel.items) do
		if cheatsInfo.isOpen ~= 0 then	-- 排出未开启的
			-- 已经学完的
			if self.mBookInfo[tostring(cheatsInfo.bookID)] and self.mBookInfo[tostring(cheatsInfo.bookID)].IsOver then
				cheatsInfo.state = 3
			-- 还未解锁的
			elseif not unlockList[cheatsInfo.bookID] then
				cheatsInfo.state = 0
			else
				local progress = 0
				for _, bookInfo in pairs(self.mBookInfo[tostring(cheatsInfo.bookID)].BookInfo or {}) do
					progress = progress + bookInfo.Step
				end
				-- 是否达到领悟绝学的要求
				if progress >= cheatsInfo.fashionNeedLearnNum then
					cheatsInfo.state = 2
				else
					cheatsInfo.state = 1
				end

				cheatsInfo.progress = progress
			end

			cheatsInfo.progress = cheatsInfo.progress or 0

			table.insert(self.mCheatsInfo, cheatsInfo)
		end
	end

	-- 排序
	table.sort(self.mCheatsInfo, function (item1, item2)
		-- 学完的（放后面）
		if (item1.state == 3) ~= (item2.state == 3) then
			return not (item1.state == 3)
		end

		return item1.bookID < item2.bookID
	end)
end

function GuildBookOverViewLayer:initUI()
	-- 创建页面背景
    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- title
    local titleSprite = ui.newSprite("bpz_56.png")
    titleSprite:setPosition(320, 1030)
    self.mParentLayer:addChild(titleSprite)

    -- 提示
    local hintLabel = ui.newLabel({
    		text = TR("学完一本帮派秘籍即可领悟相应绝学"),
    		color = Enums.Color.eWhite,
    		outlineColor = Enums.Color.eOutlineColor,
    		size = 24,
    	})
    hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
    hintLabel:setPosition(320, 950)
    self.mParentLayer:addChild(hintLabel)

    -- 列表背景
    local listBgSize = cc.size(620, 800)
    local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
    listBg:setAnchorPoint(cc.p(0.5, 0))
    listBg:setPosition(320, 120)
    self.mParentLayer:addChild(listBg)

    -- 秘籍列表
    self.mFashionListView = ccui.ListView:create()
	self.mFashionListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mFashionListView:setBounceEnabled(true)
	self.mFashionListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mFashionListView:setItemsMargin(5)
	self.mFashionListView:setContentSize(cc.size(listBgSize.width-15, listBgSize.height-15))
	self.mFashionListView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mFashionListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
	listBg:addChild(self.mFashionListView)

	-- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(cc.p(604, 1040))
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 创建时装的技能介绍框
function GuildBookOverViewLayer:showSkillDlg(modelId, isSkill, pos)
    local dlgBgNode = cc.Node:create()
    self.mParentLayer:addChild(dlgBgNode, 1)

    -- 背景图
    local dlgBgSprite = ui.newSprite("zr_53.png")
    local dlgBgSize = dlgBgSprite:getContentSize()
    dlgBgSprite:setAnchorPoint(cc.p(1, 1))
    dlgBgSprite:setPosition(pos)
    dlgBgNode:addChild(dlgBgSprite)

    -- 技能图标
    local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
    for _,v in ipairs(attackList) do
        attackText = attackText .. Enums.Color.eNormalWhiteH .. v
    end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
        node = dlgBgNode,
        allowTouch = true,
        endedEvent = function(touch, event)
            dlgBgNode:removeFromParent()
        end
        })
end

function GuildBookOverViewLayer:createEmptyItem(itemInfo)
	-- 大小
	local cellSize = cc.size(self.mFashionListView:getContentSize().width, 150)

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newScale9Sprite("c_18.png", cellSize)
	cellBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	cellItem:addChild(cellBg)

	-- 敬请期待
	local hintSprite = ui.newSprite("bp_28.png")
	hintSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	cellItem:addChild(hintSprite)

	return cellItem
end

function GuildBookOverViewLayer:createItem(itemInfo)
	-- 大小
	local cellSize = cc.size(self.mFashionListView:getContentSize().width, 150)

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newScale9Sprite("c_18.png", cellSize)
	cellBg:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	cellItem:addChild(cellBg)

	-- 绝学
	local fashionId = GuildBookModel.items[itemInfo.fahionBookModelID].fashionID
	local fashionData = FashionModel.items[fashionId]
	-- 绝学图
    local fashionCard = require("common.CardNode").new({
                allowClick = true,
                onClickCallback = function(sender)
                	local beginPos = sender:getTouchBeganPosition()
                    self:showSkillDlg(fashionData.RAID, true, cc.p(380, beginPos.y/Adapter.MinScale+50))
                end
            })
    fashionCard:setPosition(cellSize.width*0.12, cellSize.height*0.6)
    fashionCard:setSkillAttack({modelId = fashionData.RAID, icon = fashionData.skillIcon .. ".png", notShowSkill = true}, {CardShowAttr.eBorder})
    cellItem:addChild(fashionCard)
    -- 绝学标签
    local jueXueLabelSprite = ui.newSprite("mp_51.png")
    jueXueLabelSprite:setPosition(cellSize.width*0.2, cellSize.height*0.7)
    cellItem:addChild(jueXueLabelSprite)
    -- 绝学名
    local jueXueColor = Utility.getQualityColor(fashionData.quality, 1)
	local nameLabel = ui.newLabel({
			text = fashionData.name,
			size = 20,
			color = jueXueColor,
            outlineColor = cc.c3b(0x17, 0x34, 0x4d),
		})
	nameLabel:setAnchorPoint(cc.p(0.5, 0))
	nameLabel:setPosition(cellSize.width*0.12, cellSize.height*0.1)
	cellItem:addChild(nameLabel)

	-- 提示语
	local hintLabel = ui.newLabel({
			text = TR("需要学完%s", itemInfo.name),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 24,
		})
	hintLabel:setAnchorPoint(cc.p(0, 0.5))
	hintLabel:setPosition(cellSize.width*0.3, cellSize.height*0.7)
	cellItem:addChild(hintLabel)

	-- 进度条
	local progressBar = require("common.ProgressBar"):create({
    	bgImage = "xxzy_01.png",
        barImage = "xxzy_02.png",
        currValue = itemInfo.state == 3 and itemInfo.fashionNeedLearnNum or itemInfo.progress,
        maxValue = itemInfo.fashionNeedLearnNum,
        needLabel = true,
        percentView = false,
        size = 20,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    progressBar:setPosition(cellSize.width*0.52, cellSize.height*0.5)
    cellItem:addChild(progressBar)

    -- 已完成
    if itemInfo.state == 3 then
    	local completeSprite = ui.createSpriteAndLabel({
                imgName = "c_156.png",
                labelStr = TR("已领悟"),
                fontSize = 24,
            })
		completeSprite:setPosition(cellSize.width*0.9, cellSize.height*0.5)
		cellItem:addChild(completeSprite)
	-- 可领悟
	elseif itemInfo.state == 2 then
		local studyBtn = ui.newButton({
				normalImage = "c_33.png",
				text = TR("可领悟"),
				clickAction = function ()
					self:requestLearn(itemInfo.fahionBookModelID, fashionId)
				end,
			})
		studyBtn:setScale(0.8)
		studyBtn:setPosition(cellSize.width*0.9, cellSize.height*0.5)
		cellItem:addChild(studyBtn)

		-- 消耗
		local daibiImage = Utility.getDaibiImage(ResourcetypeSub.eGuildGongfuCoin)
		local useNum = Utility.analysisStrAttrList(GuildBookModel.items[itemInfo.fahionBookModelID].gongfuCoinConsum)[1].value
		local useLabel = ui.newLabel({
				text = TR("{%s}%s", daibiImage, useNum),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
		useLabel:setPosition(cellSize.width*0.88, cellSize.height*0.25)
		cellItem:addChild(useLabel)

		-- 在帮派武技不足时，可领悟按钮置灰
		if Utility.getOwnedGoodsCount(ResourcetypeSub.eGuildGongfuCoin) < useNum then
			studyBtn:setEnabled(false)
			useLabel:setColor(Enums.Color.eRed)
		end
	-- 前往学习
	elseif itemInfo.state == 1 then
		local goBtn = ui.newButton({
				normalImage = "c_28.png",
				text = TR("前往学习"),
				clickAction = function ()
					LayerManager.addLayer({
							name = "guild.GuildBookLearnLayer",
							data = {
								cheatsId = itemInfo.bookID, -- 秘籍id
								callback = function (response)
							        self.mBookInfo = response.Value.GuildBookInfo

							        self:initData()
								    self:refreshList()
								end,
							},
							cleanUp = false,
						})
				end,
			})
		goBtn:setScale(0.8)
		goBtn:setPosition(cellSize.width*0.9, cellSize.height*0.5)
		cellItem:addChild(goBtn)
	elseif itemInfo.state == 0 then
    	local lockSprite = ui.createSpriteAndLabel({
                imgName = "c_157.png",
                labelStr = TR("未解锁"),
                fontSize = 24,
            })
		lockSprite:setPosition(cellSize.width*0.9, cellSize.height*0.5)
		cellItem:addChild(lockSprite)
	end

	return cellItem
end

-- 去装备绝学弹窗
function GuildBookOverViewLayer:createSkipLayer(modelId)
    local name = FashionModel.items[modelId].name
    local nameColor = Utility.getColorValue(FashionModel.items[modelId].colorLV, 2)
    local hintText = TR("已学习绝学%s%s%s，是否立即前往上阵？", nameColor, name, Enums.Color.eNormalWhiteH)

    MsgBoxLayer.addOKLayer(
        hintText,
        TR("提示"),
        {
            {
                text = TR("确定"),
                clickAction = function ()
                    LayerManager.showSubModule(ModuleSub.eFashion)
                end,
            }
        },
        {}
    )
end

function GuildBookOverViewLayer:refreshList()
	self.mFashionListView:removeAllChildren()

	for _, cheatsInfo in ipairs(self.mCheatsInfo) do
		local item = self:createItem(cheatsInfo)
		self.mFashionListView:pushBackCustomItem(item)
	end

	-- 添加敬请期待项
	local emptyItem = self:createEmptyItem()
	self.mFashionListView:pushBackCustomItem(emptyItem)
end

--====================网络相关==================
-- 秘籍信息
function GuildBookOverViewLayer:requestInfo()
	HttpClient:request({
	    moduleName = "Guild",
	    methodName = "GetGuildBookInfo",
	    svrMethodData = {},
	    callback = function (response)
	        if not response or response.Status ~= 0 then
	            return
	        end

	        self.mBookInfo = response.Value.GuildBookInfo

	        self:initData()
		    self:refreshList()
	    end
	})
end

-- 学习
function GuildBookOverViewLayer:requestLearn(id, fashionID)
	HttpClient:request({
	    moduleName = "Guild",
	    methodName = "LearnGuildBook",
	    svrMethodData = {id},
	    callback = function (response)
	        if not response or response.Status ~= 0 then
	            return
	        end

	        self.mBookInfo = response.Value.GuildBookInfo

	        self:initData()
		    self:refreshList()

		    -- 提示弹窗
		    self:createSkipLayer(fashionID)
		    -- 更新绝学缓存
            FashionObj:refreshFashionList()
	    end
	})
end

return GuildBookOverViewLayer