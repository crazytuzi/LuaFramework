-- 聊天引用表情
-- author:cloud
-- date:2017.1.13


RefFacesUI = RefFacesUI or BaseClass()

function RefFacesUI:__init(parent)
    self.parent = parent
    self:createRootWnd()
end

function RefFacesUI:createRootWnd()
    self.size = self.parent:getContentSize()

	local setting = {
        item_class = RefFacesUIItem,      -- 单元类
        start_x = 18,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 2,                    -- 第一个单元的Y起点
        space_y = 15,                   -- y方向的间隔
        item_width = 66,               -- 单元的尺寸width
        item_height = 66,              -- 单元的尺寸height
        row = 5,                        -- 行数，作用于水平滚动类型
        col = 6,                         -- 列数，作用于垂直滚动类型
        once_num = 5,
        need_dynamic = true
	}
    self.scroll_view = CommonScrollViewLayout.new(self.parent, cc.p(8,8), nil, nil, cc.size(self.size.width-16, self.size.height-16), setting)

    self.face_count = 0
    -- 设置数据
    self:setData()

    
    if not self.face_count_evt then
        self.face_count_evt = GlobalEvent:getInstance():Bind(ChatEvent.FACE_COUNT_EVENT, function(face_count)
           self.face_count = face_count or 0
        end)
    end
end

function RefFacesUI:setVisible(bool)
    if not tolua.isnull(self.scroll_view) then
        self.scroll_view:setVisible(bool)
    end
end

function RefFacesUI:setData()
    local config = Config.FaceData.data_biaoqing 
    local function call_back(spine_id)
        self:onFaceTouched(spine_id)
    end

    self.scroll_view:setData(config, call_back)
end 

function RefFacesUI:onFaceTouched(face_name)
    local from_name = RefController:getInstance():getFrom()
    local face_num = 0
    if from_name == ChatConst.ChatInputType.eMessageBoardpanel or  -- 留言板
        from_name == ChatConst.ChatInputType.eArenateam or  -- 组队竞技场聊天
        from_name == ChatConst.ChatInputType.eMessageBoardReplyPanel then --留言板弹窗的
        
        face_num = self.face_count or 0
    else
        face_num = ChatController:getInstance():getTextInputFace()
    end
    if face_num >= 5 then
        message(TI18N("发言中不能超过5个表情"))
    else
        GlobalEvent:getInstance():Fire(EventId.CHAT_SELECT_FACE, face_name, from_name)
    end
end

function RefFacesUI:__delete()
    if self.face_count_evt then
        GlobalEvent:getInstance():UnBind(self.face_count_evt)
        self.face_count_evt = nil
    end

    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      表情单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
RefFacesUIItem = class("RefFacesUIItem", function()
	return ccui.Layout:create()
end)

function RefFacesUIItem:ctor()
    self.effect_spine_name = ""

    self.size = cc.size(66,66)
    self:setContentSize(self.size)
    self:setAnchorPoint(0.5,0.5)
    self:setTouchEnabled(true)

    --self.face_bg = createSprite(PathTool.getResFrame("mainui", "mainui_chat_face_bg"), 23, 23, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

    self:registerEvent()
end

function RefFacesUIItem:registerEvent()
    self:addTouchEventListener(function(sender, event)
        if ccui.TouchEventType.ended == event then
            playButtonSound2()
            if self.call_back and self.effect_spine_name ~= "" then
                self.call_back(self.effect_spine_name)
            end
        end
    end)
end

function RefFacesUIItem:setData(data)
    self.data = data
    if data then
        if self.effect_name ~= data.name then
            self.effect_name = data.name
            --self:clearEffectSpine()
            if self.face_image then
                self.face_image:removeFromParent()

            end
            --self.effect_spine = createSpineByName(data.name)
            --self.effect_spine:setAnchorPoint(cc.p(0.5, 0.5))
            --self.effect_spine:setAnimation(0, PlayerAction.action, true)
            --self.effect_spine:setPosition(23,23)
            --self:addChild(self.effect_spine)
            local res = PathTool.getFaceIconRes(data.name)
            self.face_image = createSprite(res,self.size.width/2,self.size.height/2,self,cc.p(0.5,0.5),LOADTEXT_TYPE)

            self.effect_spine_name = "#"..data.id
        end
    end
end

function RefFacesUIItem:clearEffectSpine()
    if self.effect_spine then
        self.effect_spine:removeFromParent()
        self.effect_spine = nil

        self.effect_spine_name = ""
    end
end

function RefFacesUIItem:clearTimeTicket()
end

function RefFacesUIItem:addCallBack(call_back)
    self.call_back = call_back
end

function RefFacesUIItem:suspendAllActions()
end

function RefFacesUIItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 