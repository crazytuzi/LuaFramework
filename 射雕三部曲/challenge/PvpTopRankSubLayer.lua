--[[
    文件名：PvpTopRankSubLayer.lua
    描述： 武林盟主排名子界面
    创建人：yanghongsheng
    创建时间：2017.11.2
-- ]]
local PvpTopRankSubLayer = class("PvpTopRankSubLayer", function(params)
	return display.newLayer()
end)

-- 自定义枚举（用于进行页面分页, 必须是从1开始的有序数）
local TabPageTags = {
    eDongxie = 1,   -- 东邪
    eXidu = 2, -- 西毒
    eNandi = 3, -- 南帝
    eBeigai = 4, -- 北丐
}

function PvpTopRankSubLayer:ctor(params)
	-- 设置父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 选中项
    self.mSelectItem =  params.selectItem or TabPageTags.eDongxie
    -- 排名数据
    self.mRankData = {}

    -- 初始化界面
    self:initUI()
end

function PvpTopRankSubLayer:initUI()
	-- 创建分页按钮
	local btnListNode = self:createTabBtn()
	btnListNode:setPosition(0, 920)
	self.mParentLayer:addChild(btnListNode)
	-- 列表背景
	local listBgSize = cc.size(610, 750)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setPosition(320, 490)
	self.mParentLayer:addChild(listBg)
	-- 列表
	local rankList = ccui.ListView:create()
	rankList:setDirection(ccui.ScrollViewDir.vertical)
	rankList:setBounceEnabled(true)
	rankList:setContentSize(cc.size(listBgSize.width, listBgSize.height-20))
	rankList:setItemsMargin(5)
	rankList:setGravity(ccui.ListViewGravity.centerHorizontal)
	rankList:setAnchorPoint(cc.p(0.5, 0.5))
	rankList:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
	listBg:addChild(rankList)
	self.rankList = rankList
	-- 请求服务器数据
	self:requsetInfo()
end

function PvpTopRankSubLayer:createTabBtn()
	-- 四个组按钮图标
	local btnList = {
		[TabPageTags.eDongxie] = "wlmz_02.png",
		[TabPageTags.eXidu] = "wlmz_03.png",
		[TabPageTags.eNandi] = "wlmz_04.png",
		[TabPageTags.eBeigai] = "wlmz_05.png",
	}
	-- 按钮父节点
	local parentNode = cc.Node:create()
	-- 按钮个数
	local btnNum = table.maxn(btnList)
	-- 计数
	local count = 1
	-- 摆放总宽度
	local width = 640
	-- 上一个选中图索引
	self.oldSelectSprite = nil
	-- 循环创建按钮
	for key, v in ipairs(btnList) do
		-- 创建选中图
		local selectSprite = ui.newSprite("wlmz_13.png")
		selectSprite:setPosition(width/(btnNum+1)*count, 0)
		parentNode:addChild(selectSprite)
		selectSprite:setVisible(false)
		-- 初始化选中图显示
		if key == self.mSelectItem then
			selectSprite:setVisible(true)
			self.oldSelectSprite = selectSprite
		end
		-- 创建按钮
		local tabBtn = ui.newButton({
				normalImage = v,
				clickAction = function ()
					if self.mSelectItem == key then
						return
					end
					-- 切换选中图
					self.oldSelectSprite:setVisible(false)
					selectSprite:setVisible(true)
					self.oldSelectSprite = selectSprite
					-- 切换当前tab的tag
					self.mSelectItem = key
					-- 更新列表
					if self.mRankData[key] == nil or not next(self.mRankData[key]) then
						self:requsetInfo()
					else
						self:refreshList(self.mRankData[key])
					end
				end,
			})
		tabBtn:setPosition(width/(btnNum+1)*count, 0)
		parentNode:addChild(tabBtn)

		count = count + 1
	end

	return parentNode
end

function PvpTopRankSubLayer:refreshList(rankData)
	-- 隐藏空列表提示
	if self.emptyHintSprite then self.emptyHintSprite:setVisible(false) end
	-- 移除所有项
	self.rankList:removeAllChildren()
	-- 临时排行列表
	local temRankList = {}
	-- 排行数据键值
	local rankDataKeys = table.keys(rankData)
	-- 对键排序
	table.sort(rankDataKeys, function (item1, item2)
		return tonumber(item1) < tonumber(item2)
	end)
	-- 按排位排序
	for key, Value in pairs(rankDataKeys) do
		table.insert(temRankList, rankData[Value])
	end
	-- 循环创建
	for key, Value in ipairs(temRankList) do
		if Value.Status == 1 then
			for _, playerData in pairs(Value.PVPinterInfo) do
				local item = self:createCell(key, playerData)
				self.rankList:pushBackCustomItem(item)
			end
		else
			local item = self:createCell(key, Value.Status)
			self.rankList:pushBackCustomItem(item)
		end
	end
	self.rankList:jumpToTop()
end

function PvpTopRankSubLayer:createCell(order, playerData)
	-- 排位图
	local orderTextureList = {	[1] = {						-- 第一
									rank = "wlmz_07.png",
									effect = "effect_ui_wulinmengzhu",
								},
								[2] = {						-- 第二
									rank = "wlmz_08.png",
									headFrame = "wlmz_14.png",
								},
								[3] = {						-- 4强
									rank = "wlmz_09.png",
									headFrame = "wlmz_14.png",
								},
								[4] = {						-- 8强
									rank = "wlmz_10.png",
									headFrame = "wlmz_14.png",
								},
								[5] = {						-- 16强
									rank = "wlmz_11.png",
									headFrame = "wlmz_14.png",
								},
								[6] = {						-- 32强
									rank = "wlmz_12.png",
									headFrame = "wlmz_14.png",
								},
							}
	-- 项大小
	local listSize = self.rankList:getContentSize()
	local itemSize = cc.size(listSize.width-10, 140)
	-- 容器
	local layout = ccui.Layout:create()
	layout:setContentSize(itemSize)
	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", itemSize)
	bgSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
	layout:addChild(bgSprite)
	-- 名次
	local orderSprite = ui.newSprite(orderTextureList[order].rank)
	orderSprite:setPosition(itemSize.width*0.15, itemSize.height*0.5)
	layout:addChild(orderSprite)
	-- 比赛还没结束
	if playerData == 2 or playerData == 3 then
		local hintLabel = ui.newLabel({
				text = TR("还未决出排名"),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 27,
			})
		hintLabel:setPosition(itemSize.width*0.5, itemSize.height*0.5)
		layout:addChild(hintLabel)
		return layout
	end
	-- 头像
	local headCard = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eHero,
	        modelId = playerData.HeadImageId,
	        fashionModelID = playerData.FashionModelId,
	        IllusionModelId = playerData.IllusionModelId,
	        allowClick = false,
	        cardShowAttrs = {
	            CardShowAttr.eBorder,
	        },
		})
	headCard:setPosition(itemSize.width*0.36, itemSize.height*0.5)
	layout:addChild(headCard)
	-- 头像框
	if orderTextureList[order].headFrame then
		local frameSprite = ui.newSprite(orderTextureList[order].headFrame)
		frameSprite:setPosition(itemSize.width*0.36, itemSize.height*0.5)
		layout:addChild(frameSprite)
	else
		local frameEffect = ui.newEffect({
				parent = layout,
				position = cc.p(itemSize.width*0.36, itemSize.height*0.5),
				effectName = orderTextureList[order].effect,
				loop = true,
			})
	end
	-- 玩家名
	local playerName = ui.newLabel({
			text = playerData.Name,
			size = 22,
			color = cc.c3b(0xfb, 0x73, 0x73),
			outlineColor = Enums.Color.eBlack,
		})
	playerName:setAnchorPoint(cc.p(0, 0.5))
	playerName:setPosition(itemSize.width*0.48, itemSize.height*0.75)
	layout:addChild(playerName)
	-- 会员等级
	local vipNode = ui.createVipNode(playerData.Vip)
    vipNode:setPosition(itemSize.width*0.77, itemSize.height*0.75)
    layout:addChild(vipNode)
	-- 服务器
	local zoneLabel = ui.newLabel({
			text = TR("服务器: %s%s", "#d17b00", playerData.Zone),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	zoneLabel:setAnchorPoint(cc.p(0, 0.5))
	zoneLabel:setPosition(itemSize.width*0.48, itemSize.height*0.5)
	layout:addChild(zoneLabel)
	-- 战力
	local fapLabel = ui.newLabel({
			text = TR("战力: %s%s", "#d17b00", Utility.numberFapWithUnit(playerData.FAP)),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	fapLabel:setAnchorPoint(cc.p(0, 0.5))
	fapLabel:setPosition(itemSize.width*0.48, itemSize.height*0.25)
	layout:addChild(fapLabel)

	return layout
end

--========================服务器相关=======================

function PvpTopRankSubLayer:requsetInfo()
    HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "GetPVPInterNowRank",
        svrMethodData = {self.mSelectItem},
        callback = function(response)
            -- if response and response.Status ~= 0 then
            --     return
            -- end
            -- dump(response.Value, "排行")
            if response.Value == nil or not next(response.Value) then
            	-- 空列表提示
            	if not self.emptyHintSprite then
	                self.emptyHintSprite = ui.createEmptyHint(TR("暂无排名"))
	                self.emptyHintSprite:setScale(1.3)
	                self.emptyHintSprite:setPosition(320, 500)
	                self.mParentLayer:addChild(self.emptyHintSprite)
	            end
	            self.emptyHintSprite:setVisible(true)
	            self.rankList:removeAllChildren()
            else
            	self:refreshList(response.Value)
            	self.mRankData[self.mSelectItem] = response.Value
            end
        end
    })
end


return PvpTopRankSubLayer