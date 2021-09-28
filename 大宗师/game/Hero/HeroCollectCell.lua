
local data_field_field = require("data.data_field_field")
local data_battle_battle = require("data.data_battle_battle")
local data_world_world = require("data.data_world_world")

local HeroCollectCell = class("HeroCollectCell", function ()
 -- -- display.addSpriteFramesWithFile("ui/ui_equip.plist", "ui/ui_equip.png")
 --    display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
 --    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")

    return CCTableViewCell:new()		
	 
end)

function HeroCollectCell:getContentSize()
    -- local sprite = display.newSprite("#herolist_board.png")
    return CCSizeMake(display.width, 140) --sprite:getContentSize()
end

function HeroCollectCell:refresh(id)
    self.lvlIndex = self.data[id]


    local name = data_battle_battle[self.lvlIndex].name
    local fieldName = data_field_field[ data_battle_battle[self.lvlIndex].field].name

    self.fieldId = data_battle_battle[self.lvlIndex].field
    self.battleId = self.lvlIndex
    self.bigMapName = data_world_world[data_field_field[self.fieldId].world].name

    
    self.fubenName:setString("")
    self.submapName:setString(name)
    self.fubenName:removeAllChildren()
    local bigMapTTF = ui.newTTFLabelWithShadow({
    text = self.bigMapName,
    size = 24,
    color = ccc3(255,139,45),
    shadowColor = ccc3(0,0,0),
    font = FONTS_NAME.font_fzcy,
    align = ui.TEXT_ALIGN_LEFT
    })
    self.fubenName:addChild(bigMapTTF)

    local subMapTTF = ui.newTTFLabelWithShadow({
    text = fieldName,
    size = 24,
    color = ccc3(255,208,44),
    shadowColor = ccc3(0,0,0),
    font = FONTS_NAME.font_fzcy,
    align = ui.TEXT_ALIGN_LEFT
    })
    subMapTTF:setPosition(bigMapTTF:getPositionX() + bigMapTTF:getContentSize().width+20,bigMapTTF:getPositionY())
    self.fubenName:addChild(subMapTTF)

    --在这里判断当前的地图的信息  必须得知道
    --判断当前的大地图能不能点
    --判断当前的小地图能不能点
    --如果两个都能点则将按钮设置可点击，否则则设置为不能点击 
    local maxFiledId = self.lvlData["2"]
    local maxSubId   = self.lvlData["3"]

    if self.fieldId <= maxFiledId and self.battleId <= maxSubId  then
        self.goto_btn:setEnabled(true)
    else
        self.goto_btn:setEnabled(false)
    end
    
     
end

function HeroCollectCell:toSubMap()

     GameStateManager:ChangeState(GAME_STATE.STATE_SUBMAP, {submapID = self.fieldId, subMap = self._subMap,battleId = self.battleId })
    -- GameStateManager:ChangeState(GAME_STATE.STATE_FUBEN,msg)

end

function HeroCollectCell:getLvlList()
        local bigMapID  = data_field_field[data_battle_battle[self.lvlIndex].field].world
        print("bigMapID"..bigMapID)
        RequestHelper.getLevelList({
        id = bigMapID,
        callback = function(data)
        print("dfdfdjkdkdkdk")
            -- dump(data) 
            local bgName = "bigmap_1"
            if data["0"] == "" then
                self._curLevel = {
                    bigMap = data["1"],  --大地图
                    subMap = data["2"],  --小地图
                    level  = data["3"]   --小关卡
                }
                self._subMap = data["4"] 
                 -- 打到的最大关卡
                game.player.m_maxLevel = data["3"] 

                game.player:setBattleData({
                        cur_bigMapId = data["1"], 
                        cur_subMapId = data["2"], 
                        new_subMapId = data["2"] 
                    })
                -- 世界地图背景音乐
                local soundName = ResMgr.getSound(data_world_world[bigMapID].bgm)
                GameAudio.playMusic(soundName, true)

                self:toSubMap()
            end

        end
    }) 
end



function HeroCollectCell:create(param)
    local _id       = param.id 

    self.data = param.listData
    self.lvlData = param.lvlData

     -- self._subMap = self.lvlData["4"] 
  
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("hero/hero_collect_cell.ccbi", proxy, self._rootnode)
    node:setPosition(0, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self.fubenName = self._rootnode["fuben_name"]

    self.submapName = self._rootnode["submap_name"]

    self.goto_btn = self._rootnode["goto_btn"]
 

    self.goto_btn:addHandleOfControlEvent(function(eventName,sender)         
         self:getLvlList()      
    end,
    CCControlEventTouchUpInside)  


    self:refresh(_id + 1)      

    return self

end

function HeroCollectCell:beTouched()
	
	
end

function HeroCollectCell:onExit()
	-- display.removeSpriteFramesWithFile("submap/submap.plist", "submap/submap.png")
	-- display.removeSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")
end

function HeroCollectCell:runEnterAnim(  )

end



return HeroCollectCell