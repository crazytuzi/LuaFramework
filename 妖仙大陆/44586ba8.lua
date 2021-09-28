local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"
local PetModelBase          = require 'Zeus.UI.XmasterPet.PetModelBase'

local self = {menu = nil}

local function ClearModel()
    
    if self.Model3DGameObj ~= nil then
        GameObject.Destroy(self.Model3DGameObj)
        IconGenerator.instance:ReleaseTexture(self.Model3DAssetBundel)
        self.Model3DGameObj = nil
        self.Model3DAssetBundel = nil
    end
end

local function Refresh3DModel(cvs, str)
    ClearModel()

    self.Model3DGameObj, self.Model3DAssetBundel = GameUtil.Add3DModel(cvs, str, nil, "", 0, true)
    IconGenerator.instance:SetModelScale(self.Model3DAssetBundel, Vector3.New(1,1, 1))
    IconGenerator.instance:SetModelPos(self.Model3DAssetBundel, Vector3.New(0.1, -0.5, 2))
    IconGenerator.instance:SetCameraParam(self.Model3DAssetBundel, 0.1, 50, 5)
    IconGenerator.instance:SetRotate(self.Model3DAssetBundel, Vector3.New(0, 140, 0))
end

local function UpdateItemList(datalist)
    local count = #datalist
    for i=1,7 do
        local node = self.ItemNodeList[i]
        local show = false
        if i <= count then
            local data = datalist[i]
            node.Visible = true
            local cvs_icon = node:FindChildByEditName("cvs_icon", true)
            local ib_already = node:FindChildByEditName("ib_already", true)
            ib_already.Visible = data.state == 2

            local btn_get = node:FindChildByEditName("btn_get", true)
            btn_get.Visible = data.state < 2
            btn_get.Enable = data.state < 2
            btn_get.IsGray = data.state == 0

            local detail, itshow

            if i <= 6 then
                detail = ItemModel.GetItemDetailByCode(data.itemcode)
                itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,data.itemcount,false)
                Util.NormalItemShowTouchClick(itshow,data.itemcode,false)

                local ib_texiao = node:FindChildByEditName("ib_texiao", true)
                ib_texiao.Enable = false
                ib_texiao.Visible = data.state == 1
            else
                Refresh3DModel(cvs_icon,data.itemmodel)
                local ib_effect = node:FindChildByEditName("ib_effect", true)
                ib_effect.Visible = data.state == 1
                cvs_icon.TouchClick = function (sender)
                    EventManager.Fire('Event.OnPreviewItems',{items = {{code = data.itemcode, groupCount = data.itemcount}}})
                end
            end
            btn_get.TouchClick = function (sender)
                if data.state == 0 then
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY,'noGetAwardTime'))
                elseif data.state == 1 then
                    ActivityAPI.SevenDayPackageAwardRequest(data.packageId, function()
                        if self.menu then
                            data.state = 2
                            UpdateItemList(datalist)
                        end
                    end)
                end
            end
        else
            self.ItemNodeList[i].Visible = false
        end
    end
end

local function updateTimeAndDesc(beginTime, endTime, desc)
    self.tb_time.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, desc)
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.SevenDayPackageGetInfoRequest(function(data)
            updateTimeAndDesc(data.endTime,data.endTime,data.describe)
            UpdateItemList(data.sevenDayPackageAwardInfo or {})
        end)
    end
end

function  _M.OnEnter()
    RequestInfo()
end
function _M.OnExit()
    ClearModel()
end

local ui_names = 
{
    {name = 'tb_time'},
    {name = 'cvs_type1'},
    {name = 'cvs_type2'},
    {name = 'cvs_type3'},
    {name = 'cvs_type4'},
    {name = 'cvs_type5'},
    {name = 'cvs_type6'},
    {name = 'cvs_type7'},
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

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu,ui_names,self)

    self.ItemNodeList = {self.cvs_type1,self.cvs_type2,self.cvs_type3,self.cvs_type4,self.cvs_type5,self.cvs_type6,self.cvs_type7}

    return self.menu
end

local function Create(ActivityID,xmlPath)
    self = {}
    self.ActivityID = ActivityID
    setmetatable(self, _M)
    local node = InitComponent(self,xmlPath)
    return self,node
end

return {Create = Create}
