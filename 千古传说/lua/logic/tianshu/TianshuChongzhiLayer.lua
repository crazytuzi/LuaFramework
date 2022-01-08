--[[
  天书重置
]]
local TianshuChongzhiLayer = class("TianshuChongzhiLayer", BaseLayer)

function TianshuChongzhiLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.tianshu.TianShuChongZhi")
end

function TianshuChongzhiLayer:initUI(ui)
    self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")
    self.txt_des = TFDirector:getChildByPath(ui, "txt_des")
    self.btn_ok = TFDirector:getChildByPath(ui, "btn_ok")
    self.btn_cancel = TFDirector:getChildByPath(ui, "btn_cancel")
    self.txt_price = TFDirector:getChildByPath(ui, "txt_price")
    self.panel_txt = TFDirector:getChildByPath(ui, "panel_txt")

    self.btn_close.logic = self
    self.btn_ok.logic = self
    self.btn_cancel.logic = self
end

function TianshuChongzhiLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function TianshuChongzhiLayer:loadData(data)
    self.instanceId = data
    self:refreshUI()
end

function TianshuChongzhiLayer:refreshBaseUI()

end

function TianshuChongzhiLayer:refreshUI()
    if not self.isShow then
        return
    end

    self.item = SkyBookManager:getItemByInstanceId(self.instanceId)
    local name = self.item:getConfigName()

    --local yueliCost = self:calculateNeed()  
    local yueliCost = SkyBookManager:calculateChongzhiGetYueli(self.item) 
     
    self.txt_des:setText("")
    local size = self.panel_txt:getContentSize()
    self.richtext = TFRichText:create(CCSizeMake(400,120))
    self.richtext:setFontSize(22)
    self.richtext:setPosition(ccp(self.txt_des:getPosition().x, self.txt_des:getPosition().y + 30))
    self.txt_des:addChild(self.richtext)

    --local desc1 = "  1.天书变为一重<br/>  2.返还阅历"
    local desc1 = localizable.Tianshu_chongzhi_tips1
    local desc2 = yueliCost
    --local desc3 = "点<br/>"
    local desc3 = localizable.Tianshu_chongzhi_tips2
    --local desc4 = "  3.返还所有精要<br/>"
    local desc4 = localizable.Tianshu_chongzhi_tips3
    --local desc5 = "是否重置&lt;&lt;"
    local desc5 = localizable.Tianshu_chongzhi_tips4
    local desc6 = GetColorStringByQuality(self.item.quality)
    local desc7 = name
    local desc8 = "&gt;&gt;？"
	local desc9 = localizable.Tianshu_chongzhi_tips5
  
    local str = {}
    str[1] = [[<p style="text-align:left; margin:3px"><br/><br/><font face = "simhei" color="#3d3d3d" fontSize="22">%s</font><font face = "simhei" color="#008030" fontSize="22">%s</font>]]
    str[2] = [[<font face = "simhei" color="#3d3d3d" fontSize="22">%s</font>]]
    str[3] = [[<font face = "simhei" color="#3d3d3d" fontSize="22">%s</font>]]
    str[4] = [[<font face = "simhei" color="#3d3d3d" fontSize="22">%s</font>]]
	str[5] = [[<font face = "simhei" color="#3d3d3d" fontSize="22">%s</font>]]
    str[6] = [[<font face = "simhei" color="]] .. desc6 .. [["fontSize="22">%s</font>]] 
    str[7] = [[<font face = "simhei" color="#3d3d3d" fontSize="22">%s</font></p>]]

    local strFormat = table.concat(str)
    
    local notifyStr = ""
    notifyStr = string.format(strFormat, desc1, desc2, desc3, desc4, desc9, desc5, desc7, desc8)
    self.richtext:setText(notifyStr)   

    local num = SkyBookManager:getCongzhifuNumByQality(self.item.quality)
    if num then
      self.txt_price:setText(num)
    end
end

function TianshuChongzhiLayer:calculateCost()

end

function TianshuChongzhiLayer:calculateNeed()
    local need = 0
    local bibleConfig = BibleData:getBibleInfoByIdAndLevel(self.item.id, self.item.level)
    local moasicStr = bibleConfig.mosaic
    local tab = string.split(moasicStr, "|")
    for i = 1, self.item.maxStoneNum do
        if self.item:getStonePos(i) and self.item:getStonePos(i) > 0 then
            local tab1 = string.split(tab[i], ",")
            local str = tab1[1]
            local tab2 = string.split(str, "_")
            if tonumber(tab2[1]) == EnumDropType.YUELI then
                need = need + tonumber(tab2[3])
            end
        end
    end
    if self.item.level <= 1 then
        return need
    end
    for i = self.item.level - 1, 1, -1 do
        local config = BibleData:getBibleInfoByIdAndLevel(self.item.id, i)
        moasicStr = config.mosaic
        tab = string.split(moasicStr, "|")
        for j = 1, #tab do
            local tab1 = string.split(tab[j], ",")
            local str = tab1[1]
            local tab2 = string.split(str, "_")
            if tonumber(tab2[1]) == EnumDropType.YUELI then
                need = need + tonumber(tab2[3])
            end
        end
    end

    return need
end

function TianshuChongzhiLayer:removeUI()
    self.super.removeUI(self)
end

function TianshuChongzhiLayer.onChongzhiClickHandle(sender)
    local self = sender.logic

    --如果为第一重且未镶嵌任何精要,则不能重置
    local status = 0
    for i = 1, self.item.maxStoneNum do
        if self.item:getStonePos(i) and self.item:getStonePos(i) > 0 then
            status = 1
        end
    end
    if self.item.level == 1 and status == 0 then
        --toastMessage("请至少镶嵌一颗精要")
        toastMessage(localizable.Tianshu_chongzhi_text2)
        return
    end

    --判断天书重置符是否足够
    local needNum = SkyBookManager:getCongzhifuNumByQality(self.item.quality)
    local curNum = SkyBookManager:getCurChongzhifuNum()
    if curNum and curNum < needNum then
        --toastMessage("天书重置符数量不够")
        toastMessage(localizable.Tianshu_chongzhi_text3)
        return    
    end

    print("=========== before chongzhi, num = ", curNum)
    SkyBookManager:requestBibleReset(self.instanceId)
    AlertManager:closeLayer(self)
end

--注册事件
function TianshuChongzhiLayer:registerEvents()
   self.super.registerEvents(self)

   ADD_ALERT_CLOSE_LISTENER(self, self.btn_close)
   ADD_ALERT_CLOSE_LISTENER(self, self.btn_cancel)

   self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChongzhiClickHandle), 1)
end

function TianshuChongzhiLayer:removeEvents()
    self.super.removeEvents(self)
end

return TianshuChongzhiLayer