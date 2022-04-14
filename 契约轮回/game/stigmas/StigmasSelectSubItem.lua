---
--- Created by  Administrator
--- DateTime: 2019/9/24 20:29
---
StigmasSelectSubItem = StigmasSelectSubItem or class("StigmasSelectSubItem", BaseCloneItem)
local this = StigmasSelectSubItem

function StigmasSelectSubItem:ctor(obj, parent_node, parent_panel)
    StigmasSelectSubItem.super.Load(self)
    self.events = {}
    self.model = StigmasModel:GetInstance()
end

function StigmasSelectSubItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function StigmasSelectSubItem:LoadCallBack()
    self.nodes = {
        "head","nums","name","choseBtn","choseBtn/choseTex"
    }
    self:GetChildren(self.nodes)
    self.head = GetImage(self.head)
    self.nums = GetText(self.nums)
    self.name = GetText(self.name)
    self.choseTex = GetText(self.choseTex)
    self.choseImg = GetImage(self.choseBtn)
    self:InitUI()
    self:AddEvent()
    self.red = RedDot(self.choseBtn.transform, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(40, 13)
end

function StigmasSelectSubItem:InitUI()

end

function StigmasSelectSubItem:AddEvent()

    local function call_back()
        if not self.IsOption then
            Notify.ShowText("Inactive")
            return
        end
        if self.isDown then
            StigmasController:GetInstance():RequstDungeSoulSelect(self.model.curSlot,0)
            return
        end
        local godId =  self.model:GetSlotByIndex(self.model.curSlot)
        if godId ~= 0 then
            local curColor = Config.db_god_morph[godId].color
            if curColor <= self.color then
                local function call_back()
                    StigmasController:GetInstance():RequstDungeSoulSelect(self.model.curSlot,self.godId)
                end
                Dialog.ShowTwo("Tip", "Replace current avatar?", "Confirm", call_back, nil, "Cancel", nil, nil)
            else
                local function call_back()
                    StigmasController:GetInstance():RequstDungeSoulSelect(self.model.curSlot,self.godId)
                end
                Dialog.ShowTwo("Tip", "You are replacing a guardian soul with a lower-level one, continue?", "Confirm", call_back, nil, "Cancel", nil, nil)
            end
            return
        end
        StigmasController:GetInstance():RequstDungeSoulSelect(self.model.curSlot,self.godId)
    end
    AddButtonEvent(self.choseBtn.gameObject,call_back)
end

function StigmasSelectSubItem:SetData(godId)
    self.godId = godId
    self.color = Config.db_god_morph[godId].color
    self.name.text = Config.db_god_morph[godId].sname
    lua_resMgr:SetImageTexture(self, self.head, "iconasset/icon_god", godId, true)
    self:UpdateInfo()
end

function StigmasSelectSubItem:UpdateInfo()
    --dump(self.model.redGodTab)
    --logError("1111131")
    if not table.isempty(self.model.redGodTab )then
        local isRed = self.model.redGodTab[self.model.curSlot][self.godId]
        self.red:SetRedDotParam(isRed)
    end
    if not self.model:IsOption(self.godId) then --不可以布置
        ShaderManager:GetInstance():SetImageGray(self.choseImg)
        self.choseTex.text = "Activate"
        self.nums.text = "It needs to activate guard"
        return
    end
    self.IsOption = true
    local times = self.model:GetGodtimes(self.godId)
    local num = Config.db_dunge_soul_morph[self.godId].num
    local color = "1CFF11"
    if num - times <= 0 then
        color = "FF0A00"
    end
    self.nums.text = string.format("You can still deploy <color=#%s>%s</color>",color,num - times)
    ShaderManager:GetInstance():SetImageNormal(self.choseImg)
    self:SetBtnState()
end

function StigmasSelectSubItem:SetBtnState()
    local  godId = self.model:GetSlotByIndex(self.model.curSlot)
    if godId == self.godId then
        self.isDown = true
        self.choseTex.text = "Remove"
        lua_resMgr:SetImageTexture(self, self.choseImg, "common_image", "btn_yellow_4", true)
    else

        self.isDown = false
        if not self.model:IsOption(self.godId) then --不可以布置
            self.choseTex.text = "Activate"
            return
        end
        if godId == 0 then
            lua_resMgr:SetImageTexture(self, self.choseImg, "common_image", "btn_yellow_4", true)
            self.choseTex.text = "Select"
        else
            self.choseTex.text = "Switch"
            lua_resMgr:SetImageTexture(self, self.choseImg, "common_image", "btn_blue_4", true)
        end


    end

end