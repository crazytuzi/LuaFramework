-- @Author: lwj
-- @Date:   2019-01-04 10:50:59
-- @Last Modified time: 2019-01-04 10:51:10

BookTopItem = BookTopItem or class("BookTopItem", BaseItem)
local BookTopItem = BookTopItem

function BookTopItem:ctor(parent_node, layer)
    self.abName = "book"
    self.assetName = "BookTopItem"
    self.layer = layer

    self.model = BookModel:GetInstance()
    BaseItem.Load(self)

    self.isDefault = false
end

function BookTopItem:dctor()
    if self.modelEventList then
        for i, v in pairs(self.modelEventList) do
            self.model:RemoveListener(v)
        end
        self.modelEventList = {}
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end

end

function BookTopItem:LoadCallBack()
    self.nodes = {
        "topText", "sel", "bg", "red_con","sel/Text",
    }
    self:GetChildren(self.nodes)
    self.sel_img = self.sel:GetComponent('Image')
    self.textT = self.topText:GetComponent('Text')
    self.textT1 = self.Text:GetComponent('Text')
    self:AddEvent()
    self:UpdateView()
end

function BookTopItem:AddEvent()
    local function call_back()
        if self.data.conData then
            self.model.curTheme = self.data.conData.id
            self.model:Brocast(BookEvent.ThemeTopItemClick, self.data.conData, self.data.tasksInfo)
        else
            --未开放
            local tip = ""
            if self.data.pre_id == 0 then
                --没有前置
                if self.data.open_data then
                    local lv = self.data.open_data[2]
                    if lv > RoleInfoModel.GetInstance():GetMainRoleLevel() then
                        lv = GetLevelShow(lv)
                        tip = string.format(ConfigLanguage.Book.OpenAfterLevelAchi, lv)
                        --else
                        --    local od = self.data.open_data[2][2]
                        --    tip = string.format(ConfigLanguage.Book.OpenAfterOpenDay, od)
                    end
                end
            else
                tip = ConfigLanguage.Book.OpenAfterActivateLast
            end
            Notify.ShowText(tip)
        end
    end
    AddClickEvent(self.bg.gameObject, call_back)

    self.modelEventList = {}
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(BookEvent.ThemeTopItemClick, handler(self, self.Select))
    --self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.UpdatePuttOn, handler(self, self.UpdatePutOn))
end

function BookTopItem:SetData(data)
    self.data = data
    if not data.conData then
        self.data.conData = Config.db_target[self.data.id]
    end
    if self.is_loaded then
        self:UpdateView()
    end
end

function BookTopItem:UpdateView()
    if self.data.conData then
        self.textT.text = self.data.conData.name
        self.textT1.text = self.data.conData.name
        self:SetRedDot(self.model:IsHaveThemeRD(self.data.conData.id))
        if self.isDefault then
            self.model.curTheme = self.data.conData.id
            self.model:Brocast(BookEvent.ThemeTopItemClick, self.data.conData, self.data.tasksInfo)
            self:Select(self.data.conData)
            self.isDefault = false
        end
    else
        self.textT.text = ConfigLanguage.Book.ThemeInavailidTextShow
    end
end

function BookTopItem:Select(conData)
    if self.data.conData then
        SetVisible(self.sel_img, conData.id == self.data.conData.id)
        SetVisible(self.topText, conData.id ~= self.data.conData.id)
    end
end

function BookTopItem:SetDefaultFlag()
    self.isDefault = true
    if self.is_loaded then
        self:UpdateView()
    end
end

function BookTopItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    if isShow == nil then
        isShow = false
    end
    self.red_dot:SetPosition(-10, 0)
    self.red_dot:SetRedDotParam(isShow)
end
--  活动是否开启
function BookTopItem:IsActive()
    if self.data.conData then
        return true
    else
        return false
    end
end
-- 设置活动text显示
function BookTopItem:SetText()
    local lv = self.data.open_data[2]
    if lv > RoleInfoModel.GetInstance():GetMainRoleLevel() then
        lv = GetLevelShow(lv)
        self.textT.text = string.format(ConfigLanguage.Book.OpenAfterLevel, lv)
    end
end