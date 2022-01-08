--[[
******装备洗炼*******

	-- by david.dai
	-- 2014/4/19
]]

local EquipPractice = class("EquipPractice", BaseLayer)


function EquipPractice:ctor(gmId)
    self.super.ctor(self,data)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.EquipPractice")
end

function EquipPractice:initUI(ui)
	self.super.initUI(self,ui)

    --左侧详情
    self.scroll_left            = TFDirector:getChildByPath(ui, 'scroll_left')
    self.info_panel             = require('lua.logic.smithy.EquipInfoPanel'):new(self.gmId)
    self.scroll_left:addChild(self.info_panel)

    self.scroll_right           = TFDirector:getChildByPath(ui, 'scroll_right')
    self.img_bg           = TFDirector:getChildByPath(ui, 'img_bg')
    self.panel_content           = TFDirector:getChildByPath(ui, 'panel_content')
    
    self.panel_shuxing  = {}
    self.txt_attr_num   = {}
    self.bar_percent_bg = {}
    self.bar_percent    = {}
    self.check_attr     = {}
    self.img_shuxing    = {}
    self.txt_cost       = {}
    self.txt_change       = {}
    self.txt_tuppStep       = {}

    self.lockConsume = ConstantData:objectByID("Equip.Remake.Extra.Lock.Consume")

    for i=1,EquipmentManager.kMaxExtraAttributeSize do
        local str = "panel_shuxing" .. i
        self.panel_shuxing[i] = TFDirector:getChildByPath(ui, str)
        self.img_shuxing[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_shuxing" .. i)
        self.txt_attr_num[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_attr_val")
        self.bar_percent_bg[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "img_jindutiaobj")
        self.bar_percent[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "bar_percent")
        self.check_attr[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "check_attr")
        self.txt_cost[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_cost")
        self.txt_change[i] = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_change")
        self.txt_cost[i]:setText(self.lockConsume.value)
        self.check_attr[i].tag = i
        self.check_attr[i].logic = self


        self.txt_tuppStep[i]       = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_tupostep")
    end

    self.btn_practice   = TFDirector:getChildByPath(ui, 'btn_practice')
    self.btn_practice.logic = self

    self.txt_refin_stone_num = TFDirector:getChildByPath(ui, 'txt_refin_stone_num')

    self.lockList = {}

    self.img_notice         = TFDirector:getChildByPath(ui, 'img_notice')

end

function EquipPractice:onShow()
    self.super.onShow(self)
    self:refreshUI()
    self.info_panel:onShow()
end

function EquipPractice:dispose()
    self.info_panel:dispose()
    self.super.dispose(self)
end

function EquipPractice:refreshUI()
    
    self.info_panel:setEquipGmId(self.gmId)
    self:refreshExtraAttribute()
    self:refreshConsumeGoodsRemaining()
end

function EquipPractice:removeUI()
    self.super.removeUI(self)
end

function EquipPractice:setEquipGmId(gmId)
    self.gmId = gmId
    self.lockList = {}
    self:refreshUI()
end

-- function EquipPractice:refreshExtraAttribute()
--     local equip = EquipmentManager:getEquipByGmid(self.gmId)
--     if equip == nil  then
--         print("equipment not found .",self.gmId)
--         return false
--     end

--     local attribute,indexTable = equip:getExtraAttribute():getAttribute()
--     local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
--     if equipmentTemplate == nil then
--         print("没有此类装备模板信息")
--         return
--     end

--     if equip.quality < 2 then
--         self:setRefinEnabled(false)
--         return
--     end

--     self:setRefinEnabled(true)

--     local refineLevel = equip.refineLevel
--     print("EquipPractice refineLevel = ", refineLevel)
--     local min_attribute, max_attribute, extra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel)
--     -- local LastStepValue_min , LastStepValue_max, Lastextra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel-1)


--     print("attribute = ",attribute)
--     print("min_attribute = ",min_attribute)
--     -- print("extra_interval_max = ",extra_interval_max)
--     -- print("Lastextra_interval_max = ",Lastextra_interval_max)

--     local max_tupo_level = EquipRefineBreachData:length()
--     if refineLevel < max_tupo_level then
--         refineLevel = refineLevel + 1
--     end


--     local index = 1

--     for k,i in pairs(indexTable) do
--         self.panel_shuxing[index]:setVisible(true)
--         self.txt_change[index]:setVisible(false)

--         local attrTitle = AttributeTypeStr[i] or "未知"
--         self.img_shuxing[index]:setText(attrTitle)
--         local curAttr = attribute[i] or 0
--         local minAttr = min_attribute[i] or 0
--         local fuckAttri = curAttr - minAttr
--         if i >= EnumAttributeType.CritPercent then
--             -- self.txt_attr_num[index]:setText("+"..(attribute[i]/100).."%")
--             self.txt_attr_num[index]:setText("+"..(fuckAttri/100).."%")
--         else
--             -- self.txt_attr_num[index]:setText("+"..attribute[i])
--             self.txt_attr_num[index]:setText("+"..fuckAttri)
--         end

--         local stepIdex,stepNum = equipmentTemplate:getExtraAttributeIndex(i, fuckAttri)
--         if stepIdex < 1 then
--             stepIdex = 1
--         end
--         print("stepIdex = ", stepIdex)
--         -- print("stepNum = ", stepNum)


--         self.txt_tuppStep[index]:setText((stepIdex-1).."/"..refineLevel)

--         -- 绘制进度条
--         local bgPath = "ui_new/equipment/tjp_jindutiaodi_icon.png"
--         local bgIndex = stepIdex-1
--         if bgIndex <= 0 then
--             bgIndex = 0
--         else
--             bgIndex = math.mod(bgIndex, 5)
--             if bgIndex == 0 then
--                 bgIndex = 5
--             end
--             bgPath = "ui_new/equipment/tjp_jindutiao"..bgIndex.."_icon.png"
--         end

--         self.bar_percent_bg[index]:setTexture(bgPath)

--         bgIndex = math.mod(stepIdex, 5)
--         if bgIndex == 0 then
--             bgIndex = 5
--         end

--         bgPath = "ui_new/equipment/tjp_jindutiao"..bgIndex.."_icon.png"
--         self.bar_percent[index]:setTexture(bgPath)
        
--         -- if min_attribute[i] and max_attribute[i] then
--         --     local diffMax = max_attribute[i] - min_attribute[i]
--         --     local diff = attribute[i] - min_attribute[i]
--         --     local percent = math.ceil(diff*100/diffMax)
--         --     --self.txt_attr_percent[index]:setText(percent.."%")
--         --     -- print("percent",percent)
--         --     self.bar_percent[index]:setPercent(percent)

--         --     print("value1 = "..diff.."  value2 = "..diffMax)
--         -- end
--         local lastStepTupoIndex = stepIdex-1
--         if lastStepTupoIndex < 1 then
--             lastStepTupoIndex = -1
--         end

--         local LastStepValue_min , LastStepValue_max, Lastextra_interval_max = equipmentTemplate:getExtraAttribute(lastStepTupoIndex)
 
--         print("Lastextra_interval_max = ",Lastextra_interval_max)

--         Lastextra_interval_max[i] = Lastextra_interval_max[i] or 0
--         if min_attribute[i] and max_attribute[i] and LastStepValue_min[i] and extra_interval_max[i] and Lastextra_interval_max[i] then

--             local diffMax = extra_interval_max[i] - Lastextra_interval_max[i]
--             local diff = fuckAttri - Lastextra_interval_max[i] --attribute[i] - min_attribute[i]
--             local percent = math.ceil(diff*100/diffMax)
--             --self.txt_attr_percent[index]:setText(percent.."%")
--             -- print("percent",percent)
--             self.bar_percent[index]:setPercent(percent)
            
--             print("---------------"..i)
--             print("fuckAttri = "..fuckAttri.."  Lastextra_interval_max[i] = "..Lastextra_interval_max[i])
--             print("value1 = "..diff.."  value2 = "..diffMax)
--         end

--         self.check_attr[index].attr_index = i
--         if self.lockList and self.lockList[i] then
--             self.check_attr[index]:setSelectedState(true)
--         else
--             self.check_attr[index]:setSelectedState(false)
--         end
--         index = index + 1
--     end

--     if index < 1 then
--         self:setRefinEnabled(false)
--     else
--         self:setRefinEnabled(true)
--         self.btn_practice:setGrayEnabled(false)
--         self.btn_practice:setTouchEnabled(true)
--     end

--     while  index <= 3 do
--         self.panel_shuxing[index]:setVisible(false)
--         index = index+1
--     end

-- end

function EquipPractice:refreshExtraAttribute()
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    local attribute,indexTable = equip:getExtraAttribute():getAttribute()
    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    if equipmentTemplate == nil then
        print("没有此类装备模板信息")
        return
    end

    if equip.quality <= 2 then
        self:setRefinEnabled(false)
        return
    end
    self:setRefinEnabled(true)


    local refineLevel = equip.refineLevel
    print("EquipPractice refineLevel = ", refineLevel)
    local min_attribute, max_attribute, extra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel)
    -- local LastStepValue_min , LastStepValue_max, Lastextra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel-1)


    print("attribute = ",attribute)
    print("min_attribute = ",min_attribute)
    print("extra_interval_max = ",extra_interval_max)
    -- print("Lastextra_interval_max = ",Lastextra_interval_max)

    local max_tupo_level = EquipRefineBreachData:length()
    if refineLevel < max_tupo_level then
        refineLevel = refineLevel + 1
    end

    local recastPercent = equip:getRecastPercent()
    local index = 1
    print("recastPercent = ", recastPercent)
    for k,i in pairs(indexTable) do
        self.panel_shuxing[index]:setVisible(true)
        self.txt_change[index]:setVisible(false)

        local attrTitle = AttributeTypeStr[i] or localizable.common_not_know
        self.img_shuxing[index]:setText(attrTitle)
        local curAttr = attribute[i] or 0
        -- curAttr = math.floor(curAttr/((100+recastPercent)/100))

        local minAttr = min_attribute[i] or 0
        local fuckAttri = curAttr - minAttr

        print("minAttr = ", minAttr)
        print("curAttr = ", curAttr)

        if i >= EnumAttributeType.CritPercent then
            self.txt_attr_num[index]:setText("+"..(fuckAttri/100).."%")
        else
            self.txt_attr_num[index]:setText("+"..fuckAttri)
        end

        local stepIdex,stepNum = equipmentTemplate:getExtraAttributeIndex(i, fuckAttri)

        print("当前属性的突破进度 = ", stepIdex)

        -- 绘制进度条
        local bgPath        = "ui_new/equipment/tjp_jindutiaodi_icon.png"
        local processPath   = "ui_new/equipment/tjp_jindutiao1_icon.png"
        -- stepIdex == 0
        if stepIdex == 0 then
            -- print("stepIdex")
        else
            -- print("stepIdex = "..stepIdex)
            local bgIndex       = stepIdex
            local processIndex  = stepIdex+1
            print("1111111bgIndex =>"..bgIndex.."       processIndex=>"..processIndex)
            bgIndex = math.mod(bgIndex, 5)
            if bgIndex == 0 then
                bgIndex = 5
            end
            bgPath = "ui_new/equipment/tjp_jindutiao"..bgIndex.."_icon.png"

            processIndex = math.mod(processIndex, 5)
            if processIndex == 0 then
                processIndex = 5
            end
            processPath = "ui_new/equipment/tjp_jindutiao"..processIndex.."_icon.png"


            print("222222bgIndex =>"..bgIndex.."       processIndex=>"..processIndex)
        end

        self.bar_percent_bg[index]:setTexture(bgPath)
        self.bar_percent[index]:setTexture(processPath)

        if stepIdex == 0 then
            self.txt_tuppStep[index]:setText("0/"..refineLevel)
        else
            self.txt_tuppStep[index]:setText((stepIdex).."/"..refineLevel)
        end

                -- 上一个突破等级
        local lastStepTupoIndex = 0
        -- 新装备
        if stepIdex == 0 then
            stepIdex = 0
            lastStepTupoIndex = -1

        -- elseif  stepIdex == 1 then
        --     stepIdex = 0
        --     lastStepTupoIndex = -1
        else
            stepIdex = stepIdex
            lastStepTupoIndex = stepIdex-1
        end


        local LastStepValue_min1 , LastStepValue_max1, Lastextra_interval_max1 = equipmentTemplate:getExtraAttribute(stepIdex)
        local LastStepValue_min2 , LastStepValue_max2, Lastextra_interval_max2 = equipmentTemplate:getExtraAttribute(lastStepTupoIndex)
        
        print('1111stepIdex = ',stepIdex)
        print('22222stepIdex = ',lastStepTupoIndex)
        print("Lastextra_interval_max1 = ",Lastextra_interval_max1)
        print("Lastextra_interval_max2 = ",Lastextra_interval_max2)

        Lastextra_interval_max1[i] = Lastextra_interval_max1[i] or 0
        Lastextra_interval_max2[i] = Lastextra_interval_max2[i] or 0

        if Lastextra_interval_max1[i] and Lastextra_interval_max2[i] then

            local diffMax = Lastextra_interval_max1[i] - Lastextra_interval_max2[i]
            local diff = fuckAttri - Lastextra_interval_max2[i]
            local percent = math.ceil(diff*100/diffMax)

            print("percent",percent)
            self.bar_percent[index]:setPercent(percent)
            
            print("---------------"..i)
            print("fuckAttri = "..fuckAttri.."  Lastextra_interval_max2[i] = "..Lastextra_interval_max2[i])
            print("value1 = "..diff.."  value2 = "..diffMax)
        end

        self.check_attr[index].attr_index = i
        if self.lockList and self.lockList[i] then
            self.check_attr[index]:setSelectedState(true)
        else
            self.check_attr[index]:setSelectedState(false)
        end
        index = index + 1
    end

    if index < 1 then
        self:setRefinEnabled(false)
    else
        self:setRefinEnabled(true)
        self.btn_practice:setGrayEnabled(false)
        self.btn_practice:setTouchEnabled(true)
    end

    while  index <= EquipmentManager.kMaxExtraAttributeSize do
        self.panel_shuxing[index]:setVisible(false)
        index = index+1
    end

end

--[[
设置是否可以洗炼
]]
function EquipPractice:setRefinEnabled(enabled)
    --for i=1,3 do
    --    self.panel_shuxing[i]:setVisible(enabled)
    --end
    --self.btn_practice:setGrayEnabled(not enabled)
    --self.btn_practice:setTouchEnabled(enabled)
    self.img_notice:setVisible(not enabled)
    self.scroll_right:setVisible(enabled)
end

--打开商城界面
function EquipPractice:showMallLayer()
    CommonManager:showOperateSureLayer(
        function()
            MallManager:openGiftsShop()
        end,
        nil,
        {
            --msg = "您没有足够的道具[洗炼石]，是否打开商城界面进行购买？",
            msg = localizable.smithy_EquipPractice_store_tips,
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end

function EquipPractice.PracticeClickHandle(sender)
    local self = sender.logic
    -- local stoneNumber = tonumber(self.txt_refin_stone_num:getText())
    local stoneNumber = self.practiceStone
    if stoneNumber < 1 then
        -- self:showMallLayer()
        --toastMessage("洗炼石不足")
        toastMessage(localizable.smithy_EquipPractice_not_store)
        return
    end

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    
    local lockArray = {}
    local index = 1
    for k,v in pairs(self.lockList) do
        lockArray[index] = k - 1
        index = index + 1 
    end
    -- if #lockArray >= (equip.quality - 1)  then
    --    toastMessage("所有属性都已上锁")
    --    return
    -- end
    -- local refineLevel   = equip.refineLevel

    local attribute = equip:getExtraAttribute():getAttribute()
    local attrSize = 0

    for k,v in pairs(attribute) do
        attrSize = attrSize + 1

    end

    if #lockArray >= attrSize  then
       --toastMessage("所有属性都已上锁")
       toastMessage(localizable.smithy_EquipPractice_all)
       return
    end
    -- -- EquipmentManager:EquipPractice(self.gmId , lockArray)
    print("self.lockConsume = ", self.lockConsume)
    local numOfLock = #lockArray
    local lockConsume = self.lockConsume
    if numOfLock > 0 then
        local cost = numOfLock * lockConsume.value
        --local warningMsg = "大侠，锁定属性将花费您"..cost.."元宝，是否确认洗炼?"
        local warningMsg = stringUtils.format(localizable.smithy_EquipPractice_ok_tips,cost)
        CommonManager:showOperateSureLayer(
                function()
                    EquipmentManager:EquipPractice(self.gmId , lockArray)
                end,
                nil,
                {
                    msg = warningMsg
                }
        )
    else
        -- EquipmentManager:EquipPractice(self.gmId , lockArray)
        --local warningMsg = "洗练将会随机更换装备附加属性，是否开始洗练？"
        local warningMsg = localizable.smithy_EquipPractice_tips1
        CommonManager:showOperateSureLayer(
            function()
                EquipmentManager:EquipPractice(self.gmId , lockArray)
            end,
            nil,
            {
                msg = warningMsg
            }
        )
    end


end

--显示充值提示框
function EquipPractice:showRechargeDialog()
    CommonManager:showOperateSureLayer(
        function()
            PayManager:showPayLayer()
        end,
        nil,
        {
            --msg = "您没有足够的元宝购买物品，是否进入充值界面？",
            msg = localizable.common_pay_tips_1,
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end

function EquipPractice.CheckClickHandle(sender)
	local self = sender.logic
    local tag = sender.tag

    -- self.check_attr[tag]:setSelectedState(false)
    -- do return end 

    --检验是否有足够的元宝来进行锁定属性，不足时提示冲值
    local lockConsume = self.lockConsume
    local totalConsume = 0
    for k,v in pairs(self.lockList) do
        totalConsume = totalConsume + lockConsume.value
    end
    totalConsume = totalConsume + lockConsume.value

    local needResType   = lockConsume.res_type
    local num           = totalConsume

        -- 判断资源是否足够刷新
    if needResType == EnumDropType.COIN then 
        if MainPlayer:isEnoughCoin(num, true) then
            self.lockList[sender.attr_index] = true
            play_linglianshangsuo()
        end
    end

    if needResType == EnumDropType.SYCEE then 
        if MainPlayer:isEnoughSycee(num, true) then
            self.lockList[sender.attr_index] = true
            play_linglianshangsuo()
        end
    end

    -- local enough = MainPlayer:isEnough(lockConsume.res_type,totalConsume)
    -- if not enough then
    --     --self:showRechargeDialog()
    --     self.check_attr[tag]:setSelectedState(false)
    --     return
    -- end
    
    -- self.lockList[sender.attr_index] = true
    -- play_linglianshangsuo()
end

function EquipPractice.UnCheckClickHandle(sender)
    local self = sender.logic
    local tag = sender.tag

    if self.lockList[sender.attr_index] then
        self.lockList[sender.attr_index] = nil
    end
    play_linglianshangsuo()
end

function EquipPractice:refreshConsumeGoodsRemaining()
    self.practiceStone = 0
    local consumeGoods = EquipmentManager:getPracticeStone()
    local holdGoods = EquipmentManager:getHoldPracticeStone()
    if holdGoods ~=nil then
        --self.txt_refin_stone_num:setText("(拥有 ".. holdGoods.num ..")")
        self.txt_refin_stone_num:setText(stringUtils.format(localizable.changetProLayer_have, holdGoods.num))
        self.practiceStone = holdGoods.num
    else
        --self.txt_refin_stone_num:setText("(拥有 ".. 0 ..")")
        self.txt_refin_stone_num:setText(stringUtils.format(localizable.changetProLayer_have, 0))
    end


end

function EquipPractice:showRefiningEffect(notice_data )
    if notice_data.gmId ~= self.gmId then
        return
    end
    local change_attr = notice_data.change_attr
    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    local attribute,indexTable = equip:getExtraAttribute():getAttribute()

    local index = 1
    for k,i in pairs(indexTable) do
        local attrTitle = AttributeTypeStr[i] or localizable.common_not_know
        if i >= EnumAttributeType.CritPercent then
            if change_attr[i] > 0 then
                self.txt_change[index]:setText("+"..(change_attr[i]/100).."%")
                self.txt_change[index]:setFntFile("font/num_219.fnt")
                self:refiningNumEffect(self.txt_change[index])
                -- self.txt_change[index]:setVisible(true)
            elseif change_attr[i] < 0 then
                self.txt_change[index]:setText((change_attr[i]/100).."%")
                self.txt_change[index]:setFntFile("font/num_218.fnt")
                self:refiningNumEffect(self.txt_change[index])
                -- self.txt_change[index]:setVisible(true)
            end
        else
            if change_attr[i] > 0 then
                self.txt_change[index]:setText("+"..change_attr[i])
                self.txt_change[index]:setFntFile("font/num_219.fnt")
                self:refiningNumEffect(self.txt_change[index])
                -- self.txt_change[index]:setVisible(true)
            elseif change_attr[i] < 0 then
                self.txt_change[index]:setText(change_attr[i])
                self.txt_change[index]:setFntFile("font/num_218.fnt")
                self:refiningNumEffect(self.txt_change[index])
                -- self.txt_change[index]:setVisible(true)
            end
        end
        -- self:refiningNumEffect(self.txt_change[index])
        index = index + 1
    end

    if self.equipEffect == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equipment_pratice.xml")
        local effect = TFArmature:create("equipment_pratice_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        self.panel_content:addChild(effect)
        effect:setPosition(ccp(465,300))
        effect:setZOrder(10)
        self.equipEffect = effect
    end
    self.equipEffect:playByIndex(0, -1, -1, 0)

end



function EquipPractice:refiningNumEffect(widget )
    TFDirector:killAllTween(widget)
    widget:setVisible(true)
    widget:setScale(0.1)
    local tween = {
        target = widget,
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0.1,
                scale = 0.8,
            },
            {
                duration = 0.1,
                scale = 1,
            },
            {
                duration = 0,
                delay = 1,
                onComplete = function ()
                    widget:setVisible(false)
                end,
            },
    }
    TFDirector:toTween(tween)

end
function EquipPractice:registerEvents()
	self.super.registerEvents(self)

    self.btn_practice:addMEListener(TFWIDGET_CLICK, audioClickfun(self.PracticeClickHandle),1)

    for i = 1,EquipmentManager.kMaxExtraAttributeSize do
       self.check_attr[i]:addMEListener(TFWIDGET_CHECKBOXSELECT, self.CheckClickHandle)
	   self.check_attr[i]:addMEListener(TFWIDGET_CHECKBOXUNSELECT, self.UnCheckClickHandle)
    end

     self.EquipPracticeResultCallBack = function (event)
        play_jinglian()
        self:refreshUI()
        self:showRefiningEffect(event.data[1])
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_PRACTICE_RESULT,self.EquipPracticeResultCallBack)

    --新增物品监听
    self.itemAddCallBack = function (event)
        local consumeGoods = EquipmentManager:getPracticeStone()
        if event.data[1] and event.data[1].itemdata.id == consumeGoods.id then
            self:refreshConsumeGoodsRemaining()
        end
    end
    self.itemNumChangedCallBack = function (event)
        local consumeGoods = EquipmentManager:getPracticeStone()
        if event.data[1].item and event.data[1].item.itemdata.id == consumeGoods.id then
            self:refreshConsumeGoodsRemaining()
        end
    end
    self.itemDeleteCallBack = function (event)
        local consumeGoods = EquipmentManager:getPracticeStone()
        if event.data[1] and event.data[1].itemdata.id == consumeGoods.id then
            self:refreshConsumeGoodsRemaining()
        end
    end
    TFDirector:addMEGlobalListener(BagManager.ItemAdd,self.itemAddCallBack)
    TFDirector:addMEGlobalListener(BagManager.ItemChange,self.itemNumChangedCallBack)
    TFDirector:addMEGlobalListener(BagManager.ItemDel,self.itemDeleteCallBack)



end

function EquipPractice:removeEvents()
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_PRACTICE_RESULT,self.EquipPracticeResultCallBack)
    TFDirector:removeMEGlobalListener(BagManager.ItemAdd)
    TFDirector:removeMEGlobalListener(BagManager.ItemChange)
    TFDirector:removeMEGlobalListener(BagManager.ItemDel)
    self.super.removeEvents(self)
end

return EquipPractice
