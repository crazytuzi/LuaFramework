--[[
    SectMyBookLayer.lua
    描述: 我的功法界面
    创建人: yanghongsheng
    创建时间: 2017.8.30
-- ]]

local SectMyBookLayer = class("SectMyBookLayer", function()
    return display.newLayer()
end)

function SectMyBookLayer:ctor()
	-- 框体大小
	self.boxSize = cc.size(586, 600)
	-- 列表项大小
	self.cellSize = cc.size(524, 126)
	-- 列表大小
	self.listSize = cc.size(536, 390)
	-- 功法列表
	self.bookDataList = {}
	-- 服务器数据
	self.serverData = {}
    -- 初始化book数据
    self:initBookList()
    -- 请求数据
    self:requsetInfo()
end

-- 初始化book表
function SectMyBookLayer:initBookList()
	-- 将来表中数据按门派分成各个小表
	for _, value in pairs(SectBookModel.items) do
		self.bookDataList[value.sectModelID] = self.bookDataList[value.sectModelID] or {}
		self.bookDataList[value.sectModelID][value.ID] = value
	end
end
-- 刷新book表
function SectMyBookLayer:refreshBookList(serverData)
	-- 更新服务器数据
	self.serverData = serverData
	-- 将服务器数据更入book表中
	for key, value in pairs(serverData) do
		for _, v in pairs(value) do
			self.bookDataList[tonumber(key)][v].isLearn = true
		end
	end
end
-- 获取总的加成属性列表
function SectMyBookLayer:getAllAttr()
	-- 属性列表
	local attrList = {}
	-- 解析服务器数据
	-- 遍历所有门派
	for _, value in pairs(self.serverData) do
		-- 遍历这个门派已学习的功法
		for _, v in pairs(value) do
			-- 这门功法的属性
			local attrStr = SectBookModel.items[v].attrStr
			if attrStr ~= "" and attrStr ~= nil then
				-- 这门功法的属性列表
				local tempAttrList = Utility.analysisStrFashionAttrList(attrStr)
				-- 遍历属性列表
				for _, item in pairs(tempAttrList) do
					-- 生成这个属性的唯一标识
					local uniqueTag = tostring(item.fightattr)..tostring(item.range)
					-- 作为key值插入总的属性列表
					if attrList[uniqueTag] then
						-- 叠加相同属性的属性值
						attrList[uniqueTag].value = attrList[uniqueTag].value + item.value
					else
						-- 初始化该属性列表
						attrList[uniqueTag] = item
					end	
				end
			end
		end
	end
	return attrList
end

-- 获取属性string
function SectMyBookLayer.getAttrString(attrData)
	-- 获取属性范围字符串
	local text = Utility.getRangeStr(attrData.range)
	-- 属性名
	text = text .. FightattrName[attrData.fightattr]
	-- 属性值
	text = "#46220d" .. text .. "#d38212" .. "+" .. tostring(attrData.value)

	return text
end

-- 获取属性string列表
function SectMyBookLayer.getAttrStringList(attrListData)
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
			-- 全体 > 主角
			if (a.range ~= b.range) then
				return a.range > b.range
			end

			-- 血量 > 攻击 > 防御
			return getSortIndex(a.fightattr) > getSortIndex(b.fightattr)
		end)
	for _, value in pairs(tmpList) do
		local text = SectMyBookLayer.getAttrString(value)
		table.insert(attrTextList, text)
	end
	return attrTextList
end

-- 合并string列表
function SectMyBookLayer.mergeString(stringList, sep)
	if stringList == nil then return "" end

	return table.concat(stringList, sep)
end

function SectMyBookLayer:initUI()
	-- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("我的功法"),
        bgSize = self.boxSize,
        closeImg = "c_29.png", -- 不需要关闭按钮
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    -- 弹窗背景
    self.mBgSprite = bgLayer.mBgSprite
	-- 属性总览按钮
	local lookAttrBtn = ui.newButton({
			normalImage = "mp_43.png",
			clickAction = function ()
				self:createAttrLookMsg()
			end,
		})
	lookAttrBtn:setPosition(self.boxSize.width*0.85, self.boxSize.height*0.82)
	self.mBgSprite:addChild(lookAttrBtn)
	-- list背景
	local listBg = ui.newScale9Sprite("c_17.png", cc.size(self.listSize.width, self.listSize.height + 10))
	listBg:setPosition(self.boxSize.width*0.5, self.boxSize.height*0.4+2)
	self.mBgSprite:addChild(listBg)
	-- listView
	local bookListView = ccui.ListView:create()
    bookListView:setDirection(ccui.ScrollViewDir.vertical)
    bookListView:setBounceEnabled(true)
    bookListView:setContentSize(self.listSize)
    bookListView:setGravity(ccui.ListViewGravity.centerVertical)
    bookListView:setAnchorPoint(cc.p(0.5, 0.5))
    bookListView:setItemsMargin(5)
    bookListView:setPosition(self.listSize.width*0.5+5, self.listSize.height*0.5+5)
    listBg:addChild(bookListView)
    self.bookListView = bookListView

	-- tab标签按钮
	local btnInfos = {}
	for key, _ in pairs(self.bookDataList) do
		local btnInfo = {}
		btnInfo.text = SectModel.items[key].name
		btnInfo.tag = key

		table.insert(btnInfos, btnInfo)
	end

	-- 创建门派tabView
	local tabView = ui.newTabLayer({
		btnInfos = btnInfos,
		viewSize = cc.size(420, 80),
		space = 14,
		needLine = false,
		defaultSelectTag = SectObj:getPlayerSectInfo().SectId,
		onSelectChange = function(selectBtnTag)
		    self:refreshListView(selectBtnTag)
    	end
	})
	tabView:setAnchorPoint(cc.p(0, 0))
	tabView:setPosition(self.boxSize.width*0.05, self.boxSize.height*0.721)
	self.mBgSprite:addChild(tabView)
end
-- 属性总览弹窗
function SectMyBookLayer:createAttrLookMsg()
	local allAttrList = self.getAttrStringList(self:getAllAttr())
	local function createMsgUI(parent, bgSprite, bgSize)
		-- 属性背景
		local attrBg = ui.newScale9Sprite("c_18.png", cc.size(bgSize.width*0.85, bgSize.height*0.55))
		attrBg:setPosition(bgSize.width*0.5, bgSize.height*0.54)
		bgSprite:addChild(attrBg)
		local attrBgSize = attrBg:getContentSize()
		-- 属性文字
		if next(allAttrList) then
			-- 属性列表
	        local listSize = cc.size(attrBgSize.width * 0.75, attrBgSize.height-20)
	        local listView = ccui.ListView:create()
	        listView:setItemsMargin(5)
	        listView:setDirection(ccui.ListViewDirection.vertical)
	        listView:setBounceEnabled(true)
	        listView:setAnchorPoint(cc.p(0.5, 0.5))
	        listView:setContentSize(listSize)
	        listView:setPosition(attrBgSize.width*0.5, attrBgSize.height*0.5)
	        attrBg:addChild(listView)

	        -- 填入信息
	        for _, text in ipairs(allAttrList) do
	        	local item = ccui.Layout:create()
	        	item:setContentSize(listSize.width, 28)
	        	listView:pushBackCustomItem(item)
	        	-- 属性
	        	local attrLabel = ui.newLabel({
	        			text = text,
	        			size = 22,
	        			color = cc.c3b(0x46, 0x22, 0x0d),
	        		})
	        	attrLabel:setAnchorPoint(cc.p(0, 0.5))
	        	attrLabel:setPosition(10, item:getContentSize().height*0.5)
	        	item:addChild(attrLabel)
	        end
		else
			local attrLabel = ui.newLabel({
					text = TR("还没有学习功法"),
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
            bgSize = cc.size(300, 400),
            title = TR("属性总览"),
            DIYUiCallback = createMsgUI,
        }
    })
end

-- 刷新列表
function SectMyBookLayer:refreshListView(sectId)
	-- 清空列表
	self.bookListView:removeAllChildren()
	-- 排序表
	local tempBookList = {}
	for _, value in pairs(self.bookDataList[sectId]) do
		table.insert(tempBookList, value)
	end
	table.sort(tempBookList, function (item1, item2)
		return item1.ID < item2.ID
	end)
	-- 更新列表
	for _, value in pairs(tempBookList) do
		if value.TALModelID == 0 then	-- 剔除招式
			local item = self:createItem(value)
			self.bookListView:pushBackCustomItem(item)
		end
	end
	-- 回到列表顶部
	self.bookListView:jumpToTop()
end
-- 创建列表项
function SectMyBookLayer:createItem(itemData)
	local itemLayout = ccui.Layout:create()
	itemLayout:setContentSize(self.cellSize)

	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", self.cellSize)
	bgSprite:setPosition(self.cellSize.width*0.5, self.cellSize.height*0.5)
	itemLayout:addChild(bgSprite)
	-- 创建卡片
	local bookCard = CardNode.createCardNode({
			resourceTypeSub = itemData.typeID,
			modelId = itemData.ID,
			cardShowAttrs = {CardShowAttr.eBorder},
		})
	bookCard:setPosition(self.cellSize.width*0.12, self.cellSize.height*0.5)
	bgSprite:addChild(bookCard)
	-- book名字
	local bookName = ui.newLabel({
			text = itemData.name,
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 24,
		})
	bookName:setAnchorPoint(cc.p(0, 0))
	bookName:setPosition(self.cellSize.width*0.27, self.cellSize.height*0.6)
	bgSprite:addChild(bookName)
	-- 属性
	if itemData.attrStr ~= "" and itemData.attrStr ~= nil then
		local attrStrList = self.getAttrStringList(Utility.analysisStrFashionAttrList(itemData.attrStr))
		local attrLabel = ui.newLabel({
				text = self.mergeString(attrStrList, "  "),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
				dimensions = cc.size(self.cellSize.width*0.6, 0),
			})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrLabel:setPosition(self.cellSize.width*0.27, self.cellSize.height*0.3)
		bgSprite:addChild(attrLabel)
	end
	-- 是否学习
	if itemData.isLearn then
		local isLearnLabel = ui.createSpriteAndLabel({
				imgName = "c_156.png",
				labelStr = TR("已学习"),
				fontSize = 24,
			})
		isLearnLabel:setPosition(self.cellSize.width*0.85, self.cellSize.height*0.5)
		bgSprite:addChild(isLearnLabel)
	else
		local isLearnLabel = ui.createSpriteAndLabel({
				imgName = "c_157.png",
				labelStr = TR("未习得"),
				fontSize = 24,
			})
		isLearnLabel:setPosition(self.cellSize.width*0.85, self.cellSize.height*0.5)
		bgSprite:addChild(isLearnLabel)
	end

	return itemLayout
end

--------------服务器相关-------------
-- 请求数据
function SectMyBookLayer:requsetInfo()
	HttpClient:request({
        moduleName = "SectInfo",
        methodName = "GetSectBookInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 刷新数据
            self:refreshBookList(response.Value)
            -- 初始化界面
    		self:initUI()
        end
    })
end

return SectMyBookLayer