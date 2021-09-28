local _M = { }
_M.__index = _M

local PetModel = require 'Zeus.Model.Pet'
local Util = require 'Zeus.Logic.Util'
local cjson = require "cjson"
local ItemModel = require 'Zeus.Model.Item'

local self = {
    m_Root = nil,
}
local itemdata_Primitive = {
    { code = "", num = 0 },
    { code = "", num = 0 },
    { code = "", num = 0 }
}
local itemdata_Used =
{
    { code = "", num = 0 },
    { code = "", num = 0 },
    { code = "", num = 0 }
}
local usecode = nil
local usenum = nil

local function OnEnter()
    self.itemFilter = { }
end

local function OnExit()
    for _, v in pairs(self.itemFilter) do
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(v)
    end

    self.itemFilter = nil
end

local function InitUI()
    local UIName = {
        "btn_close",
        "ib_peticon",
        "lb_pet",
        "ib_man_icon",
        "lb_role",
        "ib_pc_num",
        "ib_pc_num1",
        "ib_pc_num2",
        "ib_pc_num3",
        "lb_mt_num1",
        "lb_mt_num2",
        "lb_mt_num3",
        "lb_mt_num4",
        "lb_mt_single1",
        "lb_mt_single2",
        "lb_mt_single3",
        "lb_mt_single4",
        "lb_level",
        "gg_experience",
        "tb_experience_num",
        "sp_updata",
        "cvs_updata",
        "btn_upone",
        "btn_upmax",

        "ib_pc_name",
        "ib_pc_namemag"
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end

end

local function CheckItemUseNum()

    local item1UsedNum = itemdata_Primitive[1].num - itemdata_Used[1].num
    local item2UsedNum = itemdata_Primitive[2].num - itemdata_Used[2].num
    local item3UsedNum = itemdata_Primitive[3].num - itemdata_Used[3].num

    if item1UsedNum > 0 and item2UsedNum <= 0 and item3UsedNum <= 0 then
        
        return itemdata_Used[1].code,item1UsedNum

    elseif item2UsedNum > 0 and item1UsedNum <= 0 and item3UsedNum <= 0 then
        
        return itemdata_Used[2].code, item2UsedNum

    elseif item3UsedNum > 0 and item1UsedNum <= 0 and item2UsedNum <= 0 then
        
        return itemdata_Used[3].code, item3UsedNum

    elseif item1UsedNum > 0 and item2UsedNum > 0 and item3UsedNum <= 0 then
        
        return itemdata_Used[1].code,item1UsedNum,itemdata_Used[2].code,item2UsedNum

    elseif item1UsedNum > 0 and item2UsedNum <= 0 and item3UsedNum > 0 then
        
        return itemdata_Used[1].code, item1UsedNum,itemdata_Used[3].code, item3UsedNum

    elseif item2UsedNum > 0 and item3UsedNum > 0 and item1UsedNum <= 0 then
        
        return itemdata_Used[2].code,item2UsedNum,itemdata_Used[3].code, item3UsedNum

    elseif item1UsedNum > 0 and item2UsedNum > 0 and item3UsedNum > 0 then
        return itemdata_Used[1].code, item1UsedNum, itemdata_Used[2].code, item2UsedNum, itemdata_Used[3].code, item3UsedNum
        
    end
end
local function GetUseItemStr()
    local code1, num1, code2, num2, code3, num3 = CheckItemUseNum()
    local useItemStr= ""
    if code1 ~= nil and code2 == nil and code3 == nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code1).Name .. "(" .. code1 .. ")" .. ":" .. num1
    elseif code1 == nil and code2 ~= nil and code3 == nil then 
        useItemStr = ItemModel.GetItemStaticDataByCode(code2).Name .. "(" .. code2 .. ")" .. ":" .. num2
    elseif code1 == nil and code2 == nil and code3 ~= nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code3).Name .. "(" .. code3 .. ")" .. ":" .. num3
    elseif code1~= nil and code2 ~= nil and code3 == nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code1).Name .. "(" .. code1 .. ")" .. ":" .. num1 .. "," .. ItemModel.GetItemStaticDataByCode(code2).Name .. "(" .. code2 .. ")" .. ":" .. num2
    elseif code1~=nil and code2==nil and code3~=nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code1).Name .. "(" .. code1 .. ")" .. ":" .. num1 .. "," .. ItemModel.GetItemStaticDataByCode(code3).Name .. "(" .. code3 .. ")" .. ":" .. num3
    elseif code1==nil and code2~=nil and code3~=nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code2).Name .. "(" .. code2 .. ")" .. ":" .. num2 .. "," .. ItemModel.GetItemStaticDataByCode(code3).Name .. "(" .. code3 .. ")" .. ":" .. num3
    elseif code1~=nil and code2~=nil and code3~=nil then
        useItemStr = ItemModel.GetItemStaticDataByCode(code1).Name .. "(" .. code1 .. ")" .. ":" .. num1 .. "," .. ItemModel.GetItemStaticDataByCode(code2).Name .. "(" .. code2 .. ")" .. ":" .. num2 .. ",".. ItemModel.GetItemStaticDataByCode(code3).Name .. "(" .. code3 .. ")" .. ":" .. num3
    end
    return useItemStr
end
local function ResetItemPri(index, code)
    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(code)
    local num =(vItem and vItem.Num) or 0

    if (vItem == nil) then
        itemdata_Primitive[index].code = code
    else
        itemdata_Primitive[index].code = vItem.TemplateId
    end
    itemdata_Primitive[index].num = num
    
end

local function refrashAttrs(self)
    self.serverData = PetModel.getPetData(self.petData.PetID)
    local curphy = math.floor(self.petData.BasePhyDamage * math.pow(self.petData.PhyGrowUp, self.serverData.level - 1) + 0.5)
    local curmag = math.floor(self.petData.BaseMagDamage * math.pow(self.petData.MagGrowUp, self.serverData.level - 1) + 0.5)
    local curhit = math.floor(self.petData.initHit * math.pow(self.petData.HitGrowUP, self.serverData.level - 1) + 0.5)
    local curcrit = math.floor(self.petData.initCrit * math.pow(self.petData.CritGrowUP, self.serverData.level - 1) + 0.5)
    local curcritDamage = math.floor(self.petData.initCritDamage * math.pow(self.petData.CritDamageGrowUp, self.serverData.level - 1) + 0.5)

    local nextphy = math.floor(self.petData.BasePhyDamage * math.pow(self.petData.PhyGrowUp, self.serverData.level) + 0.5)
    local nextmag = math.floor(self.petData.BaseMagDamage * math.pow(self.petData.MagGrowUp, self.serverData.level) + 0.5)
    local nexthit = math.floor(self.petData.initHit * math.pow(self.petData.HitGrowUP, self.serverData.level) + 0.5)
    local nextcrit = math.floor(self.petData.initCrit * math.pow(self.petData.CritGrowUP, self.serverData.level) + 0.5)
    local nextcritDamage = math.floor(self.petData.initCritDamage * math.pow(self.petData.CritDamageGrowUp, self.serverData.level) + 0.5)

    local subphy = nextphy - curphy
    local submag = nextmag - curmag
    local subhit = nexthit - curhit
    local subcrit = nextcrit - curcrit
    local subcritDamage = nextcritDamage - curcritDamage

    if curmag > curphy then
        self.ib_pc_name.Visible = false
        self.ib_pc_namemag.Visible = true
        self.ib_pc_num.Text = '+' .. submag
    else
        self.ib_pc_name.Visible = true
        self.ib_pc_namemag.Visible = false
        self.ib_pc_num.Text = '+' .. subphy
    end

    self.ib_pc_num1.Text = '+' .. subhit
    self.ib_pc_num2.Text = '+' .. subcrit
    self.ib_pc_num3.Text = '+' .. string.format("%.2f", subcritDamage / 100) .. '%'

    local masterdata = GlobalHooks.DB.Find('MasterProp', { PropID = self.petData.PetID })[1]
    for i = 1, 4 do
        local curNum = math.floor(masterdata['Min' .. i] * math.pow(masterdata['Grow' .. i], self.serverData.level - 1) + 0.5)
        local nextNum = math.floor(masterdata['Min' .. i] * math.pow(masterdata['Grow' .. i], self.serverData.level) + 0.5)
        self['lb_mt_single' .. i].Text = masterdata['Prop' .. i]
        self['lb_mt_num' .. i].Text = '+' ..(nextNum - curNum)
    end
end

local function refrashExp(self)
    local data = self.petData
    self.serverData = PetModel.getPetData(self.petData.PetID)

    self.lb_level.Text = self.serverData.level .. Util.GetText(TextConfig.Type.ITEM, 'lvSuffix')
    local expData = GlobalHooks.DB.Find("PetExpLevel", self.serverData.level)
    self.gg_experience:SetGaugeMinMax(0, expData.Experience)
    self.gg_experience.Value = self.serverData.exp > expData.Experience and expData.Experience or self.serverData.exp
    local text = self.serverData.exp .. "/" .. expData.Experience
    
    
    
    
    self.tb_experience_num.Text = text
    
end

local function canUpLevel()


    
        
        
    
    return true
end

local function checkLevelIsLimit()
    return true


    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end


local function setItemFilter(self, code, node, itemShow)
    self.itemFilter = self.itemFilter or { }
    local filter = self.itemFilter[code]
    if filter then
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
    end
    filter = ItemPack.FilterInfo.New()
    self.itemFilter[code] = filter

    filter.MergerSameTemplateID = true
    filter.CheckHandle = function(item)
        return item.TemplateId == code
    end
    filter.NofityCB = function(pack, type, index)
        if itemShow == nil then

            return
        end
        if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
            local bag_data = DataMgr.Instance.UserData.RoleBag
            local vItem = bag_data:MergerTemplateItem(code)
            local num =(vItem and vItem.Num) or 0

            if (node.Name == "cvs_updata1") then
                if vItem == nil then
                    itemdata_Used[1].code = code
                else
                    itemdata_Used[1].code = vItem.TemplateId
                end
                itemdata_Used[1].num = num
            elseif node.Name == "cvs_updata2" then
                if (vItem == nil) then
                    itemdata_Used[2].code = code
                else
                    itemdata_Used[2].code = vItem.TemplateId
                end
                itemdata_Used[2].num = num
            elseif node.Name == "cvs_updata3" then
                if (vItem == nil) then
                    itemdata_Used[3].code = code
                else
                    itemdata_Used[3].code = vItem.TemplateId
                end
                itemdata_Used[3].num = num
            end

            local cvs_icon = node:FindChildByEditName('cvs_icon', false)
            local btn_use = node:FindChildByEditName('btn_use', false)
            local btn_get = node:FindChildByEditName('btn_get', false)

            btn_get.Visible = false
            
            
            
            
            
            
            
            
            
            
            
            Util.NormalItemShowTouchClick(itemShow, code, num <= 0)
            itemShow.ForceNum = num
        end
    end
    DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function refrashItmes()
    local items = string.split(self.petData.ExpCode, ',')

    local function RefreshPetItem(x, y, node)
        node.Visible = true
        node.Name = "cvs_updata" .. tostring(x + 1)
        local itemcode = items[x + 1]

        local cvs_icon = node:FindChildByEditName('cvs_icon', false)
        local btn_use = node:FindChildByEditName('btn_use', false)
        local btn_get = node:FindChildByEditName('btn_get', false)

        local bag_data = DataMgr.Instance.UserData.RoleBag
        local vItem = bag_data:MergerTemplateItem(itemcode)
        local num =(vItem and vItem.Num) or 0
        if (x == 0) then
            if (vItem == nil) then
                itemdata_Primitive[1].code = itemcode
            else
                itemdata_Primitive[1].code = vItem.TemplateId
            end
            itemdata_Primitive[1].num = num
        elseif (x == 1) then
            if (vItem == nil) then
                itemdata_Primitive[2].code = itemcode
            else
                itemdata_Primitive[2].code = vItem.TemplateId
            end
            itemdata_Primitive[2].num = num
        else
            if (vItem == nil) then
                itemdata_Primitive[3].code = itemcode
            else
                itemdata_Primitive[3].code = vItem.TemplateId
            end
            itemdata_Primitive[3].num = num
        end

        local item = GlobalHooks.DB.Find("Items", itemcode)
        local itemShow = Util.ShowItemShow(cvs_icon, item.Icon, item.Qcolor, num, true)
        btn_get.Visible = false
        
        
        
        
        
        
        
        
        
        
        Util.NormalItemShowTouchClick(itemShow, itemcode, num <= 0)
        
        
        

        btn_use.TouchClick = function(sender)
            if checkLevelIsLimit() then
                if canUpLevel() then
                    self.serverData = PetModel.getPetData(self.petData.PetID)
                    self.cultivateLv_before = self.serverData.level
                    self.cultivateExp_before = self.serverData.exp
                    PetModel.addExpByItemRequest(self.petData.PetID, itemcode, function()
                                         
                        refrashAttrs(self)
                        refrashExp(self)
                        EventManager.Fire("Event.UI.PetUIMain.Refresh", { })

                        if self.serverData.level > self.cultivateLv_before  then 
                           Util.showUIEffect(self.gg_experience, 30)
                           XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("petlevelup")
                        end

                        
                        
                        
                        
                        

                        ResetItemPri(1, itemdata_Used[1].code)
                        ResetItemPri(2, itemdata_Used[2].code)
                        ResetItemPri(3, itemdata_Used[3].code)


                    end )
                end

            else

                   GameAlertManager.Instance:ShowAlertDialog(
                        AlertDialog.PRIORITY_NORMAL, 
                        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTips"),
                        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "go"),
                        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "cancel"),
                        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTitle"),
                        nil,
                        function()
                           if self ~= nil and self.m_Root ~= nil then
                                self.m_Root:Close()
                            end
                            EventManager.Fire("Event.UI.PetUIMain.SwitchUpgrade", {})
                        end,
                        function ()
                        end
                    )
            end
        end


        itemShow.TouchClick = function(sender)
            
        end
        setItemFilter(self, itemcode, node, itemShow)
    end
    self.sp_updata:Initialize(self.cvs_updata.Width+10, self.cvs_updata.Height, 1, #items, self.cvs_updata, RefreshPetItem, function() end)
end 

function _M:setPetInfo(data)
    self.petData = data

    self.serverData = PetModel.getPetData(self.petData.PetID)

    self.cultivateLv_before = self.serverData.level
    self.cultivateExp_before = self.serverData.exp

    refrashAttrs(self)
    refrashExp(self)
    refrashItmes(self)

    Util.HZSetImage(self.ib_peticon, "static_n/hud/target/" .. self.petData.Icon .. ".png", false)
    Util.SetHeadImgByPro(self.ib_man_icon, DataMgr.Instance.UserData.Pro)
end

local function InitCompnent()
    InitUI()

    self.btn_close.TouchClick = function()
        
        if self ~= nil and self.m_Root ~= nil then
            self.m_Root:Close()
        end
    end
    self.cvs_updata.Visible = false

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory( function()
        
    end )



    self.btn_upone.TouchClick = function(sender)
        if checkLevelIsLimit() then
            if canUpLevel() then
                self.serverData = PetModel.getPetData(self.petData.PetID)
                self.cultivateLv_before = self.serverData.level
                self.cultivateExp_before = self.serverData.exp
                PetModel.upgradeOneLevelRequest(self.petData.PetID, function()
                    self.serverData = PetModel.getPetData(self.petData.PetID)
                    refrashAttrs(self)
                    refrashExp(self)
                    EventManager.Fire("Event.UI.PetUIMain.Refresh", { })
                    Util.showUIEffect(self.gg_experience, 30)
                    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("petlevelup")

                    
                    
                    
                    
                    

                    ResetItemPri(1, itemdata_Used[1].code)
                    ResetItemPri(2, itemdata_Used[2].code)
                    ResetItemPri(3, itemdata_Used[3].code)


                end )
            end
        else

              GameAlertManager.Instance:ShowAlertDialog(
                    AlertDialog.PRIORITY_NORMAL, 
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTips"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "go"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "cancel"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTitle"),
                    nil,
                    function()
                       if self ~= nil and self.m_Root ~= nil then
                            self.m_Root:Close()
                        end
                        EventManager.Fire("Event.UI.PetUIMain.SwitchUpgrade", {})
                    end,
                    function ()
                    end
                )
        end

    end

    self.btn_upmax.TouchClick = function(sender)
        if checkLevelIsLimit() then
            if canUpLevel() then
                self.serverData = PetModel.getPetData(self.petData.PetID)
                self.cultivateLv_before = self.serverData.level
                self.cultivateExp_before = self.serverData.exp
                PetModel.upgradeToTopRequest(self.petData.PetID, function()
                    self.serverData = PetModel.getPetData(self.petData.PetID)
                    refrashAttrs(self)
                    refrashExp(self)
                    EventManager.Fire("Event.UI.PetUIMain.Refresh", { })
                    Util.showUIEffect(self.gg_experience, 30)
                    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("petlevelup")

                    
                    
                    
                    
                    

                    ResetItemPri(1, itemdata_Used[1].code)
                    ResetItemPri(2, itemdata_Used[2].code)
                    ResetItemPri(3, itemdata_Used[3].code)



                end )
            else 
                XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
            end
        else
            
             GameAlertManager.Instance:ShowAlertDialog(
                    AlertDialog.PRIORITY_NORMAL, 
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTips"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "go"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "cancel"),
                    ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PET, "breakTitle"),
                    nil,
                    function()
                       if self ~= nil and self.m_Root ~= nil then
                            self.m_Root:Close()
                        end
                        EventManager.Fire("Event.UI.PetUIMain.SwitchUpgrade", {})
                    end,
                    function ()
                    end
                )
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("buttonClick")
        end
    end
end

local function Init(tag, params)
    self.m_Root = LuaMenuU.Create("xmds_ui/pet/levelup.gui.xml", GlobalHooks.UITAG.GameUIPetEvolution)
    InitCompnent()
    self.menu = self.m_Root

    return self.m_Root
end

local function Create(tag, params)
    self = { }
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return { Create = Create }
