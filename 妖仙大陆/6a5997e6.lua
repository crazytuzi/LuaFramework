local _M = {}
_M.__index = _M

local Bit           = require 'bit'
local Item          = require "Zeus.Model.Item"
local Util          = require "Zeus.Logic.Util"
local ItemModel     = require 'Zeus.Model.Item'
local FashionModel  = require "Zeus.Model.Fashion"


local self = {
    menu = nil,
    jihuotwo = nil,
    jihuothree = nil,
}

local function GetFashionData(suitId,param)
    for i,v in ipairs(self.fashionAllList) do
        if v.FashionID == suitId and v.Type == param then
            return v
        end
    end

    return nil
end

local function IsGetFashion(code)
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
    return false
end

local function ShowAllAttrList()
    local attrList = {}

    local function insertAttr(id, value)
        for i,v in ipairs(attrList) do
            if v.id == id then
                v.value = v.value + value
                return
            end
        end
        table.insert(attrList, {id = id, value = value})
    end

    for i,v in ipairs(self.suitAllList) do
        local hasCount = 0
        local fashion1 = GetFashionData(v.SuitID,1)
        local fashion2 = GetFashionData(v.SuitID,2)
        local fashion3 = GetFashionData(v.SuitID,3)
        if fashion1 and IsGetFashion(fashion1.Code) then
            hasCount = hasCount + 1
        end
        if fashion2 and IsGetFashion(fashion2.Code) then
            hasCount = hasCount + 1
        end
        if fashion3 and IsGetFashion(fashion3.Code) then
            hasCount = hasCount + 1
        end
        
        if hasCount >= 2 then
            local list = string.split(v.Attr2,";")
            for _,k in ipairs(list) do
                local str = string.split(k,":")
                local id = str[1]
                local value = str[2]
                insertAttr(id,value)
            end
        end
        if hasCount >= 3 then
            local list = string.split(v.Attr3,";")
            for _,k in ipairs(list) do
                local str = string.split(k,":")
                local id = str[1]
                local value = str[2]
                insertAttr(id,value)
            end
        end
    end

    self.sp_value:Initialize(self.lb_attValue.Width+40, self.lb_attValue.Height+5, #attrList, 1, self.lb_attValue, 
        function(gx, gy, node)
            local attr = attrList[gy+1]
            if attr then
                local attrEle = GlobalHooks.DB.Find('Attribute', tonumber(attr.id))
                node.Text = "      " .. string.gsub(attrEle.attDesc,'{A}',tostring(attr.value))
            else
                node.Text = ""
            end
        end, 
        function(node)
            node.Visible = true
        end
    )
    self.cvs_value.Visible = true
end

local function UpdateSelectAttr(data)
    local function getInfo(label, param)
        local fashion = GetFashionData(data.SuitID,param)
        label.Text = fashion.Name
        if IsGetFashion(fashion.Code) then
            label.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xFF00F012)
            return 1
        else
            label.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xFFDDF2FF)
            return 0
        end
    end

    local hasCount = getInfo(self.lb_taozhuang1, 1) + getInfo(self.lb_taozhuang2, 2) + getInfo(self.lb_taozhuang3, 3)
    self.lb_suit_name.Text = data.Name .. "(" .. hasCount .. "/" .. 3 .. ")"

    local text = "<f><name color='FFDDF2FF'>%s</name><name color='FFDDF2FF'>%s</name></f>"
    if hasCount == 2 then
        text = "<f><name color='FF00F012'>%s</name><name color='FFDDF2FF'>%s</name></f>"
    elseif hasCount == 3 then
        text = "<f><name color='FF00F012'>%s</name><name color='FF00F012'>%s</name></f>"
    end
    
    local function GetAttrsString(attrList, title)
        local string = ""
        for i,v in ipairs(attrList) do
            local attr = string.split(v, ":")
            local id = attr[1]
            local value = attr[2]
            local attrEle = GlobalHooks.DB.Find('Attribute', tonumber(id))
            
            local add = "                    "
            if i == 1 then
                add = title
            end
            string = string .. add .. string.gsub(attrEle.attDesc,'{A}',tostring(value)) .. "\n"
        end
        return string .. "\n"
    end
    local text1 = GetAttrsString(string.split(data.Attr2, ";"),self.jihuotwo )
    local text2 = GetAttrsString(string.split(data.Attr3, ";"), self.jihuothree)
    self.tb_set_detail.XmlText = string.format(text, text1 ,text2)
end

local function ShowItemShow(node, data, param)
    local detail = ItemModel.GetItemDetailByCode(data.Code)
    local cvs_icon = node:FindChildByEditName("cvs_icon",true)
    local ib_suoding = node:FindChildByEditName("ib_suoding",true)

    if not detail then
        cvs_icon.Visible = false
        ib_suoding.Visible = false
    else
        local hasGet = IsGetFashion(data.Code)
        local itshow = Util.ShowItemShow(cvs_icon, detail.static.Icon, detail.static.Qcolor)
        Util.NormalItemShowTouchClick(itshow,data.Code)
        cvs_icon.Visible = true
        ib_suoding.Visible = not hasGet
    end
end

local function GetShowAvatarList(data)
    local fashion = GetFashionData(data.SuitID, 1)
    local avtTab = {}
    if fashion and not string.empty(fashion.AvatarId) then
        local ava = {
                        fileName = fashion.AvatarId,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.R_Hand_Weapon),
                    }
        table.insert(avtTab,ava)
    end
    ShowItemShow(self.cvs_item1,fashion,1)

    local fashion = GetFashionData(data.SuitID, 2)
    if fashion and not string.empty(fashion.AvatarId) then
        local ava = {
                        fileName = fashion.AvatarId,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Avatar_Body),
                    }
        table.insert(avtTab,ava)
    end
    ShowItemShow(self.cvs_item2,fashion,2)

    local fashion = GetFashionData(data.SuitID, 3)
    if fashion and not string.empty(fashion.AvatarId) then
        local ava = {
                        fileName = fashion.AvatarId,
                        effectType = 0,
                        PartTag = GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Rear_Equipment),
                    }
        table.insert(avtTab,ava)
    end
    ShowItemShow(self.cvs_item3,fashion,3)

    return avtTab
end

local function Clear3dModel()
    if self.avatarKey and self.avatarObj then
        UnityEngine.Object.DestroyObject(self.avatarObj)
        IconGenerator.instance:ReleaseTexture(self.avatarKey)
    end
    self.avatarObj = nil
    self.avatarKey = nil
end

local function Update3dModel(data)
    Clear3dModel()

    local avatarList = GetShowAvatarList(data)

    self.ib_3d.Enable = true
    self.ib_3d.EnableChildren = true
    self.ib_3d.IsInteractive = true

    local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
    local obj, key = GameUtil.AddLua3DFashionModel(self.ib_3d, avatarList, '', nil, filter, true)
    if IsNil(obj) then
        return
    end
    IconGenerator.instance:SetModelPos(key, Vector3.New(0.2, -1.1, 3))
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

local function SelectSuitNode(index)
    local node = self.suitNodeList[index]
    local data = self.suitAllList[index]

    if self.selectNode and self.selectNode.UserTag ~= node.UserTag then
        local ib_select = self.selectNode:FindChildByEditName("ib_select",true)
        ib_select.Visible = false
        self.selectNode.Enable = true
    end

    local ib_select = node:FindChildByEditName("ib_select",true)
    ib_select.Visible = true
    node.Enable = false
    self.selectNode = node

    Update3dModel(data)
    UpdateSelectAttr(data)
end

local function OnExit()
    Clear3dModel()
end

local function OnEnter()
    Clear3dModel()

    FashionModel.GetFashionsRequest(function (data)
        self.fashionList = data
        
        
        if self.suitCount > 0 then
            SelectSuitNode(1)
        end
    end)
end

local function InitUI()
    local UIName = {
        "btn_close",

        "cvs_suit",
        "cvs_right",
        "cvs_renwu",

        "sp_suit",
        "cvs_left",
        "sp_suit",

        "ib_3d",
        "cvs_item1",
        "cvs_item2",
        "cvs_item3",

        "lb_suit_name",
        "lb_taozhuang1",
        "lb_taozhuang2",
        "lb_taozhuang3",
        "tb_set_detail",

        "btn_zongjiacheng",
        "cvs_value",
        "sp_value",
        "lb_attValue",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.jihuotwo = Util.GetText(TextConfig.Type.SUIT, "jihuotwo")
    self.jihuothree = Util.GetText(TextConfig.Type.SUIT, "jihuothree")

    self.cvs_left.Visible = false
    self.cvs_value.Visible = false
    self.lb_attValue.Visible = false

    self.fashionAllList = GlobalHooks.DB.Find("Fashion",{Pro = DataMgr.Instance.UserData.Pro})
    self.suitAllList = GlobalHooks.DB.Find("FashSuitConfig",{Pro = DataMgr.Instance.UserData.Pro})

    self.suitCount = #self.suitAllList

    self.suitNodeList = {}
    for i=1,self.suitCount do
        local node = self.cvs_left:Clone()
        local data = self.suitAllList[i]
        local ib_suiName = node:FindChildByEditName("ib_suiName",true)
        ib_suiName.Text = data.Name
        local ib_select = node:FindChildByEditName("ib_select",true)
        ib_select.Visible = false
        node.Visible = true
        node.Enable = true
        node.UserTag = i
        node.Y = (node.Height+5)*(i-1)
        node.TouchClick = function(sender)
            SelectSuitNode(i)
        end
        table.insert(self.suitNodeList,node)
        self.sp_suit.Scrollable.Container:AddChild(node)
    end

    self.cvs_suit.Visible = self.suitCount > 0
    self.cvs_right.Visible = self.suitCount > 0
    self.cvs_renwu.Visible = self.suitCount > 0

    self.btn_zongjiacheng.TouchClick = function(sender)
        ShowAllAttrList()
    end

    self.cvs_value.TouchClick = function(sender)
        self.cvs_value.Visible = false
    end
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
    self.menu = LuaMenuU.Create("xmds_ui/fashion/tujian.gui.xml", GlobalHooks.UITAG.GameUIFashionSuit)
    self.menu.mRoot.Enable = false
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

local function initial()
    
end

return {Create = Create, initial = initial}
