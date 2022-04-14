---
---Author: wry
---Date: 2019/9/16 17:48:27
---

StigmataPanel = StigmataPanel or class('StigmataPanel', BaseBagPanel)
local this = StigmataPanel

local panelObjList = {} --界面显示集合 左侧7个圣痕位置上的UI相关组件列表

local canSetPos = {}    --可以进行设置的空位 

local dbPos = {}    --圣痕位置的表格数据 记录位置id和开放等级

function StigmataPanel:ctor(parent_node,layer)
    self.abName = 'bag'
    self.assetName = 'StigmataPanel'
    self.layer = layer
    self.bagId = BagModel.Stigmata

    self.stigmataEvents = self.stigmataEvents or {}

    panelObjList = {}
    canSetPos = {}
    dbPos = {}

    self.putOnSoulItemList = {}  --左侧圣痕面板7个空位的Item列表

    self.controller = StigmataController:GetInstance()
    self.stigmataModel = StigmataModel:GetInstance()

    BagModel.Instance.stigmataCellCount = Config.db_bag[BagModel.Stigmata].cap

    dbPos = Config.db_soul_pos

    self.stigmataCompoundPanel = nil
    self.panelType = {stigmata = 1,stigmataCompound = 2}  --面板类型
    self.cur_panelType = nil  --当前面板类型
    self.sel_tab = {}  --上方页签的选中ui
    self.nosel_tab = {}  --上方页签的未选中ui
    self.text_tab = {} --上方页签的文本
    self.jumpItemSettor = nil

    self.reddot = nil
    self.is_have_can_puton = false
    self.is_hava_can_levelup = false

    --左侧孔位红点列表
    self.panel_reddot = {}

    self.jump_item_id = nil

    StigmataPanel.super.Load(self)
end

function StigmataPanel:dctor()

    StigmataPanel.super.dctor(self)


    for k,v in pairs(self.stigmataEvents) do
        self.stigmataModel:RemoveListener(v)

    end
    self.stigmataEvents = {}

  

    for i, v in pairs(self.putOnSoulItemList) do
        v:destroy()
    end
    self.putOnSoulItemList = {}

    panelObjList = {}
    canSetPos = {}
    dbPos = {}

    self.stigmataModel:Reset()

    self.controller = nil
    self.stigmataModel = nil

    if self.stigmataCompoundPanel then
        self.stigmataCompoundPanel:destroy()
        self.stigmataCompoundPanel= nil
    end

    self.sel_tab = nil
    self.nosel_tab = nil
    self.text_tab = nil

    if self.jumpItemSettor then
        self.jumpItemSettor:destroy()
        self.jumpItemSettor = nil
    end

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end

    for k,v in pairs(self.panel_reddot) do
        if v then
           v:destroy()
        end
    end
    self.panel_reddot = nil
end

function StigmataPanel:LoadCallBack()
   -- StigmataPanel.super.LoadCallBack(self)

    self.controller:RequestSoulList()

    self.nodes = {
        "stigmata/embed/slots/card_slot_1","stigmata/embed/slots/card_slot_2","stigmata/embed/slots/card_slot_3","stigmata/embed/slots/card_slot_4","stigmata/embed/slots/card_slot_5","stigmata/embed/slots/card_slot_6","stigmata/embed/slots/card_slot_7",
        "stigmata/embed/slots/card_slot_1/lock_1","stigmata/embed/slots/card_slot_2/lock_2","stigmata/embed/slots/card_slot_3/lock_3","stigmata/embed/slots/card_slot_4/lock_4","stigmata/embed/slots/card_slot_5/lock_5","stigmata/embed/slots/card_slot_6/lock_6","stigmata/embed/slots/card_slot_7/lock_7",
        "stigmata/embed/slots/card_slot_1/soul_1","stigmata/embed/slots/card_slot_2/soul_2","stigmata/embed/slots/card_slot_3/soul_3","stigmata/embed/slots/card_slot_4/soul_4","stigmata/embed/slots/card_slot_5/soul_5","stigmata/embed/slots/card_slot_6/soul_6","stigmata/embed/slots/card_slot_7/soul_7",
        "stigmata/embed/slots/card_slot_1/stigmata_1","stigmata/embed/slots/card_slot_2/stigmata_2","stigmata/embed/slots/card_slot_3/stigmata_3","stigmata/embed/slots/card_slot_4/stigmata_4","stigmata/embed/slots/card_slot_5/stigmata_5","stigmata/embed/slots/card_slot_6/stigmata_6","stigmata/embed/slots/card_slot_7/stigmata_7",
        "stigmata/embed/slots/card_slot_1/level_1","stigmata/embed/slots/card_slot_2/level_2","stigmata/embed/slots/card_slot_3/level_3","stigmata/embed/slots/card_slot_4/level_4","stigmata/embed/slots/card_slot_5/level_5","stigmata/embed/slots/card_slot_6/level_6","stigmata/embed/slots/card_slot_7/level_7",

        "stigmata/btnContain/CompoundBtn","stigmata/btnContain/CompoundBtn/CompoundBtnText",
        "stigmata/btnContain/ResolveBtn","stigmata/btnContain/ResolveBtn/ResolveBtnText",

        "stigmata/propertyBtn","stigmata/getBtn",
        "stigmata/SoulMessage",
        "stigmata/jumpPanel",
        --"stigmata/SoulMessage/message",
        "stigmata/SoulMessage/Scroll View/Viewport/message",
        "stigmata/SoulMessage/noPutOnMessage",
        "stigmata/jumpPanel/JumpContent",
        "stigmata/jumpPanel/txt_get",

        "stigmata/jumpPanel/btn_jump_close",
        "stigmata/btn_full_close",
        "stigmata/SoulMessage/btn_soulMessage_close",

        "stigmata/bg/cost1/cost1Img","stigmata/bg/cost2/cost2Img","stigmata/bg/cost3/cost3Img",
        "stigmata/bg/cost1/cost1Text","stigmata/bg/cost2/cost2Text","stigmata/bg/cost3/cost3Text",

        "stigmata/equipTipContainer",
		"stigmata/goodsTipContainer",
		"stigmata/ScrollView",
		"stigmata/ScrollView/Viewport/Content",
		"stigmata/btnContain",
		"stigmata/btnContain/ArrangeBtn",
		"stigmata/ScrollView/Viewport",

        "stigmata",

        "common/soulCompound",
        "common/soul",
        "common/soulCompound/img_soulCompound_nosel",
        "common/soul/img_soul_sel",
        "common/soulCompound/img_soulCompound_sel",
        "common/soul/img_soul_nosel",
        "common/soul/text_soul",
        "common/soulCompound/text_soulCompound",
    }
    self:GetChildren(self.nodes)


    self.cost1Text = GetText(self.cost1Text)
    self.cost2Text = GetText(self.cost2Text)
    self.cost3Text = GetText(self.cost3Text)

    self.message = GetText(self.message)

    self.text_soul = GetText(self.text_soul)
    self.text_soulCompound = GetText(self.text_soulCompound)

    self.txt_get = GetText(self.txt_get)

    local cellCount = Config.db_bag[BagModel.Stigmata].cap
    BagController.Instance:RequestBagInfo(BagModel.Stigmata)
    self:CreateItems(cellCount)

    self:GetPanelObj()

    self:AddEvent()
    self:AddBtnEvent()
    self:SetMask()
    self:SetLock()

    SetVisible(self.SoulMessage.gameObject,false)
    SetVisible(self.jumpPanel.gameObject,false)

    self.sel_tab = {self.img_soul_sel,self.img_soulCompound_sel}
    self.nosel_tab = {self.img_soul_nosel,self.img_soulCompound_nosel}
    self.text_tab = {self.text_soul,self.text_soulCompound}

    if self.jump_item_id then
        self:OpenStigmataCompound(self.jump_item_id)
    else
        self:ChangePanelType(self.panelType.stigmata)
    end

    
end

function StigmataPanel:AddEvent()
    StigmataPanel.super.AddEvent(self)
    self.events[#self.events+1] = self.model:AddListener(BagEvent.OpenCellView,handler(self,self.DealOpenCellView))
    self.events[#self.events+1] = self.model:AddListener(StigmataEvent.LoadStigmataItems,handler(self,self.LoadItems))
    self.events[#self.events+1] = self.model:AddListener(StigmataEvent.OpenStigmataCombine,handler(self,self.OpenStigmataCompound))

    --刷新玩家圣痕相关货币事件                  
    self.stigmataEvents[#self.stigmataEvents+1] = self.stigmataModel:AddListener(StigmataEvent.UpdatePlayerConstant,handler(self,self.SetPlayerConstant))
    
    --获取左侧圣痕数据事件
    self.stigmataEvents[#self.stigmataEvents+1] = self.stigmataModel:AddListener(StigmataEvent.GetStigmataPanelData, handler(self, self.GetPanelData))

    --取下圣痕事件
    self.stigmataEvents[#self.stigmataEvents+1] = self.stigmataModel:AddListener(StigmataEvent.PutOffStigmata, handler(self, self.PutOffSoul))

  
end

function StigmataPanel:OnEnable()

end

function StigmataPanel:OnDisable()
end

--开启圣痕背包新格子
function StigmataPanel:DealOpenCellView(bagWare,index)
    if self.bagId == bagWare then
        local openCellCount = BagModel:GetOpenCellCount(index,bagWare)
        if openCellCount > 0 then
            lua_panelMgr:GetPanelOrCreate(OpenBagInputPanel):Open(bagWare, openCellCount)
        end
    end
end

--创建背包格子回调
function StigmataPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function StigmataPanel:UpdateCellCB(itemCLS)

    itemCLS.bag = BagModel.Stigmata
    itemCLS.need_deal_quick_double_click = false
    if self.model.stigmataItems ~=nil then
        local itemBase = self.model.stigmataItems[itemCLS.__item_index]
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
                param["bind"] = false
                param["itemSize"] = {x=80, y=80}
                param["outTime"] = itemBase.etime
                param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
                param["quick_double_click_call_back"] = nil
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId

                --红点相关参数
                local reddot_tab = {}
                local canPutOn = false
                canPutOn = self.stigmataModel:ReturnCanSetPos(itemBase.id) ~= 0
               
                reddot_tab["Equip"] = canPutOn
                param["reddot_tab"] = reddot_tab

                --param["show_reddot"] = canPutOn

                --圣痕等级
                if itemBase.slot ~= 0 then
                    param["lv"] = itemBase.extra
                end
               
                --双属性圣痕 或者身上没有的属性 要有特效
                local soulCfg = Config.db_soul[itemBase.id]
                local basTable = String2Table(soulCfg.base)
                if #basTable > 1 or self.stigmataModel:SoulIsCanPutOnPlayer(itemBase.id) then
                    param["effect_id"] = 20429
                end

                itemCLS:UpdateItem(param)
            end

        else
            local param = {}
            param["bag"] = BagModel.Stigmata
            param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
            param["quick_double_click_call_back"] = nil
            param["model"] = self.model
            param["stencil_id"] = self.StencilId
            param["itemSize"] = {x=80, y=80}
            param["bind"] = false
            itemCLS:InitItem(param)
        end
    else
        local param = {}

        param["bag"] = BagModel.Stigmata
        param["get_item_cb"] = handler(self,self.GetWareItemDataByIndex)
        param["quick_double_click_call_back"] = nil
        param["model"] = self.model
        param["stencil_id"] = self.StencilId
        param["itemSize"] = {x=80, y=80}
        param["bind"] = false
        itemCLS:InitItem(param)
    end

    itemCLS:SetCellIsLock(BagModel.Stigmata)

end

function StigmataPanel:GetWareItemDataByIndex(index)
    return self.model:GetStigmataItemDataByIndex(index)
end

--获得左侧圣痕面板数据监听
--tData : 位置序号-圣痕数据
function StigmataPanel:GetPanelData(tData)
    self.stigmataModel:Brocast(StigmataEvent.UpdatePlayerConstant)

    self:ShowPlayerSoul()

    self:UpdateSoulMessage()
end

--取下圣痕监听
--tData : 位置序号-圣痕数据
function StigmataPanel:PutOffSoul(tData)
    
end

--展示玩家圣痕货币监听
function StigmataPanel:SetPlayerConstant()
    self.cost1Text.text = RoleInfoModel.GetInstance():GetRoleValue(90010022)
    self.cost2Text.text = RoleInfoModel.GetInstance():GetRoleValue(90010023)
    self.cost3Text.text = RoleInfoModel.GetInstance():GetRoleValue(90010024)
end

--获取左侧圣痕位置相关的UI组件
function StigmataPanel:GetPanelObj()


    local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()

    for i = 1, 7 do
        local data = {}
        data.pos = self["card_slot_"..i]
        data.soul = self["soul_"..i]
        data.lock = GetImage(self["lock_"..i])

        data.soulName = GetText(self["stigmata_"..i])
        data.soulLv = GetText(self["level_"..i])

        table.insert(panelObjList,data)

        local index = i
        AddClickEvent(data.soul.gameObject,function()

            local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()
            if dbPos[index].level > playerLV then
                --提示解锁等级
                local message = "Slot"..dbPos[index].level.."Unlocks at L.X"
                Notify.ShowText(message)
                return
            end
            
            if data.canPutOn then
                Notify.ShowText("You can socket 1 stigmata")
            end

        end)
    end
end

--卸下圣痕
function StigmataPanel:TakeOffSoul(param)
    self.controller:RequestSoulPutOff(param[1])
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--升级圣痕
function StigmataPanel:LevelUpSoul(param)
    self.controller:OpenStigmataLevelUpPanel(param)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--凝聚圣痕(单属性圣痕)
function StigmataPanel:CohesionSoul(param)
    local itemcfg = Config.db_item[param[1].id]
    OpenLink(unpack(String2Table(itemcfg.jump)))

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--进阶圣痕(双属性圣痕)
function StigmataPanel:MoveUpSoul(param)
    
    local itemcfg = Config.db_item[param[1].id]
    OpenLink(unpack(String2Table(itemcfg.jump)))

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--跳转圣痕合成界面
function StigmataPanel:OpenStigmataCompound(item_id)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    
    if not self.is_loaded then
        self.jump_item_id = item_id
    else
        self:ChangePanelType(self.panelType.stigmataCompound)
        self.stigmataCompoundPanel:ToTargetItem(item_id)
    end
   

end


--分解圣痕
function StigmataPanel:DecomposeSoul(param)
    self.controller:DecomposeSoul(param)
end

--拆解圣痕
function StigmataPanel:DismantleSoul(param)
    self.controller:DismantleSoul(param)
end

--返回左侧圣痕Item的参数 用于Item.SetIcon
function StigmataPanel:ReturnSoulItemParam(tData,index)
    local operate_param = {}
    local attr_type = StigmataModel.GetInstance():ReturnSoulItemAttr_Type(Config.db_soul[tData.id])

    GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOffSoul), { index })


    if tData.extra < 50 then
        GoodsTipController.Instance:SetLevelUpCB(operate_param, handler(self, self.LevelUpSoul), { index })
    end
  

    if #attr_type < 2 then

        if self.stigmataModel:GetCanJump(tData.id) and  Config.db_item[tData.id].color >= 4  then
            GoodsTipController.Instance:SetCohesionCB(operate_param, handler(self, self.CohesionSoul), { tData })
        end
     
    else
        if self.stigmataModel:GetCanJump(tData.id) then
            GoodsTipController.Instance:SetMoveUpCB(operate_param, handler(self, self.MoveUpSoul), { tData })
        end
        
        GoodsTipController.Instance:SetDismantleCB(operate_param, handler(self, self.DismantleSoul), { tData })
    end

    local param = {}
    local num = tData.num
    param["model"] = self.model
    param["item_id"] = tData.id
    param["num"] = num
    param["can_click"] = true
    param["bind"] = false
    param["show_noput"] = true
    param["operate_param"] = operate_param

    param["p_item"] = tData

    --红点相关参数
    local reddot_tab = {}
    local canLvUp = self.stigmataModel:GetCanTargetStigmataLevelUp(tData)
    reddot_tab["Upgrade"] = canLvUp
    param["reddot_tab"] = reddot_tab
    param["show_reddot"] = canLvUp

    if canLvUp then
        --可升级红点
        self.is_hava_can_levelup = true
    end
   

    --双击卸下已佩戴圣痕
    function callback(  )
        self:TakeOffSoul({index})
    end
    param["quick_double_click_call_back"] = callback

    --隐藏品质背景框
    param["is_hide_quatily"] = true

    --隐藏锁定图标
    param["is_hide_bind"]  = true
    return param
end

--在圣痕位置刷新item
function StigmataPanel:UpdatePlayerSoulItem(tData,index)

    local param = self:ReturnSoulItemParam(tData,index)

    self.putOnSoulItemList[index] = self.putOnSoulItemList[index] or GoodsIconSettorTwo(panelObjList[index].soul)
    self.putOnSoulItemList[index].need_deal_quick_double_click = true
    self.putOnSoulItemList[index]:SetIcon(param)

end

--设置左侧圣痕位置的锁状态
function StigmataPanel:SetLock()
   local playerLV = RoleInfoModel:GetInstance():GetMainRoleLevel()

    for i = 1, #dbPos do
        if dbPos[i].level > playerLV then
            self:SetSoulItem(i,true,false,"",dbPos[i].level.."Unlocks at L.X",99)--,"bag_image","soul_lock")
        else
            self:SetSoulItem(i,false,false,"","",99)

        end
    end
end

--展示玩家左侧装备的圣痕
function StigmataPanel:ShowPlayerSoul()
    self:SetLock()

    self.is_hava_can_levelup = false

    if self.stigmataModel.mainPanelData == nil or table.nums(self.stigmataModel.mainPanelData) == 0 then
        self:UpdateReddot()
        return
    end

    for i, v in pairs(self.stigmataModel.mainPanelData) do

        self:UpdatePlayerSoulItem(v,i)

        local soulConfig = Config.db_soul[v.id]
        local colorNum = Config.db_item[v.id].color

        self:SetSoulItem(i,false,true,"LV."..v.extra,soulConfig.name,colorNum)--,abName,assetName)
    end

    --刷新红点
    self:UpdateReddot()
end

------设置单个圣痕
---index列表中的位置
---isLock是否有锁
---isOnSoul是否装备圣痕
---soulLv圣痕等级-没装备为nil
---soulName当前的名字显示信息
---isShowSoulImage是否显示Image-锁和装配都要显示
---abName
---assetName
function StigmataPanel:SetSoulItem(index,isLock,isOnSoul,soulLv,soulName,colorNum)

    if self.putOnSoulItemList[index] then
        SetVisible(self.putOnSoulItemList[index].transform,isOnSoul)
    end
    
    SetVisible(panelObjList[index].soulLv.gameObject,isOnSoul)
    panelObjList[index].soulLv.text = soulLv
    
    SetVisible(panelObjList[index].lock.gameObject, isLock)

    local color = ColorUtil.GetColor(colorNum)
    panelObjList[index].soulName.text = string.format("<color=#%s>%s</color>",color,soulName)

    --左侧孔位的可佩带红点
    local canPutOn = self.stigmataModel:HavaCanPutOnToTargetPos(index)
    panelObjList[index].canPutOn = canPutOn
    if not canPutOn and not self.panel_reddot[index] then
        return
    end

    local reddot = self.panel_reddot[index] or RedDot(panelObjList[index].pos)
    self.panel_reddot[index] = reddot
    SetLocalPositionZ(reddot.transform,0)
    SetAnchoredPosition(reddot.transform,34.5,35.1)
    SetVisible(reddot.transform,canPutOn)
end

--添加按钮方法
function StigmataPanel:AddBtnEvent()

    --合成按钮
    local function CompoundCall_back()
        self:ChangePanelType(self.panelType.stigmataCompound)
    end
    AddClickEvent(self.CompoundBtn.gameObject,CompoundCall_back)

    --分解按钮
    local function ResolveBtnCall_back()
        self.controller.isOpenSellPanel = true
        self.controller:RequestGetSetSoulDecompose()
    end
    AddClickEvent(self.ResolveBtn.gameObject,ResolveBtnCall_back)

    --圣痕页签
    local function soul_callback(  )
        self:ChangePanelType(self.panelType.stigmata)
    end
    AddClickEvent(self.soul.gameObject,soul_callback)

    --圣痕合成页签
    local function soulCompound_callback(  )
        self:ChangePanelType(self.panelType.stigmataCompound)
    end
    AddClickEvent(self.soulCompound.gameObject,soulCompound_callback)

    --圣痕属性
    local function soulMessage_callback(  )
--[[         SetVisible(self.SoulMessage,true)
        SetVisible(self.btn_full_close,true) ]]

        SetVisible(self.SoulMessage,not self.SoulMessage.gameObject.activeInHierarchy)
        SetVisible(self.btn_full_close,self.jumpPanel.gameObject.activeInHierarchy or self.SoulMessage.gameObject.activeInHierarchy)

        self:UpdateSoulMessage()
        
    end

    AddClickEvent(self.propertyBtn.gameObject,soulMessage_callback)

    --获取途径
    local function jumpPanel_callback(  )
        SetVisible(self.jumpPanel,not self.jumpPanel.gameObject.activeInHierarchy)
        SetVisible(self.btn_full_close,self.jumpPanel.gameObject.activeInHierarchy or self.SoulMessage.gameObject.activeInHierarchy)

        if not self.jumpItemSettor then
            self.jumpItemSettor = GoodsJumpItemSettor(self.JumpContent)

            self.jumpItemSettor:CreateJumpItems(ConfigLanguage.Soul.Jump, 0,ConfigLanguage.Soul.Icon)
            self.jumpItemSettor:SetGridPosX(79)
            self.txt_get.text = ConfigLanguage.Soul.Tip
        end
    end
    AddClickEvent(self.getBtn.gameObject,jumpPanel_callback)

    --圣痕属性面板关闭按钮
    local function soulMessageClose_callback()
        SetVisible(self.SoulMessage,false)
        SetVisible(self.btn_full_close,false)
    end
    AddButtonEvent(self.btn_soulMessage_close.gameObject,soulMessageClose_callback)

    --获取途径面板关闭按钮
    local function jumpClose_callback()
        SetVisible(self.jumpPanel,false)
        SetVisible(self.btn_full_close,false)
    end
    AddButtonEvent(self.btn_jump_close.gameObject,jumpClose_callback)

    --用来关闭圣痕属性与获取途径面板的底图
    local function jumpAndSoulMessageClose_callback(  )
        SetVisible(self.SoulMessage,false)
        SetVisible(self.jumpPanel,false)
        SetVisible(self.btn_full_close,false)
    end
    AddClickEvent(self.btn_full_close.gameObject,jumpAndSoulMessageClose_callback,0)
end

--切换界面类型
function StigmataPanel:ChangePanelType(panelType) 
    if not panelType or self.cur_panelType == panelType then
        return
    end

    for i=1,#self.sel_tab do
        if i == panelType then
            SetVisible(self.sel_tab[i],true)
            SetVisible(self.nosel_tab[i],false)
            SetColor(self.text_tab[i],133,132,176,255)
        else
            SetVisible(self.sel_tab[i],false)
            SetVisible(self.nosel_tab[i],true)
            SetColor(self.text_tab[i],255,255,255,255)
        end
       
    end

     self.cur_panelType = panelType

     if panelType == self.panelType.stigmata then
         --圣痕界面
        SetVisible(self.stigmata,true)

        if self.stigmataCompoundPanel then
            SetVisible(self.stigmataCompoundPanel.transform,false)
        end

     elseif panelType == self.panelType.stigmataCompound then
         -- 圣痕合成界面
         SetVisible(self.stigmata,false)
         if not self.stigmataCompoundPanel then
            self.stigmataCompoundPanel = StigmataCompoundPanel(self.transform,self.layer)
         end
         SetVisible(self.stigmataCompoundPanel.transform,true)
     end
end

--重写父类同名方法 
function StigmataPanel:LoadItems(bagWareId)

    StigmataPanel.super.LoadItems(self,bagWareId)

    --强制刷新scrollView 以刷新特效
    if self.scrollView ~= nil then
		self.scrollView:ForceUpdate()
    end
    
    --根据是否有可佩带圣痕刷新红点
    self.is_have_can_puton = self.stigmataModel:GetCanStigmataPutOn()
    self:UpdateReddot()
end

--刷新圣痕属性面板
function StigmataPanel:UpdateSoulMessage()

    if not self.SoulMessage.gameObject.activeInHierarchy then
        return
    end
    local data = self.stigmataModel.playerData

    local message = ""

    if table.nums(data) == 0 then
        message = ""
    else
        for i,v in ipairs(data) do
            local attrName = GetAttrNameByIndex(v[1])
            local value = v[2]
            if Config.db_attr_type[v[1]].type == 2 then
                --处理百分比属性
                value = (value/100).."%"
            end
    
            value = string.format("<color=#%s>+%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),value)
    
            message = message .. attrName .."："..value.."\n"
        end
    end

   

    self.message.text = message
    SetVisible(self.noPutOnMessage,message == "")
end


--刷新红点
function StigmataPanel:UpdateReddot()

    --不需要显示红点 并且没实例化过红点 那么不进行后续处理
    if not self.is_hava_can_levelup and not self.is_have_can_puton and not self.reddot then
        return
    end

    self.reddot  = self.reddot or RedDot(self.soul)
    SetVisible(self.reddot,self.is_hava_can_levelup or self.is_have_can_puton)
    SetLocalPositionZ(self.reddot.transform,0)
    SetAnchoredPosition(self.reddot.transform,64,24.5)
end

--设置跳转参数
function StigmataPanel:SetJumpParam(jump_param)
   if jump_param[2] == 2 then
       -- 跳转合成
       self:OpenStigmataCompound(jump_param[3])
   end
end