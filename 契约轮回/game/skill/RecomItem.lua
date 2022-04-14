-- @Author: lwj
-- @Date:   2018-10-22 21:30:17
-- @Last Modified time: 2018-10-24 19:56:27

RecomItem = RecomItem or class("RecomItem", BaseItem)
local RecomItem = RecomItem

function RecomItem:ctor(parent_node, layer)
    self.abName = "skill"
    self.assetName = "RecomItem"
    self.layer = layer

    self.model = SkillUIModel.GetInstance()
    BaseItem.Load(self)
end

function RecomItem:dctor()
    self.itemList = {}
end

function RecomItem:LoadCallBack()
    self.nodes = {
        "slots/slotFrame_1/image1",
        "slots/slotFrame_2/image2",
        "slots/slotFrame_3/image3",
        "slots/slotFrame_4/image4",
        "slots/slotFrame_5/image5",
        "bg",
        "btn_Confirm",
        "Title",
        "Text"
    }
    self:GetChildren(self.nodes)
    self:AddItemList()
    self.title_text = GetText(self.Text)

    self:AddEvent()
    self:InitShow()
end

function RecomItem:AddEvent()
    local function call_back(target, x, y)
        GlobalEvent:Brocast(SkillUIEvent.SetRecommendInfo, self.data.id)
        GlobalEvent:Brocast(SkillUIEvent.OpenSkillUIPanel)
    end
    AddClickEvent(self.btn_Confirm.gameObject, call_back)
end

function RecomItem:SetData(data)
    self.data = data
end

function RecomItem:InitShow()
    local item_Img = nil
    for i = 1, #self.itemList do
        item_Img = self.itemList[i]:GetComponent('Image')
        lua_resMgr:SetImageTexture(self, item_Img, "iconasset/icon_skill", tostring(self.data.recommend[i][1]), true, nil, false)
    end
    if self.data.id == 3 then
        --local title_Img = self.Title:GetComponent('Image')
        --lua_resMgr:SetImageTexture(self, title_Img, "skill_image", "SkillPanel_GreatestPVP", true)
        self.title_text.text = "Best at PK"
    end
end

function RecomItem:AddItemList()
    self.itemList = {}
    self.itemList[1] = self.image1
    self.itemList[2] = self.image2
    self.itemList[3] = self.image3
    self.itemList[4] = self.image4
    --self.itemList[5] = self.image5
end
