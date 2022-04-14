--
-- Author: LaoY
-- Date: 2018-07-12 20:10:35
--
CreateRoleItem = CreateRoleItem or class("CreateRoleItem", Node)
local this = CreateRoleItem

function CreateRoleItem:ctor(obj, parent, tab)
    if not obj then
        return
    end
    self.transform = obj.transform

    self.transform:SetParent(parent)
    SetLocalScale(self.transform, 1, 1, 1)
    SetLocalRotation(self.transform, 0, 0, 0)

    self.data = tab

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self.abName = "login"
    self.image_abName = "login_image"
    self.model = LoginModel:GetInstance()
    self.idx = 1

    self:InitUI();
end

function CreateRoleItem:dctor()
end

function CreateRoleItem:InitUI()
    self.is_loaded = true
    self.nodes = {
        "Head",
        "sel_img", "nor_bg", "Frame",
    }
    self:GetChildren(self.nodes)

    self.headImg = GetImage(self.Head)

    self:AddEvent()

    if (self.is_need_refresh and self.data) then
        self:RefreshView()
    end
end
local lastClick
function CreateRoleItem:AddEvent()
    local function call_back()

        if lastClick and Time.time - lastClick < 0.5 then
            return
        end
        lastClick = Time.time
        if self.select_state then
            return
        end
        if self.call_back then
            self.call_back(self.index)
        end
    end
    AddClickEvent(self.nor_bg.gameObject, call_back)
    AddClickEvent(self.Frame.gameObject, call_back)
end

function CreateRoleItem:SetCallBack(call_back)
    self.call_back = call_back
end

function CreateRoleItem:SetData(index, data)
    self.index = index
    self.data = data
    self:RefreshView()
end

function CreateRoleItem:SetSelectState(flag)
    self.select_state = flag
    SetVisible(self.sel_img, flag)
    SetVisible(self.Frame, flag)
    SetVisible(self.nor_bg, not flag)
end

function CreateRoleItem:RefreshView()
    if self.is_loaded then
        lua_resMgr:SetImageTexture(self, self.headImg, self.image_abName, self.data.head, true)
    else
        self.is_need_refresh = true
    end
end

function CreateRoleItem:SetIdx(idx)
    self.idx = idx
end