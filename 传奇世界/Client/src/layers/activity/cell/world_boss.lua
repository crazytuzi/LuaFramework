--[[ 世界Boss ]]--
local M = class( "world_boss" , require("src/LeftSelectNode") )

local function tablemerge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function M:refreshData()
    local function upData()
        if self["getTableView"] then 
            self:getTableView():reloadData() 
            self:updateRight()
        end
    end

    g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_CS_BOSSREQ , "WorldBossReqProtocol", {} )    --世界Boss数据请求
    g_msgHandlerInst:registerMsgHandler( ACTIVITY_SC_BOSSRET , function( buff ) 
                                                                    local t = g_msgHandlerInst:convertBufferToTable( "WorldBossReqRetProtocol" , buff ) 
                                                                    local bossNum = t.bossNum
                                                                    local bossInfo = t.bossInfo
                                                                    local data = {}
                                                                    local index = 1
                                                                    local endBoss = nil
                                                                   for i = 1 , bossNum do
                                                                        local itemInfo = {}
                                                                        local id = bossInfo[i].bossID
                                                                        -- local cfg = getConfigItemByKey( "worldBossCfg" , "q_mon_id" )[id]
                                                                        -- if (not cfg ) or (cfg.q_refresh_times and cfg.q_refresh_times == 'A' ) then
                                                                        --   sevData:popInt()
                                                                        -- else
                                                                          itemInfo["id"] = id
                                                                          itemInfo["state"] = bossInfo[i].bossLive
                                                                          itemInfo["nextTime"] = bossInfo[i].nextLiveTime -- boss下次复活时间
                                                                          itemInfo["nextState"] = bossInfo[i].isTomorrow -- 0表示不是  1表示是
                                                                          data[index] = itemInfo
                                                                          if id == 6007 then
                                                                            endBoss = index
                                                                          end                                                                          
                                                                          index = index + 1
                                                                        -- end
                                                                    end
                                                                    if endBoss then
                                                                      local temp = data[endBoss]
                                                                      data[endBoss] = data[#data]
                                                                      data[#data] = temp
                                                                    end

                                                                    self.data = data
                                                                    for key , v in pairs( self.data ) do
                                                                        local configData  = getConfigItemByKey( "worldBossCfg" , "q_mon_id" )[ v.id ]
                                                                        if configData then tablemerge( v , configData ) end
                                                                    end
                                                                    upData()
                                                                end )
    addNetLoading( ACTIVITY_CS_BOSSREQ , ACTIVITY_SC_BOSSRET )
end

function M:ctor( params )
    params = params or {}
    self.base_node = createBgSprite(self , game.getStrByKey("world_boss") )
    self.selectIdx = params.selectIdx or 0  --初始化活动默认激活项
    self.data = self:refreshData()

    --local bg = createSprite( self.base_node , "res/common/bg/bg-6.png" , cc.p( 480 , 290 ) )

    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(18 + 15, 18 + 23),
        cc.size(180, 500),
        4
    )

    local rightBg  = createSprite( self.base_node, "res/layers/activity/cell/world_boss/right_bg.jpg", cc.p( 220 , 40 ), cc.p(0, 0))
    
    self.view_node = cc.Node:create()
    setNodeAttr( self.view_node , cc.p( 214, 24 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.view_node )


    local menuitem = createMenuItem( self.base_node , "res/component/button/50.png" , cc.p( 600 + 132 , 70 ) , function() self.gotoFun() end )
    createLabel( menuitem , game.getStrByKey("find_path_go")  , getCenterPos(menuitem) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )

    self.callBackFunc = function(idx)
        --更新右侧界面
        self:updateRight()
    end

    self.normal_img = "res/component/button/40.png"
    self.select_img = "res/component/button/40_sel.png"
    local msize = size or cc.size( 190 , 490 )
    self:createTableView( self.base_node , msize , cc.p( 35 , 45 ) , true )



end


function M:updateRight() 
    if self.view_node then self.view_node:removeAllChildren()  end --清除可视内容
    local curData = self.data[ self.selectIdx + 1 ]

    local bossImg = createSprite( self.view_node , "res/layers/activity/cell/world_boss/" .. curData.q_monster_id .. ".png" , cc.p( 220 - 214 , 40 - 24 ), cc.p(0, 0) )    

    createSprite( self.view_node , "res/common/bg/titleLine.png", cc.p( 160 + 357  , 507 ) , cc.p( 0.5 , 1 ) )
    createLabel( self.view_node , "Lv." .. curData.q_monster_lv , cc.p( 160 + 303 , 498  )  , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.white , nil)
    createLabel( self.view_node , curData.gwmz , cc.p( 160 + 375 , 498  )  , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.yellow , nil )
    

    local shadowBg  = createScale9Sprite( self.view_node , "res/common/scalable/8.png", cc.p( 20 , 25 ), cc.size(310 , 480 ) , cc.p( 0 , 0 ) )
    local size = shadowBg:getContentSize()

    local desc = createLabel( shadowBg , curData.bsjs  , cc.p( 5 , 470 )  , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , 300 )
    createLabel( shadowBg , curData.cyjl  , cc.p( 5 , 470 - desc:getContentSize().height - 10 )  , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.yellow , nil , 300 )

    createSprite( shadowBg , "res/common/bg/bg65-1.png" , cc.p( size.width/2 , 230 ) , cc.p( 0.5 , 0.5 ) )
    createLabel( shadowBg , game.getStrByKey( "world_reward" ) , cc.p( size.width/2 , 230  )  , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil )
    
    local str = ""
    if curData.state == 1  then
      str = "BOSS" .. game.getStrByKey( "fieldboss_fresh" )
    else
        str = curData.nextTime ..  game.getStrByKey( "refresh" )
        if curData.nextState == 1 then
            str = game.getStrByKey( "tomorrow" ) .. str
        end
    end
    createLabel( shadowBg , str , cc.p( size.width/2 , 10  )  , cc.p( 0.5 , 0 ) , 22 , nil , nil , nil , MColor.green , nil )


    local DropOp = require("src/config/DropAwardOp")
    local tempTable = DropOp:dropItem_ex(curData[ "q_drop_id" ])
    if tablenums(tempTable) >0 then
        table.sort( tempTable , function( a , b ) return a.px < b.px end )
    end
    local awards = {}
    for j = 1 , 6 do
        if tempTable[j] then
            awards[j] =  { 
                              id = tempTable[j]["q_item"] ,       --奖励ID
                              binding = tempTable[j]["bdlx"] ,    --绑定(1绑定0不绑定)
                              streng = tempTable[j]["q_strength"] ,   --强化等级
                              quality = tempTable[j]["q_quality"] ,   --品质等级
                              upStar = tempTable[j]["q_star"] ,     --升星等级
                              time = tempTable[j]["q_time"] ,     --限时时间
                              showBind = true ,                     --掉落表数据里边的数据  就必须设置当前这个字段存在且为true
                              isBind = tonumber(tempTable[j]["bdlx"] or 0) == 1,       --绑定表现
                            }
        end
    end

    local oneTab = {}
    if tablenums( awards ) > 3 then
        table.insert( oneTab , table.remove( awards ,1 ) )
        table.insert( oneTab , table.remove( awards ,1 ) )
        table.insert( oneTab , table.remove( awards ,1 ) )
    end

    if tablenums( oneTab ) > 0 then
        local awardsGroup = __createAwardGroup( oneTab , nil , 95 )
        setNodeAttr( awardsGroup ,  cc.p( 20 , 200  ) , cc.p( 0 , 0.5 )  )
        self.view_node:addChild( awardsGroup )
    end

    if tablenums( awards ) > 0 then
        local awardsGroup = __createAwardGroup( awards , nil , 95 )
        setNodeAttr( awardsGroup ,  cc.p( 20 , 110  ) , cc.p( 0 , 0.5 )  )
        self.view_node:addChild( awardsGroup )
    end


    self.gotoFun = function()
    	local map_item = getConfigItemByKey( "monsterUpdate" , "q_id" , curData.q_monster_id )
        --不需要单独配置 后台禁飞地图设置生效就可以了
        if curData.addr_info then
            local tagInfo = stringsplit( curData.addr_info , "_" )
            map_item = { q_mapid = tonumber(tagInfo[1]) , q_center_x = tonumber(tagInfo[2]) ,  q_center_y = tonumber(tagInfo[3]) }
        end

		local function chechConditions()
			local isRefuse = false
			local mapInfoItem = getConfigItemByKey( "MapInfo" , "q_map_id" , map_item.q_mapid ) 

			--地图等级限制判断
            if mapInfoItem then
    			if not isRefuse and ( MRoleStruct:getAttr(ROLE_LEVEL) < tonumber( mapInfoItem.q_map_min_level ) )  then
    				local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
    				local msgStr = string.format( msg_item.msg , tostring( mapInfoItem.q_map_min_level  ) )
    				TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr } )
    				isRefuse = true
    				return isRefuse
    			end
            end

			return isRefuse
		end


		if chechConditions() then return end

        local tempData = { targetType = 4 , mapID =  map_item.q_mapid ,  x = map_item.q_center_x  , y = map_item.q_center_y  }
        __TASK:findPath( tempData )

		__removeAllLayers()
    end

end

function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 

    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    local itemData = self.data[ index ]

    local button = createSprite( cell , self.normal_img , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
    if button then
        local size = button:getContentSize()
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture(self.select_img)
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(size.width, size.height/2), cc.p(0, 0.5))
            arrow:setTag(20)
        end
        createLabel(button, itemData.cxdd, getCenterPos(button),cc.p(0.5, 0.5), 22, true, nil, nil )
    end

    return cell
end

function M:numberOfCellsInTableView(table)
    return self.data and tablenums( self.data ) or 0
end


return M