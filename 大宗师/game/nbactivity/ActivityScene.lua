--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-14
-- Time: 下午4:49
-- To change this template use File | Settings | File Templates.
--

ccb = ccb or {}
ccb["nbHuodongCtrl"] = {} 

local data_nbactivity = require("data.data_nbactivity")
local data_jingcaihuodong_jingcaihuodong = require("data.data_jingcaihuodong_jingcaihuodong")
local data_item_item =  require("data.data_item_item") 
local data_card_card =  require("data.data_card_card") 


local ActivityScene = class("ActivityScene", function()

    display.addSpriteFramesWithFile("ui/ui_nbhuodong_icons.plist", "ui/ui_nbhuodong_icons.png")

    return require("game.BaseSceneExt").new({

        bottomFile = "public/bottom_frame.ccbi",
        topFile    = "nbhuodong/nbhuodong_top.ccbi"
    })
end)


function ActivityScene:getTypeCellIndex(showType) 
    for i, v in ipairs(self._data) do 
        if showType == v.huodong then 
            return i - 1
        end 
    end 
end


function ActivityScene:ctor(showType)
    self._contentNode = display.newNode()
    self:addChild(self._contentNode)

    self:sendActRes(showType) 
end 


function ActivityScene:sendActRes(showType) 
    local firstType = self:init() 
    if showType ~= nil then 
        self:changeShowLayer(showType) 
    else 
        self:changeShowLayer(firstType) 
    end 
end 


function ActivityScene:changeShowLayer(showType) 
    if showType ~= nil and self._showType ~= showType then 
        self._showType = showType 
        self._cellIndex = self:getTypeCellIndex(self._showType) 
        self:updateLayer(self._showType, self._cellIndex) 
    end 
end 


function ActivityScene:init() 
    self._data = {}
    for k, v in ipairs(data_jingcaihuodong_jingcaihuodong) do
        if ActStatusModel.getIsActOpen(v.huodong) then
            if v.open == 1 then 
                if v.huodong == nbActivityShowType.VipShouchong then 
                    if not game.player:getIsHasBuyGold() then 
                        table.insert(self._data, v)
                    end 
                elseif v.huodong == nbActivityShowType.VipFuli then 
                    if game.player:getVip() > 0 then 
                        table.insert(self._data, v)
                    end 
                elseif v.huodong == nbActivityShowType.Yueqian then 
                    if ENABLE_YUEQIAN == true then 
                        table.insert(self._data, v) 
                    end 
                elseif v.huodong == nbActivityShowType.DengjiTouzi then 
                    if ENABLE_DENGJITOUZI == true then 
                        table.insert(self._data, v) 
                    end 
                elseif v.huodong == nbActivityShowType.LimitHero then --限时神将
                    table.insert(self._data, v) 
				elseif v.huodong ~= nbActivityShowType.VipLibao then  -- vip礼包已移到商场内 
                    table.insert(self._data, v) 
                elseif v.huodong == nbActivityShowType.DialyActivity then --新加每日活动
                	table.insert(self._data, v)
                end
        	end

		end
        if v.huodong == nbActivityShowType.xianshiShop then --限时商店
                table.insert(self._data, v)
        end
    end

    -- dump(self._data) 

    local firstType 
    if #self._data > 0 then 
        firstType = self._data[1].huodong  
    end 

    local function createFunc(index)
        -- print("limimimi")
        -- dump(self._data)
        local item = require("game.nbactivity.ActivityItem").new()
        return item:create({
            viewSize = CCSizeMake(self._rootnode["headList"]:getContentSize().width, self._rootnode["headList"]:getContentSize().height),
            itemData = self._data[index + 1] 
        })
    end 

    local function refreshFunc(cell, index) 
        local selected = false
        if index == self._cellIndex then 
            selected = true
        end

        cell:refresh(self._data[index + 1], selected) 
    end

    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["headList"]:getContentSize().width, self._rootnode["headList"]:getContentSize().height), 
        createFunc  = createFunc,
        refreshFunc = refreshFunc,
        cellNum     = #self._data,
        cellSize    = require("game.nbactivity.ActivityItem").new():getContentSize(), 
        touchFunc = function(cell)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian)) 
            local id = cell:getId()
            local index = cell:getIdx() 
            if self._showType ~= id then                 
                self:updateLayer(id, index)  
            end 
        end
    })

    self._rootnode["headList"]:addChild(self._scrollItemList) 

    return firstType
end


function ActivityScene:updateLayer(showType, cellIndex)  
    local viewSize = CCSizeMake(display.width, self:getContentHeight()) 

    if self._contentNode and self._contentNode:getChildByTag(111) then
    	if self._contentNode:getChildByTag(111).clear then
    		self._contentNode:getChildByTag(111):clear()
    	end
	end

    print("-----type"..showType)
    -- 客栈
    if showType == nbActivityShowType.KeZhan then 
        self._showType = showType 

        self._contentNode:removeAllChildrenWithCleanup(true)
        local sleepLayer = require("game.nbactivity.SleepLayer").new({
            viewSize = viewSize 
            }) 
		
        sleepLayer:setPosition(display.width/2, self:getBottomHeight())
        self._contentNode:addChild(sleepLayer, 1)
		
    elseif showType == nbActivityShowType.xianshiDuiHuan then
    	self._showType = showType
    	self._contentNode:removeAllChildrenWithCleanup(true)
        local sleepLayer = require("game.nbactivity.DuiHuan.DuiHuanMainView").new({
        	size = viewSize
        })  
        sleepLayer:setPosition(0, self:getBottomHeight())
        self._contentNode:addChild(sleepLayer, 1 ,111)
        
	elseif showType == nbActivityShowType.huanggongTanBao then
    	local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.TanBao, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt) 
        else
        	self._showType = showType
	        self._contentNode:removeAllChildrenWithCleanup(true)
	        local sleepLayer = require("game.nbactivity.TanBao.TanbaoMainView").new({
	        	size = viewSize
	        })  
	        sleepLayer:setPosition(0, self:getBottomHeight())
	        self._contentNode:addChild(sleepLayer, 1 , 111)
		end
	elseif showType == nbActivityShowType.migongWaBao then
		self._showType = showType
    	self._contentNode:removeAllChildrenWithCleanup(true)
        local sleepLayer = require("game.nbactivity.WaBao.WaBaoMainView").new({
        	size = viewSize
        })  
        sleepLayer:setPosition(0, self:getBottomHeight())
        self._contentNode:addChild(sleepLayer, 1 ,111)
	elseif showType == nbActivityShowType.ShenMi then 
        -- 神秘商店 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenMi_Shop, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt) 
        else 
            self._showType = showType 
            self._contentNode:removeAllChildrenWithCleanup(true)

            local shenmiLayer = require("game.nbactivity.ShenmiShop.ShenmiLayer").new({
                viewSize = viewSize 
                }) 

            shenmiLayer:setPosition(display.width/2, self:getBottomHeight())
            self._contentNode:addChild(shenmiLayer, 1) 
        end
	elseif showType == nbActivityShowType.CaiQuan then
        --猜拳
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true)

        local caiQuanLayer = require("game.nbactivity.CaiQuan.CaiQuanLayer").new({
            viewSize = viewSize 
            }) 

        caiQuanLayer:setPosition(display.width/2, self:getBottomHeight())
        self._contentNode:addChild(caiQuanLayer, 1) 
    elseif  showType == nbActivityShowType.xianshiShop then
        --限时商店
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true)

        local caiQuanLayer = require("game.nbactivity.XianShiShop.XianShiMainView").new({
            viewSize = viewSize 
            }) 

        caiQuanLayer:setPosition(0, self:getBottomHeight())
        self._contentNode:addChild(caiQuanLayer, 1) 

    elseif  showType == nbActivityShowType.LimitHero then
        --限时神将
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.LimitHero, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt) 
        else 
            self._showType = showType 
            self._contentNode:removeAllChildrenWithCleanup(true)

            local caiQuanLayer = require("game.nbactivity.LimitHero.LimitHeroLayer").new({
                viewSize = viewSize 
                }) 

            caiQuanLayer:setPosition(display.width/2, self:getBottomHeight())
            self._contentNode:addChild(caiQuanLayer, 1) 
        end

    elseif showType == nbActivityShowType.MonthCard then 
        -- 月卡
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 

        local monthCardLayer = require("game.nbactivity.MonthCard.MonthCardLayer").new({
            viewSize = viewSize
            })
        monthCardLayer:setPosition(display.cx, self:getBottomHeight()) 
        self._contentNode:addChild(monthCardLayer, 1) 

    elseif showType == nbActivityShowType.VipFuli then 
        -- vip福利
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 

        local vipFuliLayer = require("game.nbactivity.VipFuli.VipFuliLayer").new({
            viewSize = viewSize
            })
        vipFuliLayer:setPosition(display.cx, self:getBottomHeight()) 
        self._contentNode:addChild(vipFuliLayer, 1) 

    elseif showType == nbActivityShowType.VipShouchong then 
        -- 首充礼包
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 

        local vipFuliLayer = require("game.nbactivity.ShouchongLibao.ShouchongLibaoLayer").new({
            viewSize = viewSize
            })
        vipFuliLayer:setPosition(display.cx, self:getBottomHeight()) 
        self._contentNode:addChild(vipFuliLayer, 1) 

    elseif showType == nbActivityShowType.LeijiLogin then 
        -- 累积登录 
        self._showType = showType 
        local function addLeijiLoginLayer()
            self._contentNode:removeAllChildrenWithCleanup(true) 
            local leijiLoginLayer = require("game.nbactivity.LeijiLogin.LeijiLoginLayer").new({
                viewSize = viewSize, 
                rewardDatas = self._leijiLoginListData
                })
            leijiLoginLayer:setPosition(display.cx, self:getBottomHeight()) 
            self._contentNode:addChild(leijiLoginLayer, 1) 
        end 

        if self._leijiLoginListData == nil then 
            RequestHelper.leijiLogin.getListData({
                callback = function(data)
                    dump(data) 
                    if data.err ~= "" then 
                        dump(data.err) 
                    else  
                        self._leijiLoginListData = {} 
                        self._leijiLoginListData = self:createLeijiRewardData(data.rtnObj.listObj) 
                        addLeijiLoginLayer() 
                    end 
                end
            }) 
        else
            addLeijiLoginLayer() 
        end 

    elseif showType == nbActivityShowType.Yueqian then 
        -- 月签 
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 

        local yueqianLayer = require("game.nbactivity.Yueqian.YueqianLayer").new({
            viewSize = viewSize
            })
        yueqianLayer:setPosition(display.cx, self:getBottomHeight()) 
        self._contentNode:addChild(yueqianLayer, 1) 

    elseif showType == nbActivityShowType.DengjiTouzi then 
        -- 等级投资 
        self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 

        local touziLayer = require("game.nbactivity.DengjiTouzi.DengjiTouziLayer").new({
            viewSize = viewSize
            })
        touziLayer:setPosition(display.cx, self:getBottomHeight()) 
        self._contentNode:addChild(touziLayer, 1) 

    elseif  showType == nbActivityShowType.DialyActivity then
    	self._showType = showType 
        self._contentNode:removeAllChildrenWithCleanup(true) 
        local bng = display.newSprite("bg/duobao_bg.jpg")
        bng:setScale(display.height/bng:getContentSize().height)
        bng:setAnchorPoint(cc.p(0,0))
        self._contentNode:addChild(bng)
    	RequestHelper.dialyTask.getTaskList({
                callback = function(data)
                    	dump(data)
                    if data["0"] ~= "" then
                        dump(data["0"]) 
                    else 
                        local layer = require("game.nbactivity.Huodong.TaskPopup").new(data,self,viewSize) 
                        layer:setAnchorPoint(cc.p(0.5,0))
                        layer:setPosition(0, self:getBottomHeight())
                        self._contentNode:addChild(layer,1) 
                    end
                end 
                })
    end

    if self._showType == showType then 
        self._cellIndex = cellIndex 
        for i = 0, self._scrollItemList:getCellNum() - 1 do 
            local item = self._scrollItemList:cellAtIndex(i) 
            if item ~= nil then 
                if self._cellIndex == i then 
                    item:setSelected(true) 
                else
                    item:setSelected(false) 
                end 
            end 
        end 

        local cellContentSize = require("game.nbactivity.ActivityItem").new():getContentSize()

        -- 当前每页显示的个数
        local pageCount = (self._scrollItemList:getViewSize().width) / cellContentSize.width  
        local maxMove = self._scrollItemList:getCellNum() - pageCount   
        local curIndex = 0 
        local tmpCount = self._cellIndex + 1 
        if tmpCount > pageCount then 
            curIndex = tmpCount - pageCount 
        end 

        if curIndex > maxMove then 
            curIndex = maxMove 
        end 

        -- 刷新 精彩活动 顶部 icon位置
        if(self._scrollItemList:getCellNum() > pageCount ) then
            self._scrollItemList:setContentOffset(CCPoint((-curIndex * cellContentSize.width), 0)) 
        end
    end 


end 


function ActivityScene:createLeijiRewardData(listData)
    dump(listData) 

    local tmpRewardDatas = {} 
    local rewardDatas = {} 

    for j, d in pairs(listData) do 
        local itemData = {} 
        for i, v in ipairs(d) do 
            local itemType = v.t 
            local itemId = v.id 
            local itemNum = v.n 

            local iconType = ResMgr.getResType(v.t) 
            local itemInfo 
            
            if iconType == ResMgr.HERO then 
                itemInfo = ResMgr.getCardData(itemId)
            else
                itemInfo = data_item_item[itemId] 
            end 

            table.insert(itemData, {
                id = itemId, 
                type = itemType, 
                num = itemNum or 0, 
                name = itemInfo.name, 
                describe = itemInfo.describe or "", 
                iconType = iconType 
                })
        end 
        table.insert(tmpRewardDatas, {
            day = checkint(j),  
            itemData = itemData 
            })
    end 

    for i = 1, #tmpRewardDatas do 
        for k, v in ipairs(tmpRewardDatas) do 
            if v.day == i then 
                table.insert(rewardDatas, v) 
                break 
            end 
        end  
    end 

    -- dump(rewardDatas) 

    return rewardDatas 
end


function ActivityScene:onEnter()
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end


function ActivityScene:onExit()
	if self._contentNode and self._contentNode:getChildByTag(111) then
    	if self._contentNode:getChildByTag(111).clear then
    		self._contentNode:getChildByTag(111):clear()
    	end
	end
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    self:unregNotice() 
end


return ActivityScene

