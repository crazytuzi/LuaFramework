--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-05 14:16:55
-- @description    : 
		-- 跨服竞技场 宝可梦 item
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

CrossareanRoleItem = CrossareanRoleItem or BaseClass()

function CrossareanRoleItem:__init(parent)
    self.is_init = false
    self.parent = parent
    self:createRoorWnd()
    self:registerEvent()
end

function CrossareanRoleItem:createRoorWnd(  )
	self.size = cc.size(220, 430)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("crossarena/crossarena_role_item"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
        self.root_wnd:setVisible(false)
    end

    self.container = self.root_wnd:getChildByName("container")

    self.challenge_btn = self.container:getChildByName("challenge_btn")
    local btn_size = self.challenge_btn:getContentSize()
    self.challenge_btn_label = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.challenge_btn_label:setString(TI18N("挑战"))
    self.challenge_btn:addChild(self.challenge_btn_label)

    self.ticket_bid = Config.ArenaClusterData.data_const["arena_ticket"].val
    local item_config = Config.ItemData.data_get_data(self.ticket_bid) 
    if item_config then
        self.challenge_btn_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /><div shadow=0,-2,2,#920eb3>3 挑战</div>"), PathTool.getItemRes(item_config.icon)))
    end

    self.txt_role_name = self.container:getChildByName("txt_role_name")
    self.txt_score = self.container:getChildByName("txt_score")
    --self.txt_atk = self.container:getChildByName("txt_atk")
    self.image_atk_bg = self.container:getChildByName("image_atk_bg")
    self.txt_atk = CommonNum.new(20, self.image_atk_bg, 0, 0, cc.p(0.5, 0.5))
    self.txt_atk:setPosition(self.image_atk_bg:getContentSize().width*0.5,self.image_atk_bg:getContentSize().height*0.5+14)
end

function CrossareanRoleItem:registerEvent(  )
    registerButtonEventListener(self.container, handler(self, self.onClickRoleItem), false)

    registerButtonEventListener(self.challenge_btn, handler(self, self.onClickRoleItem), true)

    if not self.update_single_role_event then
        self.update_single_role_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Update_Single_Challenge_Role_Event, function ( data )
            if data and data.idx and self.data and self.data.idx == data.idx then
                self:setData(data)
            end
        end)
    end
end

function CrossareanRoleItem:onClickRoleItem(  )
    if self.data and _model:checkCrossarenaIsOpen() then
        if self.data.rid == 0 then
            message(TI18N("新赛季已开启，请刷新对手"))
            return
        end
        _controller:sender25602( self.data.rid, self.data.srv_id )
    end
end

-- 挑战
function CrossareanRoleItem:onClickChallengeBtn(  )
    if self.data and _model:checkCrossarenaIsOpen() then
        if self.data.rid == 0 then
            message(TI18N("新赛季已开启，请刷新对手"))
            return
        end
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.CrossArena, {rid = self.data.rid, srv_id = self.data.srv_id}, HeroConst.FormShowType.eFormFight)
    end
end

function CrossareanRoleItem:setData( data, index )
	if not data then return end

	self.data = data

    -- 名称
    self.txt_role_name:setString(transformNameByServ(data.name or "", data.srv_id, true))

    -- 积分
    self.txt_score:setString(_string_format(TI18N("积分:%d"), data.score or 0))

    -- 战力
    self.txt_atk:setNum(changeBtValueForPower(data.power or 0))
    -- 模型
    if self.role_spine then
        self.role_spine:DeleteMe()
        self.role_spine = nil
    end
    if data.look then
        self.role_spine = BaseRole.new(BaseRole.type.role, data.look)
        self.role_spine:setCascade(true)
        self.role_spine:setAnchorPoint(cc.p(0.5, 0))
        self.role_spine:setAnimation(0,PlayerAction.show,true)
        self.parent:addChild(self.role_spine, 1)

        local pos_x = 15 + (index-1)*(15+self.size.width)
        self.role_spine:setPosition(cc.p(pos_x+self.size.width*0.5, 480+218))
        if index and index == 2 then
            self.role_spine:setLocalZOrder(2)
        end
    end

    self:setItemPos(index)
end

-- 位置
function CrossareanRoleItem:setItemPos( index )
    if index and not self.cur_index or self.cur_index ~= index then
        local star_x = 15
        local distance_x = 15
        local pos_x = star_x + (index-1)*(distance_x+self.size.width)
        self.root_wnd:setPosition(cc.p(pos_x, 500))
        self.root_wnd:setVisible(true)
        self.cur_index = index
    end
end

function CrossareanRoleItem:__delete()
    if self.role_spine then
        self.role_spine:DeleteMe()
        self.role_spine = nil
    end
    if self.update_single_role_event then
        GlobalEvent:getInstance():UnBind(self.update_single_role_event)
        self.update_single_role_event = nil
    end
end