 

-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      分享按钮
-- <br/>Create: 2019年3月22日
-- --------------------------------------------------------------------
ChooseFacePanel = ChooseFacePanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()

function ChooseFacePanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "elitematch/choose_face_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function ChooseFacePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        -- self.background:setSwallowTouches(false)
    end
    self.share_panel = self.root_wnd:getChildByName("share_panel")

    self.share_bg = self.share_panel:getChildByName("share_bg")

    local face_list = self.share_bg:getChildByName("face_list")
    local scroll_view_size = face_list:getContentSize()
    local setting = {
        item_class = ChooseFaceItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 235,               -- 单元的尺寸width
        item_height = 121,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.face_scrollview = CommonScrollViewLayout.new(face_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.face_scrollview:setSwallowTouches(false)
end

function ChooseFacePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
end

--关闭
function ChooseFacePanel:onClickCloseBtn()
    controller:openChooseFacePanel(false)
end

--设置选择框
function ChooseFacePanel:setSelectCheckBox()
    if not self.face_scrollview then return end
    local item_list = self.face_scrollview:getItemList()
    for k,item in pairs(item_list) do
        item:setCurFaceId(self.select_checkbox)
        if item:getFaceIndex() == self.select_checkbox then
            item:setSelectStatus(true)
        else
            item:setSelectStatus(false)
        end
    end
end

function ChooseFacePanel:_onClickFaceItem( id )
    self.select_checkbox = id
    local config_list = Config.ArenaEliteData.data_face
    if config_list[id] then
        GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Declaration_Face_Event, self.index, config_list[id])
    end
    self:setSelectCheckBox()
end


function ChooseFacePanel:openRootWnd(index, id, world_pos, msg_type)
    if not index then return end
    if not id then return end
    if not world_pos then return end


    self.index = index
    self.select_checkbox = id
    local config_list = Config.ArenaEliteData.data_face
    local msg_type = msg_type

    self.face_scrollview:setData(config_list, handler(self, self._onClickFaceItem), nil, {msg_type = msg_type})
    self.face_scrollview:addEndCallBack(function (  )
        self:setSelectCheckBox()
    end)

    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        self.share_bg:setPosition(cc.p(node_pos.x - 191, node_pos.y))
    end
end

function ChooseFacePanel:close_callback()
    if self.spine_list then
        for i,v in ipairs(self.spine_list) do
            v:clearTracks()
            v:removeFromParent()
        end
    end
    if self.face_scrollview then
        self.face_scrollview:DeleteMe()
        self.face_scrollview = nil
    end
    self.spine_list = nil
    controller:openChooseFacePanel(false)
end

----------------------@ item
ChooseFaceItem = class("ChooseFaceItem", function()
    return ccui.Widget:create()
end)

function ChooseFaceItem:ctor()
    self:configUI()
    self:register_event()
end

function ChooseFaceItem:configUI(  )
    self.size = cc.size(235, 121)
    self:setTouchEnabled(false)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("elitematch/choose_face_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.checkbox = self.container:getChildByName("checkbox")
    self.checkbox:setSelected(false)
    self.checkbox:setPositionX(170)
    self.name = self.checkbox:getChildByName("name")
end

function ChooseFaceItem:setExtendData(data)
    self.msg_type = data.msg_type
end

function ChooseFaceItem:register_event(  )
    self.checkbox:addEventListener(function ( sender,event_type )
        playButtonSound2()
        if self.call_back and self.data then
            self.call_back(self.data.id)
        end
    end)
end

function ChooseFaceItem:addCallBack( call_back )
    self.call_back = call_back
end

function ChooseFaceItem:getFaceIndex(  )
    if self.data then
        return self.data.id
    end
end

function ChooseFaceItem:setSelectStatus( status )
    if self.checkbox then
        self.checkbox:setSelected(status)
    end
end

function ChooseFaceItem:setCurFaceId( id )
    self.cur_face_id = id
end

function ChooseFaceItem:setData( data )
    if not data then return end

    self.data = data

    if self.msg_type == ElitematchConst.MsgType.eYearMonster then
        local text = data.text or TI18N("恭喜发财")
        self.name:setString(text)
    else
        self.name:setString(data.name)
    end

    if self.cur_face_id == data.id then
        self.checkbox:setSelected(true)
    else
        self.checkbox:setSelected(false)
    end

    if self.face_spine then
        self.face_spine:clearTracks()
        self.face_spine:removeFromParent()
        self.face_spine = nil
    end
    self.face_spine = createEffectSpine(data.msg, cc.p(75, self.size.height/2), cc.p(0.5, 0.5), false, PlayerAction.action)
    self.container:addChild(self.face_spine)
end

function ChooseFaceItem:DeleteMe(  )
    if self.face_spine then
        self.face_spine:clearTracks()
        self.face_spine:removeFromParent()
        self.face_spine = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end