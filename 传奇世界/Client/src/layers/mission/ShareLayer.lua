-- Share Task Interface

local ShareLayer = class("ShareLayer", require("src/LeftSelectNode"))


-----------------------------------------------------------

function ShareLayer:ctor(parent)

	self.data = DATA_Mission:getShareData()

	if not self.data then
		return
	end
	
	if parent then
		parent:addChild(self)
	end

	-------------------------------------------------------

    local nodeLeft = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p( 17 + 15 , 18 + 21 ),
        cc.size(332,502),
        5
    )
	--local nodeLeft = createSprite( self , "res/common/bg/bg2.png" , cc.p( 17 + 15 , 18 + 21 ) , cc.p( 0 , 0 ) ) 


	-------------------------------------------------------

	local task_id = self.data.id
	local taskdb_item = getConfigItemByKey("SharedTaskDB", "q_taskid", task_id);

	-------------------------------------------------------

    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p( 356 + 15 , 18 + 21 ),
        cc.size(558,502),
        5
    )
    --local bg = createSprite( self ,"res/common/bg/bg3.png" , cc.p( 356 + 15 , 18 + 21 ) ,  cc.p( 0 , 0 ) )
    local nodeRight = bg 
    createSprite( bg ,"res/common/bg/bg66-1.jpg" , getCenterPos( bg ) ,  cc.p( 0.5 , 0.5 ) )
    local config = {{  text = "task_target" , y = 330 } , {  text = "task_reward" , y = 70 } , }
    for i = 1 , #config do
        local titleSp = createSprite( bg , "res/common/bg/titleLine.png" , cc.p(  590/2 - 15 , config[i].y + 115) ,  cc.p( 0.5 , 0 )  )
        createLabel( titleSp , game.getStrByKey( config[i].text )  , getCenterPos( titleSp ), cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    end



	local RCenterX = 295
	local PosLeftX = 40 - 15



	local strLeft = game.getStrByKey("taskSubmit") .. game.getStrByKey("map_detail_npc") .. game.getStrByKey("colon")
	local npcName = ""
	if taskdb_item then
		local npcId = taskdb_item.q_endnpc
		npcName = getConfigItemByKey("NPC", "q_id", npcId, "q_name")
	end
	createLabel(nodeRight, strLeft, cc.p(PosLeftX, 435 - 21 ), cc.p(0.0, 0.0), 20 , nil , nil , nil , MColor.brown  ) 
	createLabel(nodeRight, npcName, cc.p(PosLeftX + 100, 435 - 21), cc.p(0.0, 0.0), 20 , nil , nil , nil , MColor.brown  ) 

	createLabel(nodeRight, game.getStrByKey("task_target") .. game.getStrByKey("colon"), cc.p(PosLeftX, 400  - 21 ), cc.p(0.0, 0.0), 20, true, 10, nil, MColor.brown)
	-- 目标描述
    local tmpTargetStr = "";
    if self.data.targetData.cur_num == self.data.targetData.count then
		local npcId = 10465
		local npcName = ""
		local getName = getConfigItemByKey("NPC", "q_id", npcId, "q_name")
		if getName then
			npcName = getName
		end
		local strGo = game.getStrByKey("share_task_go")
		tmpTargetStr = string.format(strGo, npcName)
	else
		local monster_name = game.getStrByKey("treasure_target");
        if self.data.posData and self.data.targetState and self.data.targetCount then
            for i = 1, #self.data.posData do
                -- 顺序开放
		        if self.data.targetState[i] < self.data.targetCount[i] then
                    if self.data.targetData and (i-1) <= self.data.targetData.cur_num then
                        local target_data = self.data.posData[i]
		                if target_data then
			                monster_name = getConfigItemByKey("MapInfo", "q_map_id", target_data.map_id, "q_map_name")
                            break;
                        end
                    end
		        end
	        end
        end
		tmpTargetStr = string.format(game.getStrByKey("week_go") .. "%s (%s/%s)", monster_name, self.data.targetData.cur_num, self.data.targetData.count);
	end
    createLabel(nodeRight, tmpTargetStr, cc.p(PosLeftX + 100, 400  - 21 ), cc.p(0.0, 0.0), 20, true, 10, nil, cc.c3b(44,124,255));

	createLabel( nodeRight ,  tmpTargetStr , cc.p( PosLeftX , 330 + 20 - 21 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown  ) 

    -- 描述
    local tmpDescStr = "";
    local mapDests = {};
    for i = 1, #self.data.posData do
		local target_data = self.data.posData[i]
		local map_name = getConfigItemByKey("MapInfo", "q_map_id", target_data.map_id, "q_map_name")
		mapDests[i] = map_name;
	end

    if #mapDests >= 4 then
        tmpDescStr = string.format(self.data.desc, mapDests[1], mapDests[2], mapDests[3], mapDests[4]);
    end
	--local desc =  createLabel(nodeRight, tmpDescStr, cc.p(PosLeftX, 327 + 20 - 21 ), cc.p(0.0, 1 ), 20 , nil , nil , nil , MColor.black  ) 
	--desc:setDimensions( 460,0  )
    
    local descRichText = require("src/RichText").new(nodeRight , cc.p( PosLeftX, 230 ) , cc.size( 545 , 0 ) , cc.p( 0 , 0 ) , 22 , 20 , MColor.black );
    descRichText:setAutoWidth();
    descRichText:addText(tmpDescStr);
	descRichText:format();

	if taskdb_item then
		local iconGroup = __createAwardGroup(DATA_Mission.__formatAwardData(taskdb_item))
		if iconGroup then
			setNodeAttr( iconGroup , cc.p( 306 - 15 , 130 ) , cc.p( 0.5 , 0.5 ) )
			nodeRight:addChild(iconGroup)
		end
	end

	-------------------------------------------------------


	self:createTableView(nodeLeft, cc.size(361 - 15 , 470 + 20), cc.p( 3 , 5 ), true)


	self.selectIdx = 0


	-------------------------------------------------------
	-- button

	
	local MainRoleId = 0

	local funcCBDelete = function()
		local funcConfirm = function()
			if userInfo then
				MainRoleId = userInfo.currRoleId
			end
			g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_DELETE_SHARED_TASK, "DeleteSharedTaskProtocol", {})
			cclog("[TASK_CS_DELETE_SHARED_TASK] sent. role_id = %s.", MainRoleId)
		end

		local text_hint = game.getStrByKey("task_delete_confirm")
		MessageBoxYesNo(nil, text_hint, funcConfirm)
	end

	local funcCBShare = function()
		if userInfo then
			MainRoleId = userInfo.currRoleId
		end
		local t = {}
		t.taskRank = task_id
		g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_SHARE_TASK, "ShareTaskProtocol", t)
		cclog("[TASK_CS_SHARE_TASK] sent. role_id = %s, task_id = %s.", MainRoleId, task_id)
	end

	local btnFile = "res/component/button/39.png"

	local btnDelete = createMenuItem(nodeRight, btnFile, cc.p( 470, 420 ), funcCBDelete)
	createLabel(btnDelete, game.getStrByKey("delete_relation") .. game.getStrByKey("task"), getCenterPos(btnDelete), cc.p(0.5,0.5), 22, true)

    local gotoBtn = createMenuItem(nodeRight, btnFile, cc.p( 590/2 - 145 , 60 - 21 ), function()
        require("src/layers/teamTreasureTask/teamTreasureTaskLayer"):onClickTaskPanel(self.data);
    end)
	createLabel(gotoBtn, game.getStrByKey("goto_activity_now"), getCenterPos(gotoBtn), cc.p(0.5,0.5), 22, true)

	local btnShare = createMenuItem(nodeRight, btnFile, cc.p( 590/2 + 115 , 60 - 21 ), funcCBShare)
	createLabel(btnShare, game.getStrByKey("task_gx") .. game.getStrByKey("task"), getCenterPos(btnShare), cc.p(0.5,0.5), 22, true)
	if self.data.flag == 0 then
        createLabel(nodeRight, game.getStrByKey("treasure_warning"), cc.p( 590/2 - 30, 27 ), cc.p(0.0, 0.0), 20, true, 10, nil, cc.c3b(255,0,0));
		btnShare:setVisible(false);
	end

	-------------------------------------------------------

--	DATA_Mission:setCallback("share_refresh", function() self:refreshDataFunc() end)
end



function ShareLayer:cellSizeForTable(table, idx)
	return 65, 361
end

function ShareLayer:numberOfCellsInTableView(table)
	return 1
end

function ShareLayer:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	local index = idx + 1
	if cell == nil then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end

	local curData = self.data

--	local normal_img = "res/component/button/52.png"
	local select_img = "res/component/button/52_sel.png"
	local isFinished = false
	if curData.targetData.cur_num >= curData.targetData.count then
		isFinished = true
	end

	local button = createSprite(cell, select_img, cc.p(0, 0), cc.p(0, 0))

	local posCX = getCenterPos(button).x
	local posCY = getCenterPos(button).y

    local titleColor = 
        (
            curData.q_rank == 1 and MColor.green or
            curData.q_rank == 2 and MColor.blue or
            MColor.purple
        )
	createLabel(button, curData.name, cc.p(posCX - 120, posCY), cc.p(0.0, 0.5), 20, nil, 20, nil, titleColor, nil, nil)

	local strState
	local colState
	if isFinished then
		strState = game.getStrByKey("task_finish3")
		colState = MColor.yellow
	else
		strState = game.getStrByKey("task_finish2")
		colState = MColor.red
	end
	createLabel(button, strState, cc.p(posCX + 120, posCY), cc.p(1.0, 0.5), 20, nil, 20, nil, colState, nil, nil)


	return cell
end


function ShareLayer:refreshDataFunc()

end


-----------------------------------------------------------

return ShareLayer
