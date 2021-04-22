local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetVipClient = class("QUIWidgetVipClient", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QRichText = import("...utils.QRichText")

-- local vipContent = {
--   VIP1 = {"累计充值$10$钻石即可享受以下特权。\n","解锁使用钻石扫荡关卡功能。\n","每天可免费领取扫荡劵$20$张。\n","每天可购买体力$2$次。\n","每天可使用点石成金$5$次。"},
--   VIP2 = {"累计充值$100$钻石即可享受以下特权。\n","包含$VIP1$等级所有特权。\n","解锁购买技能强化点数功能。\n", "解锁要塞狩猎，酿酒，体技之家的中级收获方式。\n","每天可免费领取扫荡劵$30$张。\n","每天可购买体力$3$次。\n","每天可使用点石成金$20$次。\n","每天可重置精英关卡$1$次。"},
--   VIP3 = {"累计充值$300$钻石即可享受以下特权。\n","包含$VIP2$等级所有特权。\n","解锁立即重置斗魂场战斗CD功能。\n","每天可免费领取扫荡劵$40$张。\n","每天可购买体力$4$次。\n","每天可使用点石成金$30$次。\n","每天可重置精英关卡$2$次。\n","每天可购买斗魂场门票$1$次。"},
--   VIP4 = {"累计充值$500$钻石即可享受以下特权。\n","包含$VIP3$等级所有特权。\n","解锁扫荡关卡之一键扫荡$10$次功能。\n", "解锁要塞狩猎，酿酒，体技之家的高级收获方式。\n","每天可免费领取扫荡劵$50$张。\n","每天可购买体力$5$次。\n","每天可使用点石成金$40$次。\n","每天可重置精英关卡$3$次。\n","每天可购买斗魂场门票$2$次。"},
--   VIP5 = {"累计充值$1000$钻石即可享受以下特权。\n","包含$VIP4$等级所有特权。\n","解锁技能点上限增加至$20$点功能。\n", "解锁新的魂兽区，酿酒中的采集格位。\n","每天可免费领取扫荡劵$60$张。\n","每天可购买体力$6$次。\n","每天可使用点石成金$50$次。\n","每天可重置精英关卡$4$次。\n","每天可购买斗魂场门票$3$次。"},
--   VIP6 = {"累计充值$2000$钻石即可享受以下特权。\n","包含$VIP5$等级所有特权。\n", "解锁新的体技之家的采集格位。\n","每天可免费领取扫荡劵$70$张。\n","每天可购买体力$7$次。\n","每天可使用点石成金$60$次。\n","每天可重置精英关卡$5$次。\n","每天可购买斗魂场门票$4$次。"},
--   VIP7 = {"累计充值$3000$钻石即可享受以下特权。\n","包含$VIP6$等级所有特权。\n","每天可免费领取扫荡劵$80$张。\n","每天可购买体力$8$次。\n","每天可使用点石成金$70$次。\n","每天可重置精英关卡$6$次。\n","每天可购买斗魂场门票$5$次。"},
--   VIP8 = {"累计充值$5000$钻石即可享受以下特权。\n","包含$VIP7$等级所有特权。\n","每天可免费领取扫荡劵$90$张。\n","每天可购买体力$9$次。\n","每天可使用点石成金$80$次。\n","每天可重置精英关卡$7$次。\n","每天可购买斗魂场门票$6$次。"},
--   VIP9 = {"累计充值$7000$钻石即可享受以下特权。\n","包含$VIP8$等级所有特权。\n","解锁永久召唤地精商人功能。\n","每天可免费领取扫荡劵$100$张。\n","每天可购买体力$10$次。\n","每天可使用点石成金$90$次。\n","每天可重置精英关卡$8$次。\n","每天可购买斗魂场门票$7$次。"},
--   VIP10 = {"累计充值$10000$钻石即可享受以下特权。\n","包含$VIP9$等级所有特权。\n","解锁每天可重置决战太阳之井$2$次功能。\n","每天可免费领取扫荡劵$110$张。\n","每天可购买体力$11$次。\n","每天可使用点石成金$100$次。\n","每天可重置精英关卡$10$次。\n","每天可购买斗魂场门票$8$次。"},
--   VIP11 = {"累计充值$15000$钻石即可享受以下特权。\n","包含$VIP10$等级所有特权。\n","解锁永久召唤黑市商人功能。\n","解锁酒馆之酒仙召唤功能。\n","每天可免费领取扫荡劵$120$张。\n","每天可购买体力$12$次。\n","每天可使用点石成金$120$次。\n","每天可重置精英关卡$12$次。\n","每天可购买斗魂场门票$9$次。"},
--   VIP12 = {"累计充值$20000$钻石即可享受以下特权。\n","包含$VIP11$等级所有特权。\n","每天可免费领取扫荡劵$130$张。\n","每天可购买体力$13$次。\n","每天可使用点石成金$150$次。\n","每天可重置精英关卡$15$次。\n","每天可购买斗魂场门票$10$次。"},
--   VIP13 = {"累计充值$40000$钻石即可享受以下特权。\n","包含$VIP12$等级所有特权。\n","解锁决战太阳之井宝箱中金魂币奖励增加$50%$功能。\n","每天可免费领取扫荡劵$140$张。\n","每天可购买体力$14$次。\n","每天可使用点石成金$200$次。\n","每天可重置精英关卡$18$次。\n","每天可购买斗魂场门票$11$次。"},
--   VIP14 = {"累计充值$80000$钻石即可享受以下特权。\n","包含$VIP13$等级所有特权。\n","每天可免费领取扫荡劵$150$张。\n","每天可购买体力$15$次。\n","每天可使用点石成金$250$次。\n","每天可重置精英关卡$21$次。\n","每天可购买斗魂场门票$12$次。"},
--   VIP15 = {"累计充值$150000$钻石即可享受以下特权。\n","包含$VIP14$等级所有特权。\n","每天可免费领取扫荡劵$160$张。\n","每天可购买体力$16$次。\n","每天可使用点石成金$300$次。\n","每天可重置精英关卡$25$次。\n","每天可购买斗魂场门票$13$次。"},
-- }

function QUIWidgetVipClient:ctor(options)
    local ccbFile = "ccb/Widget_Vip.ccbi"
    local callBacks = {}
    QUIWidgetVipClient.super.ctor(self, ccbFile, callBacks, options)

    self.lineHeight = 24
    self.rowSpace = 10
    self.rowNums = 0

    if options ~= nil then
        self.vipLevel = options.vip
    end
end

function QUIWidgetVipClient:setVipContent(vip)
    local vipContent = QStaticDatabase:sharedDatabase():getVIP()
    self._vipDescriptions = {}
    for i = 0, QVIPUtil:getMaxLevel(), 1 do
        local description = string.split(vipContent[tostring(i)].description, "\r\n")
        table.insert(self._vipDescriptions, description)
    end
    self._ccbOwner.content_node:removeAllChildren()
    
    self._totalHeight = 0
    if self._vipDescriptions[vip + 1] ~= nil then
        self:setMoreColorLabel(self._vipDescriptions[vip + 1][1])
    end

end

function QUIWidgetVipClient:setMoreColorLabel(str)
    local strArrs = string.split(str, "\n")

    local height = 0
    local strs = ""
    local lineNum = 0
    local textSize = 22
    local lineHeight = 40
    local newOffsetY = 10

    for _, value in ipairs(strArrs) do
        local data = string.split(value, "^")
        local strTable = {}
        local text = QRichText.new(nil, 450, {stringType = 1, size = textSize, defaultColor = ccc3(134,85,55), lineSpacing = 10})
        text:setAnchorPoint(ccp(0, 0))
        strTable = text:parseString2(data[2])
        if tonumber(data[1]) == 1 then
            table.insert(strTable, {oType = "img", fileName = QResPath("vip_new_icon"), skewX = 0, scale = 0.65})
        end
        text:setString(strTable)
        local textHeight = text:getContentSize().height
        height = height + textHeight + newOffsetY
        text:setPosition(30, -height)
        self._ccbOwner.content_node:addChild(text)
        lineNum = lineNum + math.floor(textHeight/textSize)

        local ttf = CCLabelTTF:create("◆ ", global.font_default, 22)
        ttf:setPosition(15, -height+textHeight-13)
        ttf:setColor(ccc3(199, 146, 95))
        self._ccbOwner.content_node:addChild(ttf)

        lineHeight = textHeight + newOffsetY
    end

    for i = 1, lineNum do        
        local line = CCSprite:create(QResPath("vip_line"))
        line:setPosition(line:getContentSize().width/2, -lineHeight*i)
        self._ccbOwner.content_node:addChild(line)
    end
    
    self._totalHeight = height
end

function QUIWidgetVipClient:getContentSize()
    return CCSize(0, self._totalHeight)
end

return QUIWidgetVipClient
