local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local FriendModel = require 'Zeus.Model.Friend'
local MailRq = require "Zeus.Model.Mail"

local self = {
    menu = nil,
}

local re = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "mailreply")

local function Update_pan(x, y, node)
    local index = y + 1
    node.UserTag = index
    local msg = self.friendlistmsg[index]
    local chooseEfc = node:FindChildByEditName("ib_choose", true)
    local friendIcon = node:FindChildByEditName("ib_face", true)
    local path = "static_n/hud/target/" .. msg.pro .. ".png"
    local layout = XmdsUISystem.CreateLayoutFromFile(path, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
    friendIcon.Layout = layout
    local lvlable = node:FindChildByEditName("lb_lvnum", true)
    lvlable.Text = msg.level
    local namelable = node:FindChildByEditName("lb_name", true)
    namelable.Text = msg.name
    local zhanli = node:FindChildByEditName("lb_zhanlinum", true)
    zhanli.Text = msg.fightPower
    
    
end

local string_num = "（%d/%d）"

local function initFriendsList(parent)
    local lb_number = parent:FindChildByEditName("lb_number",true)
    local scroll_pan = parent:FindChildByEditName("sl_friend", true)
    local cell = parent:FindChildByEditName("cvs_friend", true)
    local addFriendmenu = self.cvsmain:FindChildByEditName("btn_friendtable", true)
    cell.Visible = false
    local cellnum = 0
    if self.friendlistmsg then cellnum = #self.friendlistmsg end
    lb_number.Text = string.format(string_num,cellnum,self.friendMax)
    scroll_pan:Initialize(
    cell.Width,
    cell.Height,
    cellnum,
    
    1,
    
    cell,
    LuaUIBinding.HZScrollPanUpdateHandler(Update_pan),
    LuaUIBinding.HZTrusteeshipChildInit( function(node)
        node.TouchClick = function()
            self.curfriend = self.friendlistmsg[node.UserTag]
            if self.curfriend then
                self.friendName.Text = self.curfriend.name
                self.curfdid = self.curfriend.id
                self.curfdname = self.curfriend.name
                self.cvsmain.Visible = true
                self.friendlist.Visible = false
                addFriendmenu.IsChecked = false
            end
        end
    end )
    )
end

local function ShowFriendList()
    
    self.friendlist.Visible = true
    initFriendsList(self.friendlist)
end

local function findMailTitle()
    for k, v in pairs(self.mailList) do
        if v.id == self.extParam then
            return re .. v.mailTitle
        end
    end
end

local function showWriteingUI()
    local namestr = ""
    self.mailList = MailRq.GetAllMail()
    if self.extParam and self.friendlistmsg then
        for i, v in ipairs(self.mailList) do
            if v.id == self.extParam then
                self.sendplayerid = v.mailSenderId
                break
            end
        end
        for i, v in ipairs(self.friendlistmsg) do
            if v.id == self.sendplayerid then
                namestr = v.name
                self.curfdid = self.sendplayerid
                self.curfdname = namestr
                break
            end
        end
        if string.len(namestr) == 0 then
            for i, v in ipairs(self.friendlistmsg) do
                if v.id == self.extParam then
                    namestr = v.name
                    self.curfdid = self.extParam
                    self.curfdname = namestr
                    break
                end
            end
        end
    end
    local titleinput = self.cvsmain:FindChildByEditName("ti_topic", true)
    if string.len(self.extParam) > 1 then
        self.isWrite = false
        Util.SetInputTextShortText(titleinput, findMailTitle())
        self.titleText = titleinput.Input.Text
        self.isWrite = true
    else
        titleinput.Input.Text = ""
    end
    local oldtxt = ""
    titleinput.event_endEdit = function(sender, txt)
        if string.find(txt, re) and not self.isWrite then
            oldtxt = txt
        end
        if Util.widthString(txt) <= 14 then
            oldtxt = txt
        else
            titleinput.Input.Text = oldtxt
        end
        self.titleText = tostring(oldtxt)
    end
    self.friendName = self.cvsmain:FindChildByEditName("lb_friendname", true)
    self.friendName.Text = namestr

    local addFriendmenu = self.cvsmain:FindChildByEditName("btn_friendtable", true)
    addFriendmenu.TouchClick = function()
        if addFriendmenu.IsChecked == true then
            ShowFriendList()
        else
            self.friendlist.Visible = false
        end
    end

    local numtomax = self.cvsmain:FindChildByEditName("lb_numtomax", true)
    numtomax.Text = "0/300"
    local inputText = self.cvsmain:FindChildByEditName("ti_information", true)
    inputText.Input.characterLimit = 300
    inputText.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineNewline
    inputText.Input.Text = ""
    local oldtext = ""

    inputText.event_endEdit = function(sender, txt)
        
        if Util.widthString(txt) <= 300 then
            oldtext = txt
        else
            inputText.Input.Text = oldtext
        end
        local len = Util.widthString(oldtext)
        numtomax.Text = tostring(len) .. "/300"
        self.contentText = tostring(oldtext)
    end

    local function FindSpac(contstr)
        
        local tab = contstr
        local tab = string.gsub(tab, " ", "")
        if string.len(tab) > 0 then
            return true
        else
            return false
        end
    end

    local sendbtn = self.cvsmain:FindChildByEditName("bt_sendout", true)
    sendbtn.TouchClick = function()
        if self.titleText == nil then
            
            self.titleText = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "sendnotitle")
        end

        if self.curfriend then
            if self.contentText == nil then
                GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "noinfo"))
                return
            end
            
            if FindSpac(self.contentText) then
                MailRq.MailSendMailRequest(self.curfriend.id,
                self.titleText, self.contentText, 1, self.curfriend.name,
                function()
                    GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "sendsuccess"))
                    self.menu:Close()
                end
                )
            else
                GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "noinfo"))
            end
        else
            if self.curfdid == nil then
                GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "nochose"))
            else
                if self.contentText == nil then
                    GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "noinfo"))
                    return
                end
                
                if FindSpac(self.contentText) then
                    MailRq.MailSendMailRequest(self.curfdid,
                    self.titleText, self.contentText, 1, self.curfdname,
                    function()
                        GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "sendsuccess"))
                        self.menu:Close()
                    end
                    )
                else
                    GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "noinfo"))
                end

            end
        end
    end
end

local function OnEnter()
    self.extParam = self.menu.ExtParam
    FriendModel.friendGetAllFriendsRequest( function(params)
        print(PrintTable(params))
        self.friendlistmsg = params.friends
        self.friendMax = params.friendsNumMax
        showWriteingUI()
    end )
end

local function OnExit()
    
    self.contentText = nil
    self.curfriend = nil
    self.titleText = nil
    self.friendlist.Visible = false
    self.cvsmain:FindChildByEditName("btn_friendtable", true).IsChecked = false
end

local function InitCompnent()
    self.cvsmain = self.menu:FindChildByEditName("cvs_main", true)
    self.friendlist = self.menu:FindChildByEditName("cvs_friendlist", true)
    self.cvsmain.Visible = true
    self.friendlist.Visible = false
    local closebtn = self.cvsmain:FindChildByEditName("bt_close", true)
    closebtn.TouchClick = function()
        self.menu:Close()
    end
    
    
    
    
    
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/mail/mail_type.gui.xml", GlobalHooks.UITAG.GameUIInMail)
    local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png', LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    InitCompnent()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory( function()
        self = nil
    end )
    return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
    local node = Init(params)
    return node
end

return { Create = Create }
