 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛宣言
-- <br/> 2019年3月25日
-- --------------------------------------------------------------------
ElitematchDeclarationPanel = ElitematchDeclarationPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchDeclarationPanel:__init(msgType)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_declaration_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    self.msg_type = msgType or ElitematchConst.MsgType.eElitematch --默认精英段位赛

    self.default_content_msg = TI18N("无宣言")
    self.label_content_list = {}
    self.spine_list = {}
    self.content_str_list = {}


    --表情的参数
    self.form_name_list = {
        [1] = "elitematch_1",
        [2] = "elitematch_2",
        [3] = "elitematch_3",
    }
    self.form_index_list = {}
    for k,v in pairs(self.form_name_list) do
        self.form_index_list[v] = k
    end
    self.face_ui_y_list = {
        [1] = 640,
        [2] = 560,
        [3] = 480,
    }
    --标示表情数量
    self.mask_face_count = {}
end

function ElitematchDeclarationPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("宣言设置"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    local key_name = {
        [1] = TI18N("战斗前:"),
        [2] = TI18N("战斗胜利:"),
        [3] = TI18N("战斗失败:")
    }
   
    self.pos_y_list = {
        [1] =  398,
        [2] =  307,
        [3] =  210,
    }

    if self.msg_type == ElitematchConst.MsgType.eYearMonster then -- 年兽
        key_name = {
            [1] = TI18N("主动发送:"),
            [2] = TI18N("表情回应:"),
            [3] = TI18N("烟花回应:")
        }
        self.title:setString(TI18N("表情互动"))
    end

    self.face_btn_list = {}
    for i=1,3 do
        local key = self.main_container:getChildByName("key_"..i)
        key:setString(key_name[i])
        self.face_btn_list[i] = self.main_container:getChildByName("face_btn_"..i)
        self.label_content_list[i] = self:addEditContent(1, 170, self.pos_y_list[i] + 10)
    end

    local tips = self.main_container:getChildByName("tips")
    tips:setVisible(false)
    --tips:setString(TI18N("战前将从3句宣言中随机选取1句向您对手发出"))
    self.left_btn = self.main_container:getChildByName("left_btn")
    local left_str = TI18N("取 消")
    if self.msg_type == ElitematchConst.MsgType.eYearMonster then
        left_str = TI18N("发 送")
    end
    self.left_btn:getChildByName("label"):setString(left_str)
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("保 存"))
end

function ElitematchDeclarationPanel:addEditContent(index, x, y)
    local res = PathTool.getResFrame("common","common_99998")
    local label_content = createRichLabel(24, Config.ColorData.data_color4[151], cc.p(0,1), cc.p(x,y), 6, nil, 450)
    label_content:setString(self.default_content_msg)
    self.main_container:addChild(label_content)
    -- --内容输入框
    -- local edit_content = createEditBox(self.main_container, res,cc.size(450,46), nil, 24, nil, 24, "", nil, nil, LOADTEXT_TYPE_PLIST)
    -- edit_content:setAnchorPoint(cc.p(0,1))
    -- edit_content:setPlaceholderFontColor(Config.ColorData.data_color4[63])
    -- edit_content:setFontColor(Config.ColorData.data_color4[66])
    -- edit_content:setPosition(cc.p(x - 2, y - 3))

    -- local begin_change_label = false
    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     if strEventName == "return" or strEventName == "ended" then
    --         if begin_change_label then  
    --             begin_change_label = false
    --             label_content:setVisible(true)
    --             local str = pSender:getText()
    --             pSender:setText("")  
    --             if str ~= "" and str ~= self.content_str_list[index] then
    --                 if StringUtil.SubStringGetTotalIndex(str) > 15 then
    --                     str = StringUtil.SubStringUTF8(str, 1, 15)
    --                 end
    --                 self.content_str_list[index] = str
    --                 local label = string_format("<div fontcolor=#643223>%s</div>", str)
    --                 label_content:setString(label)
    --             else
    --                 label_content:setString(self.default_content_msg)
    --             end 

    --         end
    --     elseif strEventName == "began" then
    --         if not begin_change_label then
    --             label_content:setVisible(false)
    --             begin_change_label = true
    --         end
    --     elseif strEventName == "changed" then

    --     end
    -- end
    -- edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
    return label_content
end

function ElitematchDeclarationPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    for i,btn in ipairs(self.face_btn_list) do
        registerButtonEventListener(btn, function() self:onShowFaceIndex(i, btn) end ,true, 1)
    end

    self:addGlobalEvent(ElitematchEvent.Elite_Declaration_Event, function(data)
        if not data then return end
        self:setData(data)
    end)

    self:addGlobalEvent(ActionyearmonsterEvent.Year_Face_Event, function(data)
        if not data then return end
        self:setData(data)
    end)
    
    self:addGlobalEvent(ElitematchEvent.Elite_Declaration_Face_Event, function(index, config)
        if not index then return end
        if not config then return end
        self.content_str_list[index] = config.id
        self:setLabelContent(index, config)
    end)

    -- self:addGlobalEvent(EventId.CHAT_SELECT_FACE, function(face_name, from_name)
    --     local index = self.form_index_list[from_name]
    --     if index then
    --         if self.mask_face_count[index] == nil or self.mask_face_count[index] == 0 then
    --             self.mask_face_count[index] = 0
    --             self.content_str_list[index] = ""             
    --         end
    --         if self.mask_face_count[index] >= 5 then
    --             message(TI18N("不能超过5个表情"))
    --             return     
    --         end
    --         self.mask_face_count[index] = self.mask_face_count[index] + 1
    --         self.content_str_list[index] = self.content_str_list[index]..face_name
    --         self:setLabelContent(index, self.content_str_list[index])
    --     end
        
    -- end)
end

--提交
function ElitematchDeclarationPanel:onClickBtnRight()
    local manifesto = {}
    if self.msg_type == ElitematchConst.MsgType.eYearMonster then --年兽
        for i,v in pairs(self.content_str_list) do
            table_insert(manifesto, {order = i, face_id = v})
        end
        ActionyearmonsterController:getInstance():sender28219(manifesto)
    else
        for i,v in pairs(self.content_str_list) do
            table_insert(manifesto, {order = i, manifesto_id = v})
        end
        controller:sender24946(manifesto)
    end
   
    self:onClickBtnClose()
end

function ElitematchDeclarationPanel:onShowFaceIndex(index, btn)
    if not index then return end
    local world_pos = btn:convertToWorldSpace(cc.p(0.5, 0))
    local id = self.content_str_list[index] or 0
    controller:openChooseFacePanel(true, index, id, world_pos, self.msg_type)
    -- self.mask_face_count[index] = 0
    -- RefController:getInstance():openView(self.form_name_list[index], self.face_ui_y_list[index], ChatConst.Channel.Province)
end

--关闭
function ElitematchDeclarationPanel:onClickBtnLeft()
    if self.content_str_list and self.content_str_list[1] then
       GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Send_Face_Event, self.content_str_list[1])
    end
    
    self:onClickBtnClose()
end

--关闭
function ElitematchDeclarationPanel:onClickBtnClose()
    controller:openElitematchDeclarationPanel(false)
end

--@rid id
--@svr_id 服务器id
--@_type
function ElitematchDeclarationPanel:openRootWnd()
    if self.msg_type == ElitematchConst.MsgType.eYearMonster then
        ActionyearmonsterController:getInstance():sender28220()
    else
        controller:sender24945()
    end
end

function ElitematchDeclarationPanel:setData(data)
    if self.msg_type == ElitematchConst.MsgType.eYearMonster then
        
        
        if data.face and #data.face<=0 then
            local temp_config = Config.HolidayNianData.data_const.holiday_nian_default_face
            if temp_config then
                for i,v in ipairs(temp_config.val) do
                    if self.label_content_list[v[1]] then
                        self.content_str_list[v[1]] = v[2]
                        if v[2] ~= 0 then
                            local config = Config.ArenaEliteData.data_face[v[2]]
                            self:setLabelContent(v[1], config)
                        end
                    end
                end
            end            
        else
            for i,v in ipairs(data.face) do
                if self.label_content_list[v.order] then
                    self.content_str_list[v.order] = v.face_id
                    if v.face_id ~= 0 then
                        local config = Config.ArenaEliteData.data_face[v.face_id]
                        self:setLabelContent(v.order, config)
                    end
                end
            end
        end
    else
        for i,v in ipairs(data.manifesto) do
            if self.label_content_list[v.order] then
                self.content_str_list[v.order] = v.manifesto_id
                if v.manifesto_id ~= 0 then
                    local config = Config.ArenaEliteData.data_face[v.manifesto_id]
                    self:setLabelContent(v.order, config)
                end
            end
       end
    end
    
end

function ElitematchDeclarationPanel:setLabelContent(index, config)
    if not config then return end
    local label
    if self.msg_type == ElitematchConst.MsgType.eYearMonster then
        local text = config.text or TI18N("恭喜发财")
        label = string_format("<div fontcolor=#643223>[%s]</div>", text)
    else
        label = string_format("<div fontcolor=#643223>[%s]</div>", config.name)
    end
    self.label_content_list[index]:setString(label)
    self.label_content_list[index]:setPositionX(230 + 25)
    self:showSpine(true, index, config)
end
    
--config :Config.ArenaEliteData.data_face
function ElitematchDeclarationPanel:showSpine(status, index, config)
    if not index then return end

    if status == false then
        if self.spine_list[index] then
            self.spine_list[index]:clearTracks()
            self.spine_list[index]:removeFromParent()
            self.spine_list[index] = nil
        end
    else
        if not config then return end
        if not self.pos_y_list[index] then return end
        self:showSpine(false, index)
        self.spine_list[index] = createEffectSpine(config.msg, cc.p(190 + 25, self.pos_y_list[index]), cc.p(0.5, 0.5), false, PlayerAction.action)
        self.spine_list[index]:setScale(0.6)
        self.main_container:addChild(self.spine_list[index], 1)
    end
end


function ElitematchDeclarationPanel:close_callback()
    controller:openElitematchDeclarationPanel(false)
end