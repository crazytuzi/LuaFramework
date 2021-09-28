local _M = { }
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemEar = require "Zeus.Model.Item"

local self = {
    menu = nil,
}

local MailRq = require "Zeus.Model.Mail"
local MailList = { }
local friendMsg = { }
local curMailIndex = 0
local curMailId = nil
local oldNode = nil
local _initui
local readMailArr = { }
local mailState = {
    
}

local mailPic =
{
    [1] = "#dynamic_n/mail/mail.xml|mail|3",
    [2] = "#dynamic_n/mail/mail.xml|mail|2",
    [3] = "#dynamic_n/mail/mail.xml|mail|1",
    [4] = "#dynamic_n/mail/mail.xml|mail|4"
}

local mailColor =
{
    bai = 0xe7e5d1ff,
    hong = 0xf43a1cff,
    lan = 0x448cd5ff,
    chen = 0xef880eff,
    nv = 0x5bc61aff,
    huang = 0xffba00ff
}


local mailID =
{
    [1] = "20201",
    [2] = "20202",
    [3] = "20203",
    [4] = "20204",
    [5] = "20205"
}

local mailCode =
{
    [1] = "MailTest1",
    [2] = "MailTest2",
    [3] = "MailTest3",
    [4] = "",
    [5] = ""
}

local function clearCurMail()
    if self.lbname then
        self.lbname.Visible = false
        self.lbtime.Visible = false
    end
    curMailIndex = 0
    oldNode = nil
    curMailId = nil
end

local function setImage(name, path)
    local ring = self.menu:FindChildByEditName(name, true)
    local layout = XmdsUISystem.CreateLayoutFromFile(path, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
    ring.Layout = layout
end

local function setNameAndTimePos(cvsP, lable, name, time)
    local lableY = LuaUIBinding.GetRichTextBox(lable).PreferredSize.y
    self.lbname = cvsP:FindChildByEditName("mail_usname", true)
    self.lbtime = cvsP:FindChildByEditName("mail_sendtime", true)
    self.lbname.Visible = true
    self.lbtime.Visible = true
    local num = math.floor(time / 1000)
    local tab = os.date("*t", num)
    local timestr = tab.year .. "-" .. tab.month .. "-" .. tab.day
    self.lbname.Text = name
    self.lbtime.Text = timestr
    self.lbname.Y = lableY + 10
    self.lbtime.Y = lableY + 35
end

local function addNameTime(strrr)
    
    local str = strrr
    local strrrrr = string.gsub(str, "$e", 77)
    
    local strr = "<b color='ffe7e5d1'><f size='22'>" .. strrrrr .. "</f></b>"
    return strr
end

local function update_List(x, y, node, senum)
    local index = x + 1
    node.UserTag = index
    node.Visible = true
    local ib_itemicon = node:FindChildByEditName("ib_itemicon",false)
    local item = Util.ShowItemShow(ib_itemicon, MailList[senum].attachment[index].icon, MailList[senum].attachment[index].qColor, MailList[senum].attachment[index].groupCount)
    ib_itemicon.Enable = true
    ib_itemicon.EnableChildren = true
    
    
    if MailList[senum].newAttachment then
        local detail = ItemEar.GetItemDetailByCode(MailList[senum].newAttachment[index].code)
        ItemEar.SetDynamicAttrToItemDetail(detail,MailList[senum].newAttachment[index])
        
        
        
        
        

        
        if detail and detail.equip then
            Util.ItemShow_MandatoryBindTypeTouchClick(item, MailList[senum].newAttachment[index].code, nil, MailList[senum].newAttachment[index].bindType, detail)
        else
            Util.NormalItemShowTouchClick(item, MailList[senum].newAttachment[index].code, false)
        end
    elseif MailList[senum].itemEar then
        item.EnableTouch = true
        item.TouchClick = function()
            EventManager.Fire("Event.ShowItemDetail", { id = MailList[senum].itemEar[1].id })
        end
    else
        local detail = ItemEar.GetItemDetailByCode(MailList[senum].attachment[index].code)
        if detail and detail.equip then
            Util.ItemShow_MandatoryBindTypeTouchClick(item, MailList[senum].attachment[index].code, nil, MailList[senum].attachment[index].bindType, detail)
        else
            Util.NormalItemShowTouchClick(item, MailList[senum].attachment[index].code, false)
        end
    end

end

local function InitIconScoll(senum)
    local scroll_icon = self.menu:FindChildByEditName("sp_item", true)
    local cell = self.menu:FindChildByEditName("cvs_item", true)
    cell.Visible = false
    local num = 0
    if MailList[senum].attachment then
        num = #MailList[senum].attachment
    end
    scroll_icon:Initialize(
        cell.Width + 5,
        cell.Height,
        1,
        
        num,
        
        cell,
        function(x,y,node)
            update_List(x, y, node, senum)
        end,
        LuaUIBinding.HZTrusteeshipChildInit( function(node)

        end )
    )
end

local function mailContent(index)
    if index == 0 then
        local cvs = self.menu:FindChildByEditName("cvs_content2", true)
        self.menu:FindChildByEditName("cvs_content1", true).Visible = false
        cvs.Visible = true
        
        
        
        
        
        
        
        
        
        
        
        
    else
        if MailList[index].hadAttach == 2 then
            if MailList[index].attachment ~= nil then
                
                
                self.menu:FindChildByEditName("cvs_content1", true).Visible = true
                self.menu:FindChildByEditName("cvs_content2", true).Visible = false
                local cvs = self.menu:FindChildByEditName("cvs_content1", true)
                
                
                local title = cvs:FindChildByEditName("lb_theme", true)
                title.Text = MailList[index].mailTitle
                local content = cvs:FindChildByEditName("tb_content_deatil", true)
                local str = addNameTime(MailList[index].mailText)
                content.XmlText = str
                
                local lb_set_man = cvs:FindChildByEditName("lb_set_man", true)
                lb_set_man.Text = MailList[index].mailSender
                local num = math.floor(MailList[index].createTime / 1000)
                local tab = os.date("*t", num)
                local timestr = tab.year .. "." .. tab.month .. "." .. tab.day
                local lb_set_date = cvs:FindChildByEditName("lb_set_date", true)
                lb_set_date.Text = timestr
                cvs:FindChildByEditName("cvs_enclosure", true).Visible = true
                local scoll = self.menu:FindChildByEditName("sp_item", true)
                scoll.Visible = true
                InitIconScoll(index)
            else
                
                
                self.menu:FindChildByEditName("cvs_content1", true).Visible = true
                self.menu:FindChildByEditName("cvs_content2", true).Visible = false
                local cvs = self.menu:FindChildByEditName("cvs_content1", true)


                local title = cvs:FindChildByEditName("lb_theme", true)
                title.Text = MailList[index].mailTitle
                local content = cvs:FindChildByEditName("tb_content_deatil", true)
                local str = addNameTime(MailList[index].mailText)
                content.XmlText = str
                
                local lb_set_man = cvs:FindChildByEditName("lb_set_man", true)
                lb_set_man.Text = MailList[index].mailSender
                local num = math.floor(MailList[index].createTime / 1000)
                local tab = os.date("*t", num)
                local timestr = tab.year .. "." .. tab.month .. "." .. tab.day
                local lb_set_date = cvs:FindChildByEditName("lb_set_date", true)
                lb_set_date.Text = timestr
                cvs:FindChildByEditName("cvs_enclosure", true).Visible = false
            end
        else
            if MailList[index].status == 3 then
                
                
                self.menu:FindChildByEditName("cvs_content1", true).Visible = true
                self.menu:FindChildByEditName("cvs_content2", true).Visible = false
                local cvs = self.menu:FindChildByEditName("cvs_content1", true)
                
                
                local title = cvs:FindChildByEditName("lb_theme", true)
                title.Text = MailList[index].mailTitle
                local content = cvs:FindChildByEditName("tb_content_deatil", true)
                local str = addNameTime(MailList[index].mailText)
                content.XmlText = str
                
                local lb_set_man = cvs:FindChildByEditName("lb_set_man", true)
                lb_set_man.Text = MailList[index].mailSender
                local num = math.floor(MailList[index].createTime / 1000)
                local tab = os.date("*t", num)
                local timestr = tab.year .. "." .. tab.month .. "." .. tab.day
                local lb_set_date = cvs:FindChildByEditName("lb_set_date", true)
                lb_set_date.Text = timestr
                cvs:FindChildByEditName("cvs_enclosure", true).Visible = true
                local scoll = self.menu:FindChildByEditName("sp_item", true)
                scoll.Visible = false
            else
                
                
                self.menu:FindChildByEditName("cvs_content2", true).Visible = false
                self.menu:FindChildByEditName("cvs_content1", true).Visible = true
                local cvs = self.menu:FindChildByEditName("cvs_content1", true)
                local title = cvs:FindChildByEditName("lb_theme", true)
                title.Visible = true
                title.Text = MailList[index].mailTitle
                local content = cvs:FindChildByEditName("tb_content_deatil", true)
                local lb_set_man = cvs:FindChildByEditName("lb_set_man", true)
                lb_set_man.Text = MailList[index].mailSender
                local str = addNameTime(MailList[index].mailText)
                content.XmlText = str
                local num = math.floor(MailList[index].createTime / 1000)
                local tab = os.date("*t", num)
                local timestr = tab.year .. "." .. tab.month .. "." .. tab.day
                local lb_set_date = cvs:FindChildByEditName("lb_set_date", true)
                lb_set_date.Text = timestr
                cvs:FindChildByEditName("cvs_enclosure", true).Visible = false
            end
        end
    end
end

local function MenusVisible(index)
    local oneBtnRemov = self.menu:FindChildByEditName("btn_delete_all", true)
    local oneBtnGet = self.menu:FindChildByEditName("btn_receive_all", true)
    local reply = self.menu:FindChildByEditName("btn_reply", true)
    local get = self.menu:FindChildByEditName("btn_receive", true)
    


    if index == 0 then
        oneBtnRemov.Visible = true
        oneBtnGet.Visible = true
        reply.Visible = false
        get.Visible = false
        
    else
        reply.Visible = true
        if MailList[index].mailType == 1 then
            reply.Enable = true
            reply.IsGray = false
            get.Visible = false
            
        else
            if MailList[index].attachment ~= nil then
                reply.Enable = false
                reply.IsGray = true
                get.Visible = true
                
            else
                reply.Enable = false
                reply.IsGray = true
                get.Visible = false
                
            end
        end
    end
end

local function Update_pan(x, y, node)
    local index = y + 1
    node.UserTag = index
    local ischoose = node:FindChildByEditName("ib_choose", true)
    if curMailIndex == index then
        ischoose.Visible = true
    else
        ischoose.Visible = false
    end
    local img_readed = node:FindChildByEditName("ib_mailtype", true)
    local img_unReaded = node:FindChildByEditName("ib_mailunread",true)
    local img_noGetItems = node:FindChildByEditName("ib_yl",true)
    local img_getItems = node:FindChildByEditName("ib_wl",true)
    img_readed.Visible = false
    img_unReaded.Visible = false
    img_noGetItems.Visible = false
    img_getItems.Visible = false
    local isPlay = false
    if MailList[index].hadAttach == 2 then
        if MailList[index].status == 3 then
            img_readed.Visible = true
            img_getItems.Visible = true
        elseif MailList[index].status == 2 then
            img_readed.Visible = true
            img_noGetItems.Visible = true
        else
            img_unReaded.Visible = true
            img_noGetItems.Visible = true
        end
    else
        if MailList[index].status == 1 then
            img_unReaded.Visible = true
        else
            img_readed.Visible = true
        end










    end
















    
    
    local nc = 0xffe7e5d1
    
    if MailList[index].mailType == 1 then
        
        
        nc = GameUtil.GetProColor(MailList[index].mailIcon)
        
    elseif MailList[index].mailType == 2 then
        
        
        nc = mailColor.chen
    else
        
        
        nc = mailColor.hong
    end

    local biaoji = node:FindChildByEditName("lb_flag", true)
    

    if MailList[index].status == 1 then
        biaoji.Visible = true
    else
        biaoji.Visible = false
    end

    local name = node:FindChildByEditName("lb_who", true)
    name.Text = MailList[index].mailSender
    name.FontColor = GameUtil.RGBA2Color(nc)
    local time = node:FindChildByEditName("lb_time", true)
    local num = math.floor((MailList[index].createTime) / 1000)
    local curtime = os.time()
    local str = ""
    local chazhi = curtime - num
    local mc = 0xffe7e5d1
    
    if chazhi < 7200 then
        str = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "just")
        
        mc = mailColor.huang
    elseif chazhi < 86400 and chazhi > 7200 then
        local tab1 = os.date("*t", num)
        local tab2 = os.date("*t", curtime)
        if tab2.day == tab1.day then
            str = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "today")
            
            mc = mailColor.lan
        else
            str = tab1.year .. "-" .. tab1.month .. "-" .. tab1.day
            mc = mailColor.bai
        end
    else
        local tab = os.date("*t", num)
        str = tab.year .. "-" .. tab.month .. "-" .. tab.day
        mc = mailColor.bai
    end

    time.Text = str
    time.FontColor = GameUtil.RGBA2Color(mc)
    local title = node:FindChildByEditName("lb_title", true)
    title.Text = MailList[index].mailTitle
end

local function changeIcon(node, msg)
    local img_readed = node:FindChildByEditName("ib_mailtype", true)
    local img_unReaded = node:FindChildByEditName("ib_mailunread",true)
    local img_noGetItems = node:FindChildByEditName("ib_yl",true)
    local img_getItems = node:FindChildByEditName("ib_wl",true)
    img_readed.Visible = false
    img_unReaded.Visible = false
    img_noGetItems.Visible = false
    img_getItems.Visible = false
    local isPlay = false



























    if msg.hadAttach == 2 then
        if msg.status == 3 then
            img_readed.Visible = true
            img_getItems.Visible = true
        elseif msg.status == 2 then
            img_readed.Visible = true
            img_noGetItems.Visible = true
        else
            img_unReaded.Visible = true
            img_noGetItems.Visible = true
        end
    else
        if msg.status == 1 then
            img_unReaded.Visible = true
        else
            img_readed.Visible = true
        end
    end
    local biaoji = node:FindChildByEditName("lb_flag", true)
    
    if msg.status == 1  then
        biaoji.Visible = true
    else
        biaoji.Visible = false
    end
end

local function readmailbefor(id, type)
    for k, v in pairs(MailList) do
        if id == v.id then
            if v.status == 1 then
                v.status = 2
            end
            break
        end
    end
end

local function init_pan(node)
    node.TouchClick = function(sender)
        if oldNode == nil then
            oldNode = node
        else
            oldNode:FindChildByEditName("ib_choose", true).Visible = false
        end
        oldNode = node
        curMailIndex = node.UserTag
        node:FindChildByEditName("ib_choose", true).Visible = true
        node:FindChildByEditName("lb_flag", true).Visible =(MailList[curMailIndex].attachment ~= nil and table.getCount(MailList[curMailIndex].attachment or { }) > 1)
        
        curMailId = MailList[curMailIndex].id
        mailContent(node.UserTag)
        MenusVisible(node.UserTag)
        local arr = { }
        arr[1] = MailList[curMailIndex].id
        table.insert(readMailArr, MailList[curMailIndex].id)
        MailRq.readMail(arr, true)
        readmailbefor(MailList[curMailIndex].id, MailList[curMailIndex].hadAttach)
        changeIcon(node, MailList[curMailIndex])
    end
end

local function initScroll()
    local nummax = MailRq.GetMaxMailNum()
    local curmail = #MailList
    local mailnumAll = self.menu:FindChildByEditName("lb_mail_num", true)
    mailnumAll.Text = '(' .. curmail .. '/' .. nummax .. ')'
    local scroll_pan = self.menu:FindChildByEditName("sp_seemail", true)
    local cell = self.menu:FindChildByEditName("cvs_mailinformation", true)
    cell.Visible = false
    scroll_pan:Initialize(
    cell.Width,
    cell.Height,
    #MailList,
    
    1,
    
    cell,
    LuaUIBinding.HZScrollPanUpdateHandler(Update_pan),
    LuaUIBinding.HZTrusteeshipChildInit(init_pan)
    )
end

local function btnBack(sender)
    
    
    local tag = sender.UserTag
    if not MailList[1] then
        if tag == 1 then
            GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "noshanchu"))
            return
        elseif tag == 2 then
            GameAlertManager.Instance:ShowNotify(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "nolingqu"))
            return
        end
    end
    if tag == 1 then
        GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL,
        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "suredelall"),
        
        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "yes"),
        
        ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "no"),
        
        nil,
        function()
            MailRq.MailDeleteOneKeyRequest( function()
                clearCurMail()
                _initui()
            end )
        end , nil)
    elseif tag == 2 then
        if MailList ~= nil then
            MailRq.MailGetAttachmentOneKeyRequest( function()
                clearCurMail()
                _initui()
            end )
        end
    elseif tag == 3 then
        
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIInMail, 0, MailList[curMailIndex].id)
    elseif tag == 4 then
        if curMailId ~= nil then
            MailRq.MailGetAttachmentRequest(curMailId, function()
                clearCurMail()
                _initui()
            end )
        end
    else
        
        if curMailId ~= nil then
            MailRq.MailDeleteRequest(MailList[curMailIndex].mailRead, curMailId, function()
                clearCurMail()
                _initui()
            end )
        end
    end

end

local function writeBack(sender)
    
    
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIInMail, 0)

end

local function initBtn()
    local oneBtnRemov = self.menu:FindChildByEditName("btn_delete_all", true)
    local oneBtnGet = self.menu:FindChildByEditName("btn_receive_all", true)
    local reply = self.menu:FindChildByEditName("btn_reply", true)
    local get = self.menu:FindChildByEditName("btn_receive", true)
    
    oneBtnRemov.TouchClick = btnBack
    oneBtnRemov.UserTag = 1
    oneBtnGet.TouchClick = btnBack
    oneBtnGet.UserTag = 2
    reply.TouchClick = btnBack
    reply.Visible = false
    reply.UserTag = 3
    get.TouchClick = btnBack
    get.Visible = false
    get.UserTag = 4
    
    
    

    local writeBtn = self.menu:FindChildByEditName("btn_write", true)
    writeBtn.TouchClick = writeBack
end

local function MailIsNull()
    self.menu:FindChildByEditName("cvs_mailinformation", true).Visible = false
    self.menu:FindChildByEditName("btn_reply", true).Visible = false
    self.menu:FindChildByEditName("btn_receive", true).Visible = false
    
    
    
    local cvs = self.menu:FindChildByEditName("cvs_content2", true)
    self.menu:FindChildByEditName("cvs_content1", true).Visible = false
    cvs.Visible = true
    local text = self.menu:FindChildByEditName("tb_nomail1", true)
    text.TextComponent.Anchor = TextAnchor.C_C 
    text.Visible = true
    text = self.menu:FindChildByEditName("tb_nomail", true)
    text.TextComponent.Anchor = TextAnchor.C_C 
    text.Visible = true
    text.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAIL, "nomail")
    
    
    
    
    
    
    
    
    
    
    
end

local function HaveSomeMail()
    self.menu:FindChildByEditName("tb_nomail1", true).Visible = false
end

local function SetItemEar()
    if MailList then
        for k, v1 in pairs(MailList) do
            if v1.itemEar then
                for k, v2 in pairs(v1.itemEar) do
                    if not v2.code then v2.code = "rewardEar" end
                    ItemEar.SetEarItem( { [1] = v2 })
                end
            end
        end
    end
end

local function initUI()
    MailList = MailRq.GetAllMail()
    
    SetItemEar()
    if MailList == nil then MailList = { } end
    if MailList[1] == nil then
        initScroll()
        MailIsNull()
        return
    end
    HaveSomeMail()
    initScroll()
    mailContent(0)
    MenusVisible(0)
end
_initui = initUI

local function OnEnter()
    self.extParam = self.menu.ExtParam
    initUI()
    if string.len(self.extParam) > 1 then
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIInMail, 0, self.extParam)
    end
end

local function OnExit()
    MailRq.readMail(readMailArr, true)
    readMailArr = { }
    clearCurMail()
    if self.lbname then
        self.lbname.Visible = false
        self.lbtime.Visible = false
    end
end

local function InitCompnent()
    local closebtn = self.menu:FindChildByEditName("btn_close", true)
    local touch = {
        node = closebtn,
        click = function()
            self.menu:Close()
        end
    }
    LuaUIBinding.HZPointerEventHandler(touch)
    
    
    
    

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory( function()
        self = nil
    end )
    initBtn()
end


local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/mail/mail_new.gui.xml", GlobalHooks.UITAG.GameUIMail)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.ShowType = UIShowType.HideBackHud
    InitCompnent()
    return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
    local node = Init(params)
    return node
end

local function initial()
    
end

return { Create = Create, initial = initial }
