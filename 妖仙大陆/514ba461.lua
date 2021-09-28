local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Item = require "Zeus.Model.Item"
local TreeView = require "Zeus.Logic.TreeView"
local BloodSoulAPI = require "Zeus.Model.BloodSoul"


local self = {
    menu = nil,
}

local function getTreeIndex(param)
    param = tonumber(param)
    local root = 1
    local sub = 1
    local index = 1
    for i,v in ipairs(self.TreeViewList) do
        for _,k in ipairs(v.subInfo) do
            if k.SuitID2 == param then
                root = i
                sub = _
                return {root, sub, index}
            end
            index = index + 1
        end
    end

    if root == 1 and sub == 1 then
        index = 1
    end
    return {root, sub, index}
end

local function getIndex(root, sub)
    local index = 1
    if root == 1 then
        index = sub
    elseif root == 2 then
        index = sub+7
    elseif root == 3 then
        index = sub+11
    end
    return index
end

local function OnEnter()
    BloodSoulAPI.GetEquipedBloodsRequest(DataMgr.Instance.UserData.RoleID, function(data)
        self.equipList = data
        local tmp = getTreeIndex(self.menu.ExtParam)
        self.treeView:selectNode(tmp[1],tmp[2],true)
        self.subNodeList[tmp[3]].IsChecked = true
    end)
end

local function OnExit()

end

local ui_names = 
{
  
  {name = 'btn_close'},

  {name = 'sp_list'},
  {name = 'cvs_item'},
  {name = "cvs_right"},

  {name = 'cvs_icon'},
  {name = 'lb_suitname'},
  {name = 'lb_desc'},

  {name = 'lb_attValue'},
  {name = 'sp_value'},
}

local function UpdateAttrItem(cell,data,index, hasCount)
    local title = "                  "
    if index == 1 or index == 3 then
        title = Util.GetText(TextConfig.Type.ITEM, "activeBloodSoul", data.PartReqCount)
    end

    local attrdata = GlobalHooks.DB.Find('Attribute', tonumber(data.Prop))

    if attrdata.isFormat == 1 then
        local v = data.Num / 100
        cell.Text = title .. string.gsub(attrdata.attDesc,'{A}',string.format("%.2f",v))
    else
        local v = Mathf.Round(data.Num)
        cell.Text = title .. string.gsub(attrdata.attDesc,'{A}',tostring(v))
    end

    if hasCount >= data.PartReqCount then
        cell.FontColor = Util.FontColorGreen
    else
        cell.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xFFDDF2FF)
    end
end

local function UpdateSuitAttr(suitId, hasCount)
    local suitAttrList = GlobalHooks.DB.Find('BloodSuitConfig',{SuitID = suitId})
    self.sp_value:Initialize(self.lb_attValue.Width, self.lb_attValue.Height+5, #suitAttrList, 1, self.lb_attValue,
      function(x, y, cell)
          UpdateAttrItem(cell,suitAttrList[y + 1], y + 1, hasCount)
      end,
      function()
      end
    )
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

local function InitClassify(tag)
    local root = math.floor(tag/10)
    local sub = tag%10
    local data = self.TreeViewList[root].subInfo[sub]
    if data then
        self.cvs_right.Visible = true
        Util.ShowItemShow(self.cvs_icon, data.Icon1, data.Quality)

        self.lb_desc.UnityRichText = data.SuitDesc
        self.lb_suitname.Text = data.SuitName

        local equiplist = string.split(data.PartCodeList, ",")
        local hasCount = 0
        for i,v in ipairs(equiplist) do
            local cvs_blood = self.menu:FindChildByEditName('cvs_blood'..i, true)
            if UpdateSuitChildItem(cvs_blood, v) then
                hasCount = hasCount + 1
            end
        end

        UpdateSuitAttr(data.SuitID2, hasCount)
    else
        self.cvs_right.Visible = false
    end
end

local function GetTreeViewCount()
    local suitList = BloodSoulAPI.GetAllBloodSuitList()
    local treeList = GlobalHooks.DB.GetFullTable("BloodTips")

    local list = {}
    for i,v in ipairs(treeList) do
        local childList = {}
        for _,k in ipairs(suitList) do
            if v.ID == k. BloodType then
              table.insert(childList, k)
            end
        end
        table.insert(list, {rootInfo = v, subInfo = childList})
    end
    return list
end

local function CreatTreeView()
    local sp_type = self.menu.mRoot:FindChildByEditName("sp_type", true)
    local cvs_typename = self.menu.mRoot:FindChildByEditName("cvs_typename", true)
    local tbt_subtype = self.menu.mRoot:FindChildByEditName("tbt_subtype", true)

    local subValues = {}
    self.TreeViewList = GetTreeViewCount()
    self.treeView = TreeView.Create(#self.TreeViewList,0,self.sp_list.Size2D,TreeView.MODE_SINGLE)
    local function rootCreateCallBack(index,node)
        node.Enable = true
        local lb_title = node:FindChildByEditName("lb_typename", false)
        lb_title.Text = self.TreeViewList[index].rootInfo.Tips
    end
    local function rootClickCallBack(node,visible)
        local tbt_open = node:FindChildByEditName("tbt_open",false)
        tbt_open.IsChecked = visible
        if visible == true then
          XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        end
    end
    local rootValue = TreeView.CreateRootValue(cvs_typename,#self.TreeViewList,rootCreateCallBack,rootClickCallBack)

    self.subNodeList = {}
    local function subClickCallback(rootIndex,subIndex,node)

    end
    local function subCreateCallback(rootIndex,subIndex,node)
        node.UserTag = rootIndex*10+subIndex
        node.Enable = true
        node.IsChecked = false
        node.Text = self.TreeViewList[rootIndex].subInfo[subIndex].SuitName
        table.insert(self.subNodeList, node)
    end

    for i=1,#self.TreeViewList do
        subValues[i] = TreeView.CreateSubValue(i,tbt_subtype,#self.TreeViewList[i].subInfo, subClickCallback, subCreateCallback)
    end
    self.treeView:setValues(rootValue,subValues)
    self.sp_list:AddNormalChild(self.treeView.view)
    local rootViews = self.treeView:GetRootView()
    local subViews = self.treeView:GetSubViews()
    
    Util.InitMultiToggleButton( function(sender)
        InitClassify(sender.UserTag)
    end , nil, self.subNodeList)
end

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    
    self.lb_attValue.Visible = false

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end
    
    self.cvs_item.Visible = false
    CreatTreeView()
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/bloodsoul/bloodsuit.gui.xml", GlobalHooks.UITAG.GameUIBloodSuit)
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
