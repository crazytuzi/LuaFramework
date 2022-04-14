---
--- Created by  Administrator
--- DateTime: 2019/12/23 15:32
---
MachineArmorUpStarPanel = MachineArmorUpStarPanel or class("MachineArmorUpStarPanel", BaseItem)
local this = MachineArmorUpStarPanel

function MachineArmorUpStarPanel:ctor(parent_node, parent_panel)
    self.abName = "machinearmor"
    self.assetName = "MachineArmorUpStarPanel"
    self.layer = "UI"

    self.model = MachineArmorModel:GetInstance()
    self.attrs = {}
    self.events = {}
    self.modelEvents = {}
    MachineArmorUpStarPanel.super.Load(self)
end

function MachineArmorUpStarPanel:dctor()
    self.model:RemoveTabListener(self.modelEvents)
    GlobalEvent:RemoveTabListener(self.events)
    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = {}
    end
    if self.itemicon then
        self.itemicon:destroy()
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function MachineArmorUpStarPanel:LoadCallBack()
    self.nodes = {
        "attrObj/iconParent","attrObj/PowerObj/equipPower","attrObj/starBtn/starBtnTex","jihuoBg","jihuoBg/jihuoText",
        "attrObj/starBtn","attrObj/hudunTex","attrObj",
        "attrObj/itemNums","MachineArmorAttrItem","attrObj/curStar","attrObj/attrParent",
        "starObj/starBg_3/star_3","starObj/starBg_2","starObj/starBg_7","starObj/starBg_8/star_8","starObj/starBg_6",
        "starObj/starBg_4/star_4","starObj/starBg_6/star_6","starObj/starBg_4","starObj/starBg_5","starObj/starBg_1",
        "starObj/starBg_3","starObj/starBg_2/star_2","starObj/starBg_8","attrObj/hudunUpImg","attrObj/hudunNextTex",
        "starObj/starBg_7/star_7","starObj/starBg_5/star_5","starObj/starBg_1/star_1","attrObj/max","attrObj/kejinjie","attrObj/keJihuo",
    }
    self:GetChildren(self.nodes)
    self.equipPower = GetText(self.equipPower)
    self.starBtnTex = GetText(self.starBtnTex)
    self.hudunTex = GetText(self.hudunTex)
    self.itemNums = GetText(self.itemNums)
    self.curStar = GetText(self.curStar)
    self.hudunTex = GetText(self.hudunTex)
    self.jihuoText = GetText(self.jihuoText)
    self.hudunNextTex = GetText(self.hudunNextTex)
    --SetVisible(self.kejinjie,false)
    --SetVisible(self.keJihuo,false)
    --for i = 1, 8 do
    --    self["star_"..i] = GetImage(self["star_"..i])
    --    self["starBg_"..i] = GetImage(self["starBg_"..i])
    --end
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.info)
    end


end

function MachineArmorUpStarPanel:InitUI()

end

function MachineArmorUpStarPanel:AddEvent()


    for i = 1, 8 do
        local function call_back(go)
            local arr = string.split(go.name,"_")
            local num = tonumber(arr[2]) - 1
            -- local curStar = self.curCfg.star
            --local index = (curStar%9) + 1
            self:KongClick(num,go)
        end
        AddClickEvent(self["starBg_"..i].gameObject,call_back)
        --self["starBg_"..i] = GetImage(self["starBg_"..i])
    end

    local function call_back() --升星
        MachineArmorController:GetInstance():RequstUpStarInfo(self.info.id)
    end
    AddClickEvent(self.starBtn.gameObject,call_back)

    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaUpStarInfo,handler(self,self.MechaUpStarInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(MachineArmorEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
end

function MachineArmorUpStarPanel:CheckRedPoint()
    if not self.red then
        self.red = RedDot(self.starBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(58, 18)
    end
    self.red:SetRedDotParam(self.model.starRedPoints[self.info.id])
end

function MachineArmorUpStarPanel:SetData(info)
    self.info = info
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:UpdateStarInfo()
    self:CheckRedPoint()
end

function MachineArmorUpStarPanel:KongClick(index,go)
    local starIndex =  math.floor(self.curCfg.star / 9) * 9 + index
    local tipsPanel = lua_panelMgr:GetPanelOrCreate(MachineArmorTips)
    --logError(starIndex)
    tipsPanel:Open()
    tipsPanel:SetData(self.curCfg.id,starIndex, go.transform,self.curCfg.star)
end

function MachineArmorUpStarPanel:MechaUpStarInfo(data)
    if data.mecha.id == self.info.id then
        self:UpdateStarInfo()
    end
end

function MachineArmorUpStarPanel:UpdateStarInfo()
    local serInfo = self.model:GetMecha(self.info.id)
    if not serInfo then
        local key = tostring(self.info.id).."@".."0"
        self.curCfg = Config.db_mecha_star[key]
        self.curStar.text = "Not owned"
        --self.jihuoText.text
        self.jihuoText.text = string.format("Collect 8 shards to activate  %s/%s",0,8)
        SetVisible(self.jihuoBg,true)

    else
        local key = tostring(self.info.id).."@"..serInfo.star
        self.curCfg  = Config.db_mecha_star[key]
        if self.curCfg.star_client < 0 then --未激活
            self.curStar.text = "Not owned"
            self.jihuoText.text = string.format("Collect 8 shards to activate  %s/%s",self.curCfg.star,8)
            SetVisible(self.jihuoBg,true)
        else --已经激活了
            self.curStar.text = self.curCfg.star_client.."Stage"..self.curCfg.plot_client.."Star"
            SetVisible(self.jihuoBg,false)
        end
    end
    --self["star_"..i]
    if self:IsMaxOrder() then
        for i = 1, 8 do
            SetVisible(self["star_"..i],true)
        end
        SetVisible(self.max,true)
        SetVisible(self.itemNums,false)
        SetVisible(self.iconParent,false)
        SetVisible(self.kejinjie,false)
        SetVisible(self.keJihuo,false)
    else
        for i = 1, 8 do
            local  curStar = self.curCfg.plot_client
            if i <= curStar then
                SetVisible(self["star_"..i],true)
            else
                SetVisible(self["star_"..i],false)
            end
        end
        SetVisible(self.max,false)
        --SetVisible(self.itemNums,true)
        --SetVisible(self.iconParent,true)
        local costTab = String2Table(self.curCfg.cost)
        if table.isempty(costTab) then  --无消耗
            if self.curCfg.star_client < 0 then
                self.starBtnTex.text = "Activate"
                SetVisible(self.keJihuo,true)
            else
                SetVisible(self.kejinjie,true)
                self.starBtnTex.text = "Advance"
            end

            SetVisible(self.itemNums,false)
            SetVisible(self.iconParent,false)
        else
            self.starBtnTex.text = "Star up"
            SetVisible(self.itemNums,true)
            SetVisible(self.iconParent,true)
            SetVisible(self.kejinjie,false)
            SetVisible(self.keJihuo,false)
            self:CreateIcon(costTab[1],costTab[2])
        end

    end
    self:UpdateAttr()
end

function MachineArmorUpStarPanel:UpdateAttr()
    local cfg  = self.curCfg
    local nextKey = tostring(self.curCfg.id).."@"..tostring(self.curCfg.star+1)
    local nextCfg = Config.db_mecha_star[nextKey]
    local baseTab =String2Table(cfg.attrs)
    local nextTab = {}
    if nextCfg then
         nextTab = String2Table(nextCfg.attrs)
    end
    for i = 1, #baseTab do
        if baseTab[i][1] == enum.ATTR.ATTR_MECHA_SHIELD then
            self.hudunTex.text = (baseTab[i][2]/100).."%"
            if not table.isempty(nextTab[i]) then

                local num = nextTab[i][2] - baseTab[i][2]
                if num == 0 then
                    SetVisible(self.hudunUpImg,false)
                    self.hudunNextTex.text = ""
                else
                    self.hudunNextTex.text = (num/100).."%"
                    SetVisible(self.hudunUpImg,true)
                end

            else
                SetVisible(self.hudunUpImg,false)
                self.hudunNextTex.text = ""
            end

        else
            local buyItem =  self.attrs[i]
            if  not buyItem then
                buyItem = MachineArmorAttrItem(self.MachineArmorAttrItem.gameObject,self.attrParent,"UI")
                self.attrs[i] = buyItem
            else
                buyItem:SetVisible(true)
            end
            buyItem:SetData(baseTab[i],nextTab[i] or {},nextCfg == nil)
        end

    end
    for i = #baseTab + 1,#self.attrs do
        local buyItem = self.attrs[i]
        buyItem:SetVisible(false)
    end
    local attriList = baseTab
    local power2,tab2 = GetPowerByConfigList(attriList,{})
    local power,tab = GetPowerByConfigList(attriList,tab2)
    -- logError(power,self.fPower,power + self.fPower)
    self.equipPower.text = power
end

function MachineArmorUpStarPanel:CreateIcon(id,itemNum)
    local num = BagModel:GetInstance():GetItemNumByItemID(id);
    local param = {}
    param["item_id"] = id
    local color = "00FF1A"
    if num < (itemNum or 1) then
        color = "FF1200"
    end
   -- param["num"] = string.format("<color=#%s>%s/%s</color>",color,num,itemNum or 1)
    param["num"] = ""
    param["model"] = BagModel
    param["can_click"] = true
    param["show_num"] = true
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    self.itemicon:SetIcon(param)
    self.itemNums.text = string.format("<color=#%s>%s/%s</color>",color,num,itemNum or 1)
    --if num < (itemNum or 1) then
    --    self.itemicon:SetIconGray()
    --else
    --    self.itemicon:SetIconNormal()
    --end
end



function MachineArmorUpStarPanel:IsMaxOrder()
    local nextKey = tostring(self.curCfg.id).."@"..tostring(self.curCfg.star + 1)
    if not Config.db_mecha_star[nextKey] then --最大星数
        return true
    end
    return false
end

