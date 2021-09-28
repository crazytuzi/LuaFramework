--[[
	文件名：ShopEntranceLayer.lua
	描述：商城入口
	创建人：chenqiang
	创建时间：2016.12.13
--]]

local ShopEntranceLayer = class("ShopEntranceLayer", function()
	return display.newLayer(cc.c4b(10, 10, 10, 150))
end)

-- 构造函数
function ShopEntranceLayer:ctor()
	ui.registerSwallowTouch({node = self})

	-- 变量
	self.mCellSize = cc.size(640, 220)

	-- 创建父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

    -- 整理数据
    self:handlerData()
    -- 初始化UI
    self:initUI()
end

-- 整理数据
function ShopEntranceLayer:handlerData()
	self.mShopBtn = {
		{	-- 武林大会商店
			normalImage = "shop_09.png",
			moduleId = ModuleSub.eGDDHShop,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eGDDHShop, true) then
					return
				end

				LayerManager.addLayer({name = "challenge.GGDHShopLayer", cleanUp = true})
			end
		},
		{	-- 帮派商店
			normalImage = "shop_05.png",
			moduleId = ModuleSub.eGuild,
			clickAction = function()
				if not ModuleInfoObj:moduleIsOpen(ModuleSub.eGuild, true) then
                    return
                end
                local function gotoGuildShopLayer()
                	LayerManager.addLayer({
                        name = "guild.GuildStoreLayer",
                        cleanUp = true
                    })
                end

                -- 判断是否已加入帮派
                if not Utility.isEntityId(GuildObj:getGuildInfo().Id) then
                	ui.showFlashView(TR("您尚未加入任何帮派"))
                	return
                end
                -- 判断建筑信息是否为空
            	if (table.nums(GuildObj:getGuildBuildInfo()) > 0) then
            		gotoGuildShopLayer()
            		return 
            	end

            	HttpClient:request({
			        svrType = HttpSvrType.eGame,
			        moduleName = "Guild",
			        methodName = "GetGuildInfo",
			        svrMethodData = {},
			        callbackNode = self,
			        callback = function(response)
			        	if not response or response.Status ~= 0 then
			                ui.showFlashView(TR("获取帮派详细信息出错"))
			            else
			            	GuildObj:updateGuildInfo(response.Value)
			            	gotoGuildShopLayer()
			            end
			        end,
			    })
			end
		},
		{	-- 装备商城（比武招亲）
			normalImage = "shop_03.png",
			moduleId = ModuleSub.eBDDShop,
            needRedDot = true,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBDDShop, true) then
					return
				end

				LayerManager.addLayer({name = "challenge.BddExchangeLayer", cleanUp = true})
			end
		},
		{	-- 华山论剑商店
			normalImage = "shop_04.png",
			moduleId = ModuleSub.ePVPShop,
            needRedDot = true,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePVPShop, true) then
					return
				end

				LayerManager.addLayer({name = "challenge.PvpCoinStoreLayer", cleanUp = true})
			end
		},
		{	-- 据守襄阳商店
			normalImage = "shop_08.png",
			moduleId = ModuleSub.eTeambattleShop,
            needRedDot = true,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eTeambattleShop, true) then
					return
				end

				LayerManager.addLayer({name ="teambattle.TeambattleShop", cleanUp = true})
			end
		},
		{	-- 道具商店
			normalImage = "shop_06.png",
			moduleId = ModuleSub.eStore,
            needRedDot = true,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eStore, true) then
					return
				end
    			LayerManager.showSubModule(ModuleSub.eStoreProps, nil, true)
			end
		},
		{	-- 黑市
			normalImage = "shop_07.png",
			moduleId = ModuleSub.eMysteryShop,
            needRedDot = true,
			clickAction = function()
				if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eMysteryShop, true) then
                    return
                end

                LayerManager.addLayer({
                	name = "mysteryshop.MysteryShopLayer",
                	cleanUp = true,
                	})
			end
		},
        {   -- 桃花岛
            normalImage = "shop_12.png",
            moduleId = ModuleSub.eShengyuanWars,
            clickAction = function()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eShengyuanWars, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "shengyuan.ShengyuanWarsShopLayer",
                    cleanUp = false,
                    })
            end
        },
        {   -- 武林争霸
            normalImage = "shop_11.png",
            moduleId = ModuleSub.ePVPInter,
            clickAction = function()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePVPInter, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "challenge.PvpInterShopLayer",
                    cleanUp = true,
                    })
            end
        },
        {   -- 丹药商店
            normalImage = "shop_13.png",
            moduleId = ModuleSub.eMedicine,
            clickAction = function()
                if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eMedicine, true) then
                    return
                end

                LayerManager.addLayer({
                    name = "quench.QuenchShopLayer",
                    cleanUp = false,
                    })
            end
        },
        {   -- 真元商店
            normalImage = "shop_14.png",
            moduleId = ModuleSub.eZhenyuanRecruit,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenyuanRecruit, true) then
                    return
                end
                LayerManager.addLayer({
                    name = "zhenyuan.ZhenYuanTabLayer", 
                    data = {moduleSub = 2},
                    cleanUp = true,
                })
            end
        },
		-- {	-- 外功商店
		-- 	normalImage = "shop_07.png",
		-- 	moduleId = ModuleSub.ePetShop,
		-- 	clickAction = function()
		-- 		if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePetShop, true) then
  --                   return
  --               end

  --               LayerManager.addLayer({
  --               	name = "challenge.ExpediShopLayer",
  --               	cleanUp = true,
  --               	})
		-- 	end
		-- },
		{   -- 绝情谷商店
            normalImage = "shop_15.png",
            moduleId = ModuleSub.eKillerValley,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eKillerValley, true) then
                    return
                end
                LayerManager.addLayer({
                    name = "killervalley.KillerValleyShopLayer",
                    cleanUp = false,
                })
            end
        },
        {   -- 江湖杀商店
            normalImage = "shop_16.png",
            moduleId = ModuleSub.eJiangHuKill,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eJiangHuKill, true) then
                    return
                end
                LayerManager.addLayer({name = "jianghuKill.JianghuKillShopLayer", cleanUp = false})
            end
        },
        {   -- 珍兽商店
            normalImage = "shop_17.png",
            moduleId = ModuleSub.eZhenshouLaoyuShop,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshouLaoyuShop, true) then
                    return
                end
                LayerManager.addLayer({name = "zsly.ZslyShopLayer"})
            end
        },
        {   -- 门派地宫商店
            normalImage = "shop_18.png",
            moduleId = ModuleSub.eSectPalace,
            clickAction = function()
                if not ModuleInfoObj:moduleIsOpen(ModuleSub.eSectPalace, true) then
                    return
                end
                LayerManager.addLayer({name = "sect.SectPalaceShopLayer", cleanUp = false})
            end
        },
	}

	-- 整理商城按钮信息，3个为一组
	self.mBtnList = {}
	table.sort(self.mShopBtn, function (a, b)
		local aOpenLv = ModuleSubModel.items[a.moduleId].openLv
		local bOpenLv = ModuleSubModel.items[b.moduleId].openLv
        return aOpenLv < bOpenLv
	end)
	local tempList = {}
    local tempIndex = 1
	for i = 1, #self.mShopBtn do
		if ModuleInfoObj:moduleIsOpenInServer(self.mShopBtn[i].moduleId) then	-- 判断模块是否开启
			table.insert(tempList, self.mShopBtn[i])
			if tempIndex % 3 == 0 then
				table.insert(self.mBtnList, tempList)
				tempList = {}
			end
            tempIndex = tempIndex + 1
		end
	end

	if #tempList ~= 0 then
		table.insert(self.mBtnList, tempList)
	end
end

-- 初始化UI
function ShopEntranceLayer:initUI()
	local bgSprite = ui.newSprite("shop_01.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 返回按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function ()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(self.mCloseBtn)

	--创建listView
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setItemsMargin(20)
    self.mListView:setContentSize(cc.size(640, 640))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(320, 835)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)--取消动画
    self.mParentLayer:addChild(self.mListView)

    self:refreshListView()
end

-- 刷新商城列表
function ShopEntranceLayer:refreshListView()
	for i = 1, #self.mBtnList do
		local shopItem = ccui.Layout:create()
		shopItem:setContentSize(self.mCellSize)
		self.mListView:pushBackCustomItem(shopItem)

		self:refreshListItem(i)
	end
end

-- 刷新商城列表项
function ShopEntranceLayer:refreshListItem(index)
	local shopItem = self.mListView:getItem(index - 1)
	if not shopItem then
		shopItem = ccui.Layout:create()
		shopItem:setContentSize(self.mCellSize)

		self.mListView:insertCustomItem(shopItem, index - 1)
	end
	shopItem:removeAllChildren()

	local lineSprite = ui.newSprite("shop_02.png")
	lineSprite:setAnchorPoint(cc.p(0.5, 1))
	lineSprite:setPosition(320, self.mCellSize.height)
	shopItem:addChild(lineSprite)

	-- 一条子项中的商店信息
	local shopInfo = self.mBtnList[index]
	-- 一条子项中两个商店节点的位置
	local itemPos = {
		[1] = cc.p(self.mCellSize.width * 0.22, self.mCellSize.height - 5),
		[2] = cc.p(self.mCellSize.width * 0.50, self.mCellSize.height - 5),
		[3] = cc.p(self.mCellSize.width * 0.78, self.mCellSize.height - 5),
	}

	for key, btnInfo in ipairs(shopInfo) do
		-- 创建商店按钮
		local tempBtn = ui.newButton(btnInfo)
		tempBtn:setAnchorPoint(cc.p(0.5, 1))
		tempBtn:setPosition(itemPos[key])
		shopItem:addChild(tempBtn)

		-- 按钮大小
		local btnSize = tempBtn:getContentSize()

		-- 商店是否开启
		if not ModuleInfoObj:modulePlayerIsOpen(btnInfo.moduleId, false) or not ModuleInfoObj:moduleIsOpenInServer(btnInfo.moduleId) then
			tempBtn:setEnabled(false)

			-- 商店开启等级
			local openLv = ModuleSubModel.items[btnInfo.moduleId].openLv

			local openLabel = ui.newLabel({
				text = TR("%d级%s开启", openLv, Enums.Color.eNormalWhiteH),
				size = 22,
				color = Enums.Color.eRed,
				outlineColor = Enums.Color.eOutlineColor,
			})
			openLabel:setAnchorPoint(cc.p(0.5, 0.5))
			openLabel:setPosition(btnSize.width * 0.5, btnSize.height * 0.8)
			tempBtn:addChild(openLabel)
		end

		-- 小红点逻辑(部分商店无小红点)
		if btnInfo.needRedDot then
			local function dealRedDotVisible(redDotSprite)
				redDotSprite:setVisible(RedDotInfoObj:isValid(btnInfo.moduleId))
			end
            ui.createAutoBubble({parent = tempBtn, eventName = RedDotInfoObj:getEvents(btnInfo.moduleId), refreshFunc = dealRedDotVisible})
		end
	end
end


return ShopEntranceLayer
