---
--- Created by  Administrator
--- DateTime: 2020/6/24 14:35
---
ArtifactUpGradePanel = ArtifactUpGradePanel or class("ArtifactUpGradePanel", BasePanel)
local this = ArtifactUpGradePanel

function ArtifactUpGradePanel:ctor()
    self.abName = "artifact"
    self.assetName = "ArtifactUpGradePanel"
    self.layer = "UI"
    -- self.parentPanel = parent_panel
    self.events = {}
    self.gEvents = {}
    self.use_background = true
    self.needSelect = true
    self.attrs = {}
    self.model = ArtifactModel:GetInstance()
end

function ArtifactUpGradePanel:dctor()
    GlobalEvent:RemoveTabListener(self.gEvents)
    self.model:RemoveTabListener(self.events)
    if self.PageScrollView then
        self.PageScrollView:OnDestroy()
    end
    self.PageScrollView = nil
    self.model.isOpenUpPanel = false
    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = nil
    end
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
    self.model.selectEquip = {}
end

function ArtifactUpGradePanel:Open(artId)
    self.artId = artId
    self.model.isOpenUpPanel = true
    ArtifactUpGradePanel.super.Open(self)
end

function ArtifactUpGradePanel:LoadCallBack()
    self.nodes = {
        "closeBtn","upBtn","allBox","modelCon","itemScrollView/Viewport",
        "itemScrollView/Viewport/itemContent","itemScrollView","lvObj/NextLv","lvObj/curLv",
        "attrObj/sliderObj/expTex","attrObj/sliderObj/slider","attrObj/sliderObj/addTex",
        "attrObj/sliderObj/addSlider","attrObj/attrparent","ArtifactUpGradeAttrItem",
    }
    self:GetChildren(self.nodes)
    self.NextLv = GetText(self.NextLv)
    self.curLv = GetText(self.curLv)
    self.expTex = GetText(self.expTex)
    self.slider = GetImage(self.slider)
    self.addSlider = GetImage(self.addSlider)
    self.allBox = GetToggle(self.allBox)


    self.addTex = GetText(self.addTex)
    self:SetMask()
    self:InitUI()
    self:AddEvent()
    BagController:GetInstance():RequestBagInfo(BagModel.artifact)
end

function ArtifactUpGradePanel:InitUI()
    self:InitModel()
end



function ArtifactUpGradePanel:SetAllBox(bool)
    bool = bool and true or false;
    self.allBox.isOn = bool

end

function ArtifactUpGradePanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function ArtifactUpGradePanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)


    local call_back = function(target, bool)
       self:SelectAllItems(bool)
        self:UpdataNextLvInfo()
    end

    AddValueChange(self.allBox.gameObject, call_back)

    
    local function call_back()
        if table.isempty(self.model.selectEquip) then
            Notify.ShowText("Please select reinforced material")
            return
        end
        ArtifactController:GetInstance():RequstArtifactReinfInfo(self.artId,self.model.selectEquip)
    end
    AddButtonEvent(self.upBtn.gameObject,call_back)

    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(ArtifactEvent.ArtifactBagInfo,handler(self,self.ArtifactBagInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactReinfInfo, handler(self, self.ArtifactReinfInfo))
end

function ArtifactUpGradePanel:ArtifactBagInfo()
    self:UpdateLvInfo()
    self:UpdateItems()
end

function ArtifactUpGradePanel:ArtifactReinfInfo(data)
    self:UpdateLvInfo()
    self:UpdateItems()
    --if self.PageScrollView ~= nil then
    --    self.PageScrollView:ForceUpdate()
    --end
end

function ArtifactUpGradePanel:UpdateItems()
    self.bagItems = BagModel:GetInstance():GetArtifactItemBySolt(self.artId)
    BagModel:GetInstance():ArrangeGoods(self.bagItems)
    if self.PageScrollView then
        self.PageScrollView:OnDestroy()
    end
    self:CreateItems(BagModel:GetInstance().artifactOpenCells)
    if self.needSelect then
        self.needSelect = false
        self:SelectAllItems(true)
    end
    self:UpdataNextLvInfo()
    --self:UpdateAttrInfo()
end

function ArtifactUpGradePanel:UpdateLvInfo()
    self.info = self.model:GetArtiInfo(self.artId)
    self.curLv.text = self.info.reinf_lv
   -- logError(info.reinf_lv,info.reinf_exp)
    if self.info.reinf_lv == 0 then
        self.curLv.text = "LV."..self.info.reinf_lv
        self.NextLv.text = "LV."..self.info.reinf_lv
        local key = self.artId.."@"..1
        local cfg = Config.db_artifact_reinf[key]
        self.slider.fillAmount = self.info.reinf_exp/cfg.exp
      --  self.expTex.text =  string.format("<color=#FF1C00>%s/%s</color>",self.info.reinf_exp,cfg.exp)
        self.expTex.text = string.format("%s/%s",self.info.reinf_exp,cfg.exp)
    else
        local key = self.artId.."@"..self.info.reinf_lv + 1
        local cfg = Config.db_artifact_reinf[key]
        if not cfg then --满级
            self.curLv.text = "Full"
            self.NextLv.text = "Full"
            return
        end
        self.curLv.text = "LV."..self.info.reinf_lv
        self.NextLv.text = "LV."..self.info.reinf_lv
        self.slider.fillAmount = self.info.reinf_exp/cfg.exp
        --self.expTex.text =  string.format("<color=#FF1C00>%s/%s</color>",self.info.reinf_exp,cfg.exp)
        self.expTex.text = string.format("%s/%s",self.info.reinf_exp,cfg.exp)
    end
   -- self.expTex
end

function ArtifactUpGradePanel:UpdateAttrInfo(NextCfg)
    local curCfg = Config.db_artifact_reinf[self.artId.."@"..self.info.reinf_lv]
    local nextCfg = NextCfg
    if not NextCfg then
        nextCfg = Config.db_artifact_reinf[self.artId.."@500"]
    end
    local attrTab = String2Table(curCfg.attrs)
    local nextTab = String2Table(nextCfg.attrs)
    for i = 1, #attrTab do
        local item = self.attrs[i]
        if not item  then
            item = ArtifactUpGradeAttrItem(self.ArtifactUpGradeAttrItem.gameObject,self.attrparent,"UI")
            self.attrs[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(attrTab[i],nextTab[i])
    end
    for i = #attrTab + 1, #self.attrs do
        local item = self.attrs[i]
        item:SetVisible(false)
    end
end

function ArtifactUpGradePanel:UpdataNextLvInfo()
    local num = 0
    for i, v in pairs(self.model.selectEquip) do
        local id = self.model:GetEquipId(v)
        --logError(self.model:GetItemNumByItemID(id))
        local item = self.model:GetItemByUid(v)
        local nums = item.num
        --logError(nums)
        --local nums =self.model:GetItemNumByItemID(id)
        local itemCfg = Config.db_item[id]
        local effect = 0
        if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_ARTI_EQUIP then
            effect = itemCfg.effect
        else
            if nums > 1  then
                for i = 1, nums do
                    effect = effect + itemCfg.effect
                end
            else
                effect = itemCfg.effect
            end
        end

        num  =  num + effect
    end
    self.addTex.text = "+"..num

    --local cfg =
    local exp = self.info.reinf_exp + num
    --local nextLv = self.info.reinf_lv + 1
    local nextLv = self.info.reinf_lv
    local key = self.artId.."@"..nextLv
    local cfg = Config.db_artifact_reinf[key]
    if not cfg then
        cfg = Config.db_artifact_reinf[self.artId.."@"..500]
    end
    local curExp = cfg.exp
    if curExp == 0 then
        curExp = Config.db_artifact_reinf[self.artId.."@"..nextLv + 1].exp
    end
    
    local addCfg = Config.db_artifact_reinf[self.artId.."@"..nextLv + 1]
    if  addCfg then
        local addSliderNum = exp/addCfg.exp
        if addSliderNum >= 1 then
            addSliderNum = 1
        end
        self.addSlider.fillAmount = addSliderNum
    end
    while (exp > curExp)
    do
        exp = exp - curExp
        nextLv = nextLv + 1
        key = self.artId.."@"..nextLv
        local cfg = Config.db_artifact_reinf[key]
        if not cfg then
            cfg = Config.db_artifact_reinf[self.artId.."@"..500]
        end
        curExp = cfg.exp
    end

    local cfg = Config.db_artifact_reinf[key]
    if not cfg then
        self.NextLv.text = "Full"
    else

        self.NextLv.text = "LV."..nextLv
    end

    if num == 0 then
        self:UpdateAttrInfo(Config.db_artifact_reinf[self.artId.."@"..self.info.reinf_lv])
    else
        self:UpdateAttrInfo(cfg)
    end

    --logError(key)


end



function ArtifactUpGradePanel:SelectAllItems(isSlect)
    for i, v in pairs(self.bagItems) do
        self.model:SetEquipSelect(v.uid,isSlect)
    end
    if self.PageScrollView then
        self.PageScrollView:ForceUpdate()
    end
end



function ArtifactUpGradePanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = ArtifactBagSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function ArtifactUpGradePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function ArtifactUpGradePanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.artifact
    if self.bagItems ~=nil then
        local itemBase = self.bagItems[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                local param = {}
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["multy_select"] = true
                param["itemSize"] = {x=78, y=78}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
                param["selectItemCB"] = handler(self,self.SelectItemCB)
                param["get_item_select_cb"] = handler(self,self.GetItemSelect)
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end
        else
            local param = {}
            param["bag"] = BagModel.artifact
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            param["selectItemCB"] = handler(self,self.SelectItemCB)
            param["get_item_select_cb"] = handler(self,self.GetItemSelect)
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.artifact
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        param["selectItemCB"] = handler(self,self.SelectItemCB)
        param["get_item_select_cb"] = handler(self,self.GetItemSelect)
        itemCLS:InitItem(param)
    end
end

function ArtifactUpGradePanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetArtifactItemDataByIndex(index)
end

function ArtifactUpGradePanel:SelectItemCB(uid,is_select)
    self.model:SetEquipSelect(uid,is_select)
    self:UpdataNextLvInfo()
end

function ArtifactUpGradePanel:GetItemSelect(uid)
    return self.model:GetEquipOneSelect(uid)
end


function ArtifactUpGradePanel:InitModel()
    local cfg = Config.db_artifact_unlock[self.artId]

    local res = cfg.res
    local ratio = cfg.ratio
    if res == self.curRes then
        return
    end
    self.curRes = res

    -- self.curResName

    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -1992, y = -70, z = 550}
    cfg.scale = {x = 150,y = 150,z = 150}
    cfg.trans_x = 830
    cfg.trans_x = 830
    cfg.trans_offset = {y=121}
    self.monster = UIModelCommonCamera(self.modelCon, nil, "model_sacredware_"..self.curRes)
    self.monster:SetConfig(cfg)
end