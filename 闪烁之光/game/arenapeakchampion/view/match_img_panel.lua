-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--        匹配界面
-- <br/> 2019年11月13日
-- --------------------------------------------------------------------
MatchImgPanel = class("MatchImgPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function MatchImgPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function MatchImgPanel:config()
    self.play_effect_list = {}
end

function MatchImgPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenapeakchampion/match_img_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5, 0.5))

    self.container = self.root_wnd:getChildByName("container")
    -- self.container:setSwallowTouches(false)

    --中间的
    self.cetre_panel = self.container:getChildByName("cetre_panel")
    self.cetre_node = self.cetre_panel:getChildByName("head_node")
    self.cetre_node:setZOrder(3)

    self.fight_line_list = {}
    for i=1,12 do
        self.fight_line_list[i] = self.container:getChildByName("fight_line_"..i)
    end
    self.fight_line_list[13] = self.cetre_panel:getChildByName("fight_line_13")
    self.fight_line_list[14] = self.cetre_panel:getChildByName("fight_line_14")

    self.match_head_item_list = {}
    for i=1,14 do
        local head_node = self.container:getChildByName("head_node_"..i)
        head_node:setZOrder(3)
        self.match_head_item_list[i] = MatchHeadItem.new()
        self.match_head_item_list[i]:addCallBack(function() self:onPlayBtn(i) end)
        head_node:addChild(self.match_head_item_list[i])
    end

    self.match_head_item_list[15] = MatchHeadItem.new()
    self.match_head_item_list[15]:addCallBack(function() self:onPlayBtn(15) end)
    self.cetre_node:addChild(self.match_head_item_list[15])
end

--事件
function MatchImgPanel:registerEvents()
    -- registerButtonEventListener(self.province_btn, function() self:onProvinceBtn()  end ,false, 1)
    registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, 1)

    --获取称号
    -- if self.get_title_list_event == nil then
    --     self.get_title_list_event = GlobalEvent:getInstance():Bind(RoleEvent.GetTitleList,function ( data )
    --         if not data then return end
    --         self:updateHonorInfo(data.base_id)
    --     end)
    -- end
end

--点击省份
function MatchImgPanel:onPlayBtn(index)
    if not self.pos_list then return end
    if not self.zone_id then return end
    if not self.group then return end

    local _type = 1
    if self.match_type == 64 then
        _type = 2
    elseif self.match_type == 8 then
        _type = 3
        self.group = 0
    end

    local data = self.pos_list[index]
    if data then
        controller:sender27712(self.zone_id, _type, self.group, data.pos)
    end
end

function MatchImgPanel:setExtendDdata(zone_id, group)
    self.zone_id = zone_id
    self.group = group or 0
end

--pos_list 结构参考 27709 或者 27710的pos_glit 结构
--@match_type 会传 256 64 8 代表各自 256 强.....
function MatchImgPanel:setData(pos_list, match_type)
    local main_data = model:getMainData()
    if not main_data then return end

    if not match_type then return end
    for i,v in ipairs(self.fight_line_list) do
        v:setVisible(false)
    end
    -- if self.match_type and self.match_type ~= match_type then
        for i,v in pairs(self.play_effect_list) do
            v:setVisible(false)
        end
    -- end 

    self.match_type = match_type
    self.pos_list = pos_list
    local effect_times =  1
    doStopAllActions(self.container)

    for i,item in ipairs(self.match_head_item_list) do
        if pos_list and pos_list[i] then
            item:setData(pos_list[i], match_type, i)
            if i == 9 then
                self:setFightlineShow(1 , pos_list[1])
            elseif i == 10 then
                self:setFightlineShow(3 , pos_list[3])
            elseif i == 11 then
                self:setFightlineShow(5 , pos_list[5])
            elseif i == 12 then
                self:setFightlineShow(7 , pos_list[7])
            elseif i == 13 then
                self:setFightlineShow(9 , pos_list[9])
            elseif i == 14 then
                self:setFightlineShow(11 , pos_list[10])
            elseif i == 15 then
                self:setFightlineShow(13 , pos_list[13])
            end
            if pos_list[i].ret == 0 and main_data.round_status ~= 1 then
                delayRun(self.container, effect_times * 0.05, function() 
                    self:showEffectLine(i, true)
                end)
                effect_times = effect_times +1
            end
        else
            item:setData(nil, match_type, i)
        end
    end
end

function MatchImgPanel:showEffectLine(index, bool)
    if not self.play_effect_list then return end
    if bool == true then
        if self.play_effect_list[index] == nil then
            local  size = self.container:getContentSize()
            local action = nil
            if index <= 8 then
                action = PlayerAction.action_1
            elseif index > 8 and index <= 12 then
                action = PlayerAction.action_2
            else
                action = PlayerAction.action_3
            end
            local pos, scale_x, scale_y = self:getPosAndScale(index)
            if not pos then return end
            self.play_effect_list[index] = createEffectSpine("E27402", cc.p(200, 200), cc.p(0.5, 0.5), true, action)
            self.play_effect_list[index]:setPosition(pos)
            self.play_effect_list[index]:setScale(scale_x, scale_y)
            if index >= 13  then
                self.cetre_panel:addChild(self.play_effect_list[index], 1)
            else
                self.container:addChild(self.play_effect_list[index], 1)
            end
        else
            self.play_effect_list[index]:setVisible(true)
        end    
    else
        if self.play_effect_list[index] then 
            self.play_effect_list[index]:setVisible(false)
            self.play_effect_list[index]:removeFromParent()
            self.play_effect_list[index] = nil
        end
    end
end
--获取位置 和 缩放(镜像用)
function MatchImgPanel:getPosAndScale( index)
    if index == 1 then
        return  cc.p(154, 692), -1, 1
    elseif index == 2 then
        return  cc.p(154, 543), -1, -1
    elseif index == 3 then
        return  cc.p(154, 265), -1, 1
    elseif index == 4 then
        return  cc.p(154, 116), -1, -1
    elseif index == 5 then
        return  cc.p(567, 692), 1, 1
    elseif index == 6 then
        return  cc.p(567, 543), 1, -1
    elseif index == 7 then
        return  cc.p(567, 265), 1, 1
    elseif index == 8 then
        return  cc.p(567, 116), 1, -1

    elseif index == 9 then              -- 9 -12
        return  cc.p(264, 617), -1, 1
    elseif index == 10 then
        return  cc.p(264, 190), -1, 1
    elseif index == 11 then
        return  cc.p(450, 617), 1, 1
    elseif index == 12 then
        return  cc.p(450, 190), 1, 1

    elseif index == 13 then
        return  cc.p(96, 240), 1, -1   
    elseif index == 14 then
        return  cc.p(96, 0), 1, 1        
    end
end

function MatchImgPanel:setFightlineShow(i, data)
    if not self.fight_line_list[i] and not self.fight_line_list[i+1] then return end
    if data.ret == 1 then
        self.fight_line_list[i]:setVisible(true)
    elseif data.ret == 2 then
        self.fight_line_list[i+1]:setVisible(true)
    end
end

function MatchImgPanel:setCetrePanelVisible(status)
    local status = status or false
    if self.cetre_panel then
        self.cetre_panel:setVisible(status)
    end
end

--移除
function MatchImgPanel:DeleteMe()
    for i,v in ipairs(self.match_head_item_list) do
        v:DeleteMe()
    end
    doStopAllActions(self.container)
    
    for i=1,14 do
        self:showEffectLine(false, i)
    end
    self.match_head_item_list = {}
end


--比赛头像对象
MatchHeadItem = class("MatchHeadItem", function()
    return ccui.Widget:create()
end)

function MatchHeadItem:ctor(parent)
    self.parent = parent
    self:configUI()
    self:register_event()
end

function MatchHeadItem:configUI()
    local width = 130
    local height = 150
    self.size = cc.size(width, height)
    -- self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenapeakchampion/match_head_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.bg = self.container:getChildByName("bg")
    self.head_img = self.container:getChildByName("head_img")
    self.head_img:setPosition(52, 87)
    self.name = self.container:getChildByName("name")
    self.svr_name = self.container:getChildByName("svr_name")
    self.index = self.container:getChildByName("index")
    self.index:setVisible(false)
    self.play_btn = self.container:getChildByName("play_btn")

    local node = self.container:getChildByName("node")
    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setHeadLayerScale(0.8)
    self.head:setLev(99)
    self.head:addCallBack(function() self:onClickHead() end )
    node:addChild(self.head)
end

function MatchHeadItem:register_event( )
    registerButtonEventListener(self.play_btn, function() self:onPlayBtn() end, true, 2, nil, nil, 1)
end

function MatchHeadItem:onClickHead()
    if not self.data then return end
    local rid = self.data.rid
    local srv_id = self.data.srv_id
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo and rid == roleVo.rid and srv_id == roleVo.srv_id then 
        message(TI18N("这是你自己~"))
        return
    end

    if srv_id == "" then
        message(TI18N("角色信息丢失在异域中"))
        return
    end
    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = srv_id, rid = rid})
end

-- 播放录像
function MatchHeadItem:onPlayBtn()
    if not self.data then return end
    if self.callback then
        self:callback()
    end
end

function MatchHeadItem:addCallBack( callback )
    self.callback = callback
end

function MatchHeadItem:showEffect(bool, effect_id)
    if not self.container then return end
    if bool == true then
        if self.play_effect == nil then
            local  size = self.container:getContentSize()
            self.play_effect = createEffectSpine("E27403", cc.p(size.width * 0.5, size.height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.container:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

function MatchHeadItem:getNumIndex(match_type, index)
    
    if index >= 1 and index <= 8 then
        return match_type
    elseif index >= 9 and index <= 12 then
        return match_type/2
    elseif index == 13 or index == 14 then
        return match_type/4
    else
        return match_type/8
    end
end

function MatchHeadItem:showHeadImg(match_type)
    self.head:setHeadLayerScale(0.9)
    --15位置
    local res = nil
    if match_type == 64 or match_type == 256 then
        --64强 .的背景框特殊处理
        res = PathTool.getResFrame("arenapeakchampion","arenapeakchampion_promotion_05", false, "arenapeak_guessing")
    elseif match_type == 8 then
        res = PathTool.getResFrame("arenapeakchampion","arenapeakchampion_promotion_01", false, "arenapeak_guessing")
    end
    if res then
        self.head_img:setVisible(true)
        loadSpriteTexture(self.head_img, res, LOADTEXT_TYPE_PLIST)
        self:showEffect(true)
    end
end



function MatchHeadItem:setData(data, match_type, index)
    local  is_hide_lev = false
    self:setLev(false)
    if index == 15 then
        is_hide_lev = true
        self:showHeadImg(match_type)
    elseif match_type == 256 and (index == 13 or index ==14 ) then
        is_hide_lev = true
        self:showHeadImg(match_type)
    else
        self.head:setHeadLayerScale(0.8)
        self.head_img:setVisible(false)
        self:showEffect(false)
    end

    if data == nil then
        self.data = nil
        self.head:clearHead()
        self.head:closeLev()
        local bgRes = PathTool.getResFrame("common","common_1031")
        self.head:showBg(bgRes, nil, true)

        self.play_btn:setVisible(false)
        self.bg:setVisible(false)
        self.name:setVisible(false)
        self.svr_name:setVisible(false)

        self.index:setVisible(true)
        local num = self:getNumIndex(match_type, index)
        self.index:setString(num)
        setChildUnEnabled(false, self.container)
        return
    end

    if not data then return end

    self.index:setVisible(false)

    self.data = data

    local pos = self.data.new_pos or self.data.pos
    if pos > 8 then
        self.play_btn:setVisible(true)
    else
        self.play_btn:setVisible(false)
    end

    
    self:setHeadInfo(is_hide_lev)
    
    if self.data.ret == 1 then --胜利
        --不用显示名字
        self:setNameInfoVisible(false)
        self:setPlayBtnPos(true)
        setChildUnEnabled(false, self.container)

    elseif self.data.ret == 2 then --失败的
        self:setNameInfoVisible(true)
        self:setNameinfo()
        self:setPlayBtnPos(false)
        setChildUnEnabled(true, self.container)
    else
        self:setNameInfoVisible(true)
        self:setNameinfo()
        self:setPlayBtnPos(false)
        setChildUnEnabled(false, self.container)
    end
end

function MatchHeadItem:setNameinfo( )
    if not self.data then return end
    self.name:setString(self.data.name)
    local srv_name = getServerName(self.data.srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    self.svr_name:setString(string_format("[%s]",srv_name))
end

function MatchHeadItem:setLev(status, lev, pos)
    if status then
        if not self.txtLev then
            if not self.levBg then
                self.levBg = createSprite(PathTool.getResFrame("common","common_1030"), 10, 84, LOADTEXT_TYPE_PLIST)
                self.levBg:setCascadeOpacityEnabled(true)
            else
                self.levBg:setVisible(true)
            end
            self.levBg:setAnchorPoint(cc.p(0, 0))
            self:addChild(self.levBg,1)

            local scale = 0.9
            self.levBg:setScale(scale)

            self.txtLev = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[152],self.levBg:getContentSize().width/2-2,self.levBg:getContentSize().height/2+1,"",self.levBg,1,cc.p(0.5,0.5))
            self.txtLev:setLocalZOrder(1)
        end
        if self.levBg then
            self.levBg:setVisible(true)
        end
        self.txtLev:setString(lev)
        if pos ~= nil and self.levBg ~= nil then
            self.levBg:setPosition(pos)
        end
    else
        if self.levBg then
            self.levBg:setVisible(false)
        end
    end
end

function MatchHeadItem:setHeadInfo(is_hide_lev)
    if not self.data then return end
    local face_file = nil
    local face_update_time = nil
    if self.data.ext and next(self.data.ext) ~= nil then
        for i,v in ipairs(self.data.ext) do
            if v.ext_type == 1 then
                face_update_time = v.ext_val
                face_file = v.ext_str_val
            end
        end
    end
    local face_id = self.data.face_id or 1001
    self.head:setHeadRes(face_id, false, LOADTEXT_TYPE, face_file, face_update_time)
    if is_hide_lev then
        self.head:closeLev()
        self:setLev(true,self.data.lev or 1)
    else
        self.head:setLev(self.data.lev or 1)
    end
            
    local avatar_bid = self.data.avatar_bid or 1000
    if self.record_res_bid == nil or self.record_res_bid ~= avatar_bid then
        self.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.head:showBg(res, nil, false, vo.offy)
        else
            local bgRes = PathTool.getResFrame("common","common_1031")
            self.head:showBg(bgRes, nil, true)
        end
    end
end


--播放按钮显示
function MatchHeadItem:setPlayBtnPos(is_centre)
    if is_centre then
        self.play_btn:setPositionX(52)
    else
        local size = self.name:getContentSize()
        self.play_btn:setPositionX(52 - size.width * 0.5 - 15)
    end
end

--设置显示名字信息
function MatchHeadItem:setNameInfoVisible(status)
    if status then
        self.bg:setVisible(true)
        self.name:setVisible(true)
        self.svr_name:setVisible(true)
    else
        self.bg:setVisible(false)
        self.name:setVisible(false)
        self.svr_name:setVisible(false)
    end
end

--置灰
function MatchHeadItem:setUnEnabled(status)
    if status then
        setChildUnEnabled(true, self.container)
        self.name:disableEffect(cc.LabelEffect.OUTLINE)
        self.svr_name:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.container)
        self.name:enableOutline(cc.c4b(0x00,0x00,0x00,0xff), 2)
        self.svr_name:enableOutline(cc.c4b(0x00,0x00,0x00,0xff), 2)
    end
end

function MatchHeadItem:DeleteMe()
    self:showEffect(false)
    if self.head then
        self.head:DeleteMe()
        self.head = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

