--
-- @Author: chk
-- @Date:   2018-08-24 15:40:24
--
BagRolePanel = BagRolePanel or class("BagRolePanel", BaseItem)
local BagRolePanel = BagRolePanel
local ConfigLanguage = require('game.config.language.CnLanguage');
function BagRolePanel:ctor(parent_node, layer)
    self.abName = "bag"
    self.assetName = "BagRolePanel"
    self.layer = layer

    self.model = BagModel:GetInstance()
    self.equipIconContain = {}
    self.equipIcons = {}
    self.equipOperation = {}
    self.roleInfoModel = RoleInfoModel:GetInstance():GetMainRoleData()
    self.UIRole = nil
    BagRolePanel.super.Load(self)
end

function BagRolePanel:dctor()
    BagRolePanel.super.dctor()
    if self.eventIdList ~= nil then
        for k, v in pairs(self.eventIdList) do
            self.model:RemoveListener(v)
        end
        self.eventIdList = nil
    end

    if self.globalEvents then
        for i, v in pairs(self.globalEvents) do
            GlobalEvent:RemoveListener(v)
        end
        self.globalEvents = nil
    end

    for i, v in pairs(self.equipIcons) do
        if v ~= nil then
            v:destroy()
        end
    end
    self.equipIcons = nil
    self.equipIconContain = nil

    if self.UIRole ~= nil then
        self.UIRole:destroy()
        self.UIRole = nil
    end
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
    EquipModel.GetInstance().hadRequestEquip = false
    self.model = nil
end

function BagRolePanel:LoadCallBack()
    self.nodes = {
        "EquipContainer/Left/equip_1006",
        "EquipContainer/Left/equip_1007",
        "EquipContainer/Left/equip_1008",
        "EquipContainer/Left/equip_1009",
        "EquipContainer/Left/equip_1010",
        "EquipContainer/Left/equip_1013",
        "EquipContainer/equip_1012",

        "EquipContainer/Right/equip_1001",
        "EquipContainer/Right/equip_1002",
        "EquipContainer/Right/equip_1003",
        "EquipContainer/Right/equip_1004",
        "EquipContainer/Right/equip_1005",
        "EquipContainer/Right/equip_1011",
        "roleInfoBg/LVName",
        "roleContainer",
        "roleInfoBg/careerIcon",
        "equipViewContainer",

        "allContent/star",
        "allContent/strength",
        "allContent/stone",
        "roleInfoBg/job",
        "roleInfoBg/VIP",
        "EquipContainer/Right/equip_1004/bg/Image_1004",
        "EquipContainer/Right/equip_1005/bg/Image_1005",
        "EquipContainer/Left/equip_1013/bg/Image_1013",
        "EquipContainer/Right/equip_1011/bg/Image_1011",
    }
    self:GetChildren(self.nodes)
    self:SetEquipIcons()
    self:SetEquipOperation()
    self:SetVIP()
    self:SetJob()
    self:AddEvent()
    self:AddRoleModel()
    self.model:Brocast(BagEvent.UpdateRoleLv)

    if not EquipModel.GetInstance().hadRequestEquip then
        EquipModel.GetInstance().hadRequestEquip = true
        EquipController.GetInstance():RequestEquipList()
    else
        self:LoadPutOnedEquip()
    end
end

function BagRolePanel:AddEvent()
    self.eventIdList = self.eventIdList or {}
    self.globalEvents = self.globalEvents or {}
    local function call_back(...)
        self:SetNameLV()
    end

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.DealGoodsDetailInfo))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EquipEvent.PutOnEquip, handler(self, self.DealPutOnEquip))
	self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(RoleInfoEvent.RoleReName,handler(self,self.RoleReName))
    self.eventIdList[#self.eventIdList + 1] = self.model:AddListener(BagEvent.UpdateRoleLv, call_back)

    local function call_back()
        if not OpenTipModel.Instance:IsOpenSystem(120, 1) then
            Notify.ShowText(ConfigLanguage.Mix.NotOpen)
        else
            GlobalEvent:Brocast(EquipEvent.ShowEquipUpPanel, nil, 1)
            GlobalEvent:Brocast(BagEvent.CloseBagPanel)
        end

    end
    AddClickEvent(self.strength.gameObject, call_back)

    local function call_back()
        -- Notify.ShowText(ConfigLanguage.Mix.NotOpen)
        GlobalEvent:Brocast(RoleInfoEvent.OpenRoleTitlePanel)
    end
    AddClickEvent(self.star.gameObject, call_back)

    local function call_back()
        if not OpenTipModel.Instance:IsOpenSystem(120, 1) then
            Notify.ShowText(ConfigLanguage.Mix.NotOpen)
        else
            GlobalEvent:Brocast(EquipEvent.ShowEquipUpPanel, nil, 2)
            GlobalEvent:Brocast(BagEvent.CloseBagPanel)

        end
    end
    AddClickEvent(self.stone.gameObject, call_back)

    local function call_back(target,x,y)

        --不直接打开寻宝，而是先打开一个提示框
        local function ok_func(  )
            GlobalEvent:Brocast(SearchTreasureEvent.OpenSearchPanel)
        end

        
    
       
        local data  = {}
        data.tip_type = 2

        data.message1 = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Orange),"Massive attack bonus")
        data.msg1_font_size = 24
        
        data.message2 = ConfigLanguage.BagRole.JumpST--提示文本路径
        
        data.ok_func = ok_func

        local data_param = {}

        
        local item_id = 11070515

        --判断手镯还是戒指
        if target.name == "Image_1005" then
           item_id = 11070415
        end

		data_param["item_id"] = item_id
        data_param["can_click"] = true;

        data.name= Config.db_item[item_id].name

        data.param = data_param

        lua_panelMgr:GetPanelOrCreate(ComIconTip):Open(data);
       
    end
    AddClickEvent(self.Image_1004.gameObject,call_back)
    AddClickEvent(self.Image_1005.gameObject,call_back)

    local function call_back(target,x,y)
        lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(2, 2, 11020143, true)
    end
    AddClickEvent(self.Image_1013.gameObject,call_back)

    local function call_back(target,x,y)
        lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(2, 2, 11020144, true)
    end
    AddClickEvent(self.Image_1011.gameObject,call_back)
end

function BagRolePanel:AddRoleModel()

    --local res_id = 11001
    --if self.roleInfoModel and self.roleInfoModel.gender then
    --	res_id = self.roleInfoModel.gender == 1 and 11001 or 12001
    --end
    --self.UIRole = UIRoleModel(self.roleContainer , handler(self , self.LoadModelCallBack),{res_id = res_id});

    local config = {}
    --config.trans_x = 630
    --config.trans_y = 630
    --config.trans_offset = {y=7.3}
    config.is_show_magic=true
    self.UIRole = UIRoleCamera(self.roleContainer, nil, self.roleInfoModel,nil,nil,nil,config)
end

function BagRolePanel:LoadModelCallBack()
    SetLocalPosition(self.UIRole.transform, -2135, -96, 501);--172.2
    SetLocalRotation(self.UIRole.transform, 170, -23.6, -7.7);
    --SetRotation(self.UIRole.transform,10,156.4,-1);
end

--处理装备(物品)详细信息
function BagRolePanel:DealGoodsDetailInfo(...)
    local param = { ... }
    local item = param[1]
    local equipConfig = Config.db_equip[item.id]
    if equipConfig == nil then
        return
    end
    local putOnedEquip = EquipModel.Instance.putOnedEquipList[equipConfig.slot]
    if putOnedEquip ~= nil and putOnedEquip.uid == item.uid and item.bag == 0 then
        local _equip = Config.db_equip[item.id]
        local key = "equip_" .. _equip.slot
        self.equipDetailView = EquipDetailView(self.equipIconContain[key])

        self.equipDetailView:UpdateInfo(item)
    end
end

-- equip   p_item_base
function BagRolePanel:DealPutOnEquip(slot, equip)
    -- local _equip = Config.db_equip[equip.id]
    local key = "equip_" .. slot
    if self.equipIcons[key] ~= nil then
        self.equipIcons[key]:destroy()
        self.equipIcons[key] = nil
    end

    self.equipIcons[key] = PutOnedIconSettor(GetChild(self.equipIconContain[key], "icon"), nil, "system", "PutOnedIcon")
    local onEquipDetail = EquipModel.Instance.putOnedEquipDetailList[slot]
    --if onEquipDetail == nil then
    --	self.equipIcons[key]:UpdateIconClick(equip)
    --else
    local param = {}
    --local operate_param = {}
    self.equipOperation[key] = {}
    if EquipModel.Instance:GetEquipCanStrongBySlot(slot) then
        GoodsTipController.Instance:SetStrongCB(self.equipOperation[key], handler(self, self.OpenStrongPanel), { onEquipDetail })

    end

    if EquipModel.Instance:GetEquipCanStoneBySlot(slot) then
        GoodsTipController.Instance:SetInlayCB(self.equipOperation[key], handler(self, self.OpenMountStonePanel), { onEquipDetail })
    end

    if slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY or slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
        GoodsTipController.Instance:SetTakeOffCB(self.equipOperation[key], handler(self, self.RequestTakeOff), { slot })
        if equip.etime < os.time() then
            GoodsTipController.Instance:SetValidateCB(self.equipOperation[key], handler(self, self.RequestValidate), { equip.uid, equip.id })
        end
    end

    param["cfg"] = Config.db_equip[equip.id]
    param["p_item"] = onEquipDetail
    param["can_click"] = true
    param["model"] = self.model
    param["operate_param"] = self.equipOperation[key]
    param["color_effect"] = 7
    param["show_noput"] = true
    if slot == enum.ITEM_STYPE.ITEM_STYPE_LOCK then
        param["is_hide_quatily"] = true
        param["size"] = {x=60, y=60}
    end

    self.equipIcons[key]:SetSlot(slot)
    self.equipIcons[key]:SetIcon(param)
    --end

end

function BagRolePanel:LoadPutOnedEquip()
    -- for i, v in pairs(EquipModel.Instance.putOnedEquipList) do
    -- 	GlobalEvent:Brocast(EquipEvent.PutOnEquip,v)
    -- end
end

function BagRolePanel:OpenStrongPanel(param)
    --UnpackLinkConfig("120@1@'true'")
    OpenLink(120, 1, 1, 'true')
    EquipStrongModel.GetInstance().select_equip = param[1]
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--打开宝石镶嵌界面
function BagRolePanel:OpenMountStonePanel(param)
    OpenLink(120, 1, 2, 'true')
    EquipStrongModel.GetInstance().select_equip = param[1]
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function BagRolePanel:RequestTakeOff(param)
    EquipController.Instance:RequestPutOff(param[1])
end

function BagRolePanel:RequestValidate(param)
    GlobalEvent:Brocast(ShopEvent.OpenBuyFairyPanel, param[1], param[2])
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

function BagRolePanel:SetEquipOperation()
    self.equipOperation["equip_1001"] = {}
    self.equipOperation["equip_1002"] = {}
    self.equipOperation["equip_1003"] = {}
    self.equipOperation["equip_1004"] = {}
    self.equipOperation["equip_1005"] = {}
    self.equipOperation["equip_1006"] = {}
    self.equipOperation["equip_1007"] = {}
    self.equipOperation["equip_1008"] = {}
    self.equipOperation["equip_1009"] = {}
    self.equipOperation["equip_1010"] = {}
    self.equipOperation["equip_1011"] = {}
    self.equipOperation["equip_1013"] = {}
    self.equipOperation["equip_1012"] = {}
end

function BagRolePanel:SetEquipIcons()
    self.equipIconContain["equip_1001"] = self.equip_1001
    self.equipIconContain["equip_1002"] = self.equip_1002
    self.equipIconContain["equip_1003"] = self.equip_1003
    self.equipIconContain["equip_1004"] = self.equip_1004
    self.equipIconContain["equip_1005"] = self.equip_1005
    self.equipIconContain["equip_1006"] = self.equip_1006
    self.equipIconContain["equip_1007"] = self.equip_1007
    self.equipIconContain["equip_1008"] = self.equip_1008
    self.equipIconContain["equip_1009"] = self.equip_1009
    self.equipIconContain["equip_1010"] = self.equip_1010
    self.equipIconContain["equip_1011"] = self.equip_1011
    self.equipIconContain["equip_1013"] = self.equip_1013
    self.equipIconContain["equip_1012"] = self.equip_1012

end

function BagRolePanel:SetNameLV()
    self.LVName:GetComponent('Text').text = self.roleInfoModel.name
    if  not self.lv_item then
        self.lv_item = LevelShowItem(self.careerIcon)
        self.lv_item:SetData(19, nil, "FFFFFF")
    end
end

function BagRolePanel:SetJob()
    local mainrole_data = self.roleInfoModel
    if mainrole_data then
        self.jobTex = GetText(self.job);
        self.jobOutline = self.job:GetComponent('Outline')
        local job_level = mainrole_data.figure.jobtitle and mainrole_data.figure.jobtitle.model
        local config = Config.db_jobtitle[job_level]
        if config then
            self.jobTex.text = config.name
            local r, g, b, a = HtmlColorStringToColor(config.color)
            SetOutLineColor(self.jobOutline, r, g, b, a)
        else
            self.jobTex.text = "";
        end
    end
end

function BagRolePanel:SetVIP()
    self.VIP:GetComponent('Text').text = "V" .. self.roleInfoModel.viplv
end

function BagRolePanel:SetData(data)

end

function BagRolePanel:RoleReName(name)
	self.LVName:GetComponent('Text').text = name
end
