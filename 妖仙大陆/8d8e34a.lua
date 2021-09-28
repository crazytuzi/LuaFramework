local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local VSAPI = require "Zeus.Model.VS"
local Item = require "Zeus.Model.Item"
local ItemDetail = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local ItemModel = require 'Zeus.Model.Item'
local BloodSoulAPI = require "Zeus.Model.BloodSoul"

local self = {}

local nameColorIndex = {3,2,1,4,0}

local function InitUI()
    local UIName = {
    	"btn_close",
        "tbt_property",
        "tbt_title",
        "tbt_blood",
        "tbt_strg",
        "tbt_inlay",
        "cvs_content",
        "cvs_frame",
        "cvs_tab2",
    }
    self.mainUI = self.mainUI or {}
    for i = 1, #UIName do
        self.mainUI[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

local function UpdateBloodPos(self, node, data)
    local cvs_icon = node:FindChildByEditName('cvs_icon',true)
    cvs_icon.Visible = data ~= nil
    cvs_icon.Enable = false

    local itemshow
    if data ~= nil then
        local static_data = ItemModel.GetItemStaticDataByCode(data.Code)
        Util.HZSetImage(cvs_icon,"static_n/item/" .. static_data.Icon .. ".png", false, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
    
        itemshow = Util.ShowItemShow(node, static_data.Icon, static_data.Qcolor)
        itemshow.Visible = false
    end

    node.TouchClick = function ()
        if data ~= nil then
            local ib_choice = node:FindChildByEditName('ib_choice0',true)
            local detail = ItemModel.GetItemDetailByCode(data.Code)
            local menu,obj = Util.ShowItemDetailTips(itemshow,detail)
            obj:setCloseCallback(function ()
                if ib_choice then
                    ib_choice.Visible = false
                end
            end)
            ib_choice.Visible = true
        end
    end
end

local function RefreshBloosList(self, itemList)
    for i=1, 12 do
        local data = nil
        local cvs_pos = self.BloodUI:FindChildByEditName('cvs_temp'..i,true)
        for _,v in ipairs(itemList) do
            if i == v.SortID3  then
               data = v
            end
        end
        UpdateBloodPos(self, cvs_pos, data)
    end
end

local function setCompareInfo(self,tbl)
    local num = self.mapName["Phy"]
    num = num~=nil and num or 0
    local phyNum = num
    num = self.mapName["Mag"]
    num = num~=nil and num or 0
    local magNum = num

    if magNum > phyNum then
        tbl.lb_attk1.Visible = false
        tbl.lb_attk2.Visible = true
        tbl.lb_attk_num.Text = tostring(self.mapName["Mag"])

        tbl.lb_phydefign_num.Visible = false
        tbl.lb_magdefign_num.Visible = true
        tbl.lb_phydef_ignore.Visible = false
        tbl.lb_magdef_ignore.Visible = true
        tbl.lb_def_ignore_per.Visible = false
        tbl.lb_resist_ignore_per.Visible = true
        tbl.lb_ignore_pernum.Text = tostring(self.mapName["IgnoreResistPer"]/100) .. "%"
    else
        tbl.lb_attk1.Visible = true
        tbl.lb_attk2.Visible = false
        tbl.lb_attk_num.Text = tostring(self.mapName["Phy"])

        tbl.lb_phydefign_num.Visible = true
        tbl.lb_magdefign_num.Visible = false
        tbl.lb_phydef_ignore.Visible = true
        tbl.lb_magdef_ignore.Visible = false
        tbl.lb_def_ignore_per.Visible = true
        tbl.lb_resist_ignore_per.Visible = false
        tbl.lb_ignore_pernum.Text = tostring(self.mapName["IgnoreAcPer"]/100) .. "%"
    end


    tbl.lb_crit_num.Text = tostring(self.mapName["Crit"])
    tbl.lb_hit_num.Text = tostring(self.mapName["Hit"])
    tbl.lb_critharm_num.Text = tostring(self.mapName["CritDamage"]/100) .. "%" 
    tbl.lb_phydefign_num.Text = tostring(self.mapName["IgnoreAc"])
    tbl.lb_skillharm_num.Text = "0%"
    tbl.lb_magdefign_num.Text = tostring(self.mapName["IgnoreResist"])
    tbl.lb_skillcdres_num.Text = tostring(self.mapName["SkillCD"]/100) .. "%"
    tbl.lb_hp_num.Text = tostring(self.mapName["MaxHP"])
    tbl.lb_critres_num.Text = tostring(self.mapName["ResCrit"])
    tbl.lb_dod_num.Text = tostring(self.mapName["Dodge"])
    tbl.lb_critharmres_num.Text = tostring(self.mapName["CritDamageRes"]/100) .. "%"
    tbl.lb_phydef_num.Text = tostring(self.mapName["Ac"])
    tbl.lb_magdef_num.Text = tostring(self.mapName["Resist"])
    tbl.lb_controlres_num.Text = tostring(self.mapName["CtrlTimeReduce"]/100) .. "%"
    tbl.lb_damres_num.Text = tostring(self.mapName["AllDamageReduce"]/100) .. "%"
    tbl.lb_hprec_num.Text = tostring(self.mapName["HitLeechHP"])

    tbl.lb_extrahit_num.Text = tostring(self.mapName["HitRate"]/100) .. "%"
    tbl.lb_extracrith_num.Text = tostring(self.mapName["CritRate"]/100) .. "%"
    tbl.lb_extradod_num.Text = tostring(self.mapName["DodgeRate"]/100) .. "%"
    tbl.lb_critres_num.Text = tostring(self.mapName["ResCritRate"]/100) .. "%"
    tbl.lb_injuryref_num.Text = tostring(self.mapName["PhyDamageReduce"]/100) .. "%"
    tbl.lb_magreduce_num.Text = tostring(self.mapName["MagicDamageReduce"]/100) .. "%"
    tbl.lb_hpregen_num.Text = tostring(self.mapName["HPRegen"])
    tbl.lb_resstun_num.Text = tostring(self.mapName["ResStun"]/100) .. "%"
    tbl.lb_resdurance_num.Text = tostring(self.mapName["ResDurance"]/100) .. "%"
    tbl.lb_restaunt_num.Text = tostring(self.mapName["ResTaunt"]/100) .. "%"
    tbl.lb_resslowdown_num.Text = tostring(self.mapName["ResSlowDown"]/100) .. "%"
    tbl.lb_allresctrl_num.Text = tostring(self.mapName["AllResCtrl"]/100) .. "%"

end

local ui_names = {
    {name = "lb_qufu1"},
    {name = "lb_name"},
    {name = "lb_title",},
    {name = "cvs_title_click"},
    {name = "cvs_title_box"},
    {name = "lb_title_none"},
    {name = "cvs_equip"},
    {name = "cvs_cell1"},
    {name = "cvs_cell2"},
    {name = "cvs_cell3"},
    {name = "cvs_cell4"},
    {name = "cvs_cell5"},
    {name = "cvs_cell6"},
    {name = "cvs_cell7"},
    {name = "cvs_cell8"},
    {name = "cvs_cell9"},
    {name = "cvs_cell10"},
    {name = "cvs_3d"},
    {name = "lb_FC"},
    {name = "ib_xm_icon"},
    {name = "lb_xm_name"},
    {name = "lb_xm_posname"},
    {name = "gg_hp"},
    {name = "lb_hp_num"},
    {name = "lb_exp"},
    {name = "gg_exp"},
    {name = "lb_exp_num"},
    {name = "lb_lv_num"},
    {name = "lb_Glv_num"},
    {name = "lb_state_num"},
    {name = "btn_gantanhao",click = function(self)

    end},
    {name = "btn_tupo"},
    {name = "sp_redpoint_Level"},
    {name = "btn_duihuan"},
    {name = "btn_morepro",click = function(self)
        
    end},
    {name = "btn_morepro1",click = function(self)
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttributeMain)
        

        setCompareInfo(self,lua_obj)
    end},
    {name = "btn_compare1",click = function(self)
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSAttribute)
        obj:setData(self.data)
    end},
    {name = "lb_attk1"},
    {name = "lb_attk2"},
    {name = "lb_attk_num"},
    {name = "lb_hit_num"},
    {name = "lb_crit_num"},
    {name = "lb_dod_num"},
    {name = "lb_critres_num"},
    {name = "lb_pyhdef_num"},
    {name = "lb_magdef_num"},
    {name = "lb_critharm_num"},
    {name = "lb_critharmres_num"},
    {name = "cvs_property",click = function (self)
        
    end},
    {name = "cvs_character"},
    {name = "cvs_title"},
    {name = "cvs_information_detailed"},
    {name = "cvs_information_detailed1"},
    {name = "cvs_pro1"},
    {name = "cvs_pro1_none"},
    {name = "cvs_pro2"},
    {name = "cvs_pro3"},
    {name = "cvs_pro4"},
    {name = "lb_pk"},
    {name = "tbx_pk"},
    {name = "btn_pk"},
    {name = "lb_titlename"},
    {name = "btn_fashion"},
}

local blood_ui_names = {
    {name = "lb_qufu1"},
    {name = "lb_name"},
    {name = "lb_title",},
    {name = "cvs_title_click"},
    {name = "cvs_title_box"},
    {name = "lb_title_none"},
    {name = "cvs_equip"},
    {name = "cvs_cell1"},
    {name = "cvs_cell2"},
    {name = "cvs_cell3"},
    {name = "cvs_cell4"},
    {name = "cvs_cell5"},
    {name = "cvs_cell6"},
    {name = "cvs_cell7"},
    {name = "cvs_cell8"},
    {name = "cvs_cell9"},
    {name = "cvs_cell10"},
    {name = "cvs_3d"},
    {name = "lb_FC"},
    {name = "ib_xm_icon"},
    {name = "lb_xm_name"},
    {name = "lb_xm_posname"},
    {name = "gg_hp"},
    {name = "lb_hp_num"},
    {name = "lb_exp"},
    {name = "gg_exp"},
    {name = "lb_exp_num"},
    {name = "lb_lv_num"},
    {name = "lb_Glv_num"},
    {name = "lb_state_num"},
    {name = "btn_gantanhao",click = function(self)

    end},
    {name = "btn_tupo"},
    {name = "sp_redpoint_Level"},
    {name = "btn_duihuan"},
    {name = "btn_morepro",click = function(self)
        
    end},
    {name = "btn_morepro1",click = function(self)
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttributeMain)
        

        setCompareInfo(self,lua_obj)
    end},
    {name = "btn_compare1",click = function(self)
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSAttribute)
        obj:setData(self.data)
    end},
    {name = "lb_attk1"},
    {name = "lb_attk2"},
    {name = "lb_attk_num"},
    {name = "lb_hit_num"},
    {name = "lb_crit_num"},
    {name = "lb_dod_num"},
    {name = "lb_critres_num"},
    {name = "lb_pyhdef_num"},
    {name = "lb_magdef_num"},
    {name = "lb_critharm_num"},
    {name = "lb_critharmres_num"},
    {name = "cvs_property",click = function (self)
        
    end},
    {name = "cvs_character"},
    {name = "cvs_title"},
    {name = "cvs_information_detailed"},
    {name = "cvs_information_detailed1"},
    {name = "cvs_pro1"},
    {name = "cvs_pro1_none"},
    {name = "cvs_pro2"},
    {name = "cvs_pro3"},
    {name = "cvs_pro4"},
    {name = "lb_pk"},
    {name = "tbx_pk"},
    {name = "btn_pk"},
    {name = "lb_titlename"},
    {name = "btn_fashion"},
}












local equipuinames = {
    cvs_cell1 = 1,
    cvs_cell2 = 2,
    cvs_cell3 = 3,
    cvs_cell4 = 4,
    cvs_cell5 = 5,
    cvs_cell6 = 6,
    cvs_cell7 = 7,
    cvs_cell8 = 8,
    cvs_cell9 = 9,
    cvs_cell10 = 10,
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function clearAvatarObj(self)
    if self.avatarObj then
        IconGenerator.instance:ReleaseTexture(self.avatarKey)
        UnityEngine.Object.DestroyObject(self.avatarObj)
        self.avatarObj = nil
        self.avatarKey = nil
    end
end

local function showAvatar(self)
    clearAvatarObj(self)
    local list = ListXmdsAvatarInfo.New()
    for i,v in ipairs(self.data.avatars) do
        local info = XmdsAvatarInfo.New()
        GameUtil.setXmdsAvatarInfoTag(info, v.tag)
        
        info.FileName = v.fileName
        info.EffectType = v.effectType
        list:Add(info)
    end

    local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
    self.avatarObj, self.avatarKey = GameUtil.Add3DModel(self.cvs_3d, "", list, nil, filter, false)
    IconGenerator.instance:SetModelPos(self.avatarKey, Vector3.New(0, -0.98, 3.1))
    IconGenerator.instance:SetModelScale(self.avatarKey, Vector3.New(0.73, 1, 0.73))
    IconGenerator.instance:SetCameraParam(self.avatarKey, 0.3, 10, 2)

    IconGenerator.instance:SetLoadOKCallback(self.avatarKey, function (k)
        IconGenerator.instance:PlayUnitAnimation(self.avatarKey, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
        
    end)
    local t = {
        node = self.cvs_3d,
        move = function (sender,pointerEventData)
            IconGenerator.instance:SetRotate(self.avatarKey,-pointerEventData.delta.x * 5)
        end, 
        up = function() end
    }
    LuaUIBinding.HZPointerEventHandler(t)
    list = nil
end



local function setNormalInfo(self)
    self.btn_fashion.Visible = false

    if self.data.titleId > 0 then

        self.lb_title_none.Visible = false

        local rankListData = GlobalHooks.DB.Find("RankList", {RankID=self.data.titleId})[1]
   
        if rankListData~=nil then
           if rankListData.Show == "-1" then
              self.cvs_title_box.Visible =false
              self.lb_titlename.Visible = true
              self.lb_titlename.Text = rankListData.RankName
              self.lb_titlename.FontColorRGBA = Util.GetQualityColorRGBA(rankListData.RankQColor)
           else
              self.cvs_title_box.Visible = true
              self.lb_titlename.Visible = false
              local w = self.cvs_title_box.Width
              local h = self.cvs_title_box.Height
              Util.HZSetImage2(self.cvs_title_box, "#static_n/title_icon/title_icon.xml|title_icon|"..rankListData.Show, true, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER)
              self.cvs_title_box.Width = w
              self.cvs_title_box.Height = h
           end
        end

    else
        self.cvs_title_box.Visible = false
        self.lb_title_none.Visible = true
        self.lb_titlename.Visible = false
    end

    if self.data.pkValue then
        self.lb_pk.Visible = true
        self.tbx_pk.Visible = true
        self.btn_pk.Visible = false

        if self.data.pkValue <=0 then
            local text = "<f color='ff00A0FF' link='reward'>" .. self.data.pkValue .. "</f>"
            self.tbx_pk:DecodeAndUnderlineLink(text)
        else
            local text = "<f color='FFFF0000' link='reward'>" .. self.data.pkValue .. "</f>"
            self.tbx_pk:DecodeAndUnderlineLink(text)
        end
    else
        self.lb_pk.Visible = false
        self.tbx_pk.Visible = false
        self.btn_pk.Visible = false
    end

    self.lb_qufu1.Text = self.data.name
    self.lb_name.Text = GlobalHooks.DB.Find('Character',self.data.pro).ProName
    self.lb_name.FontColorRGBA = GameUtil.GetProColor(self.data.pro)
    
    self.cvs_title_click:FindChildByEditName("btn_change",false).Visible = false

    
    if self.data.guildName then
        self.cvs_pro1.Visible = true
        self.cvs_pro1_none.Visible = false
        local lb_xm_name = self.cvs_pro1:FindChildByEditName("lb_xm_name",false)
        local ib_xm_icon = self.cvs_pro1:FindChildByEditName("ib_xm_icon",false)
        local lb_xm_position = self.cvs_pro1:FindChildByEditName("lb_xm_position",false)
        local lb_xm_posname = self.cvs_pro1:FindChildByEditName("lb_xm_posname",false)
        
        lb_xm_name.Text =  self.data.guildName

        lb_xm_name.Visible = true
        ib_xm_icon.Visible = true
        lb_xm_position.Visible = true
        lb_xm_posname.Visible = true

        local filepath = 'static_n/guild/'..self.data.guildIcon..'.png'
        local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
        ib_xm_icon.Layout = layout

        lb_xm_posname.Text = Util.getGuildPosition(self.data.guildJob).position
        lb_xm_posname.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(nameColorIndex[self.data.guildJob]))
    else
        self.cvs_pro1.Visible = false
        self.cvs_pro1_none.Visible = true
        local lb_xm_name = self.cvs_pro1_none:FindChildByEditName("lb_xm_name",false)
        lb_xm_name.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 124)
        lb_xm_name.Visible = true
    end
    
    self.lb_lv_num.Text = self.data.level
    
    
    
    local maxHP = self.mapName["MaxHP"]
    maxHP = maxHP ~= nil and maxHP or 0
    self.lb_hp_num.Text = maxHP
    self.gg_hp:SetGaugeMinMax(0, math.floor(maxHP))
    self.gg_hp.Value = maxHP 
    
    local maxExp = GlobalHooks.DB.Find('Character_Level', self.data.level).experience
    self.lb_exp_num.Text = tostring(self.data.exp) .. "/" .. tostring(maxExp)
    self.gg_exp:SetGaugeMinMax(0, math.floor(maxExp))
    self.gg_exp.Value = (self.data.exp < maxExp and self.data.exp) or maxExp

    local uporder = self.data.upOrder == nil and 0 or self.data.upOrder
    local curRealm = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = uporder})[1]

    if curRealm == nil then
        self.lb_state_num.Text = Util.GetText(TextConfig.Type.ATTRIBUTE,110)
    else
        self.lb_state_num.Text = curRealm.ClassName .. curRealm.UPName
        self.lb_state_num.FontColorRGBA = Util.GetQualityColorRGBA(curRealm.Qcolor)
    end

    self.btn_gantanhao.Visible = false
    self.btn_tupo.Visible = false
    self.sp_redpoint_Level.Visible = false
    self.btn_duihuan.Visible = false
    self.btn_morepro.Visible = false
    self.btn_morepro1.Visible = true
    self.btn_compare1.Visible = true
    self.lb_FC.Text = self.data.fightPower

end

local function setAttributeInfo(self)
    self.mapName = {}
    for _,v in ipairs(self.data.attrs or {}) do
        local attrName = GlobalHooks.DB.Find("Attribute", v.id).attKey
        
        self.mapName[attrName] = v.value
    end

    local attrs = GlobalHooks.DB.Find("Attribute", {})
    for _,v in ipairs(attrs) do
        if self.mapName[v.attKey] == nil then
            self.mapName[v.attKey] = 0
        end
    end

    local num = self.mapName["Phy"]
    num = num~=nil and num or 0
    local phyNum = num
    num = self.mapName["Mag"]
    num = num~=nil and num or 0
    local magNum = num

    if magNum > phyNum then
        self.lb_attk1.Visible = false
        self.lb_attk2.Visible = true
        self.lb_attk_num.Text = tostring(self.mapName["Mag"])
    else
        self.lb_attk1.Visible = true
        self.lb_attk2.Visible = false
        self.lb_attk_num.Text = tostring(self.mapName["Phy"])
    end

    self.lb_hit_num.Text = tostring(self.mapName["Hit"])
    self.lb_crit_num.Text = tostring(self.mapName["Crit"])
    self.lb_dod_num.Text = tostring(self.mapName["Dodge"])
    self.lb_critres_num.Text = tostring(self.mapName["ResCrit"])
    self.lb_pyhdef_num.Text = tostring(self.mapName["Ac"])
    self.lb_magdef_num.Text = tostring(self.mapName["Resist"])
    self.lb_critharm_num.Text = tostring(self.mapName["CritDamage"]/100) .. "%"
    self.lb_critharmres_num.Text = tostring(self.mapName["CritDamageRes"]/100) .. "%"
end

local format4 = '+ %d'

local function setEquipInfo(self)
    self.equipMap = {}
    local detail = nil
    for i,v in ipairs(self.data.equipments or {}) do
        detail = Item.GetItemDetailByCode(v.code)
        Item.SetDynamicAttrToItemDetail(detail, v)
        self.equipMap[detail.itemSecondType] = detail
    end


    local effectColor = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.Qcolor')
    local effectEnLv = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.StrengthenLevel')
    local effectPath = '@dynamic_n/effects/sign/sign.xml|sign|sign|0'
    for k,v in pairs(self.equipCanvaseMap) do
        
            detail = self.equipMap[k]
            local itemShow = self.itemShowMap[k]
            if itemShow then
                itemShow.Visible = detail ~= nil
            end
            local lb_lv = v:FindChildByEditName("lb_lv",true)
            local item = v:FindChildByEditName("item",true)
            local eff = v:FindChildByEditName("ib_effect",true)
            eff.Visible=false
            
            if detail then
                
                self.itemShowMap[k] = Util.ShowItemShow(item, detail.static.Icon, detail.static.Qcolor, 1)
                self.itemShowMap[k].StrengthenLv = detail.equip.enLevel
                
                if detail.equip.enLevel >= effectEnLv and detail.static.Qcolor >= effectColor then
                    self.itemShowMap[k].EffectPath = effectPath
                else
                    self.itemShowMap[k].EffectPath = ''
                end

                local itemIdConfigTypeId = ItemModel.GetSecondType(detail.static.Type)
                local strength_Pos = ItemModel.GetEquipStrgData(itemIdConfigTypeId,self.data.strengthPos) 
                
                if strength_Pos ~= nil then
                    
                    local strengthLv = strength_Pos.enLevel
                    local strengthSection = strength_Pos.enSection

                    local lv = string.format(format4, strengthSection*10+strengthLv)
                    lb_lv.Text = lv
                    lb_lv.Visible = true
                end

                local bind = false
                

                if detail.static.Qcolor == 4 then    
                    eff.Visible = true
                end


            else
                lb_lv.Visible = false
            end
    end
end


local function OnEnter()
    self.mainUI.tbt_property.IsChecked = true
end

local function cancelSelectEquip(self)
    self.cvs_information_detailed:RemoveAllChildren(true)
    self.cvs_information_detailed1:RemoveAllChildren(true)
    self.cvs_information_detailed1.Enable = false
    self.cvs_information_detailed.Enable = false
    for i=1,#self.itemShowMap do
        if self.itemShowMap[i]~= nil then
            self.itemShowMap[i].IsSelected = false
        end
    end
end

local function OnExit()
    clearAvatarObj(self)
    cancelSelectEquip(self)
end


local function OnFuncBtnChecked(self,sender)
    if sender == self.mainUI.tbt_property then
        if self.BloodUI then
            self.BloodUI.Visible = false
        end
        VSAPI.requestPlayerInfo(self.menu.ExtParam, function(data)
            if self.menu and self.menu.IsRunning then
                self.propertyUI.Visible = true
                self.data = data
                setAttributeInfo(self)
                setNormalInfo(self)
                showAvatar(self)
                setEquipInfo(self)
            end
        end,
        function()
            if self.menu and self.menu.IsRunning then
                self.menu:Close()
            end
        end)
    elseif sender == self.mainUI.tbt_blood then
        cancelSelectEquip(self)
        if self.propertyUI then
            self.propertyUI.Visible = false
        end
        if not self.BloodUI then
            self.BloodUI = XmdsUISystem.CreateFromFile('xmds_ui/character/see_blood.gui.xml')
            self.mainUI.cvs_content:AddChild(self.BloodUI)
        end
        BloodSoulAPI.GetEquipedBloodsRequest(self.menu.ExtParam, function(data)
            self.BloodUI.Visible = true
            RefreshBloosList(self, data)
        end)
    end
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/character/background.gui.xml',tag)
    InitUI()
    self.mainUI.tbt_property.Visible = true
    self.mainUI.tbt_blood.Visible = true
    self.mainUI.tbt_title.Visible = false
    self.mainUI.tbt_strg.Visible = false
    self.mainUI.tbt_inlay.Visible = false
    
    Util.InitMultiToggleButton( function(sender)
        OnFuncBtnChecked(self, sender)
    end , nil, {self.mainUI.tbt_property,self.mainUI.tbt_blood})

    self.propertyUI = XmdsUISystem.CreateFromFile('xmds_ui/character/property.gui.xml')

    self.mainUI.cvs_content:AddChild(self.propertyUI)
    initControls(self.propertyUI,ui_names,self)
    self.cvs_information_detailed.Enable = false
    self.cvs_information_detailed1.Enable = false

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.mainUI.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.equipCanvaseMap = {}
    self.itemShowMap = {}
    for i,v in pairs(equipuinames) do
        local canvase = self[i]
        self.equipCanvaseMap[v] = canvase
        local item = canvase:FindChildByEditName("item",true)
        item.TouchClick = function(sender)
            if self.itemShowMap[sender.UserTag]==nil or self.itemShowMap[sender.UserTag].IsSelected or self.equipMap[sender.UserTag] ==nil then
                return
            end
            cancelSelectEquip(self)

            if not self.equipMap then return end
            local equipType = sender.UserTag
            self.itemShowMap[equipType].IsSelected = true
            local compEquip = ItemDetail.CreateWithBagUI(0,self.cvs_information_detailed,
                {{title=Util.GetText(TextConfig.Type.ATTRIBUTE, 133),eventName="ttt",clickFunc = function(sender, name)
                    if self.cvs_information_detailed1.Enable then
                        self.cvs_information_detailed1.Enable = false
                        self.cvs_information_detailed1:RemoveAllChildren(true)
                    else
                        local data = ItemModel.GetLocalCompareDetail(self.equipMap[equipType].itemSecondType)
                        if data~=nil then
                            local compEquip1 = ItemDetail.CreateWithBagUI(0,self.cvs_information_detailed1)
                            compEquip1:setEquip(data)
                            compEquip1.equip.Visible = true
                            self.cvs_information_detailed1.Enable = true
                        else
                            GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.ATTRIBUTE, 125))
                        end
                    end
            end}})

            local itemIdConfigTypeId = ItemModel.GetSecondType(self.equipMap[equipType].static.Type)
            local strength_Pos = ItemModel.GetEquipStrgData(itemIdConfigTypeId,self.data.strengthPos) 
            compEquip:setEquip(self.equipMap[equipType],strength_Pos or {}, self.equipMap)
            compEquip.equip.Visible = true
            self.cvs_information_detailed.Enable = true
            
        end
        item.UserTag = v
    end

    
    
    
    
    

    self.cvs_pro1.EnableChildren = false
    self.cvs_pro2.EnableChildren = false
    self.cvs_pro3.EnableChildren = false
    self.cvs_pro4.EnableChildren = false
    self.cvs_title.EnableChildren = false
    self.cvs_pro1.TouchClick = function()
        cancelSelectEquip(self)
    end
    self.cvs_pro2.TouchClick = function()
        cancelSelectEquip(self)
    end
    self.cvs_pro3.TouchClick = function()
        cancelSelectEquip(self)
    end
    self.cvs_pro4.TouchClick = function()
        cancelSelectEquip(self)
    end
    
    
    
    self.cvs_title.TouchClick = function()
        cancelSelectEquip(self)
    end
    self.mainUI.cvs_tab2.TouchClick = function()
        cancelSelectEquip(self)
    end

    self.lb_exp.Visible = true
    self.gg_exp.Visible = true
    self.lb_exp_num.Visible = true

    return self.menu
end

function _M:Start(global)

end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
