

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'

local Bit    = require 'bit'
local TitleAPI = require "Zeus.Model.Title"
local MoreProView = require "Zeus.UI.XmasterActor.UIPropertyDetail"
local GameUIEquipmentList = require "Zeus.UI.XmasterActor.UIEquipmentList"
local EventItemDetail = require "Zeus.UI.XmasterBag.EventItemDetail"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"
local ItemModel = require 'Zeus.Model.Item'
local Player = require "Zeus.Model.Player"

local _M = { }
_M.__index = _M

local self = {
    menu = nil,
}

local nameColorIndex = {3,2,1,4,0}

local EQUIP_PARTS = {
    "cvs_cell1",
    "cvs_cell2",
    "cvs_cell3",
    "cvs_cell4",
    "cvs_cell5",
    "cvs_cell6",
    "cvs_cell7",
    "cvs_cell8",
    "cvs_cell9",
    "cvs_cell10",
}

local ui_names = {
    {name = "lb_qufu1"},
    {name = "lb_name"},
    {name = "lb_title",},
    {name = "cvs_title_click",click = function(self)
        self:OpenTitleList()
    end},
    {name = "btn_change",click = function(self)
        self:OpenTitleList()
    end},
    {name = "cvs_title_box"},
    {name = "lb_title_none"},
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
    {name = "gg_exp"},
    {name = "lb_hp_num"},
    {name = "lb_exp_num"},
    {name = "lb_lv_num"},
    
    {name = "lb_state_num"},
    {name = "btn_gantanhao",click = function(self)

    end},
    {name = "btn_tupo",click = function(self)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIUpStairs, 0)
    end},
    {name = "btn_duihuan",click = function(self)
        local needLv = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Exchange.OpenLV"})[1].ParamValue)
        if DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) >= needLv then
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIAttrExchange, 0)
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE, 121, needLv))
        end
    end},
    {name = "btn_morepro",click = function(self)
        self:OpenMoreProView()
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
    {name = "cvs_property"},
    {name = "cvs_character"},
    {name = "cvs_information_detailed"},
    {name = "cvs_pro1_none"},
    {name = "cvs_pro1"},
    {name = "lb_tipsup"},
    {name = "lb_pk2"},
    {name = "btn_pk"},
    {name = "tbx_pk"},
    {name = "sp_redpoint_Level" },
    {name = "lb_titlename"},
    {name = "btn_fashion" },
    {name = "lb_bj_fashion" },
}
local effectTab ={}
local redPointTab = {}
local curSelectIndex = 0
local function SetAttrText(status, node, v, isFormat)
    local txt
    local userdata = DataMgr.Instance.UserData
    if userdata:ContainsKey(status, v) then
        local num = userdata:TryToGetLongAttribute(v,0)
        num = num~=nil and num or 0
        if isFormat then
            txt = tostring(num/100) .. '%'
        else
            txt = tostring(num)
        end
    end
    if txt then
        node.Text = txt
    end
end

function _M:OpenMoreProView()





    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleAttributeMain, 0)
end

function _M:OpenTitleList()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleTitleList, 0)
end

local function ShowEffect(item)
    if item then
        if item.Quality == 4 then
              if effectTab[curSelectIndex] ~= nil then
                    effectTab[curSelectIndex].Visible = true
              end
        end
    end
end
local function HideEffect()
     if effectTab[curSelectIndex] ~= nil then
        effectTab[curSelectIndex].Visible = false
     end
end

local function CheckIsCanCultivation()
    local num = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.REALM)
    num = num == nil and 0 or num

    local realmNext = GlobalHooks.DB.Find("UpLevelExp", { UpOrder = num + 1 })[1]
    local roleLevel= DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)

    local cultivation = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.CULTIVATION)
    cultivation = cultivation == nil and 0 or cultivation

     if roleLevel >= realmNext.ReqLevel then
          if self.flag ~= nil then
                   if self.flag > 0 then
                        if cultivation < realmNext.ReqClassExp then
                            self.sp_redpoint_Level.Visible = false
                            DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
                        else
                            self.sp_redpoint_Level.Visible = true
                        end
                    else
                            self.sp_redpoint_Level.Visible = false
                            DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
                    end
          end
     else
              self.sp_redpoint_Level.Visible = false
              DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
     end

end
local  itemTab = {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
local function initFilter(it,index)
    self.Container = HZItemsContainer.New()
    local rolebag = DataMgr.Instance.UserData.RoleBag
    self.Container.ItemPack = rolebag
    local ProTable = GlobalHooks.DB.Find('Character',DataMgr.Instance.UserData.Pro)
    self.filter_target = ItemPack.FilterInfo.New()
    self.filter_target.IsSequence = true
    self.filter_target.Type = ItemData.TYPE_EQUIP
    self.filter_target.CheckHandle = function(item)
        local detail = item.detail
        if it ~= nil then 
            if detail and detail.static.Pro == ProTable.ProName and self.EquipContainer:GetIndex(it) == detail.itemSecondType then
    
                return true
            else
                return false
            end
        else 
                if detail and detail.static.Pro == ProTable.ProName and index == detail.itemSecondType then
        
                    return true
                else
                    return false
                end
         end
    end
    
    self.Container.Filter = self.filter_target
    local count = self.Container.Filter.ItemCount
    local lessNum = 0
    for i=1,self.Container.Filter.ShowData.Count do 
        local itemData = self.filter_target:GetItemDataAt(i)
        local score = itemData.detail.equip.score
        if it ~= nil and it.LastItemData ~= nil and  it.LastItemData.detail ~= nil then
            if score > it.LastItemData.detail.equip.score then
               if  DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) >= itemData.detail.static.LevelReq then
                   it.IsShowRedPoint = true 
               else
                   it.IsShowRedPoint = false 
               end
            else
                 lessNum = lessNum + 1
            end
        end
    end
    if lessNum >= self.Container.Filter.ShowData.Count then
         if it  then
            it.IsShowRedPoint = false
         end
    end
    if it == nil and count > 0 then
       if redPointTab ~= nil then
           redPointTab[index].Visible = true
       end
    end
    if it ~= nil then
      if redPointTab ~= nil then
           redPointTab[self.EquipContainer:GetIndex(it)].Visible = false
       end
    end
end

local function CheckIsHideAll()
     local showNum1 = 0
     local showNum2 = 0
     if itemTab ~= nil then 
         for _,v in pairs(itemTab) do 
              if v.IsShowRedPoint then
                showNum1 = showNum1 + 1
              end
         end
     end
     if redPointTab ~= nil then
         for k,v in ipairs(redPointTab) do 
              if v.Visible == true then
                 showNum2 = showNum2 + 1
              end
         end   
     end
     if showNum1 < 1 and showNum2 < 1  then
              return true
     else
              return false
     end
end

function _M.Notify(status, userdata, self)
    if userdata:ContainsKey(status, UserData.NotiFyStatus.HP) or
        userdata:ContainsKey(status, UserData.NotiFyStatus.MAXHP) then
        local hp = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.HP,0)
        local maxhp = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.MAXHP,0)
        self.gg_hp:SetGaugeMinMax(0, math.floor(maxhp))
        self.lb_hp_num.Text = tostring(hp) .. '/' .. tostring(maxhp)
        self.gg_hp.Value =(hp < maxhp and hp) or maxhp
    end
    CheckIsCanCultivation()







    if userdata:ContainsKey(status, UserData.NotiFyStatus.EXP) or
        userdata:ContainsKey(status, UserData.NotiFyStatus.NEEDEXP) then
        local need = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.NEEDEXP,0)
        local exp = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.EXP,0)
        self.gg_exp:SetGaugeMinMax(0, math.floor(need))
        self.gg_exp.Value =(exp < need and exp) or need
        self.lb_lv_num.Text = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
        self.lb_exp_num.Text = exp .. "/" .. need
    end

    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.UPLEVEL,0)
    local rqlv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.NEEDUPLV,0)
    local rolelv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    
    local num = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.REALM,0)
    num = num == nil and 0 or num
    local curRealm = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = num})[1]
    local realmClassid = 0
    if curRealm == nil then
        self.lb_state_num.Text = Util.GetText(TextConfig.Type.ATTRIBUTE,110)
    else
        self.lb_state_num.Text = curRealm.ClassName .. curRealm.UPName
        self.lb_state_num.FontColorRGBA = Util.GetQualityColorRGBA(curRealm.Qcolor)
        realmClassid = curRealm.ClassID
    end


    local nextRealm = GlobalHooks.DB.Find("UpLevelExp", {ClassID = realmClassid+1,ClassUPLevel =  1})[1]
    local maxLv = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Role.LevelLimit"})[1].ParamValue)

    if userdata:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0) >= maxLv then
        self.lb_tipsup.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 122)
        self.lb_tipsup.Visible = true
    elseif nextRealm~=nil and userdata:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0) == nextRealm.ReqLevel then
        self.lb_tipsup.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 123)
        self.lb_tipsup.Visible = true
    else
        self.lb_tipsup.Visible = false
    end
    
    
    
    
    
    
    
    
    
















    local num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.PHY,0)
    num = num~=nil and num or 0
    local phyNum = num
    num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.MAG,0)
    num = num~=nil and num or 0
    local magNum = num

    if magNum > phyNum then
        self.lb_attk1.Visible = false
        self.lb_attk2.Visible = true
        SetAttrText(status, self.lb_attk_num, UserData.NotiFyStatus.MAG)
    else
        self.lb_attk1.Visible = true
        self.lb_attk2.Visible = false
        SetAttrText(status, self.lb_attk_num, UserData.NotiFyStatus.PHY)
    end
    

    SetAttrText(status, self.lb_pyhdef_num, UserData.NotiFyStatus.AC)
    SetAttrText(status, self.lb_magdef_num, UserData.NotiFyStatus.RESIST)
    SetAttrText(status, self.lb_hit_num, UserData.NotiFyStatus.HIT)
    SetAttrText(status, self.lb_dod_num, UserData.NotiFyStatus.DODGE)
    SetAttrText(status, self.lb_crit_num, UserData.NotiFyStatus.CRIT)
    SetAttrText(status, self.lb_critres_num, UserData.NotiFyStatus.RESCRIT)
    SetAttrText(status, self.lb_FC, UserData.NotiFyStatus.FIGHTPOWER )
    SetAttrText(status, self.lb_critharm_num, UserData.NotiFyStatus.CRITDAMAGE,true)
    SetAttrText(status, self.lb_critharmres_num, UserData.NotiFyStatus.CRITDAMAGERES,true)

    local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_FASHION)
    self.lb_bj_fashion.Visible = num > 0
    
    return false
end

local function SetVisible(self,visible)
    self.menu.Visible = visible
    if self.uiItemList then
        self.uiItemList:Close()
    end
end

local function clean3dModel()
    if self.avatar_show then
        UnityEngine.Object.DestroyObject(self.avatar_show.obj)
        IconGenerator.instance:ReleaseTexture(self.avatar_show.key)
        self.avatar_show = nil
    end
end

local function add3dModel(avatarFile,cvs)
	local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
	local obj, key = GameUtil.Add3DModel(cvs, avatarFile, nil, "", filter, false)
	if IsNil(obj) then
		return
	end
	IconGenerator.instance:SetModelPos(key, Vector3.New(0, -0.98, 3.1))
    IconGenerator.instance:SetModelScale(key, Vector3.New(0.73, 1, 0.73))
	IconGenerator.instance:SetCameraParam(key, 0.3, 10, 2)
    
    IconGenerator.instance:SetLoadOKCallback(key, function (k)
		IconGenerator.instance:PlayUnitAnimation(key, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
		
    end)
	local t = {
		node = cvs,
		move = function (sender,pointerEventData)
			IconGenerator.instance:SetRotate(key,-pointerEventData.delta.x * 5)
		end, 
		up = function() end
	}
  LuaUIBinding.HZPointerEventHandler(t)
  return {key=key,obj=obj}
end

local function change3DModel(key, avatarFile)
	local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
	GameUtil.Change3DModel(key, avatarFile, '', filter)
end

local function SetAvatar(self,force)
    self.avatar_show = add3dModel("",self.cvs_3d)





end

local function OnTitleChanged(eventname, data)
    if data.titleId and data.titleId > 0 then

        self.lb_title_none.Visible = false

        local rankListData = GlobalHooks.DB.Find("RankList", {RankID=data.titleId})[1] 
        if rankListData~=nil then
           if rankListData.Show == "-1" then
              self.cvs_title_box.Visible = false
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
end


local function GetShowTips(pkvalue, pLv)
    
    local str = Util.GetText(TextConfig.Type.PK,'now_pknum')
    local data = {}
    data[1] = pkvalue
    data[2] = ""
    local min = pkvalue % 60
    local hour = math.floor(pkvalue / 60) % 24
    local day = math.floor(pkvalue / (60 * 24))
    if day > 0 then
        data[2] = data[2] .. day .. Util.GetText(TextConfig.Type.PK,'day')
    end
    if hour > 0 then
        data[2] = data[2] .. hour .. Util.GetText(TextConfig.Type.PK,'huor')
    end
    data[2] = data[2] .. min .. Util.GetText(TextConfig.Type.PK,'minute')
    data[3] = string.format("%08X",  GameUtil.RGBA_To_ARGB(GameUtil.GetPKLvColor(DataMgr.Instance.UserData:GetPKLv())))
    return  ChatUtil.HandleString(str, data) 
end

local function ShowPkValue(self)
    local pkvalue = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PKVALUE)
    local tbt_pk = self.menu:GetComponent("tbt_pk")
    local cvs_idol = self.menu:GetComponent("cvs_idol")
    local lb_pk = self.menu:GetComponent("lb_pk")
    lb_pk.Text = pkvalue

    tbt_pk.event_PointerDown = function( ... )
        
        tbt_pk.IsChecked = true
        local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShowXmlTips, 1)
        obj.SetXmlStr(GetShowTips(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PKVALUE)))

        local cvs = obj.content_node
        local v  = tbt_pk:LocalToGlobal()
        local v1 = cvs.Parent:GlobalToLocal(v,true) 
        

        if v1.x - tbt_pk.Width - cvs.Width > 15 then
            
            cvs.X = v1.x - cvs.Width - tbt_pk.Width - 10
        else
            cvs.X = v1.x 
        end

        if v1.y - tbt_pk.Height - cvs.Height > 15 then
            cvs.Y = v1.y 
        else
            cvs.Y = v1.y
        end
    end

    tbt_pk.event_PointerUp = function( ... )
        
        tbt_pk.IsChecked = false
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIShowXmlTips)
    end
end
local notify ={}
function notify.Notify(status, flagData)
	if self ~= nil and self.menu ~= nil then
		if status == FlagPushData.FLAG_REALM_UPGRADE then
                local num =  DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.REALM)
                num = num == nil and 0 or num

                local realmNext = GlobalHooks.DB.Find("UpLevelExp", { UpOrder = num + 1 })[1]

                local roleLevel=  DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)

                local cultivation =  DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.CULTIVATION)
                cultivation = cultivation == nil and 0 or cultivation

                self.flag = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REALM_UPGRADE)
                if roleLevel >= realmNext.ReqLevel then
                       if self.flag > 0  then
                            if cultivation < realmNext.ReqClassExp then
                                self.sp_redpoint_Level.Visible = false
                            else
                                self.sp_redpoint_Level.Visible = true
                            end
                        else
                                self.sp_redpoint_Level.Visible = false
                        end
                else
                      self.sp_redpoint_Level.Visible = false
                end
		 end

         if status == FlagPushData.FLAG_PROPERTY_EQUIP then

            local flag = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_PROPERTY_EQUIP)
            if flag > 0 then
                for i = 1, #EQUIP_PARTS do  
                     initFilter(itemTab[i],i)
                end

           else 
                return
           end
         end

 	end
end
function _M:OnEnter()










    local s = Util.StringSplit(DataMgr.Instance.UserData.Name,'%.')
    self.lb_qufu1.Text = DataMgr.Instance.UserData.Name
    local ProTable = GlobalHooks.DB.Find('Character',DataMgr.Instance.UserData.Pro)
    self.lb_name.Text = ProTable.ProName
    self.lb_name.FontColorRGBA = GameUtil.GetProColor(DataMgr.Instance.UserData.Pro)
    local pkvalue = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PKVALUE)
    
    if tostring(DataMgr.Instance.UserData:GetPKLv()) == "White" then
        local text = "<f color='ff00A0FF' link='reward'>" .. pkvalue .. "</f>"
        self.tbx_pk:DecodeAndUnderlineLink(text)
        
    else
        local text = "<f color='" .. string.format("%08X",  GameUtil.RGBA_To_ARGB(GameUtil.GetPKLvColor(DataMgr.Instance.UserData:GetPKLv()))) .. "' link='reward'>" .. pkvalue .. "</f>"
        self.tbx_pk:DecodeAndUnderlineLink(text)
        
    end
   

    self.btn_pk.TouchClick = function (sender)
        local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShowXmlTips, 1)
        obj.SetXmlStr(GetShowTips(pkvalue))
        local cvs = obj.content_node
        local v  = self.btn_pk:LocalToGlobal()
        local v1 = cvs.Parent:GlobalToLocal(v,true) 
        v1 = v1 + Vector2.New(0,self.btn_pk.Height)

        if v1.x - self.btn_pk.Width - cvs.Width > 15 then
            
            cvs.X = v1.x - cvs.Width - self.btn_pk.Width - 10
        else
            cvs.X = v1.x + 10
        end

        if v1.y - self.btn_pk.Height - cvs.Height > 15 then
            cvs.Y = v1.y - cvs.Height
        else
            cvs.Y = v1.y
        end
    end



	self.EquipContainer.ItemPack = DataMgr.Instance.UserData.RoleEquipBag
    if DataMgr.Instance.UserData.Guild then
        self.cvs_pro1.Visible = true
        self.cvs_pro1_none.Visible = false
        local lb_xm_name = self.cvs_pro1:FindChildByEditName("lb_xm_name",false)
        lb_xm_name.Text = DataMgr.Instance.UserData.GuildName
        local ib_xm_icon = self.cvs_pro1:FindChildByEditName("ib_xm_icon",false)
        ib_xm_icon.Visible = true
        local icon = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GUILDICON)
        local filepath = 'static_n/guild/'..icon..'.png'
        local layout = XmdsUISystem.CreateLayoutFromFile(filepath, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
        ib_xm_icon.Layout = layout
        local lb_xm_position = self.cvs_pro1:FindChildByEditName("lb_xm_position",false)
        lb_xm_position.Visible = true
        local lb_xm_posname = self.cvs_pro1:FindChildByEditName("lb_xm_posname",false)
        lb_xm_posname.Visible = true
        local job = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GUILDJOB)
        lb_xm_posname.Text = Util.getGuildPosition(job).position
        lb_xm_posname.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(nameColorIndex[job]))
    else
        self.cvs_pro1:FindChildByEditName("ib_xm_icon",false).Visible = false
        self.cvs_pro1:FindChildByEditName("lb_xm_position",false).Visible = false
        self.cvs_pro1:FindChildByEditName("lb_xm_posname",false).Visible = false
        local fInfo = GlobalHooks.DB.Find('OpenLv', "Guild")
        local lv = fInfo.OpenLv
        if(lv > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)) then
            self.cvs_pro1.Visible = false
            self.cvs_pro1_none.Visible = true
            local lb_xm_name = self.cvs_pro1_none:FindChildByEditName("lb_xm_name",false)
            lb_xm_name.Text = string.format(lb_xm_name.UserData,lv)
        else
            self.cvs_pro1.Visible = true
            self.cvs_pro1_none.Visible = false
            local lb_xm_name = self.cvs_pro1:FindChildByEditName("lb_xm_name",false)
            lb_xm_name.Text = Util.GetText(TextConfig.Type.ATTRIBUTE, 124)
        end

    end
    clean3dModel()
    SetAvatar(self,true)
    DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag, self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
    EventManager.Subscribe("Event.Title.TitleChange", OnTitleChanged)
    local gObject = IconGenerator.instance:GetGameObject(self.avatar_show.key)
    gObject:SetActive(true)















        DataMgr.Instance.FlagPushData:AttachLuaObserver(self.menu.Tag, notify)
        notify.Notify(FlagPushData.FLAG_REALM_UPGRADE,self)
        notify.Notify(FlagPushData.FLAG_PROPERTY_EQUIP,self)
        EventManager.Subscribe("Event.UI.PageUIProperty.CheckCanCultivation", CheckIsCanCultivation)
        EventManager.Subscribe("Event.PageUIProperty.ShowEffect", ShowEffect)
        EventManager.Subscribe("Event.PageUIProperty.HideEffect", HideEffect)

        for i = 1, #EQUIP_PARTS  do
            if itemTab ~= nil then
                if itemTab[i] == nil  or itemTab[i].LastItemData == nil  or itemTab[i].LastItemData.detail == nil then
                    if effectTab[i] ~= nil then
                       effectTab[i].Visible = false
                    end
                end
            end
        end

    TitleAPI.requestTitleInfo()
    EventManager.Fire("Event.Title.TitleChange",{titleId = DataMgr.Instance.UserData.TitleId})
end

function _M:OnExit()
    
    
    EventManager.Unsubscribe("Event.UI.PageUIProperty.CheckCanCultivation", CheckIsCanCultivation)

    DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)

    clean3dModel()

    EventManager.Unsubscribe("Event.Title.TitleChange",OnTitleChanged)
    if(self.moreProView) then
        self.moreProView:OnExit()
    end
    self.menu.Visible = false

    DataMgr.Instance.FlagPushData:DetachLuaObserver(self.menu.Tag)
    EventManager.Unsubscribe("Event.PageUIProperty.ShowEffect", ShowEffect)
    EventManager.Unsubscribe("Event.PageUIProperty.HideEffect", HideEffect)
    if CheckIsHideAll() then
        EventManager.Fire("Event.Menu.IsShowHudRedPoint",{showType = "0"})
        DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_PROPERTY_EQUIP,0,true) 
    else
        EventManager.Fire("Event.Menu.IsShowHudRedPoint",{showType = "1"})
    end
end

local function OnDestory(self)
  
    
end

local function ClickItemshow(self,roleEquip, it)
    if (self.uiItemList == nil) then
        self.uiItemList = GameUIEquipmentList.Create(GlobalHooks.UITAG.GameUIRoleEquipmentList,self)
        self.cvs_character:AddChild(self.uiItemList.menu)
        self.uiItemList.menu.X = self.cvs_property.X 
        self.uiItemList.menu.Y = self.cvs_property.Y
    end
    self.uiItemList:setSelectItem(it.LastItemData)
    self.uiItemList:OnEnter()

end

local function ClickGridShow(self,sender)
    if (self.uiItemList == nil) then
        self.uiItemList = GameUIEquipmentList.Create(GlobalHooks.UITAG.GameUIRoleEquipmentList,self)
        self.cvs_character:AddChild(self.uiItemList.menu)
        self.uiItemList.menu.X = self.cvs_property.X 
        self.uiItemList.menu.Y = self.cvs_property.Y
    end
    local index = self.EquipContainer:GetIndex(sender)
    self.uiItemList:setSelectPos(index)
    self.uiItemList:OnEnter()
end

function _M:closeEquipList()
    self.cvs_property.Visible = true
end

function _M:refreshEquipList(item)
    self.uiItemList:setSelectItem(item)
    self.uiItemList:closeOtherItemDetail()

end

local format4 = '+ %d'

local function initEquipments(self)
    local temp_cvs = self.menu:GetComponent(EQUIP_PARTS[1])
    
    self.EquipContainer = HZItemsContainer.New()
    self.EquipContainer.CellSize = temp_cvs.Size2D
    self.EquipContainer.Filter = ItemPack.FilterInfo.New()
    self.EquipContainer.Filter.IsSequence = false
    self.EquipContainer.IsShowLockUnlock = false

    self.EquipContainer.IsShowStrengthenLv = true

    local effectColor = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.Qcolor')
    local effectEnlv = GlobalHooks.DB.GetGlobalConfig('Equipment.Effect.StrengthenLevel')
    self.EquipContainer:AddItemShowInitHandle('itshow', function(con, it)
        local index = self.EquipContainer:GetIndex(it)
        local strength_Pos = ItemModel.GetEquipStrgData(index)
        local strengthSection = 0
        local strengthLv = 0
        local cell = self.menu:GetComponent(EQUIP_PARTS[index])
        local lb_lv = cell:FindChildByEditName("lb_lv",true)
        if strength_Pos ~= nil then
            strengthSection = strength_Pos.enSection
            strengthLv = strength_Pos.enLevel
            local lv = string.format(format4, strengthSection*10+strengthLv)
            local index = self.EquipContainer:GetIndex(it)
            lb_lv.Text = lv
            lb_lv.Visible = true
        end
        if not it.LastItemData then 
            lb_lv.Visible = false
            return 
        end
        local detail = it.LastItemData.detail
        local bind = false
        local effectPath = ''
        
        
        local eff = cell:FindChildByEditName("ib_effect",true)
        eff.Visible=false
        local index_detail = 0
        if detail then
            local bindType = detail.bindType or detail.static.BindType
            
            



            local quality = it.LastItemData.Quality
            if quality == 4 then    
                
                eff.Visible = true
                
            end
            itemTab[index] = it
        end

        local itemIdConfigTypeId = ItemModel.GetSecondType(detail.static.Type)
        local strength_Pos = ItemModel.GetEquipStrgData(itemIdConfigTypeId)
        local strengthSection = 0
        local strengthLv = 0
        if strength_Pos ~= nil then
            strengthSection = strength_Pos.enSection
            strengthLv = strength_Pos.enLevel
            local lv = string.format(format4, strengthSection*10+strengthLv)
            local index = self.EquipContainer:GetIndex(it)
            local cell = self.menu:GetComponent(EQUIP_PARTS[index])
            local lb_lv = cell:FindChildByEditName("lb_lv",true)
            lb_lv.Text = lv
        end
        
        
        
        it:SetNodeConfigVal(HZItemShow.CompType.bind, bind)
    end )

    local function UpdateEquipItem(con, itshow)
        EventManager.Fire("Event.EquipdItemChange", { pos = itshow.LastItemData.Index })
        curSelectIndex = itshow.LastItemData.Index 
    end
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.ADDITEM, UpdateEquipItem)
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.RMITEM, UpdateEquipItem)
    self.EquipContainer:RegisterNotifyAction(ItemPack.NotiFyStatus.UPDATEITEM, UpdateEquipItem)

    self.item_click = function(roleEquip, it)
        ClickItemshow(self, roleEquip, it)
        curSelectIndex = it.LastItemData.Index 
        if it.IsShowRedPoint then
            it.IsShowRedPoint = false
        end 
    end
    local is_setcell = false
    for i = 1, #EQUIP_PARTS do
        local comp = self.menu:GetComponent(EQUIP_PARTS[i])
        if not is_setcell then
            self.EquipContainer.CellSize = comp.Size2D
            is_setcell = true
        end
        comp.UserTag = i
        local item = comp:FindChildByEditName("item",true)
        self.EquipContainer:AddNode(item, i)
        local eff = comp:FindChildByEditName("ib_effect",true)
        table.insert(effectTab,i,eff)

        local redPoint = comp:FindChildByEditName("sp_redpoint",true)
        redPointTab[i] = redPoint
    end

    self.EquipContainer:OpenSelectMode(false, false, nil, function(con, it)
        if not it.IsSelected then
            con:SetSelectItem(it, it.Num+1)
            local index = self.EquipContainer:GetIndex(it)
            if redPointTab ~= nil then
                if redPointTab[index].Visible == true then
                   redPointTab[index].Visible = false
                end
            end
        end
        if not it.LastItemData then
            ClickGridShow(self,it)
            return
        end
        if it:ContainCustomAttribute('detail_tips') then
            it:RemoveCustomAttribute('detail_tips')
            return
        end
        if self.item_click then
            self.item_click(false, it)
        end
    end )
end


local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create("xmds_ui/character/property.gui.xml",tag)
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.cvs_information_detailed.Enable = false
    initEquipments(self)

    self.btn_fashion.TouchClick = function (sender)
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIRoleAttribute)
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIFashionMain, -1)
    end
end

function _M:bindEventItem(item,btn,event)
    self.eventItemDetail:SetItem(item)
    self.eventItemDetail:OnEquip()
end

function _M.Create(tag,parent)
    setmetatable(self,_M)
    InitComponent(self,tag)
    self.parent = parent
    self.parent.cvs_content:AddChild(self.menu)
    self.eventItemDetail = EventItemDetail.Create(3)
    local function callback(sender, name, item)
        if(name == "Event.EquipItem") then
            self:refreshEquipList(item)
        end
    end
    self.eventItemDetail:SubscribCallBack(callback)
    return self
end

_M.SetVisible = SetVisible
return _M

