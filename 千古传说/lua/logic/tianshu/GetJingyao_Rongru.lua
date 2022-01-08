--[[
    精要融入和取下界面
]]

local GetJingyao_Rongru = class("GetJingyao_Rongru", BaseLayer)

GetJingyao_Rongru.TAG_RONGRU = 1
GetJingyao_Rongru.TAG_XIEXIA = 2
GetJingyao_Rongru.TAG_HECHENG = 3
GetJingyao_Rongru.TAG_GETWAY = 4
GetJingyao_Rongru.EnumWindowStatus = 
{
    STATUS_CLOSE = 1,
    STATUS_OPEN = 2
}

function GetJingyao_Rongru:ctor(data)
    self.super.ctor(self, data)
    self.TAG_CAN_RONGRU = nil
    self.firstShow = true
    self:init("lua.uiconfig_mango_new.tianshu.GetJingYao")
end

function GetJingyao_Rongru:loadData(bookItem, index, status, jingyaoId)
    self.bookItem = bookItem
    self.index = index
    self.id = jingyaoId
    if self.logic.EnumJingyaoStatus.STATUS_JINGYAO_ENOUGH == status then
        self.status = self.TAG_RONGRU
    elseif self.logic.EnumJingyaoStatus.STATUS_EQUIPPED == status then
        self.status = self.TAG_XIEXIA
    elseif self.logic.EnumJingyaoStatus.STATUS_NOT_ENOUGH == status then
        self.status = self.TAG_GETWAY
    elseif self.logic.EnumJingyaoStatus.STATUS_PIECE_ENOUGH == status then
        self.status = self.TAG_HECHENG
    end
end

function GetJingyao_Rongru:setDelegate(logic)
    self.logic = logic
end

function GetJingyao_Rongru:onShow()
    self.super.onShow(self)     
    self:refreshUI()
end

function GetJingyao_Rongru:refreshUI()
    if self.firstShow then
        self:showOnCenter()
        self.firstShow = false
    end

    local item = ItemData:objectByID(tonumber(self.id))
    self.img_jy2.txt_name:setText(item.name)
    self.img_jy2.txt_name_black:setText(item.name)
    if self.status == self.TAG_RONGRU then
        self:refreshRongru()
    elseif self.status == self.TAG_XIEXIA then
        self:refreshXiexia()
    elseif self.status == self.TAG_HECHENG then
        self:refreshYJRR()
    elseif self.status == self.TAG_GETWAY then
        self:refreshHecheng()
    end
    self.img_jy2:setVisible(true)
end

--融入
function GetJingyao_Rongru:refreshRongru()
    self.txt_jihuo[1]:setVisible(true)
    self.txt_jihuo[2]:setVisible(false)

    local item = ItemData:objectByID(tonumber(self.id))
    --self.img_jy1:setTexture(GetColorRoadIconByQualitySmall(item.quality))
    self.img_jy1:setTexture("ui_new/tianshu/btn_jyk.png")
    self.img_jy1.img_jy:setTexture(item:GetPath())
    self.img_jy1.img_jy:setOpacity(100)

    self.bg_xuqiu:setVisible(true)
    self.img_jy2:setVisible(true)

    self.img_jy2:setTextureNormal(GetColorIconByQuality_82(item.quality))
    self.img_jy2.img_jy:setTexture(item:GetPath())

    self.btn_xiexia:setVisible(false)
    self.btn_rongru:setVisible(true)
    self.btn_getway:setVisible(false)
    self.btn_hecheng:setVisible(false)
    self.btn_yjrr:setVisible(false)

    local attr = self.bookItem.bibleConfig:getHoleAttr(self.index)
    local strName = AttributeTypeStr[attr.key]
    local strValue = attr.value
    self.txt_attr:setText(strName .. "+" .. strValue)
    --[[
    local costCoin = 0
    local costGoodsId = nil
    local costGoodsNum = 0
    local str = self.bookItem.bibleConfig.mosaic
    local tab = string.split(str, "|")
    local curStr = tab[self.index]
    local curTab = string.split(curStr, ",")
    for i = 1, #curTab do
        local tab1 = string.split(curTab[i], "_") 
        if tonumber(tab1[1]) == EnumDropType.COIN then
            costCoin = costCoin + tonumber(tab1[3])
        elseif tonumber(tab1[1]) == EnumDropType.YUELI then
            --costGoodsId = tonumber(tab1[2])
            costGoodsNum = costGoodsNum + tonumber(tab1[3])
        end
    end

    self.costCoin = costCoin
    self.costGoodsNum = costGoodsNum
    ]]

    self:refreshCost()

    self.btn_rongru.img_newprice1.txt_price:setText(self.costCoin)
    if MainPlayer:getCoin() < self.costCoin then
        self.btn_rongru.img_newprice1.txt_price:setColor(ccc3(255, 0, 0))
    end   
    self.btn_rongru.img_newprice1.txt_price1:setVisible(false)

    self.btn_rongru.img_newprice2.txt_price:setText(self.costGoodsNum)
    if SkyBookManager:getCurYueli() < self.costGoodsNum then
        self.btn_rongru.img_newprice2.txt_price:setColor(ccc3(255, 0, 0))
    end
    self.btn_rongru.img_newprice2.txt_price1:setVisible(false)

    self.bg_xuqiu:setVisible(true)
    self.bg_yirongru:setVisible(false)

    self.img_jy2.txt_name:setVisible(true)
    self.img_jy2.txt_name_black:setVisible(false)
end

function GetJingyao_Rongru:refreshCost()
    local costCoin = 0
    local costGoodsId = nil
    local costGoodsNum = 0
    local str = self.bookItem.bibleConfig.mosaic
    local tab = string.split(str, "|")
    local curStr = tab[self.index]
    local curTab = string.split(curStr, ",")
    for i = 1, #curTab do
        local tab1 = string.split(curTab[i], "_") 
        if tonumber(tab1[1]) == EnumDropType.COIN then
            costCoin = costCoin + tonumber(tab1[3])
        elseif tonumber(tab1[1]) == EnumDropType.YUELI then
            --costGoodsId = tonumber(tab1[2])
            costGoodsNum = costGoodsNum + tonumber(tab1[3])
        end
    end

    self.costCoin = costCoin
    self.costGoodsNum = costGoodsNum
end

function GetJingyao_Rongru:refreshYJRR()
    self.txt_jihuo[1]:setVisible(true)
    self.txt_jihuo[2]:setVisible(false)

    local item = ItemData:objectByID(tonumber(self.id))
    --self.img_jy1:setTexture(GetColorRoadIconByQualitySmall(item.quality))
    self.img_jy1:setTexture("ui_new/tianshu/btn_jyk.png")
    self.img_jy1.img_jy:setTexture(item:GetPath())
    self.img_jy1.img_jy:setOpacity(100)

    self.bg_xuqiu:setVisible(true)
    self.img_jy2:setVisible(true)

    self.img_jy2:setTextureNormal(GetColorIconByQuality_82(item.quality))
    self.img_jy2.img_jy:setTexture(item:GetPath())

    self.btn_xiexia:setVisible(false)
    self.btn_rongru:setVisible(false)
    self.btn_getway:setVisible(false)
    self.btn_hecheng:setVisible(false)
    self.btn_yjrr:setVisible(true)

    local attr = self.bookItem.bibleConfig:getHoleAttr(self.index)
    local strName = AttributeTypeStr[attr.key]
    local strValue = attr.value
    self.txt_attr:setText(strName .. "+" .. strValue)

    local costCoin = 0
    local costGoodsId = nil
    local costGoodsNum = 0
    local str = self.bookItem.bibleConfig.mosaic
    local tab = string.split(str, "|")
    local curStr = tab[self.index]
    local curTab = string.split(curStr, ",")
    for i = 1, #curTab do
        local tab1 = string.split(curTab[i], "_") 
        if tonumber(tab1[1]) == EnumDropType.COIN then
            costCoin = costCoin + tonumber(tab1[3])
        elseif tonumber(tab1[1]) == EnumDropType.YUELI then
            --costGoodsId = tonumber(tab1[2])
            costGoodsNum = costGoodsNum + tonumber(tab1[3])
        end
    end

    self.costCoin = costCoin
    self.costGoodsNum = costGoodsNum

    self.btn_yjrr:setTextureNormal("ui_new/tianshu/btn_yjrr.png")
    self.btn_yjrr:setVisible(true)
    self.btn_yjrr.img_newprice1.txt_price:setText(self.costCoin)
    if MainPlayer:getCoin() < self.costCoin then
        self.btn_yjrr.img_newprice1.txt_price:setColor(ccc3(255, 0, 0))
    end   

    self.btn_yjrr.img_newprice2.txt_price:setText(self.costGoodsNum)
    if SkyBookManager:getCurYueli() < self.costGoodsNum then
        self.btn_yjrr.img_newprice2.txt_price:setColor(ccc3(255, 0, 0))
    end

    self.bg_xuqiu:setVisible(true)
    self.bg_yirongru:setVisible(false)

    self.img_jy2.txt_name:setVisible(true)
    self.img_jy2.txt_name_black:setVisible(false)
end

--卸下
function GetJingyao_Rongru:refreshXiexia()
    self.txt_jihuo[1]:setVisible(false)
    self.txt_jihuo[2]:setVisible(true)

    local item = ItemData:objectByID(tonumber(self.id))
    self.img_jy1:setTexture(GetColorRoadIconByQualitySmall(item.quality))
    self.img_jy1.img_jy:setTexture(item:GetPath())

    self.bg_xuqiu:setVisible(false)
    self.img_jy2:setVisible(false)

    self.img_jy2:setTextureNormal(GetColorIconByQuality_82(item.quality))
    self.img_jy2.img_jy:setTexture(item:GetPath())

    self.btn_xiexia:setVisible(true)
    self.btn_rongru:setVisible(false)
    self.btn_getway:setVisible(false)
    self.btn_hecheng:setVisible(false)
    self.btn_yjrr:setVisible(false)

    local attr = self.bookItem.bibleConfig:getHoleAttr(self.index)
    local strName = AttributeTypeStr[attr.key]
    local strValue = attr.value
    self.txt_attr:setText(strName .. "+" .. strValue)

    self.bg_xuqiu:setVisible(false)
    self.bg_yirongru:setVisible(true)

    self.img_jy2.txt_name:setVisible(false)
    self.img_jy2.txt_name_black:setVisible(true)

    local costCoin = 0
    local costGoodsId = nil
    local costGoodsNum = 0
    local str = self.bookItem.bibleConfig.mosaic
    local tab = string.split(str, "|")
    local curStr = tab[self.index]
    local curTab = string.split(curStr, ",")
    for i = 1, #curTab do
        local tab1 = string.split(curTab[i], "_") 
        if tonumber(tab1[1]) == EnumDropType.COIN then
            costCoin = costCoin + tonumber(tab1[3])
        elseif tonumber(tab1[1]) == EnumDropType.YUELI then
            --costGoodsId = tonumber(tab1[2])
            costGoodsNum = costGoodsNum + tonumber(tab1[3])
        end
    end

    self.costGoodsNum = costGoodsNum
end

--合成或不足
function GetJingyao_Rongru:refreshHecheng()
    self.txt_jihuo[1]:setVisible(true)
    self.txt_jihuo[2]:setVisible(false)

    local item = ItemData:objectByID(tonumber(self.id))
    --self.img_jy1:setTexture(GetColorRoadIconByQualitySmall(item.quality))
    self.img_jy1.img_jy:setTexture(item:GetPath())

    self.img_jy1:setTexture("ui_new/tianshu/btn_jyk.png")
    self.img_jy1.img_jy:setOpacity(100)

    self.bg_xuqiu:setVisible(true)
    self.img_jy2:setVisible(true)

    self.img_jy2:setTextureNormal(GetColorIconByQuality_82(item.quality))
    self.img_jy2.img_jy:setTexture(item:GetPath())

    self.btn_xiexia:setVisible(false)
    self.btn_rongru:setVisible(false)
    self.btn_getway:setVisible(false)
    self.btn_hecheng:setVisible(false)
    self.btn_yjrr:setVisible(false)

    print("self.bookItem =",self.bookItem)
    local attr = self.bookItem.bibleConfig:getHoleAttr(self.index)
    local strName = AttributeTypeStr[attr.key]
    local strValue = attr.value
    self.txt_attr:setText(strName .. "+" .. strValue)

    if self.TAG_CHANGE_TO_RONGRU then  
        self.btn_hecheng:setVisible(false)
        self.btn_rongru:setVisible(true)
        self.btn_getway:setVisible(false)

        self.btn_rongru.img_newprice1.txt_price:setText(self.costCoin)
        if MainPlayer:getCoin() < self.costCoin then
            self.btn_rongru.img_newprice1.txt_price:setColor(ccc3(255, 0, 0))
        end   
        self.btn_rongru.img_newprice1.txt_price1:setVisible(false)

        self.btn_rongru.img_newprice2.txt_price:setText(self.costGoodsNum)
        if SkyBookManager:getCurYueli() < self.costGoodsNum then
            self.btn_rongru.img_newprice2.txt_price:setColor(ccc3(255, 0, 0))
        end
        self.btn_rongru.img_newprice2.txt_price1:setVisible(false)

        if self.TAG_CAN_RONGRU then
            self:addRongruEffect()
        end

        --[[
        self.btn_hecheng:setTextureNormal("ui_new/tianshu/btn_rongru.png")
        self.btn_hecheng:setGrayEnabled(false)
        self.btn_hecheng:setTouchEnabled(true)
        self:addHechengEffect()
        self.btn_hecheng:setVisible(true)
        self.btn_getway:setVisible(false)
        ]]
        return
    end

    if self.status == self.TAG_HECHENG then        
        self.btn_hecheng:setVisible(true)
        if self.windowStatus == self.EnumWindowStatus.STATUS_OPEN then
            self.btn_hecheng:setTextureNormal("ui_new/rolebook/btn_hqtj.png")            
            self.btn_hecheng:setGrayEnabled(true)
            self.btn_hecheng:setTouchEnabled(false)
        end
    elseif self.status == self.TAG_GETWAY then
        self.btn_getway:setVisible(true)
        if self.windowStatus == self.EnumWindowStatus.STATUS_OPEN then
            self.btn_getway:setTextureNormal("ui_new/rolebook/btn_hqtj.png")            
            self.btn_getway:setGrayEnabled(true)
            self.btn_getway:setTouchEnabled(false)
        end
    end

    self.bg_xuqiu:setVisible(true)
    self.bg_yirongru:setVisible(false)

    self.img_jy2.txt_name:setVisible(true)
    self.img_jy2.txt_name_black:setVisible(false)

    --self.costCoin = costCoin
    --self.costGoodsNum = costGoodsNum
    self:refreshCost()
end

function GetJingyao_Rongru:addHechengEffect()
    local btn = self.btn_hecheng
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end

    ModelManager:addResourceFromFile(2, "btn_common", 1)
    local effect = ModelManager:createResource(2, "btn_common")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
    
    btn:addChild(effect, 100)
    btn.effect = effect   
end

function GetJingyao_Rongru:addRongruEffect()
    local btn = self.btn_rongru
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end

    ModelManager:addResourceFromFile(2, "btn_common", 1)
    local effect = ModelManager:createResource(2, "btn_common")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)

    btn:addChild(effect, 100)
    btn.effect = effect   
end

function GetJingyao_Rongru:initUI(ui)
	self.super.initUI(self, ui)

    self.img_bg  = TFDirector:getChildByPath(ui, "img_qx_diag")
    self.txt_jihuo = {}
    --未激活
    self.txt_jihuo[1] = TFDirector:getChildByPath(ui, "txt_weijihuo")
    --已激活
    self.txt_jihuo[2] = TFDirector:getChildByPath(ui, "txt_jihuo")
    --左上角精要icon
    self.img_jy1 = TFDirector:getChildByPath(ui, "img_jy1")
    self.img_jy1.img_jy = TFDirector:getChildByPath(ui, "img_jy")
    --加属性文本
    self.txt_attr = TFDirector:getChildByPath(ui, "txt_bookname")
    --卸下按钮
    self.btn_xiexia = TFDirector:getChildByPath(ui, "btn_xiexia")
    self.btn_xiexia.logic = self

    --融入按钮
    self.btn_rongru = TFDirector:getChildByPath(ui, "btn_rongru")
    self.btn_rongru.logic = self
    self.btn_rongru.img_newprice1 = TFDirector:getChildByPath(self.btn_rongru, "img_newprice1")
    self.btn_rongru.img_newprice1.txt_price = TFDirector:getChildByPath(self.btn_rongru.img_newprice1, "txt_price")
    self.btn_rongru.img_newprice1.txt_price1 = TFDirector:getChildByPath(self.btn_rongru.img_newprice1, "txt_price1")

    self.btn_rongru.img_newprice2 = TFDirector:getChildByPath(self.btn_rongru, "img_newprice2")
    self.btn_rongru.img_newprice2.txt_price = TFDirector:getChildByPath(self.btn_rongru.img_newprice2, "txt_price")
    self.btn_rongru.img_newprice2.txt_price1 = TFDirector:getChildByPath(self.btn_rongru.img_newprice2, "txt_price1")

    --需求文字小背景
    self.bg_xuqiu = TFDirector:getChildByPath(ui, "bg_bt")
    self.bg_yirongru = TFDirector:getChildByPath(ui, "bg_bt2")

    --第二个小精要图标
    self.img_jy2 = TFDirector:getChildByPath(ui, "img_quality")
    self.img_jy2.img_jy = TFDirector:getChildByPath(ui, "img_equip")
    self.img_jy2.txt_name = TFDirector:getChildByPath(ui, "txt_name1")
    self.img_jy2.txt_name_black = TFDirector:getChildByPath(ui, "txt_name2")

    self.img_jy2.logic = self

    self.img_hechengdiag = TFDirector:getChildByPath(ui, "img_hechengdiag")

    --获取途径按钮
    self.btn_getway = TFDirector:getChildByPath(ui, "btn_huoqu1")
    self.btn_getway.logic = self

    --合成按钮
    self.btn_hecheng = TFDirector:getChildByPath(ui, "btn_hecheng")
    self.btn_hecheng.logic = self

    --一键融入按钮
    self.btn_yjrr = TFDirector:getChildByPath(ui, "btn_yjrr")
    self.btn_yjrr.logic = self
    self.btn_yjrr.img_newprice1 = TFDirector:getChildByPath(self.btn_yjrr, "img_newprice1")
    self.btn_yjrr.img_newprice1.txt_price = TFDirector:getChildByPath(self.btn_yjrr.img_newprice1, "txt_price")

    self.btn_yjrr.img_newprice2 = TFDirector:getChildByPath(self.btn_yjrr, "img_newprice2")
    self.btn_yjrr.img_newprice2.txt_price = TFDirector:getChildByPath(self.btn_yjrr.img_newprice2, "txt_price")

    self.windowStatus = self.EnumWindowStatus.STATUS_CLOSE
end

function GetJingyao_Rongru:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_xiexia:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onXiexiaClickHandle))
    self.btn_rongru:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRongruClickHandle))
    self.btn_getway:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGetwayClickHandle))
    self.btn_hecheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHechengClickHandle))
    self.img_jy2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onIconClickHandle))
    self.btn_yjrr:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onYJRRClickHandle))

    self.EssentialUnMosaicCallback = function(event)
        AlertManager:close()
    end
    TFDirector:addMEGlobalListener(SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT, self.EssentialUnMosaicCallback)

    self.EssentialMosaicCallback = function(event)
        AlertManager:close()
    end
    TFDirector:addMEGlobalListener(SkyBookManager.ESSENTIAL_MOSAIC_RESULT, self.EssentialMosaicCallback)

    self.EssentialMergeCallback = function(event)
        print("++++++rongru EssentialMergeCallback+++++++")
        self.TAG_CAN_RONGRU = true
        self.TAG_CHANGE_TO_RONGRU = true

        self:refreshCost()
        
        print("mainplayer coin = ", MainPlayer:getCoin())
        print("needCoin = ", self.costCoin)
        if MainPlayer:getCoin() < self.costCoin then
            self.TAG_CAN_RONGRU = false
        end

        print("mainplayer yueli = ", SkyBookManager:getCurYueli())
        print("need yueli = ", self.costGoodsNum)
        if SkyBookManager:getCurYueli() < self.costGoodsNum then
            self.TAG_CAN_RONGRU = false
        end

        --self.TAG_CAN_RONGRU = false

        self:refreshHecheng()
        if self and self.layer_hecheng then
            self.layer_hecheng:loadData(self.id, 1)
        end
    end
    TFDirector:addMEGlobalListener(BagManager.EQUIP_PIECE_MERGE, self.EssentialMergeCallback)
end


function GetJingyao_Rongru:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT, self.EssentialUnMosaicCallback )
    self.EssentialUnMosaicCallback = nil

    TFDirector:removeMEGlobalListener(SkyBookManager.ESSENTIAL_MOSAIC_RESULT, self.EssentialMosaicCallback)
    self.EssentialMosaicCallback = nil

    TFDirector:removeMEGlobalListener(BagManager.EQUIP_PIECE_MERGE, self.EssentialMergeCallback)
    self.EssentialMergeCallback = nil
end

function GetJingyao_Rongru.onIconClickHandle(sender)
    local self = sender.logic

    Public:ShowItemTipLayer(tonumber(self.id), EnumDropType.GOODS)
end

function GetJingyao_Rongru.onXiexiaClickHandle(sender)
    local self = sender.logic
    print("request xiexia")

    --local msg = "是否卸下该精要?\n将返还阅历" .. self.costGoodsNum .. "点"
    local msg = stringUtils.format(localizable.getJingyao_rongru_text1 ,self.costGoodsNum)
    CommonManager:showOperateSureLayer(function()
        local data = {}
        data[1] = self.bookItem.instanceId
        data[2] = self.index
        SkyBookManager:requestEssentialUnMosaic(data)
    end,
    nil,
    {
        msg = msg,
    })
end

function GetJingyao_Rongru.onYJRRClickHandle(sender)
    local self = sender.logic
    print("request rongru")

    print("mainplayer coin = ", MainPlayer:getCoin())
    print("needCoin = ", self.costCoin)
    if MainPlayer:getCoin() < self.costCoin then
        --toastMessage("融入所需金币不足!")
        toastMessage(localizable.Tianshu_rongru_text1)
        return
    end

    print("mainplayer yueli = ", SkyBookManager:getCurYueli())
    print("need yueli = ", self.costGoodsNum)
    if SkyBookManager:getCurYueli() < self.costGoodsNum then
        toastMessage("融入所需阅历不足!")
        return
    end

    SkyBookManager:requestEssentialMerge(self.id)

    local data = {}
    data[1] = self.bookItem.instanceId
    data[2] = tonumber(self.id)
    data[3] = self.index
    SkyBookManager:requestEssentialMosaic(data)
end

function GetJingyao_Rongru.onRongruClickHandle(sender)
    local self = sender.logic
    print("request rongru")

    print("mainplayer coin = ", MainPlayer:getCoin())
    print("needCoin = ", self.costCoin)
    if MainPlayer:getCoin() < self.costCoin then
        --toastMessage("融入所需金币不足!")
        toastMessage(localizable.Tianshu_rongru_text1)
        return
    end

    print("mainplayer yueli = ", SkyBookManager:getCurYueli())
    print("need yueli = ", self.costGoodsNum)
    if SkyBookManager:getCurYueli() < self.costGoodsNum then
        --toastMessage("融入所需阅历不足!")
        toastMessage(localizable.Tianshu_rongru_text2)
        return
    end

    local data = {}
    data[1] = self.bookItem.instanceId
    data[2] = tonumber(self.id)
    data[3] = self.index
    SkyBookManager:requestEssentialMosaic(data)
end

function GetJingyao_Rongru.onGetwayClickHandle(sender)
    local self = sender.logic

    print("clicking getway")

    self:openRight()
end

function GetJingyao_Rongru.onHechengClickHandle(sender)
    local self = sender.logic

    print("clicking hecheng")

    if self.TAG_CAN_RONGRU then
        print("request rongru")

        local data = {}
        data[1] = self.bookItem.instanceId
        data[2] = tonumber(self.id)
        data[3] = self.index
        SkyBookManager:requestEssentialMosaic(data)
        return
    end

    self:openRight()
end

function GetJingyao_Rongru:openRight()
    self.windowStatus = self.EnumWindowStatus.STATUS_OPEN
    self:refreshHecheng() 
    self:openRightArea()  
end

function GetJingyao_Rongru:moveArea(target_, toPos)
    local toastTween = {
      target = target_,
      {
        duration = 0.5,
        x = toPos.x,
        y = toPos.y
      },
      {
        duration = 0,
        onComplete = function() 
        end
      }
    }

    TFDirector:toTween(toastTween)
end

function GetJingyao_Rongru:openRightArea()
    self:drawRightAreaOnce()
    --[[
    if self.status == self.TAG_HECHENG then
        self.layer_hecheng:loadData(self.id, 1, 1)
    elseif self.status == self.TAG_GETWAY then
        self.layer_hecheng:loadData(self.id, 2, 1)
    end
    ]]
    self.layer_hecheng:loadData(self.id, 1)

    local parent        = self.img_bg:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_bg:getContentSize()
    local pos           = self.img_bg:getPosition()

    local center_x = sizeParent.width / 2
    local center_y = sizeParent.height / 2
    local gap = 20 -- 两个框的间隔

    local left_x = center_x - gap / 2 - sizeImage.width / 2
    local right_x = center_x + gap / 2 + sizeImage.width / 2

    -- 开启动画
    self:moveArea(self.img_bg, ccp(left_x, center_y))
    self:moveArea(self.img_hechengdiag, ccp(right_x, center_y))

    self.img_hechengdiag:setVisible(true)
end

--显示在中间
function GetJingyao_Rongru:showOnCenter()
    local parent = self.img_bg:getParent()
    local sizeParent = parent:getContentSize()
    local sizeImage = self.img_bg:getContentSize()
    local pos = self.img_bg:getPosition()

    local x = sizeParent.width / 2
    local y = sizeParent.height / 2

    self.img_bg:setPosition(ccp(x, y))
    self.img_hechengdiag:setPosition(ccp(x, y))
    self.img_hechengdiag:setVisible(false)
end

function GetJingyao_Rongru:drawRightAreaOnce()
    if self.layer_hecheng == nil then
        local GetJingyao_Hecheng = require("lua.logic.tianshu.GetJingyao_Hecheng"):new()
        GetJingyao_Hecheng:setTag(10086)
        GetJingyao_Hecheng:setZOrder(2)
        GetJingyao_Hecheng:setPosition(ccp(-207, -281))
        self.img_hechengdiag:addChild(GetJingyao_Hecheng, 200)

        self.layer_hecheng = GetJingyao_Hecheng
    else
        self.layer_hecheng:refreshUI()
    end
end

return GetJingyao_Rongru