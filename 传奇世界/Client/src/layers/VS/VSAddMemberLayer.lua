local VSAddMemberLayer = class("VSAddMemberLayer",require ("src/TabViewLayer"))
local cellHeight, cellWidth = 72, 760

function VSAddMemberLayer:Msg_relation_cs_getrelationdata(buffer)
    --获取好友信息
    local root = self
	local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", buffer) 
	local relationType = t.relationKind
	root.friendData = {}
	for i,v in ipairs(t.roleData) do
		if v.isOnLine then
            local record = {}
		    record.roleId = v.roleSid
		    record.name = v.name
		    record.lv = v.level
		    record.sex = v.sex
		    record.school = v.school
		    record.fight = v.fightAbility
		    record.online = v.isOnLine
			table.insert(root.friendData, #root.friendData + 1, record)
		end
	end
	table.sort(root.friendData, function(a, b) return a.lv > b.lv end)
    --test code:
    --[[
    self.friendData = {
        {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
        , {
            roleId = 1000
		    , name = "OOOOmingzi"
		    , lv = 40
		    , sex = 1
		    , school = 2
		    , fight = 8000
		    , online = true
        }
    }
    ]]
    --end test code
    root:getTableView():reloadData()
end

function VSAddMemberLayer:ctor()
    createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 16),
        cc.size(788, 452),
        5
    )
    createScale9Sprite(
        self,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(42, 377),
        cc.size(770, 83),
        cc.p(0, 0)
    )
    createScale9Sprite(
        self,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(42, 24),
        cc.size(770, 297),
        cc.p(0, 0)
    )
    self.friendData = {}
    self:registerScriptHandler(function(event)
		if event == "enter" then
            g_msgHandlerInst:registerMsgHandler(RELATION_SC_GETRELATIONDATA_RET, handler(self, self.Msg_relation_cs_getrelationdata))
            g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 1})
		elseif event == "exit" then
			g_msgHandlerInst:registerMsgHandler(RELATION_SC_GETRELATIONDATA_RET, nil)
		end
	end)
    self:createTableView(self, cc.size(772, 286), cc.p(75 - 34 + 6, 30), true, true)
    local scale9_name_bg = createScale9Sprite(
        self,
        "res/common/scalable/input_1.png",
        cc.p(67, 420),
        cc.size(567, 47),
        cc.p(0, 0.5)
    )
    createSprite(scale9_name_bg, "res/teamup/s2.png", cc.p(25, scale9_name_bg:getContentSize().height / 2))
    --todo:最多输入几个字
	local m_teamNameCtrl = createEditBox(scale9_name_bg, nil, cc.p(50, scale9_name_bg:getContentSize().height / 2), cc.size(490, 34), MColor.lable_black, 20, game.getStrByKey("p3v3_add_member_name_place_holder_text"))
    m_teamNameCtrl:setAnchorPoint(cc.p(0, 0.5))
    m_teamNameCtrl:setFontColor(MColor.lable_black)
    m_teamNameCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    m_teamNameCtrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    local sendBtn = createMenuItem(self, "res/component/button/50.png", cc.p(725, scale9_name_bg:getPositionY()), function()
        if m_teamNameCtrl:getText() == "" then
            TIPS({str = game.getStrByKey("p3v3_add_member_no_name_tip")})
            return
        end
        g_msgHandlerInst:sendNetDataByTableExEx(
            FIGTHTEAM_CS_ADD_MEMBER, "FightTeamAddProtocol"
            , {
                targetPlayerName = m_teamNameCtrl:getText()
            }
        )
    end)
    createLabel(sendBtn, game.getStrByKey("p3v3_add_member_btn_label_jing_que_cha_zhao"), getCenterPos(sendBtn), cc.p(0.5, 0.5), 22, true)
    createLabel(self, game.getStrByKey("p3v3_add_member_btn_label_hao_you_lie_biao_xi_tong_tui_jian"), cc.p(300 + 302 - 176 - 3, 400 - 37 - 12), cc.p(0.5, 0.5), 22, true)
end

function VSAddMemberLayer:cellSizeForTable(table,idx)
    return cellHeight, cellWidth
end

function VSAddMemberLayer:numberOfCellsInTableView(table)
    return #self.friendData
end

function VSAddMemberLayer:tableCellTouched(table,cell)
end

function VSAddMemberLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local record = self.friendData[idx+1]
    local posY = 35
    createScale9Sprite(cell, "res/common/scalable/item.png", cc.p(0, cellHeight / 2), cc.size(cellWidth, 70), cc.p(0, 0.5))
    createLabel(cell, record.name, cc.p(48, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),11)
    createLabel(cell, require("src/config/convertor"):sexName(record.sex), cc.p(208, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),11)
	createLabel(cell, record.lv .. game.getStrByKey("faction_player_level"), cc.p(277, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),13)
    createLabel(cell, record.school == 1 and game.getStrByKey("zhanshi") or record.school == 2 and game.getStrByKey("fashi") or game.getStrByKey("daoshi"), cc.p(367, posY), cc.p(0, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),14)
    createLabel(cell, game.getStrByKey("combat_forces") .. " : " .. tostring(record.fight), cc.p(500, posY), cc.p(0.5, 0.5), 22, true, nil, nil, cc.c3b(187, 141, 107),12)
    local sendBtn = createMenuItem(cell, "res/component/button/39.png", cc.p(676, posY), function()
        g_msgHandlerInst:sendNetDataByTableExEx(
            FIGTHTEAM_CS_ADD_MEMBER, "FightTeamAddProtocol"
            , {
                targetPlayerName = record.name
            }
        )
    end)
    createLabel(sendBtn, game.getStrByKey("p3v3_add_member_name_btn_label"), getCenterPos(sendBtn), cc.p(0.5, 0.5), 20, true)
    return cell
end

return VSAddMemberLayer