--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-08 15:41:27
-- @description    : 
		-- 赛季荣耀 item
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()

CrossareanHonourItem = CrossareanHonourItem or BaseClass()

function CrossareanHonourItem:__init(parent)
    self.is_init = false
    self.parent = parent
    self:createRoorWnd()
    self:registerEvent()
end

function CrossareanHonourItem:createRoorWnd(  )
	self.size = cc.size(220, 460)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("crossarena/crossarena_honour_item"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
        self.root_wnd:setVisible(false)
    end

    self.container = self.root_wnd:getChildByName("container")

    self.image_top = self.container:getChildByName("image_top")
    self.image_title = self.container:getChildByName("image_title")
    self.image_stage = self.container:getChildByName("image_stage")
    self.like_btn = self.container:getChildByName("like_btn")
    self.like_btn_label = self.like_btn:getChildByName("label")
    self.txt_role_name = self.container:getChildByName("txt_role_name")
    self.txt_no_role = self.container:getChildByName("txt_no_role")

    self.txt_role_name:setVisible(false)
    self.txt_no_role:setVisible(false)
    self.like_btn:setVisible(false)
end

function CrossareanHonourItem:registerEvent(  )
    registerButtonEventListener(self.container, handler(self, self.onClickRoleItem), false)

    registerButtonEventListener(self.like_btn, handler(self, self.onClickLikeBtn), true)

    if self.update_worship_event == nil then
        self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
            if self.data and idx and self.data.rank == idx then
                self.data.worship = self.data.worship + 1
                self.like_btn_label:setString(self.data.worship)
                self.like_btn:setTouchEnabled(false)
                setChildUnEnabled(true, self.like_btn)
                self.like_btn_label:setColor(cc.c3b(0xff,0xff,0xff))
            end
        end)
    end
end

function CrossareanHonourItem:onClickRoleItem(  )
    local role_vo = RoleController:getInstance():getRoleVo()
    if self.data and self.data.rid and self.data.srv_id and role_vo then
        if role_vo.rid == self.data.rid and role_vo.srv_id == self.data.srv_id then
            message(TI18N("你连自己都不认识了么？"))
        else
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end
end

function CrossareanHonourItem:onClickLikeBtn(  )
	if self.data and self.data.rid and self.data.srv_id and self.data.rank then
        RoleController:getInstance():requestWorshipRole(self.data.rid, self.data.srv_id, self.data.rank, WorshipType.crossarena)
    end
end

function CrossareanHonourItem:setData( data, index )
    if not index then return end

	if data then
        self.data = data

        -- 模型
        if self.role_spine then
            self.role_spine:DeleteMe()
            self.role_spine = nil
        end
        if data.lookid then
            self.role_spine = BaseRole.new(BaseRole.type.role, data.lookid)
            self.role_spine:setCascade(true)
            self.role_spine:setAnchorPoint(cc.p(0.5, 0))
            --self.role_spine:setPosition(cc.p(self.size.width*0.5, 225))
            self.role_spine:setAnimation(0,PlayerAction.show,true)
            self.parent:addChild(self.role_spine, 1)
        end

        -- 名称
        self.txt_role_name:setString(transformNameByServ(data.name, data.srv_id, true))

        -- 膜拜按钮
        self.like_btn_label:setString(data.worship or 0)
        if data.worship_status == 0 then -- 可以膜拜
            self.like_btn:setTouchEnabled(true)
            setChildUnEnabled(false, self.like_btn)
        else
            self.like_btn:setTouchEnabled(false)
            setChildUnEnabled(true, self.like_btn)
        end
        self.like_btn_label:setColor(cc.c3b(0xff,0xff,0xff))

        self.txt_role_name:setVisible(true)
        self.like_btn:setVisible(true)
        self.txt_no_role:setVisible(false)
    else
        self.txt_role_name:setVisible(false)
        self.like_btn:setVisible(false)
        self.txt_no_role:setVisible(true)
    end


    -- 称号
    local title_res = CrossarenaConst.Title_Res[index]
    if title_res then
        self.title_load = loadSpriteTextureFromCDN(self.image_title, PathTool.getTargetRes("honor", title_res, false, false), ResourcesType.single, self.title_load)
    end

    -- 位置
    if index then
        local star_x = 15
        local distance_x = 15
        local pos_x = star_x + (index-1)*(distance_x+self.size.width)
        self.root_wnd:setPosition(cc.p(pos_x, 440))
        if self.role_spine then
            self.role_spine:setPosition(cc.p(pos_x+self.size.width*0.5, 480+180))
        end
        self.root_wnd:setVisible(true)

        if index == 1 then
            loadSpriteTexture(self.image_top, PathTool.getResFrame("arenaenter", "arenaenter_1001"), LOADTEXT_TYPE_PLIST)
        elseif index == 2 then
            loadSpriteTexture(self.image_top, PathTool.getResFrame("arenaenter", "arenaenter_1002"), LOADTEXT_TYPE_PLIST)
            self.image_top:setPositionY(self.image_top:getPositionY()+12)
            self.image_title:setPositionY(self.image_title:getPositionY()+38)
            self.image_stage:setPositionY(self.image_stage:getPositionY()+12)
            self.txt_role_name:setPositionY(self.txt_role_name:getPositionY()+32)
            self.txt_no_role:setPositionY(self.txt_no_role:getPositionY()+12)
            if self.role_spine then
                self.role_spine:setPositionY(self.role_spine:getPositionY()+12)
                self.role_spine:setLocalZOrder(2)
            end
        elseif index == 3 then
            loadSpriteTexture(self.image_top, PathTool.getResFrame("arenaenter", "arenaenter_1000"), LOADTEXT_TYPE_PLIST)
        end
    end
end

function CrossareanHonourItem:__delete()
    if self.role_spine then
        self.role_spine:DeleteMe()
        self.role_spine = nil
    end
    if self.title_load then
        self.title_load:DeleteMe()
        self.title_load = nil
    end
    if self.update_worship_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
    end
end