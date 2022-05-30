-- --------------------------------------------------------------------
-- 头像框
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleFacePanel = class("RoleFacePanel", function()
    return ccui.Widget:create()
end)

function RoleFacePanel:ctor(setting)
    if setting then
        --配置的是物品id
        self.show_item_id = setting.id
    end
    self:config() 
    self:layoutUI()
    self:registerEvents()
    self.is_first = true
end
function RoleFacePanel:config()
    self.ctrl = RoleController:getInstance()
    self.size = cc.size(624,660)
    self:setContentSize(self.size)
    self.item_list = {}
    self.group_list = {}
    self.have_list = {}
    self.role_vo = self.ctrl:getRoleVo()
end
function RoleFacePanel:layoutUI()
    self.main_panel = ccui.Widget:create()
    self.main_panel:setContentSize(self.size)
    self.main_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.main_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self:addChild(self.main_panel)

    
    self.scroll_view = createScrollView(self.size.width - 30,self.size.height -10, 15, 14,self.main_panel,ccui.ScrollViewDir.vertical)
    -- self.scroll_view:setAnchorPoint(cc.p(0.5,0.5))
    self.scroll_view_size = self.scroll_view:getContentSize()

    --local bg = createImage(self.main_panel, PathTool.getResFrame("common","common_90024"), self.size.width/2,self.size.height/2, cc.p(0.5,0.5), true, -1)
    --bg:setScale9Enabled(true)
    --bg:setContentSize(self.size)

    --self:createBaseMessage()
    local res = PathTool.getResFrame("common","common_1017")
    self.use_btn = createButton(self.main_panel, TI18N("更 换"), self.size.width/2 , -36, cc.size(161,62), res, 26, Config.ColorData.data_color4[1])
    self.use_btn:setAnchorPoint(cc.p(0.5,0.5))
    --self.use_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.use_btn:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

    self.ctrl:sender21500()
end

function RoleFacePanel:setData(data)
    if not data then return end
    self.data = data
end
--事件
function RoleFacePanel:registerEvents()
    if self.use_btn then 
        self.use_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if self.select_item and self.select_item:getData() then 
                    local data = self.select_item:getData()
                    
                    if data and data.base_id then 
                        local is_lock = self.select_item:getIsLock() or false 
                        if is_lock == true then 
                            self.ctrl:sender21503(data.base_id)
                            return 
                        end
                        local bid = data.base_id
                        if data.group == 110 then 
                            
                            for i,v in pairs(self.have_list) do 
                                if self:isSameGroup(v.base_id,data.base_id) then 
                                    bid = v.base_id
                                end
                            end
                        end
                        self.ctrl:sender21501(bid)
                    end
                end
            end
        end)
    end
    if not self.open_view_event then 
        self.open_view_event = GlobalEvent:getInstance():Bind(RoleEvent.GetFaceList,function(data)
            --Debug.info(data)
            if data and data.avatar_frame then 
                for i,v in pairs(data.avatar_frame) do 
                    if v and v.base_id then 
                        self.have_list[v.base_id] = v
                        local config = Config.AvatarData.data_avatar[v.base_id]
                        if config and config.group then
                            self.group_list[config.group] =config
                        end
                    end
                end
            end
            self:createItemList()
        end)
    end
    --使用头像框成功
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
			self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key,value)
				if key == "avatar_base_id" then 
                    if self.role_vo and self.role_vo.avatar_base_id then 
                        for i,item in pairs(self.item_list) do 
                            if item and item:getData() then 
                                local info = item:getData()
                                item:showUseIcon(false)
                                if (info and info.base_id == self.role_vo.avatar_base_id) or
                                    (info and self:isSameGroup(info.base_id,self.role_vo.avatar_base_id)==true and self:getGroupByBid(info.base_id) == 110)
                                then 
                                    item:showUseIcon(true)
                                    --self:updateMessage(info)
                                end
                                
                            end
                        end
                    end
                end
			end)
		end
    end
end

function RoleFacePanel:createItemList()
    local num = Config.AvatarData.data_avatar_length or 0
    local config = Config.AvatarData.data_avatar 
    if not config then return end 
    local index =1
    
    -- local check_is_has = function(bid)
    --     local is_have = false
    --     if self.have_list and next(self.have_list or {}) ~= nil then
    --         for i, v in pairs(self.have_list) do
    --             if v.base_id == bid then
    --                 is_have = true
    --                 break
    --             end
    --         end
    --     end
    --     return is_have
    -- end

    local array = Array.New()
    for i,v in pairs(config) do 
        if v.is_show == 1 then
            v.has = 3 --这个没激活
            if v.loss and next(v.loss or {}) ~= nil then
                local loss_bid = v.loss[1][1]
                local loss_num = v.loss[1][2]
                if not self.have_list[v.base_id] then --如果是不存在已在列表又尚未激活的
                    local has_num = BackpackController:getModel():getBackPackItemNumByBid(loss_bid)
                    if has_num >= loss_num then --可激活的
                        v.has = 0
                    end
                end
            else --这个就是默认
                v.has = 1
            end

            array:PushBack(v)
        end
    end

    for i=1,array:GetSize() do
        local v = array:Get(i-1)
        if self.have_list[v.base_id] then --已经拥有的
            v.has = 2
        end
    end
    array:LowerSortByParams("has","base_id")
    --array:LowerSort("base_id")

    local item_width = self.scroll_view_size.width / 4
    local item_height = 175
    local col = 4

    local height = math.max(self.scroll_view_size.height,(math.ceil(array:GetSize()/col))*item_height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view_size.width,height))


    for i=1,array:GetSize() do 
        local v = array:Get(i-1)
        if not self.item_list[v.base_id] then 
            local item = RoleFaceItem.new()
            self.scroll_view:addChild(item)
            self.item_list[v.base_id] = item
            item:setTouchFunc(function(face_item,vo)
                if self.select_item then 
                    self.select_item:setSelected(false)
                end
                self.select_item = face_item
                self.select_item:setSelected(true)
                local is_lock = self.select_item:getIsLock() or false 
                if is_lock == true then 
                    self.use_btn:setBtnLabel(TI18N("激 活"))
                else
                    self.use_btn:setBtnLabel(TI18N("更 换"))
                end
                if self.is_first==false then
                    local world_pos = self.select_item:convertToWorldSpace(cc.p(0, 0))
                    TipsManager:getInstance():showFaceTips(2, face_item:getData(), cc.p(world_pos.x, world_pos.y+100))
                else
                    self.is_first = false
                end
            end)
        end
        self.item_list[v.base_id]:setData(v)
        if self.have_list[v.base_id] then 
            self.item_list[v.base_id]:showLock(false)
        end
        if self.group_list[v.group] and v.group == 110 then 
            self.item_list[v.base_id]:showLock(false)
        end
        if self.show_item_id ~= nil and (v.base_id == self.role_vo.avatar_base_id or (self:isSameGroup(v.base_id,self.role_vo.avatar_base_id)==true and self:getGroupByBid(v.base_id) == 110)) then 
            self.item_list[v.base_id]:showUseIcon(true)
        end
        if not self.select_item then 
            if self.show_item_id ~= nil then    --从tips传过来的物品id
                if v.loss and v.loss[1] and v.loss[1][1] and v.loss[1][1] == self.show_item_id then --当传过来的物品id和需要物品id相同
                    self.item_list[v.base_id]:clickHandler()
                end
            elseif self.role_vo and self.role_vo.avatar_base_id and self.role_vo.avatar_base_id ~=0 then 
                if v.base_id == self.role_vo.avatar_base_id or (self:isSameGroup(v.base_id,self.role_vo.avatar_base_id)==true and self:getGroupByBid(v.base_id) == 110) then 
                    self.item_list[v.base_id]:showUseIcon(true)
                    self.item_list[v.base_id]:clickHandler()
                end
            end
        else 
            if self.select_item and self.select_item:getData() then  
                local is_lock = self.select_item:getIsLock() or false 
                local data = self.select_item:getData()
                if is_lock == true then
                    self.use_btn:setBtnLabel(TI18N("激 活")) 
                else
                    self.use_btn:setBtnLabel(TI18N("更 换"))
                end
               
            end
        end
        local x = item_width * (( i - 1) % col) + item_width * 0.5
        local y = height - math.ceil(i / col) * item_height + 100
        self.item_list[v.base_id]:setPosition(cc.p(x, y))
    end
end
--是否是同组的
function RoleFacePanel:isSameGroup(bid1,bid2)
    local config_1 = Config.AvatarData.data_avatar[bid1]
    if not config_1 then return false end
    local config_2 = Config.AvatarData.data_avatar[bid2]
    if not config_2 then return false end

    if config_1.group and config_1.group == config_2.group then 
        return true
    end
    return false
end
--根据bid获取该组id
function RoleFacePanel:getGroupByBid(bid)
    local config = Config.AvatarData.data_avatar[bid]
    if not config then return 0 end 
    return config.group or 0
end

function RoleFacePanel:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool == true then 
        --self:updateMessage()
    else
        -- self.select_item = nil
    end
end
function RoleFacePanel:createTimer(value)
    value = value or 0
    if self.timer then 
        GlobalTimeTicket:getInstance():remove(self.timer)
        self.timer = nil
    end
    local count = value
    if not self.timer then 
        self.timer = GlobalTimeTicket:getInstance():add(function()
            local str = TimeTool.GetTimeFormatDay(count)
            -- local str= TimeTool.GetTimeFormatDayIV(count)
            self.use_time:setString(string.format( TI18N("使用期限：<div fontcolor=#289b14>%s</div>"),str))
            count = count -1
            if count == 0 then 
                if self.timer then 
                    GlobalTimeTicket:getInstance():remove(self.timer)
                    self.timer = nil
                end
            end
        end,1,value)
    end
end
function RoleFacePanel:DeleteMe()
    if self.timer then 
        GlobalTimeTicket:getInstance():remove(self.timer)
        self.timer = nil
    end
    if self.open_view_event then 
        GlobalEvent:getInstance():UnBind(self.open_view_event)
        self.open_view_event = nil
    end
    if self.head_icon then 
        self.head_icon:DeleteMe()
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    for i,v in pairs(self.item_list) do 
        if v and v.DeleteMe then 
            v:DeleteMe()
        end
    end
    self.item_list = nil
end



-- --------------------------------------------------------------------
-- 头像框子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleFaceItem = class("RoleFaceItem", function()
	return ccui.Widget:create()
end)

function RoleFaceItem:ctor(index)
	self.width = 164
	self.height = 164
	self.index =index or 1
    self.is_lock = false
    self.is_use =false
    self.is_can_active = false
	self.ctrl = RoleController:getInstance()
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
   	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:configUI()
end

function RoleFaceItem:clickHandler(  )
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function RoleFaceItem:setTouchFunc( value )
	self.call_fun =  value
end

function RoleFaceItem:getTouchPos(  )
    return self.touchPos or nil
end
--[[
@功能:创建视图
@参数:
@返回值:
]]
function RoleFaceItem:configUI( ... )
	--底内框 
    self.back = ccui.Widget:create()
    self.back:setCascadeOpacityEnabled(true)
    self.back:setContentSize(cc.size(self.width, self.height))
    self.back:setAnchorPoint(cc.p(0, 0))
    self.back:setTouchEnabled(true)
    self:addChild(self.back)

    --local res = PathTool.getResFrame("common","common_1032")
    self.icon_bg = createImage(self.back,"",self.width/2,69,cc.p(0.5,0.5),true,0,false)
    self.back:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touchPos = sender:getTouchBeganPosition()
			self:clickHandler()
        end
    end)
    --选择框
    self.select = ccui.ImageView:create(PathTool.getTargetRes("face/txt_face","txt_face_using"), LOADTEXT_TYPE)
    --self.select:setScale9Enabled(true)
	--self.select:setContentSize(cc.size(self.width+10, self.height+10))
	self.select:setAnchorPoint(cc.p(0.5,0.5))
	--self.select:setCapInsets(cc.rect(20,20,2,2))
	self.select:setPosition(cc.p(self.width/2,65))
	self.select:setVisible(false)
    self:addChild(self.select)

    -- 选择光效
    self.select_light = ccui.ImageView:create(PathTool.getTargetRes("face","face_01",false), LOADTEXT_TYPE)
	self.select_light:setAnchorPoint(cc.p(0.5,0.5))
	self.select_light:setPosition(cc.p(self.width/2,65))
	self.select_light:setVisible(false)
    self:addChild(self.select_light, -1)
   
    self.face_icon = createImage(self.back, nil, self.width/2, 70, cc.p(0.5,0.5), false, 1, false)

    self.face_name_bg = createImage(self.back, PathTool.getResFrame("common","common_90003"), self.width/2,-27, cc.p(0.5,0), true)
    self.face_name_bg:setScale9Enabled(true)
    self.face_name_bg:setCapInsets(cc.rect(23, 1, 1, 1))

    self.face_name_bg:setContentSize(cc.size(109,42))
    self.face_name = createLabel(16,Config.ColorData.data_color4[1],nil,self.width/2-2,-20,"",self.back,0, cc.p(0.5,0))
    

    local res = PathTool.getResFrame("common","common_1014")
    self.red_point = createImage(self.back, res, 110, 135, cc.p(0,0), true, 3, false)
    self.red_point:setVisible(false)

    self.active = createSprite(PathTool.getResFrame("common", "txt_cn_common_30017"), 80, 35, self)
    self.active:setLocalZOrder(99)
    self.active:setScale(0.7)
    self.active:setVisible(false)

    self:showLock(true)
end

function RoleFaceItem:showActive(bool)
    if self.active then
        self.active:setVisible(bool)
    end
end


function RoleFaceItem:setFaceNameBgY( y )
    self.face_name_bg:setPositionY(y)
    self.face_name:setPositionY(y+6)
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function RoleFaceItem:setData( data,index )
	if data == nil then return end
	if next(data) == nil then 		
		self:reset()
		return 
	end
	self.index = index
	self:reset()
    self.vo = data
    if data.has ~= 0 then
        self.active:setVisible(false)
    else
        self.active:setVisible(true)
    end

    local face_id = data.res_id or 1
    local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..face_id,false,false)
    self.scale = 1
    if face_id == 0 then
        self.scale = 100/117
        self.face_icon:setScale(self.scale)
    else
        self.scale = 95/117
        self.face_icon:setScale(self.scale)
    end
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.face_icon) then
                self.face_icon:loadTexture(res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    local config = Config.AvatarData.data_avatar[data.base_id]
    if config then
        self.icon_bg:setPositionY(self.icon_bg:getPositionY()-config.offy)
    end
    local name = data.name or ""
    self.face_name:setString(name)
    if StringUtil.SubStringGetTotalIndex(name) >= 5 then
        self.face_name_bg:setContentSize(cc.size(self.face_name:getContentSize().width + 20,33))
    end
    

    self:updateRedPoint()
end 

function RoleFaceItem:showBgEffect(bool, effect_id, scale)
    if not self.icon_bg then
        return
    end
    if bool == false then
        if self.bg_effect then
            self.bg_effect:clearTracks()
            self.bg_effect:removeFromParent()
            self.bg_effect = nil
        end
	else
		if effect_id.is_only_effect == 1 then
			self.face_icon:setVisible(false)
		else
			self.face_icon:setVisible(true)
		end
        if self.bg_effect == nil then
            local x, y
            if effect_id.effect_pos_x == 0 then
				x = 69
            else
				x = effect_id.effect_pos_x + 15
			end
			if effect_id.effect_pos_y == 0 then
				y = 69
            else
				y = effect_id.effect_pos_y + 15
			end
            scale = scale or 1
            self.bg_effect = createEffectSpine(effect_id.effect_id, cc.p(x, y), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.bg_effect:setScale(scale)
            self.back:addChild(self.bg_effect, 1)
        else
            self.bg_effect:setVisible(true)
        end
    end
end 

function RoleFaceItem:setSelected(bool)
    self.select:setVisible(bool)
    self.select_light:setVisible(bool)
end
--锁定
function RoleFaceItem:showLock(bool)
    self.red_point:setVisible(false)
    self.is_can_active = false
    self.is_lock = bool 
    setChildUnEnabled(bool,self.back,cc.c4b(255, 255, 255, 255))
    setChildUnEnabled(false,self.select)
    setChildUnEnabled(false,self.select_light)
    setChildUnEnabled(false,self.icon_bg)
    if bool == true then 
        self:updateRedPoint()    
    end

    if not bool and self.vo then
        local face_id = self.vo.res_id or 1
        local effect_id = Config.AvatarData.data_avatar_effect[face_id]
        if effect_id and effect_id.effect_id ~= "" then
            self:showBgEffect(true , effect_id, self.scale)
        end
    end
end
function RoleFaceItem:updateRedPoint()
    if self.vo and self.vo.loss and self.vo.loss[1]and self.vo.loss[1][1] and self.vo.loss[1][2] then 
        local bid = self.vo.loss[1][1] 
        local num = self.vo.loss[1][2]
        local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(bid)
        if count and count >num then 
            self.is_can_active = true
            self.red_point:setVisible(true)
        end
    end
end
--使用中
function RoleFaceItem:showUseIcon(bool)
    self.is_use = bool 
    if not self.use_icon and bool == false then return end 
    if not self.use_icon then 
        local res = PathTool.getTargetRes("face/txt_face","txt_face_use",false)
        self.use_icon = createImage(self, res, 79, 30, cc.p(0.5,0.5), false, 1, false)
    end
    self.use_icon:setVisible(bool)
end
function RoleFaceItem:reset()
	self.vo = nil
end

function RoleFaceItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end
function RoleFaceItem:getData( )
	return self.vo
end
function RoleFaceItem:getIsLock()
    return self.is_lock
end
function RoleFaceItem:getIsActive()
    return self.is_can_active
end
function RoleFaceItem:getIsUse()
    return self.is_use
end
function RoleFaceItem:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:showBgEffect(false)

	self:removeAllChildren()
	self:removeFromParent()
	self.vo =nil
end



