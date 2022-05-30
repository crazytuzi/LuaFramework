-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      神器选择界面
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
FormHallowsSelectPanel = FormHallowsSelectPanel or BaseClass(BaseView)

local hallowsController = HallowsController:getInstance()
local heroController = HeroController:getInstance()
local model = hallowsController:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function FormHallowsSelectPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/form_hallows_select_panel"

    self.res_list = {
    }
end

function FormHallowsSelectPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("神器更换"))
end

function FormHallowsSelectPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
end

--关闭
function FormHallowsSelectPanel:onClickBtnClose()
    heroController:openFormHallowsSelectPanel(false)
end

--@ dic_equips 已装备列表
--@ dic_equips[神器id] = 队伍编号
--@ team_index = 队伍索引
--@ mine_hallows_id 矿脉专用的...如果还有.请改成setting模式
function FormHallowsSelectPanel:openRootWnd(hallows_equip_id, callback, dic_equips, team_index, mine_hallows_id)
    if not team_index then return end
    self.dic_equips = dic_equips or {}
    self.team_index = team_index 
    self.callback = callback
    self.hallows_equip_id = hallows_equip_id
    if mine_hallows_id then
        self.mine_hallows_id = mine_hallows_id
    end

    local config_list = Config.HallowsData.data_base
    if not config_list then return end
    self.hallows_list = {}
    for i,config in ipairs(config_list) do
        local data = {}
        data.hallows_vo = model:getHallowsById(config.id)
        data.config = config
        if config.id == self.hallows_equip_id then
            data.is_equip = true
        else
            data.is_equip = false
        end
        if dic_equips[config.id] then
            data.team_index = dic_equips[config.id]
            data.team_text = string_format(TI18N("队伍%s装备中"), dic_equips[config.id])
        end

        if self.mine_hallows_id and self.mine_hallows_id[config.id] then
            data.mine_text = TI18N("其他队伍装备中")
        end
        self.hallows_list[i] = data
    end

    if #self.hallows_list > 0 then
        self:updateHallowList()
    else
        local x = self.main_container:getContentSize().width * 0.5
        self.emptyTips = createImage(self.main_container,PathTool.getEmptyMark(),x,505,cc.p(0.5,0.5))
        createLabel(22,Config.ColorData.data_color4[187],nil,self.emptyTips:getContentSize().width/2+10,-20,TI18N("暂时没有数据"),self.emptyTips,0, cc.p(0.5,0))
    end
end


--创建神器列表 
function FormHallowsSelectPanel:updateHallowList()
    if not self.list_view then
        local scroll_view_size = cc.size(646,880)
        local setting = {
            item_class = FormHallowsSelectItem,      -- 单元类
            start_x = (646-602)/2,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 602,               -- 单元的尺寸width
            item_height = 126,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            -- need_dynamic = true
        }
        local mainSize = self.main_container:getContentSize()

        self.list_view = CommonScrollViewLayout.new(self.main_container, cc.p(mainSize.width/2, mainSize.height/2 - 30) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))
    end


    self.list_view:setData(self.hallows_list, function(item, data) self:selectItem(item ,data) end )
end

--@ data 是 self.hallows_list[i]
function FormHallowsSelectPanel:selectItem(item, data)
    if not item then return end
    if not data then return end
    if not data.config then return end

        
    local _setHallow = function()
        if data.is_equip == true then
            self.hallows_equip_id = 0
        else
            self.hallows_equip_id = data.config.id
        end
        self:onClickBtnClose()
        if self.callback then
            self.callback(self.hallows_equip_id, self.team_index)
        end
    end
    if data.team_index ~= nil and data.team_index ~= 0 and not data.is_equip then
        local str = string_format(TI18N("其他队伍中已装配了该神器，若要在此队伍中装配，则系统会自动卸下其他队伍中的该神器，是否确定？"))
        CommonAlert.show( str, TI18N("确定"), function()
            _setHallow()
        end, TI18N("取消"),nil,nil,nil,{title = TI18N("提示")})
    else
        _setHallow()
    end
end


function FormHallowsSelectPanel:close_callback()

    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    heroController:openFormHallowsSelectPanel(false)
end

-------------------------------------------------------------------------------------------------------
--item 类
FormHallowsSelectItem = class("FormHallowsSelectItem", function()
    return ccui.Widget:create()
end)

function FormHallowsSelectItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvent()
end

function FormHallowsSelectItem:config()
   
end

function FormHallowsSelectItem:layoutUI()
    self.size = cc.size(602, 116)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    -- self:setTouchEnabled(true)
    -- self:setCascadeOpacityEnabled(true)
    local csbPath = PathTool.getTargetCSB("hero/form_hallows_select_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_container = self.root_wnd:getChildByName("main_container")

    self.item_icon = BackPackItem.new(false, false)
    self.item_icon:setPosition(cc.p(68, self.size.height/2))
    self.item_icon:setScale(0.8)
    self.main_container:addChild(self.item_icon)

    self.name_label =  createLabel(20, Config.ColorData.data_color4[1], nil, 124, self.size.height - 24, "", self.main_container, 2, cc.p(0,0.5))

    local word_width = 314
    self.dec_label = createRichLabel(18, cc.c3b(0x37,0x64,0x75), cc.p(0,1), cc.p(124,self.size.height - 51), 5, 0, word_width)
    self.main_container:addChild(self.dec_label)

    self.look_btn = self.main_container:getChildByName("look_btn")
    self.comfirm_btn_node = self.main_container:getChildByName("Node_comfirm_btn")
    self.comfirm_btn = self.comfirm_btn_node:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setColor(cc.c3b(0xff,0xff,0xff))
end


function FormHallowsSelectItem:registerEvent()
    registerButtonEventListener(self.look_btn, handler(self, self.onClickLookBtn) ,true, 2)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
    -- if self.can_click == true then
    --     self:addTouchEventListener(function(sender, event_type) 
    --         customClickAction(self, event_type, self.scale)
    --         if event_type == ccui.TouchEventType.ended and self.can_click == true then
    --             playButtonSound2()
    --             self:clickFun()
    --         end
    --     end)
    -- end

    -- -- 退出的时候移除一下吧.要不然可能有些人不会手动移除,就会报错
    -- self:registerScriptHandler(function(event)
    --     if "enter" == event then
    --     elseif "exit" == event then     
    --        self:unBindEvent()
    --     end 
    -- end)
end

function FormHallowsSelectItem:addCallBack(callback)
    self.callback = callback
end

function FormHallowsSelectItem:onClickLookBtn()
    if not self.hallows_id then return end
    -- body
    HallowsController:getInstance():openHallowsTips(true, self.hallows_id)
end
function FormHallowsSelectItem:onClickComfirmBtn()
    if not self.data then return end
    if self.data.hallows_vo == nil then
        message(TI18N("该神器未开启"))
        return
    end
    if self.callback then
        self.callback(self, self.data)
    end
end

function FormHallowsSelectItem:setData(data)
    if not data then return end
    self.data = data
    local config = data.config 
    if not config then return end
    --记录圣器id
    self.hallows_id = config.id 

    local item_config = Config.ItemData.data_get_data(config.item_id)
    if data.hallows_vo and data.hallows_vo.look_id ~= 0 then -- 神器被幻化了
        local magic_cfg = Config.HallowsData.data_magic[data.hallows_vo.look_id]
        if magic_cfg then
            self.item_icon:setBaseData(magic_cfg.item_id)
            self.item_icon:setMagicIcon(true)
        else
            self.item_icon:setBaseData(config.item_id)
            self.item_icon:setMagicIcon(false)
        end
    else
        self.item_icon:setBaseData(config.item_id)
        self.item_icon:setMagicIcon(false)
    end

    --名字
    local lev 
    local key
    local name_str = ""
    if data.hallows_vo ~= nil then
        key = getNorKey(config.id, data.hallows_vo.skill_lev)
        lev = data.hallows_vo.step
        if HallowsController:getInstance():getModel():getHallowsRefineIsOpen() then
            name_str = string_format(TI18N("%s (%s级)【精炼+%d级】"), config.name, lev, data.hallows_vo.refine_lev)
        else
            name_str = string_format(TI18N("%s (%s级)"), config.name, lev)
        end
        -- self.look_btn:setPositionX(495)
    else
        lev = 1
        key = getNorKey(config.id, 1)
        name_str = string_format("%s (%s%s)", config.name, lev, TI18N("级"))
        -- self.look_btn:setPositionX(380)
    end
    self.name_label:setString(name_str)
    if BackPackConst.quality_color[item_config.quality] then
        self.name_label:setColor(BackPackConst.quality_color[item_config.quality])
    end
    self.look_btn:setPositionX(self.name_label:getPositionX() + self.name_label:getContentSize().width + 20)

    --神器的详细信息
    local skill_up_config = Config.HallowsData.data_skill_up(key)
    local skill_config = Config.SkillData.data_get_skill(skill_up_config.skill_bid)
    if skill_config then
        local skill_atk_val = skill_config.hallows_atk or 0
        local refine_atk_val = 0
        if data.hallows_vo then
            skill_atk_val, refine_atk_val = data.hallows_vo:getHallowsSkillAndRefineAtkVal()
        end
        local total_atk_val = skill_atk_val + refine_atk_val
        local str = string_format(skill_config.des, total_atk_val, refine_atk_val)
        if StringUtil.SubStringGetTotalIndex(str) > 33 then
            str = StringUtil.SubStringUTF8(str, 1, 33)
            str = str.."..."
        end
        self.dec_label:setString(str)
    else
        self.dec_label:setString(TI18N("该神器没有技能"))
    end

    --按钮情况
    if data.hallows_vo == nil then
        self.item_icon:setItemIconUnEnabled(true)
        local res = PathTool.getResFrame("common","common_90009")
        local x, y = self.item_icon:getPosition()
        self.lock_icon = createImage(self.main_container,res,x, y,cc.p(0.5,0.5),true,0,false)
        if self. non_label == nil then
            local x, y = self.comfirm_btn_node:getPosition()
            self.non_label =  createLabel(24, Config.ColorData.data_color4[206], nil, x, y, TI18N("未开启"), self.main_container, 2, cc.p(0.5,0.5))
        else
            self.non_label:setVisible(true)
        end
        self.comfirm_btn:setVisible(false)
        self.look_btn:setVisible(false)
    else
        self.item_icon:setItemIconUnEnabled(false)
        self:setBtnStatus(data.is_equip)
        self.look_btn:setVisible(true)
        if data.team_index ~= nil then
            --有别的队伍装备中
            local text =  data.team_text or ""
            if self.team_dec == nil then
                self.team_dec = createLabel(20, Config.ColorData.data_color4[206], nil, 580, 20, text, self.main_container, 2, cc.p(1,0.5))
            else
                self.team_dec:setString(text)
            end
        else
            if self.team_dec then
                self.team_dec:setString("")
            end
        end

        if data.mine_text ~= nil then
            --矿脉的 说明被被人占领中
             if self.team_mine_dec == nil then
                self.team_mine_dec = createLabel(20, Config.ColorData.data_color4[206], nil, 580, 20, data.mine_text, self.main_container, 2, cc.p(1,0.5))
            else
                self.team_mine_dec:setString(data.mine_text)
            end
            setChildUnEnabled(true, self.comfirm_btn)
            self.comfirm_label:setColor(cc.c3b(0xff,0xff,0xff))
            self.comfirm_btn:setTouchEnabled(false)
        else
            if self.team_mine_dec then
                self.team_mine_dec:setString("")
            end
        end
    end
end

--是否装备
function FormHallowsSelectItem:setBtnStatus(is_equip)
    if is_equip  then
        local btn_res_id = PathTool.getResFrame("common", "common_1017")
        self.comfirm_btn:loadTexture(btn_res_id, LOADTEXT_TYPE_PLIST)
        self.comfirm_label:setString(TI18N("取消配置"))
        self.comfirm_label:enableOutline(Config.ColorData.data_color4[263], 2)
    else
        local btn_res_id = PathTool.getResFrame("common", "common_1018")
        self.comfirm_btn:loadTexture(btn_res_id, LOADTEXT_TYPE_PLIST)
        self.comfirm_label:setString(TI18N("装 配"))
        self.comfirm_label:enableOutline(Config.ColorData.data_color4[264], 2) 
    end
end



function FormHallowsSelectItem:DeleteMe()
    if self.item_icon then
        self.item_icon:DeleteMe()
        self.item_icon = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end