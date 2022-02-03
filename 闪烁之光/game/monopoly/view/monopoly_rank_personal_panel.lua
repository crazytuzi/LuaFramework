---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/17 15:46:08
-- @description: 圣夜奇境 个人排行界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()

MonopolyPersonalRankPanel = class("MonopolyPersonalRankPanel",function()
    return ccui.Layout:create()
end)

function MonopolyPersonalRankPanel:ctor(step_id)
	self.step_id = step_id
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("monopoly/monopoly_rank_guild_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    self.empty_bg = self.scroll_container:getChildByName("empty_bg")
    self.empty_bg:setVisible(false)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N("暂无记录"))

    local title_bg = self.root_wnd:getChildByName("title_bg")
    title_bg:setVisible(false)

    local scroll_size = self.scroll_container:getContentSize()
    local size = cc.size(scroll_size.width, scroll_size.height-10)
    local setting = {
        item_class = MonopolyPersonalRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 614,
        item_height = 125,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, nil, nil, nil, size, setting)

    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")
    my_rank_title:setString(TI18N("我的排名"))

    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)
    self.rank_x = self.rank_img:getPositionX()
    self.rank_y = self.rank_img:getPositionY()

    self.role_name = my_container:getChildByName("role_name")
    self.role_name:setVisible(true)
    self.atk_image = my_container:getChildByName("atk_image")
    self.atk_image:setVisible(true)
    self.atk_txt = self.atk_image:getChildByName("atk_txt")
    self.no_rank = my_container:getChildByName("no_rank")
    self.no_rank:setString(TI18N("未上榜"))
    self.no_rank:setVisible(false)
    self.my_rank_txt = my_container:getChildByName("rank_id")
    self.my_score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(520, 65), nil, nil, 300)
    my_container:addChild(self.my_score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container

    self:registerEvent()
end

function MonopolyPersonalRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(MonopolyEvent.Get_Personal_Rank_Data_Event, function(data) 
            if data and data.id == self.step_id then
            	self:updateRankList(data)
            end
        end)
    end
end

function MonopolyPersonalRankPanel:setNodeVisible(status)
    self:setVisible(status)
end

function MonopolyPersonalRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
    	if self.step_id then
    		_controller:sender27502(self.step_id)
    	end
        self.is_init = false
    end
end

function MonopolyPersonalRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.role_name:setString(role_vo.name)
        self.atk_txt:setString(role_vo.power)
        self.role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        self.role_head:setLev(role_vo.lev)
        local avatar_bid = role_vo.avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        local my_rank_data = {}
        for k, v in pairs(data.rank_list or {}) do
            if v.rid == role_vo.rid and v.srv_id == role_vo.srv_id then
                my_rank_data = v
                break
            end
        end

        if next(my_rank_data) == nil then
            self.my_rank_txt:setVisible(false)
            self.rank_img:setVisible(false)
            self.no_rank:setVisible(true)
            self.my_score_info:setString(TI18N("<div>造成伤害:</div><div fontcolor=#249003 fontsize=22>0</div>"))
        else
            if my_rank_data.rank and my_rank_data.rank <= 3 then
                self.my_rank_txt:setVisible(false)
                if my_rank_data.rank == 0 then
                    self.rank_img:setVisible(false)
                    self.no_rank:setVisible(true)
                else
                    self.no_rank:setVisible(false)
                    local res_id = PathTool.getResFrame("common", string.format("common_200%d", my_rank_data.rank or 1))
                    if self.rank_res_id ~= res_id then
                        self.rank_res_id  = res_id
                        loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                    end
                    self.rank_img:setVisible(true)
                end
            else
                self.my_rank_txt:setVisible(true)
                self.my_rank_txt:setString(my_rank_data.rank or 0)
                self.rank_img:setVisible(false)
            end
            self.my_score_info:setString(string.format(TI18N("<div>造成伤害:</div><div fontcolor=#249003 fontsize=22>%s</div>"), MoneyTool.GetMoneyWanString(my_rank_data.dps or 0)))
        end

        if data.rank_list ~= nil and next(data.rank_list) ~= nil then
            table.sort(data.rank_list, SortTools.KeyLowerSorter("rank"))
            self.scroll_view:setData(data.rank_list)
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
        end
    end
end

function MonopolyPersonalRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
    if self.role_head then
    	self.role_head:DeleteMe()
    	self.role_head = nil
    end
    if self.rank_num then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end

------------------------------@ item
MonopolyPersonalRankItem = class("ElementRankItem",function()
    return ccui.Layout:create()
end)

function MonopolyPersonalRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("monopoly/monopoly_rank_personal_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_img = container:getChildByName("rank_img")
    self.role_name = container:getChildByName("role_name")
    self.role_power = container:getChildByName("role_power")

    self.wish_container = container:getChildByName("wish_container")
    self.wish_num_txt = self.wish_container:getChildByName("num")

    self.score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(505, 32), nil, nil, 300)
    container:addChild(self.score_info)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function MonopolyPersonalRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end,false)

    registerButtonEventListener(self.wish_container, handler(self, self.onClickWishBtn), true)
end

function MonopolyPersonalRankItem:onClickWishBtn()
    if self.data then
        RoleController:getInstance():requestWorshipRole(self.data.rid, self.data.srv_id, self.data.rank, WorshipType.monopoly)
        self.data.worship_num = self.data.worship_num + 1
        self.data.worship_status = 1
        self.wish_num_txt:setString(self.data.worship_num)
        self.wish_container:setTouchEnabled(false)
        setChildUnEnabled(true, self.wish_container)
    end
end

function MonopolyPersonalRankItem:setData(data)
    if data then
        self.data = data
        self.role_name:setString(data.name)
        self.role_power:setString(data.power)
        self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        local avatar_bid = data.avatar_bid 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if data.rank <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.rank == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%d", data.rank or 1))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(59, 77)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(data.rank)
            self.rank_img:setVisible(false)
        end
        local msg = string.format(TI18N("<div>造成伤害:</div><div fontcolor=#249003 fontsize=22>%s</div>"), MoneyTool.GetMoneyWanString(data.dps or 0))
        self.score_info:setString(msg)

        -- 点赞
        self.wish_num_txt:setString(data.worship_num)
        self.wish_container:setTouchEnabled(data.worship_status == 0)
        setChildUnEnabled(data.worship_status == 1, self.wish_container)
    end
end

function MonopolyPersonalRankItem:DeleteMe()
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    if self.role_head then
    	self.role_head:DeleteMe()
    	self.role_head = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end