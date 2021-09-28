local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local MountModel        = require "Zeus.Model.Mount"
local RideModelBase     = require 'Zeus.UI.XmasterRide.RideModelBase'

local self = {
	menu = nil,
}

local SkinStatus = {
    Status_Lock = 0,
    Status_Unlock = 1,
    Status_Using = 2,
}

local qualityIndex = {2,3,4,5,1}

local function ReqUseSkin(id)
    MountModel.activeMountSkinRequest(id, function ()
          OnEnter()
    end)
end

local function ReqWaysSkin(id)
    local data = MountModel.GetSkinDataById(id)
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, data.Code)
end

local function DestoryMod()
    if self.modObj ~=nil then
        RideModelBase.ClearModel(self.modObj)
        self.modObj = nil
    end
end

local function RefreshSkinName(id)
    local nameString = MountModel.GetSkinDataById(id).SkinName
    local SkinQColor = MountModel.GetSkinDataById(id).SkinQColor
    self.lb_name.Text = nameString
    self.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(SkinQColor)
    
    self.ib_used.Visible = self.CurSelectIndex == self.RideData.usingSkinID
end

local function Refresh3dModel(id)
    
    local modelFile = MountModel.GetSkinDataById(id).ModelFile
    if self.modObj ~= nil then
        DestoryMod()
    end
    self.modObj = {}
    RideModelBase.InitModelAvaterstr(self.modObj, self.cvs_3d, modelFile, nil, false, self.RideData.usingSkinID)
    IconGenerator.instance:SetBackGroundImage(self.modObj.Model3DAssetBundel, "Textures/IconGenerator/mountshowbk")
end

local function RefreshSkinAttr(skinId, cans)
    local list = MountModel.GetSkinAttrById(skinId)
    for k,v in pairs(list) do
        if k <= 4 then
            local label = cans:FindChildByEditName("tb_attr"..k,true)
            label.XmlText = MountModel.GetAttrString(v.name, v.maxValue)
            label.TextComponent.Anchor = TextAnchor.L_C
            label.Visible = v.maxValue > 0
        end
    end
end


local function SkinAttributes(cans)  
    local AllAttributeArr = {}
    local AttributeName = {}
    local FinalAttributeArr = {}

    for i=1,6 do        
        AttributeName[i] = {}
        FinalAttributeArr[i] = 0 
    end
    
    for i=1, #self.RideData.mountSkins do 
        AllAttributeArr[i] = {}
    end

    for i=1,#self.RideData.mountSkins do        
        local v = self.RideData.mountSkins[i]
        local list = MountModel.GetSkinAttrById(v)    
        
        local AttributeArr = {}
        for x=1, 6 do
            AttributeArr[x] = 0
        end
       
        for y,m in pairs(list) do
            if y <= 6  then
                AttributeName[y] = m.name
                AttributeArr[y] = m.maxValue  
            end
        end      
        AllAttributeArr[i] = AttributeArr  
    end

    for i=1, 6 do
        for z =1,#AllAttributeArr do
            if i == 1 then
                if FinalAttributeArr[i] < AllAttributeArr[z][i] then
                    FinalAttributeArr[i] = AllAttributeArr[z][i]
                end               
            else
                FinalAttributeArr[i] = FinalAttributeArr[i] + AllAttributeArr[z][i]
            end
        end
    end
  
    for i=1, 6 do
        local label = cans:FindChildByEditName("tb_attr"..i,true)
        if i == 1 then
            FinalAttributeArr[i] = FinalAttributeArr[i] / 100
            label.XmlText = MountModel.NewGetAttrString(AttributeName[i], FinalAttributeArr[i].."%")
        else
            label.XmlText = MountModel.GetAttrString(AttributeName[i], FinalAttributeArr[i])
        end       
        label.TextComponent.Anchor = TextAnchor.L_C
        label.Visible = FinalAttributeArr[i] > 0
        if FinalAttributeArr[i] ~= 0 then
            local lb_tip1 = cans:FindChildByEditName("lb_tip1", true)
            local lb_tip2 = cans:FindChildByEditName("lb_tip2", true)
            lb_tip1.Visible = false
            lb_tip2.Visible = false
        end
        
    end
end




local function SkinRefreshSkinAttr(skinId, cans)
    
    local list = MountModel.GetSkinAttrById(skinId)
    for k,v in pairs(list) do
        if k <= 6  then
            local label = cans:FindChildByEditName("tb_attr"..k,true)
            if k == 1 then
                v.maxValue = v.maxValue / 100
                label.XmlText = MountModel.NewGetAttrString(v.name, v.maxValue.."%")
            else
                label.XmlText = MountModel.GetAttrString(v.name, v.maxValue)  
            end     
            label.TextComponent.Anchor = TextAnchor.L_C
            label.Visible = v.maxValue > 0
            local VisibleBool = true
            for i = 1, #self.RideData.mountSkins do 
                local _i = self.RideData.mountSkins[i]
                if(skinId == _i) then
                    VisibleBool = false
                end
            end
            label = cans:FindChildByEditName("ib_icon",true)
            label.Visible = VisibleBool
            label = cans:FindChildByEditName("lb_subtitle1",true)
            label.Visible = VisibleBool
        end
    end
end





local function IsSkinLock(id)
    if id == self.RideData.usingSkinID then
        return SkinStatus.Status_Using
    end
    for _,v in ipairs(self.RideData.mountSkins) do
        if v == id then
            return SkinStatus.Status_Unlock
        end
    end
    return SkinStatus.Status_Lock
end

local function RefreshBtnstatus(id)
    local status = IsSkinLock(id)
    local string = "used"
    if status == SkinStatus.Status_Using then
        
        self.btn_use.Visible = false
        self.btn_use.TouchClick = function(sender)
            ReqUseSkin(1)
        end
    elseif status == SkinStatus.Status_Unlock then
        self.btn_use.Visible = true
        string = "use"
        self.btn_use.TouchClick = function(sender)
            ReqUseSkin(id)
            local params = GlobalHooks.DB.Find("SkinList", {SkinID=id})[1].Sound
            XmdsSoundManager.GetXmdsInstance():PlaySound(params)
        end
    elseif status == SkinStatus.Status_Lock then
        self.btn_use.Visible = true
        string = 'ways'
        self.btn_use.TouchClick = function(sender)
            ReqWaysSkin(id)
        end
    end
    self.btn_use.Text = Util.GetText(TextConfig.Type.MOUNT, string)
end

local function SelectItem(id)
    if self.CurSelectIndex > 0 and self.CurSelectItem ~= nil then
        self.CurSelectIndex = 0
        self.CurSelectItem.Enable = true
        self.CurSelectItem:FindChildByEditName("ib_chosen",true).Visible = false
    end
    self.CurSelectIndex = id
    self.CurSelectItem = self.itemNodes[id]
    self.CurSelectItem.Enable = false
    self.CurSelectItem:FindChildByEditName("ib_chosen",true).Visible = true

    RefreshBtnstatus(id)
    RefreshSkinName(id)
    Refresh3dModel(id)
    SkinRefreshSkinAttr(id, self.cvs_prop)
end

local function itemOnClick(sender)
    SelectItem(sender.UserTag)
    self.PlaySoundsiknId = sender.UserTag
    
    
end

local function InitNodeWithIndex(node, index)
    node.UserTag = index
    node.X = ((index-1)%self.columns)*(self.cvs_item.Size2D.y+17)
    node.Y = (math.floor((index-1)/self.columns))*(self.cvs_item.Size2D.x+15)

    local data = self.SkinsData[index]

    local icon = node:FindChildByEditName("ib_icon",true)
    local frame = node:FindChildByEditName("ib_frame",true)
    Util.HZSetImage2(frame, "#static_n/bag_quality/bag_quality.xml|bag_quality|"..qualityIndex[data.SkinQColor+1])

    local filepath = "dynamic_n/mount_icon/"..data.Icon..".png"
    Util.HZSetImage(icon,filepath,false,LayoutStyle.IMAGE_STYLE_BACK_4)

    node.TouchClick = function(sender)
        itemOnClick(sender)
    end
end

local function RefreshLockStatus()
    
    for i=1,self.itemCount do
        local lock = IsSkinLock(i)
        self.itemNodes[i]:FindChildByEditName("ib_lock",true).Visible = lock == SkinStatus.Status_Lock
    end
end

local function InitPageScroll()
    self.itemNodes = {}
    self.itemCount = #self.SkinsData

    self.columns = 4
    self.row = math.ceil(self.itemCount/self.columns)
    for i=1,self.itemCount do
        local node = self.cvs_item:Clone()
        node.Visible = i <= self.itemCount
        InitNodeWithIndex(node,i)
        self.sp_skin.Scrollable.Container:AddChild(node)
        self.itemNodes[i] = node
    end
    
end


local function OnPlayAnimationSound()
    print(self.PlaySoundsiknId)
    local params = GlobalHooks.DB.Find("SkinList", {SkinID=self.PlaySoundsiknId})[1].Sound
    XmdsSoundManager.GetXmdsInstance():PlaySound(params)
end


local function _OnEnte()


    
    MountModel.getMountInfoRequest(function ()

        self.RideData = MountModel.GetMyMountInfo()
        
        
        
    
        if self.RideData == nil then return end
    
        RefreshLockStatus()  
        SkinAttributes(self.cvs_prop1)
        SelectItem(self.RideData.usingSkinID)
    end)

end

local function OnExit()
    self.RideData = nil
    self.SkinsData = nil

    DestoryMod()
    EventManager.Unsubscribe("Event.IniRideSkin", _OnEnte)
    EventManager.Unsubscribe("Event.PlayAnimationSound", OnPlayAnimationSound)
end

function OnEnter()
    
    self.RideData = MountModel.GetMyMountInfo()
    if self.RideData == nil then return end
    
    
    
    

    RefreshLockStatus()
    SkinRefreshSkinAttr(self.RideData.usingSkinID, self.cvs_prop)
    SkinAttributes(self.cvs_prop1)
    SelectItem(self.RideData.usingSkinID)
    EventManager.Subscribe("Event.IniRideSkin", _OnEnte)
    EventManager.Subscribe("Event.PlayAnimationSound", OnPlayAnimationSound)
end

local function InitUI()
    local UIName = {
		"cvs_main_center",
        "cvs_3d",
        "lb_name",
        "ib_used",
        
        "cvs_total",
        "cvs_prop1",
        "cvs_prop",
        

        "cvs_culture",
        "sp_skin",
        "cvs_item",
        "btn_left",
        "btn_right",
        "lb_page",

        "btn_use",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_item.Visible = false

    
    self.CurSelectIndex = 0
    self.CurSelectItem = nil
    self.SkinsData = MountModel.GetAllSkinList()
    InitPageScroll()
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
	self.menu = LuaMenuU.Create("xmds_ui/ride/skin.gui.xml", GlobalHooks.UITAG.GameUIRideSkin)
	self.menu.Enable = false
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
