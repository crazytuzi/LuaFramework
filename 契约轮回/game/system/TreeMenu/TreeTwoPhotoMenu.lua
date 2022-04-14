-- @Author: lwj
-- @Date:   2018-12-18 17:15:12
-- @Last Modified time: 2018-12-18 17:15:23

TreeTwoPhotoMenu = TreeTwoPhotoMenu or class("TreeTwoPhotoMenu", BaseTreeTwoMenu)
local TreeTwoPhotoMenu = TreeTwoPhotoMenu

function TreeTwoPhotoMenu:ctor(parent_node, layer, first_menu_item)
    self.abName = "system"
    self.assetName = "TreeTwoPhotoMenu"

    TreeTwoPhotoMenu.super.Load(self)
    self.titleModel = TitleModel.GetInstance()
    self.is_show_red = false
end

function TreeTwoPhotoMenu:dctor()
    if self.updateputon_eventid then
        GlobalEvent:RemoveListener(self.updateputon_eventid)
    end
    self.updateputon_eventid = nil

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function TreeTwoPhotoMenu:LoadCallBack()
    self.nodes = {
        "photo",
        "putFlag",
    }
    self:GetChildren(self.nodes)
    self.img = self.photo:GetComponent('Image')
    TreeTwoPhotoMenu.super.LoadCallBack(self)

    self.updateputon_eventid = GlobalEvent:AddListener(TitleEvent.UpdateTitlePuton, handler(self, self.SelectPutOn))
end

function TreeTwoPhotoMenu:AddEvent()
    local function call_back(target, x, y)
        --self:SetRedDot(false)
        --self.data.is_show_red = false
        --self.titleModel:AddOneOffRedById(self.data[1])
        FashionModel.GetInstance().default_sel_id = nil
        self.first_menu_item.select_sec_menu_id = self.data[1]
        GlobalEvent:Brocast(CombineEvent.LeftSecondMenuClick .. self.parent_cls_name, self.first_menu_id, self.data[1], self.data.is_show_red, self.index, self:GetHeight())
    end
    AddClickEvent(self.Image.gameObject, call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.SelectSecMenuDefault .. self.parent_cls_name, handler(self, self.SelectDefault))
end

function TreeTwoPhotoMenu:ShowPanel()
    if self.data then
        self.p_title = self.titleModel:GetPTitleBySunId(self.data[1])
        if self.p_title then
            --已激活
            if self.p_title.etime ~= 0 then
                --不是永久
                self.titleModel:AddSecItemToList(self)
            end
            ShaderManager.GetInstance():SetImageNormal(self.img)
        else
            --未激活

            ShaderManager.GetInstance():SetImageGray(self.img)
        end
        lua_resMgr:SetImageTexture(self, self.img, "iconasset/icon_title", tostring(self.data[1]), true, nil, false)
        self:Select(self.select_sub_id)
        if self.data.is_show_red then
            self:SetRedDot(true)
        end
    end
end

function TreeTwoPhotoMenu:SelectPutOn(id)
    SetVisible(self.putFlag.gameObject, self.data[1] == id)
end

function TreeTwoPhotoMenu:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(-100, 24)
    self.red_dot:SetRedDotParam(isShow)
end

