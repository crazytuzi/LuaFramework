local equipMakeSelectItemLayer = class("equipMakeSelectItemLayer",require ("src/TabViewLayer"))
--define
local padding_outer = 25
local table_view_width = 200
local tag_button = 10--因为本tag的节点是加在本layer下的node中，因此出于代码简洁度和耦合度低的考虑，没有必要对本tag在全局进行声明
local width_between_slider = 15
local button_width = 275--219
local cell_width = (button_width + width_between_slider * 2)
local cell_height = 105
local margin_top_buttom = 8
local background_height = 436
local label_toLeft = 93
local type_da_zao = 1
local type_he_cheng = 2
local tag_redDot = 11
function equipMakeSelectItemLayer:ctor(equip, school, sex, q_sort)
	local MpropOp = require("src/config/propOp")
    local forge = require("src/config/Forge")
    self.school = school
    self.selectIdx = 0  --当前点击的button index
	self.equipTable = {}
    local table_equipCfg = {}
    if q_sort == type_da_zao then
        --打造
        local equip_tab = {}
        for k, v in pairs(require("src/config/equipCfg")) do
            equip_tab[v.q_id] = v
        end
        local prop_tab = {}
        for k, v in pairs(require("src/config/propCfg")) do
            prop_tab[v.q_id] = v
        end
        for k_forge, v_forge in pairs(forge) do
            while true do
                if v_forge.q_sort ~= q_sort then
                    break
                end
                local table_item = assert(loadstring("return " .. v_forge.q_itemID))()
                local bool_item_more_than_one = false
                for k_forgable_item, v_forgable_item in pairs(table_item) do
                    if table.size(v_forgable_item) > 1 then
                        bool_item_more_than_one = true
                        break
                    end
                end
                --如果子item多于一个,代表这是一个命运打造物品
                local forgable_item_id_in_table = nil
                for k_forgable_item, v_forgable_item in pairs(bool_item_more_than_one and table_item[school] or table_item[1]) do
                    forgable_item_id_in_table = k_forgable_item--只取得任何一个id加入装备列表
                    break
                end
                local v = equip_tab[forgable_item_id_in_table]
                v.forge_id = k_forge
                if v == nil then
                    print("equipCfg.lua not match with Forge.lua ,can not find equip id: " .. forgable_item_id_in_table)
                    break
                end
                if equip ~= v.q_kind then
                    break
                end
                if not (v.q_sex == sex or v.q_sex == 0) then
                    break
                end
                if not (prop_tab[v.q_id].q_job == school or prop_tab[v.q_id].q_job == 0) then
                    break
                end
                table.insert(table_equipCfg, v)
                break
            end
        end
    else
        --合成
        local prop_tab = {}
        for k, v in pairs(require("src/config/propCfg")) do
            prop_tab[v.q_id] = v
        end
        for k_forge, v_forge in pairs(forge) do
            while true do
                if v_forge.q_sort ~= q_sort then
                    break
                end
                local table_item = assert(loadstring("return " .. v_forge.q_itemID))()
                local forgable_item_id_in_table = nil
                for k_forgable_item, v_forgable_item in pairs(table_item[1]) do
                    forgable_item_id_in_table = k_forgable_item
                    break
                end
                if equip ~= v_forge.q_menu then
                    break
                end
                local v = prop_tab[forgable_item_id_in_table]
                v.forge_id = k_forge
                if v == nil then
                    print("propCfg.lua not match with Forge.lua ,can not find prop id: " .. forgable_item_id_in_table)
                    break
                end
                if not (v.q_sex == sex or v.q_sex == 0) then
                    break
                end
                if not (v.q_job == school or v.q_job == 0) then
                    break
                end
                table.insert(table_equipCfg, v)
                break
            end
        end
    end
	table.sort(table_equipCfg, function(a , b) return a.forge_id < b.forge_id end)
    for k, v in ipairs(table_equipCfg) do
        self.equipTable[#self.equipTable + 1] = v.q_id
    end
    self.num = #self.equipTable
    self:createTableView(self, cc.size(cell_width, background_height - margin_top_buttom * 2), cc.p(145 + margin_top_buttom - width_between_slider, padding_outer + margin_top_buttom), true, true)
    local distance_arrow_to_table_view = 8
    local bgsize = self:getContentSize()
    self.m_upBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() + self:getTableView():getViewSize().height + distance_arrow_to_table_view
        )
        , function()
            --点击向上按钮事件
        end
    )
    self.m_upBtn:setRotation(-90)
    self.m_upBtn:setVisible(false)
	self.m_upBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 5)), cc.MoveBy:create(0.3, cc.p(0, - 5)))))
	self.m_downBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() - distance_arrow_to_table_view
        )
        , function()
            --点击向下按钮事件
        end
    )
    self.m_downBtn:setRotation(90)
    self.m_downBtn:setVisible(self:getTableView():getContentSize().height > self:getTableView():getViewSize().height)
	self.m_downBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, - 5)), cc.MoveBy:create(0.3, cc.p(0, 5)))))
	local func_refreshRedDot = function()
        for k, cell in pairs(self:getTableView():getContainer():getChildren()) do
            --查看所消耗的材料
            local bool_enough = isForgeMaterialEnough(self.equipTable[cell:getIdx() + 1], self.school)
            if not bool_enough then
                cell:getChildByTag(tag_button):removeChildByTag(tag_redDot)
            elseif not cell:getChildByTag(tag_button):getChildByTag(tag_redDot) then
                local redDot = createSprite(cell:getChildByTag(tag_button), "res/component/flag/red.png" ,cc.p(cell:getChildByTag(tag_button):getContentSize().width - 18, cell:getChildByTag(tag_button):getContentSize().height - 21), cc.p(0.5, 0.5))
                redDot:setTag(tag_redDot)
            end
        end
    end
    local func_changed_item = function(observable, event, pos, pos1, new_grid)
        if not (event == "-" or event == "+" or event == "=") then return end
        func_refreshRedDot()
    end
    local func_changed_gold = function(observable, attrId, objId, isMe, attrValue)
        if not isMe then return end
        if attrId ~= PLAYER_MONEY and attrId ~= PLAYER_VITAL then return end
		func_refreshRedDot()
    end
    local bag = MPackManager:getPack(MPackStruct.eBag)
    self:registerScriptHandler(function(event)
        if event == "enter" then
            bag:register(func_changed_item)
            MRoleStruct:register(func_changed_gold)
        elseif event == "exit" then
            bag:unregister(func_changed_item)
            MRoleStruct:unregister(func_changed_gold)
        end
    end)
end

function equipMakeSelectItemLayer:scrollViewDidScroll(view)
    if not (self.m_upBtn and self.m_downBtn) then
        return
    end
	local tableTemp = self:getTableView()
	local contentPos = tableTemp:getContentOffset()
    if tableTemp:getContentSize().height <= tableTemp:getViewSize().height then
        self.m_upBtn:setVisible(false)
		self.m_downBtn:setVisible(false)
	elseif contentPos.y >= 0 then
		self.m_upBtn:setVisible(true)
		self.m_downBtn:setVisible(false)
    elseif contentPos.y <=  -(tableTemp:getContentSize().height - tableTemp:getViewSize().height) then
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(false)
	else
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(true)
	end
end

function equipMakeSelectItemLayer:cellSizeForTable(table,idx)
    return cell_height, cell_width
end

function equipMakeSelectItemLayer:numberOfCellsInTableView(table)
    return self.num
end

function equipMakeSelectItemLayer:tableCellTouched(table, cell)
    local index = cell:getIdx()
    local num = index + 1
    if self.selectIdx == index or not self:isVisible() then
        return
    end
    AudioEnginer.playTouchPointEffect()
    local old_cell = table:cellAtIndex(self.selectIdx)
    if old_cell then
        local button = tolua.cast(old_cell:getChildByTag(tag_button),"cc.Sprite")
        button:setTexture("res/common/table/cell36.png")
    end
    local button = cell:getChildByTag(tag_button)
    button:setTexture("res/common/table/cell36_sel.png")
    self:getParent():showItem(self.equipTable[num])
    self.selectIdx = index
end

function equipMakeSelectItemLayer:tableCellAtIndex(tb, idx)
    local cell = tb:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell, "res/common/table/cell36.png", cc.p(cell_width / 2, cell_height / 2))
    button:setTag(tag_button)
    if idx == self.selectIdx then
        --如果重新加上删除的按钮,需要重新设置状态
        button:setTexture("res/common/table/cell36_sel.png")
    end
    local MpropOp = require("src/config/propOp")
    local tabTemp = self.equipTable
    local idx_lua = idx + 1
	local Mprop = require "src/layers/bag/prop"
	local icon = Mprop.new(
	{
		protoId = self.equipTable[idx_lua]
	})
	icon:setPosition(cc.p(button:getContentSize().height / 2, button:getContentSize().height / 2))
	local nameStr = MpropOp.name(self.equipTable[idx_lua])
	createLabel(button, nameStr, cc.p(label_toLeft, button:getContentSize().height / 2), cc.p(0, 0.5), 20, nil, nil, nil, MpropOp.nameColor(self.equipTable[idx_lua]))
	button:addChild(icon)
    local bool_enough = isForgeMaterialEnough(self.equipTable[idx_lua], self.school)
    if bool_enough then
        local redDot = createSprite(button, "res/component/flag/red.png" ,cc.p(button:getContentSize().width - 18, button:getContentSize().height - 21), cc.p(0.5, 0.5))
        redDot:setTag(tag_redDot)
    end
	return cell
end

return equipMakeSelectItemLayer