--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-16 20:31:31
-- @description    : 
		-- 联盟战 据点
---------------------------------
GuildwarPositionItem = class("GuildwarPositionItem", function()
    return ccui.Widget:create()
end)

GuildwarPositionItem.Width = 190
GuildwarPositionItem.Height = 226

function GuildwarPositionItem:ctor()
	self.ctrl = GuildwarController:getInstance()
    self.model = self.ctrl:getModel()

	self.star_list = {}

	self:configUI()
	self:register_event()
end

function GuildwarPositionItem:configUI(  )
	self.size = cc.size(GuildwarPositionItem.Width, GuildwarPositionItem.Height)
	self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_postion_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self:setSwallowTouches(false)
    self.container:setSwallowTouches(false)

    local temp_index = {
        [1] = 3,
        [2] = 2,
        [3] = 1
    }
    for i=1,3 do
    	local star = self.container:getChildByName(string.format("star_%d", i))
    	if star then
    		star:setVisible(false)
            local index = temp_index[i]
    		self.star_list[index] = star
    	end
    end

    self.build = self.container:getChildByName("build")
    self.name_label = self.container:getChildByName("name_label")
    self.attk_label = self.container:getChildByName("attk_label")
    self.pos_bg = self.container:getChildByName("pos_bg")
    self.pos_label = self.pos_bg:getChildByName("pos_label")
    self.image_success = self.container:getChildByName("image_success")
    local success_label = self.image_success:getChildByName("success_label")
    success_label:setString(TI18N("挑战提升"))
    self.image_success:setVisible(false)
    self.image_success:setLocalZOrder(10)
end

function GuildwarPositionItem:register_event(  )
    self.container:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.cur_position_type == GuildwarConst.positions.others and self.data and self.data.pos then
                    local guildwar_status = self.model:getGuildWarStatus()
                    if guildwar_status == GuildwarConst.status.settlement then
                        message(TI18N("本次公会战已结束啦，不能再挑战了哦"))
                    else
                        self.ctrl:openAttkPositionWindow(true, self.data.pos)
                    end
                elseif self.cur_position_type == GuildwarConst.positions.myself and self.data and self.data.pos then
                    local role_vo = RoleController:getInstance():getRoleVo()
                    if role_vo.gid ~= 0 then
                        self.ctrl:openDefendLookWindow(true, role_vo.gid, role_vo.gsrv_id, self.data.pos) -- 我方据点直接打开据点防守记录
                    end
                end 
            end
        end
    end)
end

function GuildwarPositionItem:setData( data, position_type )
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if data ~= nil then
        self.data = data
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(GuildwarEvent.UpdateGuildWarPositionDataEvent, function()
                self:refreshPosition()
            end)
        end
        self.cur_position_type = position_type
        self:refreshPosition()
    end
end

function GuildwarPositionItem:refreshPosition(  )
    if self.data == nil then return end

    if self.data.hp == 0 then
        self.build:loadTexture(PathTool.getResFrame("guildwar","guildwar_1020"), LOADTEXT_TYPE_PLIST)
        if not self.build_fall_effect then
            self.build_fall_effect = createEffectSpine(PathTool.getEffectRes(326), cc.p(GuildwarPositionItem.Width/2+30, GuildwarPositionItem.Height/2+10), cc.p(0.5, 0), true, PlayerAction.action)
            self.container:addChild(self.build_fall_effect)
        end
        self.build_fall_effect:setVisible(true)
    else
        self.build:loadTexture(PathTool.getResFrame("guildwar","guildwar_1017"), LOADTEXT_TYPE_PLIST)
        if self.build_fall_effect then
            self.build_fall_effect:setVisible(false)
        end
    end

    for i=1,3 do
        local star = self.star_list[i]
        if i > self.data.hp then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end

    self.pos_label:setString(self.data.pos)

    local guild_srvid = ""
    if self.cur_position_type == GuildwarConst.positions.others then
        local enemy_baseinfo = self.model:getEnemyGuildWarBaseInfo()
        guild_srvid = enemy_baseinfo.g_sid or ""
    else
        local role_vo = RoleController:getInstance():getRoleVo()
        guild_srvid = role_vo.gsrv_id or ""
    end

    local index = string.find(guild_srvid, "_")
    local srv_index = 1
    if index then
        srv_index = string.sub(guild_srvid, index+1)
    end

    local name_str = string.format("[S%s]%s", srv_index, self.data.name)
    self.name_label:setString(name_str)
    self.attk_label:setString(TI18N(string.format("战力:%d", self.data.power)))

    self.image_success:setVisible(false)
    if self.cur_position_type == GuildwarConst.positions.myself then
        self.name_label:setTextColor(cc.c3b(123,194,244))
    else
        self.name_label:setTextColor(cc.c3b(244,140,123))
        self.image_success:setVisible(self.data.hp <= 0)
    end

    local name_size = self.name_label:getContentSize()
    local name_pos_x = self.name_label:getPositionX()
    self.pos_bg:setPositionX(name_pos_x-name_size.width/2)
end

-- 获取pos
function GuildwarPositionItem:getPositionPos(  )
    return self.data.pos
end

function GuildwarPositionItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
end

function GuildwarPositionItem:DeleteMe(  )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
    if self.build_fall_effect then
        self.build_fall_effect:clearTracks()
        self.build_fall_effect:removeFromParent()
        self.build_fall_effect = nil
    end
end