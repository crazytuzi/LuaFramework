local ma_miniMapDialog = class("ma_miniMapDialog", function() return cc.Node:create() end)
local cellColor_visited, cellColor_lightUp, cellColor_unknown = 0, 1, 2

function ma_miniMapDialog:ctor(proto)
    --test data:
    --[[
    local proto = {
	    curIndex = 3    --所在迷仙阵房间索引


	    , endIndex = 3     --大奖索引
	    , prizeIndexs = {4, 5, 6}  --小奖房间索引
	    , curPathNodes = {
            {
	            index = 0           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 8    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 4           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 8    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 2           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 8    --事件状态 0未激活 1激活 2完成
            }
        }  --所通过的房间索引,格式是具体的地图信息
	    , rightPathNodes = {
            {
	            index = 0           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 2    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 4           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 1    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 2           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 0    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 3           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 2    --事件状态 0未激活 1激活 2完成
            } 
            , {
	            index = 10           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 9    --事件状态 0未激活 1激活 2完成
            } 
        }	--正确路线索引



	    , mazeNodes = {
            {
	            index = 0           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 2    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 4           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 1    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 2           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 0    --事件状态 0未激活 1激活 2完成
            }
            , {
	            index = 3           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 2    --事件状态 0未激活 1激活 2完成
            } 
            , {
	            index = 10           --房间索引
	            , mapId = 2         --地图Id
	            , openState	= 3 + 8     --门打开标志，低四位表示 0北 1东 2南 3西
	            , eventType = 4     --事件类型:需要具体定
	            , eventState = 1    --事件状态 0未激活 1激活 2完成
            } 
        } --所见迷仙阵房间具体信息
    }
    ]]
    for cellIndex, cell in ipairs(proto.mazeNodes) do
        cell.style = cellColor_lightUp
    end
    --经过的房间优先级最高,直接替换照亮范围内的房间信息
    for cellIndex, cell in ipairs(proto.curPathNodes) do
        local bool_foundCell = false
        local index_to_remove
        for k, v in ipairs(proto.mazeNodes) do
            if v.index == cell.index then
                bool_foundCell = true
                index_to_remove = k
                break
            end
        end
        if bool_foundCell then
            table.remove(proto.mazeNodes, index_to_remove)
        end
        cell.style = cellColor_visited
        table.insert(proto.mazeNodes, cell)
    end
    --正确路线的房间优先级最低，只有在照亮范围内房间信息不存在时才加入
    for k, cell in ipairs(proto.rightPathNodes) do
        local bool_foundCell = false
        for k, v in ipairs(proto.mazeNodes) do
            if v.index == cell.index then
                bool_foundCell = true
                break
            end
        end
        if not bool_foundCell then
            cell.style = cellColor_lightUp
            table.insert(proto.mazeNodes, cell)
        end
    end
    for i = 0, 7 * 7 - 1, 1 do
        local bool_foundCell = false
        for k, v in ipairs(proto.mazeNodes) do
            if v.index == i then
                bool_foundCell = true
                break
            end
        end
        if not bool_foundCell then
            table.insert(
                proto.mazeNodes
                , {
	                index = i           --房间索引
	                , mapId = 0         --地图Id，迷雾无效
	                , openState	= 0     --门打开标志，低四位表示 0北 1东 2南 3西, 迷雾无效
	                , eventType = 0     --事件类型:需要具体定, 迷雾无效
	                , eventState = 0    --事件状态 0未激活 1激活 2完成, 迷雾
                    , style = cellColor_unknown
                }
            )
        end
    end
    if proto.completed ==1 then
        for k, v in pairs(proto.mazeNodes) do
            v.style = cellColor_visited
        end
    end
    table.sort(proto.mazeNodes, function(a, b)
        return a.index < b.index
    end)
    local bg = createBgSprite(self, game.getStrByKey("mysteriousArea_title"))
    local x_offset = - 45 + 1 + 20
    local y_offset = 568
    local spr_bg = cc.Sprite:create("res/layers/mysteriousArea/bg.jpg")
    spr_bg:setPosition(cc.p(505 + x_offset, 288))
    bg:addChild(spr_bg)
    --外黑框
    createScale9Sprite(
        bg,
        "res/layers/mysteriousArea/outer_border.png",
        cc.p(20 + 13, 20 + 18),
        cc.size(894, 500),
        cc.p(0, 0)
    )
    local distance_x, distance_y = 63, 35
    --平铺底图
    for index = 0, 48, 1 do
        local x, y = (index % 7 + 1) * 2, (math.floor(index / 7) + 1) * 2
        local spr_grid_bg = cc.Sprite:create("res/layers/mysteriousArea/cell_bg.png")
        spr_grid_bg:setPosition(cc.p(x * distance_x + x_offset, - y * distance_y + y_offset))
        bg:addChild(spr_grid_bg)
    end
    local tag_gap = 100
    --先补齐服务器没有发送过来的数据，并按照index排序，再进行下面的渲染操作
    for k, v in ipairs(proto.mazeNodes) do
        --如果有门，并且不是完成状态，则认为这是一个照亮的房间，否则完成视为经过，其余激活和未激活均为迷雾
        local spr_grid_bg = cc.Sprite:create(v.style == cellColor_visited and "res/layers/mysteriousArea/cell_visited.png" or (v.style == cellColor_lightUp and "res/layers/mysteriousArea/cell_lightUp.png" or "res/layers/mysteriousArea/cell_unvisited.png"))
        GetUIHelper():AddTouchEventListener(true, spr_grid_bg, nil, function()
            if G_MAINSCENE.map_layer.currentMazeNode.index == v.index then
                return
            end
            if G_MAINSCENE.map_layer.currentMazeNode.eventState ~= 2 then
                TIPS(getConfigItemByKeys("clientmsg", {"sth", "mid"}, {38000, -9}))
                return
            end
            if v.eventState ~= 2 then
                TIPS(getConfigItemByKeys("clientmsg", {"sth", "mid"}, {38000, -8}))
                return
            end
            if not G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.transfor then
                local tempLayer
                tempLayer = MessageBoxYesNo(nil, game.getStrByKey("mysteriousArea_transfor_confirm"), function()
                    G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.transfor = (tempLayer.checkBox:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
                    G_MAINSCENE.map_layer.willEnterNextRoom = true
                    g_msgHandlerInst:sendNetDataByTable(MAZE_CS_JUMP_OTHER_REQ, "MazeJumpOtherReq", {index = v.index})
                end, nil)
    	        tempLayer.checkBox = createTouchItem(tempLayer, "res/component/checkbox/1.png", cc.p(170, 110), function(sender)
                    sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
		        end)
    	        createLabel(tempLayer, game.getStrByKey("ping_btn_no_more"), cc.p(195, 110), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black, nil, nil, MColor.black, 3)
            else
                G_MAINSCENE.map_layer.willEnterNextRoom = true
    	        g_msgHandlerInst:sendNetDataByTable(MAZE_CS_JUMP_OTHER_REQ, "MazeJumpOtherReq", {index = v.index})
            end
        end)
        local num_north = 1  --0x0001
        local num_east = 2  --0x0010
        local num_sourth = 4  --0x0100
        local num_west = 8  --0x1000
        --利用中间相隔去重
        --门的分布示意图,以下表示:
        --          door_2,1            door_4,1
        --door_1,2    2,2     door_3,2    4,2     door_5,2
        --          door_2,3            door_4,3
        --
        --门的tag拼接, 例子: door_2,1 => tag = 21
        --door index => tag
        local x, y = (v.index % 7 + 1) * 2, (math.floor(v.index / 7) + 1) * 2
        spr_grid_bg:setTag(x * tag_gap + y)
        spr_grid_bg:setPosition(cc.p(x * distance_x + x_offset, - y * distance_y + y_offset))
        bg:addChild(spr_grid_bg)
        if not bg:getChildByTag((x + 1) * tag_gap + y) and lua_byteAnd(v.openState, num_east) ~= 0 then
            local door_x, door_y = x + 1, y
            local spr_door_icon = cc.Sprite:create("res/layers/mysteriousArea/door_icon.png")
            spr_door_icon:setPosition(cc.p(door_x * distance_x + x_offset, - door_y * distance_y + y_offset))
            spr_door_icon:setRotation(0)
            spr_door_icon:setTag(door_x * tag_gap + door_y)
            bg:addChild(spr_door_icon)
        end
        if not bg:getChildByTag((x - 1) * tag_gap + y) and lua_byteAnd(v.openState, num_west) ~= 0 then
            local door_x, door_y = x - 1, y
            local spr_door_icon = cc.Sprite:create("res/layers/mysteriousArea/door_icon.png")
            spr_door_icon:setPosition(cc.p(door_x * distance_x + x_offset, - door_y * distance_y + y_offset))
            spr_door_icon:setRotation(0)
            spr_door_icon:setTag(door_x * tag_gap + door_y)
            bg:addChild(spr_door_icon)
        end
        if not bg:getChildByTag(x * tag_gap + y - 1) and lua_byteAnd(v.openState, num_north) ~= 0 then
            local door_x, door_y = x, y - 1
            local spr_door_icon = cc.Sprite:create("res/layers/mysteriousArea/door_icon.png")
            spr_door_icon:setPosition(cc.p(door_x * distance_x + x_offset, - door_y * distance_y + y_offset))
            spr_door_icon:setRotation(90)
            spr_door_icon:setTag(door_x * tag_gap + door_y)
            bg:addChild(spr_door_icon)
        end
        if not bg:getChildByTag(x * tag_gap + y + 1) and lua_byteAnd(v.openState, num_sourth) ~= 0 then
            local door_x, door_y = x, y + 1
            local spr_door_icon = cc.Sprite:create("res/layers/mysteriousArea/door_icon.png")
            spr_door_icon:setPosition(cc.p(door_x * distance_x + x_offset, - door_y * distance_y + y_offset))
            spr_door_icon:setRotation(90)
            spr_door_icon:setTag(door_x * tag_gap + door_y)
            bg:addChild(spr_door_icon)
        end
        if v.index == proto.endIndex and v.eventState ~= 2 then
            --最终大奖
            local spr_finalReward = cc.Sprite:create("res/fb/defense/boxCan1.png")
            spr_finalReward:setPosition(cc.p(50, 39))
            spr_finalReward:setScale(45 / 84)
            spr_grid_bg:addChild(spr_finalReward)
        end
        for k, prizeIndex in ipairs(proto.prizeIndexs) do
            if v.index == prizeIndex and v.eventState ~= 2 then
                --特别奖励
                local spr_normalReward = cc.Sprite:create("res/fb/defense/unpassed_box1.png")
                spr_normalReward:setPosition(cc.p(50, 39))
                spr_normalReward:setScale(45 / 84)
                spr_grid_bg:addChild(spr_normalReward)
            end
        end
    end
    local spr_user_icon = cc.Sprite:create("res/mapui/29.png")
    local cell_width, cell_height = 116, 60
    spr_user_icon:setPosition(cc.p(cell_width / 2, cell_height / 2))
    local user_x, user_y = proto.curIndex % 7 + 1, math.floor(proto.curIndex / 7) + 1
    bg:getChildByTag(user_x * 2 * tag_gap + user_y * 2):addChild(spr_user_icon)
    SwallowTouches(self)
end

return ma_miniMapDialog