--[[
    文件名: PuzzleLayer.lua
	描述: 重阳活动——拼图游戏
	创建人: heguanghui
	创建时间: 2017.10.24
-- ]]
local PuzzleLayer = class("PuzzleLayer", function (params)
	return display.newLayer()
end)

local imageConfigs = {
	[1] = {bigImage = "pt_02.png", grayImage = "pt_10"},
	[2] = {bigImage = "pt_03.png", grayImage = "pt_11"},
	[3] = {bigImage = "pt_04.png", grayImage = "pt_12"},
	[4] = {bigImage = "pt_05.png", grayImage = "pt_13"},
	[5] = {bigImage = "pt_06.png", grayImage = "pt_14"},
	[6] = {bigImage = "pt_07.png", grayImage = "pt_15"},
}

--
function PuzzleLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
	self:initUI()

	-- 显示页面
	self:requestGetInfo()
end

-- 初始化页面控件
function PuzzleLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("pt_01.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	-- 广告文字
	local bannerSprite = ui.newSprite("pt_16.png")
	bannerSprite:setPosition(320, 840)
	self.mParentLayer:addChild(bannerSprite)

	-- 顶部状态栏
	local topBgSize = cc.size(660, 100)
	local topBgSprite = ui.newScale9Sprite("bp_22.png", topBgSize)
	topBgSprite:setAnchorPoint(cc.p(0.5, 1))
	topBgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(topBgSprite)
	self.topBgSprite = topBgSprite
	self.topBgSize = topBgSize

	-- 添加按钮
	local btnConfigList = {
		{ 	-- 关闭按钮
			image = "c_29.png",
			pos = cc.p(590, 1086),
			action = function ()
				LayerManager.removeLayer(self)
			end
		},
		{ 	-- 规则按钮
			image = "c_72.png",
			pos = cc.p(30, 1086),
			action = function ()
				MsgBoxLayer.addRuleHintLayer(TR("规则"),
	                {
	                    TR("1.活动所需拼图碎片可以通过参与限时掉落活动获得"),
	                    TR("2.每集齐5个同种位置的拼图碎片即可点亮该位置拼图"),
	                    TR("3.点亮所有位置的拼图后，还可以欣赏精美原画，更有丰富奖励等你来拿"),
	                    TR("4.拼图活动结束后，拼图碎片自动清除，请各位大侠在活动结束前处理拼图碎片。"),
	                })
			end
		},
		{ 	-- 预览按钮
			image = "c_79.png",
			pos = cc.p(90, 1086),
			action = function ()
				self:createPreviewPop()
			end
		},
	}
	for _,v in ipairs(btnConfigList) do
		local button = ui.newButton({
			normalImage = v.image,
			clickAction = v.action
		})
		button:setPosition(v.pos)
		self.mParentLayer:addChild(button, 1)
	end

	-- 点亮拼图的按钮
	local btnActive = ui.newButton({
		normalImage = "pt_08.png",
		clickAction = function ()
			if (not self.puzzleInfo.IsExchange) then
				ui.showFlashView(TR("当前拼图尚未全部点亮！"))
			else
				self:requestExchange(self.puzzleInfo.Serial)
			end
		end
	})
	btnActive:setPosition(320, 120)
	self.mParentLayer:addChild(btnActive)
	self.btnActive = btnActive
end

-- 创建预览框
function PuzzleLayer:createPreviewPop()
	if not self.puzzleInfo then return end

	-- 项数据表
	local itemsData = {}
	-- 构造数据
	for i, resoureStr in pairs(self.puzzleInfo.PerReward) do
		local item = {}
		item.resourceList = Utility.analysisStrResList(resoureStr)
		item.title = TR("第")..i..TR("张奖励")

		table.insert(itemsData, item)
	end

	LayerManager.addLayer({
			name = "festival.RewardPreviewPopLayer",
			data = {title = TR("奖励预览"), itemsData = itemsData},
			cleanUp = false,
		})
end

-- 更新时间
function PuzzleLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时：%s",MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end
    end
end

-- 刷新页面
function PuzzleLayer:refreshLayer(newPuzzleInfo)
	-- 保存新数据
	self.puzzleInfo = clone(newPuzzleInfo)
	self.isRequesting = false
	
	-- 刷新顶部和中间的显示
	self:refreshTopNode()
	self:refreshCenterNode()

    -- 倒计时标签
    self.mTimeLabel = ui.newLabel({
        text = "",
        color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x2b, 0x66, 0x14),
        anchorPoint = cc.p(0, 0.5),
        size = 22,
        x = 360,
        y = 180,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mParentLayer:addChild(self.mTimeLabel)

        -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

-- 刷新顶部显示
function PuzzleLayer:refreshTopNode()
	-- 提示文字
	local remainLabel = ui.newLabel({
		text = TR("点亮拼图后可获得: "),
		size = 22,
		outlineColor = cc.c3b(0x5c, 0x43, 0x40),
	})
	remainLabel:setAnchorPoint(cc.p(0, 0.5))
	remainLabel:setPosition(130, self.topBgSize.height * 0.5)
	self.topBgSprite:addChild(remainLabel)

	-- 删除以前的礼包
	if (self.topBgSprite.cardList ~= nil) then
		self.topBgSprite.cardList:removeFromParent()
		self.topBgSprite.cardList = nil
	end

	-- 大奖礼包
	local newRewardList = clone(self.puzzleInfo.Reward)
 	for _, item in pairs(newRewardList) do
        item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
    end
    local cardList = ui.createCardList({
        cardDataList = newRewardList,
        allowClick = true,
        maxViewWidth = 300,
        viewHeight = self.topBgSize.height,
        space = 10,
    })
    cardList:setAnchorPoint(cc.p(0, 0))
    cardList:setPosition(320, 10)
    cardList:setScale(0.8)
    self.topBgSprite:addChild(cardList)
    self.topBgSprite.cardList = cardList
end

-- 刷新中间显示
function PuzzleLayer:refreshCenterNode()
	-- 创建彩色大图背景
	local imgIndex = MqMath.modEx(self.puzzleInfo.Serial, #imageConfigs)
	local imgItem = imageConfigs[imgIndex]
	if (self.oldImgIndex == nil) or (self.oldImgIndex ~= imgIndex) then
		if (self.centerBgSprite ~= nil) then
			self.centerBgSprite:removeFromParent()
			self.centerBgSprite = nil
		end
		local bigImgSprite = ui.newSprite(imgItem.bigImage)
		bigImgSprite:setPosition(320, 510)
		self.mParentLayer:addChild(bigImgSprite)
		self.centerBgSprite = bigImgSprite
	end
	self.centerBgSprite:removeAllChildren()
	
	-- 宽度 : 左边一列全是192，中间一列全是191，右边一列全是191
	-- 高度 : 上面一排全是192，中间一排全是190，下面一排全是192
	-- 所以每个格子的锚点必须设置成(0, 0)，否则无法保证严格对齐的效果
	local gridConfigs = {
		[1] = cc.p(13, 395), [2] = cc.p(205, 395), [3] = cc.p(396, 395), 
		[4] = cc.p(13, 205), [5] = cc.p(205, 205), [6] = cc.p(396, 205), 
		[7] = cc.p(13, 13), [8] = cc.p(205, 13), [9] = cc.p(396, 13), 
	}
	for _,v in pairs(self.puzzleInfo.ActivityInfo) do
		local idx = tonumber(v.Index) + 1
		local pos = gridConfigs[idx]
		if (not v.IsActive) then
			local graySprite = ui.newSprite(string.format("%s_%02d.png", imgItem.grayImage, idx), ccui.TextureResType.plistType, imgItem.grayImage .. ".plist")
			graySprite:setAnchorPoint(cc.p(0, 0))
			graySprite:setPosition(pos)
			self.centerBgSprite:addChild(graySprite)

			-- 透明点击按钮
			local button = ui.newButton({
		        normalImage = "c_83.png",
		        position = cc.p(95, 95),
		        size = cc.size(190, 190),
		        clickAction = function()
		           if (v.Num >= v.NeedDebris) then
		           		self:requestActive(v.Index, graySprite)
		           else
		           		ui.showFlashView(TR("%s的数量不足", GoodsModel.items[v.ModelId].name))
		           end
		        end
		    })
		    graySprite:addChild(button)

			-- 拥有数量
			local countLabel = ui.newLabel({
				text = string.format("%s/%s", v.Num, v.NeedDebris),
				size = 20,
				color = (v.Num >= v.NeedDebris) and cc.c3b(0x24, 0x90, 0x29) or cc.c3b(0xfe, 0x1c, 0x46),
				outlineColor = cc.c3b(0x62, 0x2f, 0x09),
			})
			countLabel:setAnchorPoint(cc.p(1, 0))
			countLabel:setPosition(185, 5)
			graySprite:addChild(countLabel)

			-- 显示提示加号
			if (v.Num >= v.NeedDebris) then
				ui.createGlitterSprite({
					filename = "c_22.png",
			        parent = graySprite,
			        position = cc.p(95, 95),
			        actionScale = 1.5,
				})
			end
		end
	end
end

----------------------------------------------------------------------------------------------------

-- 请求获取信息
function PuzzleLayer:requestGetInfo()
	if (self.isRequesting ~= nil) and (self.isRequesting == true) then
		return
	end
	self.isRequesting = true

	--
	HttpClient:request({
        moduleName = "TimedPuzzle",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end
            -- dump(data, "puzzleInfo")
            self.mEndTime = data.Value.EndDate
            -- 刷新页面
            self:refreshLayer(data.Value)
        end
    })
end

-- 点亮某个部位
function PuzzleLayer:requestActive(gridIdx, node)
	if (self.isRequesting ~= nil) and (self.isRequesting == true) then
		return
	end
	self.isRequesting = true

	--
	HttpClient:request({
        moduleName = "TimedPuzzle",
        methodName = "Active",
        svrMethodData = {gridIdx},
        callbackNode = self,
        callback = function(data)
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 翻牌动画
            MqAudio.playEffect("pintu_01.mp3")
            ui.newEffect({
		        parent = node,
		        effectName = "effect_ui_kaiqipintu",
		        animation = "xiao",
		        position = cc.p(96, 95),
		        loop = false,
		        endRelease = true,
		        endListener = function ()
		        	-- 刷新页面
            		self:refreshLayer(data.Value)
		      	end
		    })
        end
    })
end

-- 获取点亮的奖励
function PuzzleLayer:requestExchange(serialIdx)
	if (self.isRequesting ~= nil) and (self.isRequesting == true) then
		return
	end
	self.isRequesting = true

	--
	HttpClient:request({
        moduleName = "TimedPuzzle",
        methodName = "Exchage",
        svrMethodData = {serialIdx},
        callbackNode = self,
        callback = function(data)
        	-- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 播放点亮的特效
            MqAudio.playEffect("pintu_02.mp3")
            ui.newEffect({
		        parent = self.centerBgSprite,
		        effectName = "effect_ui_kaiqipintu",
		        animation = "da",
		        position = cc.p(300, 278),
		        loop = false,
		        endRelease = true,
		        zorder = 2,
		        endListener = function ()
		        	-- 显示奖励
		        	ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
		        	-- 刷新页面
            		self:refreshLayer(data.Value)
		      	end
		    })
        end
    })
end

----------------------------------------------------------------------------------------------------

return PuzzleLayer