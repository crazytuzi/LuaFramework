-- CityFriendListLayer

require "app.cfg.target_info"
require "app.cfg.function_level_info"


local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    if stroke then
        label:createStroke(stroke, 1)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    img:loadTexture(texture, texType)
    
end

local function _convertTimeUnit(duration)
    
    if duration < 60 or duration < 3600 then
        return tostring(math.max(1, math.floor(duration / 60)))..G_lang:get('LANG_CITY_FRIEND_OFFLINE_TIME_MIN_UNIT_DESC')
    elseif duration >= 3600 and duration < 3600 * 24 then
        return tostring(math.floor(duration / 3600))..G_lang:get('LANG_CITY_FRIEND_OFFLINE_TIME_HOUR_UNIT_DESC')
    else
        return tostring(math.floor(duration / 3600/24))..G_lang:get('LANG_CITY_FRIEND_OFFLINE_TIME_DAY_UNIT_DESC')
    end
end

local CityFriendListLayer = class("CityFriendListLayer", UFCCSModelLayer)

function CityFriendListLayer.create(...)
    return CityFriendListLayer.new("ui_layout/city_FriendCityListLayer.json", Colors.modelColor, ...)
end

function CityFriendListLayer:ctor(_, _, callback)
    
    CityFriendListLayer.super.ctor(self)
    
    self._callback = callback
    
    self._friendList = {}
    
    -- 自适应屏幕高度，这里需要设置否则弹框的整体摆放位置会不对
    self:adapterWithScreen()

    -- 关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end
    
    self:registerBtnClickEvent("Button_close", _onClose)
    self:registerBtnClickEvent("Button_close1", _onClose)
    
    self:enableAudioEffectByName("Button_close", false)
    self:enableAudioEffectByName("Button_close1", false)

    self:getLabelByName("Label_help_friend_desc"):setText("")

end

function CityFriendListLayer:onLayerEnter()
    
    self:showAtCenter(true)
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

    G_Me.cityData:getFriendList(function(message)
        
        message.id = message.id or {}

        local startIndex = #self._friendList

        -- 合并数据
        for i=1, #message.id do
            self._friendList[#self._friendList+1] = {id=message.id[i], riot=message.riot[i], patrol=message.patrol[i], num=message.num[i]}
        end

        table.sort(self._friendList, function(a, b)
            return a.riot > b.riot or (a.riot == b.riot and (a.patrol > b.patrol or (a.patrol == b.patrol and a.num > b.num)))
        end)

        self:_initCityFriendList(startIndex)
        
    end)
    
end

function CityFriendListLayer:_initCityFriendList(startIndex)
    
    if not self._listView then
    
        local list = self:getPanelByName("Panel_list")
        local listview = CCSListViewEx:createWithPanel(list, LISTVIEW_DIR_VERTICAL)
        
        self._listView = listview
        
        -- 现阶段不分页
--        listview:setShowMoreEnable(true)
--
--        listview:setShowMoreHandler(function ( list, topLeft, bottomRight )
--            if bottomRight then
--                if self._next then
--                    self._next()
--                end
--            end
--        end)
        
        -- 分别设置创建方法和更新方法
        listview:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/city_FriendCityListCell.json")

            item:registerBtnClickEvent("Button_get_in", function()
                if self._callback then
                    self._callback(G_Me.friendData:getFriendByUid(self._friendList[item:getCellIndex()+1].id))
                end
                self:animationToClose()
            end)

            return item
        end)

        listview:setUpdateCellHandler(function(list, index, cell)

            local friend = G_Me.friendData:getFriendByUid(self._friendList[index+1].id)

            -- 更新名字
            _updateLabel(cell, "Label_name", friend.name, Colors.strokeBlack, Colors.qualityColors[knight_info.get(friend.mainrole).quality])

            -- 玩家头像
            local dress_id = rawget(friend, "dress_id")
            _updateImageView(cell, "Image_icon", G_Path.getKnightIcon(G_Me.dressData:getDressedResidWithClidAndCltm(friend.mainrole, dress_id ,rawget(friend, "clid"),rawget(friend, "cltm"),rawget(friend, "clop"))), UI_TEX_TYPE_LOCAL)

            -- 品级框
            _updateImageView(cell, "Image_frame", G_Path.getEquipColorImage(knight_info.get(friend.mainrole).quality), UI_TEX_TYPE_PLIST)

            -- 离线x小时/在线
            _updateLabel(cell, "Label_online_time", G_GlobalFunc.getOnlineTime(friend.online), nil, friend.online == 0 and Colors.lightColors.TIPS_01 or Colors.lightColors.TIPS_02)
            
            -- 等级
            _updateLabel(cell, "Label_level", G_lang:get("LANG_CITY_FRIEND_LEVEL_DESC", {level=friend.level}))
            
            -- 已有城池
            _updateLabel(cell, "Label_city_desc1", G_lang:get('LANG_CITY_FRIEND_DESC1', {amount=self._friendList[index+1].num}))
            -- 巡逻中的城池
            _updateLabel(cell, "Label_city_desc2", G_lang:get('LANG_CITY_FRIEND_DESC2', {amount=self._friendList[index+1].patrol}))
            -- 暴动中的城池
            _updateLabel(cell, "Label_city_desc3", G_lang:get('LANG_CITY_FRIEND_DESC3', {amount=self._friendList[index+1].riot}))
            
            -- 暴动火焰标识
            cell:getImageViewByName("Image_riot_icon"):setVisible(self._friendList[index+1].riot > 0)
            
        end)
        
        listview:initChildWithDataLength(#self._friendList, 0.2)
        
    else
        
        self._listView:reloadWithLength(#self._friendList, startIndex)
        
    end
    
    -- 可帮好友镇压次数
    local cityData = G_Me.cityData
    _updateLabel(self, "Label_help_friend_desc", G_lang:get("LANG_CITY_FRIEND_HELP_AMOUNT_DESC", {amount=cityData:getRemainAssistCount()}), Colors.strokeBlack)
    
end


return CityFriendListLayer

