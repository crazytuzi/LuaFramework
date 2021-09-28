local privateChatListView = class("privateChatListView",require ("src/TabViewLayer"))
--define
local padding_outer = 25
local tag_button = 10--因为本tag的节点是加在本layer下的node中，因此出于代码简洁度和耦合度低的考虑，没有必要对本tag在全局进行声明
local width_between_slider = 8
local button_width = 275--219
local cell_width = (button_width + width_between_slider * 2)
local cell_height = 91
local margin_top_buttom = 8
local background_height = 436
local tag_label_name = 16
function privateChatListView:ctor(changeTargetNameDelegate)
    local spr_infoBg = cc.Sprite:create("res/common/bg/infoBg11-2.png")
    spr_infoBg:setPosition(cc.p(cell_width / 2, display.height - 143))
    self:addChild(spr_infoBg)
    createLabel(spr_infoBg, game.getStrByKey("private_chat_list_title"), getCenterPos(spr_infoBg), cc.p(0.5, 0.5), 20, true, 0, nil, MColor.lable_yellow)
    --全体按钮
    self.btn_show_all = createTouchItem(self, "res/chat/private_chat_btn_selected.png", cc.p(cell_width / 2, display.height - 202), function(sender)
        sender:setTexture("res/chat/private_chat_btn_selected.png")
        self.changeTargetNameDelegate:setPrivateChatTargetAll()
        for k, v in ipairs(self:getTableView():getContainer():getChildren()) do
            v:getChildByTag(tag_button):setTexture("res/chat/private_chat_btn.png")
        end
        self.selectIdx = -1
    end)
    createLabel(self.btn_show_all, game.getStrByKey("private_chat_all_target_btn_title"), getCenterPos(self.btn_show_all, 0, 0), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.lable_yellow)
    --修改加载人名的逻辑
    self.changeTargetNameDelegate = changeTargetNameDelegate
    self.selectIdx = -1  --当前点击的button index
    local json = require("json")
    local path = getDownloadDir() .. "privateChatTargetList_" .. tostring(userInfo.currRoleStaticId) .. ".txt"
	local file = io.open(path, "r")
    if file == nil then
		file = io.open(path, "w")
        file:write(json.encode({}))
		io.close(file)
		file = io.open(path, "r")
    end
    local fileContent = file:read("*a")
    io.close(file)
	self.table_privateChatTargetList = json.decode(fileContent)
    self.num = #self.table_privateChatTargetList
    local distance_arrow_to_table_view = 8
    local bgsize = self:getContentSize()
    self:createTableView(self, cc.size(cell_width, display.height - 246), cc.p(0, 0), true, true)
end

function privateChatListView:scrollViewDidScroll(view)
    
end

function privateChatListView:cellSizeForTable(table,idx)
    return cell_height, cell_width
end

function privateChatListView:numberOfCellsInTableView(table)
    return self.num
end

function privateChatListView:tableCellTouched(table, cell)
    local index = cell:getIdx()
    local num = index + 1
    if self.selectIdx == index or not self:isVisible() then
        return
    end
    AudioEnginer.playTouchPointEffect()
    local old_cell = table:cellAtIndex(self.selectIdx)
    if old_cell then
        local button = tolua.cast(old_cell:getChildByTag(tag_button),"cc.Sprite")
        button:setTexture("res/chat/private_chat_btn.png")
    end
    local button = cell:getChildByTag(tag_button)
    button:setTexture("res/chat/private_chat_btn_selected.png")
    self.changeTargetNameDelegate:setPrivateChatTarget(button:getChildByTag(tag_label_name):getString())
    self.btn_show_all:setTexture("res/chat/private_chat_btn.png")
    self.selectIdx = index
end

function privateChatListView:tableCellAtIndex(tb, idx)
    local cell = tb:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell, "res/chat/private_chat_btn.png", cc.p(cell_width / 2, cell_height / 2))
    button:setTag(tag_button)
    if idx == self.selectIdx then
        --如果重新加上删除的按钮,需要重新设置状态
        button:setTexture("res/chat/private_chat_btn_selected.png")
    end
    local MpropOp = require("src/config/propOp")
    local idx_lua = idx + 1
	local Mprop = require "src/layers/bag/prop"
	local nameStr = self.table_privateChatTargetList[idx_lua].roleName
    local type_friend, type_enemy, type_moShengRen = 1, 2, 3
    local peopleType = self.table_privateChatTargetList[idx_lua].roleRelation
    local peopleSchool = self.table_privateChatTargetList[idx_lua].roleSchool
    local peopleLevel = self.table_privateChatTargetList[idx_lua].roleLevel
	local label_name = createLabel(button, nameStr, cc.p(27, button:getContentSize().height / 2 + 16), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    label_name:setTag(tag_label_name)
    createLabel(button, peopleType == type_moShengRen and game.getStrByKey("privateList_moShengRen") or (peopleType == type_friend and game.getStrByKey("privateList_friend") or game.getStrByKey("privateList_enemy")), cc.p(248, button:getContentSize().height / 2), cc.p(1, 0.5), 20, nil, nil, nil, peopleType == type_moShengRen and MColor.blue or (peopleType == type_friend and MColor.orange or MColor.alarm_red))
    createLabel(button, peopleSchool == 1 and game.getStrByKey("zhanshi") or (peopleSchool == 2 and game.getStrByKey("fashi") or game.getStrByKey("daoshi")), cc.p(27, button:getContentSize().height / 2 - 14), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(button, string.format(game.getStrByKey("privateList_people_level"), peopleLevel), cc.p(153, button:getContentSize().height / 2 - 14), cc.p(1, 0.5), 20, nil, nil, nil, MColor.drop_white)
	return cell
end

return privateChatListView