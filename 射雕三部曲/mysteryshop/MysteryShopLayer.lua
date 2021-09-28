--[[
   文件名：MysteryShopLayer.lua
   描述：神秘商店页面(聚宝阁、黑市）
   创建人：libowen
   创建时间：2016.4.20
--]]

local MysteryShopLayer = class("MysteryShopLayer", function(params)
   return display.newLayer()
end)

-- 构造函数
--[[
   params:
   Table params:
   {
	   tabPageTag             -- 进入时要显示的分页面tag，用于页面恢复
	   data                   -- 复制页面需要的参数
   }
--]]
function MysteryShopLayer:ctor(params)
   -- 默认显示的分页面tag
   self.mTabPageTag = params and params.tabPageTag
   self.mCopyData = params and params.data
   -- 初始化界面
   self:initUI()

   -- 当关闭该页面时，设置聚宝阁的小红点状态为0
   self:registerScriptHandler(function(eventType)
	   if eventType == "exit" then
		   RedDotInfoObj:setSocketRedDotInfo({[tostring(ModuleSub.eMysteryShop)] = {Default=false}})
	   end
   end)
end

-- 初始化UI相关
function MysteryShopLayer:initUI()
   -- 元素父节点
   self.mParentLayer = ui.newStdLayer()
   self:addChild(self.mParentLayer)

   -- 包含顶部底部的公共layer
   self.mCommonLayer = require("commonLayer.CommonLayer"):create({
	   needMainNav = true,
	   topInfos = {ResourcetypeSub.eHeroCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
   })
   self:addChild(self.mCommonLayer)

   -- 背景
   local bgSprite = ui.newSprite("c_34.jpg")
   bgSprite:setPosition(320, 568)
   self.mBgSprite = bgSprite
   self.mParentLayer:addChild(bgSprite)

   -- 子背景
   -- local subBgSprite = ui.newScale9Sprite("c_124.png", cc.size(640, 142))
   -- subBgSprite:setAnchorPoint(cc.p(0.5, 1))
   -- subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, self.mParentLayer:getContentSize().height))
   -- self.mParentLayer:addChild(subBgSprite)

   -- 存放分页内容的父节点
   self.mContentLayer = display.newLayer()
   self.mContentLayer:setContentSize(cc.size(640, 1136))
   bgSprite:addChild(self.mContentLayer)

   -- 添加分页控件
   self:addTabLayer()

   -- 关闭按钮
   self.mCloseBtn = ui.newButton({
	   normalImage = "c_29.png",
	   position = cc.p(594, 1050),
	   clickAction = function()
		   LayerManager.removeLayer(self)
	   end
   })
   self.mParentLayer:addChild(self.mCloseBtn)

end

--------------------数据恢复-----------------------
function MysteryShopLayer:getRestoreData()
   local retData = {
	   tabPageTag = self.mTabPageTag
   }
   return retData
end

-- 创建Tab标签页
function MysteryShopLayer:addTabLayer()
   -- 添加黑底
   local decBgSize = cc.size(640, 127)
   local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
   decBg:setPosition(cc.p(320, 1073))
   self.mParentLayer:addChild(decBg)

   local buttonInfos = {}
   -- 普通宝阁按钮配置
   local btnInfo1 = {
	   text = TR("普通宝阁"),
	   tag = ModuleSub.eMysteryShop,
	   fontSize = 24,
	   -- outlineColor = cc.c3b(0x98, 0x62, 0x58),
   }
   table.insert(buttonInfos, btnInfo1)


   local btnInfo2 = {
    text = TR("高级宝阁"),
    tag = ModuleSub.eSeniorMysteryShop,
    fontSize = 24,
    -- outlineColor = cc.c3b(0x98, 0x62, 0x58),
   }
   table.insert(buttonInfos, btnInfo2)

   -- 复制法阵按钮配置
   -- if ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eMysteryshopCopy) then
   --     local btnInfo2 = {
   --         text = TR("复制法阵"),
   --         tag = ModuleSub.eMysteryshopCopy,
   --         fontSize = 24,
   --         -- outlineColor = cc.c3b(0x98, 0x62, 0x58),
   --     }
   --     table.insert(buttonInfos, btnInfo2)
   -- end

   -- 专属卖场按钮配置
   -- 检查服务器是否开放此功能，并且玩家是否达到开放等级
   -- local isOpen1 = ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eSVipMysteryShop)
   -- local isOpen2 = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eSVipMysteryShop)
   -- if isOpen1 and isOpen2 then
   --     local btnInfo3 = {
   --         text = TR("专属卖场"),
   --         tag = ModuleSub.eSVipMysteryShop
   --     }
   --     table.insert(buttonInfos, btnInfo3)
   -- end

   -- 创建分页
   local tabLayer = ui.newTabLayer({
	   btnInfos = buttonInfos,
	   isVert = false,
	   needLine = true,
	   -- normalTextColor = cc.c3b(0xe1, 0xe1, 0xe1),
	   -- lightedTextColor = cc.c3b(0xff, 0xe3, 0xd4),
	   defaultSelectTag = self.mTabPageTag or ModuleSub.eMysteryShop,
	   allowChangeCallback = function(btnTag)
		   -- 普通宝阁
		   if btnTag == ModuleSub.eMysteryshopCopy then
			   if not ModuleInfoObj:moduleIsOpen(ModuleSub.eMysteryshopCopy, true) then
				   return false
			   end
		   -- 专属卖场
		   elseif btnTag == ModuleSub.eSVipMysteryShop then
		       local isOpen = ModuleInfoObj:moduleIsOpen(ModuleSub.eSVipMysteryShop, true)
		       if not isOpen then
		           return false
		       end
            --高级宝阁
           elseif btnTag == ModuleSub.eSeniorMysteryShop then
               if not ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eSeniorMysteryShop, true) then
                   return false
               end
		   end

		   return true
	   end,
	   onSelectChange = function(selectBtnTag)
		   -- 移除当前子页面，重新添加相应子页面
		   self.mContentLayer:removeAllChildren()
		   self.mTabPageTag = selectBtnTag

		   if selectBtnTag == ModuleSub.eMysteryShop then
			   local layer = require("mysteryshop.GeneralShopLayer"):create({
				   shopLayer = self,
			   })
			   self.mContentLayer:addChild(layer)
		   elseif selectBtnTag == ModuleSub.eMysteryshopCopy then
			   local layer = require("mysteryshop.MysteryshopCopyLayer"):create(self.mCopyData)
			   self.mContentLayer:addChild(layer)
		   elseif selectBtnTag == ModuleSub.eSVipMysteryShop then
               if ModuleInfoObj:moduleIsOpen(ModuleSub.eSVipMysteryShop) then
                   --local layer = require("mysteryshop.ExclusiveShopLayer"):create()
                   --self.mContentLayer:addChild(layer)
               end
		   elseif selectBtnTag == ModuleSub.eSeniorMysteryShop then
               if ModuleInfoObj:moduleIsOpen(ModuleSub.eSeniorMysteryShop) then
    			   local layer = require("mysteryshop.MarketShopLayer"):create()
    			   self.mContentLayer:addChild(layer)
               end
		   end
	   end
   })
   tabLayer:setPosition(320, 1045)
   self.mParentLayer:addChild(tabLayer)

   ----------- 保存用于新手引导
   self.mTabLayer = tabLayer
   -------------------------

   -- 小红点逻辑
   for key, btnObj in pairs(self.mTabLayer:getTabBtns() or {}) do
	   local function dealRedDotVisible(redDotSprite)
		   local redDotData = RedDotInfoObj:isValid(key)
		   redDotSprite:setVisible(redDotData)
	   end
	   ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(key), parent = btnObj})
   end
end

return MysteryShopLayer
