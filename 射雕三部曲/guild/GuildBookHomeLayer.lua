--[[
    文件名：GuildBookHomeLayer.lua
    描述：帮派秘籍首页
    创建人：yanghongsheng
    创建时间：2018.1.25
-- ]]

local GuildBookHomeLayer = class("GuildBookHomeLayer", function(params)
    return display.newLayer()
end)

function GuildBookHomeLayer:ctor(params)
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

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(cc.p(604, 1040))
    self.mParentLayer:addChild(self.mCloseBtn)

    self:requestInfo()
end

--[[
	解析解锁秘籍字符串
	params: "1,2,3"
	get: self.mCheatsInfo = {
			[1] = true,
			[2] = true,
			[3] = true,
		}
]]
function GuildBookHomeLayer:initData()
	self.mCheatsInfo = {}
	local unlockBookStrList = string.splitBySep(GuildObj:getGuildBookInfo().GuildBook or "", ",")
	for _, unlockBookId in pairs(unlockBookStrList) do
		self.mCheatsInfo[tonumber(unlockBookId)] = true
	end
end

function GuildBookHomeLayer:initUI()
	-- 创建页面背景
    local bgSprite = ui.newSprite("bpz_48.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 静态提示
    local hintLabel = ui.createSpriteAndLabel({
    		imgName = "c_25.png",
    		scale9Size = cc.size(500, 50),
    		labelStr = TR("加成属性对全体上阵角色生效"),
    		color = Enums.Color.eWhite,
    	})
    hintLabel:setPosition(320, 900)
    self.mParentLayer:addChild(hintLabel)

    -- 秘籍列表
    self.mCheatsListView = ccui.ListView:create()
	self.mCheatsListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mCheatsListView:setContentSize(cc.size(570, 694))
	self.mCheatsListView:setAnchorPoint(cc.p(0.5, 0))
	self.mCheatsListView:setPosition(320, 165)
	self.mParentLayer:addChild(self.mCheatsListView)

    -- 按钮
    self:createBtnList()
end

-- 创建按钮列表
function GuildBookHomeLayer:createBtnList()
	-- 创建按钮背景
	local topBgSize = cc.size(660, 100)
	local topBgSprite = ui.newScale9Sprite("dz_01.png", topBgSize)
	topBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
	topBgSprite:setPosition(320, 1040)
	self.mParentLayer:addChild(topBgSprite)
	-- 按钮列表
	local btnList = {
	    -- 绝学领悟
	    {
	        normalImage = "tb_248.png",
	        position = cc.p(160, 1040),
	        clickAction = function ()
	        	LayerManager.addLayer({
	        			name = "guild.GuildBookOverViewLayer"
	        		})
	        end,
	    },
	    -- 属性汇总
	    {
	        normalImage = "mp_43.png",
	        position = cc.p(260, 1040),
	        clickAction = function ()
	        	self:showAttrBox()
	        end,
	    },
	    -- 规则
	    {
	        normalImage = "c_72.png",
	        position = cc.p(60, 1040),
	        clickAction = function ()
	            MsgBoxLayer.addRuleHintLayer(TR("规则"),
	            {
	                TR("1.帮派等级达到要求后，帮主可以解锁相应帮派秘籍，所有帮派成员都可以进行学习"),
	                TR("2.每本帮派秘籍可以学习多次，全部学完一本帮派秘籍可以领悟相应的绝学"),
	                TR("3.退出帮派后，已经学习的帮派秘籍的属性会保留，如果要继续学习某一本帮派秘籍，则需要加入帮派，并且该帮派需要解锁相应秘籍"),
	            })
	        end,
	    },
	}

	for _, btnInfo in pairs(btnList) do
	    local tempBtn = ui.newButton(btnInfo)
	    self.mParentLayer:addChild(tempBtn)
	end
end

-- 获取总的加成属性列表
function GuildBookHomeLayer:getAllAttr()
	-- 属性列表
	local attrList = {}
	-- 招式简介表
	local talIntroList = {}
	-- 解析服务器数据
	-- 遍历所有门派
	for _, value in pairs(self.mBookInfo) do
		-- 遍历这个门派已学习的功法
		for _, v in pairs(value.BookInfo or {}) do
			-- 这门功法的属性
			local bookInfo = GuildBookModel.items[v.BookId]
			if bookInfo.attrStr ~= "" and bookInfo.attrStr ~= nil then
				-- 这门功法的属性列表
				local tempAttrList = Utility.analysisStrAttrList(bookInfo.attrStr)
				-- 遍历属性列表
				for _, item in pairs(tempAttrList) do
					-- 作为key值插入总的属性列表
					if attrList[item.fightattr] then
						-- 叠加相同属性的属性值
						attrList[item.fightattr].value = attrList[item.fightattr].value + item.value*(v.Step or 0)
					else
						-- 初始化该属性列表
						item.value = item.value*(v.Step or 0)
						attrList[item.fightattr] = item
					end	
				end
			elseif bookInfo.TALModelID and bookInfo.TALModelID ~= 0 then
				local talIntro = TalModel.items[bookInfo.TALModelID].intro
				table.insert(talIntroList, talIntro)
			end
		end
	end
	return attrList, talIntroList
end

-- 获取属性string列表
function GuildBookHomeLayer.getAttrStringList(attrListData)
	if attrListData == nil then return {} end

	local attrTextList = {}
	local tmpList = {}
	for _, value in pairs(attrListData) do
		table.insert(tmpList, value)
	end
	
	local function getSortIndex(fightAttr)
		if (fightAttr == Fightattr.eHP) or (fightAttr == Fightattr.eHPR) then
			return 3
		end
		if (fightAttr == Fightattr.eAP) or (fightAttr == Fightattr.eAPR) then
			return 2
		end
		if (fightAttr == Fightattr.eDEFR) or (fightAttr == Fightattr.eDEFR) then
			return 1
		end
		return 0
	end
	table.sort(tmpList, function (a, b)
			return a.fightattr < b.fightattr
		end)
	for _, value in pairs(tmpList) do
		local text = GuildBookHomeLayer.getAttrString(value)
		table.insert(attrTextList, text)
	end
	return attrTextList
end

-- 获取属性string
function GuildBookHomeLayer.getAttrString(attrData)
	-- 获取属性名
	local text = FightattrName[attrData.fightattr]
	-- 属性值
	text = "#46220d" .. text .. "#d38212" .. Utility.getAttrViewStr(attrData.fightattr, attrData.value, true)

	return text
end

function GuildBookHomeLayer:showAttrBox()
	local attrList, talIntroList = self:getAllAttr()
	local allAttrList = self.getAttrStringList(attrList)
	local function createMsgUI(parent, bgSprite, bgSize)
		-- 属性背景
		local attrBg = ui.newScale9Sprite("c_18.png", cc.size(bgSize.width*0.87, bgSize.height*0.62))
		attrBg:setPosition(bgSize.width*0.5, bgSize.height*0.53)
		bgSprite:addChild(attrBg)
		local attrBgSize = attrBg:getContentSize()
		-- 属性文字
		if next(allAttrList) then
			-- 属性列表
	        local listSize = cc.size(attrBgSize.width * 0.8, attrBgSize.height-20)
	        local listView = ccui.ListView:create()
	        listView:setItemsMargin(5)
	        listView:setDirection(ccui.ListViewDirection.vertical)
	        listView:setBounceEnabled(true)
	        listView:setAnchorPoint(cc.p(0.5, 0.5))
	        listView:setContentSize(listSize)
	        listView:setPosition(attrBgSize.width*0.5, attrBgSize.height*0.5)
	        attrBg:addChild(listView)

	        -- 填入属性信息
	        for _, text in ipairs(allAttrList) do
	        	local item = ccui.Layout:create()
	        	listView:pushBackCustomItem(item)
	        	-- 属性
	        	local attrLabel = ui.newLabel({
	        			text = text,
	        			size = 22,
	        			color = cc.c3b(0x46, 0x22, 0x0d),
	        			dimensions = cc.size(listSize.width, 0),
	        			align = ui.TEXT_ALIGN_CENTER,
	        		})
	        	attrLabel:setAnchorPoint(cc.p(0.5, 0.5))
	        	attrLabel:setPosition(listSize.width*0.5, item:getContentSize().height*0.5)
	        	item:addChild(attrLabel)

	        	local labelSize = attrLabel:getContentSize()
	        	item:setContentSize(listSize.width, labelSize.height+5)
	        end

	        -- 招式（天赋）信息
	        for _, text in pairs(talIntroList) do
	        	local item = ccui.Layout:create()
	        	listView:pushBackCustomItem(item)
	        	-- 简介
	        	local attrLabel = ui.newLabel({
	        			text = text,
	        			size = 22,
	        			color = cc.c3b(0x46, 0x22, 0x0d),
	        			dimensions = cc.size(listSize.width, 0),
	        			align = ui.TEXT_ALIGN_CENTER,
	        		})
	        	attrLabel:setAnchorPoint(cc.p(0.5, 0.5))
	        	attrLabel:setPosition(listSize.width*0.5, item:getContentSize().height*0.5)
	        	item:addChild(attrLabel)

	        	local labelSize = attrLabel:getContentSize()
	        	item:setContentSize(listSize.width, labelSize.height+5)
	        end

		else
			local attrLabel = ui.newLabel({
					text = TR("还没有学习秘籍"),
					size = 22,
					color = cc.c3b(0x46, 0x22, 0x0d),
				})
			attrLabel:setAnchorPoint(cc.p(0.5, 0.5))
			attrLabel:setPosition(attrBgSize.width*0.5, attrBgSize.height*0.5)
			attrBg:addChild(attrLabel)
		end
		
	end

	LayerManager.addLayer({
        name = "commonLayer.MsgBoxLayer",
        cleanUp = false,
        data = {
            bgSize = cc.size(400, 500),
            title = TR("属性总览"),
            DIYUiCallback = createMsgUI,
        }
    })
end

function GuildBookHomeLayer:refreshList()

	self.mCheatsListView:removeAllChildren()

	-- 秘籍列表
	local cheatsList = clone(GuildLibraryModel.items)

	local col = 2
	local row = math.ceil(#cheatsList / col)

	for i = 1, row do
		-- 填充数据
		local itemInfo = {}
		for j = 1, col do
			if cheatsList[(i-1)*col+j] then
				table.insert(itemInfo, cheatsList[(i-1)*col+j])
			end
		end
		-- 创建项
		local item = self:createItem(itemInfo, col)
		self.mCheatsListView:pushBackCustomItem(item)
	end

	for i = 1, 4 - row - 1 do
		-- 创建空项
		local item = self:createEmptyItem()
		self.mCheatsListView:pushBackCustomItem(item)
	end

	-- 创建敬请期待项
	local hintItem = self:createEmptyItem(true)
	self.mCheatsListView:pushBackCustomItem(hintItem)
end

-- 创建空项
function GuildBookHomeLayer:createEmptyItem(isHint)
	-- 大小
	local cellSize = cc.size(self.mCheatsListView:getContentSize().width, 172)

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newSprite("bpz_50.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0))
	cellBg:setPosition(cellSize.width*0.5, 0)
	cellItem:addChild(cellBg)

	-- 敬请期待
	if isHint then
		local hintSprite = ui.newSprite("bp_28.png")
		hintSprite:setPosition(cellSize.width*0.56, cellSize.height*0.6)
		cellItem:addChild(hintSprite)
	end

	return cellItem
end

-- 创建一项
function GuildBookHomeLayer:createItem(itemInfo, col)
	-- 大小
	local cellSize = cc.size(self.mCheatsListView:getContentSize().width, 174)

	-- 横坐标
	local PosXList = {
		cellSize.width*0.05,
		cellSize.width*0.45,
	}

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newSprite("bpz_50.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0))
	cellBg:setPosition(cellSize.width*0.5, 0)
	cellItem:addChild(cellBg)

	local function createBook(index, bookInfo)
		if not bookInfo then return end

		-- 代表秘籍的小项
		local bookItemSize = cc.size(cellSize.width*0.5, cellSize.height)
		local bookItem = ccui.Layout:create()
		bookItem:setPosition(PosXList[index], 0)
		bookItem:setContentSize(bookItemSize)

		-- 帮派信息
		local guildInfo = GuildObj:getGuildInfo()
		-- 玩家的职位
		local playerPosId = GuildObj:getPlayerGuildInfo().PostId

		-- 秘籍书（按钮）
		local bookBtn = ui.newButton({
				normalImage = bookInfo.pic..".png",
				clickAction = function ()
					if bookInfo.isOpen == 0 then
						ui.showFlashView({text = TR("该秘籍还未开放")})
						return
					elseif not self.mCheatsInfo[bookInfo.bookID] then
						ui.showFlashView({text = TR("该秘籍还未解锁")})
						return
					end

					LayerManager.addLayer({
							name = "guild.GuildBookLearnLayer",
							data = {
								cheatsId = bookInfo.bookID, -- 秘籍id
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
		bookBtn:setPosition(bookItemSize.width*0.5, bookItemSize.height*0.5)
		bookItem:addChild(bookBtn)

		-- 提示
		local hintLabel = ui.newLabel({
				text = "",
				color = Enums.Color.eWhite,
				outlineColor = Enums.Color.eOutlineColor,
				valign = ui.TEXT_VALIGN_CENTER,
				align = ui.TEXT_ALIGN_CENTER,
			})
		hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
		hintLabel:setPosition(bookItemSize.width*0.5, bookItemSize.height*0.5)
		bookItem:addChild(hintLabel)
		hintLabel:setVisible(false)

		-- 解锁按钮
		local unlockBtn = ui.newButton({
				normalImage = "bpz_47.png",
				clickAction = function ()
					if not Utility.isResourceEnough(ResourcetypeSub.eGuildMoney, bookInfo.needGuildCoin, false) then
						ui.showFlashView({text = TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eGuildMoney))})
						return
					end
					-- 是否是帮主,副帮主
				    if playerPosId ~= 34001001 and playerPosId ~= 34001002 then
				        ui.showFlashView({text = TR("需要帮主或副帮主才能解锁")})
				        return
				    end
				    self:requestUnlock(bookInfo.bookID)
				end
			})
		unlockBtn:setPosition(bookItemSize.width*0.5, bookItemSize.height*0.55)
		bookItem:addChild(unlockBtn)
		unlockBtn:setVisible(false)

		-- 消耗提示
		local coinIamge = Utility.getDaibiImage(ResourcetypeSub.eGuildMoney)
		local useCoinLabel = ui.newLabel({
				text = TR("需要{%s}%d", coinIamge, bookInfo.needGuildCoin),
				color = Enums.Color.eWhite,
				size = 20,
				outlineColor = Enums.Color.eOutlineColor,
			})
		useCoinLabel:setPosition(bookItemSize.width*0.5, bookItemSize.height*0.3)
		bookItem:addChild(useCoinLabel)
		useCoinLabel:setVisible(false)

		-- 学完标签
		local completeSprite = ui.newSprite("bpz_54.png")
		completeSprite:setPosition(bookItemSize.width*0.5, bookItemSize.height*0.5)
		bookItem:addChild(completeSprite)
		completeSprite:setVisible(false)

		-- 未开放
		if bookInfo.isOpen == 0 then
			bookBtn:setEnabled(false)
			hintLabel:setString(TR("未开放"))
			hintLabel:setVisible(true)
		-- 未解锁
		elseif not self.mCheatsInfo[bookInfo.bookID] then
			bookBtn:setEnabled(false)
			-- 满足解锁条件
			if guildInfo.Lv >= bookInfo.needGuildLv then
				unlockBtn:setVisible(true)
				useCoinLabel:setVisible(bookInfo.needGuildCoin > 0)
			-- 不满足
			else
				hintLabel:setString(TR("帮派%d级解锁", bookInfo.needGuildLv))
				hintLabel:setVisible(true)
			end
		-- 学完了
		elseif self.mBookInfo[tostring(bookInfo.bookID)] and self.mBookInfo[tostring(bookInfo.bookID)].IsOver then
			completeSprite:setVisible(true)
		end

		cellItem:addChild(bookItem)
	end

	for i = 1, col do
		createBook(i, itemInfo[i])
	end

	return cellItem
end

--====================网络相关==================
-- 秘籍信息
function GuildBookHomeLayer:requestInfo()
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

-- 解锁秘籍
function GuildBookHomeLayer:requestUnlock(id)
	HttpClient:request({
	    moduleName = "Guild",
	    methodName = "UnLockGuildBook",
	    svrMethodData = {id},
	    callback = function (response)
	        if not response or response.Status ~= 0 then
	            return
	        end
	        GuildObj:updateGuildBookInfo(response.Value.GuildBookInfo)

	        ui.showFlashView({text = TR("解锁成功")})

	        self:initData()
		    self:refreshList()
	    end
	})
end

return GuildBookHomeLayer