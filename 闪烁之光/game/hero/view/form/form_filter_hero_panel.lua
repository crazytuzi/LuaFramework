-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄过滤窗口
-- <br/> 2018年12月8日
-- --------------------------------------------------------------------
FormFilterHeroPanel = FormFilterHeroPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()

function FormFilterHeroPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/form_filter_hero_panel"

    self.res_list = {
        -- { path = self.empty_res, type = ResourcesType.single }
    }

    --过滤数据
    self.dic_filter_camp_type = {}
    self.dic_filter_career_type = {}
end

function FormFilterHeroPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    --阵营
    self.checkbox_camp_list = {}
    for k,v in pairs(HeroConst.CampType) do
        if v ~= 0 then
            self.checkbox_camp_list[v] = self.main_container:getChildByName("checkbox_camp"..v)
        end
    end

    --职业
    self.checkbox_career_list = {}
    for k,v in pairs(HeroConst.CareerType) do
        if v ~= 0 then
            self.checkbox_career_list[v] = self.main_container:getChildByName("checkbox_profession"..v)
            if HeroConst.CareerName[v] then
                local label = self.checkbox_career_list[v]:getChildByName("label")
                label:setString(HeroConst.CareerName[v])
            end
        end
    end


    self.clear_btn = self.main_container:getChildByName("clear_btn")
    self.clear_label = self.clear_btn:getChildByName("label")
    self.clear_label:setString(TI18N("清除勾选"))
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确 定"))
end

function FormFilterHeroPanel:register_event()

    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.clear_btn, handler(self, self.onClickClearBtn) ,true, 2)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)

    for _type, box in pairs(self.checkbox_camp_list) do
        box:addEventListener(function ( sender,event_type )
            playButtonSound2()
            self:onSelectBoxCamp(_type)
        end)
    end
    for _type, box in pairs(self.checkbox_career_list) do
        box:addEventListener(function ( sender,event_type )
            playButtonSound2()
            self:onSelectBoxCareer(_type)
        end)
    end
end

--关闭
function FormFilterHeroPanel:onClickBtnClose()
    controller:openFormFilterHeroPanel(false)
end

--清除勾选
function FormFilterHeroPanel:onClickClearBtn()
    if self.is_clear then
        --清除勾选
        self:setBoxSelect(false)
        self.clear_label:setString(TI18N("全部勾选"))
        self.is_clear = false
    else
        --全部勾选
        self:setBoxSelect(true)
        self.clear_label:setString(TI18N("清除勾选"))
        self.is_clear = true
    end
end

function FormFilterHeroPanel:setBoxSelect(bool)
    for _type, box in pairs(self.checkbox_camp_list) do
        self.dic_filter_camp_type[_type] = bool
        box:setSelected(bool)
    end

    for _type, box in pairs(self.checkbox_career_list) do
        self.dic_filter_career_type[_type] = bool
       box:setSelected(bool)
    end
end

--确定
function FormFilterHeroPanel:onClickComfirmBtn()
    self:onClickBtnClose()
    GlobalEvent:getInstance():Fire(HeroEvent.Filter_Hero_Update, self.dic_filter_camp_type, self.dic_filter_career_type)
end


--选择box 阵营
function FormFilterHeroPanel:onSelectBoxCamp(camp_type)
    local box = self.checkbox_camp_list[camp_type]
    local is_select =  box:isSelected()
    self.dic_filter_camp_type[camp_type] = is_select
    self:setClearBtnStatus()
end

--选择box职业
function FormFilterHeroPanel:onSelectBoxCareer(career_type)
    local box = self.checkbox_career_list[career_type]
    local is_select =  box:isSelected()
    self.dic_filter_career_type[career_type] = is_select
    self:setClearBtnStatus()
end


function FormFilterHeroPanel:openRootWnd(dic_filter_camp_type, dic_filter_career_type)
    --阵营过滤
    local dic_filter_camp_type = dic_filter_camp_type or {}
    --职业过滤
    local dic_filter_career_type = dic_filter_career_type or {}

    --不直接赋值.而是克隆的方式.是因为..如果过滤没有的英雄的话..要保留原来的信息
    for _type, box in pairs(self.checkbox_camp_list) do
        self.dic_filter_camp_type[_type] = dic_filter_camp_type[_type]
        if self.dic_filter_camp_type[_type] == true then
            box:setSelected(true)
        else
            box:setSelected(false)
        end
    end
    
    for _type, box in pairs(self.checkbox_career_list) do
        self.dic_filter_career_type[_type] = dic_filter_career_type[_type]
       if self.dic_filter_career_type[_type] == true then
            box:setSelected(true)
        else
            box:setSelected(false)
        end
    end
    self:setClearBtnStatus()
end

function FormFilterHeroPanel:setClearBtnStatus()
    local is_clear = false
    for k,v in pairs(self.dic_filter_camp_type) do
        if v == true then
            is_clear = true
            break
        end
    end
    if not is_clear then
       for k,v in pairs(self.dic_filter_career_type) do
            if v == true then
                is_clear = true
                break
            end
        end 
    end
    self.is_clear = is_clear
    if is_clear then
        self.clear_label:setString(TI18N("清除勾选"))
    else
        self.clear_label:setString(TI18N("全部勾选"))
    end
end



function FormFilterHeroPanel:close_callback()
    controller:openFormFilterHeroPanel(false)
end