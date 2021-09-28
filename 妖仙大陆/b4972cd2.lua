


local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local _M = {
    parent = nil,
    nodes = nil,
    selectIndex = nil
}
_M.__index = _M

local PosCount = 10 

local function GetEnchantBonusAttStr(EnchantBonusData)
    
    local attrdata = GlobalHooks.DB.Find('Attribute', { attName = EnchantBonusData.Prop })
    if #attrdata > 0 then
        local v =(attrdata[1].isFormat == 1 and EnchantBonusData.Min / 100) or EnchantBonusData.Min
        return string.gsub(attrdata[1].attDesc, '{A}', tostring(v))
    end
    return ""
end

local function SetSectionAttrItem(self, node, enBonus, curStrengthSection)
    local lb_wendaoLV = node:FindChildByEditName('lb_wendaoLV', false)
    local lb_pro = node:FindChildByEditName('lb_pro', false)
    local ib_suo = node:FindChildByEditName('ib_suo', false)
    local lb_have_get = node:FindChildByEditName('lb_have_get', false)

    lb_wendaoLV.Text = enBonus.EnClass*10 .. Util.GetText(TextConfig.Type.ATTRIBUTE, 141)
    ib_suo.Visible =(enBonus.EnClass > curStrengthSection)
    lb_have_get.Visible =(enBonus.EnClass <= curStrengthSection)
    lb_pro.Text = GetEnchantBonusAttStr(enBonus)
    if lb_have_get.Visible == true then
        
        lb_pro.FontColorRGBA = 0x00a0ffff
    else
        lb_pro.FontColorRGBA = 0x9aa9b5ff
    end
    

end

local ui_names = {
    { name = "sp_list" },
    { name = "cvs_equip_brief" },
    { name = "lb_equip_position" },
    { name = "lb_wenben" },
    { name = "lb_strLV" },
    { name = "lb_next_pro" },
    {
        name = "btn_morereward",
        click = function(self)
            self.cvs_more_attr.Visible = not self.cvs_more_attr.Visible
            local strengthPos = ItemModel.GetEquipStrgData(self.selectIndex)
            if strengthPos ~= nil then
                local strengthLv = strengthPos.enLevel
                local strengthSection = strengthPos.enSection
                local itemIdConfig = GlobalHooks.DB.Find('ItemIdConfig', self.selectIndex)
                local EBonusDatas = GlobalHooks.DB.Find('EnchantBonus', { Type = itemIdConfig.ItemType })
                local item_counts = #EBonusDatas
                self.sp_pro.Scrollable:ClearGrid()
                if self.sp_pro.Rows <= 0 then
                    self.sp_pro.Visible = true
                    local cs = self.cvs_strengthen_pro.Size2D
                    self.sp_pro:Initialize(cs.x, cs.y, item_counts, 1, self.cvs_strengthen_pro,
                    function(gx, gy, node)
                        local enBonus = EBonusDatas[gy + 1]
                        SetSectionAttrItem(self, node, enBonus, strengthSection)
                    end , function() end)
                else
                    self.sp_pro.Rows = item_counts
                end
            else
                self.cvs_more_attr.Visible = false
            end
        end
    },
    { name = "tb_basepro_num" },
    { name = "cvs_icon" },
    { name = "lb_name" },
    { name = "tb_equip_pro" },
    { name = "lb_equip_none" },
    { name = "cvs_material1" },
    { name = "cvs_material2" },
    { name = "cvs_material3" },
    {
        name = "btn_strengthen",
        click = function(self)
            OnClickStrengthen(self)
        end
    },

    { name = "cvs_more_attr" },
    { name = "sp_pro" },
    { name = "cvs_strengthen_pro" },
    {
        name = "btn_attr_close",
        click = function(self)
            self.cvs_more_attr.Visible = false
        end
    },

}
local string_item_name = "<color=#%s>%s</color>"
local format1 = '%s:%s'
local format2 = '%s:%s-%s'
local format3 = '<color=#00f012ff>+%s</color>'



local format7 = '%s <color=#00f012ff>+%s</color>'


local biLevelNow = 0
local biCostMat = ""

local function SetCostMoney(self, chantData)
    local lb_num = self.cvs_material3:FindChildByEditName('lb_mat_num', false)
    local btn_get = self.cvs_material3:FindChildByEditName('btn_mat_get', false)
    lb_num.Text = chantData.CostGold
    local mygold = ItemModel.GetGold()
    lb_num.FontColorRGBA =(mygold >= chantData.CostGold) and 0xffffffff or 0xff0000ff
    
    btn_get.Visible = false
end

local function UpdateRedPoint(self, node, index)
    local ib_ricon = node:FindChildByEditName('ib_ricon', false) 
    local strengthPos = ItemModel.GetEquipStrgData(index)
    local strengthLv = 0
    local strengthSection = 0
    if strengthPos ~= nil then
        strengthLv = strengthPos.enLevel
        strengthSection = strengthPos.enSection
    end

    local nextLevel = strengthSection*100+strengthLv + 1
    if strengthLv == 9 then
        nextLevel = (strengthSection +1)*100
    end
    local nextChantData = GlobalHooks.DB.Find('Enchant', nextLevel)
    if nextChantData == nil then
        ib_ricon.Visible = false
    else
        local mat1 = nextChantData.MateCode1
        local mat2 = nextChantData.MateCode2
        local num1 = nextChantData.MateCount1
        local num2 = nextChantData.MateCount2

        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem1 = bag_data:MergerTemplateItem(mat1)
        local vItem2 = bag_data:MergerTemplateItem(mat2)
        local haveNum1 = (vItem1 and vItem1.Num) or 0
        local haveNum2 = (vItem2 and vItem2.Num) or 0

        local needNum = nextChantData.CostGold
        local mygold = ItemModel.GetGold()
        ib_ricon.Visible = ((haveNum1 >= num1) and (haveNum2 >= num2) and (mygold >= needNum))
    end
end

function _M.Notify(status, userdata, self)
    if userdata == DataMgr.Instance.FlagPushData then
        if status == FlagPushData.FLAG_ACTOR_STRENGTH or status == FlagPushData.FLAG_ACTOR_INLAY then
           
        end 
    elseif userdata == DataMgr.Instance.UserData then
        if userdata:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
            if self.nextChantData then
                SetCostMoney(self, self.nextChantData)

                for k, v in pairs(self.nodes) do 
                    UpdateRedPoint(self,k,v)
                end
            end
        end
    end
end

local function getItemData(self, pos)
    local showdata = self.filter_target.ShowData
    for i = 1, showdata.Count do
        local itemData = self.filter_target:GetItemDataAt(i)
        if (itemData.SecondType == pos) then
            return itemData
        end
    end
    return false
end


local function initNodeValue(self, node, index)
    node.Name = 'equip'..tostring(index)
    local ctrlIcon = node:FindChildByEditName("cvs_equipicon", true)
    local itemData = getItemData(self, index)
    local lb_equipname = node:FindChildByEditName("lb_equipname", true)
    local lb_wenben = node:FindChildByEditName("lb_wenben", true)
    local ib_click = node:FindChildByEditName("ib_click", true)

    UpdateRedPoint(self,node,index) 

    if (index == self.selectIndex) then
        ib_click.Visible = true
    else
        ib_click.Visible = false
    end
    if self.itemShows[node] == nil then
        self.itemShows[node] = Util.ShowItemShow(ctrlIcon, "", 1)
    end

    if type(itemData) ~= "boolean" then
        self.itemShows[node]:SetItemData(itemData)
    end

    if(itemData == false) then
        local path = Util.GetText(TextConfig.Type.ITEM, 'equipBack' .. index)
        Util.HZSetImage(ctrlIcon, path)
    end
    local strengthPos = ItemModel.GetEquipStrgData(index)
    
    local strengthLv = 0
    local strengthSection = 0
    if strengthPos ~= nil then
        strengthLv = strengthPos.enLevel
        strengthSection = strengthPos.enSection
    end
    local c = Util.GetQualityColorRGBAStr(0)
    if (itemData) then
        c = Util.GetQualityColorRGBAStr(itemData.detail.static.Qcolor)


    else
        local c = Util.GetQualityColorRGBAStr(0)


        if self.itemShows[node] then
            self.itemShows[node]:SetItemData(nil)
        end
    end
    lb_equipname.Text = string.format(string_item_name, c, Util.GetText(TextConfig.Type.ITEM, 'equipPos' .. index))
    lb_wenben.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 119,strengthSection*10+strengthLv)
    node.Enable = true
    node.TouchClick = function()
        self.selectIndex = index
        self.item_click(false, itemData, true)
        for k, v in pairs(self.nodes) do
            if v then
                local ib_click = k:FindChildByEditName("ib_click", true)
                ib_click.Visible = false
            end
        end
        local ib_click = node:FindChildByEditName("ib_click", true)
        ib_click.Visible = true
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('buttonClick')
    end
    local ditu = GlobalHooks.DB.Find('EquipdituConfig',index)
    Util.HZSetImage(ctrlIcon, ditu.SmallIcon)
end


local function OnStrengthenSuccess(self, data)
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('enhancedsuccess')
    SetInfo(self)
    local node = self.sp_list.Scrollable:GetCell(0,self.selectIndex - 1);
    if node then
        initNodeValue(self, node, self.selectIndex)
    end
    for k, v in pairs(self.nodes) do
        UpdateRedPoint(self,k,v)
    end
end

local function OnStrengthenFailed(self, data)
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('enhancedfail')
end

function OnClickStrengthen(self)
    local strengthPos = ItemModel.GetEquipStrgData(self.selectIndex)
    local strengthLv = 0
    local strengthSection = 0
    if strengthPos ~= nil then
        strengthLv = strengthPos.enLevel
        strengthSection = strengthPos.enSection
    end
    biLevelNow = strengthSection*100+strengthLv + 1
    if strengthLv == 9 then
        biLevelNow = (strengthSection +1)*100
    end

    local nextChantData = GlobalHooks.DB.Find('Enchant', biLevelNow)
    if nextChantData == nil then
        biCostMat = ""
    else
        local mat1 = nextChantData.MateCode1
        local mat2 = nextChantData.MateCode2
        local num1 = nextChantData.MateCount1
        local num2 = nextChantData.MateCount2
        local name1 = ItemModel.GetItemStaticDataByCode(mat1).Name
        local name2 = ItemModel.GetItemStaticDataByCode(mat2).Name
        biCostMat = string.format("%s(%s):%d , %s(%s):%d",name1,mat1,num1,name2,mat2,num2)
    end

    ItemModel.StrengthenRequest(self.selectIndex, 0, function(is_success, data)
        if is_success then
            if is_success == 1 then
                OnStrengthenSuccess(self, data)
                
                
                
                
                
                
                
                
                
            else
                OnStrengthenFailed(self, data)
            end
        else

        end
    end )
end

function _M:SetVisible(visible)
    self.menu.Visible = visible
end



local function GetEnchantBonusByPosAndSection(pos, section)
    
    
    local itemIdConfig = GlobalHooks.DB.Find('ItemIdConfig', pos)
    local data = GlobalHooks.DB.Find('EnchantBonus', { Type = itemIdConfig.ItemType, EnClass = section })
    if data ~= nil then
        return data[1]
    end
    return nil
end

local function GetSelectEquipProp(self, addPercnet)
    local detail = self.selectItemData.detail
    local mainText = ""

    local itemIdConfigTypeId = ItemModel.GetSecondType(detail.static.Type)
    local strength_Pos = ItemModel.GetEquipStrgData(itemIdConfigTypeId)
    
    local enchantKey = strength_Pos.enSection * 100 + strength_Pos.enLevel
    
    local enchant_data = GlobalHooks.DB.Find('Enchant', enchantKey)

    for _, attr in ipairs(detail.equip.baseAtts or { }) do
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)

        local value = attr.value
        if enchant_data ~= nil then
            value = value *(1 + enchant_data.PropPer / 10000)
        end
        local v = 0
        if attrdata.isFormat == 1 then
            v = value / 100
            
            mainText = mainText .. string.gsub(attrdata.attDesc, '{A}', string.format("%.2f", v))
            if addPercnet then
                local addValue =(attr.value * addPercnet / 100) / 100
                mainText = mainText .. string.format(format3, string.format("%.2f", addValue) .. "%")
            end
        else
            v = Mathf.Round(value)
            mainText = mainText .. string.gsub(attrdata.attDesc, '{A}', tostring(v))
            if addPercnet then
                local addValue = value +(attr.value * addPercnet / 100)
                addValue = Mathf.Round(addValue) - Mathf.Round(value)
                if addValue > 0 then
                    mainText = mainText .. string.format(format3, addValue)
                end
            end
        end



        
        
        
        
        
        
        
        
        
        
        mainText = mainText .. "\n"
    end
    return mainText
end

local function SetCostMaterial(self, chantData, index, newHasCount)
    local node = self.cvs_material1
    local matName = chantData.MateCode1
    local matCount = chantData.MateCount1
    if index == 2 then
        node = self.cvs_material2
        matName = chantData.MateCode2
        matCount = chantData.MateCount2
    end

    local cvs_icon = node:FindChildByEditName('cvs_mat_icon', false)
    local lb_name = node:FindChildByEditName('lb_mat_name', false)
    local lb_num = node:FindChildByEditName('lb_mat_num', false)
    local btn_get = node:FindChildByEditName('btn_mat_get', false)

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(matName)

    local static_data = ItemModel.GetItemStaticDataByCode(matName)
    local item = Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, 1)

    local x =(vItem and vItem.Num) or 0
    if newHasCount then
        x = newHasCount
    end
    local isLessItem = true
    if index == 1 then
        chantData.hasCount1 = x
    else
        chantData.hasCount2 = x
    end
    if x < matCount then
        lb_num.XmlText = string.format("<b> <f size='22' color='ffff0000'>%d</f>/%d</b>", x, matCount)
    else
        isLessItem = false
        lb_num.XmlText = string.format("<b> <f size='22' color='ff00ff00'>%d</f>/%d</b>", x, matCount)
    end
    btn_get.Visible =(x < matCount)
    lb_name.Text = static_data.Name
    lb_name.FontColorRGBA = Util.GetQualityColorRGBA(static_data.Qcolor)
    Util.NormalItemShowTouchClick(item, matName, isLessItem)
end



function SetInfo(self)
    local strengthPos = ItemModel.GetEquipStrgData(self.selectIndex)
    
    local strengthLv = 0
    local strengthSection = 0
    if strengthPos ~= nil then
        strengthLv = strengthPos.enLevel
        strengthSection = strengthPos.enSection
    end
    local count = GlobalHooks.DB.Find("Parameters", {ParamName = "EquipmentCraft.Enchant.MaxenLevel"})[1].ParamValue
    self.lb_strLV.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 119,strengthSection*10+strengthLv)
    

    
    local nextEBonusData = nil
    
    local maxSection = ActivityUtil.ParametersValue("EquipmentCraft.Enchant.MaxEnClass")
    local maxEnlv = ActivityUtil.ParametersValue("EquipmentCraft.Enchant.MaxenLevel")
    if strengthSection < maxSection then
        
        nextEBonusData = GetEnchantBonusByPosAndSection(self.selectIndex,(strengthSection + 1))
    elseif strengthSection == maxSection then
        
        if strengthLv < maxEnlv - 1 then
            nextEBonusData = GetEnchantBonusByPosAndSection(self.selectIndex,(strengthSection + 1))
        end
    end

    local curEBonusData = GetEnchantBonusByPosAndSection(self.selectIndex, strengthSection)

    if nextEBonusData ~= nil then
        
        self.lb_next_pro.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 126, nextEBonusData.EnClass*10, GetEnchantBonusAttStr(nextEBonusData))
    else
        curEBonusData = GetEnchantBonusByPosAndSection(self.selectIndex, strengthSection)
        self.lb_next_pro.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 127, GetEnchantBonusAttStr(curEBonusData))
    end

    
















    
    local enchantKey = strengthSection * 100 + strengthLv
    
    local nextEnchantKey = strengthSection * 100 + strengthLv + 1
    if strengthLv == 9 then
        
        nextEnchantKey =((strengthSection + 1) * 100)
    end
    local curChantData = GlobalHooks.DB.Find('Enchant', enchantKey)
    local nextChantData = GlobalHooks.DB.Find('Enchant', nextEnchantKey)

    local curPercent = 0
    if curChantData ~= nil then
        curPercent = curChantData.PropPer / 100
    end
    local nextPercent = 0
    if nextChantData ~= nil then
        nextPercent = nextChantData.PropPer / 100
    end
    local addPercnet = 0
    
    if nextPercent ~= 0 then
        addPercnet = nextPercent - curPercent
    end

    self.tb_basepro_num.UnityRichText = string.format(format7, string.format('+%d%%', curPercent), string.format('%d%%', addPercnet))

    
    local c = nil
    if self.selectItemData == false then
        c = Util.GetQualityColorRGBAStr(0)
        self.lb_name.Text = string.format(string_item_name, c, Util.GetText(TextConfig.Type.ITEM, 'equipPos' .. self.selectIndex))
        self.tb_equip_pro.UnityRichText = ""
    else
        c = Util.GetQualityColorRGBAStr(self.selectItemData.detail.static.Qcolor)
        self.lb_name.Text = string.format(string_item_name, c, self.selectItemData.detail.static.Name)
        self.tb_equip_pro.UnityRichText = GetSelectEquipProp(self, addPercnet)
    end

    local txtH = self.tb_equip_pro.TextComponent.RichTextLayer.ContentHeight
    self.tb_equip_pro.Size2D = Vector2.New(self.tb_equip_pro.Width, txtH)
    self.lb_equip_position.Text = Util.GetText(TextConfig.Type.ITEM, 'equipPos' .. self.selectIndex)
    

    
    if nextChantData == nil then
        
        self.cvs_material1.Visible = false
        self.cvs_material2.Visible = false
        self.cvs_material3.Visible = false
        self.btn_strengthen.Visible = false
    else
        self.cvs_material1.Visible = true
        self.cvs_material2.Visible = true
        self.cvs_material3.Visible = true
        self.btn_strengthen.Visible = true

        SetCostMaterial(self, nextChantData, 1)
        SetCostMaterial(self, nextChantData, 2)
        SetCostMoney(self, nextChantData)
        self.nextChantData = nextChantData



    end

end

local function ClickItemshow(self, roleEquip, itemData)
    self.selectItemData = itemData
    if itemData ~= nil and type(itemData) ~= "boolean" then
        self.selectItemShow:SetItemData(self.selectItemData)
        self.selectItemShow.EnableTouch = true
        Util.NormalItemShowTouchClick(self.selectItemShow, itemData.TemplateId, false)
    else
        self.selectItemShow.EnableTouch = false
    end 
    SetInfo(self)
end

local function ClickGridShow(self, itemData)

end


function _M:OnEnter()
    self.EquipContainer.ItemPack = DataMgr.Instance.UserData.RoleEquipBag
    DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
    self.selectIndex = self.parent.paramStrg
    local count = PosCount
    self.sp_list.Scrollable:Reset(1, count)
    local y = (self.selectIndex - 1) * self.cvs_equip_brief.Height
    self.sp_list.Scrollable:LookAt(Vector2.New(0,y),false)
    local itemData = getItemData(self, self.selectIndex)
    ClickItemshow(self, nil, itemData)
    self.parent.paramStrg = 1

    self.OnBuySuccess = function (evtName, param)
        local itemCode = param.itemCode
        local buyCount = param.buyCount
        local totalCount = param.totalCount
        if self.nextChantData then
            local index = 0
            local matName = self.nextChantData.MateCode1
            if self.nextChantData.MateCode2 == itemCode then
                index = 2
                matName = self.nextChantData.MateCode2
            elseif self.nextChantData.MateCode1 == itemCode then
                index = 1
                matName = self.nextChantData.MateCode1
            else 
                return
            end
            SetCostMaterial(self, self.nextChantData, index, totalCount)
        end

        
        for k, v in pairs(self.nodes) do
            UpdateRedPoint(self,k,v)
        end
    end

    EventManager.Subscribe("Event.ShopMall.BuySuccess", self.OnBuySuccess)
end

function _M:OnExit()
    self.menu.Visible = false 
end

function _M:OnDispose()
    self.itemShows = nil
    EventManager.Unsubscribe("Event.ShopMall.BuySuccess", self.OnBuySuccess)
end

local function InitComponent(self, tag)
    self.menu = LuaMenuU.Create("xmds_ui/character/strengthen.gui.xml", tag)
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    local cvs_icon = self.cvs_material3:FindChildByEditName('cvs_mat_icon', false)
    local static_data = ItemModel.GetItemStaticDataByCode("gold")
    Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, 1)
    local temp_cvs = self.cvs_equip_brief:FindChildByEditName("cvs_equipicon", true)
    self.EquipContainer = HZItemsContainer.New()
    self.EquipContainer.CellSize = temp_cvs.Size2D
    self.EquipContainer.IsShowLockUnlock = false
    
    local effectColor = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.Qcolor')
    local effectEnlv = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.StrengthenLevel')
    self.EquipContainer:AddItemShowInitHandle('itshow', function(con, it)
        if not it.LastItemData then return end
        local detail = it.LastItemData.detail
        local bind = false
        
        if detail then
            local bindType = detail.bindType or detail.static.BindType
            bind = bindType == 1



        end
        
        it:SetNodeConfigVal(HZItemShow.CompType.bind, bind)
    end )
    

    local function UpdateEquipItem(con, itshow)
        EventManager.Fire("Event.EquipdItemChange", { pos = itshow.LastItemData.Index })
    end
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.ADDITEM, UpdateEquipItem)
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.RMITEM, UpdateEquipItem)
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.UPDATEITEM, UpdateEquipItem)
    self.filter_target = ItemPack.FilterInfo.New()
    self.filter_target.IsSequence = true
    self.filter_target.Type = ItemData.TYPE_EQUIP
    self.filter_target.CheckHandle = function(item)
        return true
    end
    self.EquipContainer.Filter = self.filter_target


    self.item_click = function(roleEquip, it)
        ClickItemshow(self, roleEquip, it)
    end

    self.EquipContainer:OpenSelectMode(false, false, nil, function(con, it)
        if not it.LastItemData then
            ClickGridShow(self, it)
            return
        end
        if it:ContainCustomAttribute('detail_tips') then
            it:RemoveCustomAttribute('detail_tips')
            return
        end
        if not it.IsSelected then
            con:SetSelectItem(it, it.Num)
        end
        if self.item_click then
            self.item_click(false, it)
        end
    end )

    self.cvs_equip_brief.Visible = false
    self.nodes = { }
    self.itemShows = { }
    self.sp_list:Initialize(self.cvs_equip_brief.Width, self.cvs_equip_brief.Height, 0, 1, self.cvs_equip_brief,
    function(gx, gy, node)
        initNodeValue(self, node, gy + 1)
        self.nodes[node] = gy + 1

    end ,
    function(cell)
        cell.Visible = true
    end
    )
    if self.selectItemShow == nil then
        self.selectItemShow = Util.ShowItemShow(self.cvs_icon, "", 1)
    end

    self.cvs_strengthen_pro.Visible = false
    self.cvs_more_attr.Visible = false
end

function _M.Create(tag, parent)
    local self = { }
    setmetatable(self, _M)
    InitComponent(self, tag)
    self.parent = parent
    self.parent.cvs_content:AddChild(self.menu)
    return self
end

return _M

