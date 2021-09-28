local equipMakeSelectTypeLayer = class("equipMakeSelectTypeLayer",require ("src/TabViewLayer"))
--define 常量
local posX_item_icon = 468
local posY_item_icon = 242
local padding_outer = 25
local margin_top_buttom = 4
local tag_button = 10
local tag_arrow = 20
local tag_richText = 21
local table_view_width = 200
local cellHeight, cellWidth = 68, 104
local posX_cover, posY_cover = 613, 259
local bag = MPackManager:getPack(MPackStruct.eBag)
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MMenuButton = require "src/component/button/MenuButton"
local tag_redDot = 11
function equipMakeSelectTypeLayer:ctor(params)
    self.equipNum = {}
    self.myShop = {}
    local table_forge = require("src/config/Forge")
    for k, v in pairs(table_forge) do
        while true do
            if v.q_sort ~= params.q_sort then
                break
            end
            local bool_found_item_in_equipNum = false
            for k_equipNum, v_equipNum in pairs(self.equipNum )do
                if v_equipNum == v.q_menu then
                    bool_found_item_in_equipNum = true
                    break
                end
            end
            if bool_found_item_in_equipNum then
                break--去重
            end
            table.insert(self.equipNum, v.q_menu)
            table.insert(self.myShop, v.q_menuName)
            break
        end
    end
    createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(17, 17),
        cc.size(790, 454),
        5
    )
    --经图上测量,外侧+12像素padding = 29
    createScale9Sprite(
        self,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(padding_outer, padding_outer),
        cc.size(112, 436),
        cc.p(0, 0)
    )
    self.q_sort = params.q_sort
    self.right_panel = createSprite(self, "res/common/bg/bg80-1.jpg", cc.p(822 - padding_outer - 652 / 2, padding_outer + 436 / 2))
    self.selectIdx = 0  --当前点击的button index
    self.layerMan = {}      --当前的具体装备列表层
    self.tempForOld = 1     --之前选择的种类id
    self.sex = MRoleStruct:getAttr(PLAYER_SEX)          --性别
    self.school = MRoleStruct:getAttr(ROLE_SCHOOL)      --职业
    local sprite_cover = cc.Sprite:create("res/common/bg/bg80.png")
    sprite_cover:setPosition(cc.p(posX_cover, posY_cover))
    self:addChild(sprite_cover)
    local lineBg = createSprite(self, "res/common/bg/bg27-4-2.png", cc.p(posX_cover, 180), cc.p(0.5, 0.5))
	createLabel(lineBg, game.getStrByKey("wr_use"), getCenterPos(lineBg), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
    self:createTableView(self, cc.size(table_view_width, 436 - margin_top_buttom * 2), cc.p(padding_outer - (table_view_width - 112) / 2, padding_outer + margin_top_buttom), true)
    --底有1像素白色反光,看上去下边比较窄
    self:setTitleEqu(1)
    function func_refreshRedDot()
        for k, cell in pairs(self:getTableView():getContainer():getChildren()) do
            local q_menu = self.equipNum[cell:getIdx() + 1]
            local forge = require("src/config/Forge")
            --遍历本种类的子item,如果有一个材料足够，那么本类就显示红点
            local bool_has_one_item_enough = false
            for k, v in pairs(forge) do
                while true do
                    if v.q_sort ~= self.q_sort then
                        break
                    end
                    if v.q_menu ~= q_menu then
                        break
                    end
                    --查看所消耗的材料,命运打造的3职业消耗相同
                    local q_forgeCost = assert(loadstring("return " .. v.q_forgeCost))()
                    --如果材料足够就显示红点
                    local bool_enough = true
                    for item_id, item_count in pairs(q_forgeCost) do
                        if item_id == 777777 and item_count > MRoleStruct:getAttr(PLAYER_VITAL) then--声望
                            bool_enough = false
                            break
                        end
                        if item_id == 999998 and item_count > MRoleStruct:getAttr(PLAYER_MONEY) then--金币
                            bool_enough = false
                            break
                        end
                        if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
                            bool_enough = false
                            break
                        end
                    end
                    if bool_enough then
                        bool_has_one_item_enough = true
                    end
                    break
                end
                if bool_has_one_item_enough then
                    break
                end
            end
            if not bool_has_one_item_enough then
                cell:getChildByTag(tag_button):removeChildByTag(tag_redDot)
            elseif not cell:getChildByTag(tag_button):getChildByTag(tag_redDot) then
                local redDot = createSprite(cell:getChildByTag(tag_button), "res/component/flag/red.png" ,cc.p(cell:getChildByTag(tag_button):getContentSize().width - 18, cell:getChildByTag(tag_button):getContentSize().height - 21), cc.p(0.5, 0.5))
                redDot:setTag(tag_redDot)
            end
        end
    end
    local func_changed_item = function(observable, event, pos, pos1, new_grid)
        if not (event == "-" or event == "+" or event == "=") then return end
        self:refreshText()
        func_refreshRedDot()
    end
    local func_changed_gold = function(observable, attrId, objId, isMe, attrValue)
        if not isMe then return end
        if attrId ~= PLAYER_MONEY and attrId ~= PLAYER_VITAL then return end
		self:refreshText()
        func_refreshRedDot()
    end
    self:registerScriptHandler(function(event)
	    if event == "enter" then
		    g_msgHandlerInst:registerMsgHandler(ITEM_SC_COMPOUNDRET, function(buff)
			    local t = g_msgHandlerInst:convertBufferToTable("ItemCompoundRetProtocol", buff)
			    local result = t.result
			    dump(result, "result")
			    if result == 0 then
				    return
			    end
                --[[
                local sprite_cover = cc.Sprite:create("res/common/bg/bg80.png")
                sprite_cover:setPosition(cc.p(posX_cover, posY_cover))
                self:addChild(sprite_cover)
                ]]
                local array_sequence = {}
                local distance_shake = 2--<5  <2.5
                local interval_shake = 6 / 60.0-->3 >6  <12   <20
                math.randomseed(os.time())
                local degree, last_degree = 0, 0
                for i = 1, 9 do
                    --如果两次抖动过于接近,不服和正常反弹抖动的一般规律,因此两次抖动所朝向的角度相差不可小于90度
                    while(math.abs(degree - last_degree) < 90.0 / 180 * math.pi or math.abs(degree - last_degree) > 270.0 / 180 * math.pi) do
                        degree = math.random() * math.pi * 2
                    end
                    last_degree = degree
                    table.insert(
                        array_sequence
                        , cc.MoveTo:create(
                            interval_shake
                            , cc.p(
                                posX_cover + math.cos(degree) * distance_shake
                                , posY_cover + math.sin(degree) * distance_shake
                            )
                        )
                    )
                end
                table.insert(
                    array_sequence
                    , cc.MoveTo:create(interval_shake, cc.p(posX_cover, posY_cover))
                )
                --[[
                table.insert(
                    array_sequence
                    , cc.RemoveSelf:create()
                )
                ]]
                sprite_cover:runAction(cc.Sequence:create(
                    array_sequence
                ))
                --[[
                local animateSpr = Effects:create(false)
				animateSpr:playActionData("makeequipeff", 21, 1.9, 1)
				addEffectWithMode(animateSpr,1)
                animateSpr:setPosition(cc.p(posX_cover, posY_cover))
                animateSpr:runAction(cc.Sequence:create(
                    cc.DelayTime:create(1.9)
                    , cc.RemoveSelf:create()
                ))
                self:addChild(animateSpr)
                ]]
				--合成成功特效
                local tag_fontEffect = 1234
                local tag_action_showEffect = 4567
                if not self:getChildByTag(tag_fontEffect) and not self:getActionByTag(tag_action_showEffect) then
                    local posX_text_success, posY_text_success = 425, 280
                    local action_showEffect = cc.Sequence:create(
                        cc.DelayTime:create(1)
                        , cc.CallFunc:create(function()
                            local sprite_text_success, animateSpr = ShowEffectFont(self, cc.p(posX_text_success, posY_text_success), params.q_sort == 1 and "forge_succeed.png" or "compound_succeed.png", 3)
                            sprite_text_success:setTag(tag_fontEffect)
                        end)
                    )
                    action_showEffect:setTag(tag_action_showEffect)
                    self:runAction(action_showEffect)
                end
		    end)
            bag:register(func_changed_item)
            MRoleStruct:register(func_changed_gold)
	    elseif event == "exit" then
		    g_msgHandlerInst:registerMsgHandler(ITEM_SC_COMPOUNDRET, nil)
            bag:unregister(func_changed_item)
            MRoleStruct:unregister(func_changed_gold)
	    end
    end)
    --导航至对应物品
    if params == nil or (type(params) == "table" and next(params) == nil) or params.protoId == nil then
        return
    end
    local prop_tab = {}
    for k, v in pairs(require("src/config/propCfg")) do
        prop_tab[v.q_id] = v
    end
    local v = prop_tab[params.protoId]
    if v == nil then
        return
    end
    if not ((v.q_sex == MRoleStruct:getAttr(PLAYER_SEX) or v.q_sex == 0) and (v.q_job == MRoleStruct:getAttr(ROLE_SCHOOL) or v.q_job == 0)) then
        return
    end
    local q_kind
    for k_forge, v_forge in pairs(require("src/config/Forge")) do
        while true do
            if bool_showable == false then
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
            for k_forgable_item, v_forgable_item in pairs(bool_item_more_than_one and table_item[self.school] or table_item[1]) do
                if params.protoId == k_forgable_item then
                    q_kind = v_forge.q_menu
                    break
                end
            end
            break
        end
    end
    --点击对应kind
    local target_kind_index
    for kind_index, v in ipairs(self.equipNum) do
        if(v == q_kind) then
            target_kind_index = kind_index
            break
        end
    end
    local max_offset = math.max(0, self:getTableView():getViewSize().height - self:getTableView():getContentSize().height)
    self:getTableView():setContentOffset({x = 0, y = math.min(max_offset, self:getTableView():getViewSize().height - self:getTableView():getContentSize().height + (target_kind_index - 1) * cellHeight)})
    self:tableCellTouched(
        self:getTableView()
        , self:getTableView():cellAtIndex(target_kind_index - 1)
    )
    --点击对应item
    local selectedLayer = self.layerMan[self.selectIdx + 1]
    local target_item_index
    for item_index, v in ipairs(selectedLayer.equipTable) do
        if(v == params.protoId) then
	        target_item_index = item_index
		    break
	    end
    end
    local item_tableView_height, item_tableView_width = selectedLayer:cellSizeForTable(selectedLayer:getTableView(), 0)
    max_offset = math.max(0, selectedLayer:getTableView():getViewSize().height - selectedLayer:getTableView():getContentSize().height)
    selectedLayer:getTableView():setContentOffset({
        x = 0
        , y = math.min(max_offset, selectedLayer:getTableView():getViewSize().height - selectedLayer:getTableView():getContentSize().height + (target_item_index - 1) * item_tableView_height)
    })
    selectedLayer:tableCellTouched(
        selectedLayer:getTableView()
        , selectedLayer:getTableView():cellAtIndex(target_item_index - 1)
    )
end

function equipMakeSelectTypeLayer:refreshText()
    --实际上会导致多次刷新，每种道具或数值改变都会导致刷新，但是为了简化代码，经过测试多次刷新带来的性能损耗轻微，所以选择忽视
    --认为第一次打开界面必然选中物品，这里不做self.q_forgeCost空值判断
    while self.right_panel:getChildByTag(tag_richText) do
        self.right_panel:removeChildByTag(tag_richText)
    end
    local pos_x_left, pos_x_right = 311, 545
    --to check:暂时没有加入自动调整位置
    --按照策划要求缩小了文字
    local label_font_size = 18
    local line_height = 22
    local richTextSize_width = 960
    local pos_y_current_line = 123--第一行的位置
    for material_id, material_cost in pairs(self.q_forgeCost) do
        while true do
            if material_id == 777777 then--声望
                --todo:测试声望减少变红
                local pos_y_target_item_line = pos_y_current_line
                local own_num_sheng_wang = MRoleStruct:getAttr(PLAYER_VITAL)
                local cost_num_sheng_wang = self.q_forgeCost[material_id]
                local richText_cost_sheng_wang = require("src/RichText").new(self.right_panel, cc.p(pos_x_left, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_cost_sheng_wang:setTag(tag_richText)
                richText_cost_sheng_wang:setAutoWidth()
                richText_cost_sheng_wang:addText(
                    "^c(lable_yellow)" .. game.getStrByKey("consume") .. ":^"
                    .. "^c(yellow)" .. MpropOp.name(material_id) .. "^"
                    .. (own_num_sheng_wang >= cost_num_sheng_wang and "^c(green)x" or "^c(red)x") .. numToFatString(cost_num_sheng_wang) .. "^"
                )
                richText_cost_sheng_wang:format()
                local richText_own_sheng_wang = require("src/RichText").new(self.right_panel, cc.p(pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_own_sheng_wang:setTag(tag_richText)
                richText_own_sheng_wang:setAutoWidth()
                richText_own_sheng_wang:addText(
                    "^c(lable_yellow)" .. game.getStrByKey("own") .. ":^"
                    .. numToFatString(own_num_sheng_wang)
                )
                richText_own_sheng_wang:format()
                break
            elseif material_id == 999998 then--金币
                local pos_y_target_item_line = pos_y_current_line
                local own_num_gold = MRoleStruct:getAttr(PLAYER_MONEY)
                local cost_num_gold = self.q_forgeCost[material_id]
                local richText_cost_gold = require("src/RichText").new(self.right_panel, cc.p(pos_x_left, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_cost_gold:setTag(tag_richText)
                richText_cost_gold:setAutoWidth()
                richText_cost_gold:addText(
                    "^c(lable_yellow)" .. game.getStrByKey("consume") .. ":^"
                    .. "^c(yellow)" .. MpropOp.name(material_id) .. "^"
                    .. (own_num_gold >= cost_num_gold and "^c(green)x" or "^c(red)x") .. numToFatString(cost_num_gold) .. "^"
                )
                richText_cost_gold:format()
                local richText_own_gold = require("src/RichText").new(self.right_panel, cc.p(pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_own_gold:setTag(tag_richText)
                richText_own_gold:setAutoWidth()
                richText_own_gold:addText(
                    "^c(lable_yellow)" .. game.getStrByKey("own") .. ":^"
                    .. numToFatString(own_num_gold)
                )
                richText_own_gold:format()
                break
            end
            local pos_y_target_item_line = pos_y_current_line
            local own_num_item = bag:countByProtoId(material_id)
            local cost_num_item = self.q_forgeCost[material_id]
            local richText_cost_item = require("src/RichText").new(self.right_panel, cc.p(pos_x_left, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
            richText_cost_item:setTag(tag_richText)
            richText_cost_item:setAutoWidth()
            richText_cost_item:addText(
                "^c(lable_yellow)" .. game.getStrByKey("consume") .. ":^"
            )
            richText_cost_item:addTextItem(MpropOp.name(material_id), MColor.yellow, false, false, true, function()
                local Mtips = require "src/layers/bag/tips"
			    Mtips.new(
			    { 
				    protoId = material_id,
				    pos = cc.p(0, 0),
			    })
            end)
            richText_cost_item:addText(
                (own_num_item >= cost_num_item and "^c(green)x" or "^c(red)x") .. numToFatString(cost_num_item) .. "^"
            )
            richText_cost_item:format()
            --加入超链接下方的横线
            local linkNode = richText_cost_item:getChildren()[1]:getChildren()[1]:getChildren()[3]--link item道具名
            drawUnderLine(linkNode, MColor.yellow)
		    -- local label = cc.Label:createWithTTF("_", g_font_path, 18)
		    -- label:setAnchorPoint(cc.p(0, 0))
		    -- label:setPosition(cc.p(linkNode:getPositionX(), linkNode:getPositionY() - 2))
		    -- local scale = linkNode:getContentSize().width / label:getContentSize().width
		    -- label:setScaleX(scale)
		    -- label:setColor(MColor.yellow)
      --       linkNode:getParent():addChild(label)
            local richText_own_item = require("src/RichText").new(self.right_panel, cc.p(pos_x_right, pos_y_target_item_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
            richText_own_item:setTag(tag_richText)
            richText_own_item:setAutoWidth()
            richText_own_item:addText(
                "^c(lable_yellow)" .. game.getStrByKey("own") .. ":^"
                .. numToFatString(own_num_item)
            )
            richText_own_item:format()
            break
        end
        pos_y_current_line = pos_y_current_line - line_height
    end
end

function equipMakeSelectTypeLayer:showItem(q_id)
    local tag_icon = 15
    local tag_item_name = 16
    local protoId = q_id
    self.right_panel:removeAllChildren()--icon在特效图的上层需要单独remove,不放在right_panel中
    self:removeChildByTag(tag_icon)
    self:removeChildByTag(tag_item_name)
    -- 祝福消耗材料
    local table_forge = require("src/config/Forge")
    local icon = cc.Sprite:create(MpropOp.icon(protoId))
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:registerScriptHandler(
        function(touch, event)
            return cc.pGetDistance(icon:getParent():convertToNodeSpace(touch:getLocation()), cc.p(icon:getPosition())) < 34
		end
        , cc.Handler.EVENT_TOUCH_BEGAN
    )
    listenner:registerScriptHandler(
        function(touch, event)
		    local Mtips = require "src/layers/bag/tips"
		    Mtips.new({protoId = protoId})
		end
        , cc.Handler.EVENT_TOUCH_ENDED
    )
    icon:getEventDispatcher():addEventListenerWithSceneGraphPriority(listenner, icon)
    local tag_icon = 15
    Mnode.addChild(
	{
		parent = self,--icon在特效图的上层需要单独remove,不放在right_panel中
		child = icon,
		pos = cc.p(146 + posX_item_icon, 31 + posY_item_icon),
		tag = tag_icon,
        zOrder = 2
	})
    createLabel(self, MpropOp.name(q_id), cc.p(146 + posX_item_icon, 26 + posY_item_icon - 100 + 39), cc.p(0.5, 0.5), 18, nil, nil, nil, MpropOp.nameColor(q_id), tag_item_name)
    local forge = require("src/config/Forge")
    local q_forgeCost
    for k_forge, v_forge in pairs(forge) do
        while true do
            if v_forge.q_sort ~= self.q_sort then
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
            for k_forgable_item, v_forgable_item in pairs(bool_item_more_than_one and table_item[self.school] or table_item[1]) do
                if k_forgable_item == q_id then
                    q_forgeCost =  assert(loadstring("return " .. v_forge.q_forgeCost))()
                    break
                end
            end
            break
        end
    end
    self.q_forgeCost = q_forgeCost
    self:refreshText()
    -- 合成按钮
    local compound_menu, compound_btn = MMenuButton.new(
    {
	    parent = self.right_panel,
	    pos = cc.p(posX_item_icon, 34),
        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = self.q_sort == 1 and game.getStrByKey("equip_make") or game.getStrByKey("compound"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
		    if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
            if self.q_sort == 2 then
                --合成不需要弹出确认
                g_msgHandlerInst:sendNetDataByTable(ITEM_CS_COMPOUND_EQUIP, "EquipCompoundProtocol", {itemID = protoId, compoundType = self.q_sort})
                return
            end
            if not isForgeMaterialEnough(protoId, self.school) then
                --如果材料不足，弹出tip需要发送消息触发
                g_msgHandlerInst:sendNetDataByTable(ITEM_CS_COMPOUND_EQUIP, "EquipCompoundProtocol", {itemID = protoId, compoundType = self.q_sort})
                return
            end
            --材料足够则弹出确认
            MessageBoxYesNo(nil, string.format(game.getStrByKey("equip_makeConfirmFormat"), MpropOp.name(protoId)), function()
                g_msgHandlerInst:sendNetDataByTable(ITEM_CS_COMPOUND_EQUIP, "EquipCompoundProtocol", {itemID = protoId, compoundType = self.q_sort})
            end, nil)
	    end,
    })
    G_TUTO_NODE:setTouchNode(compound_btn, TOUCH_MAKE)
    if self.q_sort == 2 and self.equipNum[self.selectIdx + 1] == 9 then--矿石的编号9, forge.lua
        local distance_between_two_buttons_half = 75
        compound_menu:setPositionX(posX_item_icon - distance_between_two_buttons_half)
        local quick_compound_menu, quick_compound_btn = MMenuButton.new(
        {
	        parent = self.right_panel,
	        pos = cc.p(posX_item_icon + distance_between_two_buttons_half, 34),
            src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	        label = {
		        src = game.getStrByKey("quick_compound"),
		        size = 22,
		        color = MColor.lable_yellow,
	        },
	        cb = function(tag, node)
		        if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
                g_msgHandlerInst:sendNetDataByTable(ITEM_CS_COMPOUND_EQUIP, "EquipCompoundProtocol", {itemID = protoId, compoundType = self.q_sort, compoundParam = 2})--compoundParam为2代表快速合成
	        end,
        })
    end
end

function equipMakeSelectTypeLayer:cellSizeForTable(table,idx)
    return cellHeight, cellWidth
end

function equipMakeSelectTypeLayer:numberOfCellsInTableView(table)
    return #self.myShop
end

function equipMakeSelectTypeLayer:tableCellTouched(table,cell)
    local index = cell:getIdx()
    if self.selectIdx == index or not self:isVisible() then
        return
    end
    AudioEnginer.playTouchPointEffect()
    local old_cell = table:cellAtIndex(self.selectIdx)
    if old_cell then
        local button = tolua.cast(old_cell:getChildByTag(tag_button),"cc.Sprite")
        button:setTexture("res/component/button/43.png")
        button:removeChildByTag(tag_arrow)
    end
    local button = cell:getChildByTag(tag_button)
    button:setTexture("res/component/button/43_sel.png")
    button:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
    local select_allow =  button:getChildByTag(tag_arrow)
    if select_allow == nil then
        local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
        arrow:setTag(tag_arrow)
    end
    local num = index + 1
    self.selectIdx = index
    self:setTitleEqu(num)
end

function equipMakeSelectTypeLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell, "res/component/button/43.png", cc.p(table_view_width / 2, 35))
    createLabel(button,self.myShop[idx+1],cc.p(button:getContentSize().width/2,button:getContentSize().height/2),nil,22,nil,nil,nil,MColor.lable_yellow)
    button:setTag(tag_button)
    if idx == self.selectIdx then
        --如果重新加上删除的按钮,需要重新设置状态
        button:setTexture("res/component/button/43_sel.png")
        local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(button:getContentSize().width, button:getContentSize().height/2), cc.p(0, 0.5))
        arrow:setTag(tag_arrow)
    end
    local q_menu = self.equipNum[idx + 1]
    local forge = require("src/config/Forge")
    --遍历本种类的子item,如果有一个材料足够，那么本类就显示红点
    local bool_has_one_item_enough = false
    for k, v in pairs(forge) do
        while true do
            if v.q_sort ~= self.q_sort then
                break
            end
            if v.q_menu ~= q_menu then
                break
            end
            --查看所消耗的材料,命运打造的3职业消耗相同
            local q_forgeCost = assert(loadstring("return " .. v.q_forgeCost))()
            --如果材料足够就显示红点
            local bool_enough = true
            for item_id, item_count in pairs(q_forgeCost) do
                if item_id == 777777 and item_count > MRoleStruct:getAttr(PLAYER_VITAL) then--声望
                    bool_enough = false
                    break
                end
                if item_id == 999998 and item_count > MRoleStruct:getAttr(PLAYER_MONEY) then--金币
                    bool_enough = false
                    break
                end
                if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
                    bool_enough = false
                    break
                end
            end
            if bool_enough then
                bool_has_one_item_enough = true
            end
            break
        end
        if bool_has_one_item_enough then
            break
        end
    end
    if bool_has_one_item_enough then
        local redDot = createSprite(cell:getChildByTag(tag_button), "res/component/flag/red.png" ,cc.p(cell:getChildByTag(tag_button):getContentSize().width - 18, cell:getChildByTag(tag_button):getContentSize().height - 21), cc.p(0.5, 0.5))
        redDot:setTag(tag_redDot)
    end
    if idx == 1 then
        G_TUTO_NODE:setTouchNode(button, TOUCH_TAB_2)
    end
    return cell
end

function equipMakeSelectTypeLayer:setTitleEqu(num)
    if self.layerMan[self.tempForOld] then
        self.layerMan[self.tempForOld]:setVisible(false)
    end
    if self.layerMan[num] == nil then
        self.layerMan[num] = require("src/layers/equipment/equipMakeSelectItemLayer").new(self.equipNum[num], self.school, self.sex, self.q_sort)
        self:addChild(self.layerMan[num])
    else
        self.layerMan[num]:setVisible(true)
    end
    local selectedLayer = self.layerMan[num]
    if #selectedLayer.equipTable >= selectedLayer.selectIdx + 1 then
        self:showItem(selectedLayer.equipTable[selectedLayer.selectIdx + 1])
    end
    self.tempForOld = num
end

return equipMakeSelectTypeLayer