---
---Author: wry
---Date: 2019/9/28 19:32:53
---

StigmataLevelUpPanel = StigmataLevelUpPanel or class('StigmataLevelUpPanel', WindowPanel)
local this = StigmataLevelUpPanel

function StigmataLevelUpPanel:ctor()
    self.abName = 'bag'
    self.assetName = 'StigmataLevelUpPanel'
    self.layer = 'UI'
    self.panel_type = 3
    self.events = {}

    --self.bagModel = BagModel:GetInstance()
    self.model = StigmataModel.GetInstance()
    self.controller = StigmataController:GetInstance()

    self.pos = 0
    self.itemData = {}
    self.good_item = nil

    self.db_item = nil
    self.db_soul = nil
    self.db_soul_level = nil
    self.db_soul_NextLevel = nil

    self.use_background = true
    self.change_scene_close = true
end

function StigmataLevelUpPanel:dctor()
    if self.events then
        for k,v in pairs(self.events) do
            self.model:RemoveListener(v)
        end
    end
    self.events = {}

    if self.good_item then
        self.good_item:destroy()
        self.good_item = nil
    end

    self.db_item = nil
    self.db_soul = nil
    self.db_soul_level = nil
    self.db_soul_NextLevel = nil
end

function StigmataLevelUpPanel:Open(data)
    WindowPanel.Open(self)

    self.pos = data[1]
    self.itemData = self.model.mainPanelData[self.pos]
end

function StigmataLevelUpPanel:LoadCallBack()
    self.nodes = {
       "IconBGImage",
       "soulNameImage/soulName",
       "soulTypeMessage/nowType1","soulTypeMessage/nowType2","soulTypeMessage/nowType3","soulTypeMessage/upType1","soulTypeMessage/upType2","soulTypeMessage/upType3",
       "constText",
       "UpButton"
    }
    self:GetChildren(self.nodes)

    self.soulName = GetText(self.soulName)
    self.nowType1 = GetText(self.nowType1)
    self.nowType2 = GetText(self.nowType2)
    self.nowType3 = GetText(self.nowType3)
    self.upType1 = GetText(self.upType1)
    self.upType2 = GetText(self.upType2)
    self.upType3 = GetText(self.upType3)
    self.constText = GetText(self.constText)

    self:SetTileTextImage("bag_image", "bag_Up_soul")

    self:SetPanelSize(638, 492)

    self:AddEvent()
end

function StigmataLevelUpPanel:AddEvent()
    self.events[#self.events+1] = self.model:AddListener(StigmataEvent.UpdatePlayerConstant,handler(self,self.UpdateView))

    --升级按钮
    local function UpButtonCall_back()
        local cost = String2Table(self.db_soul_level.cost)[2]
        local have = RoleInfoModel.GetInstance():GetRoleValue(String2Table(self.db_soul_level.cost)[1])
        if cost > have then
            Notify.ShowText("Insufficient items")
            return
        end

        --升级后不要刷新圣痕背包
        self.model.NeedRequestBagInfo = false
        --升级后部分更新左侧圣痕数据 因为会返回被升级的单个圣痕数据
        self.model.IsUpdateMainData = true

        self.controller:RequestSoulUpLevel(self.pos)
    end
    AddClickEvent(self.UpButton.gameObject,UpButtonCall_back)
end

function StigmataLevelUpPanel:OpenCallBack()
    self:CreateItem(self.itemData)
    self:UpdateView()
end

function StigmataLevelUpPanel:UpdateView()
    self.itemData = self.model.mainPanelData[self.pos]

    self.db_item = Config.db_item[self.itemData.id]
    self.db_soul = Config.db_soul[self.itemData.id]
    self.db_soul_level = Config.db_soul_level[tostring(self.itemData.id) .."@".. tostring(self.itemData.extra)]
    self.db_soul_NextLevel = Config.db_soul_level[tostring(self.itemData.id) .."@".. tostring(self.itemData.extra + 1)]

    self:SetPanelMessage()

    if not self.db_soul_NextLevel then
        SetVisible(self.UpButton,false)
     end
end


function StigmataLevelUpPanel:CreateItem(tData)
    local db_soul = Config.db_soul[tData.id]

    local param = {}
    param["model"] = self.model
    param["item_id"] = tData.id
    param["can_click"] = false
    param["bind"] = 0
    param["show_noput"] = true

    self.good_item = GoodsIconSettorTwo(self.IconBGImage)
    self.good_item:SetIcon(param)
end

function StigmataLevelUpPanel:SetPanelMessage()
    local db_item = self.db_item
    local db_soul = self.db_soul
    local db_soul_level = self.db_soul_level
    local db_soul_NextLevel = self.db_soul_NextLevel

    local color = ColorUtil.GetColor(db_item.color)
    self.soulName.text = string.format("<color=#%s>%s</color>",color,db_item.name.."LV."..self.itemData.extra)

      --基础属性
    local baseAttribute = String2Table(self.db_soul.base)

    --当前等级附加属性
    local attribute = String2Table(db_soul_level.attrib)

    --下一级附加属性
    local nextAttribute =  nil
    if db_soul_NextLevel then
        nextAttribute = String2Table(db_soul_NextLevel.attrib)
    end
    


    local type1 = Config.db_attr_type[attribute[1][1]].type == 2
    local value1 = attribute[1][2] + baseAttribute[1][2]

    local upValue1 = 0
    if db_soul_NextLevel then
        upValue1 = nextAttribute[1][2] - attribute[1][2]
    end
    
    if type1 then
         --处理百分比属性
        value1 = (value1 / 100) .. "%"
        upValue1 = (upValue1 / 100) .. "%"
    end

    if #attribute > 1 then
        SetVisible(self.nowType1.gameObject, true)
        SetVisible(self.nowType2.gameObject, true)
        SetVisible(self.upType1.gameObject, true)
        SetVisible(self.upType2.gameObject, true)
        SetVisible(self.nowType3.gameObject, false)
        SetVisible(self.upType3.gameObject, false)

       
        --local type2 = attribute[2][1] > 12
        local type2 = Config.db_attr_type[attribute[2][1]].type == 2
        local value2 = attribute[2][2]+ baseAttribute[2][2]

        local upValue2 = 0
        if db_soul_NextLevel then
            upValue2 = nextAttribute[2][2] - attribute[2][2]
        end

        if type2 then
             --处理百分比属性
            value2 = (value2 / 100) .. "%"
            upValue2 = (upValue2 / 100) .. "%"
        end

        self.nowType1.text = self:GetAttrNameByIndex(attribute[1][1]).."+"..value1
        self.nowType2.text = self:GetAttrNameByIndex(attribute[2][1]).."+"..value2

        self.upType1.text = "+"..upValue1
        self.upType2.text = "+"..upValue2

    else
        SetVisible(self.nowType1.gameObject, false)
        SetVisible(self.nowType2.gameObject, false)
        SetVisible(self.upType1.gameObject, false)
        SetVisible(self.upType2.gameObject, false)
        SetVisible(self.nowType3.gameObject, true)
        SetVisible(self.upType3.gameObject, true)

        self.nowType3.text = self:GetAttrNameByIndex(attribute[1][1]).."+"..value1
        self.upType3.text = "+"..upValue1
    end

    --拥有
    local have = RoleInfoModel.GetInstance():GetRoleValue(String2Table(db_soul_level.cost)[1])
    
    --消耗
    local consume = String2Table(db_soul_level.cost)[2]

    --拥有文本颜色
    local color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
    if consume > have then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    end

    have = string.format("<color=#%s>%s</color>",color,have)

    self.constText.text = have.."/"..consume
end

function StigmataLevelUpPanel:GetAttrNameByIndex(index)
    local name = GetAttrNameByIndex(index)
    if string.len( name ) == 6 then
        local name1 = string.sub( name, 1,3)
        local name2 = string.sub( name, 4,6)
        return name1 .."       ".. name2
    end
    return  name
end