-------------------------------------------------------
module(..., package.seeall)

local require = require

--local ui = require("ui/base")
local ui = require("ui/profile")
-------------------------------------------------------
wnd_bagua = i3k_class("wnd_bagua", ui.wnd_profile)

local eBaguaCount = 8
local RowitemCount = 5
local WIDGETS_DJ = "ui/widgets/dj1"
local WIDGETS_BAGUAQHT2 = "ui/widgets/baguaqht2"

local PointByTimes = 8

local noHaveColor = "FF909090"


local f_yilueTypeTable = {9041, 9042, 9043} --分别对应天地人

local qualityName = {
    "白色",
    "绿色",
    "蓝色",
    "紫色",
    "橙色"
}

function wnd_bagua:ctor()
    self.bagua_equip = {}
    self.showType = 1
    self.selectID = 0
    self.strengthCostTb = {}
    self.propStones = {}
    self.choseBaguaPart = 1
    self.chosePoolPropNum = {}
    self.choseSacrificeId = 0
    self.sendData = false

    self.yilueBtnList = {}          --易略左侧按钮列表
    self.yiluePointByTimes = 0      --易略点数购买次数
    self.yilueBasePointTable = {}   
    self.yilueAddPointTable = {0,0,0}
    self.curYilueID = 0     --当前易略id
    self.curYilueZJLv = 0   --当前易略专精等级
    self.curHavePoints = 0
    self.hasAddPointChange = false
    self.curSkill_id = 0    --当前易略技能ID
    self.curSelectId = 0
end

function wnd_bagua:configure()
    self.ui = self._layout.vars
    self.ui.close_btn:onClick(self, self.onClickClose)

    self.tabs = {
        {
            btn = self.ui.bg_bt,
            ui = self.ui.bgUI
        },
        {
            btn = self.ui.qh_bt,
            ui = self.ui.qhUI
        },
        {
            btn = self.ui.dz_bt,
            ui = self.ui.dzUI
        },
        {
            btn = self.ui.yilue_bt,
            ui = self.ui.yilueUI
        }
    }

    local level = g_i3k_game_context:GetLevel()
    self.ui.yilue_bt:setVisible(level >= i3k_db_bagua_cfg.yilueShowLv)

    for i, v in ipairs(self.tabs) do
        v.btn:onClick(
            self,
            function()
                self:showIndexSwitch(i)
            end
        )
    end

    self:initBaguaEquipWidget(self.ui)
    ui_set_hero_model(
        self.ui.hero_module,
        i3k_game_get_player_hero(),
        g_i3k_game_context:GetWearEquips(),
        g_i3k_game_context:GetIsShwoFashion(),
        g_i3k_game_context:getIsShowArmor()
    )

    self.ui.sale_bat:onClick(self, self.onSaleBatButton)
    self.ui.increease:onClick(self, self.onIncreease)
    self.ui.autoincrease:onClick(self, self.onAutoIncreease)
    for i = 1, 3 do
        self.ui["poolChose" .. i]:onClick(
            self,
            function()
                g_i3k_ui_mgr:OpenUI(eUIID_BaguaStoneSelect)
                g_i3k_ui_mgr:RefreshUI(eUIID_BaguaStoneSelect, i)
            end
        )

        self.ui["remove" .. i]:onClick(
            self,
            function()
                local desc = i3k_get_string(17064)
                local fun = (function(ok)
                    if ok then
                        local energy = 0
                        local scroll = self.ui["scroll" .. i]
                        for _, v in ipairs(scroll:getAllChildren()) do
                            local stoneConfigData =
                                g_i3k_db.i3k_db_get_prop_stone(v.customData.propId, v.customData.quality)
                            if stoneConfigData then
                                energy = energy + stoneConfigData.energy
                            end
                        end
                        i3k_sbean.request_eightdiagram_del_stonepool_req(i, energy)
                    end
                end)
                g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
            end
        )
    end
    self.ui.makeBtn:onClick(
        self,
        function()
            if not self:isChoseEnoughStone() then
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17066))
                return
            end

            for i, v in ipairs(i3k_db_bagua_cfg.makeCost) do
                if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
                    g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
                    return
                end
            end
            local useStone, _ = self:getChosePropStone()
            i3k_sbean.request_eightdiagram_create_req(self.choseBaguaPart, useStone, self.choseSacrificeId)
        end
    )

    self.ui.choseJPBtn:onClick(
        self,
        function()
            if not self:checkSacrifice() then
                local need = i3k_db_bagua_cfg.sacrifice
                g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17065, need.count, qualityName[need.quality]))
                return
            end
            g_i3k_ui_mgr:OpenUI(eUIID_BaguaSacrificeSelect)
            g_i3k_ui_mgr:RefreshUI(eUIID_BaguaSacrificeSelect, self.choseBaguaPart)
        
		end
    )

    self.ui.chosePartBtn:onClick(
        self,
        function()
            self.ui.chosePartUI:setVisible(not self.ui.chosePartUI:isVisible())
        end
    )

    self.ui.helpBtn:onClick(
        self,
        function()
            local desc = ""
            if self.showType == 1 then
                desc = i3k_get_string(17097)
            elseif self.showType == 2 then
                desc = i3k_get_string(17098)
            elseif self.showType == 3 then
                desc = i3k_get_string(17099)
            else
                desc = i3k_get_string(18249)
            end
            g_i3k_ui_mgr:ShowHelp(desc)
        end
    )

    self.ui.suitBtn:onClick(
        self,
        function()
            g_i3k_ui_mgr:OpenUI(eUIID_BaGuaSuit)
            g_i3k_ui_mgr:RefreshUI(eUIID_BaGuaSuit)
        end
    )
    self.ui.guideBtn:onClick(
        self,
        function()
            g_i3k_ui_mgr:OpenUI(eUIID_BaGuaGuide)
        end
    )
	
	self.ui.look:onClick(self, function()
		g_i3k_logic:OpenBaGuaCheck()
	end
	)
	
	self.ui.affixhelp:onClick(hoster, function()
		g_i3k_ui_mgr:OpenUI(eUIID_BaguaAffixHelp)
		g_i3k_ui_mgr:RefreshUI(eUIID_BaguaAffixHelp)
	end)

    self:checkAddPointBtnState()
    
    self.addPointBtns = {
        {
            btn = self.ui.addPBtn1,
        },
        {
            btn = self.ui.addPBtn2,
        },
        {
            btn = self.ui.addPBtn3,
        },
    }

    for i, v in ipairs(self.addPointBtns) do
        v.btn:onClick(
            self,
            function()
                self:addYiluePoint(i)
            end
        )
    end
	
    self.hero_module = self.ui.hero_module
    self.revolve = self.ui.revolve
    self.ui.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型

    self.ui.giveUpBtn:onClick(self, self.onGiveUpBtnClick)
    self.ui.saveBtn:onClick(self, self.onSaveBtnClick)
    self.ui.resetPointBtn:onClick(self, self.onResetPointClick)
    self.ui.yilueDescBtn:onClick(self, self.onYilueDescBtnClick)
    self.ui.yilueSkillBtn:onClick(self, self.onYilueSkillClick)
end

function wnd_bagua:onClickClose()
    if self.hasAddPointChange then  
        local fun = (function(ok)
            if ok then
                g_i3k_ui_mgr:CloseUI(eUIID_Bagua)
            end
        end)
        local msg = i3k_get_string(18226)
        g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
    else
        self:onCloseUI()
    end
end

function wnd_bagua:checkSacrifice()
    local need = i3k_db_bagua_cfg.sacrifice
    local haveNum = self:getStoneNumByQuality(need.quality)
    if haveNum < need.count then
        return false
    end
    return true
end
function wnd_bagua:unEquip()
    self.selectID = 0
    self:showIndex(1)
end
function wnd_bagua:choseSacrifice(id)
    self.choseSacrificeId = id
    self.ui.choseJPBtn:setVisible(false)
    self.ui.sacrificeBg:setVisible(true)

    self.ui.sacrificeBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
    self.ui.sacrificeIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))

    self.ui.sacrificeBtn:onClick(
        self,
        function()
            self:initSacrifice()
            self:updateMakeAffixProp()
            --g_i3k_ui_mgr:ShowCommonItemInfo(id)
        end
    )
    self:updateMakeAffixProp()
end

function wnd_bagua:isChoseEnoughStone()
    for i, v in ipairs(self.chosePoolPropNum) do
        if v < i3k_db_bagua_part[self.choseBaguaPart].selectPropNum[i] then
            return false
        end
    end
    return true
end

function wnd_bagua:getChosePropStone()
    local useStone = {}
    local choseStoneData = {}
    for i = 1, 3 do
        local data = {}
        local scroll = self.ui["scroll" .. i]
        for i, v in ipairs(scroll:getAllChildren()) do
            if v.vars.choseBg:isVisible() then
                data[v.customData.propId] = true
                table.insert(choseStoneData, v.customData)
            end
        end

        local useStones = i3k_sbean.UseStones.new()
        useStones.props = data
        table.insert(useStone, useStones)
    end
    return useStone, choseStoneData
end

function wnd_bagua:initMakePropNum()
    for i = 1, 3 do
        self:setMakePropNum(i, 0)
    end
end

function wnd_bagua:setMakePropNum(poolId, num)
    local maxNum = i3k_db_bagua_part[self.choseBaguaPart].selectPropNum[poolId]
    if num > maxNum or num < 0 then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17110))
        return false
    end
    self.chosePoolPropNum[poolId] = num
    self.ui["propNum" .. poolId]:setText(string.format("可选 %d/%d", num, maxNum))
    return true
end

--初始化八卦装备控件
function wnd_bagua:initBaguaEquipWidget(widgets)
    for i = 1, eBaguaCount do
        local equip_btn = "equip" .. i
        local equip_icon = "equip_icon" .. i
        local grade_icon = "grade_icon" .. i
        local is_select = "is_select" .. i
        local level_label = "qh_level" .. i
        local red_tips = "tips" .. i
        local equip_blink = "equip_blink" .. i

        self.bagua_equip[i] = {
            equip_btn = widgets[equip_btn],
            equip_icon = widgets[equip_icon],
            grade_icon = widgets[grade_icon],
            is_select = widgets[is_select],
            level_label = widgets[level_label],
            red_tips = widgets[red_tips],
            equip_blink = widgets[equip_blink]
        }
    end
end

function wnd_bagua:refresh()
    self:showIndex(1)

    for i = 1, eBaguaCount do
        local item = require("ui/widgets/baguasxt")()
        item.vars.name:setText(i3k_db_bagua_part[i].name)
        item.vars.prop:setText(i3k_db_bagua_part[i].formula)
        item.vars.btn:onClick(
            self,
            function()
                self:choseMakePart(i)
            end
        )
        self.ui.chosePartScroll:addItem(item)
    end

    self.ui.dzPropScroll:removeAllChildren()
    self.ui.czPropScroll:removeAllChildren()
    self.makeProp = {}
    self.makeAffixProp = {}
    local affixName = {"第一条词缀", "第二条词缀", "第三条词缀"}
    for i = 1, 3 do
        local item = require("ui/widgets/baguadzt1")()
        item.vars.name:setText("???")
        item.vars.value:setText("???")
        table.insert(self.makeProp, {name = item.vars.name, value = item.vars.value})
        self.ui.dzPropScroll:addItem(item)

        local item = require("ui/widgets/baguadzt2")()
        item.vars.name:setText(affixName[i])
        item.vars.value:setText("0%")
        table.insert(self.makeAffixProp, {value = item.vars.value})
        self.ui.czPropScroll:addItem(item)
    end
end

function wnd_bagua:choseMakePart(part)
    self.ui.chosePartUI:setVisible(false)
    self.choseBaguaPart = part
    self.ui.partLabel:setText(i3k_db_bagua_part[part].name)
    self.ui.partBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_part[part].icon))
    self:initMake()
end

function wnd_bagua:initMake()
    self:initMakePropNum()
    self:updateStone()
    self:updateMakeBaseProp()
    self:updateMakeAffixProp()
    self:initSacrifice()
end

function wnd_bagua:initSacrifice()
    self.choseSacrificeId = 0
    self.ui.choseJPBtn:setVisible(true)
    self.ui.sacrificeBg:setVisible(false)
end

function wnd_bagua:showIndexSwitch(index)
    if self.hasAddPointChange then
        if index == 4 then
            return
        end
        local fun = (function(ok)
            if ok then
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "onGiveUpBtnClick")
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "showIndex", index)
            end
        end)
        local msg = i3k_get_string(18226)
        g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
    else
        self:showIndex(index)
    end
end

function wnd_bagua:showIndex(index)
    if index == 4 then --易略
        local data = g_i3k_game_context:getEquipDiagrams()
        if table.nums(data) == 0 then
            return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18238))
        end
        local level = g_i3k_game_context:GetLevel()
        if level < i3k_db_bagua_cfg.yilueOpenLv then
            return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18237, i3k_db_bagua_cfg.yilueOpenLv))
        end
        if not g_i3k_game_context:isYilueOpen() then
            g_i3k_ui_mgr:OpenUI(eUIID_BaguaYilue)
            return 
        else
            self.ui.hero_module:setVisible(false)
            self.ui.equips:setVisible(false)
            self.ui.guideBtn:setVisible(false)
        end
    elseif index == 3 then --锻造
        self.ui.hero_module:setVisible(false)
        self.ui.equips:setVisible(false)
        self.ui.guideBtn:setVisible(true)
        if i3k_usercfg:GetIsShowBaguaGuide() then
            i3k_usercfg:SetIsShowBaguaGuide(false)
            g_i3k_ui_mgr:OpenUI(eUIID_BaGuaGuide)
        end
    else
        if index == 2 then --强化
            local data = g_i3k_game_context:getEquipDiagrams()
            if table.nums(data) == 0 then
                return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17082))
            end
        end

        self.ui.hero_module:setVisible(true)
        self.ui.equips:setVisible(true)
        self.ui.guideBtn:setVisible(false)
    end

    for i, v in ipairs(self.tabs) do
        if i == index then
            v.btn:stateToPressed()
            v.ui:setVisible(true)
        else
            v.btn:stateToNormal()
            v.ui:setVisible(false)
        end
    end

    if index == 1 then
        self:updateBaguaEquipsData()
        self:updateBaguaBag()
        self:onStopUpStage()
        self.ui.baguaTitle:setImage(g_i3k_db.i3k_db_get_icon_path(9081))
    elseif index == 2 then
        self:updateBaguaEquipsData()
        self:updateStrengthView()
        self.ui.baguaTitle:setImage(g_i3k_db.i3k_db_get_icon_path(9081))
    elseif index == 3 then
        self:updateMakeCost()
        self:choseMakePart(1)
        self:onStopUpStage()
        self.ui.baguaTitle:setImage(g_i3k_db.i3k_db_get_icon_path(9081))
    elseif index == 4 then
        self:updateYilueData()
        self.ui.baguaTitle:setImage(g_i3k_db.i3k_db_get_icon_path(9082))
    end

    self.showType = index
end

--更新锻造基础属性
function wnd_bagua:updateMakeBaseProp()
    local isChoseEnoughStone = self:isChoseEnoughStone()

    local _, choseStoneData = self:getChosePropStone()
    for i, v in ipairs(self.makeProp) do
        if isChoseEnoughStone then
            local choseData = choseStoneData[i]
            local stoneData = g_i3k_db.i3k_db_get_prop_stone(choseData.propId, choseData.quality)
            v.name:setText(i3k_db_prop_id[choseData.propId].desc)
            v.value:setText(stoneData.propMin .. "~" .. stoneData.propMax)
        else
            v.name:setText("???")
            v.value:setText("???")
        end
    end
end
function wnd_bagua:getStoneNumByQuality(quality)
    local num = 0
    local _, choseStoneData = self:getChosePropStone()
    for i, v in ipairs(choseStoneData) do
        if v.quality >= quality then
            num = num + 1
        end
    end

    return num
end
--更新锻造词缀属性
function wnd_bagua:updateMakeAffixProp()
    local isChoseEnoughStone = self:isChoseEnoughStone()
    local _, choseStoneData = self:getChosePropStone()
    for i, v in ipairs(self.makeAffixProp) do
        if isChoseEnoughStone then
            local need = i3k_db_bagua_cfg.affix[i]
            local haveNum = self:getStoneNumByQuality(need.quality)
            if haveNum < need.count then
                v.value:setText("概率:0%")
            else
                local partPercent = i3k_db_bagua_part[self.choseBaguaPart]["affix" .. i]
                local stonePercent = 0
                for _, v in ipairs(choseStoneData) do
                    local stoneData = g_i3k_db.i3k_db_get_prop_stone(v.propId, v.quality)
                    stonePercent = stonePercent + stoneData.affixAddition[i]
                end
                local showText = ""
                if self.choseSacrificeId ~= 0 then
                    local propData = g_i3k_db.i3k_db_get_common_item_cfg(self.choseSacrificeId)
                    if propData["args" .. (i + 1)] <= 10000 then
                        showText = "概率:" .. (partPercent + stonePercent + propData["args" .. (i + 1)]) / 100 .. "%"
                    else
                        showText = "必出:" .. i3k_db_bagua_affix[propData["args" .. (i + 1)]].name
                    end
                else
                    showText = "概率:" .. (partPercent + stonePercent) / 100 .. "%"
                end
                v.value:setText(showText)
            end
        else
            v.value:setText("概率:0%")
        end
    end
end

--更新锻造消耗
function wnd_bagua:updateMakeCost()
    self.ui.dzCostScroll:removeAllChildren()
    for i, v in ipairs(i3k_db_bagua_cfg.makeCost) do
        if v.id ~= 0 then
            local item = require("ui/widgets/baguadzt3")()
            if v.count >= 100 then
                item.vars.numLabel:setText(v.count)
            else
                item.vars.numLabel:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .. "/" .. v.count)
            end

            if g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count then
                item.vars.numLabel:setTextColor(g_i3k_get_hl_green_color())
            else
                item.vars.numLabel:setTextColor(g_i3k_get_hl_red_color())
            end

            item.vars.root1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
            item.vars.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
            item.vars.lock1:setVisible(v.id > 0)
            item.vars.btn1:onClick(
                self,
                function()
                    g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
                end
            )

            self.ui.dzCostScroll:addItem(item)
        end
    end
end

--更新原石
function wnd_bagua:useStone(stones)
    for i, v in ipairs(stones) do
        local _useStones = v.props
        local _stones = self.propStones[i].stones
        for i1, v1 in ipairs(_stones) do
            for k2, v2 in pairs(_useStones) do
                if v1.propId == k2 then
                    v1.quality = 0
                end
            end
        end
    end
    self:initMake()
    self:updateMakeCost()
end

function wnd_bagua:setPropStones(stones)
    self.propStones = stones
    self:updateStone()
end

function wnd_bagua:setOnePropStones(stones, poolId)
    self.propStones[poolId].stones = stones
    self:updateOneStone(poolId)
end

function wnd_bagua:updateStone()
    for i = 1, 3 do
        self:updateOneStone(i)
    end
end

function wnd_bagua:updateOneStone(poolId)
    local stones = self.propStones[poolId].stones

    self.ui["scroll" .. poolId]:removeAllChildren()

    local emptyNum = next(stones) == nil and 5 or 0
    for stoneIndex, stoneData in ipairs(stones) do
        local item = require("ui/widgets/baguadzt4")()
        item.customData = stoneData
        item.vars.choseBg:setVisible(false)

        if stoneData.quality == 0 then
            emptyNum = emptyNum + 1
            item.rootVar:setVisible(false)
        else
            local stoneConfigData = g_i3k_db.i3k_db_get_prop_stone(stoneData.propId, stoneData.quality)
            item.vars.title:setText(stoneConfigData.propName)
            item.vars.title:setTextColor(stoneConfigData.fontColor)
            item.vars.title:enableOutline(stoneConfigData.outlineColor)
            item.vars.root1:setImage(g_i3k_db.i3k_db_get_icon_path(stoneConfigData.icon))

            item.vars.btn1:onClick(
                self,
                function()
                    local isVisible = item.vars.choseBg:isVisible()
                    local isChange = false
                    if not isVisible then
                        isChange = self:setMakePropNum(poolId, self.chosePoolPropNum[poolId] + 1)
                    else
                        isChange = self:setMakePropNum(poolId, self.chosePoolPropNum[poolId] - 1)
                    end
                    if isChange then
                        item.vars.choseBg:setVisible(not isVisible)
                        self:updateMakeBaseProp()
                        self:updateMakeAffixProp()
                        if not self:checkSacrifice() then
                            self:initSacrifice()
                        end
                    end
                end
            )
        end

        self.ui["scroll" .. poolId]:addItem(item)
    end
    self.ui["guide" .. poolId]:setVisible(emptyNum == 5)
    self.ui["content" .. poolId]:setVisible(emptyNum ~= 5)
end

--更新八卦装备信息
function wnd_bagua:updateBaguaEquipsData()
    local data = g_i3k_game_context:getEquipDiagrams()
	local yilueData = g_i3k_game_context:getPartStrength()
    local suitTotal = {}
    for _, v in pairs(i3k_db_bagua_affix) do
        local suitID = v.args1
        suitTotal[suitID] = (suitTotal[suitID] or 0) + 1
    end

    local haveSuitCnt = {}
    for _, bagDiagram in pairs(data) do
        for _, v in ipairs(bagDiagram.additionProp) do
            local data = i3k_db_bagua_affix[v]
            if data and data.affixType == 3 then
                local suitID = data.args1
                haveSuitCnt[suitID] = (haveSuitCnt[suitID] or 0) + 1
            end
        end
    end

    for i, e in ipairs(self.bagua_equip) do
        e.is_select:hide()
        local equip = data[i] -- 八卦装备数据
        if equip then
			equip.yilue = yilueData[i].changeInfo
            local rank = g_i3k_db.i3k_db_get_bagua_rank(equip.additionProp) --品质
            e.equip_btn:enable()
            e.equip_icon:show()
            e.equip_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(i).icon))
            e.grade_icon:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))

            local strengthInfo = g_i3k_game_context:getPartStrength()[equip.part]
            local finalStrength = g_i3k_game_context:getBaGuaFinalStrength()[equip.part]
            e.level_label:show()
            e.level_label:setText("+" .. finalStrength)
            e.level_label:setTextColor(finalStrength > strengthInfo.level and g_i3k_get_hl_green_color() or "FFFFFFFF")
            e.red_tips:hide()

            local suitID = 0
            for _, v in ipairs(equip.additionProp) do
                local data = i3k_db_bagua_affix[v]
                if data and data.affixType == 3 then
                    suitID = data.args1
                end
            end
            if suitID ~= 0 and haveSuitCnt[suitID] then
                e.equip_blink:setVisible(suitTotal[suitID] - haveSuitCnt[suitID] == 0)
            else
                e.equip_blink:hide()
            end

            e.equip_btn:onClick(self, self.onSelectBagua, {equip = equip, isBag = false})
        else
            e.equip_btn:disable()
            e.equip_icon:hide()
            e.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(5695)) --默认白色
            e.level_label:hide()
            e.red_tips:hide()
            e.equip_blink:hide()
        end
    end
end

--更新八卦背包信息
function wnd_bagua:updateBaguaBag()
    local bagDiagrams = g_i3k_game_context:GetBagDiagrams()
    local items = g_i3k_game_context:sortBaguaItems(bagDiagrams)
    local allBars = self.ui.scroll:addChildWithCount(WIDGETS_DJ, RowitemCount, #items)
    for i, v in ipairs(allBars) do
        if items[i] then
            local id = items[i].id
            local rank = g_i3k_db.i3k_db_get_bagua_rank(items[i].additionProp) --品质
            local part = items[i].part
            v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_bagua_rank_icon(rank))
            v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(items[i].part).icon))
            v.vars.item_count:hide()
            v.vars.suo:setVisible(id > 0)
            v.vars.bt:onClick(self, self.onSelectBagua, {equip = items[i], isBag = true})

            local curEquip = g_i3k_game_context:getEquipDiagrams()[part]
            if curEquip then
                local power = g_i3k_game_context:getBaGuaBasePower(items[i])
                local wPower = g_i3k_game_context:getBaGuaBasePower(curEquip)
                v.vars.isUp:show()
                if wPower > power then
                    v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
                elseif wPower < power then
                    v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
                else
                    v.vars.isUp:hide()
                end
            else
                v.vars.isUp:show()
                v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
            end
        else
            v.vars.item_count:hide()
        end
    end
    self.ui.noItemTips:setText(i3k_get_string(17124))
    self.ui.noItemTips:setVisible(table.nums(bagDiagrams) == 0)
end

--批量出售
function wnd_bagua:onSaleBatButton(sender)
    g_i3k_ui_mgr:OpenUI(eUIID_BaguaSaleBat)
    g_i3k_ui_mgr:RefreshUI(eUIID_BaguaSaleBat)
end

function wnd_bagua:onSelectBagua(sender, data)
    local equip = data.equip
    if not data.isBag then
        for i = 1, #self.bagua_equip do
            self.bagua_equip[i].is_select:setVisible(i == equip.part)
        end
    end
    if self.showType == 1 then
        g_i3k_ui_mgr:OpenUI(eUIID_BaguaTips)
		if equip.yilue then
			equip.yilue.changeSkills = g_i3k_game_context:GetBaguaYilue().changeSkills
		end
        g_i3k_ui_mgr:RefreshUI(eUIID_BaguaTips, {equip = equip, isOut = false})
    elseif self.showType == 2 then
        if self.selectID == equip.part then
            return
        end
        self.selectID = equip.part
        self:setStrengView(equip.part)
    end
end

function wnd_bagua:updateStrengthView()
    if self.selectID == 0 then
        local data = g_i3k_game_context:getEquipDiagrams()
        for i = 1, eBaguaCount do
            local equip = data[i]
            if equip then
                self.selectID = i
                break
            end
        end
    end
    self:setStrengView(self.selectID)
end

--查看八卦强化信息
function wnd_bagua:setStrengView(partID)
    self.bagua_equip[partID].is_select:show()
    local strengthInfo = g_i3k_game_context:getPartStrength()[partID]
    local finalStrength = g_i3k_game_context:getBaGuaFinalStrength()[partID]
    local baseProp =
        g_i3k_game_context:getEquipDiagrams()[partID] and g_i3k_game_context:getEquipDiagrams()[partID].baseProp or {}
    local curLvl = finalStrength
    local cfg = g_i3k_db.i3k_db_get_bagua_strength_data(curLvl)
    local nextCfg = g_i3k_db.i3k_db_get_bagua_strength_data(curLvl + 1)
    if strengthInfo.level >= i3k_db_bagua_cfg.strengMax then
        self.ui.max_view:setVisible(true)
        self.ui.qh_view:setVisible(false)
        if finalStrength - strengthInfo.level > 0 then
            self.ui.curLvl2:setText(finalStrength .. "级(+" .. (finalStrength - strengthInfo.level) .. ")")
        else
            self.ui.curLvl2:setText(finalStrength .. "级")
        end

        self.ui.curDesc2:setText(string.format("属性提升%s%%", cfg.attrUpPer / 100))
        self.ui.curProp2:removeAllChildren()
        for _, v in ipairs(baseProp) do
            local ui = require("ui/widgets/baguaqht3")()
            local _t = i3k_db_prop_id[v.id]
            ui.vars.name:setText(_t.desc)
            ui.vars.value:setText(i3k_get_prop_show(v.id, (v.value + math.floor(v.value * cfg.attrUpPer / 10000))))
			ui.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
            self.ui.curProp2:addItem(ui)
        end
    else
        self.ui.max_view:setVisible(false)
        self.ui.qh_view:setVisible(true)
        --左侧
        if finalStrength - strengthInfo.level > 0 then
            self.ui.curLvl:setText(finalStrength .. "级(+" .. (finalStrength - strengthInfo.level) .. ")")
            self.ui.nextLvl:setText(finalStrength + 1 .. "级(+" .. (finalStrength - strengthInfo.level) .. ")")
        else
            self.ui.curLvl:setText(finalStrength .. "级")
            self.ui.nextLvl:setText(finalStrength + 1 .. "级")
        end
        self.ui.curDesc:setText(string.format("属性提升%s%%", cfg.attrUpPer / 100))
        self.ui.curProp:removeAllChildren()
        for _, v in ipairs(baseProp) do
            local ui = require("ui/widgets/baguaqht3")()
            local _t = i3k_db_prop_id[v.id]
            ui.vars.name:setText(_t.desc)
            ui.vars.value:setText(i3k_get_prop_show(v.id, (v.value + math.floor(v.value * cfg.attrUpPer / 10000))))
			ui.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
            self.ui.curProp:addItem(ui)
        end
        --右侧

        self.ui.nextDesc:setText(string.format("属性提升%s%%", nextCfg.attrUpPer / 100))
        self.ui.nextProp:removeAllChildren()
        for _, v in ipairs(baseProp) do
            local ui = require("ui/widgets/baguaqht3")()
            local _t = i3k_db_prop_id[v.id]
            ui.vars.name:setText(_t.desc)
            ui.vars.value:setText(i3k_get_prop_show(v.id, (v.value + math.floor(v.value * nextCfg.attrUpPer / 10000))))
			ui.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
            self.ui.nextProp:addItem(ui)
        end
        --消耗
        self:refreshStrengthCost()
    end
end

function wnd_bagua:refreshStrengthCost()
    local partID = self.selectID
    if partID and partID > 0 then
        local strengthInfo = g_i3k_game_context:getPartStrength()[partID]
        local cfg = g_i3k_db.i3k_db_get_bagua_strength_data(strengthInfo.level)
        local percent = (cfg.oriSucRatio + strengthInfo.failTime * cfg.ratioAdd) / 100
        self.ui.strengthSucRate:setText(percent .. "%")
        self.ui.expbar:setPercent(percent)
        self.ui.item_scroll:removeAllChildren()
        local costTb = {}
        table.insert(costTb, {id = g_BASE_ITEM_BAGUA_ENERGY, count = cfg.costEnery})
        for _, v in ipairs(cfg.costItem) do
            if v.id ~= 0 and v.count > 0 then
                table.insert(costTb, {id = v.id, count = v.count})
            end
        end
        self.strengthCostTb = costTb

        for _, v in ipairs(costTb) do
            local ui = require(WIDGETS_BAGUAQHT2)()
            ui.vars.bt:onClick(self, self.showItemInfo, v.id)
            ui.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
            ui.vars.item_icon:setImage(
                g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole())
            )
            ui.vars.name:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .. "/" .. v.count)
            ui.vars.name:setTextColor(
                g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count and g_i3k_get_red_color() or
                    g_i3k_get_green_color()
            )
            ui.vars.suo:setVisible(v.id > 0)
            self.ui.item_scroll:addItem(ui)
        end
    end
end

function wnd_bagua:onIncreease(sender)
    if self.sendData then
        return
    end

    for _, v in ipairs(self.strengthCostTb) do
        if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
            g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
            self:onStopUpStage()
            return
        end
    end
    self.sendData = true
    i3k_sbean.request_eightdiagram_strength_req(self.selectID, self.strengthCostTb)
end

function wnd_bagua:onStopUpStage()
    self.ui.increease:enableWithChildren()
    self.ui.autoincrease:enableWithChildren()
    self.ui.autoincrease:stopAllActions()
end

function wnd_bagua:onAutoIncreease(sender)
    self.ui.increease:disableWithChildren()
    self.ui.autoincrease:disableWithChildren()
    self.ui.autoincrease:runAction(
        cc.RepeatForever:create(
            cc.Sequence:create(
                cc.CallFunc:create(
                    function()
                        self:onIncreease()
                    end
                ),
                cc.DelayTime:create(0.5)
            )
        )
    )
end

function wnd_bagua:strengthResult(result)
    if result <= 0 then
        self:onStopUpStage()
    end

    if result == 1 then
        --成功
        self:onStopUpStage()
        local strengthInfo = g_i3k_game_context:getPartStrength()[self.selectID]
        strengthInfo.level = strengthInfo.level + 1
        strengthInfo.failTime = 0
        g_i3k_game_context:refreshBaguaProp()
    end

    if result == 2 then
        --失败
        local strengthInfo = g_i3k_game_context:getPartStrength()[self.selectID]
        strengthInfo.failTime = strengthInfo.failTime + 1
    end

    if result > 0 then
        for i, v in ipairs(self.strengthCostTb) do
            g_i3k_game_context:UseCommonItem(v.id, v.count)
        end
    end

    self:showIndex(2)
    self.sendData = false
end

function wnd_bagua:showItemInfo(sender, id)
    g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

-----------------------八卦易略---------------------------------------------------


--八卦易略（加载左侧八卦列表）
function wnd_bagua:updateYilueData()
    local equipData = g_i3k_game_context:getEquipDiagrams()
    local yilueData = g_i3k_game_context:getPartStrength()
    self.yilueBtnList = {}
    self.ui.baguaScroll:removeAllChildren()
    local firstID = 0
    local index = 0
    for i,v in ipairs(i3k_db_bagua_part) do
        local item = require("ui/widgets/baguayst1")()
        item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(i).yiueIcon))

        local ZJ_lv = 0
        local yilueType = 0
        if equipData[i] then
            item.isWear = true
            if index == 0 then
                index = 1
                firstID = i
            end
            ZJ_lv = g_i3k_game_context:GetYilueZhuanjingLv(yilueData[i].changeInfo.propPoints)
            yilueType = g_i3k_game_context:GetYilueType(yilueData[i].changeInfo.propPoints)
            item.vars.zhuanjing:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[yilueType].lvSmallID))
        else
            item.vars.icon:disable()
            item.isWear = false
            item.vars.zhuanjing:hide()
        end
        item.vars.count:setText(ZJ_lv)
        item.vars.baguaBtn:onClick(self,self.OnBaguaYilueClick, i)
        table.insert(self.yilueBtnList, item)
        self.ui.baguaScroll:addItem(item)
    end

    if self.curSelectId ~= 0 and equipData[self.curSelectId] then
        firstID = self.curSelectId
    end
    self:SelectYilue(firstID)
    self:checkAddPointBtnState()
end

function wnd_bagua:OnBaguaYilueClick(sender, id)
    if id == self.curYilueID then
        return
    end
    if self.hasAddPointChange then
        local fun = (function(ok)
            if ok then
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "onGiveUpBtnClick")
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "SelectYilue", id)
            end
        end)
        local msg = i3k_get_string(18226)
        g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
    else
        self:SelectYilue(id)
    end
end

function wnd_bagua:SelectYilue(id)
    local equipData = g_i3k_game_context:getEquipDiagrams()
    if not equipData[id] then
        return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18227))
    end 
    self.curSelectId = id
    self.curYilueID = id
    for i,v in ipairs(self.yilueBtnList) do
        if i == id then
            v.vars.select:show()
        else
            v.vars.select:hide()
        end
    end

    local yilueData = g_i3k_game_context:getPartStrength() --获取已装备的八卦信息
    --当前易略技能
    local skillId = yilueData[id].changeInfo.equipSkill
    self:setYilueSkill(skillId)
    self:copyPointDataToLocal(yilueData[id].changeInfo.propPoints)
    self:RefreshCurYilueData(yilueData[id].changeInfo.propPoints)

   
end

function wnd_bagua:setYilueSkill(id)
    if id ~= 0 then
        self.ui.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_yilue_skill[id].iconID))
        self.ui.skill_icon:show()
        self.curSkill_id = id
    else
        self.ui.skill_icon:hide()
        self.curSkill_id = 0
    end
end

--保存一份点数数据到local
function wnd_bagua:copyPointDataToLocal(points)
    self.yilueBasePointTable = {}
    for i,v in ipairs(points) do
        table.insert(self.yilueBasePointTable, points[i]) 
    end
end

--设置选中八卦的易略信息
function wnd_bagua:RefreshCurYilueData(pointsData)
   
    local baseData = {}           --基础属性
    local baseOtherData = {}      --基础增加属性
    local upData = {}             --附加属性
    local upOtherData = {}        --附加增加属性

    self.ui.resetPointBtn:setVisible(not g_i3k_game_context:yiluePointIsInit(pointsData) and not self.hasAddPointChange) 

    for i=1,3 do
        self.ui["yiluePoint"..i]:setText(pointsData[i])
        --统计当前对应的属性加成
        local basePoints = g_i3k_game_context:GetYiuePointsByPartId(self.curYilueID)
        local valueData = i3k_db_bagua_yilue_Attr[self.curYilueID][i][basePoints[i]]
        local base = {}
        base.id = valueData.baseID 
        base.value = valueData.baseValue
        table.insert(baseData, base)
        local up = {}
        up.id = valueData.upID
        up.value = valueData.upValue
        table.insert(upData, up)
        --统计由于加点显示的额外属性加成
        if self.yilueAddPointTable[i] ~= 0 then
            local valueOtherData = i3k_db_bagua_yilue_Attr[self.curYilueID][i][self.yilueBasePointTable[i]]
            baseOtherData[valueOtherData.baseID] = valueOtherData.baseValue - base.value
            upOtherData[valueOtherData.upID] = valueOtherData.upValue - up.value
        end
    end
   
    --设置当前易略类型
    local typeID = g_i3k_game_context:GetYilueType(pointsData)
    self.ui.baguaType:setText(i3k_get_string(18228, i3k_get_string(i3k_db_bagua_cfg.yilueType[typeID].nameID)))
    
    --加点期间不做修改
    if (self.curSkill_id == 0 and self.hasAddPointChange) or not self.hasAddPointChange then
        self.ui.skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[typeID].skillKuangID))
        self.ui.skill_kong:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[typeID].kongID))
    end
   
    --设置当前易略专精等级
    self.curYilueZJLv = g_i3k_game_context:GetYilueZhuanjingLv(pointsData)
    self.ui.zjLv:setText(i3k_get_string(18229, self.curYilueZJLv))
    --更新左侧列表的专精等级
    self.yilueBtnList[self.curYilueID].vars.count:setText(self.curYilueZJLv)
    local typeIconID = i3k_db_bagua_cfg.yilueType[typeID].lvSmallID
    self.yilueBtnList[self.curYilueID].vars.zhuanjing:setImage(g_i3k_db.i3k_db_get_icon_path(typeIconID))
    --设置底部易略点状态
    local data = g_i3k_game_context:GetBaguaYilue()
    self.yiluePointByTimes = data.buyChangePointNum
    self:updateBaguaYiluePoint()
    --刷新右侧属性
    self:updateYilueRightValueData(baseData, upData, baseOtherData, upOtherData, typeID)

    self.ui.giveUpBtn:setVisible(self.hasAddPointChange)
    self.ui.saveBtn:setVisible(self.hasAddPointChange)
end

--更新八卦易略右侧属性界面信息
function wnd_bagua:updateYilueRightValueData(baseData, upData, baseOtherData, upOtherData, typeID)
    local isPu = typeID == 4 and true or false
    --基础属性部分
    local baseList = {}
    local upList = {}
    self.ui.attribute_scroll:removeAllChildren()
    for i,v in ipairs(baseData) do
        local item1 = require("ui/widgets/baguayst2")()
        local _t = i3k_db_prop_id[v.id]
        item1.vars.name:setText(_t.desc)
        item1.vars.value:setText(v.value)
        item1.vars.otherValue:hide()
        item1.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
        item1.vars.typeIcon:setImage(g_i3k_db.i3k_db_get_icon_path(f_yilueTypeTable[i]))
        --加点附加属性值
        if baseOtherData[v.id] then
            item1.vars.otherValue:setText("+"..baseOtherData[v.id])
            item1.vars.otherValue:show()
        else
            item1.vars.otherValue:hide()
        end
        table.insert(baseList, item1)
        self.ui.attribute_scroll:addItem(item1)
    end
    --附加属性部分
    self.ui.attribute_scroll2:removeAllChildren()
    for i,v in ipairs(upData) do
        local item2 = require("ui/widgets/baguayst3")()
        local _t = i3k_db_prop_id[v.id]
        item2.vars.name:setText(_t.desc)
        item2.vars.value:setText(v.value)
        item2.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
        item2.vars.typeIcon:setImage(g_i3k_db.i3k_db_get_icon_path(f_yilueTypeTable[i]))
        local desc = i3k_get_string(18230, i3k_get_string(i3k_db_bagua_cfg.yilueType[i].nameID))
        local descJihuo = i3k_get_string(18259)
        --加点附加属性值
        if upOtherData[v.id] then
            item2.vars.otherValue:setText("+"..upOtherData[v.id])
            item2.vars.otherValue:show()
        else
            item2.vars.otherValue:hide()
        end
        --激活显示控制
        local baguaSkills = g_i3k_game_context:GetBaguaYilue().changeSkills
        local upType = g_i3k_game_context:getYilueSkillTypeID(self.curSkill_id, baguaSkills)
        local shuoMing = ""
        if (isPu or i ~= typeID) and upType ~= 1 then 
            item2.vars.jihuo:hide()
            item2.vars.typeIcon:disable()
            item2.vars.propImage:disable()
            item2.vars.name:setTextColor(noHaveColor) 
            item2.vars.value:setTextColor(noHaveColor)
            item2.vars.text1:setTextColor(noHaveColor)
            shuoMing = desc
        else
            item2.vars.jihuo:show()
            item2.vars.typeIcon:enable()
            item2.vars.propImage:enable()
            item2.vars.text1:setTextColor(g_COLOR_VALUE_GREEN)
            shuoMing = desc..descJihuo
        end
        item2.vars.text1:setText(shuoMing)
        table.insert(upList, item2)
        self.ui.attribute_scroll2:addItem(item2)
    end

end

--更新当前易略点数状态
function wnd_bagua:updateBaguaYiluePoint()
    local haveCount = self.yiluePointByTimes == 0 and 0 or i3k_db_bagua_yilue_pointCfg[self.yiluePointByTimes].point
    local count = haveCount - g_i3k_game_context:GetBaguaYilue().usedChangePoint
    for k,v in pairs(self.yilueAddPointTable) do
        count = count - v
    end
    self.curHavePoints = count
    self.ui.canUsePoint:setText(i3k_get_string(18231, count, haveCount))
end

--成功购买易略点弹出提示
function wnd_bagua:popByPointOkMsg()
    if self.yiluePointByTimes < #i3k_db_bagua_yilue_pointCfg then
        local count = i3k_db_bagua_yilue_pointCfg[1].point
        if self.yiluePointByTimes > 1 then
            count = i3k_db_bagua_yilue_pointCfg[self.yiluePointByTimes + 1].point - i3k_db_bagua_yilue_pointCfg[self.yiluePointByTimes].point
        end
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18269, count))
    end
end

--本地增加购买的点数
function wnd_bagua:addByYiluePoints()
    self.yiluePointByTimes = self.yiluePointByTimes + 1
    g_i3k_game_context:SetBaguaYilueBuyPointTimes(self.yiluePointByTimes)
    self:updateBaguaYiluePoint()
    if self.yiluePointByTimes == #i3k_db_bagua_yilue_pointCfg then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18232))
        self:checkAddPointBtnState()
    end
end

--检查八卦易略点数增加按钮状态
function wnd_bagua:checkAddPointBtnState()
    if self.yiluePointByTimes == #i3k_db_bagua_yilue_pointCfg then
        self.ui.addPointBtn:hide()
    else
        self.ui.addPointBtn:onClick(
        self,
        function()
            g_i3k_ui_mgr:OpenUI(eUIID_BaguaYilueByPoint)
            g_i3k_ui_mgr:RefreshUI(eUIID_BaguaYilueByPoint, self.yiluePointByTimes)
        end
        )
    end
end

--加点点击事件
function wnd_bagua:addYiluePoint(i)
    --local count = self.yilueAddPointTable[i] + 1
    if self.curHavePoints == 0 then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18233))
        return
    end
    if self.yilueBasePointTable[i] == #i3k_db_bagua_cfg.yilueAddPointPre then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18234))
        return
    end

    if self.curYilueZJLv < i3k_db_bagua_cfg.yilueAddPointPre[self.yilueBasePointTable[i] + 1].needZhuanjing then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18235, i3k_db_bagua_cfg.yilueAddPointPre[self.yilueBasePointTable[i] + 1].needZhuanjing))
        return
    end
    self.hasAddPointChange = true
    self.yilueAddPointTable[i] = self.yilueAddPointTable[i] + 1
    self.yilueBasePointTable[i] = self.yilueBasePointTable[i] + 1
    self:updateBaguaYiluePoint()

    self:RefreshCurYilueData(self.yilueBasePointTable)
    
end

--向服务器请求卸载技能
function wnd_bagua:unWearSkill(part)
    i3k_sbean.unequipYilueSkill(part)
end

function wnd_bagua:unWearSkill_local(part)
    g_i3k_game_context:setBaguaJinengID(part, 0)--卸载技能
    self:setYilueSkill(0)
end

--放弃加点
function wnd_bagua:onGiveUpBtnClick(sender)
    self.hasAddPointChange = false
    self:resetAddPointTable()
    local yilueData = g_i3k_game_context:getPartStrength() --获取已装备的八卦信息
    self:RefreshCurYilueData(yilueData[self.curYilueID].changeInfo.propPoints)
    if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
        g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
    end
end

--请求保存
function wnd_bagua:onSaveBtnClick(sender)
    local typeID = g_i3k_game_context:GetYilueType(self.yilueBasePointTable)
    if self.curSkill_id ~= 0 and i3k_db_bagua_yilue_skill[self.curSkill_id].skillType ~= typeID then
        local fun = (function(ok)
            if ok then
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "unWearSkill_local", self.curYilueID)
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "sendSavePoint", self.yilueBasePointTable)
            end
        end)
        local msg = i3k_get_string(18236)
        g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
    else
        self:sendSavePoint(self.yilueBasePointTable)
    end
end

function wnd_bagua:sendSavePoint(points)
    i3k_sbean.SaveYiluePoint(self.curYilueID, points)
end

--重置当前部位易略点数
function wnd_bagua:onResetPointClick(sender)
    g_i3k_ui_mgr:OpenUI(eUIID_YilueResetPoint)
    g_i3k_ui_mgr:RefreshUI(eUIID_YilueResetPoint, self.curYilueID)
end


--保存成功操作
function wnd_bagua:saveOtherPoint()
    self.hasAddPointChange = false
    self.ui.giveUpBtn:hide()
    self.ui.saveBtn:hide()
    local usePoints = 0 --统计此次保存点数时一共增加的点数
    for i=1,3 do
        --self.yilueBasePointTable[i] = self.yilueBasePointTable[i] + self.yilueAddPointTable[i]
        usePoints = usePoints + self.yilueAddPointTable[i]
    end
    g_i3k_game_context:AddBaguaYilueUsePoint(usePoints)
    self:resetAddPointTable()
    self:RefreshCurYilueData(self.yilueBasePointTable)
end

function wnd_bagua:resetAddPointTable()
    self.yilueAddPointTable = {0,0,0}
    self.yilueBasePointTable = {}
    local yilueData = g_i3k_game_context:getPartStrength() --获取已装备的八卦信息
    for _,v in ipairs(yilueData[self.curYilueID].changeInfo.propPoints) do
        table.insert(self.yilueBasePointTable, v)
    end
    self:updateBaguaYiluePoint()
end

function wnd_bagua:onYilueDescBtnClick()
    g_i3k_ui_mgr:OpenUI(eUIID_YilueTips)
    g_i3k_ui_mgr:RefreshUI(eUIID_YilueTips)
end

function wnd_bagua:onYilueSkillClick()
    if self.hasAddPointChange then
        local fun = (function(ok)
            if ok then
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "onGiveUpBtnClick")
                g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bagua, "openSkillView")
            end
        end)
        local msg = string.format(i3k_get_string(18226))
        g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
    else
        self:openSkillView()
    end
end

function wnd_bagua:openSkillView()
    g_i3k_ui_mgr:OpenUI(eUIID_YilueSkill)
    g_i3k_ui_mgr:RefreshUI(eUIID_YilueSkill)
end

function wnd_create(layout, ...)
    local wnd = wnd_bagua.new()
    wnd:create(layout, ...)
    return wnd
end
