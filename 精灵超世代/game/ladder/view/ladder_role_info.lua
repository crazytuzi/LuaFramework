--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-01 20:01:19
-- @description    : 
		-- 功能描述
---------------------------------
LadderRoleInfoWindow = LadderRoleInfoWindow or BaseClass(BaseView)

local controller = LadderController:getInstance()
local model = controller:getModel()

function LadderRoleInfoWindow:__init()
	self.is_full_screen = false
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
	self.layout_name = "ladder/ladder_role_info"

	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("friend","friend"), type = ResourcesType.plist },
    }

    self.item_list = {}
end

function LadderRoleInfoWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2) 

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.challenge_btn = self.main_panel:getChildByName("challenge_btn")
    local challenge_btn_label = self.challenge_btn:getChildByName("label")
    challenge_btn_label:setString(TI18N("挑战"))
    self.black_btn = self.main_panel:getChildByName("black_btn")
    local black_btn_label = self.black_btn:getChildByName("label")
    black_btn_label:setString(TI18N("防守阵容"))

    self.title_container = self.main_panel:getChildByName("title_container")
    local title_label = self.title_container:getChildByName("title_label")
    title_label:setString(TI18N("挑战对手"))

    self.info_con = self.main_panel:getChildByName("info_con")
    self.name = self.info_con:getChildByName("name")
    local rank_title = self.info_con:getChildByName("rank_title")
    rank_title:setString(TI18N("排名："))
    self.rank = self.info_con:getChildByName("rank")
    self.rank:setString(TI18N("暂无"))
    local guild_title = self.info_con:getChildByName("guild_title")
    guild_title:setString(TI18N("公会："))
    self.guild = self.info_con:getChildByName("guild")
    self.guild:setString(TI18N("暂无"))

    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(cc.p(0, 0))
    self.head:setPosition(cc.p(10, -5))
    self.info_con:addChild(self.head)

    self.vip_label = CommonNum.new(19, self.info_con, 0, -2, cc.p(0, 0.5))
	self.vip_label:setPosition(145, 85)

	self.main_container = self.main_panel:getChildByName("main_container")
    local fight_title = self.main_container:getChildByName("fight_title")
    fight_title:setString(TI18N("战斗阵容"))

    self.fight_label = CommonNum.new(20, self.main_container, 0, -2, cc.p(0, 0.5))
	self.fight_label:setPosition(420, 178)

	self.scrollCon = self.main_container:getChildByName("scrollCon")
    self.scroll_view_size = self.scrollCon:getContentSize()
    self.scroll_view = createScrollView(self.scroll_view_size.width,self.scroll_view_size.height,0,0,self.scrollCon,ccui.ScrollViewDir.horizontal)
end

function LadderRoleInfoWindow:register_event(  )
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.black_btn, handler(self, self._onClickAdjustRoleForm))
	registerButtonEventListener(self.challenge_btn, handler(self, self._onClickBtnChallenge))

	if self.ladder_enemy_data_event == nil then
    	self.ladder_enemy_data_event = GlobalEvent:getInstance():Bind(LadderEvent.GetLadderEnemyData, function ( data )
            self:setData(data)
        end)
    end
end

function LadderRoleInfoWindow:_onClickBtnClose(  )
	controller:openLadderRoleInfoWindow(false)
end

function LadderRoleInfoWindow:_onClickAdjustRoleForm(  )
    HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.Ladder)
end

function LadderRoleInfoWindow:_onClickBtnChallenge(  )
	if self.data and self.data.rid and self.data.srv_id then
		controller:checkJoinLadderBattle(self.data.rid, self.data.srv_id)
	end
end

function LadderRoleInfoWindow:setData( data )
	self.data = data
	self.name:setString(transformNameByServ(data.name, data.srv_id))
    self.head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	if data.gname and data.gname ~= "" then
		self.guild:setString(data.gname)
    end
    --头像框
    local vo = Config.AvatarData.data_avatar[data.avatar_id or 0]
    if vo then
        local res_id = vo.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id,false,false)
        self.head:showBg(res,nil,false,vo.offy)
    end
    self.head:setLev(data.lev)

    self.rank:setString(data.rank or 0)
    self.head:setSex(data.sex,cc.p(70,4))
    self.vip_label:setNum(data.vip_lev)
    self.fight_label:setNum(changeBtValueForPower(data.power))

    self:createPartnerList(data.p_list)
end

function LadderRoleInfoWindow:createPartnerList( list )
	local temp = {}
    for k,v in pairs(list) do
        local vo = HeroVo.New()
        local hero_data = deepCopy(v)
        hero_data.use_skin = hero_data.quality
        hero_data.partner_id = v.id
        vo:updateHeroVo(hero_data)
        table.insert(temp,vo)
    end
    local p_list_size = #temp
    local total_width = p_list_size * 104 + (p_list_size - 1) * 6
    local start_x = 7
    local max_width = math.max(total_width,self.scroll_view_size.width) 
    self.scroll_view:setInnerContainerSize(cc.size(max_width,self.scroll_view_size.height))
    for i,v in ipairs(temp) do
        delayRun(self.main_panel, i / 60, function() 
            if self.item_list[i]==nil then 
                local partner_item = HeroExhibitionItem.new(0.88, true)
                partner_item:setPosition(start_x+104*0.5+(i-1)*(104+6), self.scroll_view_size.height*0.5)
                partner_item:setData(v)
                partner_item:addCallBack(function(item)
                    local vo = item:getData()
                    if vo and next(vo) ~=nil then 
                        local partner_id = vo.partner_id
                        local rid = self.data.rid
                        local srv_id = self.data.srv_id
                        LadderController:getInstance():requestCheckRoleInfo(rid, srv_id, vo.pos)
                        --LookController:getInstance():sender11061(rid,srv_id,partner_id)
                    end
                end)
                self.scroll_view:addChild(partner_item)
                self.item_list[i] = partner_item
            end
        end)
    end
end

function LadderRoleInfoWindow:openRootWnd( data )
	if data and data.rid and data.srv_id then
		controller:requestLadderEnemyData( data.rid, data.srv_id )
	end
end

function LadderRoleInfoWindow:close_callback(  )
	if self.ladder_enemy_data_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.ladder_enemy_data_event)
        self.ladder_enemy_data_event = nil
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

	controller:openLadderRoleInfoWindow(false)
end