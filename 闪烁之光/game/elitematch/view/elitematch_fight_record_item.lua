--@ item
local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

ElitematchFightRecordItem = class("ElitematchFightRecordItem", function()
    return ccui.Widget:create()
end)

function ElitematchFightRecordItem:ctor()
    self:configUI()
    self:register_event()
end

function ElitematchFightRecordItem:configUI(  )
    self.size = cc.size(628,244)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("elitematch/elitematch_fight_record_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")


    self.result_win = container:getChildByName("result_win")
    self.result_loss = container:getChildByName("result_loss")
    self.result_win_x = self.result_win:getPositionX()
    self.result_loss_x = self.result_loss:getPositionX()

    self.play_btn = container:getChildByName("play_btn")
    --中间部分
    self.centre_scroe = container:getChildByName("centre_scroe")
    self.centre_war_name = container:getChildByName("centre_war_name")
    self.centre_time = container:getChildByName("centre_time")

    local _getItem = function(prefix)
        local item = {}
        item.area_name = container:getChildByName(prefix.."area_name")
        item.name = container:getChildByName(prefix.."name")
        item.rank_key = container:getChildByName(prefix.."rank_key")
        item.rank_key:setString("排行")
        item.rank_value = container:getChildByName(prefix.."rank_value")
        item.level_key = container:getChildByName(prefix.."level_key")
        item.level_key:setString("等级")
        item.level_value = container:getChildByName(prefix.."level_value")
        item.level_icon = container:getChildByName(prefix.."level_icon")
        item.level_icon_1 = container:getChildByName(prefix.."level_icon_1")
        item.head_node = container:getChildByName(prefix.."head_node")
        item.player_head = PlayerHead.new(PlayerHead.type.circle)
        --self.player_head:setScale(0.8)
        -- item.player_head:setTouchEnabled(true)
        item.head_node:addChild(item.player_head)
        return item
    end
    self.left_item = _getItem("left_")
    self.right_item = _getItem("right_")
    
end

function ElitematchFightRecordItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)

    self.left_item.player_head:addCallBack(function()
        if not self.data then return end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
    end)
    self.right_item.player_head:addCallBack(function() 
        if not self.data then return end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.def_srv_id, rid = self.data.def_rid})
    end)


end

function ElitematchFightRecordItem:onClickPlayBtn()
    if not self.data then return end
    if not self.index then return end
    -- body
    controller:openElitematchFightVedioPanel(true, self.data, self.index)
end





function ElitematchFightRecordItem:setData(data, index)
    if not data then return end
    self.data = data
    self.index = index

    if data.combat_type == BattleConst.Fight_Type.EliteMatchWar then
        self.centre_war_name:setString(TI18N("常规赛"))
        self.centre_war_name:setTextColor(cc.c4b(0x3a, 0x78, 0xc4, 0xff))
        self.centre_scroe:setString("")
    else
        self.centre_war_name:setString(TI18N("王者赛"))
        self.centre_war_name:setTextColor(cc.c4b(0xd9, 0x50, 0x14, 0xff))
        local str = string_format("%s:%s", data.win_count, data.lose_count)
        self.centre_scroe:setString(str)
    end
    
    local time = TimeTool.getYMDHM(data.time)
    self.centre_time:setString(time)


    if data.ret == 1 then --左边胜利
        self.result_win:setPositionX(self.result_win_x)
        self.result_loss:setPositionX(self.result_loss_x)
    else --右边胜利了
        self.result_loss:setPositionX(self.result_win_x)
        self.result_win:setPositionX(self.result_loss_x)
    end
    --左右
    local srv_id = data.srv_id
    local name = data.atk_name
    local rank = data.atk_rank
    local lev = data.atk_lev
    local elite_lev = data.atk_elite_lev
    local face = data.atk_face

    local face_update_time = data.atk_face_update_time
    local face_file = data.atk_face_file
    
    self:initItemInfo(self.left_item, srv_id, name, rank, lev, elite_lev, face, face_file, face_update_time)

     srv_id = data.def_srv_id
     name = data.def_name
     rank = data.def_rank
     lev = data.def_lev
     elite_lev = data.def_elite_lev
     face = data.def_face
     face_update_time = data.def_face_update_time
     face_file = data.def_face_file
    self:initItemInfo(self.right_item, srv_id, name, rank, lev, elite_lev, face, face_file, face_update_time)
end

function ElitematchFightRecordItem:initItemInfo(item, srv_id, name, rank, lev, elite_lev, face, face_file, face_update_time)
    local srv_name = getServerName(srv_id)
    item.area_name:setString(string_format("[%s]", srv_name))
    item.name:setString(name)
    if rank == 0 then
        item.rank_value:setString(TI18N("暂无"))
    else
        item.rank_value:setString(rank)
    end
    item.level_value:setString(lev)

    local config = Config.ArenaEliteData.data_elite_level[elite_lev]
    if config then
        local name = config.little_ico
        if name == nil or name == "" then
            name = "icon_iron"
        end
        local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
        item.item_load = loadSpriteTextureFromCDN(item.level_icon , bg_res, ResourcesType.single, item.item_load)

        name = config.little_name_ico
        if name == nil or name == "" then
            name = "num_1_1"
        end
        local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
        item.item_load_1 = loadSpriteTextureFromCDN(item.level_icon_1 , bg_res, ResourcesType.single, item.item_load_1)
    end

    item.player_head:setHeadRes(face, false, LOADTEXT_TYPE, face_file, face_update_time)
end

function ElitematchFightRecordItem:DeleteMe( )

    if self.left_item.item_load then
        self.left_item.item_load:DeleteMe()
        self.left_item.item_load = nil
    end
    if self.right_item.item_load then
        self.right_item.item_load:DeleteMe()
        self.right_item.item_load = nil
    end
    if self.left_item.item_load_1 then
        self.left_item.item_load_1:DeleteMe()
        self.left_item.item_load_1 = nil
    end
    if self.right_item.item_load_1 then
        self.right_item.item_load_1:DeleteMe()
        self.right_item.item_load_1 = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end