-- 
-- @Author: LaoY
-- @Date:   2018-09-12 17:53:07
-- 
PanelTabButtonTwo = PanelTabButtonTwo or class("PanelTabButtonTwo", BaseWidget)
local PanelTabButtonTwo = PanelTabButtonTwo

function PanelTabButtonTwo:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelTabButtonTwo"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    PanelTabButtonTwo.super.Load(self)
end

function PanelTabButtonTwo:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function PanelTabButtonTwo:LoadCallBack()
    self.nodes = {
        "img_sel", "img_nor", "img_nor/text_sel", "img_sel/text",
    }
    self:GetChildren(self.nodes)
    self.text_component = self.text:GetComponent('Text')
    self.text_sel = GetText(self.text_sel);
    self.img_nor_cpnt=GetImage(self.img_nor)
    self.img_sel_cpnt=GetImage(self.img_sel)

    SetColor(self.text_component, HtmlColorStringToColor("#584036"))
    SetColor(self.text_sel, HtmlColorStringToColor("#C1D9E9"))
    self:SetSelectState(false)

    self.red_dot = RedDot(self.transform,nil,RedDot.RedDotType.Nor)
    self.red_dot:SetPosition(0,55)
    if self.red_dot_param ~= nil then
        self:SetRedDotParam(self.red_dot_param)
    end
    if self.red_dot_type ~= nil then
        self:SetRedDotType(self.red_dot_type)
    end

    self:AddEvent()
end

function PanelTabButtonTwo:AddEvent()
    local function call_back(target, x, y)
        PanelTabButton.OnClick(self)
    end
    AddClickEvent(self.img_sel.gameObject, call_back)
    AddClickEvent(self.img_nor.gameObject, call_back)
end

function PanelTabButtonTwo:SetCallBack(callback)
    self.callback = callback
end

function PanelTabButtonTwo:SetData(data)
    data = data or {}
    self.data = data
    self.text_component.text = data.text or ""
    self.text_sel.text = data.text or "";
    self.text_component.lineSpacing = 2;
    self.text_sel.lineSpacing = 2;
    self.id = data.id or 1 
end

function PanelTabButtonTwo:SetSelectState(flag)
    if self.select_state == flag then
        return
    end
    self.select_state = flag
    if flag then
        SetVisible(self.img_sel, true)
        SetVisible(self.img_nor, false)
        SetVisible(self.text_sel, false);
        SetVisible(self.text_component, true);
        SetAsLastSibling(self.transform);
        -- SetLocalPositionX(self.text,-2)
    else
        SetVisible(self.img_sel, false)
        SetVisible(self.img_nor, true)
        SetVisible(self.text_sel, true);
        SetVisible(self.text_component, false);
        --SetColor(self.text_component,HtmlColorStringToColor("#DAC3A2"))
        -- SetLocalPositionX(self.text,-6)
    end
end

function PanelTabButtonTwo:SetRedDotType(red_dot_type)
    if not self.red_dot then
        self.red_dot_type = red_dot_type
    else
        self.red_dot:SetRedDotType(red_dot_type)
    end
end

function PanelTabButtonTwo:SetRedDotParam(param)
    if not self.red_dot then
        self.red_dot_param = param
    else
        self.red_dot:SetRedDotParam(param)
    end
end

function PanelTabButtonTwo:SetSideBarRes()
    local nor_str=self.data.dark_icon and self.data.dark_icon or "system:panel_tog_2"
    local sel_str=self.data.icon and self.data.icon or "system:panel_tog_1"
    local nor_tbl=string.split(nor_str,':')
    local sel_tbl=string.split(sel_str,":")
    lua_resMgr:SetImageTexture(self,self.img_nor_cpnt, nor_tbl[1].."_image", nor_tbl[2],true,nil,false)
    lua_resMgr:SetImageTexture(self,self.img_sel_cpnt, sel_tbl[1].."_image", sel_tbl[2],true,nil,false)
end