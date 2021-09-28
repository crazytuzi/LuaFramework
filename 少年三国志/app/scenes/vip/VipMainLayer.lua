
local VipMainLayer = class("VipMainLayer",UFCCSModelLayer)
require("app.cfg.vip_level_info")
require("app.cfg.drop_info")
require("app.cfg.dungeon_vip_info")

local FunctionLevelConst = require("app.const.FunctionLevelConst")

Path = require("app.setting.Path")
Goods = require("app.setting.Goods")

local vipMax = 12

function VipMainLayer.create(...)   
    local layer = VipMainLayer.new("ui_layout/vip_vipMainLayer.json",require("app.setting.Colors").modelColor,...) 
    -- local vip = G_Me.userData.vip
    -- layer:updateView(vip)
    layer:adaptView()
    return layer
end


function VipMainLayer:ctor(json,color,...)
    self.super.ctor(self, ...)
    self:showAtCenter(true)
    self._curLevel = 0

    -- self._vipLevelImg = self:getImageViewByName("Image_vipLevel")
    self._levelImg = self:getImageViewByName("Image_level")
    self._vipImg = self:getImageViewByName("Image_vip")
    self._levelLabel = self:getLabelByName("Label_24")
    self._money = self:getLabelByName("Label_money")
    self._rank = self:getLabelBMFontByName("BitmapLabel_rank")
    self._tequan = self:getLabelBMFontByName("BitmapLabel_tequan")
    self._libao = self:getLabelBMFontByName("BitmapLabel_libao")
    self._fuben = self:getLabelBMFontByName("BitmapLabel_fuben")
    self._loading = self:getLoadingBarByName("LoadingBar_Pro") 
    self._left = self:getButtonByName("Button_left") 
    self._right = self:getButtonByName("Button_right") 
    self._desc = self:getLabelByName("Label_mapDesc")
    self._mapHero = self:getImageViewByName("Image_mapHero")
    self._mapName = self:getImageViewByName("Image_mapName")

    self:getLabelByName("Label_10"):setText(G_lang:get("LANG_VIP_MONEY1"))
    self:getLabelByName("Label_23"):setText(G_lang:get("LANG_VIP_MONEY2"))

    self:getLabelByName("Label_10"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_23"):createStroke(Colors.strokeBrown, 1)
    self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self._money:createStroke(Colors.strokeBrown, 1)
    self._desc:createStroke(Colors.strokeBrown, 1)

    self:getLabelByName("Label_max"):createStroke(Colors.strokeBrown, 1)

    self._nameLabels = {}
    for i=1,5 do
        self._nameLabels[#self._nameLabels+1] = self:getLabelByName(string.format("Label_Item%d", i))
    end
    
    self._imageViews = {}
    for i=1,5 do
        self._imageViews[#self._imageViews+1] = self:getImageViewByName(string.format("ImageView_Item%d", i))
    end

    self._numLabels = {}
    for i=1,5 do
        self._numLabels[#self._numLabels+1] = self:getLabelByName(string.format("Label_num%d", i))
    end

    self._bgs = {}
    for i=1,5 do
        self._bgs[#self._bgs+1] = self:getImageViewByName(string.format("Image_Buttom%d", i))
    end

    self:registerBtnClickEvent("Button_Back", function()
        if G_Me.shopData:getVipEnter() == false then
            require("app.scenes.shop.recharge.RechargeLayer").show()
        end
        G_Me.shopData:setVipEnter(false)
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_left", function()
        self:_goLeft()
    end)
    self:registerBtnClickEvent("Button_right", function()
        self:_goRight()
    end)
    self:registerBtnClickEvent("Button_recharge", function()
        require("app.scenes.shop.recharge.RechargeLayer").show()  
        self:animationToClose()
    end)
    
    self:registerWidgetClickEvent("Panel_libao", function()
        self:animationToClose()
        local ShopVipConst = require("app.const.ShopVipConst")
        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.shop.ShopScene").new(nil,nil,ShopVipConst.VIP0_LI_BAO+self._curLevel))
    end)
    self:registerWidgetClickEvent("Panel_map", function()
        local FunctionLevelConst = require("app.const.FunctionLevelConst")
        unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_SCENE)
        if not unlockFlag then 
            local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.VIP_SCENE)
            G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_VIP_TIPS",{level=_level}))
            return
        end
        local minOpenVip = G_Me.userData.vip + 1
        local findResult = false
        while (not findResult) and (minOpenVip <= vip_level_info.getLength()) do 
            local vipInfo = vip_level_info.get(minOpenVip)
            if vipInfo and vipInfo.new_open > 0 then 
                findResult = true
            end
            if not findResult then 
                minOpenVip = minOpenVip + 1
            end
        end
        if self._curLevel > minOpenVip then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_VIP_FORMAT", {vipLevel = self._curLevel}))
            return
        end
        -- uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new())
        self:animationToClose()
        local map = vip_level_info.get(self._curLevel).new_open
        uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new(map))
    end)

end

function VipMainLayer:onLayerEnter( )
    self:closeAtReturn(true)
    -- self:adapterWithScreen()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    local vip = G_Me.userData.vip
    self:updateView(vip)
    -- dump(G_Me.vipData:getData(type))
end

function VipMainLayer:adaptView( )
    -- self:adapterWithScreen()
    -- self:adapterWidgetHeight("Panel_24", "Panel_27", nil, 0, 0)
    -- local size = CCDirector:sharedDirector():getWinSize()
    -- local panel = self:getPanelByName("Panel_24")
    -- local size2 = panel:getContentSize()
    -- local adaptHeight = size.height-853+458
    -- local adaptHeight2 = size.height-853+467
    
    -- panel:setContentSize(CCSize(size2.width,adaptHeight))
    -- print(adaptHeight)
    -- local img = self:getImageViewByName("Image_24")
    -- local size3 = img:getContentSize()
    -- local pos = ccp(img:getPosition())
    -- img:setContentSize(CCSize(size3.width,size3.height))
    -- print(pos.x.." "..pos.y)
    -- img:setPosition(pos)
    -- self:adapterWidgetHeight("Panel_24", "Panel_27", "Panel_60", 0, 0)
end

function VipMainLayer:_goLeft( )
    if self._curLevel == 0 then 
        return
    end
    self._curLevel = self._curLevel - 1
    self:updateSp(self._curLevel)
end

function VipMainLayer:_goRight( )
    if self._curLevel == vipMax then 
        return
    end
    self._curLevel = self._curLevel + 1
    self:updateSp(self._curLevel)
end

function VipMainLayer:_checkArrow(vip )
    self._left:setTouchEnabled(vip ~= 0)
    self._right:setTouchEnabled(vip ~= vipMax)
end

function VipMainLayer:updateView(vip)

    self._curLevel = vip
    --当前vip exp label
    local currentVipExpLabel = self:getLabelByName("Label_progress")
    currentVipExpLabel:createStroke(Colors.strokeBrown,1)
    local exp = G_Me.vipData:getExp()
    self:updateLevel(vip)
    if vip < vipMax then
        self:getPanelByName("Panel_next"):setVisible(true)
        self:getWidgetByName("Label_max"):setVisible(false)

        self._levelLabel:setText("VIP"..vip+1)
        
        local expMax = vip_level_info.get(vip+1).low_value
        -- self._money:setText(expMax - exp)
        self._money:setText(G_Me.vipData:getNextExp())
        self._loading:setPercent(exp/expMax * 100)
        currentVipExpLabel:setText(exp .. "/" .. expMax)
    else
        local expMax = vip_level_info.get(vip).low_value
        currentVipExpLabel:setText(exp .. "/" .. expMax)
        self:getPanelByName("Panel_next"):setVisible(false)
        self:getLabelByName("Label_max"):setVisible(true)
        self._loading:setPercent(100)
    end
 
    self:updateSp(vip)
    
end

function VipMainLayer:updateLevel(vip)
    self._levelImg:loadTexture(G_Path.getShopVipLevelImage(vip))
    -- local totalWidth = self._vipLevelImg:getContentSize().width
    -- local levelWidth = self._levelImg:getContentSize().width
    -- local vipWidth = self._vipImg:getContentSize().width
    -- local center = (vipWidth-levelWidth)/2
    -- self._levelImg:setPositionXY(center+levelWidth/2,0)
    -- self._vipImg:setPositionXY(center-vipWidth/2,0)
end

function VipMainLayer:updateSp(vip)

    self._rank:setText("VIP"..vip..G_lang:get("LANG_VIP_TITLE1"))
    self._tequan:setText("V"..vip..G_lang:get("LANG_VIP_TITLE2"))
    self._libao:setText("V"..vip..G_lang:get("LANG_VIP_TITLE3"))
    self._fuben:setText("V"..vip..G_lang:get("LANG_VIP_TITLE4"))

    self:_checkArrow(vip)

    local scrollView = self:getScrollViewByName("ScrollView_main")
    local scrollSize = scrollView:getInnerContainerSize()
    local scrollContent = self:getPanelByName("Panel_main")
    local bottomY = 5

    local mapPanel = self:getPanelByName("Panel_map")
    if self:_setMap(vip) then
        mapPanel:setPosition(ccp(0,bottomY))
        bottomY = bottomY + mapPanel:getSize().height + 5
    end
    local libaoPanel = self:getPanelByName("Panel_libao")
    self:_setDrop(vip)
    libaoPanel:setPosition(ccp(0,bottomY))
    bottomY = bottomY + libaoPanel:getSize().height + 5

    bottomY = self:_loadInfo(vip,bottomY) + 5

    bottomY = bottomY - 5
    scrollView:setInnerContainerSize(CCSizeMake(scrollSize.width, bottomY))
    scrollContent:setSize(CCSizeMake(scrollSize.width, bottomY))
    
    -- self:_setInfo(vip)
    -- self:_setDrop(vip)
    -- self:_setMap(vip)
end


function VipMainLayer:_loadInfo( vip,bottomY)
    local panel = self:getPanelByName("Panel_tequan")
    if not panel then 
        return bottomY
    end

    local baseY = bottomY
    local panelHeight = 30
    local panelSize = panel:getSize()
    local viptext = vip_level_info.get(vip)
    local labelBefore = self:getLabelByName("Label_tequan")
    local size = labelBefore:getSize()
    local label = GlobalFunc.createGameLabel(viptext.function_direction, 22,Colors.lightColors.DESCRIPTION,
        nil, CCSizeMake(size.width, 0), true)
    labelBefore:removeFromParent()
    local labelSize = label:getSize()
    label:setPosition(ccp(28+labelSize.width/2, 30 + labelSize.height/2))
    label:setName("Label_tequan")
    panel:addChild(label, 1)
    panelHeight = panelHeight + labelSize.height + 30

    local bg = self:getImageViewByName("Image_tequanBg")
    local title = self:getLabelBMFontByName("BitmapLabel_tequan")
    bg:setSize(CCSizeMake(538, panelHeight))
    bg:setPositionXY(panelSize.width/2,panelHeight/2)
    title:setPositionXY(30,panelHeight-2)

    bottomY = bottomY + panelHeight
    panel:setSize(CCSizeMake(panelSize.width, panelHeight))
    panel:setPosition(ccp(0, baseY+5))

    bottomY = bottomY + 20

    return bottomY
end

function VipMainLayer:_setDrop( vip)
    local info = drop_info.get(101+vip)
    if info then
        for i=1,5 do
            if info["type_"..i] ~= 0 then
                local g = Goods.convert(info["type_"..i], info["value_"..i])
                if g then
                    self:getImageViewByName("ImageView_ItemBorder"..i):setVisible(true)
                    self._imageViews[i]:setVisible(true)
                    self._numLabels[i]:setVisible(true)
                    self._nameLabels[i]:setVisible(true)
                    self._bgs[i]:setVisible(true)
                    self._imageViews[i]:loadTexture(g.icon)
                    self._nameLabels[i]:setColor(Colors.getColor(g.quality))
                    self._nameLabels[i]:setText(g.name)
                    self._nameLabels[i]:createStroke(Colors.strokeBrown, 1)
                    self._numLabels[i]:createStroke(Colors.strokeBrown, 1)
                    self._numLabels[i]:setText("x"..info["min_num_"..i])
                    self:getImageViewByName("ImageView_ItemBorder"..i):loadTexture(G_Path.getEquipColorImage(g.quality,g.type))
                    self:regisgerWidgetTouchEvent("ImageView_ItemBorder"..i, function ( widget, param )
                        if param == TOUCH_EVENT_ENDED then -- 点击事件
                            -- require("app.scenes.common.dropinfo.DropInfo").show(info["type_"..i], info["value_"..i])  
                        end
                    end)
                end
            else
                self:getImageViewByName("ImageView_ItemBorder"..i):setVisible(false)
                self._imageViews[i]:setVisible(false)
                self._numLabels[i]:setVisible(false)
                self._nameLabels[i]:setVisible(false)
                self._bgs[i]:setVisible(false)
            end
        end
    end
end

function VipMainLayer:_setMap( vip)
    local map = vip_level_info.get(vip).new_open

    if map == 0 then
        self:getPanelByName("Panel_map"):setVisible(false)
        return false
    else
        self:getPanelByName("Panel_map"):setVisible(true)

        local info = dungeon_vip_info.get(map)
        self._desc:setText(G_lang:get("LANG_VIP_MAP",{level=vip,map=G_Me.vipData:getMapName(map)}))
        
        self._mapHero:loadTexture(G_Me.vipData:getVipMapImg(map))
        self._mapName:loadTexture(G_Me.vipData:getVipNameImg(map))
        return true
    end
    
end

return VipMainLayer

