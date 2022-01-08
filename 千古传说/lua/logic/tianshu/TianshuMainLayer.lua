--[[
    天书主界面
]]
local TianshuMainLayer = class("TianshuMainLayer", BaseLayer)

TianshuMainLayer.kMaxEssentialNum = 9
TianshuMainLayer.kMaxAttrNum = 9
TianshuMainLayer.EnumJingyaoStatus = 
{
    --未装备且精要以及碎片都不够
    STATUS_NOT_ENOUGH = 1,
    --未装备且精要不够但精要碎片够
    STATUS_PIECE_ENOUGH = 2,
    --未装备且精要够
    STATUS_JINGYAO_ENOUGH = 3,
    --已融入
    STATUS_EQUIPPED = 4
}

TianshuMainLayer.TAG_EQUIPPED = 1
TianshuMainLayer.TAG_UNEQUIPPED = 2

TianshuMainLayer.kMinHoleNum = 3
TianshuMainLayer.kMaxHoleNum = 9
TianshuMainLayer.TEXT_TUPO_MAX = localizable.Tianshu_chongzhi_tips8

function TianshuMainLayer:ctor()
    --测试添加天书残页
    --BagManager:testAddBookPiece()
    --测试添加精要
    --BagManager:testAddEssential()

    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.tianshu.TianShuMain")
end

function TianshuMainLayer:loadData(instanceId)
    self.instanceId = instanceId   
    self:refreshUI()
end

function TianshuMainLayer:setTag(tag)
    self.book_type = tag
end

local function sortByQualityAndPower(book1, book2)
    if book1.quality > book2.quality then
        return true
    elseif book1.quality == book2.quality then
        if book1:getpower() > book2:getpower() then
            return true
        end
    end

    return false
end

function TianshuMainLayer:getBookList()
    local arr = nil
    if self.book_type == self.TAG_EQUIPPED then
        arr = SkyBookManager:getEquippedBookList()        
    else
        arr = SkyBookManager:getAllUnEquippedBook()
    end
    arr:sort(sortByQualityAndPower)
    return arr
end

function TianshuMainLayer:initUI(ui)
	self.super.initUI(self, ui)    
	--通用头部   
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.TianShu, {HeadResType.YUELI, HeadResType.COIN, HeadResType.SYCEE})

    self.img_tianshu = TFDirector:getChildByPath(ui, "img_tianshu")

    self.panel_tianshu_list = {}
    for i = self.kMinHoleNum, self.kMaxHoleNum do
        self.panel_tianshu_list[i] = TFDirector:getChildByPath(ui, "panel_kong" .. i)
        self.panel_tianshu_list[i]:setVisible(false)
    end

    --天书名字
    self.txt_name = TFDirector:getChildByPath(ui, "txt_name")
    --天书重数
    self.txt_chong = TFDirector:getChildByPath(ui, "txt_chong")
    self.img_fazhen = TFDirector:getChildByPath(ui, "img_fazhen")
    --星星(突破重数)
    self.img_xing = {}
    for i = 1, SkyBookManager.kMaxStarLevel do
        local temp = TFDirector:getChildByPath(ui, "img_xing" .. i .. "_2")
        self.img_xing[i] = TFDirector:getChildByPath(ui, "img_xing" .. i .. "_1")
        self.img_xing[i].xing = temp
    end

    --精要
    --[[
    self.panel_jy = {}
    for i = 1, self.kMaxEssentialNum do
        self.panel_jy[i] = TFDirector:getChildByPath(ui, "panel_jy" .. i)
        self.panel_jy[i].img_quality = TFDirector:getChildByPath(self.panel_jy[i], "img_quality")
        self.panel_jy[i].img_jy = TFDirector:getChildByPath(self.panel_jy[i], "img_jy")
        self.panel_jy[i].img_jy:setScale(1.5)
        self.panel_jy[i].img_add = TFDirector:getChildByPath(self.panel_jy[i], "img_add")
    end
    ]]
    --天书残页
    self.panel_canye = TFDirector:getChildByPath(ui, "panel_book")
    --残页品质图片
    self.img_quality = TFDirector:getChildByPath(self.panel_canye, "img_quality")
    self.img_quality.logic = self


    --残页图片
    self.img_equip = TFDirector:getChildByPath(self.panel_canye, "img_equip")

    --残页进度条和数量
    local txt_soul = TFDirector:getChildByPath(ui, "txt_soul")
    self.txt_soul = txt_soul
    self.txt_soul_num = TFDirector:getChildByPath(txt_soul, "txt_soul_num")
    self.bar_soul = TFDirector:getChildByPath(ui, "bar_soul")
    --突破按钮
    self.btn_tupo = TFDirector:getChildByPath(ui, "btn_tupo")
    self.btn_tupo.logic = self

    --属性
    self.panel_jiacheng = TFDirector:getChildByPath(ui, "panel_jiacheng")
    self.img_attr = {}
    for i = 1, self.kMaxAttrNum do
        self.img_attr[i] = TFDirector:getChildByPath(self.panel_jiacheng, "img_attr" .. i)
        self.img_attr[i].txt_name = TFDirector:getChildByPath(self.img_attr[i], "txt_name")
        self.img_attr[i].txt_base = TFDirector:getChildByPath(self.img_attr[i], "txt_base")
        self.img_attr[i]:setVisible(false)
    end

    --精要按钮
    self.btn_jingyao = TFDirector:getChildByPath(ui, "btn_jingyao")
    self.btn_jingyao.logic = self
    --升重按钮
    self.btn_shengchong = TFDirector:getChildByPath(ui, "btn_shengchong")
    self.btn_shengchong.logic = self

    --升重消耗
    --[[
    self.img_newprice = {}
    for i = 1, 2 do
        self.img_newprice[i] = TFDirector:getChildByPath(self.btn_shengchong, "img_newprice" .. i)
        self.img_newprice[i].txt_price = TFDirector:getChildByPath(self.img_newprice[i], "txt_price")
        self.img_newprice[i]:setVisible(false)
    end 
    ]] 

    --升重所需材料panel
    self.panel_shengchong_need = TFDirector:getChildByPath(ui, "img_qdi")
    self.panel_book1 = TFDirector:getChildByPath(self.panel_shengchong_need, "panel_book1")
    self.txt_suoxu = TFDirector:getChildByPath(self.panel_shengchong_need, "txt_suoxu2")
    self.panel_book1.img_quality = TFDirector:getChildByPath(self.panel_book1, "img_quality")
    self.panel_book1.img_quality.logic = self

    self.panel_book1.img_equip = TFDirector:getChildByPath(self.panel_book1, "img_equip")
    self.panel_book1.txt_num = TFDirector:getChildByPath(self.panel_book1, "txt_num")
    self.panel_book2 = TFDirector:getChildByPath(self.panel_shengchong_need, "panel_book2")
    self.panel_book2.img_quality = TFDirector:getChildByPath(self.panel_book2, "img_quality")
    self.panel_book2.img_quality.logic = self
    self.panel_book2.txt_num1 = TFDirector:getChildByPath(self.panel_book2, "txt_num1")

    self.panel_book2.img_equip = TFDirector:getChildByPath(self.panel_book2, "img_equip")
    self.panel_book2.txt_num = TFDirector:getChildByPath(self.panel_book2, "txt_num")

    --重置按钮
    self.btn_chongzhi = TFDirector:getChildByPath(ui, "btn_chongzhi")
    self.btn_chongzhi.logic = self

    --帮助按钮
    self.btn_help = TFDirector:getChildByPath(ui, "btn_bangzu")
    self.btn_help.logic = self

    self.img_diwen1 = TFDirector:getChildByPath(ui, "img_diwen1")
    self.img_diwen2 = TFDirector:getChildByPath(ui, "img_diwen2")

    --左右按钮
    self.btn_pageleft = TFDirector:getChildByPath(ui, "btn_pageleft")
    self.btn_pageright = TFDirector:getChildByPath(ui, "btn_pageright")
    self.btn_pageleft.logic = self
    self.btn_pageright.logic = self

    self.img_equiped = TFDirector:getChildByPath(ui, "img_equiped")
    self.txt_equiped_name = TFDirector:getChildByPath(self.img_equiped, "txt_equiped_name")
end

function TianshuMainLayer:onShow()
	self.super.onShow(self)
	self.generalHead:onShow()
    self:refreshUI()
end

function TianshuMainLayer:refreshUI()
    self.item = SkyBookManager:getItemByInstanceId(self.instanceId)

    self.selectIndex = self:getBookList():indexOf(self.item)
    self.btn_pageright:setVisible(true)
    self.btn_pageleft:setVisible(true)

    self.btn_tupo:setGrayEnabled(false)
    self.btn_tupo:setTouchEnabled(true)
    self:addTupoEffect(self.btn_tupo, false)

    self.btn_shengchong:setGrayEnabled(false)
    self.btn_shengchong:setTouchEnabled(true)

    local equipId = self.item.equip
    if equipId and equipId ~= 0 then
        self.img_equiped:setVisible(true)
        self.txt_equiped_name:setVisible(true)
        local role = CardRoleManager:getRoleById(equipId)
        self.txt_equiped_name:setText(role.name)
    else
        self.img_equiped:setVisible(false)
        self.txt_equiped_name:setVisible(false)
    end

    self.txt_soul:setText(localizable.Tianshu_chongzhi_tips9)

    print("+++++++index:", self.selectIndex)
    if self.selectIndex == 1 then
        self.btn_pageleft:setVisible(false)
    end

    if self.selectIndex == self:getBookList():length() then
        self.btn_pageright:setVisible(false)
    end

    self:refreshJingyaoStatus()

    self.txt_soul:setVisible(true)
    self.txt_soul_num:setVisible(true)

    self.panel_book1:setVisible(true)
    self.panel_book2:setVisible(true)

    for i = self.kMinHoleNum, self.kMaxHoleNum do
        self.panel_tianshu_list[i]:setVisible(false)
    end

    self.panel_tianshu = self.panel_tianshu_list[self.item.maxStoneNum]
    self.panel_tianshu:setVisible(true)

    self.panel_jy = {}
    for i = 1, self.item.maxStoneNum do
        self.panel_jy[i] = TFDirector:getChildByPath(self.panel_tianshu, "btn_jy" .. i)
        --self.panel_jy[i].img_quality = TFDirector:getChildByPath(self.panel_jy[i], "img_quality")
        self.panel_jy[i].img_jy = TFDirector:getChildByPath(self.panel_jy[i], "img_jy")
        --self.panel_jy[i].img_jy:setScale(1.5)
        self.panel_jy[i].img_khc = TFDirector:getChildByPath(self.panel_jy[i], "img_khc")
        self.panel_jy[i].img_kjh = TFDirector:getChildByPath(self.panel_jy[i], "img_kjh")

        self.panel_jy[i].img_jy:setScale(0.62)
    end

    for i = 1, #self.panel_jy do
        self.panel_jy[i].logic = self
        self.panel_jy[i].index = i
        self.panel_jy[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onEssentialClickHandle), 1)
    end

    self.panel_shengchong_need:setVisible(true)
    local costCoin = 0
    local costGoodsId = nil
    local costGoodsNum = 0
    local str = self.item.bibleConfig.comsume
    local tab = string.split(str, ",")
    for i = 1, #tab do
        local tab1 = string.split(tab[i], "_")
        if tonumber(tab1[1]) == EnumDropType.COIN then
            costCoin = costCoin + tonumber(tab1[3])
        elseif tonumber(tab1[1]) == EnumDropType.GOODS then
            costGoodsId = tonumber(tab1[2])
            costGoodsNum = costGoodsNum + tonumber(tab1[3])
        end
    end

    self.panel_book1.img_equip:setTexture(GetCoinIcon())
    self.panel_book1.txt_num:setText(costCoin)
    if MainPlayer:getCoin() < costCoin then
        self.panel_book1.txt_num:setColor(ccc3(255, 0, 0))
    else
        self.panel_book1.txt_num:setColor(ccc3(255, 255, 255))
    end

    if costGoodsId then
        local item = ItemData:objectByID(costGoodsId)
        self.panel_book2.img_quality:setTextureNormal(GetColorIconByQuality_82(item.quality))
        self.panel_book2.img_equip:setTexture(item:GetPath())
        local num = 0
        num = BagManager:getItemNumById(costGoodsId)
        self.panel_book2.txt_num:setText("/" .. costGoodsNum)
        self.panel_book2.txt_num1:setText(num)
        if num < costGoodsNum then
            self.panel_book2.txt_num1:setColor(ccc3(255, 0, 0))
        else
            self.panel_book2.txt_num1:setColor(ccc3(255, 255, 255))
        end
    else
        self.panel_book2:setVisible(false)
    end

    self.costCoin = costCoin
    self.costGoodsId = costGoodsId
    self.costGoodsNum = costGoodsNum

    --升重按钮效果 
    
    if self.btn_shengchong.effect then
        self.btn_shengchong.effect:removeFromParent()
        self.btn_shengchong.effect = nil
    end
    
    if self:isCanShengchong() then
        self:addTupoEffect(self.btn_shengchong, true)
    end

    self.img_tianshu:setTexture(self.item:GetTextrue())
    
    --名字
    self.txt_name:setText(self.item:getConfigName())

    --重数
    --self.txt_chong:setText("第" .. EnumSkyBookLevelType[self.item.level] .. "重")
    self.txt_chong:setText(stringUtils.format(localizable.common_index_chong,EnumSkyBookLevelType[self.item.level] ))

    --星星
    local tupoLevel = self.item.tupoLevel
    for i = 1, SkyBookManager.kMaxStarLevel do
        self.img_xing[i]:setVisible(true)
        self.img_xing[i].xing:setVisible(false)
    end
    for i = 1, tupoLevel do
        self.img_xing[i].xing:setVisible(true)
    end

    --精要孔
    self:refreshJingyaoHole()

    --残页图片
    self.img_quality:setTextureNormal(GetColorIconByQuality_82(self.item.quality))
    local template = SkyBookManager:getBiblePieceTemplateByQuality(self.item.quality)
    self.img_equip:setTexture(template:GetPath())

    --残页进度
    local curPieceNum = SkyBookManager:getBiblePieceNumByQuality(self.item.quality)
    local needPieceNum = SkyBookManager:getTupoNeedPieceNumByInstance(self.item)

    local percent = (curPieceNum / needPieceNum) * 100
    if percent <= 100 then
        self.bar_soul:setPercent(percent)
    else
        self.bar_soul:setPercent(100)
    end
    self.txt_soul_num:setText(curPieceNum .. "/" .. needPieceNum)

    --突破按钮效果
    if percent >= 100 and SkyBookManager:isInTupoMaxLevel(self.item) == false and self:isTupoMaterialEnough() then
        self:addTupoEffect(self.btn_tupo, true)
    else
        self:addTupoEffect(self.btn_tupo, false)
    end

    for i = 1, self.kMaxAttrNum do
        self.img_attr[i]:setVisible(false)
    end

    --属性
    local totalAttr = self.item:getTotalAttr()
    local count = 0
    for i = 1, EnumAttributeType.Max - 1 do  
        if totalAttr[i] and totalAttr[i] ~= 0 and count < self.kMaxAttrNum then
            count = count + 1
            self.img_attr[count]:setVisible(true)
            self.img_attr[count].txt_name:setText(AttributeTypeStr[i])
            self.img_attr[count].txt_base:setText(totalAttr[i])
            self.img_attr[count]:setVisible(true)
        end
    end

    if SkyBookManager:isInTupoMaxLevel(self.item) then
        print("is in tupomax ++++++ ")
        self.btn_tupo:setGrayEnabled(true)
        self.btn_tupo:setTouchEnabled(false)
        self:addTupoEffect(self.btn_tupo, false)

        self.txt_soul:setVisible(true)
        self.txt_soul_num:setVisible(false)
        self.txt_soul:setText(self.TEXT_TUPO_MAX)  
    end

    self.img_diwen1:setTexture(GetRoleNameBgByQuality(self.item.quality))
    self.img_diwen2:setTexture(GetRoleNameBgByQuality(self.item.quality))

    if self.item.level >= BibleData:getMaxLevel(self.item.id) then
        self:addTupoEffect(self.btn_shengchong, false)
        --[[
        if self.btn_shengchong.effect then
            self.btn_shengchong.effect:removeFromParent()
            self.btn_shengchong.effect = nil
        end
        ]]
        self.btn_shengchong:setGrayEnabled(true)
        self.btn_shengchong:setTouchEnabled(false)
        self.txt_suoxu:setText(localizable.Tianshu_chongzhi_tips7)
        self.panel_book1:setVisible(false)
        self.panel_book2:setVisible(false)
    else
        self.txt_suoxu:setText(localizable.Tianshu_chongzhi_tips6)
    end
end

function TianshuMainLayer:isTupoMaterialEnough()
    local curPieceNum = SkyBookManager:getBiblePieceNumByQuality(self.item.quality)
    local needPieceNum, tab_tupofu = SkyBookManager:getTupoNeedPieceNumByInstance(self.item)

    if curPieceNum < needPieceNum then
        return false
    end

    if tab_tupofu and tab_tupofu.num then
        local item = ItemData:objectByID(tonumber(tab_tupofu.id))
        local curNum = BagManager:getItemNumById(tonumber(tab_tupofu.id))
        local needNum = tab_tupofu.num

        if curNum < needNum then
            return false
        end        
    end

    return true
end

--刷新精要孔
function TianshuMainLayer:refreshJingyaoHole()
    
    for i = 1, #self.panel_jy do
        self.panel_jy[i]:setVisible(true)
        self.panel_jy[i].img_jy:setVisible(false)
        self.panel_jy[i].img_jy:setOpacity(255)
    end
   
    print("++++++++++++++")
    for i = 1, #self.jingyaoIdList do
        print("id :", self.jingyaoIdList[i], "status :", self.jingyaoStatus[i])
    end
    print("++++++++++++++")


    for i = 1, self.item.maxStoneNum do
        local jingyaoId = self.jingyaoIdList[i]

        local item = ItemData:objectByID(tonumber(jingyaoId)) 
        self.panel_jy[i]:setTextureNormal("ui_new/tianshu/btn_jyk.png")       
        self.panel_jy[i].img_jy:setTexture(item:GetPath())

        if self.jingyaoStatus[i] == self.EnumJingyaoStatus.STATUS_EQUIPPED then
            self.panel_jy[i]:setTextureNormal(GetColorRoadIconByQualitySmall(item.quality))
            self.panel_jy[i].img_kjh:setVisible(false)
            self.panel_jy[i].img_khc:setVisible(false)
            self.panel_jy[i].img_jy:setVisible(true)
            self.panel_jy[i]:setOpacity(255)
            self.panel_jy[i].img_jy:setOpacity(255)
        elseif self.jingyaoStatus[i] == self.EnumJingyaoStatus.STATUS_NOT_ENOUGH then
            self.panel_jy[i].img_kjh:setVisible(false)
            self.panel_jy[i].img_khc:setVisible(false)
            self.panel_jy[i].img_jy:setVisible(true)
            --self.panel_jy[i]:setOpacity(180)
            self.panel_jy[i].img_jy:setOpacity(100)
        elseif self.jingyaoStatus[i] == self.EnumJingyaoStatus.STATUS_JINGYAO_ENOUGH then
            self.panel_jy[i].img_kjh:setVisible(true)
            self.panel_jy[i].img_khc:setVisible(false)
            self.panel_jy[i].img_jy:setVisible(true)
            --self.panel_jy[i]:setOpacity(180)
            self.panel_jy[i].img_jy:setOpacity(100)
        elseif self.jingyaoStatus[i] == self.EnumJingyaoStatus.STATUS_PIECE_ENOUGH then
            self.panel_jy[i].img_kjh:setVisible(false)
            self.panel_jy[i].img_khc:setVisible(true)
            self.panel_jy[i].img_jy:setVisible(true)
            --self.panel_jy[i]:setOpacity(180)
            self.panel_jy[i].img_jy:setOpacity(100)
        end
    end
end

function TianshuMainLayer:isCanShengchong()
    local bCanShengchong = true
    for i = 1, self.item.maxStoneNum do
        if self.jingyaoStatus[i] ~= self.EnumJingyaoStatus.STATUS_EQUIPPED then
            return false
        end
    end

    if MainPlayer:getCoin() < self.costCoin then
        return false
    end

    if self.costGoodsId then
        local goods =  BagManager:getItemById(tonumber(self.costGoodsId))
        local item = ItemData:objectByID(self.costGoodsId)
        if not goods then
            return false
        end
        print("shengchong need goodsId = ", self.costGoodsId)
        print("shengchong need goodsNum = ", self.costGoodsNum)
        if goods.num < tonumber(self.costGoodsNum) then
            return false
        end
    end

    return bCanShengchong
end

--突破按钮特效
function TianshuMainLayer:addTupoEffect(btn, bAdd)
    if bAdd then
        if btn.effect then
            btn.effect:removeFromParent()
            btn.effect = nil
        end

        ModelManager:addResourceFromFile(2, "btn_common_small", 1)
        local effect = ModelManager:createResource(2, "btn_common_small")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
        btn:addChild(effect, 100)
        btn.effect = effect
    else
        if btn.effect then
            btn.effect:removeFromParent()
            btn.effect = nil
        end
    end
end

function TianshuMainLayer:setLogic(logic)
	self.logic = logic
end

function TianshuMainLayer:removeUI()
	self.super.removeUI(self)
end

--销毁方法
function TianshuMainLayer:dispose()
	if self.generalHead then
		self.generalHead:dispose()
		self.generalHead = nil
	end

    self.super.dispose(self)
end

function TianshuMainLayer:registerEvents()
	self.super.registerEvents(self)

    self.btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTupoClickHandle), 1)
    self.btn_jingyao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onJingyaoClickHandle), 1)
    self.btn_shengchong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShengchongClickHandle), 1)
    self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChongzhiClickHandle), 1)
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHelpClickHandle), 1)
    self.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCanyeIconHandle), 1) 

    self.btn_pageleft:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onPageLeftClickHandle), 1)
    self.btn_pageright:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onPageRightClickHandle), 1)

    self.panel_book1.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCoinClickHandle), 1)
    self.panel_book2.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGoodsClickHandle), 1)
    
	self.EquipmentResultCallBack = function(event)
        print("111111111")
        --self:refreshUI()
    end
    TFDirector:addMEGlobalListener(SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT,self.EquipmentResultCallBack)

    
    self.EssentialMosaicCallBack = function(event)
        local data = event.data[1]
        print("data= ",data)
        local pos = data.pos

        local panel_tianshu = self.panel_tianshu_list[self.item.maxStoneNum]
        local widget = TFDirector:getChildByPath(panel_tianshu, "btn_jy" .. pos)
        if widget then
            if self.mosaic_effect then
                self.mosaic_effect:removeFromParent(true)
                self.mosaic_effect = nil
            end
            TFResourceHelper:instance():addArmatureFromJsonFile("effect/assistOpen.xml")
            local effect = TFArmature:create("assistOpen_anim")
            if effect == nil then
                self.img_success:removeFromParent(true)
                self.img_success = nil
                return
            end
            effect:setAnimationFps(GameConfig.ANIM_FPS)
            effect:playByIndex(0, -1, -1, 0)
            effect:setPosition(ccp(0,0))
            effect:setScale(0.75)
            effect:setZOrder(1)
            widget:addChild(effect)
            self.mosaic_effect = effect
            self.mosaic_effect:addMEListener(TFARMATURE_COMPLETE,function()
                self.mosaic_effect:removeMEListener(TFARMATURE_COMPLETE) 
                self.mosaic_effect = nil
            end)
        end

    end
    TFDirector:addMEGlobalListener(SkyBookManager.ESSENTIAL_MOSAIC_RESULT,self.EssentialMosaicCallBack)
    TFDirector:addMEGlobalListener(BagManager.EQUIP_PIECE_MERGE,self.EquipmentResultCallBack)

    self.ResetResultCallback = function(event)
        if self and self.refreshUI then
            print("000000000000000000")
            self:refreshUI()  
        end 
    end
    self.skyBookLevelUpResultCallBack = function(event)
        if self and self.refreshUI then
            self:refreshUI()
            self:showLevelUpSuccess()
        end 
    end
    TFDirector:addMEGlobalListener(SkyBookManager.BIBLE_RESET_RESULT, self.ResetResultCallback)
    TFDirector:addMEGlobalListener(SkyBookManager.BIBLE_BREACH_RESULT, self.ResetResultCallback)
    TFDirector:addMEGlobalListener(SkyBookManager.BIBLE_LEVEL_UP_RESULT, self.skyBookLevelUpResultCallBack)    

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function TianshuMainLayer.onPageLeftClickHandle(sender)
    local self = sender.logic

    --print(self.selectIndex)
    self.selectIndex = self:getBookList():indexOf(self.item)
    self.selectIndex = self.selectIndex - 1
    local item = self:getBookList():objectAt(self.selectIndex)
    
    self:loadData(item.instanceId)
end

function TianshuMainLayer.onPageRightClickHandle(sender)
    local self = sender.logic

    print(self.selectIndex)
    self.selectIndex = self:getBookList():indexOf(self.item)
    self.selectIndex = self.selectIndex + 1
    local item = self:getBookList():objectAt(self.selectIndex)
    self:loadData(item.instanceId)
end

function TianshuMainLayer:showLevelUpSuccess()
    if self.success_effect then
        self.success_effect:removeFromParent(true)
        self.success_effect  = nil
    end
    -- local img = TFImage:create()

    -- img:setTexture(self.item:GetTextrue())
    -- img:setScale(1.5)
    -- img:setPosition(ccp(0,0))
    -- img:setZOrder(10)
    -- self.img_fazhen:addChild(img)
    -- self.img_success = img

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/skyBook_shengchong_effect.xml")
    local effect = TFArmature:create("skyBook_shengchong_effect_anim")
    if effect == nil then
        return
    end
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(190,190))
    effect:setScale(1)
    effect:setZOrder(1)
    self.img_fazhen:addChild(effect)
    self.success_effect = effect
    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeMEListener(TFARMATURE_COMPLETE)
    end)
end

function TianshuMainLayer.onCanyeIconHandle(sender)
    local self = sender.logic
    local item = SkyBookManager:getBiblePieceTemplateByQuality(self.item.quality)
    Public:ShowItemTipLayer(item.id, EnumDropType.GOODS)
end

function TianshuMainLayer.onCoinClickHandle(sender)
    local self = sender.logic

    Public:ShowItemTipLayer(nil, EnumDropType.COIN)
end

function TianshuMainLayer.onGoodsClickHandle(sender)
    local self = sender.logic

    if not self.costGoodsId then
        return
    end

    Public:ShowItemTipLayer(self.costGoodsId, EnumDropType.GOODS)
end

function TianshuMainLayer:removeEvents()
    self.super.removeEvents(self)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    TFDirector:removeMEGlobalListener(SkyBookManager.ESSENTIAL_UN_MOSAIC_RESULT, self.EquipmentResultCallBack )
    --self.EquipmentResultCallBack = nil

    TFDirector:removeMEGlobalListener(SkyBookManager.ESSENTIAL_MOSAIC_RESULT, self.EssentialMosaicCallBack )
    self.EssentialMosaicCallBack = nil
    --self.EquipmentResultCallBack = nil

    TFDirector:removeMEGlobalListener(BagManager.EQUIP_PIECE_MERGE, self.EquipmentResultCallBack)
    self.EquipmentResultCallBack = nil

    TFDirector:removeMEGlobalListener(SkyBookManager.BIBLE_RESET_RESULT, self.ResetResultCallback)
    --self.ResetResultCallback = nil

    TFDirector:removeMEGlobalListener(SkyBookManager.BIBLE_BREACH_RESULT, self.ResetResultCallback)
    --self.ResetResultCallback = nil
    self.ResetResultCallback = nil

    TFDirector:removeMEGlobalListener(SkyBookManager.BIBLE_LEVEL_UP_RESULT, self.skyBookLevelUpResultCallBack)
    self.skyBookLevelUpResultCallBack = nil
end

function TianshuMainLayer.onEssentialClickHandle(sender)
    local self = sender.logic
    local index = sender.index

    if index > self.item.maxStoneNum then
        --toastMessage("该精要孔未开放")
        toastMessage(localizable.Tianshu_chongzhi_text4)
        return
    end

    local id = self.jingyaoIdList[index]
    --if self.jingyaoStatus[index] == self.EnumJingyaoStatus.STATUS_EQUIPPED or self.jingyaoStatus[index] == self.EnumJingyaoStatus.STATUS_JINGYAO_ENOUGH then
        --print("融入or卸下精要")
        local layer  = require("lua.logic.tianshu.GetJingyao_Rongru"):new()
        layer:setDelegate(self)
        layer:loadData(self.item, index, self.jingyaoStatus[index], id)
        AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
        AlertManager:show()
    --[[
    else
        print("合成精要碎片")
        local layer  = require("lua.logic.tianshu.GetJingyao_Rongru"):new()
        layer:setDelegate(self)
        layer:loadData(self.item, index, self.jingyaoStatus[index], id, self.EnumSubType.TYPE_HECHENG)
        AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
        AlertManager:show() 
    end
    ]]
end

function TianshuMainLayer.onHelpClickHandle(sender)
    local self = sender.logic

    --toastMessage("t_s_rule, t_s_rule_info还没配")
    CommonManager:showRuleLyaer("tianshu")
end

function TianshuMainLayer.onTupoClickHandle(sender)
    local self = sender.logic

    local layer =  AlertManager:addLayerByFile("lua.logic.tianshu.TianshuTupoLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(self.instanceId)
    AlertManager:show()
end

function TianshuMainLayer.onJingyaoClickHandle(sender)
    local self = sender.logic

    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.tianshu.JingyaoMainLayer")
    layer.selectedTab = nil
    AlertManager:show()
end

function TianshuMainLayer.onShengchongClickHandle(sender)
    local self = sender.logic

    self:requestShengchong()
end

--请求升重
function TianshuMainLayer:requestShengchong()
    --local maxLevel = ConstantData:getValue(" ")
    --常量表暂未配,暂时从SkyBookManager取

    local maxLevel = BibleData:getMaxLevel(self.item.id)
    local bookLevel = self.item.level
    if bookLevel >= maxLevel then
        --toastMessage("该天书已达最大重数")
        toastMessage(localizable.Tianshu_chongzhi_text5)
        return
    end

    for i = 1, self.item.maxStoneNum do
        local status = self.jingyaoStatus[i]

        if status ~= self.EnumJingyaoStatus.STATUS_EQUIPPED then
            --toastMessage("融入全部" .. self.item.maxStoneNum .. "个精要后才可以升重")
            toastMessage(stringUtils.format(localizable.Tianshu_chongzhi_text6,self.item.maxStoneNum ))
            return
        end
    end

    print("mainplayer coin = ", MainPlayer:getCoin())
    print("shengchong needCoin = ", self.costCoin)
    if MainPlayer:getCoin() < self.costCoin then
        --toastMessage("升重所需金币不足!")
        toastMessage(localizable.Tianshu_chongzhi_text7)
        return
    end

    if self.costGoodsId then
        local goods =  BagManager:getItemById(tonumber(self.costGoodsId))
        local item = ItemData:objectByID(self.costGoodsId)
        if not goods then
            toastMessage("融入所需" .. item.name .. "不足!")
            return
        end
        print("shengchong need goodsId = ", self.costGoodsId)
        print("shengchong need goodsNum = ", self.costGoodsNum)
        --print("shengchong have goodsNum = ", goods.num)
        if goods.num < tonumber(self.costGoodsNum) then
            --toastMessage("融入所需" .. goods.name .. "不足!")
            toastMessage(stringUtils.format(localizable.Tianshu_chongzhi_text8,goods.name))
            return
        end
    end
    
    SkyBookManager:requestBibleLevelUp(self.item.instanceId)
end

--获得单个精要孔状态
function TianshuMainLayer:getOneJingyaoStatus(index)
    local status = self.EnumJingyaoStatus.STATUS_NOT_ENOUGH
    local idTable = self.item:getJingyaoIdTable()
    --精要id
    local id = idTable[index]
    --已融入
    if self.item:getStonePos(index) and self.item:getStonePos(index) > 0 then
        return self.EnumJingyaoStatus.STATUS_EQUIPPED
    end
    --包里的精要
    local bagItem = BagManager:getItemById(tonumber(id))
    if bagItem and bagItem.num > 0 then
        --包里的精要足够
        return self.EnumJingyaoStatus.STATUS_JINGYAO_ENOUGH
    end

    if SkyBookManager:isJingyaoCanHecheng(tonumber(id)) then
        --包里精要碎片足够
        return self.EnumJingyaoStatus.STATUS_PIECE_ENOUGH
    end
    return status
end

--获得精要状态表
function TianshuMainLayer:refreshJingyaoStatus()
    local jingyaoStatus = {}
    for i = 1, self.item.maxStoneNum do
        local status = self:getOneJingyaoStatus(i)
        jingyaoStatus[i] = status
    end
    self.jingyaoStatus = jingyaoStatus
    self.jingyaoIdList = self.item:getJingyaoIdTable()
    return jingyaoStatus
end

function TianshuMainLayer.onChongzhiClickHandle(sender)
    local self = sender.logic

    local layer =  AlertManager:addLayerByFile("lua.logic.tianshu.TianshuChongzhiLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(self.instanceId)
    AlertManager:show()

    --SkyBookManager:requestBibleReset(self.item.instanceId)
end

return TianshuMainLayer