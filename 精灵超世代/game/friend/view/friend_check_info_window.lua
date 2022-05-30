-- --------------------------------------------------------------------
-- 竖版查看好友
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
FriendCheckInfoWindow = FriendCheckInfoWindow or BaseClass(BaseView) 

local elite_lev_data = Config.ArenaEliteData.data_elite_level
function FriendCheckInfoWindow:__init()
	self.ctrl = FriendController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "friend/friend_check_info"       	
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("friendinfo","friendinfo"), type = ResourcesType.plist },
    }
    self.item_list = {}
    self.honor_item_load = {}
    self.elfin_list = {}
end

function FriendCheckInfoWindow:open_callback(  )
	self.background_container = self.root_wnd:getChildByName("background_container")
    self.background = self.background_container:getChildByName("background")
    self.background_container:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.report_btn = self.main_panel:getChildByName("report_btn")
    self.report_btn_label = self.report_btn:getChildByName("label")

    self.friend_btn = self.main_panel:getChildByName("friend_btn")
    self.friend_btn_label = self.friend_btn:getChildByName("label")
    
    self.black_btn = self.main_panel:getChildByName("black_btn")
    self.black_btn_label = self.black_btn:getChildByName("label")

    self.pk_btn = self.main_panel:getChildByName("pk_btn")
    self.pk_btn:getChildByName("label"):setString(TI18N("切磋"))
   

    self.title_container = self.main_panel:getChildByName("title_container")
    self.title_label = self.title_container:getChildByName("title_label")
    self.title_label:setString(TI18N("个人信息"))

    self.info_con = self.main_panel:getChildByName("info_con")
    self.name = self.info_con:getChildByName("name")
    local rank_title = self.info_con:getChildByName("rank_title")
    rank_title:setString(TI18N("段位："))
    --rank_title:setTextColor(cc.c3b(155,88,37))
    self.rank = self.info_con:getChildByName("rank")
    self.rank:setString(TI18N("暂无"))
    local guild_title = self.info_con:getChildByName("guild_title")
    guild_title:setString(TI18N("公会："))
    --guild_title:setTextColor(cc.c3b(155,88,37))
    self.guild = self.info_con:getChildByName("guild")
    self.guild:setString(TI18N("暂无"))
    self.glory_btn = self.info_con:getChildByName("glory_btn")
    self.at_btn = self.info_con:getChildByName("at_btn")
    self.at_btn:setVisible(false)
    self.country = self.info_con:getChildByName("country")

    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setPosition(cc.p(10, -5))
    self.info_con:addChild(self.head)

    --self.vip_bg = self.info_con:getChildByName("Image_2")
    self.vip_icon = self.info_con:getChildByName("vip")
    self.vip_label = CommonNum.new(19, self.info_con, 0, -2, cc.p(0, 0.5))
	self.vip_label:setPosition(145, 85)

    self.main_container = self.main_panel:getChildByName("main_container")
    local fight_title = self.main_container:getChildByName("fight_title")
    fight_title:setString(TI18N("剧情战斗阵容"))
    fight_title:setPositionX(82)

    self.elfin_tree_lv = self.main_container:getChildByName("elfin_tree_lv")
    self.elfin_skill_panel = self.main_container:getChildByName("elfin_skill_panel")

    self.fight_label = CommonNum.new(20, self.main_container, 0, -2, cc.p(0, 0.5))
	self.fight_label:setPosition(390, 280)

	self.scrollCon = self.main_container:getChildByName("scrollCon")
    self.scroll_view_size = self.scrollCon:getContentSize()
    self.scroll_view = createScrollView(self.scroll_view_size.width - 10,self.scroll_view_size.height,5,0,self.scrollCon,ccui.ScrollViewDir.horizontal)
    self.scroll_view:setTouchEnabled(false)

    self.honor_item_list = {}
    for i=1,3 do
        local item_node = self.main_panel:getChildByName("item_node_"..i)
        self.honor_item_list[i] = RoleHonorItem.new(0.5, true)
        item_node:addChild(self.honor_item_list[i])
    end
end

function FriendCheckInfoWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,1)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openFriendCheckPanel(false)
			end
		end)
	end
    
	if self.glory_btn then
		self.glory_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,1)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
                local setting = {}
                setting.role_type = RoleConst.role_type.eOther
                setting.other_data = self.data
                RoleController:getInstance():openRolePersonalSpacePanel(true, setting)
			end
		end)
	end

    if self.at_btn then
        self.at_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,1)
            if event_type == ccui.TouchEventType.ended then
                local role_vo = RoleController:getInstance():getRoleVo()
                local const_data = Config.SayData.data_const
                local lev = 30
                local text = ""
                if const_data and const_data["at_condition"] then
                    lev = const_data["at_condition"].val
                    text = const_data["at_condition"].desc
                end
                if role_vo.lev < lev then
                    message(text)
                    return
                end
                playButtonSound2()
                if self.data and self.data.name then
                    if self.flag == "chat_msg" then
                        ChatController:getInstance():chatAtPeople(self.data.name, self.data.srv_id)
                    elseif self.flag == "mainchatmsg" then
                        MainuiController:getInstance():mainChatAtPeople(self.data.name, self.data.srv_id)
                    end
                    self.ctrl:openFriendCheckPanel(false)
                end
            end
        end)
    end

    for i,item in ipairs(self.honor_item_list) do
        item:addCallBack(function() self:onClickByPos(i) end)
    end
    --举报--
    registerButtonEventListener(self.report_btn, handler(self, self.onClickReportBtn) ,true, nil,nil,0.8)

    if self.friend_btn then
        self.friend_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,0.8)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data then
                    if self.model:isFriend(self.data.srv_id,self.data.rid) then
                        ChatController:getInstance():openChatPanel(ChatConst.Channel.Friend,"friend",self.data)
                        --MainuiController:getInstance():openMianChatChannel(ChatConst.Channel.Friend,self.vo)
                        self.ctrl:openFriendCheckPanel(false)
                    else
                        self.ctrl:addOther(self.data.srv_id,self.data.rid)
                        self.ctrl:openFriendCheckPanel(false)
                    end
                end
            end
        end)
    end

    if self.pk_btn then
        self.pk_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,0.8)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data then
                    if not BattleController:getInstance():getWatchReplayStatus() and not BattleController:getInstance():getModel():isInFight() then
                        local is_province = 0
                        if self.channel and self.channel == ChatConst.Channel.Cross then
                            is_province = 1
                        end
                        BattleController:getInstance():csBattlePk(self.data.rid,self.data.srv_id,is_province)
                    else
                        message(TI18N("正在观看录像或者切磋中,请先退出"))
                    end
                end
            end
        end)
    end
    if self.black_btn then
        self.black_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type,0.8)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data then
                    if self.model:isBlack(self.data.rid,self.data.srv_id) then
                        ChatController:getInstance():closeChatUseAction()
                        self.ctrl:openFriendCheckPanel(false)
                        self.ctrl:openFriendWindow(true,FriendConst.Type.BlackList)
                    else
                        local call_back = function()
                            self.ctrl:addToBlackList(self.data.rid,self.data.srv_id)
                            self.ctrl:openFriendCheckPanel(false)
                        end
                        local str = string.format(TI18N("被列入黑名单后将无法接收到该玩家发出的消息\n是否确认将<div fontColor=#289b14 fontsize= 26>%s</div>列入黑名单？\n（若为好友则会把该玩家从好友列表里删除）"), self.data.name)
                        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil)    
                    end
                end
            end
        end)
    end

	--接受数据
	if self.updateEvent == nil then
		self.updateEvent = GlobalEvent:getInstance():Bind(RoleEvent.DISPATCH_PLAYER_VO_EVENT,function ( data )
            if data and data.rid == self.rid and data.srv_id == self.srv_id then
			    self:updateData(data)
            end
		end)
	end
end

function FriendCheckInfoWindow:onClickReportBtn()
    if not self.data then return end
    local role_lv_cfg = Config.RoleData.data_role_const.role_reported_lev_limit
    local role_vo = RoleController:getInstance():getRoleVo() or {}
    local lev = role_vo.lev or 0
    if role_lv_cfg and lev < role_lv_cfg.val then
        message(role_lv_cfg.val..TI18N("级开放举报功能"))
        return
    end
    RoleController:getInstance():openRoleReportedPanel(true, self.data.rid, self.data.srv_id, self.data.name)
end

function FriendCheckInfoWindow:onClickByPos(pos)
    if self.dic_use_badges and self.dic_use_badges[pos] then
        --查看tips
        local setting = {}
        setting.id = self.dic_use_badges[pos].id
        setting.show_type = RoleConst.role_type.eOther
        setting.have_name = self.data.name
        setting.have_time = self.dic_use_badges[pos].time
        TipsController:getInstance():openHonorIconTips(true, setting)
    end
end

function FriendCheckInfoWindow:updateData( data )
	self.data = data
	self.name:setString(transformNameByServ(data.name, data.srv_id))
    self.country:setPositionX(self.name:getPositionX()+self.name:getContentSize().width+5)
	self.head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	if data.gname ~= "" then
		self.guild:setString(data.gname)
    end

    if self.data.elite_lev and self.data.elite_lev ~= 0 and elite_lev_data[self.data.elite_lev] then
        self.rank:setString(elite_lev_data[self.data.elite_lev].name)
    else
        self.rank:setString(TI18N("暂无"))
    end
    --头像框
    local vo = Config.AvatarData.data_avatar[data.avatar_bid]
    if vo then
        local res_id = vo.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head:showBg(res,nil,false,vo.offy)
    end
    self.head:setLev(data.lev)

    self.head:setSex(data.sex,cc.p(70,4))
    self.fight_label:setNum(changeBtValueForPower(data.power))

    -- 是否显示vip标识
    if data.is_show_vip and data.is_show_vip == 1 then
        --self.vip_bg:setVisible(false)
        self.vip_icon:setVisible(false)
        self.vip_label:setVisible(false)
        self.name:setPositionX(120)
    else
        --self.vip_bg:setVisible(true)
        self.vip_icon:setVisible(true)
        self.vip_label:setVisible(true)
        self.vip_label:setNum(data.vip_lev)
        self.name:setPositionX(172)
    end

    self.report_btn_label:setString(TI18N("举 报"))

    if self.model:isFriend(data.srv_id,data.rid) then
    	self.friend_btn_label:setString(TI18N("私聊"))
    else
    	self.friend_btn_label:setString(TI18N("加为好友"))
    end

    if self.model:isBlack(data.rid,data.srv_id) then
    	self.black_btn_label:setString(TI18N("黑名单"))
    else
    	self.black_btn_label:setString(TI18N("加黑名单"))
    end
    self:createPartnerList(data.partner_list)
    self.dic_use_badges = {}
    if data.use_badges and next(data.use_badges) ~= nil then
        for i,v in ipairs(data.use_badges) do
            if self.honor_item_list[v.pos] then
                self.dic_use_badges[v.pos] = v
                self.honor_item_list[v.pos]:setData(v)
                self.honor_item_list[v.pos]:setShowEffect(true)
            end
        end
    end

    -- 精灵相关
    local tree_lv = self.data.sprite_lev or 0
    self.elfin_tree_lv:setString(TI18N("古树等级：") .. tree_lv)
    for i=1,4 do
        local elfin_skill_item = self.elfin_list[i]
        if not elfin_skill_item then
            elfin_skill_item = SkillItem.new(true, true, false, 0.7, true)
            local pos_x = 50 + (i-1)*100
            elfin_skill_item:setPosition(cc.p(pos_x, 42))
            self.elfin_skill_panel:addChild(elfin_skill_item)
            self.elfin_list[i] = elfin_skill_item
        end
        self:setElfinSkillItemData(elfin_skill_item, self.data.sprites, i)
    end
end

-- 根据位置获取精灵的bid
function FriendCheckInfoWindow:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function FriendCheckInfoWindow:setElfinSkillItemData( skill_item, sprite_data, pos )
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid then
        skill_item:showLockIcon(false)
        
        local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
        if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
            skill_item:setData()
            skill_item:showLevel(false)
        else
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                skill_item:addCallBack(function() 
                    TipsManager:getInstance():showElfinTips(elfin_bid) 
                end)
                skill_item:showLevel(true)
                skill_item:setData(skill_cfg)
            end
        end
    else
        skill_item:setData()
        skill_item:showLevel(false)
        skill_item:showLockIcon(true)
    end
end

function FriendCheckInfoWindow:createPartnerList( list )
	local temp = {}
	for k,v in pairs(list) do
        local hero_vo = HeroVo.New()
        hero_vo:updateHeroVo(v)
		table.insert(temp,hero_vo)
	end
    local width = 106
    local p_list_size = #temp
    local total_width = p_list_size * width 
    local start_x = 0
    local partner_item = nil
    local max_width = math.max(total_width,self.scroll_view_size.width) 
    self.scroll_view:setInnerContainerSize(cc.size(max_width,self.scroll_view_size.height))
    
    for i,v in ipairs(temp) do
        delayRun(self.main_panel, i/60, function() 
            if self.item_list[i]==nil then 
                partner_item = HeroExhibitionItem.new(0.8, true)
                partner_item:setPosition(start_x + width * 0.5 + (i-1) * width, self.scroll_view_size.height*0.5)
                partner_item:setData(v)
                self.scroll_view:addChild(partner_item)
                self.item_list[i] = partner_item
                partner_item:addCallBack(function(item)
                    local vo = item:getData()
                    if vo and next(vo) ~=nil then 
                        local partner_id = vo.partner_id
                        if partner_id == 0 then
                            partner_id = vo.id
                        end
                        local rid = self.data.rid
                        local srv_id = self.data.srv_id 
                        LookController:getInstance():sender11061(rid,srv_id,partner_id)
                    end
                end)
            end
        end)
    end
end

function FriendCheckInfoWindow:openRootWnd(data)
    if data then
        self.rid = data.rid
        self.srv_id = data.srv_id
        self.flag = data.flag  --从聊天窗口打开时需要显示@按钮
        self.channel = data.channel -- 标记打开的聊天频道
        if data and data.rid and data.srv_id then
            RoleController:getInstance():requestRoleInfo( data.rid,data.srv_id )
        end
        if data.flag then
            self.at_btn:setVisible(true)
        end
    end
end

function FriendCheckInfoWindow:close_callback()
    for k, v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil

    for k,v in pairs(self.elfin_list) do
        v:DeleteMe()
        v = nil
    end

	if self.updateEvent then
        GlobalEvent:getInstance():UnBind(self.updateEvent)
        self.updateEvent = nil
    end

    if self.fight_label then
        self.fight_label:DeleteMe()
        self.fight_label = nil
    end

    if self.vip_label then
        self.vip_label:DeleteMe()
        self.vip_label = nil
    end

    if self.head then 
        self.head:DeleteMe()
        self.head = nil
    end
    if self.honor_item_load then
        for k,v in pairs(self.honor_item_load) do
            v:DeleteMe()
        end
        self.honor_item_load = nil
    end


	self.ctrl:openFriendCheckPanel(false)
end


