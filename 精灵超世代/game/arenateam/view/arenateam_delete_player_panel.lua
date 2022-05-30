-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      创建队伍界面
-- <br/> 2019年10月8日
-- --------------------------------------------------------------------
ArenateamDeletePlayerPanel = ArenateamDeletePlayerPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamDeletePlayerPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_delete_player_panel"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }
end

function ArenateamDeletePlayerPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("踢除队员"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.main_container:getChildByName("tips"):setString(TI18N("您将踢除该成员:"))
   
    local team_item = self.main_container:getChildByName("team_item")
    local size = team_item:getContentSize()
    self.player_name = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(132,177),nil,nil,800)
    team_item:addChild(self.player_name)
    self.power =  team_item:getChildByName("power")
    --头像
    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setHeadLayerScale(0.8)
    self.head:setPosition(56 , 160)
    self.head:setLev(99)
    team_item:addChild(self.head)

    --宝可梦
    self.hero_item_list = {}
    local item_width = HeroExhibitionItem.Width * 0.8 + 10
    local x = size.width * 0.5 -item_width * 5 * 0.5 + item_width * 0.5
    local y = 58
    for j=1,5 do
        self.hero_item_list[j] = HeroExhibitionItem.new(0.8, true)
        self.hero_item_list[j]:setSwallowTouches(false)
        self.hero_item_list[j]:setPosition(x + (j - 1) * item_width, y)
        self.hero_item_list[j]:addCallBack(function() self:onClickHeroItemByIndex(j) end)
        -- self.hero_item_list[i]:setBgOpacity(128)
        team_item:addChild(self.hero_item_list[j])
    end

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
end

function ArenateamDeletePlayerPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    -- self:addGlobalEvent(ElitematchEvent.Elite_Declaration_Event, function(data)
    --     if not data then return end
    --     self:setData(data)
    -- end)
end

--点击宝可梦
function ArenateamDeletePlayerPanel:onClickHeroItemByIndex(i)
    if not self.member_data then return end
    -- LookController:getInstance():sender11061(self.member_data.rid, self.member_data.sid, self.member_data.id)
end

--提交
function ArenateamDeletePlayerPanel:onClickBtnRight()
    if not self.member_data then return end
    controller:sender27212(self.member_data.rid, self.member_data.sid)
end
--关闭
function ArenateamDeletePlayerPanel:onClickBtnClose()
    controller:openArenateamDeletePlayerPanel(false)
end

function ArenateamDeletePlayerPanel:openRootWnd(setting)
    local setting = setting or {}
    self.member_data = setting.member_data 
    if not self.member_data then return end
    self.player_name:setString(self.member_data.name)
    self.power:setString(self.member_data.power)
    --宝可梦
    self.head:setHeadRes(self.member_data.face_id, false, LOADTEXT_TYPE, self.member_data.face_file, self.member_data.face_update_time)
    self.head:setLev(self.member_data.lev)
    local avatar_bid = self.member_data.avatar_bid
    if self.record_res_bid == nil or self.record_res_bid ~= avatar_bid then
        self.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.head:showBg(res, nil, false, vo.offy)
        end
    end

    table_sort(self.member_data.team_partner, function(a, b) return a.pos < b.pos end)
    for i,hero_item in ipairs(self.hero_item_list) do
        local hero_vo = self.member_data.team_partner[i]
        hero_item:setData(hero_vo)
    end
end

function ArenateamDeletePlayerPanel:close_callback()
    controller:openArenateamDeletePlayerPanel(false)
end