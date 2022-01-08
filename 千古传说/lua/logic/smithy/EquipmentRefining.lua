--[[
******装备洗炼*******

	-- by david.dai
	-- 2014/4/19
]]

local EquipmentRefining = class("EquipmentRefining", BaseLayer)


function EquipmentRefining:ctor(gmId)
    self.super.ctor(self,data)
    self.gmId = gmId
    self:init("lua.uiconfig_mango_new.smithy.EquipmentRefining")
end

function EquipmentRefining:initUI(ui)
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

    self.lockConsume = ConstantData:objectByID("Equip.Refining.Lock.Consume")
    self.lockVip = ConstantData:objectByID("yijianjinglian.Vip.Level")

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
        self.txt_change[i]:setVisible(false)

        self.txt_tuppStep[i]       = TFDirector:getChildByPath(self.panel_shuxing[i], "txt_tupostep")
    end

    self.btn_refining   = TFDirector:getChildByPath(ui, 'btn_refining')
    self.btn_refining.logic = self

    self.txt_refin_stone_num = TFDirector:getChildByPath(ui, 'txt_refin_stone_num')

    self.lockList = {}

    self.img_notice         = TFDirector:getChildByPath(ui, 'img_notice')

    -- 突破相关
    self.txt_tupoDesc   = TFDirector:getChildByPath(ui, 'txt_tupodesc')
    self.btn_tupo       = TFDirector:getChildByPath(ui, 'btn_tupo')
    self.txt_tupo_cost  = TFDirector:getChildByPath(ui, 'txt_tupo_cost')
    self.txt_tupo_num   = TFDirector:getChildByPath(ui, 'txt_tupo_num')
    self.img_tupodi     = TFDirector:getChildByPath(ui, 'img_tupodi')
    self.itemTupoId     = 0
    self.btn_refining2     = TFDirector:getChildByPath(ui, 'btn_refining2')
    self.btn_refining2.logic = self
end

function EquipmentRefining:onShow()
    self.super.onShow(self)
    self.info_panel:onShow()
    self:refreshUI()
end

function EquipmentRefining:dispose()
    self.info_panel:dispose()
    self.super.dispose(self)
end

function EquipmentRefining:refreshUI()
    
    self.info_panel:setEquipGmId(self.gmId)
    self:refreshExtraAttribute()
    self:refreshConsumeGoodsRemaining()
    self:refrshTupoArea()
end

function EquipmentRefining:removeUI()
    self.super.removeUI(self)
end

function EquipmentRefining:setEquipGmId(gmId)
    self.gmId = gmId
    self.lockList = {}
    self:refreshUI()
end

-- function EquipmentRefining:refreshExtraAttribute()
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
--     print("EquipmentRefining refineLevel = ", refineLevel)
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
--         self.btn_refining:setGrayEnabled(false)
--         self.btn_refining:setTouchEnabled(true)
--     end

--     while  index <= 3 do
--         self.panel_shuxing[index]:setVisible(false)
--         index = index+1
--     end

-- end

function EquipmentRefining:refreshExtraAttribute()
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
    -- print("EquipmentRefining refineLevel = ", refineLevel)
    local min_attribute, max_attribute, extra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel)
    -- local LastStepValue_min , LastStepValue_max, Lastextra_interval_max = equipmentTemplate:getExtraAttribute(refineLevel-1)


    -- print("attribute = ",attribute)
    -- print("min_attribute = ",min_attribute)
    -- print("extra_interval_max = ",extra_interval_max)
    -- print("Lastextra_interval_max = ",Lastextra_interval_max)

    local max_tupo_level = EquipRefineBreachData:length()
    if refineLevel < max_tupo_level then
        refineLevel = refineLevel + 1
    end

    local recastPercent = equip:getRecastPercent()
    local index = 1

    for k,i in pairs(indexTable) do
        self.panel_shuxing[index]:setVisible(true)
        -- self.txt_change[index]:setVisible(false)

        local attrTitle = AttributeTypeStr[i] or localizable.smithy_attr_unknow --"未知"
        self.img_shuxing[index]:setText(attrTitle)
        local curAttr = attribute[i] or 0
        print('curAttr = ',curAttr)
        -- curAttr = math.floor(curAttr/((100+recastPercent)/100))
        -- print('curAttr = ',curAttr)

        local minAttr = min_attribute[i] or 0
        print('minAttr = ',minAttr)
        local fuckAttri = curAttr - minAttr
        -- if fuckAttri < 0 then
        --     fuckAttri = 0
        -- end
        if i >= EnumAttributeType.CritPercent then
            self.txt_attr_num[index]:setText("+"..(fuckAttri/100).."%")
        else
            self.txt_attr_num[index]:setText("+"..fuckAttri)
        end

        local stepIdex,stepNum = equipmentTemplate:getExtraAttributeIndex(i, fuckAttri)

        -- print("当前属性的突破进度 = ", stepIdex)

        -- 绘制进度条
        local bgPath        = "ui_new/equipment/tjp_jindutiaodi_icon.png"
        local processPath   = "ui_new/equipment/tjp_jindutiao1_icon.png"
        -- stepIdex == 0
        if stepIdex == 0 then
            print("stepIdex")
        else
            print("stepIdex = "..stepIdex)
            local bgIndex       = stepIdex
            local processIndex  = stepIdex+1
            -- print("1111111bgIndex =>"..bgIndex.."       processIndex=>"..processIndex)
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


            -- print("222222bgIndex =>"..bgIndex.."       processIndex=>"..processIndex)
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
        
        -- print('1111stepIdex = ',stepIdex)
        -- print('22222stepIdex = ',lastStepTupoIndex)
        print("Lastextra_interval_max1 = ",Lastextra_interval_max1)
        print("Lastextra_interval_max2 = ",Lastextra_interval_max2)

        Lastextra_interval_max1[i] = Lastextra_interval_max1[i] or 0
        Lastextra_interval_max2[i] = Lastextra_interval_max2[i] or 0

        if Lastextra_interval_max1[i] and Lastextra_interval_max2[i] then

            local diffMax = Lastextra_interval_max1[i] - Lastextra_interval_max2[i]
            local diff = fuckAttri - Lastextra_interval_max2[i]
            local percent = math.ceil(diff*100/diffMax)

            -- print("percent",percent)
            self.bar_percent[index]:setPercent(percent)
            
            -- print("---------------"..i)
            -- print("fuckAttri = "..fuckAttri.."  Lastextra_interval_max2[i] = "..Lastextra_interval_max2[i])
            -- print("value1 = "..diff.."  value2 = "..diffMax)
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
        self.btn_refining:setGrayEnabled(false)
        self.btn_refining:setTouchEnabled(true)
    end

    while  index <= EquipmentManager.kMaxExtraAttributeSize do
        self.panel_shuxing[index]:setVisible(false)
        index = index+1
    end

end

--[[
设置是否可以精炼
]]
function EquipmentRefining:setRefinEnabled(enabled)
    --for i=1,3 do
    --    self.panel_shuxing[i]:setVisible(enabled)
    --end
    --self.btn_refining:setGrayEnabled(not enabled)
    --self.btn_refining:setTouchEnabled(enabled)
    self.img_notice:setVisible(not enabled)
    self.scroll_right:setVisible(enabled)
end

--打开商城界面
function EquipmentRefining:showMallLayer()
    CommonManager:showOperateSureLayer(
        function()
            MallManager:openGiftsShop()
        end,
        nil,
        {
            msg = localizable.smithy_EquipmentRefining_toBuy, --"您没有足够的道具[精炼石]，是否打开商城界面进行购买？",
            showtype = AlertManager.BLOCK_AND_GRAY
        }
    )
end

function EquipmentRefining.RefiningClickHandle(sender)
    local self = sender.logic
    self:refining(false)
end
function EquipmentRefining.RefiningAutoClickHandle(sender)
    local self = sender.logic

    local stoneNumber = math.min(self.refinStone,10)
    if stoneNumber < 1 then
        -- self:showMallLayer()
        -- toastMessage("精炼石不足")
        local consumeGoods = EquipmentManager:getRefinStone() or {}
        MallManager:checkShopOneKey(consumeGoods.id)
        return false
    end


    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    
    local index = 0
    for k,v in pairs(self.lockList) do
        index = index + 1 
    end


    local cost = self.lockConsume.value*index*stoneNumber

    -- if MainPlayer:isEnoughSycee(cost,true) == false then
    --     return false
    -- end

    -- local msg = string.format("一键精炼将自动为您精炼%d次，最多消耗%d元宝,精炼满将自动停止，是否确认？",stoneNumber,cost)
    -- if cost == 0 then
    --     msg = string.format("一键精炼将自动为您精炼%d次,精炼满将自动停止，是否确认？",stoneNumber)
    -- end

    local msg = stringUtils.format(localizable.smithy_EquipmentRefining_jl1, stoneNumber,cost)
    if cost == 0 then
        msg = stringUtils.format(localizable.smithy_EquipmentRefining_jl2, stoneNumber)
    end

    CommonManager:showOperateSureLayer(
        function()
            self:refining(true)
        end,
        function()
            AlertManager:close()
        end,
        {
            msg = msg
        }
    )

    
end

function EquipmentRefining:refining(isten)
    -- local stoneNumber = tonumber(self.txt_refin_stone_num:getText())
    local stoneNumber = self.refinStone

    if stoneNumber < 1 then
        -- self:showMallLayer()
        -- toastMessage("精炼石不足")
        local consumeGoods = EquipmentManager:getRefinStone() or {}        
        MallManager:checkShopOneKey(consumeGoods.id)
        return false
    end
    local times = 1
    if isten then
        times = math.min(stoneNumber,10)
    end



    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    
    local lockArray = {}
    local index = 0
    for k,v in pairs(self.lockList) do
        index = index + 1 
        lockArray[index] = k - 1
    end

    local cost = self.lockConsume.value*index*times

    if MainPlayer:isEnoughSycee(cost,true) == false then
        return false
    end

    --if #lockArray >= (equip.quality - 1)  then
    --    toastMessage("所有属性都已上锁")
    --    return
    --end
    -- local recastPercent = equip:getRecastPercent()
    local refineLevel   = equip.refineLevel

    local attribute = equip:getExtraAttribute():getAttribute()
    local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    local min_attribute , max_attribute = equipmentTemplate:getExtraAttribute(refineLevel)
    local allMax = true
    local attrSize = 0
    for k,v in pairs(attribute) do
        local curAttr = v--math.floor(v/((100+recastPercent)/100))
        attrSize = attrSize + 1
        local max = max_attribute[k]
        if not max then
            allMax = false
        elseif curAttr < max and allMax then
            allMax = false
        end
    end

    if allMax then
        -- toastMessage("属性全部达到最大值")
        toastMessage(localizable.smithy_EquipmentRefining_max)
        return false
    end

    EquipmentManager:EquipmentRefining(self.gmId , lockArray,isten)

    return true
end

--显示充值提示框
function EquipmentRefining:showRechargeDialog()
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

function EquipmentRefining.CheckClickHandle(sender)
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

function EquipmentRefining.UnCheckClickHandle(sender)
    local self = sender.logic
    local tag = sender.tag

    if self.lockList[sender.attr_index] then
        self.lockList[sender.attr_index] = nil
    end
    play_linglianshangsuo()
end

function EquipmentRefining:refreshConsumeGoodsRemaining()
    self.refinStone = 0
    local consumeGoods = EquipmentManager:getRefinStone()
    local holdGoods = EquipmentManager:getHoldRefinStone()
    local holdGoods_num = 0
    if holdGoods ~=nil then
        --self.txt_storenum:setText("(剩余".. holdGoods.num .."个)")
        -- self.txt_refin_stone_num:setText(holdGoods.num)
        holdGoods_num =  holdGoods.num 
        -- self.txt_refin_stone_num:setText("(拥有 ".. holdGoods.num ..")")
        self.txt_refin_stone_num:setText(stringUtils.format(localizable.smithy_EquipmentRefining_own,  holdGoods.num))

        self.refinStone = holdGoods.num
    else
        --self.txt_storenum:setText("剩余0个")
        -- self.txt_refin_stone_num:setText(0)
        holdGoods_num =  0
        -- self.txt_refin_stone_num:setText("(拥有 ".. 0 ..")")

        self.txt_refin_stone_num:setText(stringUtils.format(localizable.smithy_EquipmentRefining_own,  0))
    end

    local refine_di = TFDirector:getChildByPath(self.btn_refining2,"refine_di")
    local txt_vip = TFDirector:getChildByPath(self.btn_refining2,"txt_vip")
    local vipLevel = MainPlayer:getVipLevel()
    if vipLevel < self.lockVip.value then
        txt_vip:setVisible(true)
        refine_di:setVisible(false)
        -- txt_vip:setText("VIP".. self.lockVip.value .."可用")
        txt_vip:setText(stringUtils.format(localizable.smithy_EquipmentRefining_vip, self.lockVip.value)) 
        self.btn_refining2:setTouchEnabled(false)
        self.btn_refining2:setGrayEnabled(true)
    else
        local txt_refin_stone_num = TFDirector:getChildByPath(self.btn_refining2,"txt_refin_stone_num")
        txt_vip:setVisible(false)
        refine_di:setVisible(false)
        -- txt_refin_stone_num:setText("(拥有 ".. holdGoods_num ..")")
        self.txt_refin_stone_num:setText(stringUtils.format(localizable.smithy_EquipmentRefining_own,  holdGoods_num))

        self.btn_refining2:setTouchEnabled(true)
        self.btn_refining2:setGrayEnabled(false)
    end

    -- -- 刷新
    -- consumeGoods = EquipmentManager:getTupoStone()
    -- holdGoods = EquipmentManager:getHoldTupoStone()
    -- if holdGoods ~=nil then
    --     self.txt_tupo_num:setText(holdGoods.num)
    -- else
    --     self.txt_tupo_num:setText(0)
    -- end
end

function EquipmentRefining:showRefiningEffect(notice_data )
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
        local attrTitle = AttributeTypeStr[i] or localizable.smithy_attr_unknow --"未知"
              print("attrTitle ==== ",attrTitle,i)
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
        -- TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equipment_refining.xml")
        -- local effect = TFArmature:create("equipment_refining_anim")
        -- effect:setAnimationFps(GameConfig.ANIM_FPS)
        -- self.panel_content:addChild(effect)
        -- effect:setPosition(ccp(465,300))
        -- effect:setZOrder(10)
        local effect = Public:addEffect("lianti7", self.panel_content, 440, 255, 1, 0)
        effect:setZOrder(100)
        effect:setScale(1.7)
        self.equipEffect = effect
    else
        ModelManager:playWithNameAndIndex(self.equipEffect, "", 0, 0, -1, -1)
        -- self.equipEffect:playByIndex(0, -1, -1, 0)
    end
end



function EquipmentRefining:refiningNumEffect(widget )
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
function EquipmentRefining:registerEvents()
	self.super.registerEvents(self)

    self.btn_refining:addMEListener(TFWIDGET_CLICK, audioClickfun(self.RefiningClickHandle),1)
    self.btn_refining2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.RefiningAutoClickHandle),1)

    for i = 1,EquipmentManager.kMaxExtraAttributeSize do
       self.check_attr[i]:addMEListener(TFWIDGET_CHECKBOXSELECT, self.CheckClickHandle)
	   self.check_attr[i]:addMEListener(TFWIDGET_CHECKBOXUNSELECT, self.UnCheckClickHandle)
    end

     self.EquipmentRefiningResultCallBack = function (event)
        play_jinglian()
        self:refreshUI()
        self:showRefiningEffect(event.data[1])
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_REFINING_RESULT,self.EquipmentRefiningResultCallBack)



    self.btn_tupo.logic = self
    self.btn_tupo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.TupoOnclick),1)


    self.equipTupoCallback = function (event)
        play_jinglian()
        self:refreshUI()
        self:showTupoEffect()
        -- print("event = ", event)
        -- local consumeGoods = EquipmentManager:getRefinStone()
        -- if event.data[1] and event.data[1].itemdata.id == consumeGoods.id then
        --     self:refreshConsumeGoodsRemaining()
        -- end
    end
    TFDirector:addMEGlobalListener(EquipmentManager.EQUIPMENT_TUPO_RESULT,self.equipTupoCallback)
end

function EquipmentRefining:removeEvents()
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_TUPO_RESULT,self.equipTupoCallback)
    TFDirector:removeMEGlobalListener(EquipmentManager.EQUIPMENT_REFINING_RESULT,self.EquipmentRefiningResultCallBack)
    -- TFDirector:removeMEGlobalListener(BagManager.ItemAdd)
    -- TFDirector:removeMEGlobalListener(BagManager.ItemChange)
    -- TFDirector:removeMEGlobalListener(BagManager.ItemDel)
    self.super.removeEvents(self)
end


function EquipmentRefining:refrshTupoArea()
    -- 突破相关
    -- self.txt_tupoDesc:setText(100)
    -- self.txt_tupo_cost:setText(100)
    -- self.txt_tupo_num:setText(100)

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end


    local max_tupo_level = EquipRefineBreachData:length()
    local refineLevel   = equip.refineLevel
    
    -- print("self.gmId = ", self.gmId)
    -- print("self.refineLevel = ", refineLevel)

    if refineLevel < max_tupo_level then
    --     self.txt_tupo_cost:setText(0)
    --     -- self.txt_tupoDesc:setVisible(false)
    --     self.txt_tupoDesc:setText("已突破至满级")
    -- else
    --     -- 定位到下一等级
        refineLevel = refineLevel + 1
    end


    local tupInfo = EquipRefineBreachData:objectByID(refineLevel)
    if tupInfo == nil then
        return
    end

    local consume   = string.split(tupInfo.consume,'_')
    local costType  = tonumber(consume[1])
    local itemId    = tonumber(consume[2])
    local number    = tonumber(consume[3])


    print("consume = ", consume)
    local numberInBag = 0
    -- 刷新
    local bagItem = BagManager:getItemById(itemId)
    if bagItem ~= nil then
        numberInBag = bagItem.num
    end
 
    -- self.txt_tupo_num:setText(numberInBag)
    --self.txt_tupo_num:setText("(拥有 ".. numberInBag ..")")
    self.txt_tupo_num:setText(stringUtils.format(localizable.changetProLayer_have, numberInBag))

    local CountinueTupo = true
    if equip.refineLevel >= max_tupo_level then
        self.txt_tupo_cost:setText(0)
        --self.txt_tupoDesc:setText("(已突破至满级)")
        self.txt_tupoDesc:setText(localizable.smithy_EquipmentRefining_max)
        CountinueTupo = false

    else
        self.txt_tupo_cost:setText(number)
        --self.txt_tupoDesc:setText("(需装备强化"..tupInfo.level.."级)")
        self.txt_tupoDesc:setText(stringUtils.format(localizable.smithy_EquipmentRefining_level,tupInfo.level))

        if tupInfo.level > equip.level then
            CountinueTupo = false
        end

    end

    self.btn_tupo:setTouchEnabled(true)
    self.btn_tupo:setGrayEnabled(false)
    self.img_tupodi:setVisible(true)
    self.txt_tupoDesc:setVisible(false)
    if CountinueTupo == false then
        self.btn_tupo:setTouchEnabled(false)
        self.btn_tupo:setGrayEnabled(true)
        self.img_tupodi:setVisible(false)
        self.txt_tupoDesc:setVisible(true)
    end

    self.itemTupoId = itemId
    self.tupoCost  = number
    self.tupoStone = numberInBag
end


function EquipmentRefining.TupoOnclick( sender )
    local self = sender.logic
    -- local stoneNumber = tonumber(self.txt_tupo_num:getText())
    -- local costNumber = tonumber(self.txt_tupo_cost:getText())
    local stoneNumber = self.tupoStone
    local costNumber  = self.tupoCost
    if costNumber > stoneNumber then
        -- self:showMallLayer()
        --toastMessage("物品不足")
        --toastMessage(localizable.smithy_EquipmentRefining_pro)
        MallManager:checkShopOneKey(self.itemTupoId)
        return
    end

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end

    local max_tupo_level = EquipRefineBreachData:length()
    local refineLevel   = equip.refineLevel

    print("refineLevel = ", refineLevel)
    if refineLevel >= max_tupo_level then
        --toastMessage("您已突破到最高等级")
        toastMessage(localizable.smithy_EquipmentRefining_maxlevel)
        return
    end

    local BreachData = EquipRefineBreachData:objectByID(refineLevel+1)
    if BreachData.level > equip.level then
        --toastMessage("装备强化到"..BreachData.level.."级可继续突破")
        toastMessage(stringUtils.format(localizable.smithy_EquipmentRefining_qianghua , BreachData.level))
        return
    end
     

    
    -- local lockArray = {}
    -- local index = 1
    -- for k,v in pairs(self.lockList) do
    --     lockArray[index] = k - 1
    --     index = index + 1 
    -- end

    --if #lockArray >= (equip.quality - 1)  then
    --    toastMessage("所有属性都已上锁")
    --    return
    --end

    -- local attribute = equip:getExtraAttribute():getAttribute()
    -- local equipmentTemplate = EquipmentTemplateData:objectByID(equip.id)
    -- local min_attribute , max_attribute = equipmentTemplate:getExtraAttribute(refineLevel)
    -- local allMax = true
    -- local attrSize = 0

    -- for k,v in pairs(attribute) do
    --     attrSize = attrSize + 1
    --     local max = max_attribute[k]
    --     if not max then
    --         allMax = false
    --     elseif v < max and allMax then
    --         allMax = false
    --     end
    -- end

    -- if #lockArray == attrSize and allMax then
    --     toastMessage("属性全部达到最大值")
    --     return
    -- end
    
    EquipmentManager:EquipmentTupo(self.gmId)

end

function EquipmentRefining:showTupoEffect()
    self.tupoEffectList = {}

    local function playEffect(index)
        if self.tupoEffectList[index] == nil then
            local pos       = self.bar_percent_bg[index]:getPosition()
            local parent    =  self.bar_percent_bg[index]:getParent()

            TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/equipment_tupo.xml")
            local effect = TFArmature:create("equipment_tupo_anim")
            effect:setAnimationFps(GameConfig.ANIM_FPS)
            parent:addChild(effect)
            effect:setPosition(ccp(pos.x, pos.y))
            effect:setZOrder(10)

            self.tupoEffectList[index] = effect
        end
        self.tupoEffectList[index]:playByIndex(0, -1, -1, 0)
    end

    local equip = EquipmentManager:getEquipByGmid(self.gmId)
    if equip == nil  then
        print("equipment not found .",self.gmId)
        return false
    end
    local attribute,indexTable = equip:getExtraAttribute():getAttribute()
    local index = 1
    for k,i in pairs(indexTable) do
        playEffect(index)
        index = index + 1
    end

end

return EquipmentRefining
