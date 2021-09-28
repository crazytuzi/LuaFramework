local teamTreasureTaskLayer = class("teamTreasureTaskLayer")


function teamTreasureTaskLayer:ctor()

end


function teamTreasureTaskLayer:checkShowDigIcon(map_id, tile_pos)

	local taskData = DATA_Mission:getShareData()
	if taskData == nil or taskData.posData == nil or taskData.targetState == nil or taskData.targetCount == nil then
		return false
	end

--	if taskData.flag == 0 then
--		return false
--	end

	local check_radius = 3
	local curx = tile_pos.x
	local cury = tile_pos.y

	local pos_count = #taskData.posData
	for i = 1, pos_count do
		local digpos = taskData.posData[i]
		if digpos.map_id == map_id then
			if curx >= digpos.x - check_radius and curx <= digpos.x + check_radius and cury >= digpos.y - check_radius and cury <= digpos.y + check_radius then
				if taskData.targetState[i] < taskData.targetCount[i] then
					return true
				end
			end
		end
	end


	return false

end


function teamTreasureTaskLayer:onClickTaskPanel(data)
	if not data then
		return
	end
	if not data.targetData then
		return
	end

	if data.targetData.cur_num >= data.targetData.count then
		local mapId, posX, posY = 2100, 100, 91
		local npcCfg = require("src/config/NPC")
		for i=1, #npcCfg do
			if tonumber(npcCfg[i].q_id) == 10465 then
				mapId = tonumber(npcCfg[i].q_map)
				posX = tonumber(npcCfg[i].q_x)
				posY = tonumber(npcCfg[i].q_y)
				break
			end
		end
		local WorkCallBack = function()
			if G_ROLE_MAIN and G_MAINSCENE then
				require("src/layers/mission/MissionNetMsg"):sendClickNPC(10465)
			end
		end

		local tempData = {targetType = 4, mapID = mapId, x = posX, y = posY, callFun = WorkCallBack}
		__TASK:findPath(tempData)
		__removeAllLayers()
	else
        self:FindOneTarget(data);
	end

end


function teamTreasureTaskLayer:checkShowPromptDialog()
	local doFunc = function()
		if G_MAINSCENE and G_MAINSCENE.map_layer then
			G_MAINSCENE.map_layer:addDigAction()
		end
	end

	local dlgFunc = function()
		local tempLayer = MessageBoxYesNo(nil, game.getStrByKey("treasure_monster_tip"), doFunc, nil)

    	local no_selectBtn, selectBtn

    	local selectFun = function(value)
    		DATA_Mission.no_tip_sharetask_monster = value
    		selectBtn:setVisible(DATA_Mission.no_tip_sharetask_monster ~= 0)
		end

    	no_selectBtn = createMenuItem(tempLayer , "res/component/checkbox/1.png" , cc.p(170, 110), function() selectFun(1) end)
    	selectBtn = createMenuItem(tempLayer , "res/component/checkbox/1-1.png" , cc.p(170, 110), function() selectFun(0) end)
    	createLabel(tempLayer, game.getStrByKey("ping_btn_no_more"), cc.p(195, 110), cc.p(0, 0.5), 20, true, nil, nil, MColor.yellow_gray, nil, nil, MColor.black, 3)
    	selectBtn:setVisible(DATA_Mission.no_tip_sharetask_monster ~= 0)
	end

	if not DATA_Mission.no_tip_sharetask_monster then
		DATA_Mission.no_tip_sharetask_monster = 0
	end

	if DATA_Mission.no_tip_sharetask_monster == 0 then
		dlgFunc()
		return false
	else
		return true
	end
end

function teamTreasureTaskLayer:FindOneTarget(data)
	if not data then
		return
	end

    -------------------------------------------------------
    -- target list
	for i = 1, #data.posData do
        -- 顺序开放
		if data.targetState[i] < data.targetCount[i] then
            if data.targetData and (i-1) <= data.targetData.cur_num then
                local target_data = data.posData[i]
		        if target_data then
			        self:findTarget(data.posData[i])
                    break;
                end
            end
		end
	end

end

function teamTreasureTaskLayer:findTarget(target_data)
	DATA_Mission:setLastTarget( { 
									id = target_data.ID , 
									mapid = target_data.map_id , 
									pos = { x = target_data.x , y = target_data.y } 
								} )	

	local map_id = target_data.map_id
	local pos_x = target_data.x
	local pos_y = target_data.y

	cclog("[teamTreasureTaskLayer:findTarget] called. map_id = %s, pos_x = %s, pos_y = %s.", map_id, pos_x, pos_y)

	local tempData = {targetType = 4, mapID = map_id, x = pos_x, y = pos_y}
	__TASK:findPath(tempData)
	__removeAllLayers()
end

return teamTreasureTaskLayer
