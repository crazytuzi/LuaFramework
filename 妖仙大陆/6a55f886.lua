local _M = {}
_M.__index = _M

local Bit           = require 'bit'
local Util          = require "Zeus.Logic.Util"
local ItemModel     = require 'Zeus.Model.Item'
local FashionModel  = require "Zeus.Model.Fashion"

local self = {
    menu = nil,
}

local function IsNeedShowFlag(code)
    for i,v in ipairs(self.fashionList.flagcode1) do
        if v == code then
            return true
        end
    end
    for i,v in ipairs(self.fashionList.flagcode2) do
        if v == code then
            return true
        end
    end
    for i,v in ipairs(self.fashionList.flagcode3) do
        if v == code then
            return true
        end
    end
    return false
end

local function RemoveItemFlag(code)
    for i,v in ipairs(self.fashionList.flagcode1) do
        if v == code then
            table.remove(self.fashionList.flagcode1, i)
            return
        end
    end
    for i,v in ipairs(self.fashionList.flagcode2) do
        if v == code then
            table.remove(self.fashionList.flagcode2, i)
            return
        end
    end
    for i,v in ipairs(self.fashionList.flagcode3) do
        if v == code then
            table.remove(self.fashionList.flagcode3, i)
            return
        end
    end
end

local function UpdateLeftFlag(index)
    self.lb_bj_wushi.Visible = #self.fashionList.flagcode1 > 0
    self.lb_bj_yifu.Visible = #self.fashionList.flagcode2 > 0
    self.lb_bj_beishi.Visible = #self.fashionList.flagcode3 > 0
end

local function GetFashionCountByType(param)
    local count = 0
    for i,v in ipairs(self.fashionAllList) do
        if v.Type == param then
            count = count + 1
        end
    end
    return count
end

local function GetAvatarABSource(code)
    for i,v in ipairs(self.fashionAllList) do
        if v.Code == code then
            return v.AvatarId
        end
    end
    return ""
end

local function GetFashionCountByType(param)
    local count = 0
    for i,v in ipairs(self.fashionAllList) do
        if v.Type == param then
            count = count + 1
        end
    end
    return count
end

local function GetFashionData(index,param)
    local count = 0
    for i,v in ipairs(self.fashionAllList) do
        if v.Type == param then
            count = count + 1
            if count == index then
                return v
            end
        end
    end
    return nil
end

local function IsFashionGet(code)
    local bool = false
    for i,v in ipairs(self.fashionList.code1) do
        if code == v then
            return true
        end
    end
    for i,v in ipairs(self.fashionList.code2) do
        if code == v then
            return true
        end
    end
    for i,v in ipairs(self.fashionList.code3) do
        if code == v then
            return true
        end
    end
    return bool
end

local function IsFashionEquip(Code)
    local equiped = false
    if self.selectType == 1 and (Code == self.fashionList.equiped_code1 or Code == self.showAvatarWushi) then
        equiped = true
    elseif self.selectType == 2 and (Code == self.fashionList.equiped_code2 or Code == self.showAvatarYifu) then
        equiped = true
    elseif self.selectType == 3 and (Code == self.fashionList.equiped_code3 or Code == self.showAvatarBeishi) then
        equiped = true
    end
    return equiped
end

local function ShowItemShow(icon,code,touch)
    local detail = ItemModel.GetItemDetailByCode(code)
    if not detail then
        icon.Visible = false
    else
        local itshow = Util.ShowItemShow(icon, detail.static.Icon, detail.static.Qcolor)
        itshow.EnableTouch = touch
        icon.Visible = true
    end
end

local function ClearAvatar()
    if self.avatarKey and self.avatarObj then
        UnityEngine.Object.DestroyObject(self.avatarObj)
        IconGenerator.instance:ReleaseTexture(self.avatarKey)
    end
    self.avatarObj = nil
    self.avatarKey = nil

    self.showAvatarWushi = nil
    self.showAvatarYifu = nil
    self.showAvatarBeishi = nil
end

local function GetShowAvatarList(avtTab)
    if not string.empty(self.showAvatarWushi) then
        local abSource = GetAvatarABSource(self.showAvatarWushi)
        local ava = {
                        fileName = abSource,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.R_Hand_Weapon),
                    }
        if not string.empty(abSource) then
            table.insert(avtTab,ava)
        end
    end

    if not string.empty(self.showAvatarYifu) then
        local abSource = GetAvatarABSource(self.showAvatarYifu)
        local ava = {
                        fileName = abSource,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Avatar_Body),
                    }
        if not string.empty(abSource) then
            table.insert(avtTab,ava)
        end
    end

    if not string.empty(self.showAvatarBeishi) then
        local abSource = GetAvatarABSource(self.showAvatarBeishi)
        local ava = {
                        fileName = abSource,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Rear_Equipment),
                    }
        if not string.empty(abSource) then
            table.insert(avtTab,ava)
        end
    end
end

local function UpdateAvatar(index)
    local avatarList = {}
    if index == 0 or index == 2 then
        GetShowAvatarList(avatarList)
    end

    if self.avatarKey ~= nil then
        local filter = bit.lshift(1, GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
        GameUtil.ChangeLua3DFashionModel(self.avatarKey, avatarList, '', filter)
        return
    end

    self.ib_3d.Enable = true
    self.ib_3d.EnableChildren = true
    self.ib_3d.IsInteractive = true

    local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
    local obj, key = GameUtil.AddLua3DFashionModel(self.ib_3d, avatarList, '', nil, filter, true)
    if IsNil(obj) then
        return
    end
    IconGenerator.instance:SetModelPos(key, Vector3.New(0.2, -1.15, 3.5))
    IconGenerator.instance:SetCameraParam(key, 0.3, 10, 2)
    IconGenerator.instance:SetLoadOKCallback(key, function (k)
        IconGenerator.instance:PlayUnitAnimation(key, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
    end)
    local t = {
        node = self.ib_3d,
        move = function (sender,pointerEventData)
            IconGenerator.instance:SetRotate(key,-pointerEventData.delta.x * 5)
        end, 
        up = function() end
    }
    LuaUIBinding.HZPointerEventHandler(t)

    self.avatarKey = key
    self.avatarObj = obj

    local gObject = IconGenerator.instance:GetGameObject(key)
    gObject:SetActive(true)
end

local function UpdateFashionIcon()
    ShowItemShow(self.ib_wushi,self.fashionList.equiped_code1,false)
    ShowItemShow(self.ib_yifu,self.fashionList.equiped_code2,false)
    ShowItemShow(self.ib_beishi,self.fashionList.equiped_code3,false)
end

local function UpdateShowAvatarCode(data,index)
    
    if self.selectType == 1 then
        if index == -1 then
            self.showAvatarWushi = ""
            self.fashionList.equiped_code1 = ""
        elseif index == 0 then
            self.showAvatarWushi = data.Code
        elseif index == 1 then
            self.showAvatarWushi = data.Code
            self.fashionList.equiped_code1 = data.Code
        elseif index == 2 then
            self.showAvatarWushi = ""
        end
    elseif self.selectType == 2 then
        if index == -1 then
            self.showAvatarYifu = ""
            self.fashionList.equiped_code2 = ""
        elseif index == 0 then
            self.showAvatarYifu = data.Code
        elseif index == 1 then
            self.showAvatarYifu = data.Code
            self.fashionList.equiped_code2 = data.Code
        elseif index == 2 then
            self.showAvatarYifu = ""
        end
    elseif self.selectType == 3 then
        if index == -1 then
            self.showAvatarBeishi = ""
            self.fashionList.equiped_code3 = ""
        elseif index == 0 then
            self.showAvatarBeishi = data.Code
        elseif index == 1 then
            self.showAvatarBeishi = data.Code
            self.fashionList.equiped_code3 = data.Code
        elseif index == 2 then
            self.showAvatarBeishi = ""
        end
    end
end

local function UpdateSelectAttr(data, has)
    self.cvs_below.Visible = true

    self.lb_mingcheng.Text = data.Name
    self.lb_mingcheng.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(data.Qcolor))

    self.lb_shuxing1.Text = data.Prop1
    self.lb_shuxing2.Text = data.Prop2
    self.lb_shuxing3.Text = data.Prop3
    self.lb_shuxing4.Text = data.Prop4

    self.lb_num1.Text = data.Num1
    self.lb_num2.Text = data.Num2
    self.lb_num3.Text = data.Num3
    self.lb_num4.Text = data.Num4

    self.btn_equip.Visible = has

    self.btn_shichuan.Visible = not has
    self.btn_tujing.Visible = not has

    local equiped = IsFashionEquip(data.Code)

    if equiped then
        self.btn_equip.Text = Util.GetText(TextConfig.Type.SUIT, "xiexia")
        self.btn_shichuan.Text = Util.GetText(TextConfig.Type.SUIT, "xiexia")
    else
        self.btn_equip.Text = Util.GetText(TextConfig.Type.SUIT, "chuandai")
        self.btn_shichuan.Text =  Util.GetText(TextConfig.Type.SUIT, "shichuan")
    end

    self.btn_equip.TouchClick = function(sender)
        if IsFashionEquip(data.Code) then
            FashionModel.Unequip(data.Code, function (msg)
                self.timer = Timer.New(function ()
                    UpdateShowAvatarCode(data,-1)
                    UpdateAvatar(-1)
                    UpdateFashionIcon()
                    self.selectNode:FindChildByEditName("ib_zhuangbei",true).Visible = false
                    self.btn_equip.Text =  Util.GetText(TextConfig.Type.SUIT, "chuandai")
                    self.timer:Stop()
                end, 0.1, -1)
                self.timer:Start()
            end)
        else
            FashionModel.Equip(data.Code, function (msg)
                self.timer = Timer.New(function ()
                    UpdateShowAvatarCode(data,1)
                    UpdateAvatar(1)
                    UpdateFashionIcon()
                    self.selectNode:FindChildByEditName("ib_zhuangbei",true).Visible = true
                    self.btn_equip.Text = Util.GetText(TextConfig.Type.SUIT, "xiexia")
                    if self.lastNode then
                        self.lastNode:FindChildByEditName("ib_zhuangbei",true).Visible = false
                    end
                    self.timer:Stop()
                end, 0.1, -1)
                self.timer:Start()
            end)
        end
    end

    self.btn_shichuan.TouchClick = function(sender)
        if IsFashionEquip(data.Code) then
            UpdateShowAvatarCode(data,2)
            UpdateAvatar(2)
            self.btn_shichuan.Text = Util.GetText(TextConfig.Type.SUIT, "shichuan")
        else
            UpdateShowAvatarCode(data,0)
            UpdateAvatar(0)
            self.btn_shichuan.Text = Util.GetText(TextConfig.Type.SUIT, "xiexia")
        end
    end

    self.btn_tujing.TouchClick = function(sender)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, data.Code)
    end
end

local function SelectFashionItem(node, data, has)
    if self.selectNode then
        local ib_xuanzhong = self.selectNode:FindChildByEditName("ib_xuanzhong",true)
        ib_xuanzhong.Visible = false
        self.selectNode.Enable = true
    end

    local ib_xuanzhong = node:FindChildByEditName("ib_xuanzhong",true)
    ib_xuanzhong.Visible = true
    node.Enable = false
    self.lastNode = self.selectNode
    self.selectNode = node
    
    UpdateSelectAttr(data, has)
end

local function InitNodeWithIndex(node, index, param)
    node.UserTag = index
    node.X = ((index-1)%self.columns)*(self.cvs_item.Size2D.y+15)
    node.Y = (math.floor((index-1)/self.columns))*(self.cvs_item.Size2D.x+15)

    local data = GetFashionData(index,param)

    if data == nil then
        node.Visible = false
        return
    end

    local has = IsFashionGet(data.Code)

    local cvs_icon = node:FindChildByEditName("cvs_icon",true)
    ShowItemShow(cvs_icon,data.Code,false)

    local ib_zhuangbei = node:FindChildByEditName("ib_zhuangbei",true)
    if param == 1 and data.Code == self.fashionList.equiped_code1 then
        ib_zhuangbei.Visible = true
    elseif param == 2 and data.Code == self.fashionList.equiped_code2 then
        ib_zhuangbei.Visible = true
    elseif param == 3 and data.Code == self.fashionList.equiped_code3 then
        ib_zhuangbei.Visible = true
    else
        ib_zhuangbei.Visible = false
    end

    local ib_suoding = node:FindChildByEditName("ib_suoding",true)
    ib_suoding.Visible = not has

    local lb_bj_1 = node:FindChildByEditName("lb_bj_1",true)
    lb_bj_1.Visible = IsNeedShowFlag(data.Code)

    local ib_xuanzhong = node:FindChildByEditName("ib_xuanzhong",true)
    ib_xuanzhong.Visible = false
    
    node.Enable = true
    node.TouchClick = function(sender)
        SelectFashionItem(node, data, has)
        if lb_bj_1.Visible then
            lb_bj_1.Visible = false
            RemoveItemFlag(data.Code)
            FashionModel.DeleteFashionFlagRequest(data.Code, function ()
                UpdateLeftFlag()
            end)
        end
    end

    if ib_zhuangbei.Visible == true or
        self.showAvatarWushi == data.Code or 
        self.showAvatarYifu == data.Code or 
        self.showAvatarBeishi == data.Code then
        SelectFashionItem(node, data, has)
    end
end

local function SwithFashionList(param)
    self.sp_fasion.Scrollable.Container:RemoveAllChildren(true)
    self.selectNode = nil
    self.selectType = param

    self.lb_select1.Visible = param == 1
    self.lb_select2.Visible = param == 2
    self.lb_select3.Visible = param == 3

    local count = GetFashionCountByType(param)

    self.cvs_below.Visible = false

    self.columns = 3
    self.row = math.ceil(count/self.columns)
    for i=1,count do
        local node = self.cvs_item:Clone()
        InitNodeWithIndex(node,i,param)
        self.sp_fasion.Scrollable.Container:AddChild(node)
    end

    UpdateLeftFlag(param)
end

local function OnExit()
    if self.timer then
        self.timer:Stop()
    end
    ClearAvatar()
end

local function OnEnter()
    ClearAvatar()

    self.tbt_choice.IsChecked = false
    self.tbt_choice.Enable = true
    self.cvs_right.X = self.leftPosX

    FashionModel.GetFashionsRequest(function (data)
        self.fashionList = data
        

        self.showAvatarWushi = ""
        self.showAvatarYifu = ""
        self.showAvatarBeishi = ""

        UpdateFashionIcon()
        UpdateAvatar(0)

        Util.InitMultiToggleButton(function (sender)
            SwithFashionList(sender.UserTag)
        end,self.tbt_wushi,{self.tbt_wushi,self.tbt_yifu,self.tbt_beishi})
    end)
end

local function InitUI()
    local UIName = {
        "btn_close",
        "btn_tujian",
        "ib_3d",

        "ib_wushi",
        "tbt_wushi",
        "ib_yifu",
        "tbt_yifu",
        "ib_beishi",
        "tbt_beishi",

        "lb_bj_wushi",
        "lb_bj_yifu",
        "lb_bj_beishi",

        "cvs_right",
        "btn_select",
        "tbt_choice",

        "cvs_get",
        "lb_select1",
        "lb_select2",
        "lb_select3",
        "cvs_item",
        "sp_fasion",

        "cvs_below",
        "lb_mingcheng",
        "cvs_shuxing",
        "lb_shuxing1",
        "lb_shuxing2",
        "lb_shuxing3",
        "lb_shuxing4",
        "lb_num1",
        "lb_num2",
        "lb_num3",
        "lb_num4",

        "btn_equip",
        "btn_shichuan",
        "btn_tujing",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.btn_tujian.TouchClick = function(sender)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFashionSuit, 0)
    end

    self.cvs_item.Visible = false
    self.cvs_below.Visible = false

    self.tbt_wushi.UserTag = 1
    self.tbt_yifu.UserTag = 2
    self.tbt_beishi.UserTag = 3

    self.leftPosX = self.cvs_right.X
    self.rightPosX = self.cvs_right.X + self.cvs_right.Width
    self.tbt_choice.TouchClick = function(sender)
        sender.Enable = false
        local x = self.leftPosX
        if sender.IsChecked == true then
            x = self.rightPosX
        end
        local moveAction = MoveAction.New()
        moveAction.TargetX = x
        moveAction.TargetY = self.cvs_right.Y
        moveAction.Duration = 0.3
        self.cvs_right:AddAction(moveAction)
        moveAction.ActionFinishCallBack = function()
            sender.Enable = true
        end
    end

    self.fashionAllList = GlobalHooks.DB.Find("Fashion",{Pro = DataMgr.Instance.UserData.Pro})
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/fashion/shizhuang.gui.xml", GlobalHooks.UITAG.GameUIFashionMain)
    self.menu.ShowType = UIShowType.HideBackHud
    self.menu.mRoot.Enable = false
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

local function initial()
    
end

return {Create = Create, initial = initial}
