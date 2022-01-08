--[[
    天书突破预览界面
]]

local TianshuTupoLayer = class("TianshuTupoLayer", BaseLayer)

TianshuTupoLayer.kMaxAttrNum = 9

local CardSkyBook = require("lua.gamedata.base.CardSkyBook")

function TianshuTupoLayer:ctor(data)
	self.super.ctor(self, data)
    self.firstShow = true
	self:init("lua.uiconfig_mango_new.tianshu.TianShuTuPo")
end

function TianshuTupoLayer:initUI( ui )
	self.super.initUI(self, ui)

	self.btn_tupo = TFDirector:getChildByPath(ui,"Btn_starup")
	self.btn_tupo.logic = self
	self.btn_return = TFDirector:getChildByPath(ui, "btn_return")
	self.btn_return.logic = self

    --星星(突破重数)
    self.img_xing = {}
    for i = 1, SkyBookManager.kMaxStarLevel do
        local temp = TFDirector:getChildByPath(ui, "img_xing" .. i .. "_2")
        self.img_xing[i] = TFDirector:getChildByPath(ui, "img_xing" .. i .. "_1")
        self.img_xing[i].xing = temp

    end

	--属性
    self.img_attr = {}
    for i = 1, self.kMaxAttrNum do
        self.img_attr[i] = TFDirector:getChildByPath(ui, "img_attr" .. i)
        self.img_attr[i].txt_name = TFDirector:getChildByPath(self.img_attr[i], "txt_name")
        self.img_attr[i].txt_base = TFDirector:getChildByPath(self.img_attr[i], "txt_base")
        self.img_attr[i].txt_new = TFDirector:getChildByPath(self.img_attr[i], "txt_new")
        self.img_attr[i].img_to = TFDirector:getChildByPath(self.img_attr[i], "Img_to")
        self.img_attr[i]:setVisible(false)
    end

    --天书残页
    self.panel_canye = TFDirector:getChildByPath(ui, "panel_book")
    --残页品质图片
    self.img_quality = TFDirector:getChildByPath(self.panel_canye, "img_quality")
    self.img_quality.logic = self
    --残页图片
    self.img_equip = TFDirector:getChildByPath(self.panel_canye, "img_equip")
    self.txt_soul_num = TFDirector:getChildByPath(self.panel_canye, "txt_soul_num")
    self.txt_soul_num1 = TFDirector:getChildByPath(self.panel_canye, "txt_soul_num1")

    --天书突破符
    self.panel_tupofu = TFDirector:getChildByPath(ui, "panel_book1")
    self.panel_tupofu.img_quality = TFDirector:getChildByPath(self.panel_tupofu, "img_quality")
    self.panel_tupofu.img_equip = TFDirector:getChildByPath(self.panel_tupofu, "img_equip")
    self.panel_tupofu.txt_soul_num = TFDirector:getChildByPath(self.panel_tupofu, "txt_soul_num")
    self.panel_tupofu.txt_soul_num1 = TFDirector:getChildByPath(self.panel_tupofu, "txt_soul_num1")
    self.panel_tupofu.img_quality.logic = self

    self.txt_suoxu2 = TFDirector:getChildByPath(ui, "txt_suoxu2")

    self.panel_tianshu = TFDirector:getChildByPath(ui, "panel_tianshu")
    self.panel_tianshu.img = TFDirector:getChildByPath(ui, "img_tianshu")
	self.icon_panel = TFDirector:getChildByPath(ui, "img_tianshu")
end

function TianshuTupoLayer:removeUI()	
	self.super.removeUI(self)
end

function TianshuTupoLayer:dispose()

end

function TianshuTupoLayer:onShow()
    self.super.onShow(self)
	self:refreshUI()

	if self.firstShow == true then
    	self.ui:runAnimation("Action0", 1)
    	self.firstShow = false
    end

end

function TianshuTupoLayer:refreshUI()
    self.item = SkyBookManager:getItemByInstanceId(self.instanceId)

	self:onShowLeftInfo()
	self:onShowRightInfo()
end

function TianshuTupoLayer:registerEvents()
	self.super.registerEvents(self)

	self.btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTupoClickHandle), 1)
	self.btn_return:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onReturnClickHandle), 1)
    self.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCanyeIconClickHandle), 1)
    self.panel_tupofu.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onTupofuIconClickHandle), 1)

    self.BibleBreachCallback = function(event)
        --AlertManager:close()
        if self and self.onBibleBreachComplete then
            print("{{{{{{{{{{{")
            print(SkyBookManager:getBiblePieceNumByQuality(self.item.quality))
            self:refreshUI()
            self:onBibleBreachComplete()
        end
    end
    TFDirector:addMEGlobalListener(SkyBookManager.BIBLE_BREACH_RESULT, self.BibleBreachCallback)
end

function TianshuTupoLayer.onCanyeIconClickHandle(sender)
    local self = sender.logic

    local item = SkyBookManager:getBiblePieceTemplateByQuality(self.item.quality)
    Public:ShowItemTipLayer(item.id, EnumDropType.GOODS)
end

function TianshuTupoLayer.onTupofuIconClickHandle(sender)
    local self = sender.logic

    local needPieceNum, tab_tupofu = SkyBookManager:getTupoNeedPieceNumByInstance(self.item)

    if tab_tupofu and tab_tupofu.id then
        Public:ShowItemTipLayer(tonumber(tab_tupofu.id), EnumDropType.GOODS)
    end
end

function TianshuTupoLayer:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(SkyBookManager.BIBLE_BREACH_RESULT, self.BibleBreachCallback)
    self.BibleBreachCallback = nil
end

function TianshuTupoLayer:loadData(instanceId)
	self.instanceId = instanceId
	self.firstShow = true	
end

function TianshuTupoLayer.onTupoClickHandle(sender)
	local self = sender.logic

    self.oldarr = {}
    local totalAttr = self.item:getTotalAttr()
    for i = 1, EnumAttributeType.Max - 1 do
        self.oldarr[i] = totalAttr[i]
    end

    self.oldFactor = self.item.breachConfig.factor

    self.old_quality = self.item.quality
    self.old_starlevel = self.item.tupoLevel
    self.old_power = self.item:getpower()

    --self:onBibleBreachComplete()

    if (not self.NEED_TUPOFU) and self.curPieceNum >= self.needPieceNum then
        SkyBookManager:requestBibleBreach(self.instanceId)
        return
    end
    if self.curPieceNum >= self.needPieceNum and self.NEED_TUPOFU and self.curNum >= self.needNum then
        SkyBookManager:requestBibleBreach(self.instanceId)
        return
    end
    --[[
    local layer = AlertManager:addLayerByFile("lua.logic.common.NoticeLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);
    layer:setTitle("突破材料不足")
    local Msg = {
    	"1.xxxxxxxxxxxx",
    	"2.xxxxxxxxxxxxxxxx",
    	"3.xxxxxxxxxxxxxxxxxxx",
    	"4.xxxxxxxxxxxxxxx",
    	"5.xxxxxxxxxxxxx"
	}
	layer:setMsg(Msg)
	layer:setBtnHandle(function() end, function()
    end)
    AlertManager:show()
    ]]
    toastMessage(localizable.Tianshu_tupo_text1)
end

function TianshuTupoLayer.onReturnClickHandle( sender )
	AlertManager:close(AlertManager.TWEEN_NONE)
end

--左边星星界面
function TianshuTupoLayer:onShowLeftInfo()
	--星星
    local tupoLevel = self.item.tupoLevel
    for i = 1, SkyBookManager.kMaxStarLevel do
        self.img_xing[i]:setVisible(true)
        self.img_xing[i].xing:setVisible(false)
    end
    for i = 1, tupoLevel do
        self.img_xing[i].xing:setVisible(true)
    end

	if self.panel_tianshu.img then
		self.panel_tianshu.img:setTexture(self.item:GetTextrue())
	else
		local img_book = TFImage:create(self.item:GetTextrue())
	    img_book:setFlipX(true)
	    img_book:setAnchorPoint(ccp(0.5, 0.5))
	    img_book:setPosition(ccp(200, 200))
	    self.panel_tianshu.img = img_book
		self.panel_tianshu:addChild(img_book)
	end
end

--右边界面
function TianshuTupoLayer:onShowRightInfo()
    print("++++++++ show right ++++++++++")
	local curPieceNum = SkyBookManager:getBiblePieceNumByQuality(self.item.quality)
    local needPieceNum, tab_tupofu = SkyBookManager:getTupoNeedPieceNumByInstance(self.item)
    self.curPieceNum = curPieceNum
    self.needPieceNum = needPieceNum
    
    self.txt_suoxu2:setVisible(true)

    --属性
    local totalAttr = self.item:getTotalAttr()
    local count = 0
    --如果已经到最高级

    --残页图片
    self.img_quality:setTextureNormal(GetColorIconByQuality_82(self.item.quality))
    local template = SkyBookManager:getBiblePieceTemplateByQuality(self.item.quality)
    self.img_equip:setTexture(template:GetPath())

    self.txt_soul_num:setText(curPieceNum)    
    self.txt_soul_num1:setText("/" .. needPieceNum)

    if curPieceNum < needPieceNum then
        self.txt_soul_num:setColor(ccc3(255, 0, 0))
    end
    

    self.panel_tupofu:setVisible(false)

    if tab_tupofu and tab_tupofu.num then
        self.panel_tupofu:setVisible(true)
        local item = ItemData:objectByID(tonumber(tab_tupofu.id))
        local curNum = BagManager:getItemNumById(tonumber(tab_tupofu.id))
        local needNum = tab_tupofu.num
        self.panel_tupofu.img_quality:setTextureNormal(GetColorIconByQuality_82(item.quality))
        self.panel_tupofu.img_equip:setTexture(item:GetPath())

        if curNum < needNum then
            self.panel_tupofu.txt_soul_num:setColor(ccc3(255, 0, 0))
        end
        self.panel_tupofu.txt_soul_num:setText(curNum)
        self.panel_tupofu.txt_soul_num1:setText("/" .. needNum)

        self.NEED_TUPOFU = true
        self.curNum = curNum
        self.needNum = needNum
    end

    local newItem = CardSkyBook:new(self.item.id)
    newItem:setLevel(self.item.level)

    if self.item.tupoLevel < SkyBookManager.kMaxStarLevel then
        newItem:setTupoLevel(self.item.tupoLevel + 1)
    else
        newItem:setTupoLevel(self.item.tupoLevel)
    end

    if self.item.sbStoneId then 
        for k, v in pairs(self.item.sbStoneId) do
            newItem:setStonePos(k, v)
        end           
    end
    newItem:updatePower()
    local newAttr = newItem:getTotalAttr()

    local fac = self.item.breachConfig.factor
    local newFac = newItem.breachConfig.factor

	if SkyBookManager:isInTupoMaxLevel(self.item) == true then
		for i = 1, EnumAttributeType.Max - 1 do
            if totalAttr[i] and totalAttr[i] ~= 0 and count < self.kMaxAttrNum then	 
                count = count + 1  
                --self.img_attr[count].txt_name:setText(AttributeTypeStr[i] .. "成长")
    		self.img_attr[count].txt_name:setText(stringUtils.format(localizable.trainLayer_chengzhang,AttributeTypeStr[i]))
                self.img_attr[count].txt_base:setText(" " .. fac)
                
                --self.img_attr[count].txt_new:setText(newAttr[i])
                self.img_attr[count].txt_new:setText(newFac)
                
                self.img_attr[count]:setVisible(true)
                self.img_attr[count].txt_name:setVisible(true)
                self.img_attr[count].txt_base:setVisible(true)
                self.img_attr[count].img_to:setVisible(false)
    			self.img_attr[count].txt_new:setVisible(false)
            end
		end
		self.btn_tupo:setGrayEnabled(true)
		self.btn_tupo:setTouchEnabled(false)

        self.panel_canye:setVisible(false)
        self.panel_tupofu:setVisible(false)
        self.txt_suoxu2:setVisible(false)

		return
	else
		for i = 1, EnumAttributeType.Max - 1 do
            if totalAttr[i] and totalAttr[i] ~= 0 and count < self.kMaxAttrNum then  
                count = count + 1  
                --self.img_attr[count].txt_name:setText(AttributeTypeStr[i] .. "成长")
                self.img_attr[count].txt_name:setText(stringUtils.format(localizable.trainLayer_chengzhang,AttributeTypeStr[i]))
                --self.img_attr[count].txt_base:setText(totalAttr[i])
                --elf.img_attr[count].txt_new:setText(newAttr[i])
                self.img_attr[count].txt_base:setText("  " .. fac)
                self.img_attr[count].txt_new:setText(newFac)
                
                self.img_attr[count]:setVisible(true)
                self.img_attr[count].txt_name:setVisible(true)
                self.img_attr[count].txt_base:setVisible(true)
                self.img_attr[count].img_to:setVisible(true)
                self.img_attr[count].txt_new:setVisible(true)
            end
        end
		self.btn_tupo:setGrayEnabled(false)
		self.btn_tupo:setTouchEnabled(true)
	end
end

function TianshuTupoLayer:onBibleBreachComplete()
    local layer =  AlertManager:addLayerByFile("lua.logic.tianshu.TianshuStarupLayer", AlertManager.BLOCK_AND_GRAY)
    layer:loadData(self.instanceId,self.oldarr,self.old_power, self.oldFactor)
    layer:setOldValue(self.old_quality, self.old_starlevel)
    AlertManager:show()

    --local item = SkyBookManager:getItemByInstanceId(self.instanceId)
	--self.item = clone(item)
end

return TianshuTupoLayer