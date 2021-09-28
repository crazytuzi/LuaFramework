--仇人展示数据
SOCIAL_DATA = {}

--获取仇人数据
function SOCIAL_DATA:getEnemyList(  )
    SOCIAL_DATA.foe_list = nil
    SOCIAL_DATA.socialName = ""
    -- 空值校验
    if G_ROLE_MAIN then
        --g_msgHandlerInst:sendNetDataByFmtExEx(RELATION_CS_GETRELATIONDATA,"ic",G_ROLE_MAIN.obj_id,2)
        g_msgHandlerInst:sendNetDataByTableExEx(RELATION_CS_GETRELATIONDATA, "GetRelationDataProtocol", {relationKind = 2})
    end
    local function saveDataFun( ... )
      local sevData = { ... }
      sevData = sevData[1]
      local load_data = {}
      -- local type_data = sevData:readByFmt("c") 
      -- local enemy_num = sevData:readByFmt("c") 
      -- for i=1,enemy_num do 
      --   load_data[i] = {sevData:readByFmt("iSccciii") }
      --   load_data[i][9] = true
      -- end 
      -- local enemy_num = sevData:readByFmt("c")
      -- local online_num = #load_data 
      -- for i=1,enemy_num do 
      --   load_data[online_num+i] = {sevData:readByFmt("iSccciii") }
      -- end
      local t = g_msgHandlerInst:convertBufferToTable("GetRelationDataRetProtocol", sevData) 
      local relationType = t.relationKind
      if relationType == 2 then
        for i,v in ipairs(t.roleData) do
          local record = {}
          record[1] = v.roleSid
          record[2] = v.name
          record[3] = v.level
          record[4] = v.sex
          record[5] = v.school
          record[6] = v.fightAbility
          record[7] = v.killNum
          record[8] = v.beKillNum
          if v.isOnLine then
            table.insert(load_data, 1, record)
          else
            table.insert(load_data, record)
          end
        end

        SOCIAL_DATA[ "foe_list" ] = load_data
      end

    end
    g_msgHandlerInst:registerMsgHandler( RELATION_SC_GETRELATIONDATA_RET , saveDataFun )
end
--清空数据
function SOCIAL_DATA:clearData()  
  SOCIAL_DATA[ "foe_list" ] = nil
  SOCIAL_DATA.isHave = false 
end

function SOCIAL_DATA:init()  
  SOCIAL_DATA:getEnemyList()
  SOCIAL_DATA.isHave = false     --是否存在新仇人
  SOCIAL_DATA.socialName = ""     --新仇人名字
end


--检查是否是新仇人
function SOCIAL_DATA:checkHandler( fightList )
    if tonumber( fightList[2] ) == 2 then
      local function showFun()
            SOCIAL_DATA.isHave = true
            if G_MAINSCENE then G_MAINSCENE:showEnemyHead() end
      end
      local function checkData()
          local _idx = 0 
          for i = 1 , #SOCIAL_DATA[ "foe_list" ]  do
            if SOCIAL_DATA[ "foe_list" ][i][2] == fightList[3] then
              _idx = i
              break
            end
          end

          if _idx == 0 then 
            showFun() 
            SOCIAL_DATA[ "foe_list" ][ #SOCIAL_DATA[ "foe_list" ] + 1 ] = { 0 , fightList[3] } --假数据添加进仇人列表，使下次不展示该仇敌
            SOCIAL_DATA.socialName = fightList[3]
          end
      end
 
      if not SOCIAL_DATA[ "foe_list" ] or ( SOCIAL_DATA[ "foe_list" ] and #SOCIAL_DATA[ "foe_list" ] == 0 ) then
        -- local function delayFun()
        --   --经过服务器的数据 foe_list 一定存在
        --   if #SOCIAL_DATA[ "foe_list" ] == 0 then
        --     --还没有仇人
        --     showFun()
        --   else
        --     checkData()
        --   end
        -- end
        showFun()
        SOCIAL_DATA:getEnemyList()
      else
        checkData()
      end

  end

end


function SOCIAL_DATA:popupBox()
  --弹出对话框
  SOCIAL_DATA.isHave = false  --点击了屏幕按钮
  local tip = MessageBoxYesNo(nil,string.format( game.getStrByKey("revenge") , SOCIAL_DATA.socialName ),function() __GotoTarget( {ru = "a47"} ) end,function() __GotoTarget( { ru = "a167", index = 2 } ) end,game.getStrByKey("fight_log"),game.getStrByKey("details"))
  if tip then
    local closeFunc = function()
      removeFromParent(tip)
      tip = nil
    end
    createTouchItem(tip, "res/component/button/x2.png", cc.p(tip:getContentSize().width-30, tip:getContentSize().height-25), closeFunc)
  end
end

return SOCIAL_DATA