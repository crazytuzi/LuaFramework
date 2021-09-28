local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local BloodSoulAPI = require "Zeus.Model.BloodSoul"
local GameUIBloodList = require "Zeus.UI.XmasterBloodSoul.BloodList"

local self = {
    menu = nil,
}

local function InitBloodAttrAdd()
    BloodSoulAPI.GetAllBloodsAttrsRequest(function(list)
        self.cvs_value.Visible = true
        local row = math.ceil(#list/2)
        local col = 2
        self.sp_value:Initialize(self.cvs_pro.Width, self.cvs_pro.Height+5, row, col, self.cvs_pro,
          function(x, y, cell)
                local index = y*2+x+1
                if index <= #list then
                    cell.Visible = true
                    local lb_attValue = cell:FindChildByEditName('lb_attValue',true)
                    local data = list[index]
                    local attrdata = GlobalHooks.DB.Find('Attribute', tonumber(data.id))
                    if attrdata.isFormat == 1 then
                        local v = data.value / 100
                        lb_attValue.Text = string.gsub(attrdata.attDesc,'{A}',string.format("%.2f",v))
                    else
                        local v = Mathf.Round(data.value)
                        lb_attValue.Text = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                    end
                else
                    cell.Visible = false
                end
          end,
          function()
          end
        )
    end)
end

local function IsEquipBloodById(id)
    for i,v in ipairs(self.equipList) do
        local subStr = string.sub(v.BloodID, 1 ,4)
        if tostring(v.BloodID) == id then
          return true
        elseif subStr and subStr == id then
            return true
        end
    end

    return false
end

local function UpdateSuitChildItem(node, id)
    local info = BloodSoulAPI.GetBloodInfoById(id)
    local lb_bloodname = node:FindChildByEditName('lb_bloodname',true)
    local ib_star = node:FindChildByEditName('ib_star',true)
    local ib_star_null = node:FindChildByEditName('ib_star_null',true)

    lb_bloodname.Text = info.BloodName

    local hasEquip = IsEquipBloodById(id)

    ib_star.Visible = hasEquip
    ib_star_null.Visible = not hasEquip

    if hasEquip then
        lb_bloodname.FontColor = Util.FontColorGreen
    else
        lb_bloodname.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xFFDDF2FF)
    end

    return hasEquip
end

local function UpdateSuitItem(cell, data)
    local lb_suitname = cell:FindChildByEditName('lb_suitname',true)
    local cvs_icon = cell:FindChildByEditName('cvs_icon',true)
    local ib_discount = cell:FindChildByEditName('ib_discount',true)
    local gg_hp = cell:FindChildByEditName('gg_hp',true)
    local lb_jindu = cell:FindChildByEditName('lb_jindu',true)

    lb_suitname.Text = data.SuitName
    Util.ShowItemShow(cvs_icon, data.Icon1, data.Quality)
    ib_discount.Visible = string.find(data.Occupation,tostring(DataMgr.Instance.UserData.Pro)) ~= nil

    local equiplist = string.split(data.PartCodeList, ",")
    local hasCount = 0
    for i,v in ipairs(equiplist) do
        local cvs_blood = cell:FindChildByEditName('cvs_blood'..i, true)
        if UpdateSuitChildItem(cvs_blood, v) then
            hasCount = hasCount + 1
        end
    end

    gg_hp:SetGaugeMinMax(0, 4)
    gg_hp.Value = hasCount
    lb_jindu.Text = hasCount .. "/" .. 4

    if hasCount >= #equiplist then
        lb_jindu.FontColor = Util.FontColorGreen
    else
        lb_jindu.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xFFDDF2FF)
    end

    cell.TouchClick = function ()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBloodSuit, 0, data.SuitID2)
    end
end

local function GetSuitEquipCount(data)
    local equiplist = string.split(data.PartCodeList, ",")
    local hasCount = 0
    for i,v in ipairs(equiplist) do
        if IsEquipBloodById(v) then
            hasCount = hasCount + 1
        end
    end
    return hasCount
end

local function RefreshSuitList()
    local allSuitList = GlobalHooks.DB.GetFullTable("BloodSuitList")
    table.sort(allSuitList, function (aa,bb)
        local countA = GetSuitEquipCount(aa)
        local countB = GetSuitEquipCount(bb)
        if countA > countB then
            return true
        else
            return aa.Quality > bb.Quality
        end
    end)
    self.sp_suilt_list:Initialize(self.cvs_suit_template.Width, self.cvs_suit_template.Height+5, #allSuitList, 1, self.cvs_suit_template,
      function(x, y, cell)
          UpdateSuitItem(cell,allSuitList[y + 1])
      end,
      function()
      end
    )
end

local function ResetSelectEffect()
    if self.ib_choice then
        self.ib_choice.Visible = false
    end
end

local function OpenPosBloodList(equipCode, pos)
    if (self.uiBloodList == nil) then
        self.uiBloodList = GameUIBloodList.Create(GlobalHooks.UITAG.GameUIBloodList,self)
        self.cvs_content:AddChild(self.uiBloodList.menu)
        self.uiBloodList.menu.X = self.cvs_suit.X - 20
        self.uiBloodList.menu.Y = self.cvs_suit.Y
    end
    self.uiBloodList:InitBloodList(equipCode, pos)
    self.uiBloodList:OnEnter()
    self.uiBloodList:SetExitCallBack(ResetSelectEffect)
end

local function UpdateEuipPos(pos, data)
    local node = self.itemList[pos]
    local cvs_icon = node:FindChildByEditName('cvs_icon',true)
    cvs_icon.Visible = data ~= nil
    cvs_icon.Enable = false

    local equipCode = nil
    if data then
        equipCode = data.Code
        local static_data = ItemModel.GetItemStaticDataByCode(data.Code)
        Util.HZSetImage(cvs_icon,"static_n/item/" .. static_data.Icon .. ".png", false, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
    end

    node.TouchClick = function ()
        OpenPosBloodList(equipCode, pos)
        ResetSelectEffect()
        local ib_choice = node:FindChildByEditName('ib_choice0',true)
        if not ib_choice.Visible then
            ib_choice.Visible = true
            self.ib_choice = ib_choice
        end
    end
end

local function RefreshEquipList()
    for i=1, #self.itemList do
        local data = nil
        local cvs_pos = self.menu:FindChildByEditName('cvs_pos'..i,true)
        for _,v in ipairs(self.equipList) do
            if i == v.SortID3  then
               data = v
            end
        end
        UpdateEuipPos(i, data)
    end
end

local function ReqEquipBloodList()
    BloodSoulAPI.GetEquipedBloodsRequest(DataMgr.Instance.UserData.RoleID, function(data)
        self.equipList = data
        RefreshEquipList()
        RefreshSuitList()
    end)
end

local function SwitchSender(sender)
    if sender == self.tbt_blood then
        self.cvs_content.Visible = true
        self.cvs_content_smelt.Visible = false
        ReqEquipBloodList()
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIBloodSmelt)
    elseif sender == self.tbt_smelt then
        if self.uiBloodList then
            self.uiBloodList:Close()
        end
        self.cvs_content.Visible = false
        self.cvs_content_smelt.Visible = true
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBloodSmelt, 0)
    end
end

local function OnEnter()
    self.tbt_blood.IsChecked = true
    self.cvs_suit.Visible = true
  
    self.cvs_intrduce.Visible = false
    self.cvs_value.Visible = false

    EventManager.Subscribe("Event.BloodSoul.EquipSuccess",ReqEquipBloodList)
end

local function OnExit()
  if self.uiBloodList then
    self.uiBloodList:Close()
  end

  GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIBloodSmelt)

  EventManager.Unsubscribe("Event.BloodSoul.EquipSuccess",ReqEquipBloodList)
end

local ui_names = 
{
  
    {name = 'btn_close'},
    {name = 'btn_help'},
    {name = 'cvs_intrduce'},
    {name = 'tbt_blood'},
    {name = 'tbt_smelt'},
    {name = "cvs_position"},
    {name = 'cvs_temp'},
    
    {name = 'cvs_content'},
    {name = 'cvs_suit'},
    {name = 'sp_suilt_list'},
    {name = 'cvs_suit_template'},
    {name = 'btn_tujian'},
    {name = 'btn_pro'},
  
    {name = 'sp_soul_list'},
    {name = 'btn_go'},

    {name = 'cvs_value'},
    {name = 'sp_value'},
    {name = 'cvs_pro'},
    {name = 'cvs_content_smelt'},
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    
    self.itemList = {}
    for i=1,12 do
        local node = self.menu:FindChildByEditName('cvs_temp'..i,true)
        table.insert(self.itemList, node)
    end

    self.cvs_pro.Visible = false

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end
  
    self.btn_help.TouchClick = function ()
        self.cvs_intrduce.Visible = not self.cvs_intrduce.Visible
    end
  
    self.cvs_intrduce.TouchClick = function ()
        self.cvs_intrduce.Visible = false
    end
  
    self.btn_tujian.TouchClick = function ()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBloodSuit, 0, 1)
    end
  
    self.btn_pro.TouchClick = function ()
        InitBloodAttrAdd()
    end

    self.cvs_value.TouchClick = function ()
        self.cvs_value.Visible = false
    end

    BloodSoulAPI.InitAllBloodList()
    BloodSoulAPI.InitAllBloodSuitList()

    self.cvs_suit_template.Visible = false

    Util.InitMultiToggleButton(function(sender)
        SwitchSender(sender)
    end, nil, {self.tbt_blood, self.tbt_smelt})

    self.tbt_smelt.Visible = false
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/bloodsoul/main.gui.xml", GlobalHooks.UITAG.GameUIBloodMain)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.ShowType = UIShowType.HideBackHud
  
    InitCompnent()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function ()
        self = nil
    end)
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
