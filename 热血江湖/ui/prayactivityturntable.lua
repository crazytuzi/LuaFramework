-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_prayActivityTurntable = i3k_class("wnd_prayActivityTurntable", ui.wnd_base)

local COST_WIDGETS = "ui/widgets/qifu2t"


function wnd_prayActivityTurntable:ctor()
    self.prayData = nil
    self.selectDropId = 0
    self.prayDroptableData = nil
    self.drops = {}
    self.animations = {}
    self.drop = nil
    self.dropId2Index = {}
end

function wnd_prayActivityTurntable:configure()
    local widgets = self._layout.vars
    self.startBtn = widgets.startBtn
    self.closeBtn = widgets.closeBtn
    self.lastTimes = widgets.lastTimes
    self.costItems = widgets.costItems
    self.costText = widgets.costText
    self.bgImage = widgets.bgImage
    self.npcmodule = widgets.npcmodule
    self.timeText = widgets.timeText
    self.descText = widgets.descText
    self.turn = widgets.turn
    self:initDropTable( widgets )
    self:initAnis()
end

function wnd_prayActivityTurntable:initDropTable( widgets )
    for i=1,16 do
        local btn = "btn" .. i
        local icon = "icon" .. i
        local count = "count" .. i
        local selected = "selected" .. i
        local itemBg = "itemBg" .. i

        self.drops[i] = {
            itemBg = widgets[itemBg],
            btn   = widgets[btn],
            icon = widgets[icon],
            count = widgets[count],
            selected = widgets[selected],
        }
    end
end

function wnd_prayActivityTurntable:initAnis()
    self.dakai = self._layout.anis.c_dakai
    for i=1,16 do
        local c_cj = "c_cj" .. i
        self.animations[i] = self._layout.anis[c_cj]
    end
end

function wnd_prayActivityTurntable:refresh(data)
    self.dakai.play()
    self.prayData = data.prayData
    self.selectDropId = data.selectDropId
    self.prayDroptableData = i3k_db_pray_activity_rewards[self.selectDropId]
    self.bgImage:setImage(i3k_db.i3k_db_get_icon_path(self.prayData.bgImage))
    for k,v in ipairs(self.drops) do
        local drop = self.prayDroptableData.drops[k]
        if drop == nil then
            v.icon:hide()
            v.count:hide()
            v.btn:setVisible(false)
            v.selected:hide()
        else
            local rank = g_i3k_db.i3k_db_get_common_item_rank(drop[1])
            v.itemBg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
            if self.dropId2Index[drop[1]] ~= nil then
                table.insert(self.dropId2Index[drop[1]], k)
            else
                local indexTable = {k,}
                self.dropId2Index[drop[1]] = indexTable
            end
            v.icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(drop[1]),i3k_game_context:IsFemaleRole())
            -- local countTxt = ""
            -- if drop[2] == drop[3] then
            --     countTxt = drop[2]
            -- else
            --     countTxt = drop[2] .. "~" .. drop[3]
            -- end
            v.count:hide()
            -- v.count:setText(countTxt)
            v.btn:onClick(self, self.itembtn, drop[1])
        end
    end
    local times = self.prayData.limitTimes - g_i3k_game_context:GetPrayTimes(self.prayData.ID)
    self.lastTimes:setText(i3k_get_string(15398, times))
	-- self.lastTimes:setTextColor(self.prayData.textColor)
	-- self.costText:setTextColor(self.prayData.textColor)
	if self.prayData.isShowTime == 0 then
		self.timeText:hide()
	else
		self.timeText:show()
		self:setTimeText()
	end
    self.descText:setText(self.prayData.titleText)
	self.descText:setTextColor(self.prayData.textColor)
    self.startBtn:onClick(self, self.okbtn)
    self.closeBtn:onClick(self, self.cancel)
    self.costItems:removeAllChildren()
    self.costItems:addItemAndChild(COST_WIDGETS,1,#self.prayData.needItems)
    ui_set_hero_model(self.npcmodule, data.npcModule)
    self:updateCostItems()
end

function wnd_prayActivityTurntable:setTimeText()
    local startTime = self.prayData.startTime
    local endTime = self.prayData.endTime
    local startY = string.sub(startTime, 1, 4)
    local startMon = string.sub(startTime, 6, 7)
    local startD = string.sub(startTime, 9, 10)
    local startH = string.sub(startTime, 12, 13)
    local endY = string.sub(endTime, 1, 4)
    local endMon = string.sub(endTime, 6, 7)
    local endD = string.sub(endTime, 9, 10)
    local endH = string.sub(endTime, 12, 13)
    local timeStr = ""
    if startY == endY then
        timeStr = string.format("%s月%s日%s时 - %s月%s日%s时", startMon, startD, startH, endMon, endD, endH)
    else
        timeStr = string.format("%s年%s月%s日%s时 - %s年%s月%s日%s时", startY, startMon, startD, startH, endY, endMon, endD, endH)
    end
	self.timeText:setText(timeStr)
    -- self.timeText:setTextColor(self.prayData.textColor)
end

function wnd_prayActivityTurntable:updateCostItems( )
    self.costItems:removeAllChildren()
    self.costItems:addItemAndChild(COST_WIDGETS,1,#self.prayData.needItems)
    local cells = self.costItems:getAllChildren()
    for k,v in ipairs(self.prayData.needItems) do
        local widgets = cells[k].vars
        widgets.bt:onClick(self, self.itembtn, v[1])
        widgets.item_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(v[1]))
        widgets.item_count:setText("×" .. i3k_get_num_to_show(v[2]))
        widgets.suo:setVisible(v[1] > 0)
        if v[2] > g_i3k_game_context:GetCommonItemCanUseCount(v[1]) then
            widgets.item_count:setTextColor(g_i3k_get_red_color())
        else
            widgets.item_count:setTextColor("ffffffff")
        end
    end
end

function wnd_prayActivityTurntable:okbtn(sender)
    if g_i3k_game_context:GetLevel() < self.prayData.limitLvl then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15395, self.prayData.limitLvl))
        return
    end
    local times = g_i3k_game_context:GetPrayTimes(self.prayData.ID)
    if times >= self.prayData.limitTimes then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15396, self.prayData.limitLvl))
        return
    end
    if g_i3k_game_context:GetBagIsFull() then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15404, self.prayData.limitLvl))
        return
    end
    for _,v in ipairs(self.prayData.needItems) do
        local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(v[1])
        if itemCnt < v[2] then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15400, g_i3k_db.i3k_db_get_common_item_name(v[1]), v[2]))
            return
        end
    end
    if not g_i3k_checkIsInDateByStringTime(self.prayData.startTime, self.prayData.endTime) then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15422))
        return
    end
    i3k_sbean.join_npc_pray_req_send( self.prayData.ID, self.selectDropId )
end

function wnd_prayActivityTurntable:cancel(sender)
    self:onCloseUI()
end

function wnd_prayActivityTurntable:itembtn(sender, itemId)
    g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_prayActivityTurntable:showResult( ok, drop, times )
    self.startBtn:stateToPressedAndDisable(true)
    self.closeBtn:stateToPressedAndDisable()
    self.drop = drop
    -- local index = self.dropId2Index[drop.id]
    local index = 1
    local indexTable = self.dropId2Index[drop.id]
    if #indexTable > 1 then
        index = indexTable[i3k_engine_get_rnd_u(1, #indexTable)]
    else
        index = indexTable[1]
    end
    local currAnis = self.animations[index]
    local delay = cc.DelayTime:create((5800 + (index - 1) * 100) / 1000)
    local seq = cc.Sequence:create(cc.CallFunc:create(function ()
        currAnis.play()
    end), delay, cc.CallFunc:create(function ()
        g_i3k_ui_mgr:ShowGainItemInfo({self.drop,})
        self.lastTimes:setText(i3k_get_string(15398, self.prayData.limitTimes - times))
        self:updateCostItems()
        currAnis.stop()
        self.startBtn:stateToNormal()
        self.closeBtn:stateToNormal()
    end))
    self:runAction(seq)
end

function wnd_create(layout, ...)
    local wnd = wnd_prayActivityTurntable.new()
    wnd:create(layout, ...)
    return wnd
end
