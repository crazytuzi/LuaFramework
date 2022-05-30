--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 开奖界面
-- @DateTime:    2019-05-17 16:10:07
-- ******************************
TreasureOpenAwardWindow = TreasureOpenAwardWindow or BaseClass(BaseView)

local controll = FestivalActionController:getInstance()
local join_goods_list = Config.HolidaySnatchData.data_join_goods_list
local string_format = string.format
function TreasureOpenAwardWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "festivalaction/treasure_open_award_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","txt_cn_festival_treasure_open"), type = ResourcesType.single},
    }
end

function TreasureOpenAwardWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")

    self:playEnterAnimatianByObj(self.main_container, 2)
    local bg = self.main_container:getChildByName("bg")
    local res = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","txt_cn_festival_treasure_open")
    self.open_award_bg = loadSpriteTextureFromCDN(bg, res, ResourcesType.single, self.open_award_bg)

    self.btn_close = self.main_container:getChildByName("btn_close")
   	self.main_container:getChildByName("Text_1"):setString(TI18N("幸运号码："))
    self.main_container:getChildByName("Text_1_0"):setString(TI18N("恭喜获得："))
    self.get_award_text = self.main_container:getChildByName("get_award_text")
    self.get_award_text:setString("")
    self.main_container:getChildByName("Text_1_0_1"):setString(TI18N("我的号码："))
    self.main_container:getChildByName("Text_1_0_1_0"):setString(TI18N("我的参与人次："))
    self.no_join_text = self.main_container:getChildByName("no_join_text")
    self.no_join_text:setVisible(false)
    self.role_name = self.main_container:getChildByName("role_name")
    self.role_name:setString("")
    self.server_name = self.main_container:getChildByName("server_name")
    self.server_name:setString("")

    local num_scroll = self.main_container:getChildByName("num_scroll")
    local view_size = num_scroll:getContentSize()
    local setting = {
        item_class = OpenLotteryNumberItem,
        start_x = 0,
        space_x = -15,
        start_y = 0,
        space_y = 0,
        item_width = 100,
        item_height = 30,
        row = 1,
        col = 5,
        need_dynamic = true
    }
    self.my_number_scroll = CommonScrollViewLayout.new(num_scroll, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, view_size, setting)
    self.my_number_scroll:setSwallowTouches(false)

    self.goods_item = BackPackItem.new(nil,true,nil,0.7,false)
    self.main_container:addChild(self.goods_item)
    self.goods_item:setPosition(cc.p(389, 257))

    self.play_head = PlayerHead.new(PlayerHead.type.circle)
	self.main_container:addChild(self.play_head)
	self.play_head:setPosition(cc.p(127,349))
	self.play_head:setAnchorPoint(cc.p(0.5,0.5))
	self.play_head:setTouchEnabled(true)

    self.open_num = CommonNum.new(17, self.main_container, "", 10, cc.p(0, 0))
    self.open_num:setPosition(350, 375)
    self.my_join_num = createRichLabel(24, FestivalActionConst.ColorConst[5], cc.p(0, 0.5), cc.p(500, 150), nil, nil, 100)
	self.main_container:addChild(self.my_join_num)
end
function TreasureOpenAwardWindow:openRootWnd(data)
	local pos = data.pos or 0
	controll:sender25702(pos)
end
function TreasureOpenAwardWindow:register_event()
	self:addGlobalEvent(FestivalActionEvent.Treasure_OpenStatus_Event, function(data)
		if data.win_num ~= 0 then
            self.data = data
			self:setData(data)
		end
	end)

    registerButtonEventListener(self.play_head, function(param,sender,event_type)
        if self.data then
            local roleVo = RoleController:getInstance():getRoleVo()
            local touchPos = cc.p(sender:getTouchEndPosition().x+320,sender:getTouchEndPosition().y)
            local rid = self.data.rid
            local srv_id = self.data.srv_id
            if roleVo.rid== rid and roleVo.srv_id == srv_id then return end
            local vo = {rid = rid, srv_id = srv_id}
            ChatController:getInstance():openFriendInfo(vo,touchPos)
        end
    end,true, 1)

	registerButtonEventListener(self.background, function()
		controll:openTreasureOpenAwardView(false)
	end,false, 2)
	registerButtonEventListener(self.btn_close, function()
		controll:openTreasureOpenAwardView(false)
	end,true, 2)
end

function TreasureOpenAwardWindow:setData(data)
	self.open_num:setNum(data.win_num)
	self.play_head:setHeadRes(data.win_face)
	self.play_head:setLev(data.win_lev)
	self.role_name:setString(data.win_name)
	self.server_name:setString(getServerName(data.srv_id))

	if join_goods_list and join_goods_list[data.id] then
		self.get_award_text:setString(join_goods_list[data.id].name)
		if self.goods_item then
			self.goods_item:setBaseData(join_goods_list[data.id].award[1][1], join_goods_list[data.id].award[1][2])
		end
	end

	local str = string_format(TI18N("<div fontcolor=b7ff46>%d</div>次"),#data.buy_nums)
	self.my_join_num:setString(str)
    self.my_number_scroll:setData(data.buy_nums,nil,nil,data.win_num)
end

function TreasureOpenAwardWindow:close_callback()
	doStopAllActions(self.main_container)
	if self.open_award_bg then
        self.open_award_bg:DeleteMe()
        self.open_award_bg = nil
    end
    if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end
    if self.play_head then 
		self.play_head:DeleteMe()
		self.play_head = nil
	end
	if self.open_num then
        self.open_num:DeleteMe()
        self.open_num = nil
    end
    if self.my_number_scroll then
        self.my_number_scroll:DeleteMe()
        self.my_number_scroll = nil
    end
	controll:openTreasureOpenAwardView(false)
end

--******************************
--我的号码子项
OpenLotteryNumberItem = class("OpenLotteryNumberItem", function()
    return ccui.Widget:create()
end)

function OpenLotteryNumberItem:ctor()
    self:configNumberUI()
end

function OpenLotteryNumberItem:configNumberUI()
    self:setContentSize(cc.size(100, 30))
end
function OpenLotteryNumberItem:setExtendData(win_num)
    self.open_win_num = win_num
end
function OpenLotteryNumberItem:setData(data)
    if not data then return end
    if not self.luckly_num then
        self.luckly_num = createLabel(22,FestivalActionConst.ColorConst[5],nil,0,15,"",self,nil, cc.p(0,0.5))
    end
    if self.open_win_num == data.num then
        self.luckly_num:setTextColor(FestivalActionConst.ColorConst[6])
    else
        self.luckly_num:setTextColor(FestivalActionConst.ColorConst[5])
    end
    self.luckly_num:setString(data.num)
end
function OpenLotteryNumberItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end