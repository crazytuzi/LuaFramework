local VSRankListLayer = class("VSRankListLayer", require("src/TabViewLayer"))
local tag_vsranklistlayer = 100
local table_view_width, table_view_height = 800, 300
local cell_width, cell_height = 750, 75

function fightteam3v3_cs_getrank(buffer)
    local proto = g_msgHandlerInst:convertBufferToTable("FightTeam3v3GetRankRetProtocol", buffer)
    local root = getRunScene():getChildByTag(require("src/config/CommDef").TAG_3V3_TEAM_INFO_DIALOG):getChildByTag(tag_vsranklistlayer)
    root.rankData = proto.ranks
    root:getTableView():reloadData()
    --todo:更新界面上的 未入榜， 总战斗力， 胜负等信息
end

function VSRankListLayer:ctor()
    self.rankData = {}
    self:setTag(tag_vsranklistlayer)
    --布局代码由python解析cocostudio json文件生成
    --createSprite(self, "res/common/bg/bar.png", cc.p(431.1552, 436.7889))
    createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(432, 437),
        cc.size(754, 41),
        4
    )
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_sheng_fu"), cc.p(739.749, 437.3797), cc.p(0.5, 0.5), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_zong_zhan_dou_li"), cc.p(540.5645, 437.3795), cc.p(0.5, 0.5), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_zhan_dui_ming_cheng"), cc.p(325.1912, 437.3795), cc.p(0.5, 0.5), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_pai_ming"), cc.p(134.3963, 437.3797), cc.p(0.5, 0.5), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_ben_zhan_dui_pai_ming"), cc.p(115.2211, 35.7603), cc.p(0.4505, 0.4553), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_zong_zhan_dou_li"), cc.p(386.2014, 35.7603), cc.p(0.4505, 0.4553), 20)
    createLabel(self, game.getStrByKey("p3v3_rank_list_title_sheng_fu") .. ":", cc.p(691.7416, 35.7581), cc.p(0.4505, 0.4553), 20)
    g_msgHandlerInst:sendNetDataByTableExEx(FIGHTTEAM3V3_CS_GETRANK, "FightTeam3v3GetRankProtocol", {})
    self:registerScriptHandler(function(event)
        if event == "enter" then
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETRANKRET, fightteam3v3_cs_getrank)
        elseif event == "exit" then
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GETRANKRET, nil)
        end
    end)
    self:createTableView(self, cc.size(table_view_width, table_view_height), cc.p(30, 100), true, true)




    --test code
    self.rankData = {
        {
            teamID = 1		-- 战队id
            , rank = 1      -- 名次
	        , teamName = "test team name"		-- 战队名称
	        , win = 3		-- 胜利场次
	        , lose = 4		-- 失败场次
	        , battle = 4000		-- 战队战力
        }
        , {
            teamID = 1		-- 战队id
            , rank = 2      -- 名次
	        , teamName = "test team name"		-- 战队名称
	        , win = 3		-- 胜利场次
	        , lose = 4		-- 失败场次
	        , battle = 4000		-- 战队战力
        }
        , {
            teamID = 1		-- 战队id
            , rank = 3      -- 名次
	        , teamName = "test team name"		-- 战队名称
	        , win = 3		-- 胜利场次
	        , lose = 4		-- 失败场次
	        , battle = 4000		-- 战队战力
        }
        , {
            teamID = 1		-- 战队id
            , rank = 4      -- 名次
	        , teamName = "test team name"		-- 战队名称
	        , win = 3		-- 胜利场次
	        , lose = 4		-- 失败场次
	        , battle = 4000		-- 战队战力
        }
    }
    self:getTableView():reloadData()
end

function VSRankListLayer:tableCellTouched(table,cell)
end


function VSRankListLayer:cellSizeForTable(table,idx) 
    return cell_height, cell_width
end

function VSRankListLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local data = self.rankData[idx+1]
    local rankCellBg = createScale9Frame(
        cell,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(401, 50),
        cc.size(754, 41),
        4
    )
    --createSprite(cell, "res/common/bg/bar.png", cc.p(400, 50))
    createLabel(rankCellBg, data.win .. "-" .. data.lose, cc.p(680.749, 20.0), cc.p(0.5, 0.5), 20)
    createLabel(rankCellBg, data.battle, cc.p(481.5645, 20.0), cc.p(0.5, 0.5), 20)
    createLabel(rankCellBg, data.teamName, cc.p(266.1912, 20.0), cc.p(0.5, 0.5), 20)
    createLabel(rankCellBg, data.rank, cc.p(75.3963, 20.0), cc.p(0.5, 0.5), 20)
    return cell
end

function VSRankListLayer:numberOfCellsInTableView(table)
   	return #self.rankData
end

return VSRankListLayer