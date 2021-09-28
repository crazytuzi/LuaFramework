local VSTeamLayer = class("VSTeamLayer", require("src/TabViewLayer"))
local table_view_width, table_view_height = 341, 360
local cell_width, cell_height = 750, 40--75
--[[
需要服务器协议:
1.获得战队信息(实时)
2.获得赛季信息(实时)
]]

function VSTeamLayer:figthteam_sc_get_teaminfo_ret(buffer)
    local proto = g_msgHandlerInst:convertBufferToTable("FightTeamGetInfoRetProtocol", buffer)
    local root
    local tag_root = 10
    if self.rootNode:getChildByTag(tag_root) == nil then
        root = cc.Node:create()
        root:setTag(tag_root)
        self.rootNode:addChild(root)
    else
        --如果已经存在对话框则刷新
        self.rootNode:removeChildByTag(tag_root)
        root = cc.Node:create()
        root:setTag(tag_root)
        self.rootNode:addChild(root)
    end
    --todo:服务器返回赛季名字，怎么获得,需要单独请求一次?
    local MMenuButton = require "src/component/button/MenuButton"
    table.sort(proto.fightTeamMemInfo, function(a, b) return a.position < b.position end)
    local bool_I_am_the_leader = false
    for k, v in ipairs(proto.fightTeamMemInfo) do
        if userInfo.currRoleStaticId == v.roleSID and v.position == 1 then
            bool_I_am_the_leader = true
        end
    end
    --position: 1.队长 2.队员
    local posX_frame, posY_frame_firstLine = 200 + 463, 400 - 52 + 23
    local frame_height = 71
    for i, v in ipairs(proto.fightTeamMemInfo) do
        local posY_frame = posY_frame_firstLine - frame_height * i
        local spr_frame = cc.Scale9Sprite:create(cc.rect(20, 20, 24, 24), "res/common/scalable/item.png")
        spr_frame:setContentSize(cc.size(519, 70))
        spr_frame:setPosition(cc.p(posX_frame, posY_frame))
        root:addChild(spr_frame)
        local lineHeight = 50
        createLabel(root, v.name, cc.p(499, posY_frame), cc.p(0.5, 0.5), 22, nil, 20, nil, MColor.lable_black)
        createLabel(root, v.level, cc.p(610, posY_frame), cc.p(0.5, 0.5), 22, nil, 20, nil, MColor.lable_black)
        createLabel(root, v.school == 1 and game.getStrByKey("zhanshi") or v.school == 2 and game.getStrByKey("fashi") or game.getStrByKey("daoshi"), cc.p(250 + 436 - 1, posY_frame), cc.p(0.5, 0.5), 22, nil, 20, nil, MColor.lable_black)
        createLabel(root, v.battle, cc.p(766, posY_frame), cc.p(0.5, 0.5), 22, nil, 20, nil, MColor.lable_black)
        if v.position == 1 then
            createSprite(root, "res/teamup/2.png", cc.p(422, 304))
        end
        if v.position == 2 and bool_I_am_the_leader then
            MMenuButton.new(
            {
	            parent = root,
	            pos = cc.p(862, posY_frame),
	            src = {"res/component/button/48.png", "res/component/button/48_sel.png", "res/component/button/48_gray.png"},
	            label = {
		            src = game.getStrByKey("p3v3_team_btn_remove"),
		            size = 22,
		            color = MColor.lable_yellow,
	            },
	            cb = function(tag, node)
                    MessageBoxYesNo(nil, game.getStrByKey("p3v3_team_remove_confirm_msg"), function()
                        g_msgHandlerInst:sendNetDataByTableExEx(FIGTHTEAM_CS_REMOVE_MEMBER, "FightTeamRemoveProtocol", {targetSID = v.roleSID})
                    end)
	            end,
            })
        end
    end
    if bool_I_am_the_leader and table.size(proto.fightTeamMemInfo) < 3 then
        MMenuButton.new(
        {
	        parent = root,
	        pos = cc.p(536, 80),
	        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	        label = {
		        src = game.getStrByKey("p3v3_team_btn_add"),
		        size = 22,
		        color = MColor.lable_yellow,
	        },
	        cb = function(tag, node)
                local Mbaseboard = require "src/functional/baseboard"
                local baseBoard = Mbaseboard.new(
                {
	                src = "res/common/bg/bg18.png",
	                close = {
		                src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		                offset = { x = -8, y = 4 },
	                },
	                title = {
		                src = game.getStrByKey("p3v3_team_dialog_title_tian_jia_cheng_yuan_tian_jia_hao_you"),
		                size = 25,
		                color = MColor.lable_yellow,
		                offset = { y = -25 },
	                }
                })
                SwallowTouches(baseBoard)
                baseBoard:setPosition(g_scrCenter)
                getRunScene():addChild(baseBoard, 200)
                baseBoard:addChild(require("src/layers/VS/VSAddMemberLayer").new())
	        end,
        })
    end
    MMenuButton.new(
    {
	    parent = root,
	    pos = cc.p(789, 80),
	    src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = game.getStrByKey("p3v3_team_btn_exit"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
            MessageBoxYesNo(nil, game.getStrByKey("p3v3_team_leave_confirm_msg"), function()
                g_msgHandlerInst:sendNetDataByTableExEx(FIGTHTEAM_CS_LEAVE, "FightTeamLeaveProtocol", {})
            end)
	    end,
    })
end

function VSTeamLayer:ctor()
    self.rankData = {}
    local root, closeBtn = createBgSprite(self, game.getStrByKey("p3v3_team_info_title"))
    self.rootNode = root
    createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(33, 38),
        cc.size(357, 500),
        5
    )
    local sprite_bg = createSprite(root, "res/common/bg/teamRank_bg.png", cc.p(28, 26))
    sprite_bg:setAnchorPoint(cc.p(0, 0))
    createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(398, 395),
        cc.size(529, 143),
        5
    )
    createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(398, 38),
        cc.size(529, 350),
        5
    )
    self:registerScriptHandler(function(event)
        if event == "enter" then
            g_msgHandlerInst:registerMsgHandler(FIGTHTEAM_SC_LEAVE_RET, function(buffer)
                local proto = g_msgHandlerInst:convertBufferToTable("FightTeamLeaveRetProtocol", buffer)
                getRunScene():removeChildByTag(require("src/config/CommDef").PARTIAL_TAG_3V3_TEAM_INFO_DIALOG + 100)
            end)
            g_msgHandlerInst:registerMsgHandler(FIGTHTEAM_SC_GET_TEAMINFO_RET, handler(self, self.figthteam_sc_get_teaminfo_ret))
            g_msgHandlerInst:sendNetDataByTableExEx(FIGTHTEAM_CS_GET_TEAMINFO, "FightTeamGetInfoProtocol", {})
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETRANKRET, function(buffer)
                local proto = g_msgHandlerInst:convertBufferToTable("FightTeam3v3GetRankRetProtocol", buffer)
                self.rankData = proto.ranks
                self:getTableView():reloadData()
            end)
            g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_GETRANK, "FightTeam3v3GetRankProtocol", {})
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETTEAMDATARET, function(buffer)
                local proto = g_msgHandlerInst:convertBufferToTable("FightTeam3GetTeamDataDataRetProtocol", buffer)
                local label_font_size = 20
                local line_height = 22
                local richTextSize_width = 960
                local richText_zhan_dui = require("src/RichText").new(root, cc.p(413, 473), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_zhan_dui:setAutoWidth()
                richText_zhan_dui:addText(
                    string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_zhan_dui"), proto.teamData.fightTeamName)
                )
                richText_zhan_dui:format()
                local richText_sai_ji = require("src/RichText").new(root, cc.p(632, 473), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_sai_ji:setAutoWidth()
                richText_sai_ji:addText(
                    --string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_sai_ji"), string.format(game.getStrByKey("p3v3_team_dialog_title_di_n_sai_ji"), valueDigitToChinese(proto.season)))
                    string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_sai_ji"), proto.seasonName)
                )
                richText_sai_ji:format()
                local richText_pai_ming = require("src/RichText").new(root, cc.p(413, 445), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_pai_ming:setAutoWidth()
                richText_pai_ming:addText(
                    string.format("^c(lable_yellow)%s : ^%s", game.getStrByKey("p3v3_team_dialog_title_pai_ming"), proto.teamData.rank == 0 and game.getStrByKey("ranking_no_rank") or proto.teamData.rank)--未参加比赛或100名开外都是"未入榜"
                )
                richText_pai_ming:format()
                local richText_zhuang_tai = require("src/RichText").new(root, cc.p(632, 445), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_zhuang_tai:setAutoWidth()
                richText_zhuang_tai:addText(
                    string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_zhuang_tai"), proto.stage == 0 and game.getStrByKey("p3v3_team_dialog_title_jieShu") or (proto.stage == 1 and game.getStrByKey("p3v3_team_dialog_title_haiXuanSai") or (proto.stage == 2 and game.getStrByKey("p3v3_team_dialog_title_siFenZhiYi") or (proto.stage == 3 and game.getStrByKey("p3v3_team_dialog_title_banJueSai") or game.getStrByKey("p3v3_team_dialog_title_jueSai")))))
                )
                richText_zhuang_tai:format()
                local richText_zhan_ji = require("src/RichText").new(root, cc.p(413, 417), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_zhan_ji:setAutoWidth()
                richText_zhan_ji:addText(
                    string.format(game.getStrByKey("p3v3_team_dialog_title_format_zhan_ji"), proto.teamData.win, proto.teamData.lose)
                )
                richText_zhan_ji:format()
                local richText_shi_jian = require("src/RichText").new(root, cc.p(632, 417), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                richText_shi_jian:setAutoWidth()
                richText_shi_jian:addText(
                    string.format("^c(lable_yellow)%s : ^%s", game.getStrByKey("p3v3_team_dialog_title_shi_jian"), formatDateStr(proto.startDate) .. "-" .. formatDateStr(proto.endDate))
                )
                richText_shi_jian:format()
            end)
            g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_GETTEAMDATA, "FightTeam3GetTeamDataDataProtocol", {})
        elseif event == "exit" then
            g_msgHandlerInst:registerMsgHandler(FIGTHTEAM_SC_LEAVE_RET, nil)
            g_msgHandlerInst:registerMsgHandler(FIGTHTEAM_SC_GET_TEAMINFO_RET, nil)
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETRANKRET, nil)
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETTEAMDATARET, nil)
        end
    end)
    self:createTableView(root, cc.size(table_view_width, table_view_height), cc.p(42, 92), true, true)
    createLabel(root, game.getStrByKey("p3v3_rank_list_title"), cc.p(132, 509), cc.p(0, 0.5), 22, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_pai_ming"), cc.p(47, 473), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_zhan_dui"), cc.p(129 - 20, 473), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_zong_zhan_dou_li"), cc.p(228, 473), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_sheng_fu"), cc.p(320, 473), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local titleLine = createSprite(root, "res/common/bg/titleLine.png", cc.p(663, 515))
    createLabel(titleLine, game.getStrByKey("p3v3_team_dialog_title_wo_de_zhan_dui"), cc.p(titleLine:getContentSize().width / 2, titleLine:getContentSize().height / 2), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    CreateListTitle(root, cc.p(402, 341), 521, 43)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_ming_zi"), cc.p(477, 363), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_deng_ji"), cc.p(588, 363), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_zhi_ye"), cc.p(664, 363), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_zhan_dou_li"), cc.p(734, 363), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    createLabel(root, game.getStrByKey("p3v3_team_dialog_title_cao_zuo"), cc.p(840, 363), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)




    --[[
    --test code:
    local proto = {
        season = 1		-- 赛季
	    , stage = 2		-- 阶段  2是四分之一，3是半决赛，4是决赛，0是结束
	    , startDate = 3
	    , endDate = 15
	    , teamData = {
            fightTeamID = 1		-- 战队id
	        , fightTeamName = "abc"		-- 战队名称
	        , win = 3		-- 胜利场次
	        , lose = 4		-- 失败场次
	        , members = {
                {
                    {
	                    roleSID = 1
	                    , roleName = "abc"		-- 角色名称
	                    , battle = 3000		-- 战力
	                    , kill = 4		-- 杀人数
	                    , level = 5		-- 等级
	                    , school = 2		-- 职业
	                    , isLeader = true		-- 是否是队长
                    }
                }
                , {
                    {
	                    roleSID = 2
	                    , roleName = "abcd"		-- 角色名称
	                    , battle = 3000		-- 战力
	                    , kill = 4		-- 杀人数
	                    , level = 5		-- 等级
	                    , school = 2		-- 职业
	                    , isLeader = false		-- 是否是队长
                    }
                }
            }
        }
    }
    local label_font_size = 20
    local line_height = 22
    local richTextSize_width = 960
    local richText_zhan_dui = require("src/RichText").new(root, cc.p(413, 473), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_zhan_dui:setAutoWidth()
    richText_zhan_dui:addText(
        string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_zhan_dui"), proto.teamData.fightTeamName)
    )
    richText_zhan_dui:format()
    local richText_sai_ji = require("src/RichText").new(root, cc.p(632, 473), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_sai_ji:setAutoWidth()
    richText_sai_ji:addText(
        string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_sai_ji"), string.format(game.getStrByKey("p3v3_team_dialog_title_di_n_sai_ji"), valueDigitToChinese(proto.season)))
    )
    richText_sai_ji:format()
    local richText_pai_ming = require("src/RichText").new(root, cc.p(413, 445), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_pai_ming:setAutoWidth()
    richText_pai_ming:addText(
        string.format("^c(lable_yellow)%s : ^%s", game.getStrByKey("p3v3_team_dialog_title_pai_ming"), "100")--暂时没有协议返回
    )
    richText_pai_ming:format()
    local richText_zhuang_tai = require("src/RichText").new(root, cc.p(632, 445), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_zhuang_tai:setAutoWidth()
    richText_zhuang_tai:addText(
        string.format("^c(lable_yellow)%s : ^^c(lable_black)%s^", game.getStrByKey("p3v3_team_dialog_title_zhuang_tai"), proto.stage == 0 and game.getStrByKey("p3v3_team_dialog_title_jieShu") or (proto.stage == 2 and game.getStrByKey("p3v3_team_dialog_title_siFenZhiYi") or (proto.stage == 3 and game.getStrByKey("p3v3_team_dialog_title_banJueSai") or game.getStrByKey("p3v3_team_dialog_title_jueSai"))))
    )
    richText_zhuang_tai:format()
    local richText_zhan_ji = require("src/RichText").new(root, cc.p(413, 417), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_zhan_ji:setAutoWidth()
    richText_zhan_ji:addText(
        string.format(game.getStrByKey("p3v3_team_dialog_title_format_zhan_ji"), proto.teamData.win, proto.teamData.lose)
    )
    richText_zhan_ji:format()
    local richText_shi_jian = require("src/RichText").new(root, cc.p(632, 417), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_shi_jian:setAutoWidth()
    richText_shi_jian:addText(
        string.format("^c(lable_yellow)%s : ^%s", game.getStrByKey("p3v3_team_dialog_title_shi_jian"), formatDateStr(proto.startDate) .. "-" .. formatDateStr(proto.endDate))
    )
    richText_shi_jian:format()
    ]]
end

function VSTeamLayer:tableCellTouched(table,cell)
end


function VSTeamLayer:cellSizeForTable(table,idx) 
    return cell_height, cell_width
end

function VSTeamLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local data = self.rankData[idx+1]
    createLabel(cell, data.rank, cc.p(8, 20.0), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_black)
    createLabel(cell, data.teamName, cc.p(108 - 21 - 20, 20.0), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_black)
    createLabel(cell, data.battle, cc.p(229 - 44, 20.0), cc.p(0, 0.5), 20, nil, nil, nil, MColor.lable_black)
    createLabel(cell, data.win .. "/" .. data.lose, cc.p(328, 20.0), cc.p(1, 0.5), 20, nil, nil, nil, MColor.lable_black)
    return cell
end

function VSTeamLayer:numberOfCellsInTableView(table)
   	return #self.rankData
end

return VSTeamLayer